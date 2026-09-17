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

## Defect H - a filter that is not tree-sitter's

**Corrected 2026-09-17.** The first report of this said no predicate runs at
all. That is wrong, and it was checked the wrong way: grepping the engine for
`general_predicates` finds nothing, but the engine never needed to look. The
match loop is `cursor.matches(&q.query, tree.root_node(), source.as_bytes())`,
and the Rust binding applies text predicates itself inside
`QueryMatches::advance` (tree-sitter 0.25.10, `binding_rust/lib.rs:3450`,
`satisfies_text_predicates`). So `#eq?`, `#not-eq?`, `#match?`, `#not-match?`,
`#any-of?` and `#not-any-of?` **do filter** -- 386 uses across the Packs work as
written.

What does not work is everything tree-sitter never had. Those go into
`general_predicates`, which nothing reads, so the pattern fires unfiltered:

| operator | uses | Packs |
|---|---|---|
| `#lua-match?` | 45 | nix, ruby, html, zig, lua, bash, … |
| `#strip!`, `#select-adjacent!`, `#gsub!` | 15 | ruby, html, nix |
| `#not-lua-match?` | 4 | nix, lua |
| `#is-not?` | 3 | html |
| `#has-ancestor?` | 2 | zig |
| `#not-has-parent?` | 1 | css |

70 uses in 13 Packs: omega-nix 21, omega-ruby 15, omega-html 8, omega-zig 6,
omega-lua 5, then bash, sql, cmake, css, julia, c, dockerfile, elixir. 55 of
them are filters, so those patterns emit for every node of their root type
rather than the ones the author named; the other 15 are nvim-treesitter
*directives* that were meant to rewrite the captured text and instead leave it
raw.

These are nvim-treesitter extensions, inherited when the generator copied
`locals.scm`/`highlights.scm` baselines out of that project. No host change can
make them work. Each has to be restated structurally in the Pack, or dropped
with a coverage guard saying what is no longer filtered.

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

---

# What is closed, and what is left

Closed on 2026-09-17, across all 61 Packs, each change validated by
`validate_external_assets`. `pack-design/audit.py` measures every class below;
run it before and after any Pack you touch.

| class | was | now | how |
|---|---|---|---|
| H operator tree-sitter does not have | 70 | **0** | 46 Lua patterns translated to `#match?` regex, 21 no-op operators deleted with a coverage guard where the removal admits it, 3 in patterns that were deleted outright |
| I the universal capture | 6 | **0** | `(_) @structural.node` and the `semantic_hint.syntax_node` template it fed, which stored every named node of every CSV, SAS and VBScript file under its own text |
| J a name that is a constant | 105 | **13** | 88 templates whose whole content was a constant name deleted; 4 renamed from a capture (`var(--brand)` now references `--brand`, a compose `env_file` its path, an R subset its target); 13 remain that carry captured values in fields and belong to their Pack's rewrite |
| K the same template twice | 78 | **0** | byte-identical templates removed, plus 25 duplicate coverage guards and 33 repeated query patterns |
| L a framework overlay in a language Pack | 24+ | **0 measured** | the 24 in c-sharp and dart went with their rewrites; a sweep for API names pinned in literals then found Neovim's `vim.api.*` and the `regex` crate, both in injection patterns targeting a language Omega has no grammar for |
| M a template no pattern can bind | 7→2 | **0** | the first count was my own measurement bug (a capture trailing `]` was cut off). Two were real: omega-pug's `each` binding needed three captures split over two patterns, and omega-typescript's parameter-decorator pattern had its `decorator:` line orphaned outside the closing parens since before this work |

Two further sweeps came out of the same measurements:

- **161 syntax-highlighting patterns in 27 Packs.** `@punctuation.bracket`,
  `@operator`, `@string`, `@tag`, `@spell` — whole `highlights.scm` files pasted
  in from nvim-treesitter, matching a large share of the nodes in every file and
  feeding no template. omega-bash alone had 40.
- **23 injection patterns into a language with no grammar** (`comment`,
  `printf`, `regex`, `vim`, `luap`, `re2c`, `asm`, `query`, `readline`,
  `doxygen`, `luadoc`, `markdown_inline`), and the four orphaned injection rules
  left behind. omega-c and omega-rust keep theirs, because a template there does
  record the embedded region even when the inner language is unknown.
- **Defect F closed to 7**: 2 391 constant attributes removed from 54 Packs --
  `source` 1 316, `semantics` 265, `role` 218, `symbol_category` 120 and a long
  tail. The 7 that stay are constants under names the engine reads, such as
  `receiver_semantics`.
- **The scope/declaration trap closed to 0**: `scope.function` and
  `scope.class` became `scope.function_body` and `scope.class_body` in four
  Packs, and `scope.macro_definition` became `scope.macro_body` in omega-rust --
  the first rename was not enough, because `_body` still left `definition` in
  the kind.

Totals across all Packs: 3 673 -> 3 394 templates, 1 348 -> 1 176 guards.

## What is left, and why it is not mechanical

| class | count | why it needs the Pack's own rewrite |
|---|---|---|
| G a guard whose reason is a label | 266 | each has to be replaced by a sentence about that language, or deleted |
| a carrier the host will not fold | 240 | some are deliberate mentions; each needs the Pack author to say which |
| D a name is a whole node | 71 | the fix is a name capture that the pattern does not have yet |
| `relation.*` the host does not know | 69 | each has to be mapped onto one of the six, or demoted to a reference |
| a pattern nothing reads | 65 | either a missing template or a pattern to delete; only the author knows which |
| J a name that is a constant | 13 | each carries a value in its fields that should become the name |

---

# Wave 2 (groovy, swift, scala, ruby, cpp): three of the closures above were measured too narrowly

Four agents, working independently on four Packs, each reported the same thing:
the sweeps closed the spelling of a defect, not the defect. All three
corrections are verified and `pack-design/audit.py` now measures them.

## D was a floor, not a count

The audit flagged a whole-node name only when the captured node type was in a
fixed list (`document`, `object`, `block`, …). The real rule does not need a
list: **a template whose `name` is its own `span_capture`, where that span is a
node with named children**, stores that whole subtree as a name. Naming a leaf
from its own text is correct and ordinary; naming a container is not.

Measured that way: **937**, not 71. omega-groovy alone had eight the list
missed -- a class named from the whole `class_definition`, a call from the whole
call, a parameter from the whole `parameter`. This is now the largest open class
and the fix is per Pack: capture a name.

## I had a second spelling

`(_) @structural.node` was closed at 0, but a bare capture on the language's
general identifier node is the same failure restricted to one node type.
`(identifier) @local.reference`, inherited with nvim-treesitter and helix
`locals.scm` baselines, stores every identifier of every file. 16 of them, in 15
Packs, now removed with the 33 templates they fed. `(type_identifier) @type.reference`
is **not** this: every type mention is an answer someone wants.

## K had a second half

Byte-identical templates were closed at 0, but the generator ran two passes
(`upstream_tags` and `external-helix-tags`) over the same captures, so a Pack
declares one construct twice under two spellings: `definition.class` and
`definition.scala_class`, `binding.var` and `binding.cpp_variable`,
`scope.lexical` and `scope.cpp_lexical_scope`. Same span capture, same name
expression, different kind, so nothing compared them. The measurable signature
is exactly that: same `span_capture`, same `name`, different `output_kind`.

63 found. 24 removed where one spelling was the other with the language's own
name inserted; **45 remain** where the two kinds differ in meaning and only the
Pack's author can say which is right.

## L is not closed either

The index said "0 measured" after c-sharp and dart. That sweep looked for an API
name pinned in a literal, and the remaining overlays are spelled as **tree
shapes with no literal at all**: ten Unreal Engine patterns and three Catch2
ones in omega-cpp, two ActiveRecord ones in omega-ruby, Nextflow/Spock/Jenkins
shapes in omega-groovy, SwiftPM and SwiftUI in omega-swift. Every one of them
sat under a header comment asserting the opposite -- "Framework-neutral", "No
Flutter/go_router semantics here", "semantics are left to overlays". **19 Packs
still carry 103 such comment lines.** The denial is the tell; check the pattern
under it.

## A new class: a carrier folded onto its owner

A carrier folds onto the declaration at its own span. Seven omega-swift
templates gave a *member's* name a span capture bound to the *enclosing class*,
so a class with N members wrote the same attribute N times onto one declaration
and kept the last. Detectable as a carrier template whose name capture sits
inside its span capture in the same pattern: **289** of them.

## And the literal-marker rule is narrower than the brief said

`literal.*` and `control_flow.*` spans suppress role emissions -- but only
emissions whose kind starts with `reference_context.` (`ROLE_PREFIX`,
`emission_roles.rs:54`). A Pack that emits no `reference_context.*` kind gets no
suppression, so its `literal.*` templates are one match per string, number and
boolean in every file for an emission the host then drops. **83 such templates
removed from 16 Packs** (omega-javascript 14, omega-java 10, omega-kotlin 9,
omega-yaml 8). The rule still holds for the Packs that do emit
`reference_context.*`, which is where the +1 925 mentions came from.

## Wave 2 results

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-ruby | 48 -> 31 | 80 -> 23 | 33 -> 7 | 46 -> 26 |
| omega-groovy | 35 -> 26 | 39 -> 22 | 34 -> 5 | 19 -> 27 |
| omega-cpp | 90 -> 35 | 124 -> 35 | 42 -> 6 | 74 -> 51 |
| omega-scala | 57 -> 31 | 95 -> 35 | 37 -> 6 | 46 -> 49 |
| omega-swift | 48 -> 43 | 76 -> 23 | 32 -> 7 | 53 -> 36 |

Four blocking defects were found by review and fixed here:

- **omega-swift**: `(attribute (simple_identifier) @attribute.name) @attribute`
  was unanchored, and an attribute's arguments are direct children, so
  `@available(iOS, deprecated, renamed: "x")` emitted four references over one
  span. One token: `.` after `(attribute`.
- **omega-scala**: three carriers were renamed to `modifiers`,
  `type_parameters`, `parameters`. The signature line on a card is assembled in
  `production.rs:3170` from exactly `omega.pack.visibility`,
  `type_parameter_shape`, `parameter_shape`, `return_type` and `modifier`, so a
  Scala card read `Foo -> Result` instead of `private final Foo[A](x: Int) ->
  Result`. Restored. And a `def` captured no `parameters:` field at all, so
  *what does this method take* was stated nowhere; both `function_definition`
  and `function_declaration` now carry it.
- **omega-groovy**: the config-block pattern was unanchored, so `task hello { }`
  matched the bare-closure form and was declared as `task` -- one name for every
  task in a repository, with `hello` nowhere. Three anchored forms now: a block
  named by its keyword, by the name the keyword is given, and by its string
  label.

Totals after wave 2 and its sweeps: **3 160 templates, 1 026 guards** (from
3 673 and 1 348 before any of this).

---

# Wave 3 (rust, java, go, python, c): the heaviest Packs, and a check of mine that was measuring nothing

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-rust | 340 -> 71 | 385 -> 42 | 132 -> 6 | 150 -> 46 |
| omega-java | 215 -> 40 | 222 -> 40 | 54 -> 5 | 123 -> 58 |
| omega-go | 214 -> 47 | 140 -> 26 | 51 -> 7 | 93 -> 42 |
| omega-c | 199 -> 27 | 108 -> 32 | 33 -> 6 | 88 -> 40 |
| omega-python | 165 -> 28 | 152 -> 20 | 71 -> 8 | 80 -> 25 |

Five blocking defects found by review, all fixed here:

- **omega-rust** stated `(field_expression field: ...)` as a field mention.
  tree-sitter-rust spells a method callee the same way and a query cannot see
  the parent, so measured over `crates/` (514 files) it produced 63 649 field
  mentions against 43 807 method calls: **68.8% of the Pack's largest emission
  class were calls reported as fields**, resolving by name onto real field
  declarations. Dropped; `Foo { b: .. }` and `Foo { b }` carry the unambiguous
  ones.
- **omega-python** listed `parameters:` before `type_parameters:` while the tree
  has them the other way, so the optional capture never bound and the
  type-parameter carrier was skipped on every match. And the rewrite dropped
  `test.function` and `test.class`, which were **the only declarations in any
  Pack besides omega-rust that reach `EntityFamily::Test`** -- the family
  `test_projection` and `test_entity_count` read. Restored with a proper
  `[test_capability]` block and a `Declaration` test signal, so the host drops
  the generic declaration at the same span and a test is one entity, not two.
- **omega-c** filtered file-scope variables on `(translation_unit (declaration))`.
  A header is conventionally wrapped whole in `#ifndef HEADER_H ... #endif`, so
  in a guarded header every declaration is a child of `preproc_ifdef` and was
  declared nowhere. Seven parent forms now.
- **omega-c and omega-cpp** both captured a typedef's target as `type: (_)`, so
  `typedef struct { ...body... } Config;` -- the ordinary way C names a struct --
  stored the entire body as the value of `omega.pack.aliased_type`. Restricted
  to types that have a name.

## A check of mine that was measuring a naming convention

Three agents independently found the same thing: `audit.py`'s `carrier_owner`
check compared `pat.find('@span')` with `pat.find('@name')`. A correct carrier's
name capture is *always* inside its span, so whether the check fired depended on
whether the span capture's spelling happened to be a prefix of another capture
in the same pattern -- and wrapping the name in `trim(...)` hid it entirely. It
reported 289. The real question is whether the node the name is attached to can
occur **more than once** inside the node the span is attached to, which
`node-types.json` answers. Measured properly: **24**.

The same regex could not see through an alternation. `[ (a) (b) ] @cap` has a
`]` between the `)` and the `@`, so every capture written that way had no owner
recorded and was checked for neither D nor D2. Fixed.

## A new class the corrected audit exposes: a carrier under a name nothing assembles

A carrier's attribute name is the last dot-segment of its kind. Five names build
a card's signature line and about thirty more are read somewhere in the engine.
**260 carrier templates used none of them**: `category` (59), `target` (21),
`identity` (16), `member_category` (15), `named_owner` (13), `parameter_owned`
(9), `member_owned` (7). The value is computed and stored, and nothing ever asks
for it.

`category` is the clearest: it restates the `output_kind` the template already
declares. All 59 deleted, in 15 Packs. Four more were `parameters` and
`type_parameters` in omega-erlang and omega-ruby -- the same defect fixed in
omega-scala in wave 2 -- and are renamed to the spellings the card assembles.
**197 remain**, each needing its Pack's author to say whether the value answers
a question under a name the engine reads, or does not answer one at all.

## L, again, and much larger than the comment count suggested

Every Pack in this wave carried framework overlays spelled as tree shapes with
no literal to find them by:

| Pack | what was in it |
|---|---|
| omega-rust | 26 kinds: axum routers matched down to the argument, diesel `#[diesel(..)]`, serde `#[serde(rename)]`, and four `framework_neutral_rust_receiver_methods_v1` patterns that are the router builder with the names taken out |
| omega-java | 22 patterns of Spring, JAX-RS and JPA, three of which use `#eq?` to tie an annotated field to *the import that proves its type* -- a resolver's job written as a query |
| omega-go | 21 patterns feeding 11 templates: Cobra, gin and echo routing, controller-runtime five and six levels deep |
| omega-c | four injection patterns keyed on `#any-of?` lists of about 90 libc function names, to inject a `printf` format language Omega has no grammar for -- **L inside an injection**, a third place neither sweep read |

`frameworks/omega-framework-spring-boot` and
`frameworks/omega-framework-unreal-engine` already exist. All of these are now
out of their language Packs.

And the exemption in the injection sweep was itself wrong: omega-c and
omega-rust kept their unresolvable injections "because a template there does
record the embedded region". That template was
`embedded_region.embedded_language_candidate` -- a carrier the host will not
fold, whose name was the entire token tree of every macro invocation in the
corpus. Defect D and the unfoldable-carrier trap in one template, and it was the
stated reason for keeping four `Regex`-keyed injections and an `#offset!`
directive tree-sitter does not have. Both Packs are clean now.

Totals: **2 183 templates, 717 guards** (from 3 673 and 1 348 at the start).

---

# Wave 4 (typescript, javascript, kotlin, php, zig)

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-typescript | 198 -> 58 | 273 -> 35 | 80 -> 8 | 114 -> 59 |
| omega-javascript | 187 -> 45 | 213 -> 31 | 72 -> 7 | 84 -> 49 |
| omega-kotlin | 56 -> 28 | 59 -> 23 | 25 -> 7 | 56 -> 42 |
| omega-php | 49 -> 51 | 101 -> 44 | 37 -> 6 | 57 -> 48 |
| omega-zig | 54 -> 40 | 48 -> 34 | 20 -> 4 | 51 -> 50 |

omega-php is the first Pack to come out with *more* templates than it went in
with: 49 to 51 over half the patterns. It was not carrying noise so much as
missing answers.

Three blocking defects, fixed here:

- **omega-kotlin** wrote `(user_type (type_identifier) @implements.type)`
  unanchored. This grammar spells a dotted type flat, as a repeated run of
  `type_identifier` inside one `user_type`, so `class Foo : com.example.Base()`
  emitted three `relation.implements` occurrences -- `com`, `example` and
  `Base` -- and the first two resolved by name onto anything called `com` or
  `example`. Anchored to the last segment, with and without type arguments.
- **omega-zig** carried a field's type as `type: (_)`. In Zig a field's type may
  *be* an inline declaration (`mode: enum { fast, small },`), so the whole body
  was stored as the carried type -- the same defect fixed in omega-c and
  omega-cpp one wave earlier, in a grammar where it is idiomatic rather than
  occasional. Restricted to the forms that name a type.
- **omega-zig** also declared its test coverage family `complete_eligible` with
  `held_out_eligible = true`, which is the flag that lets the host report Zig
  test coverage as *complete*, while its pattern required a test to be named.
  `test { _ = @import("foo"); }` is idiomatic and appears throughout std. The
  name is optional now and the family is `partial_only`.

## The corrected carrier check still over-fires, and now says so

The typescript agent found that `repeats_in()` unions every `multiple` child
group, and a grammar groups unrelated modifiers together: in
tree-sitter-typescript `accessibility_modifier` shares one repeat group with
`override_modifier`, so a correct `visibility_candidate` carrier reads as a
self-overwriting one. Of the 16 it now reports, the `modifier`/`visibility`
ones are that false positive; the `member`, `param` and `text` ones are real.
The label says so rather than pretending otherwise, and one of the real ones was
mine: omega-xml carried a leaf element's text without anchoring it, so
`<a>x<b/>y</a>` wrote the carrier twice and kept `y`. Anchored on both sides.

Totals: **1 861 templates, 515 guards** (from 3 673 and 1 348 at the start).
Sixteen Packs rewritten, 45 to go.

---

# Wave 5 (tsx, solidity, markdown, toml, julia)

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-tsx | 196 -> 60 | 273 -> 40 | 80 -> 10 | 122 -> 62 |
| omega-solidity | 29 -> 50 | 64 -> 36 | 28 -> 6 | 36 -> 47 |
| omega-julia | 54 -> 35 | 60 -> 24 | 23 -> 7 | 73 -> 60 |
| omega-markdown | 29 -> 6 | 35 -> 7 | 5 -> 3 | 46 -> 16 |
| omega-toml | 25 -> 5 | 26 -> 5 | 7 -> 3 | 19 -> 16 |

omega-tsx was rewritten as a port rather than a fresh design: omega-typescript's
kinds, carrier names, capabilities and deliberate silences, plus one JSX
section. A capitalised tag in `name:` of `jsx_opening_element` or
`jsx_self_closing_element`, and a dotted member tag reduced to its last segment,
are `reference.jsx_component`, so `<Counter step={2}/>` resolves onto the
`Counter` declared in another file; an attribute on such a tag is
`reference.jsx_attribute`, resolving onto the `definition.property` of that
component's props type. Lowercase intrinsic tags, closing tags, expression
containers and text are deliberately not stated, with a reason each.

**omega-solidity and omega-php are the two Packs that grew.** Solidity went from
29 templates to 50 while halving its patterns, and touches 47 node types where
it touched 36. Like php, it was not carrying noise so much as failing to answer.

**omega-toml lost four fifths of itself** -- 25 templates to 5, 26 patterns to 5
-- and omega-markdown the same. A configuration or document format has very few
things a question can reach: a key, its value, a section, a heading, a link. The
rest was structure restated.

One blocking defect, fixed here: **omega-markdown** emitted the first cell of a
table row as `reference.documented_term`, the edge from documented to
implemented, naming it with the cell's raw text. This is the block grammar, so
inline markup is never opened -- and measured on this repository's own `.md`
files, 1 840 of 2 719 first cells (68%) begin with a backtick or a `[`, so two
thirds of the emissions the template exists for could never match a declaration.
The Pack already strips `[`/`]` and `<`/`>` elsewhere; the term is now stripped
of code ticks and link brackets the same way, in one chain, since each op
returns its input unchanged when the affix is absent.

Totals: **1 684 templates, 401 guards** (from 3 673 and 1 348 at the start).
Twenty-one Packs rewritten, 40 to go.

---

# Wave 6 (vbscript, json, cmake, lua, elixir)

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-cmake | 40 -> 20 | 50 -> 19 | 6 -> 6 | 36 -> 15 |
| omega-elixir | 31 -> 30 | 16 -> 25 | 12 -> 6 | 33 -> 18 |
| omega-json | 27 -> 4 | 28 -> 4 | 12 -> 4 | 12 -> 9 |
| omega-lua | 23 -> 24 | 61 -> 14 | 23 -> 4 | 34 -> 29 |
| omega-vbscript | 20 -> 16 | 21 -> 14 | 9 -> 5 | 20 -> 22 |

Nine blocking defects, the most of any wave. Eight are fixed here; the ninth is
a decision, recorded below.

**omega-elixir, five of them, four sharing one root.** tree-sitter-elixir's
`keyword` token *includes its trailing whitespace*: the text is `"as: "`, not
`"as:"`. So `(#any-of? @k "as:" "as")` matched nothing and three templates --
the alias binding, the `defdelegate` target, the `defimpl` target -- fired on no
file in any repository, while the `bindings` capability went on being declared.
The same token corrupted a name rather than killing a template: `defstruct name:
nil` declared a field called `"name: "`, trailing colon and space included,
because `strip_suffix` returns its input unchanged when the affix is absent. The
predicates are now `#match?` against `^as:?\s*$` and the name is trimmed on both
sides of the strip.

Two more in the same Pack were wrong-class emissions. `u.id`, `conn.assigns`
and `changeset.valid?` are parsed as a `call` with a `dot` target and no
arguments -- a field read spelled exactly like a remote call -- so requiring
`(arguments)` separates them. And `@moduledoc "x"`, `@impl true`, `@timeout
5_000` are `unary_operator("@", call(identifier, arguments))`, the same node the
local-call pattern matched: measured on a 35-line module, 19 captures of which
10 were module attributes and 2 were genuine calls. A query cannot see the
parent and an exclusion list cannot help, because a module attribute may be
named anything, so the bare local call is no longer stated and a guard says so;
the piped form is unambiguous and stays. Last, `definition.module_attribute`
splits to `[definition, module, attribute]` and the last matching word wins, so
every `@impl` was filed as a **Namespace** beside real `defmodule` declarations.
It is `definition.attribute` now.

**omega-vbscript, two.** The declared-type carrier paired every name in a `Dim`
list with every later type and kept the last, so `Dim a As Long, b As String`
stored `a` as a String; anchored, a name gets a type only when one immediately
follows it, which is also what VB means. And this grammar parses every keyword
statement it has no rule for as `invocation_statement (identifier)
(argument_list)`, so `Set conn = ...`, `Option Explicit`, `Const MAX = 5` and
`On Error Resume Next` were all calls -- making `Set` and `Option` among the
most-called names in any VBScript corpus. Filtered, case-insensitively, because
the language is.

**omega-lua, one.** `local f = function() end` was declared twice: once as a
Callable by the function-assignment pattern and once as a Value by the
file-scope variable patterns, which placed no restriction on the assigned value.
The keyed-table pattern in the same file already had the fix -- an alternation
listing every expression except `function_definition` -- and it is applied to
the other three now.

## The ninth: omega-json against three framework overlays

The rewritten omega-json states one construct, the object pair, named by its key
and carrying a scalar value: 27 templates to 4, and no pattern for the document,
the object, the array or containment. That is the right shape for the language.

It also breaks three framework Packs. `omega-framework-openapi-specification-v3`
(36 JSON-reachable rules of 73), `omega-framework-tauri` (5) and part of
`omega-framework-kubernetes-config` match on `fact_kind = structured.entry` with
`role = json_depth3_pair`, `json_depth5_pair`, … and read fields `a0` … `a6`.
Those fields are **the ancestor key path**, and the old Pack supplied them with
one pattern per nesting depth -- sixteen `structured.entry` templates whose
whole job was to restate where a key sits.

That is Defect E written into a cross-asset contract. Restoring it would undo
the reason JSON files were the largest producers of rows in the index, so it is
not restored here. The overlays have to be rewritten against the new
declarations instead: a nested key already carries its containers through the
host's `within:` namespace segment, which is the same information without a
pattern per depth. **Until that is done, those rules match nothing.** It is
recorded here rather than papered over, and it is the one piece of this work
that reaches outside the language Packs.

`omega-jsonc` and `omega-json5` are ports of omega-json and are not rewritten
yet; `pack-design/omega-json.md` says what they must copy.

Totals: **1 637 templates, 365 guards** (from 3 673 and 1 348 at the start).
Twenty-six Packs rewritten, 35 to go.

---

# Wave 7 (gdscript, sas, bash, make, powershell)

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-gdscript | 30 -> 29 | 50 -> 23 | 19 -> 5 | 40 -> 27 |
| omega-powershell | 26 -> 31 | 34 -> 21 | 10 -> 4 | 48 -> 50 |
| omega-sas | 27 -> 15 | 26 -> 13 | 9 -> 5 | 25 -> 23 |
| omega-bash | 17 -> 11 | 22 -> 11 | 10 -> 5 | 17 -> 15 |
| omega-make | 16 -> 7 | 15 -> 10 | 9 -> 4 | 14 -> 22 |

omega-powershell is the third Pack to grow, and omega-make now touches 22 node
types where it touched 14 while halving its templates.

Two blocking defects, both a pattern that could not reach the construct it
existed for:

- **omega-bash** matched a `case` alternative as `(word)`. tree-sitter-bash
  lexes an alternative adjacent to `|` as `extglob_pattern`, so
  `start|begin|go)` gives two `extglob_pattern`s and one `word`: exactly one
  name per branch was declared, and which one depended on the lexer. The
  multi-alternative form is the CLI dispatch the template exists for.
- **omega-sas** matched `(libname_statement (string_literal) @libname.path)`
  unanchored. An external-engine LIBNAME states its target in options, so
  `libname odb odbc dsn="PRODDB" user="svc_etl" password="x";` emitted four
  library paths -- a DSN, a user id and a password among them, each shown to an
  agent as *where this library points*. Anchored to the string that follows the
  libref, with a guard for the engine form.

## Two findings about the audit itself

**A quantifier hid every optional capture.** The owner regex required the
capture to follow the closing bracket directly, so `type: (type)? @cap` and
`(parameters)? @cap` recorded no owner at all and were checked for neither D nor
D2 nor carrier-overwrite -- in every Pack, for the whole of this work. Fixed;
the numbers below are the first honest ones for optional captures, and
`carrier_owner` rose from 15 to 45 because it can now see them.

**The nvim-treesitter `locals.scm` inheritance is not closed.** Earlier sweeps
took out the `highlights.scm` patterns and the bare `(identifier)
@local.reference` spelling, but a wired-up locals baseline survived in five
Packs: omega-nix carries `@local.definition.field`, `@local.definition.parameter`,
`@local.definition.var` and `@local.reference` with templates on all four, so
its declaration set is an editor's highlighting model rather than an answer set.
omega-html and omega-r have one each; omega-julia and omega-razor use the
spelling for captures of their own. Twelve Packs still name nvim-treesitter in a
provenance header. nix, r and html are in the waves that follow and will take it
with them.

Totals: **1 614 templates, 332 guards** (from 3 673 and 1 348 at the start).
Thirty-one Packs rewritten, 30 to go.

---

# Wave 8 (nix, yaml, r, html, prisma)

| Pack | templates | patterns | guards | node types touched |
|---|---|---|---|---|
| omega-yaml | 65 -> 7 | 67 -> 7 | 7 -> 6 | 21 -> 18 |
| omega-r | 23 -> 18 | 27 -> 13 | 12 -> 5 | 14 -> 34 |
| omega-nix | 19 -> 17 | 11 -> 13 | 11 -> 5 | 31 -> 31 |
| omega-prisma | 17 -> 16 | 21 -> 15 | 16 -> 5 | 16 -> 24 |
| omega-html | 15 -> 9 | 32 -> 13 | 3 -> 5 | 14 -> 13 |

omega-yaml lost nine tenths of itself -- 65 templates to 7 -- and omega-r more
than doubled the node types it reaches, from 14 to 34, while cutting its
patterns in half.

One blocking defect: **omega-r** declared a class factory twice. `Gen <-
setClass("Gen", ...)` -- the form in `?setClass`'s own examples, and the only
usable form for `setRefClass`, since you need the generator to call `$new()` --
matched both the value-assignment pattern, as a Value named `Gen`, and the class
pattern, as a Type named `Gen`, on two different spans so nothing deduplicated
them. The Pack excluded `function_definition` from the value alternation for
exactly this reason and did not carry the reasoning to the nine factory names it
already listed. A call-valued assignment is now its own pattern with those names
excluded.

## The audit was reading a prefix of every query file with a `";"` in it

`top_patterns()` stripped comments with one `re.sub(r';[^\n]*', '', src)` over
the whole file, **before** anything tracked string literals. A query that
captures the language's statement separator -- `[ "." ";" ":" ] @punctuation.delimiter`,
which every nvim-treesitter highlights baseline carries -- had its `";"`
rewritten to a bare `"`. That opened a string which never closed, the bracket
depth never returned to zero, and **no pattern after that point was parsed at
all**. On the pre-rewrite omega-nix the audit reported 11 patterns where the
file held about 75, and D, D2, the capture-owner map, `unread`, I, I2, M and
`carrier_owner` were all evaluated against that prefix.

Comments are now stripped in the same pass that tracks strings. Two Packs were
still affected at the time of the fix -- omega-sql (30 patterns seen, 66 real)
and omega-css (25 seen, 39 real), both still to be rewritten -- and the first
sweep with the fix found 13 orphaned patterns in them that had been invisible.

## Framework overlays inside injections: the largest instance yet

omega-nix carried 22 injection patterns keyed on nixpkgs and home-manager
library names -- `writeShellApplication`, `runCommand*`, `writeBash*`,
`writeFish*`, `writeHaskell*`, `writePy*`, `nixosTest`, `testScript`,
`^[A-Za-z]+Phase$`, `^pre[A-Za-z]+$`, `^post[A-Za-z]+$`, and a home-manager
Neovim `type = "lua"` pair. That is four times the size of omega-c's libc-keyed
injections. All removed. Parsing the bash inside `buildPhase` is worth having
and belongs in a `frameworks/omega-framework-nixpkgs-stdenv` overlay, which does
not exist: a gap this sweep creates and does not fill.

The nvim locals inheritance is closed for omega-nix and omega-html; omega-r's
went with its rewrite too.

Totals: **1 542 templates, 309 guards** (from 3 673 and 1 348 at the start).
Thirty-six Packs rewritten, 25 to go.

---

# Wave 9 (sql, css, hcl, twig, graphql)

| Pack | templates | patterns | guards |
|---|---|---|---|
| omega-sql | 52 -> 33 | 58 -> 27 | 10 -> 5 |
| omega-graphql | 36 -> 28 | 50 -> 22 | 4 -> 4 |
| omega-css | 32 -> 10 | 34 -> 10 | 6 -> 5 |
| omega-hcl | 31 -> 9 | 36 -> 9 | 9 -> 4 |
| omega-twig | 19 -> 15 | 18 -> 14 | 7 -> 5 |

The rewritten omega-sql finally makes SQL's one link: every name on both sides
is reduced to the last segment of its object reference, so `CREATE TABLE
public.users` and `FROM users` resolve to each other. The old Pack stored the
declaration as `public.users` and the reference as `users`, and the two could
never meet.

One blocking defect: **omega-sql**'s `DROP INDEX` branch. `drop_index` has a
required `name:` field -- the index -- and an optional `object_reference`
reachable only after `ON`. The pattern read the `object_reference`, so
`DROP INDEX idx_users_email;` (the standard form, no `ON`) bound nothing and was
not stated at all, while `DROP INDEX idx ON users;` reported **the table** as
the dropped object. The other nine branches of the same alternation were right.

## tree-sitter's static analysis is an oracle, and the brief now says so

The sql agent learned the shape of `create_index` from the validator rather than
from `node-types.json`: writing `(object_reference) . (keyword_on)` produced
`Impossible pattern`, which is how it found that the index's own name is the
field spelled `column:`. `node-types.json` records a field but not its order,
and a field's name can be misleading. Write the anchored pattern you believe is
true and let the validator refute it.

## A recurring shape, now named

A grammar that spells two different roles with the same node type under one
parent, told apart only by an anchor against a keyword token. It has produced a
*confidently wrong* answer every time it appeared, never a missing one:
omega-kotlin's `user_type` (wave 4) made `com` and `example` into supertypes,
omega-sas's `libname` (wave 7) made a password into a library path,
omega-sql's `create_index` reported the index's name as a table it depends on
and `drop_index` reported the table as the dropped object. When a pattern's
children are of one type and their roles differ, anchor them.

`carrier_owner` over-fires in a third way, beyond the modifier grouping the
label already names: tree-sitter-sql puts *every* child of `create_function`
into one `"multiple": true` group, `function_arguments` beside `keyword_create`,
so a correct parameter carrier reads as self-overwriting. Any Pack over such a
grammar reports it for every carrier it writes.

`pack-design/__pycache__/` was tracked -- committed by me when the audit was
added -- and CPython rewrites it whenever an agent imports `audit.py` to reuse
its helpers. Untracked and gitignored.

Totals: **1 467 templates, 296 guards** (from 3 673 and 1 348 at the start).
Forty-one Packs rewritten, 20 to go.

---

# Wave 10 (json5, jsonc, pug, svelte, caddyfile)

| Pack | templates | patterns | guards |
|---|---|---|---|
| omega-svelte | 23 -> 22 | 28 -> 22 | 5 -> 5 |
| omega-pug | 14 -> 15 | 21 -> 16 | 3 -> 4 |
| omega-caddyfile | 13 -> 13 | 14 -> 12 | 7 -> 4 |
| omega-json5 | 12 -> 4 | 11 -> 4 | 3 -> 5 |
| omega-jsonc | 10 -> 4 | 9 -> 4 | 2 -> 5 |

json5 and jsonc came out as ports of omega-json: the same `definition.config_key`
kind, the same silence about the document, the object, the array and
containment, and only their dialect's additions. json5 departs in one place and
says why -- tree-sitter-json5 has no `string_content`, so a string is a leaf
carrying its own quotes and the template unquotes with a `strip_prefix`/
`strip_suffix` chain instead of anchoring inside the node.

Two blocking defects, both **Defect M**, both in omega-svelte, and both a
pattern whose author read `node-types.json` without checking the tree:

- `attribute_name` has children only when a directive is present, so
  `onclick={handler}` -- the Svelte 5 spelling, and the common one -- parses as
  a bare `attribute_name` leaf. The pattern required a child, matched nothing,
  and the Pack went on claiming it stated event handlers. Both spellings now
  feed one template.
- `await_branch`'s `branch:` field carries only the braces and the keyword; the
  binding of `{:then value}` sits in a plain `pattern` child. The author tried
  the `binding:` field the grammar names, got `Impossible pattern`, and drew the
  wrong conclusion from the refusal -- the field is rejected, but the child is
  reachable without one. Written without a field, it matches.

That second one is worth keeping in mind next to wave 9's lesson: the validator
refuting a pattern tells you the tree is not that shape, not what shape it is.

## Two repository-level tidyings

`pack-design/audit.py`'s single-Pack view printed nothing when a Pack was clean:
`main()` only entered the detail branch when the Pack had at least one flag, so
the counts an agent is asked to report verbatim were exactly what the tool
withheld from a finished Pack. Every agent from wave 6 on hit it. Fixed.

Four Packs carried a `NOTICE` deriving query fragments from nvim-treesitter and
declared `license = "MIT AND Apache-2.0"` on that basis. omega-twig and
omega-json5 are rewritten from scratch and no derived line remains, so both drop
the NOTICE and revert to `MIT`. omega-blade and omega-godot-resource keep theirs
until their own rewrites, which are in the waves that follow.

Totals: **1 453 templates, 299 guards** (from 3 673 and 1 348 at the start).
Forty-six Packs rewritten, 15 to go.
