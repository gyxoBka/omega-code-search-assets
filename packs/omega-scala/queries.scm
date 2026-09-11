; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- completeness_modules ---

(package_clause) @module.expression

; --- completeness_types_high_confidence ---

(class_definition) @type.expression
(enum_definition) @type.expression
(trait_definition) @type.expression
(type_definition) @type.expression

; --- declaration_category_class ---

(class_definition
  name: (_) @definition.category.name
) @definition.category.owner

(class_parameter
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_definition
  name: (_) @definition.category.name
) @definition.category.owner

(full_enum_case
  name: (_) @definition.category.name
) @definition.category.owner

(simple_enum_case
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(function_definition
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_package ---

(package_clause
  name: (_) @definition.category.name
) @definition.category.owner

(package_object
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_trait ---

(trait_definition
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_type ---

(type_definition
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_modifiers ---

(class_definition
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(class_parameter
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(enum_definition
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(function_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(function_definition
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(given_definition
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(object_definition
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(trait_definition
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(type_definition
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(val_declaration
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(var_declaration
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- declaration_visibility ---

(class_definition
  name: (_) @definition.visibility.name
  (access_modifier) @definition.visibility.modifier
) @definition.visibility.owner

(enum_definition
  name: (_) @definition.visibility.name
  (access_modifier) @definition.visibility.modifier
) @definition.visibility.owner

(trait_definition
  name: (_) @definition.visibility.name
  (access_modifier) @definition.visibility.modifier
) @definition.visibility.owner

; --- definition_identity_hints ---

(class_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(function_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(function_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(package_clause
  name: (_) @definition.identity.name) @definition.identity.owner

(package_object
  name: (_) @definition.identity.name) @definition.identity.owner

(trait_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(type_definition
  name: (_) @definition.identity.name) @definition.identity.owner

; --- enclosing_owner_hints ---

(class_definition 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(trait_definition 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=scala kind=tags
; original baseline: audit-baselines/external/helix/scala/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(class_definition name: (identifier) @name) @definition.class
(object_definition name: (identifier) @name) @definition.module
(trait_definition name: (identifier) @name) @definition.interface
(enum_definition name: (identifier) @name) @definition.enum
(function_definition name: (identifier) @name) @definition.function
(val_definition pattern: (identifier) @name) @definition.constant
(var_definition pattern: (identifier) @name) @definition.constant
(type_definition name: (type_identifier) @name) @definition.type
(given_definition name: (identifier) @name) @definition.constant

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=scala kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/scala/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Scopes
[
  (template_body)
  (lambda_expression)
  (function_definition)
  (block)
  (for_expression)
] @local.scope

; References
(identifier) @local.reference

; Definitions
(function_declaration
  name: (identifier) @local.definition.function)

(function_definition
  name: (identifier) @local.definition.function
  (#set! definition.var.scope parent))

(parameter
  name: (identifier) @local.definition.parameter)

(class_parameter
  name: (identifier) @local.definition.parameter)

(lambda_expression
  parameters: (identifier) @local.definition.var)

(binding
  name: (identifier) @local.definition.var)

(val_definition
  pattern: (identifier) @local.definition.var)

(var_definition
  pattern: (identifier) @local.definition.var)

(val_declaration
  name: (identifier) @local.definition.var)

(var_declaration
  name: (identifier) @local.definition.var)

(for_expression
  enumerators: (enumerators
    (enumerator
      (tuple_pattern
        (identifier) @local.definition.var))))

; --- import_targets ---

(import_declaration
  path: (_) @import.target) @import.statement

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/scala/locals.scm
; sha256=06d053fab0a77e337bbf753f519b7645d74cf61cb596c9f8fb9bc817ad2abfe4
; Scopes
[
  (template_body)
  (lambda_expression)
  (function_definition)
  (block)
  (for_expression)
] @local.scope

; References
(identifier) @local.reference

; Definitions
(function_declaration
  name: (identifier) @local.definition.function)

(function_definition
  name: (identifier) @local.definition.function
  (#set! definition.var.scope parent))

(parameter
  name: (identifier) @local.definition.parameter)

(class_parameter
  name: (identifier) @local.definition.parameter)

(lambda_expression
  parameters: (identifier) @local.definition.var)

(binding
  name: (identifier) @local.definition.var)

(val_definition
  pattern: (identifier) @local.definition.var)

(var_definition
  pattern: (identifier) @local.definition.var)

(val_declaration
  name: (identifier) @local.definition.var)

(var_declaration
  name: (identifier) @local.definition.var)

(for_expression
  enumerators: (enumerators
    (enumerator
      (tuple_pattern
        (identifier) @local.definition.var))))

; --- member_access_hints ---

(field_expression
  value: (_) @reference.receiver
  field: (_) @reference.member) @reference.member_expression

; --- module_declaration_path_hints ---

(package_clause
  name: (_) @module.declaration_path.name
) @module.declaration_path.span

; --- module_path_hints ---

(import_declaration 
  path: (_) @import.module_path.target
) @import.module_path.statement

; --- named_scope_owners ---

(class_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(object_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(package_object
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(trait_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_parameters ---

(function_declaration
  name: (_) @owner.name
  parameters: (parameters
    (lazy_parameter_type) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (parameters
    (parameter) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (parameters
    (repeated_parameter_type) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (type_parameters
    (contravariant_type_parameter) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (type_parameters
    (covariant_type_parameter) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (parameters
    (lazy_parameter_type) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (parameters
    (parameter) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (parameters
    (repeated_parameter_type) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (type_parameters
    (contravariant_type_parameter) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (type_parameters
    (covariant_type_parameter) @owned.parameter)) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=scala file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/scala/locals.scm

; Scopes

[
  (template_body)
  (function_definition)
  (lambda_expression)
  (for_expression)
  (block)
  (case_clause)
] @local.scope

; Definitions

(function_definition
  name: (identifier) @local.definition.function)

; `def`/method and `class`/constructor parameters; baseline highlight is plain
; `variable`, so the parameter class is what makes these distinct.
(parameter
  name: (identifier) @local.definition.variable.parameter)
(class_parameter
  name: (identifier) @local.definition.variable.parameter)

; Lambda parameters: `(x: Int) => …` (bindings) and bare `x => …`.
(bindings
  (binding
    name: (identifier) @local.definition.variable.parameter))
(lambda_expression
  parameters: (identifier) @local.definition.variable.parameter)

(type_parameters
  name: (identifier) @local.definition.type.parameter)

; Local `val`/`var` bindings; defined so inner references resolve and shadow.
(val_definition
  pattern: (identifier) @local.definition.variable)
(var_definition
  pattern: (identifier) @local.definition.variable)

; References

(identifier) @local.reference

; Member access after `.` is a field/method name, not a local reference.
(field_expression
  field: (identifier) @_)

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=scala file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/scala/tags.scm

(class_definition name: (identifier) @name) @definition.class
(object_definition name: (identifier) @name) @definition.module
(trait_definition name: (identifier) @name) @definition.interface
(enum_definition name: (identifier) @name) @definition.enum
(function_definition name: (identifier) @name) @definition.function
(val_definition pattern: (identifier) @name) @definition.constant
(var_definition pattern: (identifier) @name) @definition.constant
(type_definition name: (type_identifier) @name) @definition.type
(given_definition name: (identifier) @name) @definition.constant

; --- reexport_hints ---

(export_declaration 
  path: (_) @module.reexport.target
) @module.reexport.statement

; --- signature_parameters ---

(function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_definition
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(function_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(class_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(contravariant_type_parameter
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(covariant_type_parameter
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(enum_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(full_enum_case
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(given_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(trait_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_lambda
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_parameters
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- static_delta ---

(import_declaration
  path: (_) @import.path) @import.statement

(extends_clause) @relation.extends

; --- upstream_tags ---

; Definitions

(package_clause
  name: (package_identifier) @name) @definition.module

(trait_definition
  name: (identifier) @name) @definition.interface

(enum_definition
  name: (identifier) @name) @definition.enum

(simple_enum_case
  name: (identifier) @name) @definition.class

(full_enum_case
  name: (identifier) @name) @definition.class

(class_definition
  name: (identifier) @name) @definition.class

(object_definition
  name: (identifier) @name) @definition.object

(function_definition
  name: (identifier) @name) @definition.function

(val_definition
  pattern: (identifier) @name) @definition.variable

(given_definition
  name: (identifier) @name) @definition.variable

(var_definition
  pattern: (identifier) @name) @definition.variable

(val_declaration
  name: (identifier) @name) @definition.variable

(var_declaration
  name: (identifier) @name) @definition.variable

(type_definition
  name: (type_identifier) @name) @definition.type

(class_parameter
  name: (identifier) @name) @definition.property

; References 

(call_expression
  (identifier) @name) @reference.call

(instance_expression
  (type_identifier) @name) @reference.interface

(instance_expression
  (generic_type
    (type_identifier) @name)) @reference.interface

(extends_clause
  (type_identifier) @name) @reference.class

(extends_clause
  (generic_type
    (type_identifier) @name)) @reference.class
