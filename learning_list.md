1. Transformer Basics
2. SFT algorithm
3. Common RL Algorithm, and post training specific ones, including GRPO.
4. distillation, such as on policy distillation.
5. Intuition wise, when to use what. SFT for behavior clonning for example, can refer to papers that discuss the skill boundaries. RL limitation, for example, pure GRPO are gradually failing on learning term agentic tasks. PRM and critics are gradually being introduced again. distillation technique, when can we use it, how to use it.
6. Training infra. Mostly distributed training, and async approach for RL and OPD. first principle, try to be infra agnostic here.
7. Lastly i want to discuss potentially continual learning in its relationship to post training. My understanding is by automating post traiing, we are doing continual learning. and recursive self-improvement and automated domain adaptation will very likely benefit from auto-post training. specifically auto data synthesis, verification, root cause discovery, data resynthesis and curiculum building, and proper auto benchmark.

## Anchor papers

- **Reinforcement learning:** DeepSeek-AI et al., *DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning* ([arXiv](https://arxiv.org/abs/2501.12948), [Nature](https://www.nature.com/articles/s41586-025-09422-z)). Use it to organize the GRPO, verifiable-reward, cold-start, reasoning-RL, and distillation modules; see `notes/rl/deepseek-r1-reading-guide.md`.
- **Distillation:** Kevin Lu and Thinking Machines Lab, *On-Policy Distillation* ([article](https://thinkingmachines.ai/blog/on-policy-distillation/), [maintained recipe](https://tinker-docs.thinkingmachines.ai/cookbook/recipes/distillation/)). Use it to compare fixed teacher data, sparse on-policy rewards, and dense teacher feedback on student rollouts; see `notes/distillation/on-policy-distillation-reading-guide.md`.
