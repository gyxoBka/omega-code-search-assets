; omega-twig
;
; Twig is the template layer of a PHP application. A `.twig` file is not a
; program: it declares blocks a child template may override, macros other
; templates call, and the local names `{% set %}` and `{% for %}` introduce;
; it depends on other templates by path; and it reads a context its controller
; supplies. Those five things are what an agent asks about, and every pattern
; below answers one of them.
;
; Two facts about this grammar shape everything here.
;
; 1. There is no block structure. `template` is a flat repeat of
;    `statement_directive`, `output_directive`, `comment` and `content`, so
;    `{% block x %}` and `{% endblock %}` are sibling nodes and nothing
;    contains a body. No region can be emitted and no declaration is nested
;    inside another; the coverage guards say so.
; 2. `tag_statement` is the catch-all: `{% <name> <expr>* %}`, with `include`,
;    `embed` and `with` aliased into it. So `block`, `extends`, `include`,
;    `embed` and `use` are all one node type and are separated by `#eq?` /
;    `#any-of?` on the tag text, which are tree-sitter's own predicates and do
;    filter.
;
; Containment is deliberately not stated: the tree already holds it.

; --- a block ---
;
; `{% block content %}`. The name is an `identifier` aliased to `variable`,
; not a `name` node -- the shipped Pack asked for `(name)`, which
; `tag_statement` never holds, so it declared no block in any file.
; Anchored to the first expression so `{% block title page.title %}` is
; declared as `title`.

((tag_statement
   (tag) @block.tag . (variable) @block.name) @block
 (#eq? @block.tag "block"))

; --- what this template depends on ---
;
; `{% extends %}`, `{% include %}`, `{% embed %}` and `{% use %}` all name
; another template by path. Double-quoted strings are `interpolated_string` in
; this grammar, so both spellings are taken.

((tag_statement
   (tag) @depends.tag . [(string) (interpolated_string)] @depends.path) @depends
 (#any-of? @depends.tag "extends" "include" "embed" "use"))

; --- a macro ---
;
; `{% macro input(name, value = '') %}`. The declaration and its parameter
; shape are two templates over this one match; `parameters` is optional, and
; the template that needs it is skipped when it is absent.

(macro_statement
  (method) @macro.name
  (parameters)? @macro.parameters) @macro

; A macro parameter is a local name the macro body uses. The grammar leaves
; the parameter's own identifier as an anonymous token and exposes only the
; default value, so the name is taken from the parameter's text up to `=`.

(parameter) @macro.parameter

; --- the names a template introduces ---
;
; `{% set page = 1 %}`. Anchored to the variable that follows the `set`
; keyword: the right-hand side of the assignment is a direct `variable` child
; too, and without the anchor `{% set a = b %}` would declare `b`.

(assignment_statement
  (keyword) @set.keyword . (variable) @set.name) @set

; `{% for user in users %}`. Anchored to the variable that follows `for`.

(for_statement
  (repeat) @for.keyword . (variable) @for.name) @for

; --- imports ---
;
; `{% import "forms.html.twig" as forms %}` -- the template imported, and the
; local alias it is given. Two patterns, because `{% import _self as forms %}`
; has no string and the alias must still be stated.

(import_statement
  (tag) @import.tag . [(string) (interpolated_string)] @import.path) @import

(import_statement
  (keyword) @import.as . (name) @import.alias) @import.alias_stmt

; `{% from "forms.html.twig" import input as field %}` -- the template, and
; the macro taken from it. The `#eq?` picks the name after `import`, which is
; the macro as the other template declares it; the name after `as` is a local
; alias and is not stated.

(from_statement
  (tag) @from.tag . [(string) (interpolated_string)] @from.path) @from

((from_statement
   (keyword) @from.keyword . (name) @from.symbol) @from.symbol_stmt
 (#eq? @from.keyword "import"))

; --- what a template calls and applies ---
;
; `{{ path('app_home') }}`, `{{ forms.input(name) }}`. A dotted target is
; reduced to its last segment in the template, so a call to an imported macro
; resolves onto the `{% macro %}` that declares it.

(function_call
  (function_identifier) @call.name) @call

(filter
  (filter_identifier) @filter.name) @filter

; `{% if user is defined %}` -- the test applied, `defined`, `empty`,
; or one an extension adds.

(test) @test.name

; --- what this template reads from its context ---
;
; The head identifier of an output directive, of a loop's sequence and of a
; condition. These are the three places a template consumes a value its
; controller passed in. A bare `(variable)` capture would store every
; identifier of every file instead, which is not an answer.

[(output_directive (variable) @context.variable)
 (for_statement (keyword) @context.in . (variable) @context.variable)
 (if_statement (conditional) @context.if . (variable) @context.variable)]
