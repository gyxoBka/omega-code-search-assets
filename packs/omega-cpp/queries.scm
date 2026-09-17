; omega-cpp
;
; C++ is used for the parts of a system that other languages call into: headers
; that declare an API, translation units that implement it, and templates that
; generate it. The questions asked of a C++ file are: where is this class, this
; function or this macro declared; what does this class derive from; what calls
; this function; what does this file include or import.
;
; Every pattern below is rooted at one node type and answers one of those.
; Containment is deliberately not stated: the tree already holds it, and a
; nested declaration carries its container through the `within:` segment.
; Two patterns use a parent node as a *filter* (a `declaration` directly under
; `translation_unit` or a namespace `declaration_list` is a namespace-scope
; variable, one inside a function body is a local) -- that is a structural
; filter, not a containment fact, and it costs one match per declaration.

; ---------------------------------------------------------------------------
; Callables
;
; Every C++ callable is a `function_declarator`, whatever the return type is
; spelled as and however many pointer or reference declarators wrap it, so one
; root node covers definitions, prototypes, methods and out-of-line
; definitions alike. `parameters` is a required field, so capturing it does not
; change what matches; it is folded onto the declaration as its signature.
; ---------------------------------------------------------------------------

(function_declarator
  declarator: (identifier) @function.name
  parameters: (parameter_list) @callable.parameters) @callable

(function_declarator
  declarator: (field_identifier) @method.name
  parameters: (parameter_list) @callable.parameters) @callable

; `void Widget::draw()` and `void ns::helper()` are the same syntax; both are
; functions, and the qualifier is carried as the owner rather than guessed at.

(function_declarator
  declarator: (qualified_identifier
    scope: (_) @function.owner
    name: (identifier) @function.name)
  parameters: (parameter_list) @callable.parameters) @callable

(function_declarator
  declarator: (destructor_name) @destructor.name
  parameters: (parameter_list) @callable.parameters) @callable

(function_declarator
  declarator: (operator_name) @operator.name
  parameters: (parameter_list) @callable.parameters) @callable

; `operator Widget()` has no `function_declarator` around it.

(operator_cast
  type: (_) @conversion.type) @conversion

; ---------------------------------------------------------------------------
; Types
;
; A body is required in each of these, so `class Widget;` -- a forward
; declaration, which names a type it does not define -- is not declared here.
; ---------------------------------------------------------------------------

(class_specifier
  name: (type_identifier) @class.name
  body: (field_declaration_list)) @class

(struct_specifier
  name: (type_identifier) @struct.name
  body: (field_declaration_list)) @struct

(union_specifier
  name: (type_identifier) @union.name
  body: (field_declaration_list)) @union

(enum_specifier
  name: (type_identifier) @enum.name
  body: (enumerator_list)) @enum

(enumerator
  name: (identifier) @enumerator.name) @enumerator

(alias_declaration
  name: (type_identifier) @alias.name
  type: (type_descriptor) @alias.target) @alias

; `typedef struct { ...body... } Config;` has no named type to alias to, and
; `type: (_)` stored the whole body as the alias target.
(type_definition
  type: [(type_identifier)
         (primitive_type)
         (sized_type_specifier)
         (qualified_identifier)
         (template_type)
         (struct_specifier name: (type_identifier))
         (union_specifier name: (type_identifier))
         (enum_specifier name: (type_identifier))
         (class_specifier name: (type_identifier))]? @typedef.target
  declarator: (type_identifier) @typedef.name) @typedef

(concept_definition
  name: (identifier) @concept.name) @concept

; A base class is the one relation C++ states in syntax. The written form may
; be qualified, template-instantiated or both, so the name is reduced to the
; leaf the declaration is spelled with.

(base_class_clause
  [(type_identifier) (qualified_identifier) (template_type)] @base.name)

; ---------------------------------------------------------------------------
; Namespaces and modules
; ---------------------------------------------------------------------------

(namespace_definition
  name: [(namespace_identifier) (nested_namespace_specifier)] @namespace.name) @namespace

(namespace_alias_definition
  name: (namespace_identifier) @namespace.alias.name) @namespace.alias

(module_declaration
  name: (module_name) @module.name) @module

; ---------------------------------------------------------------------------
; The preprocessor
;
; A macro is a declaration no compiler front end ever sees as one, and in C++
; it is the only name that can be introduced without a scope. Both spellings
; are recorded; the function-like one carries its parameter list.
; ---------------------------------------------------------------------------

(preproc_def
  name: (identifier) @macro.name) @macro

(preproc_function_def
  name: (identifier) @macro.function.name
  parameters: (preproc_params) @macro.function.parameters) @macro.function

(preproc_include
  path: [(string_literal) (system_lib_string)] @include.path) @include

; ---------------------------------------------------------------------------
; Imports
; ---------------------------------------------------------------------------

(import_declaration
  name: (module_name) @import.module.name) @import.module

(import_declaration
  header: [(string_literal) (system_lib_string)] @import.header.path) @import.header

; `using ns::name;` and `using namespace ns;` both bind a name from elsewhere
; into this scope.

(using_declaration
  [(identifier) @using.name
   (qualified_identifier name: (_) @using.name)]) @using

; ---------------------------------------------------------------------------
; Data members and namespace-scope variables
; ---------------------------------------------------------------------------

(field_declaration
  declarator: [
    (field_identifier) @field.name
    (pointer_declarator declarator: (field_identifier) @field.name)
    (reference_declarator (field_identifier) @field.name)
    (array_declarator declarator: (field_identifier) @field.name)
  ]) @field

(translation_unit
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (array_declarator declarator: (identifier) @variable.name)
    ]) @variable)

(declaration_list
  (declaration
    declarator: [
      (identifier) @variable.name
      (init_declarator declarator: (identifier) @variable.name)
      (pointer_declarator declarator: (identifier) @variable.name)
      (init_declarator
        declarator: (pointer_declarator declarator: (identifier) @variable.name))
      (array_declarator declarator: (identifier) @variable.name)
    ]) @variable)

; ---------------------------------------------------------------------------
; Calls
;
; A call is recorded by the name it is written with. Every pattern is rooted at
; `call_expression`, so the cost is one match per call site.
; ---------------------------------------------------------------------------

(call_expression
  function: (identifier) @call.name) @call

(call_expression
  function: (template_function name: (identifier) @call.name)) @call

(call_expression
  function: (qualified_identifier name: (identifier) @call.name)) @call

(call_expression
  function: (field_expression
    field: (field_identifier) @call.member.name)) @call.member

(call_expression
  function: (field_expression
    field: (template_method name: (field_identifier) @call.member.name))) @call.member

; ---------------------------------------------------------------------------
; References
;
; `type_identifier` is the one identifier class in this grammar that always
; names a declared type, so it is the reference stream worth keeping. The
; general `(identifier)` sweep is not: it matches every name in the file,
; including the ones already declared above.
; ---------------------------------------------------------------------------

(type_identifier) @reference.type

(labeled_statement
  label: (statement_identifier) @label.name) @label

(goto_statement
  label: (statement_identifier) @goto.label) @goto
