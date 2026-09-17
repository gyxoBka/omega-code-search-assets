# omega-twig

Language `omega-twig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. The tables below describe the Pack as it now stands.

## What it states today

15 templates over 14 query patterns, 24 of the grammar's 47 named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 6 |
| `imports` | yes | 4 |
| `references` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.macro_function` | Callable | 1 |
| `definition.template_block` | Value | 1 |
| `definition.template_variable` | Value | 1 |
| `definition.loop_variable` | Value | 1 |
| `definition.parameter` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |

### Regions

None. See **A grammar with no blocks** below; it is the reason.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 1 |
| `import.twig_path` | binding | 2 |
| `import.alias` | binding | 1 |
| `import.symbol` | binding | 1 |
| `call.template_function` | call | 1 |
| `reference.filter` | reference | 1 |
| `reference.twig_test` | reference | 1 |
| `reference.context_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 47 node types. The Pack looks at 24 of them.

Untouched, and why:

- `template`, `statement_directive`, `content`, `comment` -- the file, the
  `{% %}` wrapper, raw HTML and comments. Containment and punctuation.
- `binary_expression`, `unary_expression`, `ternary_expression`,
  `test_expression`, `operator`, `binary_operator`, `conditional` as a value --
  expression shape. An operator names nothing.
- `array`, `hash`, `hash_key`, `hash_value`, `boolean`, `null`, `number` --
  literal data written inline, most often the `with { ... }` payload of an
  include. Nothing resolves onto a hash key, and `literal.*` emissions would
  suppress nothing here because this Pack emits no `reference_context.*` kind.
- `arguments`, `argument`, `argument_name`, `argument_value` -- what is passed
  to a call. The call itself is stated; its arguments are values.
- `arrow_function` -- the `x => x.y` form accepted only inside a filter
  argument (`|filter(x => ...)`). Its parameter is local to that one expression.
- `attribute` -- not an attribute in any useful sense: the grammar aliases the
  keywords `with`, `only` and `ignore missing` of an include to this node type.
  The shipped Pack emitted every one of them as `data.twig_attribute` named
  `with` or `only`.

## A grammar with no blocks

`template` is a flat `repeat(choice(statement_directive, output_directive,
comment, content))`. `{% block content %}` and `{% endblock %}` are two sibling
`statement_directive` nodes with everything between them as further siblings.
There is no node whose extent is a block, a macro body or a loop body.

Three consequences, all of them stated as guards rather than faked:

- No `scope.*` is emitted. The shipped Pack emitted four, and each of them
  spanned only the opening tag -- `scope.twig_block_boundary` was the
  `{% block x %}` directive, not the block.
- Nothing this Pack declares is recorded as being inside anything else, so the
  host's `within:` namespace segment is empty for every Twig declaration. A
  macro parameter and a `{% set %}` name are file-level facts.
- The end tags carry nothing. `{% endblock %}` was emitted as
  `data.twig_block_end` named `endblock`: one mention per block in the
  repository, all with the same name, resolving to nothing.

## What is wrong with it

Counted against the Pack as found: **19 templates over 18 patterns, 7 guards,
19 node types touched.**

**M -- the Pack declared no block, in any file.** The block pattern was
`(tag_statement (tag) @t (name) @n)` with `#eq? @t "block"`. `tag_statement` is
`seq(tag, repeat($._expression))` and `name` is not among its children: the
block's name is an `identifier` aliased to `variable`. The pattern bound
nothing, so `definition.twig_block` and `scope.twig_block_boundary` both
emitted nothing, ever, while the manifest declared `definitions` and `scopes`.
The one thing a `.twig` file is asked about most -- which template overrides
which block -- was the one thing the Pack could not answer. (This is defect M
in the brief; the validator does not catch it, because `name` does exist
somewhere in the grammar.)

**D2 -- five names were the whole node they span.** `binding.symbol` named
itself from `(parameter)`, so `{% macro f(value = 'x') %}` declared a binding
called `value = 'x'`. `data.twig_variable` named itself from `(variable)`,
`call.twig_candidate` from `(function_call)` -- the whole `path('app_home')`
including its arguments -- and `import.twig_candidate` from the whole
`{% import ... as ... %}` statement.

**D -- three more names were a quoted string.** `import.twig_path`,
`import.twig_from_path` and `import.twig_template_relation` took the `(string)`
node's own text, quotes included, so every template path in the index was
`'base.html.twig'` and could never match anything spelled without quotes.

**Carriers that carry nothing.** `call.twig_candidate` and
`import.twig_candidate` end in `_candidate` but start with `call.` and
`import`, which `is_definition_kind` excludes, so neither is folded; each fell
through to the mention branch. And had they folded, `carried_name` is `twig`,
which nothing assembles: `omega.pack.twig`.

**K2 -- one span, two kinds.** `@twig.block.definition` fed both
`definition.twig_block` and `scope.twig_block_boundary` with the same name
expression. Neither fired (see M), but the shape is the defect.

**I -- every identifier in every file.** `(variable) @variable` at pattern root
is this grammar's general identifier node: `user`, `user.name`, `loop.index`,
every operand of every expression in every template, stored as
`data.twig_variable`. Two more of the same shape, `(test)` and `(attribute)`,
were inherited from an nvim-treesitter `highlights.scm` baseline and still
carried its provenance header.

**Nine templates whose kind was `data.*` and whose occurrence was a plain
reference.** `data.twig_macro` restated the macro that `definition.twig_macro`
already declared, at a different span. `data.twig_attribute` named the keyword
`with`. `data.twig_block_end` named `endblock`.

**Wrong-side declarations.** `definition.twig_macro` -> words
`[definition, twig, macro]`, none of them a family word, so a Twig macro --
a callable that is imported and called by name -- was filed as a **Value**.
`definition.twig_block` the same, which is right for a block but was arrived at
by accident.

**Bindings that resolve to nothing.** `binding.twig_set`, `binding.twig_for`
and `binding.twig_macro_parameter` are mentions, not declarations: the host
turns each into a *reference* named `page`, `user`, `value`. So `{% set page %}`
and `{{ page }}` were both references, and neither had a declaration to resolve
onto. This is what the `bindings` capability bought.

**G -- a guard whose reason is a label.** `binding_nodes_are_syntactic_
candidates_not_resolved_values`. Of the other six, three restated in three
different sentences that a call target may be dynamic, and one asserted that
the release compile gate runs.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a block a child template may override | `tag_statement` with tag `block`, first `variable` | `definition.template_block` | Value |
| a macro | `macro_statement` + `method` | `definition.macro_function` | Callable |
| the macro's parameter list | `parameters`, folded onto the macro's span | `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` |
| a macro parameter | `parameter`, named up to `=` | `definition.parameter` | Value |
| a name `{% set %}` introduces | `assignment_statement`, variable after the keyword | `definition.template_variable` | Value |
| a name `{% for %}` introduces | `for_statement`, variable after `for` | `definition.loop_variable` | Value |
| the template this one extends, includes, embeds or uses | `tag_statement` with tag in that set + string | `relation.depends` (field `path`) | depends |
| the template `{% import %}` / `{% from %}` names | `import_statement` / `from_statement` + string | `import.twig_path` (field `path`) | binding |
| the local alias `{% import ... as x %}` gives it | `import_statement` + `name` | `import.alias` | binding |
| the macro `{% from ... import x %}` takes | `from_statement` + `name` after `import` | `import.symbol` | binding |
| a function or macro call | `function_call` + `function_identifier` | `call.template_function` | call |
| a filter applied | `filter` + `filter_identifier` | `reference.filter` | reference |
| a test applied | `test` | `reference.twig_test` | reference |
| a value read from the render context | head `variable` of an output directive, a loop's sequence, a condition | `reference.context_variable` | reference |

Three naming decisions carry the resolution:

- **A template path is unquoted.** `'base.html.twig'` becomes
  `base.html.twig`, in the name and in the `path` field. Double-quoted strings
  are `interpolated_string` in this grammar, not `string`; both are taken.
- **A call target is reduced to its last dot segment.** `{{ forms.input(x) }}`
  after `{% import "forms.html.twig" as forms %}` is a call to the macro
  `input`, and `input` is how the other template declares it. A plain
  `{{ path('x') }}` is unaffected. The alias `forms` is stated separately as
  `import.alias`, so nothing is lost by dropping it from the call name.
- **A context variable is reduced to its first dot segment.** `{{ user.name }}`
  and `{{ user.email }}` both state that this template needs `user`, which is
  the unit the controller supplies and the unit a `{% set %}` or a `{% for %}`
  in the same file can declare.

## Still to decide

**`{% set %}` and `{% for %}` names are declarations, not bindings.** Every
other Pack with real lexical scopes emits a local under `bindings` as
`binding.*`, which the host makes a *reference*. That is right where a resolver
can tie a reference to its binder. Twig has no scopes in this grammar (above),
so a `binding.*` here is a mention with nothing to resolve onto -- exactly what
the shipped Pack produced. Declaring them instead makes `{{ page }}` resolve
onto `{% set page = ... %}` in the same template, which is the answer someone
wants. The cost is a `Value` declaration per loop variable in a corpus; Twig
templates are small and the trade is worth it. The `bindings` capability is
therefore not declared at all.

**`import.twig_path` keeps its old spelling on purpose.** The kind is
language-prefixed where the rest of this Pack is not, and it is kept because
`frameworks/omega-framework-symfony` matches on exactly that string with a
`path` field. Renaming it would break a framework overlay for cosmetics.

## The one audit class left open

```
carrier that may overwrite itself      1
      definition.parameter_shape_candidate: (parameters) repeats inside (macro_statement)
```

This is the known false positive the audit labels as such. `repeats_in()`
unions a node's whole `multiple` child group, and `macro_statement` has one
group holding `tag`, `method` and `parameters`; the grammar rule is
`seq(alias('macro', $.tag), alias($._name, $.method), optional($.parameters))`,
so a macro statement holds at most one `parameters`. The carrier cannot
overwrite itself.
