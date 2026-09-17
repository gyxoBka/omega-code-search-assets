# omega-r

Language `omega-r`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

18 templates over 13 query patterns, 6 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 1 |
| `definitions` | yes | 9 |
| `imports` | yes | 1 |
| `references` | yes | 4 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.function` | Callable | 2 |
| `definition.generic_method` | Callable | 1 |
| `definition.loop_variable` | Value | 1 |
| `definition.variable` | Value | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |

### Regions

- `scope.function_body` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.parameter` | reference | 1 |
| `call.function` | call | 1 |
| `import.package` | binding | 1 |
| `reference.member` | reference | 1 |
| `reference.package_member` | reference | 1 |
| `relation.depends` | depends | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 39 node types. The Pack looks at 34 of them.

Untouched:

- `comma`
- `comment`
- `escape_sequence`
- `program`
- `string_content`

`comma`, `escape_sequence`, `string_content` and `program` are punctuation, the
inside of a string and the file itself; none of them names anything. `comment`
is a flat token in this grammar, so a roxygen block (`#' @param x ...`) arrives
as a run of unstructured comment nodes with no field to capture -- see **Still
to decide**.

## What is wrong with it

This section describes the Pack as it was found, at version 1.0.0: 23 templates
over 27 patterns with 12 guards.

**An editor's highlighting model instead of an answer set (defect I).** Six of
the 27 patterns were a pasted `nvim-treesitter` `locals.scm`, carried with a
provenance header naming the provider, the snapshot marker and four sha256s.
`(binary_operator lhs: (identifier) @local.definition operator: "<-")` and three
siblings fed one template, `definition.r_symbol`, so the Pack's idea of what R
declares was "whatever an editor highlights as a local". That template took its
name from `@local.definition` and its span from the same capture, which is at
least a leaf; the companion `(function_definition) @local.scope` fed
`scope.r_lexical_scope`, whose name was the **whole function definition**.

**Five templates named an emission with a container (defect D2).** The audit
reported all five: `scope.r_lexical_scope` from `(function_definition)`,
`definition.r_function` from `(binary_operator)`, `call.r_function_call` from
`(call)`, `reference.r_namespace` from `(namespace_operator)` and
`binding.r_parameter` from `(parameter)`. Every one of them stored the source
text of the whole node as the name, so the declaration of `analyse` was named
`analyse <- function(x, y) {` plus the entire body, and the call to `mean` was
named `mean(x, na.rm = TRUE)`. None of them could ever match a reference, and
every one of them wrote a function body into the index once per call site.

**Four carriers carried nothing (defect: carrier).** `call.target_candidate`,
`scope.named_owner_candidate`, `binding.parameter_owned_candidate` and
`definition.identity_candidate` all end in `_candidate`, and the first three
fail `is_definition_kind`, so they were not folded at all -- they fell through
to the mention branch and were stored as references to nothing. The fourth,
`definition.identity_candidate`, does fold, but under `omega.pack.identity`,
which nothing in the host assembles. The one carrier that would have earned its
place -- the parameter list, which is one of the five names that build a card's
signature line -- was spelled `binding.parameter_owned_candidate` instead of
`definition.parameter_shape_candidate`, so the signature on every R function
card read `analyse -> ?` with the parameters missing.

**A name that is a constant (defect J).** `data.r_formula` set `name` to the
literal string `"r_formula"`, so every model formula in a repository -- and R
code is made of model formulas -- collapsed onto one entry called `r_formula`.

**Twelve guards, and not one of them was about R.** Eleven read as generator
confidence tiers or as generic compiler disclaimers: *"overload selection and
compile-time callable/type dispatch remain compiler semantics"* in a language
with no overloads and no compiler,
*"identity_candidate_is_syntactic; overload_namespace_module_visibility_and_cross_file_resolution_require_view_resolver_evidence"*
as a single underscored token. Three more described the same three `D1`
patterns in 40-word sentences each.

**Three patterns for one question.** `qualified_call_context`,
`qualified_call_assignment_identifier_context` and
`qualified_call_assignment_literal_context` are three separate patterns over
`pkg::fun(...)`, differing only in what the call is assigned to and what its
first argument is. They produced three kinds -- `reference.r_qualified_call_context`,
`..._assignment_identifier_context`, `..._assignment_literal_context` -- all of
which the host turns into the same occurrence (they contain `call`), each
carrying four fields nothing reads. One `namespace_operator` pattern states the
same fact once.

**Seven patterns rooted at `binary_operator`.** R spells every operator,
including both assignment arrows, as `binary_operator`, so each such pattern is
a scan over most of the nodes in the file. Four of the seven were the
`locals.scm` assignment spellings, which the Omega-owned section then restated.

**Nothing with a family.** Four declaration kinds: `definition.r_function`
(Callable), `definition.r_symbol` (Value) and two class-factory kinds that reach
Type only through the word `class` inside `r_class_factory_binding`. S4 generics
and methods, which are the whole of R's dispatch, were not declared at all;
`setGeneric` and `setMethod` were ordinary calls.

**A capability that answered nothing.** `data` carried four templates --
`r_formula`, `r_pipe`, `r_subset`, `r_subset2`. `data.r_pipe` was named from the
pipe operator token itself, so its name was `|>` or `special`; `data.r_subset`
was named from the subset target, which is `(_)` and so may be a whole nested
expression. All four are mentions that resolve against nothing.

**And the twenty-five node types the old Pack never looked at** included
`if_statement`, `while_statement`, `repeat_statement`, `return`,
`parenthesized_expression`, `braced_expression` and every literal node -- 25 of
the grammar's 39.

## What it should extract

R is the language of analysis scripts and of the packages those scripts load.
An R file is read to find out: *what function is defined here*, *what is it
called with*, *what name holds this result*, *which package does this file
need*, and *where does this name come from*. R has no declaration syntax -- a
name exists because something was assigned to it -- so the assignment operators
are the whole declaration surface of the language, and they have to be read
carefully rather than copied from a highlighter.

| what | node | emitted as | family |
|---|---|---|---|
| `f <- function(x)`, `f = ...`, `f <<- ...`, `f <- \(x) ...` | `binary_operator` with `function_definition` rhs, named by `lhs` | `definition.function` | Callable |
| `function(x) x -> f` | `binary_operator` with `function_definition` lhs | `definition.function` | Callable |
| its parameter list | `parameters` | `definition.parameter_shape_candidate` on the declaration | `omega.pack.parameter_shape` |
| its body | `function_definition` `body` | `scope.function_body`, named by the function | region |
| `x <- <anything not a function>` | `binary_operator`, named by `lhs` | `definition.variable` | Value |
| `... -> totals` | `binary_operator`, named by `rhs` | `definition.variable` | Value |
| a parameter name | `parameter` `name` | `binding.parameter` | reference |
| `for (region in regions)` | `for_statement` `variable` | `definition.loop_variable` | Value |
| `f(x)` | `call` with `identifier` function | `call.function` | call |
| `library(dplyr)`, `require("dplyr")` | `call`, first argument | `import.package` | binding |
| `source("helpers.R")` | `call`, first argument | `relation.depends` | depends |
| `setClass("Circle", ...)`, `setRefClass(...)` | `call`, first argument | `definition.class` | Type |
| `setGeneric("area", ...)`, `setMethod("area", ...)` | `call`, first argument | `definition.generic_method` | Callable |
| `dplyr::filter` -- the package | `namespace_operator` `lhs` | `relation.depends` | depends |
| `dplyr::filter` -- the name | `namespace_operator` `rhs` | `reference.package_member` | reference |
| `x$col`, `obj@slot` | `extract_operator` `rhs` | `reference.member` | reference |
| `y ~ x`, `%>%`, `x[i]`, `x[[i]]` | -- | nothing | -- |
| `if`, `while`, `repeat`, literals, comments | -- | nothing | -- |

Four notes on the choices in that table.

**Every name is a name, not a node.** No template's name expression is its own
span capture except `definition.loop_variable`, whose span is the loop variable
itself -- a leaf. A string-valued first argument (`setClass("Circle")`,
`source("x.R")`, `require("dplyr")`) is stripped of either quote style before it
becomes a name, so `Circle` resolves against the `Circle` written bare
elsewhere.

**One construct, one statement.** The generic call pattern carries a
`#not-any-of?` list of the nine functions that the import, source and class
patterns already state, so `library(dplyr)` is a package and not also a call to
`library`. That is the vbscript lesson applied before it can happen: without the
filter, `library` is among the most-called names in any R corpus.

**The value pattern lists its alternatives rather than writing `(_)`.** If
`x <- function(y) y` matched both the function pattern and the value pattern it
would be declared twice, once as a Callable and once as a Value, on the same
span and under the same name -- the omega-lua defect. The 29 non-function
right-hand sides are written out.

**The formula, the pipe and the subscript are dropped.** A formula names no
resolvable thing (and was the source of the constant name); a pipe operator is
control flow between two expressions the tree already holds; `x[i]` and `x[[i]]`
are indexing, whose "name" was a whole expression. The `data` capability goes
with them: the Pack has nothing to say under it.

**S4 stays, R6 does not.** `setClass`, `setRefClass`, `setGeneric` and
`setMethod` come from `methods`, which ships with R and is attached by default;
they are the only way the language declares a type or a dispatchable name, so
reading their literal first argument is a language fact. `R6Class` -- which the
old Pack matched alongside them -- comes from the R6 package, and a pattern for
a particular package's call shape belongs in `frameworks/`, not here. That is
defect L, and the old Pack carried it under a comment that began "Framework-neutral".

Five guards replace the twelve, each naming something an R programmer would
recognise as a limit: assignment forms that are function calls (`assign`,
`x$y <- v`, `attr<-`); run-time dispatch and `do.call`/`get`; S3 being a naming
convention and R6/S7 being packages; `library(pkg, character.only = TRUE)` and
DESCRIPTION; and `$` not distinguishing a data-frame column from an object
field.

## Still to decide

1. **Roxygen.** `#' @param`, `#' @export` and `#' @importFrom` are where an R
   package states its exports and its imports, and they are the documentation an
   agent most wants. tree-sitter-r lexes a comment as one flat `comment` token
   with no internal structure, so a query can reach the line but not its tag or
   its argument, and the six predicates that work cannot split a string. Stating
   `@export` would need either a decoder over the comment text or a grammar with
   a roxygen rule. Left out, and it is the largest thing this Pack cannot say.
2. **`$` and `@`.** Kept, as `reference.member`, on the grounds that R's
   Reference-class and environment code is written `obj$method()` and S4 slots
   are read `obj@slot`, and both have a declaration to reach. The cost is that
   `df$col`, which has none, is spelled identically and is far more common. A
   guard says so. If the member reference turns out to be the largest producer of
   unresolved mentions in an R corpus, restricting it to `@` is the fallback.
3. **The loop variable.** `for (i in 1:10)` declares `i`, and the Pack says so,
   which puts `i`, `j` and `x` into the declaration set of most R files. It is
   one template and it is true; revisit against the row count.
4. **Qualified calls are references, not calls.** `dplyr::filter(x)` is stated
   once, by the `namespace_operator` pattern, as a reference to `filter` plus a
   dependency on `dplyr`. Adding a second pattern for `call` with a
   `namespace_operator` function would make it a call as well, at the price of
   stating the same site twice. The reference resolves onto the same declaration
   either way, so the call flavour was not worth the duplication.
