; --- annotated_class_hierarchy_context ---

; Framework-neutral Java annotated class identity and direct superclass context.
(class_declaration
  (modifiers
    [(marker_annotation name: (_) @java.annotated_class.annotation)
     (annotation name: (_) @java.annotated_class.annotation)])
  name: (identifier) @java.annotated_class.name) @java.annotated_class.definition

(class_declaration
  (modifiers
    [(marker_annotation name: (_) @java.annotated_hierarchy.annotation)
     (annotation name: (_) @java.annotated_hierarchy.annotation)])
  name: (identifier) @java.annotated_hierarchy.name
  superclass: (superclass (type_identifier) @java.annotated_hierarchy.superclass)) @java.annotated_hierarchy.definition

; --- annotated_class_string_argument_context ---

; Framework-neutral Java direct class annotation with a named literal string argument.
; Deliberately excludes computed identifiers, arrays, class literals and nested annotation values.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.annotated_arg.package)
  (class_declaration
    (modifiers
      (annotation
        name: (_) @java.annotated_arg.annotation
        arguments: (annotation_argument_list
          (element_value_pair
            key: (identifier) @java.annotated_arg.key
            value: (string_literal
              (string_fragment) @java.annotated_arg.value)))))
    name: (identifier) @java.annotated_arg.class) @java.annotated_arg.definition)

; --- annotations ---

(marker_annotation) @annotation.marker
(annotation) @annotation.normal
(annotation_argument_list) @annotation.arguments
(element_value_pair) @annotation.element_pair
(annotation_type_declaration) @annotation.type
(annotation_type_element_declaration) @annotation.type_element

; --- call_targets ---

(method_invocation
  name: (_) @call.target) @call.expression

; --- calls ---

(method_invocation) @call.method
(object_creation_expression) @call.constructor
(method_reference) @call.method_reference
(argument_list) @call.arguments

; --- classes_inheritance ---

(class_declaration) @class.declaration
(superclass) @class.superclass
(super_interfaces) @class.super_interfaces
(permits) @class.permits
(interface_declaration) @interface.declaration
(extends_interfaces) @interface.extends

; --- comments ---

(line_comment) @comment.line
(block_comment) @comment.block

; --- constructors_initializers ---

(constructor_declaration) @constructor.declaration
(compact_constructor_declaration) @constructor.compact
(explicit_constructor_invocation) @constructor.explicit_invocation
(static_initializer) @initializer.static

; --- control_flow ---

(if_statement) @control.if
(while_statement) @control.while
(do_statement) @control.do
(for_statement) @control.for
(enhanced_for_statement) @control.enhanced_for
(break_statement) @control.break
(continue_statement) @control.continue
(return_statement) @control.return
(labeled_statement) @control.label
(assert_statement) @control.assert

; --- declaration_category_class ---

(class_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_constructor ---

(compact_constructor_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(constructor_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_constant
  name: (_) @definition.category.name
) @definition.category.owner

(enum_declaration
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

; --- declaration_category_module ---

(module_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_record ---

(record_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_resource ---

(resource
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_type ---

(annotation_type_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(annotation_type_element_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_modifiers ---

(annotation_type_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(annotation_type_element_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(class_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(compact_constructor_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(constructor_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(enum_constant
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(enum_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(interface_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(method_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(record_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(resource
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

; --- definition_identity_hints ---

(class_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(compact_constructor_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(constructor_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_constant
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(interface_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(method_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(method_invocation
  name: (_) @definition.identity.name) @definition.identity.owner

(module_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(record_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(resource
  name: (_) @definition.identity.name) @definition.identity.owner

(variable_declarator
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions ---

(class_declaration name: (identifier) @definition.class.name) @definition.class
(interface_declaration name: (identifier) @definition.interface.name) @definition.interface
(enum_declaration name: (identifier) @definition.enum.name) @definition.enum
(record_declaration name: (identifier) @definition.record.name) @definition.record
(annotation_type_declaration name: (identifier) @definition.annotation_type.name) @definition.annotation_type
(method_declaration name: (identifier) @definition.method.name) @definition.method
(constructor_declaration name: (identifier) @definition.constructor.name) @definition.constructor
(compact_constructor_declaration name: (identifier) @definition.compact_constructor.name) @definition.compact_constructor
(field_declaration) @definition.field
(constant_declaration) @definition.constant

; --- enclosing_owner_hints ---

(annotation_type_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(class_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(compact_constructor_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(constructor_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(interface_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(module_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- exceptions ---

(throw_statement) @exception.throw
(try_statement) @exception.try
(try_with_resources_statement) @exception.try_resources
(catch_clause) @exception.catch
(finally_clause) @exception.finally
(resource_specification) @exception.resources
(resource) @exception.resource
(throws) @exception.throws

; --- expressions ---

(assignment_expression) @expression.assignment
(binary_expression) @expression.binary
(unary_expression) @expression.unary
(update_expression) @expression.update
(ternary_expression) @expression.ternary
(cast_expression) @expression.cast
(instanceof_expression) @expression.instanceof
(parenthesized_expression) @expression.parenthesized

; --- field_data ---

(field_declaration) @data.field
(local_variable_declaration) @data.local
(variable_declarator) @data.variable
(array_initializer) @data.array

; --- generics ---

(type_parameters) @generic.parameters
(type_parameter) @generic.parameter
(type_bound) @generic.bound
(type_arguments) @generic.arguments
(wildcard) @generic.wildcard
(generic_type) @generic.type

; --- import_targets ---

(opens_module_directive
  package: (_) @import.target) @import.statement

(requires_module_directive
  module: (_) @import.target) @import.statement

; --- inheritance_target_roles ---

; Exact pinned upstream tags expose these target roles explicitly.
(type_list (type_identifier) @reference.implementation.target) @reference.implementation
(superclass (type_identifier) @reference.superclass.target) @reference.superclass
(object_creation_expression type: (type_identifier) @reference.constructor.type) @reference.constructor

; --- java_attributed_method_context ---

(class_declaration
  name: (identifier) @java.attr.owner_class
  body: (class_body
    (method_declaration
      (modifiers
        (marker_annotation
          name: (_) @java.attr.attribute_name))
      name: (identifier) @java.attr.method_name) @java.attr.method)) @java.attr.class

(class_declaration
  name: (identifier) @java.attr.owner_class
  body: (class_body
    (method_declaration
      (modifiers
        (annotation
          name: (_) @java.attr.attribute_name))
      name: (identifier) @java.attr.method_name) @java.attr.method)) @java.attr.class

; --- lambdas ---

(lambda_expression) @lambda.expression
(inferred_parameters) @lambda.inferred_parameters
(method_reference) @lambda.method_reference

; --- literals ---

(decimal_integer_literal) @literal.decimal_int
(hex_integer_literal) @literal.hex_int
(octal_integer_literal) @literal.octal_int
(binary_integer_literal) @literal.binary_int
(decimal_floating_point_literal) @literal.decimal_float
(hex_floating_point_literal) @literal.hex_float
(character_literal) @literal.char
(string_literal) @literal.string
(null_literal) @literal.null
(true) @literal.true
(false) @literal.false

; --- member_access_hints ---

(field_access
  object: (_) @reference.receiver
  field: (_) @reference.member) @reference.member_expression

; --- member_category_class ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_constructor ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (compact_constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (compact_constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_enum_member ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_body
    (enum_constant
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_enum ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_interface ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_method ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_record ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- member_category_type ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- modifiers ---

(modifiers) @modifier.list

; --- module_declaration_path_hints ---

(module_declaration
  name: (_) @module.declaration_path.name
) @module.declaration_path.span

; --- module_scope ---

(module_body) @java.module.scope

; --- modules ---

(module_declaration) @module.declaration
(requires_module_directive) @module.requires
(exports_module_directive) @module.exports
(opens_module_directive) @module.opens
(uses_module_directive) @module.uses
(provides_module_directive) @module.provides

; --- named_scope_owners ---

(class_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(compact_constructor_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(constructor_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(interface_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(method_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(module_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- objects_arrays ---

(object_creation_expression) @object.creation
(array_creation_expression) @array.creation
(array_initializer) @array.initializer
(array_access) @array.access
(class_literal) @class.literal

; --- ownership_members ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (compact_constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (compact_constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (constructor_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_constant
  name: (_) @owner.name
  body: (class_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_declaration
  name: (_) @owner.name
  body: (enum_body
    (enum_constant
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (annotation_type_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (enum_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (interface_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (method_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (record_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- ownership_parameters ---

(constructor_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (formal_parameter) @owned.parameter)) @owner.span

(constructor_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (receiver_parameter) @owned.parameter)) @owner.span

(constructor_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (spread_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (formal_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (receiver_parameter) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (spread_parameter) @owned.parameter)) @owner.span

; --- package_annotated_class_direct_string_context ---

; Framework-neutral Java package-scoped class annotation with one direct literal string argument.
; Captures syntax/owner only. Framework meaning and import provenance are resolved later.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.pkg_class.direct.package)
  (class_declaration
    (modifiers
      (annotation
        name: (_) @java.pkg_class.direct.annotation
        arguments: (annotation_argument_list
          (string_literal
            (string_fragment) @java.pkg_class.direct.value))))
    name: (identifier) @java.pkg_class.direct.class) @java.pkg_class.direct.definition)

; --- package_annotated_field_import_bound_type_context ---

; Framework-neutral Java package/class-owned annotated field with both annotation
; and field type proven by explicit imports. Narrow direct syntax only.
; No DI/container/framework semantics are inferred here.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.bound_field.package)

  (import_declaration
    (scoped_identifier
      name: (identifier) @java.bound_field.annotation_import_name) @java.bound_field.annotation_import_path)

  (import_declaration
    (scoped_identifier
      name: (identifier) @java.bound_field.type_import_name) @java.bound_field.type_import_path)

  (class_declaration
    name: (identifier) @java.bound_field.owner_class
    body: (class_body
      (field_declaration
        (modifiers
          [(marker_annotation
             name: (identifier) @java.bound_field.annotation_name)
           (annotation
             name: (identifier) @java.bound_field.annotation_name)])
        type: (type_identifier) @java.bound_field.field_type
        declarator: (variable_declarator
          name: (identifier) @java.bound_field.field_name)) @java.bound_field.definition))

  (#eq? @java.bound_field.annotation_import_name @java.bound_field.annotation_name)
  (#eq? @java.bound_field.type_import_name @java.bound_field.field_type))

; --- package_annotated_method_context ---

; Framework-neutral Java method annotation context with package-qualified owner identity.
; Only direct syntax is captured. No framework semantics, import resolution, meta-annotation
; expansion, default values or runtime processing are inferred here.

; Marker annotation, e.g. @GET or @Transactional.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.pkg_method.marker.package)
  (class_declaration
    name: (identifier) @java.pkg_method.marker.class
    body: (class_body
      (method_declaration
        (modifiers
          (marker_annotation
            name: (_) @java.pkg_method.marker.annotation))
        name: (identifier) @java.pkg_method.marker.method) @java.pkg_method.marker.definition)))

; Direct unnamed literal string argument, e.g. @GetMapping("/users").
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.pkg_method.direct.package)
  (class_declaration
    name: (identifier) @java.pkg_method.direct.class
    body: (class_body
      (method_declaration
        (modifiers
          (annotation
            name: (_) @java.pkg_method.direct.annotation
            arguments: (annotation_argument_list
              (string_literal
                (string_fragment) @java.pkg_method.direct.value))))
        name: (identifier) @java.pkg_method.direct.method) @java.pkg_method.direct.definition)))

; Direct named literal string argument, e.g. @GetMapping(path="/users").
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.pkg_method.named.package)
  (class_declaration
    name: (identifier) @java.pkg_method.named.class
    body: (class_body
      (method_declaration
        (modifiers
          (annotation
            name: (_) @java.pkg_method.named.annotation
            arguments: (annotation_argument_list
              (element_value_pair
                key: (identifier) @java.pkg_method.named.argument_name
                value: (string_literal
                  (string_fragment) @java.pkg_method.named.value)))))
        name: (identifier) @java.pkg_method.named.method) @java.pkg_method.named.definition)))

; --- package_interface_import_bound_generic_supertype_context ---

; Framework-neutral Java interface generic-supertype context where both the
; generic supertype and its first type argument are proven by explicit imports.
; No Spring/JPA/repository semantics are inferred here.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.bound_super.package)

  (import_declaration
    (scoped_identifier
      name: (identifier) @java.bound_super.super_import_name) @java.bound_super.super_import_path)

  (import_declaration
    (scoped_identifier
      name: (identifier) @java.bound_super.arg_import_name) @java.bound_super.arg_import_path)

  (interface_declaration
    name: (identifier) @java.bound_super.interface_name
    (extends_interfaces
      (type_list
        (generic_type
          (type_identifier) @java.bound_super.supertype_name
          (type_arguments
            . (type_identifier) @java.bound_super.first_type_argument)))) @java.bound_super.definition)

  (#eq? @java.bound_super.super_import_name @java.bound_super.supertype_name)
  (#eq? @java.bound_super.arg_import_name @java.bound_super.first_type_argument))

; --- packages_imports ---

(package_declaration) @package.declaration
(import_declaration) @import.declaration
(scoped_identifier) @name.scoped

; --- parameters_bindings ---

(formal_parameters) @binding.parameters
(formal_parameter) @binding.parameter
(receiver_parameter) @binding.receiver
(spread_parameter) @binding.spread
(local_variable_declaration) @binding.local
(variable_declarator) @binding.variable
(catch_formal_parameter) @binding.catch

; --- preview_boundaries ---

(record_pattern) @preview.record_pattern
(guard) @preview.guard
(template_expression) @preview.template_expression
(underscore_pattern) @preview.underscore_pattern

; --- qualified_chain_hints ---

(field_access
  object: (_) @reference.qualified_chain.base
  field: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(scoped_identifier
  scope: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

; --- qualified_name_hints ---

(scoped_identifier
  scope: (_) @reference.qualifier
  name: (_) @reference.qualified_name) @reference.qualified_expression

; --- receiver_hints ---

(super) @reference.receiver

(this) @reference.receiver

; --- records_enums ---

(record_declaration) @record.declaration
(record_pattern) @record.pattern
(record_pattern_component) @record.pattern.component
(enum_declaration) @enum.declaration
(enum_constant) @enum.constant

; --- references ---

(identifier) @reference.identifier
(scoped_identifier) @reference.scoped_identifier
(scoped_type_identifier) @reference.scoped_type
(field_access) @reference.field_access
(array_access) @reference.array_access
(method_invocation) @reference.method_invocation
(method_reference) @reference.method_reference
(this) @reference.this
(super) @reference.super

; --- scopes ---

(program) @scope.program
(class_body) @scope.class
(interface_body) @scope.interface
(enum_body) @scope.enum
(annotation_type_body) @scope.annotation_type
(constructor_body) @scope.constructor
(block) @scope.block
(lambda_expression) @scope.lambda

; --- signature_parameters ---

(constructor_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(method_declaration
  name: (_) @definition.signature.name
  type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(class_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(constructor_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(interface_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(record_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- string_templates ---

(string_literal) @string.literal
(string_interpolation) @string.interpolation
(template_expression) @string.template_expression
(escape_sequence) @string.escape

; --- switch_patterns ---

(switch_expression) @switch.expression
(switch_block) @switch.block
(switch_rule) @switch.rule
(switch_label) @switch.label
(pattern) @pattern.generic
(type_pattern) @pattern.type
(record_pattern) @pattern.record
(guard) @pattern.guard
(yield_statement) @switch.yield

; --- synchronization ---

(synchronized_statement) @sync.statement

; --- tests ---

(method_declaration name: (identifier) @test.method.name) @test.method
(annotation) @test.annotation
(marker_annotation) @test.marker_annotation

; --- types ---

(annotated_type) @type.annotated
(scoped_type_identifier) @type.scoped
(generic_type) @type.generic
(array_type) @type.array
(integral_type) @type.integral
(floating_point_type) @type.floating
(boolean_type) @type.boolean
(void_type) @type.void
(catch_type) @type.catch


; --- package_constructor_parameter_import_bound_type_context ---

; Framework-neutral Java constructor-parameter context where a direct simple
; parameter type is proven by an explicit import. No DI/container semantics here.
(program
  (package_declaration
    [(identifier) (scoped_identifier)] @java.ctor_param.package)

  (import_declaration
    (scoped_identifier
      name: (identifier) @java.ctor_param.type_import_name) @java.ctor_param.type_import_path)

  (class_declaration
    name: (identifier) @java.ctor_param.owner_class
    body: (class_body
      (constructor_declaration
        name: (identifier) @java.ctor_param.constructor_name
        parameters: (formal_parameters
          (formal_parameter
            type: (type_identifier) @java.ctor_param.parameter_type
            name: (identifier) @java.ctor_param.parameter_name))) @java.ctor_param.definition))

  (#eq? @java.ctor_param.type_import_name @java.ctor_param.parameter_type))

; --- generic direct annotation argument values (source-only, no annotation processing) ---

(annotation
  name: (_) @java.annotation_value.named_identifier.annotation
  arguments: (annotation_argument_list
    (element_value_pair
      key: (identifier) @java.annotation_value.named_identifier.key
      value: (identifier) @java.annotation_value.named_identifier.value))) @java.annotation_value.named_identifier.context

(annotation
  name: (_) @java.annotation_value.named_class_literal.annotation
  arguments: (annotation_argument_list
    (element_value_pair
      key: (identifier) @java.annotation_value.named_class_literal.key
      value: (class_literal) @java.annotation_value.named_class_literal.value))) @java.annotation_value.named_class_literal.context

(annotation
  name: (_) @java.annotation_value.default_identifier.annotation
  arguments: (annotation_argument_list
    (identifier) @java.annotation_value.default_identifier.value)) @java.annotation_value.default_identifier.context

(annotation
  name: (_) @java.annotation_value.default_class_literal.annotation
  arguments: (annotation_argument_list
    (class_literal) @java.annotation_value.default_class_literal.value)) @java.annotation_value.default_class_literal.context

(annotation
  name: (_) @java.annotation_value.default_string.annotation
  arguments: (annotation_argument_list
    (string_literal) @java.annotation_value.default_string.value)) @java.annotation_value.default_string.context

(annotation
  name: (_) @java.annotation_value.array_identifier.annotation
  arguments: (annotation_argument_list
    (element_value_pair
      key: (identifier) @java.annotation_value.array_identifier.key
      value: (element_value_array_initializer
        (identifier) @java.annotation_value.array_identifier.value)))) @java.annotation_value.array_identifier.context

(annotation
  name: (_) @java.annotation_value.array_class_literal.annotation
  arguments: (annotation_argument_list
    (element_value_pair
      key: (identifier) @java.annotation_value.array_class_literal.key
      value: (element_value_array_initializer
        (class_literal) @java.annotation_value.array_class_literal.value)))) @java.annotation_value.array_class_literal.context

(annotation
  name: (_) @java.annotation_value.array_string.annotation
  arguments: (annotation_argument_list
    (element_value_pair
      key: (identifier) @java.annotation_value.array_string.key
      value: (element_value_array_initializer
        (string_literal) @java.annotation_value.array_string.value)))) @java.annotation_value.array_string.context
