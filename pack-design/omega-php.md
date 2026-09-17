# omega-php

Language `omega-php`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. What follows describes the Pack as it is now; the old Pack is
described under *What was wrong with it*.

## What it states today

51 templates over 44 query patterns, 48 of the grammar's 162 named node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 2 |
| `calls` | yes | 5 |
| `definitions` | yes | 21 |
| `imports` | yes | 3 |
| `modules` | yes | 1 |
| `references` | yes | 11 |
| `scopes` | yes | 7 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates | what it is |
|---|---|---|---|
| `definition.class` | Type | 1 | `class Foo` |
| `definition.interface` | Type | 1 | `interface Foo` |
| `definition.trait` | Type | 1 | `trait Foo` |
| `definition.enum` | Type | 1 | `enum Suit` |
| `definition.case_constant` | Value | 1 | `case Hearts` -- a constant of the enum, not a type |
| `definition.method` | Callable | 1 | a method |
| `definition.function` | Callable | 1 | a free function |
| `definition.property` | Value | 2 | `public $x` and a promoted constructor parameter |
| `definition.constant` | Value | 1 | `const TABLE = ...` |
| `definition.parameter` | Value | 2 | a plain and a variadic parameter |
| `definition.namespace` | Namespace | 1 | `namespace App\Models` |

### Carriers -- attributes they attach to the declaration on the same span

Every one of these is a name the engine reads: four of the five that build the
signature line on a card, plus `declared_type`.

| kind | attribute | templates | attached to |
|---|---|---|---|
| `definition.visibility_candidate` | `omega.pack.visibility` | 3 | a method, a property, a promoted property |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 | a method, a function |
| `definition.return_type_candidate` | `omega.pack.return_type` | 2 | a method, a function |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 2 | a property, a promoted property |

### Regions

| kind | templates | span |
|---|---|---|
| `scope.class_body` | 4 | the body of a class, interface, trait or enum |
| `scope.function_body` | 2 | the body of a method or a function |
| `scope.namespace_body` | 1 | the body of a braced `namespace App { }` |

### Mentions

| kind | occurrence the host makes | templates | what it is |
|---|---|---|---|
| `relation.implements` | implements | 3 | `extends`, `implements`, a trait `use` |
| `call.function` | call | 1 | `foo()` |
| `call.method` | call | 2 | `$o->m()` and `$o?->m()` |
| `call.static_method` | call | 1 | `Foo::m()` |
| `call.constructor` | call | 1 | `new Foo` |
| `reference.class` | reference | 3 | the left of `::` in a call, a property access, a constant access |
| `reference.property` | reference | 3 | `$o->p`, `$o?->p`, `Foo::$p` |
| `reference.constant` | reference | 1 | `Foo::BAR` |
| `reference.attribute` | reference | 1 | `#[Route(...)]` |
| `type_use.name` | reference | 1 | every authored type hint |
| `import.symbol` | binding | 1 | `use App\Models\User` |
| `import.alias` | binding | 1 | `... as U` |
| `import.file` | binding | 1 | `require 'x.php'` with a literal path |
| `binding.global` | reference | 1 | `global $config` |
| `binding.captured_variable` | reference | 1 | a closure's `use ($config)` |

No `literal.*` template survives. The Pack emits no `reference_context.*` kind,
so a literal span suppresses nothing and a literal template would be one query
match per string, number and boolean in every file for an emission the host
drops.

### How names are spelled

This is the one decision the whole Pack turns on, because a mention answers a
question only if its name is spelled like the declaration it should reach.

- A qualified name is reduced to its last segment: `\App\Models\User`,
  `use App\Models\User` and a later `User` are all stored as `User`. That is
  what `use` puts in scope and what the rest of the file writes.
- A property is stored **without** its `$` (`name`, not `$name`), because
  `$this->name` and `Foo::$name` spell it that way.
- A parameter, a `global` and a closure capture keep their `$`, because every
  mention of them keeps it.
- `static`, `self` and `parent` are never stated: in a type position they name
  whichever class is running, not a declaration.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 162 node types. The Pack looks at 48 of them (57 before).

Deliberately untouched, by group:

- **Control flow and statements** -- `if_statement`, `for_statement`,
  `foreach_statement`, `while_statement`, `do_statement`, `switch_statement`,
  `match_expression`, `try_statement`, `catch_clause`, `return_statement`,
  `throw_expression`, `echo_statement` and the rest. Omega asks *what is
  declared and who mentions it*; a branch names nothing. A `catch (FooError $e)`
  does name a class, and it is stated -- through `named_type`, not through
  `catch_clause`.
- **Literals** -- `integer`, `float`, `boolean`, `null`, `string`,
  `encapsed_string`, `heredoc`, `nowdoc`, `array_creation_expression`. See
  above: nothing here suppresses anything, and a PHP literal is not a name.
- **Operators and plumbing** -- `binary_expression`, `assignment_expression`,
  `update_expression`, `subscript_expression`, `parenthesized_expression`,
  `arguments`, `argument`, `php_tag`, `text`, `comment`, supertypes
  (`expression`, `statement`, `literal`, `type`, `primary_expression`).
- **Modifier nodes** -- `abstract_modifier`, `final_modifier`,
  `static_modifier`, `readonly_modifier`, `var_modifier`. Not stated; see
  *Still to decide*.
- **`anonymous_function`, `arrow_function`, `anonymous_class`** -- they declare
  nothing with a name, so a region over one would have to be named with its own
  text. Their parameters and their type hints are still stated, because those
  patterns are written against the parameter and the type, not the function.
- **`static_variable_declaration`, `function_static_declaration`,
  `declare_directive`, `goto_statement`, `named_label_statement`,
  `shell_command_expression`** -- real constructs that nobody asks a repository
  question about.
- **`property_hook`, `property_hook_list`** (PHP 8.4 `get`/`set` bodies) --
  these do hold code, and a hook body is arguably a region. Not stated; see
  *Still to decide*.

## What was wrong with it

The Pack found here was 49 templates over **101** query patterns with 37
coverage guards, assembled out of six generator passes whose section headers
are still in the file: `external-helix-tags`, `locals`, `p0-exact-helix-locals`,
`p0-exact-helix-tags`, `upstream_tags`, `static_delta`. Eight of its 40 section
headers had no patterns under them at all.

- **Nothing it declared reached the right family, twice over.**
  `definition.php_interface` and `definition.php_module` are Value: a PHP
  interface was not a type and a namespace was not a namespace. (Defect A.)
- **The same construct declared twice under two spellings.** `definition.class`
  and `definition.php_type` for a class, `definition.function` and
  `definition.php_function` and `definition.php_method` for a callable,
  `scope.lexical` and `scope.php_lexical_scope` over the same `@local.scope`
  capture. (Defect K2 -- one flagged by the audit, five more by reading.)
- **15 carriers under a name nothing assembles**, and **11 carriers the host
  will not fold at all** (`call.target_candidate`, `import.php_candidate`,
  `module.php_candidate`, `type.php_declaration_candidate`,
  `scope.enclosing_owner_candidate`, `module.declaration_path_candidate`): they
  contain no `definition` and end in none of the five suffixes, so each was
  stored as a mention of a name nothing resolves. `omega.pack.identity`,
  `omega.pack.category`, `omega.pack.enclosing_owner`, `omega.pack.named_owner`
  and `omega.pack.qualified_chain` are computed and stored and never read.
- **8 templates named an emission with a whole node.** `import.php_candidate`
  stored the entire `use` declaration as the import's name,
  `module.php_candidate` the whole `namespace` statement,
  `type.php_declaration_candidate` **the entire class**, `call.call` the entire
  call expression, `scope.php_lexical_scope` the entire function. (Defect D2.)
- **3 carriers were folded onto the class that contains the member they
  described**, so a class with N methods wrote `omega.pack.visibility` N times
  onto itself and kept the last.
- **Framework overlays, spelled as tree shapes, under comments denying it.**
  Five patterns, about 60 lines with their headers: an ORM relation matcher
  (`class_relation_explicit_target_context`, matching
  `return $this->belongsTo(User::class)` with `#eq?` predicates pinning `$this`
  and `class` -- Eloquent), a routing-attribute matcher
  (`php_attributed_method_route_context`, class + attribute + first string
  argument), two string-argument call shapes and a `hook` shape
  (`function_call_expression` with a string and a callback name -- WordPress
  `add_action`). The header comments read "Framework-neutral PHP class-owned
  method", "framework meaning ... remain downstream",
  `framework_neutral_php_constructor_and_hooks_v1`. `frameworks/` already holds
  `omega-framework-laravel`, `omega-framework-symfony` and
  `omega-framework-wordpress`. (Defect L.)
- **Containment stated as a pattern.** `member_category_method` alone wrote
  five class/interface/trait/enum × `declaration_list` × `method_declaration`
  patterns to say a method is inside a class -- one match per (owner, member)
  pair, for a fact the tree holds and the `within:` segment already carries.
  `ownership_parameters` did the same for six owner × parameter pairs. Twelve
  patterns in all, feeding two carriers nothing reads.
- **`relation.php_implements_candidate`** is not one of the six relations, so
  `implements` arrived as a plain reference -- under capability `calls`.
- **13 `#set!` directives** inherited from an nvim-treesitter `locals.scm`
  baseline, which the query layer parses and nothing reads, plus
  `(variable_name (name) @local.reference)`: every `$x` in every file.
- **37 coverage guards for 49 templates**, two of them a single token
  (`php_upstream_tags_are_syntax_candidates_only`), and most of the rest one of
  four boilerplate sentences about "bounded source symbol resolution" repeated
  with the capability changed.

Not present, and worth recording: no constant attribute (defect F) and no
constant name (defect J) survived the repository-wide sweep in this Pack, and
there was no `(_)` universal capture.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a class | `class_declaration` | `definition.class` | Type |
| an interface | `interface_declaration` | `definition.interface` | Type |
| a trait | `trait_declaration` | `definition.trait` | Type |
| an enum | `enum_declaration` | `definition.enum` | Type |
| an enum case | `enum_case` | `definition.case_constant` | Value |
| a namespace | `namespace_definition` | `definition.namespace` | Namespace |
| a method | `method_declaration` | `definition.method` | Callable |
| a function | `function_definition` | `definition.function` | Callable |
| a property | `property_element` | `definition.property` | Value |
| a promoted property | `property_promotion_parameter` | `definition.property` | Value |
| a class constant | `const_element` | `definition.constant` | Value |
| a parameter | `simple_parameter`, `variadic_parameter` | `definition.parameter` | Value |
| its visibility | `visibility_modifier` | `definition.visibility_candidate` | carrier |
| its parameter list | `formal_parameters` | `definition.parameter_shape_candidate` | carrier |
| its return type | `return_type:` | `definition.return_type_candidate` | carrier |
| a property's type | `type:` | `definition.declared_type_candidate` | carrier |
| the body of a type | `declaration_list`, `enum_declaration_list` | `scope.class_body` | region |
| the body of a callable | `compound_statement` | `scope.function_body` | region |
| the body of a namespace | `compound_statement` | `scope.namespace_body` | region |
| `extends` | `base_clause` | `relation.implements` | implements |
| `implements` | `class_interface_clause` | `relation.implements` | implements |
| a trait `use` | `use_declaration` | `relation.implements` | implements |
| `use App\X` | `namespace_use_clause` | `import.symbol` | binding |
| `... as Y` | `alias:` | `import.alias` | binding |
| `require 'x.php'` | `include_expression` and its three siblings | `import.file` | binding |
| `foo()` | `function_call_expression` | `call.function` | call |
| `$o->m()`, `$o?->m()` | `member_call_expression`, `nullsafe_member_call_expression` | `call.method` | call |
| `Foo::m()` | `scoped_call_expression` | `call.static_method` | call |
| `new Foo` | `object_creation_expression` | `call.constructor` | call |
| the class left of `::` | `scoped_call_expression`, `scoped_property_access_expression`, `class_constant_access_expression` | `reference.class` | reference |
| `Foo::BAR` | `class_constant_access_expression` | `reference.constant` | reference |
| `$o->p`, `$o?->p`, `Foo::$p` | `member_access_expression`, `nullsafe_member_access_expression`, `scoped_property_access_expression` | `reference.property` | reference |
| an attribute | `attribute` | `reference.attribute` | reference |
| any authored type hint | `named_type` | `type_use.name` | reference |
| `global $x` | `global_declaration` | `binding.global` | reference |
| a closure capture | `anonymous_function_use_clause` | `binding.captured_variable` | reference |

PHP spells its four call forms as four node types and a property read as a
fifth, so the trap that cost omega-rust two thirds of its largest emission
class -- a method callee and a field access sharing one node type -- does not
exist here. `$o->m()` is a `member_call_expression` and `$o->m` is a
`member_access_expression`, and this Pack can tell them apart with certainty.

## Still to decide

- **Modifiers other than visibility are not carried.** `omega.pack.modifier` is
  one of the five names that build a card's signature, and *is this method
  static* is a question someone asks. But PHP allows several modifiers on one
  declaration (`final readonly class`, `abstract public static function`), a
  carrier keeps the last value of an attribute, and there is no node holding the
  modifiers together to name as one string. Stating one of them would be wrong
  as often as it is right, so none is stated and a guard says so. If the
  expression vocabulary grows a way to collect a node's children of several
  types, this becomes a single carrier and should be added.
- **Visibility is carried, and PHP 8.4 can put two visibility modifiers on one
  member** (`public private(set) string $x`). The write visibility is spelled
  with parentheses, so the three visibility patterns exclude it with
  `#not-match? "[(]"` and the attribute always holds the read visibility. The
  alternative -- carrying both and keeping the last -- would store
  `private(set)` as the visibility of a public property.
- **Property hooks** (`property_hook`, PHP 8.4) hold statements and could be a
  `scope.function_body`. They are new enough to be rare; left out until a
  corpus says otherwise.
- **`namespace_use_group`'s prefix is not applied.** `use App\Support\{Str, Arr}`
  imports `Str` and `Arr`, which is the right name for resolution, but the Pack
  never joins them to `App\Support`. Consistent with the last-segment rule
  above, and covered by the first guard.

## A defect in the host

None found. Every fact this Pack wants to state has a kind the host reads the
way the Pack means it.

## A note on `pack-design/audit.py`

Two of its checks read the query file with a regex that expects a pattern to
start with `(<node-type>`. A pattern wrapped in an extra pair of parentheses so
that it can carry a predicate -- `((node ...) @span (#not-match? ...))`, which
is the only way tree-sitter accepts one -- starts with `((`, so no owner node is
recorded for its captures and the D, D2 and `carrier_owner` checks silently skip
it. This Pack's three visibility carriers are in that shape. They are correct
for the reason given above, not because the audit stopped looking, but the
blind spot is general and belongs in `00-INDEX.md`.
