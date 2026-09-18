# omega-framework-prisma

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 2 detection rules. **0 could match, 12 could not.**
Rewritten in wave 5 to 16 overlay rules, all live. Rewritten again now that
`omega-prisma` publishes `value` on `definition.config_setting` as a **field**
and not only as an attribute: **22 overlay rules, all 22 live.** Everything
below this line records the file as it was; what replaced it is in *What it
states now*.

Selector: `framework:prisma`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Field` | 2 |
| `SchemaProject` | 2 |
| `Model` | 1 |
| `Datasource` | 1 |
| `Enum` | 1 |
| `Generator` | 1 |
| `View` | 1 |
| `EnumValue` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `has_field` | 2 |
| `relates_to` | 2 |
| `configured_by` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.model` | 2 | **no** |
| `data.datasource` | 2 | **no** |
| `data.generator` | 2 | **no** |
| `data.field` | 1 | **no** |
| `data.relation` | 1 | **no** |
| `data.enum` | 1 | **no** |
| `data.prisma_model_typed_field` | 1 | **no** |
| `data.view` | 1 | **no** |
| `data.view_field` | 1 | **no** |
| `data.enum_value` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x12, `field_present` x6, `fact_join_by_field` x1, `(join)` x1.

Fields read: `owner`, `data.name`, `target`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `prisma.model` | kind `data.model` |
| `prisma.field` | kind `data.field` |
| `prisma.relation` | kind `data.relation` |
| `prisma.datasource` | kind `data.datasource` |
| `prisma.enum` | kind `data.enum` |
| `prisma.generator` | kind `data.generator` |
| `prisma.datasource.configured-by-schema` | kind `data.datasource`; field `data.name` |
| `prisma.generator.configured-by-schema` | kind `data.generator`; field `data.name` |
| `prisma.implicit-model-relation` | kind `data.model`, `data.prisma_model_typed_field`; field `owner`, `target` |
| `prisma.view` | kind `data.view` |
| `prisma.view-field` | kind `data.view_field`; field `owner` |
| `prisma.enum-value` | kind `data.enum_value`; field `owner` |

## What was wrong with it

### The 12 rules this file started from (wave 5 finding, unchanged)

**All 12 rules were keyed to a vocabulary no Pack has ever emitted.** The file
matched ten kinds -- `data.model`, `data.field`, `data.relation`,
`data.datasource`, `data.enum`, `data.generator`, `data.view`,
`data.view_field`, `data.enum_value`, `data.prisma_model_typed_field` -- and
`omega-prisma` emits none of them. It emits sixteen templates over twelve kinds,
all of them `definition.*` or `reference.*`. So the overlay was 12 for 12 dead
and contributed nothing to the graph.

**It read eight fields that no Pack published.** `data.name`, `data.model`,
`data.type`, `data.target`, `owner`, `target`, `field`, `type`. Every one of
those reads was unreachable even if the kinds had existed.

**Four of the 12 rules only restated their input.** `prisma.model`,
`prisma.datasource`, `prisma.enum`, `prisma.generator` each minted an entity
whose canonical key was its own name, with one attribute equal to that same
name, and emitted no relation. **One relation dangled by construction**
(`prisma.view-field`, sourced at a key nothing mints), and **one rule required a
field-to-field join** where the Pack published zero fields.

### What was still wrong after wave 5, and is fixed now

**The most-asked fact about a Prisma schema was written down as permanently
unreachable, and is not.** Wave 5 shipped an "A field only the Pack can supply"
section arguing that `provider = "postgresql"` could never be stated, because
`omega-prisma` published the unquoted value only in `attributes` and
`OverlayFact::field` never consults `attributes`. That was true when it was
written. The Pack now publishes `value` in `fields` as well, measured on the
first `definition.config_setting` template and confirmed with
`dump_call_emissions`:

    18-41  definition.config_setting  name=provider  value=String("postgresql")

So **4 rules** now read it: `prisma.datasource.provider` and
`prisma.generator.provider` mint the value as a `Provider` entity in its own key
space, and the two setting rules were split so the value-bearing one carries
`value` as an entity attribute. That section is deleted; the whole claim it made
is now false.

**The setting rules could not simply grow a `value` attribute.** An
unresolvable attribute drops the entity and keeps the relation (brief 3b), and
`previewFeatures = ["views"]` and `url = env(...)` come from the *second*
`definition.config_setting` template, which publishes no `value`. Adding the
attribute to the one existing rule would have deleted the `Setting` entity for
every array- and call-valued setting while leaving its `configures` edge
dangling. So each block has two rules: `prisma.datasource.setting`, guarded by
`field_present value`, and `prisma.datasource.setting.plain`, which matches
every setting. They mint the same key with the same kind `Setting`, and the
value-bearing id sorts first, so its attributes are the ones `or_insert` keeps
(brief 3g).

**Two gaps wave 5 recorded as structural were reachable by a field the host
already computes, and 2 more rules follow from measuring them again.**
`definition.container` is the innermost `definition.*` fact whose span
*strictly* contains this one. Measured on a real schema:

| fact | span | `definition.container` |
|---|---|---|
| `@@map("users")` on `model User` | 459-466 | `User` |
| `@map("email_address")` on field `email` | 389-404 | one of the three facts on 363-405 -- the field, its modifier, its type -- never the model |
| `@@index([email])` at model level | inside the model only | the model |
| `references: [id]` inside `@relation(...)` | inside field `author` | the field, never the model |

So *is this mapping at model level* is one `fact_join_by_field` --
`current_field: "definition.container"`, `join_field: "definition.name"` against
`definition.model_type` -- and needs no negative join, which is what wave 5
concluded it needed. `prisma.model.table` states **which SQL table a model is
stored in**, and `prisma.model.constraint-column` states **which of a model's
own fields are named in `@@id`, `@@unique` and `@@index`**, both without ever
firing on the field-level spelling the old note was afraid of.

Counts: 16 rules -> 22. The 6 added are 2 provider, 2 setting-value split, 1
table, 1 constraint column. No rule was deleted; all 22 are live, and
`key_collisions.py` reports nothing.

## What it states now

22 rules, all live. Every join is `fact_join_by_span` or a `fact_join_by_field`
on `definition.container`, both of which read spans the Pack already emits; the
one published field the file reads is `value`. Every rule carries `**/*.prisma`,
because `definition.field`, `definition.enum`, `definition.config_setting`,
`reference.field` and `relation.depends` are emitted by 17-25 other Packs.

| what it answers | which Pack fact | what it emits |
|---|---|---|
| which models does this schema declare | `definition.model_type` | `Model` `prisma:model:{name}`, `SchemaProject` `prisma:schema:{path}`, `declares` schema -> model |
| which views | `definition.view_type` | `View` `prisma:view:{name}`, `declares` |
| which composite types (`type Photo {}`) | `definition.composite_type` | `CompositeType` `prisma:type:{name}`, `declares` |
| which enums | `definition.enum` in a `.prisma` file | `Enum` `prisma:enum:{name}`, `declares` |
| which values does this enum admit | `definition.enumeral` `within` `definition.enum` | `EnumValue` `prisma:enum-value:{enum}:{name}`, `has_value` enum -> value |
| what fields does this model have, and of what declared type | `definition.field` `within` `definition.model_type`, plus `definition.return_type_candidate` on the **same** span (`String?`, `Post[]`, `Unsupported(...)` verbatim) | `Field` `prisma:field:{model}:{name}` with `type`, `has_field` model -> field |
| same, for a view | `definition.field` `within` `definition.view_type` | `Field`, `has_field` view -> field |
| same, for a composite type | `definition.field` `within` `definition.composite_type` | `Field`, `has_field` type -> field |
| **what does this model relate to** | `reference.field_type` `within` a field `within` a model, joined by name to a `definition.model_type` anywhere in the repository | `relates_to` model -> model, attribute `field` = the field that carries it |
| which enum does this field take its values from | `reference.field_type` likewise, joined by name to a `.prisma` `definition.enum` | `uses_enum` field -> enum |
| **which SQL table is this model stored in** (`@@map("users")`) | `definition.config_mapping` whose `definition.container` is a `definition.model_type` name | `Table` `prisma:table:{table}`, `maps_to` model -> table |
| which SQL column is this field stored in (`@map("created_at")`) | `definition.config_mapping` `within` a field `within` a model | `Column` `prisma:column:{model}:{column}`, `maps_to` field -> column |
| **which of a model's own fields are keyed or indexed** (`@@id`, `@@unique`, `@@index`) | `reference.field` whose `definition.container` is a `definition.model_type` name | `constrained_by` model -> field, attribute `field` |
| which database does this schema connect to | `definition.datasource_config` | `Datasource` `prisma:datasource:{name}`, `configured_by` schema -> datasource |
| which client is generated from it | `definition.generator_config` | `Generator` `prisma:generator:{name}`, `configured_by` schema -> generator |
| **which database engine is this project on** (`provider = "postgresql"`) | `definition.config_setting` named `provider`, field `value`, `within` `definition.datasource_config` | `Provider` `prisma:provider:{value}`, `uses_provider` datasource -> provider |
| **which client generator** (`provider = "prisma-client-js"`) | the same, `within` `definition.generator_config` | `Provider` `prisma:provider:{value}`, `uses_provider` generator -> provider |
| what does this datasource configure, **and to what** (`directUrl`, `relationMode`) | `definition.config_setting` `within` `definition.datasource_config`; `value` when the Pack published one | `Setting` with `value`, `configures` setting -> datasource |
| what does this generator configure, **and to what** (`output`, `previewFeatures`, `binaryTargets`) | the same, `within` `definition.generator_config` | `Setting` with `value`, `configures` setting -> generator |
| **which environment variables must be set for this schema to load** | `relation.depends` in a `.prisma` file -- the `env("...")` argument | `EnvVar` `prisma:env:{name}`, `depends_on` schema -> env var |

The two cross-file edges are the ones a language Pack cannot state: a
`reference.field_type` named `User` in `post.prisma` and `model User` in
`user.prisma` are two unrelated facts until the overlay joins them by name. Both
`relates_to` and `uses_enum` are deliberately **not** `same_path`, so a
multi-file Prisma schema (`prismaSchemaFolder`) resolves; the model and enum keys
are path-free for the same reason. `prisma:provider:{value}` is path-free and
repository-wide on purpose: it is the node that answers *which schemas in this
repository are on postgres*.

Every relation end is minted, and every addressing rule carries the clauses of
the rule that mints the key it addresses. `prisma:schema:{path}` by six rules;
`prisma:model:{name}` by `prisma.model`, which `prisma.model.table` and
`prisma.model.constraint-column` reach only through a join to the same
`definition.model_type` in the same file; `prisma:field:{model}:{name}` by
`prisma.model.field` for every field inside a model, which is what
`constrained_by` and `maps_to` address; `prisma:provider:{value}` by both
provider rules under one kind; `prisma:datasource:{name}` and
`prisma:generator:{name}` by their own rules, whose clauses the provider and
setting rules repeat as a `within` join to the same block declaration.
`prisma.field.uses-enum` repeats the `**/*.prisma` glob inside its name join,
because `definition.enum` without it would reach a Java or Rust enum that
`prisma.enum` never mints.

## Still to decide

**`@@map` on a view or a composite type is not stated.** `prisma.model.table`
joins `definition.container` to a `definition.model_type`; a view's or a
composite type's own `@@map` would need the same rule twice more, against
`definition.view_type` and `definition.composite_type`. Both are legal Prisma
and both are rare -- a view is already a database object named by the view
declaration -- so the two rules are not written rather than written for
symmetry. The join that would write them is now known to work, so this is a cost
decision, not a structural one.

**Which kind of model-level constraint a column belongs to is not stated.**
`@@id([a, b])`, `@@unique([email])` and `@@index([email, name])` produce the
same `reference.field` with the same container, and nothing in the fact says
which annotation enclosed it: `definition.modifier_candidate` carries the
annotation text but is emitted only for field-level attributes, on the field's
span. `constrained_by` therefore says *this column participates in a model-level
key or index* and no more. Telling the three apart is a Pack change -- one
pattern per block attribute, emitting under its own kind -- not a rule.

**`@relation(fields: [...], references: [...])` is still not decomposed.** Here
`definition.container` is the annotated field for both lists, so the own-model
foreign key column and the target-model referenced column are indistinguishable;
a rule would emit `Post.id` where the schema says `User.id`. The relation itself
is stated by `prisma.model.relates-to` from the field's type, so what is missing
is only *which column backs it*.

**A field of a view or composite type typed by a model does not emit
`relates_to`.** `prisma.model.relates-to` requires the owner to be a
`definition.model_type`, so the relation always has a model at both ends.
Widening it would need a third rule per owner kind for an arrangement that is
rare; the fields themselves are stated either way.

## A field only the Pack can supply

None. The one entry this file carried -- `omega-prisma`,
`definition.config_setting`, field `value` -- has been published and is read by
four rules. It is deleted rather than kept as history: a gap left standing after
the thing it measured has changed is how the next agent inherits a conclusion
instead of a fact.
