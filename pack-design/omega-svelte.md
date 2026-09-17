# omega-svelte

Language `omega-svelte`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

28 templates over 30 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `data` | yes | 15 |
| `definitions` | yes | 2 |
| `references` | yes | 3 |
| `scopes` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.snippet` | Value | 1 |
| `definition.svelte_snippet` | Value | 1 |

### Regions

- `scope.lexical` (4)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.await` | reference | 1 |
| `binding.loop` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.svelte_each` | reference | 1 |
| `data.svelte_attribute` | reference | 1 |
| `data.svelte_attribute_value` | reference | 1 |
| `data.svelte_await_block` | reference | 1 |
| `data.svelte_declaration_tag` | reference | 1 |
| `data.svelte_directive` | reference | 1 |
| `data.svelte_directive_context` | reference | 1 |
| `data.svelte_each_block` | reference | 1 |
| `data.svelte_element` | reference | 1 |
| `data.svelte_event_attribute_context` | reference | 1 |
| `data.svelte_event_directive_binding_context` | reference | 1 |
| `data.svelte_if_block` | reference | 1 |
| `data.svelte_key` | reference | 1 |
| `data.svelte_key_block` | reference | 1 |
| `data.svelte_render_tag` | reference | 1 |
| `data.svelte_shorthand_attribute` | reference | 1 |
| `reference.svelte_expression` | reference | 1 |
| `reference.svelte_render_expression` | reference | 1 |
| `reference.svelte_shorthand` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 68 node types. The Pack looks at 24 of them.

Untouched:

- `attach_tag`
- `attribute_expected_equals_tail`
- `attribute_modifier`
- `attribute_modifiers`
- `attribute_sequence_recovery_tail`
- `await_branch`
- `await_branch_children`
- `await_pending`
- `block_close`
- `block_comment`
- `block_end`
- `block_keyword`
- `block_open`
- `block_sigil`
- `branch_kind`
- `comment`
- `const_tag`
- `debug_tag`
- `declaration_kind`
- `doctype`
- `document`
- `else_clause`
- `else_if_clause`
- `end_tag`
- `entity`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `html_tag`
- `incomplete_attribute_expression`
- `js`
- `line_comment`
- `malformed_block`
- `orphan_branch`
- `shorthand_kind`
- `snippet_header_trailing`
- `snippet_type_parameters`
- `tag_comment`
- `tag_local_name`
- `tag_member`
- `tag_missing_whitespace_trailing`
- `tag_namespace`
- `text`
- `ts`
- `unquoted_attribute_value`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
