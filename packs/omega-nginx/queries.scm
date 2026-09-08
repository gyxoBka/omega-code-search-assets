; --- completeness_scopes ---

(block) @scope.lexical
(lua_block) @scope.lexical

; --- nginx_safe_semantics ---

(block_directive name: (directive) @nginx.block.name) @nginx.block
(simple_directive name: (directive) @nginx.directive.name) @nginx.directive
(variable) @nginx.variable

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.
(_) @structural.node

; --- semantic_closure_v3_146 ---

(block_directive name: (directive) @nginx.typed.block.name (param) @nginx.typed.block.param) @nginx.typed.block
(simple_directive name: (directive) @nginx.typed.simple.name (param) @nginx.typed.simple.param) @nginx.typed.simple

((block_directive name: (directive) @_n (param) @nginx.location.path (block) @nginx.location.body) @nginx.location
  (#eq? @_n "location"))
((block_directive name: (directive) @_n (param) @nginx.upstream.name (block) @nginx.upstream.body) @nginx.upstream
  (#eq? @_n "upstream"))
((block_directive name: (directive) @_n (param) @nginx.map.source (param) @nginx.map.target (block) @nginx.map.body) @nginx.map
  (#eq? @_n "map"))
((block_directive name: (directive) @_n (block) @nginx.server.body) @nginx.server
  (#eq? @_n "server"))

((simple_directive name: (directive) @_n (param) @nginx.include.path) @nginx.include (#eq? @_n "include"))
((simple_directive name: (directive) @_n (param) @nginx.proxy.target) @nginx.proxy (#eq? @_n "proxy_pass"))
((simple_directive name: (directive) @_n (param) @nginx.listen.value) @nginx.listen (#eq? @_n "listen"))
((simple_directive name: (directive) @_n (param) @nginx.root.path) @nginx.root (#eq? @_n "root"))
((simple_directive name: (directive) @_n (param) @nginx.try_file.value) @nginx.try_file (#eq? @_n "try_files"))
((simple_directive name: (directive) @_n (param) @nginx.rewrite.arg) @nginx.rewrite (#eq? @_n "rewrite"))
((simple_directive name: (directive) @_n (param) @nginx.server_name.value) @nginx.server_name (#eq? @_n "server_name"))

; --- semantic_closure_v3_147_nginx_surface ---
((simple_directive name: (directive) @_n (param) @nginx.alias.path) @nginx.alias (#eq? @_n "alias"))
((simple_directive name: (directive) @_n (param) @nginx.return.value) @nginx.return (#eq? @_n "return"))
((simple_directive name: (directive) @_n (param) @nginx.error_page.value) @nginx.error_page (#eq? @_n "error_page"))
((simple_directive name: (directive) @_n (param) @nginx.index.value) @nginx.index (#eq? @_n "index"))
((simple_directive name: (directive) @_n (param) @nginx.fastcgi.target) @nginx.fastcgi (#eq? @_n "fastcgi_pass"))
((simple_directive name: (directive) @_n (param) @nginx.uwsgi.target) @nginx.uwsgi (#eq? @_n "uwsgi_pass"))
((simple_directive name: (directive) @_n (param) @nginx.grpc.target) @nginx.grpc (#eq? @_n "grpc_pass"))
