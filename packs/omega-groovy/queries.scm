; --- call_targets ---

(function_call
  function: (_) @call.target) @call.expression

(juxt_function_call
  function: (_) @call.target) @call.expression

; --- completeness_imports ---

(groovy_import) @import.expression

; --- completeness_modules ---

(groovy_package) @module.expression

; --- completeness_types_high_confidence ---

(class_definition) @type.expression

; --- declaration_category_class ---

(class_definition
  name: (_) @definition.category.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_modifiers ---

(class_definition
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- declaration_visibility ---

(class_definition
  (access_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(declaration
  (access_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

; --- definition_identity_hints ---


; --- enclosing_owner_hints ---

(class_definition 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- external-neovim-distributed-locals ---

; Omega coverage-first adapted external query
; source=neovim-distributed language=groovy kind=locals
; original baseline: audit-baselines/external/neovim-distributed/groovy/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(function_definition) @local.scope

(parameter
  name: (identifier) @local.definition.parameter)

(identifier) @local.reference

; --- literal_nested_calls ---

; Direct call whose first argument is a non-interpolated string-content literal.
(function_call
  function: (identifier) @groovy.string_call.name
  args: (argument_list
    . (string
        (string_content) @groovy.string_call.arg0))) @groovy.string_call.call

(juxt_function_call
  function: (identifier) @groovy.string_call.name
  args: (argument_list
    . (string
        (string_content) @groovy.string_call.arg0))) @groovy.string_call.call

; Bounded nested-call ownership through exactly one intermediary closure call.
; Example shape: owner("name") { container { nested ... } }
(function_call
  function: (identifier) @groovy.nested.owner_name
  args: (argument_list
    . (string
        (string_content) @groovy.nested.owner_arg0)
    (closure
      (juxt_function_call
        function: (identifier) @groovy.nested.container_name
        args: (argument_list
          (closure
            (juxt_function_call
              function: (identifier) @groovy.nested.call_name
              args: (argument_list) @groovy.nested.call_args) @groovy.nested.call)) @groovy.nested.container_args) @groovy.nested.container_call))) @groovy.nested.owner_call

; --- member_category_class ---

(class_definition
  name: (_) @owner.name
  body: (closure
    (class_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- module_declaration_path_hints ---

(groovy_package (dotted_identifier) @module.declaration_path.name) @module.declaration_path.span

(groovy_package (identifier) @module.declaration_path.name) @module.declaration_path.span

; --- named_scope_owners ---


; --- nextflow_dsl_context ---

; Framework-neutral Groovy DSL named/anonymous closure declarations and
; direct identifier calls nested in a workflow-like closure.
(juxt_function_call
  function: (identifier) @groovy.dsl.keyword
  args: (argument_list
    (identifier) @groovy.dsl.declared_name
    (closure) @groovy.dsl.body)) @groovy.dsl.named_context

(juxt_function_call
  function: (identifier) @groovy.dsl.anon_keyword
  args: (argument_list
    (closure) @groovy.dsl.anon_body)) @groovy.dsl.anonymous_context

(juxt_function_call
  function: (identifier) @groovy.dsl.outer_keyword
  args: (argument_list
    (closure
      (function_call
        function: (identifier) @groovy.dsl.step_name) @groovy.dsl.step_call))) @groovy.dsl.workflow_context

; --- ownership_members ---


(class_definition
  name: (_) @owner.name
  body: (closure
    (declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- priority_semantics ---

; Omega-owned Groovy semantic enrichment from grammar-backed highlight node shapes.
(class_definition name: (identifier) @definition.class.name) @definition.class
(function_definition function: (identifier) @definition.function.name) @definition.function
(function_declaration function: (identifier) @definition.function.name) @definition.function
(function_call function: (identifier) @call.function.name) @call.function
(juxt_function_call function: (identifier) @call.function.name) @call.function
(parameter type: (identifier) @type.reference name: (identifier) @binding.parameter.name) @binding.parameter

; --- signature_type_parameters ---

(class_definition
  name: (_) @definition.signature.name
  generics: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- spock_class_method_context ---

(class_definition
  name: (identifier) @spock.class.name @groovy.class.name
  superclass: (_) @spock.class.superclass @groovy.class.superclass) @spock.class @groovy.class.inheritance

(class_definition
  name: (identifier) @spock.method.owner
  superclass: (_) @spock.method.superclass
  body: (closure
    (function_definition
      function: (identifier) @spock.method.name) @spock.method)) @spock.method.class

; --- semantic_closure_v3_146_batch2 ---

(annotation (identifier) @groovy.annotation.name) @groovy.annotation
(closure) @groovy.closure

; --- semantic_closure_v3_146_batch3 ---
(groovy_import import: (_) @groovy.import.path import_alias: (identifier)? @groovy.import.alias) @groovy.import
(declaration name: (identifier) @groovy.declaration.name type: (_)? @groovy.declaration.type value: (_)? @groovy.declaration.value) @groovy.declaration
(for_in_loop variable: (identifier) @groovy.for.variable collection: (_) @groovy.for.collection body: (_) @groovy.for.body) @groovy.for
(parameter name: (identifier) @groovy.parameter.name type: (_)? @groovy.parameter.type value: (_)? @groovy.parameter.default) @groovy.parameter

