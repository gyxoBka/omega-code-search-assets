# omega-python

Language `omega-python`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

28 templates over 20 query patterns, 25 distinct node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 2 |
| `definitions` | yes | 9 |
| `imports` | yes | 6 |
| `references` | yes | 2 |
| `scopes` | yes | 2 |
| `tests` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 2 |

All three are among the five names `declared_signature` assembles a card's
signature line from, and all three take the *declaration's* span, so a class
with forty methods does not have one attribute written onto it forty times.

### Regions

- `scope.class_body` (1) -- the `block`, named by the class
- `scope.function_body` (1) -- the `block`, named by the function

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.global` | reference | 1 |
| `binding.import_alias` | binding | 2 |
| `binding.nonlocal` | reference | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `import.from_module` | binding | 1 |
| `import.module` | binding | 2 |
| `import.symbol` | binding | 3 |
| `reference.decorator` | reference | 1 |
| `relation.implements` | implements | 1 |
| `relation.tests` | tests | 2 |
| `type_use.name` | reference | 1 |

Two attributes are stored, both captured, neither constant:
`binding.import_alias` carries `module` (what `import numpy as np` binds `np`
to) and `target` (what `from x import y as z` binds `z` to). Those two are the
answer to the only Python question that needs an attribute rather than a span.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 129 node types. The Pack looks at 25 of them.

The Pack it replaced looked at 80, and that number was the defect, not the
achievement: most of the difference is node types it reached by emitting one
mention per `if_statement`, per `integer`, per `binary_operator`, per `slice`,
named with the whole node's own text and resolving against nothing -- 74 such
templates, by the audit's count. A node type is
covered when the Pack says something about it that a question can reach. An
expression node names nothing, so there is nothing to say.

Untouched, grouped by why:

**Expressions, operators and literals** -- `await`, `binary_operator`,
`boolean_operator`, `comparison_operator`, `conditional_expression`,
`unary_operator`, `not_operator`, `subscript`, `slice`, `chevron`,
`parenthesized_expression`, `parenthesized_list_splat`, `list_splat`,
`dictionary_splat`, `string`, `string_content`, `string_start`, `string_end`,
`concatenated_string`, `interpolation`, `escape_sequence`,
`escape_interpolation`, `format_expression`, `format_specifier`,
`type_conversion`, `integer`, `float`, `true`, `false`, `none`, `ellipsis`,
`list`, `set`, `tuple`, `dictionary`, `pair`, `comment`, `line_continuation`.
None of them names anything. A mention of `(x + 1)` is the text `x + 1`.

**Control flow and statements** -- `if_statement`, `elif_clause`,
`else_clause`, `while_statement`, `for_statement`, `try_statement`,
`except_clause`, `except_group_clause`, `finally_clause`, `with_statement`,
`with_clause`, `with_item`, `return_statement`, `raise_statement`,
`assert_statement`, `break_statement`, `continue_statement`, `pass_statement`,
`delete_statement`, `exec_statement`, `print_statement`, `yield`,
`expression_list`, `augmented_assignment`. These say where control goes, not
what anything is called.

**Comprehensions and lambdas** -- `list_comprehension`, `set_comprehension`,
`dictionary_comprehension`, `generator_expression`, `for_in_clause`,
`if_clause`, `lambda`, `lambda_parameters`. They bind names, but only inside
themselves.

**Patterns** -- `pattern`, `pattern_list`, `tuple_pattern`, `list_pattern`,
`splat_pattern`, `list_splat_pattern`, `dictionary_splat_pattern`,
`as_pattern`, `case_pattern`, `case_clause`, `class_pattern`, `dict_pattern`,
`keyword_pattern`, `union_pattern`, `complex_pattern`, `match_statement`.
Destructuring targets: all function-local. See **Still to decide**.

**Parameter node types** -- `parameter`, `default_parameter`,
`typed_parameter`, `typed_default_parameter`, `keyword_separator`,
`positional_separator`. Reached through `(parameters)` as one span, because the
parameter list is a signature component and not a set of names.

**Type node types the alternation does not name** -- `union_type`,
`constrained_type`, `splat_type`. Each of them wraps further `type` nodes,
which the annotation pattern matches on its own, so `int | None` yields `int`
and `None` without a pattern for the union.

**Supertypes and hidden nodes** -- `_compound_statement`, `_simple_statement`,
`expression`, `primary_expression`. Not addressable.

**The rest** -- `decorated_definition` (its decorators and its definition are
each matched directly), `keyword_argument`, `named_expression`,
`wildcard_import`, `import_prefix` (inside `relative_import`, which is
captured whole).

## What is wrong with it

These are counts against the Pack as it was found: **165 templates over 152
patterns, 71 guards, 80 node types**.

**At least eight patterns encode a named framework's call shape** (Defect L),
each under a comment asserting the opposite -- "Framework-neutral", "No framework
meaning is assigned", "framework semantics are interpreted later". They are not
neutral; they are a library's API spelled as a tree so that no literal gives it
away:

- `canvas_binary_context` matches `a.s() | b.s()` and filters the member name
  with `(#match? ... "^(s|si|signature)$")`. That is Celery's canvas.
- `import_bound_value_graph_context` carries three patterns whose comments name
  their variables `keras`: `k.Input(...)`, `k.layers.Dense(...)(inputs)`,
  `k.Model(inputs=..., outputs=...)`.
- `class_self_registration_context` filters on
  `^(register_buffer|register_parameter|add_module)$` -- `torch.nn.Module`.
- `class_method_self_member_call_context` is a PyTorch `forward`, and
  `framework_neutral_python_settings_and_class_fields_v1` names its own
  examples `models.CharField(...)` and `sa.Column(...)`: Django and SQLAlchemy.
- `mapping_context`'s comment is `task_routes = {"tasks.add": {"queue": ...}}`,
  a Celery setting.

The repository has `frameworks/omega-framework-pytorch`,
`omega-framework-django`, `omega-framework-celery` and
`omega-framework-pydantic`. This is where all of it belongs.

**Twenty-two patterns reach across statements to state a dataflow fact.**
Sixteen are rooted at `(module ...)` with two or three sibling children -- an
`import_statement`, then a `function_definition`, then an
`expression_statement` -- and six more at `(class_definition ...)` reaching
down through `block > function_definition > block > expression_statement >
assignment > call`. Tree-sitter matches sibling children independently, so each
of the sixteen costs one match per *tuple*: a module with 30 imports and 200
top-level statements produces 6 000 match attempts for one pattern. This is
Defect E in its most expensive form -- containment and adjacency hard-coded to
reach across a file, to state a dataflow fact that the resolver exists to
derive.

**Seventy-four templates name an emission with the whole node they span**
(Defect D2, the audit's largest class here): `reference.async_await` stores the
entire `await` expression as a name, `reference.function_definition_candidate`
the entire function body, `call.direct` and `call.member` the whole call with
its arguments, `control.control_if` a whole `if`/`elif`/`else` chain. A `name`
is what a question resolves against; none of these can be resolved against
anything.

**Nine of those are literal templates that were not even dropped.** The `data`
capability emitted `data.string`, `data.integer`, `data.float`, `data.boolean`,
`data.none`, `data.list`, `data.set`, `data.tuple` and `data.dictionary`, each
named from the whole literal. `retain_named_spans` drops `data` emissions whose
kind starts with `literal.`; these start with `data.`, so every string, number
and collection literal in every Python file was stored as a *reference* whose
name is its own text -- and since the Pack emitted no `reference_context.*`
kind, the parallel `literal.*` captures in the same patterns suppressed nothing
either (`ROLE_PREFIX`, `emission_roles.rs:54`). Two matches per literal, one
row per literal, nothing asking for it.

**Twenty-two declaration kinds are a sentence, not a construct.**
`definition.python_class_method_self_member_call_three_identifier_context`,
`definition.python_import_bound_member_call_literal_keyword_context`,
`definition.python_from_import_constructor_keyword_identifier_list_context`.
Eight of them contain the word `class` and are filed by `entity_family` as
**types** although what they declare is a local variable bound by a call; three
more contain `constructor` and were filed as types by Defect B, and now that
the host matches whole words they fall to Value -- still not Callable. Not one
of these kinds is a thing a Python programmer would name.

**Thirteen carriers were written onto the wrong span** (the "carrier folded
onto its owner" class): `definition.category_candidate` and
`definition.identity_candidate` take `@definition.category.owner` -- the whole
class or function -- as their span and a name from inside it, and
`scope.enclosing_owner_candidate` does the same. Worse, they carry names the
host does not read: only `visibility`, `type_parameter_shape`,
`parameter_shape`, `return_type` and `modifier` build a card's signature, so
`category`, `identity`, `enclosing_owner`, `named_owner`, `parameter_owned` and
`path_origin` were computed and stored and never shown.

**Eleven carriers could not fold at all.** `import.alias_candidate`,
`import.target_candidate`, `import.module_path_candidate` and
`import.path_origin_candidate` begin with `import`, which
`is_definition_kind` excludes outright, so none of them is a carrier; each
arrived as a binding occurrence named after a module path.
`reference.async_for_candidate`, `reference.async_with_candidate`,
`reference.function_definition_candidate` and `call.target_candidate` fail the
same test through the `reference`/`call.` prefixes.

**Two of the four regions named the whole file or an unnamed body.**
`scope.module` took `(module)` as its span *and* as its name, so every Python
file was stored once under its entire text; `scope.lambda` did the same with a
lambda body. (`scope.function` and `scope.class` -- the region that is also a
declaration -- had already been renamed to `_body` by the cross-Pack sweep
00-INDEX.md records, so this Pack no longer carried that trap.) The two regions
that survive here take the `block` as their span and the declaration's name as
their name.

**Twenty-eight of 71 guards give a token instead of a reason** (Defect G):
`terminal_static_ceiling__python_descriptor_dispatch`,
`depth_completion_high_confidence_ast_fact`,
`terminal_static_ceiling__python_comprehension_scope_resolution`. Most of the
other 43 describe the bounds of one of the framework patterns above
(`module_level_import_alias_plus_binding_to_same_alias_direct_member_call_with_flat_identifier_list_only`),
which is a limitation of the pattern, not of Python.

**And the two questions Python actually turns on were unanswered.** Nothing
stated what a class inherits: `class_definition superclasses:` was captured
only as `(argument_list) @class.base_arguments`, whose template named the whole
argument list, and as two framework-shaped patterns that required the base to
come from a from-import in the same file. And nothing linked a test to what it
tests: `test.function` and `test.class` were declarations named after
themselves, so `test_parse_header` was a Test entity called
`test_parse_header` with no edge to `parse_header`.

## What it should extract

Python's names that cross a file boundary are: what a module declares at the
top level, what a class declares in its body, what a file imports and under
what alias, what a class inherits, what decorates a declaration, what is
called, what an annotation says, and which test covers which name.

| what | node | emitted as | family |
|---|---|---|---|
| a class | `class_definition` via `name:` | `definition.class` | Type |
| its body | `class_definition` via `body:` | `scope.class_body` | region |
| its type parameters | `type_parameters:` | `type_parameter_shape` carrier | attribute |
| what it extends | `superclasses: (argument_list)` via `identifier` / `attribute` | `relation.implements` | implements |
| a function or method | `function_definition` via `name:` | `definition.function` | Callable |
| its body | `function_definition` via `body:` | `scope.function_body` | region |
| its parameters | `parameters:` | `parameter_shape` carrier | attribute |
| its return annotation | `return_type:` | `return_type` carrier | attribute |
| its type parameters | `type_parameters:` | `type_parameter_shape` carrier | attribute |
| a type alias | `type_alias_statement` via `left:` | `definition.type_alias` | Type |
| a module-level name | `module > expression_statement > assignment` via `left:` | `definition.variable` | Value |
| a class-level name | `class_definition > block > assignment` via `left:` | `definition.field` | Value |
| a decorator | `decorator` via its last `identifier` | `reference.decorator` | reference |
| a plain call | `call function: (identifier)` | `call.function` | call |
| a method call | `call function: (attribute attribute:)` | `call.method` | call |
| an annotation | `type` via `identifier` / `attribute` / `generic_type` / `member_type` | `type_use.name` | reference |
| `import a.b` | `import_statement name: (dotted_name)` | `import.module` | binding |
| `import a.b as c` | `import_statement > aliased_import` | `import.module` + `binding.import_alias` carrying `module` | binding |
| `from a.b import ...` | `import_from_statement module_name:` | `import.from_module` | binding |
| `from a import c` | `import_from_statement name: (dotted_name)` | `import.symbol` | binding |
| `from a import c as d` | `import_from_statement > aliased_import` | `import.symbol` + `binding.import_alias` carrying `target` | binding |
| `from __future__ import x` | `future_import_statement name:` | `import.symbol` | binding |
| `global x` | `global_statement (identifier)` | `binding.global` | reference |
| `nonlocal x` | `nonlocal_statement (identifier)` | `binding.nonlocal` | reference |
| `def test_parse_header` | `function_definition` with `^test_.` | `relation.tests` named `parse_header` | tests |
| `class TestParser` | `class_definition` with `^Test.` | `relation.tests` named `Parser` | tests |
| every expression, literal, statement and comprehension | -- | nothing | -- |

The whole of it is 20 patterns. Nineteen are rooted at one node type; the two
that reach two edges deep (`module > expression_statement > assignment` and
`class_definition > block > assignment`) walk a fixed path through single-child
fields, so each costs one match per top-level statement, not one per tuple.

Three things the rewrite gains that the old Pack did not have at all:

1. **Inheritance resolves.** `class Serializer(BaseModel)` now emits
   `relation.implements` named `BaseModel`, reduced to the last identifier when
   it is written `pkg.BaseModel`, so it is spelled the way `definition.class
   BaseModel` is spelled.
2. **An alias says what it stands for.** `import numpy as np` declares the
   binding `np` with the attribute `module = numpy`. Asking what `np` is no
   longer requires reading the file.
3. **A test points at what it tests.** `test_parse_header` emits
   `relation.tests` named `parse_header`; `TestParser` emits `relation.tests`
   named `Parser`. The host maps exactly `relation.tests` onto the tests
   occurrence, so this is the one edge Python's naming convention gives away
   for free, and the old Pack spent three templates not taking it.

### Why the audit is not zero

`pack-design/audit.py` reports **three** D2 flags and nothing else:

```
import.module names itself from the whole (dotted_name)
import.symbol names itself from the whole (dotted_name)
import.symbol names itself from the whole (dotted_name)
```

A `dotted_name` is `a.b.c`: it has named children only because the grammar
splits the path on its dots, and its text is exactly the name of the thing
imported. Reducing it to a single segment would destroy the module path, which
is the whole content of an import, and `from x import Foo` gives a
`dotted_name` of one identifier whose text is already `Foo`. The rule the
check encodes -- a name taken from a node with named children is a subtree
stored as a name -- is right everywhere else; here the node is a path and the
path is the name. This is the one class the Pack leaves standing, deliberately.

## Still to decide

1. **`match` statements.** `case Point(x=px, y=py)` binds `px` and `py`, and
   `class_pattern`'s `dotted_name` is a genuine mention of `Point` that would
   resolve. The binding half is function-local and excluded by the same rule
   as every other local; the `Point` half is a real reference the Pack does not
   yet state. Left out because `match` is rare enough in indexed code that one
   more pattern is not yet paid for; revisit if it stops being rare.
2. **`self.x = ...` in `__init__`.** These are the instance fields of most
   Python classes, and an agent asking what a class holds gets only the
   class-body assignments today. Stating them means asserting that `self` is
   the enclosing class, which is a convention, not a rule -- `self` is just the
   first parameter's name. It would be one pattern rooted at `class_definition`
   reaching three edges down, filtered with `(#eq? @receiver "self")`. Held
   back as the one place this Pack would have to guess.
3. **`__all__`.** A module's export list is a `definition.variable` named
   `__all__` whose strings are not read. Making each string an export mention
   would answer "what does this package expose", but every other string in the
   language stays unread and the exception would have to earn itself.
4. **Attribute reads.** `conn.timeout` is not emitted; only the callee position
   is. If measurement later shows that member reads are asked for often enough
   to be worth a mention that resolves against every same-named declaration in
   the repository, the pattern is one line. The guard says so.
