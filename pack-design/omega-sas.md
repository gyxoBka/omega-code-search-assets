# omega-sas

Language `omega-sas`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

31 templates over 29 query patterns, 22 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 4 |
| `data` | yes | 2 |
| `definitions` | yes | 9 |
| `imports` | yes | 5 |
| `references` | yes | 9 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.data_step` | Value | 1 |
| `definition.macro` | Value | 1 |
| `definition.macro.name` | Value | 1 |
| `definition.proc_step` | Value | 1 |
| `definition.sas_dataset` | Value | 1 |
| `definition.sas_output_dataset` | Value | 1 |
| `definition.sas_sql_output` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |

### Regions

- `scope.sas_macro` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.sas_macro_parameter` | reference | 1 |
| `call.macro` | call | 1 |
| `call.macro.name` | call | 1 |
| `call.macro_inline` | call | 1 |
| `data.sas_proc_sql` | reference | 1 |
| `semantic_hint.syntax_node` | reference | 1 |
| `import.include` | binding | 1 |
| `import.library` | binding | 1 |
| `import.sas_libname` | binding | 1 |
| `reference.macro_variable` | reference | 1 |
| `reference.sas_data_merge_input` | reference | 1 |
| `reference.sas_data_set_input` | reference | 1 |
| `reference.sas_data_update_input` | reference | 1 |
| `reference.sas_insert_target` | reference | 1 |
| `reference.sas_join_table` | reference | 1 |
| `reference.sas_select_table` | reference | 1 |
| `reference.sas_table` | reference | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 25 of them.

Untouched:

- `block_comment`
- `ds_options`
- `fileref_source`
- `generic_statement`
- `line_comment`
- `macro_arguments`
- `macro_do_statement`
- `macro_end`
- `macro_if_statement`
- `macro_label`
- `macro_options`
- `null_statement`
- `numeric_literal`
- `options_statement`
- `percent_comment`
- `proc_sql_header`
- `proc_step_header`
- `program`
- `run_or_quit_statement`
- `run_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
