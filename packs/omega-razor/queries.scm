; --- call_targets ---

(invocation_expression
  function: (_) @call.target) @call.expression

; --- completeness_bindings ---

(implicit_parameter) @binding.symbol
(parameter) @binding.symbol
(type_parameter) @binding.symbol
(variable_declaration) @binding.symbol

; --- completeness_calls_6 ---

(invocation_expression) @call.expression

; --- completeness_definitions_high_confidence ---

(class_declaration) @definition.expression
(enum_declaration) @definition.expression
(interface_declaration) @definition.expression
(method_declaration) @definition.expression
(namespace_declaration) @definition.expression
(record_declaration) @definition.expression
(struct_declaration) @definition.expression
(type_declaration) @definition.expression

; --- completeness_modules_4 ---

(namespace_declaration) @module.expression
(file_scoped_namespace_declaration) @module.expression

; --- completeness_references ---

(alias_qualified_name) @reference.symbol
(qualified_name) @reference.symbol

; --- completeness_scopes ---

(block) @scope.lexical
(class_declaration) @scope.lexical
(lambda_expression) @scope.lexical
(razor_block) @scope.lexical

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression
(enum_declaration) @type.expression
(interface_declaration) @type.expression
(struct_declaration) @type.expression
(type_declaration) @type.expression

; --- declaration_category_class ---

(class_declaration
  name: (_) @definition.category.class.name
) @definition.category.owner

; --- declaration_category_constructor ---

(constructor_declaration
  name: (_) @definition.category.constructor.name
) @definition.category.owner

; --- declaration_category_destructor ---

(destructor_declaration
  name: (_) @definition.category.destructor.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_declaration
  name: (_) @definition.category.enum.name
) @definition.category.owner

(enum_member_declaration
  name: (_) @definition.category.enum.name
) @definition.category.owner

; --- declaration_category_event ---

(event_declaration
  name: (_) @definition.category.event.name
) @definition.category.owner

; --- declaration_category_function ---

(local_function_statement
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- declaration_category_interface ---

(interface_declaration
  name: (_) @definition.category.interface.name
) @definition.category.owner

; --- declaration_category_method ---

(method_declaration
  name: (_) @definition.category.method.name
) @definition.category.owner

; --- declaration_category_model ---

(razor_model_directive
  name: (_) @definition.category.model.name
) @definition.category.owner

; --- declaration_category_namespace ---

(file_scoped_namespace_declaration
  name: (_) @definition.category.namespace.name
) @definition.category.owner

(namespace_declaration
  name: (_) @definition.category.namespace.name
) @definition.category.owner

; --- declaration_category_property ---

(property_declaration
  name: (_) @definition.category.property.name
) @definition.category.owner

; --- declaration_category_record ---

(record_declaration
  name: (_) @definition.category.record.name
) @definition.category.owner

; --- declaration_category_struct ---

(struct_declaration
  name: (_) @definition.category.struct.name
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

; --- literal_href_context ---

; Literal authored Razor HTML navigation attribute.
; Captures only plain string href values; C# expressions/interpolation and dynamic bindings are excluded.

((razor_html_attribute
  (razor_attribute_name) @razor.href.attribute_name
  (razor_attribute_value
    (string_literal
      (string_literal_content) @razor.href.value))
) @razor.href.attribute
(#eq? @razor.href.attribute_name "href"))

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

; --- named_attribute_identifier_context ---

; Framework-neutral Razor named HTML attribute whose value is one direct C# identifier.
; Examples: @onclick="HandleClick", @onchange="HandleChange".
; Lambdas, invocations, member access, interpolation and other expressions do not match.

(razor_html_attribute
  (razor_attribute_name) @razor.named_attr.attribute_name
  (razor_attribute_value
    (identifier) @razor.named_attr.identifier)
) @razor.named_attr.attribute


; --- named_attribute_expression_context ---

; Framework-neutral Razor named HTML/component attribute whose value is a direct authored C# expression.
; This records source shape only; handler/component target resolution remains downstream.
(razor_html_attribute
  (razor_attribute_name) @razor.named_attr_expr.attribute_name
  (razor_attribute_value
    [
      (member_access_expression)
      (invocation_expression)
      (lambda_expression)
      (parenthesized_expression)
      (assignment_expression)
      (conditional_expression)
      (element_access_expression)
      (object_creation_expression)
      (await_expression)
    ] @razor.named_attr_expr.expression)
) @razor.named_attr_expr.attribute

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

; --- page_route_context ---

(razor_page_directive
  (string_literal
    (string_literal_content) @razor.page.route)
) @razor.page.directive

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

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.
(_) @structural.node

; --- semantic_closure_v3_146 ---

(razor_layout_directive name: (_) @razor.directive.layout) @razor.directive.layout.owner
(razor_inherits_directive name: (_) @razor.directive.inherits) @razor.directive.inherits.owner
(razor_implements_directive name: (_) @razor.directive.implements) @razor.directive.implements.owner
(razor_typeparam_directive name: (_) @razor.directive.typeparam) @razor.directive.typeparam.owner
(razor_using_directive) @razor.directive.using
(razor_inject_directive (variable_declaration) @razor.directive.inject.declaration) @razor.directive.inject
(razor_rendermode_directive (razor_rendermode) @razor.directive.rendermode) @razor.directive.rendermode.owner
(razor_namespace_directive (qualified_name) @razor.directive.namespace) @razor.directive.namespace.owner
(razor_section (identifier) @razor.section.name) @razor.section

; --- semantic_closure_v3_146_batch3 ---

(razor_model_directive
  name: (_) @razor.directive.model_type) @razor.directive.model

(razor_attribute_directive
  (attribute_list) @razor.directive.attribute_list) @razor.directive.attribute

(razor_preservewhitespace_directive
  (boolean_literal) @razor.directive.preservewhitespace.value) @razor.directive.preservewhitespace

(razor_using_directive
  (type) @razor.directive.using.type) @razor.directive.using.typed

(razor_using_directive
  name: (identifier) @razor.directive.using.alias
  (type) @razor.directive.using.aliased_type) @razor.directive.using.alias_owner

(razor_inject_directive
  (variable_declaration
    type: (type) @razor.directive.inject.type
    (variable_declarator
      name: (_) @razor.directive.inject.name))) @razor.directive.inject.typed

