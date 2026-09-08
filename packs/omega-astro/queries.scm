; --- element_tag ---

[(start_tag (tag_name) @astro.tag.name) @astro.tag (self_closing_tag (tag_name) @astro.tag.name) @astro.tag]

; --- frontmatter ---

(frontmatter) @astro.frontmatter

; --- interpolation ---

(interpolation) @astro.interpolation

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=6928e1e9b85792862f41c8a0f92e872ff2d7a0c94b8f7c77fbac70bb3a01c1a2
; resolved_query_sha256=e4ffd052c89eedff08687ef49a3fd1c04501257449c393b90b2b24bcb61800d5
; parser_revision=947e93089e60c66e681eba22283f4037841451e7
; source_name=astro
; direct_inherits=html
; resolved_sources=html,astro

; ----- resolved nvim locals source: html sha256=ac78830a6a7eab92a71ba4e5448f104e059ae1e88e355e68a3035191a260be74 -----
(element) @local.scope

; ----- resolved nvim locals source: astro sha256=6928e1e9b85792862f41c8a0f92e872ff2d7a0c94b8f7c77fbac70bb3a01c1a2 -----
; inherits: html

; --- script ---

(script_element) @astro.script

; --- style ---

(style_element) @astro.style

; --- template_attribute_scope ---

(attribute
  (attribute_name) @astro.attribute.name) @astro.attribute

(element) @astro.element.scope

; --- authored_attribute_value ---

(attribute
  (attribute_name) @astro.attribute.value.name
  [
    (attribute_value)
    (quoted_attribute_value)
    (interpolation)
  ] @astro.attribute.value) @astro.attribute.with_value

; --- frontmatter_scope ---

(frontmatter) @astro.frontmatter.scope

; --- omega_injection_runtime_v1:astro ---

((frontmatter (raw_text) @injection.content)
  (#set! injection.language "typescript"))

((script_element
  (start_tag) @_start
  (raw_text) @injection.content)
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "javascript"))

(script_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_lang "lang"))

((style_element
  (start_tag) @_start
  (raw_text) @injection.content)
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "css"))

(style_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_lang "lang"))
