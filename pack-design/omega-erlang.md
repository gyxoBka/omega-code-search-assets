# omega-erlang

Language `omega-erlang`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

23 templates over 18 query patterns, 7 distinct root node types
(`attribute`, `function`, `record`, `macro`, `call`, `function_capture`, and
`stab_clause` reached through `attribute`).

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 10 |
| `implements` | yes | 1 |
| `imports` | yes | 3 |
| `references` | yes | 7 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.callback_function` | Callable | 1 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.macro` | Value | 1 |
| `definition.module` | Namespace | 1 |
| `definition.record` | Type | 1 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameters_candidate` | `omega.pack.parameters` | 2 |

One over the `function` node and one over a `-callback` attribute; both sit on
the span of the declaration they describe, so both fold into it.

### Regions

- `scope.function_body` (1) -- the extent of one function, all clauses, named
  with the function's own name.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `call.function` | call | 1 |
| `import.function` | binding | 1 |
| `import.include` | binding | 1 |
| `import.module` | binding | 1 |
| `reference.application` | reference | 1 |
| `reference.export` | binding | 1 |
| `reference.field` | reference | 1 |
| `reference.function_capture` | reference | 2 |
| `reference.macro` | reference | 1 |
| `reference.record` | reference | 1 |
| `reference.spec` | reference | 1 |

### Attributes stored

Five, all read from the source, none constant: `module` on a qualified call, a
qualified `fun` capture and an imported function; `arity` on an export, an
import and a `fun` capture; `export_kind` (`export` / `export_type`);
`include_kind` (`include` / `include_lib`).

### Coverage guards

Five, each naming a limitation of the language or of this grammar: the type
application / local call conflation, name-without-arity identity, runtime
dispatch, unread headers, and unindexed variables.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 48 node types. The Pack looks at 17 of them: `attribute`,
`atom`, `arguments`, `binary_operator`, `call`, `function`, `function_clause`,
`function_capture`, `integer`, `list`, `macro`, `quoted_content`, `record`,
`stab_clause`, `string`, `tuple`, `variable`.

The 31 untouched types, and why each is left alone:

- Expression and control forms -- `after`, `anonymous_function`, `bitstring`,
  `block`, `body`, `case`, `character`, `clause`, `float`, `guard`, `if`,
  `map`, `map_content`, `map_update`, `maybe`, `parenthesized_expression`,
  `receive`, `record_content`, `sigil`, `sigil_prefix`, `sigil_suffix`,
  `try`, `unary_operator`, `function_type`, `tripledot`: these are the shape of
  a computation, not a name. Nothing resolves to them and an agent asking about
  one of them is reading the function, not querying the index. The function's
  extent is already a region, so "which function is this `receive` in" is
  answered.
- `source`, `shebang`, `comment`, `comment_content`, `line_comment`,
  `escape_sequence`: the file, its interpreter line and its prose. The file is
  already the unit of the index.

`variable` is touched, but only as a macro name (`?TIMEOUT` and
`-define(TIMEOUT, ...)` spell it as a variable). A variable in its ordinary
sense is single-assignment and function-local in Erlang, so no question about
one crosses a file boundary. The old Pack emitted one `reference.variable` per
occurrence and one `binding.parameter` per parameter; that is the largest thing
deleted here, and it is stated as a guard.

## What is wrong with it

Measured against the Pack that shipped: 31 templates over 32 patterns,
8 declared capabilities, 16 coverage guards.

**A -- a type filed as a value (2 kinds).** `definition.record` reached Value
because `record` was not in the host's Type vocabulary; it is now, and the kind
is unchanged. `definition.erlang_callback` was Value: a callback is a callable
contract, so the kind is now `definition.callback_function` and lands in
Callable. `definition.module` was Value and is now Namespace by the same host
change.

**B -- the family won by a substring.** None. No Erlang kind spelled a family
word inside a longer word.

**C -- the grammar's boundary (14 of 48 node types seen; now 17).** Six constructs the
grammar exposes were not reached at all, and each is something an agent asks
about:

- `-define` was never matched, so **no macro was ever declared**, while every
  `?NAME` use was matched -- as a *declaration carrier* (below). Erlang macros
  are the language's only constant mechanism.
- `-record` fields (`tuple` under the record attribute) were never reached, so
  `#state.count` had nothing to resolve to.
- `-type` was matched with `(arguments . (atom))`, but a real `-type opt() ::
  ...` puts the name under a `binary_operator`, so the pattern **never matched
  any Erlang type declaration**. Confirmed by parsing: 18 type declarations
  across three OTP modules, 0 matches.
- `-callback` and `-spec` were matched at the attribute but their `stab_clause`
  was not, so the function name each one is about was thrown away and replaced
  with a literal (below).
- `-export` / `-export_type` list entries were never reached, so the module's
  public API was not stated.
- `-include` / `-include_lib` were named with the whole argument list,
  `("kernel/include/file.hrl")`, quotes and parentheses included, instead of
  the path.

**D -- the name is a whole node (7 templates).** The worst of the seven is
`semantic_hint.syntax_node` over `(_) @structural.node`: a pattern matching
**every named node in the file**, emitting one `data` fact per node whose name
is the node's entire source text. On a 120 KB OTP module that is one emission
per node with the whole subtree stored as a name. The other six:
`call.function_call` named with the entire call expression including its
arguments; `reference.function_capture` with the whole `fun m:f/1`;
`import.module_import` with the whole `-import(lists, [map/2, filter/2])`;
`scope.lexical` with the whole `(block)`; `call.target_candidate` with whatever
expression sat in the function position; `data.erlang_attribute` was named from
the attribute name, but `import.erlang_include` and `reference.erlang_on_load`
were named from their whole `(arguments)` node.

**E -- containment stated as a pattern.** Two: `(function name: (_) body: (_))`
and `(function_clause name: (_) body: (_))` emitted `scope.named_owner_candidate`,
a carrier that states a function contains its body. Replaced by one
`scope.function_body` region. No cartesian depth patterns -- Erlang is flat, so
this Pack escaped the cubic case.

**F -- the generator's batch number (14 of 31 templates).** Constant attributes
carrying `source` values `erlang-behaviour-v3.141`, `pack-ownership-v2.4`,
`pack-completeness-v2.3`, `pack-canonical-key-inputs-v2.7`,
`pack-resolution-hints-v2.5`, `erlang-function-list-context-v3.32`,
`erlang-qualified-call-v3.141`, `pack-resolution-paths-v2.6`,
`semantic-closure-v3.146`, `semantic-closure-v3.146-batch3`, plus 11 further
constants restating the kind (`role`, `semantics`, `symbol_category`,
`target_semantics`, `scope_semantics`, `chain_semantics`,
`identity_semantics`). 25 constant attribute writes per matched construct,
answering nothing. All deleted; the five attributes that remain are read from
the source.

**G -- a guard whose reason is a label (4 of 16).**
`syntactic_scope_boundaries_only_no_runtime_scope_inference`,
`generic_structural_fallback_not_semantic_truth`,
`category_is_syntactic_from_ast_node_kind; namespace_visibility_signature_...`,
`identity_candidate_is_syntactic; overload_namespace_module_visibility_...`.
Eight more said the same thing about call resolution in eight different
wordings. Sixteen guards for eight capabilities became five.

**Beyond the seven classes.**

- **A name that is a constant.** Four templates named their emission with
  `{"kind": "literal"}`: every `-spec` in the corpus was stored under the name
  `erlang_spec`, every `-callback` under `erlang_callback`, every `-behaviour`
  under `erlang_behaviour`, every `-export` under `erlang_export`. The function
  name each attribute is actually about was available two nodes away and was
  discarded. This is worse than Defect D: a whole-node name is at least
  distinct per emission.
- **A use declared as a declaration.** `(macro name: (_))` matches `?MODULE`,
  i.e. a macro *use*, and fed `definition.category_candidate` with
  `symbol_category = "macro"`. `(record name: (_))` matches `#state{}`, a
  record *use*, and did the same with `"record"`. Every use of a macro or
  record claimed to carry a declaration's category.
- **A foreign module declared as local.** The module pattern was
  `(#any-of? @attribute.kind "module" "behaviour" "behavior")`, so
  `-behaviour(gen_server)` emitted `definition.module` named `gen_server`: the
  declaring module of every OTP behaviour was declared in every module that
  implements it.
- **No `relation.*` kind at all.** Erlang has exactly one implements relation,
  `-behaviour`, and it was emitted as `definition.erlang_behaviour_context`
  plus `reference.erlang_behaviour`, neither of which the host reads as a
  relation.
- **Framework semantics in a language Pack.** The `erlang.list_owner` pattern,
  `(function_clause name: (atom) pattern: (arguments) body: (list (atom)))`
  with `(#eq? @arguments "()")`, exists to find Common Test's `all()` function.
  Its own coverage guard says so. That belongs in `frameworks/`, not here.
- **Two capabilities dropped.** `data` carried only the structural fallback,
  the generic attribute duplicate and the Common Test pattern. `bindings`
  carried one template emitting every function parameter variable. `types`
  carried only `type.erlang_spec`, whose name was the constant `erlang_spec`.
  The manifest now declares six capabilities, all programmed.
- **Duplicates.** `definition.function` and `definition.erlang_function_context`
  were two templates over two patterns for the same declaration, and both were
  rooted at `function_clause`, so a four-clause function was declared eight
  times. `call.function_call`, `call.target_candidate` and
  `reference.erlang_qualified_call_context` were three emissions per call.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| module header `-module(m)` | `attribute` + first `atom` argument | `definition.module` | Namespace |
| behaviour `-behaviour(gen_server)` | `attribute` + first `atom` argument | `relation.implements` | implements |
| function, all clauses | `function` anchored to its first `function_clause` | `definition.function` | Callable |
| its parameter list | the same match, `pattern: (arguments)` | `definition.parameters_candidate` | carrier `omega.pack.parameters` |
| its extent | the same match | `scope.function_body` | region |
| exported name `-export([f/0])` | `binary_operator` inside the argument `list` | `reference.export` (+ `arity`, `export_kind`) | binding |
| imported module `-import(lists, ...)` | `attribute` + first `atom` argument | `import.module` | binding |
| imported function `map/2` | `binary_operator` inside the argument `list` | `import.function` (+ `module`, `arity`) | binding |
| header `-include("x.hrl")` | `quoted_content` of the `string` argument | `import.include` (+ `include_kind`) | binding |
| record `-record(state, {...})` | `attribute` + first `atom` argument | `definition.record` | Type |
| record field | `atom` inside the field `tuple`, three shapes | `definition.field`, named `state.count` | Value |
| record use `#state{}` / `R#state.f` | `record`, `name:` field | `reference.record` | reference |
| record field access | the same match, optional `field:` | `reference.field`, named `state.count` | reference |
| type `-type opt() :: ...` | `call` under the `::` `binary_operator` | `definition.type` | Type |
| callback `-callback init(...)` | `stab_clause` under the attribute | `definition.callback_function` | Callable |
| its parameter list | the same match | `definition.parameters_candidate` | carrier |
| spec `-spec f(...) -> ...` | first `stab_clause` under the attribute | `reference.spec`, named `f` | reference |
| macro `-define(T, 5000)` | `variable`/`atom`/`call` first argument | `definition.macro` | Value |
| macro use `?T` | `macro`, `name:` field | `reference.macro`, named `T` | reference |
| qualified call `m:f(...)` | `call` with `module:` | `call.function` (+ `module`) | call |
| bare application `f(...)` | `call` anchored to `function:` | `reference.application` | reference |
| `fun m:f/1` | `function_capture` with `module:` | `reference.function_capture` (+ `module`, `arity`) | reference |
| `fun f/1` | `function_capture` anchored to `function:` | `reference.function_capture` (+ `arity`) | reference |

Two naming decisions carry the resolution:

- Names are stripped to the spelling the declaration uses. `?TIMEOUT` becomes
  `TIMEOUT`, `("x.hrl")` becomes `x.hrl`, `-spec f(...)` becomes `f`, so each
  mention can resolve to the declaration it is about.
- A record field is spelled `record.field` on both sides, because Erlang field
  names are only unique within their record, and `count` alone would collide
  with every other record's `count`.

## Still to decide

**A bare application is a reference, not a call.** This grammar parses a module
attribute's body as ordinary expressions, so `integer()` in a `-spec` and
`handle(X)` in a function body are both a `call` node with an `atom` in the
`function` field, and a tree-sitter pattern cannot distinguish them: nested
patterns match direct children only, so "not inside an `attribute`" is not
expressible. Measured over `lists.erl`, `gen_server.erl` and `proc_lib.erl`:
2 112 bare applications, of which 742 (35%) are type applications, 332 of those
naming `term`.

Calling all of them calls would put 742 false call edges into the index and
would file the most-used type names as callables -- the `unwrap` case from the
brief. Calling all of them references is true of both: a type application is a
reference to a type, a local call is a reference to a function. So the `calls`
capability covers qualified `m:f(...)` only, and a guard says so. The cost is
that "who calls this local helper" is answered under references rather than
calls. The alternative -- recovering statement-position local calls with
patterns rooted at `body`, `guard` and `clause` -- recovers a minority of them
and is exactly the containment pattern Defect E forbids.

**Arity is not part of a declaration's name.** `f/1` and `f/2` are different
functions in Erlang, but the parameter list is the only arity evidence at a
declaration and the expression vocabulary has no way to count list elements, so
the declaration is named `f` and the arity travels as a carrier
(`omega.pack.parameters`) and as an attribute where the source writes it
(`-export`, `-import`, `fun f/1`). Resolving `f/2` to the right declaration
would need either a counting op in `expr.rs` or arity as a first-class part of
a declaration's identity. Reported as a cross-Pack finding; nothing
Erlang-specific belongs in the host for it.
