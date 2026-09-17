# omega-lua

Language `omega-lua`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

24 templates over 14 query patterns, 7 distinct root node types
(`function_declaration`, `assignment_statement`, `field`, `chunk`,
`function_call`, `label_statement`, `goto_statement`).

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 16 |
| `imports` | yes | 1 |
| `references` | yes | 1 |
| `scopes` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 3 |
| `definition.method` | Callable | 1 |
| `definition.field` | Value | 2 |
| `definition.variable` | Value | 1 |
| `definition.label` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 4 |
| `definition.container_name_candidate` | `omega.pack.container_name` | 4 |

`parameter_shape` is one of the five names `declared_signature` assembles a
card's signature line from; `container_name` is read by the engine. Every
carrier's span is the declaration it describes, and a declaration template with
that same span capture exists in the same pattern, so nothing is folded onto
nothing.

### Regions

- `scope.function_body` (4) -- one per form a function body can be reached by,
  each named from the function's own name capture, never from the block text.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `import.module` | binding | 1 |
| `reference.label` | reference | 1 |

Nothing is emitted that the host drops: there are no `literal.*` markers (the
Pack emits no `reference_context.*`, so a literal marker would suppress
nothing), no `relation.*` kind outside the six the host knows, and no
`_candidate` kind that fails `is_definition_kind`.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 51 node types. The Pack looks at 29 of them.

Untouched:

- `attribute`, `implicit_variable_declaration` -- `local x <close>` and
  `<const>`. A Lua 5.4 attribute is a lifetime hint to the collector, not
  visibility or a modifier the card assembles.
- `break_statement`, `do_statement`, `else_statement`, `elseif_statement`,
  `empty_statement`, `for_statement`, `for_generic_clause`,
  `for_numeric_clause`, `if_statement`, `repeat_statement`, `return_statement`,
  `while_statement` -- control flow. A region per loop and branch is one row per
  control structure in the corpus for a question nobody asks; the region that
  matters, the function body, is emitted.
- `comment`, `comment_content`, `escape_sequence`, `hash_bang_line` -- text.
  LuaLS `---@class` / `---@field` annotations live in `comment` and are a tool's
  convention, not the language's, so they belong in `frameworks/` if anywhere.
- `declaration`, `expression`, `statement`, `variable` -- supertypes; every
  concrete member that carries meaning is matched by name.

## What is wrong with it

Measured before the rewrite: **23 templates over 61 query patterns, 23 guards**,
touching 34 named node types. (`audit.py` reported 22 patterns, not 61 -- see
*A defect in the audit* below.)

**More than half the file was a syntax highlighter.** The
`nvim_pinned_highlights` block was 38 of the 61 patterns and fed **two**
templates. `(comment) @comment`, `(number) @number`, `(string) @string`,
`(nil) @constant.builtin`, `[(false)(true)] @boolean`, four bracket and
delimiter alternations, `(table_constructor ["{" "}"] @constructor)`, two
`string.regexp` patterns, a 60-name `#any-of?` list of Lua 5.1 builtins: none of
it was read by any template. It was matched against every node of its type in
every Lua file, per file, to produce nothing.

**The universal capture, twice over.** `(identifier) @local.reference @variable`
at pattern root stored every identifier of every Lua file, under two templates
(`reference.local` and `reference.lua_identifier_candidate`). This is defect I2
exactly, inherited with the nvim-treesitter `locals.scm` baseline whose
provenance comment is still in the file.

**Eight framework overlays spelled as injections.** Every `injections` pattern
was Neovim or LuaJIT: `#eq? @_cdef_identifier "cdef"`, `#any-of? "vim.cmd"
"vim.api.nvim_command" "vim.api.nvim_exec2"`, `vim.treesitter.query.set`,
`vim.rpcrequest` + `nvim_exec_lua`, `exec_lua`, `vim.api.nvim_create_autocmd`,
`vim.api.nvim_create_user_command`, `vim.api.nvim_buf_create_user_command`.
A language Pack may not encode one editor's API; this is defect L inside an
injection, the same place it was found in omega-c.

**Two more overlays wearing a "framework-neutral" comment.** The file said
`; Framework-neutral Lua DSL calls carrying an authored literal string` over
`(function_call name: (identifier) arguments: (arguments (string)))` -- which is
every one-string call in the language, declared as
`definition.lua_dsl_string_call_context` -- and
`; Framework-neutral action/table declaration` over a pattern keyed on
`#eq? @_trigger_key "trigger"`, a literal from somebody's build DSL. The denial
is the tell.

**Five carriers under names nothing assembles, four of which could not fold
anyway.** `omega.pack.target`, `omega.pack.identity`,
`omega.pack.lua_identifier`, `omega.pack.named_owner`,
`omega.pack.parameter_owned`: the value was computed and stored and nothing ever
read it. And `call.target_candidate`, `reference.lua_identifier_candidate`,
`scope.named_owner_candidate` and `binding.parameter_owned_candidate` all fail
`is_definition_kind` (they start with `call.`, `reference`, or are a `scope.`
kind with no `definition` in them), so the host never folded them at all -- each
fell through to the mention branch and was stored as a reference to nothing.
`binding.parameter_owned_candidate` was additionally named with the whole
`(parameters)` node, and `scope.named_owner_candidate` was a carrier on a
*scope*, which is not a declaration and has no attribute bag.

**Four constructs declared twice under two spellings** (K2), same span capture
and same name expression, two kinds and two rows each: `definition.associated`
and `definition.lua_field`; `binding.var` and `binding.lua_variable`;
`reference.local` and `reference.lua_identifier_candidate`; `scope.lexical` and
`scope.lua_lexical_scope`. The generator ran two passes over one set of captures
and kept both spellings. `definition.function` / `definition.lua_function` and
`definition.method` / `definition.lua_method` are the same duplication written
over two different patterns, so the check does not see them.

**Two scope templates named themselves with the whole node** (D2).
`scope.lexical` and `scope.lua_lexical_scope` both had `span_capture` equal to
their `name`, over `[(chunk) (do_statement) (while_statement) (repeat_statement)
(if_statement) (for_statement) (function_declaration) (function_definition)]`.
The name of a region rooted at `chunk` is **the entire file**, written into the
index once per file, and again for every nested block.

**Nothing resolved.** Seven templates were mentions -- `binding.lua_parameter`,
`binding.lua_variable`, `binding.parameter`, `binding.var`, `reference.local`,
`reference.lua_three_segment_call_context`, `call.lua_call` -- against
declarations the Pack mostly did not make. Nothing declared a file-scope local,
a table field, a global, or a function assigned as a value (`local f =
function() end`, the second most common way to write a Lua function), so
`local M = require("x")` left `M` undeclared and `M.f = ...` left `f`
undeclared.

**Nineteen of 23 guards were generator confidence tiers, not limitations.**
Three were single tokens (`lua_require_resolution_depends_on_package_path_and_
runtime`, `terminal_static_ceiling__lua_metatable_and_dynamic_environment_
semantics`, `lua_upstream_tags_project_semantics_terminal_static_boundary`) and
the rest were sentences of the same substance repeated per capability
(`overload selection and compile-time callable/type dispatch remain compiler
semantics` -- Lua has no overloads and no compile-time dispatch; four guards
mentioned types, which Lua does not have).

**And the manifest declared `bindings` for four templates that resolved against
nothing.** Dropped with them.

## What it should extract

Lua is the embedded-configuration and plugin language: Neovim config, Redis and
nginx scripts, game logic, build DSLs. It **declares nothing** -- a name exists
because something assigned it, and the unit of structure is the table. So the
questions are *what functions does this file define and what do they take*,
*what does this module put on its table*, *what does this file require*, and
*what calls what*.

| what | node | emitted as | family |
|---|---|---|---|
| `function f()`, `local function f()` | `function_declaration` via `name: (identifier)` | `definition.function` | Callable |
| `function M.f()` | `function_declaration` via `dot_index_expression` `field:` | `definition.function` + `container_name` carrier | Callable |
| `function M:f()` | `function_declaration` via `method_index_expression` `method:` | `definition.method` + `container_name` carrier | Callable |
| `local f = function() end`, `M.f = function() end` | `assignment_statement` with a `function_definition` first value | `definition.function` (+ `container_name`) | Callable |
| `M = { f = function() end }` | `field` with a `function_definition` value | `definition.function` | Callable |
| what any of them take | `parameters` | `parameter_shape` carrier on the declaration | attribute |
| a function's extent | `block` in `body:` | `scope.function_body`, named from the function | region |
| `{ timeout = 30 }` | `field` with a non-function value | `definition.field` | Value |
| `M.handler = ...` at file scope | `chunk > assignment_statement > dot_index_expression` | `definition.field` + `container_name` carrier | Value |
| `local M = {}`, `local M`, `X = 1` at file scope | `chunk > variable_declaration` / `assignment_statement` | `definition.variable` | Value |
| `require "mod"` | `function_call` + `#eq?`, name from `string_content` | `import.module` | binding occurrence |
| `f()`, `M.f()` | `function_call` `name:` last segment | `call.function` | call occurrence |
| `obj:f()` | `method_index_expression` `method:` | `call.method` | call occurrence |
| `::done::` | `label_statement` | `definition.label` | Value |
| `goto done` | `goto_statement` | `reference.label` | reference occurrence |
| loops, branches, comments, literals | -- | nothing | -- |

The names line up on purpose: a call writes the **last segment** of the callee,
and every function declaration is stored under its last segment with the table
it hangs on carried as an attribute, so `M.f()` in one file resolves onto
`function M.f()` in another. `require` records the string's content without its
quotes, so it can match a module declared elsewhere.

Four guards, one per real ceiling: `package.path` is a run-time search;
assignment is not declaration, so `__index`, `setmetatable`, `rawset` and
`_G[expr]` declare nothing; only file-scope locals are declared; and a call is
known by the name written at the call site.

## Still to decide

1. **File scope as the cut for variables.** A `local` inside a function body is
   an implementation detail and resolves against nothing outside that body, so
   only `chunk`-level names are declared. That is the same cut omega-python made
   for `module_variable`. It costs the one real case where a module is built
   inside a `do ... end` block, which is rare enough to leave out until a corpus
   says otherwise.
2. **Field reads are not emitted.** This grammar spells a callee and a field read
   as the same `dot_index_expression`, and a query cannot see its parent, so
   `(dot_index_expression field: (identifier))` as a reference would report the
   majority of calls a second time as field reads -- the defect measured at 68.8%
   in omega-rust. Left out, and the guard says so. If a corpus shows the
   non-call share is large, the answer is a host-side parent test, not a
   different query.
3. **`setmetatable(A, {__index = B})` is Lua's only inheritance.** It is a
   stdlib call shape rather than syntax, so stating it as `relation.implements`
   would be a framework overlay by the letter of the contract. Left out; it is
   the strongest candidate for a `frameworks/omega-framework-lua-oop` overlay.

## A defect in the audit

`audit.py` reported this Pack at 22 patterns; it has 61. `top_patterns` strips
comments with `re.sub(r';[^\n]*', '', src)`, which is not string-aware, so the
`";"` in the Pack's punctuation alternation was eaten down to a single `"`. That
opened a string as far as the parser was concerned and swallowed the remaining
250 lines of the file -- 38 patterns and every capture in them, none of which
were then checked for any defect class. Any Pack whose `queries.scm` contains a
`";"` literal, or a `"` inside a comment, is under-measured the same way. Not
fixed here: `audit.py` is out of scope for this Pack, and the finding is
reported for `00-INDEX.md`.
