# omega-java

Language `omega-java`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

226 templates over 233 query patterns, 130 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 12 |
| `calls` | yes | 10 |
| `data` | yes | 25 |
| `definitions` | yes | 74 |
| `imports` | yes | 4 |
| `modules` | yes | 7 |
| `references` | yes | 32 |
| `scopes` | yes | 39 |
| `tests` | yes | 4 |
| `types` | yes | 19 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.java_annotated_class_context` | Type | 1 |
| `definition.java_annotated_class_hierarchy_context` | Type | 1 |
| `definition.java_annotated_class_string_argument_context` | Type | 1 |
| `definition.java_attributed_method_context` | Callable | 1 |
| `definition.java_package_annotated_class_direct_string_context` | Type | 1 |
| `definition.java_package_annotated_method_context` | Callable | 1 |
| `definition.java_package_annotated_method_direct_string_context` | Callable | 1 |
| `definition.java_package_annotated_method_named_string_context` | Callable | 1 |
| `definitions.definition_annotation_type` | Type | 1 |
| `definitions.definition_annotation_type_name` | Type | 1 |
| `definitions.definition_class` | Type | 1 |
| `definitions.definition_class_name` | Type | 1 |
| `definitions.definition_compact_constructor` | Type | 1 |
| `definitions.definition_compact_constructor_name` | Type | 1 |
| `definitions.definition_constant` | Value | 1 |
| `definitions.definition_constructor` | Type | 1 |
| `definitions.definition_constructor_name` | Type | 1 |
| `definitions.definition_enum` | Type | 1 |
| `definitions.definition_enum_name` | Type | 1 |
| `definitions.definition_field` | Value | 1 |
| `definitions.definition_interface` | Value | 1 |
| `definitions.definition_interface_name` | Value | 1 |
| `definitions.definition_method` | Callable | 1 |
| `definitions.definition_method_name` | Callable | 1 |
| `definitions.definition_record` | Value | 1 |
| `definitions.definition_record_name` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 9 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 8 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.qualified_name_candidate` | `omega.pack.qualified_name` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.module` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `field_data.data_array` | reference | 1 |
| `field_data.data_field` | reference | 1 |
| `field_data.data_local` | reference | 1 |
| `field_data.data_variable` | reference | 1 |
| `parameters_bindings.binding_catch` | reference | 1 |
| `parameters_bindings.binding_local` | reference | 1 |
| `parameters_bindings.binding_parameter` | reference | 1 |
| `parameters_bindings.binding_parameters` | reference | 1 |
| `parameters_bindings.binding_receiver` | reference | 1 |
| `parameters_bindings.binding_spread` | reference | 1 |
| `parameters_bindings.binding_variable` | reference | 1 |
| `calls.call_arguments` | call | 1 |
| `calls.call_constructor` | call | 1 |
| `calls.call_method` | call | 1 |
| `calls.call_method_reference` | call | 1 |
| `objects_arrays.array_access` | reference | 1 |
| `objects_arrays.array_creation` | reference | 1 |
| `objects_arrays.array_initializer` | reference | 1 |
| `objects_arrays.class_literal` | reference | 1 |
| `objects_arrays.object_creation` | reference | 1 |
| `comments.comment_block` | reference | 1 |
| `comments.comment_line` | reference | 1 |
| `data.java_annotation_argument_value` | reference | 8 |
| `literals.literal_binary_int` | reference | 1 |
| `literals.literal_char` | reference | 1 |
| `literals.literal_decimal_float` | reference | 1 |
| `literals.literal_decimal_int` | reference | 1 |
| `literals.literal_false` | reference | 1 |
| `literals.literal_hex_float` | reference | 1 |
| `literals.literal_hex_int` | reference | 1 |
| `literals.literal_null` | reference | 1 |
| `literals.literal_octal_int` | reference | 1 |
| `literals.literal_string` | reference | 1 |
| `literals.literal_true` | reference | 1 |
| `string_templates.string_escape` | reference | 1 |
| `string_templates.string_interpolation` | reference | 1 |
| `string_templates.string_literal` | reference | 1 |
| `string_templates.string_template_expression` | reference | 1 |
| `annotations.annotation_arguments` | reference | 1 |
| `annotations.annotation_element_pair` | reference | 1 |
| `annotations.annotation_marker` | reference | 1 |
| `annotations.annotation_normal` | reference | 1 |
| `annotations.annotation_type` | reference | 1 |
| `annotations.annotation_type_element` | reference | 1 |
| `classes_inheritance.class_declaration` | reference | 1 |
| `classes_inheritance.class_permits` | reference | 1 |
| `classes_inheritance.class_super_interfaces` | reference | 1 |
| `classes_inheritance.class_superclass` | reference | 1 |
| `classes_inheritance.interface_declaration` | reference | 1 |
| `classes_inheritance.interface_extends` | reference | 1 |
| `constructors_initializers.constructor_compact` | reference | 1 |
| `constructors_initializers.constructor_declaration` | reference | 1 |
| `constructors_initializers.constructor_explicit_invocation` | reference | 1 |
| `constructors_initializers.initializer_static` | reference | 1 |
| `lambdas.lambda_expression` | reference | 1 |
| `lambdas.lambda_inferred_parameters` | reference | 1 |
| `lambdas.lambda_method_reference` | reference | 1 |
| `modifiers.modifier_list` | reference | 1 |
| `records_enums.enum_constant` | reference | 1 |
| `records_enums.enum_declaration` | reference | 1 |
| `records_enums.record_declaration` | reference | 1 |
| `records_enums.record_pattern` | reference | 1 |
| `records_enums.record_pattern_component` | reference | 1 |
| `packages_imports.import_declaration` | binding | 1 |
| `packages_imports.name_scoped` | binding | 1 |
| `packages_imports.package_declaration` | binding | 1 |
| `modules.module_declaration` | reference | 1 |
| `modules.module_exports` | binding | 1 |
| `modules.module_opens` | reference | 1 |
| `modules.module_provides` | reference | 1 |
| `modules.module_requires` | reference | 1 |
| `modules.module_uses` | reference | 1 |
| `expressions.expression_assignment` | reference | 1 |
| `expressions.expression_binary` | reference | 1 |
| `expressions.expression_cast` | reference | 1 |
| `expressions.expression_instanceof` | reference | 1 |
| `expressions.expression_parenthesized` | reference | 1 |
| `expressions.expression_ternary` | reference | 1 |
| `expressions.expression_unary` | reference | 1 |
| `expressions.expression_update` | reference | 1 |
| `reference.constructor_type` | reference | 1 |
| `reference.implementation_type` | reference | 1 |
| `reference.java_package_annotated_field_import_bound_type_context` | binding | 1 |
| `reference.java_package_class_direct_string_annotation_context` | reference | 1 |
| `reference.java_package_class_named_string_annotation_context` | reference | 1 |
| `reference.java_package_constructor_parameter_import_bound_type_context` | binding | 1 |
| `reference.java_package_interface_import_bound_generic_supertype_context` | binding | 1 |
| `reference.java_package_method_direct_string_annotation_context` | reference | 1 |
| `reference.java_package_method_marker_annotation_context` | reference | 1 |
| `reference.java_package_method_named_string_annotation_context` | reference | 1 |
| `reference.superclass_type` | reference | 1 |
| `references.reference_array_access` | reference | 1 |
| `references.reference_field_access` | reference | 1 |
| `references.reference_identifier` | reference | 1 |
| `references.reference_method_invocation` | reference | 1 |
| `references.reference_method_reference` | reference | 1 |
| `references.reference_scoped_identifier` | reference | 1 |
| `references.reference_scoped_type` | reference | 1 |
| `references.reference_super` | reference | 1 |
| `references.reference_this` | reference | 1 |
| `exceptions.exception_catch` | reference | 1 |
| `exceptions.exception_finally` | reference | 1 |
| `exceptions.exception_resource` | reference | 1 |
| `exceptions.exception_resources` | reference | 1 |
| `exceptions.exception_throw` | reference | 1 |
| `exceptions.exception_throws` | reference | 1 |
| `exceptions.exception_try` | reference | 1 |
| `exceptions.exception_try_resources` | reference | 1 |
| `scopes.scope_annotation_type` | reference | 1 |
| `scopes.scope_block` | reference | 1 |
| `scopes.scope_class` | reference | 1 |
| `scopes.scope_constructor` | reference | 1 |
| `scopes.scope_enum` | reference | 1 |
| `scopes.scope_interface` | reference | 1 |
| `scopes.scope_lambda` | reference | 1 |
| `scopes.scope_program` | reference | 1 |
| `switch_patterns.pattern_generic` | reference | 1 |
| `switch_patterns.pattern_guard` | reference | 1 |
| `switch_patterns.pattern_record` | reference | 1 |
| `switch_patterns.pattern_type` | reference | 1 |
| `switch_patterns.switch_block` | reference | 1 |
| `switch_patterns.switch_expression` | reference | 1 |
| `switch_patterns.switch_label` | reference | 1 |
| `switch_patterns.switch_rule` | reference | 1 |
| `switch_patterns.switch_yield` | reference | 1 |
| `synchronization.sync_statement` | reference | 1 |
| `tests.test_annotation` | reference | 1 |
| `tests.test_marker_annotation` | reference | 1 |
| `tests.test_method` | reference | 1 |
| `tests.test_method_name` | reference | 1 |
| `generics.generic_arguments` | reference | 1 |
| `generics.generic_bound` | reference | 1 |
| `generics.generic_parameter` | reference | 1 |
| `generics.generic_parameters` | reference | 1 |
| `generics.generic_type` | reference | 1 |
| `generics.generic_wildcard` | reference | 1 |
| `preview_boundaries.preview_guard` | reference | 1 |
| `preview_boundaries.preview_record_pattern` | reference | 1 |
| `preview_boundaries.preview_template_expression` | reference | 1 |
| `preview_boundaries.preview_underscore_pattern` | reference | 1 |
| `types.type_annotated` | reference | 1 |
| `types.type_array` | reference | 1 |
| `types.type_boolean` | reference | 1 |
| `types.type_catch` | reference | 1 |
| `types.type_floating` | reference | 1 |
| `types.type_generic` | reference | 1 |
| `types.type_integral` | reference | 1 |
| `types.type_scoped` | reference | 1 |
| `types.type_void` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `control_flow.control_assert` (1)
- `control_flow.control_break` (1)
- `control_flow.control_continue` (1)
- `control_flow.control_do` (1)
- `control_flow.control_enhanced_for` (1)
- `control_flow.control_for` (1)
- `control_flow.control_if` (1)
- `control_flow.control_label` (1)
- `control_flow.control_return` (1)
- `control_flow.control_while` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 151 node types. The Pack looks at 133 of them.

Untouched:

- `_literal`
- `_simple_type`
- `_type`
- `_unannotated_type`
- `asterisk`
- `declaration`
- `dimensions`
- `dimensions_expr`
- `enum_body_declarations`
- `expression`
- `expression_statement`
- `module_directive`
- `multiline_string_fragment`
- `primary_expression`
- `record_pattern_body`
- `requires_modifier`
- `statement`
- `switch_block_statement_group`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
