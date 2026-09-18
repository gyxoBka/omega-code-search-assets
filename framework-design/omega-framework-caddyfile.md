# omega-framework-caddyfile

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**19 overlay rules, 2 detection rules. All 19 match; 0 cannot.**
(Wave 2: 16 rules, 16 live. Wave 1: 28 rules, 0 live, 28 dead.)

`python pack-design/key_collisions.py caddyfile` reports nothing: no canonical
key template in this file is minted under more than one entity kind, and the
pairs of rules that share a key space (`caddy:path:*`, `caddy:static_root:*`,
`caddy:tls:*`) mint the same kind with the same attribute names.

Selector: `framework:caddyfile`. Maturity: `semantic-overlay-full`.

## What was wrong with it

### The first rewrite (28 rules -> 16)

The original file was 28 rules and **every one of them was dead**, for four
separate reasons, all measurable:

1. **It was keyed to a vocabulary the Pack never used.** 21 rules matched
   `call.directive`, 4 matched `structured.entry`, and one each matched
   `definition.site`, `definition.route` and `definition.matcher`.
   `omega-caddyfile` emits none of those five kinds.

2. **It read six names the Pack does not publish.** `directive_name` (21 rules),
   `site`, `route`, `matcher`, `upstream`, and the attribute `role`.

3. **One rule per directive name, and five of them spelled wrong.** 21 of the 28
   rules were `caddy.directive.<name>`, differing only in a `field_equals` on
   the directive name -- the Caddyfile equivalent of the per-language spellings
   the Pack rewrite collapsed. Five were written with hyphens (`file-server`,
   `handle-path`, `handle-errors`, `php-fastcgi`, `request-body`) where Caddy
   spells them with underscores.

4. **Most of them restated their input.** Thirteen entity kinds (`Encoding`,
   `LogConfig`, `HeaderPolicy`, `AuthPolicy`, `RequestBodyPolicy`,
   `MetricsConfig`, `Mapping`, `HandlerBlock`, `StaticService`, `Response`,
   `Redirect`, `Rewrite`, `StaticRoot`) existed only to name the directive that
   produced them.

### What was still wrong after it (16 rules -> 19)

Three things, all found by running
`dump_call_emissions.exe packs/omega-caddyfile grammars/omega-caddyfile <file>`
over hand-written Caddyfiles on **2026-09-18**:

1. **The one value the matchers are about was unreachable, and no longer is.**
   `definition.config_matcher_condition` published its operand only as an
   attribute, and an attribute is write-only. The Pack now publishes `operand`
   as a **field** as well, measured unquoted: `path /api/*` arrives as
   `name=path operand=/api/*`. Two rules were written against it --
   `caddy.matcher_condition` now carries it as an attribute, and the new
   `caddy.matcher_path` turns a `path` / `path_regexp` condition into the same
   `PathMatcher` identity that an inline `handle /api/*` mints, so `@api` and
   `handle /api/*` name the same path. The old **"A field only the Pack can
   supply"** section of this document asked for exactly this; it is supplied and
   the request is deleted.

2. **`caddy.static_root` and `caddy.tls` missed the commonest spelling.** The
   `definition.parameter_shape_candidate` carrier only binds an `(argument)`
   node. Measured: `root /srv/site` and `tls /etc/cert.pem /etc/key.pem` emit no
   carrier at all -- they emit `definition.config_path`, which the overlay was
   turning into a `PathMatcher` with `pattern=/srv/site`, i.e. calling a
   filesystem directory a URL matcher. Two rules fix it: `caddy.static_root_path`
   and `caddy.tls_certificate` read that `config_path` under a `root` / `tls`
   directive and mint `StaticRoot` / `TlsConfig`, and `caddy.handler_path` now
   excludes those two directive names from its join so one fact is not claimed
   twice under two meanings.

3. **One coverage gap had outlived its measurement and one was too narrow.** The
   old `coverage.gaps` named imports, snippets and "runtime semantics" and said
   nothing about operands. The previous "Still to decide" said a matcher token
   before the operand hides it -- still true, `root * /srv/www` and
   `rewrite * /index.php` emit nothing but the directive -- but the larger loss
   was not written down: an upstream written with a port, a scheme or a unix
   socket emits no operand fact **even with no matcher token present**.
   `coverage.gaps` now states both, with the date they were measured.

## What it states now

Containment is reached with `fact_join_by_span` / `within` throughout: a
directive nested in a site block already lies inside that site's span, which is
exactly what `queries.scm` says it deliberately did not restate as a pattern.
A directive's first operand is reached with `fact_join_by_span` / `same` onto
the `definition.parameter_shape_candidate` carrier, which the Pack emits at the
identical span; carriers are folded only in the content IR
(`content_builder.rs`), while `overlay_facts_of` hands the overlay every
emission.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which hostnames does this repo serve | `definition.config_site` | `ServerBlock caddy:site:{path}:{name}`; `CaddyConfig contains ServerBlock` |
| where is snippet `X` defined | `definition.config_snippet` | `Snippet caddy:snippet:{name}`; `CaddyConfig contains Snippet` |
| which config imports that snippet | `relation.depends` + same-file `definition.config_directive` | `CaddyConfig depends_on caddy:snippet:{name}` |
| which named routes exist | `definition.config_route` + same-file `definition.config_directive` | `Route caddy:route:{name}`; `CaddyConfig contains Route` |
| which site invokes a named route | `reference.route` + `within definition.config_site` | `ServerBlock depends_on Route` |
| which named matchers a file declares | `definition.config_matcher` | `Matcher caddy:matcher:{path}:{name}`; `CaddyConfig contains Matcher` |
| what does `@api` test, and for what | `definition.config_matcher_condition`, field `operand` + `within definition.config_matcher` | `MatchCondition` (`test`, `operand`); `Matcher contains MatchCondition` |
| **which URL path does `@api` select** | `definition.config_matcher_condition` named `path`/`path_regexp`, field `operand` | `PathMatcher caddy:path:{path}:{operand}`; `Matcher handles PathMatcher` |
| which handler is gated by `@api` | `reference.matcher` + `within definition.config_directive` | `Directive uses_resource Matcher` |
| where is directive `D` configured | `definition.config_directive` | `Directive caddy:directive:{path}:{offset}`; `CaddyConfig contains Directive` |
| what is configured for `example.com` | `definition.config_directive` + `within definition.config_site` | `ServerBlock configured_by Directive` |
| where does this site send requests | `definition.config_directive` named `reverse_proxy`/`php_fastcgi` + `same` carrier | `Upstream caddy:upstream:{address}`; `Directive proxies_to Upstream` |
| **which directory is served as static files** (`root /srv/site`) | `definition.config_path` + `within definition.config_directive` named `root` | `StaticRoot` (`directory`); `Directive uses_resource StaticRoot` |
| how is TLS provisioned (`tls internal`, `tls me@example.com`) | `definition.config_directive` named `tls` + `same` carrier | `TlsConfig` (`subject`); `Directive configured_by TlsConfig` |
| **which certificate file serves this site** (`tls /etc/cert.pem`) | `definition.config_path` + `within definition.config_directive` named `tls` | `TlsConfig` (`subject`); `Directive configured_by TlsConfig` |
| which path rewrites or redirects where | `definition.config_directive` named `redir`/`rewrite` + `same` carrier | `Rewrite` (`directive`, `target`); `Directive handles Rewrite` |
| which path does this handler serve | `definition.config_path` + `within definition.config_directive` (not `root`, not `tls`) | `PathMatcher caddy:path:{path}:{pattern}`; `Directive handles PathMatcher` |
| which env vars must the deployment supply | `reference.environment` | `EnvVar caddy:env:{name}`; `CaddyConfig uses_resource EnvVar` |

The three rules added in this wave are the rows in bold: `caddy.matcher_path`,
`caddy.tls_certificate` and `caddy.static_root_path`. Each states a value no
rule in the file could reach before, and each shares its key space, its entity
kind and its attribute names with the rule that already owned that space.

### Keys minted vs. keys addressed

Every key a relation addresses is minted by a rule whose conditions the
addressing rule satisfies:

| key | minted by | addressed by |
|---|---|---|
| `caddy:config:{path}` | site, snippet, import, named_route, matcher, directive, environment | the same seven rules |
| `caddy:site:{path}:{name}` | `caddy.site`, unconditional on `definition.config_site` | route_invoke, site_directive -- each through a bound `definition.config_site` fact |
| `caddy:snippet:{name}` | `caddy.snippet` | import |
| `caddy:route:{name}` | `caddy.named_route` | route_invoke |
| `caddy:matcher:{path}:{name}` | `caddy.matcher`, unconditional | matcher_condition, matcher_use, matcher_path |
| `caddy:directive:{path}:{offset}` | `caddy.directive`, unconditional on `definition.config_directive` | site_directive, upstream, static_root, static_root_path, tls, tls_certificate, url_rewrite, matcher_use, handler_path |
| `caddy:path:{path}:{pattern}` | `caddy.handler_path` and `caddy.matcher_path` -- both `PathMatcher`, both with `pattern` and `source_path` | the same two rules |
| `caddy:static_root:*` | `caddy.static_root` and `caddy.static_root_path` -- one kind, one attribute set | the same two rules |
| `caddy:tls:*` | `caddy.tls` and `caddy.tls_certificate` -- one kind, one attribute set | the same two rules |
| `caddy:upstream:*`, `caddy:rewrite:*`, `caddy:match_condition:*`, `caddy:env:*` | the same rule that addresses them | -- |

Two kinds are not Caddyfile-exclusive: `relation.depends` is emitted by 25 Packs
and `definition.config_route` by `omega-razor` as well. Those two rules carry a
`fact_join_by_field` on `path` against `definition.config_directive`, which
`omega-caddyfile` alone emits -- "this fact is in a file the Caddyfile Pack
read". No `path_glob` is used anywhere:
`grammars/omega-caddyfile/manifest.toml` declares `extensions = []` and
`filenames = []`, so there is no path shape to glob on, and a guessed
`**/Caddyfile*` would have been a clause that matched nothing.
`definition.parameter_shape_candidate` is emitted by 34 Packs but is only ever
reached here by a `same_path` span join from a `definition.config_directive`.

## A field only the Pack can supply

**`omega-caddyfile`, kind `definition.parameter_shape_candidate`: the operand
capture must accept an address node, not only an `(argument)`.** Measured
2026-09-18 with `dump_call_emissions`:

| written | operand fact emitted |
|---|---|
| `reverse_proxy backend` | `definition.parameter_shape_candidate backend` |
| `reverse_proxy backend:80` | none |
| `reverse_proxy http://backend` | none |
| `reverse_proxy unix//var/run/app.sock` | none |
| `php_fastcgi 127.0.0.1:9000` | none |
| `reverse_proxy { to app1:80 }` | none (the inner `to` is a Directive with no carrier) |

The carrier pattern in `queries.scm` is anchored to `(argument)`; an upstream
carrying a port, a scheme or a unix socket parses as a `network_address`-family
node and binds nothing, so **no fact whatever exists for that text**. That is
why no join reaches it: `fact_join_by_span` relates two emissions, and here the
second emission does not happen; and the built-in names on the directive fact
give `reverse_proxy`, not the address. The remedy is one alternation in the
Pack's carrier pattern -- the same list the matcher-condition pattern already
uses, `(argument) (path) (network_address) (ip_address_or_cidr) ...`. Until it
lands, *where does this site send requests* is answered only for a bare
hostname, and `caddy.upstream` is kept for that case rather than deleted.

The `operand` field this document asked the Pack for in the previous wave has
been supplied, and that request has been removed rather than repeated.

## Still to decide

- **A matcher token before the operand still hides the operand.** `root *
  /srv/www` and `rewrite * /index.php` emit the directive and nothing else --
  neither a carrier nor a `config_path`, because the `(matcher)` node sits
  between the name and the value and both patterns are anchored. Measured
  2026-09-18. Relaxing the anchor would bind the wrong argument for
  multi-argument directives, so it is a Pack judgement, not an overlay one.
- **A `host` matcher condition is not related to a site.** `@a host
  sub.example.com` could address `caddy:site:{path}:{operand}`, but a host
  matcher usually names a subdomain that no site block in the same file
  declares, so that edge would dangle more often than it would resolve. The
  value is carried as the `operand` attribute of the `MatchCondition` instead,
  which is an honest answer to *what does `@a` test for*.
- **`import` of a file glob resolves to nothing.** `import snippets/*.conf` and
  `import redirect` are the same emission; the overlay emits
  `CaddyConfig depends_on caddy:snippet:{name}`, which resolves when a snippet
  of that name is declared anywhere in the repository and is "not found"
  otherwise. Distinguishing the two forms is a Pack question.
- **`grammars/omega-caddyfile/manifest.toml` declares no `extensions` and no
  `filenames`** (re-read 2026-09-18, still true). Only the language alias
  `caddyfile` reaches the parser, so a file actually named `Caddyfile` is never
  handed to this grammar in an ordinary scan and none of these rules sees a
  fact. That is a grammar-asset gap, outside this framework's files, and it is
  the reason no rule here is keyed to a path.
