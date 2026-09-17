; --- completeness_imports_6 ---

(import_header) @import.expression

; --- completeness_modules_3 ---

(package_header) @module.expression

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression

; --- composable_owner_calls ---

; Framework-neutral Kotlin annotated-function and direct top-level call context.
; No Compose semantics here: annotation/function/callee names are emitted as authored syntax only.
(function_declaration
  (modifiers
    (annotation
      (user_type
        (type_identifier) @kotlin.annotated.annotation)))
  (simple_identifier) @kotlin.annotated.function_name
  (function_body) @kotlin.annotated.body) @kotlin.annotated.function

(function_declaration
  (modifiers
    (annotation
      (user_type
        (type_identifier) @kotlin.annotated_call.annotation)))
  (simple_identifier) @kotlin.annotated_call.owner_name
  (function_body
    (statements
      (call_expression
        (simple_identifier) @kotlin.annotated_call.callee_name) @kotlin.annotated_call.call))
  @kotlin.annotated_call.body) @kotlin.annotated_call.owner

; --- declaration_category_class ---

(class_declaration
  (type_identifier) @definition.category.class.name @definition.identity.name @name
) @definition.category.owner @definition.identity.owner @definition.class

; --- declaration_category_component ---

(object_declaration
  (type_identifier) @definition.category.component.name @definition.identity.name @name
) @definition.category.owner @definition.identity.owner @definition.class

; --- declaration_category_function ---

(function_declaration
  (simple_identifier) @definition.category.function.name @definition.identity.name @name
) @definition.category.owner @definition.identity.owner @definition.function

; --- declaration_category_type ---

(type_alias
  (type_identifier) @definition.category.type.name @definition.identity.name @name
) @definition.category.owner @definition.identity.owner @definition.type

; --- declaration_modifiers ---

(function_declaration
  (modifiers) @definition.modifiers.modifier
  (simple_identifier) @definition.modifiers.name
) @definition.modifiers.owner

(class_declaration
  (modifiers) @definition.modifiers.modifier
  (type_identifier) @definition.modifiers.name
) @definition.modifiers.owner

; --- definition_identity_hints ---





; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=kotlin kind=tags
; original baseline: audit-baselines/external/helix/kotlin/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(class_declaration
  (type_identifier) @definition.class)

(object_declaration
  "object" (type_identifier) @definition.class)

(function_declaration
  (simple_identifier) @definition.function)

(property_declaration
  (variable_declaration
    (simple_identifier) @definition.constant))

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=kotlin kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/kotlin/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Imports
(package_header
  .
  (identifier) @local.definition.namespace)

(import_header
  (identifier
    (simple_identifier) @local.definition.import .)
  (import_alias
    (type_identifier) @local.definition.import)?)

; Functions
(function_declaration
  .
  (simple_identifier) @local.definition.function
  (#set! definition.function.scope "parent"))

(class_body
  (function_declaration
    .
    (simple_identifier) @local.definition.method)
  (#set! definition.method.scope "parent"))

; Variables
(function_declaration
  (function_value_parameters
    (parameter
      (simple_identifier) @local.definition.parameter)))

(lambda_literal
  (lambda_parameters
    (variable_declaration
      (simple_identifier) @local.definition.parameter @local.definition.variable.parameter)))

; NOTE: temporary fix for treesitter bug that causes delay in file opening
;(class_body
;  (property_declaration
;    (variable_declaration
;      (simple_identifier) @local.definition.field)))
(class_declaration
  (primary_constructor
    (class_parameter
      (simple_identifier) @local.definition.field)))

(enum_class_body
  (enum_entry
    (simple_identifier) @local.definition.field))

(variable_declaration
  (simple_identifier) @local.definition.var @local.definition.variable)

; Types
(class_declaration
  (type_identifier) @local.definition.type
  (#set! definition.type.scope "parent"))

(type_alias
  (type_identifier) @local.definition.type
  (#set! definition.type.scope "parent"))

; Scopes
[
  (if_expression)
  (when_expression)
  (when_entry)
  (for_statement)
  (while_statement)
  (do_while_statement)
  (lambda_literal)
  (function_declaration)
  (primary_constructor)
  (secondary_constructor)
  (anonymous_initializer)
  (class_declaration)
  (enum_class_body)
  (enum_entry)
  (interpolated_expression)
] @local.scope

; --- import_targets ---

(import_header
  (identifier) @import.target @import.module_path.target) @import.statement @import.module_path.statement

; --- literal_call_context ---

; Framework-neutral Kotlin direct simple call with first non-interpolated string literal.
(call_expression
  (simple_identifier) @kotlin.string_call.name
  (call_suffix
    (value_arguments
      . (value_argument
          (string_literal
            (string_content) @kotlin.string_call.arg0))))) @kotlin.string_call.call

; Framework-neutral Kotlin member call receiver.member("literal").
(call_expression
  (navigation_expression
    (simple_identifier) @kotlin.member_string_call.receiver
    (navigation_suffix
      (simple_identifier) @kotlin.member_string_call.member))
  (call_suffix
    (value_arguments
      . (value_argument
          (string_literal
            (string_content) @kotlin.member_string_call.arg0))))) @kotlin.member_string_call.call

; Bounded one-level trailing-lambda ownership: owner { nested("literal") }.
(call_expression
  (simple_identifier) @kotlin.nested_string_call.owner
  (call_suffix
    (annotated_lambda
      (lambda_literal
        (statements
          (call_expression
            (simple_identifier) @kotlin.nested_string_call.name
            (call_suffix
              (value_arguments
                . (value_argument
                    (string_literal
                      (string_content) @kotlin.nested_string_call.arg0))))) @kotlin.nested_string_call.call)))) @kotlin.nested_string_call.owner_suffix) @kotlin.nested_string_call.owner_call

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/kotlin/locals.scm
; sha256=c97567b90fc0d306f594d9820bf3e89bd5db19fab4efcae32f31831602c4786e
; Imports


; Functions
(function_declaration
  .
  (simple_identifier) @local.definition.function
  (#set! definition.function.scope "parent"))

(class_body
  (function_declaration
    .
    (simple_identifier) @local.definition.method)
  (#set! definition.method.scope "parent"))

; Variables


; NOTE: temporary fix for treesitter bug that causes delay in file opening
;(class_body
;  (property_declaration
;    (variable_declaration
;      (simple_identifier) @local.definition.field)))



; Types
(class_declaration
  (type_identifier) @local.definition.type
  (#set! definition.type.scope "parent"))

(type_alias
  (type_identifier) @local.definition.type
  (#set! definition.type.scope "parent"))

; Scopes

; --- module_declaration_path_hints ---

(package_header (identifier) @module.declaration_path.name) @module.declaration_path.span

; --- module_path_hints ---


; --- named_scope_owners ---

(function_declaration
  (simple_identifier) @scope.owner.name
  (function_body) @scope.owner.body) @scope.owner

(class_declaration
  (type_identifier) @scope.owner.name
  (class_body) @scope.owner.body) @scope.owner

; --- ownership_members ---

(class_declaration
  (type_identifier) @owner.name
  (class_body
    (function_declaration
      (simple_identifier) @owned.member.name) @owned.member)) @owner.span

; --- ownership_parameters ---

(function_declaration
  (simple_identifier) @owner.name
  (function_value_parameters
    (parameter) @owned.parameter)
  (function_body) @owner.body) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=kotlin file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/kotlin/locals.scm

; Scopes
[
  (class_declaration)
  (function_declaration)
  (lambda_literal)
  ; `fun(x) { … }` expression form: has its own parameters and body.
  (anonymous_function)
  (control_structure_body)
  (when_entry)
  ; for/while loop variables are declared on the statement, not in its body.
  (for_statement)
] @local.scope

; Definitions
(type_parameter
  (type_identifier) @local.definition.type.parameter)

(parameter
  (simple_identifier) @local.definition.variable.parameter)


; Loop and local `val`/`var` bindings; defined so inner references resolve and
; shadow correctly.

; References
(simple_identifier) @local.reference
(type_identifier) @local.reference
(interpolated_identifier) @local.reference

; Member access after `.` is not a local reference.
(navigation_suffix
  (simple_identifier) @_)

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=kotlin file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/kotlin/tags.scm





; --- receiver_hints ---

(super_expression) @reference.receiver

(this_expression) @reference.receiver

; --- signature_parameters ---

(function_declaration
  (simple_identifier) @definition.signature.name
  (function_value_parameters) @definition.signature.parameters
) @definition.signature.owner

; --- static_delta ---

(class_declaration
  (delegation_specifier) @relation.supertype) @relation.owner

; --- upstream_tags ---

; Classes

; Objects

; Functions (top-level and member)

; Properties
(property_declaration
  (variable_declaration
    (simple_identifier) @name)) @definition.constant

; Enum entries
(enum_entry
  (simple_identifier) @name) @definition.constant

; Type aliases

; Companion objects (only named ones)
(companion_object
  (type_identifier) @name) @definition.class

; Function calls
(call_expression
  (simple_identifier) @name) @reference.call

; Method calls via navigation
(call_expression
  (navigation_expression
    (navigation_suffix
      (simple_identifier) @name))) @reference.call

; Constructor invocations (class references)
(constructor_invocation
  (user_type
    (type_identifier) @name)) @reference.class

; --- kotlin_direct_call_context ---

(call_expression
  (simple_identifier) @kotlin.direct_call.name
  (call_suffix) @kotlin.direct_call.suffix) @kotlin.direct_call.call

; --- framework_neutral_kotlin_platform_declarations_v1 ---

(class_declaration
  (modifiers (platform_modifier) @kotlin.platform.modifier)
  (type_identifier) @kotlin.platform.name) @kotlin.platform.class
(function_declaration
  (modifiers (platform_modifier) @kotlin.platform.modifier)
  (simple_identifier) @kotlin.platform.name) @kotlin.platform.function
(property_declaration
  (modifiers (platform_modifier) @kotlin.platform.modifier)
  (variable_declaration (simple_identifier) @kotlin.platform.name)) @kotlin.platform.property

; --- framework_neutral_kotlin_class_di_v3_146 ---
(class_declaration
  (modifiers
    (annotation
      (user_type
        (type_identifier) @kotlin.class_annotation.annotation)))
  (type_identifier) @kotlin.class_annotation.owner_class) @kotlin.class_annotation.context

(class_declaration
  (type_identifier) @kotlin.ctor_param.owner_class
  (primary_constructor
    (class_parameter
      (simple_identifier) @kotlin.ctor_param.parameter_name
      (user_type) @kotlin.ctor_param.parameter_type) @kotlin.ctor_param.parameter)) @kotlin.ctor_param.context

(class_declaration
  (type_identifier) @kotlin.ctor_param.owner_class
  (primary_constructor
    (class_parameter
      (simple_identifier) @kotlin.ctor_param.parameter_name
      (nullable_type
        (user_type) @kotlin.ctor_param.parameter_type) @kotlin.ctor_param.nullable_type) @kotlin.ctor_param.parameter)) @kotlin.ctor_param.context

; --- final_completion_generic_direct_literals_v1 ---
(boolean_literal) @omega.literal.boolean
(integer_literal) @omega.literal.integer
(long_literal) @omega.literal.long
(unsigned_literal) @omega.literal.unsigned
(bin_literal) @omega.literal.bin
(hex_literal) @omega.literal.hex
(real_literal) @omega.literal.real
(null_literal) @omega.literal.null
(string_literal) @omega.literal.string


; --- final_completion_a4_import_provenance ---
(import_header
  (identifier
    (simple_identifier) @kotlin.a4_import.local .) @kotlin.a4_import.target) @kotlin.a4_import.context

(import_header
  (identifier) @kotlin.a4_alias.target
  (import_alias (type_identifier) @kotlin.a4_alias.local)) @kotlin.a4_alias.context

; --- final_completion_kotlin_typed_delegation_specifiers ---
; Syntax-level classification only. Target identity remains a resolver concern.
(class_declaration
  (type_identifier) @kotlin.delegation.owner
  (delegation_specifier
    (constructor_invocation
      (user_type) @kotlin.delegation.superclass_type) @kotlin.delegation.superclass_spec)) @kotlin.delegation.class

(class_declaration
  (type_identifier) @kotlin.delegation.owner
  (delegation_specifier
    (explicit_delegation
      (user_type) @kotlin.delegation.delegated_type) @kotlin.delegation.explicit_spec)) @kotlin.delegation.class

(class_declaration
  (type_identifier) @kotlin.delegation.owner
  (delegation_specifier
    (user_type) @kotlin.delegation.superinterface_type)) @kotlin.delegation.class

(class_declaration
  (type_identifier) @kotlin.delegation.owner
  (delegation_specifier
    (function_type) @kotlin.delegation.function_supertype)) @kotlin.delegation.class
