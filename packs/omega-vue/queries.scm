; --- directive ---

(directive_attribute (directive_name) @vue.directive.name) @vue.directive

; --- element_tag ---

[(start_tag (tag_name) @vue.tag.name) @vue.tag (self_closing_tag (tag_name) @vue.tag.name) @vue.tag]

; --- interpolation ---

(interpolation) @vue.interpolation

; --- sfc_component ---

(component) @vue.component

; --- sfc_script ---

(script_element) @vue.script

; --- sfc_style ---

(style_element) @vue.style

; --- sfc_template ---

(template_element) @vue.template

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.

; --- template_attribute_scope ---

(attribute
  (attribute_name) @vue.attribute.name) @vue.attribute

; --- authored_attribute_value ---

(attribute
  (attribute_name) @vue.attribute.value.name
  [
    (attribute_value)
    (quoted_attribute_value)
  ] @vue.attribute.value) @vue.attribute.with_value

; --- directive_value ---

(directive_attribute
  (directive_name) @vue.directive.value.name
  [
    (attribute_value)
    (quoted_attribute_value)
  ] @vue.directive.value) @vue.directive.with_value

; --- directive_argument ---

(directive_attribute
  (directive_name) @vue.directive.argument.name
  [
    (directive_argument)
    (directive_dynamic_argument)
  ] @vue.directive.argument) @vue.directive.with_argument

; --- directive_modifier ---

(directive_attribute
  (directive_name) @vue.directive.modifier.name
  (directive_modifiers
    (directive_modifier) @vue.directive.modifier)) @vue.directive.with_modifier

; --- terminal_dynamic_directive_argument_v1 ---
(directive_attribute
  (directive_name) @vue.directive.dynamic.name
  (directive_dynamic_argument
    (directive_dynamic_argument_value) @vue.directive.dynamic_argument.value)) @vue.directive.dynamic_argument.owner

; --- omega_injection_runtime_v1:vue ---

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

; --- semantic_closure_v3_146_batch2 ---

(directive_attribute (directive_argument) @vue.directive.argument) @vue.directive.argument.owner
(directive_dynamic_argument (directive_dynamic_argument_value) @vue.directive.dynamic.value) @vue.directive.dynamic
(directive_modifier) @vue.directive.modifier
(interpolation (raw_text) @vue.interpolation.expression) @vue.interpolation.semantic
