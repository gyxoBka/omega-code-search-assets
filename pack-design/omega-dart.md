# omega-dart

Language `omega-dart`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

61 templates over 67 query patterns, 26 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 7 |
| `calls` | yes | 6 |
| `definitions` | yes | 31 |
| `imports` | yes | 4 |
| `references` | yes | 7 |
| `scopes` | yes | 5 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.dart_class` | Type | 1 |
| `definition.dart_class_extends_context` | Type | 1 |
| `definition.dart_enum` | Type | 1 |
| `definition.dart_extension` | Value | 1 |
| `definition.dart_function` | Callable | 2 |
| `definition.dart_method` | Callable | 1 |
| `definition.dart_mixin` | Value | 1 |
| `definition.dart_type` | Type | 1 |
| `definition.enum` | Type | 2 |
| `definition.function` | Callable | 3 |
| `definition.interface` | Value | 2 |
| `definition.type` | Type | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 6 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `import.dart_candidate` | `omega.pack.dart` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `reference.dart_identifier_candidate` | `omega.pack.dart_identifier` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.dart_declaration_candidate` | `omega.pack.dart_declaration` | 1 |

### Regions

- `scope.dart_lexical_scope` (1)
- `scope.lexical` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.dart_parameter` | reference | 1 |
| `binding.dart_variable` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `call.dart_call` | call | 1 |
| `call.dart_named_string_builder_constructor_context` | call | 1 |
| `call.dart_receiver_member_context` | call | 1 |
| `call.dart_receiver_member_route_context` | call | 1 |
| `reference.dart_prefixed_member_call_context` | call | 1 |
| `import.dart_module_context` | binding | 1 |
| `import.dart_prefixed_import_context` | binding | 1 |
| `reference.dart_class` | reference | 1 |
| `reference.local` | reference | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 221 node types. The Pack looks at 58 of them.

Untouched:

- `_literal`
- `_statement`
- `abstract`
- `additive_expression`
- `additive_operator`
- `annotation`
- `as_operator`
- `assert_builtin`
- `assert_statement`
- `assertion`
- `assertion_arguments`
- `assignment_expression_without_cascade`
- `await_expression`
- `base`
- `binary_operator`
- `bitwise_and_expression`
- `bitwise_operator`
- `bitwise_or_expression`
- `bitwise_xor_expression`
- `break_builtin`
- `break_statement`
- `case_builtin`
- `cast_pattern`
- `catch_parameters`
- `class_body`
- `combinator`
- `comment`
- `conditional_expression`
- `configuration_uri`
- `configuration_uri_condition`
- `const_builtin`
- `const_object_expression`
- `constant_constructor_signature`
- `constant_pattern`
- `constructor_invocation`
- `constructor_param`
- `constructor_tearoff`
- `continue_statement`
- `decimal_floating_point_literal`
- `decimal_integer_literal`
- `declaration`
- `do_statement`
- `documentation_comment`
- `dot_shorthand`
- `dotted_identifier_list`
- `empty_statement`
- `equality_expression`
- `equality_operator`
- `escape_sequence`
- `expression_statement`
- `extension_body`
- `false`
- `field_initializer`
- `final_builtin`
- `for_element`
- `function_type`
- `hex_integer_literal`
- `identifier_dollar_escaped`
- `identifier_list`
- `if_element`
- `if_null_expression`
- `import_or_export`
- `increment_operator`
- `index_selector`
- `inferred_type`
- `initialized_identifier_list`
- `initializer_list_entry`
- `initializers`
- `interface`
- `interfaces`
- `is_operator`
- `labeled_statement`
- `lambda_expression`
- `library_import`
- `library_name`
- `list_literal`
- `list_pattern`
- `local_function_declaration`
- `local_variable_declaration`
- `logical_and_expression`
- `logical_and_operator`
- `logical_or_expression`
- `logical_or_operator`
- `map_pattern`
- `minus_operator`
- `mixin_application`
- `mixin_application_class`
- `mixins`
- `multiplicative_expression`
- `multiplicative_operator`
- `named_parameter_types`
- `negation_operator`
- `normal_parameter_type`
- `null_assert_pattern`
- `null_check_pattern`
- `null_literal`
- `nullable_selector`
- `nullable_type`
- `object_pattern`
- `optional_parameter_types`
- `optional_positional_parameter_types`
- `pair`
- `parameter_type_list`
- `parenthesized_expression`
- `part_directive`
- `part_of_builtin`
- `part_of_directive`
- `pattern_assignment`
- `pattern_variable_declaration`
- `postfix_expression`
- `postfix_operator`
- `prefix_operator`
- `program`
- `qualified`
- `record_field`
- `record_literal`
- `record_pattern`
- `record_type`
- `record_type_field`
- `record_type_named_field`
- `redirecting_factory_constructor_signature`
- `redirection`
- `relational_expression`
- `relational_operator`
- `representation_declaration`
- `rest_pattern`
- `rethrow_builtin`
- `rethrow_expression`
- `return_statement`
- `script_tag`
- `sealed`
- `set_or_map_literal`
- `shift_expression`
- `shift_operator`
- `spread_element`
- `static_final_declaration_list`
- `super_formal_parameter`
- `switch_block`
- `switch_expression`
- `switch_expression_case`
- `switch_statement`
- `switch_statement_case`
- `switch_statement_default`
- `symbol_literal`
- `template_substitution`
- `throw_expression`
- `throw_expression_without_cascade`
- `tilde_operator`
- `true`
- `type_bound`
- `type_cast`
- `type_cast_expression`
- `type_parameter`
- `type_parameters`
- `type_test`
- `type_test_expression`
- `typed_identifier`
- `unary_expression`
- `uri_test`
- `variable_pattern`
- `void_type`
- `yield_each_statement`
- `yield_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
