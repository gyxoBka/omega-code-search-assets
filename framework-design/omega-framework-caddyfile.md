# omega-framework-caddyfile

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

28 overlay rules, 2 detection rules. **0 can match, 28 cannot.**

Selector: `framework:caddyfile`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Upstream` | 3 |
| `HandlerBlock` | 3 |
| `Import` | 2 |
| `TlsConfig` | 2 |
| `Mapping` | 2 |
| `ServerBlock` | 1 |
| `Route` | 1 |
| `Matcher` | 1 |
| `StaticRoot` | 1 |
| `StaticService` | 1 |
| `Redirect` | 1 |
| `Rewrite` | 1 |
| `Response` | 1 |
| `Encoding` | 1 |
| `LogConfig` | 1 |
| `HeaderPolicy` | 1 |
| `AuthPolicy` | 1 |
| `RequestBodyPolicy` | 1 |
| `MetricsConfig` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 14 |
| `contains` | 4 |
| `proxies_to` | 3 |
| `depends_on` | 2 |
| `handles` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.directive` | 21 | **no** |
| `structured.entry` | 4 | **no** |
| `definition.site` | 1 | **no** |
| `definition.route` | 1 | **no** |
| `definition.matcher` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x28, `field_equals` x23, `field_present` x11, `attribute_equals` x4.

Fields read: `directive_name`, `definition.name`, `site`, `matcher`, `upstream`, `route`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `caddy.server_block` | kind `definition.site` |
| `caddy.route` | kind `definition.route` |
| `caddy.matcher` | kind `definition.matcher` |
| `caddy.site_contains_matcher` | kind `structured.entry`; field `matcher`, `site`; attribute `role` |
| `caddy.site_reverse_proxy` | kind `structured.entry`; field `directive_name`, `site`, `upstream`; attribute `role` |
| `caddy.route_reverse_proxy` | kind `structured.entry`; field `directive_name`, `route`, `upstream`; attribute `role` |
| `caddy.route_handles_matcher` | kind `structured.entry`; field `matcher`, `route`; attribute `role` |
| `caddy.directive.import` | kind `call.directive`; field `directive_name` |
| `caddy.directive.include` | kind `call.directive`; field `directive_name` |
| `caddy.directive.root` | kind `call.directive`; field `directive_name` |
| `caddy.directive.file-server` | kind `call.directive`; field `directive_name` |
| `caddy.directive.tls` | kind `call.directive`; field `directive_name` |
| `caddy.directive.redir` | kind `call.directive`; field `directive_name` |
| `caddy.directive.rewrite` | kind `call.directive`; field `directive_name` |
| `caddy.directive.respond` | kind `call.directive`; field `directive_name` |
| `caddy.directive.encode` | kind `call.directive`; field `directive_name` |
| `caddy.directive.log` | kind `call.directive`; field `directive_name` |
| `caddy.directive.header` | kind `call.directive`; field `directive_name` |
| `caddy.directive.basicauth` | kind `call.directive`; field `directive_name` |
| `caddy.directive.handle` | kind `call.directive`; field `directive_name` |
| `caddy.directive.handle-path` | kind `call.directive`; field `directive_name` |
| `caddy.directive.map` | kind `call.directive`; field `directive_name` |
| `caddy.directive.php-fastcgi` | kind `call.directive`; field `directive_name` |
| `caddy.directive.handle-errors` | kind `call.directive`; field `directive_name` |
| `caddy.directive.request-body` | kind `call.directive`; field `directive_name` |
| `caddy.directive.metrics` | kind `call.directive`; field `directive_name` |
| `caddy.directive.vars` | kind `call.directive`; field `directive_name` |
| `caddy.directive.acme-server` | kind `call.directive`; field `directive_name` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
