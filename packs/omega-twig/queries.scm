; --- completeness_bindings ---

(parameter) @binding.symbol @variable.parameter

; --- completeness_calls_3 ---

(function_call) @call.expression

; --- completeness_imports_3 ---

(import_statement) @import.expression @twig.import.statement

; --- external-neovim-distributed-highlights ---

; SOURCE-SYNTACTIC ROLE QUERY adapted from the pinned external highlighting baseline.
; source=neovim-distributed
; original=packs/omega-twig/third_party/neovim-distributed/queries/highlights.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(comment) @comment @spell

(filter_identifier) @function.call

(function_identifier) @function.call

(test) @function.builtin @twig.test.name

(variable) @variable @twig.variable.ref

(string) @string

(interpolated_string) @string

(operator) @operator

(number) @number

(boolean) @boolean

(null) @constant.builtin

(keyword) @keyword

(attribute) @attribute @twig.attribute.ref

(tag) @tag

(conditional) @keyword.conditional

(repeat) @keyword.repeat

(method) @function.method


[
  "{{"
  "}}"
  "{{-"
  "-}}"
  "{{~"
  "~}}"
  "{%"
  "%}"
  "{%-"
  "-%}"
  "{%~"
  "~%}"
] @tag.delimiter

[
  ","
  "."
] @punctuation.delimiter

[
  "?"
  ":"
  "="
  "|"
] @operator

(interpolated_string
  [
    "#{"
    "}"
  ] @punctuation.special)

[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

(hash
  [
    "{"
    "}"
  ] @punctuation.bracket)

; --- twig_structural_semantics ---

(macro_statement
  (method) @twig.macro.name) @twig.macro.owner

(macro_statement
  (parameters
    (parameter) @twig.macro.parameter)) @twig.macro.parameter_owner

(assignment_statement
  (variable) @twig.set.binding) @twig.set.owner

(for_statement
  (variable) @twig.for.binding) @twig.for.owner

(import_statement
  (string) @twig.import.path) @twig.import.owner

(from_statement
  (string) @twig.from.path) @twig.from.owner

(function_call
  (function_identifier) @twig.function.name) @twig.function.owner

(filter
  (filter_identifier) @twig.filter.name) @twig.filter.owner

(template) @twig.template.owner

; --- semantic_closure_v3_146_batch2 ---

(macro_statement (method) @twig.macro.name (parameters) @twig.macro.parameters) @twig.macro.definition
(macro_statement) @twig.macro.scope
(from_statement) @twig.from.statement

; --- semantic_closure_v3_146_batch3 ---

((tag_statement
  (tag) @twig.template_relation.tag
  (string) @twig.template_relation.path) @twig.template_relation
 (#any-of? @twig.template_relation.tag "extends" "include" "use" "embed"))

((tag_statement
  (tag) @twig.block.tag
  (name) @twig.block.name) @twig.block.definition
 (#eq? @twig.block.tag "block"))

((tag_statement
  (tag) @twig.block_end.tag) @twig.block.end
 (#eq? @twig.block_end.tag "endblock"))

((tag_statement
  (tag) @twig.with.tag) @twig.with.scope
 (#eq? @twig.with.tag "with"))

((tag_statement
  (tag) @twig.apply.tag) @twig.apply.scope
 (#eq? @twig.apply.tag "apply"))

