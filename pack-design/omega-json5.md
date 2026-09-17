# omega-json5

Language `omega-json5`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

This Pack is a port of `omega-json`. Read `pack-design/omega-json.md` for the
reasoning; this file records only what JSON5 adds and where it departs.

## What it states today

4 templates over 4 query patterns, 2 distinct root node types
(`member` three times, `array` once).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 3 |
| `references` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_key` | Config | 3 |

`definition.config_key` is one construct — the object member, named by its key —
written in the only three shapes a JSON5 value has: a string, a non-string
scalar, and a compound. The first two carry the value as the attribute `value`;
the third does not, because its members are their own emissions. The three are
mutually exclusive on the `value:` field, so a member matches exactly one.

`entity_family` splits the kind into whole words and the last matching one wins.
`config` is the only word in `definition.config_key` that matches anything
(`key` matches nothing), so every JSON5 key is reachable as configuration, which
is what a JSON5 file is. The kind is deliberately the *same string* as
omega-json's: a `definition.json5_key` spelling would be defect K, one construct
under two names, and would split one question across two kinds.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.data` | data | 1 |

### Regions

None. A key written inside an object already lies inside the span of the member
that holds that object, so `compilerOptions` → `strict` comes out of the nesting
as the `within:` namespace segment. A `scope.*` region would state it a second
time.

### Carriers

None. JSON5 declares nothing with a signature, so there is nothing for a card's
signature line to assemble.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 11 node types. The Pack looks at 9 of them: `member`,
`string`, `identifier`, `number`, `true`, `false`, `null`, `object`, `array`.

Untouched:

- `file` — the root. It names nothing, and everything declared in it is already
  in it. The old Pack stored every JSON5 file in the repository once under a
  name that was the entire file.
- `comment` — legal in JSON5 where it is not in JSON, and still prose that
  resolves against nothing. See the fifth guard.

The grammar has no `string_content` and no `escape_sequence`: `string` is a
single leaf token carrying its own quotes. That is the one structural
difference from tree-sitter-json and it is what the fourth section below turns
on.

## What is wrong with it

The Pack that was here stated 12 templates over 11 patterns and 3 guards, under
the single capability `data`, and it declared nothing. (The tables at the top of
this document previously said 18 over 19; the repository-wide sweep had already
removed the six syntax-highlighting and `literal.*` templates before this
rewrite.)

**It declared nothing at all — zero templates passed `is_definition_kind`.** Its
kinds were `value.*` (5), `structured.entry` (3), `relation.*` (3) and
`data.comment` (1). So a `.json5` or `.babelrc` file contributed not one
declaration to the index, and every emission arrived as the same
undifferentiated plain reference.

**Six templates named an emission with its own span, and that span was a
container** — the audit's D2 at 6, four of which are also on its D list because
the container was an `(object)` or an `(array)`. `value.document` took `(file)` as both
span and name, so **every JSON5 file was stored once as a single name that is the
entire file**; `value.object` did the same for every object and `value.array`
for every array, so a nested file stored its own bytes again at every level.
`relation.document_value`, `relation.object_contains_pair` and
`relation.array_contains_value` were named from the container capture too.

**Three `relation.*` kinds were not relations.** `document_value`,
`object_contains_pair` and `array_contains_value` are none of the six the host
knows (`implements`, `tests`, `depends`, `config`, `data`, `handles`), so
`strip_prefix("relation.")` failed the exact compare and each arrived as a plain
reference with a long name and a container for its text.

**Three patterns stated containment the tree already holds** (defect E):
`(file (_) @data.root.value)`, `(object (member) @data.object.member)` and
`(array (_) @data.array.element)` — one match per (container, child) pair, to
state the parent link the tree gives for free.

**The three `structured.entry` templates were one member, re-matched from three
depths** (defect E again, and the expensive kind). One pattern matched a member,
one a member inside a member's object, and one a member inside an array inside a
member's object — three and five levels of tree shape written out, computing an
ancestor key path into fields `parent_key` and `array_key` that is exactly what
the host derives from the nesting at no cost. The deepest of the three is one
match per (outer member, inner member, array object member) tuple.

**`data.comment` named a comment by its own prose**, one emission per comment in
every file, resolving against nothing.

**All three guards said nothing a human could act on.** The first is the
generator's provenance boilerplate about "editor highlighting captures" and the
"release compile gate"; the other two are its vocabulary — "decoded host
values/schema semantics are not inferred", "duplicate-key consumer semantics and
schema validation are not inferred". All three named `data`, the Pack's only
capability.

**The query file was an nvim-treesitter `highlights.scm` baseline** with a
provenance header naming `third_party/neovim-distributed`, and `@comment
@spell` captures beside the Omega ones. The file is written from scratch and
none of it survives. `packs/omega-json5/NOTICE` and the manifest's
`license = "MIT AND Apache-2.0"` are the last trace of that inheritance and now
describe nothing in the Pack; they are left alone here because the same pair
survives in omega-twig, which was already rewritten, so the decision is a
cross-Pack one rather than this Pack's.

## What it should extract

JSON5 is JSON that a person is expected to edit: `.babelrc`, a bundler or
linter config, a game's data table, a tsconfig kept in the dialect that allows a
comment. The language declares nothing of its own — no function, no type, no
import. What it has is the key, and **a key is what a question reaches; a whole
object is not**. The questions are *where is this setting defined and to what*,
*which package declares this dependency* and *which names does this list*.

| what | node | emitted as | family |
|---|---|---|---|
| a key set to a string, `name: "my-package"` | `member`, `name:` is `string` or `identifier` | `definition.config_key`, value into the attribute `value` | Config |
| a key set to a number, boolean or null, `strict: true` | `member` with `value:` in `[number true false null]` | `definition.config_key`, value into the attribute `value` | Config |
| a key set to an object or an array, `plugins: [ … ]` | `member` with `value:` in `[object array]` | `definition.config_key`, no value | Config |
| a string listed in an array, `required: ["name"]` | `string` inside `array` | `relation.data`, under its unquoted text | data occurrence |
| a bare unquoted key, `strict: true` | `identifier` in `name:` | the same `definition.config_key` | Config |
| a single-quoted key or value, `'name': 'x'` | `string` | the same, quotes removed by the template | Config |
| a hex number, `+`/`-`, `Infinity`, `NaN` | `number` | the same scalar member | Config |
| a key inside an object | — | nothing extra: it is already inside the enclosing member's declaration | — |
| the file, objects and arrays as such, containment | `file`, `object`, `array` | nothing | — |
| comments, trailing commas, punctuation | `comment`, `,` `:` `{` `}` `[` `]` | nothing | — |

Four things follow from this shape, three of them carried over from omega-json
unchanged:

- **Containment is free, and it was the old Pack's largest expense.** Three
  containment patterns and three ancestry templates are replaced by nothing at
  all.
- **The value is carried only when it is a scalar.** `strict: true` is an
  answer; `compilerOptions: { … }` is not, and storing its text would store the
  whole subtree again — which is precisely what `value.object` used to do.
- **An array string is the one link JSON5 has.** `relation.data` under the
  unquoted text is a `data` occurrence the resolver can match by name, and it is
  the only mention the Pack makes.

The fourth is this Pack's own.

### Where it departs from omega-json, and why

**omega-json anchors every string; this Pack cannot, and does not need to.**
tree-sitter-json spells a string as `(string (string_content) (escape_sequence)
…)`, so omega-json writes `(string . (string_content) @x .)`: a string with an
escape in it has three named children, the anchored pattern does not match, and
the pair is **not stated at all** — its third guard chooses silence over a half
name.

tree-sitter-json5 has no such children. `string` is one leaf token including its
quotes, so there is nothing to anchor between and no structural way to see an
escape. The two available options were a `#not-match?` predicate on a backslash,
reproducing omega-json's silence, or storing the string as written. This Pack
stores it as written, with only the outer quotes removed, and says so in the
third guard:

- the loss omega-json accepts is real and larger here. A Windows path, a regex
  or a `\u` escape is common in a *value*, and dropping the member would take
  the key with it — `outDir: "..\\dist"` would be stated nowhere.
- the escaped spelling is a faithful rendering of the bytes in the file, which
  is what a reader of the config sees. It is the wrong name only against a
  declaration spelled the decoded way, which is the same limitation omega-json
  has for the keys it does state.

One unquoting chain serves both, because `strip_prefix`/`strip_suffix` return
their input unchanged when the affix is absent: strip `"` from each end, then
`'` from each end. A bare `identifier` key passes through untouched, so the key
alternation `[(string) (identifier)]` feeds a single capture and a single
template rather than doubling the pattern count.

**Comments are not stated**, for the reason omega-json.md gives for jsonc: a
comment resolves against nothing, and legalising it does not make it an answer.

Four patterns, each rooted at one node, replace eleven. Five guards say what the
Pack genuinely cannot see: that JSON5 carries no schema of its own, that a
compound value is not stored as text, that a string's escapes are not decoded,
that an array string's link is by name alone, and that comments are not stated.

## Still to decide

1. **Whether every member should be a declaration.** Inherited from omega-json,
   and less pressing here: JSON5 has no lock-file equivalent, so the
   pathological case — tens of thousands of uninteresting pairs in one file —
   does not arise in this dialect. Provisionally yes.
2. **Whether a decoder should be added for escapes.** `decoders` exist for
   exactly this, and here — unlike in omega-json — every string reaches the
   template, so a decoder would improve the stored name rather than merely
   admit a pair that was dropped. Not worth it until a corpus shows the loss is
   real.
3. **A string that is nothing but apostrophes.** `"'"` unquotes to the empty
   string, because the double-quote strip runs first and the single-quote strip
   then eats the content. It is a two-character key nobody writes, and the
   alternative — one pattern per quoting style, told apart by `#match?` —
   doubles the pattern count to fix it.
4. **Whether array strings should be `relation.data` or `relation.depends`.**
   Inherited unchanged from omega-json: `data` is the honest weaker claim,
   because JSON5 cannot tell a dependency list from a keyword list without the
   consuming tool's schema.
