; --- completeness_imports_6 ---

(import_specification) @import.expression

; --- completeness_types_high_confidence ---

(class_definition) @type.expression
(enum_declaration) @type.expression
(extension_type_declaration) @type.expression

; --- declaration_category_class ---

(class_definition
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_constructor ---

(constructor_signature
  name: (_) @definition.category.constructor.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_constant
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(enum_declaration
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_function ---

(function_signature
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_type ---

(extension_type_declaration
  name: (_) @definition.category.type.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_variable ---

(initialized_variable_definition
  name: (_) @definition.category.variable.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---




(extension_declaration
  name: (_) @definition.identity.name) @definition.identity.owner




; --- enclosing_owner_hints ---

(class_definition 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(extension_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(extension_type_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=dart kind=tags
; original baseline: audit-baselines/external/helix/dart/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(class_definition
  name: (identifier) @name) @definition.class
(enum_declaration
  name: (identifier) @name) @definition.enum
(mixin_declaration
  (identifier) @name) @definition.interface
(extension_declaration
  name: (identifier) @name) @definition.class @definition.extension
(function_signature
  name: (identifier) @name) @definition.function
(constructor_signature
  name: (identifier) @name) @definition.function
(type_alias
  "typedef" . (type_identifier) @name) @definition.type

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=dart kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/dart/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Definitions
(function_signature
  name: (identifier) @local.definition.function)

(formal_parameter
  name: (identifier) @local.definition.parameter @local.definition.variable.parameter)

(initialized_variable_definition
  name: (identifier) @local.definition.var @local.definition.variable)

(initialized_identifier
  (identifier) @local.definition.var)

(static_final_declaration
  (identifier) @local.definition.var)

; References
(identifier) @local.reference

; Scopes
(class_definition
  body: (_) @local.scope)

[
  (block)
  (if_statement)
  (for_statement)
  (while_statement)
  (try_statement)
  (catch_clause)
  (finally_clause)
] @local.scope

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/dart/locals.scm
; sha256=e353c0e1c4838ad2b14810c7358007c825e740313922032917e2dcfc43cd46ae
; Definitions





; References

; Scopes


; --- member_category_enum_member ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_body
    (enum_constant
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- named_scope_owners ---


; --- ownership_members ---


; --- ownership_parameters ---

(constructor_signature
  name: (_) @owner.name
  parameters: (formal_parameter_list
    (formal_parameter) @owned.parameter)) @owner.span

(constructor_signature
  name: (_) @owner.name
  parameters: (formal_parameter_list
    (optional_formal_parameters) @owned.parameter)) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=dart file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/dart/locals.scm

; Scopes
;-------

[
 (function_body)
 (function_expression_body)
 (block)
 (for_statement)
 (try_statement)
 (catch_clause)
 (finally_clause)
] @local.scope

; Definitions
;------------


; for-in / C-style loop variable.
(for_loop_parts
 name: (identifier) @local.definition.variable)


; References
;------------


; Member access selectors carry plain identifiers that are not local references.
(unconditional_assignable_selector
 (identifier) @_)
(conditional_assignable_selector
 (identifier) @_)

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=dart file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/dart/tags.scm


; --- prefixed_import_context ---

(import_specification
  (uri (string_literal) @dart.prefixed_import.uri)
  (identifier) @dart.prefixed_import.prefix) @dart.prefixed_import.context

; --- prefixed_member_call_context ---

((identifier) @dart.prefixed_call.prefix
  (selector
    (unconditional_assignable_selector
      (identifier) @dart.prefixed_call.member))
  (selector (type_arguments))?
  (selector
    (argument_part
      (arguments))) ) @dart.prefixed_call.context

; --- qualified_chain_hints ---

(scoped_identifier
  scope: (_) @reference.qualified_chain.base @reference.qualifier
  name: (_) @reference.qualified_chain.leaf @reference.qualified_name
) @reference.qualified_chain.span @reference.qualified_expression

; --- qualified_name_hints ---


; --- receiver_hints ---

(super) @reference.receiver

(this) @reference.receiver

; --- reexport_hints ---

(library_export
  (configurable_uri) @module.reexport.target
) @module.reexport.statement

; --- signature_parameters ---

(constructor_signature
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_type_parameters ---

(class_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(extension_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(extension_type_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- upstream_tags ---



(method_signature
  (function_signature)) @definition.method

(type_alias
  (type_identifier) @name) @definition.type

(method_signature
(getter_signature
  name: (identifier) @name)) @definition.method

(method_signature
(setter_signature
  name: (identifier) @name)) @definition.method 

(method_signature
  (function_signature
  name: (identifier) @name)) @definition.method

(method_signature
  (factory_constructor_signature
    (identifier) @name)) @definition.method

(method_signature
  (constructor_signature
  name: (identifier) @name)) @definition.method

(method_signature
  (operator_signature)) @definition.method

(method_signature) @definition.method

(mixin_declaration
  (mixin)
  (identifier) @name) @definition.mixin



(new_expression
  (type_identifier) @name) @reference.class



(initialized_variable_definition
  name: (identifier)
  value: (identifier) @name 
  value: (selector
	"!"?
	(argument_part 
	  (arguments
	    (argument)*))?)?) @reference.class

(assignment_expression
  left: (assignable_expression 
		  (identifier)
		  (unconditional_assignable_selector
			"."
			(identifier) @name))) @reference.call

(assignment_expression
  left: (assignable_expression 
		  (identifier)
		  (conditional_assignable_selector
			"?."
			(identifier) @name))) @reference.call

((identifier) @name
 (selector
    "!"?
    (conditional_assignable_selector
      "?." (identifier) @name)?
    (unconditional_assignable_selector
      "."? (identifier) @name)?
    (argument_part
      (arguments
        (argument)*))?)*
	(cascade_section
	  (cascade_selector
		(identifier)) @name 
	  (argument_part 
		(arguments
		  (argument)*))?)?) @reference.call

; --- widget_route_builder_context ---

; Framework-neutral Dart direct class-supertype and named route/builder context.
; No Flutter/go_router semantics here.
(class_definition
  name: (identifier) @dart.class_extends.class_name
  superclass: (superclass
    (type_identifier) @dart.class_extends.superclass_name)) @dart.class_extends.owner

((identifier) @dart.route_builder.call_name
  (selector
    (argument_part
      (arguments
        (named_argument
          (label (identifier) @dart.route_builder.string_label)
          (string_literal) @dart.route_builder.string_value)
        (named_argument
          (label (identifier) @dart.route_builder.builder_label)
          (function_expression
            body: (function_expression_body
              (identifier) @dart.route_builder.constructor_name
              (selector
                (argument_part
                  (arguments)))))))))) @dart.route_builder.context

; --- generic_dart_call_and_import_context_v3_146 ---
; Framework-neutral source facts for direct/imported Dart calls and authored named routes.
(import_specification
  (uri (string_literal) @dart.import_module.uri)) @dart.import_module.context

((identifier) @dart.direct_call.call_name
  (selector
    (argument_part
      (arguments)))) @dart.direct_call.context

((identifier) @dart.member_call.receiver
  (selector
    (unconditional_assignable_selector
      (identifier) @dart.member_call.member))
  (selector
    (argument_part
      (arguments)))) @dart.member_call.context

((identifier) @dart.member_route.receiver
  (selector
    (unconditional_assignable_selector
      (identifier) @dart.member_route.member))
  (selector
    (argument_part
      (arguments
        (argument (identifier) @dart.member_route.context_arg)
        (argument (string_literal) @dart.member_route.route))))) @dart.member_route.context

