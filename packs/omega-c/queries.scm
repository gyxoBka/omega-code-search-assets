; --- aggregates ---

(struct_specifier name: (type_identifier)? @aggregate.struct.name body: (field_declaration_list)? @aggregate.struct.body) @aggregate.struct
(union_specifier name: (type_identifier)? @aggregate.union.name body: (field_declaration_list)? @aggregate.union.body) @aggregate.union
(enum_specifier name: (type_identifier)? @aggregate.enum.name body: (enumerator_list)? @aggregate.enum.body) @aggregate.enum
(enumerator name: (identifier) @definition.enumerator.name value: (_)? @definition.enumerator.value) @definition.enumerator
(preproc_include path: (_) @test.include @import.target @module.include.path @import.module_path.target @preproc.include.path) @import.statement @module.include @import.module_path.statement @preproc.include
(call_expression function: (identifier) @test.call.name @concurrency.call.name @call.direct.name) @test.call @concurrency.call @call.direct

; --- atomic_threading ---

(type_qualifier) @concurrency.qualifier @modifier.type_qualifier

; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls_indirect ---

(call_expression function: (field_expression) @call.member.target) @call.member
(call_expression function: (pointer_expression) @call.pointer.target) @call.pointer

; --- calls ---

(call_expression function: (_) @call.target arguments: (argument_list) @call.arguments) @call

; --- comments ---

(comment) @comment

; --- complex_numbers ---

(primitive_type) @type.numeric @type.primitive

; --- compound_designators ---

(initializer_pair designator: (_) @init.designator value: (_) @init.designated.value) @init.designated

; --- control_flow ---

(if_statement condition: (_) @control.if.condition) @control.if
(switch_statement condition: (_) @control.switch.condition) @control.switch
(case_statement value: (_)? @control.case.value) @control.case
(while_statement condition: (_) @control.while.condition) @control.while
(do_statement condition: (_) @control.do.condition) @control.do
(for_statement) @control.for @scope.for
(return_statement (_) ? @control.return.value @data.return.value) @control.return @data.return
(goto_statement label: (statement_identifier) @control.goto.label @reference.label) @control.goto
(labeled_statement label: (statement_identifier) @definition.label.name @definition.label) @definition.label
(break_statement) @control.break
(continue_statement) @control.continue

; --- data_flow ---

(assignment_expression left: (_) @data.write.target right: (_) @data.write.value) @data.write
(init_declarator declarator: (_) @data.init.target @binding.name @init.target value: (_) @data.init.value @binding.initializer @init.value) @data.init @binding.initialized @init

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

; --- declaration_category_macro ---

(macro_type_specifier
  name: (_) @definition.category.macro.name
) @definition.category.owner

; --- declaration_category_struct ---

(struct_specifier
  name: (_) @definition.category.struct.name
) @definition.category.owner

; --- declaration_category_union ---

(union_specifier
  name: (_) @definition.category.union.name
) @definition.category.owner

; --- declarations ---

(declaration type: (_) @declaration.type declarator: (_) @declaration.declarator) @declaration
(parameter_declaration type: (_) @parameter.type declarator: (_) @parameter.name) @parameter

; --- definition_identity_hints ---

; --- definitions ---

(function_definition declarator: (function_declarator declarator: (identifier) @definition.function.name)) @definition.function
(type_definition declarator: (type_identifier) @definition.typedef.name) @definition.typedef
(struct_specifier name: (type_identifier) @definition.struct.name) @definition.struct
(union_specifier name: (type_identifier) @definition.union.name) @definition.union
(enum_specifier name: (type_identifier) @definition.enum.name) @definition.enum
(field_declaration declarator: (_) @definition.field.name) @definition.field

; --- embedded_regions ---

; Omega mature-pack enrichment from exact-compatible Neovim distributed injection baseline
; original=packs/omega-c/third_party/neovim-distributed/queries/injections.scm
; retained third-party baseline/LICENSE remains under third_party/neovim-distributed

((preproc_arg) @injection.content
  (#set! injection.self))

((comment) @injection.content
  (#set! injection.language "comment"))

((comment) @injection.content
  (#match? @injection.content "/\\*!([a-zA-Z]+:)?re2c")
  (#set! injection.language "re2c"))

((comment) @injection.content
  (#match? @injection.content "/[*/][!*/]<?[^a-zA-Z]")
  (#set! injection.language "doxygen"))

((call_expression
  function: (identifier) @_function
  arguments: (argument_list
    .
    [
      (string_literal
        (string_content) @injection.content)
      (concatenated_string
        (string_literal
          (string_content) @injection.content))
    ]))
  ; format-ignore
  (#any-of? @_function 
    "printf" "printf_s"
    "vprintf" "vprintf_s"
    "scanf" "scanf_s"
    "vscanf" "vscanf_s"
    "wprintf" "wprintf_s"
    "vwprintf" "vwprintf_s"
    "wscanf" "wscanf_s"
    "vwscanf" "vwscanf_s"
    "cscanf" "_cscanf"
    "printw"
    "scanw")
  (#set! injection.language "printf"))

((call_expression
  function: (identifier) @_function
  arguments: (argument_list
    (_)
    .
    [
      (string_literal
        (string_content) @injection.content)
      (concatenated_string
        (string_literal
          (string_content) @injection.content))
    ]))
  ; format-ignore
  (#any-of? @_function 
    "fprintf" "fprintf_s"
    "sprintf"
    "dprintf"
    "fscanf" "fscanf_s"
    "sscanf" "sscanf_s"
    "vsscanf" "vsscanf_s"
    "vfprintf" "vfprintf_s"
    "vsprintf"
    "vdprintf"
    "fwprintf" "fwprintf_s"
    "vfwprintf" "vfwprintf_s"
    "fwscanf" "fwscanf_s"
    "swscanf" "swscanf_s"
    "vswscanf" "vswscanf_s"
    "vfscanf" "vfscanf_s"
    "vfwscanf" "vfwscanf_s"
    "wprintw"
    "vw_printw" "vwprintw"
    "wscanw"
    "vw_scanw" "vwscanw")
  (#set! injection.language "printf"))

((call_expression
  function: (identifier) @_function
  arguments: (argument_list
    (_)
    .
    (_)
    .
    [
      (string_literal
        (string_content) @injection.content)
      (concatenated_string
        (string_literal
          (string_content) @injection.content))
    ]))
  ; format-ignore
  (#any-of? @_function 
    "sprintf_s"
    "snprintf" "snprintf_s"
    "vsprintf_s"
    "vsnprintf" "vsnprintf_s"
    "swprintf" "swprintf_s"
    "snwprintf_s"
    "vswprintf" "vswprintf_s"
    "vsnwprintf_s"
    "mvprintw"
    "mvscanw")
  (#set! injection.language "printf"))

((call_expression
  function: (identifier) @_function
  arguments: (argument_list
    (_)
    .
    (_)
    .
    (_)
    .
    [
      (string_literal
        (string_content) @injection.content)
      (concatenated_string
        (string_literal
          (string_content) @injection.content))
    ]))
  (#any-of? @_function "mvwprintw" "mvwscanw")
  (#set! injection.language "printf"))

((gnu_asm_expression
  assembly_code: (string_literal) @injection.content)
  (#set! injection.language "asm"))

((gnu_asm_expression
  assembly_code: (concatenated_string
    (string_literal) @injection.content))
  (#set! injection.language "asm"))

; --- enclosing_owner_hints ---

(struct_specifier 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- errors ---

(ERROR) @syntax.error

; --- expressions ---

(binary_expression left: (_) @expr.binary.left operator: _ @expr.binary.operator right: (_) @expr.binary.right) @expr.binary
(unary_expression operator: _ @expr.unary.operator argument: (_) @expr.unary.argument) @expr.unary
(update_expression argument: (_) @expr.update.argument operator: _ @expr.update.operator) @expr.update
(assignment_expression left: (_) @expr.assign.left operator: _ @expr.assign.operator right: (_) @expr.assign.right) @expr.assign
(conditional_expression condition: (_) @expr.conditional.condition consequence: (_) @expr.conditional.true alternative: (_) @expr.conditional.false) @expr.conditional
(comma_expression left: (_) @expr.comma.left right: (_) @expr.comma.right) @expr.comma

; --- extensions ---

(gnu_asm_expression) @extension.gnu_asm
(attribute_specifier) @extension.attribute @linkage.attribute @modifier.attribute

; --- function_contracts ---

(function_definition type: (_) @function.return_type declarator: (_) @function.declarator body: (compound_statement) @function.body) @function.definition

; --- function_pointers ---

(pointer_declarator declarator: (function_declarator) @type.function_pointer)
(call_expression function: (parenthesized_expression) @call.indirect.target) @call.indirect

; --- generic_selection ---

(generic_expression) @generic.selection

; --- imports_modules ---

; --- initialization ---

(initializer_list) @init.aggregate
(compound_literal_expression type: (_) @init.compound.type value: (initializer_list) @init.compound.value) @init.compound

; --- linkage_visibility ---

(storage_class_specifier) @linkage.storage @modifier.storage

; --- literals ---

(number_literal) @literal.number
(char_literal) @literal.char
(string_literal) @literal.string
(concatenated_string) @literal.concatenated_string

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

(struct_specifier
  name: (_) @owner.name
  body: (field_declaration_list
    (preproc_function_def
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

; --- module_path_hints ---

; --- named_scope_owners ---

; --- operators ---

(sizeof_expression) @operator.sizeof
(alignof_expression) @operator.alignof
(cast_expression type: (_) @operator.cast.type value: (_) @operator.cast.value) @operator.cast

; --- owned_direct_calls_v3_81 ---

; Omega v3.81 bounded direct-call ownership for C.
; Exact subset: a direct identifier call used as a top-level expression statement
; in the body of a named function definition. Nested control-flow/member/pointer/
; macro-expanded calls are intentionally excluded.

(function_definition
  declarator: (function_declarator
    declarator: (identifier) @caller.name)
  body: (compound_statement
    (expression_statement
      (call_expression
        function: (identifier) @callee.name) @call.expression))) @caller.function

; --- ownership_members ---

; --- preprocessor ---

(preproc_def name: (identifier) @preproc.macro.name) @preproc.macro
(preproc_function_def name: (identifier) @preproc.function_macro.name) @preproc.function_macro
(preproc_if condition: (_) @preproc.condition) @preproc.conditional
(preproc_ifdef name: (identifier) @preproc.condition.symbol) @preproc.conditional.symbol

; --- provider_surface_enrichment ---

; Exact-compatible provider surface enrichment for the full C parser commit.
(attribute_declaration) @surface.attribute_declaration
(escape_sequence) @surface.escape_sequence
(false) @surface.false
(field_designator) @surface.field_designator
(gnu_asm_qualifier) @surface.gnu_asm_qualifier
(linkage_specification) @surface.linkage
(ms_pointer_modifier) @surface.ms_pointer_modifier
(null) @surface.null
(parenthesized_declarator) @surface.parenthesized_declarator
(preproc_call) @surface.preproc_call
(preproc_defined) @surface.preproc_defined
(preproc_directive) @surface.preproc_directive
(preproc_elifdef) @surface.preproc_elifdef
(preproc_params) @surface.preproc_params
(sized_type_specifier) @surface.sized_type
(system_lib_string) @surface.system_include
(true) @surface.true
(type_descriptor) @surface.type_descriptor

; --- references ---

(identifier) @reference.identifier
(field_expression argument: (_) @reference.base field: (field_identifier) @reference.member)
(subscript_expression argument: (_) @reference.index.base index: (_) @reference.index.expression)

; --- scopes ---

(translation_unit) @scope.file
(function_definition body: (compound_statement) @scope.function.body) @scope.function
(compound_statement) @scope.block

; --- signature_parameters ---

(preproc_function_def
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- storage_qualifiers ---

; --- types ---

(type_identifier) @type.named
(pointer_declarator declarator: (_) @type.pointer.target) @type.pointer
(array_declarator declarator: (_) @type.array.target size: (_)? @type.array.size) @type.array
(function_declarator declarator: (_) @type.function.name parameters: (parameter_list) @type.function.parameters) @type.function

; --- variadics ---

(variadic_parameter) @parameter.variadic
