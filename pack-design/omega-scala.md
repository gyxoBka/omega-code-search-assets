# omega-scala

Language `omega-scala`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

67 templates over 97 query patterns, 33 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 7 |
| `calls` | yes | 2 |
| `definitions` | yes | 39 |
| `imports` | yes | 5 |
| `modules` | yes | 2 |
| `references` | yes | 6 |
| `scopes` | yes | 5 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.constant` | Value | 2 |
| `definition.enum` | Type | 2 |
| `definition.function` | Callable | 4 |
| `definition.interface` | Value | 2 |
| `definition.module` | Value | 2 |
| `definition.scala_class` | Type | 1 |
| `definition.scala_enum` | Type | 1 |
| `definition.scala_function` | Callable | 2 |
| `definition.scala_interface` | Value | 1 |
| `definition.scala_module` | Value | 1 |
| `definition.scala_object` | Value | 1 |
| `definition.scala_property` | Value | 1 |
| `definition.scala_type` | Type | 1 |
| `definition.scala_variable` | Value | 1 |
| `definition.type` | Type | 2 |
| `definition.type.parameter` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 6 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.reexport_candidate` | `omega.pack.reexport` | 1 |
| `relation.extends_candidate` | `omega.pack.extends` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.scala_candidate` | `omega.pack.scala` | 1 |
| `reference.member_access_candidate` | `omega.pack.member_access` | 1 |
| `reference.scala_identifier_candidate` | `omega.pack.scala_identifier` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.scala_declaration_candidate` | `omega.pack.scala_declaration` | 1 |

### Regions

- `scope.lexical` (2)
- `scope.scala_lexical_scope` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.parameter` | reference | 1 |
| `binding.scala_parameter` | reference | 1 |
| `binding.scala_variable` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `call.scala_call` | call | 1 |
| `import.import_declaration` | binding | 1 |
| `reference.local` | reference | 2 |
| `reference.scala_class` | reference | 1 |
| `reference.scala_interface` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 150 node types. The Pack looks at 46 of them.

Untouched:

- `_definition`
- `_pattern`
- `access_qualifier`
- `alternative_pattern`
- `annotated_type`
- `annotation`
- `applied_constructor_type`
- `arguments`
- `arrow_renamed_identifier`
- `as_renamed_identifier`
- `ascription_expression`
- `assignment_expression`
- `block_comment`
- `boolean_literal`
- `capture_pattern`
- `case_block`
- `case_class_pattern`
- `catch_clause`
- `character_literal`
- `class_parameters`
- `colon_argument`
- `comment`
- `compilation_unit`
- `compound_type`
- `context_bound`
- `derives_clause`
- `do_while_expression`
- `early_defs`
- `enum_body`
- `enum_case_definitions`
- `escape_sequence`
- `expression`
- `extension_definition`
- `finally_clause`
- `floating_point_literal`
- `function_type`
- `generic_function`
- `given_conditional`
- `given_pattern`
- `guard`
- `identifiers`
- `if_expression`
- `indented_block`
- `indented_cases`
- `infix_expression`
- `infix_modifier`
- `infix_pattern`
- `infix_type`
- `inline_modifier`
- `integer_literal`
- `interpolated_string`
- `interpolated_string_expression`
- `interpolation`
- `into_modifier`
- `literal_type`
- `lower_bound`
- `macro_body`
- `match_expression`
- `match_type`
- `name_and_type`
- `named_pattern`
- `named_tuple_pattern`
- `named_tuple_type`
- `namespace_selectors`
- `namespace_wildcard`
- `null_literal`
- `opaque_modifier`
- `open_modifier`
- `operator_identifier`
- `parameter_types`
- `parenthesized_expression`
- `postfix_expression`
- `prefix_expression`
- `projected_type`
- `quote_expression`
- `refinement`
- `repeat_pattern`
- `return_expression`
- `self_type`
- `singleton_type`
- `splice_expression`
- `stable_identifier`
- `stable_type_identifier`
- `string`
- `structural_type`
- `throw_expression`
- `tracked_modifier`
- `transparent_modifier`
- `try_expression`
- `tuple_expression`
- `tuple_type`
- `type_arguments`
- `type_case_clause`
- `typed_pattern`
- `unit`
- `upper_bound`
- `using_directive`
- `using_directive_key`
- `using_directive_value`
- `vararg`
- `view_bound`
- `while_expression`
- `wildcard`
- `with_template_body`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
