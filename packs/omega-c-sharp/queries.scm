; --- call_targets ---

(invocation_expression
  function: (_) @call.target) @call.expression

; --- class_base_context ---

; Framework-neutral explicit C# class base declaration.
; One match is emitted per authored base-list child. Interface/class semantics,
; alias expansion and type resolution remain outside Pack truth.
(class_declaration
  name: (identifier) @csharp.class_base.owner_class
  (base_list
    (_) @csharp.class_base.base_name)) @csharp.class_base.class

; --- class_member_string_call_context ---

; Framework-neutral C# class-owned call carrying a direct literal first string.
; Covers a direct static-style receiver (Routing.RegisterRoute("details", ...))
; and a two-segment receiver (Shell.Current.GoToAsync("details")).
; Only top-level expression statements in a method body are emitted. Runtime
; dispatch, overload/type resolution, interpolated strings and indirect values
; stay outside Pack truth.

(class_declaration
  name: (identifier) @csharp.class_string_call.owner_class
  body: (declaration_list
    (method_declaration
      name: (identifier) @csharp.class_string_call.owner_method
      body: (block
        (expression_statement
          (invocation_expression
            function: (member_access_expression
              expression: (identifier) @csharp.class_string_call.receiver
              name: (identifier) @csharp.class_string_call.member)
            arguments: (argument_list
              . (argument
                  (string_literal
                    (string_literal_content) @csharp.class_string_call.arg1)))) @csharp.class_string_call.call)))) @csharp.class_string_call.method) @csharp.class_string_call.class

(class_declaration
  name: (identifier) @csharp.class_nested_string_call.owner_class
  (base_list (_) @csharp.class_nested_string_call.owner_base)
  body: (declaration_list
    (method_declaration
      name: (identifier) @csharp.class_nested_string_call.owner_method
      body: (block
        (expression_statement
          (invocation_expression
            function: (member_access_expression
              expression: (member_access_expression
                expression: (identifier) @csharp.class_nested_string_call.receiver_root
                name: (identifier) @csharp.class_nested_string_call.receiver_member)
              name: (identifier) @csharp.class_nested_string_call.member)
            arguments: (argument_list
              . (argument
                  (string_literal
                    (string_literal_content) @csharp.class_nested_string_call.arg1)))) @csharp.class_nested_string_call.call)))) @csharp.class_nested_string_call.method) @csharp.class_nested_string_call.class

(class_declaration
  name: (identifier) @csharp.class_nested_string_call.owner_class
  (base_list (_) @csharp.class_nested_string_call.owner_base)
  body: (declaration_list
    (method_declaration
      name: (identifier) @csharp.class_nested_string_call.owner_method
      body: (block
        (expression_statement
          (await_expression
            (invocation_expression
              function: (member_access_expression
                expression: (member_access_expression
                  expression: (identifier) @csharp.class_nested_string_call.receiver_root
                  name: (identifier) @csharp.class_nested_string_call.receiver_member)
                name: (identifier) @csharp.class_nested_string_call.member)
              arguments: (argument_list
                . (argument
                    (string_literal
                      (string_literal_content) @csharp.class_nested_string_call.arg1)))) @csharp.class_nested_string_call.call))))) @csharp.class_nested_string_call.method) @csharp.class_nested_string_call.class

; --- completeness_modules ---

(namespace_declaration name: (_) @module.target) @module.expression

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression
(enum_declaration) @type.expression
(interface_declaration) @type.expression
(struct_declaration) @type.expression
(type_declaration) @type.expression

; --- csharp_attributed_method_context ---

(class_declaration
  name: (identifier) @csharp.attr.owner_class
  body: (declaration_list
    (method_declaration
      (attribute_list
        (attribute
          name: (_) @csharp.attr.attribute_name))
      name: (identifier) @csharp.attr.method_name) @csharp.attr.method)) @csharp.attr.class

; --- csharp_attributed_property_adjacent_named_sibling_context ---

; Framework-neutral C# attributed property whose direct string argument names the immediately
; following sibling property in the same class. This is deliberately adjacency-bounded to avoid
; class-wide combinatorial sibling matching. Attribute meaning is downstream Framework semantics.
((class_declaration
  name: (identifier) @csharp.attrsib.owner_class
  body: (declaration_list
    (property_declaration
      (attribute_list
        (attribute
          name: (_) @csharp.attrsib.attribute_name
          (attribute_argument_list
            (attribute_argument
              (string_literal
                (string_literal_content) @csharp.attrsib.argument_string)))))
      type: (_) @csharp.attrsib.source_property_type
      name: (identifier) @csharp.attrsib.source_property_name) @csharp.attrsib.source_property
    .
    (property_declaration
      type: (_) @csharp.attrsib.sibling_property_type
      name: (identifier) @csharp.attrsib.sibling_property_name) @csharp.attrsib.sibling_property)) @csharp.attrsib.class

(#eq? @csharp.attrsib.argument_string @csharp.attrsib.sibling_property_name))

; --- csharp_attributed_property_context ---

(class_declaration
  name: (identifier) @csharp.attrprop.owner_class
  body: (declaration_list
    (property_declaration
      (attribute_list
        (attribute
          name: (_) @csharp.attrprop.attribute_name))
      type: (_) @csharp.attrprop.property_type
      name: (identifier) @csharp.attrprop.property_name) @csharp.attrprop.property)) @csharp.attrprop.class

; --- csharp_class_property_context ---

(class_declaration
  name: (_) @csharp.property.owner_class
  body: (declaration_list
    (property_declaration
      type: (_) @csharp.property.type
      name: (_) @csharp.property.name) @csharp.property.declaration)) @csharp.property.class

; --- csharp_lifecycle_method_context ---

(class_declaration
  name: (identifier) @csharp.lifecycle.owner_class
  body: (declaration_list
    (constructor_declaration
      name: (identifier) @csharp.lifecycle.method_name) @csharp.lifecycle.method)) @csharp.lifecycle.class

(class_declaration
  name: (identifier) @csharp.lifecycle.owner_class
  body: (declaration_list
    (method_declaration
      name: (identifier) @csharp.lifecycle.method_name) @csharp.lifecycle.method)) @csharp.lifecycle.class

; --- declaration_category_class ---

(class_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_constructor ---

(constructor_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_destructor ---

(destructor_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(enum_member_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_event ---

(event_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_function ---

(local_function_statement
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_interface ---

(interface_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_method ---

(method_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_namespace ---

(file_scoped_namespace_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(namespace_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_property ---

(property_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_record ---

(record_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_struct ---

(struct_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_modifiers ---

(accessor_declaration
  name: (_) @definition.modifiers.name
  (modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(class_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(constructor_declaration
  name: (_) @definition.modifiers.name
  (modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(delegate_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(enum_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(event_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(interface_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(local_function_statement
  name: (_) @definition.modifiers.name
  (modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(method_declaration
  name: (_) @definition.modifiers.name
  (modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(property_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(record_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(struct_declaration
  (modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- definition_identity_hints ---

(class_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(constructor_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(destructor_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_member_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(event_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(file_scoped_namespace_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(interface_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(method_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(namespace_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(property_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(record_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(struct_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(variable_declarator
  name: (_) @definition.identity.name) @definition.identity.owner

; --- enclosing_owner_hints ---

(class_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(constructor_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(destructor_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(interface_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(namespace_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(struct_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- event_field_definition ---

(event_field_declaration (variable_declaration (variable_declarator name: (identifier) @csharp.event.name) @csharp.event.declarator)) @csharp.event

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=c-sharp kind=tags
; original baseline: audit-baselines/external/helix/c-sharp/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(class_declaration name: (identifier) @name) @definition.class

(class_declaration (base_list (_) @name)) @reference.class

(interface_declaration name: (identifier) @name) @definition.interface

(interface_declaration (base_list (_) @name)) @reference.interface

(method_declaration name: (identifier) @name) @definition.method

(object_creation_expression type: (identifier) @name) @reference.class

(type_parameter_constraints_clause (identifier) @name) @reference.class

(type_parameter_constraint (type type: (identifier) @name)) @reference.class

(variable_declaration type: (identifier) @name) @reference.class

(invocation_expression function: (member_access_expression name: (identifier) @name)) @reference.send

(namespace_declaration name: (identifier) @name) @definition.module

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=c-sharp kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/c-sharp/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Definitions
(variable_declarator
  .
  (identifier) @local.definition.var)

(variable_declarator
  (tuple_pattern
    (identifier) @local.definition.var))

(declaration_expression
  name: (identifier) @local.definition.var)

(foreach_statement
  left: (identifier) @local.definition.var)

(foreach_statement
  left: (tuple_pattern
    (identifier) @local.definition.var))

(parameter
  (identifier) @local.definition.parameter)

(method_declaration
  name: (identifier) @local.definition.method)

(local_function_statement
  name: (identifier) @local.definition.method)

(property_declaration
  name: (identifier) @local.definition)

(type_parameter
  (identifier) @local.definition.type)

(class_declaration
  name: (identifier) @local.definition)

; References
(identifier) @local.reference

; Scope
(block) @local.scope

; --- field_definition ---

(field_declaration (variable_declaration (variable_declarator name: (identifier) @csharp.field.name) @csharp.field.declarator)) @csharp.field

; --- import_alias_hints ---

(alias_qualified_name
  alias: (_) @import.alias) @import.statement
  name: (_) @import.target

; --- import_targets ---

(using_directive
  name: (_) @import.target) @import.statement

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/c-sharp/locals.scm
; sha256=7dccbd815d6033de319708ef27d82350af5acafefeb5f4314e5b8a525cb85e80
; Definitions
(variable_declarator
  .
  (identifier) @local.definition.var)

(variable_declarator
  (tuple_pattern
    (identifier) @local.definition.var))

(declaration_expression
  name: (identifier) @local.definition.var)

(foreach_statement
  left: (identifier) @local.definition.var)

(foreach_statement
  left: (tuple_pattern
    (identifier) @local.definition.var))

(parameter
  (identifier) @local.definition.parameter)

(method_declaration
  name: (identifier) @local.definition.method)

(local_function_statement
  name: (identifier) @local.definition.method)

(property_declaration
  name: (identifier) @local.definition)

(type_parameter
  (identifier) @local.definition.type)

(class_declaration
  name: (identifier) @local.definition)

; References
(identifier) @local.reference

; Scope
(block) @local.scope

; --- member_access_hints ---

(member_access_expression
  expression: (_) @reference.receiver
  name: (_) @reference.member) @reference.member_expression

; --- member_category_enum_member ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_member_declaration_list
    (enum_member_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- module_declaration_path_hints ---

(file_scoped_namespace_declaration
  name: (_) @module.declaration_path.name
) @module.declaration_path.span

(namespace_declaration
  name: (_) @module.declaration_path.name
) @module.declaration_path.span

; --- named_scope_owners ---

(class_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(constructor_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(destructor_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(interface_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(local_function_statement
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(method_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(namespace_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(struct_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_members ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_member_declaration_list
    (enum_member_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- ownership_parameters ---

(constructor_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter) @owned.parameter)) @owner.span

(local_function_statement
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter) @owned.parameter)) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=c-sharp file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/c-sharp/locals.scm

; Scopes

[
  (method_declaration)
  (local_function_statement)
  (constructor_declaration)
  (destructor_declaration)
  (operator_declaration)
  (lambda_expression)
  (anonymous_method_expression)
  (block)
] @local.scope

; Definitions

(parameter
  name: (identifier) @local.definition.variable.parameter)

(variable_declarator
  name: (identifier) @local.definition.variable)

(foreach_statement
  left: (identifier) @local.definition.variable)

; References

(identifier) @local.reference

; Discards: identifiers that look like references but aren't variables.

; `obj.Member` — the member name is not a local.
(member_access_expression
  name: (identifier) @_)

; Named argument `f(name: value)`.
(argument
  name: (identifier) @_)

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=c-sharp file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/c-sharp/tags.scm

(class_declaration name: (identifier) @name) @definition.class

(class_declaration (base_list (_) @name)) @reference.class

(interface_declaration name: (identifier) @name) @definition.interface

(interface_declaration (base_list (_) @name)) @reference.interface

(method_declaration name: (identifier) @name) @definition.method

(object_creation_expression type: (identifier) @name) @reference.class

(type_parameter_constraints_clause (identifier) @name) @reference.class

(type_parameter_constraint (type type: (identifier) @name)) @reference.class

(variable_declaration type: (identifier) @name) @reference.class

(invocation_expression function: (member_access_expression name: (identifier) @name)) @reference.send

(namespace_declaration name: (identifier) @name) @definition.module

; --- qualified_chain_hints ---

(qualified_name
  qualifier: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

; --- qualified_name_hints ---

(qualified_name
  qualifier: (_) @reference.qualifier
  name: (_) @reference.qualified_name) @reference.qualified_expression

; --- signature_parameters ---

(constructor_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(destructor_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(local_function_statement
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(local_function_statement
  name: (_) @definition.signature.name
  type: (_) @definition.signature.return_type
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  returns: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(delegate_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(interface_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(local_function_statement
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- static_delta ---

(using_directive) @import.statement

(class_declaration
  (base_list (_) @relation.base)) @relation.owner

(interface_declaration
  (base_list (_) @relation.base)) @relation.owner

; --- upstream_tags ---

(class_declaration name: (identifier) @name) @definition.class

(class_declaration (base_list (_) @name)) @reference.class

(interface_declaration name: (identifier) @name) @definition.interface

(interface_declaration (base_list (_) @name)) @reference.interface

(method_declaration name: (identifier) @name) @definition.method

(object_creation_expression type: (identifier) @name) @reference.class

(type_parameter_constraints_clause (identifier) @name) @reference.class

(type_parameter_constraint (type type: (identifier) @name)) @reference.class

(variable_declaration type: (identifier) @name) @reference.class

(invocation_expression function: (member_access_expression name: (identifier) @name)) @reference.send

(namespace_declaration name: (identifier) @name) @definition.module

(namespace_declaration name: (identifier) @name) @module

; --- csharp_route_attribute_and_minimal_api_context ---

(class_declaration
  name: (identifier) @csharp.route_attr.owner_class
  body: (declaration_list
    (method_declaration
      (attribute_list
        (attribute
          name: (_) @csharp.route_attr.attribute_name
          (attribute_argument_list
            . (attribute_argument
                (string_literal
                  (string_literal_content) @csharp.route_attr.route)))))
      name: (identifier) @csharp.route_attr.method_name) @csharp.route_attr.method)) @csharp.route_attr.class

(class_declaration
  name: (identifier) @csharp.minapi.owner_class
  body: (declaration_list
    (method_declaration
      name: (identifier) @csharp.minapi.owner_method
      body: (block
        (expression_statement
          (invocation_expression
            function: (member_access_expression
              expression: (identifier) @csharp.minapi.receiver
              name: (identifier) @csharp.minapi.member)
            arguments: (argument_list
              . (argument (string_literal (string_literal_content) @csharp.minapi.path))
              . (argument (identifier) @csharp.minapi.handler))) @csharp.minapi.call)))) @csharp.minapi.method) @csharp.minapi.class


; --- csharp_constructor_parameter_context ---
(class_declaration
  name: (identifier) @csharp.ctor_param.owner_class
  body: (declaration_list
    (constructor_declaration
      name: (identifier) @csharp.ctor_param.constructor_name
      parameters: (parameter_list
        (parameter
          type: (_) @csharp.ctor_param.parameter_type
          name: (identifier) @csharp.ctor_param.parameter_name)) @csharp.ctor_param.parameters) @csharp.ctor_param.constructor)) @csharp.ctor_param.class

; --- csharp_global_nested_member_string_context ---
(invocation_expression
  function: (member_access_expression
    expression: (member_access_expression
      expression: (identifier) @csharp.global_nested.receiver_root
      name: (identifier) @csharp.global_nested.receiver_member)
    name: (identifier) @csharp.global_nested.member)
  arguments: (argument_list
    . (argument
        (string_literal
          (string_literal_content) @csharp.global_nested.arg1)))) @csharp.global_nested.call

; --- csharp_service_registration_generic_context ---
; e.g. builder.Services.AddScoped<IService, Service>() or services.AddSingleton<Service>()
(invocation_expression
  function: (member_access_expression
    expression: (member_access_expression
      expression: (identifier) @csharp.service_reg.receiver_root
      name: (identifier) @csharp.service_reg.receiver_member)
    name: (generic_name
      (identifier) @csharp.service_reg.member
      (type_argument_list
        (identifier) @csharp.service_reg.service_type
        (identifier)? @csharp.service_reg.implementation_type)))
  arguments: (argument_list) @csharp.service_reg.arguments) @csharp.service_reg.call

; --- csharp_attributed_class_string_context ---
(class_declaration
  (attribute_list
    (attribute
      name: (_) @csharp.class_attr.attribute_name
      (attribute_argument_list
        . (attribute_argument
            (string_literal
              (string_literal_content) @csharp.class_attr.argument_string)))))
  name: (identifier) @csharp.class_attr.owner_class) @csharp.class_attr.class

; --- framework_neutral_csharp_attributed_field_v1 ---

(class_declaration
  name: (identifier) @csharp.attrfield.owner_class
  body: (declaration_list
    (field_declaration
      (attribute_list
        (attribute name: (_) @csharp.attrfield.attribute_name))
      (variable_declaration
        type: (_) @csharp.attrfield.field_type
        (variable_declarator name: (identifier) @csharp.attrfield.field_name)) @csharp.attrfield.variable) @csharp.attrfield.field)) @csharp.attrfield.class

; --- framework_neutral_csharp_global_member_and_typeof_v3_146 ---
(invocation_expression
  function: (member_access_expression
    expression: (identifier) @csharp.global_member_string.receiver
    name: (identifier) @csharp.global_member_string.member)
  arguments: (argument_list
    . (argument
        (string_literal
          (string_literal_content) @csharp.global_member_string.arg1)))) @csharp.global_member_string.call

(invocation_expression
  function: (member_access_expression
    expression: (member_access_expression
      expression: (identifier) @csharp.service_typeof.receiver_root
      name: (identifier) @csharp.service_typeof.receiver_member)
    name: (identifier) @csharp.service_typeof.member)
  arguments: (argument_list
    . (argument (typeof_expression type: (_) @csharp.service_typeof.service_type))
    (argument (typeof_expression type: (_) @csharp.service_typeof.implementation_type))?)) @csharp.service_typeof.call

; --- final_completion_generic_direct_literals_v1 ---
(boolean_literal) @omega.literal.boolean
(integer_literal) @omega.literal.integer
(real_literal) @omega.literal.real
(null_literal) @omega.literal.null
(string_literal) @omega.literal.string
(raw_string_literal) @omega.literal.raw_string
(verbatim_string_literal) @omega.literal.verbatim_string


; --- final_completion_a4_import_provenance ---
(using_directive
  name: (identifier) @csharp.a4_alias.local
  (_) @csharp.a4_alias.target) @csharp.a4_alias.context

(using_directive
  (qualified_name) @csharp.a4_import.target) @csharp.a4_import.context
