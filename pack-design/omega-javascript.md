# omega-javascript

Language `omega-javascript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

205 templates over 226 query patterns, 80 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 25 |
| `calls` | yes | 22 |
| `data` | yes | 51 |
| `definitions` | yes | 31 |
| `imports` | yes | 13 |
| `modules` | yes | 3 |
| `references` | yes | 47 |
| `scopes` | yes | 10 |
| `tests` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.generator_function` | Callable | 1 |
| `definition.generator_function_expression` | Callable | 1 |
| `definition.arrow_function` | Callable | 2 |
| `definition.class` | Type | 2 |
| `definition.class_expression` | Type | 1 |
| `definition.documented_class` | Type | 1 |
| `definition.documented_function` | Callable | 1 |
| `definition.documented_function_binding` | Callable | 1 |
| `definition.documented_generator` | Value | 1 |
| `definition.documented_method` | Callable | 1 |
| `definition.ecmascript_exported_function_context` | Callable | 1 |
| `definition.ecmascript_exported_variable_context` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 2 |
| `definition.function_expression` | Callable | 1 |
| `definition.generator_function` | Callable | 2 |
| `definition.generator_function_expression` | Callable | 1 |
| `definition.javascript_arrow_jsx_component_context` | Value | 1 |
| `definition.method` | Callable | 2 |
| `definition.object_method` | Callable | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `control.for_await_candidate` | `omega.pack.for_await` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `module.export_alias_candidate` | `omega.pack.export_alias` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.javascript_declaration_candidate` | `omega.pack.javascript_declaration` | 1 |

### Regions

- `scope.arrow_function` (1)
- `scope.block` (1)
- `scope.catch` (1)
- `scope.class` (1)
- `scope.class_static_block` (1)
- `scope.file` (1)
- `scope.function` (1)
- `scope.generator_function` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.catch_destructuring` | reference | 1 |
| `binding.catch_parameter` | reference | 1 |
| `binding.destructuring` | reference | 1 |
| `binding.import_alias` | binding | 1 |
| `binding.imported` | binding | 4 |
| `binding.namespace_import` | binding | 1 |
| `binding.parameter` | reference | 1 |
| `binding.shorthand_property_pattern` | reference | 1 |
| `binding.variable` | reference | 1 |
| `pattern.array` | reference | 1 |
| `pattern.assignment_default` | reference | 1 |
| `pattern.object` | reference | 1 |
| `pattern.object_assignment_default` | reference | 1 |
| `pattern.pair` | reference | 1 |
| `pattern.rest` | reference | 1 |
| `value_origin.top_level_const_alias` | reference | 1 |
| `value_origin.top_level_const_false` | reference | 1 |
| `value_origin.top_level_const_null` | reference | 1 |
| `value_origin.top_level_const_number` | reference | 1 |
| `value_origin.top_level_const_string` | reference | 1 |
| `value_origin.top_level_const_true` | reference | 1 |
| `call.call` | call | 1 |
| `call.constructor` | call | 1 |
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
| `control.await` | reference | 1 |
| `control.yield` | reference | 1 |
| `reference.ecmascript_root_member_call_context` | call | 1 |
| `data.ecmascript_assignment_export_nested_object_array_object_field_context` | binding | 1 |
| `data.ecmascript_assignment_export_nested_object_string_context` | binding | 1 |
| `data.ecmascript_assignment_export_object_array_new_context` | binding | 1 |
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
| `relation.jsx_expression` | reference | 1 |
| `structure.jsx_closing_element` | reference | 1 |
| `structure.jsx_opening_element` | reference | 1 |
| `value.array` | reference | 2 |
| `value.javascript_jsx_string_attribute_context` | reference | 1 |
| `value.jsx_attribute` | reference | 1 |
| `value.jsx_element` | reference | 1 |
| `value.jsx_self_closing_element` | reference | 1 |
| `value.object` | reference | 2 |
| `value.pair` | reference | 1 |
| `value.property_pair` | reference | 1 |
| `annotation.decorator` | reference | 1 |
| `relation.extends` | reference | 1 |
| `import.commonjs_require` | binding | 1 |
| `import.dynamic_import` | binding | 1 |
| `import.ecmascript_commonjs_binding_context` | binding | 1 |
| `import.ecmascript_commonjs_named_binding_context` | binding | 1 |
| `import.ecmascript_default_binding_context` | binding | 1 |
| `import.ecmascript_named_binding_context` | binding | 1 |
| `import.ecmascript_namespace_binding_context` | binding | 1 |
| `import.esm` | binding | 1 |
| `import.named` | binding | 1 |
| `module_relation.export` | binding | 1 |
| `module_relation.import` | binding | 1 |
| `reference.assignment_lhs` | reference | 1 |
| `reference.assignment_rhs` | reference | 1 |
| `reference.await_value` | reference | 1 |
| `reference.binary_operand` | reference | 1 |
| `reference.call_argument` | call | 1 |
| `reference.callee` | call | 1 |
| `reference.computed_property_expression` | reference | 1 |
| `reference.computed_property_name` | reference | 1 |
| `reference.condition` | reference | 1 |
| `reference.conditional_value` | reference | 1 |
| `reference.constructor` | reference | 1 |
| `reference.decorator_expression` | reference | 1 |
| `reference.default_value` | reference | 1 |
| `reference.ecmascript_class_extends_identifier_context` | reference | 1 |
| `reference.ecmascript_class_extends_member_context` | reference | 1 |
| `reference.ecmascript_root_member_context` | reference | 1 |
| `reference.export_selector` | binding | 1 |
| `reference.identifier` | reference | 1 |
| `reference.import_alias_target` | binding | 1 |
| `reference.import_selector` | binding | 1 |
| `reference.index_key` | reference | 1 |
| `reference.index_receiver` | reference | 1 |
| `reference.initializer` | reference | 1 |
| `reference.javascript_arrow_return_jsx_component_context` | reference | 1 |
| `reference.javascript_function_return_jsx_component_context` | reference | 1 |
| `reference.javascript_jsx_identifier_attribute_context` | reference | 1 |
| `reference.javascript_jsx_member_tag` | reference | 1 |
| `reference.jsx_expression` | reference | 1 |
| `reference.jsx_namespace` | reference | 1 |
| `reference.member` | reference | 1 |
| `reference.member_name` | reference | 1 |
| `reference.member_receiver` | reference | 1 |
| `reference.private_property` | reference | 2 |
| `reference.property` | reference | 1 |
| `reference.receiver` | reference | 1 |
| `reference.return_value` | reference | 1 |
| `reference.shorthand_property` | reference | 2 |
| `reference.spread_value` | reference | 1 |
| `reference.template_expression` | reference | 1 |
| `reference.throw_value` | reference | 1 |
| `reference.unary_operand` | reference | 1 |
| `reference.update_operand` | reference | 1 |
| `reference.yield_value` | reference | 1 |
| `test.test_call` | call | 1 |
| `test.test_member_call` | call | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (2)
- `literal.html_character_reference` (1)
- `literal.jsx_text` (1)
- `literal.null` (2)
- `literal.number` (2)
- `literal.regex` (2)
- `literal.string` (2)
- `literal.template` (2)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 118 node types. The Pack looks at 87 of them.

Untouched:

- `break_statement`
- `continue_statement`
- `debugger_statement`
- `declaration`
- `else_clause`
- `empty_statement`
- `escape_sequence`
- `export_clause`
- `expression`
- `finally_clause`
- `hash_bang_line`
- `html_comment`
- `import_attribute`
- `labeled_statement`
- `meta_property`
- `namespace_export`
- `optional_chain`
- `parenthesized_expression`
- `primary_expression`
- `regex_flags`
- `regex_pattern`
- `sequence_expression`
- `statement`
- `statement_identifier`
- `switch_body`
- `switch_case`
- `switch_default`
- `switch_statement`
- `try_statement`
- `undefined`
- `with_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
