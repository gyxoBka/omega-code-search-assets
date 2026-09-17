# omega-prisma

Language `omega-prisma`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. Version 2.0.0.

## What it states today

16 templates over 15 query patterns, 24 of the grammar's 36 named node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 13 |
| `references` | yes | 3 |

### Declarations

| kind | family the host gives it | templates | what it is |
|---|---|---|---|
| `definition.model_type` | Type | 1 | `model User { ... }` |
| `definition.view_type` | Type | 1 | `view ActiveUser { ... }` |
| `definition.enum` | Type | 1 | `enum Role { ... }` |
| `definition.composite_type` | Type | 1 | `type Address { ... }` |
| `definition.enumeral` | Value | 1 | an enum member |
| `definition.field` | Value | 1 | `email String @unique` |
| `definition.datasource_config` | Config | 1 | `datasource db { ... }` |
| `definition.generator_config` | Config | 1 | `generator client { ... }` |
| `definition.config_setting` | Config | 2 | `provider = "postgresql"` |
| `definition.config_mapping` | Config | 1 | the name in `@@map("users")` / `@map("created_at")` |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates | value |
|---|---|---|---|
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 | the whole declared type of a field: `String`, `String?`, `Post[]`, `Unsupported("circle")` |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 | one field attribute, as authored: `@id`, `@unique`, `@db.VarChar(255)`, `@relation(...)` |

Both fold onto the `definition.field` at the same span, so a field's card reads
`@unique @db.VarChar(255) email -> String`. `return_type` and `modifier` are two
of the five names `declared_signature` (`production.rs:3169`) assembles that line
from; no other carrier name would appear anywhere.

### Regions

None. A model's, view's, enum's and composite type's declaration already spans
its whole block, which is what a region would have been for, and the host
derives `User.email` from the nesting.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `reference.field_type` | reference | 1 |
| `reference.field` | reference | 1 |
| `relation.depends` | depends | 1 |

`reference.field_type` is the name of a model, view, enum or composite type used
as a field's type, filtered against Prisma's nine built-in scalars with
`#not-any-of?`. `reference.field` is a bare field name listed in `@@id`,
`@@unique`, `@@index` or `@relation(fields: [...], references: [...])`.
`relation.depends` is the variable name inside `env("...")`.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 36 node types. The Pack looks at 24 of them.

Untouched, and why each is right to leave:

- `program`, `_declaration`, `statement_block`, `enum_block` -- containers. What
  is in them is emitted; that they contain it is what the tree already says.
- `block_attribute_declaration` -- reached through its `call_expression`, which
  is what the `map(...)` pattern matches, so `@@map` and `@map` are one pattern.
  `@@ignore`, `@@schema` and the operands of `@@id`/`@@index` are reached by the
  `(array (identifier))` pattern or not at all; see **Still to decide**.
- `comment` (`///`) and `developer_comment` (`//`) -- prose, and in this grammar
  a sibling of the block it documents rather than a child of it. Guarded.
- `maybe` (`?`) and the empty `array` of `Post[]` -- part of the field's type,
  which is carried whole from `column_type`, so they are inside an emission
  already.
- `property_identifier` -- the tail of `@db.VarChar`, inside a modifier that is
  carried whole.
- `type_declaration_type`, `assignment_pattern`, `formal_parameters` -- shapes
  this grammar inherits from its JavaScript-derived expression rules and that no
  Prisma schema in the wild produces.

## What is wrong with it

The Pack that was here stated 17 templates over 21 patterns with 16 guards, and
**declared nothing**. Concretely:

- **Every construct Prisma names was emitted as a mention.** `data.model`,
  `data.enum`, `data.view`, `data.datasource`, `data.generator`, `data.field`,
  `data.enum_value`, `data.relation`, `data.view_field`,
  `data.prisma_model_typed_field` -- ten kinds, none of which contains
  `definition` or ends in one of the five suffixes, so all ten arrived as plain
  references. A reference named `User` at the span of `model User` resolves onto
  nothing, because nothing in the Pack declared `User`. Asking Omega where the
  `User` model is defined found no declaration in any Prisma file.
- **What did declare, declared by accident.** The one thing that reached the
  declaration branch was `definition.identity_candidate` -- a carrier under the
  name `identity`, which nothing in the engine assembles, whose value was the
  declaration's own name, so the fold dropped the value
  (`content_builder.rs:112`) and a carrier with no declaration at its span was
  materialised on its own. Every model, enum, view and composite type in a
  repository was therefore a Value under an accident.
- **Defect D2, 5 templates.** `call.prisma_candidate`,
  `definition.prisma_declaration_candidate`, `reference.symbol`, `scope.lexical`
  and `type.prisma_declaration_candidate` each took their name from their own
  span capture, and every one of those spans was a container: the whole
  `(call_expression)`, the whole `(enum_declaration)`, the whole
  `(member_expression)`, the whole `(enum_block)`.
  `definition.prisma_declaration_candidate` stored the entire text of every
  model, enum, view and type declaration as a name -- the body, the fields, the
  attributes, all of it -- once as a declaration carrier and again as a type
  carrier.
- **Four carriers under names nothing assembles**: `omega.pack.prisma`,
  `omega.pack.prisma_declaration` (twice) and `omega.pack.identity`. The value
  was computed and stored and nothing ever asked for it.
- **Two carriers the host will not fold**: `call.prisma_candidate` and
  `type.prisma_declaration_candidate` end in `_candidate` but fail
  `is_definition_kind` -- `call.` is an excluded prefix and `type.` is not one of
  the accepted suffixes -- so they fell through to the mention branch and were
  stored as references to nothing.
- **Defect G, 4 of 16 guards** gave a single token as the reason:
  `prisma_declarations_are_syntax_candidates_until_scope_and_name_resolution`,
  `reference_candidates_target_identity_requires_view_resolver_evidence`,
  `syntactic_scope_boundaries_only_no_runtime_scope_inference`,
  `prisma_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`.
  A further guard said the Pack provided "universal named-node capture ...
  structural indexing only", which describes a pattern the file did not contain.
- **Three capabilities answered nothing.** `calls` existed for
  `(call_expression) @call.expression` -- but a `call_expression` in a Prisma
  schema is `@default(now())`, `env("URL")` or `@db.VarChar(255)`, an attribute
  invocation and not a call anyone looks for, and it stored the whole invocation
  text as the call's name. `scopes` existed for one `scope.lexical` naming each
  block with the block's own text. `types` existed for a carrier the host will
  not fold. All three are gone.
- **Defect E, four patterns.** `semantic_field`, `semantic_relation`,
  `terminal_prisma_view_v1` and `implicit_model_typed_field_v3_146` each spelled
  `model_declaration > statement_block > column_declaration > column_type` out in
  full to say that a field is inside a model, which the tree says for free and
  which the host turns into the `within:` segment of the field's name.
  `semantic_relation` went two levels further to reach the `@relation`
  attribute, and each of them fires once per (model name, field) pair.
- **Four empty query sections** (`completeness_types_high_confidence`,
  `definition_identity_hints`, `semantic_enum`, `semantic_model`) and a
  `structural-fallback` heading with a comment and no pattern under it: the
  generator's section skeleton, shipped.
- One line of Defect L's tell: *"Framework-neutral authored field type target"*
  above `implicit_model_typed_field_v3_146`.

## What it should extract

| what | node | emitted as | family |
|---|---|---|---|
| a model | `model_declaration` + first `identifier` | `definition.model_type` | Type |
| a view | `view_declaration` + first `identifier` | `definition.view_type` | Type |
| an enum | `enum_declaration` + first `identifier` | `definition.enum` | Type |
| a composite type | `type_declaration` + first `identifier` | `definition.composite_type` | Type |
| an enum member | `enumeral` | `definition.enumeral` | Value |
| a field | `column_declaration` + first `identifier` | `definition.field` | Value |
| a field's declared type | `column_type` | `definition.return_type_candidate` -> `omega.pack.return_type` | carried onto the field |
| one field attribute | `attribute` | `definition.modifier_candidate` -> `omega.pack.modifier` | carried onto the field |
| a datasource block | `datasource_declaration` + `identifier` | `definition.datasource_config` | Config |
| a generator block | `generator_declaration` + `identifier` | `definition.generator_config` | Config |
| a setting in either | `assignment_expression` + `variable` | `definition.config_setting`, with the string value as attribute `value` | Config |
| the database name in `@@map`/`@map` | `call_expression` named `map` + its first `string` | `definition.config_mapping` | Config |
| a field's type when it is not a built-in scalar | `column_type` + first `identifier` | `reference.field_type` | reference |
| a field named in a key, index or relation | `array` + `identifier` | `reference.field` | reference |
| an environment variable | `call_expression` named `env` + its first `string` | `relation.depends` | depends |

The questions each answers: *where is this model / enum / type declared*, *what
fields does it have and of what type*, *what is this field annotated with*,
*which model does this field point at*, *which fields make up this key or
index*, *which SQL table or column is this*, *which database provider and which
generator does this project use, and with what settings*, *which environment
variables does this schema need*.

Every kind was chosen for the word `entity_family` will match. `model`, `view`
and `enumeral` are in none of the host's word lists, so a Prisma model would
otherwise be filed as a Value beside its own fields; `model_type`, `view_type`
and `composite_type` put the four named blocks in Type, where the `User` a
TypeScript file imports from `@prisma/client` can resolve onto them.
`datasource_config`, `generator_config`, `config_setting` and `config_mapping`
land in Config. `field` and `enumeral` stay in Value, which is what they are.

## What the audit still reports, and why it is right here

`carrier that may overwrite itself` = 2: `definition.return_type_candidate`
over `(column_type)` and `definition.modifier_candidate` over `(attribute)`,
both inside `(column_declaration)`.

The check asks whether the node the carrier's name is attached to may occur more
than once inside the node its span is attached to, reading `node-types.json`.
tree-sitter-prisma groups `identifier`, `column_type` and `attribute` into one
`multiple` child group for `column_declaration`, so `repeats_in()` reports all
three as repeatable -- the union problem 00-INDEX already records for
tree-sitter-typescript's modifier group. A `column_declaration` in fact holds
exactly one `column_type`, which is why the field pattern needs no optional
part.

For `attribute` the repetition is real and is the point. The fold is
`bag.entry(name).or_default().insert(value)` on a `BTreeSet`
(`content_builder.rs:113`) and `carried_text` joins the set
(`production.rs:3207`), so a field with `@id` and `@default(autoincrement())`
carries both rather than the last one. The failure this check exists to catch is
a carrier whose span is the *enclosing* declaration rather than the one it
describes; here the span is the field's own, so each field carries only its own
attributes.

## A defect in the host

None found. Everything this Pack needed to say, the kind string could say.

## Still to decide

- **`@@ignore`, `@@schema` and the shape of a composite key.** `@@id([a, b])`
  and `@@index([email, name])` reach their operands through the
  `(array (identifier))` pattern, so *which fields are indexed* is answerable
  from the references, but *that these three fields are one composite key* is
  not stated as a unit. Stating it would need a carrier whose span is the
  enclosing `model_declaration` -- the one shape the carrier rule forbids -- or a
  pattern spelling out `model_declaration > statement_block >
  block_attribute_declaration`, which is containment. Left unstated rather than
  stated wrongly.
- **`@default(USER)`.** A default that names an enum member is a reference that
  would resolve onto a `definition.enumeral`. It costs one more pattern rooted at
  `attribute` for a fact that is rarely asked for, so it is not in.
- **Multi-file schemas.** `prismaSchemaFolder` splits a schema across files and
  resolution between them is by name, which is the resolver's job and not stated
  here.

## What this breaks outside the Pack

`frameworks/omega-framework-prisma/semantic-v2.json` matches `fact_kind` exactly
(`overlay.rs:608`, `current.kind == *value`) against the ten `data.*` kinds this
Pack no longer emits. All 12 of its rules therefore match nothing until it is
rewritten against the declarations above. The mapping it needs:

| overlay's `fact_kind` | now | the fields it read |
|---|---|---|
| `data.model` | `definition.model_type` | `name` is the emission's own name |
| `data.view` | `definition.view_type` | as above |
| `data.enum` | `definition.enum` | as above |
| `data.datasource` | `definition.datasource_config` | as above |
| `data.generator` | `definition.generator_config` | as above |
| `data.enum_value` | `definition.enumeral` | `owner` is the enclosing declaration |
| `data.field`, `data.view_field` | `definition.field` | `model`/`owner` is the enclosing declaration; `type` is `omega.pack.return_type` |
| `data.relation`, `data.prisma_model_typed_field` | `reference.field_type` | `target` is the reference's own name; `model`/`owner` is the enclosing declaration |

Every `owner` and `model` field the overlay was supplied by hand is now the
host's own `within:` namespace segment, which is the same information without a
pattern per level. This is the same trade recorded for omega-json in
`00-INDEX.md`, and it is the one piece of this rewrite that reaches outside the
language Pack.
