; --- assignment_export_object_array_new_context ---

; Framework-neutral CommonJS assignment -> object -> flat array -> direct new Constructor().
; Exact authored subset only: direct identifier owner/property, property_identifier key,
; direct array, direct identifier constructor. Variables/spreads/member constructors/runtime composition excluded.
(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.assignment_export_array_new.owner
    property: (property_identifier) @ecma.assignment_export_array_new.property)
  right: (object
    (pair
      key: (property_identifier) @ecma.assignment_export_array_new.key
      value: (array
        (new_expression
          constructor: (identifier) @ecma.assignment_export_array_new.constructor
          arguments: (arguments) @ecma.assignment_export_array_new.arguments) @ecma.assignment_export_array_new.item) @ecma.assignment_export_array_new.array) @ecma.assignment_export_array_new.pair) @ecma.assignment_export_array_new.object) @ecma.assignment_export_array_new.context
(await_expression (_) @async.await.value @ref.role.await_value) @async.await
(yield_expression (_)? @generator.yield.value) @generator.yield
(generator_function_declaration) @generator.declaration
(generator_function) @generator.expression
(for_in_statement operator: (_) @async.for_await.operator) @async.for_await

; --- bindings ---

(formal_parameters (identifier) @binding.parameter)
(variable_declarator name: (identifier) @binding.variable)
(catch_clause parameter: (identifier) @binding.catch)
(import_specifier alias: (identifier) @binding.import_alias @import.alias)
(namespace_import (identifier) @binding.namespace_import @import.namespace)

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

(call_expression
  function: (_) @call.target
  arguments: (arguments) @call.arguments) @call.expression
(new_expression constructor: (_) @call.constructor @ref.role.constructor) @call.new

; --- classes ---

(class_declaration name: (identifier) @class.name body: (class_body) @class.body) @class.declaration
(class name: (identifier)? @class.expression.name body: (class_body) @class.expression.body) @class.expression
(class_heritage (_) @class.heritage.target) @class.heritage
(method_definition name: (_) @class.method.name parameters: (formal_parameters) @class.method.parameters body: (statement_block) @class.method.body) @class.method
(field_definition property: (_) @class.field.name value: (_)? @class.field.value) @class.field
(class_static_block body: (statement_block) @class.static.body) @class.static
(private_property_identifier) @class.private.identifier @reference.private_property.candidate
(decorator (_) @class.decorator.value @ref.role.decorator_expression) @class.decorator

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression

; --- constructor_identifier_context ---

(new_expression
  constructor: (identifier) @js.ctor_identifier.constructor_name) @js.ctor_identifier.context

; --- data ---

(object) @data.object @object.literal
(array) @data.array @array.literal
(pair key: (_) @data.key @object.property.key value: (_) @data.value @object.property.value) @data.pair @object.property
(string) @data.string @literal.string
(number) @data.number @literal.number
(true) @data.boolean @literal.boolean
(false) @data.boolean @literal.boolean
(null) @data.null @literal.null
(template_string) @data.template @literal.template
(regex) @data.regex @literal.regex

; --- declaration_category_class ---

(class
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(class_declaration
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(function_expression
  name: (_) @definition.category.function.name
) @definition.category.owner

(generator_function
  name: (_) @definition.category.function.name
) @definition.category.owner

(generator_function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_method ---

(method_definition
  name: (_) @definition.category.method.name @definition.identity.name @object.method.name
) @definition.category.owner @definition.identity.owner @object.method

; --- definition_identity_hints ---

(variable_declarator
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions ---

(function_declaration name: (identifier) @definition.function.name) @definition.function
(generator_function_declaration name: (identifier) @definition.generator.name) @definition.generator
(class_declaration name: (identifier) @definition.class.name) @definition.class
(method_definition name: [(property_identifier) (private_property_identifier) (computed_property_name)] @definition.method.name) @definition.method
(variable_declarator name: (identifier) @definition.variable.name value: (_) @definition.variable.value) @definition.variable

; --- documented_definitions ---

; Omega clean reimplementation of exact pinned upstream tag semantics for documentation attachment.
((comment) @doc . (method_definition name: (property_identifier) @documented.method.name) @documented.method)
((comment) @doc . (class_declaration name: (_) @documented.class.name) @documented.class)
((comment) @doc . (function_declaration name: (identifier) @documented.function.name) @documented.function)
((comment) @doc . (generator_function_declaration name: (identifier) @documented.generator.name) @documented.generator)
((comment) @doc . (lexical_declaration (variable_declarator name: (identifier) @documented.binding.name value: [(arrow_function) (function_expression)])) @documented.binding)

; --- enclosing_owner_hints ---

(class 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(class_declaration 
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

; --- function_return_jsx_component_context ---

; Framework-neutral direct JSX component use owned by a function declaration.
; Intentionally limited to direct return <Component/> / <Component>...</Component> shapes.

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
          name: (identifier) @js.jsx_owner.child_component)) @js.jsx_owner.jsx))
) @js.jsx_owner.function

; --- functions ---

(function_declaration name: (identifier) @function.name parameters: (formal_parameters) @function.parameters body: (statement_block) @function.body) @function.declaration
(function_expression name: (identifier)? @function.expression.name parameters: (formal_parameters) @function.expression.parameters body: (statement_block) @function.expression.body) @function.expression
(generator_function_declaration name: (identifier) @function.generator.name parameters: (formal_parameters) @function.generator.parameters body: (statement_block) @function.generator.body) @function.generator.declaration
(generator_function name: (identifier)? @function.generator_expression.name parameters: (formal_parameters) @function.generator_expression.parameters body: (statement_block) @function.generator_expression.body) @function.generator.expression
(arrow_function parameters: (formal_parameters) @function.arrow.parameters body: (_) @function.arrow.body) @function.arrow
(arrow_function parameter: (identifier) @function.arrow.parameter body: (_) @function.arrow.body) @function.arrow.single

; --- import_alias_hints ---

(import_specifier
  name: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- import_default_binding ---

(import_clause (identifier) @js.import.default) @js.import.clause

; --- import_named_binding ---

(import_specifier name: (_) @js.import.imported alias: (identifier) @js.import.local) @js.import.specifier

; --- import_named_unaliased_binding ---

(import_specifier name: (identifier) @js.import.local) @js.import.specifier

; --- import_namespace_binding ---

(import_clause (namespace_import (identifier) @js.import.namespace)) @js.import.clause
(import_specifier name: (_) @import.target @ref.role.import_selector) @import.statement

(import_statement
  source: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

(jsx_opening_element
  name: (_) @import.target @jsx.open.name) @import.statement @jsx.opening

; --- imports ---

(import_statement source: (string) @import.source @module.import_source) @import.statement @module.import
(import_specifier name: [(identifier) (string)] @import.name) @import.specifier
(call_expression function: (import) @import.dynamic.operator arguments: (arguments (string) @import.dynamic.source)) @import.dynamic
(call_expression function: (identifier) @import.require.operator arguments: (arguments (string) @import.require.source) (#eq? @import.require.operator "require")) @import.require

; --- jsx_semantics ---

(jsx_element open_tag: (jsx_opening_element) @jsx.open close_tag: (jsx_closing_element) @jsx.close) @jsx.element
(jsx_self_closing_element name: (_) @jsx.self.name) @jsx.self
(jsx_closing_element name: (_) @jsx.close.name) @jsx.closing
(jsx_attribute) @jsx.attribute
(jsx_expression) @jsx.expression
(jsx_text) @jsx.text
(jsx_namespace_name) @jsx.namespace
(html_character_reference) @jsx.entity
(member_expression object: (_) @reference.receiver @ref.role.member_receiver property: (_) @reference.member @ref.role.member_name) @reference.member_expression

; --- member_string_identifier_call_context ---

(call_expression
  function: (member_expression
    object: (identifier) @js.member_string_id.receiver
    property: (property_identifier) @js.member_string_id.member)
  arguments: (arguments
    (string (string_fragment) @js.member_string_id.arg0)
    (identifier) @js.member_string_id.arg1)) @js.member_string_id.context

; --- module_path_hints ---

; --- modules ---

(export_statement) @module.export

; --- named_import_source_context ---

(import_statement
  (import_clause
    (named_imports
      (import_specifier
        name: (identifier) @js.named_import.imported
        alias: (identifier) @js.named_import.local) @js.named_import.specifier))
  source: (string (string_fragment) @js.named_import.module_source)) @js.named_import.statement

(import_statement
  (import_clause
    (named_imports
      (import_specifier
        name: (identifier) @js.named_import.imported @js.named_import.local) @js.named_import.specifier))
  source: (string (string_fragment) @js.named_import.module_source)) @js.named_import.statement

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

; --- objects_properties ---

(shorthand_property_identifier) @object.shorthand @reference.shorthand.candidate
(computed_property_name (_) @object.computed.value @ref.role.computed_property_expression) @object.computed

; --- ownership_parameters ---

(function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (assignment_pattern) @owned.parameter)) @owner.span

(function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (pattern) @owned.parameter)) @owner.span

(function_expression
  name: (_) @owner.name
  parameters: (formal_parameters
    (assignment_pattern) @owned.parameter)) @owner.span

(function_expression
  name: (_) @owner.name
  parameters: (formal_parameters
    (pattern) @owned.parameter)) @owner.span

(generator_function
  name: (_) @owner.name
  parameters: (formal_parameters
    (assignment_pattern) @owned.parameter)) @owner.span

(generator_function
  name: (_) @owner.name
  parameters: (formal_parameters
    (pattern) @owned.parameter)) @owner.span

(generator_function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (assignment_pattern) @owned.parameter)) @owner.span

(generator_function_declaration
  name: (_) @owner.name
  parameters: (formal_parameters
    (pattern) @owned.parameter)) @owner.span

(method_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (assignment_pattern) @owned.parameter)) @owner.span

(method_definition
  name: (_) @owner.name
  parameters: (formal_parameters
    (pattern) @owned.parameter)) @owner.span

; --- patterns ---

(array_pattern) @pattern.array
(object_pattern) @pattern.object
(rest_pattern) @pattern.rest
(assignment_pattern left: (_) @pattern.assignment.left right: (_) @pattern.assignment.right) @pattern.assignment
(object_assignment_pattern left: (_) @pattern.object_assignment.left right: (_) @pattern.object_assignment.right) @pattern.object_assignment
(pair_pattern key: (_) @pattern.pair.key value: (_) @pattern.pair.value) @pattern.pair
(shorthand_property_identifier_pattern) @pattern.shorthand
(variable_declarator name: [(array_pattern) (object_pattern)] @binding.destructuring) @binding.destructuring.declarator
(catch_clause parameter: [(array_pattern) (object_pattern)] @binding.catch_destructuring) @binding.catch_destructuring.clause

; --- receiver_hints ---

(super) @reference.receiver

(this) @reference.receiver

; --- reexport_hints ---

(export_statement 
  source: (_) @module.reexport.target
) @module.reexport.statement

; --- reference_roles ---

(call_expression function: (_) @ref.role.callee arguments: (arguments (_) @ref.role.call_argument))
(call_expression function: (member_expression object: (_) @ref.role.receiver property: (_) @ref.role.member))
(return_statement (_) @ref.role.return_value)
(throw_statement (_) @ref.role.throw_value)
(assignment_expression left: (_) @ref.role.assignment_lhs right: (_) @ref.role.assignment_rhs)
(augmented_assignment_expression left: (_) @ref.role.assignment_lhs right: (_) @ref.role.assignment_rhs)
(binary_expression left: (_) @ref.role.binary_operand right: (_) @ref.role.binary_operand)
(unary_expression argument: (_) @ref.role.unary_operand)
(update_expression argument: (_) @ref.role.update_operand)
(subscript_expression object: (_) @ref.role.index_receiver index: (_) @ref.role.index_key)
(if_statement condition: (_) @ref.role.condition)
(while_statement condition: (_) @ref.role.condition)
(do_statement condition: (_) @ref.role.condition)
(for_statement condition: (_) @ref.role.condition)
(ternary_expression condition: (_) @ref.role.condition consequence: (_) @ref.role.conditional_value alternative: (_) @ref.role.conditional_value)
(variable_declarator value: (_) @ref.role.initializer)
(assignment_pattern right: (_) @ref.role.default_value)
(spread_element (_) @ref.role.spread_value)
(yield_expression (_) @ref.role.yield_value)
(template_substitution (_) @ref.role.template_expression)
(export_specifier name: (_) @ref.role.export_selector)
(import_specifier alias: (_) @ref.role.import_alias_target)
(jsx_expression (_) @ref.role.jsx_expression)

; --- references ---

(identifier) @reference.identifier.candidate
(property_identifier) @reference.property.candidate

; --- root_member_call_context ---

(call_expression
  function: (member_expression
    object: (identifier) @ecma.root_member_call.root
    property: (property_identifier) @ecma.root_member_call.member)
  arguments: (arguments) @ecma.root_member_call.arguments) @ecma.root_member_call.context

; --- scopes ---

(program) @scope.file
(statement_block) @scope.block
(function_declaration body: (statement_block) @scope.function)
(generator_function_declaration body: (statement_block) @scope.generator)
(arrow_function body: (_) @scope.arrow)
(class_body) @scope.class
(catch_clause body: (statement_block) @scope.catch)

; --- signature_parameters ---

(function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_expression
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

; --- tests ---

(call_expression function: (identifier) @test.call.name arguments: (arguments) @test.call.arguments (#match? @test.call.name "^(test|it|describe|suite)$")) @test.call
(call_expression function: (member_expression property: (property_identifier) @test.member.name) (#match? @test.member.name "^(test|it|describe|suite|beforeEach|afterEach|beforeAll|afterAll)$")) @test.member.call

; --- ecmascript_build_config_string_context ---

; direct call({outer:{key:"value"}})
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

; module.exports = { key: "value" }
(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.export_string.owner_identifier
    property: (property_identifier) @ecma.export_string.owner_property)
  right: (object
    (pair
      key: (property_identifier) @ecma.export_string.key
      value: (string (string_fragment) @ecma.export_string.value)))) @ecma.export_string.context

; module.exports = { outer: { key: "value" } }
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

(class_declaration
  name: (_) @ecma.class_extends.class_name
  (class_heritage
    (identifier) @ecma.class_extends.superclass)) @ecma.class_extends.context

(class_declaration
  name: (_) @ecma.class_extends_member.class_name
  (class_heritage
    (member_expression
      object: (identifier) @ecma.class_extends_member.object
      property: (property_identifier) @ecma.class_extends_member.member)) @ecma.class_extends_member.superclass) @ecma.class_extends_member.context

; --- semantic_closure_v3_146_javascript_arrow_jsx ---
(variable_declarator
  name: (identifier) @js.arrow_jsx.owner
  value: (arrow_function
    body: (jsx_self_closing_element
      name: (identifier) @js.arrow_jsx.child))) @js.arrow_jsx.context

(variable_declarator
  name: (identifier) @js.arrow_jsx.owner
  value: (arrow_function
    body: (jsx_element
      open_tag: (jsx_opening_element
        name: (identifier) @js.arrow_jsx.child)))) @js.arrow_jsx.context

(variable_declarator
  name: (identifier) @js.arrow_jsx.owner
  value: (arrow_function
    body: (statement_block
      (return_statement
        (jsx_self_closing_element
          name: (identifier) @js.arrow_jsx.child))))) @js.arrow_jsx.context

(variable_declarator
  name: (identifier) @js.arrow_jsx.owner
  value: (arrow_function
    body: (statement_block
      (return_statement
        (jsx_element
          open_tag: (jsx_opening_element
            name: (identifier) @js.arrow_jsx.child)))))) @js.arrow_jsx.context

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
(call_expression
  function: (identifier) @ecma.direct_context.call_name
  arguments: (arguments) @ecma.direct_context.arguments) @ecma.direct_context.context

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

; --- exported_named_object_field_v3_146 ---
(export_statement
  declaration: (lexical_declaration
    (variable_declarator
      name: (identifier) @ecma.exported_object.owner
      value: (object
        (pair
          key: (property_identifier) @ecma.exported_object.field
          value: (_) @ecma.exported_object.value) @ecma.exported_object.pair))) @ecma.exported_object.declaration) @ecma.exported_object.context

; --- semantic_closure_v3_149_jsx_owned_attributes ---
(function_declaration
  name: (identifier) @jsx.owned.owner_function
  body: (statement_block
    (return_statement
      (jsx_self_closing_element
        name: (identifier) @jsx.owned.child_component
        attribute: (jsx_attribute
          (property_identifier) @jsx.owned.attribute_name
          (jsx_expression
            (identifier) @jsx.owned.attribute_identifier)) @jsx.owned.attribute)))) @jsx.owned.context

(function_declaration
  name: (identifier) @jsx.owned.owner_function
  body: (statement_block
    (return_statement
      (jsx_element
        open_tag: (jsx_opening_element
          name: (identifier) @jsx.owned.child_component
          attribute: (jsx_attribute
            (property_identifier) @jsx.owned.attribute_name
            (jsx_expression
              (identifier) @jsx.owned.attribute_identifier)) @jsx.owned.attribute))))) @jsx.owned.context

(variable_declarator
  name: (identifier) @jsx.owned.owner_function
  value: (arrow_function
    body: (jsx_self_closing_element
      name: (identifier) @jsx.owned.child_component
      attribute: (jsx_attribute
        (property_identifier) @jsx.owned.attribute_name
        (jsx_expression
          (identifier) @jsx.owned.attribute_identifier)) @jsx.owned.attribute))) @jsx.owned.context

(variable_declarator
  name: (identifier) @jsx.owned.owner_function
  value: (arrow_function
    body: (jsx_element
      open_tag: (jsx_opening_element
        name: (identifier) @jsx.owned.child_component
        attribute: (jsx_attribute
          (property_identifier) @jsx.owned.attribute_name
          (jsx_expression
            (identifier) @jsx.owned.attribute_identifier)) @jsx.owned.attribute)))) @jsx.owned.context

(function_declaration
  name: (identifier) @jsx.string.owner_function
  body: (statement_block
    (return_statement
      (jsx_self_closing_element
        name: (identifier) @jsx.string.child_component
        attribute: (jsx_attribute
          (property_identifier) @jsx.string.attribute_name
          (string) @jsx.string.attribute_value) @jsx.string.attribute)))) @jsx.string.context

(variable_declarator
  name: (identifier) @jsx.string.owner_function
  value: (arrow_function
    body: (jsx_self_closing_element
      name: (identifier) @jsx.string.child_component
      attribute: (jsx_attribute
        (property_identifier) @jsx.string.attribute_name
        (string) @jsx.string.attribute_value) @jsx.string.attribute))) @jsx.string.context

; member-expression JSX tag references are source-exact but target resolution is deferred
(jsx_opening_element
  name: (member_expression) @jsx.member_tag.name) @jsx.member_tag.context

(jsx_self_closing_element
  name: (member_expression) @jsx.member_tag.name) @jsx.member_tag.context

; --- semantic_closure_v3_150_ecma_import_provenance ---
(import_statement
  (import_clause
    (identifier) @js.default_import.local)
  source: (string (string_fragment) @js.default_import.module_source)) @js.default_import.statement

(import_statement
  (import_clause
    (namespace_import (identifier) @js.namespace_import.local))
  source: (string (string_fragment) @js.namespace_import.module_source)) @js.namespace_import.statement

(variable_declarator
  name: (identifier) @js.require_binding.local
  value: (call_expression
    function: (identifier) @js.require_binding.operator
    arguments: (arguments (string (string_fragment) @js.require_binding.module_source)))) @js.require_binding.context

(variable_declarator
  name: (object_pattern
    (shorthand_property_identifier_pattern) @js.require_named.imported @js.require_named.local)
  value: (call_expression
    function: (identifier) @js.require_named.operator
    arguments: (arguments (string (string_fragment) @js.require_named.module_source)))) @js.require_named.context

(variable_declarator
  name: (object_pattern
    (pair_pattern
      key: (property_identifier) @js.require_named.imported
      value: (identifier) @js.require_named.local))
  value: (call_expression
    function: (identifier) @js.require_named.operator
    arguments: (arguments (string (string_fragment) @js.require_named.module_source)))) @js.require_named.context

(new_expression
  constructor: (member_expression
    object: (identifier) @js.member_ctor.object
    property: (property_identifier) @js.member_ctor.member)
  arguments: (arguments) @js.member_ctor.arguments) @js.member_ctor.context

; --- semantic_closure_v3_150_ecma_nested_member_string_identifier ---
(call_expression
  function: (member_expression
    object: (member_expression
      object: (identifier) @js.nested_member.root
      property: (property_identifier) @js.nested_member.object_member)
    property: (property_identifier) @js.nested_member.member)
  arguments: (arguments
    (string (string_fragment) @js.nested_member.arg0)
    (identifier) @js.nested_member.arg1)) @js.nested_member.context

; --- semantic_closure_v3_151_ecma_member_identifier_call ---
(call_expression
  function: (member_expression
    object: (identifier) @js.member_identifier.object
    property: (property_identifier) @js.member_identifier.member)
  arguments: (arguments
    (identifier) @js.member_identifier.arg0)) @js.member_identifier.context

; --- semantic_closure_v3_151_ecma_three_level_object_string ---
; directCall({outer:{middle:{key:"value"}}})
(call_expression
  function: (identifier) @js.three_call.call_name
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @js.three_call.outer_key
        value: (object
          (pair
            key: (property_identifier) @js.three_call.middle_key
            value: (object
              (pair
                key: (property_identifier) @js.three_call.key
                value: (string (string_fragment) @js.three_call.value))))))))) @js.three_call.context

; module.exports = {outer:{middle:{key:"value"}}}
(assignment_expression
  left: (member_expression
    object: (identifier) @js.three_export.owner_identifier
    property: (property_identifier) @js.three_export.owner_property)
  right: (object
    (pair
      key: (property_identifier) @js.three_export.outer_key
      value: (object
        (pair
          key: (property_identifier) @js.three_export.middle_key
          value: (object
            (pair
              key: (property_identifier) @js.three_export.key
              value: (string (string_fragment) @js.three_export.value)))))))) @js.three_export.context

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
      name: (identifier) @js.b3_const_string.binding
      value: (string (string_fragment) @js.b3_const_string.value)) @js.b3_const_string.declarator))
  @js.b3_const_string.program @js.b3_const_number.program @js.b3_const_true.program @js.b3_const_false.program @js.b3_const_null.program @js.b3_const_alias.program

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @js.b3_const_number.binding
      value: (number) @js.b3_const_number.value) @js.b3_const_number.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @js.b3_const_true.binding
      value: (true) @js.b3_const_true.value) @js.b3_const_true.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @js.b3_const_false.binding
      value: (false) @js.b3_const_false.value) @js.b3_const_false.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @js.b3_const_null.binding
      value: (null) @js.b3_const_null.value) @js.b3_const_null.declarator))

(program
  (lexical_declaration
    kind: "const"
    (variable_declarator
      name: (identifier) @js.b3_const_alias.binding
      value: (identifier) @js.b3_const_alias.target) @js.b3_const_alias.declarator))

; --- final_completion_ecma_generalized_config_source_v1 ---

; Any direct pair in export default { ... }: raw authored key/value source.
(export_statement
  value: (object
    (pair
      key: (_) @ecma.export_object_field.key
      value: (_) @ecma.export_object_field.value) @ecma.export_object_field.pair) @ecma.export_object_field.object) @ecma.export_object_field.context

; Shorthand direct field in export default { foo }.
(export_statement
  value: (object
    (shorthand_property_identifier) @ecma.export_object_shorthand.name) @ecma.export_object_shorthand.object) @ecma.export_object_shorthand.context

; CommonJS member assignment -> direct object -> direct array -> direct new expression,
; preserving raw key and constructor expression (identifier/member/etc.) without resolving it.
(assignment_expression
  left: (member_expression
    object: (identifier) @ecma.assignment_export_array_new_raw.owner
    property: (property_identifier) @ecma.assignment_export_array_new_raw.property)
  right: (object
    (pair
      key: (_) @ecma.assignment_export_array_new_raw.key
      value: (array
        (new_expression
          constructor: (_) @ecma.assignment_export_array_new_raw.constructor
          arguments: (arguments) @ecma.assignment_export_array_new_raw.arguments) @ecma.assignment_export_array_new_raw.item) @ecma.assignment_export_array_new_raw.array) @ecma.assignment_export_array_new_raw.pair) @ecma.assignment_export_array_new_raw.object) @ecma.assignment_export_array_new_raw.context

; Direct identifier call -> object -> direct array -> direct call expression,
; preserving raw field key and raw callee expression without resolving it.
(call_expression
  function: (identifier) @ecma.call_object_array_call_raw.owner_call
  arguments: (arguments
    (object
      (pair
        key: (_) @ecma.call_object_array_call_raw.key
        value: (array
          (call_expression
            function: (_) @ecma.call_object_array_call_raw.item_callee
            arguments: (arguments) @ecma.call_object_array_call_raw.item_arguments) @ecma.call_object_array_call_raw.item) @ecma.call_object_array_call_raw.array) @ecma.call_object_array_call_raw.pair) @ecma.call_object_array_call_raw.object)) @ecma.call_object_array_call_raw.context
