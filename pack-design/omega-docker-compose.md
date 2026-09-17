# omega-docker-compose

Language `omega-docker-compose`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

28 templates over 29 query patterns, 6 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 17 |
| `definitions` | yes | 5 |
| `references` | yes | 6 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.compose_config` | Config | 1 |
| `definition.compose_network` | Value | 1 |
| `definition.compose_secret` | Value | 1 |
| `definition.compose_service` | Value | 1 |
| `definition.compose_volume` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.compose_build` | reference | 1 |
| `data.compose_environment` | reference | 1 |
| `data.compose_healthcheck` | reference | 1 |
| `data.compose_image` | reference | 1 |
| `data.compose_port` | reference | 1 |
| `data.compose_profile` | reference | 1 |
| `data.compose_service_field` | reference | 1 |
| `data.compose_service_sequence_item` | reference | 1 |
| `data.compose_volume_mount` | reference | 1 |
| `structured.entry` | reference | 3 |
| `structured.object_entry` | reference | 1 |
| `value.array` | reference | 1 |
| `value.document` | reference | 1 |
| `value.object` | reference | 1 |
| `value.object_pair` | reference | 1 |
| `reference.compose_config` | reference | 1 |
| `reference.compose_depends_on` | reference | 2 |
| `reference.compose_env_file` | reference | 1 |
| `reference.compose_network` | reference | 1 |
| `reference.compose_secret` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

No `node-types.json` for this grammar, so the boundary cannot be
measured here.

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
