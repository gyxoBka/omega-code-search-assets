# omega-vbscript

Language `omega-vbscript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

VBScript is the language of logon scripts, WSH automation, classic ASP pages,
installer glue and Office macros. The grammar pinned here
(`JJK96/tree-sitter-vbscript@6d9548e`) accepts a VBA-flavoured dialect: it has
`Declare PtrSafe Function`, `As` types and `ByVal`/`ByRef` modifiers, and it has
**no** `Class`, `Property`, `Const`, `Set`, `Select Case`, `With` or
`Option Explicit`. The Pack's boundary of responsibility is that grammar, not
the language as Microsoft documents it.

## What it states today

16 templates over 14 query patterns, 22 distinct node types touched.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 2 |
| `definitions` | yes | 9 |
| `references` | yes | 1 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.procedure` | Callable | 1 |
| `definition.external_function` | Callable | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | attached to | templates |
|---|---|---|---|
| `definition.visibility_candidate` | `omega.pack.visibility` | the `function` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | the `function`, `subroutine`, `ptrsafe_function_declaration` | 3 |
| `definition.return_type_candidate` | `omega.pack.return_type` | the `function`, `ptrsafe_function_declaration` | 2 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | the `variable_declaration_identifier` | 1 |

All four carried names are ones the engine assembles: the first three build the
signature line in `production.rs` (`declared_signature`), and `declared_type` is
in the set the engine reads elsewhere.

### Regions

None. This grammar has no body node -- a `function` holds its statements
directly -- so a `scope.*` region could only have the declaration's own span and
would state nothing the declaration does not. `omega-c` ships the same way.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.assignment` | reference | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `relation.depends` | depends | 1 |
| `type_use.name` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 40 node types. The Pack looks at 22 of them.

Untouched, and why:

| node type | why it is not stated |
|---|---|
| `if_statement`, `for_statement` body, `while_statement`, `do_statement`, `exit_statement` | control flow names nothing a question resolves to; this Pack emits no `reference_context.*`, so a `control_flow.*` marker would have nothing to suppress |
| `binary_expression`, `unary_expression` | operators, no name |
| `literal`, `number`, `string_literal` (outside `Declare`), `boolean` | values; with no `reference_context.*` emitted, a `literal.*` template would be one match per constant for an emission the host drops |
| `argument`, `argument_list`, `keyword_argument` | an argument is a use of a name already stated where it is spelled; `x := 1` naming a parameter is vanishingly rare in this dialect |
| `array_element` (when read), `array_type` | subscripting; the array name is stated at its declaration and at its assignment |
| `parameter`, `modifier` | a parameter is carried as its procedure's `parameter_shape`, not declared on its own -- see the guard |
| `type`, `type_definition` (as a node) | the `As` clause is read for its text and its last segment, never stated as an entity |
| `variable_list` | a grouping node; the names inside it are stated |
| `source_file` | the file is not a declaration |
| `comment` | prose |
| `member_expression` (when read) | a member read is not stated -- see the guard |

## What is wrong with it

The Pack that was here was generated, and it was generated twice: the query file
still carried the generator's section headers (`completeness_bindings`,
`semantic_closure_v3_146_batch2`, `structural-fallback`), two of them empty, and
the same constructs were captured under two spellings from two passes.

Measured by `pack-design/audit.py` before the rewrite: **20 templates over 21
patterns, 9 guards**, with 16 D2, 6 G, 3 carrier-unread and 2 unfoldable-carrier
flags. Concretely:

- **D2 -- the name is the span itself, 16 of 20 templates.** Sixteen templates
  had `name` equal to `span_capture`, and the span was a node with children, so
  the name stored was the whole subtree's source text. `scope.lexical` was named
  with the entire text of a `ptrsafe_function_declaration`; `call.vbscript_candidate`
  with the whole `function_call` including its arguments; `binding.symbol` with
  the whole `variable_declaration` (`Dim n, m As Integer`); `reference.symbol`
  with an entire `member_expression`; `scope.vbscript_for` with the full body of
  every `For` loop; `binding.vbscript_assignment` with the whole statement,
  right-hand side included. **Every loop body and every `Dim` line in a
  repository was stored as a name.** Nothing could resolve against any of them.
- **Two carriers the host will not fold, and three under a name nothing
  assembles.** `call.vbscript_candidate` starts with `call.`, so
  `is_definition_kind` is false and the fold never happened: it fell through to
  the mention branch and was stored as a reference whose name was the call's
  whole text. `type.vbscript_declaration_candidate` is the same. The third,
  `definition.vbscript_declaration_candidate`, does fold -- as
  `omega.pack.vbscript_declaration`, a name no part of the engine reads.
- **A Sub was filed as a value.** `definition.vbscript_subroutine`: `subroutine`
  is not a word in the host's Callable row, so every `Sub` in a repository
  landed in `EntityFamily::Value`. Asking Omega for the procedures of a VBScript
  file found the `Function`s and none of the `Sub`s. (Defect A.)
- **Six guards whose reason was a label**, not a limitation:
  `binding_nodes_are_syntactic_candidates_not_resolved_values`,
  `terminal_static_ceiling__vbscript_runtime_binding_and_dynamic_dispatch` and
  four more. Three others were sentences, but all three said the same thing --
  that a call target is not resolved -- in three generator dialects. (Defect G.)
- **Five scopes that state nothing.** `scope.vbscript_for`, `_do`, `_while`,
  `_function`, `_subroutine` and `scope.lexical`. Two of them duplicated the
  declaration's own span; the other four made a region of every loop in every
  file, each named with its own body.
- **Nothing was ever declared to carry anything.** The Pack had three
  declaration kinds and three carrier kinds, and not one carrier shared a span
  with a declaration: `call.vbscript_candidate` sat on a `function_call`,
  `type.vbscript_declaration_candidate` on a `type_definition`. No card could
  ever show a VBScript signature, because no `visibility`, `parameter_shape` or
  `return_type` was emitted at all -- while the grammar hands all three over.
- **Two capabilities were declared and programmed for nothing.** `scopes` (six
  templates, none answering a question) and `types` (two, both carriers that
  could not fold).
- **The entry point into a native library was thrown away.**
  `Private Declare PtrSafe Function GetTickCount Lib "kernel32" ...` is the one
  place a VBScript/VBA file states an external dependency. The old Pack matched
  `ptrsafe_function_declaration` twice and used it for a scope named with the
  declaration's whole text; the library string was never read.

Not present, and worth recording: no defect H (no nvim predicates), no I (no
universal capture), no F (no constant attributes), no L (no framework shapes),
no K (no byte-identical duplicates).

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a `Function` | `function` | `definition.function`, span the whole declaration, name the identifier | Callable |
| whether it is `Private` | `"Private"` token of `function` | `definition.visibility_candidate` on the function's span | `omega.pack.visibility` |
| what it takes | `parameter_list` of `function`/`subroutine`/`ptrsafe_function_declaration` | `definition.parameter_shape_candidate` on the declaration's span | `omega.pack.parameter_shape` |
| what it returns | `type_definition` of `function`/`ptrsafe_function_declaration`, `As` stripped | `definition.return_type_candidate` on the declaration's span | `omega.pack.return_type` |
| a `Sub` | `subroutine` | `definition.procedure` | Callable |
| a `Declare PtrSafe Function` | `ptrsafe_function_declaration` | `definition.external_function` | Callable |
| the library it declares into | first `string_literal` of that node, unquoted | `relation.depends` | depends |
| a declared variable | `variable_declaration_identifier` (plain or `array_identifier`) | `definition.variable` | Value |
| the type it is given | sibling `type_definition`, `As` stripped | `definition.declared_type_candidate` on the name's span | `omega.pack.declared_type` |
| where a name is set | first child of `variable_assignment`, of `for_statement`, of `redim` | `binding.assignment`, span and name the identifier | reference |
| a call | `function_call` first identifier; `invocation_statement` first identifier | `call.function` | call |
| a method call on a receiver | last identifier of a `member_expression` heading an `invocation_statement` | `call.method` | call |
| a type named in source | `new_expression` identifier; last identifier of a `type_member_expression` in a `type_terminal` | `type_use.name` | reference |

Five coverage guards replace the nine: the constructs this grammar has no node
for; the call/subscript ambiguity and dynamic dispatch; parameters and
implicitly-declared names not being declarations; member reads not being stated;
and what is and is not stated about types and about `Alias`.

## Still to decide

- **`New A.B`.** This grammar gives `New ADODB.Connection` the shape
  `member_expression(new_expression(ADODB), Connection)` -- the `New` binds
  tighter than the dot -- so the `new_expression` holds the library prefix, not
  the class. Stating both segments is the mistake omega-kotlin was fixed for, so
  only what the `new_expression` holds is stated and the guard says so. In
  VBScript proper `New` takes a bare class name and `CreateObject("ADODB.Connection")`
  is how a COM type is named, so the form that is stated correctly is the common
  one. If the grammar is ever repointed at one that parses the dotted form as
  `type_member_expression`, add the anchored last-segment alternative.
- **`buffer(i)` read as a call.** A subscript and a call are the same syntax and
  this grammar gives both `function_call`, with no parent visible to a query.
  Every array read in a repository is therefore one `call.function` under the
  array's name. The alternative -- dropping `call.function` for the parenthesised
  form and keeping only `Call f(x)` and `f x, y` -- would lose most real calls,
  which is worse. Stated, and guarded.
- **`Helper(n)` on a line of its own does not parse.** The grammar produces an
  `ERROR` node for a parenthesised call used as a statement without `Call`. That
  is a grammar defect, not a Pack defect; nothing in `queries.scm` can reach an
  `ERROR`'s contents usefully. Recorded here so the next reader does not look
  for the missing call.
