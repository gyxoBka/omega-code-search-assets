# omega-scala

Language `omega-scala`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

31 templates over 35 query patterns, 49 distinct grammar node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 21 |
| `imports` | yes | 4 |
| `references` | yes | 3 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | node |
|---|---|---|
| `definition.class` | Type | `class_definition` |
| `definition.trait` | Type | `trait_definition` |
| `definition.enum` | Type | `enum_definition` |
| `definition.enum_case` | Type | `simple_enum_case`, `full_enum_case` |
| `definition.type_alias` | Type | `type_definition` |
| `definition.type_parameter` | Type | `type_parameters`, `covariant_type_parameter`, `contravariant_type_parameter` |
| `definition.package` | Namespace | `package_clause` |
| `definition.package_object` | Namespace | `package_object` |
| `definition.object_module` | Namespace | `object_definition` |
| `definition.function` | Callable | `function_definition` |
| `definition.abstract_function` | Callable | `function_declaration` |
| `definition.given` | Value | `given_definition` |
| `definition.value` | Value | `val_definition`, `val_declaration` |
| `definition.variable` | Value | `var_definition`, `var_declaration` |
| `definition.field` | Value | `class_parameter` |
| `definition.parameter` | Value | `parameter`, `binding`, `lambda_expression` |

### Carriers -- attributes they attach to the declaration on the same span

Every declaration pattern binds the same `@decl.*` captures, so one carrier
template serves every node type that has that part.

| kind | attribute | from |
|---|---|---|
| `definition.modifiers_candidate` | `omega.pack.modifiers` | `modifiers`, `access_modifier`, `opaque_modifier` |
| `definition.type_parameters_candidate` | `omega.pack.type_parameters` | `type_parameters` |
| `definition.parameters_candidate` | `omega.pack.parameters` | `class_parameters` |
| `definition.return_type_candidate` | `omega.pack.return_type` | `return_type` field of `def` and `given` |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | `type` field of `val`, `var`, parameters and `type` |

### Regions

- `scope.declaration_body` -- the body of a class, trait, enum, object, package
  object or braced package, named by the declaration that owns it.
- `scope.function_body` -- the body of a `def`, named by the method.

### Mentions

| kind | occurrence the host makes | node |
|---|---|---|
| `relation.implements` | implements | `extends_clause`, `derives_clause` |
| `relation.depends` | depends | `using_directive` with a dependency key |
| `reference.type` | reference | `type_identifier`, anywhere it stands |
| `call.function` | call | `call_expression`, `infix_expression` |
| `import.binding` | binding | `import_declaration` path tail and selectors |
| `import.alias_binding` | binding | `as` / `=>` rename in a selector |
| `import.package` | binding | wildcard import |
| `export.binding` | binding | `export_declaration` |

### Coverage guards

Six, one sentence each: call resolution needs types; only single-identifier
patterns are declared; a wildcard import names a package, not members;
`extends` / `derives` are spelled, not linearised; an unapplied field selection
is not a reference; macro- and compiler-generated members are not declared.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 150 node types. The Pack looks at 48 of them, plus
`type_identifier`, which the grammar exposes as a query symbol without listing
it in `node-types.json`.

Untouched:

- `_definition`
- `_pattern`
- `access_qualifier`
- `alternative_pattern`
- `annotated_type`
- `annotation`
- `applied_constructor_type`
- `arguments`
- `ascription_expression`
- `assignment_expression`
- `bindings`
- `block`
- `block_comment`
- `boolean_literal`
- `capture_pattern`
- `case_block`
- `case_class_pattern`
- `case_clause`
- `catch_clause`
- `character_literal`
- `colon_argument`
- `comment`
- `compilation_unit`
- `compound_type`
- `context_bound`
- `do_while_expression`
- `early_defs`
- `enum_case_definitions`
- `enumerator`
- `enumerators`
- `escape_sequence`
- `expression`
- `extension_definition`
- `finally_clause`
- `floating_point_literal`
- `for_expression`
- `function_type`
- `given_conditional`
- `given_pattern`
- `guard`
- `identifiers`
- `if_expression`
- `indented_block`
- `indented_cases`
- `infix_modifier`
- `infix_pattern`
- `infix_type`
- `inline_modifier`
- `instance_expression`
- `integer_literal`
- `interpolated_string`
- `interpolated_string_expression`
- `interpolation`
- `into_modifier`
- `lazy_parameter_type`
- `literal_type`
- `lower_bound`
- `macro_body`
- `match_expression`
- `match_type`
- `name_and_type`
- `named_pattern`
- `named_tuple_pattern`
- `named_tuple_type`
- `null_literal`
- `open_modifier`
- `operator_identifier`
- `parameter_types`
- `parameters`
- `parenthesized_expression`
- `postfix_expression`
- `prefix_expression`
- `projected_type`
- `quote_expression`
- `refinement`
- `repeat_pattern`
- `repeated_parameter_type`
- `return_expression`
- `self_type`
- `singleton_type`
- `splice_expression`
- `stable_identifier`
- `string`
- `structural_type`
- `throw_expression`
- `tracked_modifier`
- `transparent_modifier`
- `try_expression`
- `tuple_expression`
- `tuple_pattern`
- `tuple_type`
- `type_arguments`
- `type_case_clause`
- `type_lambda`
- `typed_pattern`
- `unit`
- `upper_bound`
- `vararg`
- `view_bound`
- `while_expression`
- `wildcard`
- `with_template_body`

Most of that is expression and pattern syntax -- `if_expression`,
`while_expression`, `infix_pattern`, `tuple_expression`, the literals, the
comments, the quote/splice macro forms. None of it names anything a question
resolves to, and the Pack deliberately leaves it alone. Several type-shape nodes
(`compound_type`, `infix_type`, `function_type`, `generic_type`'s arguments) are
untouched as nodes but reached through them: `type_identifier` is a leaf of all
of them and it is captured wherever it stands. The three that were weighed and
left out on purpose are recorded under **Still to decide**.

## What is wrong with it

Measured on the Pack as found: **57 templates over 95 patterns with 37 coverage
guards**, and `pack-design/audit.py` flagged 13 carriers the host will not fold,
4 guards whose reason is a label, and 1 `relation.*` the host does not know.

**It was six generator passes concatenated, and they all said the same thing.**
The file carried section headers named `external-helix-tags`,
`external-nvim-treesitter-locals`, `locals`, `p0-exact-helix-locals`,
`p0-exact-helix-tags` and `upstream_tags` -- five imported baselines beside
Omega's own. `(function_definition name: (identifier))` was matched by four
separate patterns. A single `class_definition` fed
`definition.category_candidate`, `definition.identity_candidate`,
`definition.class`, `definition.scala_class` and
`type.scala_declaration_candidate`: five emissions saying *this is a class*.
Nine kinds existed twice under two spellings -- `definition.class` and
`definition.scala_class`, `definition.function` and `definition.scala_function`,
`definition.module` and `definition.scala_module`, and so on -- a generator's
"upstream" name beside a generator's `scala_` name, never reconciled. (This is
the omega-scala half of Defect K in `00-INDEX.md`; the byte-identical pairs were
swept earlier, the differently-spelled synonyms were not, because nothing
mechanical could tell them apart.)

**Six of the 57 templates were named with a whole node.**
`module.scala_candidate` took its name from `(package_clause) @module.expression`
-- the entire package clause. `type.scala_declaration_candidate` took its name
from `(class_definition) @type.expression`, so **every class in the corpus was
stored under a name that is its own full source text**, body included.
`scope.lexical` and `scope.scala_lexical_scope` did the same over
`(template_body)`, `(block)`, `(lambda_expression)`, `(function_definition)`,
`(for_expression)` and `(case_clause)`: two emissions per block, each named with
the block. `import.import_declaration` was named with the import statement, and
`relation.extends_candidate` with the whole `extends` clause.

**Thirteen carriers folded onto nothing, or onto the wrong thing.** Six of them
-- `call.target_candidate`, `module.scala_candidate`,
`type.scala_declaration_candidate`, `scope.enclosing_owner_candidate`,
`import.target_candidate`, `reference.scala_identifier_candidate` -- fail
`is_definition_kind`, so the host never folded them; each fell through to the
mention branch and was stored as a reference to nothing. The rest folded onto a
span where the Pack did declare something, but carried a restatement of the node
kind: `definition.category_candidate` fired from six patterns to attach the
attribute `category` with the value `Foo` to a declaration already named `Foo`,
and `definition.identity_candidate` attached `identity = Foo` to the same
declaration. Two attributes per declaration, both equal to its own name.

**`relation.extends_candidate` was neither a relation nor a carrier.** The host
knows six `relation.*` kinds and this is not one, so it arrived as a plain
reference; and it ends in `_candidate` without passing the definition test, so it
was never folded either. Scala's one genuine `implements` fact -- the thing the
host has a dedicated occurrence for -- was spelled as a reference named with the
text of the `extends` clause. It was also declared under the `imports`
capability, which is what `relation.extends_candidate` has to do with imports.

**Nine kinds were filed in the wrong family** (Defect A). `definition.interface`
and `definition.scala_interface` for a `trait`, `definition.module` and
`definition.scala_module` for an `object`, `definition.scala_object`,
`definition.scala_property`, `definition.scala_variable` and
`definition.constant` all landed in Value. A trait is a type; asking Omega for
Scala types found classes, enums and aliases and no traits at all.

**`(identifier) @local.reference` made every identifier in every file a
reference.** Two templates read it -- `reference.local` and
`reference.scala_identifier_candidate` -- so every occurrence of every name,
including the defining occurrence of each declaration, was stored twice: once as
a reference to nothing and once as a carrier the host would not fold. It is not
the `(_)` universal capture of Defect I, but on Scala source it costs about the
same.

**Thirty-seven guards for 57 templates**, four of them a single token:
`scala_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`,
`scala_import_selector_resolution_requires_semantic_oracle`,
`scala_extends_clause_requires_semantic_type_resolution`,
`scala_upstream_tags_are_syntax_candidates_only`. The rest were sentences, but
sentences of the same shape repeated per capability -- "requires bounded source
symbol resolution" appears seven times -- and they describe a resolver the Pack
does not have, not a limit of Scala.

**The ownership and signature passes were cartesian.** `ownership_parameters`
wrote ten patterns -- five parameter shapes times `function_declaration` and
`function_definition` -- each re-stating `(function name: (_) parameters:
(parameters (parameter)))`, and every one emitted
`binding.parameter_owned_candidate` at the *function's* span, so a function with
four parameters produced four carriers on one span all called
`parameter_owned`, each overwriting the last. The `signature_type_parameters`
pass wrote eleven patterns, three of which --
`(contravariant_type_parameter name: ... type_parameters: ...)`,
`(covariant_type_parameter ...)` and `(type_parameters name: ...
type_parameters: ...)` -- ask a type parameter for its own type parameters.

**Nothing declared a parameter, a lambda binding or a type parameter as
something a reference could resolve to.** They were `binding.*` and
`definition.type.parameter` mentions, and the host turned each into a reference.
So Scala's most common resolution -- a name in a method body reaching the
parameter it was bound to -- had no declaration on the other end.

## What it should extract

Scala files are libraries, services and data pipelines, and the questions asked
of them are: *what does this file declare*, *what type does this name have*,
*what does this class extend or derive*, *what does this file import*, and *who
calls this method*.

| what | node | emitted as | family |
|---|---|---|---|
| a class | `class_definition` via `name` | `definition.class` | Type |
| a trait | `trait_definition` via `name` | `definition.trait` | Type |
| an enum | `enum_definition` via `name` | `definition.enum` | Type |
| an enum case | `simple_enum_case`, `full_enum_case` via `name` | `definition.enum_case` | Type |
| a type alias or abstract type | `type_definition` via `name` | `definition.type_alias` | Type |
| a type parameter | `type_parameters`, `covariant_type_parameter`, `contravariant_type_parameter` via `name` | `definition.type_parameter` | Type |
| a package | `package_clause` via `package_identifier` | `definition.package` | Namespace |
| a package object | `package_object` via `name` | `definition.package_object` | Namespace |
| an `object` | `object_definition` via `name` | `definition.object_module` | Namespace |
| a `def` with a body | `function_definition` via `name` | `definition.function` | Callable |
| a `def` without one | `function_declaration` via `name` | `definition.abstract_function` | Callable |
| a `given` instance | `given_definition` via `name` | `definition.given` | Value |
| a `val` | `val_definition`, `val_declaration` | `definition.value` | Value |
| a `var` | `var_definition`, `var_declaration` | `definition.variable` | Value |
| a class parameter | `class_parameter` via `name` | `definition.field` | Value |
| a parameter or lambda binding | `parameter`, `binding`, `lambda_expression` | `definition.parameter` | Value |
| modifiers and access | `modifiers`, `access_modifier`, `opaque_modifier` | `modifiers` carrier on the declaration | attribute |
| the type parameter list | `type_parameters` | `type_parameters` carrier | attribute |
| the constructor parameter list | `class_parameters` | `parameters` carrier | attribute |
| the declared return type | `return_type` field | `return_type` carrier | attribute |
| the declared value type | `type` field | `declared_type` carrier | attribute |
| a declaration's extent | `template_body`, `enum_body` | `scope.declaration_body` | region |
| a method's extent | `body` field of `function_definition` | `scope.function_body` | region |
| `extends`, `derives` | `extends_clause`, `derives_clause` via the type name | `relation.implements` | implements |
| any type in any position | `type_identifier` | `reference.type` | reference |
| an applied name | `call_expression`, `infix_expression` | `call.function` | call |
| `import a.b.C` | `import_declaration`, last path name | `import.binding` | binding |
| `import a.b.{C, D => E}` | `namespace_selectors` | `import.binding` | binding |
| the local name of a rename | `as_renamed_identifier`, `arrow_renamed_identifier` | `import.alias_binding` | binding |
| `import a.b.*` | `namespace_wildcard` | `import.package` | binding |
| `export` | `export_declaration` | `export.binding` | binding |
| `//> using dep "..."` | `using_directive` | `relation.depends` | depends |
| expressions, patterns, literals, comments | -- | nothing | -- |

Three things make this smaller than the old Pack rather than larger.

**One capture namespace for every declaration's parts.** Each declaration
pattern binds `@decl.span`, and optionally `@decl.modifiers`,
`@decl.type_parameters`, `@decl.parameters`, `@decl.return_type`,
`@decl.declared_type`, `@decl.declaration_body`, `@decl.function_body`. Five
carrier templates and two region templates then serve all sixteen declaration
node types, and the kind is chosen by which `@<kind>.name` capture bound -- the
skip rule does the dispatch. That is what replaces the eleven-pattern
`signature_type_parameters` pass and the ten-pattern `ownership_parameters` pass
with nothing at all.

**Type references are one leaf pattern.** `(type_identifier) @type.reference`
matches every type in every position -- a parameter type, a return type, a type
argument, a `new`, an annotation, a self type, a bound -- and is the reference
that makes every type declaration above reachable. The old Pack had four narrow
type-reference patterns (`instance_expression` twice, `extends_clause` twice)
and one universal identifier capture that swamped them.

**Calls are one pattern with four arms.** `f(x)`, `o.m(x)`, `f[T](x)` and
`o.m[T](x)` are alternations inside a single `call_expression` pattern, plus
`xs map f` on `infix_expression`. Operator identifiers are excluded: `+` and
`::` name no method a question is asked about.

Two other decisions are worth stating, because the kind string decided them.

`definition.object_module` is a Namespace, not a Value. A Scala `object` is a
singleton whose members are reached through its name, which is what Namespace
answers; `object` is not a word the host knows, so the kind has to say `module`
for the family to come out right. The same reasoning puts `definition.package`
and `definition.package_object` in Namespace.

`definition.field` for a `class_parameter` is a compromise. The obvious kinds
are unusable: `definition.class_parameter` contains the word `class` and lands in
Type, and `definition.constructor_parameter` contains `constructor` and lands in
Callable. A `val`-bearing class parameter *is* a field; a plain one is a
constructor parameter that the body still refers to by name. Both want Value,
and `field` is the word that gets there.

## Still to decide

1. **An unapplied field selection.** `config.host` is recorded through the type
   identifiers around it but not as a reference to `host`. Scala's uniform
   access makes `config.host` and `config.host()` the same thing in the source,
   so emitting both a call and a member reference would put two emissions on the
   same identifier span for every method call in the file. Provisionally: calls
   only, with a guard. Revisit if member reads turn out to be asked for more
   often than the duplication costs.
2. **A `given` with no name.** An anonymous `given Show[Foo] with ...` declares
   an instance that nothing in the source names. It could be named from its
   return type, which is what a question would use -- *who provides a `Show` for
   `Foo`* -- but that name is a type, not a value, and would collide with the
   trait's own declaration on lookup. Left undeclared and guarded.
3. **Destructuring patterns.** `val (a, b) = p` and `case Foo(x) =>` bind names
   the Pack does not declare, because `_pattern` is a supertype over eight node
   types and each would need its own pattern to reach the identifiers under it.
   The guard says so. Worth doing if pattern-bound names turn out to be
   referenced as often as parameters are.
