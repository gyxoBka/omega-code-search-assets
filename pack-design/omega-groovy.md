# omega-groovy

Language `omega-groovy`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

36 templates over 39 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 5 |
| `calls` | yes | 5 |
| `data` | yes | 1 |
| `definitions` | yes | 14 |
| `imports` | yes | 2 |
| `modules` | yes | 2 |
| `references` | yes | 2 |
| `scopes` | yes | 3 |
| `types` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.groovy_anonymous_dsl_closure_context` | Value | 1 |
| `definition.groovy_class` | Type | 1 |
| `definition.groovy_class_context` | Type | 1 |
| `definition.groovy_function` | Callable | 1 |
| `definition.groovy_method_context` | Callable | 1 |
| `definition.groovy_named_dsl_closure_context` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.member_category_candidate` | `omega.pack.member_category` | 1 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `import.groovy_candidate` | `omega.pack.groovy` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.groovy_candidate` | `omega.pack.groovy` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.groovy_declaration_candidate` | `omega.pack.groovy_declaration` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.groovy_declaration` | reference | 1 |
| `binding.groovy_for_variable` | reference | 1 |
| `binding.groovy_parameter` | reference | 1 |
| `binding.groovy_parameter_full` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `call.groovy_dsl_nested_identifier_call_context` | call | 1 |
| `call.groovy_function_call` | call | 1 |
| `call.groovy_nested_call_context` | call | 1 |
| `call.groovy_string_arg_context` | call | 1 |
| `data.groovy_closure` | reference | 1 |
| `type_reference.groovy_type` | reference | 1 |
| `import.groovy_path` | binding | 1 |
| `reference.groovy_annotation` | reference | 1 |
| `reference.local` | reference | 1 |
| `type_relation.groovy_extends` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 65 node types. The Pack looks at 19 of them.

Untouched:

- `access_op`
- `array_type`
- `assertion`
- `assignment`
- `binary_op`
- `boolean_literal`
- `break`
- `builtintype`
- `case`
- `comment`
- `continue`
- `do_while_loop`
- `escape_sequence`
- `first_line`
- `for_loop`
- `for_parameters`
- `generic_param`
- `generic_parameters`
- `generics`
- `groovy_doc`
- `groovy_doc_at_text`
- `groovy_doc_param`
- `groovy_doc_tag`
- `groovy_doc_throws`
- `if_statement`
- `increment_op`
- `index`
- `interpolation`
- `list`
- `map`
- `map_item`
- `null`
- `number_literal`
- `parameter_list`
- `pipeline`
- `return`
- `shebang`
- `source_file`
- `string_internal_quote`
- `switch_block`
- `switch_statement`
- `ternary_op`
- `try_statement`
- `type_with_generics`
- `unary_op`
- `while_loop`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
