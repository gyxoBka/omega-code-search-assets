; --- completeness_bindings ---

(parameter) @binding.symbol

; --- external-neovim-distributed-highlights ---

; SOURCE-SYNTACTIC ROLE QUERY adapted from the pinned external highlighting baseline.
; source=neovim-distributed
; original=packs/omega-blade/third_party/neovim-distributed/queries/highlights.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; inherits: html

[
  (directive)
  (directive_start)
  (directive_end)
] @tag

; --- html_attribute_name_context ---

(attribute
  (attribute_name) @blade.attribute.name) @blade.attribute.context

; --- authored_attribute_value ---

(attribute
  (attribute_name) @blade.attribute.value.name
  [
    (attribute_value)
    (quoted_attribute_value)
    (parameter)
    (php_statement)
  ] @blade.attribute.value) @blade.attribute.with_value

; --- terminal_blade_structure_v1 ---
(section) @blade.section
(directive) @blade.directive
[
  (section)
  (loop)
  (conditional)
  (switch)
] @blade.scope

; --- omega_injection_runtime_v1:blade ---

((php_statement (php_only) @injection.content)
  (#set! injection.language "php"))

; --- semantic_closure_v3_146_blade_directives ---

((section
   (directive) @blade.section.directive
   (parameter) @blade.section.name) @blade.section.context
 (#match? @blade.section.directive "^@section$"))

((section
   (directive) @blade.yield.directive
   (parameter) @blade.yield.name) @blade.yield.context
 (#match? @blade.yield.directive "^@yield$"))

((section
   (directive) @blade.extends.directive
   (parameter) @blade.extends.target) @blade.extends.context
 (#match? @blade.extends.directive "^@extends$"))

((section
   (directive) @blade.include.directive
   (parameter) @blade.include.target) @blade.include.context
 (#match? @blade.include.directive "^@(include|includeIf|includeWhen|includeUnless|includeFirst|each)$"))

((section
   (directive) @blade.component.directive
   (parameter) @blade.component.target) @blade.component.context
 (#match? @blade.component.directive "^@(component|livewire)$"))

((stack
   (directive) @blade.stack.directive
   (parameter) @blade.stack.name) @blade.stack.context
 (#match? @blade.stack.directive "^@(stack|push|prepend)$"))

((directive) @blade.directive.named
 (#match? @blade.directive.named "^@(auth|guest|can|cannot|canany|env|production|once|php|csrf|method|error|verbatim|aware|props)$"))
