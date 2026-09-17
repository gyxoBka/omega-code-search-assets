# omega-gdscript

Language `omega-gdscript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. The tables below describe the Pack as it is now; **What is wrong with
it** records what it said before.

## What it states today

29 templates over 23 query patterns, 27 distinct root node types, 5 guards.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 19 |
| `references` | yes | 5 |
| `scopes` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | node | templates |
|---|---|---|---|
| `definition.class` | Type | `class_name_statement`, `class_definition` | 2 |
| `definition.enum` | Type | `enum_definition` | 1 |
| `definition.function` | Callable | `function_definition` | 1 |
| `definition.constructor` | Callable | `constructor_definition` | 1 |
| `definition.signal` | Value | `signal_statement` | 1 |
| `definition.enumerator` | Value | `enumerator` | 1 |
| `definition.field` | Value | `variable_statement` at file/class level | 1 |
| `definition.exported_field` | Value | `export_variable_statement` | 1 |
| `definition.onready_field` | Value | `onready_variable_statement` | 1 |
| `definition.constant` | Value | `const_statement` at file/class level | 1 |

### Carriers -- attributes folded onto the declaration at the same span

| kind | attribute | attached to | templates |
|---|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | function, constructor, signal | 3 |
| `definition.return_type_candidate` | `omega.pack.return_type` | function | 1 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | field, constant, export, onready | 4 |

`parameter_shape`, `return_type` and `visibility` are three of the five names
`production.rs` assembles a card's signature line from; `declared_type` is read
by the engine. Nothing else is carried.

### Regions

| kind | span | named by |
|---|---|---|
| `scope.class_body` | `class_definition` body | the class name |
| `scope.function_body` | `function_definition` body | the function name |

### Mentions

| kind | occurrence the host makes | from | templates |
|---|---|---|---|
| `relation.implements` | implements | `extends Node2D` | 1 |
| `relation.depends` | depends | `extends "res://a.gd"`, `preload`/`load` of a path | 2 |
| `reference.annotation` | reference | `@export`, `@onready`, `@rpc` … | 1 |
| `reference.accessor` | reference | `setget set_x, get_x` | 1 |
| `type_use.name` | reference | every `(type)` annotation | 1 |
| `call.function` | call | `move(1)` | 1 |
| `call.method` | call | `sprite.play(..)`, `.ready()` | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 90 node types. The Pack looks at 27 of them, and the untouched
list is now deliberate rather than accidental.

Untouched, and why:

- **Expressions and literals** -- `array`, `dictionary`, `pair`, `subscript`,
  `binary_operator`, `comparison_operator`, `unary_operator`,
  `conditional_expression`, `parenthesized_expression`, `await_expression`,
  `assignment`, `augmented_assignment`, `expression_statement`, `integer`,
  `float`, `true`, `false`, `null`, `string`, `escape_sequence`, `underscore`.
  A literal names nothing, and this Pack emits no `reference_context.*` kind, so
  a `literal.*` template here would suppress nothing and be dropped by the host
  (AGENT-BRIEF §5, the narrow reading of the marker rule).
- **Control flow** -- `if_statement`, `elif_clause`, `else_clause`,
  `for_statement`, `while_statement`, `match_statement`, `match_body`,
  `pattern_section`, `pattern_*`, `break_statement`, `continue_statement`,
  `pass_statement`, `return_statement`, `breakpoint_statement`. These are
  regions with no name; the old Pack made all of them `scope.*` named with their
  own whole text. Deleted, with a guard.
- **Locals** -- `pattern_binding`, the `for` loop variable, and a
  `variable_statement` inside a function body. Guarded: this grammar cannot
  distinguish a local from a property except by its parent, and every block form
  shares one `body` node.
- **Parameters** -- `typed_parameter`, `default_parameter`,
  `typed_default_parameter`, `_parameters`. A parameter is not a declaration a
  cross-file question resolves to; what a callable takes is on its card, through
  `omega.pack.parameter_shape`. The `(type)` inside a typed parameter *is*
  reached, as a type mention.
- **Scene-tree paths** -- `get_node` (`$Sprite/Label`), `node_path` (`^"a/b"`),
  `string_name` (`&"x"`). Guarded: they name nodes in a `.tscn`, which Omega
  does not index.
- **Accessor bodies** -- `get_body`, `set_body`, `getter`-as-body, `setter`. The
  GDScript 3 `setget f, g` form names two methods and is stated
  (`reference.accessor`); the GDScript 2 inline `set(v):` form declares nothing
  and names nothing.
- **Modifier and marker tokens** -- `static_keyword`, `remote_keyword`,
  `tool_statement`, `annotations`, `inferred_type`, `comment`.
  `annotations` is the wrapper; the `annotation` inside it is stated.
- **Attribute chains** -- `attribute`, `attribute_subscript`,
  `_attribute_expression`. `a.b.c` as a value read is a chain of identifiers
  this Pack cannot resolve a receiver for; the call form (`attribute_call`) is
  stated because the method name is an answer.
- **Hidden supertypes** -- `_expression`, `_primary_expression`, `_pattern`,
  `_compound_statement`, `lambda`, `enumerator_list`. A lambda's name is, in the
  grammar's own words, only for debugging.

## What is wrong with it

Measured with `pack-design/audit.py` before this rewrite:
**30 templates over 50 patterns, 19 guards**, 40 node types touched.

- **Half the file was a pasted `locals.scm`.** Lines 52--173 of the old
  `queries.scm` carried a literal nvim-treesitter provenance header
  (`provider=nvim-treesitter`, `snapshot_marker=…`, four sha256s) and then that
  project's GDScript `locals.scm` verbatim, including its `(#set! definition.
  function.scope "parent")` directives, which tree-sitter parses into a bucket
  nothing reads (Defect H's family). Every `@local.definition.*` capture in it
  was wired to a template, so the Pack's declarations were whatever an editor
  needed for highlighting a buffer, not what a question could resolve to.
- **13 node types made one nameless region.** `[ (if_statement) (elif_clause)
  (else_clause) (for_statement) (while_statement) (function_definition)
  (constructor_definition) (class_definition) (match_statement)
  (pattern_section) (lambda) (get_body) (set_body) ] @local.scope` fed
  `scope.gdscript_lexical_scope` whose **name was the capture itself** -- the
  whole body of every `if` in every file, stored as a name (D2, flagged).
  `type.gdscript_declaration_candidate` did the same with the whole
  `class_definition`, and `definition.gdscript_constructor` with the whole
  `constructor_definition`.
- **7 carriers under names nothing assembles.** `omega.pack.gdscript_direct`,
  `gdscript_declaration`, `identity`, `enclosing_owner`, `named_owner`,
  `member_owned`, `parameter_owned`. Each was computed and stored per emission
  and read by nothing. Three of them (`category`) had already been swept.
- **5 of those carriers the host would not even fold**:
  `call.gdscript_direct_candidate`, `type.gdscript_declaration_candidate`,
  `scope.enclosing_owner_candidate`, `scope.named_owner_candidate`,
  `binding.parameter_owned_candidate` all end in `_candidate` but fail
  `is_definition_kind`, so instead of attaching an attribute they were stored as
  mentions of nothing. `call.gdscript_direct_candidate` meant **every call in
  the corpus** arrived twice: once as a call, once as a reference.
- **Containment stated as a pattern (E).** Three `ownership_members` patterns
  spelled `(class_definition name: (_) body: (body (…_variable_statement name:
  (_))))` to produce `definition.member_owned_candidate` -- a carrier whose span
  was the **enclosing class**, so a class with N fields wrote one attribute N
  times onto one declaration and kept the last. `ownership_parameters` did the
  same with a function and its parameters. Four patterns to state what the tree
  already holds and the `within:` segment already carries.
- **The same construct declared twice, under two spellings (K).**
  `definition.gdscript_class_name` from `class_name_statement` and again from
  the `semantic_closure_v3_146_batch4` pass; `definition.gdscript_field`,
  `binding.gdscript_variable` and `definition.gdscript_export` all over a `var`;
  `definition.gdscript_signal` and `definition.gdscript_signal_signature` over
  one `signal`. The file scope, the class-body scope and the bare
  `variable_statement` patterns from `locals.scm` meant a single file-level
  `var` matched **three** patterns.
- **Wrong families.** `definition.gdscript_enum_member` -> Type (an enum member
  is a value); `definition.gdscript_type` -> Type for both an enum and a class,
  losing the distinction; `definition.gdscript_symbol` (a `const`) and
  `definition.gdscript_class_name` sat under kinds whose words say nothing about
  what they are. Every kind carried the redundant `gdscript_` infix.
- **A mention named with a whole node (D).** `reference.gdscript_extends` took
  its name from `(string)`, quotes included, so `extends "res://actor.gd"` was
  stored as `"res://actor.gd"` and could never match anything.
- **Not one `relation.*` kind.** Inheritance -- the one edge a GDScript
  codebase is built out of -- was a plain `reference`. `preload`/`load`, the
  other edge, was not stated at all.
- **19 guards for 30 templates (G).** Three reasons were a single token
  (`terminal_static_ceiling__gdscript_inheritance_resource_loading_and_runtime_dispatch`),
  and six more were one of two sentences -- "requires bounded source symbol
  resolution", "require view resolver evidence" -- reworded. Three named
  `bindings`, a capability whose templates emitted reference-to-nothing.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| the script's registered type | `class_name_statement` | `definition.class` | Type |
| an inner class | `class_definition` | `definition.class` | Type |
| its body | `class_definition` body | `scope.class_body` | region |
| a function or method | `function_definition` | `definition.function` | Callable |
| its parameters | `parameters` | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| its return type | `return_type:` | `definition.return_type_candidate` | `omega.pack.return_type` |
| its body | `body:` | `scope.function_body` | region |
| the constructor | `constructor_definition` | `definition.constructor` (named `_init`) | Callable |
| a signal | `signal_statement` | `definition.signal` | Value |
| its parameters | `parameters` | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| an enum | `enum_definition` | `definition.enum` | Type |
| an enum member | `enumerator` | `definition.enumerator` | Value |
| a property | `variable_statement` under `source` or a class body | `definition.field` | Value |
| an inspector property | `export_variable_statement` | `definition.exported_field` | Value |
| a tree-ready property | `onready_variable_statement` | `definition.onready_field` | Value |
| a constant | `const_statement` under `source` or a class body | `definition.constant` | Value |
| any of their declared types | `type:` | `definition.declared_type_candidate` | `omega.pack.declared_type` |
| the base class | `extends_statement (type)` | `relation.implements` | implements |
| a base script by path | `extends_statement (string)` | `relation.depends` | depends |
| a preloaded resource | `preload`/`load` first string argument | `relation.depends` | depends |
| an annotation | `annotation` | `reference.annotation` | reference |
| a property's accessors | `setget` `set:`/`get:` | `reference.accessor` | reference |
| a type mention | `type (identifier)` | `type_use.name` | reference |
| a free call | `call` | `call.function` | call |
| a method or base call | `attribute_call`, `base_call` | `call.method` | call |

Names are captured, never taken from a container. The three names built with
expressions are: the base class, reduced to its last dotted segment
(`last(split(…, "."))`) so `extends A.B` resolves onto the `class_name B`
somewhere else in the repository; and the two script paths, stripped of their
quotes (`strip_prefix`/`strip_suffix`, each a no-op when the affix is absent, so
one chain covers `"` and `'`).

## Still to decide

**The constructor's name is a literal, and the audit is right to flag it (J=1).**
`constructor_definition` has no `name` field: this grammar spells `_init` as a
keyword token of the rule, exactly as it spells `func`. The choices were to name
the constructor from its own whole node (D2 -- what the old Pack did), to leave
`func _init` undeclared, or to write the one name the language gives it. Every
GDScript constructor *is* called `_init`, so the literal is not the usual J
failure of collapsing distinct things onto one string: the constructors stay
distinct through the `within:` segment of their enclosing class, and `_init` is
the spelling a `super._init(..)` call and a card both use. It is the only
constant name in the Pack.

**`signal_statement` groups `name` and `parameters` in one repeat group** in
`node-types.json`, so a literal reading of the grammar says a signal's parameter
carrier could overwrite itself. The language allows exactly one of each, and
`audit.py`'s `carrier_owner` check does not fire on the optional capture. Noted
rather than worked around.

**`@export var` (GDScript 2) versus `export var` (GDScript 3).** The first is a
`variable_statement` carrying an `annotations` child and is declared as
`definition.field`; the second is `export_variable_statement` and is declared as
`definition.exported_field`. The `@export` annotation itself is stated either
way, so "which fields are exported" is answerable in both dialects, but through
two different facts. Unifying them would need a predicate on the annotation's
name from the variable's pattern, which no single pattern can express here.
