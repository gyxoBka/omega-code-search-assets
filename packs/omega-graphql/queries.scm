; omega-graphql
;
; One grammar, two languages. A `.graphql` file is either a schema -- the
; types, fields, arguments and directives an API offers -- or an executable
; document: the operations and fragments a client sends. The questions asked
; of them are: where is this type defined, what fields does it have, what type
; does a field return, who uses this type, where is this fragment declared and
; where is it spread, and which schema field does this selection reach.
;
; Containment is deliberately not stated. A field nested in a type already
; carries its type through the host's `within:` segment, and a pattern per
; nesting level costs one match per tuple of nodes at that level.
;
; Two patterns are rooted at a parent on purpose: `input_value_definition` is
; the same node for a field argument and for an input object's field, and only
; its parent says which. That is disambiguation, not containment -- neither
; pattern states anything about the parent.

; --- the six type definitions ---
;
; Every one of these names a type, and every kind below carries a word from
; the host's Type vocabulary, so all six land in the Type family.

(object_type_definition (name) @object_type.name) @object_type

(interface_type_definition (name) @interface.name) @interface

(union_type_definition (name) @union.name) @union

(enum_type_definition (name) @enum.name) @enum

(input_object_type_definition (name) @input_type.name) @input_type

(scalar_type_definition (name) @scalar.name) @scalar

; --- extending a type ---
;
; `extend type Query { me: User }` is how a federated subgraph declares its
; part of a root type, and in a schema split across files it may be the only
; declaration of that type in this repository. So an extension is a
; declaration under the same name, not a reference to one: the fields inside
; it then have an enclosing declaration to hang from.

[
  (object_type_extension (name) @extension.name)
  (interface_type_extension (name) @extension.name)
  (input_object_type_extension (name) @extension.name)
  (enum_type_extension (name) @extension.name)
  (scalar_type_extension (name) @extension.name)
  (union_type_extension (name) @extension.name)
] @extension

; --- a field of an object type, an interface, or either one's extension ---
;
; One pattern reaches all of them, because `field_definition` is the same node
; everywhere. Three templates over the one match: the field itself, its
; arguments as the signature's parameter shape, and its type as the return
; type. A GraphQL field *is* the call: `user(id: ID!): User` reads on a card
; exactly as a function does.

(field_definition
  (name) @field.name
  (arguments_definition)? @field.arguments
  (type) @field.type) @field

; --- an argument ---
;
; The same node under `arguments_definition` is an argument of a field or of a
; directive; under `input_fields_definition` it is a field of an input object.
; They answer different questions and are named apart.

(arguments_definition
  (input_value_definition
    (name) @argument.name
    (type) @argument.type) @argument)

(input_fields_definition
  (input_value_definition
    (name) @input_field.name
    (type) @input_field.type) @input_field)

; --- an enum member ---
;
; A member is a constant, not a type. Any kind with the word `enum` in it is
; filed under Type by the host, so the word is left out deliberately.

(enum_value_definition (enum_value (name) @enum_member.name)) @enum_member

; --- a directive declaration ---
;
; Where it may be written is the whole of what a directive declaration says
; that its name does not, so the locations are carried on the declaration.

(directive_definition
  (name) @directive.name
  (directive_locations) @directive.locations) @directive

; --- the schema's roots ---
;
; `schema { query: Query, mutation: Mutation }`, and the same node inside
; `extend schema`. This is the one piece of configuration a GraphQL document
; holds: which type answers which kind of operation.

(root_operation_type_definition
  (operation_type) @schema.root.operation
  (named_type (name) @schema.root.type)) @schema.root

; --- an executable document ---
;
; A named operation declares itself; the variables it takes are its parameter
; shape. An anonymous `{ ... }` operation declares nothing and does not match:
; it binds neither the operation type nor a name.

(operation_definition
  (operation_type) @operation.type
  (name) @operation.name
  (variable_definitions)? @operation.variables) @operation

(fragment_definition (fragment_name (name) @fragment.name)) @fragment

(variable_definition
  (variable (name) @variable.name)
  (type) @variable.type) @variable

; --- every mention of a type ---
;
; `named_type` is the one node a type name is ever written as: a field's type,
; an argument's type, a variable's type, a union member, a fragment's type
; condition, a schema root, an implemented interface. One pattern covers all
; of them, and the name is taken without its list or non-null wrappers so it
; resolves onto the declaration.

(named_type (name) @type.reference)

; --- implementing an interface ---
;
; `type Dog implements Pet` is one of the six relations the host knows. The
; clause nests for `A & B`, so each level contributes its own named type.
; The general pattern above also sees these names; the relation is what makes
; the edge, and it is the rarer of the two.

(implements_interfaces (named_type (name) @implements.interface))

; --- what an executable document reaches ---
;
; A selection names a field of the schema, a spread names a fragment, a
; directive names a directive declaration, an argument names the argument
; declared beside the field. Each resolves onto a declaration above.
; `(field (name))` cannot pick up an alias: an alias spells its name inside an
; `alias` node, not as a direct child.

(field (name) @selection.name)

(fragment_spread (fragment_name (name) @fragment.reference))

(directive (name) @directive.reference)

(argument
  (name) @argument.reference
  (value) @argument.reference.value)
