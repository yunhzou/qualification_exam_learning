# Exact Token Trajectories in RL and On-Policy Distillation

## Tokens, not decoded text, are the policy actions

For language-model reinforcement learning, the rollout policy samples a token trajectory:

\[
y = (y_1, y_2, \ldots, y_T), \qquad
y_t \sim \pi_{\mathrm{old}}(\cdot \mid x, y_{<t}).
\]

The decoded string is an environment-facing view of that trajectory. It is not a lossless record of the policy actions.

Suppose the rollout samples:

```text
sampled token IDs: [258, 259]
decoded text:      " tokenization"
```

If deterministic re-encoding returns `[900]`, the reconstructed sequence has one action instead of two. It is not the sampled RL trajectory even though the text is identical.

## Why retokenization invalidates a policy update

PPO- and GRPO-style objectives use the probability ratio for the exact sampled action:

\[
\rho_t =
\frac{\pi_\theta(y_t \mid x,y_{<t})}
     {\pi_{\mathrm{old}}(y_t \mid x,y_{<t})}.
\]

The original rollout contains:

```text
pi_old(258 | prompt)
pi_old(259 | prompt, 258)
```

The canonical re-encoding instead asks for:

```text
pi_old(900 | prompt)
```

These probabilities are not interchangeable. Training on the reconstructed path can corrupt importance ratios, clipping, token advantages, KL penalties, response lengths, EOS handling, and reward-to-token alignment. The update is no longer an exact on-policy update for the observed actions.

## Minimum rollout record

An RL system should retain at least:

```python
{
    "prompt_ids": [...],
    "response_ids": [...],       # exact sampled IDs
    "old_logprobs": [...],       # aligned with response_ids
    "loss_mask": [...],
    "reward_or_advantage": [...],
    "policy_version": 42,
    "sampling_parameters": {...},
    "decoded_text": "...",       # useful, but not authoritative
}
```

The exact requirements depend on whether log probabilities and advantages are recomputed, but the original response IDs must not be replaced by decoded-and-retokenized text.

## Multi-turn agent trajectories

An agent alternates between policy tokens and external observations:

```text
prompt -> assistant action -> tool/environment output -> assistant action
```

Assistant actions should retain their exact sampled IDs. External tool output begins as text or structured data and must be encoded before the next policy turn. Those observation IDs remain in context but should normally be masked out of the policy loss:

```text
segment                         loss mask
prompt and system tokens        0
sampled assistant tokens        1
tool/environment observations   0
next sampled assistant tokens   1
```

Serving layers may strip stop tokens, normalize text, or reconstruct chat messages. The rollout record should preserve the pre-postprocessing IDs and explicit ownership boundaries before these transformations.

## The same-text, different-token-path problem in OPD

On-policy distillation evaluates a teacher on the exact state reached by the student. At a student prefix `s`, token-level reverse KL is:

\[
D_{\mathrm{KL}}(\pi_S(\cdot\mid s)\|\pi_T(\cdot\mid s))
= \sum_a \pi_S(a\mid s)
\left[\log\pi_S(a\mid s)-\log\pi_T(a\mid s)\right].
\]

Return to the vocabulary:

```text
900 -> " tokenization"
258 -> " token"
259 -> "ization"
```

At the beginning of the word, suppose:

```text
student: high probability on 258, planning to emit 259 next
teacher: high probability on 900
```

Both paths can produce exactly `" tokenization"`, but the first-token KL treats IDs `258` and `900` as different actions. It penalizes the student's probability on `258`. After the student has emitted `258`, the teacher evaluates that exact prefix and may correctly place high probability on `259`, but the penalty at the earlier fork has already occurred.

The concern is therefore real:

> Token-level distillation matches distributions over token paths, not equivalence classes of decoded strings or meanings.

If `D(y)` decodes a token path and `z` is a byte string, a tokenization-invariant string probability would be:

\[
P(z) = \sum_{y:\,D(y)=z} P(y).
\]

Ordinary token-level KL does not compute this sum. Marginalizing over every variable-length token path is generally expensive.

## When is this harmful?

The penalty may merely encourage a more canonical, shorter token path. It becomes more concerning when:

- teacher and student were trained with different canonical segmentation behavior;
- they use different tokenizers or vocabulary-ID mappings;
- code, whitespace, Unicode, or partial-word boundaries create many equivalent paths;
- the student explores noncanonical paths during high-temperature RL rollouts;
- token-level process rewards are attached to positions that move after retokenization;
- stop strings or special tokens are stripped by the inference service;
- the OPD weight is strong enough to suppress otherwise correct exploration.

With the same tokenizer and similar pretraining, both models usually learned the same canonical paths, which limits but does not mathematically eliminate the issue.

## Different teacher and student tokenizers

Direct logit KL assumes a shared action space. If the teacher and student vocabularies differ, index `a` does not name the same token in both distributions. A token-by-token KL is then undefined even if both models decode to the same language.

Possible alternatives include sequence-level distillation, teacher-generated canonical text followed by student SFT, byte/string-level alignment, or a learned mapping between representations. Each changes the objective or sacrifices the simple dense on-policy KL. Using a shared tokenizer is the usual practical choice when logit distillation is required.

## Practical safeguards

1. Use the exact same tokenizer files, ID ordering, normalization, special tokens, and chat template in rollout and training engines.
2. Store original sampled IDs and per-token metadata; store decoded text only as an additional view.
3. Evaluate teacher and reference models on the exact student-generated ID prefixes when they share the vocabulary.
4. Test `encode(decode(ids)) == ids` on rollout samples and report how often it fails. Do not require equality to train; use failures to detect unsafe text reconstruction.
5. Preserve EOS and stop tokens before serving-layer postprocessing.
6. Maintain explicit masks and segment ownership for assistant, tool, environment, and padding tokens.
7. Compare inference-engine and training-engine log probabilities on identical IDs and prefixes.
8. Monitor KL by token category, especially whitespace, Unicode, code, special tokens, and noncanonical round trips.
9. Retain outcome or semantic evaluation alongside token KL so path matching is not mistaken for task correctness.
10. Treat tokenization-invariant or cross-tokenizer distillation as a different research problem rather than silently comparing unmatched logits.

## Relation to the learning notebooks

- The SFT notebook should tokenize the formatted sequence consistently and mask prompt rather than response targets.
- The GRPO notebook conceptually requires exact rollout actions for old-policy probability ratios.
- The OPD notebook requires teacher feedback on the exact student state and should interpret its KL as token-path matching.

## Takeaway

Decoded text is sufficient for many environment rewards, but it is not sufficient to reconstruct an RL or OPD trajectory. Exact sampled token IDs define the actions. Even with those IDs preserved, token-level KL can penalize an alternative subword path that would decode to the same correct text; shared tokenizers and canonical pretraining reduce this mismatch, while true tokenization invariance requires a more expensive sequence- or string-level objective.
