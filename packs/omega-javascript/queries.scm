; omega-javascript
;
; JavaScript is written as modules of functions, classes and module-level
; values, and the names that cross a file boundary are the ones a module
; imports, the ones it declares, the ones it exports, the classes it extends
; and the functions it calls. The questions asked of a JavaScript file are:
; where is this function, class, method or module-level value defined, what
; does this file import and what does a short alias stand for, what does this
; file export, what does this class extend, who calls this, what is applied to
; this declaration, and which component is rendered here. Every pattern below
; answers one of them.
;
; Containment is not stated as a pattern. The tree already holds it, a nested
; declaration carries its container through the `within:` segment, and the
; extent of a class body or a function body is emitted once as a region.
;
; Names bound inside a function body -- a `const`/`let`/`var` below module
; level, a destructuring pattern, a parameter, a `for` target, a `catch`
; binding -- are deliberately absent. They resolve to nothing outside their own
; block and there are more of them in a JavaScript repository than of
; everything else here put together. Parameters are carried on the declaration
; as its parameter shape, which is what a card's signature line is built from.
;
; Control flow -- `if`, `for`, `while`, `switch`, `try`, `break`, `continue`,
; `label`, `await`, `yield` -- is not stated at all. None of it names anything
; a question can resolve to.

; --- a function ---
;
; One match carries the declaration, its region and its parameter shape.

(function_declaration
  name: (identifier) @function.name
  parameters: (formal_parameters) @function.parameters
  body: (statement_block) @function.body) @function

(generator_function_declaration
  name: (identifier) @generator.name
  parameters: (formal_parameters) @generator.parameters
  body: (statement_block) @generator.body) @generator

; --- a function bound to a name ---
;
; `const handle = async (req, res) => {...}` is how most of a modern
; JavaScript codebase declares its functions, and the name it answers to is the
; name of the binding, not of the expression. The single-parameter arrow
; (`x => x * 2`) spells its parameter in a different field, so it is a branch
; of its own rather than an optional capture: an optional capture would change
; which nodes match, not only how the pattern reads.

(variable_declarator
  name: (identifier) @function.binding.name
  value: [(function_expression
            parameters: (formal_parameters) @function.binding.parameters
            body: (statement_block) @function.binding.body)
          (generator_function
            parameters: (formal_parameters) @function.binding.parameters
            body: (statement_block) @function.binding.body)
          (arrow_function
            parameters: (formal_parameters) @function.binding.parameters
            body: (_) @function.binding.body)
          (arrow_function
            parameter: (identifier) @function.binding.parameters
            body: (_) @function.binding.body)]) @function.binding

; --- a class ---
;
; `class C {}` and `const C = class {}` are the same declaration under two
; spellings; the named class expression is folded in here, the anonymous one
; below.

[(class_declaration
   name: (identifier) @class.name
   body: (class_body) @class.body)
 (class
   name: (identifier) @class.name
   body: (class_body) @class.body)] @class

(variable_declarator
  name: (identifier) @class.binding.name
  value: (class body: (class_body) @class.binding.body)) @class.binding

; --- what a class extends ---
;
; A qualified base (`extends mod.Base`) is reduced to its last identifier so
; that it is spelled the way the declaration of that class is spelled.

(class_heritage
  [(identifier) @class.base
   (member_expression property: (property_identifier) @class.base)])

; --- a method ---
;
; `method_definition` is the same node in a class body and in an object
; literal, so one pattern declares both.

(method_definition
  name: [(property_identifier) @method.name
         (private_property_identifier) @method.name]
  parameters: (formal_parameters) @method.parameters
  body: (statement_block) @method.body) @method

; --- a class field ---

(field_definition
  property: [(property_identifier) @field.name
             (private_property_identifier) @field.name]) @field

; --- a function held by an object property ---
;
; `{ onClick: () => {...} }` -- the handler tables, reducers and route maps
; that a JavaScript project keeps in object literals. The name a question asks
; for is the key.

(pair
  key: (property_identifier) @object_function.name
  value: [(function_expression
            parameters: (formal_parameters) @object_function.parameters
            body: (statement_block) @object_function.body)
          (generator_function
            parameters: (formal_parameters) @object_function.parameters
            body: (statement_block) @object_function.body)
          (arrow_function
            parameters: (formal_parameters) @object_function.parameters
            body: (_) @object_function.body)
          (arrow_function
            parameter: (identifier) @object_function.parameters
            body: (_) @object_function.body)]) @object_function

; --- a module-level value ---
;
; `const TIMEOUT = 30`, `const config = {...}`, `const log = createLogger()` --
; the one JavaScript construct that answers "where is this configured". Only
; the top of a file, and only a binding that holds a value rather than a
; function: a function-valued binding is already declared above, and a name
; bound inside a function body resolves to nothing outside it.
;
; The parent chain is a filter for "module level", not a statement of
; containment: the number of matches is the number of declarators, not a tuple
; of nodes at a depth.

(program
  [(lexical_declaration
     (variable_declarator
       name: (identifier) @module_variable.name
       value: [(string) (template_string) (number) (true) (false) (null)
               (regex) (object) (array) (new_expression) (call_expression)
               (member_expression) (identifier) (await_expression)]) @module_variable)
   (variable_declaration
     (variable_declarator
       name: (identifier) @module_variable.name
       value: [(string) (template_string) (number) (true) (false) (null)
               (regex) (object) (array) (new_expression) (call_expression)
               (member_expression) (identifier) (await_expression)]) @module_variable)
   (export_statement
     declaration: (lexical_declaration
       (variable_declarator
         name: (identifier) @module_variable.name
         value: [(string) (template_string) (number) (true) (false) (null)
                 (regex) (object) (array) (new_expression) (call_expression)
                 (member_expression) (identifier) (await_expression)]) @module_variable))
   (export_statement
     declaration: (variable_declaration
       (variable_declarator
         name: (identifier) @module_variable.name
         value: [(string) (template_string) (number) (true) (false) (null)
                 (regex) (object) (array) (new_expression) (call_expression)
                 (member_expression) (identifier) (await_expression)]) @module_variable))])

; --- what a file imports ---
;
; The module specifier is kept as written and stripped of its quotes, so
; `"./util"` is stated as `./util`. An alias is bound separately and carries
; the name it stands for, which is what answers "what is `fs` here".

(import_statement source: (string) @import.module)

; A local name bound by an import, together with the module it came from.
; The module specifier has to be captured in the same pattern as the name:
; the host reads an external package only from a binding carrying a field
; literally called `qualifier`, and a template can only reference captures
; from its own match.

(import_statement
  (import_clause (identifier) @import.local.default)
  source: (string) @import.qualifier)

(import_statement
  (import_clause (namespace_import (identifier) @import.local.namespace))
  source: (string) @import.qualifier)

(import_statement
  (import_clause
    (named_imports
      (import_specifier name: (identifier) @import.local.symbol)))
  source: (string) @import.qualifier)

(import_clause (identifier) @import.default)

(namespace_import (identifier) @import.namespace)

(import_specifier !alias name: (identifier) @import.symbol)

(import_specifier
  name: (identifier) @import.alias.target
  alias: (identifier) @import.alias.name) @import.alias

(call_expression
  function: (import)
  arguments: (arguments (string) @import.dynamic))

; CommonJS is JavaScript's other module system, not a library: `require` is how
; every Node file written before ESM names its dependencies.

(call_expression
  function: (identifier) @import.require.function
  arguments: (arguments (string) @import.require.module)
  (#eq? @import.require.function "require"))

; `const fs = require("fs")` binds a whole module to one name, which is what a
; namespace import does; CommonJS is how every Node file written before ESM
; names its dependencies, so the binding has to carry its qualifier too.

(variable_declarator
  name: (identifier) @import.local.require
  value: (call_expression
    function: (identifier) @_require.fn
    arguments: (arguments (string) @import.qualifier))
  (#eq? @_require.fn "require"))

; --- what a file exports ---

(export_clause
  (export_specifier !alias name: (identifier) @export.name))

(export_clause
  (export_specifier
    name: (identifier) @export.alias.target
    alias: (identifier) @export.alias.name) @export.alias)

(export_statement source: (string) @export.reexport)

(namespace_export (identifier) @export.namespace)

(export_statement value: (identifier) @export.default)

; CommonJS: `exports.parse = ...`, `module.exports.parse = ...`,
; `module.exports = parse`.

(assignment_expression
  left: (member_expression
          object: (identifier) @commonjs.export.object
          property: (property_identifier) @commonjs.export.name)
  (#eq? @commonjs.export.object "exports"))

(assignment_expression
  left: (member_expression
          object: (member_expression
                    object: (identifier) @commonjs.member.object
                    property: (property_identifier) @commonjs.member.property)
          property: (property_identifier) @commonjs.export.member)
  (#eq? @commonjs.member.object "module")
  (#eq? @commonjs.member.property "exports"))

(assignment_expression
  left: (member_expression
          object: (identifier) @commonjs.default.object
          property: (property_identifier) @commonjs.default.property)
  right: (identifier) @commonjs.default.name
  (#eq? @commonjs.default.object "module")
  (#eq? @commonjs.default.property "exports"))

; --- a call ---
;
; The span is the name that is called, not the call with its arguments: a
; mention is the bytes that name the thing.

(call_expression function: (identifier) @call.function)

(call_expression function: (member_expression property: (property_identifier) @call.method))

(new_expression
  constructor: [(identifier) @call.constructor
                (member_expression property: (property_identifier) @call.constructor)])

; --- what is applied to a declaration ---
;
; Named by the last identifier, so it resolves to the declaration of the
; decorator itself.

(decorator
  [(identifier) @decorator.name
   (member_expression property: (property_identifier) @decorator.name)
   (call_expression
     function: [(identifier) @decorator.name
                (member_expression property: (property_identifier) @decorator.name)])])

; --- a component rendered in JSX ---
;
; JSX's own rule, older than any one library, is that a capitalised tag names a
; value in scope and a lowercase tag is a literal element name. Only the
; capitalised one resolves to a declaration, so only it is stated.

(jsx_opening_element
  name: [(identifier) @jsx.component
         (member_expression property: (property_identifier) @jsx.component)
         (jsx_namespace_name (identifier) @jsx.component)]
  (#match? @jsx.component "^[A-Z]"))

(jsx_self_closing_element
  name: [(identifier) @jsx.self_closing.component
         (member_expression property: (property_identifier) @jsx.self_closing.component)
         (jsx_namespace_name (identifier) @jsx.self_closing.component)]
  (#match? @jsx.self_closing.component "^[A-Z]"))
