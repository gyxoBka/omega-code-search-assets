; omega-php
;
; PHP is the language of web applications: a repository of it is namespaces of
; classes, interfaces, traits and enums, their methods and properties, a few
; free functions, and the `use` lines that wire them together. The questions
; asked of it are: where is this class declared, what does it extend or
; implement, what are its members and their visibility, who calls this method,
; who reads this property, and what does this file import.
;
; Containment is never stated as a pattern: the tree holds it, a declaration
; nested in a class carries its owner through the `within:` segment, and the
; extent of a class or a function body is emitted once as a region.
;
; Names are stored the way a reference to them is spelled. A qualified name is
; reduced to its last segment, because that is what `use` puts in scope and
; what every mention in the file then writes. A property is stored without its
; `$`, because `$this->name` spells it that way; a parameter, a captured
; variable and a global keep their `$`, because every mention of them does.

; --- a class, an interface, a trait, an enum ---
;
; One pattern per declaration. The declaration and the region of its body are
; two templates over the one match.

(class_declaration
  name: (name) @class.name
  body: (declaration_list) @class.body) @class

(interface_declaration
  name: (name) @interface.name
  body: (declaration_list) @interface.body) @interface

(trait_declaration
  name: (name) @trait.name
  body: (declaration_list) @trait.body) @trait

(enum_declaration
  name: (name) @enum.name
  body: (enum_declaration_list) @enum.body) @enum

(enum_case
  name: (name) @case.name) @case

; --- what a type declaration inherits ---
;
; `extends`, `implements` and a trait `use` inside a class body are the three
; ways PHP says one type is built out of another. All three are stated as the
; one relation the host knows.

(base_clause
  [(name) (qualified_name) (relative_name)] @extends.name)

(class_interface_clause
  [(name) (qualified_name) (relative_name)] @implements.name)

(use_declaration
  [(name) (qualified_name) (relative_name)] @trait.use.name)

; --- a method ---
;
; The name and the parameter list are required, so they are one pattern with
; the declaration itself. The body, the return type and the visibility are
; optional -- an interface method has no body, a method may have no declared
; return type -- and an optional capture in the pattern above would change
; which nodes match, so each is its own pattern over the same node.

(method_declaration
  name: (name) @method.name
  parameters: (formal_parameters) @method.parameters) @method

(method_declaration
  name: (name) @method.body.name
  body: (compound_statement) @method.body)

(method_declaration
  return_type: (_) @method.return_type) @method.return.owner

; PHP 8.4 asymmetric visibility puts two visibility modifiers on one member
; (`public private(set) string $x`). The second one governs writing and is
; spelled with parentheses; the read visibility is the one a card wants, so the
; parenthesised form is excluded rather than left to overwrite it.

((method_declaration
   (visibility_modifier) @method.visibility) @method.visibility.owner
 (#not-match? @method.visibility "[(]"))

; --- a function ---

(function_definition
  name: (name) @function.name
  parameters: (formal_parameters) @function.parameters
  body: (compound_statement) @function.body) @function

(function_definition
  return_type: (_) @function.return_type) @function.return.owner

; --- a property and a class constant ---
;
; `public ?Foo $a, $b;` declares two properties that share one type and one
; visibility, so each of the three facts is stated against the individual
; `property_element`, which is where the declaration sits.

(property_declaration
  (property_element
    name: (variable_name (name) @property.name)) @property)

(property_declaration
  type: (_) @property.type
  (property_element) @property.type.target)

((property_declaration
   (visibility_modifier) @property.visibility
   (property_element) @property.visibility.target)
 (#not-match? @property.visibility "[(]"))

(const_declaration
  (const_element . (name) @constant.name) @constant)

; --- parameters ---
;
; A promoted constructor parameter declares a property, not a parameter, and is
; stated as one so that `$this->x` resolves to it.

(simple_parameter
  name: (variable_name) @parameter.name) @parameter

(variadic_parameter
  name: (variable_name) @parameter.variadic.name) @parameter.variadic

(property_promotion_parameter
  name: (variable_name (name) @promoted.name)) @promoted

((property_promotion_parameter
   visibility: (visibility_modifier) @promoted.visibility) @promoted.visibility.owner
 (#not-match? @promoted.visibility "[(]"))

(property_promotion_parameter
  type: (_) @promoted.type) @promoted.type.owner

; --- the namespace ---

(namespace_definition
  name: (namespace_name) @namespace.name) @namespace

(namespace_definition
  name: (namespace_name) @namespace.body.name
  body: (compound_statement) @namespace.body)

; --- what the file imports ---
;
; `use App\Models\User;` is stored under `User`: that is the name the rest of
; the file writes and the name the declaration carries. An alias is stored
; separately under the alias, for the same reason.

; The target is anchored as the clause's first named child: an alias is a
; `name` child of the same clause, and without the anchor `use A\B as C` is
; imported twice, once under `B` and once under `C`.

(namespace_use_clause
  . [(name) (qualified_name)] @use.target) @use.clause

(namespace_use_clause
  alias: (name) @use.alias)

; `include`/`require` name a file rather than a symbol. Only the literal-string
; form is stated; a computed path is not a name anything can resolve.

[(include_expression (string (string_content) @include.path))
 (include_once_expression (string (string_content) @include.path))
 (require_expression (string (string_content) @include.path))
 (require_once_expression (string (string_content) @include.path))] @include

; --- calls ---
;
; PHP spells the four call forms as four node types, so a method call can never
; be confused with a property read here.

(function_call_expression
  function: [(name) (qualified_name) (relative_name)] @call.function.name) @call.function

(member_call_expression
  name: (name) @call.method.name) @call.method

(nullsafe_member_call_expression
  name: (name) @call.nullsafe.name) @call.nullsafe

(scoped_call_expression
  name: (name) @call.static.name) @call.static

(object_creation_expression
  . [(name) (qualified_name) (relative_name)] @new.class) @new

; --- where a class is named ---
;
; The left-hand side of `::` in a static call, a static property access and a
; class-constant access, including `Foo::class`.

(scoped_call_expression
  scope: [(name) (qualified_name) (relative_name)] @scoped.class)

(scoped_property_access_expression
  scope: [(name) (qualified_name) (relative_name)] @scoped.property.class)

(class_constant_access_expression
  . [(name) (qualified_name) (relative_name)] @const_access.class)

; The constant on the right of `::`. `Foo::class` is the class, not a constant,
; and is already stated by the pattern above.

((class_constant_access_expression
   . (_) . (name) @const_access.name) @const_access
 (#not-eq? @const_access.name "class"))

; --- where a property is read ---

(member_access_expression
  name: (name) @property.access.name) @property.access

(nullsafe_member_access_expression
  name: (name) @property.nullsafe.name) @property.nullsafe

(scoped_property_access_expression
  name: (variable_name (name) @scoped.property.name)) @scoped.property

; --- a declared type ---
;
; Every authored type hint: a parameter type, a return type, a property type
; and a `catch` type all reach the tree as `named_type`.

; `static`, `self` and `parent` in a type position name whichever class is
; running, not a declaration, so they are not stated as type mentions.

((named_type
   [(name) (qualified_name) (relative_name)] @type.reference) @type.use
 (#not-any-of? @type.reference "static" "self" "parent"))

; --- an attribute ---
;
; `#[Foo(...)]` names a class. What any particular attribute means belongs to a
; framework overlay; that it is used here does not.

(attribute
  . [(name) (qualified_name) (relative_name)] @attribute.name) @attribute

; `reference.attribute_applied` -- the same attribute carrying what it was
; given. `#[Route('/orders/{id}')]` is where a Symfony URL is stated, and the
; argument list is the only place it appears. A second emission on the same
; span rather than a field on `reference.attribute`, so a rule matching the
; plain kind does not fire twice; read it with `fact_join_by_span` `relation:
; "same"`.

(attribute
  . [(name) (qualified_name) (relative_name)] @attribute.applied.name
  parameters: (arguments) @call.args) @attribute.applied

; --- the two places a variable crosses a scope boundary ---
;
; Ordinary variable reads are not stated: `(variable_name)` is every `$x` in
; every file, and a Pack that emits it stores the file instead of answering a
; question. `global` and a closure's `use` clause are different: each names a
; variable that is declared somewhere else.

(global_declaration
  (variable_name) @global.name) @global

(anonymous_function_use_clause
  (variable_name) @closure.capture) @closure.use
