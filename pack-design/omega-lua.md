# omega-lua

Language `omega-lua`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

36 templates over 90 query patterns, 32 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 7 |
| `calls` | yes | 3 |
| `definitions` | yes | 17 |
| `imports` | yes | 2 |
| `references` | yes | 3 |
| `scopes` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.associated` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.lua_dsl_action_context` | Value | 1 |
| `definition.lua_dsl_string_call_context` | Value | 1 |
| `definition.lua_field` | Value | 2 |
| `definition.lua_function` | Callable | 3 |
| `definition.lua_method` | Callable | 3 |
| `definition.method` | Callable | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 2 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `reference.lua_identifier_candidate` | `omega.pack.lua_identifier` | 2 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.lexical` (1)
- `scope.lua_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.lua_parameter` | reference | 2 |
| `binding.lua_variable` | reference | 2 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `call.lua_call` | call | 1 |
| `reference.lua_three_segment_call_context` | call | 1 |
| `import.require_module` | binding | 1 |
| `reference.local` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.literal_or_table` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 51 node types. The Pack looks at 39 of them.

Untouched:

- `block`
- `bracket_index_expression`
- `comment_content`
- `declaration`
- `empty_statement`
- `expression`
- `implicit_variable_declaration`
- `parenthesized_expression`
- `return_statement`
- `statement`
- `variable`
- `variable_declaration`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
