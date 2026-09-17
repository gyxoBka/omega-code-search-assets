# omega-c-sharp

Language `omega-c-sharp`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

41 templates over 45 query patterns.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 4 |
| `data` | yes | 3 |
| `definitions` | yes | 25 |
| `imports` | yes | 3 |
| `references` | yes | 6 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.namespace` | Namespace | 1 |
| `definition.class` | Type | 1 |
| `definition.struct` | Type | 1 |
| `definition.record` | Type | 1 |
| `definition.interface` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.delegate_type` | Type | 1 |
| `definition.type_parameter` | Type | 1 |
| `definition.method` | Callable | 1 |
| `definition.constructor` | Callable | 1 |
| `definition.destructor` | Callable | 1 |
| `definition.local_function` | Callable | 1 |
| `definition.operator_method` | Callable | 1 |
| `definition.conversion_method` | Callable | 1 |
| `definition.property` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.event` | Value | 2 |
| `definition.constant` | Value | 1 |
| `definition.indexer` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.visibility_candidate` | `omega.pack.visibility` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 1 |

### Regions

None. Every C# construct with an extent is a declaration, and a declaration
already carries its own defining region and its container through `within:`.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `reference.type` | reference | 4 |
| `reference.attribute` | reference | 1 |
| `call.method` | call | 4 |
| `import.namespace` | binding | 2 |
| `import.extern_alias` | binding | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal.

- `literal.value` (1) -- boolean, integer, real, character
- `literal.string` (1) -- plain, verbatim, raw
- `literal.null` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 224 node types. The Pack reaches 74 of them: 48 written out
in `queries.scm`, and 26 more reached through the two wildcard patterns
`(_ type: ...)`, which pick up every declaring position the grammar gives a
`type:` field -- a parameter, a cast, a `typeof`, a `catch`, a pattern, a
generic constraint, and through `array_type` and `nullable_type` the element
type inside them.

Untouched:

- `accessor_declaration`
- `accessor_list`
- `alias_qualified_name`
- `and_pattern`
- `anonymous_method_expression`
- `anonymous_object_creation_expression`
- `argument`
- `argument_list`
- `array_rank_specifier`
- `arrow_expression_clause`
- `as_expression`
- `assignment_expression`
- `attribute_argument`
- `attribute_argument_list`
- `attribute_list`
- `attribute_target_specifier`
- `await_expression`
- `binary_expression`
- `block`
- `bracketed_argument_list`
- `break_statement`
- `calling_convention`
- `catch_clause`
- `catch_filter_clause`
- `character_literal_content`
- `checked_expression`
- `checked_statement`
- `collection_element`
- `collection_expression`
- `comment`
- `compilation_unit`
- `conditional_expression`
- `constant_pattern`
- `constructor_constraint`
- `constructor_initializer`
- `continue_statement`
- `declaration`
- `declaration_list`
- `discard`
- `do_statement`
- `element_access_expression`
- `element_binding_expression`
- `empty_statement`
- `enum_member_declaration_list`
- `escape_sequence`
- `explicit_interface_specifier`
- `expression`
- `expression_element`
- `expression_statement`
- `finally_clause`
- `fixed_statement`
- `for_statement`
- `function_pointer_type`
- `global_attribute`
- `global_statement`
- `goto_statement`
- `group_clause`
- `if_statement`
- `implicit_array_creation_expression`
- `implicit_object_creation_expression`
- `implicit_parameter`
- `implicit_stackalloc_expression`
- `implicit_type`
- `initializer_expression`
- `interpolated_string_expression`
- `interpolation`
- `interpolation_alignment_clause`
- `interpolation_brace`
- `interpolation_format_clause`
- `interpolation_quote`
- `interpolation_start`
- `is_expression`
- `is_pattern_expression`
- `join_into_clause`
- `labeled_statement`
- `let_clause`
- `list_pattern`
- `literal`
- `local_declaration_statement`
- `lock_statement`
- `lvalue_expression`
- `makeref_expression`
- `negated_pattern`
- `non_lvalue_expression`
- `or_pattern`
- `order_by_clause`
- `parenthesized_expression`
- `parenthesized_pattern`
- `parenthesized_variable_designation`
- `pattern`
- `positional_pattern_clause`
- `postfix_unary_expression`
- `predefined_type`
- `prefix_unary_expression`
- `preproc_arg`
- `preproc_define`
- `preproc_elif`
- `preproc_else`
- `preproc_endregion`
- `preproc_error`
- `preproc_if`
- `preproc_if_in_attribute_list`
- `preproc_line`
- `preproc_nullable`
- `preproc_pragma`
- `preproc_region`
- `preproc_undef`
- `preproc_warning`
- `property_pattern_clause`
- `query_expression`
- `range_expression`
- `raw_string_content`
- `raw_string_end`
- `raw_string_start`
- `ref_expression`
- `reftype_expression`
- `relational_pattern`
- `return_statement`
- `select_clause`
- `shebang_directive`
- `spread_element`
- `statement`
- `string_content`
- `string_literal_content`
- `string_literal_encoding`
- `subpattern`
- `switch_body`
- `switch_expression`
- `switch_expression_arm`
- `switch_section`
- `switch_statement`
- `throw_expression`
- `throw_statement`
- `try_statement`
- `tuple_expression`
- `tuple_pattern`
- `tuple_type`
- `type`
- `type_declaration`
- `type_parameter_constraints_clause`
- `unary_expression`
- `unsafe_statement`
- `using_statement`
- `var_pattern`
- `when_clause`
- `where_clause`
- `while_statement`
- `with_expression`
- `with_initializer`
- `yield_statement`
## What is wrong with it

This section describes the Pack as it was found: 101 templates over 118 query
patterns, nine declared capabilities, 48 coverage guards.

**Fifty-nine of 101 templates carried the generator's batch number.** (Defect F.)
`source` appeared on 59 templates with values like
`framework-neutral-csharp-global-member-and-typeof-v3.146` and
`depth-completion-d1-v2.9`. Alongside it, `semantics` on 18, `symbol_category`
on 14, `role` on 11, and one each of `identity_semantics`, `owner_semantics`,
`path_semantics`, `scope_semantics`, `chain_semantics`, `member_category`, plus
`ownership` (2), `hint_semantics` (3), `signature_component` (3),
`target_semantics` (2) and `source_only` (2). Attributes are evaluated and
stored per emission, so 117 constant attribute bindings across the Pack wrote a
fixed string into the index once per matched construct. None of them answered a
question; every one restated the `output_kind` the template already declared,
or the version of the script that wrote it. All deleted.

**Twenty-four templates said the same thing twice or three times.** The Pack
carried four generations of itself at once. A class declaration was emitted as
`definition.class`, again as `definition.c-sharp_class`, again as
`definition.category_candidate`, again as `definition.identity_candidate`, and
again as `type.c_sharp_declaration_candidate`. A method: `definition.method`
(x3), `definition.c-sharp_method`, `definition.csharp_lifecycle_method_context`,
`definition.csharp_attributed_method_context`,
`definition.csharp_attributed_method_route_context`. A namespace:
`definition.module`, `definition.c-sharp_module`, `module.c_sharp_candidate`,
`module.declaration_path_candidate`, `module_relation.c-sharp_module`. Five
pairs of templates were literal duplicates of each other -- same capability,
kind, span capture and name expression -- because two imported `locals`
baselines and a `static_delta` block were concatenated without being reconciled.

**Twenty-one of 101 templates were framework semantics, which a language Pack
may not encode** (`00-CONTRACT.md` section 6).
`call.csharp_minimal_api_route_context` matches `app.MapGet("/path", handler)`.
`call.csharp_service_registration_generic_context` matches
`builder.Services.AddScoped<IService, Service>()`.
`definition.csharp_attributed_property_adjacent_named_sibling_context` matches
an attributed property whose string argument `#eq?`s the name of the property
written immediately after it -- an Entity Framework navigation-property rule
spelled as a tree shape. These are ASP.NET Core and EF Core facts. They belong
in `frameworks/`, where `omega-framework-asp-net-core` and
`omega-framework-entity-framework-core` already are.

**Nine patterns stated containment, at up to nine edges of depth.** (Defect E.)
`class_declaration > declaration_list > method_declaration > block >
expression_statement > invocation_expression > member_access_expression >
argument_list > argument > string_literal > string_literal_content` is one
pattern, written out three times with small variations. Each costs one match
per tuple of nodes at that depth. `csharp_class_property_context` and
`csharp_lifecycle_method_context` state nothing except that a property or a
method is inside a class -- which the tree, and the `within:` segment of the
declaration's own name, already say.

**The catch-all identifier pattern.** `(identifier) @local.reference` fed three
templates (`reference.local` x2, `reference.c-sharp_identifier_candidate`), so
every identifier token in every C# file -- parameter names, local variables,
the receiver of every member access, the left side of every assignment --
became a mention resolving against nothing. `(block) @local.scope` fed three
more (`scope.lexical` x2, `scope.c-sharp_lexical_scope`): one region per block.

**Eight `binding.*` templates produced references, not bindings.**
`binding.local`, `binding.var`, `binding.variable`, `binding.parameter`,
`binding.variable.parameter`, `binding.c-sharp_parameter`,
`binding.c-sharp_variable`, `binding.parameter_owned_candidate`. None of those
kinds is a declaration kind by `is_definition_kind`, so every local variable
and every parameter arrived as a plain reference occurrence named `x` or
`sender`. Eight templates, one useless occurrence kind.

**Kinds in the wrong family.** (Defect A, Defect B.) `definition.c-sharp_symbol`,
`definition.event`, `definition.field` were Value, which is right;
`definition.module` (x2) and `definition.c-sharp_module` were Value for a
namespace, which is not. `definition.csharp_class_base_context` and
`definition.csharp_class_property_context` were routed to **Type** because the
word `class` appears in the kind, although the first names a base-list entry
and the second a property. `definition.csharp_attributed_method_route_context`
was a Callable named after a route string. `definition.interface` (x2) and
`definition.c-sharp_interface` were Value; the host's Type vocabulary now
contains `interface`, so that pair is fixed in the host rather than here.

**Two `relation.*` kinds, neither of them a relation the host knows.**
`relation.inherits_or_implements_candidate` -- which is also a carrier, declared
under capability `imports`, so it folded a base type into an
`omega.pack.inherits_or_implements` attribute instead of producing an edge --
and `module_relation.c-sharp_module`, declared under capability `calls`, which
arrived as a plain reference. C# inheritance, the most useful relation the
language has, produced no `implements` occurrence at all.

**Five templates named an emission with a container node.** (Defect D.)
`type.c_sharp_declaration_candidate` took its name from
`(class_declaration) @type.expression` -- the whole class, body included,
stored as a name, once per type declaration in the corpus.
`import.using_directive` was named from the whole `using_directive`,
`reference.csharp_attributed_class_string_context` from the class declaration,
and `definition.member_owned_candidate` and `binding.parameter_owned_candidate`
from the owner span.

**Forty-eight coverage guards, most of them labels.** (Defect G.) Two were a
single token (`depth_completion_high_confidence_ast_fact`,
`c-sharp_upstream_tags_are_syntax_candidates_only`); eleven more were
underscore-joined sentences of the same kind, such as
`category_is_syntactic_from_ast_node_kind; namespace_visibility_signature_and_resolution_require_view_resolver_evidence`.
The rest are variations on "resolution requires the resolver", repeated once
per template family. Forty-eight guards for 101 templates say nothing a query
can act on.

**The boundary.** (Defect C.) 64 of 224 node types. `record_declaration` and
`struct_declaration` were matched only to feed the category carrier, so a
record and a struct had no declaration of their own at all.
`indexer_declaration`, `operator_declaration`,
`conversion_operator_declaration`, `type_parameter`, `attribute` as a
reference, `object_creation_expression`, `typeof_expression`,
`cast_expression`, `catch_declaration`, `declaration_pattern`, `type_pattern`,
`array_type`, `nullable_type`, `type_argument_list`,
`member_binding_expression`, `extern_alias_directive` and
`primary_constructor_base_type` were untouched, and `enum_member_declaration`
only fed a carrier. A C# codebase is mostly generics, and `List<Order>` named
`Order` nowhere.

**One import target was simply wrong.** `(using_directive name: (_) @import.target)`
reads the `name:` field, which in this grammar is the *alias* of
`using Json = System.Text.Json;`, not the namespace. Plain `using System;` has
no `name:` field at all, so the most common statement in C# matched that
pattern not once.

## What it should extract

C# files are application and library source: a compilation unit holds a
namespace, the namespace holds types, and the types hold members. The questions
asked of them are *what does this file declare*, *what is this member's
signature and visibility*, *what does this type inherit or implement*, *where
is this type used*, *what calls this*, and *what does this file import*.

| what | node | emitted as | family |
|---|---|---|---|
| a namespace | `namespace_declaration`, `file_scoped_namespace_declaration` | `definition.namespace` | Namespace |
| a class | `class_declaration` | `definition.class` | Type |
| a struct | `struct_declaration` | `definition.struct` | Type |
| a record | `record_declaration` | `definition.record` | Type |
| an interface | `interface_declaration` | `definition.interface` | Type |
| an enum | `enum_declaration` | `definition.enum` | Type |
| a delegate | `delegate_declaration` | `definition.delegate_type` | Type |
| a generic parameter | `type_parameter` | `definition.type_parameter` | Type |
| a method | `method_declaration` | `definition.method` | Callable |
| a constructor | `constructor_declaration` | `definition.constructor` | Callable |
| a finalizer | `destructor_declaration` | `definition.destructor` | Callable |
| a local function | `local_function_statement` | `definition.local_function` | Callable |
| an operator | `operator_declaration` via `operator:` | `definition.operator_method` | Callable |
| a conversion | `conversion_operator_declaration` via `type:` | `definition.conversion_method` | Callable |
| a property | `property_declaration` | `definition.property` | Value |
| an indexer | `indexer_declaration`, named `this` | `definition.indexer` | Value |
| a field | `field_declaration` via `variable_declarator` | `definition.field` | Value |
| an event | `event_declaration`, `event_field_declaration` | `definition.event` | Value |
| an enum member | `enum_member_declaration` | `definition.constant` | Value |
| `public`, `static`, `partial`, `async`, `const` | `modifier` | `visibility_candidate` carrier | attribute |
| a return type | `returns:` / `type:` on a callable | `return_type_candidate` carrier | attribute |
| a parameter list | `parameter_list`, `bracketed_parameter_list` | `parameter_shape_candidate` carrier | attribute |
| a type parameter list | `type_parameter_list` | `type_parameter_shape_candidate` carrier | attribute |
| a member's own type | `type:` on a property, field, event, indexer | `declared_type_candidate` carrier | attribute |
| a base class or interface | `base_list`, `primary_constructor_base_type` | `relation.implements` | implements |
| a type named anywhere | any node with a `type:` field, plus `returns:` and `type_argument_list` | `reference.type` | reference |
| an attribute usage | `attribute` via `name:` | `reference.attribute` | reference |
| a call | `invocation_expression`, all four receiver shapes | `call.method`, with `receiver_hint` / `qualifier` | call |
| a using directive | `using_directive` | `import.namespace` | binding |
| an extern alias | `extern_alias_directive` | `import.extern_alias` | binding |
| a literal | `boolean`/`integer`/`real`/`character`/`string`/`verbatim`/`raw`/`null_literal` | `literal.value`, `literal.string`, `literal.null` | dropped; span marker |
| a local variable, a parameter | -- | nothing | -- |
| a block, a lambda body, a statement | -- | nothing | -- |

Three things are deliberately not stated.

**No scopes.** Every C# construct that has an extent -- a type, a method, a
property, a namespace -- is a declaration, and a declaration already gets a
defining region over its own span and its container through the `within:`
segment. `scope.lexical` over every `(block)` added a region per block and
answered nothing the declaration did not.

**No local variables or parameters.** A parameter's contribution to a question
is the method's signature, and that is carried on the method as
`omega.pack.parameter_shape`. A local variable is visible in one body; nothing
outside that body can ask about it, and `binding.local` is not a declaration
kind anyway, so the old Pack turned each one into a reference to nothing. The
types they name are still stated, because `(_ type: ...)` reaches the declaring
position without emitting the binding.

**No framework semantics.** Routes, DI registrations, EF navigation properties
and `[Fact]` / `[Test]` test detection are overlays, not syntax. What the Pack
states instead is the `attribute` usage itself -- `reference.attribute` named
`Route`, `HttpGet`, `Fact` -- which is the fact a framework overlay needs and
the only part of it that is C#.

## Still to decide

1. **A member access that is not a call.** `options.Value`, `Colors.Red`,
   `this._lines` are references to fields, properties and enum members, and
   "where is this property read" is a real question. They are left out: the
   name would resolve against every member of that name in the repository, and
   emitting one per member access roughly doubles the mention count of a C#
   corpus for an answer that is mostly noise. Revisit once the resolver can
   narrow a member by its receiver's declared type -- `receiver_hint` is
   already carried on every call for exactly that.
2. **`relation.implements` for a base class.** C# writes `class A : B, IC` with
   no syntactic difference between the base class and the interfaces, so both
   are stated as `implements`. `relation.depends` would be wrong for the
   interfaces, and a separate `extends` is not one of the six relations the
   host knows. Left as `implements` for every base-list entry, and said so in a
   guard.
3. **`#region` and `#if`.** `preproc_region content:` names a section of a file
   and `preproc_if` hides declarations from the parse. Neither is emitted: a
   region is a comment with a name, and an excluded branch is a limitation,
   which is what it got -- a coverage guard.
