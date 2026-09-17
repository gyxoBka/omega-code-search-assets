# omega-ruby

Language `omega-ruby`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten 2026-09-17. `version` 1.0.0 -> 2.0.0. The tables below describe the
Pack as it is now; **What is wrong with it** records what was replaced.

## What it states today

31 templates over 23 query patterns, 26 node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `data` | yes | 6 |
| `definitions` | yes | 13 |
| `imports` | yes | 1 |
| `references` | yes | 5 |
| `scopes` | yes | 5 |

`bindings` and `modules` are no longer declared: nothing in the Pack programs
them. A Ruby module is a declaration and is stated under `definitions`, where
`entity_family` puts `definition.module` in Namespace.

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.module` | Namespace | 1 |
| `definition.method` | Callable | 2 (`def`, `define_method`) |
| `definition.singleton_method` | Callable | 1 |
| `definition.alias_method` | Callable | 1 |
| `definition.attribute_method` | Callable | 1 |
| `definition.constant` | Value | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

Each is emitted with the *declaration's* span, so the fold finds an owner.
Each kind contains `definition`, so it passes `is_definition_kind` and is
actually folded.

| kind | attribute | attaches to | templates |
|---|---|---|---|
| `definition.superclass_candidate` | `omega.pack.superclass` | `definition.class` | 1 |
| `definition.parameters_candidate` | `omega.pack.parameters` | `definition.method`, `definition.singleton_method` | 2 |
| `definition.receiver_candidate` | `omega.pack.receiver` | `definition.singleton_method` | 1 |

### Regions

| kind | span | named by |
|---|---|---|
| `scope.class_body` | the `class` node | the class name |
| `scope.module_body` | the `module` node | the module name |
| `scope.method_body` | the `method` / `singleton_method` node | the method name |
| `scope.singleton_class_body` | the `singleton_class` node | its `value` (`self`, a constant) |

None contains `definition` and none ends in `.type/.function/.class/.method/
.trait`, so none is also read as a declaration.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 2 (superclass, `include`/`extend`/`prepend`) |
| `call.method` | call | 1 |
| `import.require` | binding | 1 |
| `reference.constant` | reference | 1 |
| `reference.method` | reference | 1 (the target of `alias`) |
| `reference.variable` | reference | 1 (`@x`, `@@x`, `$x`) |

`relation.implements` is the only `relation.*` kind in the Pack and it is one
of the six the host knows.

### Emitted, dropped as mentions, but read as span markers

Not waste: these are discarded from the IR, and their spans then tell the host
that a role boundary sitting exactly on them is a literal, not a name.

- `literal.number` (2 -- `integer`, `float`)
- `literal.boolean` (2 -- `true`, `false`)
- `literal.null` (1 -- `nil`)
- `literal.string` (1 -- named from `string_content`, not from the `string` node)

## What is wrong with it

This is what the Pack said before the rewrite: **54 templates over 87
patterns, 33 coverage guards**, built by concatenating four generator passes
(`external-helix-tags`, `external-nvim-treesitter-locals`, `upstream_tags`,
`p0-exact-helix-*`) with a set of hand-written "context" patterns. Measured:

- **Nine carriers the host would never fold** (`call.target_candidate`,
  `module.ruby_candidate`, `scope.enclosing_owner_candidate`,
  `import.alias_candidate`, `reference.ruby_identifier_candidate`,
  `scope.named_owner_candidate`, and three more). None contains `definition`,
  so `is_definition_kind(kind) && is_carrier_kind(kind)` was false for all of
  them and every one fell through to the mention branch and was stored as a
  reference to nothing. `module.ruby_candidate` did it with the whole `module`
  node as its name.
- **One `relation.*` the host does not know**: `relation.inherits_candidate`,
  declared under the `imports` capability, named with the whole `class` node.
  It arrived as a plain reference whose name was the source of the class.
- **Defect D, one template**: `literal.string` named from `(string)`, storing
  every string literal in the repository, quotes and interpolation included, as
  a name.
- **Defect G, one guard reason that is a label**
  (`ruby_upstream_tags_are_syntax_candidates_only`), and 32 more guards that
  are sentences only in the typographic sense: `category_is_syntactic_from_ast_
  node_kind`, `overload selection and compile-time callable/type dispatch
  remain compiler semantics` (Ruby has no compile-time dispatch), five separate
  guards saying the same thing about "bounded source symbol resolution". 33
  guards for a Pack that stated eight kinds of declaration.
- **Four declaration kinds duplicated under a `ruby_` prefix**:
  `definition.ruby_class` beside `definition.class`, `definition.ruby_method`
  beside `definition.method`, `definition.ruby_module`, `definition.ruby_type`,
  `definition.ruby_function`, `definition.ruby_namespace`, `call.ruby_call`
  beside `call.call`. Twelve declaration kinds for four Ruby constructs, every
  construct emitted two or three times at the same span under different names,
  and `definition.module` / `definition.namespace` landing in Value.
- **Defect E, containment as a pattern, in its most expensive form.** Sixteen
  of the 87 patterns were "block-call ownership contexts": `(call ... block:
  (block body: (block_body (call ... (string (string_content)))))))` and five
  variants, each matching once per (outer call, inner call, label) tuple, to
  emit a mention named with a string literal. Two more,
  `ruby_class_association_explicit_target_context` and
  `ruby_class_qualified_super_block_string_context`, hard-coded four-edge tree
  shapes.
- **Defect L, a framework overlay.** Those same two patterns are ActiveRecord.
  `class Post < ApplicationRecord` with `belongs_to :author, class_name:
  "Admin::User"` is written out as the example in the query file, under a
  comment claiming the pattern is "framework-neutral". A macro call with a
  symbol and a `class_name:` string option is Rails' association DSL and
  belongs in `frameworks/`, not in the language Pack.
- **Sixteen near-identical `ownership_parameters` patterns** -- `(method name:
  (_) parameters: (method_parameters (block_parameter) @owned.parameter))` once
  per parameter node type, twice over for `singleton_method` -- feeding one
  template, `binding.parameter_owned_candidate`, another carrier the host would
  not fold.
- **Every bare identifier emitted as a call.** `[(identifier) (constant)] @name
  @reference.call` at top level, plus `(identifier) @local.reference`, made
  every local variable read in every Ruby file a call mention and a reference
  mention. The Pack's own last guard admits it: *"the query that claimed to
  (`#is-not?` local) never ran"* -- Defect H, since removed repository-wide.
- **`(call method: (_) @call.target) @call.expression`** captured the callee of
  every call including operators, and stored it as `call.target_candidate` with
  the whole call expression as its span.

Net effect: a Ruby file produced declarations of `Foo` two or three times over,
a mention for every identifier token, carriers that were stored as references
to nothing, and one region kind (`scope.lexical`) emitted twice under two names
for every method, class, block and lambda.

## What it should extract

Ruby's constructs, the node each comes from, and the fact stated about it.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a class | `class` | `definition.class` | Type |
| its extent | `class` | `scope.class_body` | region |
| what it inherits | `class` `superclass:` | `definition.superclass_candidate` | folded to `omega.pack.superclass` |
| the inheritance edge | the superclass `constant` | `relation.implements` | implements |
| a module | `module` | `definition.module` | Namespace |
| its extent | `module` | `scope.module_body` | region |
| a method | `method` | `definition.method` | Callable |
| a singleton method (`def self.x`) | `singleton_method` | `definition.singleton_method` | Callable |
| its receiver | `singleton_method` `object:` | `definition.receiver_candidate` | folded to `omega.pack.receiver` |
| its parameter list | `method_parameters` | `definition.parameters_candidate` | folded to `omega.pack.parameters` |
| a method body's extent | `method`, `singleton_method` | `scope.method_body` | region |
| `class << self` | `singleton_class` | `scope.singleton_class_body` | region |
| `alias new old` | `alias` `name:` | `definition.alias_method` | Callable |
| the aliased method | `alias` `alias:` | `reference.method` | reference |
| `attr_accessor :x` and friends | `call` + `simple_symbol` | `definition.attribute_method` | Callable |
| `define_method :x` | `call` + `simple_symbol` | `definition.method` | Callable |
| `include` / `extend` / `prepend` | `call` + `constant` | `relation.implements` | implements |
| `require` / `require_relative` / `load` | `call` + `string_content` | `import.require` | binding |
| a method call | `call` `method:` | `call.method` | call |
| a constant used | `constant` | `reference.constant` | reference |
| `FOO = ...`, `FOO ||= ...` | `assignment`, `operator_assignment` | `definition.constant` | Value |
| `@x = `, `@@x = `, `$x = ` | `assignment`, `operator_assignment` | `definition.variable` | Value |
| `@x`, `@@x`, `$x` read | `instance_variable`, `class_variable`, `global_variable` | `reference.variable` | reference |
| a literal | `integer` `float` `nil` `true` `false` `string` | `literal.*` | dropped; span is a marker |

Three design decisions worth stating:

1. **A qualified name is reduced to its last constant.** `class A::B` is
   declared as `B`, and `include A::B` references `B`, so a mention and a
   declaration are spelled the same way and can meet. The alternative -- the
   full `A::B` text -- would never match the bare `B` that most call sites use.
   The cost is in a coverage guard.
2. **Calls are stated only where the grammar says `call`.** A receiverless,
   argumentless Ruby call is an `identifier` node, the same node a local
   variable read produces. Emitting those was the largest single source of
   noise in the old Pack. It is now a coverage guard instead.
3. **Parameters are carried, not emitted.** The old Pack emitted one binding
   per parameter, resolving to nothing. The parameter list is a signature
   component; it belongs in the declaration's bag.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 149 node types. The Pack looks at 26.

The old Pack looked at 46, but twenty of those were parameter and assignment
shapes (`block_parameter`, `optional_parameter`, `destructured_parameter`,
`rest_assignment`, `left_assignment_list`, …) captured only to feed
`binding.var` and `binding.parameter_owned_candidate`, neither of which
resolved to anything. The number went down because the questions went up.

Untouched, and the reason:

- **Control flow** -- `if`, `unless`, `while`, `until`, `for`, `case`,
  `case_match`, `when`, `in_clause`, `else`, `elsif`, `then`, `break`, `next`,
  `redo`, `retry`, `return`, and the `*_modifier` forms. These name nothing; a
  question about them is a question about a span, which the enclosing method
  region already gives.
- **Pattern matching** -- `array_pattern`, `hash_pattern`, `find_pattern`,
  `as_pattern`, `alternative_pattern`, `keyword_pattern`, `test_pattern`,
  `if_guard`, `unless_guard` and the `_pattern_*` hidden types. The constants
  inside them are reached by `(constant)`; the binders they introduce are local
  variables.
- **Parameter and assignment shapes** -- `block_parameter`, `keyword_parameter`,
  `optional_parameter`, `splat_parameter`, `hash_splat_parameter`,
  `destructured_parameter`, `forward_parameter`, `lambda_parameters`,
  `block_parameters`, `left_assignment_list`, `rest_assignment`,
  `destructured_left_assignment`, `right_assignment_list`. Deliberate: a
  parameter or a destructured local is not a thing another file can name. The
  method's parameter list is carried whole on the declaration instead.
- **Composite values** -- `array`, `hash`, `pair`, `range`, `regex`,
  `string_array`, `symbol_array`, `chained_string`, `bare_string`,
  `bare_symbol`, `delimited_symbol`, `hash_key_symbol`, `character`,
  `complex`, `rational`, `heredoc_*`, `interpolation`, `escape_sequence`,
  `subshell`, `uninterpreted`. Values, not names. The scalar literals that are
  emitted are emitted only as span markers.
- **Bodies and wrappers** -- `program`, `body_statement`, `block_body`,
  `begin`, `parenthesized_statements`, `do`, `_statement`, `_expression` and
  the other hidden `_` types. The Pack states the extent of the four
  constructs that own one; the rest is punctuation.
- **Blocks** -- `block`, `do_block`, `lambda`, `block_argument`. A judgement
  call, recorded under **Still to decide**.
- **Exception handling** -- `rescue`, `ensure`, `exceptions`,
  `exception_variable`, `rescue_modifier`, `begin_block`, `end_block`. The
  exception classes are `constant` nodes and are already referenced; the
  rescue variable is a local.
- **Operators and receivers** -- `binary`, `unary`, `operator`,
  `operator_assignment` as an expression, `element_reference`, `self`, `super`,
  `yield`, `undef`, `setter`, `_call_operator`. `self` and `super` name nothing
  distinct per occurrence: emitting them would store the string `super` once
  per call site and collapse every one onto it (Defect J in effect, if not in
  form). `element_reference` (`a[b]`) is a call to `[]` and would be stored
  under that name; the same objection applies.
- **`comment`, `encoding`, `line`, `file`, `empty_statement`** -- no fact.

## Still to decide

- **Blocks as regions.** `do ... end` and `{ ... }` are Ruby's unit of
  closure, and a region per block would let a question ask which closure a line
  is in. They are also the most common node in idiomatic Ruby, so one region
  per block is a large number of regions for a distinction that the enclosing
  method region usually already makes. Left out; the decision should be
  revisited against a real corpus rather than by argument.
- **Convention-named tests.** `def test_foo` inside a `Minitest::Test`
  subclass is a test, and `tests` is a capability the host understands. But
  the convention belongs to minitest and Test::Unit, not to Ruby, and RSpec's
  `describe`/`it` certainly does. Both are `frameworks/` work; the language
  Pack declares them as ordinary methods.
- **Visibility.** `private` with no arguments sets a mode over the remainder
  of a class body. A Pack states facts about spans and cannot carry that state
  across siblings. `private def foo` and `private :foo` could be stated; the
  bare form cannot, and stating only half of it would be worse than a guard
  saying so. It is a guard.

## Coverage guards

Seven, each a sentence about Ruby: the bare-identifier call, the constant that
is emitted as a reference in its own declaring header, metaprogramming beyond
`define_method` and `attr_*`, visibility, `$LOAD_PATH`, non-constant mixins,
and the reduction of qualified names to their last constant.
