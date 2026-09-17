# omega-swift

Language `omega-swift`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

51 templates over 78 query patterns, 23 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 3 |
| `calls` | yes | 10 |
| `definitions` | yes | 26 |
| `imports` | yes | 2 |
| `references` | yes | 4 |
| `scopes` | yes | 5 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.swift_class` | Type | 1 |
| `definition.swift_class_method_context` | Type | 1 |
| `definition.swift_function` | Callable | 3 |
| `definition.swift_interface` | Value | 1 |
| `definition.swift_method` | Callable | 1 |
| `definition.swift_property` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.call_candidate` | `omega.pack.call` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `relation.inheritance_or_conformance_candidate` | `omega.pack.inheritance_or_conformance` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 7 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 6 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.swift_candidate` | `omega.pack.swift` | 1 |
| `reference.navigation_candidate` | `omega.pack.navigation` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.swift_declaration_candidate` | `omega.pack.swift_declaration` | 1 |

### Regions

- `scope.lexical` (1)
- `scope.swift_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.import` | binding | 1 |
| `import_binding.swift_import` | binding | 2 |
| `call.swift_computed_property_direct_call_context` | call | 1 |
| `call.swift_named_array_string_argument_context` | call | 1 |
| `call.swift_named_string_argument_context` | call | 1 |
| `call.swift_receiver_member_string_argument_context` | call | 1 |
| `call.swift_receiver_member_string_segment_context` | call | 1 |
| `module_relation.imported_module` | binding | 1 |
| `reference.swift_nominal_conformance_context` | reference | 1 |
| `reference.swift_property_attribute_context` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.literal` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 183 node types. The Pack looks at 56 of them.

Untouched:

- `_expression`
- `additive_expression`
- `array_type`
- `as_expression`
- `as_operator`
- `assignment`
- `availability_condition`
- `await_expression`
- `bang`
- `bin_literal`
- `bitwise_operation`
- `capture_list`
- `capture_list_item`
- `catch_block`
- `catch_keyword`
- `check_expression`
- `comparison_expression`
- `computed_getter`
- `computed_modify`
- `computed_setter`
- `conjunction_expression`
- `constructor_expression`
- `control_transfer_statement`
- `custom_operator`
- `default_keyword`
- `deprecated_operator_declaration_body`
- `diagnostic`
- `dictionary_literal`
- `dictionary_type`
- `didset_clause`
- `directive`
- `directly_assignable_expression`
- `disjunction_expression`
- `else`
- `equality_constraint`
- `equality_expression`
- `existential_type`
- `external_macro_definition`
- `fully_open_range`
- `function_body`
- `function_modifier`
- `getter_specifier`
- `hex_literal`
- `infix_expression`
- `inheritance_constraint`
- `inheritance_modifier`
- `integer_literal`
- `interpolated_expression`
- `key_path_expression`
- `key_path_string_expression`
- `lambda_function_type`
- `lambda_function_type_parameters`
- `lambda_literal`
- `lambda_parameter`
- `macro_declaration`
- `macro_definition`
- `macro_invocation`
- `member_modifier`
- `metatype`
- `modify_specifier`
- `multi_line_str_text`
- `multiplicative_expression`
- `mutation_modifier`
- `nil_coalescing_expression`
- `oct_literal`
- `opaque_type`
- `open_end_range_expression`
- `open_start_range_expression`
- `operator_declaration`
- `optional_type`
- `ownership_modifier`
- `parameter_modifier`
- `parameter_modifiers`
- `playground_literal`
- `postfix_expression`
- `precedence_group_attribute`
- `precedence_group_attributes`
- `precedence_group_declaration`
- `prefix_expression`
- `property_modifier`
- `protocol_composition_type`
- `protocol_property_requirements`
- `range_expression`
- `raw_str_continuing_indicator`
- `raw_str_end_part`
- `raw_str_interpolation`
- `raw_str_interpolation_start`
- `raw_str_part`
- `raw_string_literal`
- `real_literal`
- `selector_expression`
- `setter_specifier`
- `shebang_line`
- `source_file`
- `special_literal`
- `statement_label`
- `str_escaped_char`
- `suppressed_constraint`
- `switch_entry`
- `switch_pattern`
- `ternary_expression`
- `throw_keyword`
- `throws`
- `throws_clause`
- `try_expression`
- `try_operator`
- `tuple_expression`
- `tuple_type`
- `type_annotation`
- `type_arguments`
- `type_constraint`
- `type_constraints`
- `type_modifiers`
- `type_pack_expansion`
- `type_parameter`
- `type_parameter_modifiers`
- `type_parameter_pack`
- `type_parameters`
- `value_binding_pattern`
- `value_pack_expansion`
- `value_parameter_pack`
- `visibility_modifier`
- `where_clause`
- `where_keyword`
- `wildcard_pattern`
- `willset_clause`
- `willset_didset_block`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
