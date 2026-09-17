# omega-csv

Language `omega-csv`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

6 templates over 7 query patterns, 3 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 6 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `semantic_hint.syntax_node` | reference | 1 |
| `structured.entry` | reference | 3 |
| `value.csv_row` | reference | 1 |
| `value.document` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 17 node types. The Pack looks at 9 of them.

Untouched:

- `cycle4`
- `cycle5`
- `cycle6`
- `cycle7`
- `fifth`
- `fourth`
- `seventh`
- `sixth`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
