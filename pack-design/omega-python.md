# omega-python

Language `omega-python`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

166 templates over 153 query patterns, 73 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 6 |
| `calls` | yes | 8 |
| `data` | yes | 15 |
| `definitions` | yes | 33 |
| `imports` | yes | 7 |
| `modules` | yes | 3 |
| `references` | yes | 71 |
| `scopes` | yes | 16 |
| `tests` | yes | 3 |
| `types` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.module_level_binding` | Value | 1 |
| `definition.python_binding_call_context` | Value | 1 |
| `definition.python_binding_call_keyword_context` | Value | 1 |
| `definition.python_binding_member_call_context` | Value | 1 |
| `definition.python_class_field_context` | Type | 1 |
| `definition.python_class_member_constructor_context` | Type | 1 |
| `definition.python_class_method_context` | Type | 1 |
| `definition.python_class_method_self_member_call_identifier_context` | Type | 1 |
| `definition.python_class_method_self_member_call_three_identifier_context` | Type | 1 |
| `definition.python_class_method_self_member_call_two_identifier_context` | Type | 1 |
| `definition.python_class_self_member_from_import_constructor_context` | Type | 1 |
| `definition.python_class_self_member_import_alias_constructor_context` | Type | 1 |
| `definition.python_from_import_callable_invocation_context` | Callable | 1 |
| `definition.python_from_import_constructor_binding_context` | Type | 1 |
| `definition.python_from_import_constructor_keyword_identifier_context` | Type | 1 |
| `definition.python_from_import_constructor_keyword_identifier_list_context` | Type | 1 |
| `definition.python_import_bound_chained_call_identifier_context` | Value | 1 |
| `definition.python_import_bound_member_binding_context` | Value | 1 |
| `definition.python_import_bound_member_call_identifier_context` | Value | 1 |
| `definition.python_import_bound_member_call_literal_keyword_context` | Value | 1 |
| `definition.python_import_bound_member_call_three_identifier_context` | Value | 1 |
| `definition.python_import_bound_member_call_two_identifier_context` | Value | 1 |
| `definition.python_import_bound_member_two_keyword_identifiers_context` | Value | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.variable` | Value | 1 |
| `test.class` | Test | 1 |
| `test.function` | Test | 1 |
| `type.class` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 2 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.path_origin_candidate` | `omega.pack.path_origin` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `reference.async_for_candidate` | `omega.pack.async_for` | 1 |
| `reference.async_with_candidate` | `omega.pack.async_with` | 1 |
| `reference.function_definition_candidate` | `omega.pack.function_definition` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.class` (1)
- `scope.function` (1)
- `scope.lambda` (1)
- `scope.module` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.import_alias` | binding | 1 |
| `binding.local` | reference | 1 |
| `binding.loop` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.update` | reference | 1 |
| `call.awaited` | call | 1 |
| `call.direct` | call | 1 |
| `call.member` | call | 1 |
| `call.python_class_method_self_member_return_identifier_context` | call | 1 |
| `call.python_class_self_registration_string_context` | call | 1 |
| `call.python_import_bound_member_identifier_list_item_context` | call | 1 |
| `call.python_receiver_identifier_argument_context` | call | 1 |
| `data.boolean` | reference | 1 |
| `data.dictionary` | reference | 1 |
| `data.float` | reference | 1 |
| `data.integer` | reference | 1 |
| `data.list` | reference | 1 |
| `data.none` | reference | 1 |
| `data.python_class_member_constructor_keyword_context` | reference | 1 |
| `data.python_module_identifier_dict_entry_context` | reference | 1 |
| `data.python_module_string_dict_entry_context` | reference | 1 |
| `data.python_module_string_list_item_context` | reference | 1 |
| `data.python_module_string_setting_context` | reference | 1 |
| `data.set` | reference | 1 |
| `data.string` | reference | 1 |
| `data.tuple` | reference | 1 |
| `structured.entry` | reference | 1 |
| `import.from_module` | binding | 1 |
| `import.future` | binding | 1 |
| `import.module` | binding | 1 |
| `module.from_module` | reference | 1 |
| `module.imported_module` | binding | 1 |
| `module.main_guard` | reference | 1 |
| `reference.async_await` | reference | 1 |
| `reference.call` | call | 1 |
| `reference.class_base_arguments` | reference | 1 |
| `reference.class_definition_extended` | reference | 1 |
| `reference.class_name` | reference | 1 |
| `reference.comprehension_dictionary` | reference | 1 |
| `reference.comprehension_for_clause` | reference | 1 |
| `reference.comprehension_generator` | reference | 1 |
| `reference.comprehension_if_clause` | reference | 1 |
| `reference.comprehension_list` | reference | 1 |
| `reference.comprehension_set` | reference | 1 |
| `reference.context_with` | reference | 1 |
| `reference.context_with_item` | reference | 1 |
| `reference.decorated_definition` | reference | 1 |
| `reference.decorator` | reference | 2 |
| `reference.exception_except` | reference | 1 |
| `reference.exception_finally` | reference | 1 |
| `reference.exception_try` | reference | 1 |
| `reference.expression_attribute` | reference | 1 |
| `reference.expression_binary` | reference | 1 |
| `reference.expression_boolean` | reference | 1 |
| `reference.expression_comparison` | reference | 1 |
| `reference.expression_conditional` | reference | 1 |
| `reference.expression_lambda` | reference | 1 |
| `reference.expression_named` | reference | 1 |
| `reference.expression_slice` | reference | 1 |
| `reference.expression_subscript` | reference | 1 |
| `reference.expression_unary` | reference | 1 |
| `reference.generator_yield` | reference | 1 |
| `reference.identifier` | reference | 1 |
| `reference.import_alias_extended` | binding | 1 |
| `reference.import_from_extended` | binding | 1 |
| `reference.import_future` | binding | 1 |
| `reference.import_relative` | binding | 1 |
| `reference.import_statement_extended` | binding | 1 |
| `reference.lambda_parameters` | reference | 1 |
| `reference.literal_comment` | reference | 1 |
| `reference.literal_concatenated_string` | reference | 1 |
| `reference.literal_dictionary` | reference | 1 |
| `reference.literal_ellipsis` | reference | 1 |
| `reference.literal_false` | reference | 1 |
| `reference.literal_float` | reference | 1 |
| `reference.literal_integer` | reference | 1 |
| `reference.literal_interpolation` | reference | 1 |
| `reference.literal_list` | reference | 1 |
| `reference.literal_none` | reference | 1 |
| `reference.literal_set` | reference | 1 |
| `reference.literal_string` | reference | 1 |
| `reference.literal_string_content` | reference | 1 |
| `reference.literal_true` | reference | 1 |
| `reference.literal_tuple` | reference | 1 |
| `reference.member` | reference | 1 |
| `reference.parameter_default` | reference | 1 |
| `reference.parameter_double_star` | reference | 1 |
| `reference.parameter_star` | reference | 1 |
| `reference.parameter_typed` | reference | 1 |
| `reference.parameter_typed_default` | reference | 1 |
| `reference.parameters` | reference | 1 |
| `reference.python_binary_identifier_context` | reference | 1 |
| `reference.python_class_list_string_tuple_context` | reference | 1 |
| `reference.python_from_import_class_base_context` | binding | 1 |
| `reference.python_import_alias_class_member_base_context` | binding | 1 |
| `reference.python_signature_binary_context` | reference | 1 |
| `reference.scope_global` | reference | 1 |
| `reference.scope_global_extended` | reference | 1 |
| `reference.scope_nonlocal` | reference | 1 |
| `reference.scope_nonlocal_extended` | reference | 1 |
| `control.control_assert` | reference | 1 |
| `control.control_break` | reference | 1 |
| `control.control_continue` | reference | 1 |
| `control.control_delete` | reference | 1 |
| `control.control_else_clause` | reference | 1 |
| `control.control_for` | reference | 1 |
| `control.control_if` | reference | 1 |
| `control.control_raise` | reference | 1 |
| `control.control_return` | reference | 1 |
| `control.control_while` | reference | 1 |
| `test.assertion` | reference | 1 |
| `type.alias` | reference | 1 |
| `type.parameter_annotation` | reference | 1 |
| `type.return_annotation` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 129 node types. The Pack looks at 80 of them.

Untouched:

- `_compound_statement`
- `_simple_statement`
- `as_pattern`
- `case_clause`
- `case_pattern`
- `chevron`
- `class_pattern`
- `complex_pattern`
- `constrained_type`
- `dict_pattern`
- `dictionary_splat`
- `elif_clause`
- `escape_interpolation`
- `escape_sequence`
- `except_group_clause`
- `exec_statement`
- `expression`
- `expression_list`
- `format_expression`
- `format_specifier`
- `generic_type`
- `import_prefix`
- `keyword_pattern`
- `keyword_separator`
- `line_continuation`
- `list_pattern`
- `list_splat`
- `match_statement`
- `member_type`
- `not_operator`
- `parenthesized_expression`
- `parenthesized_list_splat`
- `pass_statement`
- `pattern`
- `pattern_list`
- `positional_separator`
- `primary_expression`
- `print_statement`
- `splat_pattern`
- `splat_type`
- `string_end`
- `string_start`
- `tuple_pattern`
- `type_conversion`
- `type_parameter`
- `union_pattern`
- `union_type`
- `wildcard_import`
- `with_clause`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
