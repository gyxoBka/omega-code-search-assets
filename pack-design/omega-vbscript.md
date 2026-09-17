# omega-vbscript

Language `omega-vbscript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

24 templates over 23 query patterns, 19 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 5 |
| `calls` | yes | 2 |
| `data` | yes | 2 |
| `definitions` | yes | 4 |
| `references` | yes | 3 |
| `scopes` | yes | 6 |
| `types` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.vbscript_function` | Callable | 1 |
| `definition.vbscript_ptrsafe_function` | Callable | 1 |
| `definition.vbscript_subroutine` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.vbscript_candidate` | `omega.pack.vbscript` | 1 |
| `definition.vbscript_declaration_candidate` | `omega.pack.vbscript_declaration` | 1 |
| `type.vbscript_declaration_candidate` | `omega.pack.vbscript_declaration` | 1 |

### Regions

- `scope.lexical` (1)
- `scope.vbscript_do` (1)
- `scope.vbscript_for` (1)
- `scope.vbscript_function` (1)
- `scope.vbscript_subroutine` (1)
- `scope.vbscript_while` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.symbol` | reference | 1 |
| `binding.vbscript_assignment` | reference | 1 |
| `binding.vbscript_parameter` | reference | 1 |
| `binding.vbscript_redim` | reference | 1 |
| `binding.vbscript_variable` | reference | 1 |
| `call.vbscript_invocation` | call | 1 |
| `data.vbscript_array` | reference | 1 |
| `semantic_hint.syntax_node` | reference | 1 |
| `reference.symbol` | reference | 1 |
| `reference.vbscript_member` | reference | 1 |
| `reference.vbscript_type_member` | reference | 1 |
| `type.vbscript_new_expression` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 40 node types. The Pack looks at 20 of them.

Untouched:

- `argument`
- `argument_list`
- `array_element`
- `array_type`
- `binary_expression`
- `boolean`
- `comment`
- `exit_statement`
- `if_statement`
- `keyword_argument`
- `literal`
- `modifier`
- `number`
- `parameter_list`
- `source_file`
- `string_literal`
- `type`
- `type_terminal`
- `unary_expression`
- `variable_list`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
