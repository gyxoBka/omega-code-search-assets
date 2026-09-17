# omega-json

Language `omega-json`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

4 templates over 4 query patterns, 4 distinct root node types
(`pair` three times, `array` once).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 3 |
| `references` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_key` | Config | 3 |

`definition.config_key` is one construct — the object pair, named by its key —
written in the only three shapes a JSON value has: a string, a non-string
scalar, and a compound. The first two carry the value as the attribute `value`;
the third does not, because its members are their own emissions. They are
mutually exclusive patterns, so a pair matches exactly one of them.

`entity_family` splits the kind into whole words and the last matching one
wins. `config` is the only word in `definition.config_key` that matches
anything (`key` matches nothing), so every JSON key is reachable as
configuration, which is what a JSON file is.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.data` | data | 1 |

### Regions

None. A key written inside an object already lies inside the span of the pair
that holds that object, so `dependencies` → `react` comes out of the nesting as
the `within:` namespace segment. A `scope.*` region would state it a second
time.

### Carriers

None. JSON declares nothing with a signature, so there is nothing for a card's
signature line to assemble.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 13 node types. The Pack looks at 9 of them: `pair`, `string`,
`string_content`, `number`, `true`, `false`, `null`, `object`, `array`.

Untouched:

- `_value` — a supertype, not a node; it is the seven concrete value types,
  every one of which the Pack reaches through the `value:` field.
- `document` — the file. It names nothing, and everything declared in it is
  already in it.
- `comment` — a parser extension, not RFC 8259, and present in this grammar
  only so that `.jsonc` parses. Prose that resolves against nothing; the old
  Pack emitted one mention per comment, named by the comment's own text.
- `escape_sequence` — a spelling detail inside a string. See the third guard:
  a string containing one is not stated at all rather than stated wrong.

## What is wrong with it

The Pack that was here stated 27 templates over 28 patterns and 12 guards,
under one capability, and it declared nothing.

**It declared nothing at all — zero templates passed `is_definition_kind`.**
Its only capability was `data`, and its kinds were `structured.entry` (16
templates), `value.*` (8) and `relation.*` (3). So JSON — the format of every
`package.json`, `package-lock.json`, `tsconfig.json`, `composer.json`,
`.eslintrc.json` and JSON Schema in a repository — contributed not one
declaration to the index. *Which package declares this dependency*, *where is
`strict` set and to what*, *what does this schema require* all returned
nothing, while every emission arrived as the same undifferentiated plain
reference.

**Eight templates named an emission with a whole node, seven of them with
their own span.** `value.document` took `(document)` as both span and name, so
**every JSON file in the repository was stored once as a single name that is
the entire file**. `value.object` did the same for every object, `value.array`
for every array — so a nested file stored its own bytes again at every level.
`relation.document_value` and `relation.object_contains_pair` were named from
the container capture too. This is defect D at its most expensive: the index
measurement that started this work found data files to be the largest row
producers, and this is why.

**Three `relation.*` kinds were not relations.** `document_value`,
`object_contains_pair` and `array_contains_value` — none is one of the six the
host knows (`implements`, `tests`, `depends`, `config`, `data`, `handles`), so
`strip_prefix("relation.")` failed the exact compare and each arrived as a
plain reference with a long name and a container for its text.

**Three patterns stated containment the tree already holds.**
`(document (_) @data.root.value)`, `(object (pair) @data.object.pair)` and
`(array (_) @data.array.element)` are one match per (container, child) pair, to
state the parent link the tree gives for free.

**Twelve of the sixteen `structured.entry` templates were one pair, re-matched
from twelve depths.** The
`owned_context`, `depth3_context`, `nested_array_object_string_pair_context`
and `semantic_closure_v3_146_json_deep_context` blocks matched a pair, then a
pair inside a pair, then at depth 3, 4, 5, 6 and 7, then the same through an
array at three depths, each writing the ancestor keys into fields named `a0`
… `a6`. Every one of them produced `structured.entry` — the same kind, from
the same node, with the container spelled into the pattern instead of read off
the tree. On a deeply nested file this is combinatorial: one pair at depth 7
matched the d3, d4, d5, d6 and d7 patterns and the two `owned_context`
patterns, so **one key-value line was stated up to seven times over**, and the
ancestry it spent those matches computing is exactly what the host derives from
the nesting at no cost.

**The other four `structured.entry` templates, over six patterns, were a
framework overlay (defect L).** The
`openapi_operation_schema_refs` block spelled OpenAPI v3 into the query file
as a tree shape nine levels deep — `paths` → path → method → `responses` →
status → `schema` → `$ref` — and the `array_object_type_name` and
`array_named_string_pair` blocks hard-coded the key spellings `"type"` and
`"name"` with `#eq?`. OpenAPI is not JSON syntax; it is a schema a tool
imposes on JSON, and `frameworks/omega-framework-openapi-specification-v3`
already exists. Two of the four were also a pair of patterns written twice to
cover both orderings of two sibling keys, which is a resolver's job spelled as
a query.

**Five `literal.*` markers had nothing to suppress, and two more templates
stored a string's own text.** `literal.boolean` (×2), `literal.null`,
`literal.number` and
`literal.string` are dropped by the host, and a `literal.*` span only
suppresses emissions whose kind starts with `reference_context.`. This Pack
emitted no such kind, so they were five matches per literal in every file for
five emissions thrown away. (They had already been removed by the
repository-wide sweep before this rewrite; the count of 27 templates above is
after that sweep, and the document's original tables said 32 over 33.)
`value.string_content` and `value.escape_sequence` are the same waste without
even the marker excuse: one emission per string and per escape in every file,
named by its own text.

**Ten of twelve guards said nothing a human could act on**, and four were
single tokens: `json_comments_are_parser_extension_not_rfc8259`,
`json_string_decoded_value_not_inferred`,
`json_number_host_numeric_semantics_not_inferred`,
`json_duplicate_object_key_semantics_consumer_defined`. The rest were
generator vocabulary — "require generic bounded structured-path emission",
"bounded_json_mapping_ancestry_only", "remain downstream framework/runtime
concerns". Every one named `data`, the Pack's only capability, and several
restated the same limitation in two spellings.

## What it should extract

JSON is read by one tool per file: npm, cargo, composer, tsc, eslint, a JSON
Schema validator, a test runner's fixtures. The language itself declares
nothing — no function, no type, no import, no name it defines for its own
use. What it has is the key, and **a key is what a question reaches; a whole
object is not**. The questions are *which package declares this dependency*,
*where is this setting defined and to what*, *what does this schema require*
and *which names does this list*.

| what | node | emitted as | family |
|---|---|---|---|
| a key set to a string, `"name": "my-package"` | `pair` via `key:` content | `definition.config_key`, value into the attribute `value` | Config |
| a key set to a number, boolean or null, `"strict": true` | `pair` via `key:` content | `definition.config_key`, value into the attribute `value` | Config |
| a key set to an object or an array, `"dependencies": { … }` | `pair` via `key:` content | `definition.config_key`, no value | Config |
| a string listed in an array, `"required": ["name"]` | `string` inside `array` | `relation.data`, under its own text | data occurrence |
| a key inside an object | — | nothing extra: it is already inside the enclosing pair's declaration | — |
| the file, objects and arrays as such, containment | `document`, `object`, `array` | nothing | — |
| comments, escapes, punctuation | `comment`, `escape_sequence`, `{ } [ ] , : "` | nothing | — |
| an OpenAPI `$ref`, a `"type"`/`"name"` sibling pair, a schema shape | — | nothing: it is an overlay's fact, not JSON's | — |

Four things follow from this shape:

- **Containment is free, and it was the old Pack's largest expense.**
  `"dependencies"` is a declaration spanning the whole object and `"react"` is
  a declaration inside it, so the host derives `dependencies.react` from the
  nesting. Sixteen ancestry templates and three containment patterns are
  replaced by nothing at all.
- **The value is carried only when it is a scalar.** `"strict": true` and
  `"react": "^18.2.0"` are answers; `"dependencies": { … }` is not, and
  storing its text would store the whole subtree again — which is precisely
  what `value.object` used to do.
- **An array string is the one link JSON has.** A required property, a
  workspace member, an included file, a plugin id, an enum member: a name that
  lives somewhere else. `relation.data` under the unquoted text is a `data`
  occurrence the resolver can match by name, and it is the only mention the
  Pack makes.
- **Every string is matched with an anchor on both sides.** `"a\nb"` is three
  named children, and a loose `(string_content)` would match twice, emitting
  one pair under two half-names. Anchored, such a string matches nothing and
  the third guard says so.

Four patterns, each rooted at one node, replace 28. The four guards say what
the Pack genuinely cannot see: that JSON carries no schema of its own, that a
compound value is not stored as text, that an escaped or empty string is not
stated, and that an array string's link is by name alone.

## Still to decide

1. **Whether every pair should be a declaration.** A `package-lock.json` is
   tens of thousands of pairs and each becomes one Config entity. Provisionally
   yes, on the same reasoning as omega-toml: the alternative is guessing which
   keys matter, and which keys matter is a per-tool judgement, therefore an
   overlay's. Lock files are the case to measure first, since they are the
   largest JSON in most repositories and the least interesting per row.
2. **Whether array strings should be `relation.data` or `relation.depends`.**
   `depends` is what the strings under `"required"` or a workspace list
   actually are, but JSON cannot tell a dependency list from a keyword list
   without the consuming tool's schema. `data` is the honest weaker claim.
3. **Numbers and booleans inside arrays** are not stated. A bare `3` in a list
   names nothing. If a use appears, it belongs as an attribute on the key, not
   as a mention.
4. **Escaped and empty strings.** Guard three chooses silence over a wrong
   name. Decoding `\uXXXX` is what `decoders` exist for and would let those
   keys be stated correctly; it is not worth a decoder until a corpus shows
   the loss is real.

## For omega-jsonc and omega-json5, which are ported from this

Both reuse this grammar family, so port the result rather than redesigning it.

**Copy exactly:**

- the kind `definition.config_key` for all three pair shapes, and
  `relation.data` for an array string. Do not invent a `definition.jsonc_key`
  or `definition.json5_key` spelling: that is defect K, the same construct
  under two names, and it would split one question across two kinds.
- the capabilities `["definitions", "references"]`, and nothing else.
- the attribute name `value`, on the two scalar templates only.
- the double anchor on every string: `(string . (string_content) @x .)`.
- all four guards, in language terms, one sentence each.

**Deliberately not stated, and it should stay that way:** the document, the
object and the array as nodes; containment of any kind; any pattern keyed on a
particular key spelling (`$ref`, `paths`, `type`, `name`); the escape sequence;
and any `scope.*` region.

**What each has that JSON does not, and whether it changes a decision:**

- **jsonc — comments.** `comment` is already a node in *this* grammar and this
  Pack ignores it, for the reason in the boundary section: a comment resolves
  against nothing, and one emission per comment in every file is one row per
  line of prose. That reasoning does not weaken when comments become legal, so
  **no change**: jsonc ignores `comment` too.
- **json5 — unquoted keys.** A json5 grammar spells a bare key as its own node
  type (typically `identifier`) rather than as `string`. The key pattern must
  therefore accept an alternation in the `key:` field —
  `key: [(string . (string_content) @k .) (identifier) @k]` — and a bare key
  needs no anchor because it has no children. Check the node type against that
  grammar's own `node-types.json`; do not assume the spelling. This is the one
  structural change.
- **json5 — trailing commas.** Anonymous punctuation. Nothing to state, and
  nothing anchored on: the anchors here are between *named* siblings inside a
  string, which a trailing comma is not. **No change.**
- **json5 — single-quoted strings, hex numbers, `Infinity`, `NaN`, `+`/`-`
  signs.** All are spellings of the same two value classes. Whatever node types
  that grammar gives them go into the existing `[(number) (true) (false)
  (null)]` alternation of the scalar pattern; the kind, the family, the
  attribute name and the guards are unchanged.
- **json5 — multi-line strings with line continuations.** These are escape
  sequences, so guard three covers them unchanged.
