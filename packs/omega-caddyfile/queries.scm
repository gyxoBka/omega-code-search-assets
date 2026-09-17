; omega-caddyfile
;
; A Caddyfile is the whole configuration of a web server: which hostnames are
; served, what handles a request once it arrives, and where a request is sent
; on. The questions asked of one are: what is served at this address, where
; does this path go, what does this matcher select, where is this snippet
; defined and who imports it, and which environment variables does the
; deployment need. Every pattern below answers one of them.
;
; Containment is deliberately not stated. A directive nested in a site block is
; inside that site's span already, and the host carries it through the `within:`
; segment; a pattern per (site, directive) pair states nothing extra and costs
; one match per pair.

; --- a site ---
;
; Two spellings of the same construct. `example.com { ... }` is a `site_block`;
; a Caddyfile that serves exactly one site may drop the braces and is then a
; `single_site`. The shipped Pack matched only the second, so an ordinary
; Caddyfile declared no site at all.
;
; `name:` is a repeated field -- `example.com, www.example.com { ... }` -- so
; this matches once per address and the site is declared under each name it
; answers to. That is what the addresses mean.

[(site_block name: (site_address) @site.name)
 (single_site name: (site_address) @site.name)] @site

; --- a snippet, and who imports it ---
;
; `(redirect) { ... }` defines a snippet; `import redirect` uses it. The two
; names are spelled the same way, so the import resolves onto the definition.
; `import` also takes a file glob, which resolves onto nothing and is recorded
; as a dependency on the text as written.

(snippet_definition name: (snippet_name) @snippet.name) @snippet

(directive
  name: (directive_name) @import.directive
  .
  (argument) @import.name
  (#eq? @import.directive "import")) @import

; --- a named route, and who invokes it ---

(named_route name: (named_route_identifier) @route.name) @route

(directive
  name: (directive_name) @invoke.directive
  .
  (argument) @invoke.name
  (#eq? @invoke.directive "invoke")) @invoke

; --- a named matcher, and every use of it ---
;
; `@api { path /api/* }` declares it; `reverse_proxy @api backend:80` uses it.
; Both sites take the name from the `name:` field of `matcher_identifier`, so
; both are `api` and the use resolves onto the declaration. The shipped Pack
; captured `(matcher_identifier)` bare, which matched declaration and use
; alike and named the use with the whole node -- `@api`, sigil included --
; which could never match the declaration's `api`.

(named_matcher
  .
  (matcher_identifier name: (matcher_name) @matcher.name)) @matcher

; A `matcher` node is only ever a use: a named matcher declares itself through
; a bare `matcher_identifier`, not through this node. The inline path form
; `handle /api/*` is the path the request must have, so it is stated under its
; own name.

(matcher
  [(matcher_identifier name: (matcher_name) @matcher.ref.name)
   (path_matcher) @matcher.path]) @matcher.ref

; --- what a matcher tests ---
;
; `path /api/*`, `header X-Forwarded-Proto https`, `expression {method} == 'GET'`.
; The condition is named by the thing it tests and carries what it tests for.
; A condition always takes an operand, so one pattern states both.

(matcher_directive
  name: (matcher_directive_name) @matcher_condition.name
  .
  [(argument)
   (path)
   (network_address)
   (ip_address_or_cidr)
   (interpreted_string_literal)
   (raw_string_literal)
   (cel_expression)
   (int_literal)] @matcher_condition.value) @matcher_condition

; --- a directive ---
;
; A directive is where something is configured: `reverse_proxy`, `root`, `tls`,
; `encode`, `header`. It is declared at the point of use, under its own name,
; in the Config family -- "where is `tls` configured in this repository" is the
; question, and there is no declaration of `reverse_proxy` anywhere for a call
; to resolve against. `import` and `invoke` are excluded: they are links, and
; are stated as such above.
;
; Directives nested in a directive's own block (`reverse_proxy { header_up ... }`)
; are `directive` nodes too and are declared here, inside the outer directive's
; span.

(directive
  name: (directive_name) @directive.name
  (#not-any-of? @directive.name "import" "invoke")) @directive

; The first operand of a directive is the answer to most questions asked of it
; -- the upstream of a `reverse_proxy`, the directory of a `root`, the codec of
; an `encode`. Many directives take none (`file_server`, `templates`), so it
; cannot be an attribute of the declaration above: a template whose attribute
; references an unbound capture is skipped, and the directive would then not be
; declared at all. It is a carrier folded onto the declaration at the same span.
;
; Anchored to the child immediately after the name, so exactly one operand
; binds per match.

(directive
  name: (directive_name) @directive.valued.name
  .
  (argument) @directive.value
  (#not-any-of? @directive.valued.name "import" "invoke")) @directive.valued

; --- what the deployment must supply ---
;
; `{$DOMAIN}` and `{env.DOMAIN}` are the same variable in two spellings, and
; both are reduced to `DOMAIN` so they resolve onto whatever declares it.
; Every other placeholder -- `{http.request.uri}`, `{vars.x}`, `{re.name.1}` --
; names a value Caddy computes at request time, which nothing in a repository
; declares; those are not stated, and a guard says so.

(environment_variable) @env

((placeholder) @env.placeholder
  (#match? @env.placeholder "^\\{env\\."))
