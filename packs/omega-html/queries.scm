; --- asset-exact-helix-highlights ---

(tag_name) @tag
(erroneous_end_tag_name) @error
(doctype) @constant
(attribute_name) @attribute
(entity) @string.special.symbol
(comment) @comment

((attribute
  (attribute_name) @attribute
  (quoted_attribute_value (attribute_value) @markup.link.url))
 (#any-of? @attribute "href" "src"))

((element
  (start_tag
    (tag_name) @tag)
  (text) @markup.link.label)
  (#eq? @tag "a"))

(attribute [(attribute_value) (quoted_attribute_value)] @string)

((element
  (start_tag
    (tag_name) @tag)
  (text) @markup.bold)
  (#any-of? @tag "strong" "b"))

((element
  (start_tag
    (tag_name) @tag)
  (text) @markup.italic)
  (#any-of? @tag "em" "i"))

((element
  (start_tag
    (tag_name) @tag)
  (text) @markup.strikethrough)
  (#any-of? @tag "s" "del"))

[
  "<"
  ">"
  "</"
  "/>"
  "<!"
] @punctuation.bracket

"=" @punctuation.delimiter

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=html kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/html/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(element) @local.scope

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/html/locals.scm
; sha256=ac78830a6a7eab92a71ba4e5448f104e059ae1e88e355e68a3035191a260be74


; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=376d8a7cb5819a9577c10a49b4ffb02a512744eca10ef9e82adf306e7f44089e
; source_name=html

; ----- resolved nvim injections source: html_tags sha256=1abf3c61023ba40944533f38712580c0fb14bade1479915fc8743fe5381f6d57 -----
((comment) @injection.content
  (#set! injection.language "comment"))

; <style>...</style>
; <style blocking> ...</style>
; Add "lang" to predicate check so that vue/svelte can inherit this
; without having this element being captured twice
((style_element
  (start_tag) @_no_type_lang
  (raw_text) @injection.content)
  (#not-lua-match? @_no_type_lang "%slang%s*=")
  (#not-lua-match? @_no_type_lang "%stype%s*=")
  (#set! injection.language "css"))
((style_element
  (start_tag
    (attribute
      (attribute_name) @_type
      (quoted_attribute_value
        (attribute_value) @_css)))
  (raw_text) @injection.content)
  (#eq? @_type "type")
  (#eq? @_css "text/css")
  (#set! injection.language "css"))
; <script>...</script>
; <script defer>...</script>
((script_element
  (start_tag) @_no_type_lang
  (raw_text) @injection.content)
  (#not-lua-match? @_no_type_lang "%slang%s*=")
  (#not-lua-match? @_no_type_lang "%stype%s*=")
  (#set! injection.language "javascript"))
; <script type="foo/bar">
(script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (#eq? @_attr "type")
      (quoted_attribute_value
        (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#gsub! @injection.language "(.+)/(.+)" "%2"))
; <script type="importmap">
((script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (#eq? @_attr "type")
      (quoted_attribute_value
        (attribute_value) @_type)))
  (raw_text) @injection.content)
  (#eq? @_type "importmap")
  (#set! injection.language "json"))
; <script type="module">
((script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (#eq? @_attr "type")
      (quoted_attribute_value
        (attribute_value) @_type)))
  (raw_text) @injection.content)
  (#eq? @_type "module")
  (#set! injection.language "javascript"))

; <a style="/* css */">
((attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#eq? @_attr "style")
  (#set! injection.language "css"))
; lit-html style template interpolation
; <a @click=${e => console.log(e)}>
; <a @click="${e => console.log(e)}">
((attribute
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#lua-match? @injection.content "%${")
  (#offset! @injection.content 0 2 0 -1)
  (#set! injection.language "javascript"))

((attribute
  (attribute_value) @injection.content)
  (#lua-match? @injection.content "%${")
  (#offset! @injection.content 0 2 0 -2)
  (#set! injection.language "javascript"))
; <input pattern="[0-9]"> or <input pattern=[0-9]>
(element
  (_
    (tag_name) @_tagname
    (#eq? @_tagname "input")
    (attribute
      (attribute_name) @_attr
      [
        (quoted_attribute_value
          (attribute_value) @injection.content)
        (attribute_value) @injection.content
      ]
      (#eq? @_attr "pattern"))
    (#set! injection.language "regex")))
; <input type="checkbox" onchange="this.closest('form').elements.output.value = this.checked">
(attribute
  (attribute_name) @_name
  (#lua-match? @_name "^on[a-z]+$")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript"))

; ----- resolved nvim injections source: html sha256=8fc292c0ba2d60e3808b7a58815d5cb8e7aee94c4d1310b9d1e0eec6b4462ee3 -----
; inherits: html_tags

(element
  (start_tag
    (tag_name) @_py_script)
  (text) @injection.content
  (#any-of? @_py_script "py-script" "py-repl")
  (#set! injection.language "python"))

(script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @_type)))
  (raw_text) @injection.content
  (#eq? @_attr "type")
  ; not adding type="py" here as it's handled by html_tags
  (#any-of? @_type "pyscript" "py-script")
  (#set! injection.language "python"))

(element
  (start_tag
    (tag_name) @_py_config)
  (text) @injection.content
  (#eq? @_py_config "py-config")
  (#set! injection.language "toml"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=ac78830a6a7eab92a71ba4e5448f104e059ae1e88e355e68a3035191a260be74
; resolved_query_sha256=9d563a2864c4e41531ec66260a024656f638f3afed520e755837ec53be269e50
; parser_revision=73a3947324f6efddf9e17c0ea58d454843590cc0
; source_name=html
; direct_inherits=
; resolved_sources=html

; ----- resolved nvim locals source: html sha256=ac78830a6a7eab92a71ba4e5448f104e059ae1e88e355e68a3035191a260be74 -----

; --- static_delta ---

[(start_tag) (self_closing_tag)] @data.element
(attribute) @data.attribute
[(text) (entity)] @data.textual
(script_element) @embedded.script
(style_element) @embedded.style


; --- semantic_closure_v3_146_html_element_attribute_context ---

(start_tag
  (tag_name) @html.ctx.tag
  (attribute
    (attribute_name) @html.ctx.attribute_name
    [(attribute_value) (quoted_attribute_value)] @html.ctx.attribute_value) @html.ctx.attribute) @html.ctx.start_tag

(self_closing_tag
  (tag_name) @html.selfctx.tag
  (attribute
    (attribute_name) @html.selfctx.attribute_name
    [(attribute_value) (quoted_attribute_value)] @html.selfctx.attribute_value) @html.selfctx.attribute) @html.selfctx.tag_node

(element
  (start_tag (tag_name) @html.textctx.tag)
  (text) @html.textctx.text) @html.textctx.element

; --- final_completion_html_owner_aware_resource_urls ---
(start_tag
  (tag_name) @html.resource.tag
  (attribute
    (attribute_name) @html.resource.attribute
    [(attribute_value) (quoted_attribute_value)] @html.resource.url) @html.resource.attribute_node
  (#any-of? @html.resource.attribute "href" "src")) @html.resource.owner

(self_closing_tag
  (tag_name) @html.resource.tag
  (attribute
    (attribute_name) @html.resource.attribute
    [(attribute_value) (quoted_attribute_value)] @html.resource.url) @html.resource.attribute_node
  (#any-of? @html.resource.attribute "href" "src")) @html.resource.owner
