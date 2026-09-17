# omega-bash

Language `omega-bash`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

29 templates over 26 query patterns, 11 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 5 |
| `calls` | yes | 3 |
| `data` | yes | 5 |
| `definitions` | yes | 5 |
| `imports` | yes | 1 |
| `references` | yes | 6 |
| `scopes` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.bash_function` | Callable | 2 |
| `definition.function` | Callable | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.command_candidate` | `omega.pack.command` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `reference.bash_identifier_candidate` | `omega.pack.bash_identifier` | 2 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.bash_lexical_scope` (2)
- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.bash_assignment` | reference | 1 |
| `binding.bash_for` | reference | 1 |
| `binding.bash_variable` | reference | 2 |
| `binding.var` | reference | 1 |
| `value_origin.assignment` | reference | 1 |
| `data.bash_array` | reference | 1 |
| `data.bash_parameter_expansion` | reference | 1 |
| `data.bash_pipeline` | reference | 1 |
| `data.bash_pipeline_statement` | reference | 1 |
| `data.bash_redirect` | reference | 1 |
| `import.source_command` | binding | 1 |
| `reference.bash_expanded_variable` | reference | 1 |
| `reference.bash_expansion` | reference | 1 |
| `reference.bash_redirect_destination` | reference | 1 |
| `reference.local` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 62 node types. The Pack looks at 40 of them.

Untouched:

- `_expression`
- `_primary_expression`
- `_statement`
- `brace_expression`
- `c_style_for_statement`
- `case_statement`
- `compound_statement`
- `do_group`
- `elif_clause`
- `else_clause`
- `heredoc_content`
- `if_statement`
- `list`
- `negated_command`
- `parenthesized_expression`
- `redirected_statement`
- `string_content`
- `subshell`
- `test_command`
- `translated_string`
- `variable_assignments`
- `while_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
