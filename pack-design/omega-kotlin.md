# omega-kotlin

Language `omega-kotlin`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

28 templates over 23 query patterns, 42 distinct node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 18 |
| `imports` | yes | 3 |
| `references` | yes | 3 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.interface` | Type | 1 |
| `definition.object_class` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.type_parameter` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.property` | Value | 1 |
| `definition.parameter` | Value | 1 |
| `definition.variable` | Value | 1 |
| `definition.constant` | Value | 1 |
| `definition.package` | Namespace | 1 |

### Carriers -- attributes they attach to the declaration on the same span

Every one of them is spanned on the declaration node itself and named from an
optional capture of the same match, so it folds onto that declaration and is
skipped when the construct does not have that part.

| kind | attribute | what it holds |
|---|---|---|
| `definition.modifier_candidate` | `omega.pack.modifier` | the `modifiers` group as written (`private data`, `override`, `const`) |
| `definition.visibility_candidate` | `omega.pack.visibility` | `public`/`private`/`internal`/`protected` |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | `<T>`, `<K, V>` |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | `(times: Int = 1)`, and the primary constructor of a class |
| `definition.return_type_candidate` | `omega.pack.return_type` | the written return type of a function |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | the written type of a property, parameter or alias target |
| `definition.container_name_candidate` | `omega.pack.container_name` | the receiver of an extension function or property |

The first five are exactly the names `production.rs::declared_signature`
assembles into the signature line on a card; the last two are read by
`materialize.rs`.

### Regions

- `scope.function_body` (1) -- named by the function, spanned on its body
- `scope.type_body` (1) -- named by the type, spanned on its `class_body` or `enum_class_body`

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `reference.type` | reference | 1 |
| `reference.member` | reference | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `import.binding` | binding | 1 |
| `import.alias_binding` | binding | 1 |
| `import.package` | binding | 1 |

### Coverage guards

Seven, each a sentence about Kotlin: unresolved name spelling, the unnamed
secondary constructor, inferred types, the untyped call receiver and the
unrecorded infix and operator forms, the star import and the implicit default
imports, the one relation that three supertype spellings collapse into, and the
unnamed accessor / `init` / object-expression bodies.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 142 node types. The Pack looks at 42 of them.

The 100 untouched types divide cleanly, and each group has one reason:

- **Expression forms** -- `additive_expression`, `comparison_expression`,
  `conjunction_expression`, `disjunction_expression`, `elvis_expression`,
  `equality_expression`, `multiplicative_expression`, `range_expression`,
  `prefix_expression`, `postfix_expression`, `indexing_expression`,
  `indexing_suffix`, `as_expression`, `check_expression`, `range_test`,
  `type_test`, `spread_expression`, `parenthesized_expression`,
  `directly_assignable_expression`, `assignment`, `infix_expression`.
  Operators name nothing a question resolves to. `infix_expression` is a real
  Kotlin call (`a to b`) and is still left out: the grammar gives operand and
  operator the same `simple_identifier` node, so a pattern over it would
  declare two of every three as calls.
- **Control flow** -- `if_expression`, `when_expression`, `when_entry`,
  `when_subject`, `when_condition`, `guard_condition`, `while_statement`,
  `do_while_statement`, `try_expression`, `catch_block`, `finally_block`,
  `jump_expression`, `label`, `control_structure_body`, `statements`. The host
  discards `control_flow.*` and `scope_context.*`, and this Pack emits no
  `reference_context.*` kind for their spans to suppress, so every one of them
  would be a match per construct for an emission the host drops.
- **Literals** -- `integer_literal`, `real_literal`, `hex_literal`,
  `bin_literal`, `long_literal`, `unsigned_literal`, `boolean_literal`,
  `null_literal`, `character_literal`, `character_escape_seq`,
  `string_literal`, `string_content`, `collection_literal`, and the five
  interpolation nodes. Same rule, and it is why nine `literal.*` templates were
  swept out of this Pack before the rewrite.
- **Modifier leaves** -- `class_modifier`, `function_modifier`,
  `inheritance_modifier`, `member_modifier`, `property_modifier`,
  `parameter_modifier`, `parameter_modifiers`, `platform_modifier`,
  `reification_modifier`, `variance_modifier`, `type_modifiers`,
  `type_parameter_modifiers`, `type_projection_modifiers`, `use_site_target`.
  All sit inside `modifiers`, whose text the Pack already carries as
  `omega.pack.modifier`; capturing each leaf would multiply a declaration's
  match by the number of modifiers it carries.
- **Type plumbing** -- `type_arguments`, `type_projection`, `type_constraint`,
  `type_constraints`, `parenthesized_user_type`, `function_type_parameters`,
  `quest`, `binding_pattern_kind`. The `type_identifier` inside each of them is
  already a reference; the wrapper adds nothing.
- **Call plumbing** -- `call_suffix`, `value_arguments`, `value_argument`,
  `annotated_lambda`, `lambda_literal`, `anonymous_function`, `object_literal`.
  An argument is an expression; a lambda and an object expression declare no
  name.
- **Deliberate, and guarded** -- `secondary_constructor` and
  `constructor_delegation_call` (no identifier to name them by), `getter`,
  `setter`, `property_delegate`, `anonymous_initializer` (no name),
  `annotation` and `file_annotation` (the `type_identifier` in them is already
  a reference, and reading an annotation's name as a semantic marker is what a
  framework overlay is for), `destructuring_declaration`,
  `parameter_with_optional_type`, `super_expression`, `this_expression`.
- **Noise** -- `source_file`, `import_list`, `line_comment`,
  `multiline_comment`, `shebang_line`.

## What is wrong with it

Measured before the rewrite by `python pack-design/audit.py omega-kotlin`:
**56 templates over 59 patterns, 25 guards**, 56 node types touched, and every
defect class in `00-INDEX.md` that the repository-wide sweeps could not close.

**Sixteen carriers under a name nothing assembles.** `omega.pack.kotlin`
(twice, from `import.kotlin_candidate` and `module.kotlin_candidate`),
`omega.pack.kotlin_declaration`, `omega.pack.identity`, `omega.pack.target`,
`omega.pack.declaration_path`, `omega.pack.module_path`, `omega.pack.category`
(four templates), `omega.pack.member_owned`, `omega.pack.parameter_owned`,
`omega.pack.named_owner`, `omega.pack.receiver`, and the five
`relation.*_candidate` ones. Each was computed per match and stored, and
nothing in the engine ever asks for any of those names. `omega.pack.identity`
and `omega.pack.category` restate the `output_kind` the template already
declares.

**Fourteen carriers the host will not fold at all.** `import.kotlin_candidate`,
`module.kotlin_candidate`, `type.kotlin_declaration_candidate`,
`import.target_candidate`, `module.declaration_path_candidate`,
`import.module_path_candidate` and the five `relation.*_candidate` kinds end in
`_candidate` but fail `is_definition_kind` -- `import` is an excluded prefix and
`relation.*`/`type.*` contain no `definition` and end in none of the five
suffixes -- so instead of folding onto a declaration they fell through to the
mention branch and were stored as references to nothing.

**Twelve templates named an emission with a whole node.**
`import.kotlin_candidate` stored the text of the entire `import_header` as a
name, `module.kotlin_candidate` the entire `package_header`,
`type.kotlin_declaration_candidate` **and `definition.class` the entire
`class_declaration`** -- every byte of a class, its body included, written into
the index as that class's name -- and `definition.function` the entire
`function_declaration`. `definition.namespace` named itself from an
`(identifier)`. A single class was therefore stored three times: the whole
node, the whole node again under a second kind, and once under its real name.

**Five `relation.*` kinds the host does not know.**
`relation.supertype_or_delegation_candidate`,
`relation.superclass_constructor_candidate`,
`relation.explicit_delegation_candidate`, `relation.superinterface_candidate`,
`relation.function_supertype_candidate`. The host recognises exactly
`implements`, `tests`, `depends`, `config`, `data` and `handles`; all five
arrived as plain references, so *what does this class implement* was answered
nowhere -- while `manifest.toml` went on declaring the `implements` capability.

**Four constructs declared twice under two spellings.** `binding.field` and
`definition.kotlin_field` over the same capture, `binding.import` and
`import_binding.kotlin_import`, `binding.kotlin_variable` and `binding.var`,
`scope.kotlin_lexical_scope` and `scope.lexical`. Two generator passes
(`upstream_tags` and `external-helix-tags`) ran over one `locals.scm` baseline
and neither reconciled with the other. On top of those, `definition.class`
existed three times over, `definition.function` four times, and
`definition.type`, `definition.kotlin_type` and `definition.type.parameter`
were three names for two things.

**Three carriers folded onto their owner and overwrote themselves.**
`definition.modifier_candidate`, `scope.named_owner_candidate` and
`definition.parameter_shape_candidate` were spanned on a node that holds many
of the node their name came from, so N members wrote one attribute onto one
declaration and the last one won.

**Two guards whose reason is a label**
(`kotlin_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`
and `kotlin_upstream_tags_are_syntax_candidates_only`); of the other 23, twelve
were variations on "requires View-level resolver evidence", which is a
statement about the engine's pipeline and not about Kotlin. 25 guards for 56
templates.

**A type filed as a value** (Defect A). `definition.kotlin_namespace` and
`definition.namespace` both landed in Value. A Kotlin package is a namespace
and the Pack had no kind that said so.

**Eleven patterns of framework overlay, spelled as tree shapes** (Defect L),
under four comments asserting the opposite: "Framework-neutral Kotlin
annotated-function and direct top-level call context. No Compose semantics
here", "Framework-neutral Kotlin direct simple call with first
non-interpolated string literal", "Bounded one-level trailing-lambda
ownership", and `framework_neutral_kotlin_class_di_v3_146`. What they encode is
Jetpack Compose (`@Composable fun` plus the call inside its body), a
routing/DSL builder (`owner { nested("literal") }`, matched down to the first
string argument of the nested call) and constructor dependency injection (an
annotated class plus the type of each primary-constructor parameter). None of
that is Kotlin syntax; all of it belongs in `frameworks/`. Together they fed
six `call.kotlin_*_context` templates and two `reference.kotlin_*_context`
ones.

**The universal capture in its second spelling.** The `locals.scm` baseline's
`(variable_declaration (simple_identifier) @local.definition.var
@local.definition.variable)` matched every `val`, `var`, lambda parameter,
destructuring component and loop variable in the file, and fed three templates
that each stored it again.

**A scope pattern that is a list of control-flow nodes.** `[(if_expression)
(when_expression) (when_entry) (for_statement) (while_statement)
(do_while_statement) (lambda_literal) (function_declaration)
(primary_constructor) (secondary_constructor) (anonymous_initializer)
(class_declaration) (enum_class_body) (enum_entry) (interpolated_expression)]
@local.scope` -- twice, once from the nvim baseline and once from the helix
one -- each feeding a `scope.*` template **named from the whole node it
spans**: a region whose name is the entire class it covers.

**Three `#set!` directives** inherited from nvim-treesitter
(`definition.function.scope "parent"`), which only the injection layer reads
and which no injection in this Pack uses.

What this added up to: of 56 templates, five declared something under a name a
question could use. A Kotlin file's interfaces, objects, type aliases, enum
entries, properties, extension receivers and supertypes were either absent or
stored under the text of the node that held them.

## What it should extract

Kotlin is used for Android apps, JVM services, multiplatform libraries and
Gradle build logic. The questions asked of a Kotlin file are: *what does this
file declare*, *what package is it in*, *what does it import*, *what does this
class extend or implement*, *what type does this name have*, and *who calls
this function*.

| what | node | emitted as | family |
|---|---|---|---|
| a class, and data/sealed/annotation/enum class | `class_declaration` + `"class"`, via `type_identifier` | `definition.class` | Type |
| an interface | `class_declaration` + `"interface"` | `definition.interface` | Type |
| an object, a companion object | `object_declaration`, `companion_object` | `definition.object_class` | Type |
| a type alias | `type_alias` | `definition.type_alias` | Type |
| a type parameter | `type_parameter` via `type_identifier` | `definition.type_parameter` | Type |
| a function, member or extension | `function_declaration` via `simple_identifier` | `definition.function` | Callable |
| a property, and a `val`/`var` in a body | `property_declaration` via `variable_declaration` | `definition.property` | Value |
| a primary-constructor parameter | `class_parameter` | `definition.property` | Value |
| a function or lambda parameter | `parameter`, `lambda_parameters` | `definition.parameter` | Value |
| a loop or destructuring binding | `for_statement`, `multi_variable_declaration` | `definition.variable` | Value |
| an enum entry | `enum_entry` | `definition.constant` | Value |
| the file's package | `package_header` via `identifier` | `definition.package` | Namespace |
| what a declaration is marked with | `modifiers`, `visibility_modifier` | `modifier` / `visibility` carriers | attribute |
| what it takes and returns | `type_parameters`, `function_value_parameters`, `primary_constructor`, the bare type child | `type_parameter_shape` / `parameter_shape` / `return_type` carriers | attribute |
| the written type of a property or parameter | the bare type child of `variable_declaration`, `parameter`, `class_parameter` | `declared_type` carrier | attribute |
| what an extension is declared on | `receiver_type` | `container_name` carrier | attribute |
| a function's body extent | `function_body` | `scope.function_body` | region |
| a type's body extent | `class_body`, `enum_class_body` | `scope.type_body` | region |
| `: Base()`, `: Iface`, `: Iface by d` | `delegation_specifier` via `type_identifier` | `relation.implements` | implements |
| any type mention | `type_identifier` | `reference.type` | reference |
| `::foo` | `callable_reference` | `reference.member` | reference |
| `foo(...)` | `call_expression` via `simple_identifier` | `call.function` | call |
| `x.foo(...)` | `call_expression` via `navigation_suffix` | `call.method` | call |
| `import a.b.C`, `import a.b.C as D` | `import_header`, last `simple_identifier` of the path | `import.binding` | binding |
| the local name an alias introduces | `import_alias` | `import.alias_binding` | binding |
| `import a.b.*` | `import_header` + `wildcard_import` | `import.package` | binding |

Two capture namespaces make this 23 patterns instead of one per question.
`@decl.span`, `@decl.modifiers`, `@decl.visibility`, `@decl.type_parameters`,
`@decl.parameters`, `@decl.return_type`, `@decl.declared_type`,
`@decl.container`, `@decl.name`, `@decl.function_body` and `@decl.type_body`
are shared by every declaration pattern, so the seven carrier templates and the
two region templates are written once and serve all eleven declaration kinds.
The `@<kind>.name` capture is what picks the declaration template, and exactly
one of them binds per match. Containment is stated nowhere: a member carries
its class through the `within:` namespace segment, and a body's extent is the
one region that says it.

Two anonymous tokens do work no named node can. `"class"` and `"interface"` are
the only thing that tells the two arms of `class_declaration` apart, and
`#not-match?` over the import header's own text is the only way to keep
`import a.b.*` out of the pattern that binds the last segment of a path:
tree-sitter has no negation, and the grammar gives the wildcard form the same
`identifier` child as every other import.

Measured after: **28 templates over 23 patterns, 7 guards**, 42 node types
touched, and `pack-design/audit.py omega-kotlin` reports zero in every class.

## Still to decide

1. **A local `val` is stored as `definition.property`.** Kotlin spells a local
   binding and a class property with the same `property_declaration` node, and
   telling them apart needs the parent -- which is containment, which this Pack
   does not state. Both land in Value and both carry their written type, so the
   answer is right and only the kind word is a compromise. Revisit if the rows
   coming out of function bodies turn out to dominate.
2. **`omega.pack.container_name` on an extension holds the receiver as
   written**, so `val List<User>.first2` carries `List<User>` and resolves
   against nothing. Stripping the type arguments would make it resolve to
   `List`, which is usually a type the repository does not declare either. Left
   as written: a container name that is wrong is worse than one that finds
   nothing.
3. **`(type_identifier) @type.reference` also fires on the name of every
   declaration**, so a class is both declared and mentioned at its own span.
   This is what omega-scala does, and it is what makes a type mention in an
   argument, a supertype, a cast, a type argument or an annotation reachable
   from one leaf pattern. The alternative is one pattern per position the
   grammar allows a type in, which is where the old Pack's pattern count came
   from.
4. **Jetpack Compose, Hilt/Dagger and the Android annotations are not here**,
   and `@Test` is not a test signal, so this Pack declares no `tests`
   capability. Each of them is an annotation name applied to an otherwise
   ordinary declaration, which is exactly what an overlay in `frameworks/` is
   for; the annotation's `type_identifier` is already a `reference.type`, so an
   overlay has something to match on.
