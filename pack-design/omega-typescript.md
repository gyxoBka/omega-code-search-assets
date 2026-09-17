# omega-typescript

Language `omega-typescript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten 2026-09-17. **198 templates over 273 patterns and 80 guards became 58
templates over 35 patterns and 8 guards.** The sections below describe the Pack
that is there now; *What is wrong with it* records what was replaced.

## What it states today

58 templates over 35 query patterns, 59 distinct node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 6 |
| `calls` | yes | 3 |
| `definitions` | yes | 38 |
| `imports` | yes | 3 |
| `modules` | yes | 1 |
| `references` | yes | 2 |
| `scopes` | yes | 6 |
| `types` | yes | 1 |

`data`, `tests` and `implements` are no longer declared: see *What is wrong with
it*.

### Declarations

| kind | family the host gives it | templates | the construct |
|---|---|---|---|
| `definition.class` | Type | 1 | `class` and `abstract class` |
| `definition.interface` | Type | 1 | `interface` |
| `definition.type_alias` | Type | 1 | `type X = ...` |
| `definition.enum` | Type | 1 | `enum` |
| `definition.constant` | Value | 1 | a member of an enum, bare or assigned |
| `definition.function` | Callable | 2 | `function`, `function*`, and a body-less `function_signature` |
| `definition.method` | Callable | 1 | a method with a body, including `constructor` |
| `definition.method_signature` | Callable | 1 | an interface member and an `abstract` member |
| `definition.field` | Value | 2 | a class field, and a parameter property |
| `definition.property` | Value | 1 | a property of an interface or object type |
| `definition.variable` | Value | 1 | a `const`/`let`/`var` at module, export, ambient or namespace scope |
| `definition.namespace` | Namespace | 1 | `namespace X {}`, `module X {}` |
| `definition.ambient_module` | Namespace | 1 | `declare module "koa" {}` |

### Carriers -- attributes they attach to the declaration on the same span

Only names `production.rs` assembles into a card's signature line are carried.

| kind | attribute | templates | taken from |
|---|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 4 | `formal_parameters` of a function, signature, method or method signature |
| `definition.return_type_candidate` | `omega.pack.return_type` | 7 | a `return_type:` annotation, and the `type:` of a field, a property and a parameter property, with the `:` taken off |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 7 | `<T, U>` on a class, interface, type alias, function, signature, method or method signature |
| `definition.visibility_candidate` | `omega.pack.visibility` | 3 | `accessibility_modifier` on a method, a field or a parameter property |

### Regions

- `scope.class_body` (1) -- named by the class
- `scope.interface_body` (1) -- named by the interface
- `scope.function_body` (2) -- the body of a function and of a method, named by it
- `scope.namespace_body` (2) -- the body of a namespace and of an ambient module

None of these ends in `.type`, `.function`, `.class`, `.method` or `.trait`, and
none contains `definition`, so none is also read as a declaration.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `reference.decorator` | reference | 1 |
| `type_use.name` | reference | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.constructor` | call | 1 |
| `import.module` | binding | 2 |
| `import.symbol` | binding | 1 |
| `binding.import_default` | binding | 1 |
| `binding.import_namespace` | binding | 1 |
| `binding.import_alias` | binding | 3 |
| `binding.export_alias` | binding | 1 |
| `module.export` | binding | 1 |

`relation.implements` is the only `relation.*` kind in the Pack, and it is one
of the six the host knows.

## What is wrong with it

This is what the Pack said before the rewrite, measured with
`python pack-design/audit.py omega-typescript` and by reading the two files.

**58 of 198 templates were one library's call shape, not a TypeScript
construct (defect L).** Every `output_kind` ending `_context` -- 58 of them --
hard-coded a tree written for a particular API:
`call.ecmascript_variable_object_fluent_chain_context` matched a three-stage
builder chain; `data.ecmascript_call_object_array_object_string_identifier_context`
matched a call whose argument is an object whose field is an array of objects
with one string field; `reference.typescript_class_decorator_object_array_string_context`
matched an Angular/Nest-shaped decorator metadata object; four patterns matched
`describe("...", () => { test("...", ...) })` and `test.describe`. Twelve
comment lines in `queries.scm` asserted "Framework-neutral" directly above
them, which is the tell 00-INDEX.md names. All 58 are gone; the questions they
tried to answer belong in `frameworks/`, where `omega-framework-react`,
`omega-framework-next-js` and the rest already live.

**29 `data.*` templates stored values that answer nothing (defect D).**
`data.object`, `data.array` and `data.string` named themselves from the whole
`(object)`, `(array)` and `(string)` node, so a module-scope object literal was
stored once under its own entire text -- and again at every nesting level, since
the `data.ecmascript_*_context` family matched objects inside objects inside
calls. TypeScript is a repository's code, not its data; JSON, YAML and TOML
have their own Packs. The whole `data` capability is gone.

**77 templates named an emission with its own span (defect D2), 5 of them with
a container node (defect D).** `binding.parameter` named itself from the whole
`(required_parameter)`, so `private readonly deps: Deps` was a name;
`call.member` named itself from the whole `(call_expression)`, arguments
included; `definition.import_alias` from the whole `(import_alias)`. Every
declaration in the new Pack takes its name from a name capture.

**18 carriers used a name nothing assembles, and 12 could not be folded at
all.** `omega.pack.target`, `omega.pack.identity`, `omega.pack.enclosing_owner`,
`omega.pack.export_alias`, `omega.pack.alias`, `omega.pack.category`,
`omega.pack.member_category`, `omega.pack.member_owned` are read by nothing --
`category` and `member_category` restated the `output_kind` the template had
just declared. And `call.target_candidate`, `scope.enclosing_owner_candidate`,
`module.export_alias_candidate`, `import.alias_candidate`,
`import.target_candidate` and `reference.member_access_candidate` fail
`is_definition_kind`, so the host never folded them: each was stored as a
reference to nothing. The new Pack carries four names and no others, all four
in the set `production.rs:3170` reads.

**2 carriers were folded onto an owner that overwrote them.**
`definition.modifier_candidate` and `definition.visibility_candidate` took their
span from `abstract_method_signature`, whose modifier children are a repeat, so
the attribute was written once per modifier and the last one won.

**3 `relation.*` kinds were not relations.** `relation.assignment`,
`relation.augmented_assignment` and `relation.extends` all arrived as plain
references with long names. `extends` is now `relation.implements`, which is the
subtype edge the host knows; assignment is not stated at all.

**2 scope kinds were also read as declarations.** `scope.function` ends with
`.function` and `scope.class` with `.class`, so each became a region *and* a
declaration of the same name -- two entities per function and per class in every
file. They are `scope.function_body` and `scope.class_body` now.

**12 of 80 coverage guards gave a label instead of a reason (defect G).**
`terminal_static_ceiling__typescript_overload_resolution`,
`typescript_runtime_value_semantics_unavailable` and ten more named a
generator's confidence tier, not a limitation of TypeScript. 80 guards for 198
templates is a guard for every other template; there are 8 now, each a sentence
a reader can act on.

**26 templates spelled one kind, `type.syntax`, over 26 separate patterns**,
one per type node -- `union_type`, `intersection_type`, `array_type`,
`conditional_type`, and so on -- each naming the whole type expression. A type
mention in TypeScript always reaches a `type_identifier`, at any depth and in
any position, so one pattern replaces all 26 and names the type rather than the
syntax around it.

**6 `value_origin.*` templates used a capability no host code reads.**
`value_origins` is in neither the engine's ten capabilities nor the two the
relation-coverage layer reads (AGENT-BRIEF §7); the kinds also start with
`value_`, which `is_definition_kind` excludes, so they were references named
`top_level_const_string` and the like. Gone.

**4 patterns carried an `#eq?` that did work, and are kept in spirit.** Two tied
an imported name to a constructor of the same name -- a resolver's job written
as a query -- and two pinned `constructor` as a method name. The one surviving
`#eq?` is `(#eq? @_require "require")`, which is the language's own CommonJS
spelling, not a library's.

**The manifest declared `implements`, `data` and `tests`.** `tests` had one
template, `test.declaration`, whose kind is a mention, not a test; `implements`
had one. All three are removed, and `capabilities` is now exactly the eight the
58 templates program.

**The grammar's boundary.** The old Pack touched 114 of 183 node types, but a
large share of that reach was the 58 framework shapes and the 26 type-syntax
patterns walking nodes it had nothing to say about. The new Pack touches 59, and
the constructs it reaches are listed above. What it still does not reach is
below.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a class | `class_declaration`, `abstract_class_declaration` | `definition.class` | Type |
| its extent | `class_body` | `scope.class_body` | region |
| its type parameters | `type_parameters` | `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` |
| what it extends or implements | `extends_clause`, `implements_clause`, `extends_type_clause` | `relation.implements` | implements |
| an interface | `interface_declaration` | `definition.interface` | Type |
| its extent | `interface_body` | `scope.interface_body` | region |
| a type alias | `type_alias_declaration` | `definition.type_alias` | Type |
| an enum | `enum_declaration` | `definition.enum` | Type |
| an enum member | `enum_assignment`, `enum_body` | `definition.constant` | Value |
| a function | `function_declaration`, `generator_function_declaration` | `definition.function` | Callable |
| a function without a body | `function_signature` | `definition.function` | Callable |
| its body | `statement_block` | `scope.function_body` | region |
| a method | `method_definition` | `definition.method` | Callable |
| a method without a body | `method_signature`, `abstract_method_signature` | `definition.method_signature` | Callable |
| what any of them takes | `formal_parameters` | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| what any of them returns | `type_annotation`, `type_predicate_annotation`, `asserts_annotation` | `definition.return_type_candidate` | `omega.pack.return_type` |
| whether a member is private | `accessibility_modifier` | `definition.visibility_candidate` | `omega.pack.visibility` |
| a class field | `public_field_definition` | `definition.field` | Value |
| a parameter property | `required_parameter`/`optional_parameter` with an `accessibility_modifier` | `definition.field` | Value |
| an interface property | `property_signature` | `definition.property` | Value |
| a module-scope name | `variable_declarator` under `program`, `export_statement`, `ambient_declaration`, a namespace body | `definition.variable` | Value |
| a namespace | `internal_module`, `module` | `definition.namespace` | Namespace |
| an ambient module | `module` with a string name | `definition.ambient_module` | Namespace |
| their extent | `statement_block` | `scope.namespace_body` | region |
| the module a file depends on | `import_statement`, `export_statement`, `import_require_clause`, `require(...)`, `import(...)` | `import.module` | binding |
| a name taken from a module | `import_specifier` | `import.symbol` | binding |
| what a local name stands for | `import_specifier` alias, `import_clause` identifier, `namespace_import`, `import_require_clause`, `import_alias` | `binding.import_alias`, `binding.import_default`, `binding.import_namespace` | binding |
| a name a module exports | `export_specifier`, `namespace_export`, `export_statement value:` | `module.export` | binding |
| the name it is exported under | `export_specifier` alias | `binding.export_alias` | binding |
| a call | `call_expression` | `call.function`, `call.method` | call |
| a construction | `new_expression` | `call.constructor` | call |
| a decorator | `decorator` | `reference.decorator` | reference |
| a type, anywhere | `type_identifier` | `type_use.name` | reference |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 183 node types. The Pack looks at 59.

Untouched, and why:

- **Statements and control flow** -- `if_statement`, `for_statement`,
  `for_in_statement`, `while_statement`, `do_statement`, `switch_statement`,
  `switch_body`, `switch_case`, `switch_default`, `try_statement`,
  `catch_clause`, `finally_clause`, `else_clause`, `return_statement`,
  `throw_statement`, `break_statement`, `continue_statement`,
  `labeled_statement`, `statement_identifier`, `empty_statement`,
  `debugger_statement`, `with_statement`, `statement`, `declaration`,
  `expression_statement`, `expression`, `primary_expression`, `pattern`,
  `primary_type`, `type`. Control flow names nothing a question resolves to, and
  the last six are the grammar's supertypes, which no pattern needs.

- **Operators and expression shapes** -- `binary_expression`,
  `unary_expression`, `update_expression`, `ternary_expression`,
  `sequence_expression`, `parenthesized_expression`, `assignment_expression`,
  `augmented_assignment_expression`, `await_expression`, `yield_expression`,
  `spread_element`, `optional_chain`, `non_null_expression`,
  `subscript_expression`, `meta_property`, `super`, `this`,
  `instantiation_expression`, `as_expression`, `satisfies_expression`,
  `type_assertion`. An assignment is not a declaration in TypeScript and a cast
  is only the type written in it, which `type_identifier` already states.

- **Literals** -- `string`, `template_string`, `template_substitution`,
  `number`, `true`, `false`, `null`, `undefined`, `object`, `array`, `pair`,
  `shorthand_property_identifier`, `regex`, `regex_pattern`, `regex_flags`,
  `escape_sequence`, `computed_property_name`. A literal resolves to no
  declaration, and this Pack emits no `reference_context.*` kind, so a
  `literal.*` emission would suppress nothing and be dropped (AGENT-BRIEF §5).
  A string is reached where it means something: a module path, an ambient
  module's name.

- **Patterns and destructuring** -- `object_pattern`, `array_pattern`,
  `pair_pattern`, `rest_pattern`, `assignment_pattern`,
  `object_assignment_pattern`, `shorthand_property_identifier_pattern`. Covered
  by the first coverage guard: a destructured name is not declared.

- **Anonymous functions** -- `arrow_function`, `function_expression`,
  `generator_function`, `class`, `class_static_block`. They have no name of
  their own; when one is assigned to a name, that name is the declaration.

- **Type syntax with nothing of its own to name** -- `union_type`,
  `intersection_type`, `array_type`, `tuple_type`, `optional_type`,
  `rest_type`, `readonly_type`, `parenthesized_type`, `conditional_type`,
  `lookup_type`, `index_type_query`, `literal_type`, `template_literal_type`,
  `template_type`, `function_type`, `constructor_type`, `object_type`,
  `infer_type`, `mapped_type_clause`, `type_query`, `predefined_type`,
  `existential_type`, `flow_maybe_type`, `type_arguments`, `constraint`,
  `default_type`, `type_predicate`, `asserts`, `this_type`,
  `type_predicate_annotation`, `asserts_annotation`, `adding_type_annotation`,
  `omitting_type_annotation`, `opting_type_annotation`, `type_parameter`,
  `named_imports`, `export_clause`, `import_attribute`. Every one of these is a
  container whose meaning is the type names inside it, and
  `(type_identifier) @type.name` reaches all of them at any depth. Naming the
  container would store the whole type expression as a name -- defect D, which
  is what the old `type.syntax` did 26 times.

- **The anonymous members of an object type** -- `call_signature`,
  `construct_signature`, `index_signature`. They have no name, so there is
  nothing to declare them under; the third coverage guard says so.

- **Comments and file furniture** -- `comment`, `html_comment`,
  `hash_bang_line`, `override_modifier`. A doc comment is worth reaching one
  day; see *Still to decide*.

## Still to decide

1. **A function assigned to a `const` is a Value, not a Callable.**
   `export const load = async () => {}` is the dominant way modern TypeScript
   declares a function, and the grammar gives it the same `variable_declarator`
   as `const TIMEOUT = 30`. Nothing structural separates them, so the choice was
   between one declaration in the wrong family and two declarations at
   overlapping spans. One was chosen; the second coverage guard states it. A
   `#match?` on the initialiser's text could separate them, but the regex would
   have to distinguish `() => {}` from `(a, b)` and from `(1 + 2)` by spelling,
   and a wrong answer there is silent.

2. **The audit's `carrier_owner` check cannot see the visibility carriers, and
   should not need to.** `accessibility_modifier` sits in a `multiple` child
   group with `override_modifier` on `method_definition`, `public_field_definition`
   and `required_parameter`, so `repeats_in()` reports it as repeating even
   though TypeScript allows exactly one per member. The check happens not to fire
   here, because its `owner` regex cannot attach a capture that trails a `?`
   quantifier or a nested closing paren, so neither the carrier's span nor its
   name is resolved to a node type. Had it fired it would have been wrong: the
   carriers are correct. Reported in `cross_pack_findings` rather than worked
   around.

3. **Doc comments.** A `comment` immediately before a declaration is the
   declaration's documentation, and nothing in the Pack states it. It is the
   same question in every language, so it belongs in the contract before it
   belongs here.

## What omega-tsx and omega-javascript must copy

`omega-tsx` is a port of this Pack, and `omega-javascript` is this Pack with the
type half removed. The three only agree if the following are copied exactly.

**The kinds.** `definition.class`, `definition.interface`,
`definition.type_alias`, `definition.enum`, `definition.constant`,
`definition.function`, `definition.method`, `definition.method_signature`,
`definition.field`, `definition.property`, `definition.variable`,
`definition.namespace`, `definition.ambient_module`; `scope.class_body`,
`scope.interface_body`, `scope.function_body`, `scope.namespace_body`;
`relation.implements`, `reference.decorator`, `type_use.name`, `call.function`,
`call.method`, `call.constructor`, `import.module`, `import.symbol`,
`binding.import_default`, `binding.import_namespace`, `binding.import_alias`,
`binding.export_alias`, `module.export`. A different spelling for the same
construct is defect K2 across the three Packs, and nothing compares them.

**The carrier names.** Exactly four: `parameter_shape`, `return_type`,
`type_parameter_shape`, `visibility`. These and only these are what
`production.rs` assembles into a card's signature line. Do not invent
`parameters`, `type_parameters`, `alias`, `target`, `category` or `identity`.

**The capabilities.** `bindings`, `calls`, `definitions`, `imports`, `modules`,
`references`, `scopes`, `types`. omega-javascript has no `type_identifier`, so
it drops `types` and the `type_use.name` template with it, and it has no
`interface`, `type_alias`, `enum`, `property_signature`, `method_signature`,
`parameter property`, `namespace` or `ambient module`; everything else is the
same. omega-tsx keeps all eight and adds nothing: a JSX element is a use of a
component, and stating it is a decision for omega-tsx's own document, not a
carry-over from here.

**What is deliberately not stated, and must stay unstated.**

- No `data` capability. Object and array literals are not named, at any depth.
- No `tests` capability. `describe`/`it`/`test.each` are a runner's call shape
  and belong in `frameworks/`.
- No `implements` or `value_origins` capability.
- No local binding: a name bound inside a function body, a destructured name, a
  `catch` or `for` binding, and an ordinary parameter are not declared.
- No property *read*: `obj.prop` outside a callee position is not emitted.
- No containment pattern. `(object (pair (object ...)))` and every
  `*_contains_*` relation stay out; the tree already holds containment and a
  region states an extent.
- No `#eq?`/`#match?` tying one node to another node's text. The single `#eq?`
  in the file pins the word `require`.
