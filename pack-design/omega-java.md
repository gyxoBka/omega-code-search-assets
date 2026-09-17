# omega-java

Language `omega-java`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

40 templates over 40 query patterns, 58 named node types, 5 coverage guards.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 3 |
| `definitions` | yes | 20 |
| `imports` | yes | 5 |
| `modules` | yes | 2 |
| `references` | yes | 7 |
| `scopes` | yes | 3 |

### Declarations

| kind | family the host gives it | node it spans |
|---|---|---|
| `definition.class` | Type | `class_declaration` |
| `definition.interface` | Type | `interface_declaration` |
| `definition.enum` | Type | `enum_declaration` |
| `definition.record` | Type | `record_declaration` |
| `definition.annotation_interface` | Type | `annotation_type_declaration` |
| `definition.type_parameter` | Type | `type_parameter` |
| `definition.method` | Callable | `method_declaration` |
| `definition.constructor` | Callable | `constructor_declaration` |
| `definition.compact_constructor` | Callable | `compact_constructor_declaration` |
| `definition.annotation_element_method` | Callable | `annotation_type_element_declaration` |
| `definition.field` | Value | `variable_declarator` of a `field_declaration` |
| `definition.constant` | Value | `variable_declarator` of a `constant_declaration` |
| `definition.enumerator` | Value | `enum_constant` |
| `definition.variable` | Value | local, resource, catch, loop and pattern bindings |
| `definition.parameter` | Value | `formal_parameter`, `spread_parameter` |
| `definition.package` | Namespace | `package_declaration` |
| `definition.module` | Namespace | `module_declaration` |

`definition.enumerator` is deliberate: `definition.enum_constant` would put the
word `enum` last among the words the host matches and file every enum constant
as a Type. An enum constant is a value of its enum, so the kind avoids the word
(`entity_family`, `content_builder.rs`). `definition.annotation_interface` is
the same lever used the other way -- Java calls `@interface` an annotation
interface, and `interface` is in the host's Type vocabulary.

### Carriers -- attributes folded onto the declaration on the same span

Each of these is emitted with `@decl.span`, which is the declaration itself, so
it folds onto that declaration and nothing else. The first four are exactly the
names `declared_signature` (`omega-runtime/src/build/production.rs`) assembles a
card's signature line from.

| kind | attribute | what it carries |
|---|---|---|
| `definition.modifier_candidate` | `omega.pack.modifier` | the `modifiers` node: `public static final`, and the annotations written on it |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | `<T extends Comparable<T>>` |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | `(String name, int count)`, and a record's header |
| `definition.return_type_candidate` | `omega.pack.return_type` | a method's or an `@interface` element's declared type |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | the type of a field, constant, parameter, local, resource or caught exception |

### Regions

| kind | span |
|---|---|
| `scope.class_body` | `class_body`, `interface_body`, `enum_body`, `annotation_type_body`, and an enum constant's anonymous body |
| `scope.function_body` | a method's `block`, a constructor's `constructor_body`, a compact constructor's `block` |
| `scope.module_body` | `module_body` |

Each is named by the declaration that owns it, never by its own text.

### Mentions

| kind | occurrence the host makes | what it is |
|---|---|---|
| `relation.implements` | implements | `extends` on a class, every type in an `implements`/`extends` list, and `provides S with Impl` |
| `reference.type` | reference | every `type_identifier`: a field's type, a parameter's type, a cast, a type argument, a `throws` clause, a catch type, `Foo::new` |
| `reference.annotation` | reference | the annotation interface an `@Ann` names |
| `reference.field` | reference | the field named by a `field_access` |
| `reference.service_type` | reference | `uses S;` in a module declaration |
| `call.method` | call | `method_invocation`, by the method's simple name |
| `call.constructor` | call | `object_creation_expression`, by the type constructed |
| `call.method_reference` | call | `String::valueOf`, by the method named |
| `import.binding` | binding | `import a.b.C;`, under the simple name `C` |
| `import.package` | binding | `import a.b.*;`, under `a.b` |
| `import.requires` | binding | `requires M;` |
| `export.package` | binding | `exports p;` |
| `export.opens` | binding | `opens p;` |

Nothing is emitted under a `relation.*` name the host does not know, and no
`literal.*` or `control_flow.*` markers are emitted: the Pack states no
`reference_context.*` kind, so such markers would suppress nothing and the host
would drop them (`emission_roles.rs`, `ROLE_PREFIX`).

## The boundary: what the grammar offers and the Pack ignores

The grammar names 151 node types. The Pack names 58 of them, down from 123 --
the removed ones were statements, operators, literals and comments, which
declare nothing and mention nothing resolvable.

Untouched, and why that is right:

- **Every statement and expression form** -- `if_statement`, `for_statement`,
  `while_statement`, `do_statement`, `switch_expression`, `switch_block`,
  `switch_rule`, `switch_label`, `try_statement`, `try_with_resources_statement`,
  `catch_clause`, `finally_clause`, `throw_statement`, `return_statement`,
  `break_statement`, `continue_statement`, `yield_statement`,
  `labeled_statement`, `assert_statement`, `synchronized_statement`,
  `expression_statement`, `binary_expression`, `unary_expression`,
  `update_expression`, `assignment_expression`, `ternary_expression`,
  `cast_expression`, `parenthesized_expression`, `array_access`,
  `array_creation_expression`, `array_initializer`, `class_literal`,
  `explicit_constructor_invocation`, `lambda_expression`, `inferred_parameters`.
  None of them names anything a question resolves to; the names *inside* them
  are reached through `type_identifier`, `method_invocation`, `field_access` and
  the declaration patterns.
- **Every literal and comment** -- the ten `*_literal` nodes, `true`, `false`,
  `null_literal`, `string_literal`, `string_fragment`,
  `multiline_string_fragment`, `string_interpolation`, `escape_sequence`,
  `template_expression`, `line_comment`, `block_comment`.
- **Type spellings that are not a name** -- `array_type`, `annotated_type`,
  `generic_type`, `void_type`, `integral_type`, `floating_point_type`,
  `boolean_type`, `type_arguments`, `type_bound`, `wildcard`, `dimensions`.
  They are carried as text on `omega.pack.declared_type` /
  `omega.pack.return_type`, and the names they contain are captured as
  `type_identifier` mentions.
- **Grouping nodes with no name of their own** -- `program`, `declaration`,
  `statement`, `expression`, `primary_expression`, `_type`, `_simple_type`,
  `_unannotated_type`, `_literal`, `module_directive`, `resource_specification`,
  `record_pattern`, `record_pattern_body`, `enum_body_declarations`,
  `argument_list`, `annotation_argument_list`, `permits`, `throws`,
  `requires_modifier`, `underscore_pattern`, `this`, `super`.
  `permits` and `throws` contain only `type_identifier`s, which are already
  mentioned; `program` was a `scope.program` region named with the whole file.
- **`static_initializer`** and **`receiver_parameter`**: a static block has no
  name, and `Foo this` binds no new name.
- **`element_value_pair` / `element_value_array_initializer`**: see *Still to
  decide*.

## What is wrong with it

This section describes the Pack as it was found: **215 templates over 222 query
patterns with 54 coverage guards**, generated in bulk and never read back.

**Half the templates named an emission with a whole node -- 125 of 215.** The
audit's D2 class counted every template whose `name` was its own `span_capture`
where that span is a node with children. `annotations.annotation_normal` stored
the full text of `@GetMapping(path = "/users", produces = "application/json")`
as a name; `annotations.annotation_type` stored an entire `@interface`
declaration, body included; `expressions.expression_binary` stored every binary
expression in the file under its own source text. Three more (class D proper)
named a region with a container: `scopes.scope_program` named a region with the
whole file, `scopes.scope_class` with the whole class body, `scopes.scope_block`
with every block. Nothing can be asked of a name that is a compilation unit.

**148 of 215 templates were mentions that resolve against nothing.** The Pack
declared 26 kinds and mentioned 148, and the mention kinds were the grammar's
node list transcribed: `expressions.*` (8), `literals.*` (11),
`switch_patterns.*` (9), `exceptions.*` (8), `generics.*` (6), `types.*` (9),
`objects_arrays.*` (5), `string_templates.*` (4), `comments.*` (2),
`preview_boundaries.*` (4), `modifiers.modifier_list`, `synchronization.*`.
Every one of them is a plain `reference` occurrence whose name is that node's
own text, so an agent asking anything gets back a wall of expression bodies.
Ten `literal.*` and ten `control_flow.*` templates were the same thing with a
justification attached -- but the suppression they exist for only applies to
`reference_context.*` kinds, which this Pack never emitted.

**Thirty-one carriers were folded onto the wrong declaration.** Nine
`definition.category_candidate` templates and eight
`definition.member_category_candidate` ones spanned the *enclosing* class while
naming a *member*, so a class with forty methods had `omega.pack.category`
written onto it forty times and kept the last. Ten more carriers
(`call.target_candidate`, `import.target_candidate`,
`scope.enclosing_owner_candidate`, `scope.named_owner_candidate`,
`module.declaration_path_candidate`, `reference.member_access_candidate`,
`reference.qualified_chain_candidate`, `reference.qualified_name_candidate`,
`reference.receiver_candidate`, `binding.parameter_owned_candidate`) failed
`is_definition_kind`, so the host never folded them at all and stored each as a
reference to nothing.

**Forty-eight patterns stated containment.** The `member_category_*` and
`ownership_parameters` families spelled out
`(class_declaration name: (_) body: (class_body (method_declaration name: (_))))`
once per (owner kind × member kind) pair -- three owner kinds times seven member
kinds, plus six parameter shapes -- to say that a method is inside a class. The
tree says that, and a nested declaration already carries its owner in the
`within:` segment.

**Twenty-two patterns were a Spring/JAX-RS overlay in a language Pack.** Eight
`java.pkg_*` and `java.annotated_*` families rooted at `(program
(package_declaration ...) (class_declaration (modifiers (annotation ...))))`,
matching once per (package, class, annotation, argument) tuple in the file, plus
three `#eq?`-bound patterns
(`package_annotated_field_import_bound_type_context`,
`package_constructor_parameter_import_bound_type_context`,
`package_interface_import_bound_generic_supertype_context`) that pair an
annotated field or constructor parameter with the import that proves its type --
the constructor-injection and repository-supertype shapes of Spring, spelled as
a tree shape so no literal would give them away. Each sat under a comment
asserting "Framework-neutral", "No DI/container/framework semantics are inferred
here", "No Spring/JPA/repository semantics are inferred here". That is defect L,
and `frameworks/omega-framework-spring-boot` already exists for it. The twenty
`data.java_annotation_argument_value` and `java.annotation_value.*` templates
under them stored annotation argument strings as `data.*` mentions, which is the
same overlay without the pairing.

**Four families had the wrong family word.** `definitions.definition_interface`
and `definitions.definition_record` landed in Value (fixed by the host's
whole-word matching plus the Type vocabulary, but the kinds still had to say
`interface` and `record`, which they now do). `definitions.definition_constructor`
and `definitions.definition_compact_constructor` landed in Type, because
`con`**`struct`**`or` contains `struct`; that was defect B and is fixed in
`content_builder.rs`, so `definition.constructor` is now a Callable.

**The `tests` capability answered nothing.** Four templates: `(annotation)
@test.annotation` and `(marker_annotation) @test.marker_annotation` declared
*every* annotation in every file a test, and `tests.test_method` named a test
with the whole method. None carried a `test_signal` (the manifest declares no
`[test_capability]`), so `is_definition_kind` sent all four to the mention
branch and they became plain references. Recognising `@Test` is JUnit, which is
a framework; the capability is gone from the manifest.

**Forty-eight of 54 guards were duplicates or labels.** Seven gave a single
token as the reason -- `terminal_static_ceiling__java_dynamic_dispatch_resolution`,
`depth_completion_high_confidence_ast_fact` -- a generator confidence tier, not
something a reader can act on (defect G). The rest repeated the same handful of
sentences once per template family.

Not present, and worth recording as checked: no constant attributes (F = 0), no
constant names (J = 0), no `#lua-match?`-style operators (H = 0), no `(_)`
universal capture, no byte-identical duplicate templates, and every template's
captures were bound by some single pattern (M = 0).

## What it should extract

Java files are classes, interfaces, enums, records, annotation interfaces and
module declarations. The questions asked of them are *where is this name
declared*, *what shape does it have*, *what does this type extend or implement*,
*what does this file import*, and *who calls or mentions this name*.

| what | node | emitted as | family |
|---|---|---|---|
| a class | `class_declaration` via `name:` | `definition.class` | Type |
| an interface | `interface_declaration` via `name:` | `definition.interface` | Type |
| an enum | `enum_declaration` via `name:` | `definition.enum` | Type |
| a record | `record_declaration` via `name:` | `definition.record` | Type |
| an annotation interface | `annotation_type_declaration` via `name:` | `definition.annotation_interface` | Type |
| a type variable | `type_parameter` via its `type_identifier` | `definition.type_parameter` | Type |
| a method | `method_declaration` via `name:` | `definition.method` | Callable |
| a constructor | `constructor_declaration` via `name:` | `definition.constructor` | Callable |
| a compact constructor | `compact_constructor_declaration` via `name:` | `definition.compact_constructor` | Callable |
| an `@interface` member | `annotation_type_element_declaration` via `name:` | `definition.annotation_element_method` | Callable |
| a field | `field_declaration` via `declarator: (variable_declarator name:)` | `definition.field` | Value |
| an interface constant | `constant_declaration` via its declarator | `definition.constant` | Value |
| an enum constant | `enum_constant` via `name:` | `definition.enumerator` | Value |
| a parameter | `formal_parameter`, `spread_parameter` | `definition.parameter` | Value |
| a local, resource, caught or pattern binding | `local_variable_declaration`, `resource`, `catch_formal_parameter`, `enhanced_for_statement`, `instanceof_expression`, `type_pattern`, `record_pattern_component` | `definition.variable` | Value |
| a package | `package_declaration` | `definition.package` | Namespace |
| a module | `module_declaration` via `name:` | `definition.module` | Namespace |
| modifiers and written annotations | `modifiers` | `definition.modifier_candidate` | attribute on the declaration |
| the type parameter list | `type_parameters` | `definition.type_parameter_shape_candidate` | attribute |
| the parameter list, and a record header | `formal_parameters` | `definition.parameter_shape_candidate` | attribute |
| a method's declared return type | `method_declaration type:` | `definition.return_type_candidate` | attribute |
| the declared type of a value | `type:` of a field, local, parameter, resource, catch | `definition.declared_type_candidate` | attribute |
| a type body's extent | `class_body`, `interface_body`, `enum_body`, `annotation_type_body` | `scope.class_body` | region |
| a callable body's extent | `block`, `constructor_body` | `scope.function_body` | region |
| a module body's extent | `module_body` | `scope.module_body` | region |
| `extends`, `implements`, `provides ... with` | `superclass`, `super_interfaces`, `extends_interfaces`, `provides_module_directive` | `relation.implements` | implements |
| any type mention | `type_identifier` | `reference.type` | reference |
| an annotation use | `annotation`, `marker_annotation` via `name:` | `reference.annotation` | reference |
| a field read or write | `field_access` via `field:` | `reference.field` | reference |
| a service a module uses | `uses_module_directive type:` | `reference.service_type` | reference |
| a call | `method_invocation` via `name:` | `call.method` | call |
| a construction | `object_creation_expression` via `type:` | `call.constructor` | call |
| a method reference | `method_reference` via its trailing `identifier` | `call.method_reference` | call |
| a single-type import | `import_declaration` via `scoped_identifier name:` | `import.binding` | binding |
| an on-demand import | `import_declaration` with `asterisk` | `import.package` | binding |
| `requires`, `exports`, `opens` | the three module directives | `import.requires`, `export.package`, `export.opens` | binding |
| statements, expressions, literals, comments | -- | nothing | -- |

Two structural decisions carry the design:

**One capture namespace, several templates per pattern.** Every declaration
pattern binds `@decl.span` (the declaration), `@decl.name`, and whichever of
`@decl.modifiers`, `@decl.type_parameters`, `@decl.parameters`,
`@decl.return_type`, `@decl.declared_type`, `@decl.declaration_body`,
`@decl.function_body` that construct has. A per-construct name capture
(`@class.name`, `@method.name`, ...) selects which declaration template runs,
and the skip rule drops the rest. So the five carriers and the two region
templates are written once and serve twenty-two patterns, instead of the 48
containment patterns the old Pack spelled out.

**A declaration's span is the declaration, not its container.** For a field or
a local that means the `variable_declarator`, so `int a, b;` is two
declarations and each carrier folds onto its own. That closes the 31 carriers
the old Pack wrote onto an enclosing class.

## Still to decide

1. **Annotation element values.** `@Column(name = "order_id")` states a fact an
   agent wants, and `element_value_pair` is untouched. But reading it usefully
   means knowing what the annotation means, and that is the Spring/JPA overlay
   this rewrite removed. Left out; if it comes back it belongs in
   `frameworks/`, keyed on the annotation's fully qualified name, not here.
2. **`reference.field` on every `field_access`.** `System.out.println(x)` emits
   a reference to a field named `out`. It answers "where is this field read",
   but it is the highest-volume mention this Pack makes after `reference.type`.
   Kept for now; the first thing to measure against a real index.
3. **Lambdas as regions.** A `lambda_expression` body is a real scope, but it
   has no name to carry, and a region named with its own text is exactly the
   defect this rewrite removed. Left out.
4. **`Foo::new`.** The grammar gives the constructor reference no `identifier`
   to name, so it is left to the `type_identifier` mention rather than emitted
   as a `call.constructor` named `Foo`, which would say a construction happened
   where only a reference to one was taken.
