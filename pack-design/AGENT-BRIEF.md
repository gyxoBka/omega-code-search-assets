# Rewriting one Pack: everything you need

You are being sent to rewrite exactly one language Pack.

## Required reading, before you touch anything

Read all four, whole, in this order. They are your context; you should not need
to reverse-engineer the engine.

1. **This file** — how a Pack works, what the host reads, what goes wrong.
2. **`pack-design/00-CONTRACT.md`** — the spec a Pack is judged against.
3. **`pack-design/00-INDEX.md`** — the defects that are not one Pack's problem,
   measured across all 61, and the order the rewrite goes in.
4. **`pack-design/<your-pack>.md`** — your own Pack's document. This one is not
   optional and not a skim. It already holds every template your Pack emits,
   the family the host gives each kind, the occurrence each mention becomes,
   what it emits that nothing reads, and every node type in its grammar the
   Pack never looks at. It is the inventory you are working from; do not
   rediscover it by hand, and do not start writing until you have read it to
   the end.

If `pack-design/<your-pack>.md` does not exist, stop and say so rather than
improvising — the document is generated from the Pack and the grammar, and
working without it means working blind.

Two repositories:

- `D:\WebProjects\omega-code-search-assets` — Packs, grammars, frameworks. This
  is canonical. Your work happens here.
- `D:\WebProjects\omega-code-search` — the engine that reads them. Read it to
  check a rule; change it only if the defect is genuinely the host's, and then
  see **When the defect is the host's** at the end.

---

## 1. What Omega is, in one paragraph

Omega indexes code. An agent asks a question about the code and Omega answers.
That is all of it. Where Omega found nothing, the answer is "not found" — that
is a complete, correct answer and needs no apparatus around it.

Everything in a Pack must trace back to a question someone could ask. A fact no
question reaches is not neutral: it costs a tree-sitter match, an emission, a
row, and index bytes, and it dilutes the answers that do matter. **No rituals
for the sake of rituals.** If you cannot say which question an emission
answers, delete it.

## 2. Why you are here

The current Packs were written by ChatGPT in bulk. About 90% of them are bad,
and they are bad in the same ways. We measured it. A repository index came to
1.87M rows and 296 MB; the largest producers were data files, and when we
looked at why, the Packs were storing whole documents as names, storing the
generator's own batch number on every emission, encoding tree containment as
cartesian query patterns, and declaring almost nothing that a question could
resolve against.

The order of work is: understand what the Pack extracts, judge what it *should*
extract to cover its area of responsibility, write that down, then rewrite the
Pack cleanly. Not micro-optimisation. We already hit the limit of that: earlier
attempts to merge patterns and delete "unread" templates mechanically either
changed the output silently or broke Packs outright. See §10.

---

## 3. What a Pack is, physically

Three files in `packs/<name>/`:

### `manifest.toml`

```toml
schema_version = 1
distribution_class = "production"     # never "staged" unless it truly cannot build
kind = "language"
name = "omega-xml"
version = "2.0.0"                     # bump the major when you rewrite
pack_runtime_version = "2"
parser_id = "tree-sitter-xml"         # must match grammars/<name>/manifest.toml
compatible_grammar_identities = ["tree-sitter-xml@<rev>#nodes:<sha256>"]
capabilities = ["data", "definitions", "references"]
license = "MIT"
source = "https://github.com/gyxoBka/omega-code-search-assets"

[resource_budget]
parse_millis = 200
query_millis = 200
max_matches = 15000
max_emitted_ir = 30000
max_injection_depth = 4
max_decoder_expansion = 2048
max_string_bytes = 65536
```

`capabilities` must be exactly the set your templates use — no more (a declared
capability with no template is a lie the coverage layer repeats) and no less
(the Pack will not compile).

### `queries.scm`

Tree-sitter query patterns with captures. One compiled Query per Pack, one tree
walk per file. Every pattern you add is matched against every node of its root
type in every file of that language, so a pattern's cost is real.

### `rules.json`

```json
{ "schema_version": 1,
  "asset": "omega-xml",
  "templates": [ ... ],
  "decoders": [], "injections": [], "coverage_guards": [ ... ],
  "legacy_rules": [] }
```

A template:

```json
{ "query": "queries.scm",
  "capability": "definitions",
  "output_kind": "definition.config_element",
  "span_capture": "element",
  "name": { "kind": "capture_ref", "name": "element.name" },
  "attributes": {},
  "fields": {},
  "decoder": null }
```

- `span_capture` — the capture whose byte range the emission occupies. Write it
  **without** the leading `@`.
- `name` — an expression. If absent, the name is the span capture's own text
  (almost never what you want; see Defect D).
- `attributes` — evaluated per emission and stored in the item's bag.
- `fields` — evaluated per emission; the framework overlay matches on them.

## 4. How the runtime executes it

One compiled Query, one walk of the tree per file. For each match the runtime
gathers the **candidate templates** whose captures that match bound, then
evaluates each. A template is **skipped** (silently) when its name expression,
its span capture, or any attribute expression references a capture that this
match did not bind.

That skip rule is why optional captures are dangerous and why one match can
legitimately feed several templates. **One pattern per node, not one pattern
per question**: if you want to state three things about an element, write one
pattern that captures what all three need, and three templates over it.

Each surviving template produces a `NormalizedEmission` (144 bytes) with a
capability, a kind, a span, a name, attributes and fields. Then the host reads
the kind string.

---

## 5. The kind string is a protocol

`output_kind` is not a label. It is how the Pack tells the host what it just
said. Every rule below is a literal reading of the string, in
`crates/omega-ingest/src/content_builder.rs`.

### Is it a declaration?

`is_definition_kind` — **false** if the kind starts with any of `call.`,
`reference`, `type_use.`, `value_`, `import`. Otherwise **true** if it contains
`definition`, or ends with `.type`, `.function`, `.class`, `.method`, `.trait`.

The prefix exclusion exists because `call.method` ends with `.method`: every
method call in a corpus used to be stored as a declaration of the method it
called — 38 913 of 207 169 declarations on one repository, 4 525 of them named
`unwrap`, each with its own retrieval card.

### Is it a carrier?

`is_carrier_kind` — the kind ends with `_candidate`. Then `carried_name` is the
last dot-segment minus `_candidate`, and the emission is folded into the
attribute bag of the declaration **at the same span**, as `omega.pack.<name>`,
with the emission's own name as the value. A carrier with no declaration at its
span is materialised on its own.

**A carrier must also pass `is_definition_kind`.** The fold is
`is_definition_kind(kind) && is_carrier_kind(kind)`. So `text_candidate` is not
a carrier: it contains no `definition` and ends in none of the five suffixes, so
it falls through to the mention branch and is stored as a reference to nothing.
Name it `definition.text_candidate`. 247 templates in 35 Packs end in
`_candidate` without passing the definition test.

**And the declaration it attaches to must exist.** A carrier folds onto a
declaration at the same span; if the Pack never declares anything there, the
carrier carries nothing. omega-razor had 20 carrier kinds and 2 declaration
kinds, so nearly every carrier in it attached to nothing.

So a carrier must be emitted with the *declaration's* span, not the evidence's
span. `definition.return_type_candidate` → `omega.pack.return_type`.

These carrier attribute names are dropped as provenance and never stored:
`source`, `semantics`, `identity_semantics`, `ownership`, `signature_component`.

### Is it a scope?

`is_scope_kind` — the kind is exactly `scope` or starts with `scope.`. It
becomes a region. Its span is the point of it; do not give it the container's
text as a name.

**A scope kind must not also read as a declaration.** Declarations and regions
are selected by two independent filters, so `scope.function` — which ends with
`.function` — becomes a region *and* a declaration of that name. Never end a
scope kind with `.type`, `.function`, `.class`, `.method` or `.trait`, and never
put `definition` in one. `scope.function_body` and `scope.code_block` are safe;
9 kinds in 5 Packs are not.

### Which family does a declaration get?

`entity_family` splits the kind on every non-alphanumeric character and matches
**whole words**. `test`/`tests`/`testcase` wins from any position. Otherwise the
**last** matching word wins:

| family | words |
|---|---|
| Test | test, tests, testcase |
| Namespace | module, modules, namespace, namespaces, package, packages |
| Type | type(s), typedef(s), class(es), trait(s), struct(s), enum(s), alias(es), interface(s), union(s), record(s), mixin(s), protocol(s), concept(s) |
| Callable | function(s), method(s), callable(s), constructor(s), destructor(s), procedure(s) |
| Config | config, configs, configuration |
| Value | anything else |

Last-word-wins because these kinds are English compounds whose head noun
trails: `class_method` is a method, `function_type` is a type. Choose the word
deliberately — this is the one lever you have over where a declaration lands.

Words *not* in the lists fall to Value. `signature`, `object`, `schema`,
`variant`, `component`, `entity`, `model`, `shape` are all Value. If you mean a
type, say a word from the Type row.

### What does a mention become?

Anything that is not a declaration and not a scope is a mention. Its occurrence
kind:

| kind | occurrence |
|---|---|
| exactly `relation.implements` | implements |
| exactly `relation.tests` | tests (or tests_convention_candidate with a convention test signal) |
| exactly `relation.depends` | depends |
| exactly `relation.config` | config |
| exactly `relation.data` | data |
| exactly `relation.handles` | handles |
| any other `relation.*` | **plain reference** |
| contains `call` | call |
| contains `import` or `export` | binding |
| anything else | reference |

The `relation.` match is `strip_prefix("relation.")` then an **exact** compare.
`relation.element_contains_child` is not a relation; it is a reference with a
long name. This is the single most common mistake in the shipped Packs.

### What gets thrown away

`retain_named_spans` drops emissions that name nothing:

- capability `scopes`: kinds starting `control_flow.`, `control_context.`,
  `scope_context.`
- capability `data`: kinds starting `literal.`
- capability `bindings`: `binding.mutable_specifier`, `binding_pattern_shape.*`
- always: `reference_context.attribute_path`
- `reference_candidate.value` on a span that also has an `attribute_path`
- `reference_context.*` on a span that also carries a `literal.*` or
  `control_flow.*` emission
- `reference_candidate.*` inside a `reference_candidate.lifetime` span

**Read that second-to-last rule twice.** A `literal.*` or `control_flow.*`
emission is discarded itself, but its *span* is used as a marker to suppress
role emissions over the same bytes. Deleting "unread" literal templates once
cost us 1 925 mentions that should have been dropped. Do not remove a
`literal.*` or `control_flow.*` template on the grounds that nothing reads it.

---

## 6. The expression vocabulary

Three expression shapes:

```json
{"kind": "capture_ref", "name": "element.name"}
{"kind": "literal", "value": "element"}
{"kind": "call", "op": "trim", "args": [ ... ]}
```

A `capture_ref` evaluates to that capture's source text.

Available ops (`crates/omega-ingest/src/pack/expr.rs`): `text`, `trim`,
`lower`, `upper`, `strip_prefix`, `strip_suffix`, `replace_fixed`, `concat`,
`split`, `join`, `select`, `default`, `span`, `parent`, `present`,
`ordered_children`, `stem`, `path_parent`, `relative`, `normalize_separators`,
`extension`, `path_prefix`, `path_suffix`, `source_root`, `module_stem`, `map`,
`stable_sort`, `dedup`, `map_trim`, `map_lower`, `map_upper`, `first`, `last`.

The shipped Packs use three of the thirty-three: `capture_ref`, `literal` and a
handful of `first(ordered_children(...))`. That is itself a symptom. When a
grammar leaves a name as an anonymous token, you can still take it:
`first(split(trim(<node text>), " "))`. When a reference is spelled `&name;`,
strip it to `name` so it can resolve — the old XML Pack emitted `&name;`
verbatim and could never have matched a declaration.

`strip_prefix`/`strip_suffix` take 2 args, `replace_fixed` 3, `select` takes a
numeric string index, `split` returns a list.

## 6a. Which query predicates work

`#eq?`, `#not-eq?`, `#match?`, `#not-match?`, `#any-of?` and `#not-any-of?` are
tree-sitter's own and **do** filter: the runtime iterates matches with the
source as the text provider, and the binding applies them itself. Use them.

Everything else does not exist. `#lua-match?`, `#not-lua-match?`, `#is-not?`,
`#has-ancestor?`, `#not-has-parent?`, `#strip!`, `#gsub!` and
`#select-adjacent!` are nvim-treesitter extensions that arrived with copied
`locals.scm` baselines. tree-sitter parses them into a bucket nothing reads, so
the pattern matches **everything** and the author cannot tell from reading the
file. 70 uses survive in 13 Packs.

`#set!` is read, but only by the injection layer.

So: if you need a filter, use one of the six that work, or state it
structurally — a distinct node type, a field, an anchor, an alternation. Never
write an operator that is not in that list of six.

## 7. Capabilities

Ten are understood by the engine: `definitions`, `references`, `data`,
`bindings`, `calls`, `scopes`, `types`, `imports`, `modules`, `tests`. Two more
are read only by the relation-coverage layer in
`crates/omega-semantic/src/materialize.rs`: `implements` and `config_consumers`.

`value_origins` appears in 9 templates across 4 Packs and **no host code reads
it**. If your Pack uses a capability outside that list, it answers nothing.

`names_something` keys off the capability, so the capability you choose changes
what survives (§5). Match it to the kind: `definition.*` → `definitions`,
`scope.*` → `scopes`, a mention → `references`/`calls`/`data` as appropriate.

## 8. Coverage guards

A guard states what the Pack **cannot** see, so a query knows an answer is
partial:

```json
{ "query": "queries.scm",
  "capabilities": ["references"],
  "reason": "An entity reference is linked to its declaration; the entity is not expanded, so text a reference stands for is not part of any element's value." }
```

1 348 guards ship and 316 of them give a single token as the reason, usually
`depth_completion_high_confidence_ast_fact`. That is a generator confidence
tier, not a limitation of the language. Write guards a human can act on, and
write few: three honest ones beat eighteen labels. Every guard's capability
must be one your templates actually program. The key is `capabilities` — a
list, not `capability`.

---

## 9. The seven defect classes, and how to find each

These are measured across all 61 Packs. Check every one against your Pack.

**A — a type filed as a value.** 54 kinds in 22 Packs. `interface`, `union`,
`record`, `mixin`, `protocol`, `concept`, `namespace`, `module` were not in the
host's Type vocabulary; they are now (§5), but check your kinds actually use
one of those words for the construct they name. Find: take every declaration
kind, run it through the §5 table, compare with what the construct actually is.

**B — the family won by a substring.** Fixed in the host (whole-word matching)
as of 2026-09-17. But check your kinds still *say* the right word:
`construct_signature` no longer matches `struct` and now lands in Value, which
for a TypeScript construct signature is wrong. Rename it.

**C — the grammar's boundary not reached.** Your Pack's `.md` lists every node
type in `grammars/<name>/node-types.json` the Pack never mentions. Coverage is
not a target — hidden nodes and punctuation should stay untouched — but for
each untouched type ask: *does this carry meaning a question could reach?* The
Packs at the bottom of the table (xml 14/67, razor 61/262, dart 58/221, nginx
7/26, c-sharp 64/224) are ignoring real constructs.

**D — the name is a whole node.** 40 templates in 19 Packs. A `capture_ref`
name is that capture's source text, so a name taken from `(document) @document`
stores the entire file as a name. Find: for every template, look at what its
name capture is attached to in `queries.scm`. If it is a container node
(`document`, `object`, `array`, `block`, `element`, `body`, `program`,
`source_file`, `text`, `string`), it is wrong. Names are names.

**E — containment stated as a pattern.** The tree already holds containment,
and a declaration nested inside another already carries its container through
the `within:` namespace segment. A pattern like
`(element (element (element ...)))` costs one match per tuple of nodes at that
depth — cubic on a nested file — to state something the tree said for free.
Delete these. If you need the extent of a construct, emit one `scope.*` region.

**F — the generator's batch number, stored per emission.** 1 604 of 3 673
templates carry a constant attribute `source` with values like
`semantic-closure-v3.146-batch3`, `pack-canonical-key-inputs-v2.7`,
`depth-completion-d1-v2.9`. Attributes are evaluated and stored per emission,
so this writes a fixed string into the index once per matched construct.
`semantics`, `role` and `symbol_category` (328, 250, 158 templates) are the
same thing: a restatement of the `output_kind` the template already declares.
(Carriers drop five of these names as provenance; ordinary declarations and
mentions do not.) Delete every constant attribute that does not answer a
question.

**G — a guard whose reason is a label.** See §8.

**H — a filter the runtime never applies.** See §6a. Find: grep your
`queries.scm` for `#`.

**I — the universal capture.** A top-level `(_) @x` matches every named node of
every file. Six Packs ship one; in three of them a template turns each match
into a mention named with that node's whole text. Delete it.

**J — a name that is a constant.** 105 templates in 27 Packs set `name` to a
`literal`, so every instance of a construct in the repository collapses onto one
string. Find: grep `rules.json` for a `name` whose `kind` is `literal`.

**K — the same template twice.** 78 templates in 14 Packs are byte-identical to
another in the same file. Find: group templates on (capability, output_kind,
span_capture, name, attributes).

**L — a framework overlay inside a language Pack.** Forbidden by the contract
and not enforced. omega-c-sharp held 21 templates of ASP.NET and EF Core;
omega-dart held 3 of go_router under a comment denying it. If a pattern encodes
a particular library's call shape, it belongs in `frameworks/`, not here.

**M — a template no pattern can bind.** If no single pattern binds all the
captures a template needs together, the skip rule drops it on every match and it
emits nothing — while the manifest still claims the capability. The shipped
omega-dart declared no method at all this way. The validator does not catch it:
it only checks each capture exists somewhere in the file. Check per pattern.

---

## 10. Traps: what we already tried that does not work

Do not repeat these. Each one cost a day.

- **"The host discards this kind, so stop emitting it."** Wrong for
  `literal.*` and `control_flow.*`: they are discarded but their spans suppress
  role emissions over the same bytes (§5). Removing 135 such templates *added*
  1 925 mentions.
- **Merging patterns that share a root node.** Two `field_declaration`
  patterns merged with an optional name capture gave −3 180 matches and **+402
  emissions**, because the optional capture admitted unnamed tuple-struct
  fields the separate patterns had excluded. Optional captures change what
  matches, not just how it is written.
- **Merging patterns that look identical after stripping.** A comparator that
  stripped string literals made `["if" "else"]` and `["for" "while"]` look the
  same; 154 patterns were merged into nonsense and 15 Packs stopped compiling.
  If you compare patterns, compare them with their literals intact.
- **Editing patterns by line manipulation.** An auto-fixer that swapped lines
  scrambled a complex TSX pattern. Rewrite a pattern by hand, whole.
- **Deleting templates without their captures, or captures without their
  templates.** One pass removed patterns using only template captures and wiped
  all 22 `@injection.*` captures in omega-html, which no template references but
  the injection layer reads. Walk every string in `rules.json`, not just
  template fields.
- **Deleting a capability's last template.** You then have a manifest declaring
  a capability with no program, and coverage guards referencing it. Trim
  `capabilities` in the manifest and the guards in the same change.

## 11. The procedure for your Pack

1. **Read `pack-design/<pack>.md` to the end** — see the required reading at the
   top of this file. Every template, the family the host gives each kind, the
   occurrence each mention becomes, what is emitted that nothing reads, and
   every untouched node type is already in there. Work from it.
2. **Read the Pack**: `manifest.toml`, `queries.scm`, `rules.json`. Read
   `grammars/<pack>/node-types.json` for the node shapes — fields, children,
   which nodes are named. A pattern can capture a named node by its type, and
   an anonymous node by writing its literal text (`"=" @eq`). What it cannot
   capture is an anonymous token whose text varies — an identifier the grammar
   never exposes as a named node. XML spells entity names that way, so
   `<!ENTITY foo "bar">` is captured at the declaration and the name is taken
   from its text with `first(split(trim(...), " "))`.
3. **Decide what the language's constructs are** and which question each
   answers. Write that into the `.md` as two sections: *What is wrong with it*
   (concrete, with counts) and *What it should extract* (a table: what → node →
   emitted as → family). `pack-design/omega-xml.md` is the worked example.
4. **Write the Pack from scratch.** Do not patch the old one. One pattern per
   node; several templates over one pattern where one match answers several
   questions. Every emission traceable to a question.
5. **Verify** (§12).
6. **Commit** the `.md` and the Pack together, with a message that states what
   was wrong and what replaced it, ending with the session trailer.

## 12. How to verify — exact commands

Compile every Pack against its real grammar. This is the hard gate: it parses
`queries.scm` against the pinned grammar, checks every capture a template
references exists, and validates manifests and hashes.

```bash
cd /d/WebProjects/omega-code-search
cargo run --release -j 6 -p omega-runtime --example validate_external_assets -- D:/WebProjects/omega-code-search-assets
```

Expect `asset validation passed` with `staged_skipped: 0`. A Pack marked
`distribution_class = "staged"` is **skipped**, so staging a Pack hides it from
this gate rather than fixing it.

Package the assets (also a structural check):

```bash
cd /d/WebProjects/omega-code-search-assets && node tools/build-source.mjs
```

`dist/` is generated and is never committed.

Regenerate or hand-update your Pack's document after the rewrite so its tables
describe the new Pack, not the old one.

If you change anything in `D:\WebProjects\omega-code-search`, build with
`cargo build --release -j 6` and run `cargo test --release -j 6`. Kill leftover
daemons first (`Stop-Process -Name omega-daemon -Force`) or the link step fails
with "Отказано в доступе" on `omega-daemon.exe`.

## 13. The questions to ask of every Pack

Answer all of these in the `.md` before writing a line of the new Pack.

1. What kinds of file is this language used for in a real project, and what
   would an agent ask about them?
2. What does the language **declare**? Every named thing a question could
   resolve to. Is each one emitted, and with a kind whose words put it in the
   right family?
3. What does the language **reference**? Does each reference's name match the
   spelling of the declaration it should resolve to, after stripping sigils?
4. What is emitted as a mention that has nothing to resolve against?
5. Which emissions are named with a whole node rather than a name? (D)
6. Which patterns state containment the tree already holds? (E)
7. Which `relation.*` kinds are not one of the six the host knows?
8. Which attributes are constants? What question does each answer? (F)
9. Which node types in the grammar carry meaning and are untouched, and under
   which capability do they belong? (C)
10. Does every declared capability have a template, and every template's
    capability appear in the manifest?
11. Does every coverage guard name a real limitation in language terms, and is
    its capability one the Pack programs? (G)
12. What does the Pack state that answers no question at all? Delete it.

## 14. Rules that must not be broken

- **No language-specific branches in the engine.** A Pack states language
  facts; the runtime is generic. If your fix needs a branch in the host for one
  language, the fix is wrong.
- A Pack may not encode framework semantics. Syntax and the language's own
  declarations only; frameworks are overlays in `frameworks/`.
- `dist/` is generated, never committed.
- `D:\WebProjects\omega-code-search-assets\.secrets\` holds ed25519 catalog
  keys. It is gitignored. Never commit, read out, or expose it.
- Local installs need no signature.
- End commit messages with:
  `Claude-Session: https://claude.ai/code/session_017mpbMrebarDtuEL9LHnuVJ`

## 15. When the defect is the host's

Sometimes the Pack cannot state the truth because the engine will not hear it.
That happened once already: no kind containing the letters `constructor` could
ever be a Callable, because `struct` was tested first. Renaming could not fix
it, so the host was fixed.

If you conclude the same, say so explicitly in the `.md`, and note that these
files in the engine are **frozen**:

`content_builder.rs`, `surface.rs`, `materialize.rs`, `indexes.rs`,
`resolver/*`, `pack/runtime.rs`, `expr.rs`, `decoder.rs`, `policy.rs`,
`parser_registry.rs`

Changing one requires re-running the design-set obligations
(`cargo test --release -j 6 -p omega-pack-design-set`; six behavioural tests
must pass) and re-stamping `tests/fixtures/design-set/freeze.json` — update the
file's sha256 and append a dated note to `methodology_notes` saying what
changed, why it is not language-specific, and that the obligations were re-run.
The hash test `frozen_generic_semantic_sources_fail_closed_on_change` fails
until you do.

Prefer reporting the finding over changing a frozen file yourself unless the
change is small and provably generic.

## 16. Done means

- `pack-design/<pack>.md` has **What is wrong with it** (concrete, with counts)
  and **What it should extract** (a table), and its factual tables describe the
  Pack you are leaving behind, not the one you found.
- `packs/<pack>/queries.scm` and `rules.json` are rewritten, not patched.
- `manifest.toml` declares exactly the capabilities the templates use, and the
  version's major is bumped.
- No template names an emission with a container node.
- No template carries a constant attribute that answers no question.
- No pattern states containment.
- Every `relation.*` kind is one of the six the host knows.
- Coverage guards are few and each names a real limitation in language terms.
- `validate_external_assets` prints `asset validation passed` and
  `staged_skipped: 0`.
- One commit holding the `.md` and the Pack, with the session trailer.

Report back: what the Pack said before, what it says now, the template and
pattern counts either way, and anything you found that belongs in
`00-INDEX.md` because it is not one Pack's problem.
