# omega-go

Language `omega-go`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten 2026-09-17. The tables below describe the Pack as it stands now; the
two analysis sections at the end record what was there before and why it went.

## What it states today

47 templates over 26 query patterns, 7 coverage guards, 42 of the grammar's 111
named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 31 |
| `imports` | yes | 5 |
| `references` | yes | 4 |
| `scopes` | yes | 4 |
| `tests` | yes | 1 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | node | templates |
|---|---|---|---|
| `definition.package` | Namespace | `package_clause` | 1 |
| `definition.function` | Callable | `function_declaration` | 1 |
| `definition.test_function` | Test | `function_declaration` (`Test`/`Benchmark`/`Fuzz`/`Example`) | 1 |
| `definition.method` | Callable | `method_declaration` | 1 |
| `definition.interface_method` | Callable | `method_elem` | 1 |
| `definition.struct` | Type | `type_spec` with a `struct_type` | 1 |
| `definition.interface` | Type | `type_spec` with an `interface_type` | 1 |
| `definition.type` | Type | any other `type_spec` | 1 |
| `definition.type_alias` | Type | `type_alias` | 1 |
| `definition.type_parameter` | Type | `type_parameter_declaration` | 1 |
| `definition.field` | Value | `field_declaration` with a name | 1 |
| `definition.constant` | Value | `const_spec` | 1 |
| `definition.variable` | Value | `var_spec` | 1 |
| `definition.label` | Value | `labeled_statement` | 1 |

### Carriers -- attributes they attach to the declaration on the same span

Each of these is emitted with the *declaration's* span, so the fold lands on the
declaration and not on something that contains it. The first four are the names
the card's signature line is built from.

| kind | attribute | attached to | templates |
|---|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | function, test, method, interface method | 4 |
| `definition.return_type_candidate` | `omega.pack.return_type` | function, method, interface method | 3 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | function, struct, interface, other type | 4 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | other type, alias, struct field | 3 |
| `definition.receiver_candidate` | `omega.pack.receiver` | method | 1 |
| `definition.tag_candidate` | `omega.pack.tag` | struct field | 1 |

### Regions

| kind | span | named by | templates |
|---|---|---|---|
| `scope.function_body` | the `block` of a function, test or method | the callable's own name | 3 |
| `scope.type_body` | the `struct_type` or `interface_type` | the type's own name | 2 |

Neither kind ends in `.type`, `.function`, `.class`, `.method` or `.trait`, and
neither contains `definition`, so neither is read back as a declaration.

### Mentions

| kind | occurrence the host makes | node | templates |
|---|---|---|---|
| `import.package` | binding | `import_spec` path, plain or aliased | 2 |
| `import.alias` | binding | `import_spec` `name:` | 1 |
| `import.side_effect` | binding | `import_spec` named `_` | 1 |
| `import.dot` | binding | `import_spec` named `.` | 1 |
| `call.function` | call | `call_expression` on a plain identifier | 1 |
| `call.method` | call | `call_expression` through a selector | 1 |
| `relation.implements` | implements | embedded struct field, embedded interface | 2 |
| `reference.member` | reference | `selector_expression` `field:` | 1 |
| `reference.label` | reference | `goto`/`break`/`continue` label | 1 |
| `type_use.name` | reference | every `type_identifier` | 1 |

`relation.implements` is the only `relation.*` kind in the Pack, and it is one
of the six the host knows.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 111 node types. The Pack looks at 42 of them.

Untouched, and why:

- **Every literal** -- `int_literal`, `float_literal`, `imaginary_literal`,
  `rune_literal`, `interpreted_string_literal`, `raw_string_literal`,
  `escape_sequence`, `true`, `false`, `nil`, `iota`, `literal_value`,
  `keyed_element`, `literal_element`, `composite_literal`. The Pack emits no
  `reference_context.*` kind, so a `literal.*` emission suppresses nothing and
  the host drops it (`emission_roles.rs`, `ROLE_PREFIX`). One query match per
  number and string in every Go file, for nothing.
- **Every control-flow statement** -- `if_statement`, `for_statement`,
  `for_clause`, `range_clause`, `expression_switch_statement`,
  `type_switch_statement`, `select_statement`, `expression_case`, `type_case`,
  `default_case`, `communication_case`, `return_statement`,
  `break_statement`/`continue_statement` (except for their labels),
  `fallthrough_statement`, `defer_statement`, `go_statement`, `send_statement`,
  `receive_statement`, `empty_statement`. None of them names anything. "Where
  does this file start a goroutine" is a real question, but the goroutine's call
  is already emitted as a call and the `go` keyword adds no name.
- **Every expression form** -- `binary_expression`, `unary_expression`,
  `index_expression`, `slice_expression`, `parenthesized_expression`,
  `type_conversion_expression`, `type_instantiation_expression`,
  `type_assertion_expression`, `variadic_argument`, `argument_list`,
  `expression_list`, `expression_statement`. Same reason.
- **Statement-level binding** -- `short_var_declaration`, `assignment_statement`,
  `inc_statement`, `dec_statement`, `func_literal`. See the guard: what a
  package declares is stated, what one function body declares is not.
- **Group wrappers** -- `import_declaration`, `import_spec_list`,
  `const_declaration`, `var_declaration`, `var_spec_list`, `type_declaration`,
  `field_declaration_list`, `block` as a thing in itself, `source_file`. A group
  has no name of its own; its members are declared individually, and the tree
  already puts them inside it.
- **Supertypes** -- `_type`, `_simple_type`, `_statement`, `_simple_statement`,
  `_expression`. Not matchable as node types.
- `comment` -- Go doc comments sit immediately above the declaration they
  document. Attaching one as a carrier is the obvious next step and is listed
  under *Still to decide*.
- `type_arguments`, `type_constraint` -- the names inside them are already
  emitted by `(type_identifier) @type.reference`.
- `variadic_parameter_declaration` -- it is part of the `parameter_list` whose
  text the `parameter_shape` carrier stores.
- `raw_string_literal_content`, `interpreted_string_literal_content` --
  an import path is taken from the whole literal and unquoted by the template.

## What is wrong with it

Measured before the rewrite by `python pack-design/audit.py omega-go`:
**214 templates over 140 patterns, 51 guards.**

**Defect L -- a framework overlay inside a language Pack, 21 patterns feeding 11
templates.** This is the largest single thing wrong with the old Pack and the
reason it was so big. Under nine header comments asserting "Framework-neutral",
it hard-coded the call shapes of specific Go libraries:

| what it encoded | patterns | templates |
|---|---|---|
| Cobra: `var x = &cobra.Command{Use: "..."}` | 2 | 1 |
| gin/echo routing: import alias + `alias.New()` + `root.Group("/prefix")` | 6 | 4 |
| controller-runtime: `ctrl.NewControllerManagedBy(mgr).For(&v1.Kind{}).Complete(r)` | 5 | 3 |
| `receiver.Method("path", handler)` and receiver chains | 3 | 3 |
| qualified composite binding `&pkg.Type{Field: x}` | 3 | 2 |
| struct embedding as a framework fact | 1 | 1 |

Four of them are five and six levels of `call_expression` nested inside
`selector_expression` inside `call_expression`, each costing a match attempt at
every call site in every Go file to recognise one library's builder chain. Every
one of these belongs in `frameworks/`, and the `#eq?` predicates tying an import
alias to a receiver identifier are a resolver's job, not a Pack's.

**Defect D2 -- the name is the span itself, 129 templates.** The dominant defect
by count. 129 of 214 templates gave no `name` expression distinct from their
span, so the emission's name was the whole node's source text. Because so many
of those spans were statements and types rather than leaves, the index stored:
every `(assignment_statement)` under its own text; every `(expression_list)` on
each side of a `:=` under its own text; every `(block)` and every
`(source_file)` -- the whole file, as a name -- under `reference.scope_block`
and `reference.scope_file`; every `(struct_type)`, `(interface_type)`,
`(function_type)`, `(map_type)`, `(channel_type)` under its own text;
every comment under `data.data_comment` and again under `lexical.lex_comment`.
On a real Go repository this is where the rows come from, and none of it can be
asked a question: nothing resolves against the text of a block.

**Defect K2 -- the same fact under two kinds.** The generator ran passes that
never reconciled, and the query file is full of nodes captured twice on the same
line: `(comment) @data.comment @lex.comment`, `(channel_type) @channel.type
@type.channel`, `(array_type) @collection.array_type @type.array`,
`(interface_type) @interface.type @type.interface`, `(var_spec) @binding.var
@decl.var_spec @package.var`. Eleven literal node types were each emitted twice,
once as `data.data_*` and once as `lexical.lex_*`, with identical spans and
identical names. So were the collection types, as `collection.*` and `type.*`.

**Kinds that answer nothing, ~150 templates.** The old Pack had ten capabilities
and a private taxonomy under each: `control.*` (20 templates, every statement
keyword), `type.*` (22, every type form), `collection.*` (8), `channel.*` (5),
`signature.*` (4), `lexical.*` (11), `data.*` (22), `declaration.*` (7),
`module.*` (15), `type_operation.*` (3). None of these prefixes means anything
to `content_builder.rs`. Every one of them fell through to the mention branch
and was stored as a *reference to its own source text*. `control.control_if`
under capability `scopes` is a reference named `if err != nil { return err }`.

**Defect G -- a guard whose reason is a label, 14 of 51.** Six distinct tokens,
each repeated: `terminal_static_ceiling__go_short_declaration_scope_resolution`,
`..._go_dynamic_interface_dispatch`, `..._go_builtin_vs_user_call_resolution`,
`..._go_concurrency_happens_before_runtime`, `..._go_select_runtime_choice`,
`go_runtime_value_semantics_unavailable`. Of the other 37, most were a sentence
about the generator's own capture subset ("captures only an authored direct
`&qualified.Type{Field: identifier}` binding") -- a description of a framework
pattern that should not have existed, not a limitation of Go.

**A carrier folded onto its owner, 11 templates.** `definition.category_candidate`
and `definition.identity_candidate` took their span from a `@...owner` capture
and their name from a node inside it, and both carried names -- `category`,
`identity` -- that no host code reads. `call.target_candidate`,
`import.target_candidate`, `import.module_path_candidate`,
`scope.named_owner_candidate` and `binding.parameter_owned_candidate` end in
`_candidate` but do not pass `is_definition_kind`, so the host never folded
them: five templates arriving as references to nothing.

**What Go actually declares, and was missing.** For all 214 templates the Pack
could not answer the two questions asked most often of Go code:

- *Which type does this method belong to?* A Go method is written at file top
  level, so nothing in the tree nests it in its type. The old Pack captured
  `@go.method.receiver_type` in two patterns and used it only as a *field* of a
  framework template. There was no carrier and no reference linking a method to
  its receiver type.
- *Is this a struct or an interface?* Every `type_spec` became
  `definition.definition_type`, one kind for all of them, plus a second
  emission `definition.definition_type_name` at the same span.

Three more that were absent: struct tags (`json:"id"` is how a Go struct meets
every wire format it touches), embedding as an implements edge, and dot and
blank imports, which change what a file's unqualified names mean.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| the package this file is in | `package_clause` | `definition.package` | Namespace |
| an imported package | `import_spec` `path:` | `import.package` | binding |
| the local name given to an import | `import_spec` `name:` | `import.alias` | binding |
| a blank import, taken for its side effects | `import_spec` named `_` | `import.side_effect` | binding |
| a dot import, which spills its names into the file | `import_spec` named `.` | `import.dot` | binding |
| a function | `function_declaration` | `definition.function` | Callable |
| a test, benchmark, fuzz target or example | `function_declaration`, name matching Go's convention | `definition.test_function` | Test |
| a method | `method_declaration` | `definition.method` | Callable |
| the type a method hangs off | `method_declaration` `receiver:` type | `definition.receiver_candidate` | `omega.pack.receiver` on the method |
| a method an interface requires | `method_elem` | `definition.interface_method` | Callable |
| what a callable takes | `parameter_list` | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| what a callable returns | `result:` | `definition.return_type_candidate` | `omega.pack.return_type` |
| what a generic construct is parameterised by | `type_parameter_list` | `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` |
| a struct type | `type_spec` + `struct_type` | `definition.struct` | Type |
| an interface type | `type_spec` + `interface_type` | `definition.interface` | Type |
| any other defined type | `type_spec` | `definition.type` | Type |
| what that type is defined as | the `type:` field | `definition.declared_type_candidate` | `omega.pack.declared_type` |
| a type alias | `type_alias` | `definition.type_alias` | Type |
| a type parameter | `type_parameter_declaration` | `definition.type_parameter` | Type |
| a struct field | `field_declaration` with a name | `definition.field` | Value |
| the field's declared type | `field_declaration` `type:` | `definition.declared_type_candidate` | `omega.pack.declared_type` |
| the field's wire name | `field_declaration` `tag:` | `definition.tag_candidate` | `omega.pack.tag` |
| a type embedded in a struct | `field_declaration` without a name | `relation.implements` | implements |
| an interface embedded in an interface | `type_elem` | `relation.implements` | implements |
| a package constant | `const_spec` | `definition.constant` | Value |
| a package variable | `var_spec` | `definition.variable` | Value |
| a label | `labeled_statement` | `definition.label` | Value |
| a jump to a label | `goto`/`break`/`continue` | `reference.label` | reference |
| a call by plain name | `call_expression` on an `identifier` | `call.function` | call |
| a call through a selector | `call_expression` on a `selector_expression` | `call.method` | call |
| a field or method reached through a selector | `selector_expression` `field:` | `reference.member` | reference |
| any mention of a type | `type_identifier` | `type_use.name` | reference |
| the extent of a body | the `block` of a function, test or method | `scope.function_body` | region |
| the extent of a type | `struct_type`, `interface_type` | `scope.type_body` | region |

Twenty-six patterns, one per node, with several templates over the patterns
whose single match answers several questions: a `function_declaration` match
carries the declaration, its region, and three of the five carriers the card's
signature line is built from.

## Still to decide

Three genuine judgement calls, taken one way here and worth revisiting.

1. **Locals are not declared.** `x := f()`, a `range` clause and a type switch
   guard introduce names, and they are the most common declarations in Go by a
   wide margin -- and the least useful to index, because the agent asking
   "where does `err` come from" is already looking at the function. They are
   left out and a guard says so. If the index proves it can carry them, the
   pattern is one line.
2. **A method call is emitted twice**, as `call.method` on the
   `call_expression` and as `reference.member` on the `selector_expression`
   inside it, at two different spans. Splitting them needs a way to say
   "a selector that is not a call's function", which tree-sitter's six
   predicates cannot express. Keeping both costs a row per method call and
   answers both "who calls this" and "who touches this member"; dropping
   `reference.member` would lose every struct field read.
3. **Doc comments are not attached.** A Go doc comment is the `comment` node
   immediately preceding a declaration, and `((comment) @doc . (function_declaration))`
   states exactly that. It would make a good `definition.doc_candidate` carrier.
   It is left out because a comment's text is unbounded and `max_string_bytes`
   is the only thing standing between a licence header and the index.

## A defect in the host

None found. Everything wrong with this Pack was the Pack's.
