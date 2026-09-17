# omega-html

Language `omega-html`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

17 templates over 40 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 12 |
| `references` | yes | 2 |
| `scopes` | yes | 3 |

### Regions

- `scope.html_lexical_scope` (2)
- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.html_attribute_context` | reference | 2 |
| `data.html_element_text_context` | reference | 1 |
| `semantic_hint.html_attribute` | reference | 1 |
| `semantic_hint.html_doctype` | reference | 1 |
| `semantic_hint.html_entity` | reference | 1 |
| `semantic_hint.html_tag` | reference | 1 |
| `value.attribute` | reference | 1 |
| `value.element` | reference | 1 |
| `value.embedded_script_region` | reference | 1 |
| `value.embedded_style_region` | reference | 1 |
| `reference.html_link_target` | reference | 1 |
| `reference.html_resource_url_context` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.text_or_entity` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 19 node types. The Pack looks at 16 of them.

Untouched:

- `document`
- `end_tag`
- `erroneous_end_tag`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
