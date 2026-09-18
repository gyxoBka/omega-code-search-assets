# omega-framework-prisma

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 2 detection rules. **0 could match, 12 could not.**
Rewritten: **16 overlay rules, all 16 live.** Everything below this line
records the file as it was; what replaced it is in *What it states now*.

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

**All 12 rules were keyed to a vocabulary no Pack has ever emitted.** The file
matched ten kinds — `data.model`, `data.field`, `data.relation`,
`data.datasource`, `data.enum`, `data.generator`, `data.view`,
`data.view_field`, `data.enum_value`, `data.prisma_model_typed_field` — and
`omega-prisma` emits none of them. It emits sixteen templates over twelve kinds,
all of them `definition.*` or `reference.*`. So the overlay was 12 for 12 dead
and contributed nothing to the graph.

**It read eight fields that no Pack publishes.** `data.name`, `data.model`,
`data.type`, `data.target`, `owner`, `target`, `field`, `type`. `omega-prisma`
publishes **no `fields` at all** on any of its sixteen templates — one
`attributes` entry (`value` on `definition.config_setting`) and nothing else.
Every one of those reads was unreachable even if the kinds had existed. The
whole of what the rewritten file reads is `definition.name`, `path`, and the
names of facts reached by a span join, which is all `omega-prisma` gives.

**Four of the 12 rules only restated their input.** `prisma.model`,
`prisma.datasource`, `prisma.enum`, `prisma.generator` each minted an entity
whose canonical key was its own name, with one attribute equal to that same
name, and emitted no relation. Nothing could be asked of them.

**One relation dangled by construction.** `prisma.view-field` emitted
`has_field` from `prisma:view:{path}:{source.start}` — a key `prisma.view`
mints from *its own* `source.start`, the span of the view declaration — while
the field's `source.start` is the span of the field. The two never agree, so
the source key was one nothing mints. The same rule minted `Field` under
`prisma:view-field:...` while `prisma.field` minted `Field` under
`prisma:field:...`: two spellings of one entity kind that could never meet.

**One rule required a join that could not run.** `prisma.implicit-model-relation`
joined `data.prisma_model_typed_field` to `data.model` on `current_field:
"target"` / `join_field: "name"` — a field-to-field join needing two published
fields where the Pack publishes zero.

Measured against a real schema with `dump_call_emissions` (a datasource, a
generator, two models, an enum, a view and a composite type), the old file
produced nothing at all. The new one produces the graph below.

## What it states now

16 rules, all live. Every join is `fact_join_by_span` — `omega-prisma` publishes
no field, so a span join is the only one available, and the queries were written
so that a field lies inside its model's span and a setting inside its block's,
which is exactly what `within` reads. Every rule carries `**/*.prisma`, because
`definition.field`, `definition.enum`, `definition.config_setting`,
`reference.field` and `relation.depends` are emitted by 17–25 other Packs.

| what it answers | which Pack fact | what it emits |
|---|---|---|
| which models does this schema declare | `definition.model_type` | `Model` `prisma:model:{name}`, `SchemaProject` `prisma:schema:{path}`, `declares` schema → model |
| which views | `definition.view_type` | `View` `prisma:view:{name}`, `declares` |
| which composite types (`type Photo {}`) | `definition.composite_type` | `CompositeType` `prisma:type:{name}`, `declares` |
| which enums | `definition.enum` in a `.prisma` file | `Enum` `prisma:enum:{name}`, `declares` |
| which values does this enum admit | `definition.enumeral` `within` `definition.enum` | `EnumValue` `prisma:enum-value:{enum}:{name}`, `has_value` enum → value |
| what fields does this model have, and of what declared type | `definition.field` `within` `definition.model_type`, plus `definition.return_type_candidate` on the **same** span (`String?`, `Post[]`, `Unsupported(...)` verbatim) | `Field` `prisma:field:{model}:{name}` with `type`, `has_field` model → field |
| same, for a view | `definition.field` `within` `definition.view_type` | `Field`, `has_field` view → field |
| same, for a composite type | `definition.field` `within` `definition.composite_type` | `Field`, `has_field` type → field |
| **what does this model relate to** | `reference.field_type` `within` a field `within` a model, joined by name to a `definition.model_type` anywhere in the repository | `relates_to` model → model, attribute `field` = the field that carries it |
| which enum does this field take its values from | `reference.field_type` likewise, joined by name to a `.prisma` `definition.enum` | `uses_enum` field → enum |
| which database does this schema connect to | `definition.datasource_config` | `Datasource` `prisma:datasource:{name}`, `configured_by` schema → datasource |
| which client is generated from it | `definition.generator_config` | `Generator` `prisma:generator:{name}`, `configured_by` schema → generator |
| what does this datasource configure (`directUrl`, `shadowDatabaseUrl`, `relationMode`) | `definition.config_setting` `within` `definition.datasource_config` | `Setting`, `configures` setting → datasource |
| what does this generator configure (`previewFeatures`, `output`, `binaryTargets`) | `definition.config_setting` `within` `definition.generator_config` | `Setting`, `configures` setting → generator |
| **which environment variables must be set for this schema to load** | `relation.depends` in a `.prisma` file — the `env("…")` argument | `EnvVar` `prisma:env:{name}`, `depends_on` schema → env var |
| which SQL column is this field stored in | `definition.config_mapping` `within` a field `within` a model — `@map("created_at")` | `Column` `prisma:column:{model}:{column}`, `maps_to` field → column |

The two cross-file edges are the ones a language Pack cannot state: a
`reference.field_type` named `User` in `post.prisma` and `model User` in
`user.prisma` are two unrelated facts until the overlay joins them by name. Both
`relates_to` and `uses_enum` are deliberately **not** `same_path`, so a
multi-file Prisma schema (`prismaSchemaFolder`) resolves; the model and enum keys
are path-free for the same reason.

Every relation end is minted. `prisma:schema:{path}` by six rules,
`prisma:model:{name}` by `prisma.model`, `prisma:view:…` by `prisma.view`,
`prisma:type:…` by `prisma.composite-type`, `prisma:enum:…` by `prisma.enum`,
`prisma:field:{model}:{name}` by `prisma.model.field`,
`prisma:datasource:…`/`prisma:generator:…` by their own rules. The addressing
rules carry the same clauses as the minting ones: `prisma.field.uses-enum`
repeats the `**/*.prisma` glob inside its name join, because `definition.enum`
without it would reach a Java or Rust enum that `prisma.enum` never mints; and
`prisma.field.column-name` addresses `prisma:field:{model}:{field}`, which
`prisma.model.field` mints for every field inside a model.

## A field only the Pack can supply

**Pack `omega-prisma`, kind `definition.config_setting`, field `value`.**

`provider = "postgresql"` is the single most-asked fact about a Prisma schema —
*which database is this project on* — and the overlay cannot state it. The Pack
already computes the unquoted value and publishes it, but as an **attribute**,
and `OverlayFact::field` resolves the `fields` map and a fixed list of built-in
names and never consults `attributes` (`overlay.rs:56`). The only clause that
reads one is `attribute_equals`, against a single literal constant: the value
cannot become a canonical key, a relation end, an entity attribute or a join
key. The same applies to `generator.output`, `generator.binaryTargets` and
`datasource.relationMode`.

Neither of the two cheaper routes reaches it. It is not a built-in name — it is
not the emission's name, which is `provider`, nor its path or span. And no join
reaches it either: a span join would have to land on a fact that *carries* the
value, and the only fact spanning `"postgresql"` is the `definition.config_setting`
itself; the string is not separately emitted, because `queries.scm` deliberately
declines to emit a mention for a setting's scalar value. The fix is one
character of Pack template: move `value` from `attributes` to `fields` on the
first `definition.config_setting` template. This is the same row wave 1 already
recorded for `omega-yaml`/`omega-json` `definition.config_key`, and it is the
same remedy.

## Still to decide

**`@@map("users")` — the table a model is stored in — is not stated, and the
reason is structural.** `@@map` on a model and `@map` on a field are the *same*
`definition.config_mapping` fact; the only thing that tells them apart is that
the field-level one lies inside a `definition.field` span and the model-level one
does not. The overlay has no negative join and no clause that compares a fact's
own derived container against a joined fact's name, so a rule written for the
table case would also fire on every `@map`, claiming `model User` is stored in
table `email_address`. That is a false fact, so the rule is not written and only
the column case ships. Two ways out, neither taken here: a Pack pattern that
distinguishes `(block_attribute (call_expression …))` from
`(column_declaration (attribute …))` and emits the model-level one under its own
kind, or a host clause that negates a join. The first is cheap and local and is
probably the right one.

**`reference.field` is unused.** `@@id([a, b])`, `@@unique([email])`,
`@@index([email, name])` and `@relation(fields: [authorId], references: [id])`
all emit `reference.field`, and nothing in the fact distinguishes an own-model
key column from a target-model referenced column — `references: [id]` names a
field of `User` while sitting inside `model Post`. A rule keyed to it would
emit `Post.id` where the schema says `User.id`. Rather than ship a wrong edge,
*which columns form this index* and *which foreign key backs this relation* are
left unanswered; the relation itself is still stated, by `prisma.model.relates-to`,
from the field's type.

**A field of a view or composite type typed by a model does not emit
`relates_to`.** `prisma.model.relates-to` requires the owner to be a
`definition.model_type`, so the relation always has a model at both ends.
Widening it would need a third rule per owner kind for an arrangement that is
rare; the fields themselves are stated either way.
