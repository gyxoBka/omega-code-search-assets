# omega-graphql

Language `omega-graphql`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

39 templates over 53 query patterns, 30 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `data` | yes | 7 |
| `definitions` | yes | 20 |
| `references` | yes | 8 |
| `types` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `semantic_hint.graphql_object_type_definition_structure_hint` | Type | 1 |
| `definition.graphql_directive` | Value | 2 |
| `definition.graphql_directive_argument` | Value | 1 |
| `definition.graphql_enum_type` | Type | 1 |
| `definition.graphql_enum_value` | Type | 1 |
| `definition.graphql_field` | Value | 1 |
| `definition.graphql_fragment` | Value | 1 |
| `definition.graphql_input_object_type` | Type | 1 |
| `definition.graphql_input_value` | Value | 1 |
| `definition.graphql_interface_type` | Type | 1 |
| `definition.graphql_object_type` | Type | 1 |
| `definition.graphql_operation` | Value | 1 |
| `definition.graphql_scalar_type` | Type | 1 |
| `definition.graphql_type_extension` | Type | 6 |
| `definition.graphql_union` | Value | 1 |
| `definition.graphql_root_field_argument_context` | Value | 1 |
| `definition.graphql_root_field_response_context` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `type.graphql_declaration_candidate` | `omega.pack.graphql_declaration` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.graphql_variable` | reference | 1 |
| `data.graphql_argument` | reference | 1 |
| `data.graphql_default` | reference | 1 |
| `data.graphql_directive_location` | reference | 1 |
| `data.graphql_schema` | reference | 1 |
| `data.graphql_schema_extension` | reference | 1 |
| `data.graphql_typed_default` | reference | 1 |
| `reference.graphql_directive_use` | reference | 1 |
| `reference.graphql_field_selection` | reference | 1 |
| `reference.graphql_fragment_reference` | reference | 1 |
| `reference.graphql_implements` | reference | 1 |
| `reference.graphql_interface_extends` | reference | 1 |
| `reference.graphql_interface_implementation` | reference | 1 |
| `reference.graphql_type_reference` | reference | 1 |
| `reference.graphql_union_member` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 74 node types. The Pack looks at 43 of them.

Untouched:

- `alias`
- `arguments`
- `boolean_value`
- `comma`
- `comment`
- `definition`
- `description`
- `directives`
- `document`
- `enum_values_definition`
- `executable_definition`
- `executable_directive_location`
- `float_value`
- `inline_fragment`
- `input_fields_definition`
- `int_value`
- `list_value`
- `null_value`
- `object_field`
- `object_value`
- `operation_type`
- `selection`
- `selection_set`
- `source_file`
- `string_value`
- `type_condition`
- `type_extension`
- `type_system_definition`
- `type_system_directive_location`
- `type_system_extension`
- `variable_definitions`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
