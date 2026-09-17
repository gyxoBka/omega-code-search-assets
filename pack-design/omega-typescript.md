# omega-typescript

Language `omega-typescript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

208 templates over 281 query patterns, 94 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 23 |
| `calls` | yes | 20 |
| `data` | yes | 29 |
| `definitions` | yes | 46 |
| `imports` | yes | 17 |
| `modules` | yes | 4 |
| `references` | yes | 19 |
| `scopes` | yes | 6 |
| `tests` | yes | 1 |
| `types` | yes | 43 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.ecmascript_imported_constructor_binding_context` | Type | 1 |
| `definition.abstract_class` | Type | 1 |
| `definition.abstract_method_signature` | Callable | 1 |
| `definition.ambient_declaration` | Value | 1 |
| `definition.call_signature` | Value | 1 |
| `definition.class` | Type | 1 |
| `definition.construct_signature` | Type | 1 |
| `definition.ecmascript_exported_function_context` | Callable | 1 |
| `definition.ecmascript_exported_variable_context` | Value | 1 |
| `definition.enum` | Type | 2 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.function_signature` | Callable | 1 |
| `definition.import_alias` | Type | 1 |
| `definition.index_signature` | Value | 1 |
| `definition.interface` | Value | 2 |
| `definition.method` | Callable | 1 |
| `definition.method_signature` | Callable | 1 |
| `definition.module` | Value | 1 |
| `definition.namespace` | Value | 1 |
| `definition.property_signature` | Value | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 9 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 4 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `module.export_alias_candidate` | `omega.pack.export_alias` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.block` (1)
- `scope.class` (1)
- `scope.function` (1)
- `scope.interface` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.destructuring` | reference | 1 |
| `binding.imported` | binding | 4 |
| `binding.optional_parameter` | reference | 1 |
| `binding.optional_parameter_destructuring` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.parameter_destructuring` | reference | 1 |
| `binding.required_parameter` | reference | 1 |
| `binding.variable` | reference | 1 |
| `pattern.array` | reference | 1 |
| `pattern.assignment` | reference | 1 |
| `pattern.object` | reference | 1 |
| `pattern.rest` | reference | 1 |
| `value_origin.top_level_const_alias` | reference | 1 |
| `value_origin.top_level_const_false` | reference | 1 |
| `value_origin.top_level_const_null` | reference | 1 |
| `value_origin.top_level_const_number` | reference | 1 |
| `value_origin.top_level_const_string` | reference | 1 |
| `value_origin.top_level_const_true` | reference | 1 |
| `call.constructor` | call | 1 |
| `call.direct` | call | 1 |
| `call.ecmascript_constructor_identifier_context` | call | 1 |
| `call.ecmascript_constructor_member_context` | call | 1 |
| `call.ecmascript_direct_context` | call | 1 |
| `call.ecmascript_direct_dependency_array_identifier_context` | call | 1 |
| `call.ecmascript_direct_identifier_argument_context` | call | 1 |
| `call.ecmascript_direct_string_argument_context` | call | 1 |
| `call.ecmascript_member_identifier_context` | call | 1 |
| `call.ecmascript_member_owned_member_call_context` | call | 1 |
| `call.ecmascript_member_owned_string_call_context` | call | 1 |
| `call.ecmascript_member_string_identifier_context` | call | 1 |
| `call.ecmascript_nested_member_string_identifier_context` | call | 1 |
| `call.ecmascript_owned_call_context` | call | 1 |
| `call.ecmascript_owned_string_call_context` | call | 1 |
| `call.ecmascript_variable_object_fluent_chain_context` | call | 1 |
| `call.generic_instantiation` | call | 1 |
| `call.member` | call | 1 |
| `reference.ecmascript_root_member_call_context` | call | 1 |
| `data.array` | reference | 1 |
| `data.boolean` | reference | 1 |
| `data.ecmascript_assignment_export_nested_object_array_object_field_context` | binding | 1 |
| `data.ecmascript_assignment_export_nested_object_string_context` | binding | 1 |
| `data.ecmascript_assignment_export_object_array_new_raw_context` | binding | 1 |
| `data.ecmascript_assignment_export_object_string_context` | binding | 1 |
| `data.ecmascript_assignment_export_three_level_object_string_context` | binding | 1 |
| `data.ecmascript_call_nested_object_identifier_context` | call | 1 |
| `data.ecmascript_call_nested_object_string_context` | call | 1 |
| `data.ecmascript_call_object_array_direct_call_context` | call | 1 |
| `data.ecmascript_call_object_array_direct_call_raw_context` | call | 1 |
| `data.ecmascript_call_object_array_object_string_identifier_context` | call | 1 |
| `data.ecmascript_call_object_string_array_item_context` | call | 1 |
| `data.ecmascript_call_object_string_field_context` | call | 1 |
| `data.ecmascript_call_three_level_object_string_context` | call | 1 |
| `data.ecmascript_direct_array_identifier_item_context` | reference | 1 |
| `data.ecmascript_direct_array_string_item_context` | reference | 1 |
| `data.ecmascript_export_object_field_context` | binding | 1 |
| `data.ecmascript_export_object_identifier_field_context` | binding | 1 |
| `data.ecmascript_export_object_shorthand_context` | binding | 1 |
| `data.ecmascript_exported_object_field_context` | binding | 1 |
| `data.ecmascript_function_directive_context` | reference | 1 |
| `data.ecmascript_module_directive_context` | reference | 1 |
| `data.ecmascript_root_member_object_identifier_context` | reference | 1 |
| `data.ecmascript_root_member_string_argument_context` | reference | 1 |
| `data.null` | reference | 1 |
| `data.number` | reference | 1 |
| `data.object` | reference | 1 |
| `data.string` | reference | 1 |
| `relation.extends` | reference | 1 |
| `relation.implements` | implements | 1 |
| `import.alias` | binding | 1 |
| `import.ecmascript_commonjs_binding_context` | binding | 1 |
| `import.ecmascript_commonjs_named_binding_context` | binding | 1 |
| `import.ecmascript_default_binding_context` | binding | 1 |
| `import.ecmascript_named_binding_context` | binding | 1 |
| `import.ecmascript_namespace_binding_context` | binding | 1 |
| `import.import_equals_require` | binding | 1 |
| `import.require` | binding | 1 |
| `import.statement` | binding | 1 |
| `module_relation.ambient` | reference | 1 |
| `module_relation.export` | binding | 1 |
| `module_relation.external_module` | reference | 1 |
| `module_relation.namespace` | reference | 1 |
| `module.ambient` | reference | 1 |
| `module.export` | binding | 1 |
| `module.namespace` | reference | 1 |
| `reference.decorator` | reference | 2 |
| `reference.ecmascript_class_extends_identifier_context` | reference | 1 |
| `reference.ecmascript_class_extends_member_context` | reference | 1 |
| `reference.ecmascript_root_member_context` | reference | 1 |
| `reference.identifier` | reference | 1 |
| `reference.type_identifier` | reference | 1 |
| `reference.typescript_class_decorator_object_array_identifier_context` | reference | 1 |
| `reference.typescript_class_decorator_object_array_string_context` | reference | 1 |
| `reference.typescript_class_decorator_object_string_field_context` | reference | 1 |
| `reference.typescript_class_member_decorator_context` | reference | 1 |
| `reference.typescript_class_member_marker_decorator_context` | reference | 1 |
| `reference.typescript_constructor_parameter_decorator_context` | reference | 1 |
| `reference.typescript_constructor_parameter_type_context` | reference | 1 |
| `reference.typescript_method_parameter_decorator_context` | reference | 1 |
| `reference.typescript_method_parameter_marker_decorator_context` | reference | 1 |
| `test.declaration` | reference | 1 |
| `control.await` | reference | 1 |
| `control.yield` | reference | 1 |
| `relation.assignment` | reference | 1 |
| `relation.augmented_assignment` | reference | 1 |
| `type.alias` | reference | 1 |
| `type.annotation` | reference | 1 |
| `type.arguments` | reference | 1 |
| `type.conditional` | reference | 1 |
| `type.interface` | reference | 1 |
| `type.parameters` | reference | 1 |
| `type.syntax` | reference | 26 |
| `type_arguments.list` | reference | 1 |
| `type_parameter.declaration` | reference | 1 |
| `type_parameters.list` | reference | 1 |
| `type_relation.as` | reference | 1 |
| `type_relation.assertion` | reference | 1 |
| `type_relation.non_null` | reference | 1 |
| `type_relation.satisfies` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 183 node types. The Pack looks at 114 of them.

Untouched:

- `adding_type_annotation`
- `asserts_annotation`
- `binary_expression`
- `break_statement`
- `catch_clause`
- `class_static_block`
- `comment`
- `computed_property_name`
- `continue_statement`
- `debugger_statement`
- `declaration`
- `do_statement`
- `else_clause`
- `empty_statement`
- `escape_sequence`
- `existential_type`
- `export_clause`
- `expression`
- `extends_type_clause`
- `finally_clause`
- `flow_maybe_type`
- `for_in_statement`
- `for_statement`
- `hash_bang_line`
- `html_comment`
- `if_statement`
- `import`
- `import_attribute`
- `labeled_statement`
- `meta_property`
- `namespace_export`
- `nested_identifier`
- `object_assignment_pattern`
- `omitting_type_annotation`
- `opting_type_annotation`
- `optional_chain`
- `optional_type`
- `parenthesized_expression`
- `parenthesized_type`
- `pattern`
- `primary_expression`
- `primary_type`
- `regex`
- `regex_flags`
- `regex_pattern`
- `rest_type`
- `return_statement`
- `sequence_expression`
- `spread_element`
- `statement`
- `statement_identifier`
- `subscript_expression`
- `switch_body`
- `switch_case`
- `switch_default`
- `switch_statement`
- `template_string`
- `template_substitution`
- `template_type`
- `ternary_expression`
- `throw_statement`
- `try_statement`
- `type`
- `type_predicate_annotation`
- `unary_expression`
- `undefined`
- `update_expression`
- `while_statement`
- `with_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
