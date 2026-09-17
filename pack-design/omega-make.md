# omega-make

Language `omega-make`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

7 templates over 10 query patterns, 22 of the grammar's 44 named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 2 |
| `references` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.make_target` | Value | 1 |
| `definition.make_variable` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.make_function` | call | 1 |
| `call.make_macro` | call | 1 |
| `reference.make_variable` | reference | 1 |
| `relation.depends` | depends | 2 |

There are no carriers, no scopes, no `data` and no `imports`: nothing in a
makefile builds a signature line, a makefile's regions are its rules and those
are already the declarations' own spans, and an `include` is a dependency on a
file rather than a binding of a name.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 44 node types. The Pack looks at 22 of them.

Untouched:

- `archive`
- `automatic_variable`
- `comment`
- `concatenation`
- `conditional`
- `else_directive`
- `elsif_directive`
- `escape`
- `ifeq_directive`
- `ifneq_directive`
- `makefile`
- `override_directive`
- `paths`
- `pattern_list`
- `private_directive`
- `raw_text`
- `recipe`
- `recipe_line`
- `shell_command`
- `shell_text`
- `string`
- `vpath_directive`

Most of these are reached without being named. `override`, `private` and
`export FOO = bar` wrap a `variable_assignment`, which is matched wherever it
sits; `conditional`, `else_directive` and `elsif_directive` hold ordinary
statements, and a query matches at any depth; `ifeq_directive` and
`ifneq_directive` hold `variable_reference` nodes, which are matched as uses;
`shell_text` and `shell_command` hold the `function_call` and
`variable_reference` nodes written inside a recipe, and those are matched too.
`concatenation`, `string`, `paths`, `pattern_list` and `archive` are ways of
spelling a word list and carry no name of their own.

Four are deliberate silences, each with a reason:

- `recipe`, `recipe_line`, `shell_text` — a recipe line is shell, and this Pack
  has no shell grammar. Naming one would store a command line as a name.
- `automatic_variable` — `$@`, `$<`, `$^` are make's built-ins. They are
  mentions that can never resolve onto a declaration, in any file, ever.
- `vpath_directive` — a search path is an instruction to make's file lookup,
  not a name a question resolves to; the Pack does not resolve paths.
- `comment`, `escape`, `raw_text`, `makefile` — no name.

## What is wrong with it

Measured on the Pack as found: **16 templates over 15 patterns, 9 guards,
touching 14 node types**, and `python pack-design/audit.py omega-make`
reporting six classes.

**Nothing in it stated the build graph.** A Makefile is one thing: a graph of
targets and what each needs. The host knows `relation.depends` by that exact
name and turns it into a depends edge. The Pack emitted **zero** `relation.*`
kinds. The two prerequisite templates were
`reference.make_target_prerequisite_context` and
`reference.make_order_only_prerequisite`, which are neither of the six
relations and arrive as plain references, indistinguishable from a mention of a
variable. The edge was restated instead as two `fields`, `owner_target` and
`prerequisite_target`, which only a framework overlay would ever read, and the
order-only template took **the whole rule as its span** — so a mention of `dir`
covered the target, the prerequisites and every line of the recipe.

**Six of 16 templates named an emission with a whole node** (audit class D2),
and in four of them that is also why the emission could never resolve:

| template | what it stored as a name |
|---|---|
| `definition.make_variable` | the whole `variable_assignment` — `CFLAGS := -O2 -Wall -Iinclude` |
| `definition.make_target` | the whole `targets` list — `all install clean` as one name |
| `import.make_candidate` | the whole `include_directive` — `include config.mk rules.mk` |
| `reference.make_include_path` | the same node again |
| `reference.make_variable` | the whole `variable_reference` — `$(CC)`, sigil and parentheses included |
| `reference.make_function_candidate` | the whole `function_call` — `$(wildcard src/*.c)` |

`$(CC)` is the reference that should resolve onto `CC`. Spelled `$(CC)` it
matched no declaration in any repository, and the declaration it should have
matched was itself named `CC := gcc`. **The one resolvable link the language
has was broken at both ends.**

**Four carriers the host will not fold, all four also under a name nothing
assembles.** `call.target_candidate`, `call.make_direct_candidate`,
`import.make_candidate` and `reference.make_function_candidate` end in
`_candidate`, but the fold is `is_definition_kind && is_carrier_kind` and a
kind starting with `call.`, `import` or `reference` fails the first test. So
each fell through to the mention branch and was stored as a call, a binding or
a reference whose name was the text above. And had they folded, they would have
folded to `omega.pack.target`, `omega.pack.make_direct`, `omega.pack.make` and
`omega.pack.make_function`, four names no part of the engine reads.

**Three templates could never fire at all.** The call pattern was
`(function_call function: (_) @call.target)`. `(_)` matches any *named* node,
and tree-sitter-make spells every function name as an anonymous token
(`function:` is one of `abspath`, `addprefix`, … `words`). The pattern matched
nothing, so `call.target_candidate`, `call.make_direct_candidate` and
`call.make_function` emitted nothing while the manifest went on declaring
`calls`. The validator cannot see this: each capture does exist in the file.
This is defect M with a cause worth naming — `(_)` where `_` was meant.

**The same variable declared twice, two ways.** `(variable_assignment)
@definition.variable` and `(variable_assignment name: (_) @make.variable.name)`
are two patterns over one node feeding two `definition.make_variable`
templates: every assignment in every makefile produced two declarations at the
same span, one named `CC` and one named `CC := gcc`. `definition.make_target`
and `definition.make_target_variable` are a second pair of spellings for one
construct (audit class K2 flagged `call.target_candidate` /
`call.make_direct_candidate`, which were byte-identical but for the kind).

**One constant name** (class J): `data.make_vpath` was named with the literal
`"VPATH"`, so every `VPATH = ...` line in the repository collapsed onto one
string.

**Five of nine guards were about another language.** "overload selection and
compile-time callable/type dispatch remain compiler semantics", "dynamic
dispatch and runtime callable/member targets remain runtime semantics",
"macro-expanded/generated callable targets remain compiler/generated
semantics" — make has no overloads, no dispatch and no compiler. Two more were
a single token (class G):
`make_dynamic_indirect_runtime_call_resolution_unavailable` and
`terminal_static_ceiling__make_variable_expansion_and_function_evaluation`. The
second one names the only limitation that is actually true of make, and it
names it as a label rather than a sentence.

**Untouched constructs that carry names.** `ifdef VERBOSE`, `ifndef DEBUG`,
`undefine FOO`, `export PREFIX`, `unexport LDFLAGS` and `$(SRCS:.c=.o)` are all
places where a makefile writes a variable name in full, and none of them was
matched: six node types, all of them uses that resolve onto a declaration.
`$(call build_lib,foo)` — the one call in the language of something a makefile
itself declares — was not matched either.

## What it should extract

A makefile is a build description. The questions asked of one are *what does
this project build*, *what does a target need before it can be built*, *where
is this variable set*, *where is it used*, and *which other makefiles does this
one pull in*.

| what | node | emitted as | family |
|---|---|---|---|
| a variable assignment | `variable_assignment` via `name: (word)` | `definition.make_variable` | Value |
| a shell assignment (`!=`) | `shell_assignment` via `name:` | `definition.make_variable` | Value |
| a multi-line `define` | `define_directive` via `name:` | `definition.make_variable` | Value |
| `VPATH =`, `.RECIPEPREFIX =` | `VPATH_assignment`, `RECIPEPREFIX_assignment` | `definition.make_variable` | Value |
| a target | `rule` via `(targets (word))` | `definition.make_target`, spanning the whole rule | Value |
| a prerequisite | `rule` via `normal: (prerequisites (word))` | `relation.depends` | depends |
| an order-only prerequisite | `rule` via `order_only: (prerequisites (word))` | `relation.depends` | depends |
| `$(CC)`, `${CC}` | `variable_reference` via its `(word)` | `reference.make_variable` | reference |
| `$(SRCS:.c=.o)` | `substitution_reference` via `text: (word)` | `reference.make_variable` | reference |
| `ifdef`, `ifndef`, `undefine`, `export`, `unexport` | those directives via their `(word)` | `reference.make_variable` | reference |
| `include other.mk` | `include_directive` via `filenames: (list (word))` | `relation.depends` | depends |
| `$(wildcard …)` and the other 32 builtins | `function_call` via its `function:` token | `call.make_function` | call |
| `$(shell …)` | `shell_function` | `call.make_function` | call |
| `$(call build_lib,foo)` | `function_call` with `function: "call"`, first argument | `call.make_macro` | call |
| make's special targets (`.PHONY:` and fifteen more) | `rule` | nothing | — |
| a recipe line | `recipe_line`, `shell_text` | nothing | — |
| `$@`, `$<`, `$^` | `automatic_variable` | nothing | — |

Three decisions in that table are worth their reasons.

**A target declaration spans its whole rule, not its target word.** The host
gives every mention the smallest declaration whose span contains it
(`content_builder.rs`, `enclosing`, sorted by span length). With the rule as
the span, a prerequisite, a `$(CFLAGS)` in the recipe and a `$(shell …)` at the
top of the recipe are all owned by the target they belong to, and containment
is stated once by the tree rather than by a pattern per level. `a b: c`
declares `a` and `b` over the same span, which is what the line means.

**`.PHONY: all clean` is excluded whole.** make's special targets are
directives spelled as rules. Declaring a target called `.PHONY` in every
makefile in the world is noise, and — worse — `all` does not depend on `clean`.
Sixteen special target names are filtered with `#not-any-of?`, which excludes
both the declaration and the false depends edges. This is the one place a
filter changes meaning rather than volume.

**A builtin function call resolves onto nothing, and is kept anyway.** The 33
function names are make's own vocabulary, not names a makefile declares, so
`call.make_function` is a mention with no declaration to reach. It is kept
because `$(shell …)` and `$(eval …)` are what an agent asks after when it asks
whether a build runs commands at parse time or generates rules — a question
answerable by the name alone. `$(call …)` is excluded from that list and stated
separately, because its first argument *does* name a declaration in the same
repository.

The Pack that results is 7 templates over 10 patterns with 4 guards, touching
22 node types instead of 14, and every emission is either a name a question can
resolve to or an edge the host knows by name.

## Still to decide

1. **The prerequisite patterns anchor the special-target filter to the first
   target.** `(targets . (word) @depends.owner)` costs one match per
   prerequisite rather than one per (target, prerequisite) pair, but it also
   means a rule whose *first* target is an expansion — `$(OBJS) extra: deps` —
   contributes no depends edges at all. The alternative is to drop the filter
   and accept `.PHONY`'s prerequisites as dependencies, which is wrong rather
   than merely incomplete. Chosen: keep the filter; revisit if a corpus shows
   variable-headed rules are common.
2. **A target-specific variable (`debug: CFLAGS += -g`) is declared under its
   own name, and the target it is scoped to is not recorded.** The scoping
   could be carried as an attribute, but no carrier name the engine reads means
   "the target this assignment is scoped to", and an ordinary attribute would
   be stored and never asked for. Left unstated.
3. **The assignment flavour (`=` vs `:=` vs `+=`) is not stored.** It answers a
   real question when tracing where a value came from, but it would be an
   attribute on every variable declaration in the index, and the declaration's
   span already contains the operator.
