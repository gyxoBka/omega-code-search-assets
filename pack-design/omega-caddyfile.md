# omega-caddyfile

Language `omega-caddyfile`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

13 templates over 16 query patterns, 10 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `data` | yes | 4 |
| `definitions` | yes | 4 |
| `references` | yes | 3 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.matcher` | Value | 1 |
| `definition.route` | Value | 1 |
| `definition.site` | Value | 1 |
| `definition.snippet` | Value | 1 |

### Regions

- `scope.block` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.directive` | call | 1 |
| `structured.entry` | reference | 4 |
| `reference.environment` | reference | 1 |
| `reference.matcher` | reference | 1 |
| `reference.placeholder` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 38 node types. The Pack looks at 16 of them.

Untouched:

- `cel_expression`
- `comment`
- `duration_literal`
- `escape_sequence`
- `global_options`
- `heredoc`
- `heredoc_body`
- `heredoc_end`
- `heredoc_start`
- `int_literal`
- `interpreted_string_literal`
- `ip_address_or_cidr`
- `matcher_block`
- `matcher_directive`
- `matcher_directive_name`
- `network_address`
- `path`
- `path_matcher`
- `raw_string_literal`
- `site_block`
- `source_file`
- `status_code_fallback`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
