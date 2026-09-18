# omega-framework-caddyfile

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**16 overlay rules, 2 detection rules. All 16 match; 0 cannot.**
(Was 28 rules, 0 live, 28 dead.)

Selector: `framework:caddyfile`. Maturity: `semantic-overlay-full`.

## What was wrong with it

The old file was 28 rules and **every one of them was dead**, for four separate
reasons, all measurable:

1. **It was keyed to a vocabulary the Pack never used.** 21 rules matched
   `call.directive`, 4 matched `structured.entry`, and one each matched
   `definition.site`, `definition.route` and `definition.matcher`.
   `omega-caddyfile` emits none of those five kinds. It emits
   `definition.config_site`, `definition.config_snippet`,
   `definition.config_route`, `definition.config_matcher`,
   `definition.config_path`, `definition.config_matcher_condition`,
   `definition.config_directive`, `definition.parameter_shape_candidate`,
   `reference.route`, `reference.matcher`, `reference.environment` and
   `relation.depends` — twelve templates, and the overlay named none of them.

2. **It read six names the Pack does not publish.** `directive_name` (21 rules),
   `site`, `route`, `matcher`, `upstream`, and the attribute `role`. The
   `omega-caddyfile` Pack publishes an **empty `fields` map on every one of its
   twelve templates**; the only readable names are the built-ins
   (`definition.name`, `path`, `source.start`, …). A directive's name was being
   asked for under `directive_name` when it is the emission's own `name`.

3. **One rule per directive name, and five of them spelled wrong.** 21 of the 28
   rules were `caddy.directive.<name>`, differing only in a `field_equals` on
   the directive name — the Caddyfile equivalent of the per-language spellings
   the Pack rewrite collapsed. Worse, five of the names were written with
   hyphens (`file-server`, `handle-path`, `handle-errors`, `php-fastcgi`,
   `request-body`) where Caddy spells them with underscores, so those five would
   have matched nothing even against a Pack that did publish a directive name.

4. **Most of them restated their input.** `caddy.directive.encode` emitted an
   `Encoding` entity keyed on the word `encode`; `metrics` emitted a
   `MetricsConfig`; `vars` emitted a `Mapping`. Thirteen entity kinds
   (`Encoding`, `LogConfig`, `HeaderPolicy`, `AuthPolicy`, `RequestBodyPolicy`,
   `MetricsConfig`, `Mapping`, `HandlerBlock`, `StaticService`, `Response`,
   `Redirect`, `Rewrite`, `StaticRoot`) existed only to name the directive that
   produced them. They are gone: one `Directive` entity, minted for **every**
   Caddy directive rather than for a hand-listed 21, answers *where is `tls`
   configured in this repository* and *what is configured for `example.com`*
   better than the list did.

The four `structured.entry` rules (`site_contains_matcher`,
`site_reverse_proxy`, `route_reverse_proxy`, `route_handles_matcher`) were the
only ones that stated a relation between two real things, and they were doing it
with invented `site`/`route`/`upstream` fields. Those four are what was worth
porting; they are now `caddy.matcher_use`, `caddy.upstream` and
`caddy.site_directive`, carried by span joins that need no Pack field at all.

## What it states now

Containment is reached with `fact_join_by_span` / `within` throughout: a
directive nested in a site block already lies inside that site's span, which is
exactly what `queries.scm` says it deliberately did not restate as a pattern.
The first operand of a directive is reached with `fact_join_by_span` / `same`
onto the `definition.parameter_shape_candidate` carrier, which the Pack emits at
the identical span; carriers are folded only in the content IR
(`content_builder.rs`), while `overlay_facts_of` hands the overlay every
emission, so the carrier is a fact the overlay can join.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which hostnames does this repo serve | `definition.config_site` | `ServerBlock caddy:site:{path}:{name}`; `CaddyConfig contains ServerBlock` |
| where is snippet `X` defined | `definition.config_snippet` | `Snippet caddy:snippet:{name}`; `CaddyConfig contains Snippet` |
| which config imports that snippet | `relation.depends` + same-file `definition.config_directive` | `CaddyConfig depends_on caddy:snippet:{name}` |
| which named routes exist | `definition.config_route` + same-file `definition.config_directive` | `Route caddy:route:{name}`; `CaddyConfig contains Route` |
| which site invokes a named route | `reference.route` + `within definition.config_site` | `ServerBlock depends_on Route` |
| which named matchers a file declares | `definition.config_matcher` | `Matcher caddy:matcher:{path}:{name}`; `CaddyConfig contains Matcher` |
| what does `@api` test | `definition.config_matcher_condition` + `within definition.config_matcher` | `MatchCondition` (`test` = `path`/`header`/`expression`); `Matcher contains MatchCondition` |
| which handler is gated by `@api` | `reference.matcher` + `within definition.config_directive` | `Directive uses_resource Matcher` |
| where is directive `D` configured | `definition.config_directive` | `Directive caddy:directive:{path}:{offset}`; `CaddyConfig contains Directive` |
| what is configured for `example.com` | `definition.config_directive` + `within definition.config_site` | `ServerBlock configured_by Directive` |
| where does this site send requests | `definition.config_directive` named `reverse_proxy` or `php_fastcgi` + `same` carrier | `Upstream caddy:upstream:{address}`; `Directive proxies_to Upstream` |
| which directory is served as static files | `definition.config_directive` named `root` + `same` carrier | `StaticRoot` (`directory`); `Directive uses_resource StaticRoot` |
| how is TLS provisioned | `definition.config_directive` named `tls` + `same` carrier | `TlsConfig` (`subject`); `Directive configured_by TlsConfig` |
| which path rewrites or redirects where | `definition.config_directive` named `redir` or `rewrite` + `same` carrier | `Rewrite` (`directive`, `target`); `Directive handles Rewrite` |
| which path does this handler serve | `definition.config_path` + `within definition.config_directive` | `PathMatcher caddy:path:{path}:{pattern}`; `Directive handles PathMatcher` |
| which env vars must the deployment supply | `reference.environment` | `EnvVar caddy:env:{name}`; `CaddyConfig uses_resource EnvVar` |

### Keys minted vs. keys addressed

Every key a relation addresses is minted by a rule whose conditions the
addressing rule satisfies:

| key | minted by | addressed by |
|---|---|---|
| `caddy:config:{path}` | site, snippet, import, named_route, matcher, directive, environment | the same seven rules |
| `caddy:site:{path}:{name}` | `caddy.site`, unconditional on `definition.config_site` | route_invoke, site_directive — each through a bound `definition.config_site` fact |
| `caddy:snippet:{name}` | `caddy.snippet` | import |
| `caddy:route:{name}` | `caddy.named_route` | route_invoke |
| `caddy:matcher:{path}:{name}` | `caddy.matcher`, unconditional | matcher_condition, matcher_use |
| `caddy:directive:{path}:{offset}` | `caddy.directive`, unconditional on `definition.config_directive` | site_directive, upstream, static_root, tls, url_rewrite, matcher_use, handler_path |
| `caddy:upstream:*`, `caddy:static_root:*`, `caddy:tls:*`, `caddy:rewrite:*`, `caddy:path:*`, `caddy:match_condition:*`, `caddy:env:*` | the same rule that addresses them | — |

Two kinds are not Caddyfile-exclusive: `relation.depends` is emitted by 25 Packs
and `definition.config_route` by `omega-razor` as well. Those two rules therefore
carry a `fact_join_by_field` on `path` against `definition.config_directive`,
which `omega-caddyfile` alone emits — "this fact is in a file the Caddyfile Pack
read". No `path_glob` is used anywhere:
`grammars/omega-caddyfile/manifest.toml` declares `extensions = []` and
`filenames = []`, so there is no path shape to glob on, and a guessed
`**/Caddyfile*` would have been a clause that matched nothing.
`definition.parameter_shape_candidate` is emitted by 34 Packs but is only ever
reached here by a `same_path` span join from a `definition.config_directive`.

## A field only the Pack can supply

**`omega-caddyfile`, kind `definition.config_matcher_condition`, attribute
`operand` → should be a field.** The condition's name is *what* it tests
(`path`, `header`, `expression`); the value it tests *for* — `/api/*`,
`X-Forwarded-Proto https` — is published as the attribute `operand`.
`OverlayFact::field` resolves the `fields` map plus a fixed list of built-ins and
never consults `attributes`, and the only clause that reads an attribute is
`attribute_equals` against one literal constant. So that value cannot be a
canonical key, a relation end, an entity attribute or a join key. No join
reaches it either: it is the same emission's own value, not another fact's, so
there is nothing to join to, and `definition.name` already carries the test
name rather than the operand. Moving it from `attributes` to `fields` is the
same bytes in a different map — the identical remedy four wave-1 frameworks
asked for. Until then, *which path does `@api` select* is unanswerable and
`MatchCondition` states only which kind of test it is.

## Still to decide

- **`import` of a file glob resolves to nothing.** `import snippets/*.conf` and
  `import redirect` are the same emission — the Pack strips quotes and states
  the text as written, and cannot tell a snippet name from a path. The overlay
  emits `CaddyConfig depends_on caddy:snippet:{name}`, which resolves when a
  snippet of that name is declared anywhere in the repository and is "not found"
  otherwise. Recording the unresolvable file case as a dependency of its own
  would need the Pack to distinguish the two forms; that is a Pack question, not
  an overlay one, and "not found" is the honest answer meanwhile.
- **A matcher before the operand hides the operand.** The Pack's carrier pattern
  anchors `(argument)` immediately after the directive name, so
  `reverse_proxy @api backend:80` and `root * /srv/www` bind no carrier — the
  `(matcher)` node sits between them — and `caddy.upstream` /
  `caddy.static_root` state nothing for those forms. Relaxing the anchor is a
  Pack change with its own cost (it would bind the wrong argument for
  multi-argument directives), so it is recorded rather than worked around here.
- **`grammars/omega-caddyfile/manifest.toml` declares no `extensions` and no
  `filenames`.** Only the language alias `caddyfile` reaches the parser, so a
  file actually named `Caddyfile` is never handed to this grammar and none of
  these rules ever sees a fact. That is a grammar-asset gap, outside this
  framework's files, and it is the reason no rule here is keyed to a path.
