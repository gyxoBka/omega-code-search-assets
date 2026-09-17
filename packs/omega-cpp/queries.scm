; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- completeness_modules_3 ---

(namespace_definition) @module.expression
(module_declaration) @module.expression

; --- completeness_types_high_confidence ---

(type_definition) @type.expression

; --- declaration_category_class ---

(class_specifier
  name: (_) @definition.category.class.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_specifier
  name: (_) @definition.category.enum.name
) @definition.category.owner

(enumerator
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_function ---

(preproc_function_def
  name: (_) @definition.category.function.name
) @definition.category.owner

(template_function
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- declaration_category_method ---

(template_method
  name: (_) @definition.category.method.name
) @definition.category.owner

; --- declaration_category_module ---

(module_declaration
  name: (_) @definition.category.module.name @definition.identity.name @module.declaration_path.name
) @definition.category.owner @definition.identity.owner @module.declaration_path.span

; --- declaration_category_namespace ---

(namespace_alias_definition
  name: (_) @definition.category.namespace.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(namespace_definition
  name: (_) @definition.category.namespace.name @definition.identity.name @module.declaration_path.name
) @definition.category.owner @definition.identity.owner @module.declaration_path.span

; --- declaration_category_struct ---

(struct_specifier
  name: (_) @definition.category.struct.name
) @definition.category.owner

; --- declaration_category_type ---

(optional_type_parameter_declaration
  name: (_) @definition.category.type.name
) @definition.category.owner

; --- declaration_category_union ---

(union_specifier
  name: (_) @definition.category.union.name
) @definition.category.owner

; --- definition_identity_hints ---





; --- direct_and_member_call_site_context ---

(call_expression
  function: (identifier) @cpp.direct_call.name
  arguments: (argument_list) @cpp.direct_call.arguments) @cpp.direct_call.context

(call_expression
  function: (field_expression
    field: (field_identifier) @cpp.member_call.member)
  arguments: (argument_list) @cpp.member_call.arguments) @cpp.member_call.context

; --- enclosing_owner_hints ---

(class_specifier 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(namespace_definition 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(struct_specifier 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=cpp kind=tags
; original baseline: audit-baselines/external/helix/cpp/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(function_declarator
  declarator: [(identifier) (field_identifier)] @definition.function)
(preproc_function_def name: (identifier) @definition.function @local.definition.macro) @local.scope

(preproc_def name: (identifier) @definition.constant @local.definition.macro)
(type_definition declarator: (type_identifier) @definition.type @local.definition.type @name) @definition.type

(struct_specifier
  name: (type_identifier) @definition.struct @local.definition.type)
(enum_specifier name: (type_identifier) @definition.enum @name) @definition.type

(union_specifier
  name: (type_identifier) @definition.struct)
(function_declarator declarator: (qualified_identifier name: (identifier) @definition.function @local.definition.function)) @local.scope

(class_specifier
  name: (type_identifier) @definition.class
  body: (field_declaration_list))

(namespace_definition
  name: (namespace_identifier) @definition.module)

(concept_definition
  name: (identifier) @definition.interface @local.definition.type)

(alias_declaration
  name: (type_identifier) @definition.type @local.definition.type)
(function_declarator declarator: (identifier) @local.definition.function @name) @definition.function


(pointer_declarator
  declarator: (identifier) @local.definition.var)

(parameter_declaration
  declarator: (identifier) @local.definition.parameter)

(init_declarator
  declarator: (identifier) @local.definition.var)

(array_declarator
  declarator: (identifier) @local.definition.var)

(declaration
  declarator: (identifier) @local.definition.var)

(enum_specifier
  name: (_) @local.definition.type
  (enumerator_list
    (enumerator
      name: (identifier) @local.definition.var)))

; Type / Struct / Enum
(field_declaration
  declarator: (field_identifier) @local.definition.field)



; goto
(labeled_statement
  (statement_identifier) @local.definition)

; References
(identifier) @local.reference

((field_identifier) @local.reference
  (#set! reference.kind "field"))

((type_identifier) @local.reference
  (#set! reference.kind "type"))

(goto_statement
  (statement_identifier) @local.reference)

; Scope
[
  (for_statement)
  (if_statement)
  (while_statement)
  (translation_unit)
  (function_definition)
  (compound_statement) ; a block in curly braces
  (struct_specifier)
] @local.scope
; Parameters
(variadic_parameter_declaration
  declarator: (variadic_declarator
    (identifier) @local.definition.parameter @local.definition.variable.parameter))

(optional_parameter_declaration
  declarator: (identifier) @local.definition.parameter @local.definition.variable.parameter)

; Class / struct definitions
(class_specifier) @local.scope

(reference_declarator
  (identifier) @local.definition.var)

(variadic_declarator
  (identifier) @local.definition.var)

(struct_specifier
  name: (qualified_identifier
    name: (type_identifier) @local.definition.type))
(class_specifier name: (type_identifier) @local.definition.type @name) @definition.class


(class_specifier
  name: (qualified_identifier
    name: (type_identifier) @local.definition.type))


;template <typename T>
(type_parameter_declaration
  (type_identifier) @local.definition.type)

(template_declaration) @local.scope

; Namespaces
(namespace_definition
  name: (namespace_identifier) @local.definition.namespace
  body: (_) @local.scope)

(namespace_definition
  name: (nested_namespace_specifier) @local.definition.namespace
  body: (_) @local.scope)

((namespace_identifier) @local.reference
  (#set! reference.kind "namespace"))

; Function definitions
(template_function
  name: (identifier) @local.definition.function) @local.scope

(template_method
  name: (field_identifier) @local.definition.method) @local.scope

(field_declaration
  declarator: (function_declarator
    (field_identifier) @local.definition.method))

(lambda_expression) @local.scope

; Control structures
(try_statement
  body: (_) @local.scope)

(catch_clause) @local.scope

(requires_expression) @local.scope

; --- identifier_string_call_context ---

; Framework-neutral direct C++ call/macro-like invocation with identifier arg1 + plain string arg2.
; Example source shape: TEST_CASE_METHOD(Fixture, "name", "[tag]").
; Macro expansion and framework lifecycle interpretation remain downstream.

(call_expression
  function: (identifier) @cpp.identifier_string_call.call_name
  arguments: (argument_list
    (identifier) @cpp.identifier_string_call.arg1
    (string_literal
      (string_content) @cpp.identifier_string_call.arg2)) @cpp.identifier_string_call.arguments
) @cpp.identifier_string_call.context

; --- import_targets ---

(import_declaration
  name: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

(preproc_include
  path: (_) @import.target @import.module_path.target @import.path) @import.statement @import.module_path.statement @import.include

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: inherited c
; path=audit-baselines/external/nvim-treesitter/c/locals.scm
; sha256=b3ecf04dadb49555af03644686fb68c3ce3ccfd98af33f003371beb5a37652b0
; Functions definitions









; Type / Struct / Enum



; goto

; References

((field_identifier) @local.reference
  (#set! reference.kind "field"))

((type_identifier) @local.reference
  (#set! reference.kind "type"))


; Scope

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/cpp/locals.scm
; sha256=7047179aee75f5e85b0fadd1da4a1856b32d68d6694952738a257ca13a5e4a52
; inherits: c

; Parameters


; Class / struct definitions








;template <typename T>


; Namespaces


((namespace_identifier) @local.reference
  (#set! reference.kind "namespace"))

; Function definitions





; Control structures



; --- member_access_hints ---

(field_expression
  argument: (_) @reference.receiver
  field: (_) @reference.member) @reference.member_expression

; --- member_category_enum ---

(enum_specifier
  name: (_) @owner.name
  body: (enumerator_list
    (enumerator
      name: (_) @owned.member_category.enum.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_function ---

(class_specifier
  name: (_) @owner.name
  body: (field_declaration_list
    (preproc_function_def
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

(namespace_definition
  name: (_) @owner.name
  body: (declaration_list
    (preproc_function_def
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

(struct_specifier
  name: (_) @owner.name
  body: (field_declaration_list
    (preproc_function_def
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

; --- module_declaration_path_hints ---



; --- module_path_hints ---



; --- named_scope_owners ---




; --- ownership_members ---

(class_specifier
  name: (_) @owner.name
  body: (field_declaration_list
    (alias_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span



(namespace_definition
  name: (_) @owner.name
  body: (declaration_list
    (alias_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(namespace_definition
  name: (_) @owner.name
  body: (declaration_list
    (concept_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span

(namespace_definition
  name: (_) @owner.name
  body: (declaration_list
    (namespace_alias_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span

(namespace_definition
  name: (_) @owner.name
  body: (declaration_list
    (namespace_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span


(struct_specifier
  name: (_) @owner.name
  body: (field_declaration_list
    (alias_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span


; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=cpp file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/cpp/locals.scm

;; Scopes
(function_definition) @local.scope
(declaration) @local.scope

;; Definitions

; Parameters
; Up to 6 layers of declarators
(parameter_declaration
  (identifier) @local.definition.variable.parameter)
(parameter_declaration
  (_
    (identifier) @local.definition.variable.parameter))
(parameter_declaration
  (_
    (_
      (identifier) @local.definition.variable.parameter)))
(parameter_declaration
  (_
    (_
      (_
        (identifier) @local.definition.variable.parameter))))
(parameter_declaration
  (_
    (_
      (_
        (_
          (identifier) @local.definition.variable.parameter)))))
(parameter_declaration
  (_
    (_
      (_
        (_
          (_
            (identifier) @local.definition.variable.parameter))))))

;; References


; A call's function name is not a variable reference; keep its class
; even when a same-named local is in scope.
(call_expression
  function: (identifier) @_)
; C++-specific scopes on top of c's function_definition / declaration scopes.
[
  (lambda_expression)
  (namespace_definition)
  (class_specifier)
  (for_range_loop)
] @local.scope

; C++-only parameter forms (c only has parameter_declaration).

; Template type parameters.

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=cpp file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/cpp/tags.scm












; --- qualified_chain_hints ---

(attribute
  namespace: (_) @reference.qualified_chain.base
  name: (_) @reference.qualified_chain.leaf
) @reference.qualified_chain.span

(qualified_identifier
  scope: (_) @reference.qualified_chain.base @reference.qualifier
  name: (_) @reference.qualified_chain.leaf @reference.qualified_name
) @reference.qualified_chain.span @reference.qualified_expression

; --- qualified_name_hints ---


; --- receiver_hints ---

(this) @reference.receiver

; --- reexport_hints ---

(export_declaration
  (import_declaration
    name: (_) @module.reexport.target)) @module.reexport.statement

(export_declaration
  (import_declaration
    header: (_) @module.reexport.target)) @module.reexport.statement

; --- signature_parameters ---

(preproc_function_def
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- static_delta ---

(call_expression) @call.expression


(import_declaration) @import.module

(base_class_clause (_) @relation.base) @relation.inherits

; --- string_literal_call_context ---

; Framework-neutral direct C++ call/macro-like invocation with a plain first string literal.
; Example syntactic shapes include TEST_CASE("name", "[tag]") and SECTION("name").
; Macro expansion and framework interpretation remain downstream.

(call_expression
  function: (identifier) @cpp.string_call.call_name
  arguments: (argument_list
    (string_literal
      (string_content) @cpp.string_call.arg1)) @cpp.string_call.arguments) @cpp.string_call.context

; --- two_identifier_call_context ---

(call_expression
  function: (identifier) @cpp.two_identifier_call.call_name
  arguments: (argument_list
    (identifier) @cpp.two_identifier_call.arg1
    (identifier) @cpp.two_identifier_call.arg2) @cpp.two_identifier_call.arguments) @cpp.two_identifier_call.context

; --- upstream_tags ---

(struct_specifier name: (type_identifier) @name body:(_)) @definition.class

(declaration type: (union_specifier name: (type_identifier) @name)) @definition.class

(function_declarator declarator: (field_identifier) @name) @definition.function

(function_declarator declarator: (qualified_identifier scope: (namespace_identifier) @local.scope name: (identifier) @name)) @definition.method

; --- semantic_closure_v3_146_cpp ---
(concept_definition
  name: (identifier) @cpp.concept.name
  (_) @cpp.concept.constraint) @cpp.concept.context

(requires_clause
  constraint: (_) @cpp.requires.constraint) @cpp.requires.context

(requires_expression
  parameters: (parameter_list)? @cpp.requires_expression.parameters
  requirements: (requirement_seq) @cpp.requires_expression.requirements) @cpp.requires_expression.context

(lambda_expression
  captures: (lambda_capture_specifier) @cpp.lambda.captures
  declarator: (lambda_declarator)? @cpp.lambda.declarator
  template_parameters: (template_parameter_list)? @cpp.lambda.template_parameters
  constraint: (requires_clause)? @cpp.lambda.constraint
  body: (compound_statement) @cpp.lambda.body) @cpp.lambda.context

(template_declaration
  parameters: (template_parameter_list) @cpp.template.parameters) @cpp.template.context

(template_instantiation
  declarator: (_) @cpp.template_instantiation.declarator) @cpp.template_instantiation.context

(function_declarator
  declarator: (destructor_name
    (identifier) @cpp.destructor.name)) @cpp.destructor.context

(function_declarator
  declarator: (operator_name) @cpp.operator.name) @cpp.operator.context

(function_definition
  declarator: (operator_cast
    type: (_) @cpp.operator_cast.type
    declarator: (_) @cpp.operator_cast.declarator)) @cpp.operator_cast.context


; --- semantic_closure_v3_146_cpp_macro_adjacency ---

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_type.macro_name
      arguments: (argument_list) @cpp.adjmacro_type.arguments) @cpp.adjmacro_type.macro_call) @cpp.adjmacro_type.macro_stmt
  .
  (declaration
    type: (class_specifier
      name: (_) @cpp.adjmacro_type.owner_name) @cpp.adjmacro_type.owner_decl) @cpp.adjmacro_type.declaration) @cpp.adjmacro_type.context

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_struct.macro_name
      arguments: (argument_list) @cpp.adjmacro_struct.arguments) @cpp.adjmacro_struct.macro_call) @cpp.adjmacro_struct.macro_stmt
  .
  (declaration
    type: (struct_specifier
      name: (_) @cpp.adjmacro_struct.owner_name) @cpp.adjmacro_struct.owner_decl) @cpp.adjmacro_struct.declaration) @cpp.adjmacro_struct.context

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_enum.macro_name
      arguments: (argument_list) @cpp.adjmacro_enum.arguments) @cpp.adjmacro_enum.macro_call) @cpp.adjmacro_enum.macro_stmt
  .
  (declaration
    type: (enum_specifier
      name: (_) @cpp.adjmacro_enum.owner_name) @cpp.adjmacro_enum.owner_decl) @cpp.adjmacro_enum.declaration) @cpp.adjmacro_enum.context

(class_specifier
  name: (_) @cpp.adjmacro_member.owner_name
  body: (field_declaration_list
    (declaration
      declarator: (function_declarator
        declarator: (identifier) @cpp.adjmacro_member.macro_name
        parameters: (parameter_list) @cpp.adjmacro_member.arguments) @cpp.adjmacro_member.macro_call) @cpp.adjmacro_member.macro_stmt
    .
    (field_declaration) @cpp.adjmacro_member.member_decl)) @cpp.adjmacro_member.context

(struct_specifier
  name: (_) @cpp.adjmacro_smember.owner_name
  body: (field_declaration_list
    (declaration
      declarator: (function_declarator
        declarator: (identifier) @cpp.adjmacro_smember.macro_name
        parameters: (parameter_list) @cpp.adjmacro_smember.arguments) @cpp.adjmacro_smember.macro_call) @cpp.adjmacro_smember.macro_stmt
    .
    (field_declaration) @cpp.adjmacro_smember.member_decl)) @cpp.adjmacro_smember.context


; --- semantic_closure_v3_146_unreal_macro_argument_items ---

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_arg_type.macro_name
      arguments: (argument_list
        (_) @cpp.adjmacro_arg_type.argument)) @cpp.adjmacro_arg_type.macro_call) @cpp.adjmacro_arg_type.macro_stmt
  .
  (declaration
    type: (class_specifier
      name: (_) @cpp.adjmacro_arg_type.owner_name) @cpp.adjmacro_arg_type.owner_decl) @cpp.adjmacro_arg_type.declaration) @cpp.adjmacro_arg_type.context

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_arg_struct.macro_name
      arguments: (argument_list
        (_) @cpp.adjmacro_arg_struct.argument)) @cpp.adjmacro_arg_struct.macro_call) @cpp.adjmacro_arg_struct.macro_stmt
  .
  (declaration
    type: (struct_specifier
      name: (_) @cpp.adjmacro_arg_struct.owner_name) @cpp.adjmacro_arg_struct.owner_decl) @cpp.adjmacro_arg_struct.declaration) @cpp.adjmacro_arg_struct.context

(translation_unit
  (expression_statement
    (call_expression
      function: (identifier) @cpp.adjmacro_arg_enum.macro_name
      arguments: (argument_list
        (_) @cpp.adjmacro_arg_enum.argument)) @cpp.adjmacro_arg_enum.macro_call) @cpp.adjmacro_arg_enum.macro_stmt
  .
  (declaration
    type: (enum_specifier
      name: (_) @cpp.adjmacro_arg_enum.owner_name) @cpp.adjmacro_arg_enum.owner_decl) @cpp.adjmacro_arg_enum.declaration) @cpp.adjmacro_arg_enum.context

(class_specifier
  name: (_) @cpp.adjmacro_arg_member.owner_name
  body: (field_declaration_list
    (declaration
      declarator: (function_declarator
        declarator: (identifier) @cpp.adjmacro_arg_member.macro_name
        parameters: (parameter_list
          (_) @cpp.adjmacro_arg_member.argument)) @cpp.adjmacro_arg_member.macro_call) @cpp.adjmacro_arg_member.macro_stmt
    .
    (field_declaration) @cpp.adjmacro_arg_member.member_decl)) @cpp.adjmacro_arg_member.context

(struct_specifier
  name: (_) @cpp.adjmacro_arg_smember.owner_name
  body: (field_declaration_list
    (declaration
      declarator: (function_declarator
        declarator: (identifier) @cpp.adjmacro_arg_smember.macro_name
        parameters: (parameter_list
          (_) @cpp.adjmacro_arg_smember.argument)) @cpp.adjmacro_arg_smember.macro_call) @cpp.adjmacro_arg_smember.macro_stmt
    .
    (field_declaration) @cpp.adjmacro_arg_smember.member_decl)) @cpp.adjmacro_arg_smember.context
