# omega-swift

Language `omega-swift`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten 2026-09-17. Version 2.0.0. The tables below describe the Pack as it
now stands; the rewrite is argued under *What is wrong with it*.

## What it states today

43 templates over 23 query patterns, 22 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 32 |
| `imports` | yes | 1 |
| `references` | yes | 4 |
| `scopes` | yes | 4 |

`bindings` and `types` are no longer declared. Nothing the Pack states is a
binding shape, and a type mention is a reference like any other: the capability
string is read by nothing except `names_something`, which drops emissions by
capability and kind together, so choosing `types` over `references` would have
changed nothing but the manifest.

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.swift_type` (class, struct, enum, actor) | Type | 1 |
| `definition.swift_protocol` | Type | 1 |
| `definition.swift_alias` | Type | 1 |
| `definition.associated_type` | Type | 1 |
| `definition.swift_function` | Callable | 1 |
| `definition.protocol_function` | Callable | 1 |
| `definition.swift_constructor` | Callable | 1 |
| `definition.swift_destructor` | Callable | 1 |
| `definition.swift_property` | Value | 1 |
| `definition.swift_property_requirement` | Value | 1 |
| `definition.swift_parameter` | Value | 1 |
| `definition.swift_subscript` | Value | 1 |
| `definition.swift_case` | Value | 1 |
| `definition.swift_macro` | Value | 1 |
| `definition.swift_operator` | Value | 1 |
| `definition.precedence_group` | Value | 1 |

`entity_family` matches whole words and the **last** match wins, so the names
above are chosen word by word. `definition.protocol_function` lands in Callable
because `function` trails `protocol`. `definition.swift_property_requirement`
deliberately avoids the word `protocol`, which would have filed a property
requirement as a Type; `definition.swift_case` deliberately avoids `enum`, for
the same reason.

### Carriers -- attributes they attach to the declaration on the same span

Every carrier below is emitted with the **declaration's** span, so the host
folds it onto that declaration, and every one contains `definition`, so it
passes `is_definition_kind` and is folded rather than stored as a mention.

| kind | attribute | carried on | templates |
|---|---|---|---|
| `definition.kind_candidate` | `omega.pack.kind` | the nominal type: `class` / `struct` / `enum` / `actor` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | type, protocol, function, init, property, alias | 6 |
| `definition.return_type_candidate` | `omega.pack.return_type` | function, protocol function requirement | 2 |
| `definition.throws_candidate` | `omega.pack.throws` | function, protocol function requirement | 2 |
| `definition.type_candidate` | `omega.pack.type` | property, property requirement, parameter | 3 |
| `definition.mutability_candidate` | `omega.pack.mutability` | property: `let` or `var` | 1 |
| `definition.aliased_type_candidate` | `omega.pack.aliased_type` | typealias | 1 |

### Regions

- `scope.type_body` (3: the class/struct/enum/actor body, the extension body, the protocol body)
- `scope.function_body` (1)

Both are named by the declaration the body belongs to, never by the body's own
text. Neither contains `definition` nor ends in `.type`, `.function`, `.class`,
`.method` or `.trait`, so neither is read as a declaration as well as a region.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `relation.depends` | depends | 1 |
| `reference.type` | reference | 1 |
| `reference.attribute` | reference | 1 |
| `call.swift` | call | 1 |
| `call.swift_macro` | call | 1 |
| `import.swift_module` | binding | 1 |

### Emitted and read by nothing

None. In particular the Pack emits no `literal.*` and no `control_flow.*`
marker family; see item 8 below for why that is right here and is not a general
rule.

### Coverage guards

Seven, each a sentence about Swift: overload and dynamic dispatch; member reads
outside call position; unexpanded aliases and qualified names; extensions;
conditional compilation and macro expansion; unreconstructed signatures; and
bindings that are not a single name.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 183 node types. The Pack names 36 of them. `class_body`,
`enum_class_body` and `protocol_body` are reached as well, through the `body:`
field with a wildcard, so that one pattern covers every body spelling.

Untouched: `_expression`, `additive_expression`, `array_literal`, `array_type`,
`as_expression`, `as_operator`, `assignment`, `availability_condition`,
`await_expression`, `bang`, `bin_literal`, `bitwise_operation`,
`boolean_literal`, `capture_list`, `capture_list_item`, `catch_block`,
`catch_keyword`, `check_expression`, `class_body`, `comment`,
`comparison_expression`, `computed_getter`, `computed_modify`,
`computed_property`, `computed_setter`, `conjunction_expression`,
`constructor_expression`, `constructor_suffix`, `control_transfer_statement`,
`default_keyword`, `deprecated_operator_declaration_body`, `diagnostic`,
`dictionary_literal`, `dictionary_type`, `didset_clause`, `directive`,
`directly_assignable_expression`, `disjunction_expression`, `do_statement`,
`else`, `enum_class_body`, `enum_type_parameters`, `equality_constraint`,
`equality_expression`, `existential_type`, `external_macro_definition`,
`for_statement`, `fully_open_range`, `function_modifier`, `function_type`,
`getter_specifier`, `guard_statement`, `hex_literal`, `if_statement`,
`infix_expression`, `inheritance_constraint`, `inheritance_modifier`,
`integer_literal`, `interpolated_expression`, `key_path_expression`,
`key_path_string_expression`, `lambda_function_type`,
`lambda_function_type_parameters`, `lambda_literal`, `lambda_parameter`,
`line_str_text`, `line_string_literal`, `macro_definition`, `member_modifier`,
`metatype`, `modify_specifier`, `multi_line_str_text`,
`multi_line_string_literal`, `multiline_comment`, `multiplicative_expression`,
`mutation_modifier`, `nil_coalescing_expression`, `oct_literal`, `opaque_type`,
`open_end_range_expression`, `open_start_range_expression`, `optional_type`,
`ownership_modifier`, `parameter_modifier`, `parameter_modifiers`,
`playground_literal`, `postfix_expression`, `precedence_group_attribute`,
`precedence_group_attributes`, `prefix_expression`,
`property_behavior_modifier`, `property_modifier`, `protocol_body`,
`protocol_composition_type`, `protocol_property_requirements`,
`range_expression`, `raw_str_continuing_indicator`, `raw_str_end_part`,
`raw_str_interpolation`, `raw_str_interpolation_start`, `raw_str_part`,
`raw_string_literal`, `real_literal`, `regex_literal`,
`repeat_while_statement`, `selector_expression`, `self_expression`,
`setter_specifier`, `shebang_line`, `source_file`, `special_literal`,
`statement_label`, `statements`, `str_escaped_char`, `super_expression`,
`suppressed_constraint`, `switch_entry`, `switch_pattern`, `switch_statement`,
`ternary_expression`, `throw_keyword`, `throws_clause`, `try_expression`,
`try_operator`, `tuple_expression`, `tuple_type`, `tuple_type_item`,
`type_arguments`, `type_constraint`, `type_constraints`, `type_modifiers`,
`type_pack_expansion`, `type_parameter`, `type_parameter_modifiers`,
`type_parameter_pack`, `type_parameters`, `value_argument`,
`value_argument_label`, `value_arguments`, `value_pack_expansion`,
`value_parameter_pack`, `where_clause`, `where_keyword`, `while_statement`,
`wildcard_pattern`, `willset_clause`, `willset_didset_block`.

Most of that list is expression and literal syntax -- twelve expression node
types, six numeric and string literal types, ten string-part types. None of them
names anything. An agent does not ask where an addition is; it asks where a name
is declared, used or called, and the names inside those expressions reach the
Pack through `call_expression`, `navigation_expression` and `user_type`, which
are covered.

The untouched types that do carry meaning, and why each stays untouched:

| node | what it would say | why not |
|---|---|---|
| `lambda_literal` | the extent of a closure | a closure has no name, and a region named by its own body text is Defect D |
| `type_parameter`, `where_clause`, `type_constraint` | the generic signature | a generic parameter `T` is a name only inside one declaration; declaring it makes every `T` in the repository one symbol |
| `directive` (`#if`) | which branch a declaration is in | evaluating it is compiler work; a guard says so, and declarations in every branch are recorded |
| `capture_list_item` | what a closure captures | it resolves against nothing until closures have regions |
| `computed_getter`/`computed_setter`/`willset_didset_block` | where a property's accessor body is | the property declaration already spans it; a second region inside it answers nothing new |
| `switch_entry`, `catch_block`, `control_transfer_statement` | control flow | nothing here names anything; see item 8 |
| `self_expression`, `super_expression` | the receiver of a member access | their names are the constants `self` and `super`; they resolve to nothing |

## What is wrong with it

Measured against the Pack as shipped (version 1.0.0): **48 templates over 76
query patterns, 32 coverage guards**.

1. **Containment stated as a pattern -- Defect E, 22 of 76 patterns.** Thirteen
   `member_category_*` and `ownership_members` patterns spelled
   `(class_declaration name: (_) body: (class_body (function_declaration name: (_))))`
   -- one pattern per (owner x body spelling x member kind) -- plus nine more in
   `swift_class_method_context`, `swift_computed_property_direct_call_context`,
   `nominal_conformance_context`, `framework_neutral_swift_property_attribute_v1`
   and the four `upstream_tags` shapes. Every one of them states that a member
   is inside a type, which the tree already holds and which the host already
   carries in the declaration's namespace. Each cost one match per (owner,
   member) pair.
2. **A carrier attached to the wrong span -- 7 templates.** The six
   `definition.member_category_candidate` templates and
   `definition.member_owned_candidate` used `span_capture: owner.span` -- the
   class -- while naming the member. A carrier folds onto the declaration that
   occupies its span, so every member of a class wrote the same
   `omega.pack.member_category` attribute onto the class and all but one were
   lost.
3. **A carrier the host will not fold -- 10 templates (the audit's count).**
   `call.target_candidate`, `call.call_candidate`, `import.swift_candidate`,
   `import.module_path_candidate`, `type.swift_declaration_candidate`,
   `scope.enclosing_owner_candidate`, `scope.named_owner_candidate`,
   `reference.receiver_candidate`, `reference.navigation_candidate` and
   `relation.inheritance_or_conformance_candidate` all end in `_candidate` but
   contain no `definition` and end in none of the five declaration suffixes.
   `is_definition_kind` is therefore false, the fold never happened, and each
   fell through to the mention branch and was stored as a reference to nothing.
4. **The name is a whole node -- Defect D, 8 templates.**
   `import.swift_candidate` named itself with the whole `import` statement;
   `type.swift_declaration_candidate` with the whole `class_declaration`, body
   included; `call.call_candidate` with the whole `call_expression`;
   `reference.navigation_candidate` with the whole `a.b.c.d`;
   `module_relation.imported_module` with the whole import;
   `relation.inheritance_or_conformance_candidate` with the whole
   `inheritance_specifier`; and `scope.lexical` and `scope.swift_lexical_scope`
   -- two templates over one capture, so twice -- with the whole text of every
   `statements`, `if`, `for`, `while`, `repeat`, `do`, `guard`, `switch`,
   property, function, class and protocol node in the file. That is the file's
   own text stored again at every block depth.
5. **A `relation.*` kind the host does not know -- 1.**
   `relation.inheritance_or_conformance_candidate` is not one of the six the
   host recognises, so Swift's only structural relation -- who conforms to this
   protocol, who subclasses this class -- arrived as a plain reference named
   with the source text of the inheritance clause.
6. **A type filed as a value -- Defect A, 1 kind.**
   `definition.swift_interface`, emitted for every `protocol_declaration`,
   carries no word from the Type row, so every Swift protocol in the corpus was
   stored as a Value.
7. **The same fact stated four and five times.** A function was declared by
   `definition.function`, by `definition.swift_function` twice over two
   different span captures, by `definition.category_candidate` and by
   `definition.identity_candidate`. A class by `definition.swift_class`,
   `definition.category_candidate`, `definition.identity_candidate` and
   `type.swift_declaration_candidate`. A single `import Foundation` produced
   five emissions: `binding.import`, `import_binding.swift_import`,
   `import.swift_candidate`, `import.module_path_candidate` and
   `module_relation.imported_module`.
8. **A `literal.*` marker that suppresses nothing.** `literal.literal` was kept
   under the rule in `AGENT-BRIEF.md` §10 that a `literal.*` span suppresses
   role emissions over the same bytes. Read
   `crates/omega-ingest/src/pack/emission_roles.rs:132`: the suppression fires
   only for emissions whose kind starts with `reference_context.`. omega-swift
   emitted no `reference_context.*` kind at all, so the marker suppressed
   nothing and was pure cost -- one match for every string, number and boolean
   in every Swift file, producing an emission the host then drops. It is
   removed. The §10 rule is real but conditional, and the condition is not
   stated in the brief.
9. **Guards whose reason is a label -- Defect G, 4 of 32.**
   `swift_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`,
   `swift_overload_and_dynamic_dispatch_require_sourcekit_semantics`,
   `swift_inheritance_specifier_kind_requires_type_resolution` and
   `swift_upstream_tags_project_semantics_terminal_static_boundary`. Of the
   other 28, most were a second and third restatement of one another: eleven
   said some form of "resolution requires the resolver", which is true of every
   Pack and says nothing about Swift.
10. **Four patterns that are a framework overlay in disguise -- Defect L.**
    `named_string_argument_context`, `named_array_string_argument_context`,
    `swift_receiver_member_string_argument_context` and
    `semantic_closure_v3_146_swift_receiver_member_literal_segments` match
    `f(label: "string")` and `a.b("string")` and store the string in `fields`.
    Nothing in Swift makes a string argument meaningful; the shapes are
    SwiftPM's `.package(url:)` and `.target(name:)` and SwiftUI's
    `Image("name")`, written into a language Pack under a header comment
    claiming neutrality. They belong in `frameworks/`.
11. **Dead sections.** `definition_identity_hints`, `locals`,
    `nvim_pinned_injections` and `nvim_pinned_locals` held nothing but
    provenance comments and a `; Scopes` heading -- the residue of an
    nvim-treesitter import whose body had already been swept out.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a class, struct, enum or actor | `class_declaration`, `declaration_kind` not `extension` | `definition.swift_type` | Type |
| which of the four it is | the `declaration_kind` keyword | `definition.kind_candidate` -> `omega.pack.kind` | carrier |
| a protocol | `protocol_declaration` | `definition.swift_protocol` | Type |
| a type alias | `typealias_declaration` | `definition.swift_alias` | Type |
| what it aliases | its `value` field | `definition.aliased_type_candidate` | carrier |
| an associated type | `associatedtype_declaration` | `definition.associated_type` | Type |
| a function | `function_declaration` | `definition.swift_function` | Callable |
| a protocol's function requirement | `protocol_function_declaration` | `definition.protocol_function` | Callable |
| an initializer | `init_declaration` | `definition.swift_constructor` | Callable |
| a deinitializer | `deinit_declaration` | `definition.swift_destructor` | Callable |
| the written return type | the `return_type` field | `definition.return_type_candidate` | carrier |
| whether it throws | `throws` | `definition.throws_candidate` | carrier |
| a property | `property_declaration` | `definition.swift_property` | Value |
| a protocol's property requirement | `protocol_property_declaration` | `definition.swift_property_requirement` | Value |
| `let` or `var` | `value_binding_pattern` `mutability` | `definition.mutability_candidate` | carrier |
| the written type annotation | `type_annotation` `type` | `definition.type_candidate` | carrier |
| a parameter | `parameter` | `definition.swift_parameter` | Value |
| a subscript | `subscript_declaration` | `definition.swift_subscript` | Value |
| an enum case | `enum_entry` | `definition.swift_case` | Value |
| a macro | `macro_declaration` | `definition.swift_macro` | Value |
| a custom operator | `operator_declaration` | `definition.swift_operator` | Value |
| a precedence group | `precedence_group_declaration` | `definition.precedence_group` | Value |
| the declared visibility | `modifiers (visibility_modifier)` | `definition.visibility_candidate` | carrier |
| the extent of a type body | the `body:` field of a type or protocol | `scope.type_body` | region |
| the extent of a function body | `function_body` | `scope.function_body` | region |
| what a file imports | `import_declaration` | `import.swift_module` | binding |
| what it calls | `call_expression` with a `simple_identifier` or `navigation_suffix` callee | `call.swift` | call |
| a macro invocation | `macro_invocation` | `call.swift_macro` | call |
| where a type is used | `user_type (type_identifier)` | `reference.type` | reference |
| a bare-word attribute | `attribute (simple_identifier)` | `reference.attribute` | reference |
| what conforms to or subclasses what | `inheritance_specifier` | `relation.implements` | implements |
| what an extension extends | `class_declaration`, `declaration_kind` = `extension` | `relation.depends` | depends |

Two decisions inside that table are worth stating plainly.

**One node for four keywords.** `class`, `struct`, `enum` and `actor` are one
grammar node distinguished by a keyword token, and `extension` is the same node
again. Writing five patterns would have forced five kinds and five families.
Instead the keyword is captured with `declaration_kind: _ @type.keyword`, the
pattern is filtered with `(#not-eq? @type.keyword "extension")` -- one of the
six predicates the Rust binding actually applies -- and the word itself is
carried on the declaration as `omega.pack.kind`. One pattern, one declaration,
the exact word preserved.

**An extension declares nothing.** `extension Array` introduces no name; it is
a dependency on a type declared elsewhere. So it is emitted as
`relation.depends` naming that type, and its body is a region so that members
written inside it still have an extent. Those members are declared by the
ordinary member patterns, nested in the extension.

## Still to decide

- **A member access outside call position.** `a.b` read as a value is not
  emitted. Emitting it would answer "where is this property read", but it would
  also put a second mention on every `a.b()`, where the call is already
  recorded, and member calls are the common case. The Pack takes the call and
  states the omission in a guard. If the resolver ever de-duplicates a call and
  a reference on the same span, this is the first thing to add back.
- **An inheritance specifier carries two emissions.** The `user_type` inside
  `class Foo: Bar` is both `relation.implements` (the edge) and `reference.type`
  (the mention), because the blanket type-use pattern cannot exclude a parent
  node in tree-sitter. It is deliberate -- the two answer different questions --
  and inheritance clauses are a small fraction of all type mentions.
- **Closures have no region.** `lambda_literal` is the one untouched node type
  that clearly carries meaning. It needs a name the grammar does not give it,
  and a region named by its own text is exactly Defect D.
