; --- block_scope ---

(block) @caddy.scope @local.scope @structural.candidate

; --- directive_call ---

(directive
  name: (directive_name) @caddy.directive.name
  .
  (argument) @caddy.directive.argument) @caddy.directive

(directive
  name: (directive_name) @caddy.directive.name) @caddy.directive

; --- env_reference ---

(environment_variable) @caddy.env

; --- external-helix-locals ---

; Omega coverage-first adapted external query
; source=helix language=caddyfile kind=locals
; original baseline: audit-baselines/external/helix/caddyfile/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; --- helix_independent_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED from normalized exact-grammar AST evidence only.
; Helix MPL query body is NOT copied. language=caddyfile

; --- matcher_reference ---

(matcher_identifier) @caddy.matcher

; --- named_matcher_definition ---

(named_matcher
  (matcher_identifier
    name: (matcher_name) @caddy.matcher.name)) @caddy.matcher.definition

; --- named_route_definition ---

(named_route name: (named_route_identifier) @caddy.route.name) @caddy.route

; --- owner_context ---

(single_site
  name: (site_address) @caddy.site.name
  body: (named_matcher
    (matcher_identifier
      name: (matcher_name) @caddy.matcher.name)) @caddy.matcher) @caddy.site

(single_site
  name: (site_address) @caddy.site.directive_site_name
  body: (directive
    name: (directive_name) @caddy.site.directive_name
    .
    (argument) @caddy.site.directive_argument) @caddy.site.directive) @caddy.site.directive_site

(named_route
  name: (named_route_identifier) @caddy.route.name
  (block
    body: (directive
      name: (directive_name) @caddy.directive.name
      .
      (argument) @caddy.directive.argument) @caddy.directive)) @caddy.route

(named_route
  name: (named_route_identifier) @caddy.route.matcher_route_name
  (block
    body: (named_matcher
      (matcher_identifier
        name: (matcher_name) @caddy.route.matcher_name)) @caddy.route.matcher)) @caddy.route.matcher_route

; --- placeholder_reference ---

(placeholder) @caddy.placeholder

; --- site_definition ---

(single_site name: (site_address) @caddy.site.name) @caddy.site

; --- snippet_definition_modern ---

(snippet_definition name: (snippet_name) @caddy.snippet.name) @caddy.snippet
