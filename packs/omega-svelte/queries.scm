; --- await_bindings ---

(await_block binding: (pattern) @svelte.await.binding) @svelte.await.span

; --- await_scope ---

(await_block) @svelte.scope @svelte.await_block

; --- data_await_block ---


; --- data_declaration_tag ---

(declaration_tag) @svelte.declaration_tag

; --- data_each_block ---

(each_block) @svelte.each_block @svelte.scope

; --- data_if_block ---

(if_block) @svelte.if_block @svelte.scope

; --- data_render_tag ---

(render_tag) @svelte.render_tag

; --- each_bindings ---

(each_block binding: (pattern) @svelte.each.binding) @svelte.each.span

; --- each_scope ---


; --- element_tag ---

[(start_tag name: (tag_name) @svelte.tag.name) @svelte.tag (self_closing_tag name: (tag_name) @svelte.tag.name) @svelte.tag]

; --- event_directive_binding_context ---

; Framework-neutral Svelte attribute directive with authored expression value.
; Captures legacy on:event={handler} shape without resolving handler identity.

(attribute
  name: (attribute_name
    (attribute_directive) @svelte.event.directive
    (attribute_identifier) @svelte.event.name)
  value: (expression) @svelte.event.handler_expression) @svelte.event.binding

; --- if_scope ---


; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=6928e1e9b85792862f41c8a0f92e872ff2d7a0c94b8f7c77fbac70bb3a01c1a2
; resolved_query_sha256=1926847b9a40b4e3d723101e87a067f671b9222be8ed1c97f8cce5a6d2990f2e
; parser_revision=c9b9cc35709fff494a3a9e41cd9471b633649e45
; source_name=svelte
; direct_inherits=html
; resolved_sources=html,svelte

; ----- resolved nvim locals source: html sha256=ac78830a6a7eab92a71ba4e5448f104e059ae1e88e355e68a3035191a260be74 -----
(element) @local.scope

; ----- resolved nvim locals source: svelte sha256=6928e1e9b85792862f41c8a0f92e872ff2d7a0c94b8f7c77fbac70bb3a01c1a2 -----
; inherits: html

; --- snippet_definition ---

(snippet_block name: (snippet_name) @svelte.snippet.name) @svelte.snippet

; --- snippet_parameters ---

(snippet_block name: (snippet_name) @svelte.snippet.owner parameters: (snippet_parameters parameter: (pattern) @svelte.snippet.parameter)) @svelte.snippet.span

; --- snippet_scope ---

(snippet_block) @svelte.scope

; --- svelte_modern_event_attribute_context ---

(attribute
  name: (attribute_name) @svelte.event_attr.name
  value: (expression) @svelte.event_attr.handler) @svelte.event_attr.attribute

; --- terminal_svelte_attribute_key_v2 ---
(attribute name: (attribute_name) @svelte.attribute.name) @svelte.attribute
(attribute name: (attribute_name) @svelte.attribute.value.name value: (_) @svelte.attribute.value) @svelte.attribute.with_value
(shorthand_attribute content: (_) @svelte.attribute.shorthand.value) @svelte.attribute.shorthand
(key_block expression: (_) @svelte.key.expression) @svelte.key.block
(key_block) @svelte.scope

; --- omega_injection_runtime_v1:svelte ---

((element
  (start_tag name: (tag_name) @_tag) @_start
  (raw_text) @injection.content)
  (#eq? @_tag "script")
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "javascript"))

(element
  (start_tag
    name: (tag_name) @_tag
    (attribute
      name: (attribute_name) @_lang
      value: (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_tag "script")
  (#eq? @_lang "lang"))

((element
  (start_tag name: (tag_name) @_tag) @_start
  (raw_text) @injection.content)
  (#eq? @_tag "style")
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "css"))

(element
  (start_tag
    name: (tag_name) @_tag
    (attribute
      name: (attribute_name) @_lang
      value: (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_tag "style")
  (#eq? @_lang "lang"))

; --- semantic_closure_v3_146_batch2 ---

(attribute_directive) @svelte.directive
(shorthand_attribute) @svelte.shorthand.attribute
(expression) @svelte.expression
(each_block binding: (_) @svelte.each.binding expression: (expression) @svelte.each.expression) @svelte.each
(key_block expression: (expression) @svelte.key.expression) @svelte.key


; --- semantic_closure_v3_146_svelte_directive_context ---
(attribute
  name: (attribute_name
    (attribute_directive) @svelte.directive_ctx.directive
    (attribute_identifier)? @svelte.directive_ctx.identifier)
  value: (expression)? @svelte.directive_ctx.value) @svelte.directive_ctx.attribute

(render_tag expression: (expression_value) @svelte.render.expression) @svelte.render.context
