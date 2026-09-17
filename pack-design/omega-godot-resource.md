# omega-godot-resource

Language `omega-godot-resource`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

7 templates over 10 query patterns, 5 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 6 |
| `references` | yes | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `structured.entry` | reference | 2 |
| `structured.godot_ext_resource_id_path_context` | reference | 1 |
| `structured.godot_node_script_ext_resource_context` | reference | 1 |
| `structured.godot_section_attribute_context` | reference | 1 |
| `value.document` | reference | 1 |
| `reference.godot_resource_constructor` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 18 node types. The Pack looks at 9 of them.

Untouched:

- `array`
- `comment`
- `dictionary`
- `false`
- `float`
- `integer`
- `null`
- `pair`
- `true`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
