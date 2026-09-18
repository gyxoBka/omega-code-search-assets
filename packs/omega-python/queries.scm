; omega-python
;
; Python is written as modules of functions and classes, and the names that
; cross a file boundary are the ones a module imports, the ones it declares at
; module or class level, the base classes it extends, the decorators it applies
; and the functions it calls. The questions asked of a Python file are: where
; is this function or class defined, what does this file import and what does
; a short alias stand for, what does this class inherit, who calls this, what
; is this annotated with, and which test covers this name. Every pattern below
; answers one of them.
;
; Containment is not stated as a pattern. The tree already holds it, a nested
; declaration carries its container through the `within:` segment, and the
; extent of a class or a function body is emitted once as a region.
;
; Names bound inside a function body -- an assignment, a `for` target, a
; `with`/`except` alias, a comprehension variable, a `match` capture -- are
; deliberately absent. They resolve to nothing outside their own block and
; there are more of them in a Python repository than of everything else here
; put together.

; --- a class ---
;
; One match carries the declaration, its region and its type parameters.

(class_definition
  name: (identifier) @class.name
  type_parameters: (type_parameter)? @class.type_parameters
  body: (block) @class.body) @class

; --- what a class extends ---
;
; `class C(Base)` and `class C(pkg.Base)`. A qualified base is reduced to its
; last identifier so that it is spelled the way the declaration of that class
; is spelled. Keyword arguments in the header (`metaclass=`) are not bases.

(class_definition
  superclasses: (argument_list
    [(identifier) @class.base
     (attribute attribute: (identifier) @class.base)]))

; --- a function ---
;
; The parameter list, the return annotation and the type parameters are
; carried on the declaration, not emitted on their own: they are signature
; components, and a mention of `(self, timeout=5)` resolves to nothing.

(function_definition
  name: (identifier) @function.name
  type_parameters: (type_parameter)? @function.type_parameters
  parameters: (parameters) @function.parameters
  return_type: (type)? @function.return_type
  body: (block) @function.body) @function

; --- a type alias ---

(type_alias_statement
  left: (type
    [(identifier) @type_alias.name
     (generic_type (identifier) @type_alias.name)])) @type_alias

; --- a module-level name ---
;
; `TIMEOUT = 30` at the top of a file is the one Python construct that answers
; "where is this configured". The span is the assignment, so the card shows
; the value without the Pack storing it a second time.

(module
  (expression_statement
    (assignment left: (identifier) @module_variable.name) @module_variable))

; --- a class-level name ---
;
; A class body's own assignments: the fields of a dataclass, a model or a
; settings class.

(class_definition
  body: (block
    (expression_statement
      (assignment left: (identifier) @class_variable.name) @class_variable)))

; --- what is applied to a declaration ---
;
; `@property`, `@app.route(...)`, `@pytest.fixture`. Named by the last
; identifier, so it resolves to the declaration of the decorator itself.

(decorator
  [(identifier) @decorator.name
   (attribute attribute: (identifier) @decorator.name)
   (call
     function: [(identifier) @decorator.name
                (attribute attribute: (identifier) @decorator.name)])])

; `reference.decorator_applied` -- the same decorator as a fact of its own,
; carrying what it was given and what it is on. It is a second emission on the
; same span rather than a field on `reference.decorator`, so a rule matching the
; plain kind does not fire twice. Read it with `fact_join_by_span` `relation:
; "same"`.
;
; What it was given and what it is on. A decorator and
; the declaration it decorates are SIBLINGS under `decorated_definition`, so no
; span join reaches from one to the other: the target has to be captured in the
; pattern that captures the decorator. `@app.route("/users")` is where a Flask
; URL is stated, and `@field_validator("title")` is what a Pydantic validator
; validates.

(decorated_definition
  (decorator
    [(identifier) @decorator.applied.name
     (attribute attribute: (identifier) @decorator.applied.name)
     (call
       function: [(identifier) @decorator.applied.name
                  (attribute attribute: (identifier) @decorator.applied.name)]
       arguments: (argument_list) @call.args)])
  definition: [(function_definition name: (identifier) @decorator.target)
               (class_definition name: (identifier) @decorator.target)])

; --- a call ---
;
; The span is the name that is called, not the call with its arguments: a
; mention is the bytes that name the thing.

; The argument list is captured beside the name, because a call's positional
; arguments are what a framework overlay asks a call for -- a Django route, a
; Pydantic field alias, a torch extension's source list -- and they are the
; ordered children of the node the call already names them in.

(call
  function: (identifier) @call.name
  arguments: (argument_list) @call.args)

(call
  function: (attribute
    object: (_) @call.receiver
    attribute: (identifier) @call.method)
  arguments: (argument_list) @call.args)

; --- an annotation ---
;
; Every `type` node names a type, and a nested one (`dict[str, Model]`) is a
; `type` node in its own right, so this one pattern reaches the whole
; annotation without stating containment.

(type
  [(identifier) @type.name
   (attribute attribute: (identifier) @type.name)
   (generic_type (identifier) @type.name)
   (member_type (identifier) @type.name)])

; --- what a file imports ---
;
; `import a.b`, `import a.b as c`, `from a.b import c`, `from a.b import c as d`
; and `from __future__ import x`. The module path is kept as written, leading
; dots and all; the alias is bound separately and carries the name it stands
; for, which is what answers "what is `np`".

(import_statement name: (dotted_name) @import.module)

(import_statement
  name: (aliased_import
    name: (dotted_name) @import.alias.module
    alias: (identifier) @import.alias.name) @import.alias)

(import_from_statement
  module_name: [(dotted_name) (relative_import)] @import.from.module)

(import_from_statement name: (dotted_name) @import.symbol)

(import_from_statement
  name: (aliased_import
    name: (dotted_name) @import.from_alias.target
    alias: (identifier) @import.from_alias.name) @import.from_alias)

(future_import_statement name: (dotted_name) @import.future)

; --- a name declared to live in an outer scope ---

(global_statement (identifier) @global.name)

(nonlocal_statement (identifier) @nonlocal.name)

; --- a test, and what its name says it covers ---
;
; Python's test conventions are older than any one runner: `test_parse_header`
; names `parse_header`, `TestParser` names `Parser`. The declaration itself is
; already stated above; this is the edge from it to the name under test.

(function_definition
  name: (identifier) @test.function.name
  (#match? @test.function.name "^test_.")) @test.function

(class_definition
  name: (identifier) @test.class.name
  (#match? @test.class.name "^Test.")) @test.class
