; omega-erlang
;
; Erlang source is a flat list of module attributes and function definitions.
; The questions asked of it are: what does this module declare, what behaviour
; does it implement, what is its public API, what does it depend on, and where
; is a function, record, type or macro used. Every pattern below answers one
; of those.
;
; Containment is not stated anywhere: Erlang declares nothing inside anything
; else, so the only region worth naming is a function's own extent, and that
; is a second template over the function pattern rather than a pattern of its
; own.
;
; One note on the grammar. It parses everything after `-name(` as ordinary
; expressions, so a type application in `-spec`, `-type`, `-record` or
; `-callback` (`integer()`, `server_ref()`) is the same `call` node as a local
; function call. On three OTP modules 742 of 2 112 bare applications were type
; applications. Only a qualified `m:f(...)` is therefore stated as a call; a
; bare application is stated as a plain reference, which is true of both.

; --- the module header ---

((attribute
   name: (atom) @_module
   (arguments . (atom) @module.name)) @module
 (#eq? @_module "module"))

; `-behaviour(gen_server)` is the one implements relation Erlang has.

((attribute
   name: (atom) @_behaviour
   (arguments . (atom) @behaviour.name)) @behaviour
 (#any-of? @_behaviour "behaviour" "behavior"))

; --- a function ---
;
; A `function` node holds every clause of one function. The anchor takes the
; first clause only, so a four-clause function is one declaration and not four.
; The declaration, its parameter list and its extent are three templates over
; this one match.

(function
  . (function_clause
      name: (atom) @function.name
      pattern: (arguments) @function.parameters)) @function

; --- what the module exports and imports ---
;
; `-export([f/0, g/1])` is the module's public API, one emission per entry so
; each names the function it exports. `-import` is the same shape and states a
; dependency on another module's function.

((attribute
   name: (atom) @export.kind
   (arguments
     (list
       (binary_operator
         left: (atom) @export.name
         right: (integer) @export.arity) @export.entry)))
 (#any-of? @export.kind "export" "export_type"))

((attribute
   name: (atom) @_import
   (arguments . (atom) @import.module)) @import
 (#eq? @_import "import"))

((attribute
   name: (atom) @_import_fn
   (arguments
     . (atom) @import.fn.module
     (list
       (binary_operator
         left: (atom) @import.fn.name
         right: (integer) @import.fn.arity) @import.fn.entry)))
 (#eq? @_import_fn "import"))

; The header path is taken from the quoted content, so the name is a path and
; not `("kernel/include/file.hrl")`.

((attribute
   name: (atom) @include.kind
   (arguments . (string (quoted_content) @include.path))) @include
 (#any-of? @include.kind "include" "include_lib"))

; --- records ---
;
; `-record(state, {count = 0 :: integer(), name})`. The record is one
; declaration; each field is declared as `state.count`, the same spelling a
; `#state.count` access uses, so the two resolve against each other. A field is
; written bare, with a default, or with a default and a type, which is the
; three-way alternation.

((attribute
   name: (atom) @_record
   (arguments . (atom) @record.name)) @record
 (#eq? @_record "record"))

((attribute
   name: (atom) @_record_field
   (arguments
     . (atom) @field.record
     (tuple
       [(atom) @field.name
        (binary_operator left: (atom) @field.name)
        (binary_operator left: (binary_operator left: (atom) @field.name))])))
 (#eq? @_record_field "record"))

; `#state{...}` and `R#state.count` are the same node; the field is optional
; and only the second binds it.

(record
  name: (atom) @record.ref.name
  field: (atom)? @record.ref.field) @record.ref

; --- types, callbacks and specs ---
;
; `-type opt() :: ...` puts the name inside a `::` operator, so the name is
; reached through it. `-callback` and `-spec` are parsed as stab clauses and
; carry the function name directly.

((attribute
   name: (atom) @_type
   (arguments . (binary_operator left: (call function: (atom) @type.name)))) @type
 (#any-of? @_type "type" "opaque" "nominal"))

((attribute
   name: (atom) @_callback
   (stab_clause
     name: (atom) @callback.name
     pattern: (arguments) @callback.parameters)) @callback
 (#eq? @_callback "callback"))

; A spec declares nothing; it names the function it constrains. The anchor
; takes the first clause of a multi-clause spec only.

((attribute
   name: (atom) @_spec
   . (stab_clause name: (atom) @spec.name)) @spec
 (#eq? @_spec "spec"))

; --- macros ---
;
; `-define(TIMEOUT, 5000)` and `-define(LOG(X), ...)`, with the name written as
; a variable or as an atom. `?TIMEOUT` is stripped to `TIMEOUT` by capturing
; the name rather than the macro node.

((attribute
   name: (atom) @_define
   (arguments
     . [(variable) @macro.name
        (atom) @macro.name
        (call function: (variable) @macro.name)
        (call function: (atom) @macro.name)])) @macro.def
 (#eq? @_define "define"))

(macro name: [(variable) (atom)] @macro.ref.name) @macro.ref

; --- calls and function values ---
;
; `m:f(...)` names its target unambiguously. The anchored pattern below is the
; bare application, which the grammar cannot separate from a type application
; (see the note at the top).

(call
  module: (atom) @call.q.module
  function: (atom) @call.q.name) @call.q

(call . function: (atom) @call.l.name) @call.l

(function_capture
  module: (atom) @fc.q.module
  function: (atom) @fc.q.name
  arity: (integer) @fc.q.arity) @fc.q

(function_capture
  . function: (atom) @fc.l.name
  arity: (integer) @fc.l.arity) @fc.l
