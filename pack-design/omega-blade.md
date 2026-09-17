# omega-blade

Language `omega-blade`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

14 templates over 16 query patterns, 5 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `data` | yes | 6 |
| `definitions` | yes | 1 |
| `imports` | yes | 1 |
| `references` | yes | 4 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.blade_section` | Value | 1 |

### Regions

- `scope.blade_construct` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.symbol` | reference | 1 |
| `data.blade_attribute_name_context` | reference | 1 |
| `data.blade_attribute_value_context` | reference | 1 |
| `data.blade_directive` | reference | 1 |
| `data.blade_directive_token` | reference | 1 |
| `data.blade_named_directive` | reference | 1 |
| `data.blade_section` | reference | 1 |
| `import.blade_extends` | binding | 1 |
| `reference.blade_component` | reference | 1 |
| `reference.blade_include` | reference | 1 |
| `reference.blade_stack` | reference | 1 |
| `reference.blade_yield` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 39 node types. The Pack looks at 17 of them.

Untouched:

- `comment`
- `conditional_keyword`
- `doctype`
- `document`
- `element`
- `end_tag`
- `entity`
- `envoy`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `fragment`
- `keyword`
- `livewire`
- `once`
- `raw_text`
- `script_element`
- `self_closing_tag`
- `start_tag`
- `style_element`
- `tag_name`
- `text`
- `verbatim`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
