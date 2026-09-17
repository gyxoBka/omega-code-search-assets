# omega-solidity

Language `omega-solidity`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

40 templates over 69 query patterns, 29 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 2 |
| `data` | yes | 1 |
| `definitions` | yes | 25 |
| `imports` | yes | 4 |
| `references` | yes | 3 |
| `scopes` | yes | 3 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.contract_or_type` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.interface_or_library` | Value | 1 |
| `definition.method` | Callable | 1 |
| `definition.solidity_constructor` | Type | 1 |
| `definition.solidity_enum_value` | Type | 1 |
| `definition.solidity_fallback_receive` | Value | 1 |
| `definition.solidity_yul_function` | Callable | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 8 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 5 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `reference.local_candidate` | `omega.pack.local` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.solidity_declaration_candidate` | `omega.pack.solidity_declaration` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.local` | reference | 1 |
| `call.call` | call | 1 |
| `semantic_hint.solidity_contract_declaration_structure_hint` | reference | 1 |
| `import.import_reference` | binding | 1 |
| `reference.type_or_event_reference` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 124 node types. The Pack looks at 40 of them.

Untouched:

- `any_pragma_token`
- `any_source_type`
- `array_access`
- `assembly_flags`
- `assembly_statement`
- `augmented_assignment_expression`
- `binary_expression`
- `boolean_literal`
- `break_statement`
- `call_argument`
- `catch_clause`
- `comment`
- `continue_statement`
- `do_while_statement`
- `error_parameter`
- `expression_statement`
- `false`
- `for_statement`
- `function_body`
- `hex_string_literal`
- `if_statement`
- `immutable`
- `inline_array_expression`
- `layout_specifier`
- `meta_type_expression`
- `modifier_invocation`
- `new_expression`
- `number_literal`
- `number_unit`
- `override_specifier`
- `parenthesized_expression`
- `payable_conversion_expression`
- `pragma_directive`
- `pragma_value`
- `primitive_type`
- `return_parameter`
- `return_statement`
- `return_type_definition`
- `revert_arguments`
- `revert_statement`
- `slice_access`
- `solidity_pragma_token`
- `solidity_version`
- `solidity_version_comparison_operator`
- `state_location`
- `state_mutability`
- `statement`
- `string`
- `string_literal`
- `struct_expression`
- `ternary_expression`
- `true`
- `try_statement`
- `tuple_expression`
- `type_alias`
- `type_cast_expression`
- `type_name`
- `unary_expression`
- `unchecked`
- `unicode_string_literal`
- `update_expression`
- `user_definable_operator`
- `using_alias`
- `variable_declaration_statement`
- `variable_declaration_tuple`
- `virtual`
- `while_statement`
- `yul_assignment`
- `yul_block`
- `yul_boolean`
- `yul_break`
- `yul_continue`
- `yul_decimal_number`
- `yul_evm_builtin`
- `yul_for_statement`
- `yul_hex_number`
- `yul_hex_string_literal`
- `yul_if_statement`
- `yul_label`
- `yul_leave`
- `yul_path`
- `yul_string_literal`
- `yul_switch_statement`
- `yul_variable_declaration`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
