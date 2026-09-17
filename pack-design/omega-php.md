# omega-php

Language `omega-php`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

71 templates over 109 query patterns, 37 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 10 |
| `data` | yes | 5 |
| `definitions` | yes | 32 |
| `imports` | yes | 4 |
| `modules` | yes | 2 |
| `references` | yes | 9 |
| `scopes` | yes | 4 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.function` | Callable | 2 |
| `definition.php_attributed_method_route_context` | Callable | 1 |
| `definition.php_class` | Type | 1 |
| `definition.php_class_method_context` | Type | 1 |
| `definition.php_field` | Value | 2 |
| `definition.php_function` | Callable | 2 |
| `definition.php_interface` | Value | 1 |
| `definition.php_method` | Callable | 1 |
| `definition.php_module` | Value | 1 |
| `definition.php_type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `relation.php_implements_candidate` | `omega.pack.php_implements` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 9 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 2 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.php_candidate` | `omega.pack.php` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.php_candidate` | `omega.pack.php` | 1 |
| `reference.php_identifier_candidate` | `omega.pack.php_identifier` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.php_declaration_candidate` | `omega.pack.php_declaration` | 1 |

### Regions

- `scope.lexical` (1)
- `scope.php_lexical_scope` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.php_variable` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `import_binding.php_import` | binding | 1 |
| `call.call` | call | 2 |
| `call.direct` | call | 1 |
| `call.member` | call | 1 |
| `call.php_call` | call | 1 |
| `call.php_function_string_arg_context` | call | 1 |
| `call.php_function_string_identifier_args_context` | call | 1 |
| `call.php_function_two_string_args_context` | call | 1 |
| `import.php_alias_source_binding_context` | binding | 1 |
| `import.php_simple_source_context` | binding | 1 |
| `import.php_source_context` | binding | 1 |
| `reference.class` | reference | 2 |
| `reference.local` | reference | 1 |
| `reference.php_class` | reference | 1 |
| `reference.php_class_relation_explicit_target_context` | reference | 1 |
| `reference.php_constructor_parameter_type_context` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (1)
- `literal.null` (1)
- `literal.number` (2)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 162 node types. The Pack looks at 61 of them.

Untouched:

- `anonymous_class`
- `argument_placeholder`
- `array_creation_expression`
- `array_element_initializer`
- `assignment_expression`
- `augmented_assignment_expression`
- `binary_expression`
- `bottom_type`
- `break_statement`
- `by_ref`
- `case_statement`
- `cast_expression`
- `cast_type`
- `catch_clause`
- `clone_expression`
- `colon_block`
- `comment`
- `conditional_expression`
- `const_declaration`
- `const_element`
- `continue_statement`
- `declare_directive`
- `declare_statement`
- `default_statement`
- `disjunctive_normal_form_type`
- `do_statement`
- `dynamic_variable_name`
- `echo_statement`
- `else_clause`
- `else_if_clause`
- `empty_statement`
- `encapsed_string`
- `error_suppression_expression`
- `escape_sequence`
- `exit_statement`
- `expression`
- `expression_statement`
- `finally_clause`
- `for_statement`
- `function_static_declaration`
- `global_declaration`
- `goto_statement`
- `heredoc`
- `heredoc_body`
- `heredoc_end`
- `heredoc_start`
- `if_statement`
- `include_once_expression`
- `intersection_type`
- `list_literal`
- `literal`
- `match_block`
- `match_condition_list`
- `match_conditional_expression`
- `match_default_expression`
- `match_expression`
- `named_label_statement`
- `namespace_use_group`
- `nowdoc`
- `nowdoc_body`
- `nowdoc_string`
- `operation`
- `optional_type`
- `parenthesized_expression`
- `php_end_tag`
- `php_tag`
- `primary_expression`
- `primitive_type`
- `print_intrinsic`
- `program`
- `property_hook`
- `property_hook_list`
- `reference_assignment_expression`
- `reference_modifier`
- `relative_scope`
- `require_once_expression`
- `sequence_expression`
- `shell_command_expression`
- `statement`
- `subscript_expression`
- `switch_block`
- `switch_statement`
- `text`
- `text_interpolation`
- `throw_expression`
- `try_statement`
- `type`
- `type_list`
- `unary_op_expression`
- `union_type`
- `unset_statement`
- `update_expression`
- `use_as_clause`
- `use_declaration`
- `use_instead_of_clause`
- `use_list`
- `var_modifier`
- `variadic_placeholder`
- `variadic_unpacking`
- `while_statement`
- `yield_expression`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
