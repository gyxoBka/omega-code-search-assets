# omega-make

Language `omega-make`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

23 templates over 21 query patterns, 15 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 4 |
| `data` | yes | 6 |
| `definitions` | yes | 5 |
| `imports` | yes | 1 |
| `references` | yes | 7 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.make_define` | Value | 1 |
| `definition.make_target` | Value | 1 |
| `definition.make_target_variable` | Value | 1 |
| `definition.make_variable` | Value | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.make_direct_candidate` | `omega.pack.make_direct` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `import.make_candidate` | `omega.pack.make` | 1 |
| `reference.make_function_candidate` | `omega.pack.make_function` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.make_function` | call | 1 |
| `call.make_shell` | call | 1 |
| `data.make_conditional` | reference | 1 |
| `data.make_export` | binding | 1 |
| `data.make_recipe` | reference | 1 |
| `data.make_recipe_line` | reference | 1 |
| `data.make_undefine` | reference | 1 |
| `data.make_vpath` | reference | 1 |
| `reference.make_automatic_variable` | reference | 2 |
| `reference.make_include_path` | reference | 1 |
| `reference.make_order_only_prerequisite` | reference | 1 |
| `reference.make_target_prerequisite_context` | reference | 1 |
| `reference.make_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 44 node types. The Pack looks at 20 of them.

Untouched:

- `RECIPEPREFIX_assignment`
- `archive`
- `arguments`
- `comment`
- `concatenation`
- `else_directive`
- `elsif_directive`
- `escape`
- `ifdef_directive`
- `ifeq_directive`
- `ifndef_directive`
- `ifneq_directive`
- `makefile`
- `override_directive`
- `pattern_list`
- `private_directive`
- `raw_text`
- `shell_command`
- `shell_text`
- `string`
- `substitution_reference`
- `text`
- `unexport_directive`
- `vpath_directive`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
