; omega-ruby
;
; Ruby is written as classes, modules and methods, and its programs are held
; together by constants: a class name, a mixin argument, a superclass and a
; reference to any of them are all spelled the same way. The questions asked of
; a Ruby file are: where is this class, module or method defined, what does this
; class inherit or include, what does this file require, who calls this method,
; and where is this constant used. Every pattern below answers one of them.
;
; Containment is not stated as a pattern. The tree already holds it; the extent
; of a class, module or method body is emitted once as a region.

; --- a class ---
;
; `class A::B < C::D` is one pattern. The declaration, its region, the
; superclass it carries and the inheritance edge are four templates over this
; one match. A qualified name is reduced to its last constant so that it is
; spelled the way every reference to it is spelled.

(class
  name: [(constant) @class.name
         (scope_resolution name: (constant) @class.name)]
  superclass: (superclass
    [(constant) @class.superclass
     (scope_resolution name: (constant) @class.superclass)])?) @class

; --- a module ---

(module
  name: [(constant) @module.name
         (scope_resolution name: (constant) @module.name)]) @module

; --- a method ---
;
; The parameter list is carried on the declaration, not emitted on its own: it
; is a signature component, and a mention of `(a, b = 1)` resolves to nothing.

(method
  name: (_) @method.name
  parameters: (method_parameters)? @method.parameters) @method

(singleton_method
  object: (_) @singleton_method.object
  name: (_) @singleton_method.name
  parameters: (method_parameters)? @singleton_method.parameters) @singleton_method

; --- `class << self` ---
;
; It declares nothing of its own; it is the region that makes the methods
; inside it singleton methods.

(singleton_class value: (_) @singleton_class.value) @singleton_class

; --- `alias new old` ---
;
; A declaration of the new name and a mention of the old one.

(alias
  name: (_) @alias.name
  alias: (_) @alias.target) @alias

; --- the two core-library macros that declare methods ---
;
; `attr_accessor`, `attr_reader`, `attr_writer` and `define_method` are
; Module's own methods, not a framework's. An argument list of several symbols
; yields one match per symbol, so each declared accessor gets its own span.

(call
  method: (identifier) @attr.macro
  arguments: (argument_list (simple_symbol) @attr.name)
  (#any-of? @attr.macro "attr_accessor" "attr_reader" "attr_writer" "attr"))

(call
  method: (identifier) @define_method.macro
  arguments: (argument_list . (simple_symbol) @define_method.name)
  (#eq? @define_method.macro "define_method")) @define_method

; --- what a class or module takes in ---

(call
  method: (identifier) @mixin.macro
  arguments: (argument_list
    [(constant) @mixin.module
     (scope_resolution name: (constant) @mixin.module)])
  (#any-of? @mixin.macro "include" "extend" "prepend"))

; --- what a file loads ---
;
; The name is the path as written, so it can be matched against a file.

(call
  method: (identifier) @require.fn
  arguments: (argument_list . (string (string_content) @require.path))
  (#any-of? @require.fn "require" "require_relative" "load")) @require

; --- a call ---
;
; The span is the method name, not the call with its block: a mention is the
; bytes that name the thing. The macros above are excluded so that `require`
; and `include` are not also stored as calls to `require` and `include`.

(call
  method: [(identifier) (constant)] @call.name
  (#not-any-of? @call.name
     "require" "require_relative" "load"
     "include" "extend" "prepend"
     "attr" "attr_accessor" "attr_reader" "attr_writer"
     "define_method"))

; --- a constant ---
;
; The one name in Ruby that resolves across files.

(constant) @constant.ref

; --- where a constant or an object's state is set ---

(assignment left: (constant) @constant.assigned) @constant.assignment
(operator_assignment left: (constant) @constant.assigned) @constant.assignment

(assignment
  left: [(instance_variable) (class_variable) (global_variable)] @variable.assigned) @variable.assignment
(operator_assignment
  left: [(instance_variable) (class_variable) (global_variable)] @variable.assigned) @variable.assignment

[(instance_variable) (class_variable) (global_variable)] @variable.ref

; --- literals ---
;
; These are dropped from the IR, but their spans are read first: a role
; boundary that sits exactly on a literal is that literal, not a name.

