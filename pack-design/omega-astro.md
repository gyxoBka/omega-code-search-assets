# omega-astro

Language `omega-astro`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

9 templates over 13 query patterns, 7 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 7 |
| `scopes` | yes | 2 |

### Regions

- `scope.astro_element` (1)
- `scope.astro_frontmatter` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.astro_element` | reference | 1 |
| `data.astro_frontmatter` | reference | 1 |
| `data.astro_interpolation` | reference | 1 |
| `data.astro_script_section` | reference | 1 |
| `data.astro_style_section` | reference | 1 |
| `structured.astro_attribute_value` | reference | 1 |
| `structured.entry` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 20 node types. The Pack looks at 13 of them.

Untouched:

- `comment`
- `doctype`
- `end_tag`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `fragment`
- `text`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
