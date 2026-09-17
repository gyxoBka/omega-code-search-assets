# omega-groovy

Language `omega-groovy`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

26 templates over 22 query patterns, 14 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `data` | yes | 1 |
| `definitions` | yes | 17 |
| `implements` | yes | 1 |
| `imports` | yes | 1 |
| `references` | yes | 2 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.config_block` | Config | 1 |
| `definition.config_entry` | Config | 1 |
| `definition.function` | Callable | 2 |
| `definition.package` | Namespace | 1 |
| `definition.parameter` | Value | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.type_parameter` | Type | 1 |
| `definition.variable` | Value | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | attaches to | templates |
|---|---|---|---|
| `definition.declared_type_candidate` | `omega.pack.declared_type` | `definition.variable`, `definition.parameter` | 1 |
| `definition.label_candidate` | `omega.pack.label` | `definition.config_block` | 1 |
| `definition.modifier_candidate` | `omega.pack.modifier` | class, field, callable | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | `definition.function` | 2 |
| `definition.return_type_candidate` | `omega.pack.return_type` | `definition.function` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | `definition.class` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | class, field, callable | 1 |

Every carrier is emitted on the span of a node that another template declares,
so each one folds. None of them is emitted at the evidence's own span.

### Regions

- `scope.class_body` (1) -- the closure that is a class body
- `scope.function_body` (1) -- the closure that is a method body

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `import.package` | binding | 1 |
| `reference.annotation` | reference | 1 |
| `reference.type` | reference | 1 |
| `relation.implements` | implements | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 65 node types. The Pack looks at 27 of them.

Untouched, and why:

- Operators and expression plumbing, which name nothing a question resolves to:
  `access_op`, `assignment`, `binary_op`, `unary_op`, `ternary_op`,
  `increment_op`, `index`, `pipeline`\*, `return`, `assertion`.
- Literals and their pieces: `boolean_literal`, `number_literal`, `null`,
  `string_internal_quote`, `escape_sequence`, `interpolation`, `list`, `map`.
  (`map_item` is reached; the `map` that holds it is not, since the entries are
  the facts.) No `literal.*` or `control_flow.*` template exists here and none
  is needed: this Pack emits no role emission over a literal's span, so there
  is nothing for a literal marker to suppress.
- Control flow: `if_statement`, `for_loop`, `for_parameters`, `while_loop`,
  `do_while_loop`, `switch_statement`, `switch_block`, `case`, `try_statement`,
  `break`, `continue`. A branch declares nothing and references nothing.
  (`for_in_loop` **is** reached, because it binds a name.)
- Documentation and trivia: `comment`, `groovy_doc`, `groovy_doc_at_text`,
  `groovy_doc_param`, `groovy_doc_tag`, `groovy_doc_throws`, `first_line`,
  `shebang`.
- `source_file`, which is the file and needs no fact of its own.

The remaining node types are all reached: `closure` as a class or method body,
`parameter_list` and `argument_list` inside their callables and calls, and
`identifier`, `dotted_identifier`, `builtintype`, `array_type`,
`type_with_generics`, `string` and `string_content` as the pieces the names
above are taken from.

\* `pipeline` is the one untouched node that carries meaning. See
**Still to decide**.

## What is wrong with it

This section describes the Pack as it was found, at version 1.0.0: **35
templates over 39 patterns, 34 coverage guards.**

**Seven carriers the host will not fold, and two that had nothing to fold
onto.** `call.target_candidate`, `import.groovy_candidate`,
`module.groovy_candidate`, `type.groovy_declaration_candidate`,
`scope.enclosing_owner_candidate`, `scope.named_owner_candidate` and
`module.declaration_path_candidate` all end in `_candidate` but fail
`is_definition_kind` -- they start with `call.`, `import`, or contain no
`definition` and end in none of the five suffixes. Each was stored as a
reference to nothing instead of an attribute. Separately,
`definition.member_category_candidate` and `definition.member_owned_candidate`
were emitted with `@owner.span`, the *class's* span, while naming the member;
both folded onto the class declaration as `member_category` and
`member_owned`, overwriting each other once per member.

**Eight templates named an emission with a whole node.**
`definition.groovy_class` was named from `@definition.class`, the whole
`class_definition`; `definition.groovy_function` from the whole
`function_definition`; `call.groovy_function_call` from the whole call;
`binding.groovy_parameter` from the whole `parameter`;
`import.groovy_candidate`, `module.groovy_candidate` and
`type.groovy_declaration_candidate` from the whole `groovy_import`,
`groovy_package` and `class_definition`; `scope.lexical` from the whole
`function_definition`. `audit.py` only flags the containers in its own list, so
it reported none of these -- but a name that is `public static void main(String[] args) { ... }`
answers nothing, and the correct name capture was bound in the very same
pattern.

**Three framework overlays, forbidden by §6 of the contract.** The
`nextflow_dsl_context` block encodes Nextflow's `workflow`/`process` shape
(three patterns, three templates); `spock_class_method_context` encodes Spock
specifications (two patterns, two templates), and one of its own coverage
guards says so out loud -- "Spock interpretation remains framework overlay
semantics"; `literal_nested_calls` hard-codes a three-deep Jenkins/Gradle
`owner("name") { container { nested } }` tree, costing one match per tuple at
that depth to produce two mentions.

**An `(identifier) @local.reference` pattern over the whole file.** Every
identifier in every Groovy file -- every type name, every call target, every
field access segment, every parameter -- became a `reference.local` mention
named after itself. That is Defect I in all but spelling: not `(_)`, but the
single most common named node in the grammar.

**Duplicated work.** `class_definition` was the root of **ten** separate
patterns: `completeness_types_high_confidence`, `declaration_category_class`,
one each in `declaration_modifiers` and `declaration_visibility`,
`enclosing_owner_hints`, `member_category_class`, `ownership_members`,
`priority_semantics`, `signature_type_parameters`, and two in
`spock_class_method_context`. `function_call` was the root of four patterns and
`juxt_function_call` of six. Parameters were emitted three times over
(`binding.parameter`, `binding.groovy_parameter`, `binding.groovy_parameter_full`)
under three kinds that all became plain references.

**`type_relation.groovy_extends` was not a relation and `type_reference.groovy_type`
was not a type.** The host knows six `relation.*` kinds; neither of these is
even spelled `relation.`, so the inheritance edge -- the one cross-file link a
Groovy class has -- arrived as a plain reference named after the *subclass*,
with the superclass buried in a field nothing reads. `type_reference.groovy_type`
was declared under capability `definitions`, so a type use was filed with the
declarations.

**`data.groovy_closure` over `(closure)` was read by no template.** Reported by
the audit as "pattern nothing reads": one match per closure in every file, for
nothing. (The Pack also declared `binding.groovy_declaration` and
`binding.groovy_for_variable` as mentions, so a field, a local and a loop
variable were references to nothing rather than declarations a reference could
resolve to.)

**34 coverage guards for 35 templates, one of them a label.**
`groovy_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`
is Defect G. Most of the rest are the same sentence in nine variations --
"requires bounded source symbol resolution", "remain compiler semantics",
"remain runtime semantics" -- said once per template rather than once per real
limitation.

Counts, before to after: templates 35 to 26, patterns 39 to 22, guards 34 to 5,
grammar node types reached 19 to 27.

## What it should extract

Groovy in a real project is Gradle build scripts, Jenkins pipelines, Spock
specifications and JVM glue. The questions asked are *what does this file
declare*, *what type does it name*, *what does it call*, *what block
configures this*, and *what does it import or inherit from*.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| the package | `groovy_package` | `definition.package` | Namespace |
| an import | `groovy_import` (`import:`) | `import.package` | binding |
| `import a.b.C as D` | `groovy_import` (`import_alias:`) | `definition.type_alias` | Type |
| a class | `class_definition` (`name:`) | `definition.class` | Type |
| its body | `class_definition` (`body:`) | `scope.class_body` | region |
| its type parameters | `generic_parameters` | `type_parameter_shape_candidate` carrier | attribute |
| `extends` / `implements` | `class_definition` (`superclass:`) | `relation.implements` | implements |
| a type parameter | `generic_param` (`name:`) | `definition.type_parameter` | Type |
| a method with a body | `function_definition` | `definition.function` | Callable |
| a method without one | `function_declaration` | `definition.function` | Callable |
| its body | `function_definition` (`body:`) | `scope.function_body` | region |
| its parameter list | `parameter_list` | `parameter_shape_candidate` carrier | attribute |
| its return type | `function_*` (`type:`) | `return_type_candidate` carrier | attribute |
| a field or local | `declaration` (`name:`) | `definition.variable` | Value |
| its declared type | `declaration`/`parameter` (`type:`) | `declared_type_candidate` carrier | attribute |
| a parameter | `parameter` (`name:`) | `definition.parameter` | Value |
| a for-each variable | `for_in_loop` (`variable:`) | `definition.variable` | Value |
| `public`/`private`/`protected` | `access_modifier` | `visibility_candidate` carrier | attribute |
| `static`/`final`/`abstract`/… | `modifier` | `modifier_candidate` carrier | attribute |
| any position naming a type | `type:`, `generics`, `generic_param superclass:` | `reference.type` | reference |
| an annotation | `annotation` | `reference.annotation` | reference |
| a call, both spellings | `function_call`, `juxt_function_call` | `call.function` | call |
| `name { ... }` | `juxt_function_call`/`function_call` with a closure argument | `definition.config_block` | Config |
| `stage('Build') { ... }` | the leading `string_content` | `label_candidate` carrier | attribute |
| `plugin: 'java'` | `map_item` | `definition.config_entry` | Config |
| operators, literals, control flow, docs | — | nothing | — |

Three deliberate choices behind that table:

**Names are stripped to what they can resolve against.** A call target and a
supertype are run through `last(split(text, "."))`, so `p.q.Service` and
`Service` are the same name and a call to `helper.run()` resolves against a
declaration of `run`. Map keys and block labels are stripped of their quotes.
This is the expression vocabulary the runtime already has; the old Pack used
none of it.

**A block is a declaration, not a call.** `dependencies { }`, `stage('x') { }`
and `task hello { }` are Groovy's block syntax -- an identifier, optional
arguments, a closure. The old Pack reached the same shape but only through
Nextflow-, Spock- and Jenkins-shaped patterns. Stated generically it is syntax,
not a framework fact, and `definition.config_block` with family Config is what
an agent asking *where is the `jacoco` block configured* resolves to. The same
node is also a `call.function`; the two answer different questions and cost one
match between them.

**`extends` and `implements` become `relation.implements`.** This grammar puts
both in one `superclass` field and there is no way to tell them apart. Of the
six relations the host knows, `implements` is the one that means an inheritance
edge, so both go there and the guard says they cannot be distinguished. The
alternative -- a `relation.groovy_extends` -- is one of the 69 `relation.*`
kinds the host silently demotes to a plain reference.

## Still to decide

1. **`pipeline`.** The grammar has a dedicated `pipeline` node holding one
   closure: a Jenkinsfile's top-level block. It carries meaning, but it has no
   name in the syntax, and the only way to emit it would be a `literal` name --
   Defect J, which collapses every Jenkinsfile in a repository onto one string.
   Left untouched. If a name is ever wanted it should come from the file path
   via `stem`, which is a file fact rather than a syntax fact and belongs in a
   framework overlay.
2. **Bare identifier reads.** Dropping `(identifier) @local.reference` removed
   the noise but also the answer to *where is this variable read*. Recovering it
   needs a set of patterns for the positions where an identifier is a value
   rather than a name -- `access_op` receivers, `argument_list` members,
   `binary_op` operands -- which is a large pattern set for a language whose
   locals are file-scoped anyway. Left out, with a coverage guard; revisit if a
   query asks for it.
3. **Map entries everywhere.** `definition.config_entry` is right for a build
   script, where a map literal is configuration. In an ordinary Groovy program
   a map literal is data, and every key becomes a Config declaration. Kept,
   because the corpus Groovy appears in is overwhelmingly build and pipeline
   scripts; revisit against a row count.

## A defect in the host

None found. Every kind this Pack needs routes to the family it means under the
whole-word matching that landed on 2026-09-17.
