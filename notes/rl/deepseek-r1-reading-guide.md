# RL Anchor Paper: DeepSeek-R1

## Paper

**DeepSeek-AI et al.** "DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning." arXiv:2501.12948v2, 2026. Related peer-reviewed article: Guo et al., "DeepSeek-R1 incentivizes reasoning in LLMs through reinforcement learning," *Nature* 645, 633-638 (2025), DOI: [10.1038/s41586-025-09422-z](https://doi.org/10.1038/s41586-025-09422-z).

- [arXiv abstract and source](https://arxiv.org/abs/2501.12948)
- [Nature version of record](https://www.nature.com/articles/s41586-025-09422-z)
- Local PDF: `papers/deepseek-r1-arxiv-2501.12948v2.pdf` (ignored by Git)

This paper is the anchor for the reinforcement-learning part of the curriculum. It should be read as a concrete reasoning-RL system and a source of hypotheses, not as a complete introduction to reinforcement learning.

## Why this paper anchors the RL module

The paper connects the main algorithmic and systems questions we want to study:

- policy-gradient optimization of a decoder-only LLM;
- multiple sampled completions for each prompt;
- group-relative advantages instead of a learned value critic;
- outcome and format rewards that can be verified automatically;
- KL control against a reference policy;
- exploration, response-length growth, and emergent reasoning strategies;
- cold-start SFT before RL versus RL directly from a base model;
- rejection sampling, a second SFT stage, and a later all-scenario RL stage;
- distillation versus RL for smaller models;
- reward hacking, readability, language mixing, and infrastructure cost.

## Models and pipelines to keep separate

### DeepSeek-R1-Zero

R1-Zero starts from DeepSeek-V3-Base and applies large-scale RL without preliminary SFT. The reported setup uses GRPO, rule-based accuracy rewards, and a structural format reward. The experiment is valuable because it isolates what reward-driven sampling can elicit from a strong base model. It also produces poor readability and language mixing, demonstrating that task reward alone does not specify all desirable behavior.

### DeepSeek-R1

R1 is not simply R1-Zero trained longer. Its multi-stage pipeline is approximately:

1. SFT on thousands of curated long chain-of-thought cold-start examples.
2. Reasoning-oriented RL with verifiable rewards and language-consistency pressure.
3. Rejection sampling from an RL checkpoint, combined with non-reasoning data, followed by SFT on roughly 800,000 examples.
4. A second RL stage mixing reasoning rewards with preference signals for helpfulness and harmlessness.

When analyzing results, do not attribute every R1 improvement to GRPO: data curation, cold start, rejection sampling, SFT, reward design, model scale, and the second RL stage all change.

## GRPO mechanics

For a prompt (q), sample a group of (G) completions (o_1,\ldots,o_G) from the behavior policy. Score them with reward (r_i), then normalize within the group:

\[
A_i = \frac{r_i - \operatorname{mean}(r_1,\ldots,r_G)}
{\operatorname{std}(r_1,\ldots,r_G) + \epsilon_A}.
\]

The group mean acts as a prompt-specific baseline. GRPO then uses a PPO-style clipped policy-ratio objective with KL regularization toward a reference policy:

\[
\max_\theta\; \frac{1}{G}\sum_i\frac{1}{|o_i|}\sum_t
\left[
\min\left(\rho_{i,t}A_i,
\operatorname{clip}(\rho_{i,t},1-\epsilon,1+\epsilon)A_i\right)
- \beta D_{\mathrm{KL}}(\pi_\theta\|\pi_{\mathrm{ref}})
\right],
\]

where

\[
\rho_{i,t} =
\frac{\pi_\theta(o_{i,t}\mid q,o_{i,<t})}
{\pi_{\mathrm{old}}(o_{i,t}\mid q,o_{i,<t})}.
\]

The paper's exact estimator and later variants should be checked carefully when implementing. The conceptual difference from PPO with a learned critic is that the group reward statistics provide the baseline, avoiding a separate value model. This reduces one major memory and training component, but it requires multiple rollouts per prompt and depends strongly on within-group reward variation.

## Component map

| Component | Role | Question to answer |
|---|---|---|
| Base policy | Supplies prior capabilities and exploration distribution | Which capabilities must already exist before RL can elicit them? |
| Prompt distribution | Defines environments/tasks encountered during RL | Does benchmark-like training transfer outside verifiable reasoning? |
| Rollout engine | Samples (G) completions per prompt | How do group size, temperature, length limits, and staleness affect learning? |
| Verifier/reward | Scores correctness and format | Is the reward accurate, exploitable, sparse, or contaminated? |
| Group baseline | Converts rewards into relative advantages | What happens when all group rewards are equal or nearly equal? |
| Clipped policy objective | Limits destructive policy updates | How should clipping interact with long token sequences? |
| Reference/KL term | Constrains drift from the starting policy | Does it preserve language quality at the cost of exploration? |
| Optimizer | Updates policy parameters | What are the effective batch tokens and gradient variance? |
| Evaluation | Measures pass@1, sampling gains, style, and regressions | Are gains robust to held-out problems and verifier changes? |

## Reading order

1. Read the abstract, introduction, and pipeline overview without focusing on benchmark tables.
2. Reconstruct GRPO from the equations: sampling policy, old policy, reference policy, group advantage, clipping, and KL.
3. Trace R1-Zero from prompts through rollouts, rewards, updates, and evaluation.
4. Identify what the cold-start and later SFT stages add to R1 that reward-only R1-Zero lacks.
5. Compare distillation and RL results, accounting for base-model scale and compute.
6. Read the unsuccessful-attempts section and list which failures are algorithmic, reward-related, and infrastructure-related.
7. Only then assess the claims about emergent reasoning and self-improvement.

## Critical questions

1. Does RL create new reasoning algorithms, increase the probability of latent strategies, or mainly allocate more inference tokens?
2. Which result actually isolates RL from SFT, rejection sampling, data filtering, and increased sampling compute?
3. How much does GRPO depend on a strong base model and a verifier with low false-positive rates?
4. Does group normalization make gradients unstable for prompts that are too easy, too hard, or have identical rewards?
5. Are response length and anthropomorphic reflection causal mechanisms, useful correlates, or reward-driven artifacts?
6. Could benchmark overlap or verifier-specific strategies explain part of the gain?
7. Why did direct distillation outperform large-scale RL on the smaller 32B model in the reported comparison?
8. Which details are sufficient for independent reproduction, and which remain dependent on private data or infrastructure?

## Planned coding sequence

The RL notebook should not begin by reproducing DeepSeek-R1 at model scale. It should implement the same conceptual pipeline in controlled stages:

1. A contextual bandit version of REINFORCE and variance-reducing baselines.
2. Sequence-level rewards for a tiny autoregressive policy.
3. Multiple completions per prompt and group-relative normalized advantages.
4. PPO-style probability ratios and clipping.
5. Reference-policy KL regularization.
6. A deterministic arithmetic verifier plus a separately measured format reward.
7. Diagnostics for reward variance, zero-variance groups, KL, entropy, response length, and pass@k.
8. Ablations comparing SFT only, RL from random/base initialization, cold-start SFT plus RL, and distillation.

The implementation goal is to understand the estimator and failure modes. It is not to claim that a CPU-scale toy model reproduces emergent reasoning in DeepSeek-R1.
