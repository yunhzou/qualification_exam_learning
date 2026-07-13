# On-Policy Distillation

## Primary sources

**Kevin Lu and Thinking Machines Lab.** "On-Policy Distillation." *Thinking Machines Lab: Connectionism*, October 27, 2025. DOI: [10.64434/tml.20251026](https://doi.org/10.64434/tml.20251026).

- [Official article](https://thinkingmachines.ai/blog/on-policy-distillation/)
- [Maintained Tinker recipe](https://tinker-docs.thinkingmachines.ai/cookbook/recipes/distillation/)
- Executable study: `notebooks/03_on_policy_distillation.ipynb`

This is a technical article with a DOI, not a conventional conference paper. Treat the article as the conceptual source and the recipe as changing implementation documentation. The recipe currently uses Qwen3.5-9B-Base as the student and Qwen3.5-9B as the teacher; the original article reports Qwen3-8B-Base students and Qwen3-8B or Qwen3-32B teachers.

## Central idea

On-policy distillation (OPD) samples trajectories from the current student, then asks a fixed teacher for a dense token-level distribution on every student-generated prefix. Its most useful contrast is:

| Method | Prefix/state distribution | Feedback |
|---|---|---|
| SFT or offline distillation | Fixed dataset, often teacher-generated | Dense token targets or teacher probabilities |
| Outcome-reward RL | Current student | Sparse scalar reward |
| On-policy distillation | Current student | Dense teacher distribution at each token |

For a student-visited prefix (s_t), the article minimizes reverse KL:

\[
D_{\mathrm{KL}}\!\left(\pi_S(\cdot\mid s_t)\,\|\,\pi_T(\cdot\mid s_t)\right)
= \sum_a \pi_S(a\mid s_t)
\left[\log \pi_S(a\mid s_t)-\log \pi_T(a\mid s_t)\right].
\]

The prefix distribution is the important part: the teacher evaluates states the student actually reaches, including mistakes and recovery states that clean teacher demonstrations may omit. This connects OPD to online imitation learning and DAgger.

## What the article reports

- In a Qwen3 reasoning experiment, OPD reaches approximately 70% AIME accuracy after about 150 updates using roughly 77,000 prompts and four samples per prompt.
- The article reports 7--10 times fewer gradient steps and 50--100 times less cumulative compute than RL in a controlled teacher-recovery experiment.
- It attributes the sample-efficiency difference to dense feedback: token-level teacher probabilities provide information throughout a trajectory, while a scalar outcome reward supplies only episode-level information.
- A strong initialization still matters. If useful teacher behavior has negligible probability under the student, on-policy sampling will rarely expose it and larger batches or another initialization/data stage may be necessary.
- The authors use zero future-reward discount in the presented formulation and report that future discounts did not help in their experiments.
- Reusing prompts is acceptable because the student's changing trajectory distribution continues to produce new states and training signal.

These are results from the authors' systems and tasks, not general guarantees. Record model versions, compute accounting, evaluation protocol, and the distinction between the original article and maintained recipe when citing them.

## Algorithm checklist

1. Draw prompts and all conditioning fields from a deliberate training distribution.
2. Generate completions from a snapshot of the current student policy.
3. Run the teacher on the exact same prompt and student-generated prefixes.
4. Mask prompt, padding, tool/environment, and other non-student tokens.
5. Compute token-level reverse KL on eligible positions.
6. Update only the student; keep the teacher fixed.
7. Refresh rollouts frequently enough that they remain representative of the updated student.
8. Track task performance, student-teacher KL, entropy, response length, support failures, and regressions outside the distillation domain.

## Conditioning and system prompts

A fixed system prompt is part of every state. If it never varies, the student can absorb it as a constant correlation, so later changing or removing it may not behave like a clean control switch. This is a data-distribution issue rather than an OPD-specific solution. Decide which invariances are required, then train and evaluate across the relevant prompt variants. Keep policy loss off environment/tool tokens in multi-turn traces, while still retaining those tokens in the prefix seen by both models.

## Resource model

Let (P_S) and (P_T) be student and teacher parameter counts and let (T) be the number of processed tokens. A dense Transformer forward pass is approximately (2PT) floating-point operations; the student forward plus backward is approximately (6P_ST). OPD additionally needs student generation and a teacher forward pass, so a rough no-reuse total is (8P_ST + 2P_TT), before attention, communication, sampling, and recomputation details.

Full-parameter Adam training in FP32 needs roughly 16 bytes per trainable student parameter for weights, gradients, and two optimizer moments, excluding activations. The fixed teacher needs weights but no gradients or optimizer state. Token activations, KV cache, and full teacher/student logits can dominate depending on batch size, sequence length, width, and vocabulary; avoid retaining the full (batch x length x vocabulary) logits when chunked KL computation is available. LoRA reduces trainable-state memory but not the need to run the base student and teacher forwards.

## Critical questions

1. When does the teacher's strategy lie outside the student's practical support?
2. Does reverse KL copy only one teacher mode, and is that desirable for the task?
3. How stale can rollouts become before the procedure is meaningfully off-policy?
4. Is the teacher calibrated on erroneous, tool-generated, or adversarial student prefixes?
5. Which tokens should receive loss in multi-turn agent trajectories?
6. Does matching the teacher preserve or reduce useful student diversity?
7. How does OPD compare with SFT and RL under equal wall-clock, total FLOPs, and teacher-inference budgets?
8. Can OPD maintain a discovered strategy efficiently while RL or search continues to discover new strategies?

## Scope of the notebook

The notebook implements exact reverse KL over a six-action toy vocabulary. It deliberately creates recovery states absent from fixed teacher trajectories and shows that on-policy prefixes teach those states. It does not reproduce the scale, asynchronous infrastructure, long-context reasoning, or benchmark results in the article.
