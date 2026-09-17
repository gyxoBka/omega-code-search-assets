# omega-gdscript

Language `omega-gdscript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

35 templates over 54 query patterns, 28 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 5 |
| `calls` | yes | 1 |
| `definitions` | yes | 21 |
| `references` | yes | 4 |
| `scopes` | yes | 3 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.gdscript_class_name` | Type | 2 |
| `definition.gdscript_constructor` | Type | 1 |
| `definition.gdscript_enum_member` | Type | 1 |
| `definition.gdscript_export` | Value | 1 |
| `definition.gdscript_field` | Value | 1 |
| `definition.gdscript_function` | Callable | 1 |
| `definition.gdscript_method` | Callable | 1 |
| `definition.gdscript_onready` | Value | 1 |
| `definition.gdscript_signal` | Value | 1 |
| `definition.gdscript_signal_signature` | Value | 1 |
| `definition.gdscript_symbol` | Value | 1 |
| `definition.gdscript_type` | Type | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.gdscript_direct_candidate` | `omega.pack.gdscript_direct` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `reference.gdscript_identifier_candidate` | `omega.pack.gdscript_identifier` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.gdscript_declaration_candidate` | `omega.pack.gdscript_declaration` | 1 |

### Regions

- `scope.gdscript_lexical_scope` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.gdscript_export_typed` | binding | 1 |
| `binding.gdscript_onready_typed` | reference | 1 |
| `binding.gdscript_parameter` | reference | 1 |
| `binding.gdscript_variable` | reference | 1 |
| `reference.gdscript_annotation` | reference | 1 |
| `reference.gdscript_extends` | reference | 1 |
| `reference.gdscript_resource_load` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 90 node types. The Pack looks at 42 of them.

Untouched:

- `_attribute_expression`
- `_compound_statement`
- `_pattern`
- `_primary_expression`
- `annotations`
- `array`
- `assignment`
- `attribute`
- `attribute_subscript`
- `augmented_assignment`
- `await_expression`
- `binary_operator`
- `break_statement`
- `breakpoint_statement`
- `comment`
- `comparison_operator`
- `conditional_expression`
- `continue_statement`
- `dictionary`
- `enumerator_list`
- `escape_sequence`
- `expression_statement`
- `false`
- `float`
- `get_node`
- `inferred_type`
- `integer`
- `match_body`
- `node_path`
- `null`
- `pair`
- `parenthesized_expression`
- `pass_statement`
- `pattern_array`
- `pattern_dictionary`
- `pattern_guard`
- `pattern_open_ending`
- `pattern_pair`
- `remote_keyword`
- `return_statement`
- `setget`
- `static_keyword`
- `string_name`
- `subscript`
- `tool_statement`
- `true`
- `unary_operator`
- `underscore`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
