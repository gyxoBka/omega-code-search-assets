; --- call_targets ---

(call_expression
  (_) @call.target
  (argument_list)) @call.expression

; --- completeness_calls_3 ---

(call_expression) @call.expression

; --- completeness_imports_3 ---

(import_statement) @import.expression @julia.import

; --- completeness_modules_3 ---

(module_definition) @module.expression

; --- completeness_types_high_confidence ---

(struct_definition) @type.expression @julia.struct

; --- declaration_category_module ---

(module_definition
  name: (_) @definition.category.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---


; --- external_highlights ---

; OMEGA PINNED EXTERNAL HIGHLIGHTS — SYNTAX-ROLE EVIDENCE ONLY
; sha256=7bb322f3c048a7e951b64e4c8a0bc97e782034f95dff15385b946eded569d94d

; Identifiers
(identifier) @variable @local.reference

(field_expression
  (identifier) @variable.member .)

; Symbols
(quote_expression
  ":" @string.special.symbol
  [
    (identifier)
    (operator)
  ] @string.special.symbol)

; Function calls
(call_expression
  (identifier) @function.call)

(call_expression
  (field_expression
    (identifier) @function.call .))
(broadcast_call_expression (identifier) @function.call @julia.broadcast.callee) @julia.broadcast.direct_call

(broadcast_call_expression
  (field_expression
    (identifier) @function.call .))

(binary_expression
  (_)
  (operator) @_pipe
  (identifier) @function.call
  (#any-of? @_pipe "|>" ".|>"))

; Macros
(macro_identifier
  "@" @function.macro
  (identifier) @function.macro)
(macro_definition (signature (call_expression . (identifier) @function.macro @local.definition.function))) @local.scope

; Built-in functions
; print.("\"", filter(name -> getglobal(Core, name) isa Core.Builtin, names(Core)), "\" ")
((identifier) @function.builtin
  (#any-of? @function.builtin
    "applicable" "fieldtype" "getfield" "getglobal" "invoke" "isa" "isdefined" "isdefinedglobal"
    "modifyfield!" "modifyglobal!" "nfields" "replacefield!" "replaceglobal!" "setfield!"
    "setfieldonce!" "setglobal!" "setglobalonce!" "swapfield!" "swapglobal!" "throw" "tuple"
    "typeassert" "typeof"))

; Type definitions
(type_head
  (_) @type.definition)

; Type annotations
(parametrized_type_expression
  [
    (identifier) @type
    (field_expression
      (identifier) @type .)
  ]
  (curly_expression
    (_) @type))

(typed_expression
  (identifier) @type .)

(unary_typed_expression
  (identifier) @type .)

(where_expression
  [
    (curly_expression
      (_) @type)
    (_) @type
  ] .)

(unary_expression
  (operator) @operator
  (_) @type
  (#any-of? @operator "<:" ">:"))

(binary_expression
  (_) @type
  (operator) @operator
  (_) @type
  (#any-of? @operator "<:" ">:"))

; Built-in types
; print.("\"", filter(name -> typeof(Base.eval(Core, name)) in [DataType, UnionAll], names(Core)), "\" ")
((identifier) @type.builtin
  (#any-of? @type.builtin
    "AbstractArray" "AbstractChar" "AbstractFloat" "AbstractString" "Any" "ArgumentError" "Array"
    "AssertionError" "AtomicMemory" "AtomicMemoryRef" "Bool" "BoundsError" "Char"
    "ConcurrencyViolationError" "Cvoid" "DataType" "DenseArray" "DivideError" "DomainError"
    "ErrorException" "Exception" "Expr" "FieldError" "Float16" "Float32" "Float64" "Function"
    "GenericMemory" "GenericMemoryRef" "GlobalRef" "IO" "InexactError" "InitError" "Int" "Int128"
    "Int16" "Int32" "Int64" "Int8" "Integer" "InterruptException" "LineNumberNode" "LoadError"
    "Memory" "MemoryRef" "Method" "MethodError" "Module" "NTuple" "NamedTuple" "Nothing" "Number"
    "OutOfMemoryError" "OverflowError" "Pair" "Ptr" "QuoteNode" "ReadOnlyMemoryError" "Real" "Ref"
    "SegmentationFault" "Signed" "StackOverflowError" "String" "Symbol" "Task" "Tuple" "Type"
    "TypeError" "TypeVar" "UInt" "UInt128" "UInt16" "UInt32" "UInt64" "UInt8" "UndefInitializer"
    "UndefKeywordError" "UndefRefError" "UndefVarError" "Union" "UnionAll" "Unsigned" "VecElement"
    "WeakRef"))

; Keywords
[
  "global"
  "local"
] @keyword

(compound_statement
  [
    "begin"
    "end"
  ] @keyword)

(quote_statement
  [
    "quote"
    "end"
  ] @keyword)

(let_statement
  [
    "let"
    "end"
  ] @keyword)

(if_statement
  [
    "if"
    "end"
  ] @keyword.conditional)

(elseif_clause
  "elseif" @keyword.conditional)

(else_clause
  "else" @keyword.conditional)

(ternary_expression
  [
    "?"
    ":"
  ] @keyword.conditional.ternary)

(try_statement
  [
    "try"
    "end"
  ] @keyword.exception)

(catch_clause
  "catch" @keyword.exception)

(finally_clause
  "finally" @keyword.exception)

(for_statement
  [
    "for"
    "end"
  ] @keyword.repeat)

(for_binding
  "outer" @keyword.repeat)

; comprehensions
(for_clause
  "for" @keyword.repeat)

(if_clause
  "if" @keyword.conditional)

(while_statement
  [
    "while"
    "end"
  ] @keyword.repeat)

[
  (break_statement)
  (continue_statement)
] @keyword.repeat

[
  "const"
  "mutable"
] @keyword.modifier

(function_definition
  [
    "function"
    "end"
  ] @keyword.function)

(do_clause
  [
    "do"
    "end"
  ] @keyword.function)

(macro_definition
  [
    "macro"
    "end"
  ] @keyword)

(return_statement
  "return" @keyword.return)

(module_definition
  [
    "module"
    "baremodule"
    "end"
  ] @keyword.import)

(export_statement
  "export" @keyword.import)

(public_statement
  "public" @keyword.import)

(import_statement
  "import" @keyword.import)

(using_statement
  "using" @keyword.import)

(import_alias
  "as" @keyword.import)

(selected_import
  ":" @punctuation.delimiter)

(struct_definition
  [
    "mutable"
    "struct"
    "end"
  ] @keyword.type)

(abstract_definition
  [
    "abstract"
    "type"
    "end"
  ] @keyword.type)

(primitive_definition
  [
    "primitive"
    "type"
    "end"
  ] @keyword.type)

; Operators & Punctuation
(operator) @operator

(adjoint_expression
  "'" @operator)

(range_expression
  ":" @operator)

(arrow_function_expression
  "->" @operator)

[
  "."
  "..."
] @punctuation.special

[
  ","
  ";"
  "::"
] @punctuation.delimiter

; Treat `::` as operator in type contexts, see
; https://github.com/nvim-treesitter/nvim-treesitter/pull/7392
(typed_expression
  "::" @operator)

(unary_typed_expression
  "::" @operator)

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

; Interpolation
(string_interpolation
  .
  "$" @punctuation.special)

(interpolation_expression
  .
  "$" @punctuation.special)

; Keyword operators
((operator) @keyword.operator
  (#any-of? @keyword.operator "in" "isa"))

(where_expression
  "where" @keyword.operator)

; Built-in constants
((identifier) @constant.builtin
  (#any-of? @constant.builtin "nothing" "missing"))

((identifier) @variable.builtin
  (#any-of? @variable.builtin "begin" "end")
  (#has-ancestor? @variable.builtin index_expression))

; Literals
(boolean_literal) @boolean

(integer_literal) @number

(float_literal) @number.float

((identifier) @number.float
  (#any-of? @number.float "NaN" "NaN16" "NaN32" "Inf" "Inf16" "Inf32"))

(character_literal) @character

(escape_sequence) @string.escape

(string_literal) @string

(prefixed_string_literal
  prefix: (identifier) @function.macro) @string

(command_literal) @string.special

(prefixed_command_literal
  prefix: (identifier) @function.macro) @string.special

((string_literal) @string.documentation
  .
  [
    (abstract_definition)
    (assignment)
    (const_statement)
    (function_definition)
    (macro_definition)
    (module_definition)
    (struct_definition)
  ])

(source_file
  (string_literal) @string.documentation
  .
  [
    (identifier)
    (call_expression)
  ])

[
  (line_comment)
  (block_comment)
] @comment @spell

; --- external_injections ---

; OMEGA PINNED EXTERNAL INJECTIONS — BOUNDED CANDIDATE EVIDENCE ONLY
; sha256=8c9533faf169d4734d7f6b0e84dd063055eb63cd4966f2e5416deaf574965db8

; Inject markdown in docstrings
((string_literal
  (content) @injection.content)
  .
  [
    (module_definition)
    (abstract_definition)
    (struct_definition)
    (function_definition)
    (macro_definition)
    (assignment)
    (const_statement)
    (call_expression)
    (identifier)
  ]
  (#set! injection.language "markdown"))

; Inject comments
([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))

; Inject regex in r"..." and r"""...""" (e.g. r"hello\bworld")
(prefixed_string_literal
  prefix: (identifier) @_prefix
  (content) @injection.content
  (#eq? @_prefix "r")
  (#set! injection.language "regex"))

; Inject markdown in md"..." and md"""...""" (e.g. md"**Bold** and _Italics_")
(prefixed_string_literal
  prefix: (identifier) @_prefix
  (content) @injection.content
  (#eq? @_prefix "md")
  (#set! injection.language "markdown"))

; Inject bash in `...` and ```...``` (e.g. `git add --help`)
(command_literal
  (content) @injection.content
  (#set! injection.language "bash"))

; --- external_locals ---

; OMEGA EXTERNAL LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim legacy immutable snapshot
; sha256=ed83a7a3e780e3238f23c6eeae211db5cb05b8f330d6795c221d2a137e5f2d71

; References

; Definitions
(assignment
  .
  (identifier) @local.definition.var)

(assignment
  .
  (tuple_expression
    (identifier) @local.definition.var))

(assignment
  .
  (open_tuple
    (identifier) @local.definition.var))

(for_binding
  .
  (identifier) @local.definition.var)

(for_binding
  .
  (tuple_expression
    (identifier) @local.definition.var))
(import_statement (identifier) @local.definition.import @import.module_path.target) @import.module_path.statement

(using_statement
  (identifier) @local.definition.import)

(selected_import
  (identifier) @local.definition.import)

(module_definition
  .
  (identifier) @local.definition.type)

(type_head
  (identifier) @local.definition.type)

(type_head
  (binary_expression
    .
    (identifier) @local.definition.type))

(function_definition
  (signature
    (call_expression
      .
      (identifier) @local.definition.function))) @local.scope

; Scopes
[
  (quote_statement)
  (let_statement)
  (for_statement)
  (while_statement)
  (try_statement)
  (catch_clause)
  (finally_clause)
  (do_clause)
] @local.scope

; --- import_bound_callable_invocation_context ---

; Framework-neutral Julia source fact. Supported bounded subset:
;   import Module
;   binding = Module.member(...)
;   output = binding(input)
; All three forms are direct source-file children; module/receiver and binding/callable must match textually.
(source_file
  (import_statement
    (identifier) @julia.callable_invocation.module_name)
  (assignment
    . (identifier) @julia.callable_invocation.binding_name
    (call_expression
      . (field_expression
          value: (identifier) @julia.callable_invocation.receiver
          (identifier) @julia.callable_invocation.member_name)
      (argument_list)) @julia.callable_invocation.constructor_call) @julia.callable_invocation.constructor_assignment
  (assignment
    . (identifier) @julia.callable_invocation.output_name
    (call_expression
      . (identifier) @julia.callable_invocation.callable_name
      (argument_list
        . (identifier) @julia.callable_invocation.input_name)) @julia.callable_invocation.call) @julia.callable_invocation.assignment
  (#eq? @julia.callable_invocation.module_name @julia.callable_invocation.receiver)
  (#eq? @julia.callable_invocation.binding_name @julia.callable_invocation.callable_name))

; --- import_bound_member_binding_context ---

; Framework-neutral Julia authored module-member binding fact.
; Supported source-only subset:
;   import ModuleName
;   binding = ModuleName.member(...)
; Module import name and receiver must be textually identical.
; `using`, import aliases, nested field chains, rebinding and runtime resolution are out of scope.
(source_file
  (import_statement
    (identifier) @julia.import_bound.module_name)
  (assignment
    . (identifier) @julia.import_bound.binding_name
    (call_expression
      . (field_expression
          value: (identifier) @julia.import_bound.receiver
          (identifier) @julia.import_bound.member_name)
      (argument_list)) @julia.import_bound.call) @julia.import_bound.assignment
  (#eq? @julia.import_bound.module_name @julia.import_bound.receiver))

; --- import_targets ---

(import_statement
  (import_path) @import.target @import.module_path.target @julia.import.path) @import.statement @import.module_path.statement @julia.import.path_owner

; --- module_declaration_path_hints ---

(module_definition name: (identifier) @module.declaration_path.name) @module.declaration_path.span

; --- named_scope_owners ---

(module_definition
  name: (_) @scope.owner.name
  (block) @scope.owner.body) @scope.owner

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=7bb322f3c048a7e951b64e4c8a0bc97e782034f95dff15385b946eded569d94d
; source_name=julia

; ----- resolved nvim highlights source: julia sha256=7bb322f3c048a7e951b64e4c8a0bc97e782034f95dff15385b946eded569d94d -----
; Identifiers


; Symbols

; Function calls




(binary_expression
  (_)
  (operator) @_pipe
  (identifier) @function.call
  (#any-of? @_pipe "|>" ".|>"))

; Macros


; Built-in functions
; print.("\"", filter(name -> getglobal(Core, name) isa Core.Builtin, names(Core)), "\" ")
((identifier) @function.builtin
  (#any-of? @function.builtin
    "applicable" "fieldtype" "getfield" "getglobal" "invoke" "isa" "isdefined" "isdefinedglobal"
    "modifyfield!" "modifyglobal!" "nfields" "replacefield!" "replaceglobal!" "setfield!"
    "setfieldonce!" "setglobal!" "setglobalonce!" "swapfield!" "swapglobal!" "throw" "tuple"
    "typeassert" "typeof"))

; Type definitions

; Type annotations




(unary_expression
  (operator) @operator
  (_) @type
  (#any-of? @operator "<:" ">:"))

(binary_expression
  (_) @type
  (operator) @operator
  (_) @type
  (#any-of? @operator "<:" ">:"))

; Built-in types
; print.("\"", filter(name -> typeof(Base.eval(Core, name)) in [DataType, UnionAll], names(Core)), "\" ")
((identifier) @type.builtin
  (#any-of? @type.builtin
    "AbstractArray" "AbstractChar" "AbstractFloat" "AbstractString" "Any" "ArgumentError" "Array"
    "AssertionError" "AtomicMemory" "AtomicMemoryRef" "Bool" "BoundsError" "Char"
    "ConcurrencyViolationError" "Cvoid" "DataType" "DenseArray" "DivideError" "DomainError"
    "ErrorException" "Exception" "Expr" "FieldError" "Float16" "Float32" "Float64" "Function"
    "GenericMemory" "GenericMemoryRef" "GlobalRef" "IO" "InexactError" "InitError" "Int" "Int128"
    "Int16" "Int32" "Int64" "Int8" "Integer" "InterruptException" "LineNumberNode" "LoadError"
    "Memory" "MemoryRef" "Method" "MethodError" "Module" "NTuple" "NamedTuple" "Nothing" "Number"
    "OutOfMemoryError" "OverflowError" "Pair" "Ptr" "QuoteNode" "ReadOnlyMemoryError" "Real" "Ref"
    "SegmentationFault" "Signed" "StackOverflowError" "String" "Symbol" "Task" "Tuple" "Type"
    "TypeError" "TypeVar" "UInt" "UInt128" "UInt16" "UInt32" "UInt64" "UInt8" "UndefInitializer"
    "UndefKeywordError" "UndefRefError" "UndefVarError" "Union" "UnionAll" "Unsigned" "VecElement"
    "WeakRef"))

; Keywords













; comprehensions



















; Operators & Punctuation






; Treat `::` as operator in type contexts, see
; https://github.com/nvim-treesitter/nvim-treesitter/pull/7392



; Interpolation


; Keyword operators
((operator) @keyword.operator
  (#any-of? @keyword.operator "in" "isa"))


; Built-in constants
((identifier) @constant.builtin
  (#any-of? @constant.builtin "nothing" "missing"))

((identifier) @variable.builtin
  (#any-of? @variable.builtin "begin" "end")
  (#has-ancestor? @variable.builtin index_expression))

; Literals



((identifier) @number.float
  (#any-of? @number.float "NaN" "NaN16" "NaN32" "Inf" "Inf16" "Inf32"))










; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=8c9533faf169d4734d7f6b0e84dd063055eb63cd4966f2e5416deaf574965db8
; source_name=julia

; ----- resolved nvim injections source: julia sha256=8c9533faf169d4734d7f6b0e84dd063055eb63cd4966f2e5416deaf574965db8 -----
; Inject markdown in docstrings
((string_literal
  (content) @injection.content)
  .
  [
    (module_definition)
    (abstract_definition)
    (struct_definition)
    (function_definition)
    (macro_definition)
    (assignment)
    (const_statement)
    (call_expression)
    (identifier)
  ]
  (#set! injection.language "markdown"))

; Inject comments
([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))

; Inject regex in r"..." and r"""...""" (e.g. r"hello\bworld")
(prefixed_string_literal
  prefix: (identifier) @_prefix
  (content) @injection.content
  (#eq? @_prefix "r")
  (#set! injection.language "regex"))

; Inject markdown in md"..." and md"""...""" (e.g. md"**Bold** and _Italics_")
(prefixed_string_literal
  prefix: (identifier) @_prefix
  (content) @injection.content
  (#eq? @_prefix "md")
  (#set! injection.language "markdown"))

; Inject bash in `...` and ```...``` (e.g. `git add --help`)
(command_literal
  (content) @injection.content
  (#set! injection.language "bash"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=ed83a7a3e780e3238f23c6eeae211db5cb05b8f330d6795c221d2a137e5f2d71
; resolved_query_sha256=c328abdf40a4834eb6b54dfea752a38a00e95b8dcaf895b4e9cda31b25401654
; parser_revision=e0f9dcd180fdcfcfa8d79a3531e11d99e79321d3
; source_name=julia
; direct_inherits=
; resolved_sources=julia

; ----- resolved nvim locals source: julia sha256=ed83a7a3e780e3238f23c6eeae211db5cb05b8f330d6795c221d2a137e5f2d71 -----
; References

; Definitions













; Scopes

; --- semantic_closure_v3_146_batch2 ---

(macro_definition) @julia.macro.definition
(macrocall_expression (macro_identifier) @julia.macro.call.name) @julia.macro.call
(using_statement) @julia.using
(selected_import) @julia.selected_import @julia.selected_import.entry
(broadcast_call_expression) @julia.broadcast.call

; --- semantic_closure_v3_146_batch4 ---

(field_expression) @julia.field.expression

(using_statement
  (import_path) @julia.using.path) @julia.using.path_owner

