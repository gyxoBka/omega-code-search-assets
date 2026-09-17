# omega-c-sharp

Language `omega-c-sharp`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

101 templates over 118 query patterns, 44 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 8 |
| `calls` | yes | 10 |
| `data` | yes | 7 |
| `definitions` | yes | 45 |
| `imports` | yes | 6 |
| `modules` | yes | 2 |
| `references` | yes | 17 |
| `scopes` | yes | 5 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.c-sharp_class` | Type | 1 |
| `definition.c-sharp_interface` | Value | 1 |
| `definition.c-sharp_method` | Callable | 2 |
| `definition.c-sharp_module` | Value | 1 |
| `definition.c-sharp_symbol` | Value | 1 |
| `definition.c-sharp_type` | Type | 1 |
| `definition.class` | Type | 2 |
| `definition.csharp_attributed_method_context` | Callable | 1 |
| `definition.csharp_attributed_method_route_context` | Callable | 1 |
| `definition.csharp_attributed_property_adjacent_named_sibling_context` | Value | 1 |
| `definition.csharp_attributed_property_context` | Value | 1 |
| `definition.csharp_class_base_context` | Type | 1 |
| `definition.csharp_class_property_context` | Type | 1 |
| `definition.csharp_lifecycle_method_context` | Callable | 1 |
| `definition.event` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.interface` | Value | 2 |
| `definition.method` | Callable | 3 |
| `definition.module` | Value | 2 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 12 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `relation.inherits_or_implements_candidate` | `omega.pack.inherits_or_implements` | 1 |
| `module.c_sharp_candidate` | `omega.pack.c_sharp` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `reference.c-sharp_identifier_candidate` | `omega.pack.c-sharp_identifier` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.c_sharp_declaration_candidate` | `omega.pack.c_sharp_declaration` | 1 |

### Regions

- `scope.c-sharp_lexical_scope` (1)
- `scope.lexical` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.c-sharp_parameter` | reference | 1 |
| `binding.c-sharp_variable` | reference | 1 |
| `binding.local` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `call.c-sharp_send` | call | 1 |
| `call.csharp_class_member_string_context` | call | 1 |
| `call.csharp_class_nested_member_string_context` | call | 1 |
| `call.csharp_global_member_string_context` | call | 1 |
| `call.csharp_global_nested_member_string_context` | call | 1 |
| `call.csharp_minimal_api_route_context` | call | 1 |
| `call.csharp_service_registration_generic_context` | call | 1 |
| `call.csharp_service_registration_typeof_context` | call | 1 |
| `module_relation.c-sharp_module` | reference | 1 |
| `import.csharp_alias_source_binding_context` | binding | 1 |
| `import.csharp_source_context` | binding | 1 |
| `import.using_directive` | binding | 1 |
| `reference.c-sharp_class` | reference | 1 |
| `reference.c-sharp_interface` | reference | 1 |
| `reference.class` | reference | 2 |
| `reference.csharp_attributed_class_string_context` | reference | 1 |
| `reference.csharp_attributed_field_context` | reference | 1 |
| `reference.csharp_constructor_parameter_context` | reference | 1 |
| `reference.interface` | reference | 2 |
| `reference.local` | reference | 2 |
| `reference.send` | reference | 2 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (1)
- `literal.null` (1)
- `literal.number` (2)
- `literal.string` (3)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 224 node types. The Pack looks at 64 of them.

Untouched:

- `accessor_list`
- `and_pattern`
- `anonymous_object_creation_expression`
- `array_creation_expression`
- `array_rank_specifier`
- `array_type`
- `arrow_expression_clause`
- `as_expression`
- `assignment_expression`
- `attribute_target_specifier`
- `binary_expression`
- `bracketed_argument_list`
- `bracketed_parameter_list`
- `break_statement`
- `calling_convention`
- `cast_expression`
- `catch_clause`
- `catch_declaration`
- `catch_filter_clause`
- `character_literal`
- `character_literal_content`
- `checked_expression`
- `checked_statement`
- `collection_element`
- `collection_expression`
- `comment`
- `compilation_unit`
- `conditional_access_expression`
- `conditional_expression`
- `constant_pattern`
- `constructor_constraint`
- `constructor_initializer`
- `continue_statement`
- `conversion_operator_declaration`
- `declaration`
- `declaration_pattern`
- `default_expression`
- `discard`
- `do_statement`
- `element_access_expression`
- `element_binding_expression`
- `empty_statement`
- `escape_sequence`
- `explicit_interface_specifier`
- `expression`
- `expression_element`
- `extern_alias_directive`
- `finally_clause`
- `fixed_statement`
- `for_statement`
- `from_clause`
- `function_pointer_parameter`
- `function_pointer_type`
- `global_attribute`
- `global_statement`
- `goto_statement`
- `group_clause`
- `if_statement`
- `implicit_array_creation_expression`
- `implicit_object_creation_expression`
- `implicit_parameter`
- `implicit_stackalloc_expression`
- `implicit_type`
- `indexer_declaration`
- `initializer_expression`
- `interpolated_string_expression`
- `interpolation`
- `interpolation_alignment_clause`
- `interpolation_brace`
- `interpolation_format_clause`
- `interpolation_quote`
- `interpolation_start`
- `is_expression`
- `is_pattern_expression`
- `join_clause`
- `join_into_clause`
- `labeled_statement`
- `let_clause`
- `list_pattern`
- `literal`
- `local_declaration_statement`
- `lock_statement`
- `lvalue_expression`
- `makeref_expression`
- `member_binding_expression`
- `negated_pattern`
- `non_lvalue_expression`
- `nullable_type`
- `or_pattern`
- `order_by_clause`
- `parenthesized_expression`
- `parenthesized_pattern`
- `parenthesized_variable_designation`
- `pattern`
- `pointer_type`
- `positional_pattern_clause`
- `postfix_unary_expression`
- `predefined_type`
- `prefix_unary_expression`
- `preproc_arg`
- `preproc_define`
- `preproc_elif`
- `preproc_else`
- `preproc_endregion`
- `preproc_error`
- `preproc_if`
- `preproc_if_in_attribute_list`
- `preproc_line`
- `preproc_nullable`
- `preproc_pragma`
- `preproc_region`
- `preproc_undef`
- `preproc_warning`
- `primary_constructor_base_type`
- `property_pattern_clause`
- `query_expression`
- `range_expression`
- `raw_string_content`
- `raw_string_end`
- `raw_string_start`
- `recursive_pattern`
- `ref_expression`
- `ref_type`
- `reftype_expression`
- `refvalue_expression`
- `relational_pattern`
- `return_statement`
- `scoped_type`
- `select_clause`
- `shebang_directive`
- `sizeof_expression`
- `spread_element`
- `stackalloc_expression`
- `statement`
- `string_content`
- `string_literal_encoding`
- `subpattern`
- `switch_body`
- `switch_expression`
- `switch_expression_arm`
- `switch_section`
- `switch_statement`
- `throw_expression`
- `throw_statement`
- `try_statement`
- `tuple_element`
- `tuple_expression`
- `tuple_type`
- `type_parameter_list`
- `type_pattern`
- `unary_expression`
- `unsafe_statement`
- `using_statement`
- `var_pattern`
- `when_clause`
- `where_clause`
- `while_statement`
- `with_expression`
- `with_initializer`
- `yield_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
