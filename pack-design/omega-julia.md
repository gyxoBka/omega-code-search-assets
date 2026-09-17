# omega-julia

Language `omega-julia`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. The tables below describe the Pack as it now stands; the two
sections after them record what was wrong with the one it replaced.

## What it states today

35 templates over 24 query patterns, 60 of the grammar's 89 named node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 3 |
| `calls` | yes | 2 |
| `definitions` | yes | 19 |
| `imports` | yes | 3 |
| `references` | yes | 3 |
| `scopes` | yes | 4 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.module` | Namespace | 1 |
| `definition.function` | Callable | 1 |
| `definition.macro_function` | Callable | 1 |
| `definition.struct` | Type | 1 |
| `definition.abstract_type` | Type | 1 |
| `definition.primitive_type` | Type | 1 |
| `definition.field` | Value | 1 |
| `definition.constant` | Value | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

Every one of these is a name the engine reads: the first four build the
signature line on a card (`production.rs`, `declared_signature`), and
`declared_type` is read by the value layer.

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 4 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 3 |

### Regions

- `scope.module_body` (1)
- `scope.function_body` (2 -- a function and a macro)
- `scope.type_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 3 |
| `call.function` | call | 1 |
| `call.macro` | call | 1 |
| `import.module` | binding | 1 |
| `import.symbol` | binding | 1 |
| `export.symbol` | binding | 1 |
| `binding.import_alias` | binding | 1 |
| `binding.global` | reference | 1 |
| `binding.local` | reference | 1 |
| `type_use.name` | reference | 1 |

### Coverage guards

Seven, one per thing the Pack genuinely cannot see: multiple dispatch, the
dot in a qualified name, `include`, duck-typed interfaces, macro-generated
code, package resolution, and body-local names.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 89 node types. The Pack looks at 60 of them.

Untouched, and why:

- `_definition`, `_expression`, `_statement` -- hidden supertypes, not nodes.
- `boolean_literal`, `integer_literal`, `float_literal`, `character_literal`,
  `string_literal`, `command_literal`, `prefixed_string_literal`,
  `prefixed_command_literal`, `content`, `escape_sequence`,
  `interpolation_expression` -- literals. The Pack emits no
  `reference_context.*` kind, so a `literal.*` template here would suppress
  nothing and the host would drop it (`emission_roles.rs`); a literal that is
  not a name answers no question of its own.
- `line_comment`, `block_comment` -- prose, including docstrings. See
  *Still to decide*.
- `if_statement`, `while_statement`, `for_statement`, `for_clause`,
  `try_statement`, `catch_clause`, `else_clause`, `finally_clause`,
  `quote_statement`, `compound_statement`, `break_statement`,
  `continue_statement` -- control flow. Every one of them is reached as a
  *parent* of a call by the call pattern, but none of them names anything, and
  `control_flow.*` emissions are dropped by the host.
- `matrix_expression`, `quote_expression`, `operator` -- values and syntax with
  no name to resolve against.

## What was wrong with it

The Pack that was replaced: **54 templates over 60 patterns with 23 coverage
guards**, touching 73 node types -- the high node count came almost entirely
from three pasted `highlights.scm` copies, not from coverage of meaning.
`audit.py` reported 28 defects in six classes, and the reading below adds the
ones it cannot measure.

**The Pack was a syntax highlighter.** 32 of the 54 templates -- 59% -- were
under the `data` capability, one per nvim-treesitter highlight capture:
`semantic_hint.julia_syntax_role` named after `@keyword`, `@operator`,
`@punctuation.delimiter`; `semantic_hint.julia_literal` after `@string`,
`@number`, `@boolean`; `semantic_hint.julia_value` after `@variable`. Each is
a mention that the host stores as a reference to nothing: every `end` keyword,
every operator and every number in every Julia file, stored under its own text
as a name. None of them can be the answer to a question, and the Pack said so
itself in a guard whose whole reason was the token
`julia_highlight_capture_not_semantic_identity`.

**Eleven carriers under names nothing assembles** (audit: `carrier_unread` 11).
`omega.pack.julia` was set by three different templates, on a call, on an
import and on a module. `omega.pack.target`, `omega.pack.identity`,
`omega.pack.julia_declaration`, `omega.pack.category`, `omega.pack.named_owner`,
`omega.pack.declaration_path`, `omega.pack.module_path`,
`omega.pack.julia_identifier` -- the value was computed and stored on every
match and nothing in the engine ever asks for any of them. A Julia function
had no `omega.pack.parameter_shape`, no `omega.pack.return_type` and no
`omega.pack.type_parameter_shape`, so a card for a Julia method read as a bare
name: *what does this method take* was stated nowhere in the Pack.

**Ten of those carriers the host would not have folded even if the name were
read** (audit: `carrier` 10). `call.julia_candidate` starts with `call.`, so
`is_definition_kind` is false and the fold never runs;
`import.julia_candidate`, `module.julia_candidate`,
`type.julia_declaration_candidate`, `reference.julia_identifier_candidate` and
`call.target_candidate` are the same mistake. Each fell through to the mention
branch and was stored as a reference to nothing.

**Five of them named themselves with the whole node** (audit: `D2` 5).
`call.julia_candidate` took its name from the entire `(call_expression)`,
`import.julia_candidate` from the entire `(import_statement)`,
`module.julia_candidate` from the entire `(module_definition)` -- so a module
was stored under a name that was the module's whole source text, `end`
included -- `type.julia_declaration_candidate` from the entire
`(struct_definition)`, and `scope.julia_lexical_scope` from the entire
`(macro_definition)`.

**The universal identifier capture.** `(identifier) @variable @local.reference`
at the top of the pinned highlights, feeding two templates: every identifier of
every file, stored twice, once as `semantic_hint.julia_value` and once as
`reference.julia_identifier_candidate`. This is Defect I in its second
spelling, and the 00-INDEX sweep closed 16 of them; this Pack kept its own
because the capture was inside a pinned external block rather than at the top
level of the file.

**Two framework overlays, spelled as tree shapes, each under a comment saying
it was not one.** `import_bound_member_binding_context` and
`import_bound_callable_invocation_context` are 25-line patterns over
`(source_file (import_statement) (assignment) (assignment))` tied together with
`#eq?` on the receiver name, matching the exact shape

```julia
import Module
binding = Module.member(...)
output  = binding(input)
```

and emitting `definition.julia_import_bound_member_binding_context` (a Value,
named after the binding) and
`reference.julia_import_bound_callable_invocation_context`. Both sat under
headers reading "Framework-neutral Julia source fact". That is not a fact about
Julia; it is a resolver written as a query, for one three-statement shape, and
its two guards are the two longest in the Pack. Gone.

**Two guards whose reason was a label** (audit: `G` 2), and 21 more that said
in different words that resolution is the resolver's job -- eight of the 23
began with the same clause about "the generic bounded source symbol/import
resolver". A guard exists to say what a Pack cannot see about the *language*.

**Everything real about Julia was missing.** No struct field. No abstract
type. No primitive type. No supertype edge, so `<:` -- the only place Julia
writes a type relationship down -- produced nothing at all. No constant. No
return type, no parameter list, no `where` clause. No export. `using Foo: bar`
bound nothing (only the whole statement was captured). The short form
`f(x) = ...`, which is how a large share of Julia methods are written, declared
no function. A macro was declared as `definition.julia_macro`, which the
host's `entity_family` files under **Value**: asking Omega for the callables a
Julia module offers found the functions and none of the macros.

**A defect in the host:** none found. Everything above is the Pack's.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a module | `module_definition` name: | `definition.module` | Namespace |
| a module's extent | its `block` | `scope.module_body` | region |
| a function, `function f(x) … end` | `function_definition` → `signature` | `definition.function` | Callable |
| a function, `f(x) = …` | `assignment` with a call on the left | `definition.function` | Callable |
| its argument list | `argument_list` in the signature | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| its return type, `f(x)::T` | the `typed_expression` wrapper | `definition.return_type_candidate` | `omega.pack.return_type` |
| its `where` clause | the `where_expression` wrapper | `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` |
| its body | its `block` | `scope.function_body` | region |
| a macro | `macro_definition` → `signature` | `definition.macro_function` | Callable |
| a struct | `struct_definition` → `type_head` | `definition.struct` | Type |
| its type parameters | the `curly_expression` of the head | `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` |
| its supertype, `<:` | the right side of the head's `binary_expression` | `relation.implements` | implements |
| its body | its `block` | `scope.type_body` | region |
| a field, `x` or `x::T` | `identifier` / `typed_expression` in the struct block | `definition.field` | Value |
| a field's type | the annotation | `definition.declared_type_candidate` | `omega.pack.declared_type` |
| an abstract type | `abstract_definition` → `type_head` | `definition.abstract_type` | Type |
| a primitive type | `primitive_definition` → `type_head` | `definition.primitive_type` | Type |
| a constant | `const_statement` | `definition.constant` | Value |
| a module-level variable | `assignment` directly in `source_file` or a module `block` | `definition.variable` | Value |
| a declared type on either | the annotation | `definition.declared_type_candidate` | `omega.pack.declared_type` |
| `global x` | `global_statement` | `binding.global` | reference |
| `local x` | `local_statement` | `binding.local` | reference |
| `import M`, `using M`, `using M: …` | `import_statement` / `using_statement` | `import.module` | binding |
| `import M as N` | `import_alias` | `binding.import_alias` | binding |
| `using M: a, b` | each name in the `selected_import` | `import.symbol` | binding |
| `export f`, `public f` | `export_statement` / `public_statement` | `export.symbol` | binding |
| `f(x)`, `M.f(x)`, `f.(x)` | `call_expression` / `broadcast_call_expression` | `call.function` | call |
| `@m x` | `macrocall_expression` → `macro_identifier` | `call.macro` | call |
| `x::T`, `::T`, `x::T{…}` | `typed_expression` / `unary_typed_expression` | `type_use.name` | reference |

Three shapes of name are stripped to the spelling the declaration carries, so
that a mention resolves: a macro loses its `@` (the `identifier` inside
`macro_identifier` is captured, not the whole token), a qualified callee
`M.f` is taken at its last segment, and a parametrized type `T{A}` is taken at
its head.

### The one thing the grammar makes hard, and how it is handled

Julia spells a method definition as a call expression. `function f(x)` and
`f(x) = …` contain the same `(call_expression (identifier) (argument_list))`
node an actual call of `f` does, and a tree-sitter pattern cannot look at a
node's parent. A pattern rooted at `(call_expression)` therefore reports one
call of its own name at every function in the corpus: on the sample in
`packs/omega-julia/` terms, 8 of the 16 calls in a 70-line file -- **half** --
were definitions reporting themselves, which is the same failure as the
`field_expression` conflation removed from omega-rust in wave 3.

So the call pattern is rooted at the *parent* instead. The alternation lists
every node type the pinned grammar lets a call expression sit in, taken from
`node-types.json`, minus the two in which a call expression is a declaration --
`signature` and `type_head` -- and minus the first child of `assignment`,
`typed_expression` and `where_expression`, which is where the three assignment
forms of a definition put it. 42 branches, one query pattern, no false call.

The same reasoning trims the type-use pattern: the head of a parametrized type
is taken only in the two annotation positions (`x::T{…}` and `::T{…}`), because
everywhere else in Julia a parametrized head is the head of the declaration
itself and would mention the type being declared as a use of itself.

## Still to decide

1. **Tests.** Julia's test suite is `Test`, a standard library, written
   `@testset "name" begin … end` and `@test expr`. Recognising it means pinning
   a library's API name in a pattern, which `00-CONTRACT.md` §6 forbids in a
   language Pack -- and Julia has no naming convention to key off the way Go
   and Python do. The `tests` capability is therefore not declared, and
   `@testset` is recorded only as an ordinary `call.macro`. If Julia test
   coverage is wanted, it belongs in `frameworks/omega-framework-julia-test`,
   not here.
2. **Docstrings.** A Julia docstring is a bare string literal immediately
   before a definition. It could be carried onto that definition, but no
   carried name the engine reads holds documentation, and its value is a
   paragraph rather than a name. Left out; it is a host question (is there a
   carried name for prose?) rather than a Julia one.
3. **`include("file.jl")`.** This is the one call that changes what a file
   means, and it is stated only as a `call.function` named `include` with the
   path in the argument the Pack does not read. Lifting it to
   `relation.depends` named by the path would need the string literal argument
   captured and its quotes stripped -- cheap to do, but `include` is an
   ordinary function that can be shadowed or called with a computed path, so
   the edge would sometimes be wrong. Left as a call, and named in a guard.
