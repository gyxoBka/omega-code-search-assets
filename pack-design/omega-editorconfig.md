# omega-editorconfig

Language `omega-editorconfig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

2 templates over 3 query patterns, 3 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 2 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `structured.editorconfig_global_setting` | reference | 1 |
| `structured.editorconfig_section_setting` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 17 node types. The Pack looks at 7 of them.

Untouched:

- `brace_expansion`
- `character`
- `character_choice`
- `character_escape`
- `character_range`
- `comment`
- `editorconfig`
- `integer`
- `integer_range`
- `wildcard`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
