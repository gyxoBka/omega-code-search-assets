# omega-go

Language `omega-go`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

215 templates over 141 query patterns, 88 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 17 |
| `calls` | yes | 14 |
| `data` | yes | 33 |
| `definitions` | yes | 44 |
| `imports` | yes | 8 |
| `modules` | yes | 10 |
| `references` | yes | 14 |
| `scopes` | yes | 31 |
| `tests` | yes | 2 |
| `types` | yes | 42 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.definition_alias` | Type | 1 |
| `definition.definition_alias_name` | Type | 1 |
| `definition.definition_field` | Value | 1 |
| `definition.definition_function` | Callable | 1 |
| `definition.definition_function_name` | Callable | 1 |
| `definition.definition_method` | Callable | 1 |
| `definition.definition_method_name` | Callable | 1 |
| `definition.definition_type` | Type | 1 |
| `definition.definition_type_name` | Type | 1 |
| `definition.documented_function` | Callable | 1 |
| `definition.documented_method` | Callable | 1 |
| `definition.field_declaration` | Value | 1 |
| `definition.go_bound_qualified_composite_identifier_field_context` | Value | 1 |
| `definition.go_bound_qualified_composite_string_field_context` | Value | 1 |
| `definition.go_import_alias_constructor_binding_context` | Type | 1 |
| `definition.go_import_alias_group_binding_context` | Type | 1 |
| `definition.go_method_context` | Callable | 1 |
| `definition.go_struct_embedding_context` | Type | 1 |
| `definition.go_unaliased_import_constructor_binding_context` | Type | 1 |
| `definition.go_unaliased_import_group_binding_context` | Type | 1 |
| `definition.method_name` | Callable | 1 |
| `definition.method_receiver` | Callable | 1 |
| `label.label_definition` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 4 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.assignment_dec` | reference | 1 |
| `binding.assignment_inc` | reference | 1 |
| `binding.assignment_left` | reference | 1 |
| `binding.assignment_right` | reference | 1 |
| `binding.binding_const` | reference | 1 |
| `binding.binding_parameter` | reference | 1 |
| `binding.binding_range` | reference | 1 |
| `binding.binding_range_left` | reference | 1 |
| `binding.binding_receive` | reference | 1 |
| `binding.binding_short` | reference | 1 |
| `binding.binding_short_left` | reference | 1 |
| `binding.binding_var` | reference | 1 |
| `binding.binding_variadic_parameter` | reference | 1 |
| `binding.short_declaration` | reference | 1 |
| `binding.short_left` | reference | 1 |
| `binding.short_right` | reference | 1 |
| `call.call_arguments` | call | 1 |
| `call.call_selector` | call | 1 |
| `call.call_selector_field` | call | 1 |
| `call.call_selector_operand` | call | 1 |
| `call.call_target` | call | 1 |
| `call.go_builder_qualified_resource_context` | call | 1 |
| `call.go_imported_constructor_qualified_resource_context` | call | 1 |
| `call.go_method_builder_qualified_resource_context` | call | 1 |
| `call.go_receiver_identifier_argument_context` | call | 1 |
| `call.go_receiver_method_chain_string_argument_context` | call | 1 |
| `call.go_receiver_string_identifier_context` | call | 1 |
| `call.parenthesized_function_call` | call | 1 |
| `call.parenthesized_method_call` | call | 1 |
| `data.data_comment` | reference | 1 |
| `data.data_composite` | reference | 1 |
| `data.data_false` | reference | 1 |
| `data.data_float` | reference | 1 |
| `data.data_imaginary` | reference | 1 |
| `data.data_int` | reference | 1 |
| `data.data_iota` | reference | 1 |
| `data.data_keyed_element` | reference | 1 |
| `data.data_literal_value` | reference | 1 |
| `data.data_nil` | reference | 1 |
| `data.data_raw_string` | reference | 1 |
| `data.data_rune` | reference | 1 |
| `data.data_string` | reference | 1 |
| `data.data_true` | reference | 1 |
| `data.expression_binary` | reference | 1 |
| `data.expression_composite_literal` | reference | 1 |
| `data.expression_func_literal` | reference | 1 |
| `data.expression_index` | reference | 1 |
| `data.expression_slice` | reference | 1 |
| `data.expression_type_conversion` | reference | 1 |
| `data.expression_type_instantiation` | reference | 1 |
| `data.expression_unary` | reference | 1 |
| `lexical.lex_comment` | reference | 1 |
| `lexical.lex_false` | reference | 1 |
| `lexical.lex_float` | reference | 1 |
| `lexical.lex_imaginary` | reference | 1 |
| `lexical.lex_int` | reference | 1 |
| `lexical.lex_iota` | reference | 1 |
| `lexical.lex_nil` | reference | 1 |
| `lexical.lex_raw_string` | reference | 1 |
| `lexical.lex_rune` | reference | 1 |
| `lexical.lex_string` | reference | 1 |
| `lexical.lex_true` | reference | 1 |
| `declaration.decl_const_group` | reference | 1 |
| `declaration.decl_const_spec` | reference | 1 |
| `declaration.decl_type_alias` | reference | 1 |
| `declaration.decl_type_group` | reference | 1 |
| `declaration.decl_type_spec` | reference | 1 |
| `declaration.decl_var_group` | reference | 1 |
| `declaration.decl_var_spec` | reference | 1 |
| `label.label_break` | reference | 1 |
| `label.label_continue` | reference | 1 |
| `label.label_goto` | reference | 1 |
| `signature.signature_function_type` | reference | 1 |
| `signature.signature_parameter` | reference | 1 |
| `signature.signature_parameters` | reference | 1 |
| `signature.signature_variadic_parameter` | reference | 1 |
| `import.go_explicit_alias_context` | binding | 1 |
| `module.import_alias` | binding | 1 |
| `module.import_declaration` | binding | 1 |
| `module.import_named` | binding | 1 |
| `module.import_path` | binding | 1 |
| `module.import_spec` | binding | 1 |
| `module.module_import` | binding | 1 |
| `module.module_import_path` | binding | 1 |
| `module.module_package` | reference | 1 |
| `module.module_package_name` | reference | 1 |
| `module.package_clause` | reference | 1 |
| `module.package_const` | reference | 1 |
| `module.package_function` | reference | 1 |
| `module.package_function_name` | reference | 1 |
| `module.package_name` | reference | 1 |
| `module.package_var` | reference | 1 |
| `reference.assignment` | reference | 1 |
| `reference.call` | call | 1 |
| `reference.method` | reference | 1 |
| `reference.reference_field` | reference | 1 |
| `reference.reference_identifier` | reference | 1 |
| `reference.reference_index` | reference | 1 |
| `reference.reference_package` | reference | 1 |
| `reference.reference_selector` | reference | 1 |
| `reference.reference_slice` | reference | 1 |
| `reference.reference_type` | reference | 1 |
| `reference.reference_type_assertion` | reference | 1 |
| `reference.selector` | reference | 1 |
| `reference.selector_field` | reference | 1 |
| `reference.selector_operand` | reference | 1 |
| `control.concurrency_go` | reference | 1 |
| `control.concurrency_receive` | reference | 1 |
| `control.concurrency_send` | reference | 1 |
| `control.control_break` | reference | 1 |
| `control.control_continue` | reference | 1 |
| `control.control_defer` | reference | 1 |
| `control.control_fallthrough` | reference | 1 |
| `control.control_for` | reference | 1 |
| `control.control_goto` | reference | 1 |
| `control.control_if` | reference | 1 |
| `control.control_label` | reference | 1 |
| `control.control_range` | reference | 1 |
| `control.control_return` | reference | 1 |
| `control.control_select` | reference | 1 |
| `control.control_switch` | reference | 1 |
| `control.control_type_switch` | reference | 1 |
| `control.switch_communication_case` | reference | 1 |
| `control.switch_default_case` | reference | 1 |
| `control.switch_expression_case` | reference | 1 |
| `control.switch_type_case` | reference | 1 |
| `reference.scope_block` | reference | 1 |
| `reference.scope_file` | reference | 1 |
| `reference.scope_for` | reference | 1 |
| `reference.scope_function` | reference | 1 |
| `reference.scope_function_literal` | reference | 1 |
| `reference.scope_if` | reference | 1 |
| `reference.scope_method` | reference | 1 |
| `reference.scope_select` | reference | 1 |
| `reference.scope_switch` | reference | 1 |
| `reference.scope_type_switch` | reference | 1 |
| `test.test_function` | reference | 1 |
| `test.test_function_name` | reference | 1 |
| `channel.channel_case` | reference | 1 |
| `channel.channel_receive` | reference | 1 |
| `channel.channel_select` | reference | 1 |
| `channel.channel_send` | reference | 1 |
| `channel.channel_type` | reference | 1 |
| `collection.collection_array_type` | reference | 1 |
| `collection.collection_composite` | reference | 1 |
| `collection.collection_implicit_array_type` | reference | 1 |
| `collection.collection_index` | reference | 1 |
| `collection.collection_keyed_element` | reference | 1 |
| `collection.collection_map_type` | reference | 1 |
| `collection.collection_slice_expression` | reference | 1 |
| `collection.collection_slice_type` | reference | 1 |
| `type.generic_arguments` | reference | 1 |
| `type.generic_parameter` | reference | 1 |
| `type.generic_parameter_constraint` | reference | 1 |
| `type.generic_parameter_name` | reference | 1 |
| `type.generic_parameters` | reference | 1 |
| `type.generic_type` | reference | 1 |
| `type.interface_method` | reference | 1 |
| `type.interface_negated_term` | reference | 1 |
| `type.interface_type` | reference | 1 |
| `type.interface_type_element` | reference | 1 |
| `type.type_arguments` | reference | 1 |
| `type.type_array` | reference | 1 |
| `type.type_channel` | reference | 1 |
| `type.type_constraint_elem` | reference | 1 |
| `type.type_function` | reference | 1 |
| `type.type_generic` | reference | 1 |
| `type.type_implicit_array` | reference | 1 |
| `type.type_interface` | reference | 1 |
| `type.type_map` | reference | 1 |
| `type.type_negated_constraint` | reference | 1 |
| `type.type_parameter` | reference | 1 |
| `type.type_parameters` | reference | 1 |
| `type.type_pointer` | reference | 1 |
| `type.type_qualified` | reference | 1 |
| `type.type_slice` | reference | 1 |
| `type.type_struct` | reference | 1 |
| `type_operation.typeop_assertion` | reference | 1 |
| `type_operation.typeop_conversion` | reference | 1 |
| `type_operation.typeop_instantiation` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 111 node types. The Pack looks at 93 of them.

Untouched:

- `_expression`
- `_simple_statement`
- `_simple_type`
- `_statement`
- `_type`
- `blank_identifier`
- `dot`
- `empty_statement`
- `escape_sequence`
- `expression_statement`
- `for_clause`
- `import_spec_list`
- `label_name`
- `parenthesized_type`
- `raw_string_literal_content`
- `type_constraint`
- `var_spec_list`
- `variadic_argument`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
