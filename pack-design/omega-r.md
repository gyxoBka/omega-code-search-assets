# omega-r

Language `omega-r`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

24 templates over 28 query patterns, 12 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 3 |
| `calls` | yes | 2 |
| `data` | yes | 4 |
| `definitions` | yes | 6 |
| `imports` | yes | 1 |
| `references` | yes | 6 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.r_class_factory_binding` | Type | 1 |
| `definition.r_function` | Callable | 1 |
| `definition.r_qualified_class_factory_binding` | Type | 1 |
| `definition.r_symbol` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `reference.r_identifier_candidate` | `omega.pack.r_identifier` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.r_lexical_scope` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.r_for` | reference | 1 |
| `binding.r_parameter` | reference | 1 |
| `call.r_function_call` | call | 1 |
| `data.r_formula` | reference | 1 |
| `data.r_pipe` | reference | 1 |
| `data.r_subset` | reference | 1 |
| `data.r_subset2` | reference | 1 |
| `reference.r_namespace` | reference | 1 |
| `import.r_package` | binding | 1 |
| `reference.r_member_access` | reference | 1 |
| `reference.r_namespace` | reference | 1 |
| `reference.r_qualified_call_assignment_identifier_context` | call | 1 |
| `reference.r_qualified_call_assignment_literal_context` | call | 1 |
| `reference.r_qualified_call_context` | call | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 39 node types. The Pack looks at 14 of them.

Untouched:

- `braced_expression`
- `break`
- `comma`
- `comment`
- `complex`
- `dot_dot_i`
- `dots`
- `escape_sequence`
- `false`
- `float`
- `if_statement`
- `inf`
- `integer`
- `na`
- `nan`
- `next`
- `null`
- `parenthesized_expression`
- `program`
- `repeat_statement`
- `return`
- `string_content`
- `true`
- `unary_operator`
- `while_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
