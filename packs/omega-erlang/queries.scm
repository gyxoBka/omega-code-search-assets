; --- behaviour_context ---

((attribute
  name: (atom) @erlang.behaviour.kind
  (arguments . (atom) @erlang.behaviour.name)) @erlang.behaviour.context
  (#any-of? @erlang.behaviour.kind "behaviour" "behavior"))

; --- call_targets ---

(call
  function: (_) @call.target) @call.expression

; --- completeness_scopes ---

(block) @scope.lexical

; --- declaration_category_function ---

(function
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(function_clause
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_macro ---

(macro
  name: (_) @definition.category.macro.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_record ---

(record
  name: (_) @definition.category.record.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---





; --- function_list_context ---

(function_clause
  name: (atom) @erlang.function.name
  pattern: (arguments) @erlang.function.arguments) @erlang.function.clause

((function_clause
  name: (atom) @erlang.list_owner.function_name
  pattern: (arguments) @erlang.list_owner.arguments
  body: (list
    (atom) @erlang.list_owner.item) @erlang.list_owner.list) @erlang.list_owner.clause
  (#eq? @erlang.list_owner.arguments "()"))

; --- named_scope_owners ---

(function
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_clause
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- practical-p0-semantics ---

; Exact pinned Erlang grammar roles.
(function_clause name: (atom) @definition.function.name pattern: (arguments)? @definition.function.parameters body: (_) @definition.function.body) @definition.function
(call module: (atom)? @call.module function: (atom) @call.function) @call
(function_capture module: (atom)? @capture.module @erlang.capture.module function: (atom) @capture.function @erlang.capture.function) @reference.function_capture @erlang.capture
((attribute name: (atom) @attribute.kind (arguments . (atom) @definition.module.name)) @definition.module (#any-of? @attribute.kind "module" "behaviour" "behavior"))
((attribute name: (atom) @attribute.kind (arguments . (atom) @import.module)) @import (#eq? @attribute.kind "import"))
((attribute name: (atom) @attribute.kind (arguments . (atom) @definition.type.name)) @definition.type (#any-of? @attribute.kind "type" "opaque" "nominal"))
((attribute name: (atom) @attribute.kind (arguments . (atom) @definition.record.name)) @definition.record (#eq? @attribute.kind "record"))
(variable) @reference.variable
(function_clause pattern: (arguments (variable) @binding.parameter))
(stab_clause pattern: (arguments (variable) @binding.parameter))

; --- qualified_call_context ---

(call
  module: (atom) @erlang.qualified_call.module
  function: (atom) @erlang.qualified_call.function) @erlang.qualified_call.context

; --- qualified_chain_hints ---

(attribute
  name: (_) @reference.qualified_chain.leaf
  module: (_) @reference.qualified_chain.base
) @reference.qualified_chain.span

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.
(_) @structural.node

; --- semantic_closure_v3_146_batch2 ---

(attribute name: (atom) @erlang.attribute.name) @erlang.attribute
((attribute name: (atom) @_n (arguments) @erlang.behaviour.arguments) @erlang.behaviour (#any-of? @_n "behaviour" "behavior"))
((attribute name: (atom) @_n (arguments) @erlang.callback.arguments) @erlang.callback (#eq? @_n "callback"))
((attribute name: (atom) @_n (arguments) @erlang.spec.arguments) @erlang.spec (#eq? @_n "spec"))
((attribute name: (atom) @_n (arguments) @erlang.export.arguments) @erlang.export (#eq? @_n "export"))

; --- semantic_closure_v3_146_batch3 ---
(binary_operator left: (_) @erlang.send.sender operator: "!" right: (_) @erlang.send.message) @erlang.send
((attribute name: (atom) @_n (arguments) @erlang.include.arguments) @erlang.include (#any-of? @_n "include" "include_lib"))
((attribute name: (atom) @_n (arguments) @erlang.on_load.arguments) @erlang.on_load (#eq? @_n "on_load"))

