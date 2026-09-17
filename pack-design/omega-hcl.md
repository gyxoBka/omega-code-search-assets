# omega-hcl

Language `omega-hcl`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

37 templates over 42 query patterns, 14 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 2 |
| `calls` | yes | 2 |
| `data` | yes | 15 |
| `definitions` | yes | 7 |
| `references` | yes | 9 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.hcl_attribute` | Value | 1 |
| `definition.hcl_block` | Value | 1 |
| `definition.hcl_block_labeled` | Value | 2 |
| `definition.hcl_local` | Value | 1 |

### Regions

- `scope.hcl_block` (1)
- `scope.hcl_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.hcl_for_binding` | reference | 1 |
| `binding.hcl_template_for_binding` | reference | 1 |
| `call.hcl_function_call` | call | 1 |
| `call.hcl_function_context` | call | 1 |
| `data.hcl_block_attribute_context` | reference | 1 |
| `data.hcl_block_object_entry_context` | reference | 1 |
| `data.hcl_block_object_entry_one_label_context` | reference | 1 |
| `data.hcl_block_object_entry_unlabeled_context` | reference | 1 |
| `data.hcl_block_string_attribute_context` | reference | 1 |
| `data.hcl_nested_block_context` | reference | 1 |
| `data.hcl_unlabeled_block_attribute_context` | reference | 1 |
| `data.hcl_unlabeled_block_string_attribute_context` | reference | 1 |
| `data.hcl_unlabeled_nested_block_context` | reference | 1 |
| `semantic_hint.hcl_function_call_structure_hint` | call | 1 |
| `structured.entry` | reference | 1 |
| `reference_context.template_condition` | reference | 1 |
| `reference_context.template_interpolation` | reference | 1 |
| `reference.hcl_block_list_traversal3_context` | reference | 1 |
| `reference.hcl_block_list_traversal_context` | reference | 2 |
| `reference.hcl_block_traversal3_context` | reference | 2 |
| `reference.hcl_block_traversal_context` | reference | 2 |
| `reference.hcl_traversal_member` | reference | 1 |
| `reference.hcl_variable` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (1)
- `literal.null` (1)
- `literal.number` (1)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 64 node types. The Pack looks at 22 of them.

Untouched:

- `attr_splat`
- `binary_operation`
- `block_end`
- `block_start`
- `comment`
- `conditional`
- `config_file`
- `ellipsis`
- `for_cond`
- `for_expr`
- `for_object_expr`
- `for_tuple_expr`
- `full_splat`
- `function_arguments`
- `heredoc_identifier`
- `heredoc_start`
- `heredoc_template`
- `index`
- `legacy_index`
- `new_index`
- `object_end`
- `object_start`
- `operation`
- `quoted_template`
- `quoted_template_end`
- `quoted_template_start`
- `splat`
- `strip_marker`
- `template_directive`
- `template_directive_end`
- `template_directive_start`
- `template_else_intro`
- `template_expr`
- `template_for`
- `template_for_end`
- `template_if`
- `template_if_end`
- `template_interpolation_end`
- `template_interpolation_start`
- `tuple_end`
- `tuple_start`
- `unary_operation`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
