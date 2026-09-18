; omega-c-sharp
;
; C# is the language of .NET applications and libraries. The questions asked of
; a C# file are: what types and members does it declare, what is a member's
; signature and visibility, what does a type inherit or implement, what types
; does this code name, what does it call, and what namespaces does it import.
; Every pattern below answers one of those.
;
; Containment is deliberately not stated. A declaration nested in a type or a
; namespace already carries its container through the `within:` segment, and
; every C# construct with an extent is itself a declaration with its own
; region, so there is nothing a `scope.*` emission would add.
;
; Evidence that can occur more than once on one declaration -- a modifier, a
; type argument -- is matched by its own pattern, so that the declaration
; pattern stays one match per node.

; ============================== namespaces ==============================

(namespace_declaration name: (_) @namespace.name) @namespace

(file_scoped_namespace_declaration name: (_) @namespace.name) @namespace

; ============================ type declarations =========================
;
; One shared name capture, one span capture per node type: the template for a
; class is skipped on a struct match because `@type.struct` is unbound.

(class_declaration name: (identifier) @type.name) @type.class

(struct_declaration name: (identifier) @type.name) @type.struct

(record_declaration name: (identifier) @type.name) @type.record

(interface_declaration name: (identifier) @type.name) @type.interface

(enum_declaration name: (identifier) @type.name) @type.enum

(delegate_declaration name: (identifier) @type.name) @type.delegate

(type_parameter name: (identifier) @type.name) @type.parameter

; ============================ callable members ==========================

(method_declaration name: (identifier) @callable.name) @callable.method

(constructor_declaration name: (identifier) @callable.name) @callable.constructor

(destructor_declaration name: (identifier) @callable.name) @callable.destructor

(local_function_statement name: (identifier) @callable.name) @callable.local_function

(operator_declaration operator: _ @callable.name) @callable.operator

(conversion_operator_declaration type: (_) @callable.name) @callable.conversion

; ============================= value members ============================

(property_declaration name: (identifier) @member.name) @member.property

(event_declaration name: (identifier) @member.name) @member.event

(enum_member_declaration name: (identifier) @member.name) @member.constant

; An indexer has no name of its own; it is written `this[...]`.

; A field's name is on the declarator, not on the declaration, and one
; declaration may hold several. The declarator is the span of each.

(field_declaration
  (variable_declaration
    (variable_declarator name: (identifier) @member.name) @member.field))

(event_field_declaration
  (variable_declaration
    (variable_declarator name: (identifier) @member.name) @member.event_field))

; ====================== what a declaration carries ======================
;
; Visibility, the parameter list, the return type, the declared type and the
; type parameter list are folded into the declaration that occupies the same
; span, so a card can show a signature and nothing resolves to `public`.

[(class_declaration (modifier) @signature.modifier)
 (struct_declaration (modifier) @signature.modifier)
 (record_declaration (modifier) @signature.modifier)
 (interface_declaration (modifier) @signature.modifier)
 (enum_declaration (modifier) @signature.modifier)
 (delegate_declaration (modifier) @signature.modifier)
 (method_declaration (modifier) @signature.modifier)
 (constructor_declaration (modifier) @signature.modifier)
 (local_function_statement (modifier) @signature.modifier)
 (operator_declaration (modifier) @signature.modifier)
 (conversion_operator_declaration (modifier) @signature.modifier)
 (property_declaration (modifier) @signature.modifier)
 (indexer_declaration (modifier) @signature.modifier)
 (event_declaration (modifier) @signature.modifier)] @signature.owner

[(field_declaration
   (modifier) @signature.modifier
   (variable_declaration (variable_declarator) @signature.owner))
 (event_field_declaration
   (modifier) @signature.modifier
   (variable_declaration (variable_declarator) @signature.owner))]

[(method_declaration returns: (_) @signature.return)
 (local_function_statement type: (_) @signature.return)
 (delegate_declaration type: (_) @signature.return)
 (operator_declaration type: (_) @signature.return)
 (conversion_operator_declaration type: (_) @signature.return)] @signature.owner

[(method_declaration parameters: (parameter_list) @signature.parameters)
 (constructor_declaration parameters: (parameter_list) @signature.parameters)
 (destructor_declaration parameters: (parameter_list) @signature.parameters)
 (local_function_statement parameters: (parameter_list) @signature.parameters)
 (operator_declaration parameters: (parameter_list) @signature.parameters)
 (conversion_operator_declaration parameters: (parameter_list) @signature.parameters)
 (delegate_declaration parameters: (parameter_list) @signature.parameters)
 (indexer_declaration parameters: (bracketed_parameter_list) @signature.parameters)
 (class_declaration (parameter_list) @signature.parameters)
 (struct_declaration (parameter_list) @signature.parameters)
 (record_declaration (parameter_list) @signature.parameters)] @signature.owner

[(class_declaration (type_parameter_list) @signature.type_parameters)
 (struct_declaration (type_parameter_list) @signature.type_parameters)
 (record_declaration (type_parameter_list) @signature.type_parameters)
 (interface_declaration type_parameters: (type_parameter_list) @signature.type_parameters)
 (delegate_declaration type_parameters: (type_parameter_list) @signature.type_parameters)
 (method_declaration type_parameters: (type_parameter_list) @signature.type_parameters)
 (local_function_statement type_parameters: (type_parameter_list) @signature.type_parameters)] @signature.owner

[(property_declaration type: (_) @signature.declared_type)
 (event_declaration type: (_) @signature.declared_type)
 (indexer_declaration type: (_) @signature.declared_type)] @signature.owner

[(field_declaration
   (variable_declaration
     type: (_) @signature.declared_type
     (variable_declarator) @signature.owner))
 (event_field_declaration
   (variable_declaration
     type: (_) @signature.declared_type
     (variable_declarator) @signature.owner))]

; ========================= what a type inherits =========================
;
; C# spells a base class and an implemented interface the same way and the
; difference needs type resolution, so both are stated as `relation.implements`
; -- one of the six relations the host knows.

(base_list
  [(identifier) @base.name
   (qualified_name name: (identifier) @base.name)
   (generic_name (identifier) @base.name)
   (primary_constructor_base_type type: (identifier) @base.name)
   (primary_constructor_base_type type: (qualified_name name: (identifier) @base.name))
   (primary_constructor_base_type type: (generic_name (identifier) @base.name))]) @base

; ============================== type uses ===============================
;
; Every declaring position spells its type in a `type:` field -- a parameter, a
; local, a field, a cast, a `typeof`, a pattern, a `catch`, a generic
; constraint -- and `array_type` and `nullable_type` carry the same field, so
; one pattern reaches through them.

(_ type: [(identifier) @type_use.name
          (generic_name (identifier) @type_use.name)] @type_use)

(_ type: (qualified_name
           qualifier: (_) @type_use.qualifier
           name: [(identifier) @type_use.qualified.name
                  (generic_name (identifier) @type_use.qualified.name)]) @type_use.qualified)

(method_declaration
  returns: [(identifier) @return_use.name
            (generic_name (identifier) @return_use.name)] @return_use)

(method_declaration
  returns: (qualified_name
             name: [(identifier) @return_use.name
                    (generic_name (identifier) @return_use.name)]) @return_use)

(type_argument_list
  [(identifier) @type_argument.name
   (generic_name (identifier) @type_argument.name)
   (qualified_name name: (identifier) @type_argument.name)] @type_argument)

; An attribute names a type too, but under a short spelling (`[Obsolete]` for
; `ObsoleteAttribute`), so it is stated as its own kind.

(attribute
  name: [(identifier) @attribute.name
         (qualified_name name: (identifier) @attribute.name)
         (generic_name (identifier) @attribute.name)]) @attribute

; ================================ calls =================================

; The argument list is captured beside the name: a call's positional arguments
; are what a framework overlay asks a call for -- a route's URL, a registered
; service token, a resource path -- and they are the ordered children of the
; node the call already names them in.

(invocation_expression
  function: (member_access_expression
              expression: (_) @call.receiver
              name: [(identifier) @call.name
                     (generic_name (identifier) @call.name)])
  arguments: (argument_list) @call.args) @call.member

(invocation_expression
  function: (conditional_access_expression
              condition: (_) @call.bound.receiver
              (member_binding_expression
                name: [(identifier) @call.bound.name
                       (generic_name (identifier) @call.bound.name)]))) @call.bound

(invocation_expression
  function: [(identifier) @call.plain.name
             (generic_name (identifier) @call.plain.name)]
  arguments: (argument_list) @call.args) @call.plain

(invocation_expression
  function: (qualified_name
              qualifier: (_) @call.qualifier
              name: [(identifier) @call.qualified.name
                     (generic_name (identifier) @call.qualified.name)])) @call.qualified

; =============================== imports ================================
;
; `using System.Text;`, `using static System.Math;` and the local name of
; `using Json = System.Text.Json;` are all the names this file brings in.

(using_directive (qualified_name) @import.path) @import.qualified

(using_directive (identifier) @import.name) @import.simple

(extern_alias_directive name: (identifier) @extern_alias.name) @extern_alias

; =============================== literals ===============================
;
; Dropped as data, but their spans mark bytes that are a written-out value, so
; a role boundary landing on one is not mistaken for a name.

