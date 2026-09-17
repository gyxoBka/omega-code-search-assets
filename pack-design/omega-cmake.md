# omega-cmake

Language `omega-cmake`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

40 templates over 53 query patterns, 14 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 4 |
| `data` | yes | 21 |
| `definitions` | yes | 8 |
| `imports` | yes | 2 |
| `references` | yes | 4 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.cmake_function` | Callable | 1 |
| `definition.cmake_macro` | Value | 1 |
| `definition.cmake_option` | Value | 1 |
| `definition.cmake_project` | Value | 1 |
| `definition.cmake_target` | Value | 1 |
| `definition.cmake_variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.cmake_candidate` | `omega.pack.cmake` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `reference.cmake_candidate` | `omega.pack.cmake` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.cmake_command` | call | 1 |
| `structured.entry` | reference | 3 |
| `data.cmake_install` | reference | 1 |
| `data.cmake_property` | reference | 1 |
| `semantic_hint.cmake_callable` | call | 3 |
| `semantic_hint.cmake_lexical_role` | reference | 8 |
| `semantic_hint.cmake_literal` | reference | 3 |
| `semantic_hint.cmake_module` | reference | 1 |
| `semantic_hint.cmake_type` | reference | 1 |
| `semantic_hint.cmake_value` | reference | 3 |
| `import.cmake_include` | binding | 1 |
| `import.cmake_subdirectory` | binding | 1 |
| `reference.cmake_package` | reference | 1 |
| `reference.cmake_target_link` | reference | 1 |
| `reference.cmake_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 58 node types. The Pack looks at 36 of them.

Untouched:

- `body`
- `bracket_argument_close`
- `bracket_argument_content`
- `bracket_argument_open`
- `bracket_comment_close`
- `bracket_comment_content`
- `bracket_comment_open`
- `cache_var`
- `else_command`
- `endforeach_command`
- `endfunction_command`
- `endif_command`
- `endmacro_command`
- `endwhile_command`
- `env_var`
- `foreach_command`
- `foreach_loop`
- `if_condition`
- `normal_var`
- `quoted_element`
- `while_command`
- `while_loop`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
