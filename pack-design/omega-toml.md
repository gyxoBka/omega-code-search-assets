# omega-toml

Language `omega-toml`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

30 templates over 31 query patterns, 14 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 28 |
| `scopes` | yes | 2 |

### Regions

- `scope.toml_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.document_contains_pair` | reference | 1 |
| `relation.document_contains_table` | reference | 1 |
| `relation.object_contains_pair` | reference | 1 |
| `relation.table_array_contains_pair` | reference | 1 |
| `relation.table_contains_pair` | reference | 1 |
| `semantic_hint.toml_documentation` | reference | 1 |
| `semantic_hint.toml_literal` | reference | 6 |
| `semantic_hint.toml_member` | reference | 1 |
| `semantic_hint.toml_syntax_role` | reference | 1 |
| `structured.entry` | reference | 4 |
| `value.array` | reference | 1 |
| `value.document` | reference | 1 |
| `value.object` | reference | 1 |
| `value.object_pair` | reference | 1 |
| `value.table` | reference | 1 |
| `value.table_array` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (1)
- `literal.number` (2)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 19 node types. The Pack looks at 19 of them.

Untouched:


## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
