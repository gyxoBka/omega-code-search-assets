; omega-groovy
;
; Groovy is the language of Gradle build scripts, Jenkins pipelines, Spock
; specifications and JVM glue scripts. The questions asked of a Groovy file
; are: what does this file declare, what type does it name, what does it call,
; what block configures this setting, and what does it import or inherit from.
; Every pattern below answers one of those.
;
; Containment is deliberately not stated. The tree already holds it, a class
; body and a method body are emitted as regions, and a pattern per nesting
; depth costs one match per tuple of nodes at that depth.
;
; Modifiers, return types, declared types and parameter shapes are captured on
; the span of the declaration they belong to, so the host folds them into that
; declaration's attribute bag instead of storing them as facts of their own.

; --- the package this file belongs to ---

(groovy_package [(dotted_identifier) (identifier)] @package.name) @package

; --- an import, and the local name an aliased import binds ---

(groovy_import import: [(dotted_identifier) (identifier)] @import.path) @import

(groovy_import import_alias: (identifier) @import.alias) @import.alias.owner

; --- a class, and its body as a region ---

(class_definition
  name: (identifier) @class.name
  body: (closure) @class.body) @class

(class_definition
  generics: (generic_parameters) @class.type_parameters) @class.type_parameters.owner

; `extends` and `implements` fill the same field in this grammar, so both
; arrive here; the supertype is stripped to its last segment so that it can
; resolve against a class declared elsewhere in the repository.
(class_definition
  superclass: [(identifier) (dotted_identifier)] @class.superclass) @class.superclass.owner

; --- a type parameter is a type name a question can resolve to ---

(generic_param name: (identifier) @type_parameter.name) @type_parameter

; --- a method or function, with a body, and its body as a region ---

(function_definition
  function: (identifier) @function.name
  parameters: (parameter_list) @function.parameters
  body: (closure) @function.body) @function

; --- a method without a body (abstract, or an interface member) ---

(function_declaration
  function: (identifier) @declared_function.name
  parameters: (parameter_list) @declared_function.parameters) @declared_function

; --- the declared return type, carried on the callable it belongs to ---
;
; The return type is an optional field only in the sense that it may be the
; anonymous `def` token, which no pattern can name, so it is asked for
; separately rather than inside the callable pattern above.

[(function_definition
   type: [(builtintype) (identifier) (dotted_identifier) (type_with_generics) (array_type)] @return_type.name)
 (function_declaration
   type: [(builtintype) (identifier) (dotted_identifier) (type_with_generics) (array_type)] @return_type.name)] @return_type.owner

; --- the declared type of a field, a local or a parameter ---

[(declaration
   type: [(builtintype) (identifier) (dotted_identifier) (type_with_generics) (array_type)] @declared_type.name)
 (parameter
   type: [(builtintype) (identifier) (dotted_identifier) (type_with_generics) (array_type)] @declared_type.name)] @declared_type.owner

; --- every position where a type is named ---

[(function_definition type: [(identifier) (dotted_identifier)] @type_use.name)
 (function_declaration type: [(identifier) (dotted_identifier)] @type_use.name)
 (declaration type: [(identifier) (dotted_identifier)] @type_use.name)
 (parameter type: [(identifier) (dotted_identifier)] @type_use.name)
 (generics [(identifier) (dotted_identifier)] @type_use.name)
 (generic_param superclass: [(identifier) (dotted_identifier)] @type_use.name)]

; --- a field or local declaration ---

(declaration name: (identifier) @variable.name) @variable

; --- a parameter ---

(parameter name: (identifier) @parameter.name) @parameter

; --- the variable a for-each loop binds ---

(for_in_loop variable: (identifier) @loop.variable)

; --- visibility and modifiers, carried on the declaration they qualify ---

[(class_definition (access_modifier) @visibility.name)
 (declaration (access_modifier) @visibility.name)
 (function_definition (access_modifier) @visibility.name)
 (function_declaration (access_modifier) @visibility.name)] @visibility.owner

[(class_definition (modifier) @modifier.name)
 (declaration (modifier) @modifier.name)
 (function_definition (modifier) @modifier.name)
 (function_declaration (modifier) @modifier.name)] @modifier.owner

; --- an annotation names a type ---

(annotation (identifier) @annotation.name) @annotation

; --- a call ---
;
; Both spellings are one pattern: `foo(x)` and the command form `foo x`.
; A qualified target is stripped to its last segment so that `p.q.run()`
; resolves against a declaration of `run`.

[(function_call function: [(identifier) (dotted_identifier)] @call.target)
 (juxt_function_call function: [(identifier) (dotted_identifier)] @call.target)] @call

; --- a configuration block: `name { ... }` ---
;
; The identifier-followed-by-closure form is Groovy's block syntax, and it is
; what a build script or a pipeline is made of. It is declared under the
; identifier that opens it; which DSL that identifier belongs to is not
; stated here.

; Three forms, anchored so they cannot overlap: `jacoco { }` is named by the
; keyword itself, `task hello { }` by the name the keyword is given, and
; `stage('Build') { }` by its label. Unanchored, the first form swallowed the
; other two and every named block in a repository was declared under its
; keyword -- one `task` for all of them, with `hello` nowhere in the index.

[(juxt_function_call
   function: (identifier) @block.name
   args: (argument_list . (closure)))
 (function_call
   function: (identifier) @block.name
   args: (argument_list . (closure)))] @block

[(juxt_function_call
   function: (identifier) @block.keyword
   args: (argument_list . (identifier) @block.name . (closure)))
 (function_call
   function: (identifier) @block.keyword
   args: (argument_list . (identifier) @block.name . (closure)))] @block

; `stage('Build') { ... }` — the leading string literal labels the block, and
; is carried on the block's own span.

[(juxt_function_call
   function: (identifier) @block.label.keyword
   args: (argument_list . (string (string_content) @block.label) . (closure)))
 (function_call
   function: (identifier) @block.label.keyword
   args: (argument_list . (string (string_content) @block.label) . (closure)))] @block.label.owner

; --- a named entry in a map literal ---
;
; `apply plugin: 'java'` and `group: 'org.example'` are how a Groovy build
; script states a setting, so the key is declared and the value is carried
; with it.

(map_item
  key: [(identifier) (string)] @map.key
  value: (_) @map.value) @map.item
