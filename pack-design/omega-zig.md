# omega-zig

Language `omega-zig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. `packs/omega-zig` version `2.0.0`.

## What it states today

40 templates over 34 query patterns, 4 guards, 50 of the grammar's 99 named
node types touched.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `data` | yes | 1 |
| `definitions` | yes | 25 |
| `imports` | yes | 4 |
| `references` | yes | 4 |
| `scopes` | yes | 2 |
| `tests` | yes | 1 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.struct` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.union` | Type | 1 |
| `definition.opaque_type` | Type | 1 |
| `definition.error_set_type` | Type | 1 |
| `definition.module` | Namespace | 1 |
| `definition.test` | Test | 1 |
| `definition.field` | Value | 1 |
| `definition.variant` | Value | 1 |
| `definition.error_value` | Value | 1 |
| `definition.value` | Value | 1 |
| `definition.label` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | attached to | templates |
|---|---|---|---|
| `definition.visibility_candidate` | `omega.pack.visibility` | function, the five type declarations, a named value, an import alias | 8 |
| `definition.modifier_candidate` | `omega.pack.modifier` | function (`extern`/`export`/`inline`/`noinline`), a named value (`const`/`var`) | 2 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | function | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | function | 1 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | container field | 1 |

All five names are ones the engine reads; the first four are what
`declared_signature` assembles a card's signature line from.

### Regions

- `scope.function_body`, named for its function (1)
- `scope.type_body`, named for its struct, enum, union or opaque (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `import.module` | binding | 1 |
| `import.c_include` | binding | 1 |
| `import.usingnamespace` | binding | 2 |
| `relation.data` | data | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `reference.qualifier` | reference | 1 |
| `reference.error_value` | reference | 1 |
| `reference.field` | reference | 1 |
| `reference.label` | reference | 1 |
| `type_use.name` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 99 node types. The Pack looks at 50 of them.

Untouched, and why that is right: the four supertypes (`expression`,
`statement`, `type_expression`, `primary_type_expression`) are hidden and are
reached through their members; `comment`, `string_content`, `character_content`
and `escape_sequence` are text, not names; `address_space`, `byte_alignment`,
`calling_convention`, `link_section` are ABI decoration on a declaration the
Pack already states; the eight `asm_*` nodes are inline assembly, for which
Omega has no grammar to inject; and the twenty-six control-flow and operator
expressions (`if_statement`, `while_expression`, `switch_case`, `catch_expression`,
`defer_statement`, `payload`, `return_expression`, `range_expression`, …) declare
and mention nothing -- their names would be their own source text.

Full list:

- `address_space`
- `asm_clobbers`
- `asm_expression`
- `asm_input`
- `asm_input_item`
- `asm_output`
- `asm_output_item`
- `async_expression`
- `await_expression`
- `block_expression`
- `break_expression`
- `byte_alignment`
- `calling_convention`
- `catch_expression`
- `character_content`
- `comment`
- `comptime_declaration`
- `comptime_statement`
- `comptime_type_expression`
- `continue_expression`
- `defer_statement`
- `dereference_expression`
- `else_clause`
- `errdefer_statement`
- `escape_sequence`
- `expression`
- `expression_statement`
- `field_initializer`
- `for_expression`
- `for_statement`
- `if_statement`
- `if_type_expression`
- `labeled_statement`
- `link_section`
- `nosuspend_expression`
- `nosuspend_statement`
- `null_coercion_expression`
- `payload`
- `primary_type_expression`
- `range_expression`
- `resume_expression`
- `return_expression`
- `statement`
- `string_content`
- `suspend_statement`
- `switch_case`
- `type_expression`
- `while_expression`
- `while_statement`

`field_initializer` is in the grammar but the pinned parser does not produce it:
`.{ .x = 1 }` is an `initializer_list` holding an `assignment_expression` whose
left side is an object-less `field_expression`. That is the shape the Pack
matches.

---

## What was wrong with it

The Pack that was there stated 54 templates over 48 patterns with 20 coverage
guards, and it declared six kinds of thing. Concretely:

**It was a syntax highlighter with an IR attached.** 35 of its 54 templates --
two thirds of the Pack -- were `data` capability over nvim-treesitter's
`highlights.scm`, pinned by sha256 and copied twice into the same file
(`external_highlights` and `nvim_pinned_highlights`). `semantic_hint.zig_syntax_role`
(11 templates) emitted one row for every `if`, `else`, `for`, `while`, `pub`,
`comptime`, `=`, `+`, `;` and `,` in every Zig file in the repository, named by
its own text. `semantic_hint.zig_literal` (6) did it for every string, number,
character and escape sequence. No question reaches any of them: the answer to
"where is `+` used" is every file.

**Defect I2, the universal capture.** `(identifier) @variable @local.reference`
at pattern root, fed by two templates (`semantic_hint.zig_value` and
`reference.zig_identifier_candidate`). Every identifier of every Zig file, twice.

**Defect D2, thirteen times.** `import.zig_candidate` named itself from the
whole `using_namespace_declaration`; `type.zig_declaration_candidate` named
itself from the whole `enum_declaration` -- the entire body of every enum,
struct and union in the corpus stored as the name of a type.

**Eight carriers the host will never fold.** `call.target_candidate`,
`call.zig_direct_candidate`, `import.zig_candidate`, `type.zig_declaration_candidate`,
`reference.zig_identifier_candidate`, `reference.member_access_candidate`,
`reference.qualified_chain_candidate` all end in `_candidate` but start with
`call.`, `import`, `reference` or `type_use.`, so `is_definition_kind` is false,
the fold never runs and each was stored as a mention of nothing.

**Nine carriers under names nothing assembles.** `omega.pack.target`,
`omega.pack.zig_direct`, `omega.pack.zig`, `omega.pack.zig_declaration`,
`omega.pack.identity`, `omega.pack.zig_identifier`, `omega.pack.member_access`,
`omega.pack.qualified_chain`, `omega.pack.named_owner`. Computed and stored per
emission; read by nothing.

**Defect K2.** `@call.expression` carried both `call.target_candidate` and
`call.zig_direct_candidate`, the same span with the same name under two kinds.

**Three guards whose reason was a label**, out of twenty:
`zig_comptime_dynamic_function_values_and_indirect_calls_remain_candidate`,
`zig_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`,
`zig_highlight_capture_not_semantic_identity`. The other seventeen were the same
sentence about resolution being a resolver's job, restated per capability.

**Four unresolvable injections.** `comment`, and three `asm` ones over
`asm_output_item`, `asm_input_item` and `asm_clobbers`. Omega has no grammar for
either language, so the injection layer had nothing to hand them to.

**And it declared almost nothing a Zig question resolves against.** No
constant, no field type, no visibility, no parameter shape, no error set, no
enum member, no `@import` path, no test. `definition.zig_field` and
`definition.zig_symbol` came from the copied `locals.scm`, so a struct field was
declared from `(container_field type: (identifier))` -- the field's **type**, not
its name -- and every `const` in the corpus, local or not, was declared as
`definition.zig_symbol`.

## What it should extract

| what | node | emitted as | family |
|---|---|---|---|
| a function | `function_declaration` with `name:` | `definition.function` | Callable |
| its visibility | `"pub"` | `definition.visibility_candidate` | -- |
| its linkage | `"extern"`/`"export"`/`"inline"`/`"noinline"` | `definition.modifier_candidate` | -- |
| its parameters | `parameters`, joined from `ordered_children` | `definition.parameter_shape_candidate` | -- |
| its return type | `type:` | `definition.return_type_candidate` | -- |
| its body | `body: (block)` | `scope.function_body` | region |
| a struct type | `const X = (struct_declaration)` | `definition.struct` | Type |
| an enum type | `const X = (enum_declaration)` | `definition.enum` | Type |
| a union type | `const X = (union_declaration)` | `definition.union` | Type |
| an opaque type | `const X = (opaque_declaration)` | `definition.opaque_type` | Type |
| an error set | `const X = (error_set_declaration)` | `definition.error_set_type` | Type |
| a container body | the declaration node | `scope.type_body` | region |
| a struct or union field | `container_field` with `type:` | `definition.field` | Value |
| the field's type | `type:` | `definition.declared_type_candidate` | -- |
| an enum member | `container_field` with `!type` | `definition.variant` | Value |
| an error the set names | `(error_set_declaration (identifier))` | `definition.error_value` | Value |
| a constant or global | container-level `variable_declaration` | `definition.value` | Value |
| whether it is `const` or `var` | `["const" "var"]` | `definition.modifier_candidate` | -- |
| the name an import is bound to | `const std = @import(..)` | `definition.module` | Namespace |
| the module imported | `@import("path")` | `import.module` | binding |
| a C header pulled in | `@cInclude("h")` | `import.c_include` | binding |
| a namespace merged in | `using_namespace_declaration` | `import.usingnamespace` | binding |
| a file compiled in | `@embedFile("path")` | `relation.data` | data |
| a test | `test_declaration` with a name | `definition.test` | Test |
| a direct call | `call_expression function: (identifier)` | `call.function` | call |
| a method call | `call_expression function: (field_expression member:)` | `call.method` | call |
| the base of a qualified name | `field_expression object: (identifier)` | `reference.qualifier` | reference |
| an error value used | `error.X` | `reference.error_value` | reference |
| a field set in an initializer | `.x = v` | `reference.field` | reference |
| a type named | `identifier` in a type position | `type_use.name` | reference |
| a block label | `block_label` | `definition.label` | Value |
| a break or continue target | `break_label` | `reference.label` | reference |

Three decisions in that table are Zig-specific and worth stating.

**One node, four meanings.** `variable_declaration` is a type declaration, a
module alias, a container constant and a local, all at once. The Pack separates
them by the value: a `struct_declaration`, `enum_declaration`,
`union_declaration`, `opaque_declaration` or `error_set_declaration` as the last
named child makes a type; an `@import` call makes a module; anything else makes
a value. The alternation is written out positively because tree-sitter cannot
negate a child.

**Locals are not declared.** A `const` in a function body is that same node. The
five container patterns (`source_file`, `struct_declaration`, `enum_declaration`,
`union_declaration`, `opaque_declaration`) are the filter. Without it a
repository of Zig declares `self`, `allocator` and `buf` once per function --
the `unwrap` pathology of §5 of the brief. `[(a) (b)] (child)` does not work as
a pattern root in tree-sitter: it compiles and matches nothing, which is why the
five are written out rather than alternated.

**The leaf of `a.b` is not stated.** tree-sitter-zig spells a method callee as
the same `field_expression` as a field read, and omega-rust measured the cost of
not noticing: 68.8% of its field mentions were calls. So the Pack states the
*base* of a qualified chain, which is unambiguous and resolves to the import
alias or container that `definition.module` and `definition.struct` declare, and
the member only where the parent proves what it is -- a call, or an object-less
`.x =` inside an initializer.

## Why the audit still reports five

`D2 the name is the span itself` -- 5, and all five are right for this language.

`tree-sitter-zig` gives `identifier` a `string` child, because Zig writes an
identifier that is not a bare word as `@"some name"`. `node-types.json` therefore
lists `identifier` as a node with named children, and `audit.py`'s D2 test --
*the name is its own span, and that span has named children* -- fires on every
leaf named from its own text:

- `definition.error_value` (a member of an error set)
- `reference.qualifier` (the base of `std.mem.x`)
- `reference.error_value` (the `X` of `error.X`)
- `reference.field` (the `x` of `.x = v`)
- `type_use.name` (an identifier in a type position)

In every one of them the span is exactly the identifier and the name is exactly
that identifier's text, which is what the mention is about and what it must
resolve by. There is no larger node to take the span from and no smaller one to
take the name from. The same templates in omega-go pass the check only because
tree-sitter-go's `type_identifier` happens to be a leaf. The check is measuring
the grammar here, not the Pack.

The one real imprecision it hides: for `@"a b"` the stored name includes the
`@"` and the `"`, so such an identifier will not match a declaration spelled the
same way from a different node. That is rare enough not to be worth an
expression, and it is stated here rather than in a guard because it is a
spelling defect, not a limit on what the Pack can see.

## Still to decide

- **`definition.value` merges `const` and `var`.** Both are the same node with a
  different keyword, and a `var` at container level is rare enough that a second
  pair of five patterns was not worth it; the keyword is carried as
  `omega.pack.modifier` instead. If globals turn out to matter, split the kind.
- **`const x = @sizeOf(T);` is not declared.** `builtin_function` is excluded
  from the value alternation so that `@import` is declared once, as a module,
  rather than twice. Every other builtin-valued constant goes with it.
- **Builtin calls other than `@import`, `@cInclude` and `@embedFile` are not
  stated.** `@intCast` and `@as` are on nearly every line of Zig; the three that
  are kept name a file or a module, and the rest name nothing.
