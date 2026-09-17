; --- call_targets ---

(call
  function: (_) @call.target) @call.expression

; --- definition_identity_hints ---

(binary_operator
  lhs: (identifier) @definition.identity.name
  operator: "<-"
  rhs: (function_definition)) @definition.identity.owner

; --- named_scope_owners ---

(binary_operator
  lhs: (identifier) @scope.owner.name
  operator: "<-"
  rhs: (function_definition
    body: (_) @scope.owner.body)) @scope.owner

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=f492d0f06b7716a5e6ecd606ef5b09bf7362481ad46e01dfedb4637a5b232e3c
; resolved_query_sha256=9f981a11cc7be6d96a4851824c5320391a00aeb0d178e1cc8f5cede580952fdd
; parser_revision=0e6ef7741712c09dc3ee6e81c42e919820cc65ef
; source_name=r
; direct_inherits=
; resolved_sources=r

; ----- resolved nvim locals source: r sha256=f492d0f06b7716a5e6ecd606ef5b09bf7362481ad46e01dfedb4637a5b232e3c -----
; locals.scm
(function_definition) @local.scope

(argument
  name: (identifier) @local.definition)
(parameter name: (identifier) @local.definition @binding.parameter.name) @binding.parameter

(binary_operator
  lhs: (identifier) @local.definition
  operator: "<-")

(binary_operator
  lhs: (identifier) @local.definition
  operator: "=")

(binary_operator
  operator: "->"
  rhs: (identifier) @local.definition)

; --- ownership_parameters ---

(binary_operator
  lhs: (identifier) @owner.name
  operator: "<-"
  rhs: (function_definition
    parameters: (parameters) @owned.parameters)) @owner.span

; --- priority_semantics ---

; Omega-owned R semantic enrichment from exact grammar node/field facts.
(binary_operator lhs: (identifier) @definition.function.name operator: ["<-" "="] rhs: (function_definition)) @definition.function
(call function: (identifier) @call.function.name) @call.function
(call function: (namespace_operator rhs: (identifier) @call.function.name)) @call.function
(namespace_operator lhs: (identifier) @module.name) @module.reference

; --- qualified_call_assignment_identifier_context ---

; Framework-neutral authored R fact:
; direct local identifier assignment from a fully-qualified package::function call
; whose first argument is itself a direct identifier. No pipe expansion, NSE,
; runtime evaluation, member lookup or implicit package resolution is performed.
(binary_operator
  lhs: (identifier) @r.qualified_transform.output_name
  operator: ["<-" "="]
  rhs: (call
    function: (namespace_operator
      lhs: (identifier) @r.qualified_transform.package_name
      operator: "::"
      rhs: (identifier) @r.qualified_transform.function_name)
    arguments: (arguments
      . (argument
          value: (identifier) @r.qualified_transform.input_name)))) @r.qualified_transform.context

; --- qualified_call_assignment_literal_context ---

; Framework-neutral authored R source binding from a fully-qualified call
; whose first argument is a direct string literal. No file access/runtime evaluation occurs.
(binary_operator
  lhs: (identifier) @r.qualified_literal.output_name
  operator: ["<-" "="]
  rhs: (call
    function: (namespace_operator
      lhs: (identifier) @r.qualified_literal.package_name
      operator: "::"
      rhs: (identifier) @r.qualified_literal.function_name)
    arguments: (arguments
      . (argument
          value: (string) @r.qualified_literal.literal_value)))) @r.qualified_literal.context

; --- qualified_call_context ---

; Framework-neutral authored R fact: direct fully-qualified package::function(...) call source site.
; No package loading, NSE evaluation, runtime execution, pipe expansion or alias resolution.
(call
  function: (namespace_operator
    lhs: (identifier) @r.qualified_call.package_name
    operator: "::"
    rhs: (identifier) @r.qualified_call.function_name)
  arguments: (arguments)) @r.qualified_call.context

; --- semantic_closure_v3_146_batch2 ---

(namespace_operator lhs: (_) @r.namespace.package rhs: (_) @r.namespace.member) @r.namespace
(for_statement variable: (identifier) @r.for.binding sequence: (_) @r.for.sequence) @r.for
(binary_operator operator: ["|>" "special"] @r.pipe.operator) @r.pipe
((call function: (identifier) @r.package.call.name) @r.package.call (#any-of? @r.package.call.name "library" "require" "requireNamespace"))

; --- semantic_closure_v3_146_batch3 ---

(binary_operator
  lhs: (_) @r.formula.lhs
  operator: "~"
  rhs: (_) @r.formula.rhs) @r.formula

(extract_operator
  lhs: (_) @r.extract.owner
  operator: ["$" "@"] @r.extract.operator
  rhs: (_) @r.extract.member) @r.extract

(subset
  function: (_) @r.subset.target
  arguments: (arguments) @r.subset.arguments) @r.subset

(subset2
  function: (_) @r.subset2.target
  arguments: (arguments) @r.subset2.arguments) @r.subset2

((binary_operator
  lhs: (identifier) @r.class.binding
  operator: ["<-" "="]
  rhs: (call
    function: (identifier) @r.class.factory)) @r.class.assignment
 (#any-of? @r.class.factory "setClass" "setRefClass" "R6Class"))

((binary_operator
  lhs: (identifier) @r.class.binding
  operator: ["<-" "="]
  rhs: (call
    function: (namespace_operator
      lhs: (identifier) @r.class.package
      rhs: (identifier) @r.class.factory))) @r.class.qualified_assignment
 (#any-of? @r.class.factory "setClass" "setRefClass" "R6Class"))

