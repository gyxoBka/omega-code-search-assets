# omega-razor

Language `omega-razor`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

54 templates over 91 query patterns, 45 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 2 |
| `data` | yes | 5 |
| `definitions` | yes | 23 |
| `imports` | yes | 3 |
| `modules` | yes | 3 |
| `references` | yes | 8 |
| `scopes` | yes | 3 |
| `types` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.razor_section` | Value | 1 |
| `definition.razor_type_parameter` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.razor_candidate` | `omega.pack.razor` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 13 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.razor_declaration_candidate` | `omega.pack.razor_declaration` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.razor_candidate` | `omega.pack.razor` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.razor_declaration_candidate` | `omega.pack.razor_declaration` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.razor_inject` | reference | 1 |
| `binding.razor_inject_typed` | reference | 1 |
| `binding.symbol` | reference | 1 |
| `data.razor_attribute_directive` | reference | 1 |
| `data.razor_layout` | reference | 1 |
| `data.razor_page_route` | reference | 1 |
| `data.razor_preservewhitespace` | reference | 1 |
| `data.razor_rendermode` | reference | 1 |
| `import.razor_using` | binding | 1 |
| `import.razor_using_alias` | binding | 1 |
| `import.razor_using_target` | binding | 1 |
| `module.razor_namespace` | reference | 1 |
| `reference.razor_literal_href_context` | reference | 1 |
| `reference.razor_model_type` | reference | 1 |
| `reference.razor_named_attribute_expression_context` | reference | 1 |
| `reference.razor_named_attribute_identifier_context` | reference | 1 |
| `reference.symbol` | reference | 1 |
| `type_relation.razor_implements` | reference | 1 |
| `type_relation.razor_inherits` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 262 node types. The Pack looks at 61 of them.

Untouched:

- `accessor_list`
- `and_pattern`
- `anonymous_method_expression`
- `anonymous_object_creation_expression`
- `argument`
- `argument_list`
- `array_creation_expression`
- `array_rank_specifier`
- `array_type`
- `arrow_expression_clause`
- `as_expression`
- `attribute`
- `attribute_argument`
- `attribute_argument_list`
- `attribute_target_specifier`
- `base_list`
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
- `comment`
- `compilation_unit`
- `conditional_access_expression`
- `constant_pattern`
- `constructor_constraint`
- `constructor_initializer`
- `continue_statement`
- `conversion_operator_declaration`
- `declaration`
- `declaration_expression`
- `declaration_list`
- `declaration_pattern`
- `default_expression`
- `discard`
- `do_statement`
- `element`
- `element_binding_expression`
- `empty_statement`
- `escape_sequence`
- `event_field_declaration`
- `explicit_interface_specifier`
- `explicit_line_transition`
- `expression`
- `expression_statement`
- `extern_alias_directive`
- `field_declaration`
- `finally_clause`
- `fixed_statement`
- `for_statement`
- `foreach_statement`
- `from_clause`
- `function_pointer_parameter`
- `function_pointer_type`
- `generic_name`
- `global_attribute`
- `goto_statement`
- `group_clause`
- `html_comment`
- `if_statement`
- `implicit_array_creation_expression`
- `implicit_object_creation_expression`
- `implicit_stackalloc_expression`
- `implicit_type`
- `indexer_declaration`
- `initializer_expression`
- `integer_literal`
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
- `null_literal`
- `nullable_type`
- `operator_declaration`
- `or_pattern`
- `order_by_clause`
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
- `raw_string_literal`
- `raw_string_start`
- `razor_attribute_modifier`
- `razor_await_expression`
- `razor_case_condition`
- `razor_catch`
- `razor_comment`
- `razor_compound_using`
- `razor_condition`
- `razor_do_while`
- `razor_else`
- `razor_else_if`
- `razor_escape`
- `razor_explicit_expression`
- `razor_finally`
- `razor_for`
- `razor_foreach`
- `razor_if`
- `razor_implicit_expression`
- `razor_lock`
- `razor_switch`
- `razor_switch_case`
- `razor_switch_default`
- `razor_try`
- `razor_while`
- `real_literal`
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
- `tuple_pattern`
- `tuple_type`
- `type_argument_list`
- `type_parameter_constraint`
- `type_parameter_constraints_clause`
- `type_parameter_list`
- `type_pattern`
- `typeof_expression`
- `unary_expression`
- `unsafe_statement`
- `using_directive`
- `using_statement`
- `var_pattern`
- `verbatim_string_literal`
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
