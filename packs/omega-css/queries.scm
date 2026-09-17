; --- completeness_imports_3 ---

(import_statement) @import.expression

; --- completeness_modules_6 ---

(namespace_statement) @module.expression

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=0001d93c2787981b132f3316a6c18c63ffb82b582c80ea5b025613161cbd75c3
; source_name=css

; ----- resolved nvim highlights source: css sha256=0001d93c2787981b132f3316a6c18c63ffb82b582c80ea5b025613161cbd75c3 -----
[
  "@media"
  "@charset"
  "@namespace"
  "@supports"
  "@keyframes"
  (at_keyword)
] @keyword.directive

"@import" @keyword.import

[
  (to)
  (from)
] @keyword

(comment) @comment @spell

(tag_name) @tag

(class_name) @type

(id_name) @constant

[
  (property_name)
  (feature_name)
] @property

(function_name) @function

[
  "~"
  ">"
  "+"
  "-"
  "*"
  "/"
  "="
  "^="
  "|="
  "~="
  "$="
  "*="
] @operator

[
  "and"
  "or"
  "not"
  "only"
] @keyword.operator

(important) @keyword.modifier

[
  (nesting_selector)
  (universal_selector)
] @character.special

(attribute_selector
  (plain_value) @string)

(pseudo_element_selector
  "::"
  (tag_name) @attribute)

(pseudo_class_selector
  (class_name) @attribute)

(attribute_name) @tag.attribute

(namespace_name) @module

(keyframes_name) @variable

((property_name) @variable
  (#lua-match? @variable "^[-][-]"))

((plain_value) @variable
  (#lua-match? @variable "^[-][-]"))

[
  (string_value)
  (color_value)
  (unit)
] @string

(integer_value) @number

(float_value) @number.float

[
  "#"
  ","
  "."
  ":"
  "::"
  ";"
] @punctuation.delimiter

[
  "{"
  ")"
  "("
  "}"
  "["
  "]"
] @punctuation.bracket

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=e8bc96da2faabe257a32d805d3954e200215d94a85fce4d521530c89e0969244
; source_name=css

; ----- resolved nvim injections source: css sha256=e8bc96da2faabe257a32d805d3954e200215d94a85fce4d521530c89e0969244 -----
((comment) @injection.content
  (#set! injection.language "comment"))


; --- terminal_css_source_semantics_v1 ---
(call_expression (function_name) @css.call.name @css.function.name) @css.call @css.function.call
(class_selector (class_name) @css.class.name) @css.class.selector
(id_selector (id_name) @css.id.name) @css.id.selector
(keyframes_statement (keyframes_name) @css.keyframes.name @css.keyframes.strong.name) @css.keyframes @css.keyframes.strong
(declaration (property_name) @css.declaration.property) @css.declaration
(import_statement (string_value) @css.import.path) @css.import.path_owner

; --- semantic_closure_v3_146_batch2 ---

((declaration (property_name) @css.custom_property.name) @css.custom_property (#match? @css.custom_property.name "^--"))
((call_expression (function_name) @_var (arguments) @css.var.arguments) @css.var.reference (#eq? @_var "var"))
[(child_selector) (descendant_selector) (adjacent_sibling_selector) (sibling_selector)] @css.selector.combinator

; --- semantic_closure_v3_147_css_surface ---
((declaration (property_name) @_animation_name (plain_value) @css.animation.name) @css.animation.reference (#eq? @_animation_name "animation-name"))
(media_statement) @css.media.rule
(supports_statement) @css.supports.rule
