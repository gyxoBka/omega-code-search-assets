; --- bindings ---

(variable_declarator name: (identifier) @binding.name @definition.variable.name) @binding.variable @definition.variable
(required_parameter pattern: (identifier) @binding.name) @binding.parameter
(optional_parameter pattern: (identifier) @binding.name) @binding.parameter

; --- block_call_context ---

; Generic ECMAScript literal-labeled callback ownership contexts.
; Framework-neutral: captures only outer call identity/label and direct child calls.

; describe("suite", () => { test("case", ...) })-shape
(call_expression
  function: (identifier) @ecma.owned_string.owner_call
  arguments: (arguments
    (string (string_fragment) @ecma.owned_string.owner_label)
    (arrow_function
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.owned_string.child_call
            arguments: (arguments
              (string (string_fragment) @ecma.owned_string.child_label))) @ecma.owned_string.child_context))))) @ecma.owned_string.owner_context

(call_expression
  function: (identifier) @ecma.owned_string.owner_call
  arguments: (arguments
    (string (string_fragment) @ecma.owned_string.owner_label)
    (function_expression
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.owned_string.child_call
            arguments: (arguments
              (string (string_fragment) @ecma.owned_string.child_label))) @ecma.owned_string.child_context))))) @ecma.owned_string.owner_context

; describe("suite", () => { beforeEach(...) })-shape
(call_expression
  function: (identifier) @ecma.owned_call.owner_call
  arguments: (arguments
    (string (string_fragment) @ecma.owned_call.owner_label)
    (arrow_function
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.owned_call.child_call) @ecma.owned_call.child_context))))) @ecma.owned_call.owner_context

(call_expression
  function: (identifier) @ecma.owned_call.owner_call
  arguments: (arguments
    (string (string_fragment) @ecma.owned_call.owner_label)
    (function_expression
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.owned_call.child_call) @ecma.owned_call.child_context))))) @ecma.owned_call.owner_context

; test.describe("suite", () => { test("case", ...) })-shape
(call_expression
  function: (member_expression
    object: (identifier) @ecma.member_owned_string.owner_object
    property: (property_identifier) @ecma.member_owned_string.owner_call)
  arguments: (arguments
    (string (string_fragment) @ecma.member_owned_string.owner_label)
    (arrow_function
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.member_owned_string.child_call
            arguments: (arguments
              (string (string_fragment) @ecma.member_owned_string.child_label))) @ecma.member_owned_string.child_context))))) @ecma.member_owned_string.owner_context

(call_expression
  function: (member_expression
    object: (identifier) @ecma.member_owned_string.owner_object
    property: (property_identifier) @ecma.member_owned_string.owner_call)
  arguments: (arguments
    (string (string_fragment) @ecma.member_owned_string.owner_label)
    (function_expression
      body: (statement_block
        (expression_statement
          (call_expression
            function: (identifier) @ecma.member_owned_string.child_call
            arguments: (arguments
              (string (string_fragment) @ecma.member_owned_string.child_label))) @ecma.member_owned_string.child_context))))) @ecma.member_owned_string.owner_context

; test.describe("suite", () => { test.beforeEach(...) })-shape
(call_expression
  function: (member_expression
    object: (identifier) @ecma.member_owned_member.owner_object
    property: (property_identifier) @ecma.member_owned_member.owner_call)
  arguments: (arguments
    (string (string_fragment) @ecma.member_owned_member.owner_label)
    (arrow_function
      body: (statement_block
        (expression_statement
          (call_expression
            function: (member_expression
              object: (identifier) @ecma.member_owned_member.child_object
              property: (property_identifier) @ecma.member_owned_member.child_call)) @ecma.member_owned_member.child_context))))) @ecma.member_owned_member.owner_context

(call_expression
  function: (member_expression
    object: (identifier) @ecma.member_owned_member.owner_object
    property: (property_identifier) @ecma.member_owned_member.owner_call)
  arguments: (arguments
    (string (string_fragment) @ecma.member_owned_member.owner_label)
    (function_expression
      body: (statement_block
        (expression_statement
          (call_expression
            function: (member_expression
              object: (identifier) @ecma.member_owned_member.child_object
              property: (property_identifier) @ecma.member_owned_member.child_call)) @ecma.member_owned_member.child_context))))) @ecma.member_owned_member.owner_context

; --- call_nested_object_identifier_context ---

; Framework-neutral ECMA direct call -> object -> nested object -> nested object -> identifier value.
; Exact authored subset only: direct identifier call, property_identifier keys, direct nested objects,
; and direct identifier leaf. No spreads, computed/string keys, shorthand properties, arrays,
; member calls, function expressions, arrow functions, template strings, variables, or runtime composition.

(call_expression
  function: (identifier) @ecma.call_nested_identifier.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_nested_identifier.outer_key
        value: (object
          (pair
            key: (property_identifier) @ecma.call_nested_identifier.owner_key
            value: (object
              (pair
                key: (property_identifier) @ecma.call_nested_identifier.field_key
                value: (identifier) @ecma.call_nested_identifier.value_identifier) @ecma.call_nested_identifier.field_pair) @ecma.call_nested_identifier.owner_object) @ecma.call_nested_identifier.owner_pair) @ecma.call_nested_identifier.outer_object) @ecma.call_nested_identifier.outer_pair) @ecma.call_nested_identifier.config_object)) @ecma.call_nested_identifier.context

; --- call_object_array_direct_call_context ---

; Framework-neutral ECMA direct call -> object -> flat array -> direct identifier call item.
; Exact authored subset only: direct identifier owner call, property_identifier key, direct array,
; and direct identifier item calls. No spreads, variables, member/computed calls, or runtime arrays.

(call_expression
  function: (identifier) @ecma.call_object_array_call.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_object_array_call.key
        value: (array
          (call_expression
            function: (identifier) @ecma.call_object_array_call.item_call_name
            arguments: (arguments) @ecma.call_object_array_call.item_arguments) @ecma.call_object_array_call.item_context) @ecma.call_object_array_call.array) @ecma.call_object_array_call.pair) @ecma.call_object_array_call.config_object)) @ecma.call_object_array_call.context

; --- call_object_array_object_string_identifier_context ---

; Framework-neutral ECMA direct call -> object -> array -> object containing one plain string field
; and one direct identifier field. Both authored source orders are captured.
; No spreads, computed/string keys, template strings, variable arrays, member/computed owner calls,
; nested expressions, shorthand fields, or runtime composition.

(call_expression
  function: (identifier) @ecma.call_array_object_pair.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_array_object_pair.array_key
        value: (array
          (object
            (pair
              key: (property_identifier) @ecma.call_array_object_pair.string_key
              value: (string (string_fragment) @ecma.call_array_object_pair.string_value))
            (pair
              key: (property_identifier) @ecma.call_array_object_pair.identifier_key
              value: (identifier) @ecma.call_array_object_pair.identifier_value)) @ecma.call_array_object_pair.item_object) @ecma.call_array_object_pair.array) @ecma.call_array_object_pair.array_pair) @ecma.call_array_object_pair.config_object)) @ecma.call_array_object_pair.context

(call_expression
  function: (identifier) @ecma.call_array_object_pair.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_array_object_pair.array_key
        value: (array
          (object
            (pair
              key: (property_identifier) @ecma.call_array_object_pair.identifier_key
              value: (identifier) @ecma.call_array_object_pair.identifier_value)
            (pair
              key: (property_identifier) @ecma.call_array_object_pair.string_key
              value: (string (string_fragment) @ecma.call_array_object_pair.string_value))) @ecma.call_array_object_pair.item_object) @ecma.call_array_object_pair.array) @ecma.call_array_object_pair.array_pair) @ecma.call_array_object_pair.config_object)) @ecma.call_array_object_pair.context

; --- call_object_literal_fields ---

; Framework-neutral authored ECMAScript call-object metadata.
; Intentionally restricted to a direct identifier callee, direct object literal,
; property_identifier key, and literal string / flat array literal string values.

(call_expression
  function: (identifier) @ecma.call_object_string.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_object_string.key
        value: (string
          (string_fragment) @ecma.call_object_string.value))))) @ecma.call_object_string.context

(call_expression
  function: (identifier) @ecma.call_object_array.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_object_array.key
        value: (array
          (string
            (string_fragment) @ecma.call_object_array.value)))))) @ecma.call_object_array.context

; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls ---

(call_expression function: (identifier) @call.target @ecma.direct_context.call_name
  arguments: (arguments) @call.direct.args @ecma.direct_context.arguments) @call.direct @ecma.direct_context.context
(call_expression
  function: (member_expression
    object: (_) @call.member.receiver
    property: (property_identifier) @call.target)
  arguments: (arguments) @call.member.args) @call.member
(new_expression constructor: (identifier) @call.target @ts.ctor_identifier.constructor_name) @call.constructor @ts.ctor_identifier.context

; --- class_decorator_object_array_identifier_context ---

(class_declaration
  decorator: (decorator
    (call_expression
      function: (identifier) @ts.decorator_array.decorator_name
      arguments: (arguments
        (object
          (pair
            key: (property_identifier) @ts.decorator_array.field_name
            value: (array
              (identifier) @ts.decorator_array.item_identifier))))))
  name: (type_identifier) @ts.decorator_array.owner_class) @ts.decorator_array.class

; --- class_decorator_object_string_field_context ---

; Framework-neutral TypeScript class decorator object-literal plain-string field.
; Captures authored syntax only; decorator package/provenance remains separate evidence.
(class_declaration
  decorator: (decorator
    (call_expression
      function: (identifier) @ts.decorator_string.decorator_name
      arguments: (arguments
        (object
          (pair
            key: (property_identifier) @ts.decorator_string.field_name
            value: (string
              (string_fragment) @ts.decorator_string.string_value))))))
  name: (type_identifier) @ts.decorator_string.owner_class) @ts.decorator_string.class

; --- constructor_identifier_context ---

; --- data ---

(object) @data.object
(array) @data.array
(string) @data.string
(number) @data.number
(true) @data.boolean
(false) @data.boolean
(null) @data.null

; --- declaration_category_class ---

(abstract_class_declaration
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(class
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(class_declaration
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_enum ---

(enum_assignment
  name: (_) @definition.category.enum.name
) @definition.category.owner

(enum_body
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(enum_declaration
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_field ---

(public_field_definition
  name: (_) @definition.category.field.name @definition.identity.name @member.field.name
) @definition.category.owner @definition.identity.owner @member.field

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(function_expression
  name: (_) @definition.category.function.name
) @definition.category.owner

(function_signature
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(generator_function
  name: (_) @definition.category.function.name
) @definition.category.owner

(generator_function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_interface ---

(interface_declaration
  name: (_) @definition.category.interface.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_method ---

(abstract_method_signature
  name: (_) @definition.category.method.name @member.abstract_method.name
) @definition.category.owner @member.abstract_method

(method_definition
  name: (_) @definition.category.method.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(method_signature
  name: (_) @definition.category.method.name @definition.identity.name @member.method_signature.name
) @definition.category.owner @definition.identity.owner @member.method_signature

; --- declaration_category_module ---

(internal_module
  name: (_) @definition.category.module.name
) @definition.category.owner

(module
  name: (_) @definition.category.module.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_property ---

(property_signature
  name: (_) @definition.category.property.name @member.property_signature.name
) @definition.category.owner @member.property_signature

; --- declaration_category_type ---

(type_alias_declaration
  name: (_) @definition.category.type.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_modifiers ---

(abstract_method_signature
  name: (_) @definition.modifiers.name
  (override_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(method_definition
  name: (_) @definition.modifiers.name
  (override_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(method_signature
  name: (_) @definition.modifiers.name
  (override_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(property_signature
  name: (_) @definition.modifiers.name
  (override_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(public_field_definition
  name: (_) @definition.modifiers.name
  (override_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

; --- declaration_visibility ---

(abstract_method_signature
  (accessibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(method_definition
  (accessibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(method_signature
  (accessibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(property_signature
  (accessibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(public_field_definition
  (accessibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

; --- declarations_extended ---

(abstract_class_declaration name: (type_identifier) @definition.abstract_class.name) @definition.abstract_class
(function_signature name: (identifier) @definition.function_signature.name) @definition.function_signature
(import_alias) @definition.import_alias @module.import_alias
(internal_module) @definition.namespace @module.namespace
(module) @definition.module @module.module
(ambient_declaration) @definition.ambient @module.ambient.extended @module.ambient
(enum_declaration name: (identifier) @definition.enum.extended.name @definition.enum.name) @definition.enum.extended @definition.enum

; --- definition_identity_hints ---

(variable_declarator
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions ---

(function_declaration name: (identifier) @definition.function.name) @definition.function
(class_declaration name: (type_identifier) @definition.class.name) @definition.class
(interface_declaration name: (type_identifier) @definition.interface.name @interface.name @type.interface.name) @definition.interface @interface.declaration @type.interface
(type_alias_declaration name: (type_identifier) @definition.type_alias.name) @definition.type_alias
(method_definition name: (property_identifier) @definition.method.name) @definition.method

; --- enclosing_owner_hints ---

(abstract_class_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(class 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(class_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(interface_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(internal_module 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(module 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- export_alias_hints ---

(export_specifier
  name: (_) @module.export_alias.local
  alias: (_) @module.export_alias.public
) @module.export_alias.statement

; --- export_object_identifier_field_context ---

; Framework-neutral ECMA default-export object direct identifier field.
; Exact subset only: export default { key: Identifier }.
; Member expressions, shorthand, spreads, computed/string keys and indirection remain outside this D1.
(export_statement
  value: (object
    (pair
      key: (property_identifier) @ecma.export_object_identifier.key
      value: (identifier) @ecma.export_object_identifier.value) @ecma.export_object_identifier.pair) @ecma.export_object_identifier.object) @ecma.export_object_identifier.context

; --- expressions_extended ---

(as_expression) @expression.as @type.as_expression
(satisfies_expression) @expression.satisfies @type.satisfies
; TSX has no `<T>expr` assertion: that syntax is JSX here, so the
; TypeScript grammar's `type_assertion` node does not exist in this one.
(non_null_expression) @expression.non_null @type.non_null
(instantiation_expression function: (_) @expression.instantiation.function type_arguments: (type_arguments) @expression.instantiation.type_arguments) @expression.instantiation
(assignment_expression left: (_) @expression.assignment.left right: (_) @expression.assignment.right) @expression.assignment
(augmented_assignment_expression left: (_) @expression.augmented.left operator: (_) @expression.augmented.operator right: (_) @expression.augmented.right) @expression.augmented
(await_expression) @expression.await
(yield_expression) @expression.yield

; --- heritage_members ---

(extends_clause (_) @relation.extends.target) @relation.extends
(implements_clause (_) @relation.implements.target) @relation.implements
(index_signature) @member.index_signature
(call_signature) @member.call_signature
(construct_signature) @member.construct_signature

; --- import_alias_hints ---

(import_specifier
  name: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- import_default_binding ---

(import_clause (identifier) @ts.import.default) @ts.import.clause

; --- import_named_binding ---

(import_specifier name: (_) @ts.import.imported alias: (identifier) @ts.import.local) @ts.import.specifier

; --- import_named_unaliased_binding ---

(import_specifier name: (identifier) @ts.import.local) @ts.import.specifier

; --- import_namespace_binding ---

(import_clause (namespace_import (identifier) @ts.import.namespace)) @ts.import.clause

; --- import_targets ---

(import_require_clause
  source: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

(import_specifier
  name: (_) @import.target) @import.statement

(import_statement
  source: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

; --- imported_constructor_binding_context ---

(program
  (import_statement
    (import_clause
      (named_imports
        (import_specifier
          name: (identifier) @ts.import_ctor_binding.imported
          alias: (identifier) @ts.import_ctor_binding.local)))
    source: (string (string_fragment) @ts.import_ctor_binding.module_source))
  (lexical_declaration
    (variable_declarator
      name: (identifier) @ts.import_ctor_binding.binding_name
      value: (new_expression
        constructor: (identifier) @ts.import_ctor_binding.constructor_name
        arguments: (arguments)) @ts.import_ctor_binding.new_expression) @ts.import_ctor_binding.context)
  (#eq? @ts.import_ctor_binding.local @ts.import_ctor_binding.constructor_name))

(program
  (import_statement
    (import_clause
      (named_imports
        (import_specifier
          name: (identifier) @ts.import_ctor_binding.imported @ts.import_ctor_binding.local)))
    source: (string (string_fragment) @ts.import_ctor_binding.module_source))
  (lexical_declaration
    (variable_declarator
      name: (identifier) @ts.import_ctor_binding.binding_name
      value: (new_expression
        constructor: (identifier) @ts.import_ctor_binding.constructor_name
        arguments: (arguments)) @ts.import_ctor_binding.new_expression) @ts.import_ctor_binding.context)
  (#eq? @ts.import_ctor_binding.local @ts.import_ctor_binding.constructor_name))

; --- imports ---

(import_statement source: (string) @import.source) @import.statement
(import_require_clause source: (string) @import.source @module.import_require.source) @import.require @module.import_require

; --- member_access_hints ---

(member_expression
  object: (_) @reference.receiver
  property: (_) @reference.member) @reference.member_expression

; --- member_category_enum_member ---

(enum_declaration
  name: (_) @owner.name
  body: (enum_body
    (enum_assignment
      name: (_) @owned.member_category.enum_member.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_field ---

(abstract_class_declaration
  name: (_) @owner.name
  body: (class_body
    (public_field_definition
      name: (_) @owned.member_category.field.name @owned.member.name) @owned.member)) @owner.span

(class
  name: (_) @owner.name
  body: (class_body
    (public_field_definition
      name: (_) @owned.member_category.field.name @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (public_field_definition
      name: (_) @owned.member_category.field.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_method ---

(abstract_class_declaration
  name: (_) @owner.name
  body: (class_body
    (abstract_method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(abstract_class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_definition
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(abstract_class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class
  name: (_) @owner.name
  body: (class_body
    (abstract_method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class
  name: (_) @owner.name
  body: (class_body
    (method_definition
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class
  name: (_) @owner.name
  body: (class_body
    (method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (abstract_method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_definition
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (method_signature
      name: (_) @owned.member_category.method.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_property ---

(interface_declaration
  name: (_) @owner.name
  body: (interface_body
    (property_signature
      name: (_) @owned.member_category.property.name @owned.member.name) @owned.member)) @owner.span

; --- member_string_identifier_call_context ---

(call_expression
  function: (member_expression
    object: (identifier) @ts.member_string_id.receiver
    property: (property_identifier) @ts.member_string_id.member)
  arguments: (arguments
    (string (string_fragment) @ts.member_string_id.arg0)
    (identifier) @ts.member_string_id.arg1)) @ts.member_string_id.context

; --- module_path_hints ---

; --- modules_extended ---

(export_statement) @module.export.extended @module.export

; --- modules ---

; --- named_import_source_context ---

(import_statement
  (import_clause
    (named_imports
      (import_specifier
        name: (identifier) @ts.named_import.imported
        alias: (identifier) @ts.named_import.local) @ts.named_import.specifier))
  source: (string (string_fragment) @ts.named_import.module_source)) @ts.named_import.statement

(import_statement
  (import_clause
    (named_imports
      (import_specifier
        name: (identifier) @ts.named_import.imported @ts.named_import.local) @ts.named_import.specifier))
  source: (string (string_fragment) @ts.named_import.module_source)) @ts.named_import.statement

; --- named_scope_owners ---

(function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_expression
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(generator_function
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(generator_function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(method_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- object_fluent_procedure_context ---

; Framework-neutral ECMA/TypeScript variable -> call(object property -> fluent 3-stage member-call chain).
; No tRPC semantics here: owner call, property name and fluent member/argument texts are emitted as authored syntax.

(variable_declarator
  name: (identifier) @ecma.fluent.owner_variable
  value: (call_expression
    function: (identifier) @ecma.fluent.owner_call
    arguments: (arguments
      (object
        (pair
          key: (property_identifier) @ecma.fluent.property_name
          value: (call_expression
            function: (member_expression
              object: (call_expression
                function: (member_expression
                  object: (call_expression
                    function: (member_expression
                      object: (_) @ecma.fluent.base_expression
                      property: (property_identifier) @ecma.fluent.stage1_name)
                    arguments: (arguments
                      (_) @ecma.fluent.stage1_argument))
                  property: (property_identifier) @ecma.fluent.stage2_name)
                arguments: (arguments
                  (_) @ecma.fluent.stage2_argument))
              property: (property_identifier) @ecma.fluent.terminal_name)
            arguments: (arguments)) @ecma.fluent.property_value) @ecma.fluent.property_pair))) @ecma.fluent.owner_initializer) @ecma.fluent.context

(variable_declarator
  name: (identifier) @ecma.fluent.owner_variable
  value: (call_expression
    function: (member_expression
      property: (property_identifier) @ecma.fluent.owner_call)
    arguments: (arguments
      (object
        (pair
          key: (property_identifier) @ecma.fluent.property_name
          value: (call_expression
            function: (member_expression
              object: (call_expression
                function: (member_expression
                  object: (call_expression
                    function: (member_expression
                      object: (_) @ecma.fluent.base_expression
                      property: (property_identifier) @ecma.fluent.stage1_name)
                    arguments: (arguments
                      (_) @ecma.fluent.stage1_argument))
                  property: (property_identifier) @ecma.fluent.stage2_name)
                arguments: (arguments
                  (_) @ecma.fluent.stage2_argument))
              property: (property_identifier) @ecma.fluent.terminal_name)
            arguments: (arguments)) @ecma.fluent.property_value) @ecma.fluent.property_pair))) @ecma.fluent.owner_initializer) @ecma.fluent.context

; --- ownership_members ---

; --- ownership_parameters ---

(abstract_method_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(abstract_method_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(function_expression
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(function_expression
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(function_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(function_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(generator_function
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(generator_function
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(generator_function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(generator_function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(method_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(method_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

(method_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(method_signature
  name: (_) @owner.name
  parameters: (formal_parameters
    (required_parameter) @owned.parameter)) @owner.span

; --- patterns_extended ---

(array_pattern) @pattern.array
(object_pattern) @pattern.object
(rest_pattern) @pattern.rest
(assignment_pattern) @pattern.assignment
(variable_declarator name: [(array_pattern) (object_pattern)] @binding.destructuring) @binding.destructuring.declarator
(required_parameter pattern: [(array_pattern) (object_pattern)] @binding.parameter.destructuring) @binding.parameter.destructuring.required
(optional_parameter pattern: [(array_pattern) (object_pattern)] @binding.parameter.optional_destructuring) @binding.parameter.destructuring.optional

; --- qualified_chain_hints ---

(nested_type_identifier
  module: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

; --- receiver_hints ---

(super) @reference.receiver

(this) @reference.receiver

; --- reexport_hints ---

(export_statement 
  source: (_) @module.reexport.target
) @module.reexport.statement

; --- references ---

(identifier) @reference.identifier
(type_identifier) @reference.type_identifier

; --- root_member_call_context ---

(call_expression
  function: (member_expression
    object: (identifier) @ecma.root_member_call.root
    property: (property_identifier) @ecma.root_member_call.member)
  arguments: (arguments) @ecma.root_member_call.arguments) @ecma.root_member_call.context

; --- scopes ---

(function_declaration) @scope.function
(class_declaration) @scope.class
(interface_declaration) @scope.interface
(statement_block) @scope.block

; --- signature_parameters ---

(abstract_method_signature
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_expression
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_signature
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(generator_function
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(generator_function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_definition
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_signature
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(abstract_method_signature
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_expression
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_signature
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(generator_function
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(generator_function_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(method_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(method_signature
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(abstract_class_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(abstract_method_signature
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(class
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(class_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_expression
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_signature
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(generator_function
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(generator_function_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(interface_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(method_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(method_signature
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_alias_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- tests ---

(call_expression function: (identifier) @test.api arguments: (arguments (string) @test.name)) @test.declaration

; --- type_parameters_extended ---

(type_parameter name: (type_identifier) @type.parameter.name constraint: (constraint)? @type.parameter.constraint value: (default_type)? @type.parameter.default) @type.parameter
(type_parameters (type_parameter) @type.parameters.item) @type.parameters.extended
(type_arguments (_) @type.arguments.item) @type.arguments.extended
(required_parameter name: (_) @parameter.required.name type: (_)? @parameter.required.type) @parameter.required
(optional_parameter name: (_) @parameter.optional.name type: (_)? @parameter.optional.type) @parameter.optional

; --- type_system_extended ---

(union_type) @type.union
(intersection_type) @type.intersection
(generic_type) @type.generic
(array_type) @type.array
(tuple_type) @type.tuple
(object_type) @type.object
(function_type) @type.function
(constructor_type) @type.constructor
(conditional_type) @type.conditional.extended @type.conditional
(infer_type) @type.infer
(mapped_type_clause name: (type_identifier) @type.mapped.name type: (_) @type.mapped.constraint alias: (_)? @type.mapped.alias) @type.mapped
(index_type_query) @type.keyof
(lookup_type) @type.lookup
(type_query) @type.typeof
(template_literal_type) @type.template_literal
(literal_type) @type.literal
(predefined_type) @type.predefined
(readonly_type) @type.readonly
(this_type) @type.this
(type_predicate name: (_) @type.predicate.name type: (_) @type.predicate.type) @type.predicate
(asserts) @type.asserts
(instantiation_expression) @type.instantiation

; --- types ---

(type_annotation) @type.annotation
(type_alias_declaration name: (type_identifier) @type.alias.name value: (_) @type.alias.value) @type.alias
(type_parameters) @type.parameters
(type_arguments) @type.arguments

; --- generic_decorator_reference ---

(decorator) @decorator

(decorator
  (call_expression
    function: [
      (identifier) @decorator.callee
      (member_expression property: (property_identifier) @decorator.callee)
    ] @decorator.target
    arguments: (arguments) @decorator.args)) @decorator.call

; --- ecmascript_build_config_string_context ---

(call_expression
  function: (identifier) @ecma.call_nested_string.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.call_nested_string.outer_key
        value: (object
          (pair
            key: (property_identifier) @ecma.call_nested_string.key
            value: (string (string_fragment) @ecma.call_nested_string.value))))))) @ecma.call_nested_string.context

(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.export_string.owner_identifier
    property: (property_identifier) @ecma.export_string.owner_property)
  right: (object
    (pair
      key: (property_identifier) @ecma.export_string.key
      value: (string (string_fragment) @ecma.export_string.value)))) @ecma.export_string.context

(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.export_nested_string.owner_identifier
    property: (property_identifier) @ecma.export_nested_string.owner_property)
  right: (object
    (pair
      key: (property_identifier) @ecma.export_nested_string.outer_key
      value: (object
        (pair
          key: (property_identifier) @ecma.export_nested_string.key
          value: (string (string_fragment) @ecma.export_nested_string.value)))))) @ecma.export_nested_string.context

; --- ecmascript_root_member_argument_context_v3_146 ---

; Framework-neutral authored root.member("literal") call.
(call_expression
  function: (member_expression
    object: (identifier) @ecma.root_member_string.root
    property: (property_identifier) @ecma.root_member_string.member)
  arguments: (arguments
    . (string) @ecma.root_member_string.arg0)) @ecma.root_member_string.context

; Framework-neutral authored root.member({ key: identifier }) call.
(call_expression
  function: (member_expression
    object: (identifier) @ecma.root_member_object_identifier.root
    property: (property_identifier) @ecma.root_member_object_identifier.member)
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ecma.root_member_object_identifier.field_key
        value: (identifier) @ecma.root_member_object_identifier.value_identifier)))) @ecma.root_member_object_identifier.context

; --- semantic_closure_v3_146_ts_member_decorators ---

(class_declaration
  name: (type_identifier) @ts.member_decorator.owner_class
  body: (class_body
    (public_field_definition
      decorator: (decorator
        (call_expression
          function: (identifier) @ts.member_decorator.decorator_name))
      name: [(property_identifier) (private_property_identifier) (string)] @ts.member_decorator.member_name) @ts.member_decorator.member)) @ts.member_decorator.class_context

(class_declaration
  name: (type_identifier) @ts.member_marker.owner_class
  body: (class_body
    (public_field_definition
      decorator: (decorator
        (identifier) @ts.member_marker.decorator_name)
      name: [(property_identifier) (private_property_identifier) (string)] @ts.member_marker.member_name) @ts.member_marker.member)) @ts.member_marker.class_context
; The TSX grammar rejects this pattern as impossible. It is kept in
; the TypeScript Pack, where it compiles; TSX is a different parser.
;
; (class_declaration
;   name: (type_identifier) @ts.ctor_param_decorator.owner_class
;   body: (class_body
;     (method_definition
;       name: (property_identifier) @ts.ctor_param_decorator.constructor_name
;       parameters: (formal_parameters
;         (required_parameter
;           decorator: (decorator
;             (call_expression function: (identifier) @ts.ctor_param_decorator.decorator_name))
;           name: (identifier) @ts.ctor_param_decorator.parameter_name) @ts.ctor_param_decorator.parameter))) @ts.ctor_param_decorator.class_context
;  (#eq? @ts.ctor_param_decorator.constructor_name "constructor"))

; --- class_decorator_object_array_string_context ---
(class_declaration
  decorator: (decorator
    (call_expression
      function: (identifier) @ts.decorator_array_string.decorator_name
      arguments: (arguments
        (object
          (pair
            key: (property_identifier) @ts.decorator_array_string.field_name
            value: (array
              (string
                (string_fragment) @ts.decorator_array_string.item_string)))))))
  name: (type_identifier) @ts.decorator_array_string.owner_class) @ts.decorator_array_string.class

; --- semantic_closure_v3_146_ts_constructor_parameter_type ---
(class_declaration
  name: (type_identifier) @ts.ctor_type.owner_class
  body: (class_body
    (method_definition
      name: (property_identifier) @ts.ctor_type.constructor_name
      parameters: (formal_parameters
        [
          (required_parameter
            name: (identifier) @ts.ctor_type.parameter_name
            type: (type_annotation) @ts.ctor_type.parameter_type)
          (optional_parameter
            name: (identifier) @ts.ctor_type.parameter_name
            type: (type_annotation) @ts.ctor_type.parameter_type)
        ] @ts.ctor_type.parameter)) @ts.ctor_type.method) @ts.ctor_type.class_context
 (#eq? @ts.ctor_type.constructor_name "constructor"))

; --- semantic_closure_v3_146_ecma_direct_call_arguments ---
(call_expression
  function: (identifier) @ecma.direct_id_arg.call_name
  arguments: (arguments
    (identifier) @ecma.direct_id_arg.arg1)) @ecma.direct_id_arg.context

(call_expression
  function: (identifier) @ecma.direct_string_arg.call_name
  arguments: (arguments
    (string
      (string_fragment) @ecma.direct_string_arg.arg1))) @ecma.direct_string_arg.context

(call_expression
  function: (identifier) @ecma.direct_array.call_name
  arguments: (arguments
    (_)
    (array
      (identifier) @ecma.direct_array.item))) @ecma.direct_array.context
; The TSX grammar rejects this pattern as impossible. It is kept in
; the TypeScript Pack, where it compiles; TSX is a different parser.
; ; The TSX grammar rejects this pattern as impossible. It is kept in
; ; the TypeScript Pack, where it compiles; TSX is a different parser.
; ;
; ; (class_declaration
; ;   name: (_) @ecma.class_extends.class_name
; ;   (class_heritage
; ;     (identifier) @ecma.class_extends.superclass)) @ecma.class_extends.context
;
; (class_declaration
;   name: (_) @ecma.class_extends_member.class_name
;   (class_heritage
;     (member_expression
;       object: (identifier) @ecma.class_extends_member.object
;       property: (property_identifier) @ecma.class_extends_member.member)) @ecma.class_extends_member.superclass) @ecma.class_extends_member.context

; --- semantic_closure_v3_146_ecma_direct_array_first_argument ---
(call_expression
  function: (identifier) @ecma.direct_array_string.call_name
  arguments: (arguments
    (array
      (string
        (string_fragment) @ecma.direct_array_string.item)))) @ecma.direct_array_string.context

(call_expression
  function: (identifier) @ecma.direct_array_identifier.call_name
  arguments: (arguments
    (array
      (identifier) @ecma.direct_array_identifier.item))) @ecma.direct_array_identifier.context

; --- semantic_closure_v3_146_ecma_direct_context ---

; --- semantic_closure_v3_146_ecma_exports_members_directives ---
(export_statement
  declaration: (function_declaration
    name: (identifier) @ecma.exported_function.name
    parameters: (formal_parameters) @ecma.exported_function.parameters)) @ecma.exported_function.context

(export_statement
  declaration: (lexical_declaration
    (variable_declarator
      name: (identifier) @ecma.exported_variable.name
      value: (_) @ecma.exported_variable.value))) @ecma.exported_variable.context

(export_statement
  declaration: (variable_declaration
    (variable_declarator
      name: (identifier) @ecma.exported_variable.name
      value: (_) @ecma.exported_variable.value))) @ecma.exported_variable.context

(member_expression
  object: (identifier) @ecma.root_member.root
  property: (property_identifier) @ecma.root_member.member) @ecma.root_member.context

(expression_statement
  (string
    (string_fragment) @ecma.module_directive.value)) @ecma.module_directive.context

(function_declaration
  name: (identifier) @ecma.function_directive.owner_function
  body: (statement_block
    (expression_statement
      (string
        (string_fragment) @ecma.function_directive.value)))) @ecma.function_directive.context
; The TSX grammar rejects this pattern as impossible. It is kept in
; the TypeScript Pack, where it compiles; TSX is a different parser.
; ; The TSX grammar rejects this pattern as impossible. It is kept in
; ; the TypeScript Pack, where it compiles; TSX is a different parser.
; ;
; ; ; --- framework_neutral_ts_method_parameter_decorator_v1 ---
; ;
; ; (class_declaration
; ;   name: (type_identifier) @ts.method_param_decorator.owner_class
; ;   body: (class_body
; ;     (method_definition
; ;       name: (property_identifier) @ts.method_param_decorator.method_name
; ;       parameters: (formal_parameters
; ;         (required_parameter
; ;           decorator: (decorator
; ;             (call_expression function: (identifier) @ts.method_param_decorator.decorator_name))
; ;           name: (identifier) @ts.method_param_decorator.parameter_name) @ts.method_param_decorator.parameter))) @ts.method_param_decorator.class_context)
;
; (class_declaration
;   name: (type_identifier) @ts.method_param_marker.owner_class
;   body: (class_body
;     (method_definition
;       name: (property_identifier) @ts.method_param_marker.method_name
;       parameters: (formal_parameters
;         (required_parameter
;           decorator: (decorator (identifier) @ts.method_param_marker.decorator_full)
;           name: (identifier) @ts.method_param_marker.parameter_name) @ts.method_param_marker.parameter))) @ts.method_param_marker.class_context)

; --- exported_named_object_field_v3_146 ---
(export_statement
  declaration: (lexical_declaration
    (variable_declarator
      name: (identifier) @ecma.exported_object.owner
      value: (object
        (pair
          key: (property_identifier) @ecma.exported_object.field
          value: (_) @ecma.exported_object.value) @ecma.exported_object.pair))) @ecma.exported_object.declaration) @ecma.exported_object.context

; --- semantic_closure_v3_150_ecma_import_provenance ---
(import_statement
  (import_clause
    (identifier) @ts.default_import.local)
  source: (string (string_fragment) @ts.default_import.module_source)) @ts.default_import.statement

(import_statement
  (import_clause
    (namespace_import (identifier) @ts.namespace_import.local))
  source: (string (string_fragment) @ts.namespace_import.module_source)) @ts.namespace_import.statement

(variable_declarator
  name: (identifier) @ts.require_binding.local
  value: (call_expression
    function: (identifier) @ts.require_binding.operator
    arguments: (arguments (string (string_fragment) @ts.require_binding.module_source)))) @ts.require_binding.context

(variable_declarator
  name: (object_pattern
    (shorthand_property_identifier_pattern) @ts.require_named.imported @ts.require_named.local)
  value: (call_expression
    function: (identifier) @ts.require_named.operator
    arguments: (arguments (string (string_fragment) @ts.require_named.module_source)))) @ts.require_named.context

(variable_declarator
  name: (object_pattern
    (pair_pattern
      key: (property_identifier) @ts.require_named.imported
      value: (identifier) @ts.require_named.local))
  value: (call_expression
    function: (identifier) @ts.require_named.operator
    arguments: (arguments (string (string_fragment) @ts.require_named.module_source)))) @ts.require_named.context

(new_expression
  constructor: (member_expression
    object: (identifier) @ts.member_ctor.object
    property: (property_identifier) @ts.member_ctor.member)
  arguments: (arguments) @ts.member_ctor.arguments) @ts.member_ctor.context

; --- semantic_closure_v3_150_ecma_nested_member_string_identifier ---
(call_expression
  function: (member_expression
    object: (member_expression
      object: (identifier) @ts.nested_member.root
      property: (property_identifier) @ts.nested_member.object_member)
    property: (property_identifier) @ts.nested_member.member)
  arguments: (arguments
    (string (string_fragment) @ts.nested_member.arg0)
    (identifier) @ts.nested_member.arg1)) @ts.nested_member.context

; --- semantic_closure_v3_151_ecma_member_identifier_call ---
(call_expression
  function: (member_expression
    object: (identifier) @ts.member_identifier.object
    property: (property_identifier) @ts.member_identifier.member)
  arguments: (arguments
    (identifier) @ts.member_identifier.arg0)) @ts.member_identifier.context

; --- semantic_closure_v3_151_ecma_three_level_object_string ---
; directCall({outer:{middle:{key:"value"}}})
(call_expression
  function: (identifier) @ts.three_call.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @ts.three_call.outer_key
        value: (object
          (pair
            key: (property_identifier) @ts.three_call.middle_key
            value: (object
              (pair
                key: (property_identifier) @ts.three_call.key
                value: (string (string_fragment) @ts.three_call.value))))))))) @ts.three_call.context

; module.exports = {outer:{middle:{key:"value"}}}
(assignment_expression
  left: (member_expression
    object: (identifier) @ts.three_export.owner_identifier
    property: (property_identifier) @ts.three_export.owner_property)
  right: (object
    (pair
      key: (property_identifier) @ts.three_export.outer_key
      value: (object
        (pair
          key: (property_identifier) @ts.three_export.middle_key
          value: (object
            (pair
              key: (property_identifier) @ts.three_export.key
              value: (string (string_fragment) @ts.three_export.value)))))))) @ts.three_export.context

; --- assignment_export_nested_object_array_object_field_context_v3_150 ---
; CommonJS assignment -> object -> nested object -> array of object items -> authored field.
; Example: module.exports = { module: { rules: [ { loader: "x" } ] } }.
(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.assignment_export_nested_array.owner
    property: (property_identifier) @ecma.assignment_export_nested_array.property)
  right: (object
    (pair
      key: (_) @ecma.assignment_export_nested_array.outer_key
      value: (object
        (pair
          key: (_) @ecma.assignment_export_nested_array.array_key
          value: (array
            (object
              (pair
                key: (_) @ecma.assignment_export_nested_array.item_key
                value: (_) @ecma.assignment_export_nested_array.item_value) @ecma.assignment_export_nested_array.item_pair) @ecma.assignment_export_nested_array.item_object) @ecma.assignment_export_nested_array.array) @ecma.assignment_export_nested_array.array_pair) @ecma.assignment_export_nested_array.nested_object) @ecma.assignment_export_nested_array.outer_pair) @ecma.assignment_export_nested_array.object) @ecma.assignment_export_nested_array.context

; --- final_completion_b3_top_level_const_values ---
; Framework-neutral immutable module-scope value origins.
; Only direct const declarations are covered; no expression folding or runtime evaluation.
(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_string.binding
      value: (string (string_fragment) @ts.b3_const_string.value)) @ts.b3_const_string.declarator))
  @ts.b3_const_string.program @ts.b3_const_number.program @ts.b3_const_true.program @ts.b3_const_false.program @ts.b3_const_null.program @ts.b3_const_alias.program

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_number.binding
      value: (number) @ts.b3_const_number.value) @ts.b3_const_number.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_true.binding
      value: (true) @ts.b3_const_true.value) @ts.b3_const_true.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_false.binding
      value: (false) @ts.b3_const_false.value) @ts.b3_const_false.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_null.binding
      value: (null) @ts.b3_const_null.value) @ts.b3_const_null.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @ts.b3_const_alias.binding
      value: (identifier) @ts.b3_const_alias.target) @ts.b3_const_alias.declarator))

; --- staged_tsx_jsx_surface ---
; These node names are expected from the upstream TSX grammar at the pinned tree-sitter-typescript revision.
; They MUST be real-compiled by Codex before promotion.
(jsx_element open_tag: (jsx_opening_element) @jsx.open close_tag: (jsx_closing_element) @jsx.close) @jsx.element
(jsx_self_closing_element name: (_) @jsx.self.name) @jsx.self
(jsx_opening_element name: (_) @jsx.open.name) @jsx.opening
(jsx_closing_element name: (_) @jsx.close.name) @jsx.closing
(jsx_attribute) @jsx.attribute
(jsx_expression) @jsx.expression
(jsx_text) @jsx.text
(jsx_namespace_name) @jsx.namespace
(html_character_reference) @jsx.entity

(function_declaration
  name: (identifier) @js.jsx_owner.owner_function
  body: (statement_block
    (return_statement
      (jsx_self_closing_element
        name: (identifier) @js.jsx_owner.child_component) @js.jsx_owner.jsx))
) @js.jsx_owner.function

(function_declaration
  name: (identifier) @js.jsx_owner.owner_function
  body: (statement_block
    (return_statement
      (jsx_element
        open_tag: (jsx_opening_element
          name: (identifier) @js.jsx_owner.child_component)) @js.jsx_owner.jsx)))

(jsx_expression (_) @ref.role.jsx_expression)
