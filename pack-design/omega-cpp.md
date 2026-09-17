# omega-cpp

Language `omega-cpp`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

101 templates over 128 query patterns, 50 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 7 |
| `calls` | yes | 8 |
| `data` | yes | 4 |
| `definitions` | yes | 51 |
| `imports` | yes | 5 |
| `modules` | yes | 2 |
| `references` | yes | 18 |
| `scopes` | yes | 5 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.constant` | Value | 2 |
| `definition.cpp_class` | Type | 1 |
| `definition.cpp_concept` | Value | 1 |
| `definition.cpp_conversion_operator` | Value | 1 |
| `definition.cpp_destructor` | Type | 1 |
| `definition.cpp_field` | Value | 1 |
| `definition.cpp_function` | Callable | 2 |
| `definition.cpp_method` | Callable | 2 |
| `definition.cpp_namespace` | Value | 1 |
| `definition.cpp_operator` | Value | 1 |
| `definition.cpp_symbol` | Value | 2 |
| `definition.cpp_type` | Type | 2 |
| `definition.enum` | Type | 2 |
| `definition.function` | Callable | 3 |
| `definition.interface` | Value | 2 |
| `definition.macro` | Value | 1 |
| `definition.method` | Callable | 1 |
| `definition.module` | Value | 2 |
| `definition.namespace` | Value | 1 |
| `definition.struct` | Type | 2 |
| `definition.type` | Type | 4 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.call_candidate` | `omega.pack.call` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `relation.inherits_candidate` | `omega.pack.inherits` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 9 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 2 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `module.cpp_candidate` | `omega.pack.cpp` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `reference.cpp_identifier_candidate` | `omega.pack.cpp_identifier` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.cpp_declaration_candidate` | `omega.pack.cpp_declaration` | 1 |

### Regions

- `scope.cpp_lexical_scope` (1)
- `scope.lexical` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.cpp_parameter` | reference | 1 |
| `binding.cpp_variable` | reference | 1 |
| `binding.field` | reference | 1 |
| `binding.local` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `call.cpp_identifier_string_arguments_context` | call | 1 |
| `call.cpp_string_literal_argument_context` | call | 1 |
| `call.cpp_two_identifier_arguments_context` | call | 1 |
| `reference.cpp_direct_call_site_context` | call | 1 |
| `reference.cpp_member_call_site_context` | call | 1 |
| `data.cpp_lambda` | reference | 1 |
| `data.cpp_requires_clause` | reference | 1 |
| `data.cpp_requires_expression` | reference | 1 |
| `data.cpp_template_declaration` | reference | 1 |
| `import.module_import` | binding | 1 |
| `import.preprocessor_include` | binding | 1 |
| `reference.cpp_adjacent_macro_argument_context` | reference | 5 |
| `reference.cpp_adjacent_macro_member_context` | reference | 2 |
| `reference.cpp_adjacent_macro_type_context` | reference | 3 |
| `reference.cpp_template_instantiation` | reference | 1 |
| `reference.local` | reference | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 230 node types. The Pack looks at 74 of them.

Untouched:

- `_abstract_declarator`
- `_declarator`
- `_field_declarator`
- `_type_declarator`
- `abstract_array_declarator`
- `abstract_function_declarator`
- `abstract_parenthesized_declarator`
- `abstract_pointer_declarator`
- `abstract_reference_declarator`
- `access_specifier`
- `alignas_qualifier`
- `alignof_expression`
- `annotation`
- `assignment_expression`
- `attribute_declaration`
- `attribute_specifier`
- `attributed_declarator`
- `attributed_statement`
- `auto`
- `binary_expression`
- `bitfield_clause`
- `break_statement`
- `case_statement`
- `cast_expression`
- `char_literal`
- `character`
- `co_await_expression`
- `co_return_statement`
- `co_yield_statement`
- `comma_expression`
- `comment`
- `compound_literal_expression`
- `compound_requirement`
- `concatenated_string`
- `condition_clause`
- `conditional_expression`
- `consteval_block_declaration`
- `constraint_conjunction`
- `constraint_disjunction`
- `continue_statement`
- `decltype`
- `default_method_clause`
- `delete_expression`
- `delete_method_clause`
- `dependent_name`
- `dependent_type`
- `do_statement`
- `else_clause`
- `escape_sequence`
- `expansion_statement`
- `explicit_function_specifier`
- `explicit_object_parameter_declaration`
- `expression`
- `extension_expression`
- `false`
- `field_designator`
- `field_initializer`
- `field_initializer_list`
- `fold_expression`
- `friend_declaration`
- `generic_expression`
- `global_module_fragment_declaration`
- `gnu_asm_clobber_list`
- `gnu_asm_expression`
- `gnu_asm_goto_list`
- `gnu_asm_input_operand`
- `gnu_asm_input_operand_list`
- `gnu_asm_output_operand`
- `gnu_asm_output_operand_list`
- `gnu_asm_qualifier`
- `init_statement`
- `initializer_list`
- `initializer_pair`
- `lambda_capture_initializer`
- `lambda_default_capture`
- `lambda_specifier`
- `linkage_specification`
- `literal_suffix`
- `module_name`
- `module_partition`
- `ms_based_modifier`
- `ms_call_modifier`
- `ms_declspec_modifier`
- `ms_pointer_modifier`
- `ms_restrict_modifier`
- `ms_signed_ptr_modifier`
- `ms_unaligned_ptr_modifier`
- `ms_unsigned_ptr_modifier`
- `new_declarator`
- `new_expression`
- `noexcept`
- `null`
- `number_literal`
- `offsetof_expression`
- `parameter_pack_expansion`
- `parenthesized_declarator`
- `parenthesized_expression`
- `placeholder_type_specifier`
- `pointer_expression`
- `pointer_type_declarator`
- `preproc_arg`
- `preproc_call`
- `preproc_defined`
- `preproc_directive`
- `preproc_elif`
- `preproc_elifdef`
- `preproc_else`
- `preproc_if`
- `preproc_ifdef`
- `preproc_params`
- `primitive_type`
- `private_module_fragment_declaration`
- `pure_virtual_clause`
- `raw_string_content`
- `raw_string_delimiter`
- `raw_string_literal`
- `ref_qualifier`
- `reflect_expression`
- `return_statement`
- `seh_except_clause`
- `seh_finally_clause`
- `seh_leave_statement`
- `seh_try_statement`
- `simple_requirement`
- `sized_type_specifier`
- `sizeof_expression`
- `splice_expression`
- `splice_specifier`
- `splice_type_specifier`
- `statement`
- `static_assert_declaration`
- `storage_class_specifier`
- `structured_binding_declarator`
- `subscript_argument_list`
- `subscript_designator`
- `subscript_expression`
- `subscript_range_designator`
- `switch_statement`
- `system_lib_string`
- `template_argument_list`
- `template_template_parameter_declaration`
- `template_type`
- `throw_specifier`
- `throw_statement`
- `trailing_return_type`
- `true`
- `type_descriptor`
- `type_qualifier`
- `type_requirement`
- `type_specifier`
- `unary_expression`
- `update_expression`
- `user_defined_literal`
- `using_declaration`
- `variadic_type_parameter_declaration`
- `virtual_specifier`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
