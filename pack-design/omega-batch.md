# omega-batch

Language `omega-batch`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

13 templates over 11 query patterns, 11 distinct root node types, 18 node types
mentioned in all.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 3 |
| `data` | yes | 1 |
| `definitions` | yes | 6 |
| `references` | yes | 2 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.procedure` | Callable | 1 |
| `definition.variable` | Value | 2 |
| `definition.input_variable` | Value | 1 |
| `definition.loop_variable` | Value | 1 |

### Carriers

| kind | folds onto | as |
|---|---|---|
| `definition.value_candidate` | `definition.variable` at the same span | `omega.pack.value` |

### Regions

- `scope.for_loop` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.procedure` | call | 1 |
| `call.script` | call | 1 |
| `call.command` | call | 1 |
| `reference.procedure` | reference | 1 |
| `reference.variable` | reference | 1 |
| `relation.data` | data | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 53 node types. The Pack looks at 18 of them.

Untouched:

- `argument_list`
- `argument_value`
- `assignment_literal`
- `assignment_paren_group`
- `bracketed_literal`
- `bracketed_value`
- `command_option`
- `command_sep`
- `comment`
- `comparison_op`
- `cond_exec`
- `echo_off`
- `else_clause`
- `endlocal_stmt`
- `exit_stmt`
- `fd_redirect`
- `fd_redirect_op`
- `for_options`
- `for_set`
- `for_set_group`
- `for_set_literal`
- `if_option`
- `if_stmt`
- `integer`
- `macro_invocation`
- `paren_expression`
- `parenthesized`
- `pipe_stmt`
- `program`
- `redirect_op`
- `redirect_stmt`
- `set_keyword`
- `set_option`
- `setlocal_stmt`
- `string`

Every one of those is punctuation (`set_keyword`, `set_option`, `redirect_op`,
`command_sep`, `for_options`, `if_option`), a container the tree already states
(`program`, `parenthesized`, `pipe_stmt`, `cond_exec`, `redirect_stmt`,
`if_stmt`, `else_clause`), a literal fragment of a value the Pack already
carries whole (`assignment_literal`, `assignment_paren_group`,
`bracketed_literal`, `argument_value`, `string`, `integer`), or a construct
whose name is not reachable -- see **Still to decide**.

## What is wrong with it

These are the defects of the Pack as found, at 13 templates over 11 patterns
and 3 guards.

**Three of 13 templates named an emission with the whole statement (Defect D).**
`call.batch_call_statement` took its name from `@call.statement`, the entire
`call_stmt`; `call.batch_command` from `@call.command_statement`, the entire
`cmd`; `scope.batch_for` from `@batch.for.scope`, the entire `for_stmt` -- a
region named with every byte of the loop it delimits, body included. The
adjacent captures that hold the actual names (`(command_name)`,
`(for_variable)`) were bound in the very same patterns and not used. So
`call msbuild.exe /p:Configuration=Release build.sln > build.log` was stored as
a call *named* that whole line, and a nested `for` stored the text of every
statement inside it as the name of a scope.

**The same node stated twice under two spellings (Defect K).** One pattern read
`(variable_reference) @reference.variable @batch.variable.reference` -- two
captures on one node -- and two templates, `reference.batch_variable_reference`
and `reference.batch_variable`, each emitted a reference with the same name at
the same span. Every `%PATH%` in the corpus was stored twice. `call_stmt` was
likewise read by `call.batch_call_statement`, named with the statement, while
the `@call.target` capture that holds the actual target was bound by the same
pattern and read by no template at all.

**Nothing that a reference could resolve to.** The Pack declared exactly two
kinds: `definition.constant` (from `set NAME=`, named from `variable_name` --
correct) and `definition.function` (from `label`, named from the label node's
own text, *including the leading colon*). Meanwhile the three things batch
actually links were not stated, or were stated in a spelling that could never
meet a declaration:

- `goto` was not stated. `goto_stmt` appears in no pattern, so the commonest
  jump in the language produced nothing.
- `call :build` bound `@call.target` and no template read it, so the one
  spelling of a subroutine call was dropped on the floor.
- `%NAME%` was emitted verbatim, sigils and all, while the declaration was
  emitted as `NAME`. `%PATH%` and `set PATH=` could never resolve to each
  other. The same for labels: the declaration was `:build`, so even had `goto`
  been stated, the two spellings differed by a colon.
- Batch is case-insensitive in labels, variable names and command words. Both
  sides were stored as written, so `%Path%`, `%PATH%` and `%path%` were three
  names.

**Three of three guards gave a label instead of a reason (Defect G).**
`terminal_static_ceiling__batch_command_target_resolution`,
`batch_helix_ast_fact_not_symbol_truth` and
`terminal_static_ceiling__batch_for_runtime_expansion_and_delayed_environment`.
The second is not a limitation of batch at all; it is a note about where the
query fragment was copied from.

**A `semantic_hint` that repeated a declaration.**
`semantic_hint.batch_label_structure_hint` was a second capture
(`@structural.candidate`) on the very `(label)` node that `definition.function`
already declared, emitting the same text again as a mention under the `data`
capability. It answered no question the declaration did not already answer.

**Four of eleven patterns were a generator's second pass over the same nodes.**
The file carried five banner comments naming the batch that produced each group
-- `semantic_closure_v3_146_batch2`, `_batch4`, `p1-exact-helix-tags`,
`helix_independent_structural`, `terminal_batch_for_semantics_v1` -- two of
which contained no patterns at all. `(for_stmt) @batch.for.scope` and
`(for_stmt (for_variable) @batch.for.binding) @batch.for` are two matches over
one node for two facts one match carries; `(for_variable) @batch.for.variable`
is a third. `(variable_assignment (set_keyword) (variable_name))` and
`(variable_assignment (variable_name) @batch.assignment.name) @batch.assignment`
are the same node asked for twice.

**`bindings` was declared and programmed with four templates nothing could
resolve against.** `binding.*` is not a definition kind, so the host files it as
a plain reference (§5). `binding.batch_assignment`, `binding.batch_for`,
`binding.batch_for_variable` and `binding.batch_prompt_assignment` therefore
emitted mentions of names whose declarations the Pack either also emitted (the
`set`) or never emitted at all (the loop variable, the `set /p`). The capability
is gone; the loop variable and the prompt assignment are declarations now.

## What it should extract

A batch file is a build step, an installer, a launcher or a CI entry point. The
questions asked of one are: *which subroutines does this script define and who
jumps into them*, *which environment variables does it set and where are they
read*, *which programs does it run*, *which other scripts does it call*, and
*which files does it write*.

Batch has exactly three name spaces a question can resolve in -- labels,
variables, command words -- and all three are case-insensitive. Every name below
is lowered and stripped of its sigil on both sides of the link, which is the
whole reason the rewrite resolves where the old Pack did not.

| what | node | emitted as | family |
|---|---|---|---|
| a label, `:build` | `label` | `definition.procedure` | Callable |
| `set NAME=value` | `variable_assignment` via `variable_name` | `definition.variable` | Value |
| its value | `assignment_value`, `quoted_assignment_value`, `caret_quoted_assignment_value` | `definition.value_candidate` carrier on the declaration | attribute `omega.pack.value` |
| `set /p NAME=` | `prompt_assignment` via `variable_name` | `definition.input_variable` | Value |
| `set /a NAME=expr` | `arithmetic_assignment` via `arithmetic_expression` | `definition.variable` | Value |
| `for %%i in (...)` | `for_variable` | `definition.loop_variable` | Value |
| the loop's extent | `for_stmt` | `scope.for_loop`, named with the loop variable | region |
| `call :build` | `call_stmt` whose `command_name` starts with `:` | `call.procedure` | call |
| `call other.bat` | `call_stmt` whose `command_name` does not | `call.script` | call |
| `goto :build` | `goto_stmt` | `reference.procedure` | reference |
| `msbuild x.sln` | `cmd` via `command_name` | `call.command` | call |
| `%NAME%`, `!NAME!`, `%~dp0`, `%1` | `variable_reference` | `reference.variable` | reference |
| `> build.log` | `redirection` via `redirect_target` | `relation.data` | data |
| comments, separators, options, containers | `comment`, `command_sep`, `set_option`, `program`, `parenthesized`, ... | nothing | -- |

`definition.procedure` is deliberate: batch's only named unit of code is the
label, it is entered with `call`, and `procedure` is the word that puts it in
Callable. `definition.constant`, the old spelling for `set`, was wrong twice
over -- a batch variable is the opposite of a constant, and `constant` lands in
Value by accident rather than by choice.

Two grammar facts shape the patterns, and the validator confirmed both by not
refusing them:

- **`goto_stmt` has no named child for its target.** Its only named children are
  `comment` and `variable_reference`; the label is an anonymous token. The
  statement is captured whole and the target taken from its text --
  `strip_prefix "@"`, `strip_prefix "goto"`, `strip_prefix ":"`,
  `first(split " ")` over the lowered text, which reads `goto :eof`, `GOTO:EOF`,
  `@goto end` and `goto build` alike.
- **`set /a` spells its target inside one `arithmetic_expression` token.**
  `arithmetic_assignment` has only `arithmetic_expression` and `set_option` as
  children, so `set /a COUNT=COUNT+1` reaches its name as the text before the
  first `=`, with a trailing `+ - * /` stripped for the compound forms.

Containment is not stated anywhere. `program`, `parenthesized`, `pipe_stmt`,
`cond_exec` and `command_sep` are containers the tree already holds, and a batch
file has no nesting that a pattern per depth would pay for.

## The audit's two remaining flags, and why they are right here

`pack-design/audit.py` reports zero for every defect class except two, both on
the one carrier:

1. **"carrier that may overwrite itself".** `tree-sitter-batch` puts every child
   of `variable_assignment` into a single `"multiple": true` group, so
   `node-types.json` cannot say that a `set` statement has at most one value.
   This is the grammar shape wave 9 named on `create_function`: any Pack writing
   any carrier over such a grammar is reported. A `set` statement has one value
   in the language.
2. **"carrier under a name nothing assembles".** `omega.pack.value` is not one
   of the five carried names that build a card's signature line, and it is not
   meant to be: a batch variable has no signature. The value is an attribute on
   the declaration, which is what *"what is `BUILD_DIR` set to"* asks for, and it
   is a carrier rather than a plain attribute only because `set NAME=` with no
   value still declares the variable -- an attribute expression over an unbound
   capture would skip the declaration itself, and a second pattern for the
   valueless form would double-emit the ones that have a value.

## Still to decide

1. **Whether every `cmd` deserves a `call.command`.** `echo` is a command and
   the pattern states it, so a script of sixty `echo` lines yields sixty calls
   named `echo`. Excluding the shell builtins would need a `#not-any-of?` list,
   and that predicate compares text exactly while batch command words are
   case-insensitive, so `ECHO` would slip past it. Stated in full for now;
   revisit against the row count, not against taste.
2. **Command arguments.** `msbuild /p:Configuration=Release x.sln` carries its
   arguments in `argument_list`, and "what flags does this build use" is a real
   question. Storing the list as an attribute writes the rest of the line into
   the index once per command; left out until the cost is measured.
3. **`for_set`.** `for %%f in (*.log)` and `for /f %%a in ('dir /b')` name what
   is iterated, sometimes a glob and sometimes a nested command line. The nested
   command is not parsed as a command by this grammar, so stating the set would
   store a string that resolves to nothing. Left out.
4. **`setlocal` scope.** `setlocal_stmt` and `endlocal_stmt` are childless leaf
   tokens; the region between them is not a node, so the extent over which an
   assignment is local cannot be emitted as a region. Recorded as a coverage
   guard instead.
