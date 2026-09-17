# omega-c

Language `omega-c`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

206 templates over 113 query patterns, 81 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 12 |
| `calls` | yes | 14 |
| `data` | yes | 78 |
| `definitions` | yes | 49 |
| `imports` | yes | 13 |
| `modules` | yes | 3 |
| `references` | yes | 8 |
| `scopes` | yes | 7 |
| `tests` | yes | 3 |
| `types` | yes | 19 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.c_definition_label` | Value | 1 |
| `definition.c_definition_label_name` | Value | 1 |
| `definition.c_definition_enum` | Type | 1 |
| `definition.c_definition_enum_name` | Type | 1 |
| `definition.c_definition_enumerator` | Type | 1 |
| `definition.c_definition_enumerator_name` | Type | 1 |
| `definition.c_definition_enumerator_value` | Type | 1 |
| `definition.c_definition_field` | Value | 1 |
| `definition.c_definition_field_name` | Value | 1 |
| `definition.c_definition_function` | Callable | 1 |
| `definition.c_definition_function_name` | Callable | 1 |
| `definition.c_definition_label` | Value | 1 |
| `definition.c_definition_struct` | Type | 1 |
| `definition.c_definition_struct_name` | Type | 1 |
| `definition.c_definition_typedef` | Type | 1 |
| `definition.c_definition_typedef_name` | Type | 1 |
| `definition.c_definition_union` | Value | 1 |
| `definition.c_definition_union_name` | Value | 1 |
| `definition.c_function_context` | Callable | 1 |
| `definition.parenthesized_declarator` | Value | 1 |
| `function.c_function_definition` | Callable | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `embedded_region.embedded_language_candidate` | `omega.pack.embedded_language` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 5 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 2 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.c_scope_block` (1)
- `scope.c_scope_file` (1)
- `scope.c_scope_for` (1)
- `scope.c_scope_function` (1)
- `scope.c_scope_function_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.c_binding_initialized` | reference | 1 |
| `binding.c_binding_initializer` | reference | 1 |
| `binding.c_binding_name` | reference | 1 |
| `binding.preprocessor_parameters` | reference | 1 |
| `init.c_init` | reference | 1 |
| `init.c_init_aggregate` | reference | 1 |
| `init.c_init_compound` | reference | 1 |
| `init.c_init_compound_type` | reference | 1 |
| `init.c_init_compound_value` | reference | 1 |
| `init.c_init_target` | reference | 1 |
| `init.c_init_value` | reference | 1 |
| `parameter.c_parameter_variadic` | reference | 1 |
| `call.c_call` | call | 1 |
| `call.c_call_arguments` | call | 1 |
| `call.c_call_direct` | call | 1 |
| `call.c_call_direct_name` | call | 1 |
| `call.c_call_indirect` | call | 1 |
| `call.c_call_indirect_target` | call | 1 |
| `call.c_call_member` | call | 1 |
| `call.c_call_member_target` | call | 1 |
| `call.c_call_pointer` | call | 1 |
| `call.c_call_pointer_target` | call | 1 |
| `call.c_call_target` | call | 1 |
| `call.c_owned_direct_context` | call | 1 |
| `reference.c_direct_call_site_context` | call | 1 |
| `comment.c_comment` | reference | 1 |
| `concurrency.c_concurrency_call` | call | 1 |
| `concurrency.c_concurrency_call_name` | call | 1 |
| `concurrency.c_concurrency_qualifier` | reference | 1 |
| `control.c_control_break` | reference | 1 |
| `control.c_control_case` | reference | 1 |
| `control.c_control_case_value` | reference | 1 |
| `control.c_control_continue` | reference | 1 |
| `control.c_control_do` | reference | 1 |
| `control.c_control_do_condition` | reference | 1 |
| `control.c_control_for` | reference | 1 |
| `control.c_control_goto` | reference | 1 |
| `control.c_control_goto_label` | reference | 1 |
| `control.c_control_if` | reference | 1 |
| `control.c_control_if_condition` | reference | 1 |
| `control.c_control_return` | reference | 1 |
| `control.c_control_return_value` | reference | 1 |
| `control.c_control_switch` | reference | 1 |
| `control.c_control_switch_condition` | reference | 1 |
| `control.c_control_while` | reference | 1 |
| `control.c_control_while_condition` | reference | 1 |
| `data.attribute_declaration` | reference | 1 |
| `data.c_data_init` | reference | 1 |
| `data.c_data_init_target` | reference | 1 |
| `data.c_data_init_value` | reference | 1 |
| `data.c_data_return` | reference | 1 |
| `data.c_data_return_value` | reference | 1 |
| `data.c_data_write` | reference | 1 |
| `data.c_data_write_target` | reference | 1 |
| `data.c_data_write_value` | reference | 1 |
| `data.c_expr_assign` | reference | 1 |
| `data.c_expr_assign_left` | reference | 1 |
| `data.c_expr_assign_operator` | reference | 1 |
| `data.c_expr_assign_right` | reference | 1 |
| `data.c_expr_binary` | reference | 1 |
| `data.c_expr_binary_left` | reference | 1 |
| `data.c_expr_binary_operator` | reference | 1 |
| `data.c_expr_binary_right` | reference | 1 |
| `data.c_expr_comma` | reference | 1 |
| `data.c_expr_comma_left` | reference | 1 |
| `data.c_expr_comma_right` | reference | 1 |
| `data.c_expr_conditional` | reference | 1 |
| `data.c_expr_conditional_condition` | reference | 1 |
| `data.c_expr_conditional_false` | reference | 1 |
| `data.c_expr_conditional_true` | reference | 1 |
| `data.c_expr_unary` | reference | 1 |
| `data.c_expr_unary_argument` | reference | 1 |
| `data.c_expr_unary_operator` | reference | 1 |
| `data.c_expr_update` | reference | 1 |
| `data.c_expr_update_argument` | reference | 1 |
| `data.c_expr_update_operator` | reference | 1 |
| `data.escape_sequence` | reference | 1 |
| `data.false_literal` | reference | 1 |
| `data.gnu_asm_qualifier` | reference | 1 |
| `data.null_literal` | reference | 1 |
| `data.preprocessor_call` | call | 1 |
| `data.preprocessor_defined` | reference | 1 |
| `data.preprocessor_directive` | reference | 1 |
| `data.preprocessor_elifdef` | reference | 1 |
| `data.true_literal` | reference | 1 |
| `extension.c_extension_attribute` | reference | 1 |
| `extension.c_extension_gnu_asm` | reference | 1 |
| `init.c_init_designated` | reference | 1 |
| `init.c_init_designated_value` | reference | 1 |
| `init.c_init_designator` | reference | 1 |
| `operator.c_operator_alignof` | reference | 1 |
| `operator.c_operator_cast` | reference | 1 |
| `operator.c_operator_cast_type` | reference | 1 |
| `operator.c_operator_cast_value` | reference | 1 |
| `operator.c_operator_sizeof` | reference | 1 |
| `syntax.c_syntax_error` | reference | 1 |
| `aggregate.c_aggregate_enum` | reference | 1 |
| `aggregate.c_aggregate_enum_body` | reference | 1 |
| `aggregate.c_aggregate_enum_name` | reference | 1 |
| `aggregate.c_aggregate_struct` | reference | 1 |
| `aggregate.c_aggregate_struct_body` | reference | 1 |
| `aggregate.c_aggregate_struct_name` | reference | 1 |
| `aggregate.c_aggregate_union` | reference | 1 |
| `aggregate.c_aggregate_union_body` | reference | 1 |
| `aggregate.c_aggregate_union_name` | reference | 1 |
| `declaration.c_declaration` | reference | 1 |
| `declaration.c_declaration_declarator` | reference | 1 |
| `declaration.c_declaration_type` | reference | 1 |
| `function.c_function_body` | reference | 1 |
| `function.c_function_declarator` | reference | 1 |
| `function.c_function_return_type` | reference | 1 |
| `linkage.c_linkage_attribute` | reference | 1 |
| `linkage.c_linkage_storage` | reference | 1 |
| `parameter.c_parameter` | reference | 1 |
| `parameter.c_parameter_name` | reference | 1 |
| `parameter.c_parameter_type` | reference | 1 |
| `import.system_include_token` | binding | 1 |
| `relation.c_preproc_condition` | reference | 1 |
| `relation.c_preproc_condition_symbol` | reference | 1 |
| `relation.c_preproc_conditional` | reference | 1 |
| `relation.c_preproc_conditional_symbol` | reference | 1 |
| `relation.c_preproc_function_macro` | reference | 1 |
| `relation.c_preproc_function_macro_name` | reference | 1 |
| `relation.c_preproc_include` | reference | 1 |
| `relation.c_preproc_include_path` | reference | 1 |
| `relation.c_preproc_macro` | reference | 1 |
| `relation.c_preproc_macro_name` | reference | 1 |
| `module.c_module_include` | reference | 1 |
| `module.c_module_include_path` | reference | 1 |
| `module.linkage_specification` | reference | 1 |
| `reference.c_reference_base` | reference | 1 |
| `reference.c_reference_identifier` | reference | 1 |
| `reference.c_reference_index_base` | reference | 1 |
| `reference.c_reference_index_expression` | reference | 1 |
| `reference.c_reference_label` | reference | 1 |
| `reference.c_reference_member` | reference | 1 |
| `reference.field_designator` | reference | 1 |
| `test.c_test_call` | call | 1 |
| `test.c_test_call_name` | call | 1 |
| `test.c_test_include` | reference | 1 |
| `generic.c_generic_selection` | reference | 1 |
| `modifier.c_modifier_attribute` | reference | 1 |
| `modifier.c_modifier_storage` | reference | 1 |
| `modifier.c_modifier_type_qualifier` | reference | 1 |
| `type.c_type_array` | reference | 1 |
| `type.c_type_array_size` | reference | 1 |
| `type.c_type_array_target` | reference | 1 |
| `type.c_type_function` | reference | 1 |
| `type.c_type_function_name` | reference | 1 |
| `type.c_type_function_parameters` | reference | 1 |
| `type.c_type_function_pointer` | reference | 1 |
| `type.c_type_named` | reference | 1 |
| `type.c_type_numeric` | reference | 1 |
| `type.c_type_pointer` | reference | 1 |
| `type.c_type_pointer_target` | reference | 1 |
| `type.c_type_primitive` | reference | 1 |
| `type.ms_pointer_modifier` | reference | 1 |
| `type.sized_type_specifier` | reference | 1 |
| `type.type_descriptor` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.c_literal_char` (1)
- `literal.c_literal_concatenated_string` (1)
- `literal.c_literal_number` (1)
- `literal.c_literal_string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 132 node types. The Pack looks at 90 of them.

Untouched:

- `_abstract_declarator`
- `_declarator`
- `_field_declarator`
- `_type_declarator`
- `abstract_array_declarator`
- `abstract_function_declarator`
- `abstract_parenthesized_declarator`
- `abstract_pointer_declarator`
- `alignas_qualifier`
- `attribute`
- `attributed_declarator`
- `attributed_statement`
- `bitfield_clause`
- `character`
- `declaration_list`
- `else_clause`
- `expression`
- `extension_expression`
- `gnu_asm_clobber_list`
- `gnu_asm_goto_list`
- `gnu_asm_input_operand`
- `gnu_asm_input_operand_list`
- `gnu_asm_output_operand`
- `gnu_asm_output_operand_list`
- `ms_based_modifier`
- `ms_call_modifier`
- `ms_declspec_modifier`
- `ms_restrict_modifier`
- `ms_signed_ptr_modifier`
- `ms_unaligned_ptr_modifier`
- `ms_unsigned_ptr_modifier`
- `offsetof_expression`
- `preproc_elif`
- `preproc_else`
- `seh_except_clause`
- `seh_finally_clause`
- `seh_leave_statement`
- `seh_try_statement`
- `statement`
- `subscript_designator`
- `subscript_range_designator`
- `type_specifier`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
