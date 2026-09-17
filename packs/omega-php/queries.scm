; --- call_targets ---

(function_call_expression
  function: (_) @call.target) @call.expression

(member_call_expression
  name: (_) @call.target) @call.expression

(nullsafe_member_call_expression
  name: (_) @call.target) @call.expression

(scoped_call_expression
  name: (_) @call.target) @call.expression

; --- class_relation_explicit_target_context ---

; Framework-neutral PHP class-owned method returning an explicit $this relation call
; whose first argument is a literal ClassName::class expression.
; Example:
;   class Post extends Model {
;     public function author() { return $this->belongsTo(User::class); }
;   }
; Syntax only: ORM/framework meaning and declaration resolution remain downstream.

((class_declaration
  name: (name) @php.class_relation.owner_class
  body: (declaration_list
    (method_declaration
      name: (name) @php.class_relation.owner_method
      body: (compound_statement
        (return_statement
          (member_call_expression
            object: (variable_name) @php.class_relation.receiver
            name: (name) @php.class_relation.relation_method
            arguments: (arguments
              (argument
                (class_constant_access_expression
                  [(name) (qualified_name) (relative_name)] @php.class_relation.target_class
                  (name) @php.class_relation.target_constant))))))) @php.class_relation.context))
  (#eq? @php.class_relation.receiver "$this")
  (#eq? @php.class_relation.target_constant "class"))

; --- completeness_imports ---

(namespace_use_declaration) @import.expression
(include_expression) @import.expression
(require_expression) @import.expression

; --- completeness_modules ---

(namespace_definition) @module.expression

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression
(enum_declaration) @type.expression
(interface_declaration) @type.expression
(trait_declaration) @type.expression

; --- declaration_category_class ---

(class_declaration
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_enum ---

(enum_case
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(enum_declaration
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_function ---

(function_definition
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_interface ---

(interface_declaration
  name: (_) @definition.category.interface.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_method ---

(method_declaration
  name: (_) @definition.category.method.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_namespace ---

(namespace_definition
  name: (_) @definition.category.namespace.name @definition.identity.name @module.declaration_path.name
) @definition.category.owner @definition.identity.owner @module.declaration_path.span

; --- declaration_category_property ---

; --- declaration_category_trait ---

(trait_declaration
  name: (_) @definition.category.trait.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_variable ---

(static_variable_declaration
  name: (_) @definition.category.variable.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_modifiers ---

(class_declaration
  (abstract_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(class_declaration
  (final_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(class_declaration
  (readonly_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(class_declaration
  (static_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(method_declaration
  (abstract_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(method_declaration
  (final_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(method_declaration
  (readonly_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(method_declaration
  (static_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- declaration_visibility ---

(class_declaration
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(method_declaration
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

; --- definition_identity_hints ---

; --- enclosing_owner_hints ---

(class_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(interface_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(namespace_definition 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(trait_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=php kind=tags
; original baseline: audit-baselines/external/helix/php/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(class_declaration
  name: (name) @name) @definition.class

(function_definition
  name: (name) @name) @definition.function

(method_declaration
  name: (name) @name) @definition.function

(object_creation_expression
  [
    (qualified_name (name) @name)
    (variable_name (name) @name)
  ]) @reference.class

(function_call_expression
  function: [
    (qualified_name (name) @name)
    (variable_name (name)) @name
  ]) @reference.call

(scoped_call_expression
  name: (name) @name @call.target) @reference.call @call.member

(member_call_expression
  name: (name) @name @call.target) @reference.call @call.member

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: inherited php_only
; path=audit-baselines/external/nvim-treesitter/_shared/php_only/locals.scm
; sha256=6f1e6b67d0f850ebfc4c19063e280670449a8b6bdfac4a3a8dad0364103785b9
; Scopes
;-------
((class_declaration
  name: (name) @local.definition.type) @local.scope
  (#set! definition.type.scope "parent"))

((method_declaration
  name: (name) @local.definition.method) @local.scope
  (#set! definition.method.scope "parent"))

((function_definition
  name: (name) @local.definition.function) @local.scope
  (#set! definition.function.scope "parent"))

(anonymous_function
  (anonymous_function_use_clause
    (variable_name
      (name) @local.definition.var))) @local.scope

; Definitions
;------------
(simple_parameter
  (variable_name
    (name) @local.definition.var))

(foreach_statement
  (pair
    (variable_name
      (name) @local.definition.var)))

(foreach_statement
  (variable_name
    (name) @local.reference
    (#set! reference.kind "var"))
  (variable_name
    (name) @local.definition.var))
(property_declaration (property_element (variable_name (name) @local.definition.field @name))) @definition.field

(namespace_use_clause
  (qualified_name
    (name) @local.definition.import))

; References
;------------
(named_type
  (name) @local.reference
  (#set! reference.kind "type"))

(named_type
  (qualified_name) @local.reference
  (#set! reference.kind "type"))

(variable_name
  (name) @local.reference
  (#set! reference.kind "var"))

(member_access_expression
  name: (name) @local.reference
  (#set! reference.kind "field"))

(member_call_expression
  name: (name) @local.reference
  (#set! reference.kind "method"))

(function_call_expression
  function: (qualified_name
    (name) @local.reference
    (#set! reference.kind "function")))

(object_creation_expression
  (qualified_name
    (name) @local.reference
    (#set! reference.kind "type")))

(scoped_call_expression
  scope: (qualified_name
    (name) @local.reference
    (#set! reference.kind "type"))
  name: (name) @local.reference
  (#set! reference.kind "method"))

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/php/locals.scm
; sha256=28a611e72b425f496800fd568aeb8ce3211112b44fbb7fb5c2b4b757b3148339
; inherits: php_only

; --- member_category_enum ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_declaration_list
    (enum_case
      name: (_) @owned.member_category.enum.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_method ---

(class_declaration
  name: (_) @owner.name
  body: (declaration_list
    (method_declaration
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(enum_declaration
  name: (_) @owner.name
  body: (enum_declaration_list
    (method_declaration
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (declaration_list
    (method_declaration
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(trait_declaration
  name: (_) @owner.name
  body: (declaration_list
    (method_declaration
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

; --- module_declaration_path_hints ---

; --- named_scope_owners ---

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(method_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_members ---

; --- ownership_parameters ---

(function_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (property_promotion_parameter) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (simple_parameter) @owned.parameter)) @owner.span

(function_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (variadic_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (property_promotion_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (simple_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (variadic_parameter) @owned.parameter)) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=php file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/php/locals.scm

; Scopes

[
  (function_definition)
  (method_declaration)
  (anonymous_function)
  (arrow_function)
  (compound_statement)
] @local.scope

; Definitions

; PHP variables are `variable_name` ($foo); parameters share that node type so
; references match by text including the leading `$`.
(simple_parameter
  name: (variable_name) @local.definition.variable.parameter)
(variadic_parameter
  name: (variable_name) @local.definition.variable.parameter)
(property_promotion_parameter
  name: (variable_name) @local.definition.variable.parameter)

; References

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=php file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/php/tags.scm

; --- php_class_method_context ---

(class_declaration
  name: (name) @php.class_method.owner_class
  (base_clause
    [(name) (qualified_name) (relative_name)] @php.class_method.superclass)
  body: (declaration_list
    (method_declaration
      name: (name) @php.class_method.method_name) @php.class_method.method)) @php.class_method.class

; --- qualified_chain_hints ---

(member_access_expression
  object: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(member_call_expression
  object: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(nullsafe_member_access_expression
  object: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(nullsafe_member_call_expression
  object: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(scoped_call_expression
  scope: (_) @reference.qualified_chain.base @reference.qualifier
  name: (_) @reference.qualified_chain.leaf @reference.qualified_name
) @reference.qualified_chain.span @reference.qualified_expression

(scoped_property_access_expression
  scope: (_) @reference.qualified_chain.base @reference.qualifier
  name: (_) @reference.qualified_chain.leaf @reference.qualified_name
) @reference.qualified_chain.span @reference.qualified_expression

; --- qualified_name_hints ---

; --- signature_parameters ---

(function_definition
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(function_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- static_delta ---

; No additional static delta: exact upstream/adapted sources already cover local semantic dimensions.

; --- upstream_tags ---

(namespace_definition
  name: (namespace_name) @name) @definition.module

(interface_declaration
  name: (name) @name) @definition.interface

(trait_declaration
  name: (name) @name) @definition.interface

(class_interface_clause [(name) (qualified_name)] @name) @reference.implementation

; --- generic_direct_and_member_calls ---

(function_call_expression
  function: (name) @call.target) @call.direct

; --- php_framework_string_call_and_attribute_context ---

(function_call_expression
  function: (name) @php.string_call.name
  arguments: (arguments
    . (argument
        (string (string_content) @php.string_call.arg0)))) @php.string_call.call

(function_call_expression
  function: (name) @php.string_two_call.name
  arguments: (arguments
    . (argument (string (string_content) @php.string_two_call.arg0))
    . (argument (string (string_content) @php.string_two_call.arg1)))) @php.string_two_call.call

(class_declaration
  name: (name) @php.attr_route.owner_class
  body: (declaration_list
    (method_declaration
      attributes: (attribute_list
        (attribute_group
          (attribute
            (name) @php.attr_route.attribute_name
            parameters: (arguments
              . (argument
                  (string (string_content) @php.attr_route.route))))))
      name: (name) @php.attr_route.method_name) @php.attr_route.method)) @php.attr_route.class

; --- framework_neutral_php_constructor_and_hooks_v1 ---

(class_declaration
  name: (name) @php.ctor_param.owner_class
  body: (declaration_list
    (method_declaration
      name: (name) @php.ctor_param.method_name
      parameters: (formal_parameters
        [
          (simple_parameter type: (named_type) @php.ctor_param.parameter_type name: (variable_name) @php.ctor_param.parameter_name)
          (property_promotion_parameter type: (named_type) @php.ctor_param.parameter_type name: (_) @php.ctor_param.parameter_name)
        ] @php.ctor_param.parameter))) @php.ctor_param.class_context
 (#eq? @php.ctor_param.method_name "__construct"))

(function_call_expression
  function: (name) @php.hook.call_name
  arguments: (arguments
    (argument (string) @php.hook.hook_name)
    (argument (name) @php.hook.callback_name))) @php.hook.context

; --- final_completion_generic_direct_literals_v1 ---

; --- final_completion_a4_import_provenance ---
(namespace_use_clause
  (qualified_name) @php.a4_import.target) @php.a4_import.context
(namespace_use_clause
  (name) @php.a4_import_simple.target) @php.a4_import_simple.context
(namespace_use_clause
  [(qualified_name) (name)] @php.a4_alias.target
  alias: (name) @php.a4_alias.local) @php.a4_alias.context
