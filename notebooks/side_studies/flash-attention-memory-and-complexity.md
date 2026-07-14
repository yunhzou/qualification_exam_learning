# FlashAttention: Memory, Tiling, and Complexity

## Start with the three separate costs

A naive causal-attention implementation creates several quadratic objects:

```text
causal mask       [1, 1, L, L]
attention scores  [B, H, L, L]
attention weights [B, H, L, L]
```

These expose three related but distinct problems:

1. **Checkpoint storage:** a registered mask is saved with the model unless marked non-persistent.
2. **Runtime memory and memory traffic:** masks, scores, and softmax weights are materialized and moved through GPU memory.
3. **Arithmetic:** dense attention compares every query with every permitted key.

Different techniques solve different parts of this list.

## Why the explicit mask becomes expensive

For a maximum sequence length `L`, a dense Boolean causal mask contains `L^2` values. At `L = 32,768`:

\[
32{,}768^2 \times 1\text{ byte} \approx 1\text{ GiB}.
\]

At `L = 131,072`, the mask alone is approximately 16 GiB. This is unnecessary because causality has a simple rule:

\[
\text{query position }i\text{ may attend to key position }j
\quad\Longleftrightarrow\quad j \leq i.
\]

An attention kernel can determine whether a tile is causal from its position. It does not need a stored triangular matrix.

## `persistent=False` solves only checkpoint storage

This change keeps a registered buffer out of `state_dict`:

```python
self.register_buffer("causal_mask", causal_mask, persistent=False)
```

It prevents the mask from inflating checkpoints, but the complete `L x L` tensor is still allocated at runtime. It does not solve the main long-context memory problem.

## Implicit causality with scaled dot-product attention

The explicit implementation is:

```python
scores = Q @ K.transpose(-2, -1)
scores = scores / math.sqrt(head_dim)
scores = scores.masked_fill(~causal_mask, float("-inf"))
weights = torch.softmax(scores, dim=-1)
context = weights @ V
```

The corresponding PyTorch operation is:

```python
import torch.nn.functional as F

context = F.scaled_dot_product_attention(
    Q,
    K,
    V,
    is_causal=True,
)
```

For the tensors in `CausalAttention_by_Jackie`, `Q`, `K`, and `V` already have the expected shape:

```text
[batch, heads, sequence, head_dimension]
```

The `is_causal=True` flag expresses the rule without constructing a mask in Python. On a supported GPU, dtype, and shape, the backend may select a FlashAttention-style kernel. Other environments can use a different exact implementation of the same operation.

## What FlashAttention changes

Standard attention is written as:

\[
S = QK^\top, \qquad
P = \operatorname{softmax}(S), \qquad
O = PV.
\]

A naive implementation writes all of `S` and `P` to high-bandwidth device memory. For FP16 attention weights with one batch, 32 heads, and 32K tokens, one `[B,H,L,L]` tensor alone would require approximately 64 GiB.

FlashAttention processes Q, K, and V in tiles that fit in fast on-chip memory:

```text
load a Q tile
for each permitted K/V tile:
    compute partial scores
    update online-softmax statistics
    accumulate the partial output
    discard the partial scores
write the completed output tile
```

It maintains a running row maximum, normalization sum, and output accumulator. This makes it possible to compute exact softmax attention without storing the complete score or probability matrix.

The backward pass can recompute tiled quantities instead of retaining every attention weight from the forward pass. This exchanges some recomputation for a much smaller activation footprint.

## FlashAttention does not remove quadratic arithmetic

For dense attention, both the naive and tiled algorithms perform approximately:

\[
O(L^2D)
\]

attention arithmetic. FlashAttention improves the input/output behavior and avoids quadratic intermediate storage; it does not stop every query from interacting with every eligible key.

Conceptually:

```text
Naive intermediates:       O(B H L^2)
FlashAttention working set: approximately linear in stored sequence activations
Dense attention arithmetic: O(L^2 D) in both cases
```

The speed improvement can still be large because modern accelerators are often limited by moving the score and softmax matrices rather than by matrix multiplication alone.

## Techniques that actually change the arithmetic

Reducing asymptotic compute requires changing the attention pattern or architecture:

| Technique | Main effect | Does it preserve full dense attention? |
|---|---|---|
| FlashAttention | Tiles exact attention and reduces memory traffic | Yes |
| Sliding-window attention | Each query attends to a local window | No |
| Block-sparse attention | Computes selected attention blocks | No |
| Learned sparse retrieval | Selects a subset of keys | No |
| Linear attention | Reorders or approximates attention computations | Usually no |
| State-space/recurrent model | Replaces the full attention history with a state | No |

With a fixed window width `W`, sliding-window attention changes the attention cost from approximately `O(L^2 D)` to `O(L W D)`.

## Padding and packed sequences

Implicit causality only prevents attention to the future. It does not identify padding or boundaries between packed examples.

A naive implementation can combine masks into `[B,1,L,L]`, but that recreates a large quadratic object. Efficient variable-length kernels instead accept sequence lengths, cumulative offsets, or block-boundary metadata so they can skip invalid tiles without materializing the complete mask.

The logical rules remain:

```text
causal rule: do not attend to future positions
padding rule: do not attend to padding keys
packing rule: do not attend across example boundaries
```

## Training and autoregressive inference differ

During training, every sequence position is a query, so a naive implementation produces the full quadratic score matrix. FlashAttention provides a major activation-memory and memory-traffic improvement.

During cached autoregressive decoding, the newest step usually has one query and all preceding K/V entries:

```text
query length = 1
key/value length = current context length
```

One step is linear in the current context length, but generating a complete long sequence accumulates approximately quadratic work across all steps.

Related inference techniques solve other costs:

| Technique | Primary purpose |
|---|---|
| KV cache | Avoid recomputing K/V for previous tokens |
| MQA/GQA | Reduce the number of stored K/V heads |
| Paged attention | Allocate and share KV-cache memory efficiently |
| Flash decoding kernels | Improve attention computation and memory access during decoding |

These techniques complement FlashAttention; they are not alternative names for the same mechanism.

## Applying this to the custom implementation

The custom implementation correctly exposes the mathematical steps, which is valuable for learning and testing causality. A scalable version would:

1. keep the Q/K/V projections and head reshaping;
2. remove the preallocated `causal_mask` buffer;
3. replace explicit scores, masking, softmax, and `weights @ V` with scaled dot-product attention using `is_causal=True`;
4. represent padding or packed boundaries without a dense four-dimensional mask;
5. request full attention weights only for small diagnostic examples, because returning them requires materializing a quadratic result.

## Takeaway

FlashAttention is an exact, tiled implementation of dense softmax attention. It removes the need to store the complete causal mask, score matrix, and attention-probability matrix, which greatly reduces memory traffic and activation memory. Dense attention still performs quadratic pairwise interactions; sparse attention and alternative sequence models are required to change that asymptotic compute cost.

## Primary references

- Tri Dao et al., [FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness](https://arxiv.org/abs/2205.14135).
- Tri Dao, [FlashAttention-2: Faster Attention with Better Parallelism and Work Partitioning](https://arxiv.org/abs/2307.08691).
