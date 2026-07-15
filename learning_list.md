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
- **Process feedback and critics:** *Let's Verify Step by Step* and *AgentPRM*. Use them to separate step correctness, progress, and promise from terminal task success, and to understand when a learned critic adds information that grouped outcome rewards do not provide.
- **Long-horizon training systems:** the *GLM-5* technical report. Use it to study asynchronous rollout/training infrastructure, policy staleness, long trajectories, and training--inference consistency. The *Composer 2 Technical Report* is optional systems background for asynchronous RL and self-summarization, not an OPD anchor.
- **Recent production post-training:** the GLM-5.2 and Composer 2.5 research articles. Use GLM-5.2 to examine critic-based PPO and parallel multi-expert OPD, and Composer 2.5 to examine localized textual feedback implemented as privileged-context on-policy distillation.
