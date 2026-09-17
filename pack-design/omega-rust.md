# omega-rust

Language `omega-rust`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten 2026-09-17: 340 templates over 385 patterns with 132 guards became
**72 templates over 42 patterns with 6 guards**. The tables below describe the
Pack that is there now; *What is wrong with it* describes the one that was.

## What it states today

72 templates over 42 query patterns, 46 of the grammar's 169 named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 5 |
| `definitions` | yes | 47 |
| `imports` | yes | 8 |
| `references` | yes | 10 |
| `scopes` | yes | 1 |
| `tests` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.struct` | Type | 1 |
| `definition.union` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.enum_variant` | Type | 1 |
| `definition.trait` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.associated_type` | Type | 1 |
| `definition.type_parameter` | Type | 1 |
| `definition.function` | Callable | 1 |
| `definition.required_method` | Callable | 1 |
| `definition.macro_function` | Callable | 1 |
| `definition.module` | Namespace | 1 |
| `definition.const` | Value | 1 |
| `definition.static` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.impl_block` | Value | 1 |
| `test.function` | Test | 1 |

`definition.union` and `definition.module` used to land in Value; the host's
Type and Namespace vocabularies now hold `union` and `module`, so the same
constructs are filed where they belong. `definition.impl_block` is deliberately
a Value: the type it is for is declared by its own `struct_item`, and this
entity exists so that the members inside it are owned by a name — `Foo::bar`
rather than a bare `bar` at module level.

### Carriers — attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.visibility_candidate` | `omega.pack.visibility` | 12 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 8 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 3 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 2 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 2 |
| `definition.aliased_type_candidate` | `omega.pack.aliased_type` | 1 |
| `definition.cfg_candidate` | `omega.pack.cfg` | 1 |

Four of these are the names `declared_signature` assembles a card's signature
line from — `visibility`, `type_parameter_shape`, `parameter_shape`,
`return_type`, `modifier` — so a Rust function reads
`pub async fn parse<T: Read>(r: T, limit: usize) -> Result<Ast>` and not
`parse -> Result<Ast>`. Every one of them is emitted with the *declaration's*
span, never the enclosing item's.

### Regions

- `scope.function_body` (1) — the block of a function, named after the function.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.path` | call | 1 |
| `call.turbofish` | call | 1 |
| `call.macro` | call | 1 |
| `import.use` | binding | 4 |
| `import.alias` | binding | 2 |
| `import.crate` | binding | 1 |
| `import.glob` | binding | 1 |
| `reference.type` | reference | 1 |
| `reference.field` | reference | 3 |
| `reference.path` | reference | 1 |
| `reference.attribute` | reference | 1 |
| `relation.implements` | implements | 2 |
| `relation.config` | config | 1 |
| `relation.depends` | depends | 1 |

Four `relation.*` kinds, all four among the six the host knows. The Pack emits
no `literal.*` and no `control_flow.*`: it emits no `reference_context.*`
either, so those spans would suppress nothing and each one was a query match
per string, number and control form in every file for an emission the host
discards.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 169 node types. The Pack looks at 46 of them.

The number went *down*, from 150. That is the point of the rewrite: the old
Pack reached almost every node type in the grammar by emitting a fact for every
expression form, every literal, every pattern node and every type syntax, and
those facts answered nothing. What is untouched now is, almost entirely,
expression and statement syntax, pattern syntax, literals, and the type-syntax
wrappers whose payload (`type_identifier`) is captured anyway.

Untouched:

- expressions and statements: `_expression`, `_declaration_statement`,
  `expression_statement`, `empty_statement`, `arguments`, `array_expression`,
  `assignment_expression`, `compound_assignment_expr`, `binary_expression`,
  `unary_expression`, `await_expression`, `break_expression`,
  `continue_expression`, `return_expression`, `yield_expression`,
  `try_expression`, `index_expression`, `range_expression`,
  `parenthesized_expression`, `tuple_expression`, `unit_expression`,
  `type_cast_expression`, `reference_expression`, `struct_expression`,
  `field_initializer_list`, `base_field_initializer`, `if_expression`,
  `else_clause`, `match_expression`, `match_block`, `match_arm`,
  `match_pattern`, `for_expression`, `while_expression`, `loop_expression`,
  `let_declaration`, `let_chain`, `let_condition`, `label`, `closure_expression`,
  `closure_parameters`, `async_block`, `gen_block`, `const_block`, `try_block`,
  `unsafe_block`
- patterns: `_pattern`, `_literal_pattern`, `captured_pattern`, `field_pattern`,
  `generic_pattern`, `mut_pattern`, `or_pattern`, `range_pattern`,
  `ref_pattern`, `reference_pattern`, `remaining_field_pattern`,
  `slice_pattern`, `struct_pattern`, `tuple_pattern`, `tuple_struct_pattern`
- literals: `_literal`, `boolean_literal`, `char_literal`, `float_literal`,
  `integer_literal`, `negative_literal`, `raw_string_literal`,
  `escape_sequence`
- type syntax whose payload is captured as `type_identifier`: `_type`,
  `abstract_type`, `array_type`, `bounded_type`, `bracketed_type`,
  `dynamic_type`, `function_type`, `generic_type_with_turbofish`,
  `higher_ranked_trait_bound`, `never_type`, `pointer_type`, `primitive_type`,
  `qualified_type`, `reference_type`, `removed_trait_bound`, `trait_bounds`,
  `tuple_type`, `type_arguments`, `type_binding`, `unit_type`, `use_bounds`,
  `where_clause`, `where_predicate`, `for_lifetimes`, `lifetime`,
  `lifetime_parameter`, `const_parameter`
- containers whose members are matched directly, or whose whole text is
  carried as a shape: `enum_variant_list`, `field_declaration_list`,
  `ordered_field_declaration_list`, `scoped_use_list`, `foreign_mod_item`,
  `parameter`, `self_parameter`, `variadic_parameter`, `extern_modifier`
- macro interior: `macro_rule`, `token_tree_pattern`, `token_repetition`,
  `token_repetition_pattern`, `token_binding_pattern`, `fragment_specifier`
- comments and markers: `line_comment`, `block_comment`, `doc_comment`,
  `inner_doc_comment_marker`, `outer_doc_comment_marker`, `shebang`
- leaves handled by their parent: `crate`, `self`, `super`,
  `shorthand_field_identifier`, `mutable_specifier`; and
  `inner_attribute_item`, whose `attribute` child is matched directly, so
  `#![deny(..)]` is recorded like any other attribute

The one untouched type that carries meaning and is left out on purpose is
`doc_comment`; see *Still to decide*.

## What is wrong with it

The Pack that was here declared thirteen capabilities and ran 385 query
patterns over every Rust file to produce 340 emissions' worth of facts, of
which the great majority answered nothing.

**Half the Pack was a framework overlay, under a comment saying it was not.**
26 output kinds carried the prefix `rust_`, and behind them were axum
(`rust_fq_router_nest_context`, `rust_fq_router_route_context` — a pattern
matching `Router::new().route("/x", get(handler))` down to the argument),
diesel (`#[diesel(table_name = ...)]`, `#[diesel(belongs_to(...))]` spelled as
`struct_named_attribute_context`), serde (`#[serde(rename = "x")]` as
`struct_field_string_attribute_context`) and four
`framework_neutral_rust_receiver_methods_v1` patterns matching any
`receiver.method(string, identifier)` shape — the router builder with the names
removed. 15 comment lines in the file asserted "Framework-neutral", "Framework
meaning is assigned later", "semantics remain downstream". The contract forbids
this in a language Pack; `frameworks/omega-framework-tokio` and the rest are
where it belongs.

**52 `reference_context.*` templates stored every identifier by the position it
sat in.** `reference_context.call_argument`, `.binary_operand`, `.condition`,
`.tuple_element`, `.range_bound`, `.await_operand`, `.parenthesized_value` —
one mention per identifier per expression form, none of which resolves to a
declaration and none of which any question asks for. They in turn were the only
reason the Pack's 25 `literal.*` and `control_flow.*` templates were not dead:
those spans suppress role boundaries, so the Pack matched every string, number,
boolean, `if`, `match`, `loop` and `await` in every file in order to suppress
mentions it should not have been making.

**41 more templates restated type syntax as mentions.** `type_expression.array`,
`.tuple`, `.pointer`, `.never`, `.bracketed`, `type_constraint.for_lifetimes`,
`type_context.generic_parameter_list`, `type_use.cast`, `.local`, `.field` —
a fact per wrapper node, all of them carrying the same `type_identifier` the
one `(type_identifier)` capture now records once.

**22 `relation.*` kinds were not relations.** `relation.struct_field`,
`relation.enum_variant`, `relation.enum_discriminant`, `relation.union_field`,
`relation.argument`, `relation.assignment`, `relation.initializer`,
`relation.return`, `relation.yield`, `relation.where_bound` and the rest strip
to a word the host does not know, so every one arrived as a plain reference —
indistinguishable from the 79 other reference kinds. The two relations Rust
actually has, *implements* and *depends*, were spelled
`relation.explicit_trait_impl` and `implementation.rust_qualified_trait_for_context`,
which are not relations either.

**123 templates named an emission with the whole node.** Every attribute was
stored under the full text of `#[derive(Debug, Clone, Serialize, Deserialize)]`;
`scope.file` was named with the entire source file and `scope.block` with the
entire block; `embedded_region.embedded_language_candidate` was named with the
whole token tree of every macro invocation in the corpus.

**17 carriers could never fold and 28 folded onto the wrong span.**
`call.target_candidate`, `import.alias_candidate`, `import.module_path_candidate`,
`scope.enclosing_owner_candidate`, `reference.member_access_candidate` and
`embedded_region.embedded_language_candidate` end in `_candidate` without
containing `definition` or ending in one of the five declaration suffixes, so
the host never folded them and stored each as a reference to nothing. Ten
`definition.category_candidate` templates took a member's name and gave it the
*enclosing owner's* span, so one struct's attribute bag was written once per
member and kept the last.

**Nine `value_origins` templates.** No host code reads that capability.
Four of them also carried a constant `value_semantics` attribute, and two
`call.*` templates a constant `receiver_semantics` — a fixed string written into
the index once per matched construct.

**65 of the 132 coverage guards gave a label for a reason**, most often
`rust_macro_expansion_semantics_unavailable` or
`terminal_static_ceiling__rust_type_inference_call_resolution`: a generator
confidence tier, repeated, saying nothing a reader can act on. 132 guards for
340 templates.

**The injections were kept for a bad reason.** `00-INDEX.md` records that
omega-rust and omega-c were allowed to keep injection patterns into languages
Omega has no grammar for, "because a template there does record the embedded
region even when the inner language is unknown". That template is
`embedded_region.embedded_language_candidate`: a carrier the host cannot fold,
named with the entire token tree. The injection set also held four `regex`
patterns keyed on the `Regex`/`RegexSet` API — a framework overlay — and one
`#offset!`, which is not a tree-sitter directive and does nothing. The whole
injection block is gone; the coverage guard now says plainly that a macro's
body is not parsed.

## What it should extract

Rust is the implementation language of a crate. The questions asked of it are
*where is this item declared*, *what is its signature and its visibility*,
*who calls it*, *who implements this trait*, *what does this file import*, and
*what is compiled only under a cfg*.

| what | node | emitted as | family |
|---|---|---|---|
| a function | `function_item` via `name:` | `definition.function` | Callable |
| a trait's required method | `function_signature_item` | `definition.required_method` | Callable |
| `macro_rules!` | `macro_definition` | `definition.macro_function` | Callable |
| a struct | `struct_item` | `definition.struct` | Type |
| a union | `union_item` | `definition.union` | Type |
| an enum | `enum_item` | `definition.enum` | Type |
| a variant | `enum_variant` | `definition.enum_variant` | Type |
| a trait | `trait_item` | `definition.trait` | Type |
| `type X = Y` | `type_item` | `definition.type_alias` | Type |
| an associated type | `associated_type` | `definition.associated_type` | Type |
| a generic parameter | `type_parameter` | `definition.type_parameter` | Type |
| a module | `mod_item` | `definition.module` | Namespace |
| a const, a static | `const_item`, `static_item` | `definition.const`, `.static` | Value |
| a named field | `field_declaration` | `definition.field` | Value |
| `impl Foo` | `impl_item` via `type:` | `definition.impl_block` | Value (the owner of its members) |
| `pub`, `pub(crate)` | `visibility_modifier` | `definition.visibility_candidate` | carrier |
| `async`, `unsafe`, `extern "C"` | `function_modifiers` | `definition.modifier_candidate` | carrier |
| `<T: Read>` | `type_parameters` | `definition.type_parameter_shape_candidate` | carrier |
| `(r: T, limit: usize)` | `parameters` | `definition.parameter_shape_candidate` | carrier |
| `-> Result<Ast>` | the `return_type:` field | `definition.return_type_candidate` | carrier |
| a field's, const's or static's written type | the `type:` field | `definition.declared_type_candidate` | carrier |
| what an alias aliases | `type_item` `type:` | `definition.aliased_type_candidate` | carrier |
| `#[cfg(feature = "x")]` | `attribute_item` anchored to the item below it | `definition.cfg_candidate` | carrier |
| `#[test] fn` | `attribute_item` anchored to the `function_item` | `test.function` | Test |
| a function's body extent | `function_item` `body:` | `scope.function_body` | region |
| `impl Trait for Type` | `impl_item` `trait:` | `relation.implements` | implements |
| `#[derive(Trait)]` | `attribute_item` anchored to the type below it | `relation.implements` | implements |
| `env!("VAR")`, `option_env!` | `macro_invocation` | `relation.config` | config |
| `include_str!("p")`, `include!`, `include_bytes!` | `macro_invocation` | `relation.depends` | depends |
| `use a::b;`, `use a::{b, c};` | `use_declaration`, `use_list` | `import.use` | binding |
| `use a as b;`, `extern crate a as b;` | `use_as_clause`, `extern_crate_declaration` | `import.alias` | binding |
| `use a::*;` | `use_wildcard`, star stripped | `import.glob` | binding |
| `extern crate a;` | `extern_crate_declaration` | `import.crate` | binding |
| `f(x)` | `call_expression` `function: (identifier)` | `call.function` | call |
| `a::f(x)` | `function: (scoped_identifier)` | `call.path` | call |
| `x.f()` | `function: (field_expression)` | `call.method` | call |
| `f::<T>(x)` | `function: (generic_function)` | `call.turbofish` | call |
| `m!(..)` | `macro_invocation` | `call.macro` | call |
| every mention of a type | `type_identifier` | `reference.type` | reference |
| `a.b`, `Foo { b: .. }`, `Foo { b }` | `field_expression`, `field_initializer`, `shorthand_field_initializer` | `reference.field` | reference |
| `Ordering::SeqCst`, `Self::LIMIT` | `scoped_identifier` `name:` | `reference.path` | reference |
| `#[serde(..)]`, `#[inline]` | `attribute` | `reference.attribute` | reference |
| every expression, literal and pattern form | — | nothing | — |

Three design decisions are worth stating because they cut the Pack by four
fifths.

**Containment is not a pattern, but attribute attachment has to be.** The tree
holds containment, and the host takes a declaration's owner from the smallest
declaration span around it — which is exactly why `impl_item` is declared: with
it, `bar` inside `impl Foo` is owned by `Foo`; without it, a repository's
thousand `new`s are all bare. Attributes are a different case: `#[derive]`,
`#[test]` and `#[cfg]` are *siblings* of the item they describe, so the tree
does not say what they attach to and the six anchored patterns that pair them
are the only way to state it. They are anchored on both sides with
`(attribute_item)*` between, so an intervening `#[ignore]` does not break the
pair and a distant attribute does not claim an item that is not below it.

**Nothing inside a function body is declared.** No `let`, no closure parameter,
no `match`, `for` or `if let` binding. A local name is not an entity a question
from another file can reach, it cannot be resolved without scoping the host does
not do, and it is the single most numerous construct in the language. The
guard says so.

**References are emitted only where they can resolve.** A type mention, a
field, a qualified path, a call target, an import, an attribute. There is no
bare `(identifier)` capture anywhere in the file; the only bare capture is
`(type_identifier)`, which the brief names explicitly as the one worth having.

## Still to decide

1. **Doc comments.** `doc_comment`, `line_comment` and `block_comment` are
   untouched. The old Pack emitted them as mentions named with the whole
   comment, which is Defect D and worse than nothing. The right shape would be
   a `definition.documentation_candidate` carrier anchored to the item below the
   comment run, the way `#[cfg]` is — one more pair of patterns and one more
   attribute per documented item, holding text that can be long. Left out until
   there is a reader for it.
2. **`definition.type_parameter`.** Declaring every `T` makes the mentions of
   `T` inside an item resolve to something rather than to nothing, but the host
   resolves by name across the repository, so a `T` in one crate and a `T` in
   another are the same name. Kept, on the grounds that a mention resolving to
   the wrong `T` is no worse than a mention resolving to nothing and the shape
   is what a later scoped resolver would want; revisit against the row count.
3. **`x.f()` is two facts.** The grammar spells a method call and a field
   access with the same `field_expression`, and a query cannot ask what the
   parent is, so `x.f()` is a `call.method` on the call and a `reference.field`
   on the access. Both are true statements about the bytes; if the duplication
   costs more than it answers, the `field_expression` pattern is the one to
   drop, since `Foo { b: .. }` and `Foo { b }` already carry the unambiguous
   field mentions.
4. **`#[test]` is a second declaration.** A test function is a Callable named
   `foo` and a Test named `foo` at the same span. Two consumers in the host
   (`production.rs`, `public_execution.rs`) filter entities by
   `EntityFamily::Test`, so the Test entity has to exist; the alternative, a
   carrier marking the Callable, would answer "list the tests" with nothing.
   Kept as it is.
