# omega-tsx

Language `omega-tsx`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

TSX is TypeScript plus JSX. The Pack is therefore
`packs/omega-typescript/` with one section added, and the rest of this document
says what that section is and where it departs from the TypeScript Pack.

## What it states today

60 templates over 40 query patterns, 62 distinct node types, 10 guards.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 6 |
| `calls` | yes | 3 |
| `definitions` | yes | 36 |
| `imports` | yes | 3 |
| `modules` | yes | 1 |
| `references` | yes | 4 |
| `scopes` | yes | 6 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.interface` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.namespace` | Namespace | 1 |
| `definition.ambient_module` | Namespace | 1 |
| `definition.function` | Callable | 2 |
| `definition.method` | Callable | 1 |
| `definition.method_signature` | Callable | 1 |
| `definition.field` | Value | 2 |
| `definition.property` | Value | 1 |
| `definition.constant` | Value | 1 |
| `definition.variable` | Value | 1 |

`interface`, `namespace` and `alias` are Type and Namespace words in the host's
current vocabulary (whole-word matching, `entity_family`); this is the fix for
defect A, which the old Pack carried six times.

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 4 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 7 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 7 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 3 |

Four names, all four of them read by `declared_signature` in
`omega-runtime/src/build/production.rs`. Every carrier's span is the
declaration it describes, never the enclosing class.

### Regions

- `scope.class_body` (1)
- `scope.interface_body` (1)
- `scope.function_body` (2)
- `scope.namespace_body` (2)

None of them ends in a word that also reads as a declaration.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.constructor` | call | 1 |
| `import.module` | binding | 2 |
| `import.symbol` | binding | 1 |
| `binding.import_default` | binding | 1 |
| `binding.import_namespace` | binding | 1 |
| `binding.import_alias` | binding | 3 |
| `binding.export_alias` | binding | 1 |
| `module.export` | binding | 1 |
| `reference.decorator` | reference | 1 |
| `reference.jsx_component` | reference | 1 |
| `reference.jsx_attribute` | reference | 1 |
| `type_use.name` | reference | 1 |

`relation.implements` is the only `relation.*` kind, and it is one of the six
the host knows. `extends` and `implements` are both stated as it: the host has
one subtype edge.

### Emitted, dropped as mentions, but read as span markers

None. The Pack emits no `reference_context.*` kind, so a `literal.*` span would
suppress nothing; the two the old Pack had (`literal.jsx_text`,
`literal.html_character_reference`) were one match per text run in every file
for an emission the host then drops, and they are gone.

## What is wrong with it

Measured on the Pack as found: **196 templates over 273 query patterns, 80
coverage guards**, against 58 over 35 with 8 for the same language without JSX.

- **D / D2 -- the name is the whole node (82 by the audit, and every one of the
  nine JSX templates).** `value.jsx_element` took its name from `@jsx.element`,
  which was the whole `jsx_element`: the entire markup subtree, opening tag,
  children and closing tag, stored as the *name* of an emission, once per
  element in every `.tsx` file in the repository. `value.jsx_self_closing_element`,
  `structure.jsx_opening_element`, `structure.jsx_closing_element`,
  `value.jsx_attribute`, `relation.jsx_expression` and `reference.jsx_expression`
  did exactly the same thing with their own container. Outside JSX,
  `data.object`, `data.array`, `data.string`, `call.member`, `binding.parameter`
  and `definition.import_alias` were the same defect. This is the single largest
  producer of index bytes in the Pack, and none of those names could ever
  resolve to anything.
- **Not one JSX emission resolved by name.** `<Counter />` is a use of the
  `Counter` declared in another file; the old Pack stated the tag as a slab of
  text and the component's name appeared nowhere. The one answer JSX adds was
  the one answer missing.
- **50 kinds named after the generator, not the language**:
  `call.ecmascript_nested_member_string_identifier_context`,
  `data.ecmascript_assignment_export_three_level_object_string_context`,
  `reference.typescript_class_decorator_object_array_identifier_context`. These
  are shapes of a particular library's configuration call spelled as a query,
  three and four levels deep -- defect E and defect L in one kind. 31 of them
  sat under capability `data` and stated fields of object literals reached
  through nested `pair` chains.
- **Defect L, with the denial attached.** 11 comment lines asserting
  "Framework-neutral" and one capture spelled `framework_neutral`, over
  patterns that match a decorator's metadata object down to its array items.
- **Four `relation.*` kinds the host does not know** -- `relation.assignment`,
  `relation.augmented_assignment`, `relation.extends`, `relation.jsx_expression`
  -- each stored as a plain reference with a long name.
- **25 templates under one kind, `type.syntax`**, restating that a piece of type
  syntax is type syntax, plus `type.alias`, `type.annotation`, `type.arguments`,
  `type.conditional`, `type.interface`, `type.parameters`, `type_arguments.list`,
  `type_parameter.declaration`, `type_parameters.list`. A type mention reaches a
  `type_identifier` at any depth; one capture states them all.
- **18 carriers under names nothing assembles** (`omega.pack.category`,
  `identity`, `target`, `enclosing_owner`, `export_alias`, `alias`) and **12
  carriers the host will not fold at all** (`call.target_candidate`,
  `import.alias_candidate`, `reference.member_access_candidate` and the rest fail
  `is_definition_kind`, so they were stored as references to nothing).
- **25 guards whose reason was a single token**, e.g.
  `terminal_static_ceiling__typescript_overload_resolution`, out of 80.
- **K2: `@module.namespace` emitted twice**, as `module.namespace` and
  `module_relation.namespace`, same span and same name.
- **Three capabilities declared for noise**: `data` (31 templates of nested
  object-literal shapes), `implements` (the relation-coverage capability, which
  needs no template of its own here) and `tests` (one `test.declaration` that
  matched a call named `test` or `describe` -- a runner's shape, not a
  TSX construct).

## What it should extract

Everything omega-typescript extracts, in the same words, plus the three rows
marked **JSX**.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a class | `class_declaration`, `abstract_class_declaration` | `definition.class` | Type |
| its type parameters, extent | same match | `definition.type_parameter_shape_candidate`, `scope.class_body` | carrier, region |
| what it extends or implements | `extends_clause`, `implements_clause`, `extends_type_clause` | `relation.implements` | implements |
| an interface | `interface_declaration` | `definition.interface` | Type |
| a type alias | `type_alias_declaration` | `definition.type_alias` | Type |
| an enum, and its members | `enum_declaration`, `enum_assignment`, `enum_body` | `definition.enum`, `definition.constant` | Type, Value |
| a function, with or without a body | `function_declaration`, `generator_function_declaration`, `function_signature` | `definition.function` | Callable |
| its parameters, return type, extent | same match | `definition.parameter_shape_candidate`, `definition.return_type_candidate`, `scope.function_body` | carrier, region |
| a method, with or without a body | `method_definition`, `method_signature`, `abstract_method_signature` | `definition.method`, `definition.method_signature` | Callable |
| a field, a property, a parameter property | `public_field_definition`, `property_signature`, `required_parameter`/`optional_parameter` with an accessibility modifier | `definition.field`, `definition.property` | Value |
| a module-scope name | `variable_declarator` under `program`/`export_statement`/`ambient_declaration`/a module body | `definition.variable` | Value |
| a namespace, an ambient module | `internal_module`, `module` | `definition.namespace`, `definition.ambient_module` | Namespace |
| what the file imports | `import_statement`, `import_clause`, `import_specifier`, `import_require_clause`, `import_alias`, `require(...)`, `import(...)` | `import.module`, `import.symbol`, `binding.import_*` | binding |
| what the file exports | `export_specifier`, `export_statement`, `namespace_export` | `module.export`, `binding.export_alias` | binding |
| a call | `call_expression`, `new_expression` | `call.function`, `call.method`, `call.constructor` | call |
| a decorator | `decorator` | `reference.decorator` | reference |
| a type, at any depth | `type_identifier` | `type_use.name` | reference |
| **JSX** -- a component used as a tag | `jsx_opening_element`/`jsx_self_closing_element` `name:` a capitalised `identifier` | `reference.jsx_component` | reference |
| **JSX** -- a dotted component tag | the same `name:` a `member_expression`, reduced to its last segment | `reference.jsx_component` | reference |
| **JSX** -- a prop passed to a component | `jsx_attribute`'s first `property_identifier`, under a component tag | `reference.jsx_attribute` | reference |

### Where this departs from omega-typescript

1. **Three new patterns' worth of JSX, and nothing else changed.** The kinds,
   the carrier names, the guards and the capability set are the TypeScript
   Pack's, deliberately: a `.ts` file and a `.tsx` file in one project declare
   the same vocabulary, and an answer must not change shape because a component
   happens to live in the file. 58 templates become 60 and 35 patterns become
   40.
2. **A lowercase tag is not stated.** JSX resolves a tag by its case: `<div>` is
   an intrinsic element, a string the runtime hands to the DOM, and it names no
   declaration in any TypeScript file in the project. Stating it would be one
   mention per tag in every file resolving to nothing, and intrinsic tags are
   the majority of tags. The case test is `#match? "^[A-Z]"`, one of the six
   predicates the runtime applies. A dotted tag needs no test: an intrinsic
   element cannot be spelled with a dot.
3. **The closing tag is not stated.** It names the same component at the same
   call site as the opening tag and would double every count.
4. **An attribute is stated only on a component tag.** `step` in
   `<Counter step={2}/>` resolves to the `step` declared in that component's
   props type, which this Pack emits as `definition.property`. `className` on a
   `<div>` resolves to nothing. This is narrower than it looks: it is the same
   reasoning by which omega-typescript declines to emit a bare
   `member_expression` property read.
5. **`jsx_expression` is not stated.** `{...}` is a hole in the markup; what it
   holds is ordinary TypeScript and is already covered by the call, type and
   import patterns. The container itself names nothing.
6. **`jsx_text` and `html_character_reference` are not stated.** See the marker
   note above: with no `reference_context.*` kind in the Pack, a `literal.*`
   emission suppresses nothing and is discarded.
7. **A component is not declared as a component.** It is declared as the
   `function` or `variable` the grammar gives it, and a tag resolves onto that.
   See *Still to decide*.

## Still to decide

- **Is a component tag a reference or a call?** `<Counter/>` compiles to a call
  of `Counter`, and `call.component` would put components into the call graph,
  which would answer "what does this screen render" through the same machinery
  as "what does this function call". It is stated as a reference here because
  JSX defers the invocation and the host's `call` occurrence carries a claim
  about control flow that the source does not make. Both spellings resolve by
  the same name, so this is reversible without touching anything else.
- **Should a component be declared as its own kind?** An agent asking "what
  components does this package export" is asking a real question, and the
  answer is not in the index: a component is an ordinary `function` or `const`
  and the family is Callable or Value. Detecting one means matching a function
  whose body returns markup, which in practice returns a conditional, a
  fragment or a call to another component, so the pattern would be both
  fragile and deep -- and *component* is a Value word in `entity_family`
  anyway. Left undone rather than done badly.
- **`definition.constant` for an enum member** is Value. There is no word in the
  host's vocabulary for an enum member that puts it under the enum's own Type
  family; inherited from omega-typescript unchanged.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 191 node types. The Pack looks at 62 of them.

Untouched, and why the classes of them are untouched:

- **Statements and control flow** (`if_statement`, `for_statement`,
  `while_statement`, `switch_statement`, `try_statement`, `return_statement`,
  `throw_statement`, and the rest): the questions are about what a file
  declares, imports and calls, not about its control flow. A function's extent
  is already one region.
- **Expression forms** (`binary_expression`, `ternary_expression`,
  `arrow_function`, `await_expression`, `yield_expression`,
  `subscript_expression`, `template_string`, `regex`, `object`, `array`,
  `number`, `string`, `true`, `false`, `null`): a literal or an operator names
  no declaration. `arrow_function` and `function_expression` are reached through
  the `variable_declarator` that names them.
- **Type syntax** (`union_type`, `intersection_type`, `conditional_type`,
  `mapped_type_clause`, `infer_type`, `tuple_type`, `array_type`,
  `literal_type`, `predefined_type`, `type_arguments`, `type_parameter`, …):
  every name written inside any of them is a `type_identifier`, and one capture
  states them all. `predefined_type` is deliberately excluded -- `string` and
  `number` resolve to no declaration.
- **Binding patterns** (`object_pattern`, `array_pattern`, `rest_pattern`,
  `pair_pattern`, `assignment_pattern`, `shorthand_property_identifier_pattern`):
  a destructured name is not declared, by the guard on `definitions`.
- **Anonymous type members** (`call_signature`, `construct_signature`,
  `index_signature`): there is no name to declare them under, by the guard on
  `definitions`.
- **JSX interior** (`jsx_element`, `jsx_closing_element`, `jsx_expression`,
  `jsx_text`, `jsx_namespace_name`, `html_character_reference`): see items 3, 5
  and 6 above.
- The rest are supertypes the query never needs to name (`expression`,
  `statement`, `declaration`, `pattern`, `type`, `primary_expression`,
  `primary_type`), `comment`, `html_comment`, `hash_bang_line`, and flow-typed
  annotation forms the TypeScript dialect does not produce
  (`flow_maybe_type`, `existential_type`, `adding_type_annotation`,
  `omitting_type_annotation`, `opting_type_annotation`).

## What the audit says

`python pack-design/audit.py omega-tsx` reports zero in every class: D, D2, F,
G, H, I, I2, J, K, K2, M, capability mismatch, unfoldable carrier,
self-overwriting carrier, unassembled carrier, dead marker, unknown relation,
scope-that-is-also-a-declaration, unread pattern.
