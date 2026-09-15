; --- calls ---

; Omega call facts for GDScript. Bounded to syntax visible in tree-sitter-gdscript.

(call
  (identifier) @call.target) @call.expression

(attribute_call
  (identifier) @call.target) @call.expression

(base_call
  (identifier) @call.target) @call.expression

; --- completeness_types_high_confidence ---

(class_definition) @type.expression
(enum_definition) @type.expression

; --- declaration_category_class ---

(class_definition
  name: (_) @definition.category.class.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_definition
  name: (_) @definition.category.enum.name
) @definition.category.owner

; --- declaration_category_function ---

(function_definition
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- definition_identity_hints ---

(class_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(function_definition
  name: (_) @definition.identity.name) @definition.identity.owner

; --- enclosing_owner_hints ---

(class_definition 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- named_scope_owners ---

(class_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=b40c6fdfe8670ff0f73fb55f96c8d80c1233c4de50aea656a60a5a3414ba3794
; resolved_query_sha256=7cdeee60974931981bbce5fa66f7f4e44e2b3e87aeebfb561b646ad513123b5b
; parser_revision=1f1e782fe2600f50ae57b53876505b8282388d77
; source_name=gdscript
; direct_inherits=
; resolved_sources=gdscript

; ----- resolved nvim locals source: gdscript sha256=b40c6fdfe8670ff0f73fb55f96c8d80c1233c4de50aea656a60a5a3414ba3794 -----
; Scopes
[
  (if_statement)
  (elif_clause)
  (else_clause)
  (for_statement)
  (while_statement)
  (function_definition)
  (constructor_definition)
  (class_definition)
  (match_statement)
  (pattern_section)
  (lambda)
  (get_body)
  (set_body)
] @local.scope

; Parameters
(parameters
  (identifier) @local.definition.parameter)

(default_parameter
  (identifier) @local.definition.parameter)

(typed_parameter
  (identifier) @local.definition.parameter)

(typed_default_parameter
  (identifier) @local.definition.parameter)

; Signals
; Can gdscript 2 signals be considered fields?
(signal_statement
  (name) @local.definition.field)

; Variable Definitions
(const_statement
  (name) @local.definition.constant)

; onready and export variations are only properties.
(variable_statement
  (name) @local.definition.var)

(setter) @local.reference

(getter) @local.reference

; Function Definition
((function_definition
  (name) @local.definition.function)
  (#set! definition.function.scope "parent"))

; Lambda
; lambda names are not accessible and are only for debugging.
(lambda
  (name) @local.definition.function)

; Source
(class_name_statement
  (name) @local.definition.type)

(source
  (variable_statement
    (name) @local.definition.field))

(source
  (onready_variable_statement
    (name) @local.definition.field))

(source
  (export_variable_statement
    (name) @local.definition.field))

; Class
((class_definition
  (name) @local.definition.type)
  (#set! definition.type.scope "parent"))

(class_definition
  (body
    (variable_statement
      (name) @local.definition.field)))

(class_definition
  (body
    (onready_variable_statement
      (name) @local.definition.field)))

(class_definition
  (body
    (export_variable_statement
      (name) @local.definition.field)))

(class_definition
  (body
    (signal_statement
      (name) @local.definition.field)))

; Although a script is also a class, let's only define functions in an inner class as
; methods.
((class_definition
  (body
    (function_definition
      (name) @local.definition.method)))
  (#set! definition.method.scope "parent"))

; Enum
(enum_definition
  (name) @local.definition.enum)

; Repeat
(for_statement
  .
  (identifier) @local.definition.var)

; Match Statement
(pattern_binding
  (identifier) @local.definition.var)

; References
(identifier) @local.reference

; --- ownership_members ---

(class_definition
  name: (_) @owner.name
  body: (body
    (export_variable_statement
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_definition
  name: (_) @owner.name
  body: (body
    (onready_variable_statement
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_definition
  name: (_) @owner.name
  body: (body
    (variable_statement
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- ownership_parameters ---

(function_definition
  name: (_) @owner.name
  parameters: (parameters
    (_parameters) @owned.parameter)) @owner.span

; --- signature_parameters ---

(function_definition
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(function_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- terminal_gdscript_source_semantics_v1 ---

(extends_statement
  (string) @gdscript.extends.target) @gdscript.extends
(extends_statement
  (type) @gdscript.extends.target) @gdscript.extends
(enumerator
  left: (identifier) @gdscript.enum.member) @gdscript.enum.member.owner
(constructor_definition) @gdscript.constructor

; --- semantic_closure_v3_146_batch2 ---

(signal_statement (name) @gdscript.signal.name) @gdscript.signal
(class_name_statement (name) @gdscript.class_name.name) @gdscript.class_name
(export_variable_statement name: (name) @gdscript.export.name) @gdscript.export
(onready_variable_statement name: (name) @gdscript.onready.name) @gdscript.onready
((call (identifier) @_fn) @gdscript.resource.load (#any-of? @_fn "preload" "load"))

; --- semantic_closure_v3_146_batch4 ---

(signal_statement
  (name) @gdscript.signal.typed.name
  (parameters) @gdscript.signal.parameters) @gdscript.signal.typed

(class_name_statement
  (name) @gdscript.class_name.typed.name
  icon_path: (string)? @gdscript.class_name.icon) @gdscript.class_name.typed

(export_variable_statement
  name: (name) @gdscript.export.typed.name
  type: (_) @gdscript.export.type
  value: (_expression)? @gdscript.export.value) @gdscript.export.typed

(onready_variable_statement
  name: (name) @gdscript.onready.typed.name
  type: (_) @gdscript.onready.type
  value: (_expression)? @gdscript.onready.value) @gdscript.onready.typed

(annotation
  (identifier) @gdscript.annotation.name
  (arguments)? @gdscript.annotation.arguments) @gdscript.annotation

