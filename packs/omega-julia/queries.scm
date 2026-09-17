; omega-julia
;
; Julia is written as packages: a `src/Package.jl` that declares one module,
; a tree of files it `include`s, and a `test/` tree. The questions asked of
; that source are: what does this module define and export, what does this
; package depend on, what type is this, what is this function's signature,
; what subtypes what, and who calls what. Every pattern below answers one of
; those and nothing else.
;
; Containment is not stated as a pattern. The tree holds it, a declaration
; nested in a module already carries the module through `within:`, and the
; extent of a module, a function, a macro and a struct is emitted once as a
; region.

; --- a module ---
;
; `module M ... end` and `baremodule M ... end` are the same node. The block
; is optional in the grammar, so the region is optional too and the
; declaration survives without it.

(module_definition
  name: (identifier) @module.name
  (block)? @module.body) @module

; --- a function, long form ---
;
; The name is the callee of the call in the signature. The grammar wraps that
; call in a `typed_expression` when a return type is written and in a
; `where_expression` when type parameters are, so the four written forms are
; four branches of one alternation and the parameter list, return type and
; where clause are carried on the declaration's own span.
;
; `function f end` declares a generic function with no method and no argument
; list; the parameter carrier is simply skipped for it.

(function_definition
  (signature
    [ (identifier) @function.name
      (call_expression
        . [ (identifier) @function.name
            (field_expression (identifier) @function.name .) ]
        (argument_list) @function.parameters)
      (typed_expression
        . (call_expression
            . [ (identifier) @function.name
                (field_expression (identifier) @function.name .) ]
            (argument_list) @function.parameters)
        . (_) @function.return_type)
      (where_expression
        . (call_expression
            . [ (identifier) @function.name
                (field_expression (identifier) @function.name .) ]
            (argument_list) @function.parameters)
        (_) @function.type_parameters .)
      (where_expression
        . (typed_expression
            . (call_expression
                . [ (identifier) @function.name
                    (field_expression (identifier) @function.name .) ]
                (argument_list) @function.parameters)
            . (_) @function.return_type)
        (_) @function.type_parameters .) ])
  (block)? @function.body) @function

; --- a function, assignment form ---
;
; `f(x) = x + 1` is an assignment whose left side is a call. Same captures as
; the long form, so the same templates state it; only the region is missing,
; because there is no block.

(assignment
  . [ (call_expression
        . [ (identifier) @function.name
            (field_expression (identifier) @function.name .) ]
        (argument_list) @function.parameters)
      (typed_expression
        . (call_expression
            . [ (identifier) @function.name
                (field_expression (identifier) @function.name .) ]
            (argument_list) @function.parameters)
        . (_) @function.return_type)
      (where_expression
        . (call_expression
            . [ (identifier) @function.name
                (field_expression (identifier) @function.name .) ]
            (argument_list) @function.parameters)
        (_) @function.type_parameters .)
      (where_expression
        . (typed_expression
            . (call_expression
                . [ (identifier) @function.name
                    (field_expression (identifier) @function.name .) ]
                (argument_list) @function.parameters)
            . (_) @function.return_type)
        (_) @function.type_parameters .) ]) @function

; --- a macro ---
;
; A macro is invoked like a callable and is declared under a callable kind so
; that asking for what a module can call finds it.

(macro_definition
  (signature
    (call_expression
      . (identifier) @macro.name
      (argument_list) @macro.parameters))
  (block)? @macro.body) @macro

; --- a struct ---
;
; The head is `Foo`, `Foo{T}`, `Foo <: Bar` or `Foo{T} <: Bar{T}`. The name is
; always the leading identifier, the curly braces are the type parameter shape,
; and `<:` is Julia's one written subtype edge.

(struct_definition
  (type_head
    [ (identifier) @struct.name
      (parametrized_type_expression
        . (identifier) @struct.name
        (curly_expression) @struct.parameters)
      (binary_expression
        . [ (identifier) @struct.name
            (parametrized_type_expression
              . (identifier) @struct.name
              (curly_expression) @struct.parameters) ]
        [ (identifier) @struct.supertype
          (parametrized_type_expression . (identifier) @struct.supertype)
          (field_expression (identifier) @struct.supertype .) ] .) ])
  (block)? @struct.body) @struct

; --- a struct's fields ---
;
; A bare identifier in a struct body is an untyped field; `x::T` is a typed
; one. Inner constructors are function definitions and are declared by the
; function patterns above, not here.

(struct_definition
  (block
    [ (identifier) @field.name
      (typed_expression
        . (identifier) @field.name
        . (_) @field.type) ] @field))

; --- an abstract type ---

(abstract_definition
  (type_head
    [ (identifier) @abstract.name
      (parametrized_type_expression
        . (identifier) @abstract.name
        (curly_expression) @abstract.parameters)
      (binary_expression
        . [ (identifier) @abstract.name
            (parametrized_type_expression
              . (identifier) @abstract.name
              (curly_expression) @abstract.parameters) ]
        [ (identifier) @abstract.supertype
          (parametrized_type_expression . (identifier) @abstract.supertype)
          (field_expression (identifier) @abstract.supertype .) ] .) ])) @abstract

; --- a primitive type ---

(primitive_definition
  (type_head
    [ (identifier) @primitive.name
      (parametrized_type_expression
        . (identifier) @primitive.name
        (curly_expression) @primitive.parameters)
      (binary_expression
        . [ (identifier) @primitive.name
            (parametrized_type_expression
              . (identifier) @primitive.name
              (curly_expression) @primitive.parameters) ]
        [ (identifier) @primitive.supertype
          (parametrized_type_expression . (identifier) @primitive.supertype)
          (field_expression (identifier) @primitive.supertype .) ] .) ])) @primitive

; --- a constant ---

(const_statement
  (assignment
    . [ (identifier) @const.name
        (typed_expression
          . (identifier) @const.name
          . (_) @const.type) ])) @const

; --- a module-level variable ---
;
; Julia has no declaration keyword for a variable: an assignment is one. Only
; the assignments that sit directly in a file or directly in a module body are
; declared, because those are the names another file can reach; a name
; assigned inside a function body belongs to that body alone.

(source_file
  (assignment
    . [ (identifier) @variable.name
        (typed_expression
          . (identifier) @variable.name
          . (_) @variable.type) ]) @variable)

(module_definition
  (block
    (assignment
      . [ (identifier) @variable.name
          (typed_expression
            . (identifier) @variable.name
            . (_) @variable.type) ]) @variable))

; --- global and local declarations ---
;
; `global x` inside a body names a module-level binding; `local x` states that
; a name is not one. Both are written precisely because the default is the
; other way round, so both are worth recording.

(global_statement
  [ (identifier) @global.name
    (assignment . (identifier) @global.name)
    (open_tuple (identifier) @global.name) ]) @global

(local_statement
  [ (identifier) @local.name
    (assignment . (identifier) @local.name)
    (open_tuple (identifier) @local.name) ]) @local

; --- what a file brings in ---
;
; `import M`, `using M`, `import M.Sub`, `using M: a, b`. The module a
; selected import draws from is the first child of the selection, so all four
; spellings give one `import.module` named the way the dependency is spelled.

[ (import_statement
    [ (identifier) @import.module
      (import_path) @import.module
      (selected_import . [ (identifier) (import_path) ] @import.module) ])
  (using_statement
    [ (identifier) @import.module
      (import_path) @import.module
      (selected_import . [ (identifier) (import_path) ] @import.module) ]) ] @import

; `import M as N` and `using M as N`: the dependency and the local name it is
; given are two facts about one statement.

[ (import_statement
    (import_alias
      . [ (identifier) (import_path) ] @import.module
      (identifier) @import.alias .))
  (using_statement
    (import_alias
      . [ (identifier) (import_path) ] @import.module
      (identifier) @import.alias .)) ] @import

; The names a selected import actually binds, each under its own span so it
; resolves against the declaration it came from.

[ (import_statement
    (selected_import
      . [ (identifier) (import_path) ]
      [ (identifier) @import.symbol
        (macro_identifier (identifier) @import.symbol) ]))
  (using_statement
    (selected_import
      . [ (identifier) (import_path) ]
      [ (identifier) @import.symbol
        (macro_identifier (identifier) @import.symbol) ])) ]

; --- what a module offers ---

[ (export_statement
    [ (identifier) @export.name
      (macro_identifier (identifier) @export.name) ])
  (public_statement
    [ (identifier) @export.name
      (macro_identifier (identifier) @export.name) ]) ] @export

; --- calls ---
;
; Julia spells a method definition as a call expression: `function f(x)` and
; `f(x) = ...` contain the very same node an actual call of `f` does. A query
; cannot look at a node's parent, so the only way to tell the two apart is to
; root the pattern at the parent, and the list below is every node type the
; pinned grammar lets a call expression sit in -- taken from node-types.json --
; minus the two in which it is a declaration and not a call:
;
;   (signature)   `function f(x)` and `macro m(x)`
;   (type_head)   the head of a `struct`, `abstract type` or `primitive type`
;
; and minus the first child of `assignment`, `typed_expression` and
; `where_expression`, which is where `f(x) = ...`, `f(x)::T = ...` and
; `f(x) where T = ...` put the definition. Rooting it at `(call_expression)`
; instead costs one call of its own name at every function in the corpus:
; measured on the sample in this Pack's document, half of all calls.
;
; `M.f(x)` is a call of `f`; the name at the end of the callee is the spelling
; the declaration carries.

[
  (adjoint_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (argument_list (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (arrow_function_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (binary_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (block (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (broadcast_call_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (call_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (compound_assignment_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (comprehension_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (const_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (curly_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (do_clause (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (elseif_clause (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (field_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (for_binding (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (generator (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (global_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (if_clause (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (if_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (index_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (juxtaposition_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (let_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (local_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (macro_argument_list (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (matrix_row (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (open_tuple (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (parametrized_type_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (parenthesized_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (range_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (return_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (source_file (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (splat_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (string_interpolation (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (ternary_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (tuple_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (unary_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (unary_typed_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (vector_expression (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (while_statement (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (assignment (_) (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (typed_expression (_) (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call)
  (where_expression (_) (call_expression . [ (identifier) @call.name (field_expression (identifier) @call.name .) ]) @call) ]

; A broadcast call, `f.(x)` or `M.f.(x)`, is never a definition.

(broadcast_call_expression
  . [ (identifier) @call.name
      (field_expression (identifier) @call.name .) ]
  (argument_list)) @call

; `@assert x`, `@Base.kwdef struct ...`: the macro is named without its `@`,
; so it resolves against the macro definition.

(macrocall_expression
  (macro_identifier
    [ (identifier) @macrocall.name
      (field_expression (identifier) @macrocall.name .) ])) @macrocall

; --- where a type is used ---
;
; `x::T` and `::T`, and the head of a parametrized type in those same two
; annotation positions. A parametrized head is not taken from anywhere else,
; because everywhere else it is the head of the declaration itself.

(typed_expression (identifier) @type_use.name .)

(unary_typed_expression (identifier) @type_use.name)

(typed_expression
  (parametrized_type_expression
    . [ (identifier) @type_use.name
        (field_expression (identifier) @type_use.name .) ]) .)

(unary_typed_expression
  (parametrized_type_expression
    . [ (identifier) @type_use.name
        (field_expression (identifier) @type_use.name .) ]))
