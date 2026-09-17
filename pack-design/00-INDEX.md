# Pack design: where the rewrite starts

One `.md` per Pack in this folder. Each records what the Pack actually states,
what family the host gives each statement, and what the grammar offers that the
Pack never looks at. `00-CONTRACT.md` is the spec those documents are read
against. This file is the cross-Pack reading: the defects that are not one
Pack's mistake but the same mistake everywhere, and the order to fix them in.

## Defect A — a type the host files as a value (54 kinds, 22 Packs)

`entity_family` recognises a type by the words `type class trait struct enum
alias`. Every other word for a type falls through to Value. So these are
declared as types and stored as values:

| Pack | kinds | examples |
|---|---|---|
| omega-tsx, omega-typescript | 6 each | `definition.interface`, `definition.call_signature`, `definition.index_signature` |
| omega-cpp | 5 | `definition.cpp_concept`, `definition.cpp_namespace`, `definition.interface` |
| omega-scala | 5 | `definition.interface`, `definition.module`, `definition.scala_interface` |
| omega-java | 4 | `definitions.definition_interface`, `definitions.definition_record` |
| omega-ruby | 4 | `definition.module`, `definition.namespace` |
| omega-rust | 3 | `definition.union`, `definition.module`, `definition.signature_like` |
| omega-c | 2 | `definition.c_definition_union` |
| … 15 more Packs | | `dart_mixin`, `php_interface`, `erlang_record`, `kotlin_namespace`, `elixir_module` |

An interface, a union, a record, a mixin, a protocol, a concept and a namespace
are all types. Asking Omega for a type finds none of them.

## Defect B — the family won by a substring inside a longer word (20 kinds)

The match is a plain `contains`, so a word that merely *spells* a keyword wins:

| kind | matched | inside |
|---|---|---|
| `definition.python_class_member_constructor_context` | `struct` | con**struct**or |
| `definitions.definition_constructor` (java) | `struct` | con**struct**or |
| `definition.gdscript_constructor`, `definition.solidity_constructor` | `struct` | con**struct**or |
| `definition.rust_scoped_constructor_binding_context` | `struct` | con**struct**or |
| `definition.go_import_alias_constructor_binding_context` | `struct` | con**struct**or |
| `semantic_hint.graphql_object_type_definition_structure_hint` | `struct` | **struct**ure |
| `definition.c_definition_typedef` | `type` | **type**def |

Constructors land in Type. They are callables. And no renaming fixes it: any
kind containing the letters `constructor` is Type before `function|method|
callable` is ever consulted. **This one is the host's to fix** — match on word
boundaries, and consult the more specific word first. It is not
language-specific, so it belongs in `content_builder.rs`.

`c_definition_typedef` → Type is right by accident: a typedef does name a type.
Accidentally right is still not a rule.

## Defect C — the boundary the Pack never reaches

How much of the grammar each Pack looks at:

| Pack | node types seen | of | |
|---|---|---|---|
| omega-xml | 14 | 67 | 21% |
| omega-razor | 61 | 262 | 23% |
| omega-dart | 58 | 221 | 26% |
| omega-nginx | 7 | 26 | 27% |
| omega-c-sharp | 64 | 224 | 29% |
| omega-erlang | 14 | 48 | 29% |
| omega-groovy | 19 | 65 | 29% |
| omega-swift | 56 | 183 | 31% |
| omega-scala | 46 | 150 | 31% |
| omega-ruby | 46 | 149 | 31% |
| … | | | |
| omega-markdown | 46 | 51 | 90% |
| omega-json | 12 | 13 | 92% |
| omega-json5, omega-toml | all | | 100% |

Coverage is not a target — a grammar names hidden and punctuation nodes nobody
should ask for, and a Pack that touched 100% of Razor would be noise. The
number is a question, not a verdict: each Pack's document lists the untouched
types by name, and the rewrite answers, per type, *does this carry meaning a
question could be asked about*. The bottom of this table is where the answer is
most often yes.

## Defect D — the name is the whole node (40 templates, 19 Packs)

A template names its emission with a `capture_ref`. In these, the capture is a
whole container node, so the name stored is every byte that node covers:

| Pack | kinds | the captured node |
|---|---|---|
| omega-xml | `value.document`, `value.text` | `(document)`, `(text)` |
| omega-json, omega-jsonc | `value.document`, `value.object`, `value.array`, `literal.string` | `(document)`, `(object)`, `(array)` |
| omega-toml, omega-json5, omega-yaml | `value.document`, `value.array`, `value.object` | same |
| omega-typescript, omega-tsx | `data.object`, `data.array`, `data.string` | `(object)`, `(array)` |
| omega-php, omega-ruby | `literal.string` | `(string)` |

`value.*` and `data.*` are mentions, and `names_something` only drops
`literal.` under `data`, so the rest are stored. In XML the same bytes are
stored once per nesting level: a document containing an element containing an
element yields `value.document` naming the file, `relation.document_contains_
element` naming the top element, and `relation.element_contains_child` naming
the child -- the file, written out again at every depth.

This is where the row count and the database size come from on data files, and
it is not a storage problem. Nothing can be asked of a name that is a whole
document. The scope emissions in the same shape (`scope.file <- (source_file)`,
`scope.block <- (block)`) are a different case: a scope is a region and the
span is the point of it, but its name is that same blob and it does not need
one.

## Defect E — containment stated as a pattern

omega-xml has six families of "context" pattern -- `parent_child`,
`ancestor_grandchild`, `depth3`, `two_attr`, `coordinate_entries`,
`parent_child_text` -- that hard-code a tree shape two and three edges deep
with attributes at each level, and a `structure-v2` set that states
`(document (element))`, `(element (start_tag (attribute)))` and
`(element (element))`. Sixteen of its 21 templates say only that one node is
inside another.

The tree already says that, and every one of them costs a match per tuple: the
depth-3 pattern matches once for each (ancestor, child, intermediate,
descendant) combination in the document. The four `relation.*_contains_*` kinds
are not relations the host knows -- it recognises `relation.implements`,
`.tests`, `.depends`, `.config`, `.data` and `.handles` -- so all four arrive
as plain references. They cost a cubic number of matches to state something
nothing reads.

Containment is a scope. One region per element answers every one of those
questions, and the Pack states it once.

## Defect F — the generator's batch number, stored a million times

1 604 of the 3 673 templates the shipped Packs contain carry a constant
attribute `source`. Its values are the versions of the script that wrote the
template:

| value | templates |
|---|---|
| `pack-canonical-key-inputs-v2.7` | 249 |
| `semantic-closure-v3.146` | 171 |
| `pack-ownership-v2.4` | 102 |
| `pack-resolution-hints-v2.5` | 66 |
| `pack-resolution-paths-v2.6` | 64 |
| `depth-completion-d1-v2.9` | 58 |
| `semantic-closure-v3.146-batch3` | 43 |

A template's attributes are evaluated per emission and stored in the item's
bag. So 44% of all templates write a fixed string into the store once for every
construct they match -- the batch number of the generator run, on every element
of every XML file, answering nothing. `semantics`, `role` and `symbol_category`
(328, 250 and 158 templates) are constants of the same kind: a restatement of
the `output_kind` the template already declares.

## Defect G — a coverage guard whose reason is a label

1 348 coverage guards ship. 316 of them give a reason that is a single token,
most often `depth_completion_high_confidence_ast_fact`. A guard exists to say
what a Pack cannot see, so that a query knows an answer is partial. A token
naming the generator's confidence tier says nothing about the language and
nothing a reader could act on. omega-xml alone ships 18 guards for 21
templates, three of them that token.

## Order

1. Fix Defect B in the host first — until the family is decided by whole words,
   no kind can be named correctly.
2. Then rewrite, worst boundary first, checking A and B per Pack as it goes:
   xml, razor, dart, nginx, c-sharp, erlang, groovy, swift, scala, ruby.
3. json, json5, toml, markdown are already at their boundary; they are rewritten
   last and only for what their documents flag.

---

# Found by the first rewrite wave (razor, dart, nginx, c-sharp, erlang)

Each of these was reported by an agent rewriting one Pack and then measured
here across all 61.

## Defect H - a filter the runtime never applies

43 Packs write tree-sitter predicates into `queries.scm`: 233 `#eq?`, 107
`#any-of?`, 46 `#match?`, 45 `#lua-match?`, 12 `#not-match?`, and a tail of
`#not-eq?`, `#not-any-of?`, `#is-not?`, `#has-ancestor?`, `#not-has-parent?`.
**None of them runs.** Nothing in `crates/` reads `general_predicates` or the
text predicates; the one predicate call site,
`runtime.rs:1490 query.property_settings(...)`, serves injections and reads
`#set!` only.

So a pattern written to match one thing matches every node of its root type,
and the author cannot tell from reading the file. omega-razor shipped
`(#eq? @n "href")` next to a coverage guard reading `plain_literal_href_only`;
it matched every attribute with a string value. This is a wrong-output defect,
not a cost one, and it is the largest single source of over-emission we have
found.

Two separate problems underneath it:

- `#eq?`, `#match?`, `#any-of?` and their negations **are** tree-sitter's own,
  applied by the Rust binding inside `QueryMatches::advance`. The engine bypasses
  that path, so they are the host's to enable.
- `#lua-match?`, `#is-not?`, `#has-ancestor?`, `#not-has-parent?` (54 uses in 13
  Packs) are nvim-treesitter extensions that tree-sitter has never had. No host
  change will make them work; those 13 Packs must state the filter structurally.

## Defect I - the universal capture

Six Packs ship `(_) @structural.node` as a top-level pattern: it matches every
named node of every file.

In omega-editorconfig, omega-prisma and omega-vue no template reads it — one
query match per node per file for zero emissions.

In omega-csv, omega-sas and omega-vbscript it is worse. A template turns it
into `semantic_hint.syntax_node`, a mention, **named `capture_ref` of the same
capture** — so every named node in the file is stored, under its own full text
as its name. On a CSV that is every row and every field, plus the document. This
is Defect D taken to its limit and it lands on exactly the data files that
dominated the original row count.

## Defect J - a name that is a constant

105 templates in 27 Packs set `name` to a `literal`. Every `-spec` in a corpus
was stored under the name `erlang_spec`, every Dockerfile instruction of a kind
under that kind's name, while the real name sat two nodes away. Worse than
Defect D: a whole-node name is at least distinct per emission, a constant name
collapses every instance of a construct in the repository onto one string.

Leaders: omega-dockerfile 12, omega-sql 9, omega-julia 8, omega-make 8,
omega-batch 6, omega-twig 6, omega-zig 6, omega-bash 5.

## Defect K - the same template twice

78 templates in 14 Packs are byte-identical to another template in the same
file — same capability, same `output_kind`, same span capture, same name
expression, same attributes. Each duplicate is a second emission at the same
span saying the same thing. They come from concatenating generator passes
(`external-helix-tags` and `upstream_tags` over the same captures) without
reconciling them. Leaders: omega-cpp 11, omega-scala 10, omega-zig 9,
omega-elixir 7, omega-lua 7.

## Defect L - a framework overlay inside a language Pack

`00-CONTRACT.md` §6 forbids it and nothing enforces it. omega-c-sharp held 21
templates encoding ASP.NET Core and EF Core (`app.MapGet`,
`builder.Services.AddScoped<..>`, an EF navigation-property rule spelled as a
tree shape); omega-dart held 3 encoding go_router, under a header comment
asserting "No Flutter/go_router semantics here". Both are now removed. Not yet
measured across the other 56 Packs — the same generator wrote omega-java
(Spring), omega-typescript and omega-php, so expect more.

## Defect M - a template no pattern can bind

7 templates in 4 Packs (omega-c-sharp 3, omega-cpp 2, omega-c 1, omega-rust 1)
require a set of captures that no single pattern binds together. By the skip
rule the template is skipped on **every** match, so it emits nothing, while the
manifest and the coverage layer go on claiming the capability. The shipped
omega-dart declared no Dart method at all for this reason.

`validate_external_assets` does not catch it: it checks that each referenced
capture exists somewhere in the file, which passes when another pattern binds
it. The compiled Query already knows each pattern's capture set, so a
per-pattern check is available and worth adding.

## Two host rules that are traps, not defects

Both are real behaviour of `content_builder.rs`, and both are now in
`AGENT-BRIEF.md`.

**A carrier must also pass `is_definition_kind`.** Line 103 folds an emission
only when `is_definition_kind(kind) && is_carrier_kind(kind)`. A kind ending
`_candidate` that contains no `definition` and ends in none of
`.type/.function/.class/.method/.trait` is not folded onto the declaration at
its span — it falls through to the mention branch and is stored as a reference
to nothing. 247 templates in 35 Packs end in `_candidate` without passing the
definition test. Some of those are deliberate (the runtime's own
`reference_candidate.*` family is meant to be a mention), so treat the number
as an upper bound and judge per Pack. The rewritten omega-xml tripped over this
and is fixed.

**A scope kind must not also read as a declaration.** Line 94 selects
declarations and line 234 selects regions, independently. `scope.function` ends
with `.function`, so it becomes both a region and a declaration of that name. 9
kinds in 5 Packs do this today: `scope.function` and `scope.class` in
omega-javascript, omega-python, omega-tsx and omega-typescript, and one in
omega-rust.
