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
