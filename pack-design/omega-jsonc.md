# omega-jsonc

Language `omega-jsonc`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

This Pack is a port of `omega-json`. Read `pack-design/omega-json.md` beside it:
the design, the reasoning and the deliberate silences are that document's, and
the section at its end, *For omega-jsonc and omega-json5, which are ported from
this*, is the instruction this rewrite carried out.

## What it states today

4 templates over 4 query patterns, 9 distinct node types touched
(`pair` three times, `array` once as a root).

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
anything (`key` matches nothing), so every JSONC key is reachable as
configuration, which is what a `.jsonc` file always is.

The kind is `omega-json`'s kind, not a `definition.jsonc_key` of its own. That
would be defect K — one construct under two spellings — and it would split
*where is this setting defined* across two kinds for two files that are the
same language.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.data` | data | 1 |

### Regions

None. A key written inside an object already lies inside the span of the pair
that holds that object, so `compilerOptions` → `strict` comes out of the
nesting as the `within:` namespace segment. A `scope.*` region would state it a
second time.

### Carriers

None. JSONC declares nothing with a signature, so there is nothing for a card's
signature line to assemble.

## The boundary: what the grammar offers and the Pack ignores

There is no `grammars/omega-jsonc/`. This Pack declares
`parser_id = "tree-sitter-json"` and parses with `grammars/omega-json`, whose
`node-types.json` is the boundary. That grammar already accepts `comment`,
which is the whole of the JSON/JSONC difference: **the two Packs are over one
identical grammar**, and the grammar bundle's own `extensions` list is in fact
`["jsonc"]`. The earlier version of this document said the boundary could not
be measured; it can, and it is JSON's.

The grammar names 13 node types. The Pack looks at 9 of them: `pair`, `string`,
`string_content`, `number`, `true`, `false`, `null`, `object`, `array`.

Untouched:

- `_value` — a supertype, not a node; it is the seven concrete value types,
  every one of which the Pack reaches through the `value:` field.
- `document` — the file. It names nothing, and everything declared in it is
  already in it.
- `comment` — the one thing this dialect adds. Still not stated; see the
  reasoning under *What it should extract* and the third guard.
- `escape_sequence` — a spelling detail inside a string. See the fourth guard:
  a string containing one is not stated at all rather than stated wrong.

## What is wrong with it

The Pack that was here stated 10 templates over 9 patterns and 2 guards, under
one capability, and it declared nothing. (The tables at the top of this
document used to say 15 over 15; that count predated the repository-wide sweep
that removed the five `literal.*` markers, and the 10 above is the state this
rewrite actually found.)

**It declared nothing at all — zero templates passed `is_definition_kind`.**
Its only capability was `data`, and its kinds were `value.*` (7) and
`relation.*` (3). So `tsconfig.json`, `.vscode/settings.json`, `launch.json`,
`devcontainer.json` and every agent-harness config in a repository contributed
not one declaration to the index. *Where is `strict` set and to what*, *which
paths does this project include*, *what does this harness point at* all
returned nothing, while every emission arrived as the same undifferentiated
plain reference.

**Eight templates named an emission with a whole node, six of them with their
own span.** `value.document` took `(document)` as both span and name, so **every
`.jsonc` file in the repository was stored once as a single name that is the
entire file**; `value.object` did the same for every object, `value.array` for
every array, so a nested file stored its own bytes again at every level.
`value.object_pair` and `value.object_key` both named themselves from
`(string)` — the quoted node, not its content, so the stored name carried its
own quotation marks and could never match the unquoted spelling of anything.
`relation.document_value`, `relation.object_contains_pair` and
`relation.array_contains_value` were named from the container capture too. The
audit reported all eight; this is defect D at its most expensive, and data
files are where the index row count came from.

**Three `relation.*` kinds were not relations.** `document_value`,
`object_contains_pair` and `array_contains_value` — none is one of the six the
host knows (`implements`, `tests`, `depends`, `config`, `data`, `handles`), so
`strip_prefix("relation.")` failed the exact compare and each arrived as a
plain reference with a long name and a container for its text.

**Three of the nine patterns stated containment the tree already holds.**
`(document (_) @data.root.value)`, `(object (pair) @data.object.pair)` and
`(array (_) @data.array.element)` are one match per (container, child) pair, to
state the parent link the tree gives for free.

**Two more patterns were one emission per string and per escape in every
file.** `(string_content) @data.string.content` and
`(escape_sequence) @data.string.escape` fed `value.string_content` and
`value.escape_sequence`, each named by its own text. Neither is a `literal.*`
marker, so neither suppressed anything; and this Pack emits no
`reference_context.*` kind, so a marker would have suppressed nothing either.
That is why the five `literal.*` templates the old table lists were already
gone before this rewrite.

**The object was captured twice in one pattern.**
`(object) @structural.candidate @data.object` carried a second capture that no
template reads, under a header comment naming a Helix `highlights.scm` as its
"exact grammar evidence" — an editor's highlighting model quoted as a source of
semantics.

**Both guards said nothing a human could act on.** One was pure provenance
("Exact Helix grammar/query evidence proves this AST node shape only"); the
other was generator vocabulary ("structure/literals are syntactically
preserved … not inferred"). Both named `data`, the Pack's only capability.

## What it should extract

The same thing `omega-json` extracts, because it is the same language with one
token class added. A `.jsonc` file is a configuration file that a person is
expected to edit: the key is what a question reaches, and a whole object is
not.

| what | node | emitted as | family |
|---|---|---|---|
| a key set to a string, `"target": "es2022"` | `pair` via `key:` content | `definition.config_key`, value into the attribute `value` | Config |
| a key set to a number, boolean or null, `"strict": true` | `pair` via `key:` content | `definition.config_key`, value into the attribute `value` | Config |
| a key set to an object or an array, `"compilerOptions": { … }` | `pair` via `key:` content | `definition.config_key`, no value | Config |
| a string listed in an array, `"include": ["src"]` | `string` inside `array` | `relation.data`, under its own text | data occurrence |
| a key inside an object | — | nothing extra: it is already inside the enclosing pair's declaration | — |
| the file, objects and arrays as such, containment | `document`, `object`, `array` | nothing | — |
| a comment, `// why this is off` | `comment` | nothing | — |
| escapes, punctuation | `escape_sequence`, `{ } [ ] , : "` | nothing | — |
| a `$schema`, an `extends`, a known option name | — | nothing: it is an overlay's fact, not JSONC's | — |

Four things follow, and they are `omega-json`'s four:

- **Containment is free, and it was the old Pack's largest expense.**
  `compilerOptions` is a declaration spanning the whole object and `strict` is
  a declaration inside it, so the host derives `compilerOptions.strict` from
  the nesting. Three containment patterns are replaced by nothing at all.
- **The value is carried only when it is a scalar.** `"strict": true` is an
  answer; `"compilerOptions": { … }` is not, and storing its text would store
  the whole subtree again — which is precisely what `value.object` used to do.
- **An array string is the one link JSONC has.** An included path, a plugin id,
  a workspace, an enum member: a name that lives somewhere else. `relation.data`
  under the unquoted text is a `data` occurrence the resolver can match by
  name, and it is the only mention the Pack makes.
- **Every string is matched with an anchor on both sides.** `"a\nb"` is three
  named children, and a loose `(string_content)` would match twice, emitting
  one pair under two half-names. Anchored, such a string matches nothing and
  the fourth guard says so.

### The one dialect question: comments

This is the only place where `omega-jsonc` could have departed from
`omega-json`, and it does not. A comment resolves against nothing: it has no
name, it declares nothing, and it is not a reference to any declaration in the
repository. Emitting one per comment would be one row per line of prose in the
one JSON dialect whose whole reason to exist is that it is commented — the most
expensive possible emission for the least resolvable fact. Attaching a comment
to the key beneath it as a carrier was considered and rejected twice over: it
needs a containment pattern to reach the sibling, and `omega.pack.comment` is
not a name anything in the engine assembles or reads, so the text would be
computed and stored and never asked for. It is stated as a guard instead, which
is what a guard is for.

The rest of the dialect is punctuation: a trailing comma, if the parser admits
one, is an anonymous token with nothing to state, and the anchors here are
between *named* siblings inside a string, so no trailing comma can break one.

## Still to decide

1. **Whether every pair should be a declaration.** Inherited from
   `omega-json`'s first open question, and less pressing here: a `.jsonc` file
   is hand-written, so there is no JSONC equivalent of `package-lock.json`
   generating tens of thousands of uninteresting Config entities. Provisionally
   yes, on the same reasoning: the alternative is guessing which keys matter,
   and which keys matter is a per-tool judgement, therefore an overlay's.
2. **Whether array strings should be `relation.data` or `relation.depends`.**
   `depends` is closer to what the strings under `"include"` or `"extends"`
   actually are, but JSONC cannot tell a path list from a keyword list without
   the consuming tool's schema. `data` is the honest weaker claim, and it must
   stay the same as `omega-json`'s or one question splits in two.
3. **Whether a comment should ever become a carrier on the key below it.** Not
   until there is a carried name the engine reads for documentation. That is a
   host question, not this Pack's, and it is recorded rather than acted on.
4. **Escaped and empty strings.** The fourth guard chooses silence over a wrong
   name. Decoding `\uXXXX` is what `decoders` exist for; not worth one until a
   corpus shows the loss is real.

## Why the audit is clean

`python pack-design/audit.py omega-jsonc` reports every class at zero after the
rewrite. Nothing in this Pack is a deliberate exception.
