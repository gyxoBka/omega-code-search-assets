; --- assignments ---

(assignment_statement left: (expression_list) @assignment.left right: (expression_list) @assignment.right) @assignment
(short_var_declaration left: (expression_list) @short.left right: (expression_list) @short.right) @short.declaration
(inc_statement) @assignment.inc
(dec_statement) @assignment.dec

; --- bindings ---

(var_spec) @binding.var @decl.var_spec @package.var
(const_spec) @binding.const @decl.const_spec @package.const
(short_var_declaration left: (expression_list) @binding.short.left) @binding.short
(parameter_declaration) @binding.parameter @signature.parameter
(variadic_parameter_declaration) @binding.variadic_parameter @signature.variadic_parameter
(range_clause left: (expression_list)? @binding.range.left) @binding.range
(receive_statement) @binding.receive @channel.receive @concurrency.receive

; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls ---

(call_expression function: (_) @call.target arguments: (argument_list) @call.arguments) @call
(selector_expression operand: (_) @call.selector.operand @selector.operand field: (field_identifier) @call.selector.field @selector.field) @call.selector @selector

; --- channels ---

(channel_type) @channel.type @type.channel
(send_statement) @channel.send @concurrency.send
(select_statement) @channel.select @control.select @scope.select
(communication_case) @channel.case @switch.communication_case

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

(array_type) @collection.array_type @type.array
(implicit_length_array_type) @collection.implicit_array_type @type.implicit_array
(slice_type) @collection.slice_type @type.slice
(map_type) @collection.map_type @type.map
(composite_literal) @collection.composite @data.composite @expression.composite_literal
(keyed_element) @collection.keyed_element @data.keyed_element
(index_expression) @collection.index @expression.index @reference.index
(slice_expression) @collection.slice_expression @expression.slice @reference.slice

; --- control_concurrency ---

(go_statement) @concurrency.go
(defer_statement) @control.defer
(if_statement) @control.if @scope.if
(for_statement) @control.for @scope.for
(range_clause) @control.range
(expression_switch_statement) @control.switch @scope.switch
(type_switch_statement) @control.type_switch @scope.type_switch
(return_statement) @control.return
(break_statement) @control.break @label.break
(continue_statement) @control.continue @label.continue
(goto_statement) @control.goto @label.goto
(labeled_statement) @control.label @label.definition
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

(interpreted_string_literal) @data.string @lex.string
(raw_string_literal) @data.raw_string @lex.raw_string
(rune_literal) @data.rune @lex.rune
(int_literal) @data.int @lex.int
(float_literal) @data.float @lex.float
(imaginary_literal) @data.imaginary @lex.imaginary
(nil) @data.nil @lex.nil
(true) @data.true @lex.true
(false) @data.false @lex.false
(iota) @data.iota @lex.iota
(literal_value) @data.literal_value
(comment) @data.comment @lex.comment

; --- declaration_category_field ---

(field_declaration
  name: (_) @definition.category.field.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_method ---

(method_declaration
  name: (_) @definition.category.method.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(method_elem
  name: (_) @definition.category.method.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_type ---

(type_alias
  name: (_) @definition.category.type.name
) @definition.category.owner

(type_parameter_declaration
  name: (_) @definition.category.type.name
) @definition.category.owner

; --- declaration_details ---

(const_declaration) @decl.const_group
(var_declaration) @decl.var_group
(type_declaration) @decl.type_group
(type_alias) @decl.type_alias
(type_spec) @decl.type_spec

; --- definition_identity_hints ---





; --- definitions ---

(function_declaration name: (identifier) @definition.function.name @package.function.name @test.function.name) @definition.function @package.function @test.function
(method_declaration name: (field_identifier) @definition.method.name) @definition.method
(type_spec name: (type_identifier) @definition.type.name) @definition.type
(type_alias name: (type_identifier) @definition.alias.name) @definition.alias
(field_declaration) @definition.field @field.declaration

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
(type_conversion_expression) @expression.type_conversion @typeop.conversion
(type_instantiation_expression) @expression.type_instantiation @typeop.instantiation
(func_literal) @expression.func_literal @scope.function_literal

; --- fields_methods ---

(method_declaration receiver: (parameter_list) @method.receiver name: (field_identifier) @method.name) @method

; --- generics_interfaces ---

(type_parameter_list) @generic.parameters @type.parameters
(type_parameter_declaration name: (identifier) @generic.parameter.name type: (_) @generic.parameter.constraint) @generic.parameter
(interface_type) @interface.type @type.interface
(method_elem) @interface.method
(type_elem) @interface.type_element @type.constraint_elem
(negated_type) @interface.negated_term @type.negated_constraint
(generic_type) @generic.type @type.generic
(type_arguments) @generic.arguments @type.arguments

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
  path: (_) @import.target @import.path @import.module_path.target @module.import.path) @import.statement @import.spec @import.module_path.statement @module.import

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
(import_spec name: (_) @import.alias) @import.named

; --- labels ---


; --- lexical_surface ---


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


; --- modules ---

(package_clause (package_identifier) @module.package.name @package.name) @module.package @package.clause

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
(type_assertion_expression) @reference.type_assertion @typeop.assertion

; --- scopes ---

(source_file) @scope.file
(function_declaration) @scope.function
(method_declaration) @scope.method
(block) @scope.block

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
(function_type) @signature.function_type @type.function

; --- switch_cases ---

(expression_case) @switch.expression_case
(default_case) @switch.default_case
(type_case) @switch.type_case

; --- tests ---


; --- type_operations ---


; --- types ---

(type_parameter_declaration) @type.parameter
(pointer_type) @type.pointer
(struct_type) @type.struct
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
