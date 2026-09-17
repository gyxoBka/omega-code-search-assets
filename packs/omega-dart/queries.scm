; omega-dart
;
; Dart is the language of Flutter applications, CLI tools and packages. The
; questions asked of a Dart file are: what does it declare, what type does a
; declaration extend or implement, what does it import and export, what type
; does a piece of code use, and who calls this member. Every pattern below
; answers one of them.
;
; Containment is deliberately not stated. A method inside a class, a class
; inside a library -- the tree already holds all of it, and a declaration
; nested inside another carries its container through the `within:` segment.
; No pattern here names a node by a container: every name is an identifier,
; or a short shape derived from one signature's own text.

; --- types the language declares ---

(class_definition
  name: (identifier) @class.name
  type_parameters: (type_parameters)? @class.type_parameters) @class

; `abstract`, `base`, `sealed`, `interface`, `mixin` before `class`. Its own
; pattern, so a class with two modifiers is not declared twice.
(class_definition
  [(abstract) (base) (sealed) (interface) (mixin)] @class.modifier) @class.modifier.owner

(mixin_declaration
  (mixin) . (identifier) @mixin.name) @mixin

(enum_declaration
  name: (identifier) @enum.name) @enum

; A `Color.red` is a value of the enum, not a type of its own.
(enum_constant
  name: (identifier) @constant.name) @constant

; `extension Foo on Bar` names a group of members; it cannot be written as a
; type annotation, so it is not declared as one.
(extension_declaration
  name: (identifier) @extension.name) @extension

; `extension type Meters(int value)` is a type, and its representation is the
; one field it declares.
(extension_type_declaration
  name: (identifier) @extension_type.name
  representation: (representation_declaration
                    name: (identifier) @extension_type.field)) @extension_type

(type_alias
  "typedef" . (type_identifier) @type_alias.name) @type_alias

; --- callables ---
;
; One pattern per signature node, and the parameter list and return type are
; carried onto the declaration at the same span rather than emitted apart.
; `function_signature` covers a top-level function, a method and a local
; function alike: all three are callables, and the tree says which is which.

(function_signature
  [(type_identifier) (nullable_type) (void_type)
   (function_type) (record_type)]? @function.return_type
  name: (identifier) @function.name
  (type_parameters)? @function.type_parameters
  (formal_parameter_list) @function.parameters) @function

(getter_signature
  [(type_identifier) (nullable_type) (void_type)
   (function_type) (record_type)]? @getter.return_type
  name: (identifier) @getter.name) @getter

(setter_signature
  name: (identifier) @setter.name
  (formal_parameter_list) @setter.parameters) @setter

; The operator itself is an anonymous token whose text varies, so the
; signature is captured whole and the name is taken from its text.
(operator_signature
  (formal_parameter_list) @operator.parameters) @operator

; The four constructor spellings share their templates: `Foo(...)`,
; `const Foo(...)`, `factory Foo.of(...)` and `const factory Foo.of(...) = _F`.
; The name field is a sequence (`Foo` `.` `of`), so the name is read from the
; signature's own text up to the parameter list.
(constructor_signature
  parameters: (formal_parameter_list) @constructor.parameters) @constructor

(constant_constructor_signature
  (formal_parameter_list) @constructor.parameters) @constructor

(factory_constructor_signature
  (formal_parameter_list) @constructor.parameters) @constructor

(redirecting_factory_constructor_signature
  (formal_parameter_list) @constructor.parameters) @constructor

; --- fields and top-level variables ---
;
; `initialized_variable_definition` -- the single `var x = …` inside a body --
; is deliberately not here: it binds a name for one body and resolves to
; nothing outside it.

(initialized_identifier
  . (identifier) @variable.name) @variable

(static_final_declaration
  . (identifier) @variable.name) @variable

(identifier_list
  (identifier) @variable.name) @variable

; --- the library and what it pulls in ---

(library_name
  (dotted_identifier_list) @library.name) @library

(import_specification
  [(uri (string_literal) @import.uri)
   (configurable_uri (uri (string_literal) @import.uri))]
  (identifier)? @import.prefix) @import

(combinator (identifier) @import.symbol)

(library_export
  (configurable_uri (uri (string_literal) @export.uri))) @export

(part_directive (uri (string_literal) @part.uri)) @part

(part_of_directive (uri (string_literal) @part.uri)) @part

(part_of_directive (dotted_identifier_list) @part_of.library) @part_of

; --- what a type is built from ---
;
; `extends`, `with`, `implements` and a mixin's `on` clause all say that one
; type is defined in terms of another. One pattern, rooted at the clause, so
; `implements A, B, C` is three mentions and not three copies of the class.

[(superclass (type_identifier) @supertype)
 (mixins (type_identifier) @supertype)
 (interfaces (type_identifier) @supertype)
 (mixin_declaration (type_identifier) @supertype)]

; --- what the code refers to ---

(type_identifier) @type.reference

(annotation
  name: [(identifier) @annotation.name
         (scoped_identifier name: (identifier) @annotation.name)]) @annotation

; --- calls ---
;
; Dart has no call node: a call is an identifier followed immediately by a
; selector carrying an argument list. The anchors matter -- without them
; `a.b()` also reads as a call to `a`.

((identifier) @call.function.name
  . (selector (argument_part (arguments))))

((selector
   [(unconditional_assignable_selector (identifier) @call.method.name)
    (conditional_assignable_selector (identifier) @call.method.name)])
  . (selector (argument_part (arguments))))

(cascade_section
  (cascade_selector (identifier) @call.method.name)
  (argument_part (arguments)))

; `Foo(...)`, `new Foo(...)`, `const Foo(...)` and `this.Foo(...)` name the
; type being constructed.

(new_expression (type_identifier) @call.constructor.name)

(const_object_expression (type_identifier) @call.constructor.name)

(constructor_invocation (type_identifier) @call.constructor.name)
