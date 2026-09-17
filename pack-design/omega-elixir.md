# omega-elixir

Language `omega-elixir`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Elixir has almost no syntax of its own. `defmodule`, `def`, `defstruct`,
`defimpl`, `@spec`, `alias` and `use` are all calls to a macro, so the grammar
gives every one of them the same shape -- `(call target: (identifier) ...)` --
and the only thing that distinguishes a module declaration from a function call
is the text of the target. A Pack for this language is therefore almost entirely
`#eq?` and `#any-of?` on that one identifier, and the two places where that
breaks are the two coverage guards that matter.

## What it states today

30 templates over 25 query patterns, 18 node types touched, 6 coverage guards.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 2 |
| `definitions` | yes | 10 |
| `imports` | yes | 2 |
| `references` | yes | 7 |
| `scopes` | yes | 4 |
| `tests` | yes | 2 |
| `types` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.module` | Namespace | 1 |
| `definition.protocol` | Type | 1 |
| `definition.type` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.callback_function` | Callable | 1 |
| `definition.field` | Value | 2 |
| `definition.module_attribute` | Value | 1 |
| `test.function` | Test | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |

Both are emitted with the span of the `def` call they describe, so they fold
onto `definition.function` at that span. Together they make a card read
`defp normalise(name, opts)` instead of `normalise`.

### Regions

- `scope.module_body` (3: `defmodule`, `defprotocol`, `defimpl`)
- `scope.function_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 2 |
| `relation.tests` | tests_convention_candidate | 1 |
| `call.local_function` | call | 1 |
| `call.remote_function` | call | 1 |
| `import.module` | binding | 2 |
| `binding.import_alias` | binding | 1 |
| `reference.module` | reference | 4 |
| `reference.module_attribute` | reference | 1 |
| `type_use.struct` | reference | 1 |
| `type_use.spec` | reference | 1 |

Nothing is emitted that the host discards.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 18.

Untouched, and why:

- `integer`, `float`, `boolean`, `nil`, `char`, `charlist`, `quoted_atom`,
  `quoted_keyword`, `escape_sequence`, `operator_identifier` -- literals and
  punctuation. This Pack emits no `reference_context.*` kind, so a `literal.*`
  emission over them would suppress nothing and the host would drop it (§5 of
  the brief). Atom and keyword *are* read, but only where they name a struct
  field or a keyword option, never on their own.
- `source`, `block`, `body`, `map_content`, `bitstring`, `interpolation`,
  `access_call` -- containers. The tree already holds containment and a
  declaration carries its container through `within:`.
- `anonymous_function`, `stab_clause` -- `fn x -> ... end` and every `case`,
  `with` and `receive` clause. These are real lexical regions, but none of them
  has a name, and a region named by its own text is the whole subtree. The old
  Pack emitted `scope.lexical` over every `stab_clause` in the corpus, named
  with the clause's entire source.
- `after_block`, `catch_block`, `else_block`, `rescue_block` -- the arms of
  `try`/`receive`. Same: no name, and control flow is not a declaration.
- `sigil`, `sigil_name`, `sigil_modifiers` -- a sigil's content is a foreign
  language (`~H` is HEEx, `~r` a regex, `~F` Surface) and none of those has a
  grammar in this repository. Stated as a coverage guard instead of as a
  broken injection.
- `comment` -- documentation, not a name anything resolves to.

## What is wrong with it

The Pack that was here stated 31 templates over 16 top-level patterns with 12
guards, and it was assembled by concatenating six generator passes over the
same file: `external-nvim-treesitter-locals`, `locals`, `nvim_pinned_locals`,
`nvim_pinned_highlights`, `nvim_pinned_injections`, `upstream_tags`,
`static_delta` and three `semantic_closure_v3_146_batch*` blocks, each with its
own provenance banner. Concretely:

- **I -- the universal capture.** `(identifier) @local.reference @variable` and
  `(alias) @local.reference @module @name @reference.module` at pattern root.
  Two templates read `@local.reference`, so **every identifier and every
  capitalised name in every Elixir file** was stored twice, under its own text,
  as `reference.local` and as `reference.elixir_identifier_candidate`.
- **K2 -- the same fact under two kinds, 5 times.** The concatenated passes
  declared everything twice: `binding.import` and `import_binding.elixir_import`
  over `@local.definition.import`; `binding.elixir_variable` and `binding.var`
  over `@local.definition.var`; `reference.elixir_identifier_candidate` and
  `reference.local`; `scope.elixir_lexical_scope` and `scope.lexical`;
  `call.elixir_module_call_context` and `call.elixir_module_string_call_context`.
- **A carrier the host will not fold, 4 times.** `call.target_candidate`,
  `reference.elixir_identifier_candidate`,
  `relation.protocol_implementation_candidate` and `type.typespec_candidate` all
  end in `_candidate` but fail `is_definition_kind`, so none of them folded;
  each fell through to the mention branch and was stored as a reference to
  nothing. And all four carried names -- `target`, `elixir_identifier`,
  `protocol_implementation`, `typespec` -- that no code in the engine
  assembles, so even had they folded the value would have been written and
  never read.
- **D2 -- the name is the span itself, 2 times.** `scope.lexical` and
  `scope.elixir_lexical_scope` both named a `stab_clause` with the whole
  `stab_clause`. `relation.protocol_implementation_candidate` did the same with
  the entire `defimpl ... do ... end` call, and `type.typespec_candidate` with
  the entire `@spec` attribute.
- **`relation.*` the host does not know, 1.**
  `relation.protocol_implementation_candidate` is not one of the six, so it was
  a plain reference named with a whole subtree. Elixir's two real implements
  edges -- `defimpl` and `@behaviour` -- were both stated as something else, and
  `@behaviour` was not stated at all.
- **G -- a guard whose reason is a label, 3.**
  `elixir_protocol_implementation_identity_requires_project_semantics`,
  `elixir_typespec_resolution_requires_elixir_semantics`,
  `elixir_upstream_tags_project_semantics_terminal_static_boundary`.
- **L -- a framework overlay, spelled as a tree shape.** Five patterns
  (`elixir_imported_function_literal_keyword_in_context`,
  `elixir_module_imported_function_call_context`, `elixir_module_used_call_context`,
  `elixir_module_used_function_context`, `elixir_module_used_string_call_context`)
  matched `defmodule` + `import`/`use` + `def` + a returned call whose argument
  is `x in "table"` with a keyword whose value is also `y in "table"`. That is
  `Ecto.Query.from/2` with the names taken out, down to the `#not-match? "#\{"`
  on the source string. Each carried a comment asserting the Pack "does not
  interpret call/keyword names (e.g. Ecto from/join)" -- the denial is the
  tell -- and one of them, `definition.elixir_module_used_function_context`,
  declared a *second* Callable at the span of every function in a module that
  happens to `use` something.
- **Syntax highlighting, about 350 lines of it.** The pinned nvim highlights
  block contributed `@punctuation.delimiter`, `@keyword`, `@string`, `@number`,
  `@boolean`, `@operator` and thirty more captures no template reads, plus 20
  nested `(_ (_ (_ ...)))` ladders from the nvim `locals.scm` baseline, each 21
  alternatives deep, to find an identifier at any depth inside a pattern match.
- **Defect D in the two struct templates.** `definition.elixir_struct` and
  `definition.elixir_exception` were *named with the argument list*:
  `defstruct [:name, :email, :inserted_at]` was declared under the name
  `[:name, :email, :inserted_at]`. The construct they were reaching for has no
  name of its own at all (see below).
- **A -- a type filed as a value.** `definition.elixir_module` is Value; a
  protocol was not declared as anything.
- **`import.elixir_alias`, `import.elixir_import`, `import.elixir_require` and
  `reference.elixir_use`** were four patterns and four kinds for one fact with
  four spellings.
- **Not stated at all:** `@behaviour`, `@callback`, `@macrocallback`, `@type`
  as a declaration with a name, struct and exception *fields*, `defdelegate`'s
  target, `alias Foo.{A, B}`, `alias Foo, as: Bar`, `%Struct{}` literals, a
  module passed as an argument, and ExUnit -- the `tests` capability was not
  declared, so no Elixir declaration anywhere reached the Test family.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a module | `call` target `defmodule`, first `alias` argument | `definition.module` | Namespace |
| its body | the `do_block` of that call | `scope.module_body` | region |
| a protocol | `call` target `defprotocol` | `definition.protocol` | Type |
| a function, macro or guard | `call` target `def`/`defp`/`defmacro`/`defmacrop`/`defguard`/`defguardp`/`defn`/`defnp`/`defdelegate` | `definition.function` | Callable |
| its argument list | the inner `arguments` | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| `def` vs `defp` vs `defmacro` | the macro identifier | `definition.visibility_candidate` | `omega.pack.visibility` |
| its body | the `do_block` | `scope.function_body` | region |
| a struct or exception field | `atom` in the list, or `pair` key, under `defstruct`/`defexception` | `definition.field` | Value |
| a declared type | `@type` / `@typep` / `@opaque` | `definition.type` | Type |
| a behaviour callback | `@callback` / `@macrocallback` | `definition.callback_function` | Callable |
| a module attribute and its value | `@name value` | `definition.module_attribute` + attribute `value` | Value |
| a test | `call` target `test`, its description string | `test.function` | Test |
| what a test module covers | `defmodule <X>Test` | `relation.tests` | tests_convention_candidate |
| a behaviour implemented | `@behaviour Alias` | `relation.implements` | implements |
| a protocol implemented | `call` target `defimpl`, first `alias` | `relation.implements` | implements |
| the `for:` of a `defimpl` | `pair` value under `defimpl` | `reference.module` | reference |
| what a module brings in | `alias` / `import` / `require` / `use` + `alias` argument | `import.module` + attribute `form` | binding |
| a multi-alias member | `alias Foo.{A, B}` | `import.module`, joined to `Foo.A` | binding |
| a local name for a module | `alias Foo, as: Bar` | `binding.import_alias` + attribute `target` | binding |
| a local call | `call` target `identifier`, minus the macros above | `call.local_function` | call |
| a remote call | `call` target `dot`, right `identifier` | `call.remote_function` | call |
| the module a remote call goes to | left `alias` of that dot | `reference.module` | reference |
| a module passed by name | `alias` argument of any other call | `reference.module` | reference |
| a struct literal | `%Alias{}` | `type_use.struct` | reference |
| a spec | `@spec foo(...) :: t` | `type_use.spec` | reference |
| a module attribute read | `@name` with no argument | `reference.module_attribute` | reference |

`definition.module` is deliberately Namespace and `definition.protocol`
deliberately Type: an Elixir module is a namespace that holds functions, and a
protocol is a type that other modules implement. `definition.callback_function`
ends in the Callable word on purpose -- a callback is the contract of a
function, and a question about a behaviour's callables should find it.

## Still to decide

**Two judgement calls are live in the Pack as it stands.**

*A definition's header is a call node, and a query cannot see its parent.*
tree-sitter-elixir parses `def foo(a, b) do ... end` as a `call` to `def` whose
argument is the `call` `foo(a, b)`. The inner node is indistinguishable from a
real call to `foo/2`: same node type, same target type, arguments that are
patterns rather than values but with no marker saying so. A tree-sitter query
cannot ask what a node's parent is, so the single pattern that states local
calls also reports one call from each function clause to itself, at its own
header.

The alternative is to root local calls at the containers a definition header
never has -- `do_block`, `body`, `block`, `binary_operator`, `unary_operator`,
and `arguments` filtered on the outer target -- which is six patterns instead of
one and still misses every call written inside a list, a map, a keyword value or
a string interpolation, and `"#{render(assigns)}"` is ordinary Elixir. That
trades a bounded, explainable artifact for unbounded silent holes, so the single
pattern stands and the artifact is written into a coverage guard in the Pack's
own words. If a measurement on a real corpus later shows the self-call ratio is
worse than the roughly one-per-clause it should be, this is the first thing to
revisit.

*A struct has no name.* `defstruct [:name, :age]` declares the struct of the
module it is written in, and that module is already declared, at a span this
pattern cannot reach. So there is no `definition.struct`: the module
declaration is the struct, the fields are declared under their own names, and
`%MyApp.User{}` resolves onto `definition.module MyApp.User` through
`type_use.struct`. The same is true of `defexception`. The alternative --
a carrier at the `defstruct` call's span -- folds onto nothing, which is exactly
what the old `definition.elixir_struct` did.

## Audit

`python pack-design/audit.py omega-elixir` reports nothing: every class is
zero.
