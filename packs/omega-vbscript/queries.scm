; --- completeness_bindings ---

(parameter) @binding.symbol
(variable_declaration) @binding.symbol

; --- completeness_calls_4 ---

(function_call) @call.expression

; --- completeness_definitions_high_confidence ---

(type_definition) @definition.expression

; --- completeness_references ---

(member_expression) @reference.symbol
(type_member_expression) @reference.symbol

; --- completeness_scopes ---

(ptrsafe_function_declaration) @scope.lexical

; --- completeness_types_high_confidence ---

(type_definition) @type.expression

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; Supplemental structural indexing only; semantic capabilities are exactly those declared and emitted by this Pack.
(_) @structural.node

; --- terminal_vbscript_source_semantics_v1 ---

(function
  (new_identifier (identifier) @vb.function.name)) @vb.function
(subroutine
  (new_identifier (identifier) @vb.subroutine.name)) @vb.subroutine
(ptrsafe_function_declaration
  (new_identifier (identifier) @vb.ptrsafe.name)) @vb.ptrsafe
(parameter
  (new_identifier (identifier) @vb.parameter.name)) @vb.parameter
(variable_declaration_identifier) @vb.variable.name
(function) @vb.function.scope
(subroutine) @vb.subroutine.scope

; --- semantic_closure_v3_146_batch2 ---

(member_expression) @vbscript.member
(type_member_expression) @vbscript.type_member
(array_identifier) @vbscript.array

; --- semantic_closure_v3_146_batch3 ---
(variable_assignment) @vbscript.assignment
(new_expression) @vbscript.new_expression
(redim) @vbscript.redim
(for_statement) @vbscript.for_scope
(do_statement) @vbscript.do_scope
(while_statement) @vbscript.while_scope
(invocation_statement) @vbscript.invocation

