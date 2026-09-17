; omega-java
;
; Java is the language of typed, named, nested declarations. Almost every
; question asked of a Java file is "where is this name declared, what is its
; shape, and who mentions it": where is class `OrderService`, what does
; `process` take and return, what does this class extend, which type does this
; file import, which module requires which.
;
; So the Pack declares every named thing Java has, carries the four pieces a
; signature is built from onto the declaration that owns them, and states the
; three links Java gives for free -- inheritance, imports and type mentions.
;
; Containment is not stated as a pattern. The tree already holds it; a
; declaration nested in a class carries that class through the `within:`
; segment, and a body's extent is one `scope.*` region.
;
; Captures are one shared namespace. `@decl.span` is the declaration being
; stated, `@decl.name` its name, and `@decl.modifiers` / `@decl.type_parameters`
; / `@decl.parameters` / `@decl.return_type` / `@decl.declared_type` the pieces
; that are carried onto it. A per-construct name capture (`@class.name`,
; `@method.name`, ...) selects which declaration template runs: a template whose
; captures this match did not bind is skipped, so one set of carrier templates
; serves every declaration below.

; ---------------------------------------------------------------- types ----

(class_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @class.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  body: (class_body) @decl.declaration_body) @decl.span

(interface_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @interface.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  body: (interface_body) @decl.declaration_body) @decl.span

(enum_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @enum.name @decl.name
  body: (enum_body) @decl.declaration_body) @decl.span

; A record's header is its parameter shape as well as its constructor's.
(record_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @record.name @decl.name
  type_parameters: (type_parameters)? @decl.type_parameters
  parameters: (formal_parameters) @decl.parameters
  body: (class_body) @decl.declaration_body) @decl.span

(annotation_type_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @annotation_type.name @decl.name
  body: (annotation_type_body) @decl.declaration_body) @decl.span

; A type parameter declares a name that `(type_identifier)` mentions resolve to.
(type_parameter
  (type_identifier) @type_parameter.name @decl.name) @decl.span

; ------------------------------------------------------------ callables ----

(method_declaration
  (modifiers)? @decl.modifiers
  type_parameters: (type_parameters)? @decl.type_parameters
  type: (_) @decl.return_type
  name: (identifier) @method.name @decl.name
  parameters: (formal_parameters) @decl.parameters
  body: (block)? @decl.function_body) @decl.span

(constructor_declaration
  (modifiers)? @decl.modifiers
  type_parameters: (type_parameters)? @decl.type_parameters
  name: (identifier) @constructor.name @decl.name
  parameters: (formal_parameters) @decl.parameters
  body: (constructor_body) @decl.function_body) @decl.span

(compact_constructor_declaration
  (modifiers)? @decl.modifiers
  name: (identifier) @compact_constructor.name @decl.name
  body: (block) @decl.function_body) @decl.span

; An `@interface` member is a method with a type and an optional default.
(annotation_type_element_declaration
  (modifiers)? @decl.modifiers
  type: (_) @decl.return_type
  name: (identifier) @annotation_element.name @decl.name) @decl.span

; --------------------------------------------------------------- values ----
;
; The span of a field or a local is its own declarator, not the statement: two
; names declared in one `int a, b;` are two declarations, and a carrier folds
; onto the declaration standing at its own span.

(field_declaration
  (modifiers)? @decl.modifiers
  type: (_) @decl.declared_type
  declarator: (variable_declarator
    name: (identifier) @field.name @decl.name) @decl.span)

(constant_declaration
  (modifiers)? @decl.modifiers
  type: (_) @decl.declared_type
  declarator: (variable_declarator
    name: (identifier) @constant.name @decl.name) @decl.span)

(enum_constant
  (modifiers)? @decl.modifiers
  name: (identifier) @enumerator.name @decl.name
  body: (class_body)? @decl.declaration_body) @decl.span

(local_variable_declaration
  (modifiers)? @decl.modifiers
  type: (_) @decl.declared_type
  declarator: (variable_declarator
    name: (identifier) @variable.name @decl.name) @decl.span)

(formal_parameter
  (modifiers)? @decl.modifiers
  type: (_) @decl.declared_type
  name: (identifier) @parameter.name @decl.name) @decl.span

(spread_parameter
  (variable_declarator
    name: (identifier) @parameter.name @decl.name)) @decl.span

(catch_formal_parameter
  (catch_type) @decl.declared_type
  name: (identifier) @variable.name @decl.name) @decl.span

(resource
  type: (_) @decl.declared_type
  name: (identifier) @variable.name @decl.name) @decl.span

; The loop variable's own bytes are the declaration; the loop is not.
(enhanced_for_statement
  type: (_) @decl.declared_type
  name: (identifier) @variable.name @decl.name @decl.span)

; Pattern bindings: `o instanceof String s`, `case Point p`, `case Point(int x, _)`.
(instanceof_expression
  name: (identifier) @variable.name @decl.name @decl.span)

(type_pattern
  (identifier) @variable.name @decl.name) @decl.span

(record_pattern_component
  (identifier) @variable.name @decl.name) @decl.span

; ---------------------------------------------------- packages and modules ----

(package_declaration
  [(identifier) (scoped_identifier)] @package.name) @package

(module_declaration
  name: (_) @module.name
  body: (module_body) @module.body) @module

(requires_module_directive
  module: (_) @requires.name) @requires

(exports_module_directive
  package: (_) @exports.name) @exports

(opens_module_directive
  package: (_) @opens.name) @opens

(uses_module_directive
  type: (_) @uses.name) @uses

; `provides S with Impl` is the one place a module file states an
; implementation relation, once per provider.
(provides_module_directive
  provided: (_) @provides.name
  provider: (_) @provides.span)

; -------------------------------------------------------------- imports ----
;
; An import is stated under the simple name it brings into scope, so it
; resolves against the declaration of that type. The trailing anchor keeps the
; on-demand form `import a.b.*;` out of this pattern.

(import_declaration
  (scoped_identifier name: (identifier) @import.name) .) @import

(import_declaration
  (scoped_identifier) @import.package.name
  (asterisk)) @import.package

; --------------------------------------------------------- inheritance ----
;
; The name is the span: a supertype is named by the leaf that carries its
; simple name, in all three spellings a type list admits.

(superclass
  [(type_identifier) @extends.name
   (generic_type (type_identifier) @extends.name)
   (scoped_type_identifier (type_identifier) @extends.name .)])

(super_interfaces
  (type_list
    [(type_identifier) @implements.name
     (generic_type (type_identifier) @implements.name)
     (scoped_type_identifier (type_identifier) @implements.name .)]))

(extends_interfaces
  (type_list
    [(type_identifier) @implements.name
     (generic_type (type_identifier) @implements.name)
     (scoped_type_identifier (type_identifier) @implements.name .)]))

; ------------------------------------------------------------ mentions ----
;
; Every type mention is an answer someone wants, and `type_identifier` is the
; node Java gives one at: a field's type, a parameter's type, a throws clause,
; a cast, a type argument, a catch type.

(type_identifier) @type.reference

; An annotation is a mention of the annotation interface it names. Its element
; values are deliberately not read -- see the coverage guard.
[(marker_annotation name: [(identifier) (scoped_identifier)] @annotation.name)
 (annotation name: [(identifier) (scoped_identifier)] @annotation.name)] @annotation

(method_invocation
  name: (identifier) @call.name) @call

(object_creation_expression
  type: [(type_identifier) @new.name
         (generic_type (type_identifier) @new.name)
         (scoped_type_identifier (type_identifier) @new.name .)]) @new

; `String::valueOf`, `this::handle`. `Foo::new` has no identifier to name and
; is left to the `type_identifier` mention above.
(method_reference
  (identifier) @method_ref.name .) @method_ref

(field_access
  field: (identifier) @field_access.name) @field_access
