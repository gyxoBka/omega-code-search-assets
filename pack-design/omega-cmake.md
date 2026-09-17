# omega-cmake

Language `omega-cmake`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

20 templates over 19 query patterns, 15 node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 10 |
| `imports` | yes | 2 |
| `references` | yes | 5 |
| `scopes` | yes | 1 |
| `tests` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.macro_callable` | Callable | 1 |
| `definition.project_namespace` | Namespace | 1 |
| `definition.build_target` | Value | 1 |
| `definition.variable` | Value | 2 |
| `definition.config_option` | Config | 1 |
| `definition.test` | Test | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |

Both are emitted on the span of the `function_def`/`macro_def` they describe,
which is the span the declaration occupies, so the fold finds its declaration.
`parameter_shape` is one of the five names the card's signature line is built
from.

### Regions

- `scope.function_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.command` | call | 1 |
| `relation.depends` | depends | 2 |
| `import.include` | binding | 1 |
| `import.subdirectory` | binding | 1 |
| `reference.build_target` | reference | 2 |
| `reference.variable` | reference | 1 |
| `reference.environment_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 58 node types. The Pack looks at 15 of them: `normal_command`,
`identifier`, `argument_list`, `argument`, `function_def`, `function_command`,
`macro_def`, `macro_command`, `body`, `foreach_command`, `variable_ref`,
`normal_var`, `cache_var`, `env_var`, `variable`.

Everything else is either punctuation the grammar happens to name, or a
construct this Pack states a reason for not stating:

- **The keyword leaves and the `end*` commands** -- `function`, `endfunction`,
  `macro`, `endmacro`, `if`, `elseif`, `else`, `endif`, `foreach`,
  `endforeach`, `while`, `endwhile`, `block`, `endblock`, and the
  `end*_command` nodes that wrap them. These are the syntax that delimits a
  construct the Pack already states from its opening node. Naming them was the
  whole of the old Pack's `semantic_hint.cmake_lexical_role` traffic.
- **`if_condition`, `if_command`, `elseif_command`, `else_command`,
  `while_loop`, `while_command`, `foreach_loop`.** A condition argument in
  CMake is a bare word that may be a variable name, a string, or one of about
  thirty operators, and nothing in the syntax says which. Emitting `if(FOO)` as
  a reference to `FOO` would be a guess; the loop *variable* of a `foreach` is
  not a guess and is declared, from `foreach_command`.
- **`block_def`, `block_command`.** `block()` opens a variable scope, so it is
  a region in the language -- but an anonymous one. A region template with no
  name expression is named with its own span's text, which for a block is the
  whole block; a literal name collapses every block in the repository onto one
  string. Neither is worth a row, so the block scope is not emitted and the
  scopes guard says so.
- **`quoted_argument`, `unquoted_argument`, `bracket_argument`** and their
  `_open`/`_content`/`_close` parts. Every pattern here captures the `argument`
  that wraps them and strips the quotes in the name expression, so the two
  spellings of one name are one name.
- **`line_comment`, `bracket_comment`, `escape_sequence`, `quoted_element`,
  `source_file`.** A comment answers no question a name can be resolved
  against, and the file is already the file.

## What is wrong with it

These are the defects of the Pack as found, 40 templates over 50 patterns with
6 guards, measured by `pack-design/audit.py`.

**Nineteen of 40 templates were a syntax highlighter.** The Pack had swallowed
nvim-treesitter's `highlights.scm` for cmake whole -- 28 of its 50 patterns --
and wired a template onto each highlight capture. Eight templates emitted
`semantic_hint.cmake_lexical_role` named by the text of `@keyword.function`,
`@keyword.conditional`, `@keyword.repeat`, `@keyword.operator`,
`@keyword.modifier`, `@keyword.return`, `@keyword.directive` and `@comment`;
three emitted `semantic_hint.cmake_literal` for every string, escape and
boolean-looking argument in every file; three more `semantic_hint.cmake_value`
for every `@variable` and `@variable.parameter`; three
`semantic_hint.cmake_callable` for every command name. All of them are
mentions, so each one arrived as a *reference* -- a reference to `endif`, to
`"Debug"`, to `AND`. Nothing resolves against those, and the Pack's own guard
admitted it: `cmake_highlight_capture_not_symbol_truth`. Five of those patterns
exist only to colour the destination variable of `list(APPEND ...)` and its
siblings, and each costs a match attempt on every `list` command in the file.

**The two biggest declarations in the Pack declared nothing.** `(function_def)
@definition.expression` and `(macro_def) @definition.expression` fed
`definition.cmake_candidate`, a carrier whose name was its own span -- the
entire text of the function, body included -- stored as
`omega.pack.cmake`. `omega.pack.cmake` is not a name the engine assembles from,
so the whole body was copied into the index to be read by nothing. The same
shape appeared as `(variable_ref) @reference.expression` ->
`reference.cmake_candidate`, which is not even a carrier the host will fold:
it does not pass `is_definition_kind`, so it fell through to the mention branch
and every `${FOO}` in the corpus was stored twice, once as a reference to
`${FOO}` with the sigils on. The audit counted 10 templates naming an emission
with its own span, 3 carriers under a name nothing assembles, and 1 carrier the
host will not fold.

**`scope.lexical` was named with the whole block.** One template, span
`(block) @scope.lexical`, name the same capture. It also stated the wrong
language fact: a `block()` is a variable scope in CMake and a `function()` is
too, but the Pack emitted only the former and never the latter.

**Three templates were `structured.entry`.** `project`, `add_library`/
`add_executable` and `target_link_libraries` each got a `calls`-capability
emission under a kind the host has no reading for: not a declaration, not a
scope, not a relation -- a plain reference, competing with the real
declarations of the same construct emitted by three *other* patterns over the
same nodes. `project` was matched by two patterns, `add_library` by two,
`target_link_libraries` by two.

**Two more kinds answered nothing.** `data.cmake_install` was named from the
first argument of `install(...)`, which in the overwhelmingly common form is
the literal word `TARGETS`, so it declared a reference to `TARGETS` once per
install rule. `data.cmake_property` named `set_property`/
`set_target_properties` by their first argument -- the word `TARGET`, or a
target name -- with an unanchored second argument as the `value` field, giving
one emission per pair of arguments in the command.

**Four of six guards had a label for a reason**, three of them a single
underscore-joined token: `cmake_definitions_candidate_requires_contextual_-
resolution_and_may_include_declaration_or_reference_overlap`,
`syntactic_scope_boundaries_only_no_runtime_scope_inference`,
`cmake_highlight_capture_not_symbol_truth`.

**And the questions a CMake file exists to answer were not asked.**
`find_package` was a plain `reference.cmake_package` rather than a dependency;
`target_link_libraries` recorded only the *first* library of the list, as
`reference.cmake_target_link`, so `target_link_libraries(app PUBLIC zlib fmt)`
stated that `app` depends on `PUBLIC`; `add_test` was not matched at all, so a
CMake project's tests were invisible; `$ENV{...}` was not distinguished from
`${...}`; and a `foreach` loop variable was not declared, so `${it}` inside the
loop resolved to nothing.

## What it should extract

CMake is the build description of a C or C++ project. The questions asked of a
`CMakeLists.txt` or a `.cmake` module are: *what does this build produce*,
*where is this target, variable or option defined*, *what does it link
against*, *what does this file pull in*, *which tests are registered*, and
*where is this function called*.

CMake has no syntax for declaring any of those. The grammar spells every one of
them as a `normal_command`, and the command's name is the only thing that says
which construct it is. So every pattern below is keyed on a command name with
`#match?`. That is not a framework overlay: `set`, `option`, `project`,
`add_library`, `add_executable`, `add_test`, `find_package`, `include`,
`add_subdirectory` and `target_link_libraries` are built into cmake(1), cannot
be redefined, and are the language's declaration forms in the same sense that
`fn` is Rust's.

| what | node | emitted as | family |
|---|---|---|---|
| any command invocation | `normal_command` via `identifier` | `call.command` | call occurrence |
| `function(f ARGS)` | `function_def` via first `argument` | `definition.function` | Callable |
| its parameters | the header `argument_list` minus the name | `parameter_shape_candidate` carrier | attribute |
| its body | `body` | `scope.function_body` | region |
| `macro(m ARGS)` | `macro_def` via first `argument` | `definition.macro_callable` | Callable |
| `project(P)` | `normal_command` | `definition.project_namespace` | Namespace |
| `add_library`/`add_executable`/`add_custom_target` | `normal_command` | `definition.build_target` + `command` attribute | Value |
| `set(V ...)` | `normal_command` | `definition.variable` | Value |
| `foreach(it ...)` | `foreach_command` | `definition.variable` | Value |
| `option(O ...)` | `normal_command` | `definition.config_option` | Config |
| `add_test(NAME t)` and `add_test(t cmd)` | `normal_command` | `definition.test` | Test |
| `target_link_libraries(a PUBLIC x y)` | each `argument` after the target | `relation.depends` + `linked_by` attribute | depends |
| `find_package(P)` | `normal_command` | `relation.depends` | depends |
| `include(M)` | `normal_command` | `import.include` | binding |
| `add_subdirectory(d)` | `normal_command` | `import.subdirectory` | binding |
| `target_*`, `set_target_properties`, `add_dependencies` | first `argument` | `reference.build_target` | reference |
| `install(TARGETS t)` | the `argument` after `TARGETS` | `reference.build_target` | reference |
| `${V}`, `$CACHE{V}` | `variable_ref` via `variable` | `reference.variable` | reference |
| `$ENV{V}` | `variable_ref` via `env_var` | `reference.environment_variable` | reference |
| conditions, comments, keywords, `block()` | -- | nothing | -- |

The names all resolve. The grammar exposes the bare name inside `${...}` as a
`variable` node, so a reference is stored as `FOO` and matches the `set(FOO
...)` that declared it -- the old Pack stored `${FOO}` with the sigils on and
could never have matched anything. A quoted argument's name is stripped of its
quotes in the name expression, so `target_link_libraries(app PUBLIC "fmt")` and
`... fmt` are one dependency on one `fmt`. A call of a user-defined command
resolves onto the `function()` or `macro()` that declared it, because both are
named the same way.

Two attributes are carried, and neither is a constant: `command` on a build
target says whether it came from `add_library`, `add_executable` or
`add_custom_target` -- the one fact that distinguishes a library from an
executable, and the reason all three are one pattern rather than three --
and `linked_by` on a dependency names the target that links it, which is the
subject of the edge and is otherwise lost.

The parameter shape is taken with `trim(strip_prefix(<argument_list text>,
<name text>))`: the header's argument list is the name followed by the
parameters, and `strip_prefix` takes an expression for its prefix, so no new
capture and no new pattern is needed for it.

## Still to decide

1. **`call.command` fires on every command in every file**, including `set`
   and `message`. It is kept because it is the only thing that answers "where
   is this function called" -- CMake's user-defined commands are invoked with
   exactly the syntax that `set` is -- and because `find_package`, `install`
   and `configure_file` are themselves worth finding by name. A
   `#not-any-of?` over the ~150 built-in command names would cut the row count
   sharply and would also stop answering the second half of that. Revisit
   against a measured index.
2. **`install(TARGETS a b DESTINATION bin)` records only `a`.** Dropping the
   anchor would record `b` as well, but also `bin`, because what follows a
   keyword there is a path and the grammar does not distinguish them. Partial
   and correct was chosen over complete and wrong; the references guard states
   it.
3. **`if(FOO)` is not a reference to `FOO`.** A condition argument is a bare
   word that may be a variable name, a string literal, or one of about thirty
   operators, and only cmake's own evaluation rules tell them apart. Stating it
   would put a reference to `NOT`, `STREQUAL` and `"Debug"` into the index
   beside the real ones.
