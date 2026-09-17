# omega-vue

Language `omega-vue`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

18 templates over 23 query patterns, 12 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 14 |
| `references` | yes | 3 |
| `scopes` | yes | 1 |

### Regions

- `scope.vue_element` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.vue_component` | reference | 1 |
| `data.vue_directive` | reference | 1 |
| `data.vue_directive_argument` | reference | 1 |
| `data.vue_directive_dynamic_argument` | reference | 1 |
| `data.vue_directive_modifier` | reference | 2 |
| `data.vue_directive_value` | reference | 1 |
| `data.vue_element` | reference | 1 |
| `data.vue_interpolation` | reference | 1 |
| `data.vue_script_section` | reference | 1 |
| `data.vue_style_section` | reference | 1 |
| `data.vue_template_section` | reference | 1 |
| `structured.entry` | reference | 1 |
| `structured.vue_attribute_value` | reference | 1 |
| `reference.vue_directive_argument` | reference | 1 |
| `reference.vue_dynamic_argument` | reference | 1 |
| `reference.vue_interpolation` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 26 node types. The Pack looks at 21 of them.

Untouched:

- `comment`
- `end_tag`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `text`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
