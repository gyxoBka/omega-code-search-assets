; omega-scala
;
; Scala is used for libraries, services and data pipelines. The questions asked
; of a Scala file are: what does this file declare, what type does a name have,
; what does this class extend or derive, what does this file import, and who
; calls this method. Every pattern below answers one of them.
;
; Containment is never stated as a pattern: the tree already holds it, and a
; declaration's body is emitted once as a region instead.
;
; Two capture namespaces are used deliberately.
;   @decl.*   -- the parts every declaration may have: its span, its modifiers,
;                its type parameters, its parameter list, its declared or
;                returned type, its body. These names are shared across every
;                declaration pattern, so one carrier template serves all of
;                them rather than one per node type.
;   @<kind>.name -- the capture that decides which declaration kind is emitted.
;                Only one of these binds in any match, so the skip rule picks
;                exactly one declaration template per match.

; ---------------------------------------------------------------------------
; Type declarations
; ---------------------------------------------------------------------------

(class_definition
  [(modifiers) (access_modifier)]? @decl.modifiers
  name: (_) @class.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  class_parameters: (class_parameters)? @decl.parameters
  body: (template_body)? @decl.declaration_body) @decl.span

(trait_definition
  [(modifiers) (access_modifier)]? @decl.modifiers
  name: (_) @trait.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  class_parameters: (class_parameters)? @decl.parameters
  body: (template_body)? @decl.declaration_body) @decl.span

(enum_definition
  [(modifiers) (access_modifier)]? @decl.modifiers
  name: (_) @enum.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  class_parameters: (class_parameters)? @decl.parameters
  body: (enum_body)? @decl.declaration_body) @decl.span

; `case A` and `case A(x: Int) extends E` are both declarations of an enum
; member and are named the same way.

(simple_enum_case
  name: (_) @enum_case.name) @decl.span

(full_enum_case
  name: (_) @enum_case.name
  type_parameters: (type_parameters)? @decl.type_parameters
  class_parameters: (class_parameters)? @decl.parameters) @decl.span

; `type T = ...` and the abstract `type T <: Bound`.

(type_definition
  [(modifiers) (opaque_modifier)]? @decl.modifiers
  name: (_) @type_alias.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  type: (_)? @decl.declared_type) @decl.span

; A type parameter is declared so that the type references inside the body
; have something of their own to resolve against.

(type_parameters
  name: (_) @type_parameter.name)

(covariant_type_parameter
  name: (_) @type_parameter.name)

(contravariant_type_parameter
  name: (_) @type_parameter.name)

; ---------------------------------------------------------------------------
; Namespaces: package, package object, object
; ---------------------------------------------------------------------------

(package_clause
  name: (package_identifier) @package.name @decl.name
  body: (template_body)? @decl.declaration_body) @decl.span

(package_object
  name: (_) @package_object.name @decl.name
  body: (template_body)? @decl.declaration_body) @decl.span

; A Scala `object` is a singleton namespace: the members it holds are reached
; through its name, which is what a Namespace answers.

(object_definition
  (modifiers)? @decl.modifiers
  name: (_) @object.name @decl.name
  body: (template_body)? @decl.declaration_body) @decl.span

; ---------------------------------------------------------------------------
; Callables
; ---------------------------------------------------------------------------

(function_definition
  (modifiers)? @decl.modifiers
  name: (_) @function.name @decl.name
  parameters: (type_parameters)? @decl.type_parameters
  parameters: (parameters)? @decl.parameters
  return_type: (_)? @decl.return_type
  body: (_)? @decl.function_body) @decl.span

; A `def` with no body: the member a subclass or given instance must supply.

(function_declaration
  (modifiers)? @decl.modifiers
  name: (_) @abstract_function.name @decl.name
  parameters: (type_parameters)? @decl.type_parameters
  parameters: (parameters)? @decl.parameters
  return_type: (_)? @decl.return_type) @decl.span

; ---------------------------------------------------------------------------
; Values
; ---------------------------------------------------------------------------

(given_definition
  (modifiers)? @decl.modifiers
  name: (_) @given.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  return_type: (_)? @decl.return_type) @decl.span

(val_definition
  (modifiers)? @decl.modifiers
  pattern: (identifier) @value.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

(val_declaration
  (modifiers)? @decl.modifiers
  name: (_) @value.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

(var_definition
  (modifiers)? @decl.modifiers
  pattern: (identifier) @variable.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

(var_declaration
  (modifiers)? @decl.modifiers
  name: (_) @variable.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

; A class parameter is the member a case class or a constructor names, and is
; referenced from the body by that name.

(class_parameter
  (modifiers)? @decl.modifiers
  name: (_) @field.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

(parameter
  name: (_) @parameter.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

; Lambda and for-comprehension bindings: `(x: Int) => ...` and `x => ...`.

(binding
  name: (identifier) @parameter.name @decl.name
  type: (_)? @decl.declared_type) @decl.span

(lambda_expression
  parameters: (identifier) @parameter.name @decl.span)

; ---------------------------------------------------------------------------
; What a type is built out of
; ---------------------------------------------------------------------------
;
; `extends A with B` and `derives Show` both state that this declaration
; supplies the interface of another type. Both are recorded under the one
; relation the host knows for that, named by the supertype so it resolves
; against the class or trait that declares it.

(extends_clause
  type: [(type_identifier) @implements.type
         (generic_type
           type: (type_identifier) @implements.type)
         (stable_type_identifier
           (type_identifier) @implements.type)])

(derives_clause
  type: [(type_identifier) @implements.type
         (stable_type_identifier
           (type_identifier) @implements.type)])

; ---------------------------------------------------------------------------
; References
; ---------------------------------------------------------------------------
;
; Every type identifier, wherever it stands -- a parameter type, a return type,
; a type argument, a `new`, an annotation -- is a reference to the class,
; trait, enum or type alias of that name. One pattern, one leaf node, and it is
; the reference that makes the declarations above reachable.

(type_identifier) @type.reference

; An applied name is a call. All four spellings of the applied thing are
; alternations of one pattern, so a call costs one match.

(call_expression
  function: [(identifier) @call.name
             (field_expression
               field: (identifier) @call.name)
             (generic_function
               function: (identifier) @call.name)
             (generic_function
               function: (field_expression
                 field: (identifier) @call.name))])

; `xs map f` is a method call spelled infix. Operator symbols are left out:
; `+` and `::` name no method a question could be asked about.

(infix_expression
  operator: (identifier) @call.name)

; ---------------------------------------------------------------------------
; Imports and exports
; ---------------------------------------------------------------------------
;
; `import a.b.C` -- the imported symbol is the last name in the path, so the
; anchor requires it to be the last named child. That is also what excludes
; the selector and wildcard forms, which are their own patterns below.

(import_declaration
  (identifier) @import.name .)

; `import a.b.{C, D => E, F as G}` -- one binding per selector, named by the
; name in the exporting namespace so it resolves there.

(import_declaration
  (namespace_selectors
    [(identifier) @import.name
     (as_renamed_identifier
       name: (identifier) @import.name)
     (arrow_renamed_identifier
       name: (identifier) @import.name)]))

; The local name a renamed selector introduces.

(import_declaration
  (namespace_selectors
    [(as_renamed_identifier
       alias: (identifier) @import.alias)
     (arrow_renamed_identifier
       alias: (identifier) @import.alias)]))

; `import a.b.*` / `import a.b._` -- no symbol is named, so what is recorded is
; the package the file depends on.

(import_declaration
  (namespace_wildcard)) @import.wildcard

(export_declaration
  (identifier) @export.name .)

(export_declaration
  (namespace_selectors
    [(identifier) @export.name
     (as_renamed_identifier
       name: (identifier) @export.name)
     (arrow_renamed_identifier
       name: (identifier) @export.name)]))

; ---------------------------------------------------------------------------
; Scala CLI `using` directives
; ---------------------------------------------------------------------------
;
; `//> using dep "org::lib:1.0"` is the one place a Scala source file states a
; dependency of its own. Only the dependency keys are taken; the predicate is
; tree-sitter's own `#any-of?`, which the runtime does apply.

(using_directive
  (using_directive_key) @using.key
  (using_directive_value) @using.value
  (#any-of? @using.key "dep" "lib" "test.dep" "compileOnly.dep" "plugin"))
