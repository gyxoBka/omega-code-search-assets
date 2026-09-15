; --- async_extended ---

(function_definition) @function.definition.candidate
(await) @async.await
(for_statement) @async.for_candidate
(with_statement) @async.with_candidate

; --- augmented_assignment_binding ---

(augmented_assignment left: (identifier) @python.binding.update) @python.binding.update.span

; --- binary_identifier_context ---

; Syntactic dependency-operator expression over two identifier operands.
; This is framework-neutral evidence only: frameworks must prove operand value origins.
(binary_operator
  left: (identifier) @python.binary.left
  operator: [">>" "<<"] @python.binary.operator
  right: (identifier) @python.binary.right) @python.binary.expression

; --- bindings ---

(parameters (identifier) @binding.parameter.name) @binding.parameter
(default_parameter name: (identifier) @binding.parameter.name) @binding.parameter
(typed_parameter (identifier) @binding.parameter.name) @binding.parameter
(assignment left: (identifier) @binding.local.name) @binding.local
(for_statement left: (identifier) @binding.loop.name) @binding.loop
(aliased_import alias: (identifier) @binding.import_alias.name) @binding.import_alias

; --- call_targets ---

(call
  function: (_) @call.target) @call.expression

; --- calls ---

(call function: (identifier) @call.direct.target
  arguments: (argument_list) @call.direct.args) @call.direct
(call
  function: (attribute
    object: (_) @call.member.object
    attribute: (identifier) @call.member.target)
  arguments: (argument_list) @call.member.args) @call.member
(await (call function: (_) @call.awaited.target)) @call.awaited

; --- canvas_binary_context ---

; Framework-neutral inline signature/canvas-like binary expression.
(binary_operator
  left: (call
    function: (attribute
      object: (identifier) @python.canvas.left_object
      attribute: (identifier) @python.canvas.left_member)
    arguments: (argument_list))
  operator: "|" @python.canvas.operator
  right: (call
    function: (attribute
      object: (identifier) @python.canvas.right_object
      attribute: (identifier) @python.canvas.right_member)
    arguments: (argument_list)) @python.canvas.expression
  (#match? @python.canvas.left_member "^(s|si|signature)$")
  (#match? @python.canvas.right_member "^(s|si|signature)$"))

; --- class_list_string_tuple_context ---

; Framework-neutral class-owned list field containing literal 2-string tuples:
; class X:
;     field = [("a", "b"), ...]
; Captures authored syntax only; field semantics are interpreted later.

(class_definition
  name: (identifier) @python.class_tuple.class_name
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @python.class_tuple.field_name
        right: (list
          (tuple
            . (string (string_content) @python.class_tuple.item0)
            . (string (string_content) @python.class_tuple.item1))) @python.class_tuple.assignment))) @python.class_tuple.context)

; --- comprehensions_generators ---

(list_comprehension) @comprehension.list
(set_comprehension) @comprehension.set
(dictionary_comprehension) @comprehension.dictionary
(generator_expression) @comprehension.generator
(for_in_clause) @comprehension.for_clause
(if_clause) @comprehension.if_clause
(yield) @generator.yield

; --- control_flow_extended ---

(if_statement) @control.if
(for_statement) @control.for
(while_statement) @control.while
(break_statement) @control.break
(continue_statement) @control.continue
(return_statement) @control.return
(raise_statement) @control.raise
(assert_statement) @control.assert
(delete_statement) @control.delete
(global_statement) @scope.global
(nonlocal_statement) @scope.nonlocal

; --- data ---

(dictionary) @data.dictionary
(list) @data.list
(set) @data.set
(tuple) @data.tuple
(string) @data.string
(integer) @data.integer
(float) @data.float
(true) @data.boolean
(false) @data.boolean
(none) @data.none

; --- declaration_category_class ---

(class_definition
  name: (_) @definition.category.class.name
) @definition.category.owner

; --- declaration_category_function ---

(function_definition
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- decorators_classes_extended ---

(decorated_definition) @decorated.definition
(decorator) @decorator

(decorator
  (call
    function: [
      (identifier) @decorator.callee
      (attribute attribute: (identifier) @decorator.callee)
    ] @decorator.target
    arguments: (argument_list) @decorator.args)) @decorator.call
(class_definition name: (identifier) @class.name) @class.definition.extended
(argument_list) @class.base_arguments

; --- definition_identity_hints ---

(class_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(function_definition
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions ---

(function_definition name: (identifier) @definition.function.name) @definition.function
(class_definition name: (identifier) @definition.class.name) @definition.class
(type_alias_statement left: (type) @definition.type_alias.name) @definition.type_alias
(assignment left: (identifier) @definition.variable.name) @definition.variable

; --- enclosing_owner_hints ---

(class_definition 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- exceptions_context ---

(try_statement) @exception.try
(except_clause) @exception.except
(finally_clause) @exception.finally
(else_clause) @control.else_clause
(with_statement) @context.with
(with_item) @context.with_item

; --- expressions_extended ---

(named_expression) @expression.named
(lambda) @expression.lambda
(conditional_expression) @expression.conditional
(boolean_operator) @expression.boolean
(comparison_operator) @expression.comparison
(binary_operator) @expression.binary
(unary_operator) @expression.unary
(attribute) @expression.attribute
(subscript) @expression.subscript
(slice) @expression.slice

; --- from_import_callable_invocation_context ---

; Framework-neutral source fact:
; from pkg import Type
; obj = Type(...)
; out = obj(input)
; All three bindings must occur at module scope and names are textually equal where required.
(module
  (import_from_statement
    module_name: (dotted_name) @python.from_callable.module_name
    name: (dotted_name) @python.from_callable.imported_name) @python.from_callable.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.from_callable.binding_name
      right: (call
        function: (identifier) @python.from_callable.constructor_name
        arguments: (argument_list)) @python.from_callable.constructor_call) @python.from_callable.constructor_assignment)
  (expression_statement
    (assignment
      left: (identifier) @python.from_callable.output_name
      right: (call
        function: (identifier) @python.from_callable.receiver_name
        arguments: (argument_list
          . (identifier) @python.from_callable.input_identifier)) @python.from_callable.invocation_call) @python.from_callable.invocation_assignment)
  (#eq? @python.from_callable.imported_name @python.from_callable.constructor_name)
  (#eq? @python.from_callable.binding_name @python.from_callable.receiver_name))

; --- from_import_constructor_binding_context ---

; Framework-neutral Python explicit from-import direct constructor binding.
; Supported source-only subset:
;   from pkg import Type
;   binding = Type(...)
; The imported name and callee must be textually identical. No framework meaning is assigned.

(module
  (import_from_statement
    module_name: (dotted_name) @python.from_ctor.module_name
    name: (dotted_name) @python.from_ctor.imported_name) @python.from_ctor.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.from_ctor.binding_name
      right: (call
        function: (identifier) @python.from_ctor.callee_name
        arguments: (argument_list)) @python.from_ctor.call) @python.from_ctor.assignment)
  (#eq? @python.from_ctor.imported_name @python.from_ctor.callee_name))

; --- from_import_constructor_keyword_identifier_context ---

; Framework-neutral Python explicit from-import constructor binding with an identifier-valued keyword.
; Supported source-only subset:
;   from pkg import Type
;   binding = Type(..., keyword=identifier)
(module
  (import_from_statement
    module_name: (dotted_name) @python.from_ctor_kw.module_name
    name: (dotted_name) @python.from_ctor_kw.imported_name) @python.from_ctor_kw.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.from_ctor_kw.binding_name
      right: (call
        function: (identifier) @python.from_ctor_kw.callee_name
        arguments: (argument_list
          (keyword_argument
            name: (identifier) @python.from_ctor_kw.keyword_name
            value: (identifier) @python.from_ctor_kw.keyword_identifier))) @python.from_ctor_kw.call) @python.from_ctor_kw.assignment)
  (#eq? @python.from_ctor_kw.imported_name @python.from_ctor_kw.callee_name))

; --- from_import_constructor_keyword_identifier_list_context ---

; Framework-neutral explicit from-import constructor binding with a flat identifier-list keyword.
; Example source shape: `from pkg import Type; obj = Type(items=[a, b])`.
; Emits one match per direct identifier list item. No framework meaning is assigned.
(module
  (import_from_statement
    module_name: (dotted_name) @python.from_ctor_list.module_name
    name: (dotted_name) @python.from_ctor_list.imported_name) @python.from_ctor_list.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.from_ctor_list.binding_name
      right: (call
        function: (identifier) @python.from_ctor_list.callee_name
        arguments: (argument_list
          (keyword_argument
            name: (identifier) @python.from_ctor_list.keyword_name
            value: (list
              (identifier) @python.from_ctor_list.list_item))) @python.from_ctor_list.arguments) @python.from_ctor_list.call) @python.from_ctor_list.assignment)
  (#eq? @python.from_ctor_list.imported_name @python.from_ctor_list.callee_name))

; --- import_alias_hints ---

(aliased_import
  name: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- import_bound_member_call_identifier_context ---

; Framework-neutral Python authored dataflow fact.
; Explicit module import alias + named function owner + direct local assignment
; from alias.member(first_identifier, ...). Runtime execution, rebinding,
; member chains, computed first arguments and implicit imports are out of scope.
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_flow.module_name
      alias: (identifier) @python.import_flow.alias_name))
  (function_definition
    name: (identifier) @python.import_flow.owner_function
    body: (block
      (expression_statement
        (assignment
          left: (identifier) @python.import_flow.binding_name
          right: (call
            function: (attribute
              object: (identifier) @python.import_flow.receiver
              attribute: (identifier) @python.import_flow.member)
            arguments: (argument_list
              . (identifier) @python.import_flow.input_identifier)) @python.import_flow.call) @python.import_flow.assignment)))
  (#eq? @python.import_flow.alias_name @python.import_flow.receiver))

; --- import_bound_member_call_literal_keyword_context ---

; Framework-neutral Python import-bound member-call assignment carrying a
; literal positional string and a literal string keyword argument.
; The receiver identifier must exactly equal the authored module alias.
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_bound_literal.module_name
      alias: (identifier) @python.import_bound_literal.alias_name) @python.import_bound_literal.aliased_import) @python.import_bound_literal.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.import_bound_literal.binding
      right: (call
        function: (attribute
          object: (identifier) @python.import_bound_literal.receiver
          attribute: (identifier) @python.import_bound_literal.member)
        arguments: (argument_list
          (string (string_content) @python.import_bound_literal.positional_string)
          (keyword_argument
            name: (identifier) @python.import_bound_literal.keyword_name
            value: (string (string_content) @python.import_bound_literal.keyword_string) @python.import_bound_literal.keyword_value) @python.import_bound_literal.keyword_argument) @python.import_bound_literal.arguments) @python.import_bound_literal.call) @python.import_bound_literal.assignment)
  (#eq? @python.import_bound_literal.alias_name @python.import_bound_literal.receiver))

; --- import_bound_navigation_list_context ---

; Framework-neutral Python module-level assignment to an import-bound member
; call whose flat list argument contains identifiers. Emits one match per item.
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_bound_list.module_name
      alias: (identifier) @python.import_bound_list.alias_name) @python.import_bound_list.aliased_import) @python.import_bound_list.import_statement
  (expression_statement
    (assignment
      left: (identifier) @python.import_bound_list.binding
      right: (call
        function: (attribute
          object: (identifier) @python.import_bound_list.receiver
          attribute: (identifier) @python.import_bound_list.member)
        arguments: (argument_list
          (list
            (identifier) @python.import_bound_list.item) @python.import_bound_list.list) @python.import_bound_list.arguments) @python.import_bound_list.call) @python.import_bound_list.assignment)
  (#eq? @python.import_bound_list.alias_name @python.import_bound_list.receiver))

; --- import_bound_value_graph_context ---

; Framework-neutral Python value-graph facts tied to an explicit import alias.
; These patterns intentionally cover only module-level identifier bindings and
; direct authored identifier dataflow. Runtime execution, alias rebinding,
; unpacking, conditionals and arbitrary call resolution are outside Pack truth.

; import keras as k; inputs = k.Input(...)
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_value.module_name
      alias: (identifier) @python.import_value.alias_name))
  (expression_statement
    (assignment
      left: (identifier) @python.import_value.binding
      right: (call
        function: (attribute
          object: (identifier) @python.import_value.receiver
          attribute: (identifier) @python.import_value.member)
        arguments: (argument_list) @python.import_value.arguments) @python.import_value.call) @python.import_value.assignment)
  (#eq? @python.import_value.alias_name @python.import_value.receiver))

; import keras as k; x = k.layers.Dense(...)(inputs)
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_chain.module_name
      alias: (identifier) @python.import_chain.alias_name))
  (expression_statement
    (assignment
      left: (identifier) @python.import_chain.binding
      right: (call
        function: (call
          function: (attribute
            object: (attribute
              object: (identifier) @python.import_chain.receiver
              attribute: (identifier) @python.import_chain.namespace)
            attribute: (identifier) @python.import_chain.member)
          arguments: (argument_list) @python.import_chain.constructor_arguments)
        arguments: (argument_list
          . (identifier) @python.import_chain.input_identifier) @python.import_chain.apply_arguments) @python.import_chain.apply_call) @python.import_chain.assignment)
  (#eq? @python.import_chain.alias_name @python.import_chain.receiver))

; import keras as k; model = k.Model(inputs=inputs, outputs=outputs)
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_keywords.module_name
      alias: (identifier) @python.import_keywords.alias_name))
  (expression_statement
    (assignment
      left: (identifier) @python.import_keywords.binding
      right: (call
        function: (attribute
          object: (identifier) @python.import_keywords.receiver
          attribute: (identifier) @python.import_keywords.member)
        arguments: (argument_list
          (keyword_argument
            name: (identifier) @python.import_keywords.keyword1
            value: (identifier) @python.import_keywords.value1)
          (keyword_argument
            name: (identifier) @python.import_keywords.keyword2
            value: (identifier) @python.import_keywords.value2)) @python.import_keywords.arguments) @python.import_keywords.call) @python.import_keywords.assignment)
  (#eq? @python.import_keywords.alias_name @python.import_keywords.receiver))

; --- import_scope_extended ---

(future_import_statement) @import.future
(import_statement) @import.statement.extended
(import_from_statement) @import.from.extended
(aliased_import) @import.alias.extended
(relative_import) @import.relative
(global_statement) @scope.global.extended
(nonlocal_statement) @scope.nonlocal.extended

; --- import_targets ---

(aliased_import
  name: (_) @import.target) @import.statement

(future_import_statement
  name: (_) @import.target) @import.statement

(import_from_statement
  name: (_) @import.target) @import.statement

(import_statement
  name: (_) @import.target) @import.statement

; --- imports ---

(import_statement name: (dotted_name) @import.module.name) @import.module
(import_statement name: (aliased_import name: (dotted_name) @import.module.name alias: (identifier) @import.alias.name)) @import.module
(import_from_statement module_name: [(dotted_name) (relative_import)] @import.from.module) @import.from
(future_import_statement) @import.future

; --- literals_extended ---

(string) @literal.string
(concatenated_string) @literal.concatenated_string
(interpolation) @literal.interpolation
(string_content) @literal.string_content
(integer) @literal.integer
(float) @literal.float
(true) @literal.true
(false) @literal.false
(none) @literal.none
(ellipsis) @literal.ellipsis
(list) @literal.list
(set) @literal.set
(dictionary) @literal.dictionary
(tuple) @literal.tuple
(comment) @literal.comment

; --- mapping_context ---

; Nested dictionary field under an assigned mapping owner, e.g.
; task_routes = {"tasks.add": {"queue": "math"}}
(assignment
  left: (_) @python.mapping.owner
  right: (dictionary
    (pair
      key: (_) @python.mapping.entry.key
      value: (dictionary
        (pair
          key: (_) @python.mapping.field.key
          value: (_) @python.mapping.field.value) @python.mapping.field.pair)) @python.mapping.entry.pair)) @python.mapping.assignment

; --- module_level_bindings ---

; Exact pinned upstream tags treat module-level assignment as a top-level symbol.
(module (expression_statement (assignment left: (identifier) @module.binding.name) @module.binding))

; --- module_path_hints ---

(aliased_import 
  name: (_) @import.module_path.target
) @import.module_path.statement

(future_import_statement 
  name: (_) @import.module_path.target
) @import.module_path.statement

(import_from_statement 
  module_name: (_) @import.module_path.target
) @import.module_path.statement

(import_statement 
  name: (_) @import.module_path.target
) @import.module_path.statement

; --- modules ---

(import_statement name: (dotted_name) @module.import.name) @module.import
(import_from_statement module_name: [(dotted_name) (relative_import)] @module.from.name) @module.from
(if_statement condition: (comparison_operator (identifier) @module.guard.identifier (string) @module.guard.literal)) @module.main_guard

; --- named_scope_owners ---

(class_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_parameters ---

(function_definition
  name: (_) @owner.name
  parameters: (parameters
    (parameter) @owned.parameter)) @owner.span

; --- parameters_extended ---

(parameters) @parameters
(default_parameter) @parameter.default
(typed_parameter) @parameter.typed
(typed_default_parameter) @parameter.typed_default
(list_splat_pattern) @parameter.star
(dictionary_splat_pattern) @parameter.double_star
(lambda_parameters) @lambda.parameters

; --- path_origin_hints ---

(import_from_statement module_name: (relative_import) @import.path_origin.root) @import.path_origin.statement

; --- receiver_identifier_argument_context ---

; Framework-neutral Python member call with a direct identifier receiver
; and direct identifier first argument. Syntax only; receiver/argument meaning is unresolved.

(call
  function: (attribute
    object: (identifier) @python.receiver_arg.receiver
    attribute: (identifier) @python.receiver_arg.member)
  arguments: (argument_list
    . (identifier) @python.receiver_arg.arg0_identifier)) @python.receiver_arg.context

; --- references ---

(attribute object: (_) @reference.member.object attribute: (identifier) @reference.member.name) @reference.member
(call function: (identifier) @reference.call.name) @reference.call
(identifier) @reference.identifier

; --- scopes ---

(module) @scope.module
(function_definition name: (identifier) @scope.function.name body: (block) @scope.function.body) @scope.function
(class_definition name: (identifier) @scope.class.name body: (block) @scope.class.body) @scope.class
(lambda body: (_) @scope.lambda.body) @scope.lambda

; --- signature_parameters ---

(function_definition
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(function_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(class_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_definition
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- tests ---

(function_definition name: (identifier) @test.function.name (#match? @test.function.name "^test_")) @test.function
(class_definition name: (identifier) @test.class.name (#match? @test.class.name "^Test")) @test.class
(call function: (attribute object: (identifier) @test.assert.object attribute: (identifier) @test.assert.method) (#match? @test.assert.method "^assert")) @test.assert

; --- types ---

(type_alias_statement left: (type) @type.alias.name right: (type) @type.alias.value) @type.alias
(typed_parameter (identifier) @type.parameter.name type: (type) @type.parameter.annotation) @type.parameter
(function_definition return_type: (type) @type.return.annotation) @type.return
(class_definition name: (identifier) @type.class.name superclasses: (argument_list)? @type.class.bases) @type.class

; --- value_origin_context ---

; Framework-neutral Python value-origin facts for simple identifier bindings.
; Exact only for direct assignment where the RHS is a call expression.
(module
  (expression_statement
    (assignment
      left: (identifier) @python.origin.binding
      right: (call
        function: (identifier) @python.origin.callee
        arguments: (argument_list) @python.origin.arguments) @python.origin.call) @python.origin.assignment))

(module
  (expression_statement
    (assignment
      left: (identifier) @python.origin.binding
      right: (call
        function: (attribute
          object: (identifier) @python.origin.callee_object
          attribute: (identifier) @python.origin.callee_member) @python.origin.callee_attribute
        arguments: (argument_list) @python.origin.member_arguments) @python.origin.member_call) @python.origin.member_assignment))

; --- value_origin_keyword_context ---

; Framework-neutral simple binding call with identifier-valued keyword argument.
(module
  (expression_statement
    (assignment
      left: (identifier) @python.keyword_origin.binding
      right: (call
        function: (identifier) @python.keyword_origin.callee
        arguments: (argument_list
          (keyword_argument
            name: (identifier) @python.keyword_origin.keyword
            value: (identifier) @python.keyword_origin.keyword_identifier) @python.keyword_origin.argument)) @python.keyword_origin.call) @python.keyword_origin.assignment))

; --- class_annotated_field_context ---

(class_definition
  name: (identifier) @python.class_field.owner_class
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @python.class_field.field_name
        type: (type) @python.class_field.field_type) @python.class_field.assignment))) @python.class_field.class


; --- class_imported_base_context ---

; Framework-neutral explicit from-import class base.
(module
  (import_from_statement
    module_name: (dotted_name) @python.class_base_from.module_name
    name: (dotted_name) @python.class_base_from.imported_name)
  (class_definition
    name: (identifier) @python.class_base_from.class_name
    superclasses: (argument_list
      (identifier) @python.class_base_from.base_name)) @python.class_base_from.definition
  (#eq? @python.class_base_from.imported_name @python.class_base_from.base_name))

; Framework-neutral aliased module import class member base, e.g. import pkg as p; class X(p.Base).
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.class_base_alias.module_name
      alias: (identifier) @python.class_base_alias.alias_name))
  (class_definition
    name: (identifier) @python.class_base_alias.class_name
    superclasses: (argument_list
      (attribute
        object: (identifier) @python.class_base_alias.base_receiver
        attribute: (identifier) @python.class_base_alias.base_member))) @python.class_base_alias.definition
  (#eq? @python.class_base_alias.alias_name @python.class_base_alias.base_receiver))

; --- class_self_member_imported_constructor_context ---

; from pkg import Type; class C: def __init__(self): self.member = Type(...)
(module
  (import_from_statement
    module_name: (dotted_name) @python.self_ctor_from.module_name
    name: (dotted_name) @python.self_ctor_from.imported_name)
  (class_definition
    name: (identifier) @python.self_ctor_from.class_name
    body: (block
      (function_definition
        name: (identifier) @python.self_ctor_from.owner_function
        body: (block
          (expression_statement
            (assignment
              left: (attribute
                object: (identifier) @python.self_ctor_from.self_receiver
                attribute: (identifier) @python.self_ctor_from.member_name)
              right: (call
                function: (identifier) @python.self_ctor_from.callee_name
                arguments: (argument_list)) @python.self_ctor_from.call) @python.self_ctor_from.assignment))))
  (#eq? @python.self_ctor_from.imported_name @python.self_ctor_from.callee_name)
  (#eq? @python.self_ctor_from.self_receiver "self"))
)

; import pkg as p; class C: def __init__(self): self.member = p.Type(...)
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.self_ctor_alias.module_name
      alias: (identifier) @python.self_ctor_alias.alias_name))
  (class_definition
    name: (identifier) @python.self_ctor_alias.class_name
    body: (block
      (function_definition
        name: (identifier) @python.self_ctor_alias.owner_function
        body: (block
          (expression_statement
            (assignment
              left: (attribute
                object: (identifier) @python.self_ctor_alias.self_receiver
                attribute: (identifier) @python.self_ctor_alias.member_name)
              right: (call
                function: (attribute
                  object: (identifier) @python.self_ctor_alias.call_receiver
                  attribute: (identifier) @python.self_ctor_alias.callee_member)
                arguments: (argument_list)) @python.self_ctor_alias.call) @python.self_ctor_alias.assignment))))
  (#eq? @python.self_ctor_alias.alias_name @python.self_ctor_alias.call_receiver)
  (#eq? @python.self_ctor_alias.self_receiver "self"))
)

; --- class_method_context ---
(class_definition
  name: (identifier) @python.class_method.class_name
  body: (block
    (function_definition
      name: (identifier) @python.class_method.method_name) @python.class_method.definition))

; --- class_self_registration_context ---
; class C: def f(self): self.register_buffer("name", value)
(class_definition
  name: (identifier) @python.self_register.class_name
  body: (block
    (function_definition
      name: (identifier) @python.self_register.owner_function
      body: (block
        (expression_statement
          (call
            function: (attribute
              object: (identifier) @python.self_register.receiver
              attribute: (identifier) @python.self_register.member)
            arguments: (argument_list
              . (string (string_content) @python.self_register.name_string))) @python.self_register.call))))
  (#eq? @python.self_register.receiver "self")
  (#match? @python.self_register.member "^(register_buffer|register_parameter|add_module)$"))

; --- class_method_self_member_call_context ---
; class C: def forward(self, x): y = self.layer(x)
(class_definition
  name: (identifier) @python.self_flow.class_name
  body: (block
    (function_definition
      name: (identifier) @python.self_flow.owner_function
      body: (block
        (expression_statement
          (assignment
            left: (identifier) @python.self_flow.binding_name
            right: (call
              function: (attribute
                object: (identifier) @python.self_flow.receiver
                attribute: (identifier) @python.self_flow.member)
              arguments: (argument_list
                . (identifier) @python.self_flow.input_identifier)) @python.self_flow.call) @python.self_flow.assignment))))
  (#eq? @python.self_flow.receiver "self"))

; Direct returned self.member(input) call.
(class_definition
  name: (identifier) @python.self_return.class_name
  body: (block
    (function_definition
      name: (identifier) @python.self_return.owner_function
      body: (block
        (return_statement
          (call
            function: (attribute
              object: (identifier) @python.self_return.receiver
              attribute: (identifier) @python.self_return.member)
            arguments: (argument_list
              . (identifier) @python.self_return.input_identifier)) @python.self_return.call)))
  (#eq? @python.self_return.receiver "self"))
)

; --- framework_neutral_python_settings_and_class_fields_v1 ---

; class-owned field constructor, e.g. models.CharField(...), sa.Column(...)
(class_definition
  name: (identifier) @python.class_ctor.owner_class
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @python.class_ctor.field_name
        right: (call
          function: (attribute
            object: (identifier) @python.class_ctor.callee_object
            attribute: (identifier) @python.class_ctor.callee_member)) @python.class_ctor.call) @python.class_ctor.assignment)))

; module-level scalar/string setting
(module
  (expression_statement
    (assignment
      left: (identifier) @python.module_setting.name
      right: (string) @python.module_setting.value) @python.module_setting.assignment))

; module-level string list item setting
(module
  (expression_statement
    (assignment
      left: (identifier) @python.module_list.name
      right: (list (string) @python.module_list.item) @python.module_list.value) @python.module_list.assignment))

; module-level dictionary string->string/identifier entries
(module
  (expression_statement
    (assignment
      left: (identifier) @python.module_dict.name
      right: (dictionary
        (pair key: (string) @python.module_dict.key value: (string) @python.module_dict.string_value)) @python.module_dict.value) @python.module_dict.assignment))
(module
  (expression_statement
    (assignment
      left: (identifier) @python.module_dict.name
      right: (dictionary
        (pair key: (string) @python.module_dict.key value: (identifier) @python.module_dict.identifier_value)) @python.module_dict.value) @python.module_dict.assignment))

; --- framework_neutral_python_class_field_keyword_v3_146 ---
(class_definition
  name: (identifier) @python.class_field_kw.owner_class
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @python.class_field_kw.field_name
        right: (call
          function: (attribute
            object: (identifier) @python.class_field_kw.callee_object
            attribute: (identifier) @python.class_field_kw.callee_member)
          arguments: (argument_list
            (keyword_argument
              name: (identifier) @python.class_field_kw.keyword_name
              value: (_) @python.class_field_kw.keyword_value))) @python.class_field_kw.call) @python.class_field_kw.assignment)))



; --- import_bound_member_call_two_identifier_context_v3_151 ---
; Framework-neutral bounded Python dataflow: explicit import alias member call
; assigned to a local, with first and second direct identifier arguments.
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_flow2.module_name
      alias: (identifier) @python.import_flow2.alias_name))
  (function_definition
    name: (identifier) @python.import_flow2.owner_function
    body: (block
      (expression_statement
        (assignment
          left: (identifier) @python.import_flow2.binding_name
          right: (call
            function: (attribute
              object: (identifier) @python.import_flow2.receiver
              attribute: (identifier) @python.import_flow2.member)
            arguments: (argument_list
              . (identifier) @python.import_flow2.input_identifier
              . (identifier) @python.import_flow2.second_identifier)) @python.import_flow2.call) @python.import_flow2.assignment)))
  (#eq? @python.import_flow2.alias_name @python.import_flow2.receiver))

; --- class_method_self_member_call_two_identifier_context_v3_151 ---
(class_definition
  name: (identifier) @python.self_flow2.class_name
  body: (block
    (function_definition
      name: (identifier) @python.self_flow2.owner_function
      body: (block
        (expression_statement
          (assignment
            left: (identifier) @python.self_flow2.binding_name
            right: (call
              function: (attribute
                object: (identifier) @python.self_flow2.receiver
                attribute: (identifier) @python.self_flow2.member)
              arguments: (argument_list
                . (identifier) @python.self_flow2.input_identifier
                . (identifier) @python.self_flow2.second_identifier)) @python.self_flow2.call) @python.self_flow2.assignment))))
  (#eq? @python.self_flow2.receiver "self"))

; --- import_bound_member_call_three_identifier_context_v3_152 ---
(module
  (import_statement
    name: (aliased_import
      name: (dotted_name) @python.import_flow3.module_name
      alias: (identifier) @python.import_flow3.alias_name))
  (function_definition
    name: (identifier) @python.import_flow3.owner_function
    body: (block
      (expression_statement
        (assignment
          left: (identifier) @python.import_flow3.binding_name
          right: (call
            function: (attribute
              object: (identifier) @python.import_flow3.receiver
              attribute: (identifier) @python.import_flow3.member)
            arguments: (argument_list
              . (identifier) @python.import_flow3.input_identifier
              . (identifier) @python.import_flow3.second_identifier
              . (identifier) @python.import_flow3.third_identifier)) @python.import_flow3.call) @python.import_flow3.assignment)))
  (#eq? @python.import_flow3.alias_name @python.import_flow3.receiver))

; --- class_method_self_member_call_three_identifier_context_v3_152 ---
(class_definition
  name: (identifier) @python.self_flow3.class_name
  body: (block
    (function_definition
      name: (identifier) @python.self_flow3.owner_function
      body: (block
        (expression_statement
          (assignment
            left: (identifier) @python.self_flow3.binding_name
            right: (call
              function: (attribute
                object: (identifier) @python.self_flow3.receiver
                attribute: (identifier) @python.self_flow3.member)
              arguments: (argument_list
                . (identifier) @python.self_flow3.input_identifier
                . (identifier) @python.self_flow3.second_identifier
                . (identifier) @python.self_flow3.third_identifier)) @python.self_flow3.call) @python.self_flow3.assignment))))
  (#eq? @python.self_flow3.receiver "self"))
