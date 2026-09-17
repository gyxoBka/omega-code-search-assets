# omega-nginx

Language `omega-nginx`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

13 templates over 13 query patterns, 4 distinct root node types
(`simple_directive`, `block_directive`, `variable`, `lua_block_directive`).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 8 |
| `imports` | yes | 1 |
| `references` | yes | 2 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_setting` | Config | 1 |
| `definition.config_location` | Config | 1 |
| `definition.config_upstream` | Config | 1 |
| `definition.config_variable` | Config | 2 |
| `definition.config_server_name` | Config | 1 |

### Carriers

| kind | folded onto the declaration at the same span as | templates |
|---|---|---|
| `definition.value_candidate` | `omega.pack.value` — the parameters of a directive | 1 |
| `definition.match_candidate` | `omega.pack.match` — a location's `=`, `~`, `~*`, `^~` | 1 |

### Regions

- `scope.config_block` (1) — every `directive { … }`, named by the directive
- `scope.lua_block` (1) — an embedded `*_by_lua_block`, named by its directive

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `reference.config_variable` | reference | 1 |
| `reference.config_upstream` | reference | 1 |
| `import.config_include` | binding | 1 |

No `relation.*` kind is emitted, so none can be one the host does not know.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 26 node types. The Pack looks at 11 of them: `block`,
`block_directive`, `directive`, `generic`, `lua_block`, `lua_block_directive`,
`modifier`, `param`, `simple_directive`, `uri`, `variable`.

Untouched:

- `bracket`
- `comment`
- `conf`
- `dq_string_content`
- `escaped_dot`
- `ipv4`
- `lua_code`
- `metric`
- `number`
- `parenthese`
- `regex`
- `regex_pattern`
- `scheme`
- `sq_string_content`
- `string`

Each is either punctuation of a parameter the Pack already stores whole
(`bracket`, `parenthese`, `string` and its two content nodes, `escaped_dot`,
`regex_pattern`), a lexical shape of a parameter that carries no name
(`number`, `metric`, `ipv4`, `scheme`, `regex`), the file node itself (`conf`),
a comment, or the body of an embedded language the Pack marks as a region but
does not index (`lua_code`).

---

## What is wrong with it

This section describes the Pack as it was found, at version 1.0.0: **24
templates over 26 query patterns**, capabilities `data`, `scopes`,
`references`, `definitions`, `imports`.

**Defect F, in every single template.** All 24 carried exactly one constant
attribute and nothing else: `source` on 21 of them
(`semantic-closure-v3.146` ×13, `semantic-closure-v3.147-nginx-surface` ×7,
`pack-completeness-v2.3` ×1) and `role` on the other 3
(`nginx_block`, `nginx_directive_name`, `nginx_variable`, each a restatement of
the `output_kind` the template already declares). The generator's batch number
was written into the index once per directive of every nginx file in a
repository. 24 of 24 constant attributes, 0 of them answering a question.

**Defect D, on the most expensive template in the Pack.** `scope.lexical` took
its name from `capture_ref scope.lexical`, and that capture was
`(block) @scope.lexical` and `(lua_block) @scope.lexical` — the whole body of
the block. Every `http { … }` in the corpus stored the rest of the file as the
name of a scope, and every nested `server`, `location` and `upstream` stored
its body again inside it. A scope is a region; its span is the point of it and
it never needed that name. `definition.nginx_server` was the mirror image: its
name was the literal `"nginx_server"`, so every virtual server in a repository
was one entity called `nginx_server`.

**Defect A, on all four declarations.** `definition.nginx_location`,
`definition.nginx_map`, `definition.nginx_server`, `definition.nginx_upstream`
— four kinds, four Values. Not one of the words `location`, `map`, `server`,
`upstream`, `nginx` is in the host's vocabulary, so a question asking for
configuration found none of them, although an nginx file is nothing but
configuration. 4 of 4 declaration kinds in the wrong family.

**Defect C: 7 node types of 26.** `uri`, `scheme`, `generic` and `ipv4` were
untouched, so `proxy_pass http://backend` was stored as the string
`http://backend` and never linked to the `upstream backend` block three lines
above it — the one name-to-name link an nginx configuration has, and the Pack
had both ends of it and joined neither. `modifier` was untouched, so a prefix
location and a regex location were indistinguishable. `lua_block_directive`
and `lua_code` were untouched: the Pack captured `(lua_block)` only to name a
scope with the Lua source.

**Defect G: 2 of 3 guards.** The first gave the single token
`syntactic_scope_boundaries_only_no_runtime_scope_inference`. The third
described the structural fallback below, which produced nothing at all. The
second was a real sentence and was the only usable one.

**Almost nothing was declared, and almost everything was a mention of
nothing.** 18 of 24 templates were mentions; 17 of them arrived as a plain
`reference` and the 18th as a binding. `reference.nginx_root`,
`reference.nginx_alias` and `reference.nginx_try_file` named filesystem paths
as references; `data.nginx_listen`, `data.nginx_return`,
`data.nginx_error_page`, `data.nginx_index`, `data.nginx_server_name` and
`data.nginx_rewrite` named values as references. None of them could resolve to
anything, because the Pack declared only four things and none of them had those
names. The directive — which is what an nginx file consists of, and what
"where is `client_max_body_size` set" asks about — was never declared at all:
it was emitted three times as a mention (`structured.entry`,
`data.nginx_directive_parameter`, `data.nginx_block_parameter`), once per
parameter.

**Sixteen patterns asked the same node the same question.** `simple_directive`
was the root of 16 of the 26 patterns and `block_directive` of 6; the two
generic ones and the fourteen `#eq?`-guarded ones walk the same nodes. One
pattern per node with several templates over it is the shape the contract asks
for (§5), and the Pack never used it.

**A wildcard pattern producing nothing.** `(_) @structural.node` matched every
named node of every nginx file, and no template in `rules.json` referenced
`@structural.node`. One match per node, zero emissions, plus a coverage guard
explaining it. This is not one of the seven classes in `00-INDEX.md`; see
*Cross-Pack* below.

**One pattern multiplied its own matches.** The `location` pattern was
`(block_directive name: (directive) @_n (param) @path (block) @body)` with no
anchor, so `location = /healthz { … }` matched twice — once with the `=`
parameter bound as the path — and declared a location named `=`. The same
unanchored shape was in `upstream` and `map`.

Not wrong: Defect B (no kind spelled a keyword inside a longer word) and
Defect E (no pattern hard-coded a chain of containment; the `(block)` captures
are a node's own required child, not a depth chain).

## What it should extract

An nginx configuration file is a tree of directives, and only two shapes exist:
`directive params;` and `directive params { … }`. The questions asked of one
are *where is this setting configured and to what*, *which route handles this
path*, *what does this configuration proxy to*, *where does this variable come
from*, and *what does this file pull in*. The Pack states those and nothing
else.

| what | node | emitted as | family |
|---|---|---|---|
| a setting | `simple_directive` via `directive` | `definition.config_setting` | Config |
| what it is set to | its `param` children | `definition.value_candidate` carrier → `omega.pack.value` | attribute on the setting |
| the extent of a context | `block_directive` via `directive` | `scope.config_block` | region |
| a route | `block_directive` `location`, path taken from the directive's text | `definition.config_location` | Config |
| how it matches | `param (modifier)` | `definition.match_candidate` carrier → `omega.pack.match` | attribute on the route |
| a backend group | `block_directive` `upstream` via its last `param` | `definition.config_upstream` | Config |
| a computed variable | `block_directive` `map`/`geo`/`split_clients` via its last `param` | `definition.config_variable` | Config |
| an assigned variable | `simple_directive` `set`/`perl_set`/`auth_request_set` via its first `param (variable)` | `definition.config_variable` | Config |
| a host served | `simple_directive` `server_name` via each `param` | `definition.config_server_name` | Config |
| a variable used | `variable` | `reference.config_variable` | reference |
| what is proxied to | `param (uri (generic))` under `*_pass` | `reference.config_upstream` | reference |
| what the file pulls in | `simple_directive` `include` via its `param` | `import.config_include` | binding |
| embedded Lua | `lua_block_directive` | `scope.lua_block` | region |
| a comment, a number, a quote, a bracket | `comment`, `number`, `string`, `bracket`, `parenthese` | nothing | — |

Three things follow from declaring the directive itself.

**A configuration becomes searchable by what it sets.** `ssl_protocols`,
`client_max_body_size` and `proxy_read_timeout` are declarations named by the
directive, with their arguments folded into `omega.pack.value` at the same
span — one declaration and one attribute per line of the file, instead of one
mention per parameter that resolves to nothing.

**`proxy_pass` resolves.** The host part of the pass target is taken out of the
URI, so `proxy_pass http://backend` is a reference named `backend` and finds
`upstream backend { … }`, which is declared under exactly that name. The
same holds for `fastcgi_pass`, `uwsgi_pass`, `scgi_pass`, `grpc_pass` and
`memcached_pass`.

**`$variables` resolve.** A `$` (and a `${…}`) is stripped from both ends of
the link: `map $http_upgrade $connection_upgrade` declares `connection_upgrade`
and every `$connection_upgrade` is a reference to it.

The parameter-level mention kinds are gone. A port, a timeout, a header value,
a rewrite target and a `try_files` list are the value of the setting that
states them, held in the declaration's own bag where a card can say them and
nothing can resolve to them.

Containment is not stated as a pattern: one `scope.config_block` per block
gives the extent, and a declaration inside one already carries its container
through the `within:` namespace segment.

Cost, measured on a 700-byte configuration exercising every construct: 13
patterns, 62 emissions, and no name longer than a hostname. The wildcard
pattern and its guard are gone.

## Still to decide

1. **A `server` block has no name of its own.** nginx identifies a virtual
   server by its `listen` and `server_name`, which are separate directives, so
   the block is emitted as a region and its identity comes from the
   `definition.config_server_name` declarations inside it. Declaring the block
   under a name invented from its children would be a guess; declaring it under
   the word `server` would put one entity called `server` in the index per
   virtual host. Left as a region.
2. **`root` and `alias` are not `relation.depends` occurrences.** The directory
   they name is not an indexed entity, so the edge would resolve to nothing.
   The path is the setting's value instead. If the store ever indexes served
   directories, this is the first thing to add.
3. **A variable's declaration and its first use share a span.** `set $x 1;`
   declares `x` at the bytes `$x`, and the `(variable)` pattern also reports a
   reference there. Both are true, and separating them would need a pattern
   that excludes a node by its position in another pattern.
4. **The grammar cuts a regex location into one parameter per token.**
   `location ~ ^/api/(.*)$` is five parameters, and `^~` is a regex followed by
   a modifier, so no single parameter is the path. The path is taken from the
   directive's own text between the keyword and the brace, with the match
   operator stripped off the front. It costs a copy of the block's source per
   location; if that ever shows up in a measurement, the alternative is to
   accept the operator inside the name.
5. **Lua is marked, not indexed.** `known_injection_relationships` is empty in
   the grammar bundle and the Pack declares no injection, so a
   `content_by_lua_block` is a region and its Lua is opaque. Wiring the
   injection is a grammar-bundle change, not a Pack change.

## Cross-Pack

Two findings here are not this Pack's problem and are reported for
`00-INDEX.md` rather than written into it.

**A wildcard pattern no template reads.** `(_) @structural.node` was in this
Pack and is still in six others: `omega-csv`, `omega-editorconfig`,
`omega-prisma`, `omega-sas`, `omega-vbscript`, `omega-vue`. In
`omega-editorconfig`, `omega-prisma`, `omega-vue` and — until this rewrite —
`omega-nginx`, no template in `rules.json` mentions the capture at all. It is one query match per named node
of every file of that language, for zero emissions, and it usually ships with a
coverage guard describing it.

**Predicate operators the runtime cannot evaluate.** The tree-sitter Rust
binding applies `#eq?`, `#not-eq?`, `#any-eq?`, `#any-not-eq?`, `#match?`,
`#not-match?`, `#any-match?`, `#any-not-match?`, `#any-of?` and `#not-any-of?`
inside `QueryMatches::advance`, and files everything else under
`general_predicates`, which the runtime never consults. The shipped Packs use
45 `#lua-match?`, 4 `#not-lua-match?`, 3 `#is-not?` and 2 `#has-ancestor?`
across 13 Packs (`omega-bash`, `omega-c`, `omega-cmake`, `omega-css`,
`omega-dockerfile`, `omega-elixir`, `omega-html`, `omega-julia`, `omega-lua`,
`omega-nix`, `omega-ruby`, `omega-sql`, `omega-zig`). Every one of those
patterns fires unfiltered, which means each emits for every node of its root
type rather than for the ones the author named. This Pack uses only `#eq?` and
`#any-of?`, and their effect was checked against a real parse.
