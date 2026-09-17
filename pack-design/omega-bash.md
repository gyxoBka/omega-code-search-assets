# omega-bash

Language `omega-bash`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

11 templates over 11 query patterns, 15 distinct node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 6 |
| `imports` | yes | 1 |
| `references` | yes | 1 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.variable` | Value | 3 |
| `definition.case_pattern` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.modifier_candidate` | `omega.pack.modifier` | 2 |

### Regions

- `scope.function_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.command` | call | 1 |
| `import.source` | binding | 1 |
| `reference.variable` | reference | 1 |

### Attributes stored per emission

| on | attribute | value |
|---|---|---|
| `definition.variable` (assignment form) | `value` | the trimmed right-hand side of the assignment |

### Injections

`heredoc_redirect` -- the heredoc body is injected under the language named by
the heredoc delimiter, lowercased and mapped through the alias table
(`<<SQL`, `<<PYTHON`, `<<'JSON'`). `<<EOF` names no registered language and
injects nothing, which is correct.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 62 node types. The Pack looks at 15 of them.

Untouched:

- `_expression`
- `_primary_expression`
- `_statement`
- `ansi_c_string`
- `arithmetic_expansion`
- `array`
- `binary_expression`
- `brace_expression`
- `c_style_for_statement`
- `case_statement`
- `command_substitution`
- `comment`
- `compound_statement`
- `concatenation`
- `do_group`
- `elif_clause`
- `else_clause`
- `extglob_pattern`
- `file_descriptor`
- `file_redirect`
- `heredoc_content`
- `heredoc_start`
- `herestring_redirect`
- `if_statement`
- `list`
- `negated_command`
- `number`
- `parenthesized_expression`
- `pipeline`
- `postfix_expression`
- `process_substitution`
- `program`
- `raw_string`
- `redirected_statement`
- `regex`
- `special_variable_name`
- `string`
- `string_content`
- `subshell`
- `ternary_expression`
- `test_command`
- `test_operator`
- `translated_string`
- `unary_expression`
- `unset_command`
- `variable_assignments`
- `while_statement`

Every one of these is either control flow (`if_statement`, `while_statement`,
`case_statement`, `list`, `pipeline`, `subshell`, `compound_statement`,
`do_group`, the clause nodes), an expression node that holds no name
(`binary_expression`, `concatenation`, `number`, `string` and its content,
`arithmetic_expansion`, the `_expression` supertypes), or a leaf a question
cannot reach (`comment`, `file_descriptor`, `test_operator`,
`special_variable_name`). Control flow is the shape of a script, not a thing an
agent names; the region a question can ask about is the function body, and that
is stated. `unset_command` and `file_redirect` are discussed under *Still to
decide*.

## What is wrong with it

These are the defects of the Pack as found (17 templates over 22 patterns,
10 guards, 17 node types touched).

**Eight of the query's patterns were a syntax highlighter, and nothing read
them.**
Four lines of the file were nvim-treesitter's `highlights.scm` pasted in: the
delimiter set `[";" ";;" ";&" ";;&" "&"] @punctuation.delimiter`, `"export"
@keyword.import`, `"function" @keyword.function`, `"``" @punctuation.special`,
`(special_variable_name) @constant`, `(variable_name) @variable`, a 120-name
`#any-of?` list of Bourne-shell builtin variable names, and a three-capture
`printf -v` pattern. No template names any of those captures. `(variable_name)
@variable` alone is one query match for **every variable occurrence in every
shell script in the repository** for an emission that does not exist. The audit
reported three of these as *pattern nothing reads*; the rest were dead comment
blocks left where the baselines had been stripped.

**Four templates named an emission with a whole node (D2).**
`scope.lexical` and `scope.bash_lexical_scope` both took `(function_definition)
@local.scope` as their *name*, so the entire body of every function -- every
line of it -- was stored twice as the text of a region's name.
`call.command_candidate` named itself from `(command)`, storing the command and
all its arguments; `value_origin.assignment` named itself from
`(variable_assignment)`, storing `NAME=value` whole.

**Two facts were stated twice under two spellings (K2).** `binding.var` and
`binding.bash_variable` over the same `@local.definition.var`; `scope.lexical`
and `scope.bash_lexical_scope` over the same `@local.scope`. The generator ran
a `locals.scm` pass and a `semantic_closure` pass over the same captures.

**Three carriers the host will not fold, and four under names nothing reads.**
`call.command_candidate`, `call.target_candidate` and
`scope.named_owner_candidate` end in `_candidate` but fail
`is_definition_kind` -- `call.` and `scope.` prefixes -- so they were never
folded and fell through to the mention branch as references to a whole command.
`definition.identity_candidate` did fold, onto nothing useful:
`omega.pack.identity`, `omega.pack.target`, `omega.pack.named_owner` and
`omega.pack.command` are read by no code in the engine. That was four of 17
templates carrying nothing to anywhere.

**Nothing in a bash script was declared except a function.** Two declaration
kinds, both `definition.*function*`, and everything else -- every variable
assignment, every `export`, every loop variable -- was emitted under
`binding.*` or `data.*` or `value_origin.*` kinds. None of those pass
`is_definition_kind`, so seven of them -- `binding.var`,
`binding.bash_variable`, `binding.bash_for`, `binding.bash_assignment`,
`value_origin.assignment`, `data.bash_parameter_expansion` and
`data.bash_pipeline_statement` -- arrived as **plain references**: seven
distinct kinds collapsing onto one occurrence sort, referring to declarations
that were never made. `$PATH` could not resolve to `PATH=...`
because `PATH=...` was not a declaration; asking where an environment variable
is set returned nothing.

**One name was a constant (J).** `data.bash_pipeline_statement` set `name` to
the literal `"data_bash_pipeline_statement"`, so every pipeline stage in the
corpus collapsed onto one string -- and the template existed to say that a
statement is inside a pipeline, which is containment the tree already holds (E).

**Ten guards, seven of them boilerplate.** Four `calls` guards about overload
resolution, compile-time dispatch and macro expansion -- bash has no overloads,
no compile step and no macros; they are a generic paragraph pasted into a
shell Pack. Two more were underscore labels
(`category_is_syntactic_from_ast_node_kind`,
`identity_candidate_is_syntactic; overload_namespace_...`), and one was a bare
token, `bash_command_resolution_depends_on_shell_environment` (G) -- which is
the one real limitation this Pack has, written as an identifier rather than as
a sentence.

**Two capabilities were declared for emissions the host discards or never
resolves.** `bindings` (4 templates) and `data` (2 templates) between them
produced six references to nothing, and `calls` (3 templates) produced two
unfoldable carriers and one emission named with a whole assignment. `imports` was the only one of the seven
that both declared a real fact and spelled it so the host could see it.

**An injection with an operator tree-sitter does not have.** The `trap`
injection carried `(#offset! @injection.content 0 1 0 -1)` and two `#set!`
directives, copied from nvim; `#offset!` is an nvim extension, so the pattern
matched every `trap` command in every script and injected the string with its
quotes included.

## What it should extract

A bash file is an entrypoint, a build or CI step, an installer or a dotfile.
The questions asked of one are: *what does this script define*, *where is this
variable set and to what*, *what does this script run*, *what does it pull in*,
and *where is this subcommand handled*.

| what | node | emitted as | family |
|---|---|---|---|
| a function | `function_definition` via `name: (word)` | `definition.function` | Callable |
| its body | `function_definition` via `body:` | `scope.function_body` | region |
| a variable being set | `variable_assignment` via `name:` | `definition.variable`, with the right-hand side as attribute `value` | Value |
| an indexed assignment | `subscript name: (variable_name)` | the same, named by the array | Value |
| how it was declared | `declaration_command` keyword | `definition.modifier_candidate` on the assignment's span | `omega.pack.modifier` |
| a declaration with no value | `declaration_command` via `(variable_name)` | `definition.variable` + the same modifier carrier | Value |
| a loop variable | `for_statement` via `variable:` | `definition.variable` | Value |
| a dispatch branch | `case_item` via `value: (word)` | `definition.case_pattern` | Value |
| a command being run | `command` via `name: (command_name (word))` | `call.command` | call |
| `source` / `.` | `command` with an anchored first argument | `import.source` | binding |
| `$name`, `${name}`, `${name[i]}` | `simple_expansion`, `expansion` | `reference.variable` | reference |
| a heredoc body | `heredoc_redirect` | injection, language from `heredoc_end` | -- |
| control flow, pipelines, expressions, strings, comments | -- | nothing | -- |

The point of the rewrite is that **a bash variable is a declaration**. Once
`PORT=8080` is a `definition.variable` carrying `8080`, `$PORT` resolves onto
it, `export` is visible on the declaration under the one carried name the card
assembles, and "where is this environment variable set, and to what" is a
question with an answer. Before, both halves were references and neither could
find the other.

`definition.variable` and `definition.case_pattern` land in Value, which is
right: bash has no types, and a case branch names a subcommand, not a callable.
`definition.function` is the only Callable and the only thing a `call.command`
can resolve to -- which is also the correct boundary, since every other command
name is a binary found on `PATH` at run time.

Five guards replace ten, each a sentence about the shell rather than about
compilers: PATH resolution, non-literal command names, computed `source`
targets, `$`-less variable reads inside `(( ))` and `[[ ]]`, and the absence of
a parameter list on a bash function.

## Still to decide

1. **File redirects.** `> "$LOG"`, `>> build.log`, `2>/dev/null`: "what files
   does this script write" is a real question, but the destination is an
   expansion or a path more often than it is a name that resolves to anything
   indexed, and `/dev/null` would be among the most-referenced names in any
   corpus. Left out; revisit if the file resolver starts matching literal
   relative paths, in which case it belongs with `import.source` as
   `relation.depends`.
2. **`unset_command`.** `unset FOO` is a mention of a variable and would
   resolve onto the declaration. It is one pattern for a construct that appears
   a handful of times per repository; left out as not worth the match.
3. **Case branches with several patterns.** `start|begin)` yields two
   `definition.case_pattern` declarations sharing one span, because the useful
   span is the branch (the handler), not the word. That is deliberate: two names
   genuinely reach the same handler.
4. **`declaration_command` without `local`/`export`.** A bare `declare -A map`
   is declared and carries `declare` as its modifier, but the `-A` that makes it
   an associative array is a plain `word` argument and is not stated. Bash has
   no type to state it as.
