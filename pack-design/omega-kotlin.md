# omega-kotlin

Language `omega-kotlin`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

79 templates over 76 query patterns, 32 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 10 |
| `calls` | yes | 6 |
| `data` | yes | 9 |
| `definitions` | yes | 32 |
| `implements` | yes | 5 |
| `imports` | yes | 5 |
| `modules` | yes | 2 |
| `references` | yes | 5 |
| `scopes` | yes | 4 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.constant` | Value | 2 |
| `definition.function` | Callable | 3 |
| `definition.kotlin_annotated_function_context` | Callable | 1 |
| `definition.kotlin_class` | Type | 1 |
| `definition.kotlin_constant` | Value | 1 |
| `definition.kotlin_field` | Value | 1 |
| `definition.kotlin_function` | Callable | 2 |
| `definition.kotlin_method` | Callable | 1 |
| `definition.kotlin_namespace` | Value | 1 |
| `definition.kotlin_platform_class_context` | Type | 1 |
| `definition.kotlin_platform_function_context` | Callable | 1 |
| `definition.kotlin_platform_property_context` | Value | 1 |
| `definition.kotlin_type` | Type | 2 |
| `definition.method` | Callable | 1 |
| `definition.namespace` | Value | 1 |
| `definition.type` | Type | 1 |
| `definition.type.parameter` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 4 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `relation.explicit_delegation_candidate` | `omega.pack.explicit_delegation` | 1 |
| `relation.function_supertype_candidate` | `omega.pack.function_supertype` | 1 |
| `relation.superclass_constructor_candidate` | `omega.pack.superclass_constructor` | 1 |
| `relation.superinterface_candidate` | `omega.pack.superinterface` | 1 |
| `relation.supertype_or_delegation_candidate` | `omega.pack.supertype_or_delegation` | 1 |
| `import.kotlin_candidate` | `omega.pack.kotlin` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.kotlin_candidate` | `omega.pack.kotlin` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.kotlin_declaration_candidate` | `omega.pack.kotlin_declaration` | 1 |

### Regions

- `scope.kotlin_lexical_scope` (1)
- `scope.lexical` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.field` | reference | 1 |
| `binding.import` | binding | 1 |
| `binding.kotlin_parameter` | reference | 1 |
| `binding.kotlin_variable` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `import_binding.kotlin_import` | binding | 1 |
| `call.kotlin_annotated_owner_direct_call_context` | call | 1 |
| `call.kotlin_call` | call | 1 |
| `call.kotlin_direct_call_context` | call | 1 |
| `call.kotlin_member_string_arg_context` | call | 1 |
| `call.kotlin_nested_string_arg_context` | call | 1 |
| `call.kotlin_string_arg_context` | call | 1 |
| `import.kotlin_alias_source_binding_context` | binding | 1 |
| `import.kotlin_source_binding_context` | binding | 1 |
| `reference.kotlin_annotated_class_context` | reference | 1 |
| `reference.kotlin_class` | reference | 1 |
| `reference.kotlin_primary_constructor_parameter_context` | reference | 1 |
| `reference.local` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (1)
- `literal.null` (1)
- `literal.number` (6)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 142 node types. The Pack looks at 65 of them.

Untouched:

- `additive_expression`
- `as_expression`
- `assignment`
- `binding_pattern_kind`
- `callable_reference`
- `catch_block`
- `character_escape_seq`
- `character_literal`
- `check_expression`
- `class_modifier`
- `collection_literal`
- `comparison_expression`
- `conjunction_expression`
- `constructor_delegation_call`
- `destructuring_declaration`
- `directly_assignable_expression`
- `disjunction_expression`
- `elvis_expression`
- `equality_expression`
- `file_annotation`
- `finally_block`
- `function_modifier`
- `function_type_parameters`
- `getter`
- `guard_condition`
- `import_list`
- `indexing_expression`
- `indexing_suffix`
- `infix_expression`
- `inheritance_modifier`
- `interpolation_expression_end`
- `interpolation_expression_start`
- `interpolation_identifier_start`
- `jump_expression`
- `label`
- `line_comment`
- `member_modifier`
- `multi_variable_declaration`
- `multiline_comment`
- `multiplicative_expression`
- `not_nullable_type`
- `object_literal`
- `parameter_modifier`
- `parameter_modifiers`
- `parameter_with_optional_type`
- `parenthesized_expression`
- `parenthesized_type`
- `parenthesized_user_type`
- `postfix_expression`
- `prefix_expression`
- `property_delegate`
- `property_modifier`
- `quest`
- `range_expression`
- `range_test`
- `receiver_type`
- `reification_modifier`
- `setter`
- `shebang_line`
- `source_file`
- `spread_expression`
- `try_expression`
- `type_arguments`
- `type_constraint`
- `type_constraints`
- `type_modifiers`
- `type_parameter_modifiers`
- `type_parameters`
- `type_projection`
- `type_projection_modifiers`
- `type_test`
- `use_site_target`
- `variance_modifier`
- `visibility_modifier`
- `when_condition`
- `when_subject`
- `wildcard_import`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
