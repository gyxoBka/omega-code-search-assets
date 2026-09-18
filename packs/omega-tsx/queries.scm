; omega-tsx
;
; TSX is TypeScript plus JSX. Everything TypeScript declares -- classes,
; interfaces, type aliases, enums, functions, methods, fields, namespaces,
; imports and exports -- is declared here in the same words, with the same
; kinds and the same carrier names, because a `.tsx` file and a `.ts` file in
; one project declare the same vocabulary and an answer must not change shape
; because a component happens to live in the file. This Pack is
; `packs/omega-typescript/queries.scm` with one section added; where it departs
; from it, `pack-design/omega-tsx.md` says why.
;
; What JSX adds is one new answer: a tag that names a component is a use of the
; thing declared under that name elsewhere in the project. `<Counter step={2}/>`
; is a use of `Counter` and a use of the prop `step`. Both are stated so they
; resolve by name. A lowercase tag is an intrinsic element -- `div`, `span`,
; `circle` -- which names no declaration in any TypeScript file, so it is not
; stated at all, and neither are its attributes.
;
; Containment is not stated as a pattern. The tree already holds it, a nested
; declaration carries its container through the `within:` segment, and the
; extent of a class, an interface, a namespace or a function body is emitted
; once as a region.
;
; The signature of a declaration is carried on the declaration, not emitted on
; its own: a mention of `(a: string, b?: number)` resolves to nothing, while
; `omega.pack.parameter_shape` on the declaration is what a card prints.
;
; Test-runner shapes (`describe`, `it`, `test.each`), React's own hooks and
; router shapes, decorator metadata object literals and fluent builder chains
; are one library's call shape, not a TSX construct. They belong in an overlay
; under `frameworks/` and are not here.

; --- a class ---
;
; One match carries the declaration, its region and its type parameters.
; `abstract class` is the same declaration with the same questions asked of
; it, so it is a branch of this pattern and not a second kind.

[(class_declaration
   name: (type_identifier) @class.name
   type_parameters: (type_parameters)? @class.type_parameters
   body: (class_body) @class.body) @class
 (abstract_class_declaration
   name: (type_identifier) @class.name
   type_parameters: (type_parameters)? @class.type_parameters
   body: (class_body) @class.body) @class]

; --- what a class extends and implements ---
;
; A qualified base (`ns.Base`, `M.Base`) is reduced to its last identifier so
; that it is spelled the way the declaration of that class or interface is
; spelled. `extends` and `implements` are both stated as `relation.implements`:
; the host knows six relations and this is the subtype edge among them.

(class_heritage
  [(extends_clause
     value: [(identifier) @heritage.name
             (member_expression property: (property_identifier) @heritage.name)])
   (implements_clause
     [(type_identifier) @heritage.name
      (nested_type_identifier name: (type_identifier) @heritage.name)
      (generic_type
        name: [(type_identifier) @heritage.name
               (nested_type_identifier name: (type_identifier) @heritage.name)])])])

; --- an interface ---

(interface_declaration
  name: (type_identifier) @interface.name
  type_parameters: (type_parameters)? @interface.type_parameters
  body: (interface_body) @interface.body) @interface

(extends_type_clause
  type: [(type_identifier) @heritage.name
         (nested_type_identifier name: (type_identifier) @heritage.name)
         (generic_type
           name: [(type_identifier) @heritage.name
                  (nested_type_identifier name: (type_identifier) @heritage.name)])])

; --- a type alias ---

(type_alias_declaration
  name: (type_identifier) @type_alias.name
  type_parameters: (type_parameters)? @type_alias.type_parameters) @type_alias

; --- an enum, and the named constants in it ---
;
; `enum E { A, B = 2 }` declares E and two constants. A bare member is a
; direct child of the body; an assigned one sits under `enum_assignment`.

(enum_declaration name: (identifier) @enum.name) @enum

(enum_assignment name: (property_identifier) @constant.name) @constant

(enum_body (property_identifier) @constant.name @constant)

; --- a function ---

[(function_declaration
   name: (identifier) @function.name
   type_parameters: (type_parameters)? @function.type_parameters
   parameters: (formal_parameters) @function.parameters
   return_type: (_)? @function.return_type
   body: (statement_block) @function.body) @function
 (generator_function_declaration
   name: (identifier) @function.name
   type_parameters: (type_parameters)? @function.type_parameters
   parameters: (formal_parameters) @function.parameters
   return_type: (_)? @function.return_type
   body: (statement_block) @function.body) @function]

; --- a function declared without a body ---
;
; An overload head and a `declare function` are both `function_signature`.
; They declare the same function under the same name, which is why the Pack
; states a function per signature and leaves the overload set to the reader.

(function_signature
  name: (identifier) @function_signature.name
  type_parameters: (type_parameters)? @function_signature.type_parameters
  parameters: (formal_parameters) @function_signature.parameters
  return_type: (_)? @function_signature.return_type) @function_signature

; --- a method ---

(method_definition
  (accessibility_modifier)? @method.visibility
  name: [(property_identifier) (private_property_identifier)] @method.name
  type_parameters: (type_parameters)? @method.type_parameters
  parameters: (formal_parameters) @method.parameters
  return_type: (_)? @method.return_type
  body: (statement_block) @method.body) @method

; --- a method declared without a body ---
;
; An interface member and an `abstract` class member.

[(method_signature
   name: [(property_identifier) (private_property_identifier)] @method_signature.name
   type_parameters: (type_parameters)? @method_signature.type_parameters
   parameters: (formal_parameters) @method_signature.parameters
   return_type: (_)? @method_signature.return_type) @method_signature
 (abstract_method_signature
   name: [(property_identifier) (private_property_identifier)] @method_signature.name
   type_parameters: (type_parameters)? @method_signature.type_parameters
   parameters: (formal_parameters) @method_signature.parameters
   return_type: (_)? @method_signature.return_type) @method_signature]

; --- a field of a class ---

(public_field_definition
  (accessibility_modifier)? @field.visibility
  name: [(property_identifier) (private_property_identifier)] @field.name
  type: (type_annotation)? @field.type) @field

; --- a property of an interface or object type ---

(property_signature
  name: [(property_identifier) (private_property_identifier)] @property.name
  type: (type_annotation)? @property.type) @property

; --- a parameter property ---
;
; `constructor(private readonly repo: Repo)` declares a field of the class.
; It is TypeScript's own shorthand and nothing else in the file names that
; field, so it is declared here and nowhere else.

[(required_parameter
   (accessibility_modifier) @parameter_property.visibility
   pattern: (identifier) @parameter_property.name
   type: (type_annotation)? @parameter_property.type) @parameter_property
 (optional_parameter
   (accessibility_modifier) @parameter_property.visibility
   pattern: (identifier) @parameter_property.name
   type: (type_annotation)? @parameter_property.type) @parameter_property]

; --- a name declared at module scope ---
;
; The constants, configuration objects and arrow functions a module holds at
; its top level, whether exported, plain or ambient. Names bound inside a
; function body are deliberately absent: they resolve to nothing outside their
; own block and there are more of them in a repository than of everything else
; here put together.

[(program
   (lexical_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (program
   (variable_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (export_statement
   declaration: (lexical_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (export_statement
   declaration: (variable_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (ambient_declaration
   (lexical_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (ambient_declaration
   (variable_declaration
     (variable_declarator name: (identifier) @variable.name) @variable))
 (module
   body: (statement_block
     (lexical_declaration
       (variable_declarator name: (identifier) @variable.name) @variable)))
 (internal_module
   body: (statement_block
     (lexical_declaration
       (variable_declarator name: (identifier) @variable.name) @variable)))]

; --- a namespace ---
;
; `namespace X {}` is an `internal_module`, the older `module X {}` a `module`;
; they declare the same thing.

[(internal_module
   name: [(identifier) (nested_identifier)] @namespace.name
   body: (statement_block)? @namespace.body) @namespace
 (module
   name: [(identifier) (nested_identifier)] @namespace.name
   body: (statement_block)? @namespace.body) @namespace]

; --- an ambient module ---
;
; `declare module "koa" { ... }`. The name is the module path, so the quotes
; are taken off and it is spelled the way an import of it is spelled.

(module
  name: (string (string_fragment) @ambient_module.name)
  body: (statement_block)? @ambient_module.body) @ambient_module

; --- what a file imports ---
;
; The module path is kept exactly as written, relative dots and all: turning
; `./util` into a file means knowing `tsconfig` paths, and the compiler can
; be told to rewrite them.

(import_statement source: (string (string_fragment) @import.module))

; A local name bound by an import, together with the module it came from.
; The module specifier has to be captured in the same pattern as the name:
; the host reads an external package only from a binding carrying a field
; literally called `qualifier`, and a template can only reference captures
; from its own match.

(import_statement
  (import_clause (identifier) @import.local.default)
  source: (string (string_fragment) @import.qualifier))

(import_statement
  (import_clause (namespace_import (identifier) @import.local.namespace))
  source: (string (string_fragment) @import.qualifier))

(import_statement
  (import_clause
    (named_imports
      (import_specifier name: (identifier) @import.local.symbol)))
  source: (string (string_fragment) @import.qualifier))

; One specifier, with or without `as`: the symbol taken from the module, and
; the local name it is bound to, which is what answers "what is `fs`".

(import_specifier
  name: (identifier) @import.symbol
  alias: (identifier)? @import.alias)

; `import fs = require("fs")`, the TypeScript spelling of a CommonJS import.

(import_require_clause
  (identifier) @import.require.name
  source: (string (string_fragment) @import.require.module))

; `import A = B.C`, an alias for a namespace member.

(import_alias
  .
  (identifier) @import_alias.name
  .
  [(identifier) @import_alias.target
   (nested_identifier property: (property_identifier) @import_alias.target)])

; `require("x")` and `import("x")`, the two call forms of a dependency.

(call_expression
  function: (identifier) @_require
  arguments: (arguments (string (string_fragment) @import.module))
  (#eq? @_require "require"))

(call_expression
  function: (import)
  arguments: (arguments (string (string_fragment) @import.module)))

; `const fs = require("fs")` binds a whole module to one name, which is what a
; namespace import does; CommonJS is how every Node file written before ESM
; names its dependencies, so the binding has to carry its qualifier too.

(variable_declarator
  name: (identifier) @import.local.require
  value: (call_expression
    function: (identifier) @_require.fn
    arguments: (arguments (string (string_fragment) @import.qualifier)))
  (#eq? @_require.fn "require"))

; --- what a file exports ---
;
; The barrel file -- `export { Foo } from "./foo"` -- is how a TypeScript
; package states its surface, so both halves are stated: the name that leaves
; this module, and the module it is re-exported from.

(export_specifier
  name: (identifier) @export.name
  alias: (identifier)? @export.alias)

(export_statement source: (string (string_fragment) @import.module))

(export_statement (namespace_export (identifier) @export.name))

(export_statement value: (identifier) @export.name)

; --- a call ---
;
; The span is the name that is called, not the call with its arguments: a
; mention is the bytes that name the thing. The argument list is captured
; beside it, because a call's positional arguments are the one thing every
; framework overlay asks a call for -- a route's URL, a registration's prefix,
; a service token -- and they are already there, as the ordered children of the
; node the call names them in.

(call_expression
  function: (identifier) @call.function
  arguments: (arguments) @call.args)

(call_expression
  function: (member_expression
    object: (_) @call.receiver
    property: (property_identifier) @call.method)
  arguments: (arguments) @call.args)

(new_expression
  constructor: [(identifier) @call.constructor
                (member_expression property: (property_identifier) @call.constructor)]
  arguments: (arguments) @call.args)

; --- a decorator ---
;
; `@Component`, `@Injectable()`, `@ng.Input()`. Named by the last identifier,
; so it resolves to the declaration of the decorator itself. What the
; decorator does with its argument is the overlay's business, not this Pack's.

(decorator
  [(identifier) @decorator.name
   (member_expression property: (property_identifier) @decorator.name)
   (call_expression function: (identifier) @decorator.name)
   (call_expression
     function: (member_expression property: (property_identifier) @decorator.name))])

; --- a type, wherever it is written ---
;
; Every type mention in TypeScript reaches a `type_identifier`, at any depth of
; union, intersection, array, tuple, conditional, mapped or generic type, and
; in every position: an annotation, a type argument, a constraint, a default, a
; predicate, an `as` or a `satisfies`. One capture states them all without
; naming a single container.

(type_identifier) @type.name

; --- a component used as a tag ---
;
; JSX resolves a tag by its case: a capitalised name is a value in scope, a
; lowercase one is an intrinsic element that no source file declares. So only
; the capitalised form is stated, and it is named by the identifier alone so
; that it resolves onto the `const Counter = ...` or `function Counter()` that
; declares it.
;
; The closing tag of the same element is deliberately not stated: it names the
; same component at the same call site and would double every count.

(jsx_opening_element
  name: (identifier) @jsx.component
  (#match? @jsx.component "^[A-Z]"))

(jsx_self_closing_element
  name: (identifier) @jsx.component
  (#match? @jsx.component "^[A-Z]"))

; `<Icons.Chevron />`. A dotted tag is always a component -- an intrinsic
; element cannot be spelled with a dot -- so no case test is needed, and it is
; reduced to its last segment the way a qualified base class is.

[(jsx_opening_element
   name: (member_expression property: (property_identifier) @jsx.component))
 (jsx_self_closing_element
   name: (member_expression property: (property_identifier) @jsx.component))]

; --- a prop passed to a component ---
;
; `step` in `<Counter step={2}/>` is a use of the property declared as `step`
; in that component's props type, so it is stated under that spelling. The tag
; is captured only to test its case; nothing reads `@_tag`. Attributes of an
; intrinsic element are HTML attribute names and resolve to no declaration, so
; they are not stated. The value of the prop is not stated: it is an ordinary
; expression and whatever it names is already covered by the call and type
; patterns above.

(jsx_opening_element
  name: (identifier) @_tag
  attribute: (jsx_attribute . (property_identifier) @jsx.prop)
  (#match? @_tag "^[A-Z]"))

(jsx_self_closing_element
  name: (identifier) @_tag
  attribute: (jsx_attribute . (property_identifier) @jsx.prop)
  (#match? @_tag "^[A-Z]"))
