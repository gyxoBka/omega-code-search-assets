# omega-javascript

Language `omega-javascript`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

45 templates over 31 query patterns, 49 distinct node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 2 |
| `calls` | yes | 3 |
| `definitions` | yes | 14 |
| `imports` | yes | 7 |
| `modules` | yes | 8 |
| `references` | yes | 4 |
| `scopes` | yes | 7 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 2 |
| `definition.generator_function` | Callable | 1 |
| `definition.method` | Callable | 2 |
| `definition.class` | Type | 2 |
| `definition.field` | Value | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 5 |

`parameter_shape` is one of the five names `declared_signature` assembles a
card's signature line from, and each of the five is emitted with the
declaration's own span, so it folds onto the function, generator, method or
object-property function it describes.

### Regions

- `scope.function_body` (5) -- a function declaration, a generator, a
  function or arrow bound to a name, a method, an object-property function
- `scope.class_body` (2) -- a class declaration or expression, and a class
  bound to a name

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.constructor` | call | 1 |
| `reference.decorator` | reference | 1 |
| `reference.component` | reference | 2 |
| `import.module` | binding | 3 |
| `import.default` | binding | 1 |
| `import.namespace` | binding | 1 |
| `import.symbol` | binding | 2 |
| `binding.import_alias` | binding | 1 |
| `module.export` | binding | 4 |
| `module.default_export` | binding | 2 |
| `module.namespace_export` | binding | 1 |
| `module.reexport` | binding | 1 |
| `binding.export_alias` | binding | 1 |

No `literal.*` template is emitted: the Pack states no `reference_context.*`
kind, so a literal marker here would suppress nothing (see 00-INDEX).

### Coverage guards

Seven, each a sentence naming a limit of the language rather than a confidence
tier: dynamic call targets, property reads, function-body bindings, which
module-level bindings are declared, module specifier resolution, computed
exports, and the absence of declared types.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 118 node types. The Pack looks at 49 of them.

Untouched, and why:

- **Control flow and statements** -- `if_statement`, `else_clause`,
  `for_statement`, `for_in_statement`, `while_statement`, `do_statement`,
  `switch_statement`, `switch_body`, `switch_case`, `switch_default`,
  `try_statement`, `catch_clause`, `finally_clause`, `throw_statement`,
  `return_statement`, `break_statement`, `continue_statement`,
  `labeled_statement`, `statement_identifier`, `empty_statement`,
  `debugger_statement`, `with_statement`, `expression_statement`,
  `sequence_expression`. None of these names anything a question resolves to.
- **Operators and expression plumbing** -- `binary_expression`,
  `unary_expression`, `update_expression`, `ternary_expression`,
  `assignment_pattern`, `augmented_assignment_expression`,
  `parenthesized_expression`, `spread_element`, `subscript_expression`,
  `optional_chain`, `yield_expression`, `meta_property`, `super`, `this`,
  `undefined`.
- **Binding patterns** -- `array_pattern`, `object_pattern`, `pair_pattern`,
  `rest_pattern`, `object_assignment_pattern`,
  `shorthand_property_identifier_pattern`. These introduce names, and they are
  the subject of a coverage guard: a destructured name is a local, and a
  repository has more of them than of every declaration put together.
- **Literal internals** -- `escape_sequence`, `string_fragment`, `regex_flags`,
  `regex_pattern`, `template_substitution`, `html_character_reference`,
  `jsx_text`.
- **Comments and the shebang** -- `comment`, `html_comment`, `hash_bang_line`.
  A JSDoc block is a comment; reading `@param` out of one is a second grammar
  the Pack does not have.
- **Supertype aliases the grammar never produces as nodes** -- `declaration`,
  `expression`, `pattern`, `primary_expression`, `statement`.
- **Deliberately left** -- `import_attribute` (`with { type: "json" }` states a
  loader, not a name), `computed_property_name` (its text is an expression, not
  a name), `jsx_attribute` and `jsx_expression` (a prop name resolves to
  nothing outside the component's own declaration), `class_static_block`.

## What is wrong with it

Measured on the Pack as found: **187 templates over 213 patterns, 72 guards,
84 node types touched**, and `python pack-design/audit.py omega-javascript`
reported 100 flagged templates across six classes.

**52 templates named an emission with the whole node they span (D2), and six
more with a container (D).** `call.call` took its name from the entire
`call_expression`, so every call in the corpus was stored under a name that is
the call with its arguments -- `fetch(url, {method: "POST", headers})` as a
single name string. `control.await` and `control.yield` did the same with the
whole awaited expression, `definition.generator_function` with the whole
function including its body, and `value.object` and `value.array` with the
entire object or array literal. These are the rows that made a repository index
296 MB: an object literal stored as a name is the document repeated once per
level of nesting.

**Thirteen carriers the host will not fold, and fourteen under a name nothing
assembles.** `control.for_await_candidate`, `call.target_candidate`,
`type.javascript_declaration_candidate`, `scope.enclosing_owner_candidate`,
`module.export_alias_candidate` and `import.alias_candidate` all end in
`_candidate` but fail `is_definition_kind`, so none was folded onto anything;
each fell through to the mention branch and was stored as a reference to
nothing. Of the sixteen carriers in the Pack exactly **one**,
`definition.parameter_shape_candidate`, used a name the engine reads.
`omega.pack.category`, `omega.pack.identity`, `omega.pack.target`,
`omega.pack.named_owner`, `omega.pack.enclosing_owner` were computed and stored
per emission and read by nothing.

**Two `relation.*` kinds the host does not know.** `relation.extends` and
`relation.jsx_expression` strip to `extends` and `jsx_expression`, neither of
which is one of the six the host compares against, so both arrived as plain
references -- `extends` in particular, which is the one inheritance edge
JavaScript has, was indistinguishable from any other identifier mention.
`relation.extends` was also emitted under capability `definitions`.

**Thirteen guards whose reason was a single token.**
`javascript_async_runtime_ordering_unavailable`,
`terminal_static_ceiling__javascript_destructuring_binding_surface`,
`javascript_eval_generated_definitions_unavailable` and ten more are generator
confidence tiers, not limits a caller can act on. 72 guards for a Pack that
programs ten capabilities is a label per pattern family, not a statement of
what cannot be seen.

**Fifty-three "context" kinds spelling a tree shape in their name.** The `data`
capability alone carried
`data.ecmascript_assignment_export_nested_object_array_object_field_context`,
`data.ecmascript_call_object_array_object_string_identifier_context`,
`data.ecmascript_call_three_level_object_string_context` and eighteen siblings
-- each a query pattern three and four edges deep, matching once per tuple of
nodes at that depth, to state containment the tree already holds (defect E).
The `calls` capability had twelve more of the same shape
(`call.ecmascript_nested_member_string_identifier_context`), all of which the
host reduces to the same occurrence as the plain `call.call` beside them. Fifty-three
of the Pack's 187 templates -- more than a quarter -- are one of these.

**Forty-seven reference kinds, one occurrence.** `reference.assignment_lhs`,
`reference.assignment_rhs`, `reference.binary_operand`,
`reference.unary_operand`, `reference.update_operand`, `reference.condition`,
`reference.conditional_value`, `reference.initializer`,
`reference.default_value`, `reference.return_value`, `reference.throw_value`,
`reference.spread_value`, `reference.template_expression`,
`reference.identifier` -- every syntactic position an identifier can occupy,
each emitted as a mention, all arriving at the host as the same plain
reference. This is the identifier of every file stored once per position it
appears in, and `reference.identifier` is defect I in all but name.

**A framework overlay.** `test.test_call` and `test.test_member_call` matched
`^(test|it|describe|suite)$` and
`^(test|it|describe|suite|beforeEach|afterEach|beforeAll|afterAll)$`. Those are
Jest and Mocha call names, not JavaScript: the language has no test convention
of its own, unlike Python's `test_` prefix. Both are removed and the `tests`
capability with them.

**Six `value_origin.*` kinds under an unread capability idea.**
`value_origin.top_level_const_string`, `_number`, `_true`, `_false`, `_null`,
`_alias` were emitted under `bindings` with kinds starting `value_`, which
`is_definition_kind` excludes outright; they became references to a literal's
own text. What they were reaching for -- *what is this module-level name set
to* -- is now answered by `definition.variable` over the declarator, whose span
carries the value without storing it a second time.

**`types` was declared for one template.** `type.javascript_declaration_candidate`
was the whole of the `types` capability, and it is an unfoldable carrier under
an unread name. JavaScript declares no types; the capability is gone.

## What it should extract

JavaScript is written as modules of functions, classes and module-level values.
The questions asked of a file are: *where is this function, class, method or
value defined*, *what does this file import and what does a short alias stand
for*, *what does this file export*, *what does this class extend*, *who calls
this*, *what is applied to this declaration*, and *which component is rendered
here*.

| what | node | emitted as | family |
|---|---|---|---|
| a function | `function_declaration` | `definition.function` + `scope.function_body` | Callable |
| a generator | `generator_function_declaration` | `definition.generator_function` + `scope.function_body` | Callable |
| a function or arrow bound to a name | `variable_declarator` with a function value | `definition.function` + `scope.function_body` | Callable |
| its parameter list | `formal_parameters`, or an arrow's bare `parameter` | `definition.parameter_shape_candidate` on the declaration | `omega.pack.parameter_shape` |
| a class | `class_declaration`, `class` | `definition.class` + `scope.class_body` | Type |
| a class bound to a name | `variable_declarator` with a `class` value | `definition.class` + `scope.class_body` | Type |
| what it extends | `class_heritage` via `identifier` / `member_expression` | `relation.implements` | implements |
| a method | `method_definition` (class body or object literal) | `definition.method` + `scope.function_body` | Callable |
| a class field | `field_definition` via `property_identifier` | `definition.field` | Value |
| a function held by an object key | `pair` with a function value | `definition.method` + `scope.function_body` | Callable |
| a module-level value | `lexical_declaration` / `variable_declaration` under `program` or `export_statement` | `definition.variable` | Value |
| what a file imports | `import_statement` `source:`, `call_expression` of `import`, `require("x")` | `import.module` | binding |
| a default import | `import_clause` `identifier` | `import.default` | binding |
| a namespace import | `namespace_import` | `import.namespace` | binding |
| a named import | `import_specifier` without `alias` | `import.symbol` | binding |
| an aliased import | `import_specifier` with `alias` | `import.symbol` + `binding.import_alias` carrying `target` | binding |
| a named export | `export_specifier` without `alias` | `module.export` | binding |
| an aliased export | `export_specifier` with `alias` | `module.export` + `binding.export_alias` carrying `target` | binding |
| a re-export | `export_statement` `source:` | `module.reexport` | binding |
| `export * as ns` | `namespace_export` | `module.namespace_export` | binding |
| `export default name` | `export_statement` `value:` | `module.default_export` | binding |
| `exports.x = `, `module.exports.x = ` | `assignment_expression` with `#eq?` | `module.export` | binding |
| `module.exports = name` | `assignment_expression` with `#eq?` | `module.default_export` | binding |
| a call | `call_expression` `function:` | `call.function`, `call.method` | call |
| a construction | `new_expression` `constructor:` | `call.constructor` | call |
| a decorator | `decorator` | `reference.decorator` | reference |
| a JSX component | `jsx_opening_element`, `jsx_self_closing_element`, capitalised | `reference.component` | reference |
| everything else | control flow, operators, literals, comments, patterns | nothing | -- |

Three design decisions are worth stating outright, because they are what the
old Pack got wrong in bulk:

1. **A mention is the bytes that name the thing, never the construct.** Every
   mention above spans an identifier or a property identifier. Nothing spans a
   `call_expression`, an `object`, an `array`, an `await_expression` or a whole
   function.
2. **Containment is a region, not a pattern.** Two scope kinds replace the
   fifty-three "context" patterns; the only parent chain left in the file is
   the `program` / `export_statement` filter that distinguishes a module-level
   binding from a local, which costs one match per declarator rather than one
   per tuple.
3. **A function's identity is the name it is bound to.** JavaScript writes most
   of its functions as anonymous expressions in a declarator or an object key,
   so the declaration is emitted over the binding and named from the binding.

## What omega-tsx and omega-typescript must copy

omega-tsx is a port of this Pack and of omega-typescript, and the three have to
agree or the same construct answers to a different kind depending on which
extension a file has. The decisions to carry over verbatim:

- **Kinds.** `definition.function`, `definition.generator_function`,
  `definition.method`, `definition.class`, `definition.field`,
  `definition.variable`; `scope.function_body`, `scope.class_body`;
  `relation.implements` for `extends` (and for TypeScript's `implements`);
  `call.function`, `call.method`, `call.constructor`; `reference.decorator`;
  `reference.component`; `import.module`, `import.default`, `import.namespace`,
  `import.symbol`; `binding.import_alias`, `binding.export_alias`;
  `module.export`, `module.default_export`, `module.namespace_export`,
  `module.reexport`.
- **Carrier names.** Only `parameter_shape`, and for TypeScript additionally
  `return_type`, `type_parameter_shape` and `visibility` -- the names
  `declared_signature` assembles. No `category`, `identity`, `target`,
  `named_owner` or `enclosing_owner`.
- **Alias attribute.** An alias binding carries its original under the
  attribute name `target`, not `source` or `name`.
- **Quote stripping.** A module specifier is stated without its quotes, both
  `"` and `'`, so an import resolves against the same string a re-export
  writes.
- **The JSX capital-letter rule.** Only a tag whose name matches `^[A-Z]` is
  emitted as `reference.component`. A lowercase tag is an HTML element name and
  resolves to nothing. omega-tsx must not widen this.
- **Capabilities**: `bindings`, `calls`, `definitions`, `imports`, `modules`,
  `references`, `scopes`. omega-typescript and omega-tsx add `types` because
  TypeScript has type annotations to state; neither should add `data` or
  `tests`.
- **What is deliberately not stated**, and must stay not stated so the three
  agree: property reads, destructured names, parameters as names of their own,
  locals below module level, control flow, literals, JSX attributes, JSX text,
  comments and JSDoc, and any test-runner call shape.

TypeScript-only constructs (`interface`, `type_alias_declaration`, `enum`,
`namespace`, `abstract_class_declaration`, type annotations) are omega-tsx's
and omega-typescript's business, not a port of anything here; note only that
`definition.interface` lands in Type now that the host matches whole words.

## Still to decide

1. **`definition.method` for an object-literal key.** A handler table
   (`{ onClick: () => {} }`) declares something a question can reach, but a
   large options object full of arrow callbacks declares a dozen methods named
   `onSuccess`, `onError`, `transform`. Provisionally declared, because the
   alternative is that most React and Node code declares nothing between the
   module-level const and the class; revisit against the row count.
2. **CommonJS `require`.** It is a call shape, not a syntax form, and it is
   matched with `#eq?` on the callee name. It is kept here because CommonJS is
   JavaScript's other module system rather than one library's API -- a Node
   file written before ESM names every one of its dependencies this way. If the
   line is drawn at "no call shapes in a language Pack", the three `exports`
   patterns and the `require` pattern go together, and a
   `frameworks/omega-framework-commonjs` overlay takes them.
3. **A module-level binding with no initialiser** (`let cache;`) is not
   declared, which loses a real if uncommon declaration. Declaring it would
   need a second pattern whose only distinguishing feature is the absence of a
   field; left out and guarded instead.
