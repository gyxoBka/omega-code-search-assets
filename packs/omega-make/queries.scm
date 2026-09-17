; omega-make
;
; A Makefile is a build description. The questions asked of one are: what does
; this project build, what does a target need before it can be built, where is
; a variable set, where is it used, and which other makefiles does this one
; pull in. Every pattern below answers one of them.
;
; Containment is deliberately not stated. A target's declaration spans its
; whole rule, so the prerequisites, the variable references and the function
; calls written inside it are already owned by it; a pattern per level would
; cost a match per tuple to repeat what the tree holds.

; --- a variable ---
;
; The five spellings of "this makefile names a value" are one pattern: the
; ordinary assignment (`=`, `:=`, `::=`, `?=`, `+=`), the shell assignment
; (`!=`), the multi-line `define`, and make's two built-in assignment forms,
; whose names this grammar spells as anonymous tokens.
;
; `override`, `private` and `export FOO = bar` wrap a variable_assignment
; rather than replacing it, so they need no pattern of their own. A
; target-specific variable (`debug: CFLAGS += -g`) is a variable_assignment
; too, and is declared here once, under its own name.

[(variable_assignment name: (word) @variable.name)
 (shell_assignment name: (word) @variable.name)
 (define_directive name: (word) @variable.name)
 (VPATH_assignment name: "VPATH" @variable.name)
 (RECIPEPREFIX_assignment name: ".RECIPEPREFIX" @variable.name)] @variable

; --- a target ---
;
; The span is the whole rule, recipe included: that is the extent of "how this
; thing is built", and it makes the rule's prerequisites and variable uses
; belong to the target without a containment pattern.
;
; `a b: c` declares both `a` and `b`, so the target word is not anchored.
;
; make's special targets are directives spelled as rules. `.PHONY: all clean`
; declares nothing called `.PHONY` and `all` does not depend on `clean`, so
; the whole rule is excluded rather than half of it.

(rule
  (targets (word) @target.name)
  (#not-any-of? @target.name
    ".PHONY" ".SUFFIXES" ".DEFAULT" ".PRECIOUS" ".INTERMEDIATE"
    ".NOTINTERMEDIATE" ".SECONDARY" ".SECONDEXPANSION" ".DELETE_ON_ERROR"
    ".IGNORE" ".LOW_RESOLUTION_TIME" ".SILENT" ".EXPORT_ALL_VARIABLES"
    ".NOTPARALLEL" ".ONESHELL" ".POSIX")) @target.rule

; --- what a target needs ---
;
; A prerequisite is the one real edge in the language: `depends`, which the
; host knows by that exact name. It resolves onto the target declared above or
; onto a source file elsewhere in the repository.
;
; The owner is the first target only. It is captured to carry the special
; target filter, and anchoring it keeps the pattern linear instead of one
; match per (target, prerequisite) pair.
;
; An order-only prerequisite (`| dir`) is the same edge with a weaker rule
; about rebuilding, so it is stated under the same kind.

(rule
  (targets . (word) @depends.owner)
  (#not-any-of? @depends.owner
    ".PHONY" ".SUFFIXES" ".DEFAULT" ".PRECIOUS" ".INTERMEDIATE"
    ".NOTINTERMEDIATE" ".SECONDARY" ".SECONDEXPANSION" ".DELETE_ON_ERROR"
    ".IGNORE" ".LOW_RESOLUTION_TIME" ".SILENT" ".EXPORT_ALL_VARIABLES"
    ".NOTPARALLEL" ".ONESHELL" ".POSIX")
  normal: (prerequisites (word) @depends.name))

(rule
  (targets . (word) @depends.owner)
  (#not-any-of? @depends.owner
    ".PHONY" ".SUFFIXES" ".DEFAULT" ".PRECIOUS" ".INTERMEDIATE"
    ".NOTINTERMEDIATE" ".SECONDARY" ".SECONDEXPANSION" ".DELETE_ON_ERROR"
    ".IGNORE" ".LOW_RESOLUTION_TIME" ".SILENT" ".EXPORT_ALL_VARIABLES"
    ".NOTPARALLEL" ".ONESHELL" ".POSIX")
  order_only: (prerequisites (word) @depends.name))

; --- where a variable is used ---
;
; The name is taken from the word inside the reference, not from the
; reference's own text, so `$(CC)` is a use of `CC` and resolves onto the
; assignment that declares it. `$(SRC:.c=.o)` names `SRC` the same way.
;
; `$($(TOOL)_FLAGS)` is a use of `TOOL` only; the outer reference has no
; literal name and is left unstated.

[(variable_reference (word) @variable.ref.name)
 (substitution_reference text: (word) @variable.ref.name)] @variable.ref

; --- where a variable is named by a directive ---
;
; These four directives take a bare variable name rather than a reference, so
; `ifdef VERBOSE` and `export PREFIX` are uses of the same names the
; assignments above declare.

[(ifdef_directive variable: (word) @variable.ref.name)
 (ifndef_directive variable: (word) @variable.ref.name)
 (undefine_directive variable: (word) @variable.ref.name)
 (export_directive variables: (list (word) @variable.ref.name))
 (unexport_directive variables: (list (word) @variable.ref.name))] @variable.ref

; --- what this makefile pulls in ---
;
; `include config.mk` is a dependency on another file, written as it appears.
; A path built by expansion has no literal word here and is not stated.

(include_directive
  filenames: (list (word) @include.path))

; --- make's own functions ---
;
; The function names are a closed set of anonymous tokens in this grammar, so
; they are listed. `$(shell ...)` has its own node and is the same fact.
; `call` is left out: it is the one function whose first argument names
; something this Pack declares, and it is stated below instead.

(function_call
  function: [
    "abspath" "addprefix" "addsuffix" "and" "basename" "dir" "error" "eval"
    "file" "filter" "filter-out" "findstring" "firstword" "flavor" "foreach"
    "if" "info" "join" "lastword" "notdir" "or" "origin" "patsubst" "realpath"
    "sort" "strip" "subst" "suffix" "value" "warning" "wildcard" "word"
    "wordlist" "words"
  ] @function.name) @function.call

(shell_function
  function: "shell" @function.name) @function.call

; --- a call of a makefile's own macro ---
;
; `$(call build_lib,foo)` invokes the variable `build_lib`, usually written as
; a `define`. The first argument is the only name in the language that is a
; call of something the makefile itself declares.

(function_call
  function: "call"
  (arguments . (text) @macro.name)) @macro.call
