# omega-rust

Language `omega-rust`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

341 templates over 386 query patterns, 133 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 13 |
| `calls` | yes | 26 |
| `config_consumers` | yes | 4 |
| `data` | yes | 51 |
| `definitions` | yes | 60 |
| `implements` | yes | 5 |
| `imports` | yes | 10 |
| `modules` | yes | 1 |
| `references` | yes | 79 |
| `scopes` | yes | 27 |
| `tests` | yes | 2 |
| `types` | yes | 54 |
| `value_origins` | yes | 9 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.rust_scoped_constructor_binding_context` | Type | 1 |
| `definition.associated_type` | Type | 1 |
| `definition.const` | Value | 1 |
| `definition.const_parameter` | Value | 1 |
| `definition.control_label` | Value | 1 |
| `definition.enum` | Type | 1 |
| `definition.enum_variant` | Type | 1 |
| `definition.field` | Value | 1 |
| `definition.function_like` | Callable | 1 |
| `definition.lifetime_parameter` | Value | 1 |
| `definition.macro_rules` | Value | 1 |
| `definition.module` | Value | 1 |
| `definition.rust_fq_router_binding_context` | Value | 2 |
| `definition.signature_like` | Value | 1 |
| `definition.static` | Value | 1 |
| `definition.struct` | Type | 1 |
| `definition.trait` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.type_parameter` | Type | 1 |
| `definition.union` | Value | 1 |
| `definition_group.tuple_fields` | Value | 1 |
| `macro_metavariable_candidate.definition_or_use` | Value | 1 |
| `definition_context.enum_variant_body` | Type | 1 |
| `test.function` | Test | 1 |
| `type_expression.function` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.operator_assignment_candidate` | `omega.pack.operator_assignment` | 1 |
| `call.operator_binary_candidate` | `omega.pack.operator_binary` | 1 |
| `call.operator_index_candidate` | `omega.pack.operator_index` | 1 |
| `call.operator_try_candidate` | `omega.pack.operator_try` | 1 |
| `call.operator_unary_candidate` | `omega.pack.operator_unary` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `embedded_region.embedded_language_candidate` | `omega.pack.embedded_language` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 10 |
| `definition.container_name_candidate` | `omega.pack.container_name` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 2 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_self_candidate` | `omega.pack.return_self` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.return_type_head_candidate` | `omega.pack.return_type_head` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.path_origin_candidate` | `omega.pack.path_origin` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.block` (1)
- `scope.closure` (1)
- `scope.file` (1)
- `scope.macro_definition` (1)
- `scope.match_arm` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.captured_pattern_binding` | reference | 1 |
| `binding.field_shorthand_binding` | reference | 1 |
| `binding.macro_metavariable` | reference | 1 |
| `binding.receiver_parameter` | reference | 1 |
| `binding_pattern.conditional_binding` | reference | 1 |
| `binding_pattern.for_binding` | reference | 1 |
| `binding_pattern.local` | reference | 1 |
| `binding_pattern.match_binding` | reference | 1 |
| `binding_pattern.parameter` | reference | 1 |
| `binding_pattern.variadic_parameter` | reference | 1 |
| `binding_pattern_group.closure_parameter` | reference | 1 |
| `call.direct` | call | 1 |
| `call.dynamic_expression` | call | 1 |
| `call.generic_direct` | call | 1 |
| `call.generic_method` | call | 1 |
| `call.generic_scoped` | call | 1 |
| `call.macro` | call | 1 |
| `call.macro_scoped` | call | 1 |
| `call.method` | call | 1 |
| `call.rust_fq_router_nest_context` | call | 1 |
| `call.rust_fq_router_route_context` | call | 1 |
| `call.rust_receiver_identifier_context` | call | 1 |
| `call.rust_receiver_noarg_context` | call | 1 |
| `call.rust_receiver_route_nested_call_context` | call | 1 |
| `call.rust_receiver_string_identifier_context` | call | 1 |
| `call.scoped` | call | 1 |
| `call.self_method` | call | 1 |
| `call.self_scoped` | call | 1 |
| `call.type_scoped` | call | 1 |
| `reference.rust_three_segment_scoped_call_context` | call | 1 |
| `reference.rust_two_segment_scoped_call_context` | call | 1 |
| `config_consumer.compile_time_macro` | reference | 1 |
| `config_consumer.inner_attribute` | reference | 1 |
| `config_consumer.outer_attribute` | reference | 1 |
| `config_consumer_candidate.runtime_api` | reference | 1 |
| `attribute.inner` | reference | 1 |
| `attribute.outer` | reference | 1 |
| `attribute_path.scoped_path` | reference | 1 |
| `attribute_path.simple_path` | reference | 1 |
| `attribute_payload.arguments` | reference | 1 |
| `attribute_payload.value` | reference | 1 |
| `data.escape_sequence` | reference | 1 |
| `data.inner_doc_marker` | reference | 1 |
| `data.outer_doc_marker` | reference | 1 |
| `documentation_context.inner_doc` | reference | 1 |
| `documentation_context.outer_doc` | reference | 1 |
| `expression.async_block` | reference | 1 |
| `expression.binary` | reference | 1 |
| `expression.cast` | reference | 1 |
| `expression.closure` | reference | 1 |
| `expression.const_block` | reference | 1 |
| `expression.field_access` | reference | 1 |
| `expression.gen_block` | reference | 1 |
| `expression.index` | reference | 1 |
| `expression.parenthesized` | reference | 1 |
| `expression.range` | reference | 1 |
| `expression.reference` | reference | 1 |
| `expression.try_block` | reference | 1 |
| `expression.unary` | reference | 1 |
| `expression.unsafe_block` | reference | 1 |
| `relation.argument` | reference | 1 |
| `relation.assignment` | reference | 1 |
| `relation.compound_assignment` | reference | 1 |
| `relation.initializer` | reference | 1 |
| `relation.return` | reference | 1 |
| `relation.yield` | reference | 1 |
| `value.array` | reference | 1 |
| `value.field_initializer` | reference | 1 |
| `value.shorthand_field` | reference | 1 |
| `value.struct_constructor` | reference | 1 |
| `value.struct_update_base` | reference | 1 |
| `value.tuple` | reference | 1 |
| `value.unit` | reference | 1 |
| `value_flow.assignment` | reference | 1 |
| `value_flow.compound_assignment` | reference | 1 |
| `value_origin.const_initializer` | reference | 1 |
| `value_origin.let_initializer` | reference | 1 |
| `value_origin.static_initializer` | reference | 1 |
| `comment.block` | reference | 1 |
| `comment.line` | reference | 1 |
| `documentation.block_doc` | reference | 1 |
| `documentation.line_doc` | reference | 1 |
| `macro_rule.macro_rule` | reference | 1 |
| `macro_syntax.repetition` | reference | 1 |
| `macro_syntax.repetition_pattern` | reference | 1 |
| `macro_syntax.token_tree` | reference | 1 |
| `macro_syntax.token_tree_pattern` | reference | 1 |
| `reference_context.loop_label_reference` | reference | 1 |
| `relation.enum_discriminant` | reference | 1 |
| `relation.enum_variant` | reference | 1 |
| `relation.struct_field` | reference | 1 |
| `relation.union_field` | reference | 1 |
| `source_metadata.shebang` | reference | 1 |
| `visibility.rust_visibility` | reference | 1 |
| `implementation.rust_qualified_trait_for_context` | reference | 1 |
| `relation.env` | reference | 1 |
| `relation.explicit_trait_impl` | reference | 1 |
| `relation.return` | reference | 1 |
| `relation_candidate.direct_call_from_function` | call | 1 |
| `import.extern_crate` | binding | 1 |
| `import.glob` | binding | 1 |
| `import.use` | binding | 1 |
| `import_alias.extern_crate_alias` | binding | 1 |
| `import_alias.use_alias` | binding | 1 |
| `import_group.use_group` | binding | 1 |
| `module_scope.inline_module` | reference | 1 |
| `reference.module_or_type_path` | reference | 1 |
| `reference.module_or_value_path` | reference | 1 |
| `reference.rust_derive_trait_context` | reference | 1 |
| `reference.rust_function_scoped_attribute_context` | reference | 1 |
| `reference.rust_function_scoped_macro_literal_context` | reference | 1 |
| `reference.rust_function_scoped_string_attribute_context` | reference | 1 |
| `reference.rust_function_string_attribute_context` | reference | 1 |
| `reference.rust_import_bound_foreign_function_attribute_context` | binding | 1 |
| `reference.rust_import_bound_function_attribute_context` | binding | 1 |
| `reference.rust_macro_first_identifier_context` | reference | 1 |
| `reference.rust_macro_two_identifier_nested_identifier_context` | reference | 1 |
| `reference.rust_struct_derive_trait_context` | reference | 1 |
| `reference.rust_struct_field_string_attribute_context` | reference | 1 |
| `reference.rust_struct_named_attribute_identifier_assignment_context` | reference | 1 |
| `reference.rust_struct_named_attribute_nested_identifier_context` | reference | 1 |
| `reference_candidate.crate` | reference | 1 |
| `reference_candidate.field` | reference | 2 |
| `reference_candidate.lifetime` | reference | 1 |
| `reference_candidate.path` | reference | 1 |
| `reference_candidate.self` | reference | 1 |
| `reference_candidate.super` | reference | 1 |
| `reference_candidate.type` | reference | 1 |
| `reference_candidate.type_path` | reference | 1 |
| `reference_candidate.value` | reference | 1 |
| `reference_context.array_element` | reference | 1 |
| `reference_context.array_repeat_length` | reference | 1 |
| `reference_context.assignment_lhs` | reference | 1 |
| `reference_context.assignment_rhs` | reference | 1 |
| `reference_context.attribute_path` | reference | 1 |
| `reference_context.await_operand` | reference | 1 |
| `reference_context.binary_operand` | reference | 1 |
| `reference_context.borrowed_value` | reference | 1 |
| `reference_context.break_target_or_value` | reference | 1 |
| `reference_context.call_argument` | call | 1 |
| `reference_context.callee` | call | 1 |
| `reference_context.cast_value` | reference | 1 |
| `reference_context.condition` | reference | 1 |
| `reference_context.condition_value` | reference | 1 |
| `reference_context.const_generic_argument` | reference | 1 |
| `reference_context.const_parameter_value` | reference | 1 |
| `reference_context.field_shorthand_value` | reference | 1 |
| `reference_context.field_type_position` | reference | 1 |
| `reference_context.generic_argument_list` | reference | 1 |
| `reference_context.generic_base_type` | reference | 1 |
| `reference_context.generic_callable` | call | 1 |
| `reference_context.import_selector` | binding | 1 |
| `reference_context.initializer` | reference | 1 |
| `reference_context.iterator_value` | reference | 1 |
| `reference_context.lifetime_bound` | reference | 1 |
| `reference_context.lifetime_reference` | reference | 1 |
| `reference_context.macro_metavariable_use` | reference | 1 |
| `reference_context.macro_path` | reference | 1 |
| `reference_context.match_arm_value` | reference | 1 |
| `reference_context.match_guard_condition` | reference | 1 |
| `reference_context.match_scrutinee` | reference | 1 |
| `reference_context.member` | reference | 1 |
| `reference_context.parenthesized_value` | reference | 1 |
| `reference_context.pattern_position` | reference | 1 |
| `reference_context.range_bound` | reference | 1 |
| `reference_context.receiver` | reference | 1 |
| `reference_context.return_type_position` | reference | 1 |
| `reference_context.return_value` | reference | 1 |
| `reference_context.struct_constructor_type` | reference | 1 |
| `reference_context.struct_field_value` | reference | 1 |
| `reference_context.struct_update_base` | reference | 1 |
| `reference_context.trait_bound` | reference | 1 |
| `reference_context.trait_or_impl_type` | reference | 1 |
| `reference_context.try_operand` | reference | 1 |
| `reference_context.tuple_element` | reference | 1 |
| `reference_context.type_default` | reference | 1 |
| `reference_context.type_position` | reference | 1 |
| `reference_context.visibility_path` | reference | 1 |
| `reference_context.where_predicate_bound` | reference | 1 |
| `reference_context.where_predicate_subject` | reference | 1 |
| `reference_context.yield_value` | reference | 1 |
| `control_flow_label.label` | reference | 1 |
| `test_container.cfg_test_module` | reference | 1 |
| `implementation.inherent` | reference | 1 |
| `implementation.trait_for` | reference | 1 |
| `implementation_type.inherent` | reference | 1 |
| `implementation_type.trait_for` | reference | 1 |
| `relation.associated_type_bound` | reference | 1 |
| `relation.const_parameter_default` | reference | 1 |
| `relation.generic_callable_application` | reference | 1 |
| `relation.generic_type_application` | reference | 1 |
| `relation.lifetime_bound` | reference | 1 |
| `relation.trait_super_bound` | reference | 1 |
| `relation.type_parameter_bound` | reference | 1 |
| `relation.type_parameter_default` | reference | 1 |
| `relation.where_bound` | reference | 1 |
| `type.type_parameter_list` | reference | 1 |
| `type_constraint.associated_type_bounds` | reference | 1 |
| `type_constraint.for_lifetimes` | reference | 1 |
| `type_constraint.higher_ranked_trait_bound` | reference | 1 |
| `type_constraint.lifetime_bounds` | reference | 1 |
| `type_constraint.removed_trait_bound` | reference | 1 |
| `type_constraint.type_parameter_bounds` | reference | 1 |
| `type_constraint.use_bounds` | reference | 1 |
| `type_constraint.where_predicate` | reference | 1 |
| `type_context.generic_parameter_list` | reference | 1 |
| `type_expression.array` | reference | 1 |
| `type_expression.associated_binding` | reference | 1 |
| `type_expression.bounded` | reference | 1 |
| `type_expression.bracketed` | reference | 1 |
| `type_expression.dyn_trait` | reference | 1 |
| `type_expression.generic` | reference | 1 |
| `type_expression.generic_turbofish` | reference | 1 |
| `type_expression.impl_trait` | reference | 1 |
| `type_expression.never` | reference | 1 |
| `type_expression.pointer` | reference | 1 |
| `type_expression.primitive` | reference | 1 |
| `type_expression.qualified` | reference | 1 |
| `type_expression.reference` | reference | 1 |
| `type_expression.scoped` | reference | 1 |
| `type_expression.tuple` | reference | 1 |
| `type_parameter.generic` | reference | 1 |
| `type_parameter.lifetime` | reference | 1 |
| `type_use.alias_target` | reference | 1 |
| `type_use.cast` | reference | 1 |
| `type_use.closure_return` | reference | 1 |
| `type_use.const` | reference | 1 |
| `type_use.const_parameter` | reference | 1 |
| `type_use.field` | reference | 1 |
| `type_use.local` | reference | 1 |
| `type_use.parameter` | reference | 1 |
| `type_use.return` | reference | 2 |
| `type_use.static` | reference | 1 |
| `type_use.tuple_field` | reference | 1 |
| `type_use.type_parameter_default` | reference | 1 |
| `value_origin.alias` | reference | 1 |
| `value_origin.constructed` | reference | 1 |
| `value_origin.constructed_binding` | reference | 1 |
| `value_origin.declared_let` | reference | 1 |
| `value_origin.declared_parameter` | reference | 1 |
| `value_origin.destructured_from` | reference | 1 |
| `value_origin.returned_binding` | reference | 1 |
| `value_origin.returned_by` | reference | 1 |
| `value_origin.returned_owned_binding` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.bool` (1)
- `literal.char` (1)
- `literal.float` (1)
- `literal.integer` (1)
- `literal.negative` (1)
- `literal.raw_string` (1)
- `literal.string` (1)
- `control_flow.async_block` (1)
- `control_flow.await` (1)
- `control_flow.break` (1)
- `control_flow.const_block` (1)
- `control_flow.continue` (1)
- `control_flow.for` (1)
- `control_flow.gen_block` (1)
- `control_flow.if` (1)
- `control_flow.let_chain` (1)
- `control_flow.let_condition` (1)
- `control_flow.loop` (1)
- `control_flow.match` (1)
- `control_flow.return` (1)
- `control_flow.try` (1)
- `control_flow.try_block` (1)
- `control_flow.unsafe_block` (1)
- `control_flow.while` (1)
- `control_flow.yield` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 169 node types. The Pack looks at 150 of them.

Untouched:

- `_declaration_statement`
- `_expression`
- `_literal_pattern`
- `_pattern`
- `_type`
- `else_clause`
- `empty_statement`
- `extern_modifier`
- `generic_pattern`
- `mut_pattern`
- `mutable_specifier`
- `or_pattern`
- `range_pattern`
- `ref_pattern`
- `reference_pattern`
- `remaining_field_pattern`
- `tuple_struct_pattern`
- `unit_type`
- `where_clause`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
