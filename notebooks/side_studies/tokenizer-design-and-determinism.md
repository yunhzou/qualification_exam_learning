# Tokenizer Design and Determinism

## The interface between text and a model

A language model does not consume strings. It consumes integer IDs drawn from a finite action space:

```text
text -> tokenizer -> token IDs -> embedding vectors -> Transformer
```

The same vocabulary defines the model's output space. For a vocabulary of size `V`, the language-model head produces `V` logits at every generation step. Tokenization therefore defines both how text enters the model and which discrete actions the model can generate.

## Why use subwords?

There is a basic efficiency tradeoff:

| Unit | Advantage | Cost |
|---|---|---|
| Word | Short sequences | Huge vocabulary and unknown words |
| Character or byte | Universal coverage | Long sequences |
| Subword | Reuses common fragments with moderate sequence length | Introduces segmentation choices |

Shorter sequences reduce attention, activation, KV-cache, and generation costs. Larger vocabularies increase embedding and output-head parameters and make the final softmax more expensive. A subword vocabulary is a compromise between sequence length and vocabulary size.

Tokenizer efficiency is not uniform. A tokenizer trained mostly on one language or code style may require many more tokens for another language, Unicode representation, or formatting convention. That reduces the effective context window and increases training and inference cost for the poorly represented domain.

## How the vocabulary is learned

The tokenizer is normally trained before the language model:

1. Select a representative sample of the pretraining corpus.
2. Choose normalization, byte conversion, and pre-tokenization rules.
3. Learn a vocabulary and segmentation model.
4. Add special tokens for padding, end of sequence, chat roles, tools, and other protocol elements.
5. Freeze the tokenizer.
6. Tokenize the pretraining corpus and train the model against those fixed IDs.

This is statistical training, but it is usually not joint gradient training with the Transformer.

### BPE

Byte Pair Encoding begins with bytes or characters and repeatedly learns frequent adjacent merges. The ordered merge table determines which merges are applied during encoding. A production BPE encoder follows merge ranks; it is not necessarily equivalent to choosing the longest vocabulary item at every position.

### WordPiece

WordPiece commonly uses a greedy longest-prefix rule, with explicit markers for pieces that continue a word.

### Unigram tokenization

A unigram tokenizer assigns scores to vocabulary pieces and uses dynamic programming to select the highest-scoring complete segmentation. Optional subword sampling can select other segmentations during data augmentation.

## Canonical encoding does not imply a unique token path

Suppose the vocabulary contains:

```text
900 -> " tokenization"
258 -> " token"
259 -> "ization"
```

The byte string `" tokenization"` has at least two valid token paths:

```text
[900]
[258, 259]
```

Ordinary encoding applies the tokenizer's fixed rules and chooses one canonical path, for example:

```text
encode(" tokenization") = [900]
```

With fixed files and settings, encoding is deterministic. The relevant settings include:

- vocabulary and merge/model files;
- normalization and pre-tokenization;
- special-token handling;
- chat template;
- beginning/end-of-sequence behavior;
- tokenizer library behavior and version.

The important mathematical asymmetry is:

```text
decode(encode(text)) usually equals normalized text
encode(decode(token_ids)) does not necessarily equal token_ids
```

Decoding is many-to-one over token sequences because distinct paths can produce the same bytes.

## Generation does not run the encoder

During autoregressive generation, the model selects an ID directly from its output distribution:

```text
prompt IDs -> model logits -> sampled token ID -> append ID -> next logits
```

It does not decode its partial output and run deterministic encoding again before the next step. The model can therefore generate `[258, 259]` even when the encoder would represent the completed text canonically as `[900]`.

Pretraining strongly biases the model toward token paths produced by the canonical encoder, so noncanonical paths may be uncommon. They remain valid model actions, however, and become important when exact token probabilities are used by RL or distillation.

## Does pretraining vary segmentation?

Usually the tokenizer and its deterministic segmentation are frozen for the entire pretraining run. Some pipelines deliberately use BPE dropout, unigram sampling, or subword regularization. These expose the model to alternative segmentations and may improve robustness, but they must be explicit parts of the data pipeline. Normal inference disables this sampling.

Changing the token-to-ID mapping after pretraining is not safe. An embedding row and output-head row have learned the semantics of a particular ID. A different vocabulary would silently give those weights a different meaning.

## Boundary and normalization problems

Tokenization is not generally compositional:

```text
encode(prompt) + encode(response)
```

may differ from:

```text
encode(prompt + response)
```

Leading spaces, Unicode normalization, chat delimiters, and special tokens can change merges at the boundary. Training pipelines should format examples consistently and construct response-loss masks against the resulting IDs rather than assuming that separately tokenized fragments concatenate identically.

## Takeaway

The tokenizer learns a finite, efficient text representation and then normally becomes a deterministic, frozen protocol. Deterministic encoding chooses a canonical path, but the model's generative action space still contains other token paths that may decode to the same text.
