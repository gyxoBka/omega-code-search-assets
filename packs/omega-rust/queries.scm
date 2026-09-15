; --- aggregate_members ---

; Explicit aggregate ownership relations for named fields and enum variants.
(struct_item
  name: (_) @relation.struct.owner
  body: (field_declaration_list
    (field_declaration
      name: (_) @relation.struct.field))) @relation.struct.field_relation

(union_item
  name: (_) @relation.union.owner
  body: (field_declaration_list
    (field_declaration
      name: (_) @relation.union.field))) @relation.union.field_relation

(enum_item
  name: (_) @relation.enum.owner
  body: (enum_variant_list
    (enum_variant
      name: (_) @relation.enum.variant))) @relation.enum.variant_relation

(enum_variant
  name: (_) @relation.enum_variant.owner
  value: (_) @relation.enum_variant.discriminant) @relation.enum_variant.discriminant_relation

; --- assignments ---

(assignment_expression
  left: (_) @assignment.target
  right: (_) @assignment.value) @assignment.simple

(compound_assignment_expr
  left: (_) @assignment.target
  right: (_) @assignment.value) @assignment.compound

(let_declaration
  pattern: (_) @assignment.binding_pattern
  value: (_) @assignment.initializer) @assignment.let

(const_item
  name: (identifier) @assignment.const.name
  value: (_) @assignment.const.value) @assignment.const

(static_item
  name: (identifier) @assignment.static.name
  value: (_) @assignment.static.value) @assignment.static

; --- attributes ---

(attribute_item
  (attribute) @attribute.body) @attribute.outer

(inner_attribute_item
  (attribute) @attribute.body) @attribute.inner

(attribute
  (identifier) @attribute.path) @attribute.named

(attribute
  (scoped_identifier) @attribute.path) @attribute.scoped

(attribute
  arguments: (token_tree) @attribute.arguments) @attribute.with_arguments

(attribute
  value: (_) @attribute.value) @attribute.with_value

; --- bindings ---

(let_declaration
  pattern: (_) @binding.pattern) @binding.let

(parameter
  pattern: (_) @binding.pattern) @binding.parameter

(self_parameter
  (self) @binding.self.name) @binding.self_parameter

(variadic_parameter
  pattern: (_) @binding.pattern) @binding.variadic

(closure_expression
  parameters: (closure_parameters) @binding.closure.parameters) @binding.closure

(for_expression
  pattern: (_) @binding.pattern) @binding.for

(let_condition
  pattern: (_) @binding.pattern) @binding.let_condition

(match_arm
  pattern: (match_pattern) @binding.match.pattern) @binding.match

(captured_pattern
  (identifier) @binding.captured.name) @binding.captured

(field_pattern
  name: (shorthand_field_identifier) @binding.field_shorthand.name) @binding.field_shorthand

; Pattern-shape captures make recursive binding extraction auditable instead of
; hiding every destructuring decision behind one opaque normalization step.
(generic_pattern) @binding.pattern_shape.generic
(tuple_pattern) @binding.pattern_shape.tuple
(slice_pattern) @binding.pattern_shape.slice
(tuple_struct_pattern) @binding.pattern_shape.tuple_struct
(struct_pattern) @binding.pattern_shape.struct
(mut_pattern) @binding.pattern_shape.mut
(range_pattern) @binding.pattern_shape.range
(ref_pattern) @binding.pattern_shape.ref
(reference_pattern) @binding.pattern_shape.reference
(or_pattern) @binding.pattern_shape.or
(remaining_field_pattern) @binding.pattern_shape.remaining
(const_block) @binding.pattern_shape.const_block
(macro_invocation) @binding.pattern_shape.macro

; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls ---

(call_expression
  function: (identifier) @call.direct.target
  arguments: (arguments) @call.arguments) @call.direct

; A scoped call names its last segment; the path before it is the qualifier.
; A path whose last segment is a type (`Type::name()`) and `Self::name()` have
; their own patterns below, so each call is emitted once.
((call_expression
  function: (scoped_identifier
    path: (_) @call.path.qualifier
    name: (identifier) @call.path.name) @call.path.target
  arguments: (arguments) @call.arguments) @call.path
 (#not-match? @call.path.qualifier "(^|::)[A-Z][A-Za-z0-9_]*$"))

; `Type::name()` and `module::Type::name()`: the member of a named type.
((call_expression
  function: (scoped_identifier
    path: [
      (identifier) @call.type_path.type
      (scoped_identifier
        name: (identifier) @call.type_path.type)
    ] @call.type_path.qualifier
    name: (identifier) @call.type_path.name) @call.type_path.target
  arguments: (arguments) @call.arguments) @call.type_path
 (#match? @call.type_path.type "^[A-Z]")
 (#not-eq? @call.type_path.type "Self"))

; `Self::name()`: a member of the type the enclosing declaration belongs to.
((call_expression
  function: (scoped_identifier
    path: (identifier) @call.self_path.type
    name: (identifier) @call.self_path.name) @call.self_path.target
  arguments: (arguments) @call.arguments) @call.self_path
 (#eq? @call.self_path.type "Self"))

; A method call on any receiver but `self`, which has its own pattern.
((call_expression
  function: (field_expression
    value: (_) @call.method.receiver
    field: (field_identifier) @call.method.name) @call.method.target
  arguments: (arguments) @call.arguments) @call.method
 (#not-eq? @call.method.receiver "self"))

; `self.name()`: a member of the type the enclosing declaration belongs to.
(call_expression
  function: (field_expression
    value: (self)
    field: (field_identifier) @call.self_method.name) @call.self_method.target
  arguments: (arguments) @call.arguments) @call.self_method

(call_expression
  function: (generic_function
    function: (identifier) @call.generic.direct.name
    type_arguments: (type_arguments) @call.generic.type_arguments) @call.generic.target
  arguments: (arguments) @call.arguments) @call.generic.direct

(call_expression
  function: (generic_function
    function: (scoped_identifier) @call.generic.path.name
    type_arguments: (type_arguments) @call.generic.type_arguments) @call.generic.target
  arguments: (arguments) @call.arguments) @call.generic.path

(call_expression
  function: (generic_function
    function: (field_expression
      field: (field_identifier) @call.generic.method.name) @call.generic.method.receiver
    type_arguments: (type_arguments) @call.generic.type_arguments) @call.generic.target
  arguments: (arguments) @call.arguments) @call.generic.method

; Catch-all is intentional: closures, parenthesized callables, indexed/function-valued
; expressions and other dynamic call forms must be represented rather than silently lost.
(call_expression
  function: (_) @call.dynamic.target
  arguments: (arguments) @call.arguments) @call.dynamic

(macro_invocation
  macro: (identifier) @call.macro.name
  (token_tree) @call.macro.arguments) @call.macro

(macro_invocation
  macro: (scoped_identifier) @call.macro.path
  (token_tree) @call.macro.arguments) @call.macro.scoped

; --- cfg_guards ---

((attribute_item
   (attribute
     (identifier) @guard.cfg.attribute
     arguments: (token_tree) @guard.cfg.arguments)) @guard.cfg.item
 (#match? @guard.cfg.attribute "^(cfg|cfg_attr)$"))

((inner_attribute_item
   (attribute
     (identifier) @guard.cfg.inner_attribute
     arguments: (token_tree) @guard.cfg.arguments)) @guard.cfg.inner_item
 (#match? @guard.cfg.inner_attribute "^(cfg|cfg_attr)$"))

; --- config_consumers ---

((macro_invocation
   macro: (identifier) @config.macro.name
   (token_tree) @config.macro.arguments) @config.macro
 (#match? @config.macro.name "^(env|option_env|include|include_str|include_bytes|cfg)$"))

((attribute_item
   (attribute
     (identifier) @config.attribute.name
     arguments: (token_tree) @config.attribute.arguments)) @config.attribute
 (#match? @config.attribute.name "^(cfg|cfg_attr|path)$"))

((inner_attribute_item
   (attribute
     (identifier) @config.inner_attribute.name
     arguments: (token_tree) @config.inner_attribute.arguments)) @config.inner_attribute
 (#match? @config.inner_attribute.name "^(cfg|cfg_attr|path)$"))

; Runtime/environment APIs are post-filtered by canonical target text.
(call_expression
  function: (scoped_identifier) @config.api.target
  arguments: (arguments) @config.api.arguments) @config.api.call

; --- control_flow ---

(if_expression condition: (_) @control.if.condition) @control.if
(match_expression value: (_) @control.match.value body: (match_block) @control.match.body) @control.match
(while_expression condition: (_) @control.while.condition body: (block) @control.while.body) @control.while
(loop_expression body: (block) @control.loop.body) @control.loop
(for_expression pattern: (_) @control.for.pattern value: (_) @control.for.value body: (block) @control.for.body) @control.for
(return_expression) @control.return
(yield_expression) @control.yield
(break_expression) @control.break
(continue_expression) @control.continue
(await_expression) @control.await
(try_expression) @control.try
(let_condition pattern: (_) @control.let.pattern value: (_) @control.let.value) @control.let
(let_chain) @control.let_chain
(const_block body: (block) @control.const.body) @control.const
(unsafe_block (block) @control.unsafe.body) @control.unsafe
(async_block (block) @control.async.body) @control.async
(gen_block (block) @control.gen.body) @control.gen
(try_block (block) @control.try_block.body) @control.try_block
(label) @control.label

; --- data_handoffs ---

; Bounded local data-handoff relations. These express syntax-local flow only;
; they do not claim compiler dataflow, alias analysis, or target resolution.

(call_expression
  function: (_) @relation.data.argument.callee
  arguments: (arguments
    (_) @relation.data.argument.value)) @relation.data.argument

(assignment_expression
  left: (_) @relation.data.assignment.target
  right: (_) @relation.data.assignment.value) @relation.data.assignment

(compound_assignment_expr
  left: (_) @relation.data.assignment.target
  right: (_) @relation.data.assignment.value) @relation.data.compound_assignment

(let_declaration
  pattern: (_) @relation.data.initializer.target
  value: (_) @relation.data.initializer.value) @relation.data.initializer

(return_expression
  (_) @relation.data.return.value) @relation.data.return

(yield_expression
  (_) @relation.data.yield.value) @relation.data.yield

; --- data ---

(struct_expression
  name: (_) @data.struct.type
  body: (field_initializer_list) @data.struct.fields) @data.struct

(field_initializer
  field: (_) @data.field.name
  value: (_) @data.field.value) @data.field

(shorthand_field_initializer
  (identifier) @data.field_shorthand.name) @data.field_shorthand

(base_field_initializer) @data.field_base
(array_expression) @data.array
(tuple_expression) @data.tuple
(unit_expression) @data.unit
(string_literal) @data.literal.string
(raw_string_literal) @data.literal.raw_string
(char_literal) @data.literal.char
(boolean_literal) @data.literal.bool
(integer_literal) @data.literal.integer
(float_literal) @data.literal.float
(negative_literal) @data.literal.negative

; --- declaration_category_constant ---

(const_item
  name: (_) @definition.category.constant.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_item
  name: (_) @definition.category.enum.name
) @definition.category.owner

(enum_variant
  name: (_) @definition.category.enum.name
) @definition.category.owner

; --- declaration_category_field ---

(field_declaration
  name: (_) @definition.category.field.name
) @definition.category.owner

; --- declaration_category_function ---

(function_item
  name: (_) @definition.category.function.name
) @definition.category.owner

(function_signature_item
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- declaration_category_macro ---

(macro_definition
  name: (_) @definition.category.macro.name
) @definition.category.owner

; --- declaration_category_module ---

(mod_item
  name: (_) @definition.category.module.name
) @definition.category.owner

; --- declaration_category_struct ---

(struct_item
  name: (_) @definition.category.struct.name
) @definition.category.owner

; --- declaration_category_trait ---

(trait_item
  name: (_) @definition.category.trait.name
) @definition.category.owner

; --- declaration_category_type ---

(type_item
  name: (_) @definition.category.type.name
) @definition.category.owner

; --- declaration_category_union ---

(union_item
  name: (_) @definition.category.union.name
) @definition.category.owner

; --- declaration_category_variable ---

; --- declaration_modifiers ---

(function_item
  (function_modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(function_signature_item
  (function_modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- declaration_visibility ---

(const_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(enum_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(enum_variant
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(extern_crate_declaration
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(field_declaration
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(function_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(function_signature_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(mod_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(static_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(struct_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(trait_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(type_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

(union_item
  (visibility_modifier) @definition.visibility.modifier
  name: (_) @definition.visibility.name
) @definition.visibility.owner

; --- definition_identity_hints ---

(const_item
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_item
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_variant
  name: (_) @definition.identity.name) @definition.identity.owner

(field_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(function_item
  name: (_) @definition.identity.name) @definition.identity.owner

(function_signature_item
  name: (_) @definition.identity.name) @definition.identity.owner

(macro_definition
  name: (_) @definition.identity.name) @definition.identity.owner

(struct_item
  name: (_) @definition.identity.name) @definition.identity.owner

(trait_item
  name: (_) @definition.identity.name) @definition.identity.owner

(type_item
  name: (_) @definition.identity.name) @definition.identity.owner

(union_item
  name: (_) @definition.identity.name) @definition.identity.owner

; --- definitions_functions ---

; The type an `impl` block's functions belong to, carried onto each function
; declaration: the base type name, whatever generics or path spell it.
(impl_item
  type: [
    (type_identifier) @definition.container_name_candidate.type
    (generic_type
      type: (type_identifier) @definition.container_name_candidate.type)
    (scoped_type_identifier
      name: (type_identifier) @definition.container_name_candidate.type)
  ]
  body: (declaration_list
    (function_item) @definition.container_name_candidate))

; All Rust function-like declarations. Rule-side ancestry classification distinguishes
; free functions, inherent methods, trait methods, trait requirements, and extern signatures.
(function_item
  name: [(identifier) (metavariable)] @definition.function.name
  parameters: (parameters) @definition.function.parameters
  body: (block) @definition.function.body) @definition.function

(function_signature_item
  name: [(identifier) (metavariable)] @definition.signature.name
  parameters: (parameters) @definition.signature.parameters) @definition.signature

; --- definitions_macros ---

(macro_definition
  name: (identifier) @definition.macro.name) @definition.macro

(token_binding_pattern
  name: (metavariable) @definition.macro_parameter.name
  type: (fragment_specifier) @definition.macro_parameter.fragment) @definition.macro_parameter

(macro_rule
  left: (token_tree_pattern) @definition.macro_rule.pattern
  right: (token_tree) @definition.macro_rule.expansion) @definition.macro_rule

(token_repetition_pattern) @definition.macro.repetition_pattern
(token_repetition) @definition.macro.repetition
(token_tree_pattern) @definition.macro.token_pattern
(token_tree) @definition.macro.token_tree
(metavariable) @definition.macro.metavariable.candidate

; --- definitions_types ---

(struct_item
  name: (type_identifier) @definition.struct.name) @definition.struct

(enum_item
  name: (type_identifier) @definition.enum.name) @definition.enum

(union_item
  name: (type_identifier) @definition.union.name) @definition.union

(trait_item
  name: (type_identifier) @definition.trait.name) @definition.trait

(type_item
  name: (type_identifier) @definition.type_alias.name
  type: (_) @definition.type_alias.target) @definition.type_alias

(associated_type
  name: (type_identifier) @definition.associated_type.name) @definition.associated_type

(enum_variant
  name: (identifier) @definition.enum_variant.name) @definition.enum_variant

(field_declaration
  name: (field_identifier) @definition.field.name
  type: (_) @definition.field.type) @definition.field

(ordered_field_declaration_list
  type: (_) @definition.tuple_field.type) @definition.tuple_field.container

(type_parameter
  name: (type_identifier) @definition.type_parameter.name) @definition.type_parameter

(const_parameter
  name: (identifier) @definition.const_parameter.name
  type: (_) @definition.const_parameter.type) @definition.const_parameter

(lifetime_parameter
  name: (lifetime) @definition.lifetime_parameter.name) @definition.lifetime_parameter

; --- definitions_values ---

(const_item
  name: (identifier) @definition.const.name
  type: (_) @definition.const.type) @definition.const

(static_item
  name: (identifier) @definition.static.name
  type: (_) @definition.static.type) @definition.static

; --- documentation_marker_fields ---

; Exact inner/outer doc marker fields on line/block comments.
(line_comment inner: (_) @field.doc.inner_marker)
(line_comment outer: (_) @field.doc.outer_marker)
(block_comment inner: (_) @field.doc.inner_marker)
(block_comment outer: (_) @field.doc.outer_marker)

; --- documentation ---

(line_comment
  doc: (doc_comment) @documentation.text) @documentation.line

(block_comment
  doc: (doc_comment) @documentation.text) @documentation.block

(line_comment) @comment.line
(block_comment) @comment.block
(shebang) @source.shebang

; --- dynamic_resolution_guards ---

(call_expression
  function: (field_expression) @guard.dynamic_dispatch.target) @guard.dynamic_dispatch.call

(call_expression
  function: (_) @guard.dynamic_call.target) @guard.dynamic_call

(dynamic_type) @guard.dynamic_type
(abstract_type) @guard.impl_trait

; --- embedded_regions ---

; Omega mature-pack enrichment from exact-compatible Neovim distributed injection baseline
; original=packs/omega-rust/third_party/neovim-distributed/queries/injections.scm
; retained third-party baseline/LICENSE remains under third_party/neovim-distributed

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @_macro_name)
    (identifier) @_macro_name
  ]
  (token_tree) @injection.content
  (#not-any-of? @_macro_name "slint" "html" "json" "xml")
  (#set! injection.language "rust")
  (#set! injection.include-children))

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @injection.language)
    (identifier) @injection.language
  ]
  (token_tree) @injection.content
  (#any-of? @injection.language "slint" "html" "json" "xml")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))

(macro_definition
  (macro_rule
    left: (token_tree_pattern) @injection.content
    (#set! injection.language "rust")))

(macro_definition
  (macro_rule
    right: (token_tree) @injection.content
    (#set! injection.language "rust")))

([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "Regex" "RegexBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "Regex" "RegexBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "RegexSet" "RegexSetBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "RegexSet" "RegexSetBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

((block_comment) @injection.content
  (#match? @injection.content "/\\*!([a-zA-Z]+:)?re2c")
  (#set! injection.language "re2c"))

; --- enclosing_owner_hints ---

(struct_expression 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(struct_item 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

(trait_item 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- expressions ---

; Explicit value/expression surface not already represented as calls, assignments,
; literals, constructors or control owners. These captures preserve syntactic data
; origins without pretending to perform compiler-level constant/data-flow analysis.
(range_expression) @expression.range
(unary_expression) @expression.unary
(reference_expression) @expression.reference
(binary_expression) @expression.binary
(type_cast_expression) @expression.cast
(parenthesized_expression) @expression.parenthesized
(index_expression) @expression.index
(field_expression) @expression.field
(closure_expression) @expression.closure
(async_block) @expression.async_block
(gen_block) @expression.gen_block
(try_block) @expression.try_block
(const_block) @expression.const_block
(unsafe_block) @expression.unsafe_block

; --- ffi_guards ---

(foreign_mod_item) @guard.ffi.module

(function_signature_item
  (function_modifiers) @guard.ffi.function_modifiers) @guard.ffi.signature

(function_item
  (function_modifiers) @guard.ffi.function_modifiers) @guard.ffi.function

; --- fq_router_nest_binding_context ---

; Generic Rust fully-qualified router-constructor + nested-router binding.
; Framework-neutral: captures only source structure. Child identity must be
; established by a separate binding fact in the framework rule layer.

(let_declaration
  pattern: (identifier) @rust.router_nest.binding
  value: (call_expression
    function: (field_expression
      value: (call_expression
        function: (scoped_identifier
          path: (scoped_identifier
            path: (identifier) @rust.router_nest.module_root
            name: (identifier) @rust.router_nest.router_type)
          name: (identifier) @rust.router_nest.constructor_name)
        arguments: (arguments)) @rust.router_nest.constructor_call
      field: (field_identifier) @rust.router_nest.nest_method)
    arguments: (arguments
      . (string_literal
          (string_content) @rust.router_nest.prefix_literal)
      . (identifier) @rust.router_nest.child_binding
      .)) @rust.router_nest.nest_call) @rust.router_nest.context

; --- fq_router_route_binding_context ---

; Generic Rust fully-qualified router-constructor + route registration binding.
; Framework-neutral: captures only source structure. The framework layer decides
; whether the captured module/type/method names belong to a supported router API.

(let_declaration
  pattern: (identifier) @rust.router_route.binding
  value: (call_expression
    function: (field_expression
      value: (call_expression
        function: (scoped_identifier
          path: (scoped_identifier
            path: (identifier) @rust.router_route.module_root
            name: (identifier) @rust.router_route.router_type)
          name: (identifier) @rust.router_route.constructor_name)
        arguments: (arguments)) @rust.router_route.constructor_call
      field: (field_identifier) @rust.router_route.route_method)
    arguments: (arguments
      . (string_literal
          (string_content) @rust.router_route.path_literal)
      . (call_expression
          function: (scoped_identifier
            path: (scoped_identifier
              path: (identifier) @rust.router_route.method_root
              name: (identifier) @rust.router_route.method_module)
            name: (identifier) @rust.router_route.method_wrapper)
          arguments: (arguments
            . (identifier) @rust.router_route.handler_identifier
            .))
      .)) @rust.router_route.route_call) @rust.router_route.context

; --- function_scoped_attribute_context ---

; Framework-neutral fully-qualified Rust outer attribute immediately preceding a function.
; Arguments, if any, are deliberately not interpreted by this fact.
(source_file
  (attribute_item
    (attribute
      (scoped_identifier) @rust.fn_scoped_attr.attribute_path) @rust.fn_scoped_attr.attribute)
  .
  (function_item
    name: (identifier) @rust.fn_scoped_attr.function_name) @rust.fn_scoped_attr.function)

; --- function_scoped_macro_literal_context ---

; Framework-neutral authored Rust fact:
; a named function directly contains a let-binding whose RHS is a fully-qualified
; two-segment macro invocation and whose outer token tree begins with a direct
; string literal. The literal value is deliberately not captured or emitted.
(function_item
  name: (identifier) @rust.owned_macro.owner_name
  body: (block
    (let_declaration
      value: (macro_invocation
        macro: (scoped_identifier
          path: (identifier) @rust.owned_macro.macro_root
          name: (identifier) @rust.owned_macro.macro_name)
        (token_tree
          . (string_literal))) @rust.owned_macro.context))) @rust.owned_macro.owner

; --- function_scoped_string_attribute_context ---

; Framework-neutral Rust fully-qualified outer attribute with one direct plain string literal,
; immediately preceding a function item. The Pack records source structure only.
(source_file
  (attribute_item
    (attribute
      (scoped_identifier) @rust.fn_scoped_string_attr.attribute_path
      arguments: (token_tree
        (string_literal
          (string_content) @rust.fn_scoped_string_attr.arg0))) @rust.fn_scoped_string_attr.attribute)
  .
  (function_item
    name: (identifier) @rust.fn_scoped_string_attr.function_name) @rust.fn_scoped_string_attr.function)

; --- function_string_attribute_context ---

; Framework-neutral Rust outer attribute with one direct plain string literal, immediately
; preceding a function item. Macro expansion and framework meaning are intentionally absent.
(source_file
  (attribute_item
    (attribute
      (identifier) @rust.fn_string_attr.attribute_path
      arguments: (token_tree
        (string_literal
          (string_content) @rust.fn_string_attr.arg0))) @rust.fn_string_attr.attribute)
  .
  (function_item
    name: (identifier) @rust.fn_string_attr.function_name) @rust.fn_string_attr.function)

; --- generic_applications ---

; Explicit generic application relations for type and callable paths.
(generic_type
  type: (_) @relation.generic_type.base
  type_arguments: (_) @relation.generic_type.arguments) @relation.generic_type.application

(generic_function
  function: (_) @relation.generic_function.base
  type_arguments: (_) @relation.generic_function.arguments) @relation.generic_function.application

(type_parameter
  name: (_) @relation.type_default.owner
  default_type: (_) @relation.type_default.target) @relation.type_default

(const_parameter
  name: (_) @relation.const_default.owner
  value: (_) @relation.const_default.target) @relation.const_default

; --- generic_parameter_fields ---

; Exact generic-parameter field selectors for every grammar owner exposing the field.
(struct_item type_parameters: (_) @field.generic_parameters)
(union_item type_parameters: (_) @field.generic_parameters)
(enum_item type_parameters: (_) @field.generic_parameters)
(type_item type_parameters: (_) @field.generic_parameters)
(function_item type_parameters: (_) @field.generic_parameters)
(function_signature_item type_parameters: (_) @field.generic_parameters)
(impl_item type_parameters: (_) @field.generic_parameters)
(trait_item type_parameters: (_) @field.generic_parameters)
(associated_type type_parameters: (_) @field.generic_parameters)
(higher_ranked_trait_bound type_parameters: (_) @field.generic_parameters)

; --- glob_import_guards ---

(use_declaration
  argument: (use_wildcard) @guard.glob.import) @guard.glob.declaration

(use_wildcard) @guard.glob.any

; --- implementations ---

(impl_item
  type: (_) @implementation.target) @implementation.inherent

(impl_item
  trait: (_) @implementation.trait
  type: (_) @implementation.target) @implementation.trait_for

; --- import_alias_hints ---

(use_as_clause
  path: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- import_bound_attribute_context ---

; Framework-neutral explicit three-segment Rust use import plus an immediately
; bound unqualified outer attribute on a top-level function or foreign function block.
; The Pack records syntax only; Framework rules must validate imported/attribute names.
(source_file
  (use_declaration
    argument: (scoped_identifier
      path: (scoped_identifier
        path: (identifier) @rust.import_attr.import_root
        name: (identifier) @rust.import_attr.import_module)
      name: (identifier) @rust.import_attr.import_member)) @rust.import_attr.use
  (attribute_item
    (attribute
      (identifier) @rust.import_attr.attribute_path) @rust.import_attr.attribute) @rust.import_attr.attribute_item
  .
  (function_item
    name: (identifier) @rust.import_attr.function_name) @rust.import_attr.function)

(source_file
  (use_declaration
    argument: (scoped_identifier
      path: (scoped_identifier
        path: (identifier) @rust.import_foreign.import_root
        name: (identifier) @rust.import_foreign.import_module)
      name: (identifier) @rust.import_foreign.import_member)) @rust.import_foreign.use
  (attribute_item
    (attribute
      (identifier) @rust.import_foreign.attribute_path) @rust.import_foreign.attribute) @rust.import_foreign.attribute_item
  .
  (foreign_mod_item
    body: (declaration_list
      (function_signature_item
        name: (identifier) @rust.import_foreign.function_name))) @rust.import_foreign.block)

; --- imports ---

(use_declaration
  argument: (_) @import.argument) @import.declaration

(use_as_clause
  path: (_) @import.alias.path
  alias: (identifier) @import.alias.name) @import.alias

(scoped_use_list
  path: (_) @import.group.path
  list: (use_list) @import.group.list) @import.group

(use_wildcard) @import.glob

(extern_crate_declaration
  name: (identifier) @import.extern_crate.name) @import.extern_crate

(extern_crate_declaration
  name: (identifier) @import.extern_crate.name
  alias: (identifier) @import.extern_crate.alias) @import.extern_crate.aliased

; --- labels ---

; Rust control-flow labels are lexical control targets, not lifetimes.
; Capture declarations on label-owning constructs separately from break/continue references.

(while_expression
  (label) @definition.control_label)

(loop_expression
  (label) @definition.control_label)

(for_expression
  (label) @definition.control_label)

(block
  (label) @definition.control_label)

(break_expression
  (label) @reference.role.loop_label_reference)

(continue_expression
  (label) @reference.role.loop_label_reference)

; --- macro_first_identifier_context ---

; Framework-neutral direct macro shape: macro!(Identifier ...)
; Only the first direct named identifier in the outer token tree is captured.
(macro_invocation
  macro: (identifier) @rust.macro_first.macro_name
  (token_tree
    . (identifier) @rust.macro_first.arg0_identifier)) @rust.macro_first.context

; --- macro_two_identifier_nested_identifier_context ---

; Framework-neutral direct macro shape with two outer identifiers followed by
; a nested token tree whose first direct identifier is captured.
; Example shape only: m!(left -> right(inner)); punctuation is not interpreted.
(macro_invocation
  macro: (identifier) @rust.macro_relation.macro_name
  (token_tree
    . (identifier) @rust.macro_relation.arg0_identifier
    . (identifier) @rust.macro_relation.arg1_identifier
    . (token_tree
      . (identifier) @rust.macro_relation.nested0_identifier))) @rust.macro_relation.context

; --- macros_guards ---

(macro_invocation) @guard.macro_invocation
(macro_definition) @guard.macro_definition
(attribute_item) @guard.attribute
(inner_attribute_item) @guard.inner_attribute

; --- member_access_hints ---

(field_expression
  value: (_) @reference.receiver
  field: (_) @reference.member) @reference.member_expression

; --- member_category_enum_member ---

(enum_item
  name: (_) @owner.member_category.enum.name
  body: (enum_variant_list
    (enum_variant
      name: (_) @owned.member_category.enum.name) @owned.member)) @owner.span

; --- member_category_field ---

(enum_variant
  name: (_) @owner.member_category.field.name
  body: (field_declaration_list
    (field_declaration
      name: (_) @owned.member_category.field.name) @owned.member)) @owner.span

(struct_item
  name: (_) @owner.member_category.field.name
  body: (field_declaration_list
    (field_declaration
      name: (_) @owned.member_category.field.name) @owned.member)) @owner.span

; --- module_path_guards ---

((attribute_item
   (attribute
     (identifier) @guard.path.attribute
     arguments: (token_tree) @guard.path.arguments)) @guard.path.item
 (#eq? @guard.path.attribute "path"))

(mod_item
  name: (identifier) @guard.module.external.name
  !body) @guard.module.external

; --- module_path_hints ---

(scoped_use_list 
  path: (_) @import.module_path.target
) @import.module_path.statement

; --- modules ---

(mod_item
  name: (identifier) @module.name) @module.declaration

(mod_item
  name: (identifier) @module.inline.name
  body: (declaration_list) @module.inline.body) @module.inline

(scoped_identifier) @module.path.value
(scoped_type_identifier) @module.path.type

; --- named_scope_owners ---

(function_item
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(struct_expression
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(struct_item
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(trait_item
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- operator_calls ---

; Rust operator-like syntax can invoke trait/compiler dispatch. We index the
; syntactic operation as a call candidate while guarding exact target/type
; resolution, which belongs to compiler semantics.

(binary_expression
  left: (_) @operator.binary.left
  operator: _ @operator.binary.token
  right: (_) @operator.binary.right) @operator.binary

(compound_assignment_expr
  left: (_) @operator.assign.left
  operator: _ @operator.assign.token
  right: (_) @operator.assign.right) @operator.assign

(unary_expression
  ["-" "!" "*"] @operator.unary.token
  (_) @operator.unary.operand) @operator.unary

(index_expression
  (_) @operator.index.base
  (_) @operator.index.key) @operator.index

(try_expression
  (_) @operator.try.value) @operator.try

; --- ownership_members ---

(enum_item
  name: (_) @owner.name
  body: (enum_variant_list
    (enum_variant
      name: (_) @owned.member.name) @owned.member)) @owner.span

(enum_variant
  name: (_) @owner.name
  body: (field_declaration_list
    (field_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(struct_item
  name: (_) @owner.name
  body: (field_declaration_list
    (field_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- ownership_parameters ---

(function_item
  name: (_) @owner.name
  parameters: (parameters
    (parameter) @owned.parameter)) @owner.span

(function_item
  name: (_) @owner.name
  parameters: (parameters
    (self_parameter) @owned.parameter)) @owner.span

(function_item
  name: (_) @owner.name
  parameters: (parameters
    (variadic_parameter) @owned.parameter)) @owner.span

(function_signature_item
  name: (_) @owner.name
  parameters: (parameters
    (parameter) @owned.parameter)) @owner.span

(function_signature_item
  name: (_) @owner.name
  parameters: (parameters
    (self_parameter) @owned.parameter)) @owner.span

(function_signature_item
  name: (_) @owner.name
  parameters: (parameters
    (variadic_parameter) @owned.parameter)) @owner.span

; --- path_origin_hints ---

(scoped_use_list path: [(self) (super) (crate)] @import.path_origin.root) @import.path_origin.statement

; --- provider_surface_enrichment ---

; Exact-compatible provider surface enrichment for grammar nodes not previously named by Omega semantic queries.
(escape_sequence) @surface.escape_sequence
(inner_doc_comment_marker) @surface.doc.inner_marker
(outer_doc_comment_marker) @surface.doc.outer_marker
(mutable_specifier) @surface.mutable_specifier
(type_parameters) @surface.type_parameters

; --- qualified_chain_hints ---

(scoped_identifier
  path: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(scoped_type_identifier
  path: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

; --- qualified_trait_impl_context ---

; Framework-neutral explicit fully-qualified Rust trait implementation.
; Only a scoped trait path and direct simple target type are captured. `use`
; resolution, aliases, generic target types and compiler trait solving remain out of scope.
(impl_item
  trait: (scoped_type_identifier) @rust.qualified_impl.trait_path
  type: (type_identifier) @rust.qualified_impl.type_name) @rust.qualified_impl.context

; --- receiver_hints ---

(self) @reference.receiver

(super) @reference.receiver

; --- reexport_hints ---

(use_declaration
  (visibility_modifier)
  argument: (_) @module.reexport.target
) @module.reexport.statement

; --- reference_roles_extended ---

; Additional exact syntactic reference/value/type roles required for complete
; Rust context accounting. These are context boundaries, not name-resolution claims.

(array_expression
  length: (_) @reference.role.array_repeat_length)
(array_expression
  (_) @reference.role.array_element)

(range_expression
  (_) @reference.role.range_bound)
(tuple_expression
  (_) @reference.role.tuple_element)
(parenthesized_expression
  (_) @reference.role.parenthesized_value)

(struct_expression
  name: (_) @reference.role.struct_constructor_type)
(field_initializer
  value: (_) @reference.role.struct_field_value)
(base_field_initializer
  (_) @reference.role.struct_update_base)

(await_expression
  (_) @reference.role.await_operand)
(try_expression
  (_) @reference.role.try_operand)
(break_expression
  (_) @reference.role.break_target_or_value)

(generic_type
  type: (_) @reference.role.generic_base_type
  type_arguments: (_) @reference.role.generic_argument_list)
(generic_function
  function: (_) @reference.role.generic_callable
  type_arguments: (_) @reference.role.generic_argument_list)

(where_predicate
  left: (_) @reference.role.where_predicate_subject
  bounds: (_) @reference.role.where_predicate_bound)

(function_item
  return_type: (_) @reference.role.return_type_position)
(function_signature_item
  return_type: (_) @reference.role.return_type_position)
(closure_expression
  return_type: (_) @reference.role.return_type_position)
(field_declaration
  type: (_) @reference.role.field_type_position)
(const_item
  type: (_) @reference.role.field_type_position)
(static_item
  type: (_) @reference.role.field_type_position)
(type_item
  type: (_) @reference.role.field_type_position)
(let_declaration
  type: (_) @reference.role.field_type_position)

(const_parameter
  value: (_) @reference.role.const_parameter_value)

(use_declaration
  argument: (_) @reference.role.import_selector)
(use_as_clause
  path: (_) @reference.role.import_selector)

(macro_invocation
  macro: (_) @reference.role.macro_path)

(impl_item
  trait: (_) @reference.role.trait_or_impl_type)
(impl_item
  type: (_) @reference.role.trait_or_impl_type)
(trait_item
  bounds: (_) @reference.role.trait_bound)
(type_parameter
  bounds: (_) @reference.role.trait_bound)
(type_parameter
  default_type: (_) @reference.role.type_default)
(associated_type
  bounds: (_) @reference.role.trait_bound)
(lifetime_parameter
  bounds: (_) @reference.role.lifetime_bound)

; --- reference_roles_rust_specific ---

; Rust-specific syntactic reference roles that are easy to lose if all
; identifier-like nodes are treated as one generic reference candidate.

(shorthand_field_initializer
  (identifier) @reference.role.field_shorthand_value)

(reference_type
  (lifetime) @reference.role.lifetime_reference)
(self_parameter
  (lifetime) @reference.role.lifetime_reference)
(bounded_type
  (lifetime) @reference.role.lifetime_reference)
(use_bounds
  (lifetime) @reference.role.lifetime_reference)
(trait_bounds
  (lifetime) @reference.role.lifetime_reference)
(type_arguments
  (lifetime) @reference.role.lifetime_reference)

(type_arguments
  [(_literal) (block)] @reference.role.const_generic_argument)

(visibility_modifier
  [(crate) (identifier) (metavariable) (scoped_identifier) (self) (super)] @reference.role.visibility_path)

(attribute
  [(crate) (identifier) (metavariable) (scoped_identifier) (self) (super)] @reference.role.attribute_path)

(match_pattern
  condition: (_) @reference.role.match_guard_condition)

(token_tree
  (metavariable) @reference.role.macro_metavariable_use)

; --- reference_roles ---

; Explicit syntactic reference-role boundaries. These captures complement the
; broad reference candidate query; rules join nested reference candidates to
; the nearest captured role boundary without pretending name resolution.

(call_expression
  function: (_) @reference.role.callee)

(call_expression
  arguments: (arguments
    (_) @reference.role.argument))

(field_expression
  value: (_) @reference.role.receiver
  field: (field_identifier) @reference.role.member)

(assignment_expression
  left: (_) @reference.role.assignment_lhs
  right: (_) @reference.role.assignment_rhs)

(compound_assignment_expr
  left: (_) @reference.role.assignment_lhs
  right: (_) @reference.role.assignment_rhs)

(binary_expression
  left: (_) @reference.role.binary_operand
  right: (_) @reference.role.binary_operand)

(type_cast_expression
  value: (_) @reference.role.cast_value
  type: (_) @reference.role.type_position)

(reference_expression
  value: (_) @reference.role.borrowed_value)

(return_expression
  (_) @reference.role.return_value)

(yield_expression
  (_) @reference.role.yield_value)

(if_expression
  condition: (_) @reference.role.condition)

(while_expression
  condition: (_) @reference.role.condition)

(for_expression
  pattern: (_) @reference.role.pattern_position
  value: (_) @reference.role.iterator_value)

(let_condition
  pattern: (_) @reference.role.pattern_position
  value: (_) @reference.role.condition_value)

(match_expression
  value: (_) @reference.role.match_scrutinee)

(match_arm
  pattern: (_) @reference.role.pattern_position
  value: (_) @reference.role.match_arm_value)

(field_initializer
  field: (field_identifier) @reference.role.member
  value: (_) @reference.role.initializer)

(let_declaration
  pattern: (_) @reference.role.pattern_position
  value: (_) @reference.role.initializer)

(parameter
  pattern: (_) @reference.role.pattern_position
  type: (_) @reference.role.type_position)

; --- references ---

; Exhaustive candidate pass. Role filtering removes definition/binding/import-name spans,
; while retaining value, type, field, path and lifetime references in every expression form.
(identifier) @reference.identifier.candidate
(type_identifier) @reference.type.candidate
(field_identifier) @reference.field.candidate
(shorthand_field_identifier) @reference.field_shorthand.candidate
(scoped_identifier) @reference.path.candidate
(scoped_type_identifier) @reference.type_path.candidate
(lifetime) @reference.lifetime.candidate
(self) @reference.self
(super) @reference.super
(crate) @reference.crate

; --- scope_control_fields ---

; Exact body/branch field selectors whose containment changes scopes/control ownership.
(foreign_mod_item body: (_) @field.body.foreign_module)
(enum_variant body: (_) @field.body.enum_variant)
(impl_item body: (_) @field.body.impl)
(trait_item body: (_) @field.body.trait)
(closure_expression body: (_) @field.body.closure)
(let_declaration alternative: (_) @field.control.let_alternative)
(if_expression consequence: (_) @field.control.if_consequence)
(if_expression alternative: (_) @field.control.if_alternative)

; --- scoped_call_context ---

; Framework-neutral direct Rust scoped-call contexts.
; Two-segment call: root::member(...)
(call_expression
  function: (scoped_identifier
    path: (identifier) @rust.scoped_call.root
    name: (identifier) @rust.scoped_call.member) @rust.scoped_call.target) @rust.scoped_call.context

; Direct identifier binding to a four-segment scoped constructor call:
; let binding = root::module::Type::constructor(...);
(let_declaration
  pattern: (identifier) @rust.scoped_ctor.binding
  value: (call_expression
    function: (scoped_identifier
      path: (scoped_identifier
        path: (scoped_identifier
          path: (identifier) @rust.scoped_ctor.root
          name: (identifier) @rust.scoped_ctor.module)
        name: (identifier) @rust.scoped_ctor.type_name)
      name: (identifier) @rust.scoped_ctor.constructor) @rust.scoped_ctor.target) @rust.scoped_ctor.call) @rust.scoped_ctor.context

; --- scopes ---

(source_file) @scope.file
(block) @scope.block
(closure_expression) @scope.closure
(match_arm) @scope.match_arm
(macro_definition) @scope.macro

; --- semantic_relations ---

; Explicit semantic relations preserved from the original Rust baseline and widened.
(impl_item
  trait: (_) @relation.implements.trait
  type: (_) @relation.implements.type) @relation.implements

; Candidate calls inside functions. Rule normalization joins the enclosing function
; with the test classification emitted by tests.json before emitting relation.tests.
(function_item
  name: (identifier) @relation.test.source
  body: (block
    (expression_statement
      (call_expression function: (_) @relation.test.target) @relation.test.call))) @relation.test.function

; Environment/config consumption with a statically extractable key.
(call_expression
  function: (scoped_identifier) @relation.config.function
  arguments: (arguments (string_literal) @relation.config.key)) @relation.config

; Returning an identifier is a directly observable data handoff.
(return_expression (identifier) @relation.data.return.value) @relation.data.return

; --- signature_parameters ---

(function_item
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(function_signature_item
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- signature_return_type ---

(function_item
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_signature_item
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- signature_type_parameters ---

(associated_type
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(enum_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(function_signature_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(struct_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(trait_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(type_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

(union_item
  name: (_) @definition.signature.name
  type_parameters: (_) @definition.signature.type_parameters
) @definition.signature.owner

; --- struct_derive_trait_context ---

; Framework-neutral Rust derive trait immediately bound to a struct declaration.
; Only direct identifier entries in #[derive(...)] are captured. Attribute aliases,
; proc-macro expansion, nested paths and derive semantics remain downstream.
((source_file
  (attribute_item
    (attribute
      (identifier) @rust.derive.attribute_path
      arguments: (token_tree
        (identifier) @rust.derive.trait_name)) @rust.derive.attribute) @rust.derive.attribute_item
  .
  (struct_item
    name: (type_identifier) @rust.derive.owner_struct) @rust.derive.struct)
  (#eq? @rust.derive.attribute_path "derive"))

; --- struct_field_string_attribute_context ---

; Framework-neutral Rust struct-field outer attribute with one direct key = "simple_name" item.
; Captures only authored source structure. Framework meaning is assigned later.
(struct_item
  name: (type_identifier) @rust.struct_field_string_attr.owner_struct
  body: (field_declaration_list
    (attribute_item
      (attribute
        (identifier) @rust.struct_field_string_attr.attribute_path
        arguments: (token_tree
          (identifier) @rust.struct_field_string_attr.attribute_key
          .
          (string_literal
            (string_content) @rust.struct_field_string_attr.target_name))) @rust.struct_field_string_attr.attribute)
    .
    (field_declaration
      name: (field_identifier) @rust.struct_field_string_attr.field_name) @rust.struct_field_string_attr.field))

; --- struct_named_attribute_context ---

; Framework-neutral owner-bound Rust struct attribute contexts.
; Strict subset: the matched outer attribute must be the immediately preceding named sibling of the struct.
;
; Examples:
;   #[diesel(table_name = users)]
;   struct User { id: i32 }
;
;   #[diesel(belongs_to(User))]
;   struct Post { user_id: i32 }
;
; The Pack records syntax only. Attribute/framework meaning and cross-file resolution remain downstream.

(source_file
  (attribute_item
    (attribute
      (identifier) @rust.struct_attr_assign.attribute_path
      arguments: (token_tree
        (identifier) @rust.struct_attr_assign.key
        (identifier) @rust.struct_attr_assign.value))) @rust.struct_attr_assign.attribute
  .
  (struct_item
    name: (type_identifier) @rust.struct_attr_assign.owner_struct) @rust.struct_attr_assign.struct)

(source_file
  (attribute_item
    (attribute
      (identifier) @rust.struct_attr_nested.attribute_path
      arguments: (token_tree
        (identifier) @rust.struct_attr_nested.directive
        (token_tree
          (identifier) @rust.struct_attr_nested.target_identifier))) @rust.struct_attr_nested.attribute)
  .
  (struct_item
    name: (type_identifier) @rust.struct_attr_nested.owner_struct) @rust.struct_attr_nested.struct)

; --- tests ---

; Primary test markers. These are captured independently from items; the rule
; contract associates only a contiguous outer-attribute chain on the same
; parent with the following function. This avoids relying on sibling-anchor
; query behavior for correctness.
; A function is a test when the attribute run immediately above it carries a
; primary test attribute, and a module is a test container when that run
; carries #[cfg(test)].
;
; The attributes used to be captured on their own, in patterns no template
; named, beside an unguarded `(function_item)` and an unguarded `(mod_item)`.
; Nothing joined them, so every function in the corpus was emitted as a test:
; 6 053 of them, in a repository with 1 258 `#[test]`. `find` answered a
; plain function twice, once as a test, and everything counted per test
; counted the whole corpus.
;
; The run is anchored on both sides, so the attribute belongs to the
; declaration below it rather than to any declaration below it. Auxiliary
; markers -- #[ignore], #[case] -- never make a test by themselves, which is
; what the intervening `(attribute_item)*` allows without matching on.

((source_file
   (attribute_item
     (attribute
       [(identifier) @test.primary.name
        (scoped_identifier name: (identifier) @test.primary.name)])) @test.primary.attribute
   .
   (attribute_item)*
   .
   (function_item
     name: [(identifier) (metavariable)] @test.function.name) @test.function.candidate)
 (#match? @test.primary.name "^(test|bench|rstest|test_case)$"))

((declaration_list
   (attribute_item
     (attribute
       [(identifier) @test.primary.name
        (scoped_identifier name: (identifier) @test.primary.name)])) @test.primary.attribute
   .
   (attribute_item)*
   .
   (function_item
     name: [(identifier) (metavariable)] @test.function.name) @test.function.candidate)
 (#match? @test.primary.name "^(test|bench|rstest|test_case)$"))

((source_file
   (attribute_item
     (attribute
       (identifier) @test.cfg.attribute
       arguments: (token_tree) @test.cfg.arguments)) @test.cfg.attribute_item
   .
   (attribute_item)*
   .
   (mod_item name: (identifier) @test.module.name) @test.module.candidate)
 (#eq? @test.cfg.attribute "cfg")
 (#match? @test.cfg.arguments "^\\(\\s*test\\s*\\)$"))

((declaration_list
   (attribute_item
     (attribute
       (identifier) @test.cfg.attribute
       arguments: (token_tree) @test.cfg.arguments)) @test.cfg.attribute_item
   .
   (attribute_item)*
   .
   (mod_item name: (identifier) @test.module.name) @test.module.candidate)
 (#eq? @test.cfg.attribute "cfg")
 (#match? @test.cfg.arguments "^\\(\\s*test\\s*\\)$"))

; --- three_segment_scoped_call_context ---

; Framework-neutral direct Rust three-segment scoped-call context.
; Captures only root::namespace::member(...); import aliases, deeper chains,
; method dispatch, macro expansion and runtime semantics remain unresolved.
(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      path: (identifier) @rust.three_scoped.root
      name: (identifier) @rust.three_scoped.namespace)
    name: (identifier) @rust.three_scoped.member) @rust.three_scoped.target) @rust.three_scoped.context

; --- trait_bounds ---

; Explicit Rust type-bound relations. These preserve syntactic ownership and
; bounded type/lifetime relationships without pretending to resolve traits.

(trait_item
  name: (_) @relation.trait_super.owner
  bounds: (_) @relation.trait_super.bound) @relation.trait_super

(type_parameter
  name: (_) @relation.type_parameter.owner
  bounds: (_) @relation.type_parameter.bound) @relation.type_parameter.bound_relation

(where_predicate
  left: (_) @relation.where.subject
  bounds: (_) @relation.where.bound) @relation.where.bound_relation

(associated_type
  name: (_) @relation.associated_type.owner
  bounds: (_) @relation.associated_type.bound) @relation.associated_type.bound_relation

(lifetime_parameter
  name: (_) @relation.lifetime.owner
  bounds: (_) @relation.lifetime.bound) @relation.lifetime.bound_relation

; --- types ---

(parameter type: (_) @type.annotation.parameter) @type.owner.parameter
(let_declaration type: (_) @type.annotation.let) @type.owner.let
(field_declaration type: (_) @type.annotation.field) @type.owner.field
(ordered_field_declaration_list type: (_) @type.annotation.tuple_field) @type.owner.tuple_field
(const_item type: (_) @type.annotation.const) @type.owner.const
(static_item type: (_) @type.annotation.static) @type.owner.static
(function_item return_type: (_) @type.return.function) @type.owner.function
(function_signature_item return_type: (_) @type.return.signature) @type.owner.signature
(closure_expression return_type: (_) @type.return.closure) @type.owner.closure
(type_item type: (_) @type.alias.target) @type.owner.alias
(const_parameter type: (_) @type.annotation.const_parameter) @type.owner.const_parameter
(type_parameter) @type.parameter
(lifetime_parameter) @type.lifetime_parameter
(where_predicate left: (_) @type.where.subject bounds: (trait_bounds) @type.where.bounds) @type.where.predicate
(impl_item type: (_) @type.impl.target) @type.impl
(impl_item trait: (_) @type.impl.trait type: (_) @type.impl.target) @type.impl.trait_for
(trait_item bounds: (trait_bounds) @type.trait.bounds) @type.owner.trait
(type_cast_expression type: (_) @type.cast.target) @type.cast
(reference_type) @type.reference
(pointer_type) @type.pointer
(array_type) @type.array
(tuple_type) @type.tuple
(function_type) @type.function
(generic_type) @type.generic
(scoped_type_identifier) @type.path
(dynamic_type) @type.dynamic
(abstract_type) @type.impl_trait
(qualified_type) @type.qualified
(type_binding) @type.associated_binding
(bracketed_type) @type.bracketed
(generic_type_with_turbofish) @type.generic_turbofish
(bounded_type) @type.bounded
(use_bounds) @type.use_bounds
(never_type) @type.never
(primitive_type) @type.primitive
(higher_ranked_trait_bound) @type.higher_ranked_bound
(removed_trait_bound) @type.removed_trait_bound
(for_lifetimes) @type.for_lifetimes

(type_parameter
  bounds: (trait_bounds) @type.parameter.bounds) @type.parameter.with_bounds

(type_parameter
  default_type: (_) @type.parameter.default) @type.parameter.with_default

(lifetime_parameter
  bounds: (trait_bounds) @type.lifetime.bounds) @type.lifetime.with_bounds

(associated_type
  bounds: (trait_bounds) @type.associated.bounds) @type.associated.with_bounds

; --- value_origins ---

; Explicit value-origin relations retained for downstream provenance/retrieval.
(let_declaration
  pattern: (identifier) @origin.binding
  value: (struct_expression name: (_) @origin.struct.type)) @origin.struct

(let_declaration
  pattern: (identifier) @origin.binding
  value: (call_expression function: (_) @origin.call.target)) @origin.call

(let_declaration
  pattern: (identifier) @origin.binding
  value: (identifier) @origin.alias.source) @origin.alias

; Destructuring still has a value source even when there is no single local name.
(let_declaration
  pattern: [(tuple_pattern) (struct_pattern) (slice_pattern)] @origin.pattern
  value: (_) @origin.pattern.source) @origin.destructure

; --- visibility ---

(struct_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(enum_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(union_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(type_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(function_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(mod_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(use_declaration (visibility_modifier) @definition.visibility) @definition.visibility.owner
(const_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(static_item (visibility_modifier) @definition.visibility) @definition.visibility.owner
(trait_item (visibility_modifier) @definition.visibility) @definition.visibility.owner

; --- framework_neutral_rust_receiver_methods_v1 ---

(call_expression
  function: (field_expression
    value: (identifier) @rust.receiver_id.receiver
    field: (field_identifier) @rust.receiver_id.method)
  arguments: (arguments
    (identifier) @rust.receiver_id.arg0)) @rust.receiver_id.context

(call_expression
  function: (field_expression
    value: (identifier) @rust.receiver_string_id.receiver
    field: (field_identifier) @rust.receiver_string_id.method)
  arguments: (arguments
    (string_literal) @rust.receiver_string_id.arg0_string
    (identifier) @rust.receiver_string_id.arg1_identifier)) @rust.receiver_string_id.context

(call_expression
  function: (field_expression
    value: (identifier) @rust.receiver_route.receiver
    field: (field_identifier) @rust.receiver_route.method)
  arguments: (arguments
    (string_literal) @rust.receiver_route.path_literal
    (call_expression
      function: (identifier) @rust.receiver_route.wrapper
      arguments: (arguments
        (identifier) @rust.receiver_route.handler)))) @rust.receiver_route.context

(call_expression
  function: (field_expression
    value: (identifier) @rust.receiver_noarg.receiver
    field: (field_identifier) @rust.receiver_noarg.method)
  arguments: (arguments)) @rust.receiver_noarg.context


; --- rust_derive_owner_generalized_v1 ---
; Direct #[derive(...)] trait items bound to a following struct or enum declaration,
; allowing intervening outer attributes. This is authored syntax only.
((source_file
  (attribute_item
    (attribute
      (identifier) @rust.derive.general.attribute_path
      arguments: (token_tree
        (identifier) @rust.derive.general.trait_name)) @rust.derive.general.attribute) @rust.derive.general.attribute_item
  .
  (attribute_item)*
  .
  (struct_item name: (type_identifier) @rust.derive.general.owner) @rust.derive.general.declaration)
  (#eq? @rust.derive.general.attribute_path "derive"))

((source_file
  (attribute_item
    (attribute
      (identifier) @rust.derive.general.attribute_path
      arguments: (token_tree
        (identifier) @rust.derive.general.trait_name)) @rust.derive.general.attribute) @rust.derive.general.attribute_item
  .
  (attribute_item)*
  .
  (enum_item name: (type_identifier) @rust.derive.general.owner) @rust.derive.general.declaration)
  (#eq? @rust.derive.general.attribute_path "derive"))
