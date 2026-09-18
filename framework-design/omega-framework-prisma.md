# omega-framework-prisma

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 2 detection rules. **0 can match, 12 cannot.**

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

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
