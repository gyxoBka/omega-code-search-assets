# omega-css

Language `omega-css`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

35 templates over 42 query patterns, 24 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `data` | yes | 23 |
| `definitions` | yes | 5 |
| `imports` | yes | 2 |
| `modules` | yes | 1 |
| `references` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.css_class_selector` | Type | 1 |
| `definition.css_custom_property` | Value | 1 |
| `definition.css_id_selector` | Value | 1 |
| `definition.css_keyframes` | Value | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `import.css_candidate` | `omega.pack.css` | 1 |
| `module.css_candidate` | `omega.pack.css` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.css_function` | call | 2 |
| `data.css_declaration` | reference | 1 |
| `data.css_media_rule` | reference | 1 |
| `data.css_selector_combinator` | reference | 1 |
| `data.css_supports_rule` | reference | 1 |
| `semantic_hint.css_callable` | call | 1 |
| `semantic_hint.css_lexical_role` | reference | 7 |
| `semantic_hint.css_literal` | reference | 3 |
| `semantic_hint.css_member` | reference | 3 |
| `semantic_hint.css_module` | reference | 2 |
| `semantic_hint.css_type` | reference | 1 |
| `semantic_hint.css_value` | reference | 2 |
| `import.css_path` | binding | 1 |
| `reference.css_custom_property` | reference | 1 |
| `reference.css_keyframes_animation` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 64 node types. The Pack looks at 39 of them.

Untouched:

- `at_rule`
- `binary_expression`
- `binary_query`
- `block`
- `charset_statement`
- `escape_sequence`
- `feature_query`
- `grid_value`
- `identifier`
- `important_value`
- `js_comment`
- `keyframe_block`
- `keyframe_block_list`
- `keyword_query`
- `namespace_selector`
- `parenthesized_query`
- `parenthesized_value`
- `postcss_statement`
- `rule_set`
- `scope_statement`
- `selector_query`
- `selectors`
- `string_content`
- `stylesheet`
- `unary_query`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
