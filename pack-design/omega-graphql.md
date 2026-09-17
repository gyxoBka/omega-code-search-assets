# omega-graphql

Language `omega-graphql`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

28 templates over 22 query patterns, 27 distinct root node types
(one pattern is an alternation over the six type-extension nodes).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 22 |
| `references` | yes | 6 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.object_type` | Type | 1 |
| `definition.interface` | Type | 1 |
| `definition.union` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.input_type` | Type | 1 |
| `definition.scalar_type` | Type | 1 |
| `definition.type_extension` | Type | 1 |
| `definition.field` | Value | 1 |
| `definition.argument` | Value | 1 |
| `definition.input_field` | Value | 1 |
| `definition.constant` | Value | 1 |
| `definition.directive` | Value | 1 |
| `definition.operation` | Value | 1 |
| `definition.fragment` | Value | 1 |
| `definition.variable` | Value | 1 |
| `definition.root_config` | Config | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 3 |

All six carriers are emitted on the span of the declaration they describe, and
all three names are ones the engine assembles: `parameter_shape` and
`return_type` build the signature line on a card, so a schema field reads
`user(id: ID!) -> User` and a named operation reads
`GetUser($id: ID!)`.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.implements` | implements | 1 |
| `reference.type` | reference | 1 |
| `reference.field` | reference | 1 |
| `reference.fragment` | reference | 1 |
| `reference.directive` | reference | 1 |
| `reference.argument` | reference | 1 |

### Attributes

Three, all computed per emission, none constant: `locations` on a directive
declaration (where it may be written), `operation` on an operation and on a
schema root (`query`, `mutation`, `subscription`), and `value` on an argument
at a use site.

The Pack sets no `fields`. Nothing in `frameworks/` targets GraphQL, so the
framework overlay has nothing to match on.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 74 node types. The Pack looks at 37 of them.

Untouched:

- `alias`
- `arguments`
- `boolean_value`
- `comma`
- `comment`
- `default_value`
- `definition`
- `description`
- `directive_location`
- `directives`
- `document`
- `enum_values_definition`
- `executable_definition`
- `executable_directive_location`
- `fields_definition`
- `float_value`
- `inline_fragment`
- `int_value`
- `list_type`
- `list_value`
- `non_null_type`
- `null_value`
- `object_field`
- `object_value`
- `schema_definition`
- `schema_extension`
- `selection`
- `selection_set`
- `source_file`
- `string_value`
- `type_condition`
- `type_definition`
- `type_extension`
- `type_system_definition`
- `type_system_extension`
- `type_system_directive_location`
- `union_member_types`

Most of these are reached through a node that *is* touched and carry nothing of
their own:

- `source_file`, `document`, `definition`, `executable_definition`,
  `type_system_definition`, `type_system_extension`, `type_definition`,
  `type_extension` are one-child wrappers whose only content is the node
  beneath them, and that node is matched directly.
- `fields_definition`, `enum_values_definition`, `arguments`, `directives`,
  `selection_set`, `selection` and `union_member_types` are containment. A
  field already carries its type through the host's `within:` segment.
- `list_type` and `non_null_type` wrap a `named_type`; the name is taken from
  the `named_type` inside, so `[User!]!` resolves onto `User`.
- `type_condition` is a `named_type`, so `... on User` is already a type
  reference. `schema_definition` and `schema_extension` are reached through
  `root_operation_type_definition`, which is where the fact is.
- `directive_location`, `executable_directive_location` and
  `type_system_directive_location` are the words inside `directive_locations`,
  which is carried whole on the directive declaration.
- `comma`, `comment`, and the value leaves `int_value`, `float_value`,
  `string_value`, `boolean_value`, `null_value`, `list_value`, `object_value`,
  `object_field` are literals. A literal marker would suppress nothing here --
  this Pack emits no `reference_context.*` kind -- so it would be one match per
  literal for an emission the host drops. The one place a literal answers a
  question is an argument's value, and that is an attribute of the argument
  mention.

Three are deliberate silences rather than free ones:

- `alias` -- `shortName: reallyLongFieldName` names a key in the *response*,
  not anything declared anywhere. There is nothing for it to resolve onto.
- `description` -- the `"""..."""` block is GraphQL's doc comment. No carried
  name the engine assembles holds documentation, and emitting it as a name
  would store a paragraph as a symbol.
- `default_value` -- see **Still to decide**.

## What is wrong with it

Measured on the Pack as it stood: **36 templates over 50 patterns, 4 guards,
41 node types touched.**

**Eighteen of 50 patterns state containment, and ten of them do it four to
six edges deep.** The `root_field_schema_context` section spells
`object_type_definition > fields_definition > field_definition > type >
non_null_type > list_type > type > non_null_type > named_type > name` out by
hand, once per wrapper combination -- six patterns for a field's response type
and four for an argument's type -- to feed two templates,
`definition.graphql_root_field_response_context` and
`...argument_context`. The tree already holds every one of those edges, and
each pattern costs a match per (owner, field, type) tuple. The two templates it
all feeds are a second, worse copy of `definition.graphql_field`: same name,
wider span, a kind whose last word is `context` so it lands in Value beside the
first copy.

**Eight patterns feed one template that stores a whole type definition as a
name.** `(enum_type_definition) @type.expression` and seven like it feed
`type.graphql_declaration_candidate`, whose `name` is its own span capture.
A `capture_ref` name is the capture's source text, so every `type`, `interface`,
`input`, `enum`, `scalar` and `union` block in the corpus -- body, field list,
descriptions and all -- was written into the index once as its own name.
`(object_type_definition) @structural.candidate` does it a second time under
`semantic_hint.graphql_object_type_definition_structure_hint`. That is defect
D2 twice, and the two largest nodes in the language are the ones chosen.

**And that carrier could never have folded.** `type.graphql_declaration_candidate`
ends in `_candidate`, but `is_definition_kind` is false for it: it contains no
`definition` and ends in none of the five suffixes. So it never attached to
anything; it was materialised on its own, as a mention, named with a whole type
body. Had it folded, it would have folded under `omega.pack.graphql_declaration`,
which nothing in the engine assembles.

**The one relation GraphQL actually has was never stated as one.** `type Dog
implements Pet` is exactly `relation.implements`, one of the six occurrences
the host knows. The Pack spelled it three ways -- `reference.graphql_implements`,
`reference.graphql_interface_implementation`, `reference.graphql_interface_extends`
-- none of which is a relation, so all three arrived as plain references and the
implements edge was never made. Two of the three are the same fact over the same
clause, from two patterns.

**`bindings` was declared for a template the host does not make a binding.**
`binding.graphql_variable` becomes a binding only if the kind contains `import`
or `export`; it contains neither, so it was an ordinary reference named `$id`
-- with the dollar sign, because the name came from the `variable` node rather
than the `name` inside it, so it could not have matched a declaration even if
one had existed. Nothing declared variables.

**Seven `data.*` templates name things that resolve to nothing.**
`data.graphql_schema`, `data.graphql_schema_extension`,
`data.graphql_directive_location`, `data.graphql_default`,
`data.graphql_typed_default`, `data.graphql_argument` and
`data.graphql_argument` again arrive as plain references. A directive location
(`FIELD_DEFINITION`) and a default value (`10`) are properties of a
declaration, not names anything can be asked about; stored as mentions they
resolve against nothing and are indistinguishable from real references.

**Six templates are one template.** The six type-extension templates differ
only in which of six capture names they read, and all emit the same
`definition.graphql_type_extension`. They are one alternation pattern and one
template.

**Three of four guards are labels.** `graphql_distributed_highlight_ast_fact_not_symbol_truth`,
`graphql_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`
and `graphql_cross_document_schema_resolution_unavailable` are generator
confidence tiers, not limitations an agent can act on.

**Defect L's tell, twice, over a section with no patterns in it.** The
`distributed_web_structural` section is three comment lines and a
raw.githubusercontent.com URL to an nvim-treesitter `highlights.scm`, and
contributes no pattern at all. `root_field_schema_context` opens with
"Framework-neutral GraphQL root operation field" and "framework overlays decide
which owners are operation roots" -- and then hard-codes the shape of a
resolver-facing root type anyway. Nothing in `frameworks/` targets GraphQL, so
the eight `fields` maps those templates computed were read by no overlay that
exists.

**The schema block itself was never read.** `schema { query: Query }` is where
a GraphQL service says which type is its entry point, and the Pack reached
`root_operation_type_definition` only as one more `@type.expression` whole-node
name. `schema_definition`, `schema_extension` and `operation_type` were
untouched.

## What it should extract

GraphQL is one grammar over two languages. A `.graphql`/`.graphqls` file is a
**schema**: the types, fields, arguments, enums and directives an API offers.
A `.graphql` file next to client code, or a `gql` template injected from
JavaScript, is an **executable document**: the operations and fragments a
client sends. Eight of the other language Packs alias `graphql` for injection,
so this Pack is what parses those too.

The questions are: where is this type defined, what fields does it have, what
does a field return and what arguments does it take, who uses this type, what
implements this interface, which type is the schema's Query root, where is this
fragment declared and where is it spread, and which schema field does this
selection reach.

| what | node | emitted as | family |
|---|---|---|---|
| an object type | `object_type_definition` via `name` | `definition.object_type` | Type |
| an interface | `interface_type_definition` via `name` | `definition.interface` | Type |
| a union | `union_type_definition` via `name` | `definition.union` | Type |
| an enum | `enum_type_definition` via `name` | `definition.enum` | Type |
| an input object | `input_object_type_definition` via `name` | `definition.input_type` | Type |
| a custom scalar | `scalar_type_definition` via `name` | `definition.scalar_type` | Type |
| `extend type X` and its five siblings | the six `*_type_extension` nodes, one alternation | `definition.type_extension` | Type |
| a field of a type, interface or extension | `field_definition` via `name` | `definition.field` | Value |
| that field's arguments | `arguments_definition` | `definition.parameter_shape_candidate` on the field | carrier |
| that field's type | `type` | `definition.return_type_candidate` on the field | carrier |
| a field or directive argument | `arguments_definition > input_value_definition` via `name` | `definition.argument` | Value |
| an input object's field | `input_fields_definition > input_value_definition` via `name` | `definition.input_field` | Value |
| either one's type | `type` | `definition.declared_type_candidate` | carrier |
| an enum member | `enum_value_definition` via `enum_value > name` | `definition.constant` | Value |
| a directive declaration | `directive_definition` via `name` | `definition.directive` | Value |
| where that directive may be written | `directive_locations` | attribute `locations` | -- |
| the schema's query/mutation/subscription root | `root_operation_type_definition` via `named_type > name` | `definition.root_config` | Config |
| a named operation | `operation_definition` via `name` | `definition.operation` | Value |
| its variables | `variable_definitions` | `definition.parameter_shape_candidate` on the operation | carrier |
| a variable declaration | `variable_definition` via `variable > name` | `definition.variable` | Value |
| its type | `type` | `definition.declared_type_candidate` | carrier |
| a fragment | `fragment_definition` via `fragment_name > name` | `definition.fragment` | Value |
| every mention of a type | `named_type` via `name` | `reference.type` | reference |
| implementing an interface | `implements_interfaces > named_type > name` | `relation.implements` | implements |
| a field selection | `field` via `name` | `reference.field` | reference |
| a fragment spread | `fragment_spread` via `fragment_name > name` | `reference.fragment` | reference |
| applying a directive | `directive` via `name` | `reference.directive` | reference |
| passing an argument | `argument` via `name`, value as an attribute | `reference.argument` | reference |
| aliases, descriptions, literals, containment | `alias`, `description`, `*_value`, `selection_set`, … | nothing | -- |

Three choices in that table are deliberate and worth stating.

**An enum member is `definition.constant`, not `definition.enum_value`.**
`entity_family` splits on non-alphanumerics and matches whole words, so *any*
kind with the segment `enum` in it is filed under Type. `RED` and `GREEN` are
not types. The only way to put an enum member in Value is to leave the word
out, so it is left out.

**`named_type` is one pattern, not one per site.** A type name is written as a
`named_type` in every position the language has -- a field's type, an
argument's type, a variable's type, a union member, a fragment's type
condition, a schema root, an implemented interface. One pattern rooted there
covers all of them, and taking the `name` inside strips the `[ ]` and `!`
wrappers so the mention resolves onto the declaration. It does mean an
implemented interface is seen twice, once as `reference.type` and once as
`relation.implements`; the relation is what makes the edge, it is the rarer of
the two, and excluding one clause from a general pattern is not something a
tree-sitter query can express.

**An extension is a declaration, not a reference.** `extend type Query { me:
User }` is how a federated subgraph declares its half of a root type, and in a
schema split across files it may be the only declaration of that type in the
repository. Emitting it as a reference would leave the fields inside it with no
enclosing declaration and no `within:` owner.

## Why one audit class is not zero

`python pack-design/audit.py omega-graphql` reports four
`carrier_owner` -- "carrier that may overwrite itself". All four are the
false positive the check's own label warns about, and in this grammar it is
unavoidable rather than occasional: **tree-sitter-graphql declares no fields at
all.** Zero of its 127 node types has a `fields` map, so every child of every
node arrives in one `"children": {"multiple": true}` group, and `repeats_in()`
concludes that a `field_definition` may hold many `type` nodes, many
`arguments_definition` nodes and many `name` nodes. It may hold exactly one of
each: the grammar's own rule is `description? name arguments_definition? ":"
type directives?`. The same applies to `variable_definition` (one `variable`,
one `type`) and `operation_definition` (one `variable_definitions`). Any
carrier this Pack emits on any node will read as self-overwriting, so the class
cannot be driven to zero here without giving up carriers altogether, and the
signature line is worth more than the clean number.

Every other class the audit reports is zero.

## Still to decide

1. **Default values.** `first: Int = 10` states a default that an agent does
   ask about, and it is not emitted. It cannot go in an attribute of
   `definition.argument`: an attribute expression naming an unbound capture
   skips the whole template, so an optional `default_value` capture would
   silence the declaration of every argument that has no default. It cannot go
   in a carrier either -- no name the engine assembles means "default". Two
   ways out, neither taken here: a second pattern requiring `default_value`,
   feeding a second declaration template with the attribute, which declares the
   argument twice; or a carried name the engine learns to read. Left out until
   one of them is decided.
2. **Whether a field selection should be stated at all in very large query
   documents.** `reference.field` resolves by name alone, and `id`, `name` and
   `edges` are declared on dozens of types, so a selection of `id` matches every
   one of them. It is kept because the selection-to-schema link is the main
   thing an agent wants from a GraphQL client document, and a guard says the
   resolution is by name; revisit against the row count on a repository with a
   large generated query set.
3. **Whether an operation should be Callable rather than Value.** An operation
   is what a client invokes, and `definition.operation_procedure` would land it
   in Callable. It reads as a name deformed to please the family table, so it
   is Value for now.
