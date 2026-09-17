# omega-prisma

Language `omega-prisma`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

20 templates over 22 query patterns, 12 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `data` | yes | 11 |
| `definitions` | yes | 5 |
| `references` | yes | 1 |
| `scopes` | yes | 1 |
| `types` | yes | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.prisma_candidate` | `omega.pack.prisma` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.prisma_declaration_candidate` | `omega.pack.prisma_declaration` | 1 |
| `type.prisma_declaration_candidate` | `omega.pack.prisma_declaration` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.datasource` | reference | 1 |
| `data.enum` | reference | 1 |
| `data.enum_value` | reference | 1 |
| `data.field` | reference | 1 |
| `data.generator` | reference | 1 |
| `data.model` | reference | 1 |
| `data.prisma_block_attribute` | reference | 1 |
| `data.prisma_model_typed_field` | reference | 1 |
| `data.relation` | reference | 1 |
| `data.view` | reference | 1 |
| `data.view_field` | reference | 1 |
| `reference.symbol` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 36 node types. The Pack looks at 16 of them.

Untouched:

- `_declaration`
- `arguments`
- `array`
- `assignment_expression`
- `assignment_pattern`
- `binary_expression`
- `comment`
- `developer_comment`
- `false`
- `formal_parameters`
- `maybe`
- `null`
- `number`
- `program`
- `property_identifier`
- `string`
- `true`
- `type_declaration_type`
- `type_expression`
- `variable`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
