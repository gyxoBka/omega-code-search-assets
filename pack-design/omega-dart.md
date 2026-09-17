# omega-dart

Language `omega-dart`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

36 templates over 35 query patterns, 34 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 3 |
| `definitions` | yes | 25 |
| `imports` | yes | 3 |
| `references` | yes | 5 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.mixin` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.extension_type` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.constructor` | Callable | 1 |
| `definition.getter_method` | Callable | 1 |
| `definition.setter_method` | Callable | 1 |
| `definition.operator_method` | Callable | 1 |
| `definition.library_namespace` | Namespace | 1 |
| `definition.constant` | Value | 1 |
| `definition.extension` | Value | 1 |
| `definition.variable` | Value | 2 |
| `definition.import_prefix` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates | what it carries |
|---|---|---|---|
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 | `abstract`, `base`, `sealed`, `interface`, `mixin` before `class` |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 4 | the parameter list as written |
| `definition.return_type_candidate` | `omega.pack.return_type` | 2 | the declared return type |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 2 | `<T extends Foo>` as written |

### Regions

None. Every Dart declaration is already nested inside the one that contains it,
and the host carries that through the `within:` namespace segment. A region per
class body or function body would restate the tree.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `relation.depends` | depends | 2 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.constructor` | call | 1 |
| `import.library` | binding | 1 |
| `import.symbol` | binding | 1 |
| `export.library` | binding | 1 |
| `reference.type` | reference | 1 |
| `reference.annotation` | reference | 1 |

### Coverage guards

Five, one for each thing the Pack genuinely cannot see: local and parameter
binding, type identity under prefixes and aliases, receiver dispatch at a call
site, `show` / `hide` and conditional imports, and the `part` / `part of` split
of one library across files.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 221 node types. The Pack looks at 56 of them.

Untouched:

- `_literal`
- `_statement`
- `additive_expression`
- `additive_operator`
- `argument`
- `as_operator`
- `assert_builtin`
- `assert_statement`
- `assertion`
- `assertion_arguments`
- `assignable_expression`
- `assignment_expression`
- `assignment_expression_without_cascade`
- `await_expression`
- `binary_operator`
- `bitwise_and_expression`
- `bitwise_operator`
- `bitwise_or_expression`
- `bitwise_xor_expression`
- `block`
- `break_builtin`
- `break_statement`
- `case_builtin`
- `cast_pattern`
- `catch_clause`
- `catch_parameters`
- `class_body`
- `comment`
- `conditional_assignable_selector`
- `conditional_expression`
- `configuration_uri`
- `configuration_uri_condition`
- `const_builtin`
- `constant_pattern`
- `constructor_param`
- `constructor_tearoff`
- `continue_statement`
- `decimal_floating_point_literal`
- `decimal_integer_literal`
- `declaration`
- `do_statement`
- `documentation_comment`
- `dot_shorthand`
- `empty_statement`
- `enum_body`
- `equality_expression`
- `equality_operator`
- `escape_sequence`
- `expression_statement`
- `extension_body`
- `false`
- `field_initializer`
- `final_builtin`
- `finally_clause`
- `for_element`
- `for_loop_parts`
- `for_statement`
- `formal_parameter`
- `function_body`
- `function_expression`
- `function_expression_body`
- `hex_integer_literal`
- `identifier_dollar_escaped`
- `if_element`
- `if_null_expression`
- `if_statement`
- `import_or_export`
- `increment_operator`
- `index_selector`
- `inferred_type`
- `initialized_identifier_list`
- `initialized_variable_definition`
- `initializer_list_entry`
- `initializers`
- `is_operator`
- `label`
- `labeled_statement`
- `lambda_expression`
- `library_import`
- `list_literal`
- `list_pattern`
- `local_function_declaration`
- `local_variable_declaration`
- `logical_and_expression`
- `logical_and_operator`
- `logical_or_expression`
- `logical_or_operator`
- `map_pattern`
- `method_signature`
- `minus_operator`
- `mixin_application`
- `mixin_application_class`
- `multiplicative_expression`
- `multiplicative_operator`
- `named_argument`
- `named_parameter_types`
- `negation_operator`
- `normal_parameter_type`
- `null_assert_pattern`
- `null_check_pattern`
- `null_literal`
- `nullable_selector`
- `object_pattern`
- `optional_formal_parameters`
- `optional_parameter_types`
- `optional_positional_parameter_types`
- `pair`
- `parameter_type_list`
- `parenthesized_expression`
- `part_of_builtin`
- `pattern_assignment`
- `pattern_variable_declaration`
- `postfix_expression`
- `postfix_operator`
- `prefix_operator`
- `program`
- `qualified`
- `record_field`
- `record_literal`
- `record_pattern`
- `record_type_field`
- `record_type_named_field`
- `redirection`
- `relational_expression`
- `relational_operator`
- `rest_pattern`
- `rethrow_builtin`
- `rethrow_expression`
- `return_statement`
- `script_tag`
- `set_or_map_literal`
- `shift_expression`
- `shift_operator`
- `spread_element`
- `static_final_declaration_list`
- `super`
- `super_formal_parameter`
- `switch_block`
- `switch_expression`
- `switch_expression_case`
- `switch_statement`
- `switch_statement_case`
- `switch_statement_default`
- `symbol_literal`
- `template_substitution`
- `this`
- `throw_expression`
- `throw_expression_without_cascade`
- `tilde_operator`
- `true`
- `try_statement`
- `type_arguments`
- `type_bound`
- `type_cast`
- `type_cast_expression`
- `type_parameter`
- `type_test`
- `type_test_expression`
- `typed_identifier`
- `unary_expression`
- `uri_test`
- `variable_pattern`
- `while_statement`
- `yield_each_statement`
- `yield_statement`

Most of that list is expression and operator machinery -- `additive_expression`,
`shift_operator`, `null_check_pattern` -- which names nothing a question can be
asked about. Four groups in it are deliberate, not accidental:

- **Statement and block nodes** (`block`, `if_statement`, `for_statement`,
  `try_statement`, `function_body`). The old Pack captured all of them as
  `@local.scope` and named each one with its own text. They are regions, not
  names; see *Regions* above. They are not emitted as `control_flow.*` either:
  that family is kept in a Pack only because its spans suppress role emissions
  over the same bytes (AGENT-BRIEF section 10), and this Pack emits no role
  captures for them to suppress.
- **`formal_parameter`, `initialized_variable_definition`,
  `local_variable_declaration`, `for_loop_parts`.** Names that bind inside one
  body. They are stated as a shape on the callable, not as declarations of
  their own; the first coverage guard says so.
- **`documentation_comment`, `comment`.** A doc comment is a preceding sibling
  of the declaration, not its parent, so it cannot be carried onto the
  declaration's span, and emitting it on its own would store a paragraph as a
  name.
- **`type_parameter`, `type_arguments`, `type_bound`, `qualified`.** The type
  names inside them are `type_identifier` nodes, already emitted as
  `reference.type` by the one pattern that covers every type position.

The count moved from 58 to 56 while what the Pack extracts roughly doubled.
The number was never the measure: eleven of the old 58 were `block`,
`if_statement`, `for_statement`, `while_statement`, `try_statement`,
`catch_clause`, `finally_clause`, `function_body`, `function_expression_body`,
`class_body` and `identifier`, each captured only to be stored with its own
text as a name.

## What is wrong with it

The Pack that shipped had **61 templates over 67 query patterns**, seven
declared capabilities and **32 coverage guards**. It was seven generator passes
stacked on one file -- `external-helix-tags`, `p0-exact-helix-locals`,
`upstream_tags`, `locals`, `declaration_category_*`, `semantic-closure-v3.146`
and `widget_route_builder_context` -- and four of them extract the same
declarations again under different names.

**Every class was declared three times, and seven templates were written
twice.** `definition.class` appears as two byte-identical templates (span
`definition.class`, name `name`), and `definition.dart_class` is a third over
the same capture. The same holds for `definition.enum` / `definition.dart_enum`,
`definition.function` / `definition.dart_function` and `definition.type` /
`definition.dart_type`. Seven templates in the file are exact duplicates of
another template in the same file: `definition.class`, `definition.enum`,
`definition.function`, `definition.interface`, `definition.type`,
`reference.local` and `scope.lexical`. One Dart class produced five
declarations of itself plus a sixth as `type.dart_declaration_candidate`.

**Six templates named an emission with a whole node (Defect D).**
`type.dart_declaration_candidate` is named from `(class_definition)
@type.expression` -- the *entire class*, body and all, written into the index
as a name, once per class. `import.dart_candidate` is named from
`(import_specification) @import.expression`, the whole import statement.
`scope.lexical` (twice) and `scope.dart_lexical_scope` name a region with the
full text of a `block`, a `class_body`, an `if_statement` or a `try_statement`,
and `binding.parameter_owned_candidate` names a binding with a whole
`formal_parameter` node.

**Twenty-eight of 61 templates carried a constant attribute `source` (Defect
F).** The values are generator batch numbers:
`pack-canonical-key-inputs-v2.7`, `pack-ownership-v2.4`,
`pack-resolution-hints-v2.5`, `pack-resolution-paths-v2.6`,
`dart-generic-import-call-v3.146`, `dart-prefixed-member-call-v3.141`,
`dart-class-extends-v3.111`, `pack_completeness_v2_medium_reviewed`. Beside
them sit `semantics`, `role`, `symbol_category`, `chain_semantics`,
`hint_semantics`, `owner_semantics`, `ownership` and `reexport_semantics` --
restatements of the `output_kind` the template already declares. **64 constant
attribute writes across 28 templates**, each stored once per matched construct.
The new Pack has none: its only attributes are the four carriers, and each of
those carries text read from the declaration it describes.

**Seven patterns stated containment the tree already holds (Defect E).**
`(enum_declaration name: body: (enum_body (enum_constant name:)))`,
`(constructor_signature name: parameters: (formal_parameter_list
(formal_parameter)))` twice, and `(class_definition name: body:)` four times
over -- once as `enclosing_owner_hints`, once as `named_scope_owners`, once for
`extension_declaration`, once for `extension_type_declaration`. The
`upstream_tags` `reference.call` pattern is worse than containment: an
identifier followed by a **starred** group of optional selectors with `@name`
bound three times inside it plus an optional cascade section, so one call
expression matches once per combination of the optional parts.

**Not one `relation.*` kind the host knows was emitted.** Dart's one structural
relation -- `extends`, `implements`, `with`, `on` -- shipped as
`definition.dart_class_extends_context`, a kind containing `definition`, so
`class X extends Y` was filed as *a declaration of X, family Type*, with the
superclass hidden in a `fields` entry nothing resolves. No implements
occurrence was produced at all.

**Everything a question could reach was a reference to nothing.**
`(identifier) @local.reference` emitted `reference.local` for **every
identifier in every file**, twice, against a declaration set that did not
include fields, top-level variables, enum constants, getters, setters,
operators or constructors by name. Meanwhile `definition.dart_method` was
programmed from `(method_signature) @definition.method` -- a pattern that binds
no `@name` capture -- so the template was skipped on every match and **no Dart
method was ever declared**.

**Three patterns encoded a framework (contract section 6).**
`widget_route_builder_context` and `dart.member_route` hard-code a call with a
literal named string argument and an expression-bodied builder returning a
constructor. That is go_router and Flutter navigation spelled as syntax; the
header comment says "No Flutter/go_router semantics here", and the pattern is
the shape of `GoRoute(path: '...', builder: (c, s) => Page())` and nothing
else. Framework semantics belong in `frameworks/`.

**Thirty-two coverage guards for 61 templates, eight of them a label (Defect
G).** `dart_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`,
`category_is_syntactic_from_ast_node_kind`, `identity_candidate_is_syntactic`,
`named_scope_is_syntactic`, `qualified_chain_is_syntactic`,
`qualification_is_syntactic`, `reexport_is_syntactic`,
`dart_upstream_tags_are_syntax_candidates_only`. A reader can act on none of
them: they say the Pack states syntax, which is what a Pack is.

**Defect A, and what the host fix left.** The shipped kinds
`definition.interface` (2 templates) and `definition.dart_mixin` (1) filed a
Dart mixin as a Value. Both words are in the host's Type vocabulary since the
whole-word fix of 2026-09-17, so those kinds now route to Type -- but they were
reached only from `(mixin_declaration (identifier) @name)`, and
`definition.dart_extension` stayed in Value. Defect B does not occur here: no
Dart kind won its family inside a longer word.

**Boundary (Defect C).** 58 of 221 node types, 26%, third worst of the 61
Packs. What was missing was not exotic: constructors of every spelling, factory
constructors, getters, setters, operators, enum constants, fields, top-level
variables, `library`, `part`, `part of`, `export`, `show` / `hide`,
annotations, `implements`, `with`, `on`, and every type annotation in the file.

## What it should extract

Dart is the language of Flutter applications, CLI tools and pub packages. The
questions asked of a Dart file are: *what does this file declare*, *what does
this class extend or implement*, *what does this library import, export or
re-export*, *where is this type used*, and *who calls this member*.

| what | node | emitted as | family |
|---|---|---|---|
| a class | `class_definition` via `name` | `definition.class` | Type |
| `abstract` / `base` / `sealed` / `interface` / `mixin` on it | `abstract`, `base`, `sealed`, `interface`, `mixin` | `definition.modifier_candidate` on the class | attribute |
| its type parameters | `type_parameters` | `definition.type_parameter_shape_candidate` | attribute |
| a mixin | `mixin_declaration` via the first `identifier` | `definition.mixin` | Type |
| an enum | `enum_declaration` via `name` | `definition.enum` | Type |
| one of its values | `enum_constant` via `name` | `definition.constant` | Value |
| an extension type | `extension_type_declaration` via `name` | `definition.extension_type` | Type |
| its representation field | `representation_declaration` via `name` | `definition.variable` | Value |
| an extension | `extension_declaration` via `name` | `definition.extension` | Value* |
| a typedef | `type_alias` via `type_identifier` | `definition.type_alias` | Type |
| a function, a method or a local function | `function_signature` via `name` | `definition.function` | Callable |
| its parameter list and return type | `formal_parameter_list`, the return type node | `definition.parameter_shape_candidate`, `definition.return_type_candidate` | attributes |
| a getter | `getter_signature` via `name` | `definition.getter_method` | Callable |
| a setter | `setter_signature` via `name` | `definition.setter_method` | Callable |
| an operator | `operator_signature`, name read from its own text | `definition.operator_method` | Callable |
| a constructor: plain, `const`, `factory` or redirecting factory | `constructor_signature`, `constant_constructor_signature`, `factory_constructor_signature`, `redirecting_factory_constructor_signature`, name read from the text up to `(` | `definition.constructor` | Callable |
| a field or a top-level variable | `initialized_identifier`, `static_final_declaration`, `identifier_list` | `definition.variable` | Value |
| the library's own name | `library_name` via `dotted_identifier_list` | `definition.library_namespace` | Namespace |
| an import prefix | `import_specification` via `identifier` | `definition.import_prefix` | Value |
| `extends`, `with`, `implements`, `on` | `superclass`, `mixins`, `interfaces` via `type_identifier` | `relation.implements` | implements |
| an import | `import_specification` via `uri` / `configurable_uri` | `import.library` | binding |
| a `show` / `hide` name | `combinator` via `identifier` | `import.symbol` | binding |
| an export | `library_export` via `configurable_uri` | `export.library` | binding |
| `part` / `part of` | `part_directive`, `part_of_directive` | `relation.depends` | depends |
| any type position | `type_identifier` | `reference.type` | reference |
| an annotation | `annotation` via `name` | `reference.annotation` | reference |
| `f(...)` | `identifier` plus an anchored `selector` carrying `arguments` | `call.function` | call |
| `a.b(...)` and `..b(...)` | `unconditional_assignable_selector`, `cascade_selector` | `call.method` | call |
| `Foo(...)`, `new Foo(...)`, `const Foo(...)` | `new_expression`, `const_object_expression`, `constructor_invocation` via `type_identifier` | `call.constructor` | call |
| a parameter, a local variable, a loop variable | -- | nothing; a guard says so | -- |
| statements, blocks, operators, literals, comments | -- | nothing | -- |

\* an `extension` is not a type in Dart: it cannot be written as a type
annotation and has no values. `definition.extension` lands in Value, which is
what it is -- a named group of members attached to another type. An
`extension type`, which *is* a type, is declared as one.

Two node kinds are captured by more than one pattern on purpose. A supertype's
`type_identifier` is both a use of that type and an implements relation, and a
constructed type's `type_identifier` is both a use and a construction; the two
facts answer different questions, and the host is built to run several
templates over overlapping spans. That is two extra emissions per supertype
clause and per `new`, against one pattern that indexes every type position in
the file.

The operator and constructor names come out of the expression vocabulary rather
than out of a capture, because the grammar spells neither as a named node:
`operator ==` carries its `==` as an anonymous token, and a constructor's
`name` field is the *sequence* `Foo` `.` `of`, which a capture would bind
twice, once per identifier. Both are read from the signature's own text --
`last(split(..., "operator "))` then `first(split(..., "("))` for the operator,
and `first(split(strip_prefix(strip_prefix(trim(...), "const "), "factory "),
"("))` for all four constructor spellings at once.

## Still to decide

1. **Whether `(type_identifier)` should be one pattern or none.** It is the
   highest-volume pattern in the Pack: every type annotation, type argument,
   cast and `is` test in the file. It is also the only thing that answers
   "where is `Widget` used". Provisionally kept as one pattern; revisit against
   the row count on a real Flutter repository, and if it has to go, the
   fallback is the type positions that name an API boundary -- return types,
   field types, supertypes -- rather than all of them.
2. **Whether a class field should be told apart from a top-level variable.**
   Both are `definition.variable` and both land in Value. The tree already says
   which is which through `within:`, so a second kind would only be a second
   word for the same fact -- but a card that reads "field of `Foo`" reads
   better than one that reads "variable". Left as one kind.
3. **`show` and `hide` are the same kind.** Both name a symbol of the imported
   library, and the occurrence the host makes is a binding either way. Telling
   them apart needs two patterns keyed on the anonymous `show` / `hide`
   tokens; not worth two patterns until something asks.
4. **A doc comment is not extracted.** It is the best short description a Dart
   declaration has, and a retrieval card would be better for it, but it is a
   preceding sibling of the declaration, not its parent, so no carrier can
   reach the declaration's span. This is a general shape -- Rust, Java, Python,
   Go and TypeScript all attach documentation the same way -- and it is
   reported as a cross-Pack finding rather than worked around here.
