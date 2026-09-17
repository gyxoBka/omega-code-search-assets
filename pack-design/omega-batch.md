# omega-batch

Language `omega-batch`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

19 templates over 17 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 3 |
| `data` | yes | 4 |
| `definitions` | yes | 2 |
| `references` | yes | 3 |
| `scopes` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.constant` | Value | 1 |
| `definition.function` | Callable | 1 |

### Regions

- `scope.batch_for` (1)
- `scope.batch_if` (1)
- `scope.batch_setlocal` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.batch_assignment` | reference | 1 |
| `binding.batch_for` | reference | 1 |
| `binding.batch_for_variable` | reference | 1 |
| `binding.batch_prompt_assignment` | reference | 1 |
| `call.batch_call` | call | 1 |
| `call.batch_call_statement` | call | 1 |
| `call.batch_command` | call | 1 |
| `data.batch_arithmetic_assignment` | reference | 1 |
| `data.batch_assignment_group` | reference | 1 |
| `data.batch_for_set` | reference | 1 |
| `semantic_hint.batch_label_structure_hint` | reference | 1 |
| `reference.batch_dynamic_call_target` | call | 1 |
| `reference.batch_variable` | reference | 1 |
| `reference.batch_variable_reference` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 53 node types. The Pack looks at 18 of them.

Untouched:

- `argument_list`
- `argument_value`
- `arithmetic_expression`
- `assignment_literal`
- `bracketed_literal`
- `bracketed_value`
- `caret_quoted_assignment_value`
- `command_option`
- `command_sep`
- `comment`
- `comparison_op`
- `cond_exec`
- `echo_off`
- `else_clause`
- `endlocal_stmt`
- `exit_stmt`
- `fd_redirect`
- `fd_redirect_op`
- `for_options`
- `for_set_group`
- `for_set_literal`
- `goto_stmt`
- `if_option`
- `integer`
- `macro_invocation`
- `paren_expression`
- `parenthesized`
- `pipe_stmt`
- `program`
- `redirect_op`
- `redirect_stmt`
- `redirect_target`
- `redirection`
- `set_option`
- `string`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
