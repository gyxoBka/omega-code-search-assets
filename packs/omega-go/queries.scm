; omega-go
;
; Go is a package language: a file belongs to exactly one package, imports
; other packages by quoted path, and declares functions, methods, named types,
; struct fields, constants and variables at the top level of that package.
; The questions asked of a Go file are: what does this package declare, what
; does it import, which type does this method hang off, what shape does this
; callable have, who calls this function, who reads this field, and which of
; these functions are tests. Every pattern below answers one of them.
;
; Containment is not stated as a pattern. A function's extent is one region;
; a struct's extent is one region; nothing else needs a shape spelled two or
; three edges deep.

; --- the package this file belongs to ---

(package_clause (package_identifier) @package.name) @package

; --- what the file imports ---
;
; Four spellings, kept apart so that no optional capture is needed and each
; one is named by the thing that identifies it.

(import_spec !name path: (_) @import.path) @import.spec

(import_spec
  name: (package_identifier) @import.alias
  path: (_) @import.alias.path) @import.aliased

(import_spec name: (blank_identifier) path: (_) @import.blank.path) @import.blank

(import_spec name: (dot) path: (_) @import.dot.path) @import.dot

; --- a function ---
;
; One match carries the declaration, the region of its body, and the three
; pieces the card's signature line is assembled from. `type_parameters` and
; `result` are optional fields of every function_declaration, so capturing
; them optionally admits no node that was not already matched; the templates
; that need them are skipped when they are absent.
;
; A function whose name follows Go's stdlib testing convention is matched by
; the pattern below this one instead, so the two never both fire.

((function_declaration
   name: (identifier) @function.name
   type_parameters: (type_parameter_list)? @function.type_parameters
   parameters: (parameter_list) @function.parameters
   result: (_)? @function.result
   body: (block)? @function.body) @function
 (#not-match? @function.name "^(Test|Benchmark|Fuzz|Example)([A-Z_].*)?$"))

; --- a test, a benchmark, a fuzz target or an example ---
;
; `testing` is the standard library, not a framework: the go tool itself reads
; these four prefixes off the function name.

((function_declaration
   name: (identifier) @test.name
   parameters: (parameter_list) @test.parameters
   body: (block)? @test.body) @test.function
 (#match? @test.name "^(Test|Benchmark|Fuzz|Example)([A-Z_].*)?$"))

; --- a method ---

(method_declaration
  name: (field_identifier) @method.name
  parameters: (parameter_list) @method.parameters
  result: (_)? @method.result
  body: (block)? @method.body) @method

; --- the type a method hangs off ---
;
; A Go method is written at the top level of the file, so nothing in the tree
; puts it inside the type it belongs to. The receiver's type is the only place
; that link is written down, and it is carried onto the method declaration.

(method_declaration
  receiver: (parameter_list
    (parameter_declaration
      type: [(type_identifier) @method.owner
             (pointer_type (type_identifier) @method.owner)
             (generic_type type: (type_identifier) @method.owner)]))) @method.owner.declaration

; --- a named struct type ---

(type_spec
  name: (type_identifier) @struct.name
  type_parameters: (type_parameter_list)? @struct.type_parameters
  type: (struct_type) @struct.body) @struct

; --- a named interface type ---

(type_spec
  name: (type_identifier) @interface.name
  type_parameters: (type_parameter_list)? @interface.type_parameters
  type: (interface_type) @interface.body) @interface

; --- any other defined type ---
;
; The two alternatives above are excluded by naming the remaining members of
; the grammar's `_type` supertype, so a struct or an interface is declared
; once, under the word that says what it is.

(type_spec
  name: (type_identifier) @typedef.name
  type_parameters: (type_parameter_list)? @typedef.type_parameters
  type: [(type_identifier)
         (qualified_type)
         (generic_type)
         (pointer_type)
         (slice_type)
         (array_type)
         (implicit_length_array_type)
         (map_type)
         (channel_type)
         (function_type)
         (negated_type)
         (parenthesized_type)] @typedef.underlying) @typedef

; --- a type alias ---

(type_alias
  name: (type_identifier) @alias.name
  type: (_) @alias.target) @alias

; --- a struct field, and the tag that names it on the wire ---

(field_declaration
  name: (field_identifier) @field.name
  type: (_) @field.type
  tag: (_)? @field.tag) @field

; --- an embedded field: the one place a Go struct names a type it takes
;     the method set of ---

(field_declaration !name
  type: [(type_identifier) @embed.name
         (pointer_type (type_identifier) @embed.name)
         (qualified_type name: (type_identifier) @embed.name)
         (generic_type type: (type_identifier) @embed.name)]) @embed

; --- a method an interface requires ---

(method_elem
  name: (field_identifier) @interface.method.name
  parameters: (parameter_list) @interface.method.parameters
  result: (_)? @interface.method.result) @interface.method

; --- an interface embedded in an interface ---
;
; `type_elem` occurs only inside an interface body; a type parameter's
; constraint is a `type_constraint`, which this does not reach.

(type_elem
  [(type_identifier) @interface.embed.name
   (qualified_type name: (type_identifier) @interface.embed.name)
   (generic_type type: (type_identifier) @interface.embed.name)]) @interface.embed

; --- package-level constants and variables ---
;
; `name` repeats on both nodes, so `const a, b = 1, 2` is two matches and two
; declarations.

(const_spec name: (identifier) @const.name) @const

(var_spec name: (identifier) @var.name) @var

; --- a type parameter, so that `T` in a body resolves to something ---

(type_parameter_declaration name: (identifier) @type_parameter.name) @type_parameter

; --- calls ---

; The argument list is captured beside the name: a call's positional arguments
; are the one thing every framework overlay asks a call for -- a route's URL, a
; group's prefix, a Static mount's directory -- and they are the ordered
; children of the node the call already names them in.

(call_expression
  function: (identifier) @call.function.name
  arguments: (argument_list) @call.args) @call.function

(call_expression
  function: (selector_expression
    operand: (_) @call.receiver
    field: (field_identifier) @call.method.name)
  arguments: (argument_list) @call.args) @call.method

; --- every mention of a type by name ---

(type_identifier) @type.reference

; --- every field or method reached through a selector ---

(selector_expression field: (field_identifier) @member.name) @member

; --- labels ---

(labeled_statement label: (label_name) @label.name) @label

[(goto_statement (label_name) @label.reference)
 (break_statement (label_name) @label.reference)
 (continue_statement (label_name) @label.reference)] @label.reference.statement
