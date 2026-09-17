; omega-c
;
; C is the language of headers that declare an interface and translation units
; that implement it, and of a preprocessor that introduces names no compiler
; front end ever sees as declarations. The questions asked of a C file are:
; where is this function, this type, this macro or this variable declared;
; what does this file include; what calls this function; where is this type,
; this member or this macro used.
;
; Every pattern below is rooted at one node type and answers one of those.
; Containment is deliberately not stated: the tree already holds it, and a
; declaration nested in another carries its container through the `within:`
; segment. One pattern uses a parent node as a *filter* -- a `declaration`
; directly under `translation_unit` is a file-scope variable, the same node
; inside a function body is a local -- which is a structural filter, not a
; containment fact, and costs one match per declaration.

; ---------------------------------------------------------------------------
; Callables
;
; Every C callable -- a definition, a prototype in a header, a static helper --
; is a `function_declarator` whose declarator is an `identifier`, however many
; pointer declarators wrap it and whatever the return type is spelled as. One
; root node therefore covers all of them, and the parameter list (a required
; field, so capturing it changes nothing about what matches) is folded onto the
; declaration as its signature.
;
; A `function_declarator` whose declarator is a parenthesized pointer is a
; function *pointer*, not a function, and is not matched here.
; ---------------------------------------------------------------------------

(function_declarator
  declarator: (identifier) @callable.name
  parameters: (parameter_list) @callable.parameters) @callable

; The return type and the storage class sit on the node *above* the declarator,
; so they are taken from there and folded back onto the declarator's span --
; the span the declaration above occupies. Both the defining and the declaring
; spelling are covered; `*` is carried because `char *strdup(...)` returning
; `char` is a wrong answer.

(function_definition
  type: (_) @callable.return_type
  declarator: (function_declarator
    declarator: (identifier)) @callable)

(declaration
  type: (_) @callable.return_type
  declarator: (function_declarator
    declarator: (identifier)) @callable)

(function_definition
  type: (_) @callable.pointer_return_type
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier)) @callable))

(declaration
  type: (_) @callable.pointer_return_type
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier)) @callable))

; `static` is the whole of C's visibility model: it is the difference between a
; name the linker can see and one it cannot.

(function_definition
  (storage_class_specifier) @callable.modifier
  declarator: (function_declarator
    declarator: (identifier)) @callable)

(declaration
  (storage_class_specifier) @callable.modifier
  declarator: (function_declarator
    declarator: (identifier)) @callable)

; ---------------------------------------------------------------------------
; Types
;
; A body is required in each of these: `struct sockaddr;` names a type it does
; not define, and the name is already recorded as a reference to the definition
; that does.
; ---------------------------------------------------------------------------

(struct_specifier
  name: (type_identifier) @struct.name
  body: (field_declaration_list)) @struct

(union_specifier
  name: (type_identifier) @union.name
  body: (field_declaration_list)) @union

(enum_specifier
  name: (type_identifier) @enum.name
  body: (enumerator_list)) @enum

(enumerator
  name: (identifier) @enumerator.name) @enumerator

(enumerator
  name: (identifier)
  value: (_) @enumerator.value) @enumerator

; A typedef is the one place C names a type outright. All four written forms
; name a `type_identifier`; the fourth is the callback typedef
; `typedef int (*cb)(void*)`, which is how C spells a function type.

(type_definition
  type: [(type_identifier)
         (primitive_type)
         (sized_type_specifier)
         (struct_specifier name: (type_identifier))
         (union_specifier name: (type_identifier))
         (enum_specifier name: (type_identifier))]? @typedef.target
  declarator: [
    (type_identifier) @typedef.name
    (pointer_declarator declarator: (type_identifier) @typedef.name)
    (array_declarator declarator: (type_identifier) @typedef.name)
    (function_declarator
      declarator: (parenthesized_declarator
        (pointer_declarator declarator: (type_identifier) @typedef.name)))
  ]) @typedef

; ---------------------------------------------------------------------------
; Members and file-scope variables
; ---------------------------------------------------------------------------

(field_declaration
  type: (_) @field.type
  declarator: [
    (field_identifier) @field.name
    (pointer_declarator declarator: (field_identifier) @field.name)
    (array_declarator declarator: (field_identifier) @field.name)
    (function_declarator
      declarator: (parenthesized_declarator
        (pointer_declarator declarator: (field_identifier) @field.name)))
  ]) @field

; A header is conventionally wrapped whole in `#ifndef HEADER_H ... #endif`,
; so a file-scope declaration is as often a child of a preprocessor branch
; as of the translation unit. Naming only `translation_unit` declared
; nothing in a guarded header.
[(translation_unit
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (preproc_ifdef
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (preproc_if
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (preproc_else
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (preproc_elif
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (preproc_elifdef
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)
 (declaration_list
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (array_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (init_declarator
        declarator: (array_declarator declarator: (identifier) @variable.name))
    ]) @variable)]

; ---------------------------------------------------------------------------
; Labels
;
; A label is the only name in C that `goto` can resolve against.
; ---------------------------------------------------------------------------

(labeled_statement
  label: (statement_identifier) @label.name) @label

(goto_statement
  label: (statement_identifier) @goto.label) @goto

; ---------------------------------------------------------------------------
; The preprocessor
;
; A macro is a declaration, and in C it is where most constants and a good part
; of the API surface live. The object-like form carries its replacement text as
; a value, the function-like form its parameter list.
; ---------------------------------------------------------------------------

(preproc_def
  name: (identifier) @macro.name) @macro

(preproc_def
  name: (identifier)
  value: (preproc_arg) @macro.value) @macro

(preproc_function_def
  name: (identifier) @macro.function.name
  parameters: (preproc_params) @macro.function.parameters) @macro.function

(preproc_include
  path: [(string_literal) (system_lib_string)] @include.path) @include

; `#ifdef FOO`, `#elifdef FOO` and `defined(FOO)` are the three places a macro
; is named as a condition. They are the references that make a `#define`
; findable.

(preproc_ifdef
  name: (identifier) @macro.reference.name) @macro.reference

(preproc_elifdef
  name: (identifier) @macro.reference.name) @macro.reference

(preproc_defined
  (identifier) @macro.reference.name) @macro.reference

; ---------------------------------------------------------------------------
; Calls
;
; A call is recorded by the name it is written with. Every pattern is rooted at
; `call_expression`, so the cost is one match per call site. `(*fp)(x)` is
; recorded under the pointer's own name -- the variable, which is what the file
; actually says.
; ---------------------------------------------------------------------------

(call_expression
  function: (identifier) @call.name) @call

(call_expression
  function: (parenthesized_expression
    (pointer_expression
      argument: (identifier) @call.name))) @call

(call_expression
  function: (field_expression
    field: (field_identifier) @call.member.name)) @call.member

; ---------------------------------------------------------------------------
; References
;
; `type_identifier` is the one identifier class in this grammar that always
; names a declared type, so it is the reference stream worth keeping. The
; general `(identifier)` sweep is not: it matches every name in every file.
; `x.field`, `p->field` and the `.field =` of a designated initializer all
; resolve against the same member declaration.
; ---------------------------------------------------------------------------

(type_identifier) @reference.type

(field_expression
  field: (field_identifier) @reference.member.name) @reference.member

(field_designator
  (field_identifier) @reference.member.name) @reference.member

(attribute
  name: (identifier) @attribute.name) @attribute

; ---------------------------------------------------------------------------
; The one embedded region C has
;
; A macro body is C text the parser hands back unparsed, so it is re-parsed as
; C. This one pattern is retained from the Neovim distributed injections
; baseline the old Pack was built from; the injections into languages Omega has
; no grammar for -- printf, asm, doxygen, re2c, comment -- are not, and four of
; those were keyed on a list of libc function names spelled into the query.
; ---------------------------------------------------------------------------

((preproc_arg) @injection.content
  (#set! injection.self))
