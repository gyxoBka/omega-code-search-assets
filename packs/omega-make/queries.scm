; --- call_targets ---

(function_call
  function: (_) @call.target @make.function.name) @call.expression @make.function.call

; --- calls_omega ---

; Omega bounded static call extraction derived from pinned grammar node-types.

; --- completeness_imports_2 ---

(include_directive) @import.expression @reference.path

; --- omega_runtime_minimal ---

; Minimal Omega runtime query against the staged tree-sitter-make node-types.

(variable_assignment) @definition.variable

(shell_assignment) @definition.variable

(define_directive) @definition.variable

(rule
  (targets) @definition.target)

(function_call) @reference.function

; --- target_prerequisites ---

; Direct literal Make target prerequisites only.
; Variable/function/archive-expanded prerequisites intentionally remain outside this D1 subset.
(rule
  (targets
    (word) @make.dep.owner_target)
  normal: (prerequisites
    (word) @make.dep.prerequisite_target)) @make.dep.rule

; --- terminal_make_reference_semantics_v1 ---

(variable_reference) @make.variable.reference
(automatic_variable) @make.automatic.reference @make.automatic.variable

; --- semantic_closure_v3_146_batch2 ---

(recipe) @make.recipe
(recipe_line) @make.recipe.line
(variable_assignment name: (_) @make.variable.name) @make.variable.assignment
(conditional) @make.conditional
(shell_function) @make.shell.function

; --- semantic_closure_v3_147_make_surface ---
(variable_assignment target_or_pattern: (list) @make.target_variable.target name: (word) @make.target_variable.name) @make.target_variable.assignment
(rule (targets (word) @make.order.owner) order_only: (prerequisites (word) @make.order.prerequisite)) @make.order.rule
(define_directive name: (word) @make.define.name) @make.define.definition
(VPATH_assignment value: (paths) @make.vpath.paths) @make.vpath.assignment
(undefine_directive) @make.undefine
(export_directive) @make.export
