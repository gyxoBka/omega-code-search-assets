; --- calls_references ---

; Exact pinned tree-sitter-batch node shapes.
(call_stmt (command_name) @call.target) @call.statement
(call_stmt (variable_reference) @reference.dynamic_call_target)
(cmd (command_name) @call.command) @call.command_statement
(variable_reference) @reference.variable

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=batch kind=tags
; original baseline: audit-baselines/external/helix/batch/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(label) @definition.function

(variable_assignment
  (set_keyword)
  (variable_name) @definition.constant)

; --- helix_independent_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED from normalized exact-grammar AST evidence only.
; Helix MPL query body is NOT copied. language=batch
(label) @structural.candidate

; --- p1-exact-helix-tags ---

; Omega P1 exact-revision enrichment
; source=helix language=batch file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/batch/tags.scm

(label) @definition.function

(variable_assignment
  (set_keyword)
  (variable_name) @definition.constant)

; --- terminal_batch_for_semantics_v1 ---

(for_variable) @batch.for.variable
(for_stmt) @batch.for.scope

; --- semantic_closure_v3_146_batch2 ---

(variable_assignment (variable_name) @batch.assignment.name) @batch.assignment
(arithmetic_assignment) @batch.arithmetic.assignment
(for_stmt (for_variable) @batch.for.binding) @batch.for
(variable_reference) @batch.variable.reference
(call_stmt) @batch.call.statement

; --- semantic_closure_v3_146_batch4 ---

(prompt_assignment
  (variable_name) @batch.prompt.name
  [(assignment_value) (quoted_assignment_value)] @batch.prompt.value) @batch.prompt.assignment

(for_set) @batch.for.set
(setlocal_stmt) @batch.setlocal
(assignment_paren_group) @batch.assignment.group
(if_stmt) @batch.if.scope

