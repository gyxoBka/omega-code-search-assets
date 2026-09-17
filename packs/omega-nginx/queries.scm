; omega-nginx
;
; An nginx configuration file is a tree of directives. A simple directive
; states a setting (`client_max_body_size 20m;`); a block directive opens a
; context and usually names the thing that context configures (`location
; /api`, `upstream backend`, `map $http_host $name`).
;
; The questions asked of one are: where is this setting configured and to
; what, which route handles this path, what does this configuration proxy to,
; where does this variable come from, and what does this file pull in.
;
; Containment is not stated as a pattern. The tree already holds it, and a
; block's extent is emitted once as a region.

; --- the setting a simple directive states ---
;
; One declaration per directive, named by the directive itself, so that
; `where is ssl_protocols set` has an answer.

(simple_directive name: (directive) @setting.name) @setting

; --- what that setting is set to ---
;
; A separate pattern, because this one matches once per parameter and the
; declaration above must be stated once per directive. The parameters are
; folded into the declaration's own bag at the same span, not emitted as
; mentions: `20m` and `on` resolve against nothing.

(simple_directive (param) @setting.value) @setting.site

; --- the extent of a context ---

(block_directive name: (directive) @block.name) @block

; --- a route ---
;
; The grammar cuts a location's match into one parameter per token -- `^/api/`,
; `(.*)` and `$` are three, and `^~` is a regex followed by a modifier -- so no
; single parameter is the path. The path is taken from the directive's own text
; instead: everything between the keyword and the brace, with the match
; operator stripped off the front and carried as an attribute by the pattern
; below it.

((block_directive name: (directive) @_location (block)) @location
  (#eq? @_location "location"))

((block_directive name: (directive) @_location_mod (param (modifier) @location.modifier) (block)) @location.mod
  (#eq? @_location_mod "location"))

; --- a backend group ---
;
; `upstream backend { ... }` is what `proxy_pass http://backend` resolves to.

((block_directive name: (directive) @_upstream (param) @upstream.name . (block)) @upstream
  (#eq? @_upstream "upstream"))

; --- where a variable comes from ---
;
; Two spellings: the block form, whose last parameter before the block is the
; variable it computes, and the directive form, whose first parameter is.

((block_directive name: (directive) @_map (param) @variable.map.name . (block)) @variable.map
  (#any-of? @_map "map" "geo" "split_clients"))

((simple_directive name: (directive) @_set . (param (variable) @variable.set.name))
  (#any-of? @_set "set" "perl_set" "auth_request_set"))

; --- the host a virtual server answers for ---
;
; Declared at the parameter, one per name, so `who serves api.example.com`
; resolves; the `server_name` directive itself is already declared above.

((simple_directive name: (directive) @_server_name (param) @server_name.host)
  (#eq? @_server_name "server_name"))

; --- what this configuration proxies to ---
;
; The host part of the pass target, so it resolves to the `upstream` block of
; that name.

((simple_directive name: (directive) @_pass (param (uri (generic) @proxy.host))) @proxy
  (#any-of? @_pass
    "proxy_pass" "fastcgi_pass" "uwsgi_pass" "scgi_pass" "grpc_pass" "memcached_pass"))

; --- a variable used ---

(variable) @variable.use

; --- what the file pulls in ---

((simple_directive name: (directive) @_include (param) @include.path)
  (#eq? @_include "include"))

; --- embedded Lua ---
;
; The directive is an anonymous token in this grammar, so the region is named
; from the first word of its own text. The Lua itself is not indexed.

(lua_block_directive (lua_block)) @lua
