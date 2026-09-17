; omega-vbscript
;
; VBScript (and the VBA-flavoured dialect this grammar accepts) is the language
; of logon scripts, WSH automation, ASP classic pages, installer glue and Office
; macros. The questions asked of such a file are: what procedures does it
; declare, what does each one take and return, which of them are private, what
; does it call, which native library does it declare an entry point into, what
; variables does it declare and where are they assigned, and which COM type does
; it create.
;
; Every pattern below is rooted at one node and answers one of those. There is
; no pattern for containment -- a procedure nested inside nothing, a variable
; inside a procedure, are already related by the tree and by the host's `within:`
; segment -- and none for `If`, `For`, `While`, `Do`, `Exit`, operators or
; literals: none of them names anything a question can reach, and this Pack emits
; no `reference_context.*` kind for a literal span to suppress.

; --- a Function ---
;
; One match carries four facts: the declaration, whether it is Private, its
; parameter list and its return type. The three carriers are folded onto the
; declaration at this same span and are what the card's signature line is built
; from.

(function
  "Private"? @function.visibility
  (new_identifier (identifier) @function.name)
  (parameter_list)? @function.parameters
  (type_definition)? @function.return_type) @function

; --- a Sub ---
;
; A Sub is a procedure: it takes parameters and returns nothing, and this
; grammar gives it no visibility keyword.

(subroutine
  (new_identifier (identifier) @subroutine.name)
  (parameter_list)? @subroutine.parameters) @subroutine

; --- Declare PtrSafe Function: an entry point into a native library ---
;
; `Private Declare PtrSafe Function GetTickCount Lib "kernel32" () As Long`.
; The first string literal is the library; a second one, if present, is the
; `Alias` and is deliberately not stated. The anchor keeps the two apart.

(ptrsafe_function_declaration
  (new_identifier (identifier) @external.name) .
  (string_literal) @external.library
  (parameter_list)? @external.parameters
  (type_definition)? @external.return_type) @external

; --- a declared variable ---
;
; `Dim x`, `Dim a, b, c`, `Dim buffer(1 To 10)`. Each declared name is its own
; declaration; the array bounds name nothing and are not stated.

(variable_declaration_identifier
  [(new_identifier (identifier) @variable.name)
   (array_identifier (new_identifier (identifier) @variable.name))]) @variable

; --- the type a declared variable is given ---
;
; `As` is a sibling of the name, not its child, in both spellings the grammar
; has, so the type is carried onto the name's span from the declaration above
; it. In `Dim a, b As Long` the one type belongs to every name in the list, and
; each name gets its own match.

; Anchored: the type must follow its own name. Unanchored, `Dim a As Long, b As
; String` paired both names with the last type it could reach and stored `a` as
; a String. With the anchor, only a name immediately followed by a type gets
; one, which is also what VB means -- an un-suffixed name in a Dim list is a
; Variant, not the type written after a later name.

(variable_declaration
  (variable_declaration_identifier) @variable.typed .
  (type_definition) @variable.declared_type)

(variable_declaration
  (variable_list
    (variable_declaration_identifier) @variable.typed .
    (type_definition) @variable.declared_type))

; --- where a name is assigned ---
;
; VBScript declares implicitly, so an assignment is often the only place a name
; appears, and *where is this set* is the question it answers. `For i = 1 To n`
; assigns `i` and is the same fact. `ReDim buffer(n)` re-binds an array; this
; grammar parses the subscripted form as a `function_call`, so both spellings
; are taken.

(variable_assignment
  . [(identifier) @assignment.target
     (array_element . (identifier) @assignment.target)])

(for_statement . (identifier) @assignment.target)

(redim
  [(identifier) @assignment.target
   (function_call . (identifier) @assignment.target)])

; --- a call ---
;
; `Foo(1)` and `Call Foo(1)` are one node; `Foo 1, 2` as a statement is the
; other. The name is the callee as written.

(function_call . (identifier) @call.name)

; This grammar parses every keyword statement it has no rule for as
; `invocation_statement (identifier) (argument_list)`, so `Set conn = ...`,
; `Option Explicit`, `Const MAX = 5`, `Erase arr` and `On Error Resume Next` all
; read as a call. Without this filter, `Set` and `Option` are among the most
; called names in any VBScript corpus. The language is case-insensitive, so the
; test is too.

((invocation_statement . (identifier) @call.name)
 (#not-match? @call.name
   "(?i)^(set|let|option|const|erase|randomize|on|redim|dim|exit|class|property|with|select|case|end|next|loop|wend|do|while|for|if|then|else|elseif|sub|function|public|private|stop|error|resume)$"))

; --- a method call on a receiver ---
;
; `obj.Method 1, 2`. The last segment is the member being called; the segments
; before it are the receiver and are not stated, because nothing binds a
; receiver to a type here. `obj.Method(1)` puts the parentheses inside a
; `function_call` and is taken by the pattern above instead.

(invocation_statement
  . (member_expression (identifier) @method_call.name .))

; --- a type named in the source ---
;
; `New MyClass` and `As Scripting.Dictionary` are the two places VBScript names
; a type a repository could declare elsewhere. In the dotted `As` spelling only
; the last segment is taken: `Scripting` is a library prefix and would resolve
; onto anything of that name.
;
; `New A.B` cannot be reduced the same way. This grammar parses it as a member
; access on `New A`, so the `new_expression` holds only `A`; the plain
; `New MyClass` that VBScript uses for a class of its own is the form that
; matters and the form this states.
;
; The intrinsic types are anonymous keyword tokens inside `type_terminal`
; (`Integer`, `String`, `Object`, `Variant`, ...). They are carried on the
; declaration they belong to, above, but not stated as mentions: nothing
; declares them.

(new_expression (identifier) @type.name)

(type_terminal
  (type_member_expression (identifier) @type.name .))
