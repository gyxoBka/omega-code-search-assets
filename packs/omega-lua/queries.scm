; omega-lua
;
; Lua has no declaration syntax. A name comes into being by being assigned,
; and the unit of structure is the table. So the questions an agent asks of a
; Lua file are: which functions does this file define and what do they take,
; what does this module export on its table, what does this file require, and
; what calls what.
;
; Every pattern below is rooted at one node and answers one of those. The tree
; already holds containment, so no pattern states it as a fact; where a nesting
; appears it is a filter -- `local x` at file scope is part of a module's shape,
; `local x` twelve blocks deep is not.

; --- a function declared with the `function` keyword ---
;
; `function f()`, `local function f()` and `function M.f()` are one node with
; three spellings of `name:`. One pattern, four templates: the declaration,
; its parameter shape, the table it was hung on (only bound by the dotted
; form, so the carrier is skipped on the others), and its body as a region.

(function_declaration
  name: [(identifier) @function.name
         (dot_index_expression
           table: [(identifier) (dot_index_expression)] @function.container
           field: (identifier) @function.name)]
  parameters: (parameters) @function.parameters
  body: (block)? @function.body) @function

; --- a method: `function M:f()` ---
;
; The colon form takes an implicit `self`, which is what makes it a method and
; not a function hung on a table.

(function_declaration
  name: (method_index_expression
          table: [(identifier) (dot_index_expression)] @method.container
          method: (identifier) @method.name)
  parameters: (parameters) @method.parameters
  body: (block)? @method.body) @method

; --- a function assigned to a name: `local f = function() end` ---
;
; Anchored on both sides so `local a, f = 1, function() end` does not declare
; `a` as the function: only the first name is paired with the first value.

(assignment_statement
  (variable_list
    . name: [(identifier) @function.value.name
             (dot_index_expression
               table: [(identifier) (dot_index_expression)] @function.value.container
               field: (identifier) @function.value.name)])
  (expression_list
    . value: (function_definition
               parameters: (parameters) @function.value.parameters
               body: (block)? @function.value.body))) @function.value

; --- a function in a table constructor: `M = { f = function() end }` ---
;
; Rooted at the field, not at the table: the table holds N of these and a
; pattern per table would match once per field anyway.

(field
  name: (identifier) @function.field.name
  value: (function_definition
           parameters: (parameters) @function.field.parameters
           body: (block)? @function.field.body)) @function.field

; --- a keyed table field ---
;
; `{ timeout = 30 }` is where `timeout` is set, so the key is declared. The
; value alternation lists every expression except `function_definition`, which
; the pattern above already declares as a function. Array-style fields have no
; `name:` and are not matched.

(field
  name: (identifier) @field.name
  value: [(string) (number) (true) (false) (nil) (table_constructor)
          (identifier) (dot_index_expression) (bracket_index_expression)
          (function_call) (binary_expression) (unary_expression)
          (parenthesized_expression) (vararg_expression)]) @field

; --- a name declared at file scope ---
;
; `local M = {}`, `local M`, and a bare global assignment. The `(chunk ...)`
; wrapper is a filter, not a statement of containment: a local inside a
; function body is an implementation detail of that body and resolves against
; nothing outside it, while a file-scope name is part of what the file offers.

; The value alternation is the same filter the keyed-table pattern above uses:
; `local f = function() end` is declared as a function by the pattern further
; up, and without this it was declared a second time here as a value.

(chunk
  (variable_declaration
    (assignment_statement
      (variable_list name: (identifier) @variable.declared)
      (expression_list . value: [(string) (number) (true) (false) (nil) (table_constructor)
                (identifier) (dot_index_expression) (bracket_index_expression)
                (function_call) (binary_expression) (unary_expression)
                (parenthesized_expression) (vararg_expression)]))))

(chunk
  (variable_declaration
    (variable_list name: (identifier) @variable.declared)))

(chunk
  (assignment_statement
    (variable_list name: (identifier) @variable.declared)
    (expression_list . value: [(string) (number) (true) (false) (nil) (table_constructor)
                (identifier) (dot_index_expression) (bracket_index_expression)
                (function_call) (binary_expression) (unary_expression)
                (parenthesized_expression) (vararg_expression)])))

; --- a field set at file scope: `M.handler = ...` ---
;
; The other way a Lua module puts a name on its table.

(chunk
  (assignment_statement
    (variable_list
      . name: (dot_index_expression
                table: [(identifier) (dot_index_expression)] @field.assigned.container
                field: (identifier) @field.assigned.name))
    (expression_list . value: [(string) (number) (true) (false) (nil) (table_constructor)
                (identifier) (dot_index_expression) (bracket_index_expression)
                (function_call) (binary_expression) (unary_expression)
                (parenthesized_expression) (vararg_expression)])) @field.assigned)

; --- `require "mod"` ---
;
; The module name is taken from the string's content, so it is recorded without
; its quotes and can match a module named elsewhere.

((function_call
   name: (identifier) @_require
   arguments: (arguments (string content: (string_content) @import.name))) @import
 (#eq? @_require "require"))

; --- calls ---
;
; `f()`, `M.f()` and `obj:f()`. The callee is recorded under its last segment,
; which is the name the declarations above are stored under.

(function_call
  name: [(identifier) @call.function
         (dot_index_expression field: (identifier) @call.function)])

(function_call
  name: (method_index_expression method: (identifier) @call.method))

; --- goto and its label ---

(label_statement (identifier) @label.name)

(goto_statement (identifier) @label.reference)
