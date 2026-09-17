# omega-ini

Language `omega-ini`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

9 templates over 9 query patterns, 6 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 9 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `semantic_hint.ini_lexical_role` | reference | 5 |
| `semantic_hint.ini_literal_hint` | reference | 1 |
| `semantic_hint.ini_value_hint` | reference | 1 |
| `structured.ini_section` | reference | 1 |
| `structured.ini_setting` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 8 node types. The Pack looks at 7 of them.

Untouched:

- `document`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
