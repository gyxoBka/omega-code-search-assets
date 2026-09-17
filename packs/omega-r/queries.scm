; omega-r
;
; R is the language of analysis scripts and of the packages those scripts load.
; The questions asked of an R file are: what function is defined here, what is
; it called with, what name holds this result, which package does this file
; need, and where does this name come from. Every pattern below answers one of
; them.
;
; Containment is not stated. A function's extent is one `scope.function_body`
; region; nesting is already in the tree and reaches a query through the host's
; `within:` segment.
;
; R has no declaration syntax: a name exists because something was assigned to
; it. So the four assignment patterns are the whole declaration surface of the
; language, and they are written as four patterns rather than one because a
; function and a value are different answers.

; --- a function ---
;
; `f <- function(x) ...`, `f = function(x) ...`, `f <<- function(x) ...` and
; the lambda spelling `f <- \(x) ...`, which is the same node.
;
; Three templates over this one match: the declaration, the parameter list
; carried onto it so the card's signature line reads, and the body as a region.

(binary_operator
  lhs: (identifier) @function.name
  operator: ["<-" "<<-" "="]
  rhs: (function_definition
    parameters: (parameters) @function.parameters
    body: (_) @function.body)) @function

; --- a function bound by right assignment ---
;
; `function(x) x -> f`. The same three facts, mirrored.

(binary_operator
  lhs: (function_definition
    parameters: (parameters) @rfunction.parameters
    body: (_) @rfunction.body)
  operator: ["->" "->>"]
  rhs: (identifier) @rfunction.name) @rfunction

; --- a value bound to a name ---
;
; Every right-hand side except `function_definition`, which the pattern above
; already declares as a Callable. Listing the alternatives rather than writing
; `(_)` is what keeps one construct from being declared twice under two
; families.

(binary_operator
  lhs: (identifier) @variable.name
  operator: ["<-" "<<-" "="]
  rhs: [
    (binary_operator) (braced_expression) (break) (complex)
    (dot_dot_i) (dots) (extract_operator) (false) (float) (for_statement)
    (identifier) (if_statement) (inf) (integer) (na) (namespace_operator)
    (nan) (next) (null) (parenthesized_expression) (repeat_statement)
    (return) (string) (subset) (subset2) (true) (unary_operator)
    (while_statement)
  ]) @variable

; A call-valued assignment is a variable too, except when the call is one of the
; factories declared below. `Gen <- setClass("Gen", ...)` is the form in
; ?setClass's own examples, and without this it was declared twice: once here as
; a Value named Gen and once by the class pattern as a Type named Gen, on two
; different spans, so nothing deduplicated them.

((binary_operator
   lhs: (identifier) @variable.name
   operator: ["<-" "<<-" "="]
   rhs: (call function: (identifier) @_rhs.callee)) @variable
 (#not-any-of? @_rhs.callee
   "setClass" "setRefClass" "setGeneric" "setMethod"
   "library" "require" "requireNamespace" "loadNamespace" "attachNamespace"
   "source" "sys.source"))

; --- a value bound by right assignment ---
;
; `x |> summarise(...) -> totals` is the idiomatic end of a pipeline.

(binary_operator
  lhs: [
    (binary_operator) (braced_expression) (break) (call) (complex)
    (dot_dot_i) (dots) (extract_operator) (false) (float) (for_statement)
    (identifier) (if_statement) (inf) (integer) (na) (namespace_operator)
    (nan) (next) (null) (parenthesized_expression) (repeat_statement)
    (return) (string) (subset) (subset2) (true) (unary_operator)
    (while_statement)
  ]
  operator: ["->" "->>"]
  rhs: (identifier) @rvariable.name) @rvariable

; --- a parameter ---
;
; Rooted at `parameter`, so it holds for a named function and for an anonymous
; one passed to `lapply` alike.

(parameter
  name: (identifier) @parameter.name) @parameter

; --- a call ---
;
; The named constructs below are stated once, as what they are, rather than
; twice -- once as themselves and once as a call to `library` or `setClass`.

((call
  function: (identifier) @call.name) @call
 (#not-any-of? @call.name
   "library" "require" "requireNamespace" "loadNamespace" "attachNamespace"
   "source" "sys.source"
   "setClass" "setRefClass" "setGeneric" "setMethod"))

; --- a package this file needs ---
;
; `library(dplyr)` and `require("dplyr")`: the package is the first argument,
; spelled bare or quoted.

((call
  function: (identifier) @import.function
  arguments: (arguments
    . (argument
        value: [(identifier) (string)] @import.name))) @import
 (#any-of? @import.function
   "library" "require" "requireNamespace" "loadNamespace" "attachNamespace"))

; --- a file this file needs ---

((call
  function: (identifier) @source.function
  arguments: (arguments
    . (argument
        value: (string) @source.path))) @source
 (#any-of? @source.function "source" "sys.source"))

; --- a class ---
;
; S4 and Reference classes are declared by a call whose first argument is the
; class name. This is `methods`, which ships with R, not a third-party object
; system; R6 and S3 are not stated here (see the guards).

((call
  function: (identifier) @class.factory
  arguments: (arguments
    . (argument
        value: (string) @class.name))) @class
 (#any-of? @class.factory "setClass" "setRefClass"))

; --- a generic and its methods ---
;
; `setGeneric("area", ...)` and `setMethod("area", "Circle", ...)` both name the
; generic, and both are callable under that name.

((call
  function: (identifier) @generic.factory
  arguments: (arguments
    . (argument
        value: (string) @generic.name))) @generic
 (#any-of? @generic.factory "setGeneric" "setMethod"))

; --- a name taken from a package ---
;
; `dplyr::filter` states two things: this file depends on `dplyr`, and it
; refers to `filter`. Two templates, one match.

(namespace_operator
  lhs: (identifier) @namespace.package
  rhs: (identifier) @namespace.member) @namespace

; --- a member of an object ---
;
; `x$field` and `obj@slot`. The member name only; the receiver is the span.

(extract_operator
  rhs: (identifier) @member.name) @member

; --- a loop variable ---
;
; `for (region in regions)` binds `region` in the enclosing environment, which
; is a declaration in R even though it has no assignment operator.

(for_statement
  variable: (identifier) @loop.variable)
