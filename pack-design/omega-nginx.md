# omega-nginx

Language `omega-nginx`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

24 templates over 26 query patterns, 7 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 9 |
| `definitions` | yes | 4 |
| `imports` | yes | 1 |
| `references` | yes | 8 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.nginx_location` | Value | 1 |
| `definition.nginx_map` | Value | 1 |
| `definition.nginx_server` | Value | 1 |
| `definition.nginx_upstream` | Value | 1 |

### Regions

- `scope.lexical` (1)
- `scope.nginx_block` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.nginx_block_parameter` | reference | 1 |
| `data.nginx_directive_parameter` | reference | 1 |
| `data.nginx_error_page` | reference | 1 |
| `data.nginx_index` | reference | 1 |
| `data.nginx_listen` | reference | 1 |
| `data.nginx_return` | reference | 1 |
| `data.nginx_rewrite` | reference | 1 |
| `data.nginx_server_name` | reference | 1 |
| `structured.entry` | reference | 1 |
| `import.nginx_include` | binding | 1 |
| `reference.nginx_alias` | reference | 1 |
| `reference.nginx_fastcgi_pass` | reference | 1 |
| `reference.nginx_grpc_pass` | reference | 1 |
| `reference.nginx_proxy_pass` | reference | 1 |
| `reference.nginx_root` | reference | 1 |
| `reference.nginx_try_file` | reference | 1 |
| `reference.nginx_uwsgi_pass` | reference | 1 |
| `reference.nginx_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 26 node types. The Pack looks at 7 of them.

Untouched:

- `bracket`
- `comment`
- `conf`
- `dq_string_content`
- `escaped_dot`
- `generic`
- `ipv4`
- `lua_block_directive`
- `lua_code`
- `metric`
- `modifier`
- `number`
- `parenthese`
- `regex`
- `regex_pattern`
- `scheme`
- `sq_string_content`
- `string`
- `uri`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
