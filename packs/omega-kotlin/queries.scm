; omega-kotlin
;
; Kotlin is used for Android apps, JVM services, multiplatform libraries and
; Gradle build logic. The questions asked of a Kotlin file are: what does this
; file declare, what package is it in, what does it import, what does this
; class extend or implement, what type does this name have, and who calls this
; function. Every pattern below answers one of them.
;
; Containment is never stated as a pattern. The tree already holds it, a
; declaration nested in another carries its container through the `within:`
; namespace segment, and a body's extent is emitted once as a region.
;
; Two capture namespaces are used deliberately.
;   @decl.*        the parts any declaration may have -- its span, its
;                  modifiers, its visibility, its type parameters, its
;                  parameter list, its declared or returned type, its extension
;                  receiver, its body. These names are shared across every
;                  declaration pattern, so one carrier template serves all of
;                  them instead of one per node type.
;   @<kind>.name   the capture that decides which declaration kind is emitted.
;                  Exactly one of these binds in any match, so the skip rule
;                  picks exactly one declaration template per match.

; ---------------------------------------------------------------------------
; Types
; ---------------------------------------------------------------------------
;
; `class`, `enum class`, `data class`, `sealed class` and `annotation class`
; are one node distinguished by a `class_modifier`, which is carried as the
; declaration's modifier rather than split into a kind per spelling. An
; `interface` is the other arm of the same node and is told apart by its
; keyword, because the two answer different questions.

(class_declaration
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  "class"
  (type_identifier) @class.name @decl.name
  (type_parameters)? @decl.type_parameters
  (primary_constructor)? @decl.parameters
  [(class_body) (enum_class_body)]? @decl.type_body) @decl.span

(class_declaration
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  "interface"
  (type_identifier) @interface.name @decl.name
  (type_parameters)? @decl.type_parameters
  (class_body)? @decl.type_body) @decl.span

; `object Foo { }` and `companion object Bar { }` declare a singleton: one
; name that is both a type and the only value of it.

(object_declaration
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  (type_identifier) @object.name @decl.name
  (class_body)? @decl.type_body) @decl.span

(companion_object
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  (type_identifier) @object.name @decl.name
  (class_body)? @decl.type_body) @decl.span

(type_alias
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  (type_identifier) @type_alias.name @decl.name
  (type_parameters)? @decl.type_parameters
  [(user_type)
   (nullable_type)
   (function_type)
   (not_nullable_type)
   (parenthesized_type)]? @decl.declared_type) @decl.span

; A type parameter is declared so that the type references in the body of the
; declaration that introduces it have something of their own to resolve to.

(type_parameter (type_identifier) @type_parameter.name)

; ---------------------------------------------------------------------------
; Callables
; ---------------------------------------------------------------------------
;
; One node covers a top-level function, a member function and an extension
; function. The extension receiver is a field of its own, so the return type is
; the only bare type child and needs no anchor to be told from it.

(function_declaration
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  receiver: (receiver_type)? @decl.container
  (type_parameters)? @decl.type_parameters
  (simple_identifier) @function.name @decl.name
  (function_value_parameters)? @decl.parameters
  [(user_type)
   (nullable_type)
   (function_type)
   (not_nullable_type)
   (parenthesized_type)]? @decl.return_type
  (function_body)? @decl.function_body) @decl.span

; ---------------------------------------------------------------------------
; Properties, parameters and local bindings
; ---------------------------------------------------------------------------

(property_declaration
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  receiver: (receiver_type)? @decl.container
  (variable_declaration
    (simple_identifier) @property.name
    [(user_type)
     (nullable_type)
     (function_type)
     (not_nullable_type)
     (parenthesized_type)]? @decl.declared_type)) @decl.span

; `class Foo(val bar: Int)` -- a primary-constructor parameter is how Kotlin
; declares most of its properties, and is referenced by that name from the body
; whether or not it carries `val`.

(class_parameter
  (modifiers
    (visibility_modifier)? @decl.visibility)? @decl.modifiers
  (simple_identifier) @property.name
  [(user_type)
   (nullable_type)
   (function_type)
   (not_nullable_type)
   (parenthesized_type)]? @decl.declared_type) @decl.span

(parameter
  (simple_identifier) @parameter.name
  [(user_type)
   (nullable_type)
   (function_type)
   (not_nullable_type)
   (parenthesized_type)]? @decl.declared_type) @decl.span

(lambda_parameters
  (variable_declaration
    (simple_identifier) @parameter.name
    [(user_type)
     (nullable_type)
     (function_type)
     (not_nullable_type)
     (parenthesized_type)]? @decl.declared_type) @decl.span)

(for_statement
  (variable_declaration
    (simple_identifier) @variable.name
    [(user_type)
     (nullable_type)
     (function_type)
     (not_nullable_type)
     (parenthesized_type)]? @decl.declared_type) @decl.span)

; `val (a, b) = pair` -- each component is a binding of its own.

(multi_variable_declaration
  (variable_declaration
    (simple_identifier) @variable.name) @decl.span)

; An enum entry is a named constant value of its enum, not a type.

(enum_entry (simple_identifier) @constant.name) @decl.span

; ---------------------------------------------------------------------------
; The file's place, and what it pulls in
; ---------------------------------------------------------------------------

(package_header (identifier) @package.name) @decl.span

; `import a.b.C` and `import a.b.C as D` bind the last segment of the path,
; which is the spelling the declaration it refers to is declared under. The
; predicate excludes `import a.b.*`, whose last segment names no symbol; that
; form is its own pattern below.

((import_header
   (identifier
     (simple_identifier) @import.name .)) @import.header
 (#not-match? @import.header "\\*"))

(import_header
  (import_alias (type_identifier) @import.alias)) @import.alias.header

(import_header
  (identifier) @import.package
  (wildcard_import)) @import.wildcard

; ---------------------------------------------------------------------------
; What a type is built out of
; ---------------------------------------------------------------------------
;
; `: Base()`, `: Iface`, `: Iface by delegate` -- a superclass call, a plain
; supertype and an explicit delegation all state that this declaration supplies
; the interface of another type, which is the one relation the host knows for
; that. All three spellings are one pattern, named by the supertype so the
; mention resolves against the class or interface that declares it.

; `class Foo : com.example.Base()` -- this grammar spells a dotted type flat, as
; a repeated run of `type_identifier` inside one `user_type`, so an unanchored
; child capture named every segment and `com` and `example` became implements
; edges of their own. The anchor takes the last segment, with and without type
; arguments after it.

(delegation_specifier
  [(user_type (type_identifier) @implements.type .)
   (user_type (type_identifier) @implements.type . (type_arguments))
   (constructor_invocation (user_type (type_identifier) @implements.type .))
   (constructor_invocation (user_type (type_identifier) @implements.type . (type_arguments)))
   (explicit_delegation (user_type (type_identifier) @implements.type .))
   (explicit_delegation (user_type (type_identifier) @implements.type . (type_arguments)))])

; ---------------------------------------------------------------------------
; References
; ---------------------------------------------------------------------------
;
; Every type identifier, wherever it stands -- a parameter type, a return type,
; a type argument, a supertype, an annotation, a `is`/`as` operand -- is a
; reference to the class, interface, object or alias of that name. One pattern,
; one leaf node, and it is what makes the declarations above reachable.

(type_identifier) @type.reference

; `foo(...)` and `x.foo(...)`: the applied name is the callee. The receiver is
; not stated as a type, because in Kotlin it is usually a value.

(call_expression
  .
  (simple_identifier) @call.function.name)

(call_expression
  .
  (navigation_expression
    (navigation_suffix (simple_identifier) @call.method.name)))

; What a call was given, as a fact of its own. `run { }` and `launch { }` have
; no `value_arguments` node at all, and an unbound capture skips a template
; whole, so the arguments cannot be a field on the call itself. A framework
; reads this with `fact_join_by_span` `relation: "same"`.

(call_expression
  .
  (simple_identifier) @call.arguments.name
  (call_suffix (value_arguments) @call.args))

(call_expression
  .
  (navigation_expression
    (navigation_suffix (simple_identifier) @call.arguments.name))
  (call_suffix (value_arguments) @call.args))

; `::foo` and `Foo::bar` name a callable without applying it.

(callable_reference (simple_identifier) @member.reference)
