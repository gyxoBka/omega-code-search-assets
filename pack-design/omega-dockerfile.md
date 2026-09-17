# omega-dockerfile

Language `omega-dockerfile`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

25 templates over 36 query patterns, 23 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 2 |
| `data` | yes | 19 |
| `definitions` | yes | 1 |
| `references` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.docker_stage` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.docker_arg` | reference | 1 |
| `binding.docker_env` | reference | 1 |
| `data.docker_add_path` | reference | 1 |
| `data.docker_base_image` | reference | 1 |
| `data.docker_command` | reference | 2 |
| `data.docker_copy_path` | reference | 1 |
| `data.docker_exposed_port` | reference | 1 |
| `data.docker_healthcheck` | reference | 1 |
| `data.docker_instruction` | reference | 6 |
| `data.docker_label` | reference | 1 |
| `data.docker_mount` | reference | 1 |
| `data.docker_onbuild` | reference | 1 |
| `data.docker_shell` | reference | 1 |
| `data.docker_user` | reference | 1 |
| `data.docker_workdir` | reference | 1 |
| `reference.docker_expansion` | reference | 1 |
| `reference.docker_stage_from` | reference | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 48 node types. The Pack looks at 40 of them.

Untouched:

- `cross_build_instruction`
- `escape_sequence`
- `json_string`
- `label_instruction`
- `line_continuation`
- `maintainer_instruction`
- `mount_param_param`
- `source_file`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
