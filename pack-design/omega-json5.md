# omega-json5

Language `omega-json5`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

18 templates over 19 query patterns, 11 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 18 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.comment` | reference | 1 |
| `relation.array_contains_value` | reference | 1 |
| `relation.document_value` | reference | 1 |
| `relation.object_contains_pair` | reference | 1 |
| `structured.entry` | reference | 3 |
| `value.array` | reference | 1 |
| `value.document` | reference | 1 |
| `value.identifier` | reference | 1 |
| `value.object` | reference | 1 |
| `value.object_key` | reference | 1 |
| `value.object_pair` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (2)
- `literal.null` (1)
- `literal.number` (1)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 11 node types. The Pack looks at 11 of them.

Untouched:


## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
