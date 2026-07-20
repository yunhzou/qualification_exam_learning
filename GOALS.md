# Goals and Qualification Exam Requirements

## Integrated learning goal

Build a rigorous understanding of LLM training, concentrating on post-training methods, while using that learning to prepare the PhD qualification-exam position paper and presentation. Reading, critical synthesis, and practical experiments should support one another rather than become separate tracks.

The current working corpus contains nine central sources on LLM post-training. It deliberately includes peer-reviewed papers, preprints, technical reports, and first-party research articles because important production-scale methods are often disclosed outside conventional proceedings. All nine are treated as selected works for learning and synthesis; the final administrative classification should still be confirmed with the supervisor.

## Learning scope

The working curriculum in `learning_list.md` defines the following connected areas:

- Transformer foundations needed to reason about training behavior.
- Supervised fine-tuning (SFT), including behavior cloning and skill-boundary questions.
- Reinforcement-learning foundations and post-training algorithms such as GRPO.
- Reward models, process reward models, critics, and the limits of critic-free approaches.
- Distillation, with particular attention to on-policy distillation.
- Practical intuition for selecting SFT, RL, distillation, or combinations of them.
- Training infrastructure from first principles, including distributed training and asynchronous RL and on-policy-distillation workflows, while keeping the concepts framework-agnostic.
- Continual learning in relation to automated post-training, recursive improvement, and domain adaptation.
- Automated data synthesis, verification, root-cause discovery, data resynthesis, curriculum construction, and benchmark generation as parts of a possible automated post-training loop.

Claims about where particular methods fail, when critics become necessary, and whether automated post-training constitutes continual learning are research questions to test against the literature and experiments, not assumptions to carry into the position paper.

## Qualification exam requirements

Based on the Department of Computer Science Graduate Handbook for the PhD Program, 2024-2025:

- The student and supervisor select 5-10 important research papers in one area of computer science.
- The student is expected to read and understand relevant work beyond the selected papers, but is not expected to master most of the area's literature at this stage.
- The selected area does not have to become the student's eventual PhD topic. Choosing it does not commit the student to a thesis direction.
- The student prepares a short position paper addressing points (c)-(e) of Section 1. The target is about 4,000 words, or about eight single-spaced pages in a reasonable font.
- The position paper may briefly describe the student's own progress if they have begun investigating the area.
- The paper must be submitted to the supervisory committee at least one week before the examination meeting.
- The examination begins with a 15-20 minute talk about the position paper.
- One or more rounds of questions follow. The supervisory committee examines the student on points (a)-(e) of Section 1.
- The expected scope, paper selection, and interpretation of Section 1(a)-(e) should be discussed with the supervisor and committee.

## Deliverables

- A supervisor-approved list of 5-10 core works drawn from the nine-source working corpus.
- Reading notes that cover both the core papers and enough surrounding literature to place them in context.
- A critical comparison of each paper's question, methods, evidence, assumptions, and limitations.
- A coherent position on the selected research area, supported by the literature rather than a sequence of isolated paper summaries.
- A roughly 4,000-word position paper in `main.tex`, submitted at least one week before the exam.
- A 15-20 minute presentation in `presentation.tex`.
- Rehearsed answers covering all of Section 1(a)-(e), including material broader than the written paper.
- Optional, reproducible post-training experiments that clarify or challenge claims in the literature.

## Position-paper emphasis

The written paper is approximately eight single-spaced pages. It is a position paper for
the qualifying examination, not a complete rendering of the learning curriculum.
Transformer foundations and SFT should occupy only enough space to establish prerequisites.
The main discussion should concentrate on:

1. policy-gradient RL and post-training methods such as GRPO;
2. distillation, especially on-policy distillation;
3. when to use SFT, RL, process feedback or critics, and distillation, particularly for
   long-horizon agents; and
4. automated post-training as a possible continual-learning loop involving data synthesis,
   verification, failure diagnosis, data resynthesis, curriculum construction, and
   automatic benchmarks.

Detailed derivations and implementation tutorials remain part of the repository's learning
materials but should not automatically be composed into `main.tex`.

## Working checkpoints

1. Confirm the research area, core paper list, and handbook expectations with the supervisor.
2. Read the core papers and map the surrounding literature, terminology, and historical context.
3. Develop a defensible cross-paper position and identify the evidence for and against it.
4. Run focused experiments where they materially improve understanding.
5. Draft and revise the position paper to the required scope.
6. Build a 15-20 minute talk from the paper's argument and strongest evidence.
7. Practice committee questions across every required examination point.
