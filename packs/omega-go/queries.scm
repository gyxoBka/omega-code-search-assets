; --- assignments ---

(assignment_statement left: (expression_list) @assignment.left right: (expression_list) @assignment.right) @assignment
(short_var_declaration left: (expression_list) @short.left right: (expression_list) @short.right) @short.declaration
(inc_statement) @assignment.inc
(dec_statement) @assignment.dec

; --- bindings ---

(var_spec) @binding.var
(const_spec) @binding.const
(short_var_declaration left: (expression_list) @binding.short.left) @binding.short
(parameter_declaration) @binding.parameter
(variadic_parameter_declaration) @binding.variadic_parameter
(range_clause left: (expression_list)? @binding.range.left) @binding.range
(receive_statement) @binding.receive

; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls ---

(call_expression function: (_) @call.target arguments: (argument_list) @call.arguments) @call
(selector_expression operand: (_) @call.selector.operand field: (field_identifier) @call.selector.field) @call.selector

; --- channels ---

(channel_type) @channel.type
(send_statement) @channel.send
(receive_statement) @channel.receive
(select_statement) @channel.select
(communication_case) @channel.case

; --- cobra_bound_command_context ---

(var_spec
  name: (identifier) @go.bound_command.binding
  value: (expression_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.bound_command.package
          name: (type_identifier) @go.bound_command.type_name)
        body: (literal_value
          (keyed_element
            key: (literal_element
              (identifier) @go.bound_command.field_name)
            value: (literal_element
              (interpreted_string_literal
                (interpreted_string_literal_content) @go.bound_command.field_value)))))))) @go.bound_command.context

(short_var_declaration
  left: (expression_list
    (identifier) @go.bound_command.binding)
  right: (expression_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.bound_command.package
          name: (type_identifier) @go.bound_command.type_name)
        body: (literal_value
          (keyed_element
            key: (literal_element
              (identifier) @go.bound_command.field_name)
            value: (literal_element
              (interpreted_string_literal
                (interpreted_string_literal_content) @go.bound_command.field_value)))))))) @go.bound_command.context

; --- collections ---

(array_type) @collection.array_type
(implicit_length_array_type) @collection.implicit_array_type
(slice_type) @collection.slice_type
(map_type) @collection.map_type
(composite_literal) @collection.composite
(keyed_element) @collection.keyed_element
(index_expression) @collection.index
(slice_expression) @collection.slice_expression

; --- control_concurrency ---

(send_statement) @concurrency.send
(receive_statement) @concurrency.receive
(go_statement) @concurrency.go
(defer_statement) @control.defer
(if_statement) @control.if
(for_statement) @control.for
(range_clause) @control.range
(expression_switch_statement) @control.switch
(type_switch_statement) @control.type_switch
(select_statement) @control.select
(return_statement) @control.return
(break_statement) @control.break
(continue_statement) @control.continue
(goto_statement) @control.goto
(labeled_statement) @control.label
(fallthrough_statement) @control.fallthrough

; --- controller_builder_qualified_resource_context ---

; Framework-neutral authored Go chained builder/resource context.
; Supported source-only shapes:
;   pkg.Constructor(...).Method(&resource.Type{})
;   pkg.Constructor(...).Prior(&primary.Type{}).Method(&resource.Type{})
; The Pack captures syntax only. Framework/provider meaning is interpreted later.

(call_expression
  function: (selector_expression
    operand: (call_expression
      function: (selector_expression
        operand: (identifier) @go.builder_resource.builder_alias
        field: (field_identifier) @go.builder_resource.builder_constructor)
      arguments: (argument_list))
    field: (field_identifier) @go.builder_resource.method_name)
  arguments: (argument_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.builder_resource.resource_package
          name: (type_identifier) @go.builder_resource.resource_type)
        body: (literal_value))))) @go.builder_resource.context

(call_expression
  function: (selector_expression
    operand: (call_expression
      function: (selector_expression
        operand: (call_expression
          function: (selector_expression
            operand: (identifier) @go.builder_resource.builder_alias
            field: (field_identifier) @go.builder_resource.builder_constructor)
          arguments: (argument_list))
        field: (field_identifier) @go.builder_resource.prior_method)
      arguments: (argument_list
        (unary_expression
          operator: "&"
          operand: (composite_literal
            type: (qualified_type
              package: (package_identifier) @go.builder_resource.primary_resource_package
              name: (type_identifier) @go.builder_resource.primary_resource_type)
            body: (literal_value)))))
    field: (field_identifier) @go.builder_resource.method_name)
  arguments: (argument_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.builder_resource.resource_package
          name: (type_identifier) @go.builder_resource.resource_type)
        body: (literal_value))))) @go.builder_resource.context

; --- data ---

(interpreted_string_literal) @data.string
(raw_string_literal) @data.raw_string
(rune_literal) @data.rune
(int_literal) @data.int
(float_literal) @data.float
(imaginary_literal) @data.imaginary
(nil) @data.nil
(true) @data.true
(false) @data.false
(iota) @data.iota
(composite_literal) @data.composite
(literal_value) @data.literal_value
(keyed_element) @data.keyed_element
(comment) @data.comment

; --- declaration_category_field ---

(field_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_method ---

(method_declaration
  name: (_) @definition.category.name
) @definition.category.owner

(method_elem
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_type ---

(type_alias
  name: (_) @definition.category.name
) @definition.category.owner

(type_parameter_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_details ---

(const_declaration) @decl.const_group
(var_declaration) @decl.var_group
(const_spec) @decl.const_spec
(var_spec) @decl.var_spec
(type_declaration) @decl.type_group
(type_alias) @decl.type_alias
(type_spec) @decl.type_spec

; --- definition_identity_hints ---

(field_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(function_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(method_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(method_elem
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions ---

(function_declaration name: (identifier) @definition.function.name) @definition.function
(method_declaration name: (field_identifier) @definition.method.name) @definition.method
(type_spec name: (type_identifier) @definition.type.name) @definition.type
(type_alias name: (type_identifier) @definition.alias.name) @definition.alias
(field_declaration) @definition.field

; --- documented_calls ---

; Omega clean reimplementation of exact pinned upstream tag semantics.
((comment) @doc . (function_declaration name: (identifier) @documented.function.name) @documented.function)
((comment) @doc . (method_declaration name: (field_identifier) @documented.method.name) @documented.method)
(call_expression function: (parenthesized_expression (identifier) @call.parenthesized.name)) @call.parenthesized
(call_expression function: (parenthesized_expression (selector_expression field: (field_identifier) @call.parenthesized_method.name))) @call.parenthesized_method

; --- explicit_import_alias_context ---

; Framework-neutral authored Go explicit import alias:
;   alias "example.com/pkg"
; Captures syntax only. Import/package semantics are interpreted later.

(import_spec
  name: (_) @go.explicit_import_alias.alias
  path: (interpreted_string_literal
    (interpreted_string_literal_content) @go.explicit_import_alias.import_path)) @go.explicit_import_alias.context

; --- expressions ---

(binary_expression) @expression.binary
(unary_expression) @expression.unary
(type_conversion_expression) @expression.type_conversion
(type_instantiation_expression) @expression.type_instantiation
(composite_literal) @expression.composite_literal
(func_literal) @expression.func_literal
(index_expression) @expression.index
(slice_expression) @expression.slice

; --- fields_methods ---

(method_declaration receiver: (parameter_list) @method.receiver name: (field_identifier) @method.name) @method
(field_declaration) @field.declaration
(selector_expression operand: (_) @selector.operand field: (field_identifier) @selector.field) @selector

; --- generics_interfaces ---

(type_parameter_list) @generic.parameters
(type_parameter_declaration name: (identifier) @generic.parameter.name type: (_) @generic.parameter.constraint) @generic.parameter
(interface_type) @interface.type
(method_elem) @interface.method
(type_elem) @interface.type_element
(negated_type) @interface.negated_term
(generic_type) @generic.type
(type_arguments) @generic.arguments

; --- go_test_owner_context ---

(method_declaration
  receiver: (parameter_list
    (parameter_declaration
      type: (type_identifier) @go.method.receiver_type))
  name: (field_identifier) @go.method.method_name) @go.method.method

(method_declaration
  receiver: (parameter_list
    (parameter_declaration
      type: (pointer_type
        (type_identifier) @go.method.receiver_type)))
  name: (field_identifier) @go.method.method_name) @go.method.method

(type_declaration
  (type_spec
    name: (type_identifier) @go.embed.owner_type
    type: (struct_type
      (field_declaration_list
        (field_declaration
          type: (qualified_type
            package: (package_identifier) @go.embed.package
            name: (type_identifier) @go.embed.type))))) @go.embed.struct) @go.embed.declaration

; --- import_alias_constructor_binding_context ---

((source_file
  (import_declaration
    (import_spec
      name: (_) @go.router_constructor.import_alias
      path: (interpreted_string_literal
        (interpreted_string_literal_content) @go.router_constructor.import_path)))
  (function_declaration
    body: (block
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_constructor.binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_constructor.package_receiver
              field: (field_identifier) @go.router_constructor.constructor_name)
            arguments: (argument_list)))) @go.router_constructor.context)))
 (#eq? @go.router_constructor.import_alias @go.router_constructor.package_receiver))

; --- import_alias_group_binding_context ---

((source_file
  (import_declaration
    (import_spec
      name: (_) @go.router_group.import_alias
      path: (interpreted_string_literal
        (interpreted_string_literal_content) @go.router_group.import_path)))
  (function_declaration
    body: (block
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_group.root_binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_group.package_receiver
              field: (field_identifier) @go.router_group.constructor_name)
            arguments: (argument_list))))
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_group.group_binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_group.parent_receiver
              field: (field_identifier) @go.router_group.group_method)
            arguments: (argument_list
              (interpreted_string_literal
                (interpreted_string_literal_content) @go.router_group.prefix))))) @go.router_group.context)))
 (#eq? @go.router_group.import_alias @go.router_group.package_receiver)
 (#eq? @go.router_group.root_binding @go.router_group.parent_receiver))

; --- import_targets ---

(import_spec
  path: (_) @import.target) @import.statement

; --- imported_constructor_qualified_resource_context ---

; Framework-neutral authored Go imported constructor with a qualified composite resource argument:
;   pkg.Constructor(firstArg, &resource.Type{})
; Captures syntax only. Constructor/framework/resource semantics are interpreted later.

(call_expression
  function: (selector_expression
    operand: (identifier) @go.imported_constructor_resource.builder_alias
    field: (field_identifier) @go.imported_constructor_resource.constructor_name)
  arguments: (argument_list
    (_)
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.imported_constructor_resource.resource_package
          name: (type_identifier) @go.imported_constructor_resource.resource_type)
        body: (literal_value))))) @go.imported_constructor_resource.context

; --- imports ---

(import_declaration) @import.declaration
(import_spec path: (_) @import.path) @import.spec
(import_spec name: (_) @import.alias) @import.named

; --- labels ---

(labeled_statement) @label.definition
(break_statement) @label.break
(continue_statement) @label.continue
(goto_statement) @label.goto

; --- lexical_surface ---

(interpreted_string_literal) @lex.string
(raw_string_literal) @lex.raw_string
(rune_literal) @lex.rune
(int_literal) @lex.int
(float_literal) @lex.float
(imaginary_literal) @lex.imaginary
(nil) @lex.nil
(true) @lex.true
(false) @lex.false
(iota) @lex.iota
(comment) @lex.comment

; --- method_builder_qualified_resource_context ---

; Framework-neutral Go method-owned direct builder/resource chain.
; Exact supported subset:
;   func (r *Owner) Method(mgr any) error {
;     return pkg.Constructor(mgr).BuilderMethod(&res.Type{}).Terminal(r)
;   }
; Captures syntax/ownership only. Framework meaning is interpreted later.

(method_declaration
  receiver: (parameter_list
    (parameter_declaration
      type: (pointer_type
        (type_identifier) @go.method_builder.receiver_type)))
  name: (field_identifier) @go.method_builder.owner_method
  body: (block
    (return_statement
      (expression_list
        (call_expression
          function: (selector_expression
            operand: (call_expression
              function: (selector_expression
                operand: (call_expression
                  function: (selector_expression
                    operand: (identifier) @go.method_builder.builder_alias
                    field: (field_identifier) @go.method_builder.builder_constructor)
                  arguments: (argument_list))
                field: (field_identifier) @go.method_builder.builder_method)
              arguments: (argument_list
                (unary_expression
                  operator: "&"
                  operand: (composite_literal
                    type: (qualified_type
                      package: (package_identifier) @go.method_builder.resource_package
                      name: (type_identifier) @go.method_builder.resource_type)
                    body: (literal_value)))))
            field: (field_identifier) @go.method_builder.terminal_method)
          arguments: (argument_list))))) @go.method_builder.context)

(method_declaration
  receiver: (parameter_list
    (parameter_declaration
      type: (type_identifier) @go.method_builder.receiver_type))
  name: (field_identifier) @go.method_builder.owner_method
  body: (block
    (return_statement
      (expression_list
        (call_expression
          function: (selector_expression
            operand: (call_expression
              function: (selector_expression
                operand: (call_expression
                  function: (selector_expression
                    operand: (identifier) @go.method_builder.builder_alias
                    field: (field_identifier) @go.method_builder.builder_constructor)
                  arguments: (argument_list))
                field: (field_identifier) @go.method_builder.builder_method)
              arguments: (argument_list
                (unary_expression
                  operator: "&"
                  operand: (composite_literal
                    type: (qualified_type
                      package: (package_identifier) @go.method_builder.resource_package
                      name: (type_identifier) @go.method_builder.resource_type)
                    body: (literal_value)))))
            field: (field_identifier) @go.method_builder.terminal_method)
          arguments: (argument_list))))) @go.method_builder.context)

; --- module_path_hints ---

(import_spec 
  path: (_) @import.module_path.target
) @import.module_path.statement

; --- modules ---

(package_clause (package_identifier) @module.package.name) @module.package
(import_spec path: (_) @module.import.path) @module.import

; --- named_scope_owners ---

(function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(method_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_parameters ---

(function_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter_declaration) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (variadic_parameter_declaration) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter_declaration) @owned.parameter)) @owner.span

(method_declaration
  name: (_) @owner.name
  parameters: (parameter_list
    (variadic_parameter_declaration) @owned.parameter)) @owner.span

(method_elem
  name: (_) @owner.name
  parameters: (parameter_list
    (parameter_declaration) @owned.parameter)) @owner.span

(method_elem
  name: (_) @owner.name
  parameters: (parameter_list
    (variadic_parameter_declaration) @owned.parameter)) @owner.span

; --- package_init ---

(package_clause (package_identifier) @package.name) @package.clause
(function_declaration name: (identifier) @package.function.name) @package.function
(var_spec) @package.var
(const_spec) @package.const

; --- qualified_composite_identifier_field_context ---

; Framework-neutral authored Go binding:
;   var x = &pkg.Type{Field: identifier}
;   x := &pkg.Type{Field: identifier}
; Captures syntax only. Type/framework meaning is interpreted later.

(var_spec
  name: (identifier) @go.bound_composite_identifier.binding
  value: (expression_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.bound_composite_identifier.package
          name: (type_identifier) @go.bound_composite_identifier.type_name)
        body: (literal_value
          (keyed_element
            key: (literal_element
              (identifier) @go.bound_composite_identifier.field_name)
            value: (literal_element
              (identifier) @go.bound_composite_identifier.field_identifier))))))) @go.bound_composite_identifier.context

(short_var_declaration
  left: (expression_list
    (identifier) @go.bound_composite_identifier.binding)
  right: (expression_list
    (unary_expression
      operator: "&"
      operand: (composite_literal
        type: (qualified_type
          package: (package_identifier) @go.bound_composite_identifier.package
          name: (type_identifier) @go.bound_composite_identifier.type_name)
        body: (literal_value
          (keyed_element
            key: (literal_element
              (identifier) @go.bound_composite_identifier.field_name)
            value: (literal_element
              (identifier) @go.bound_composite_identifier.field_identifier))))))) @go.bound_composite_identifier.context

; --- receiver_identifier_argument_context ---

(call_expression
  function: (selector_expression
    operand: (identifier) @go.receiver_identifier_call.receiver
    field: (field_identifier) @go.receiver_identifier_call.method_name)
  arguments: (argument_list
    (identifier) @go.receiver_identifier_call.arg1)) @go.receiver_identifier_call.context

; --- receiver_method_chain_string_context ---

(call_expression
  function: (selector_expression
    operand: (call_expression
      function: (selector_expression
        operand: (identifier) @go.receiver_chain_string.receiver
        field: (field_identifier) @go.receiver_chain_string.owner_method)
      arguments: (argument_list))
    field: (field_identifier) @go.receiver_chain_string.method_name)
  arguments: (argument_list
    (interpreted_string_literal
      (interpreted_string_literal_content) @go.receiver_chain_string.arg1))) @go.receiver_chain_string.context

; --- receiver_string_identifier_context ---

(call_expression
  function: (selector_expression
    operand: (identifier) @go.router_route.receiver
    field: (field_identifier) @go.router_route.method_name)
  arguments: (argument_list
    (interpreted_string_literal
      (interpreted_string_literal_content) @go.router_route.path_literal)
    (identifier) @go.router_route.handler_identifier)) @go.router_route.context

; --- references ---

(identifier) @reference.identifier
(package_identifier) @reference.package
(type_identifier) @reference.type
(field_identifier) @reference.field
(selector_expression) @reference.selector
(index_expression) @reference.index
(slice_expression) @reference.slice
(type_assertion_expression) @reference.type_assertion

; --- scopes ---

(source_file) @scope.file
(function_declaration) @scope.function
(method_declaration) @scope.method
(func_literal) @scope.function_literal
(block) @scope.block
(for_statement) @scope.for
(if_statement) @scope.if
(expression_switch_statement) @scope.switch
(type_switch_statement) @scope.type_switch
(select_statement) @scope.select

; --- signature_parameters ---

(function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(method_elem
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_type_parameters ---

(function_declaration
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_spec
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- signatures ---

(parameter_list) @signature.parameters
(parameter_declaration) @signature.parameter
(variadic_parameter_declaration) @signature.variadic_parameter
(function_type) @signature.function_type

; --- switch_cases ---

(expression_case) @switch.expression_case
(default_case) @switch.default_case
(type_case) @switch.type_case
(communication_case) @switch.communication_case

; --- tests ---

(function_declaration name: (identifier) @test.function.name) @test.function

; --- type_operations ---

(type_assertion_expression) @typeop.assertion
(type_conversion_expression) @typeop.conversion
(type_instantiation_expression) @typeop.instantiation

; --- types ---

(generic_type) @type.generic
(type_arguments) @type.arguments
(type_parameter_list) @type.parameters
(type_parameter_declaration) @type.parameter
(pointer_type) @type.pointer
(array_type) @type.array
(implicit_length_array_type) @type.implicit_array
(slice_type) @type.slice
(struct_type) @type.struct
(interface_type) @type.interface
(map_type) @type.map
(channel_type) @type.channel
(function_type) @type.function
(negated_type) @type.negated_constraint
(type_elem) @type.constraint_elem
(qualified_type) @type.qualified

; --- unaliased_import_constructor_binding_context_v3_146 ---

; Framework-neutral same-file unaliased import + package constructor binding.
; This proves authored import provenance and conventional receiver spelling, but cannot
; prove absence of lexical shadowing without a semantic provider; downstream confidence
; therefore remains candidate/high rather than exact.
(source_file
  (import_declaration
    (import_spec
      !name
      path: (interpreted_string_literal
        (interpreted_string_literal_content) @go.router_constructor_unaliased.import_path)))
  (function_declaration
    body: (block
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_constructor_unaliased.binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_constructor_unaliased.package_receiver
              field: (field_identifier) @go.router_constructor_unaliased.constructor_name)
            arguments: (argument_list)))) @go.router_constructor_unaliased.context)))

; Same-file unaliased import + root constructor + direct Group("prefix") binding.
(source_file
  (import_declaration
    (import_spec
      !name
      path: (interpreted_string_literal
        (interpreted_string_literal_content) @go.router_group_unaliased.import_path)))
  (function_declaration
    body: (block
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_group_unaliased.root_binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_group_unaliased.package_receiver
              field: (field_identifier) @go.router_group_unaliased.constructor_name)
            arguments: (argument_list))))
      (short_var_declaration
        left: (expression_list
          (identifier) @go.router_group_unaliased.group_binding)
        right: (expression_list
          (call_expression
            function: (selector_expression
              operand: (identifier) @go.router_group_unaliased.parent_receiver
              field: (field_identifier) @go.router_group_unaliased.group_method)
            arguments: (argument_list
              (interpreted_string_literal
                (interpreted_string_literal_content) @go.router_group_unaliased.prefix))))) @go.router_group_unaliased.context))
  (#eq? @go.router_group_unaliased.root_binding @go.router_group_unaliased.parent_receiver))
