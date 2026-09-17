; omega-swift
;
; Swift is an application language: types, their members, and the calls between
; them. The questions asked of a Swift file are: what does this file declare,
; what is each declaration called and of what sort, who conforms to this
; protocol, what does this file import, what does it call, and where is this
; type used. Every pattern below answers one of them.
;
; Containment is deliberately not stated. A member declared inside a type is
; already inside it in the tree, and the host carries the owner in the
; declaration's namespace. The extent of a type or a function is emitted once,
; as a region over its body.

; --- a nominal type ---
;
; The grammar spells class, struct, enum, actor and extension as one node with
; a `declaration_kind` keyword. The keyword is captured and carried on the
; declaration, so one pattern declares all four nominal forms and the exact
; word survives. `extension` is excluded here and handled below: it introduces
; no new name.

((class_declaration
   (modifiers (visibility_modifier) @type.visibility)?
   declaration_kind: _ @type.keyword
   name: (_) @type.name
   body: (_) @type.body) @type
 (#not-eq? @type.keyword "extension"))

; --- an extension ---
;
; `extension Foo` declares members onto a type declared elsewhere, so the
; extension is stated as depending on that type rather than as declaring it.

(class_declaration
  declaration_kind: "extension"
  name: (_) @extension.name
  body: (_) @extension.body) @extension

; --- a protocol ---

(protocol_declaration
  (modifiers (visibility_modifier) @protocol.visibility)?
  name: (_) @protocol.name
  body: (_) @protocol.body) @protocol

; --- a function ---
;
; One pattern carries the declaration, its visibility, its written return type
; and the region its body occupies.

(function_declaration
  (modifiers (visibility_modifier) @function.visibility)?
  name: (_) @function.name
  (throws)? @function.throws
  return_type: (_)? @function.return_type
  body: (function_body) @function.body) @function

; --- a function required by a protocol ---

(protocol_function_declaration
  name: (_) @requirement.function.name
  (throws)? @requirement.function.throws
  return_type: (_)? @requirement.function.return_type) @requirement.function

; --- an initializer, a deinitializer, a subscript ---
;
; Swift names these with keywords; that is what a member list calls them and
; what a member access spells.

(init_declaration
  (modifiers (visibility_modifier) @init.visibility)?
  name: "init" @init.name) @init

(deinit_declaration "deinit" @deinit.name) @deinit

(subscript_declaration "subscript" @subscript.name) @subscript

; --- a stored or computed property ---
;
; The written type annotation is carried on the property, not emitted as a
; mention of its own: the type identifier inside it is already a type mention.

(property_declaration
  (modifiers (visibility_modifier) @property.visibility)?
  (value_binding_pattern mutability: _ @property.mutability)?
  name: (pattern bound_identifier: (simple_identifier) @property.name)
  (type_annotation type: (_) @property.type)?) @property

(protocol_property_declaration
  name: (pattern bound_identifier: (simple_identifier) @requirement.property.name)
  (type_annotation type: (_) @requirement.property.type)?) @requirement.property

; --- a parameter ---
;
; A parameter is the one binding Swift gives a name to that a question reaches:
; it is what a function takes, and its written type is carried on it.

(parameter
  name: (simple_identifier) @parameter.name
  type: (_) @parameter.type) @parameter

; --- a type alias and an associated type ---

(typealias_declaration
  (modifiers (visibility_modifier) @alias.visibility)?
  name: (_) @alias.name
  value: (_) @alias.value) @alias

(associatedtype_declaration
  name: (_) @associated.name) @associated

; --- an enum case ---

(enum_entry
  name: (simple_identifier) @case.name) @case

; --- a macro, an operator, a precedence group ---

(macro_declaration
  (simple_identifier) @macro.name) @macro

(operator_declaration
  (custom_operator) @operator.name) @operator

(precedence_group_declaration
  (simple_identifier) @precedence.name) @precedence

; --- what the file imports ---

(import_declaration (identifier) @import.name) @import

; --- what it calls ---
;
; `f(x)` and `a.b(x)` are one pattern: the callee is the identifier at the call
; site in both spellings, and that is the name a call resolves by.

(call_expression
  .
  [(simple_identifier) @call.callee
   (navigation_expression
     suffix: (navigation_suffix
       suffix: (simple_identifier) @call.callee))]
  (call_suffix)) @call

(macro_invocation
  (simple_identifier) @macro_call.callee) @macro_call

; --- where a type is used ---
;
; Every written type -- an annotation, a return type, a generic argument, an
; attribute -- reaches the resolver under the name it is spelled with.

(user_type (type_identifier) @type_use.name)

; --- an attribute written as a bare word ---
;
; `@objc`, `@main`, `@available`. An attribute spelled with a type --
; `@Published`, `@MainActor` -- is a `user_type` and is already a type mention
; above, so only the bare-identifier spelling is stated here.

(attribute . (simple_identifier) @attribute.name) @attribute

; --- what conforms to what ---
;
; Swift writes a superclass and a protocol conformance the same way, and both
; are an implements edge for the host.

(inheritance_specifier
  inherits_from: (user_type (type_identifier) @implements.name)) @implements
