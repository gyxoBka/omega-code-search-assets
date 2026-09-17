# omega-razor

Language `omega-razor`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

58 templates over 46 query patterns, 44 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 44 |
| `imports` | yes | 2 |
| `references` | yes | 9 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.config_option` | Config | 1 |
| `definition.config_route` | Config | 1 |
| `definition.constant` | Value | 1 |
| `definition.constructor` | Callable | 1 |
| `definition.delegate_type` | Type | 1 |
| `definition.destructor` | Callable | 1 |
| `definition.enum` | Type | 1 |
| `definition.event` | Value | 2 |
| `definition.field` | Value | 1 |
| `definition.indexer` | Value | 1 |
| `definition.injected_service` | Value | 1 |
| `definition.interface` | Type | 1 |
| `definition.local` | Value | 2 |
| `definition.local_function` | Callable | 1 |
| `definition.method` | Callable | 1 |
| `definition.namespace` | Namespace | 1 |
| `definition.parameter` | Value | 1 |
| `definition.property` | Value | 1 |
| `definition.record` | Type | 1 |
| `definition.section` | Value | 1 |
| `definition.struct` | Type | 1 |
| `definition.type_alias` | Type | 2 |
| `definition.type_parameter` | Type | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 7 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 6 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 3 |

### Regions

- `scope.code_block` (1) -- the extent of one `@code` / `@{ }` island

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.constructor` | call | 1 |
| `call.method` | call | 1 |
| `import.using` | binding | 2 |
| `reference.attribute` | reference | 1 |
| `reference.attribute_value` | reference | 1 |
| `reference.member` | reference | 1 |
| `reference.type` | reference | 1 |
| `relation.config` | config | 1 |
| `relation.depends` | depends | 1 |
| `relation.implements` | implements | 3 |

Five coverage guards, one per real limitation: the generated class, component
tags in markup, unresolved call targets, `_Imports.razor`, and modifiers.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 262 node types. The Pack looks at 57 of them.

The untouched list is almost entirely C# expression, statement, pattern and
preprocessor forms -- `binary_expression`, `if_statement`, `switch_section`,
`preproc_pragma`, and the `razor_if` / `razor_while` / `razor_try` family. None
of them names anything. A question about an `if` is a question about the code
inside it, and that code is already declared, called or referenced by the
patterns above; a template rooted at `if_statement` would store the branch's
own text as a name, which is Defect D. The two families where the answer could
have gone the other way are `interpolated_string_expression` (whose
`interpolation` children hold member accesses the reference pattern already
sees) and `element` -- see the second coverage guard: an HTML or component tag
name is an anonymous token in this grammar.

Untouched:

- `accessor_declaration`
- `accessor_list`
- `and_pattern`
- `anonymous_method_expression`
- `anonymous_object_creation_expression`
- `argument`
- `argument_list`
- `array_creation_expression`
- `array_rank_specifier`
- `array_type`
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
- `bracketed_parameter_list`
- `break_statement`
- `calling_convention`
- `cast_expression`
- `catch_clause`
- `catch_declaration`
- `catch_filter_clause`
- `character_literal`
- `character_literal_content`
- `checked_expression`
- `checked_statement`
- `comment`
- `compilation_unit`
- `conditional_access_expression`
- `conditional_expression`
- `constant_pattern`
- `constructor_constraint`
- `constructor_initializer`
- `continue_statement`
- `conversion_operator_declaration`
- `declaration`
- `declaration_expression`
- `declaration_list`
- `declaration_pattern`
- `default_expression`
- `discard`
- `do_statement`
- `element`
- `element_access_expression`
- `element_binding_expression`
- `empty_statement`
- `enum_member_declaration_list`
- `escape_sequence`
- `explicit_interface_specifier`
- `explicit_line_transition`
- `expression`
- `expression_statement`
- `extern_alias_directive`
- `finally_clause`
- `fixed_statement`
- `for_statement`
- `from_clause`
- `function_pointer_parameter`
- `function_pointer_type`
- `global_attribute`
- `goto_statement`
- `group_clause`
- `html_comment`
- `if_statement`
- `implicit_array_creation_expression`
- `implicit_object_creation_expression`
- `implicit_parameter`
- `implicit_stackalloc_expression`
- `implicit_type`
- `initializer_expression`
- `integer_literal`
- `interpolated_string_expression`
- `interpolation`
- `interpolation_alignment_clause`
- `interpolation_brace`
- `interpolation_format_clause`
- `interpolation_quote`
- `interpolation_start`
- `is_expression`
- `is_pattern_expression`
- `join_clause`
- `join_into_clause`
- `labeled_statement`
- `lambda_expression`
- `let_clause`
- `list_pattern`
- `literal`
- `lock_statement`
- `lvalue_expression`
- `makeref_expression`
- `modifier`
- `negated_pattern`
- `non_lvalue_expression`
- `null_literal`
- `nullable_type`
- `operator_declaration`
- `or_pattern`
- `order_by_clause`
- `parameter_list`
- `parenthesized_expression`
- `parenthesized_pattern`
- `parenthesized_variable_designation`
- `pattern`
- `pointer_type`
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
- `preproc_line`
- `preproc_nullable`
- `preproc_pragma`
- `preproc_region`
- `preproc_undef`
- `preproc_warning`
- `primary_constructor_base_type`
- `property_pattern_clause`
- `query_expression`
- `range_expression`
- `raw_string_content`
- `raw_string_end`
- `raw_string_literal`
- `raw_string_start`
- `razor_attribute_directive`
- `razor_attribute_modifier`
- `razor_await_expression`
- `razor_case_condition`
- `razor_catch`
- `razor_comment`
- `razor_compound_using`
- `razor_condition`
- `razor_do_while`
- `razor_else`
- `razor_else_if`
- `razor_escape`
- `razor_explicit_expression`
- `razor_finally`
- `razor_for`
- `razor_if`
- `razor_implicit_expression`
- `razor_lock`
- `razor_switch`
- `razor_switch_case`
- `razor_switch_default`
- `razor_try`
- `razor_while`
- `real_literal`
- `recursive_pattern`
- `ref_expression`
- `ref_type`
- `reftype_expression`
- `refvalue_expression`
- `relational_pattern`
- `return_statement`
- `scoped_type`
- `select_clause`
- `shebang_directive`
- `sizeof_expression`
- `stackalloc_expression`
- `statement`
- `string_content`
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
- `tuple_element`
- `tuple_expression`
- `tuple_pattern`
- `tuple_type`
- `type_argument_list`
- `type_declaration`
- `type_parameter_constraint`
- `type_parameter_constraints_clause`
- `type_parameter_list`
- `type_pattern`
- `typeof_expression`
- `unary_expression`
- `unsafe_statement`
- `using_statement`
- `var_pattern`
- `verbatim_string_literal`
- `when_clause`
- `where_clause`
- `while_statement`
- `with_expression`
- `with_initializer`
- `yield_statement`

`razor_attribute_directive` is in that list on purpose: `@attribute [Authorize]`
holds an `attribute_list`, and the `(attribute name:)` pattern reaches the
attribute inside it wherever it is written, so a second pattern rooted at the
directive would state only containment.

## What is wrong with it

*This section describes the Pack as it was found, at version 1.0.0: 54 templates
over 91 query patterns.*

**One pattern matched every named node in the file.** The `structural-fallback`
block was literally `(_) @structural.node`, and no template referenced
`structural.node`. It produced nothing and cost one match per named node of
every Razor file in the corpus -- the single most expensive line in the Pack,
answering nothing. Its coverage guard said so out loud: "Universal named-node
capture provides syntax-aware indexing only."

**Almost nothing was declared.** Of 54 templates, exactly two produced a
declaration the host would keep: `definition.razor_section` and
`definition.razor_type_parameter`. Twenty more were carriers ending in
`_candidate`, and a carrier only attaches to a declaration that already exists
at the same span -- so `definition.category_candidate` (13 templates, one per C#
construct), `definition.identity_candidate`, `definition.modifier_candidate`,
`definition.return_type_candidate` and the rest had nothing to attach to. The
class, method, property, field, record, struct, interface and enum declarations
they described were emitted only as `definition.razor_declaration_candidate`,
itself a carrier. **Every C# construct in every `@code` block was a carrier
looking for a declaration the Pack never made.** Asking Omega for a method
declared in a Razor file returned nothing.

**Defect D, thirteen times.** Thirteen templates named an emission with a whole
container node. `definition.razor_declaration_candidate` and
`type.razor_declaration_candidate` were named from `(class_declaration)`,
`(method_declaration)`, `(namespace_declaration)` and five more -- the entire
body of the construct stored as its name. `call.razor_candidate` was named from
`(invocation_expression)`; `scope.lexical` from `(block)`, `(lambda_expression)`
and `(razor_block)`; `binding.symbol` from `(variable_declaration)`,
`(parameter)`, `(type_parameter)` and `(implicit_parameter)`;
`module.razor_candidate` from `(namespace_declaration)`;
`reference.razor_named_attribute_expression_context` from a whole lambda; and
`binding.razor_inject` from the whole `(variable_declaration)` of the directive.

**Defect F, on all 54 templates.** Every single template carried a constant
`source` attribute: `pack-canonical-key-inputs-v2.7` (17),
`semantic-closure-v3.146` (9), `semantic-closure-v3.146-batch3` (6),
`pack-ownership-v2.4` (5), `pack-resolution-hints-v2.5` (3),
`pack-resolution-paths-v2.6` (3), and eight others. Fourteen also carried
`semantics`, thirteen `symbol_category`, and there were single instances of
`target_semantics`, `hint_semantics`, `chain_semantics`, `path_semantics`,
`owner_semantics`, `scope_semantics`, `identity_semantics`, `member_category`,
`ownership`, `signature_component` and `semantic_role`. Excluding the five names
the host drops as carrier provenance, that is a fixed string written into the
index once per matched construct, answering nothing.

**Defect G, forty-seven times.** 47 coverage guards for 54 templates, and 33 of
them were a single underscored token or a clause of generator jargon:
`binding_nodes_are_syntactic_candidates_not_resolved_values`,
`razor_declarations_are_syntax_candidates_until_scope_and_name_resolution`,
`reference_candidates_target_identity_requires_view_resolver_evidence`,
`terminal_static_ceiling__CSharp_expressions_interpolation_components_and_runtime_navigation_calls_remain`.
Four separate guards said the same thing about calls. None named a limitation
of Razor.

**Two `relation.*` kinds the host does not know.** `type_relation.razor_inherits`
and `type_relation.razor_implements` do not start with `relation.` at all, so
they were never examined: both arrived as plain references. `@inherits` and
`@implements` are exactly the `relation.implements` the host does recognise, and
the Pack spelled them so that nothing could read them.

**An import whose name was a constant.** `import.razor_using` was named
`{"kind": "literal", "value": "razor_using"}`. Every `@using` in the corpus was
a binding occurrence named `razor_using`. The namespace it imported was stored
only by a second template, `import.razor_using_target`.

**Sixteen patterns asked for the same node separately.** `class_declaration` was
the root of four patterns (`completeness_definitions`,
`declaration_category_class`, `declaration_modifiers`, `enclosing_owner_hints`);
`method_declaration` of six; `constructor_declaration` of four;
`local_function_statement` of five. Each was a separate match for a fact one
match could have carried -- and each `declaration_modifiers` pattern silently
required a `(modifier)` child, so it matched only the declarations that had one.

**A predicate that does nothing.** The `literal_href_context` pattern was
guarded by `(#eq? @razor.href.attribute_name "href")`. The runtime never
evaluates query predicates (see *A defect in the host*), so the pattern matched
**every** `razor_html_attribute` whose value was a string literal, and stored
the string as a navigation reference. The guard beside it claimed
`plain_literal_href_only`.

**Defects A and B did not arise, because nothing was a declaration.** The only
two real declaration kinds were `definition.razor_section` (Value, correct) and
`definition.razor_type_parameter` (Type, correct). The 13 `symbol_category`
values -- `class`, `interface`, `record`, `struct`, `enum`, `method`,
`constructor`, `destructor`, `property`, `event`, `function`, `namespace`,
`model` -- were attribute strings on carriers, so `entity_family` never saw them.

## What it should extract

A Razor file is one compilation unit made of three languages: HTML markup, C# in
`@code` / `@{ }` islands, and the Razor directives that say what the generated
class is. The questions asked of one are: *what route does this file serve*,
*what does it inherit or implement*, *what does it inject and import*, *what C#
does it declare*, and *what does that C# call*.

| what | node | emitted as | family |
|---|---|---|---|
| `@page "/counter"` | `razor_page_directive` via `string_literal_content` | `definition.config_route` | Config |
| `@namespace Foo.Bar` | `razor_namespace_directive` via `qualified_name` | `definition.namespace` | Namespace |
| `@layout MainLayout` | `razor_layout_directive` | `relation.depends` | depends |
| `@inherits Base` | `razor_inherits_directive` | `relation.implements` | implements |
| `@implements IFoo` | `razor_implements_directive` | `relation.implements` | implements |
| `@model Customer` | `razor_model_directive` | `reference.type` | reference |
| `@typeparam TItem` | `razor_typeparam_directive` | `definition.type_parameter` | Type |
| `@rendermode X` | `razor_rendermode_directive` via `razor_rendermode` | `relation.config` | config |
| `@preservewhitespace b` | `razor_preservewhitespace_directive` | `definition.config_option` with a `value` attribute | Config |
| `@section Scripts { }` | `razor_section` via `identifier` | `definition.section` | Value |
| `@inject IFoo Bar` | `razor_inject_directive` via `variable_declarator` | `definition.injected_service` + `declared_type` carrier | Value |
| `@using Ns` | `razor_using_directive` via `type` | `import.using` | binding |
| `@using A = Ns.B` | `razor_using_directive` via `name:` | `definition.type_alias` | Type |
| `using Ns;` in a code island | `using_directive` | the same two | |
| a class, interface, struct, record, enum | `*_declaration` via `name:` | `definition.class` … `definition.enum` | Type |
| a delegate | `delegate_declaration` | `definition.delegate_type` + return and parameter carriers | Type |
| a generic parameter | `type_parameter` | `definition.type_parameter` | Type |
| a namespace, block or file-scoped | `namespace_declaration`, `file_scoped_namespace_declaration` | `definition.namespace` | Namespace |
| a method | `method_declaration` | `definition.method` + `return_type` + `parameter_shape` | Callable |
| a local function | `local_function_statement` | `definition.local_function` + both carriers | Callable |
| a constructor, a destructor | `constructor_declaration`, `destructor_declaration` | `definition.constructor`, `definition.destructor` + `parameter_shape` | Callable |
| a property | `property_declaration` | `definition.property` + `declared_type` | Value |
| an event | `event_declaration`, `event_field_declaration` | `definition.event` + `declared_type` | Value |
| an indexer | `indexer_declaration` | `definition.indexer`, named `this[]`, + both carriers | Value |
| an enum member | `enum_member_declaration` | `definition.constant` | Value |
| a parameter | `parameter` via `name:` | `definition.parameter` | Value |
| a field | `field_declaration` via `variable_declarator` | `definition.field` + `declared_type` | Value |
| a local | `local_declaration_statement` via `variable_declarator` | `definition.local` + `declared_type` | Value |
| a loop variable | `razor_foreach`, `foreach_statement` `left:` | `definition.local` | Value |
| a base type or interface | `base_list` | `relation.implements` | implements |
| `[Authorize]` | `attribute` via `name:` | `reference.attribute` | reference |
| a call | `invocation_expression`, the leaf of `function:` | `call.method` | call |
| `new Foo()` | `object_creation_expression` `type:` | `call.constructor` | call |
| `Model.Name`, `x?.Y` | `member_access_expression`, `member_binding_expression` `name:` | `reference.member` | reference |
| `@onclick="Increment"` | `razor_html_attribute` with a bare `identifier` value | `reference.attribute_value` | reference |
| the code island's extent | `razor_block` | `scope.code_block` | region |
| statements, expressions, patterns, preproc | — | nothing | — |

Three things follow from that table.

**A name is always a name.** Every declaration is named from an `identifier`,
and every qualified mention from the last dot-segment with generic arguments
dropped, so `@inherits ComponentBase<TItem>` is stored as `ComponentBase` and
resolves against the class of that name. No template names an emission with a
container node.

**A construct and its signature come out of one match.** `(method_declaration
returns: … name: … parameters: …)` feeds three templates: the declaration, the
return-type carrier and the parameter-shape carrier. That is 46 patterns where
the old Pack had 91, and 15 kinds of C# declaration that are declarations
instead of nothing.

**Containment is stated once, as a region, and only where it means something.**
A Razor file's one genuinely structural fact is where the code island is, and
`scope.code_block` says it. The `enclosing_owner`, `named_owner` and
`ownership_*` families of the old Pack are gone; `within:` already carries them.

## Still to decide

1. `reference.member` fires on every `member_access_expression`, including the
   one in the function position of an invocation, so `@item.GetName()` yields
   both a call named `GetName` and a member reference named `GetName` over a
   shorter span. Suppressing one needs a predicate the runtime does not
   evaluate. Kept, because property access is most of what Razor markup is
   (`@item.Title`), and losing it to save a duplicate on calls is the worse
   trade. Revisit against the occurrence count.
2. `definition.parameter` declares every parameter of every callable, so a
   `@code` block with ten methods declares perhaps twenty Value entities that no
   cross-file question reaches. They are what a reference inside the body
   resolves against, so they stay; if the row count says otherwise they are the
   first thing to drop.
3. `definition.indexer` is named by the literal `this[]`, the only name C# gives
   an indexer. That is a constant, close to what Defect F forbids in an
   attribute -- but it is the construct's actual name, not a batch number.

## A defect in the host

**Query predicates are parsed and then ignored.**
`crates/omega-ingest/src/pack/runtime.rs` reads
`query.property_settings(pattern_index)` for injections and never touches
`general_predicates` or the text predicates; nothing in `crates/` evaluates
`#eq?` or `#match?`. A pattern written as

```
((razor_html_attribute (razor_attribute_name) @n …) (#eq? @n "href"))
```

therefore matches every `razor_html_attribute`, and the Pack silently states the
opposite of what it reads as saying. This is not omega-razor's problem alone:
any Pack that filters with a predicate is over-emitting by exactly the amount
the predicate was meant to exclude, and an author reading `queries.scm` has no
way to tell.

It also closes off a real capability here. A Razor component reference
(`<Counter />`) differs from an HTML tag (`<div>`) only by the initial capital,
and the tag name is an anonymous token, so `#match?` over the element's text is
the only way to state component usage. Without it, `element` has to stay
untouched.

`runtime.rs` is on the frozen list, so this is reported rather than fixed. The
new Pack uses no predicates.
