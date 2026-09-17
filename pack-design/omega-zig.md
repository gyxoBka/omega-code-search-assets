# omega-zig

Language `omega-zig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

71 templates over 107 query patterns, 38 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 2 |
| `data` | yes | 35 |
| `definitions` | yes | 15 |
| `imports` | yes | 3 |
| `references` | yes | 4 |
| `scopes` | yes | 3 |
| `tests` | yes | 2 |
| `types` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.zig_error_member` | Value | 1 |
| `definition.zig_field` | Value | 2 |
| `definition.zig_function` | Callable | 2 |
| `definition.zig_method` | Callable | 2 |
| `definition.zig_symbol` | Value | 2 |
| `definition.zig_type` | Type | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `call.zig_direct_candidate` | `omega.pack.zig_direct` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 2 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `import.zig_candidate` | `omega.pack.zig` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.zig_identifier_candidate` | `omega.pack.zig_identifier` | 2 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.zig_declaration_candidate` | `omega.pack.zig_declaration` | 1 |

### Regions

- `scope.zig_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.zig_parameter` | reference | 2 |
| `binding.zig_variable` | reference | 2 |
| `data.zig_comptime_declaration` | reference | 1 |
| `data.zig_comptime_expression` | reference | 1 |
| `data.zig_comptime_statement` | reference | 1 |
| `semantic_hint.zig_callable` | call | 3 |
| `semantic_hint.zig_documentation` | reference | 2 |
| `semantic_hint.zig_literal` | reference | 6 |
| `semantic_hint.zig_module` | reference | 2 |
| `semantic_hint.zig_syntax_role` | reference | 11 |
| `semantic_hint.zig_type` | reference | 2 |
| `semantic_hint.zig_value` | reference | 6 |
| `import.zig_usingnamespace` | binding | 2 |
| `test.zig` | reference | 1 |
| `test.zig_declaration` | reference | 1 |
| `type.zig_comptime_expression` | reference | 1 |
| `type.zig_error_set` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 99 node types. The Pack looks at 51 of them.

Untouched:

- `address_space`
- `anonymous_struct_initializer`
- `anyframe_type`
- `arguments`
- `asm_expression`
- `asm_input`
- `asm_output`
- `async_expression`
- `await_expression`
- `binary_expression`
- `block_expression`
- `break_expression`
- `byte_alignment`
- `catch_expression`
- `character_content`
- `continue_expression`
- `defer_statement`
- `dereference_expression`
- `else_clause`
- `errdefer_statement`
- `error_type`
- `error_union_type`
- `expression_statement`
- `for_expression`
- `if_expression`
- `if_type_expression`
- `index_expression`
- `labeled_statement`
- `labeled_type_expression`
- `link_section`
- `nosuspend_expression`
- `nosuspend_statement`
- `null_coercion_expression`
- `parameters`
- `parenthesized_expression`
- `primary_type_expression`
- `range_expression`
- `resume_expression`
- `return_expression`
- `statement`
- `string_content`
- `suspend_statement`
- `switch_case`
- `switch_expression`
- `try_expression`
- `type_expression`
- `unary_expression`
- `while_expression`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
