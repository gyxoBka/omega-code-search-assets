# Omega Code Search — Vector / Hybrid Retrieval Rewrite Task

**Task type:** production rewrite + correctness/quality regression program  
**Target repository:** current `omega.zip` supplied with this task  
**Reference implementation for comparison:** supplied `semble-main.zip`  
**Authority:** current Omega Architecture Vision / accepted retrieval invariants remain binding; this task changes implementation, not the product truth model.

---

# 1. Mission

Rewrite Omega's static-semantic/vector retrieval path so that it retrieves **local source meaning**, not synthetic metadata bags or whole-file identifier sets, and so that lexical + semantic evidence reinforce the **same retrieval unit**.

The current exact vector scan itself is not the primary problem. The main defects are upstream of the scan and downstream in fusion/presentation:

```text
bad / mismatched retrieval units
→ weak semantic embeddings
→ lexical and semantic ranks point at different cards
→ little hybrid reinforcement
→ noisy static-semantic rankings get over-promoted or crowd top-K
→ final results expose the wrong abstraction / duplicate logical answers
```

The final implementation must:

1. build semantic vectors from bounded, syntax/source-aligned **raw source regions**;
2. index the same region text lexically and semantically;
3. retain Entity cards for identity/signature/API semantics without using synthetic metadata as the primary behavior-search corpus;
4. remove whole-file sorted/deduplicated identifier bags from the semantic plane;
5. eliminate hidden semantic-input truncation;
6. remove Pack/debug framing from model input;
7. replace the current line-count semantic-quality heuristic with a meaningful persisted quality contract;
8. add safe logical-result deduplication/diversification without hiding distinct required anchors;
9. make family-role selection query-aware while preserving Omega's evidence-family semantics;
10. verify fusion behavior rather than blindly copying Semble's constants;
11. produce correct public ranked results with exact source spans, owner entities when present, and no internal ranking implementation leakage;
12. add a frozen vector-only and hybrid retrieval evaluation suite that can prove whether the rewrite actually improves Recall@K/MRR/NDCG;
13. preserve snapshot correctness, incremental reuse, immutable components and all existing exact-search/Answer Contract invariants.

This is not a cosmetic refactor. Rewrite the retrieval-card/vector pipeline as far as required to satisfy the contract below.

---

# 2. Source findings that motivate the rewrite

The following findings are based on the supplied current Omega and Semble source trees. Treat them as the concrete defects this task must close.

## 2.1 Omega currently embeds the wrong document representation

Current Omega production:

- `crates/omega-runtime/src/build/production.rs::file_card`
- `crates/omega-runtime/src/build/production.rs::semantic_evidence_for_definition`
- `crates/omega-retrieval/src/cards.rs`
- `crates/omega-retrieval/src/semantic/model2vec.rs`

### File cards

`file_card()` currently uses:

```rust
let identifiers = ir
    .retrieval_seeds
    .iter()
    .flat_map(|seed| seed.tokens.iter().cloned())
    .collect::<Vec<_>>();
```

The seed is built in:

`crates/omega-ingest/src/content_builder.rs`

from a `BTreeSet` of generic fact names.

That means the semantic representation of a file is effectively:

```text
raw file
→ generic observed names
→ deduplicate
→ sort lexicographically
→ concatenate
→ Model2Vec
```

This destroys:

- source order;
- token frequency;
- local context;
- control/data-flow locality;
- comments and implementation prose not represented as generic facts;
- code syntax surrounding identifiers;
- much of the vocabulary in large files after truncation.

A whole-file identifier set must **not** remain the primary semantic representation.

### Entity cards

`semantic_evidence_for_definition()` currently builds a synthetic summary from:

- declaration/name;
- signature;
- deduplicated occurrence spellings;
- literals;
- callees;
- member names;
- type names;
- attributes.

It does **not** use the declaration's raw source body as the primary semantic document.

This is useful metadata, but it is not the same input distribution as raw code documents and is insufficient for behavioral queries.

## 2.2 Pack/internal metadata leaks back into semantic input

The code correctly removed field labels such as `decl:` / `sig:` from `StaticSemanticEvidence::embedding_input()`, because repeated labels distort a static mean-pooled embedding.

However `semantic_evidence_for_definition()` still renders attributes with:

```rust
format!("{name}={:?}", attribute.value())
```

so the model can receive strings like:

```text
omega.pack.visibility=String("pub")
omega.pack.parameter_shape=String("(...)")
omega.pack.return_type=String("Result<...>")
```

This reintroduces repeated infrastructure vocabulary and Rust debug formatting.

The model must consume semantic content, not Omega's internal attribute schema.

## 2.3 Source frequencies are destroyed

Entity evidence vectors are sorted and deduplicated.

File retrieval seeds are sets.

For a static embedding model that performs token-vector pooling, source frequency is part of the document representation. Raw source regions must preserve source text and therefore preserve natural repetition.

Do not globally `sort()` / `dedup()` semantic source text.

Deduplication is acceptable only for explicitly metadata-like secondary fields where repeated identical metadata is known to be accidental duplication.

## 2.4 Semantic documents are hard-truncated to 512 tokens

`crates/omega-retrieval/src/semantic/model2vec.rs::encode_unpadded` currently calls:

```rust
model.encode_with_args(std::slice::from_ref(text), Some(512), 1)
```

This silently cuts large semantic renderings.

That is particularly destructive for current whole-file token bags, because lexicographic ordering means important concepts can simply appear after the cut.

The corrected design must make semantic documents bounded **before** embedding and then encode the full bounded document with no hidden model-side truncation.

Do not fix this by embedding entire multi-megabyte files with `max_length=None`. The correct order is:

```text
source
→ meaningful bounded region
→ embed complete region
```

## 2.5 Lexical and semantic evidence currently rank different logical things

Current file card:

```text
lexical_text = whole raw file
semantic_input = whole-file identifier set
```

Current entity card:

```text
lexical_text = qualified_name || name
semantic_input = synthetic entity metadata
```

The fusion key is currently based on card ordinal:

```text
project:view:ordinal
```

Therefore a lexical hit on the file and a semantic hit on a function inside that file are different candidates and do not reinforce each other.

This is a core hybrid-search defect.

The primary behavior-search unit must be the same card for both:

```text
Region card
  lexical text  = raw bounded region source
  semantic text = the same raw bounded region source
```

Name/qname/path remain separate lexical fields on that same card.

## 2.6 `semantic_family_quality()` is too weak

Current implementation:

```rust
0 lines  -> Unavailable
1 line   -> Weak
>=2      -> Informative
```

This means a card containing two almost identical identity strings can be considered fully informative, while a compact but meaningful one-line code region can be demoted.

Replace this with a build-time semantic-quality contract based on the actual semantic representation and card type.

The query path must not infer semantic quality from line count.

## 2.7 Current normal search family roles are not query-aware

`crates/omega-runtime/src/query_api.rs` currently makes normal search roughly:

```text
Identity       SUPPORT
Lexical        PRIMARY
StaticSemantic PRIMARY
Structural     DISABLED
```

for every normal query regardless of whether the query is:

```text
ViewGenerationRoot
```

or:

```text
how does the daemon recover an interrupted index publication
```

Implement deterministic query-shape classification that adjusts **family roles**, not arbitrary cross-family numeric weights.

## 2.8 Current reciprocal-rank fusion is very steep

`crates/omega-retrieval/src/fusion.rs` currently uses a zero-based reciprocal transform equivalent to:

```text
1 / (rank + 1)
```

This strongly separates rank 1 from rank 10/20/50.

Semble uses a smoothed reciprocal-rank transform with `k=60`, which keeps deeper semantic candidates competitive. That does **not** mean Omega should blindly copy `60`.

The rewrite must make this behavior explicitly evaluable with an ablation. Preserve the accepted evidence-family architecture and do not sum raw BM25/cosine/Jaccard magnitudes.

## 2.9 The exact vector scan is not the main defect

Current Omega uses an exhaustive exact scan, not ANN.

`query_exact_bounded()` scans the slab and returns exact cosine-ranked rows. Adaptive widening can expose semantic candidates beyond the initial width.

Do not replace exact scan with ANN as part of this task.

ANN remains outside scope unless later measured crossover requires it.

## 2.10 Duplicate/crowding handling is incomplete

Normal candidates are built with:

```rust
hard_duplicate_fingerprint: None
```

and there is no final logical-result grouping suitable for the new region-card corpus.

Adding region cards will increase the chance that several adjacent regions from one declaration dominate top-K.

Do **not** copy Semble's unconditional same-file saturation rule verbatim: Omega's Vision explicitly requires that diversity heuristics never hide distinct required anchors.

Implement logical-answer dedup/grouping based on exact source/owner identity, not arbitrary “one file only” suppression.

## 2.11 Current search output leaks retrieval implementation details and does not present region matches optimally

The ranked execution path currently emits ad-hoc JSON including internal packed `rank_score`.

Normal public API must not expose internal rank packing/weights.

With region cards the output must identify:

- exact path;
- exact source span;
- exact snapshot-bound `source_ref`;
- owner Entity when one exists;
- logical match kind/card level;
- matched evidence families/channels;
- bounded source/signature preview where appropriate;
- rank;
- completeness/frontier metadata.

It must not output synthetic semantic model text or Omega internal Pack attribute strings.

## 2.12 `similar_to` currently depends on the first Entity card ordinal

`RetrievalAuxIndex::ordinal_for_entity()` maps an Entity to the first card carrying that EntityId.

If Region cards are implemented by simply assigning the owner's `entity_id` to every region, this can silently change `similar_to` / structural lookup to an arbitrary Region vector.

Do not overload `entity_id` in this way.

Introduce an explicit owner relation for Region cards while preserving the canonical Entity-card ordinal mapping.

---

# 3. Semble is a reference baseline, not architecture authority

Use the supplied Semble source to understand why its simple vector path can work well:

```text
raw syntax-aligned chunk
→ same chunk to BM25
→ same chunk to Model2Vec
→ exact cosine
→ rank fusion
→ code-aware reranking/diversity
```

Important reference files:

- `src/semble/chunking/core.py`
- `src/semble/chunking/chunking.py`
- `src/semble/index/dense.py`
- `src/semble/index/create.py`
- `src/semble/index/sparse.py`
- `src/semble/search.py`
- `src/semble/ranking/boosting.py`
- `src/semble/ranking/penalties.py`
- `src/semble/ranking/weighting.py`

Do **not** blindly copy:

- Semble's Python implementation;
- its exact constants;
- strong global test/example penalties;
- per-file saturation;
- its lack of semantic Entity/graph truth;
- its cache/invalidation weaknesses.

Omega has stronger snapshot, Entity, IR, coverage and Answer Contract requirements. Preserve them.

---

# 4. Target retrieval model

The target corpus consists of three distinct logical card families.

## 4.1 Entity cards

Purpose:

- exact symbol identity;
- qualified-name lookup;
- signature/API semantics;
- docs/type/member concept matching;
- relation/context anchors;
- `similar_to` Entity anchor compatibility.

Entity card semantic input may contain compact entity metadata, but it must be clean and source-like.

It is **not** the only semantic representation of the declaration.

### Entity semantic input rules

Allowed:

- declared name;
- qualified name when human-meaningful;
- source-like declared signature;
- documentation text;
- source-like type/member/callee/literal terms when genuinely useful.

Forbidden:

- `omega.pack.*` descriptors;
- `Debug` formatting such as `String("...")`;
- field labels repeated on every card;
- decimal length framing;
- internal IDs;
- content digests;
- `path:<hex>` / `local:<hex>` namespace identity devices;
- arbitrary sorted attribute dumps.

Extract attribute **values** into the appropriate semantic field instead of formatting descriptor + debug value.

## 4.2 Region cards — PRIMARY semantic behavior-search unit

`CardLevel::Region` already exists. Use it.

Each Region card represents one bounded local source region.

For Region cards:

```text
lexical_text  = exact raw source text of region
semantic_input = exact raw source text of region
```

No synthetic field framing.

The Region card also carries:

- project/view;
- path;
- exact ByteSpan;
- SourceRole;
- optional owner Entity binding/id through a **separate owner field**;
- optional human-facing owner name/qname metadata;
- structural features if meaningful;
- semantic-quality classification;
- representation/fingerprint/version metadata.

The owner relation is for result grouping/navigation. It must not make the Region card itself pretend to be the Entity card.

## 4.3 File cards

File card remains useful for:

- file/path identity;
- filename lookup;
- path channel;
- file-level source role;
- direct file addressing.

But it must no longer carry a whole-file semantic vector made from a sorted identifier set.

Preferred implementation:

```text
File card lexical body: empty or deliberately minimal file-level text;
path remains indexed in the path field;
semantic quality: Weak or Unavailable;
semantic input: filename/path-level content only if there is a measured reason.
```

Do not put raw multi-megabyte whole-file source into one semantic vector.

Do not retain the current BTreeSet identifier bag as the file semantic input.

Exact raw text search already has its own exhaustive path and must not depend on file semantic vectors.

---

# 5. Region construction contract

Implement a reusable Region-card builder in the appropriate retrieval/ingest/runtime boundary.

Do not put language-specific chunk logic into the retrieval engine.

The builder consumes already-trusted source bytes/text + normalized IR/regions and emits deterministic bounded source regions.

## 5.1 Coverage rule

Every semantically searchable readable-text artifact must have region coverage sufficient for behavior search even if:

- there are no Language Pack declarations;
- grammar support is absent;
- the file is Markdown/config/SQL/IaC/unknown text;
- the artifact has source text outside definitions.

Unknown text still gets source-aligned fallback Region cards.

## 5.2 Declaration-aligned regions

For a searchable declaration:

1. take its exact source span;
2. if reasonably bounded, create one raw source Region card for the declaration;
3. if too large, split inside its span using existing syntax/Region structure where possible;
4. preserve exact ByteSpan for every emitted card;
5. associate each region with the owner entity using a separate owner binding.

The first region should naturally include the signature because it begins at the actual declaration span. Do not synthesize a duplicate signature header unless evaluation proves it is needed.

## 5.3 Large declaration splitting

Target a local semantic document roughly comparable to Semble's useful scale, not a whole file.

Initial policy:

```text
soft target: ~750–1200 UTF-8 characters
hard target: bounded local region, not model-side truncation
```

Prefer boundaries in this order:

1. existing normalized syntax/semantic child regions;
2. statement/block boundaries available from IR;
3. line boundaries;
4. UTF-8-safe character/byte boundary fallback.

Do not split in the middle of a UTF-8 codepoint.

Do not silently discard the tail.

Avoid overlap by default for syntax-aligned regions. A tiny line overlap is acceptable only for fallback windows if tests show boundary recall requires it; if overlap exists, the output layer must prevent duplicate logical answers.

## 5.4 Residual/unowned source

After declaration-owned coverage, cover useful source that is not owned by a searchable declaration:

- module-level code;
- comments/docs;
- config values;
- unknown-language text;
- top-level expressions;
- malformed source fragments.

Use deterministic syntax/line-aligned regions.

## 5.5 Documentation/config/schema/IaC

For these artifacts raw text is often the semantic content.

Use section/region spans from generic ingestion when available; otherwise use bounded line/source windows.

Do not reduce config/docs to a unique-token bag.

---

# 6. RetrievalCard schema changes

Modify `crates/omega-retrieval/src/cards.rs` and persistence as required.

## 6.1 Add explicit Region owner metadata

Do not reuse `entity_id` to mean both "this card is the Entity" and "this region belongs to an Entity".

Add generation-neutral owner binding plus bound owner id, for example conceptually:

```rust
pub owner_entity_id: Option<EntityId>,
pub owner_entity_binding: Option<EntityBindingSeed>,
```

Naming may vary, but semantics must be explicit.

Entity cards:

```text
entity_id = Some(entity)
owner_entity_id = None or self by clearly documented convention
```

Region cards:

```text
entity_id = None
owner_entity_id = Some(owner) when known
```

File cards:

```text
entity_id = None
owner_entity_id = None
```

Rebinding to a new semantic generation must update both real Entity card IDs and Region owner IDs correctly.

## 6.2 Persist semantic quality directly

Replace `semantic_line_count` as the decision mechanism.

Persist a typed semantic-quality value, at minimum:

```text
UNAVAILABLE
WEAK
INFORMATIVE
```

Also persist lightweight diagnostics useful for evaluation, e.g.:

- semantic input byte length;
- optional token count when cheaply available;
- semantic input kind (`raw_region`, `entity_metadata`, `file_metadata`).

Do not require model/tokenizer inference during query just to decide quality.

`semantic_line_count` may be retained for diagnostics/backward migration if useful, but it must not remain the quality truth.

## 6.3 Version all changed formats

Because card semantics and persisted columns change, update all affected versions.

At minimum inspect and correctly bump/reconcile:

- `RETRIEVAL_CARD_VERSION`;
- `STATIC_SEMANTIC_INPUT_VERSION`;
- `CARD_SET_MANIFEST_FILE` version/name if its contract changes;
- store schema migration for new card columns;
- vector component contract/version if necessary;
- lexical/card format version if persisted/open compatibility changes;
- auxiliary index version only if its bytes/semantics actually change.

Do not reuse old semantic rows after the semantic input contract changes.

A semantic-input version bump must force the correct vector rebuild instead of mixing old and new embeddings.

The existing `cards_match_current_rendering()` safeguard must continue to work and tests must prove mixed rendering generations cannot be published.

---

# 7. Semantic input rewrite

## 7.1 Region input

For a Region card:

```text
semantic_input = exact raw source slice for ByteSpan
```

Preserve source order and natural token frequency.

Do not sort.

Do not deduplicate.

Do not prepend field names.

Do not prepend internal path/IDs by default.

## 7.2 Entity input

Rewrite `semantic_evidence_for_definition()`.

Do not do:

```rust
format!("{name}={:?}", attribute.value())
```

Instead:

- known doc attributes → raw doc text;
- visibility/modifiers → source-like tokens if useful;
- parameter/return/type shapes → source-like signature components;
- member/callee/type/literal evidence → clean values only;
- unknown internal Pack attributes → ignore for semantic embedding unless explicitly mapped.

Preserve meaningful field/source ordering where known.

Do not sort entity evidence solely for semantic embedding. Deterministic canonical hashing can have its own canonical representation; the model rendering may preserve semantic/source order.

Keep canonical fingerprinting separate from model text, as `canonical_input()` already conceptually does.

## 7.3 File input

Delete the current semantic dependence on `RetrievalSeedKind::Identifiers` for file cards.

Do not delete retrieval seeds from the IR if another subsystem uses them; simply stop using the generic identifier set as the file semantic document.

---

# 8. Model2Vec encoding contract

Modify `crates/omega-retrieval/src/semantic/model2vec.rs`.

## 8.1 Remove hidden document truncation

Replace the hardcoded document call:

```rust
Some(512)
```

with an explicit no-hidden-truncation contract for already-bounded Region/Entity documents.

Preferred behavior:

```rust
encode_with_args(..., None, 1)
```

or the exact model2vec-rs equivalent that guarantees the complete bounded input is encoded.

The region builder, not Model2Vec, is responsible for keeping the semantic unit local and bounded.

## 8.2 Query embedding

Make query encoding explicit and deterministic too.

Do not rely on a different accidental default path for queries vs documents.

Use the same model identity/normalization contract and an explicit max-length policy. Query strings are normally small; no useful query term should be silently dropped.

## 8.3 Preserve the no-padding correctness fix

The current `encode_unpadded()` intentionally encodes one distinct text at a time because padding tokens in the current tokenizer/model path can contaminate mean pooling.

Do not regress this.

If you later batch, first prove Rust Model2Vec pooling correctly masks PAD for this exact asset/tokenizer. Until proven, one-text batches remain the correctness path.

## 8.4 Duplicate semantic text reuse

Retain the good optimization that identical semantic inputs are embedded once and their vectors reused.

But do not let this imply those cards are one logical result: identical code in two different files remains distinct source evidence.

## 8.5 Python/Rust parity fixture

Add a fixed semantic corpus containing:

- simple function;
- Rust function;
- Unicode identifiers;
- comments/docstrings;
- long identifier-heavy code;
- config text;
- empty/minimal text;
- mixed punctuation/operators.

Where the reference Python Model2Vec environment is available, compare:

- tokenization expectation where exposed;
- dimensions;
- normalization;
- cosine ordering;
- embeddings within a documented numeric tolerance.

If Python cannot run in CI, keep golden fixture generation tooling and checked-in expected metadata/digest, and mark numeric parity as an explicit verification gate rather than silently skipping it.

---

# 9. Lexical/semantic alignment

The central rewrite requirement is:

> A behavioral source Region is one logical retrieval card addressed by one ordinal, and the lexical text channel and static-semantic vector channel rank that exact same card.

For every Region card:

```text
Tantivy name/qname/path fields = normal metadata
Tantivy text field            = raw region source
Model2Vec input               = raw region source
Structural                    = region/entity structural evidence where meaningful
```

Do not keep the current situation where:

```text
lexical(file)
semantic(entity)
```

are expected to reinforce one another despite different ordinals.

## 9.1 File cards

File cards should rank primarily through identity/path fields, not whole-file content ranking.

Exact text enumeration remains the exact-search subsystem's job.

## 9.2 Entity cards

Entity cards remain searchable through identity/name/qname/signature/docs.

They are a distinct retrieval unit from source Region cards.

For exact/symbol-like queries this is desirable.

For behavioral NL queries Region cards should provide the local code/document semantics.

---

# 10. Semantic eligibility and quality

Define a deterministic build-time quality classifier.

Example semantics:

## UNAVAILABLE

- no semantic input;
- vector asset unavailable;
- intentionally nonsemantic metadata-only card.

## WEAK

Examples:

- file/path-only semantic representation;
- Entity card containing little more than a single name;
- very tiny metadata-only declaration.

## INFORMATIVE

Examples:

- nontrivial raw source Region;
- Entity card with meaningful signature/docs/API evidence;
- non-code Region with real textual content.

Do not use "two lines" as the definition.

A useful implementation may derive quality from:

```text
card level
semantic input kind
meaningful character/token count
number of independent semantic fields
```

but the rules must be deterministic and tested.

Unavailable rows must never behave like real semantic evidence.

Weak PRIMARY evidence must continue to demote to SUPPORT according to the existing fusion contract.

Consider adding a semantic-eligibility mask/ordinal list so exact vector retrieval does not waste its visible frontier on cards known to be UNAVAILABLE. Do not break the card/vector snapshot identity contract while doing so.

---

# 11. Query-aware family roles

Do not introduce arbitrary floating cross-family weights.

Use the existing typed `RetrievalFamilyRole` mechanism.

Implement a deterministic query-shape classifier in the query/planning layer.

At minimum distinguish:

## Symbol / identifier query

Examples:

```text
ViewGenerationRoot
foo_bar
crate::module::Type
handlePayment
```

Policy direction:

```text
Identity       PRIMARY or strongest applicable identity semantics
Lexical        PRIMARY
StaticSemantic SUPPORT
Structural     DISABLED unless similar_to
```

## Natural-language / behavioral query

Example:

```text
how does the daemon recover after interrupted root publication
```

Policy direction:

```text
Identity       SUPPORT
Lexical        PRIMARY
StaticSemantic PRIMARY
Structural     DISABLED
```

## Path-heavy query

Example:

```text
storage migration sqlite cards schema
```

Use lexical/path/identity as primary; semantic may remain primary/support depending deterministic rule.

## similar_to

Keep semantic + structural as primary as already intended.

Add golden tests for classification and produced Query IR family roles.

The classifier must be simple, deterministic, backend-independent and not an LLM.

---

# 12. Fusion changes and ablations

## 12.1 Preserve evidence-family separation

Never combine raw score scales like:

```text
0.4 * BM25 + 0.5 * cosine + 0.1 * Jaccard
```

The accepted family-rank fusion architecture remains.

## 12.2 Make rank transform explicit

Refactor the current reciprocal transform into one clearly named/testable function/strategy.

Evaluate at least:

```text
A. current reciprocal rank: 1/(rank+1)
B. smoothed RRF-style transform, e.g. 1/(k+rank+1)
```

`k=60` from Semble is a comparator, not a mandated constant.

Run retrieval ablations on the frozen evaluation corpus.

Promotion rule:

- do not switch production purely because Semble uses a constant;
- switch only if the smoothed transform materially improves required-anchor Recall@K/MRR/NDCG and does not break deterministic ordering/frontier certification semantics;
- record the chosen constant/strategy in a regression test;
- if the Architecture Vision/frozen contract forbids changing the transform without adjudication, leave the alternate transform experiment-only and report the result rather than silently changing the contract.

## 12.3 Frontier correctness

Any changed rank transform must update:

- unseen-score upper-bound logic;
- `CandidateFrontier` certification;
- ordered-top-K stability proofs/tests.

Do not improve ranking by invalidating `ranking_stable` truthfulness.

---

# 13. Logical-result deduplication and diversity

Region cards necessarily create more candidate rows.

Implement two separate concepts.

## 13.1 Hard duplicate identity

Only exact logical duplicate rows may collapse as hard duplicates.

Do **not** deduplicate identical source text from two different locations/files.

A correct hard duplicate key can be derived from exact logical source identity such as:

```text
project/view/path/span/card-kind/representation contract
```

or the already-defined stable row identity where semantically appropriate.

Stop leaving `hard_duplicate_fingerprint` unconditionally `None` when an explicit hard duplicate witness exists.

## 13.2 Presentation grouping

Search returns logical answers, not every overlapping Region card.

After card-level fusion, group for presentation:

```text
Region with owner Entity -> owner Entity is presentation group
Entity card              -> that Entity is presentation group
unowned Region           -> exact path+span group
File card                -> file group
```

For one owner Entity with several high-ranking Region cards:

- choose the best card as the primary hit;
- union/report matched evidence channels accurately;
- optionally keep a bounded list/count of supporting region refs;
- do not emit five adjacent chunks of one function as five of top-10 logical results.

Do not apply a blanket "one result per file" rule.

Two distinct relevant entities in one file must remain eligible as two results.

If grouping reduces visible results below requested `K`, continue/widen candidate retrieval until either:

- K logical results are obtained; or
- the relevant channel frontiers are exhausted/budget-limited.

Update ranking/frontier completeness semantics so the public `ranking_stable` statement refers to the **presented logical top-K**, not merely pre-group card rows.

---

# 14. `similar_to` compatibility

Do not break `RetrievalAuxIndex::ordinal_for_entity()`.

It must continue to point to the canonical Entity retrieval card for an Entity, not an arbitrary Region card owned by that Entity.

Region owner metadata must be indexed separately if needed.

For `similar_to`:

- Entity ref should resolve to the Entity card's semantic/structural representation by default;
- optionally evaluate a future aggregate of its owned Region vectors, but do not silently change current semantics in this task unless tests prove and document it;
- region source refs are not normal Entity opaque refs.

Add regression tests proving Region card insertion does not change canonical entity ordinal selection.

---

# 15. Public search output rewrite

The normal public search response must describe the useful logical result, not the internal ordinal/card implementation.

## 15.1 Required fields per ranked hit

Use canonical public response types rather than hand-built ad-hoc JSON where possible.

A ranked hit must expose at least:

```text
rank
project_id
view_id
path
exact source span when available
source_ref bound to exact published root
owner/entity summary when available
logical match/card kind
bounded preview
matched channels/evidence families
source role
```

Keep snapshot/freshness/frontier/budget metadata at response level.

## 15.2 Do not expose packed ranking internals

Remove normal API leakage of the packed internal integer:

```text
rank_score
```

Normal API must not reveal internal family-weight/rank-packing implementation.

If a human/debug endpoint needs detailed diagnostics, keep it behind a debug/advanced surface, not normal agent search.

## 15.3 Preview semantics

For an Entity hit:

```text
preview = bounded signature/declaration/docs projection
```

For a Region hit:

```text
preview = bounded exact source slice from that Region
```

Generate Region preview only after final top-K/presentation grouping, from the pinned snapshot/source payload, so ranking does not require storing duplicate source text in every card.

Do not persist whole semantic input solely to display it.

Do not display synthetic semantic input or internal Pack attributes.

## 15.4 Source refs

Every Region result must get an exact `source_ref` with:

```text
project
view
root
path
start_byte
end_byte
```

This ref must reproduce the same source bytes after later edits/restarts while the root is retained.

## 15.5 Evidence reporting

`matched_channels` / evidence must reflect actual evidence after grouping.

Do not claim semantic evidence when the vector channel was unavailable/weak and did not contribute.

Do not hide lexical-only fallback behind a generic "semantic" match label.

---

# 16. Build pipeline rewrite

The current pipeline builds one file card while decoded text/IR are in hand, then later builds Entity cards after collecting surfaces.

Refactor as necessary so Region cards can be produced without holding every full source file in memory until the end of the corpus.

Preferred memory behavior:

```text
process one artifact
→ decoded text + ContentIr + Surface available
→ derive bounded Region-card raw projections while source is in hand
→ retain only card projections / small card metadata needed for downstream build
→ release large source/IR allocations as early as possible
```

Do not regress the current memory work that deliberately avoids holding two corpus copies.

If Entity IDs require the semantic generation later, carry generation-neutral owner/entity binding seeds and bind them after semantic generation identity is known.

Do not hold entire source strings for all files merely to attach EntityId later.

---

# 17. Incremental reuse

Preserve the good reuse design:

```text
semantic_input_fingerprint
→ reuse identical vector row under same model identity
```

For Region cards the fingerprint must derive from the exact bounded semantic source input + semantic-input contract version.

Expected behavior:

- unchanged region → vector reused;
- body edit affecting one region → that region recomputed;
- unrelated file edit → unrelated region vectors reused;
- representation/version change → correct full/affected rebuild;
- model identity change → vectors recomputed under new model component;
- path-only change must not force semantic recomputation if the region semantic input remains content-local and identity rules allow reuse.

Add tests measuring rows embedded vs reused.

Do not key vector reuse by root, ordinal or path when the semantic input itself is unchanged.

---

# 18. Lexical component implications

Region cards increase lexical document count.

Ensure Tantivy still indexes:

```text
name
qname
path
text
source role
```

For Region cards:

```text
text = raw region source
```

For Entity cards:

```text
name/qname = entity identity fields
text = compact signature/docs/entity representation, not an unrelated whole file
```

For File cards:

```text
path/name are the important lexical fields
```

Do not duplicate a whole file's raw body into every Entity card.

Run/update lexical lifecycle/write accounting tests because document cardinality will change.

---

# 19. Evaluation harness — mandatory before declaring success

Do not judge this rewrite from a few manual queries.

Build/extend a frozen retrieval evaluation harness.

## 19.1 Ground-truth record

At minimum support rows like:

```text
query
expected project
expected path
optional expected span/entity/canonical key
query family
language
notes
```

A path-only probe is useful for initial vector diagnosis, but final evaluation should prefer expected Entity/source-span anchors where available.

## 19.2 Required metrics

Report separately for vector-only and full hybrid search:

```text
Recall@1
Recall@5
Recall@10
Recall@20
Recall@50
Recall@100
MRR
NDCG@10 / NDCG@20
mean/median irrelevant results before first required anchor
logical-result duplication/crowding rate
per-language breakdown
per-query-family breakdown
```

Also report:

```text
card counts by level
vectors by semantic quality
semantic input length distribution
region count/file distribution
vector slab bytes
lexical index bytes
cold build time
vector build time
ranked query p50/p95
RSS if measurable
```

## 19.3 Frozen before/after baseline

Before deleting the old path, preserve an evaluation mode or captured report for current behavior.

The final report must compare:

```text
CURRENT Omega
vs
NEW region-aligned Omega
```

on the same repository roots/model/query labels.

## 19.4 Mandatory ablations

Run or provide runnable harnesses for:

### A. Retrieval unit

```text
old Entity/File cards
vs
new Region + Entity cards
```

### B. File semantic vector

```text
old whole-file identifier set
vs
file semantic disabled/weak + Region vectors
```

### C. Truncation

```text
old Some(512)
vs
bounded Region + no hidden truncation
```

### D. Entity rendering

```text
old debug/descriptor attributes
vs
clean source-like attribute values
```

### E. Family quality

```text
line-count heuristic
vs
new typed quality
```

### F. Query-aware roles

```text
static normal-search roles
vs
query-shape family roles
```

### G. Fusion rank transform

```text
current reciprocal
vs
smoothed RRF candidates (including k=60 as one comparator)
```

### H. Presentation grouping

```text
raw card top-K
vs
logical-result top-K
```

### I. Semantic model

Keep the model constant for the primary rewrite comparison.

Only after representation is fixed should you compare another model/provider.

---

# 20. Acceptance criteria

The rewrite is not complete merely because code compiles.

## 20.1 Correctness invariants

Must pass:

- exact represented lookup remains 100% recall;
- source refs remain snapshot-bound;
- old refs remain stale after root change as designed;
- lexical/vector/card ordinals/components remain internally consistent;
- no mixed semantic-input-version generation is publishable;
- semantic provider failure still degrades only semantic evidence family;
- exact vector scan scalar/SIMD parity remains valid;
- no ANN introduced;
- no raw-score cross-family addition introduced;
- `similar_to` Entity mapping remains canonical;
- no Region owner is accidentally treated as the Region card's Entity identity;
- query/frontier completeness remains truthful after logical-result grouping.

## 20.2 Retrieval quality target

The accepted Omega release target remains:

```text
required-anchor Recall@20 >= 90%
```

on the frozen real-repository evaluation.

Additionally, compared to current Omega on the same corpus:

- vector-only Recall@10 and Recall@20 must improve materially;
- hybrid Recall@10/20 must not regress;
- MRR/NDCG must improve or remain statistically/operationally equivalent while satisfying Recall target;
- logical-result duplication/crowding must decrease;
- exact symbol/name queries must not be harmed by concept-search changes.

Do not invent a PASS when the real-repository corpus is unavailable. Produce an `UNVERIFIED` report with exact commands/data required.

## 20.3 Performance/resource target

Do not obtain recall by making search/indexing unbounded.

Preserve Vision targets, including:

```text
ranked search p95 <= 100 ms on reference class
1M LOC derived disk <= 4 GiB
1M LOC idle RSS <= 1.5 GiB
ordinary edit freshness p95 <= 2 s
ordinary edit must not cause O(repository-size) persistent rewrite
```

If Region cardinality threatens these budgets, optimize representation/storage/indexing; do not revert to low-quality whole-file embeddings merely to lower row count.

---

# 21. Required regression tests

Add focused tests at the owning crate, not one giant integration-only test.

## Cards / region construction

- small declaration → one raw Region card;
- large declaration → deterministic multiple regions with full source coverage;
- UTF-8 boundary safety;
- nested declaration ownership;
- residual top-level source coverage;
- unknown language fallback regions;
- docs/config raw-region cards;
- Region lexical text equals Region semantic text exactly;
- File semantic input is no longer the generic identifier bag;
- owner binding is distinct from card Entity identity.

## Semantic rendering

- no `omega.pack.` token appears in model input unless it was literally source text;
- no `String("...")` debug wrapper;
- source frequency/order preserved for Region input;
- canonical fingerprint remains deterministic independent of model rendering implementation details;
- entity docs/signature values are clean/source-like.

## Model2Vec

- no hidden truncation of bounded region;
- one-text encoding deterministic;
- duplicate input vector reuse;
- query/doc normalization dimension parity;
- scalar cosine sanity;
- optional Python/Rust parity fixture.

## Quality

- name-only Entity becomes WEAK;
- meaningful raw Region becomes INFORMATIVE;
- unavailable semantic card cannot contribute as PRIMARY;
- quality survives persistence/reload exactly.

## Fusion / query policy

- symbol query roles;
- NL query roles;
- path-like query roles;
- similar_to roles;
- correlated lexical subchannels still one family vote;
- Weak primary demotes to support;
- chosen rank transform golden ordering;
- frontier upper-bound math matches rank transform.

## Logical result grouping

- adjacent regions of one Entity do not fill top-K;
- two distinct Entities in one file remain two results;
- identical code in different files is not hard-deduplicated;
- exact same logical source card is deduplicated;
- grouping widens until requested K logical results or honest frontier exhaustion.

## Public output

- no normal `rank_score` implementation integer;
- Region hit source_ref has exact span/root;
- Entity hit uses signature preview;
- Region preview comes from snapshot source and is bounded;
- matched channels are truthful;
- semantic-unavailable response does not pretend semantic match.

## Incremental/versioning

- semantic-input-version bump rejects/rebuilds old rows;
- unchanged region reuses vector after unrelated edit;
- changed region re-embeds;
- path-only context change does not unnecessarily change content-local region vector;
- daemon restart reopens the new card/vector generation.

---

# 22. Files likely to change

This list is not exhaustive. Follow ownership boundaries.

Primary expected areas:

```text
crates/omega-retrieval/src/cards.rs
crates/omega-retrieval/src/semantic/model2vec.rs
crates/omega-retrieval/src/fusion.rs
crates/omega-retrieval/src/frontier.rs
crates/omega-retrieval/src/aux_index.rs
crates/omega-retrieval/src/row_index.rs
crates/omega-retrieval/src/lexical/mod.rs
crates/omega-retrieval/src/lexical/tantivy.rs

crates/omega-runtime/src/build/production.rs
crates/omega-runtime/src/public_execution.rs
crates/omega-runtime/src/query_api.rs
crates/omega-runtime/src/retrieval_persistence.rs
crates/omega-runtime/src/vector_persistence.rs
crates/omega-runtime/examples/vector_only_search.rs

crates/omega-store/src/cards.rs
crates/omega-store/schema.sql
crates/omega-store migration code

crates/omega-query/* if query role/planning ownership belongs there
crates/omega-protocol/* for canonical public ranked-hit serialization if required
```

Potential new modules are acceptable when they isolate a real responsibility, e.g.:

```text
omega-retrieval/src/regions.rs
omega-retrieval/src/query_shape.rs
omega-retrieval/src/presentation.rs
```

but do not create needless crate proliferation.

---

# 23. Implementation order

Use this order to avoid mixing several independent variables at once.

## Phase 1 — Freeze baseline

1. Preserve current vector-only/hybrid metrics on a frozen probe set.
2. Record card counts by level and vector input statistics.
3. Add tests that capture current known-bad representations where useful as migration tests, not desired behavior tests.

## Phase 2 — Region-card substrate

1. Add owner metadata.
2. Implement deterministic raw source Region construction.
3. Persist/reload Region cards.
4. Keep old ranking behavior temporarily.
5. Verify card/vector/lexical ordinal integrity.

## Phase 3 — Semantic input cleanup

1. Region raw source input.
2. Remove file identifier-bag semantic representation.
3. Clean Entity semantic input.
4. Remove Pack debug metadata.
5. Remove hidden 512 document truncation.
6. Bump semantic/card versions and force correct rebuild.

Run vector-only evaluation now. This isolates the largest expected quality gain.

## Phase 4 — Lexical/semantic alignment

1. Tantivy Region `text` = same raw Region source.
2. Ensure BM25 and semantic hit same ordinal.
3. Verify lexical component incremental behavior.

Run hybrid evaluation now.

## Phase 5 — Semantic quality + query roles

1. Persist meaningful semantic quality.
2. Add query-shape classifier.
3. Set family roles by query type.
4. Preserve family-level truth semantics.

Run ablation.

## Phase 6 — Dedup/presentation

1. hard duplicate witness;
2. owner/entity presentation grouping;
3. widen after grouping to fill K;
4. exact source previews/refs;
5. remove public internal `rank_score`.

Run top-K crowding tests.

## Phase 7 — Fusion experiment

1. isolate rank transform;
2. add smoothed RRF comparator(s);
3. update frontier math for each transform;
4. benchmark/evaluate;
5. choose only with evidence and architecture compatibility.

## Phase 8 — Final regression/performance

Run:

- retrieval quality;
- exact find;
- source snapshot tests;
- vector scalar/SIMD;
- Tantivy lifecycle;
- incremental reuse;
- persistence/migrations;
- daemon restart;
- public API schemas;
- relevant full workspace tests.

---

# 24. What NOT to do

Do not "fix" recall by:

- replacing exact scan with ANN;
- multiplying raw cosine/BM25 scores together;
- embedding entire files with unlimited length;
- increasing `top_k` only;
- increasing `max_candidates` only;
- hiding bad rankings with giant context output;
- making semantic provider mandatory for daemon correctness;
- adding Transformer/ONNX corpus inference before the static representation is fixed;
- adding per-language retrieval code;
- exposing internal Pack fields to the model;
- storing every raw source Region twice just for previews;
- treating tests/generated/examples with large global penalties copied from Semble;
- globally limiting one result per file;
- assigning owner `EntityId` directly as Region card identity;
- silently reusing old semantic vectors after input-format changes;
- declaring quality fixed from a handful of manual examples.

---

# 25. Deliverables

The agent must return a production-ready code change plus evidence.

Required deliverables:

1. **rewritten Region/Entity/File retrieval-card implementation**;
2. **new semantic input contract and version migration**;
3. **raw source Region vector corpus**;
4. **lexical/semantic same-unit alignment**;
5. **clean Entity semantic rendering**;
6. **no hidden Model2Vec document truncation**;
7. **typed/persisted semantic quality**;
8. **query-aware family roles**;
9. **logical-result dedup/grouping**;
10. **correct public ranked-hit presentation**;
11. **fusion transform abstraction + ablation harness**;
12. **updated vector-only evaluation tool**;
13. **hybrid retrieval evaluation tool/report**;
14. **before/after metrics report**;
15. **all required unit/integration/regression tests**;
16. **store schema/card/vector/lexical migrations/version bumps**;
17. **updated documentation/comments describing the actual representation**;
18. **no stale comments claiming the old semantic corpus is intentional**.

Produce a final report containing at least:

```text
BEFORE
  card counts by level
  vector-only Recall@1/5/10/20/100
  hybrid Recall@1/5/10/20
  MRR/NDCG
  top-K duplicate/crowding rate
  vector build time
  ranked p95
  vector/lexical disk bytes

AFTER
  same metrics

ABLATIONS
  Region representation
  truncation
  entity cleanup
  semantic quality
  query roles
  fusion transform
  presentation grouping
```

If the environment lacks Rust/toolchain/model assets/real-repository labels, implement the complete code + harnesses and mark the empirical results **UNVERIFIED** with exact commands required. Do not fabricate PASS metrics.

---

# 26. Final success condition

This task is complete only when Omega's ranked search behaves like this conceptually:

```text
source artifact
   │
   ├─ Entity card
   │    identity / qname / signature / docs
   │
   └─ Region cards
        exact bounded raw source spans
            │
            ├─ Tantivy BM25/text ranking
            ├─ Model2Vec static semantic vector
            └─ optional structural evidence

same Region ordinal
        │
        └─ evidence-family fusion
               │
               └─ logical owner/source grouping
                      │
                      └─ compact public hit
                           Entity (if any)
                           exact source_ref
                           exact span
                           bounded preview
                           truthful matched channels
```

and **not** like the current problematic shape:

```text
whole file raw text ───────────────→ lexical file candidate
whole file sorted unique names ───→ semantic file candidate
entity metadata bag ──────────────→ semantic entity candidate
name/qname only ──────────────────→ lexical entity candidate

all as unrelated ordinals
→ weak cross-family reinforcement
→ poor top-K semantic recall
```

The primary goal is not "make vectors score higher". The goal is:

> **Make the semantic vector represent the local source unit the user is actually trying to find, make all retrieval families talk about that same unit, and return the resulting logical source/entity answer without leaking backend artifacts.**
