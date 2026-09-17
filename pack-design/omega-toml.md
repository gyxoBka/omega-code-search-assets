# omega-toml

Language `omega-toml`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

5 templates over 5 query patterns, 4 distinct root node types
(`table`, `table_array_element`, `pair`, `array`).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 4 |
| `references` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_table` | Config | 1 |
| `definition.config_table_array` | Config | 1 |
| `definition.config_key` | Config | 2 |

`definition.config_key` is two templates over two mutually exclusive patterns --
a key set to a scalar, which carries its unquoted value as the attribute
`value`, and a key set to an array or an inline table, which does not. They are
one construct stated in the only two shapes it has, not the same fact twice.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.data` | data | 1 |

### Regions

None. A key declared inside a table already lies inside that table's
declaration span, so the qualified name comes from the nesting and a
`scope.*` region would state it a second time.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 19 node types. The Pack looks at 16 of them.

Untouched:

- `comment`
- `document`
- `escape_sequence`

`document` is the file; it names nothing, and a declaration inside it is already
in the file. `comment` is prose -- the old Pack emitted every comment as a
mention named by its own text, which resolves against nothing and is one row per
comment line in every TOML file in a repository. `escape_sequence` is a
spelling detail inside a string whose value the Pack already stores stripped of
its quotes.

## What is wrong with it

The Pack that was here stated 25 templates over 26 patterns and 7 guards, and
almost none of it answered a question.

**It declared nothing at all.** Zero templates passed `is_definition_kind`.
`definitions` was not among its capabilities; it claimed `data` and `scopes`.
So a TOML file -- the single most common place a repository states what it is
and what it depends on -- contributed no declaration to the index. An agent
asking *where is `edition` set* or *what does `[dependencies]` contain* got
nothing back, while 16 mention kinds all arrived as the same undifferentiated
plain reference.

**Thirteen templates named an emission with a whole node.** Six of them named
it with its own span (`value.document` from `(document)`, `value.table` from
`(table)`, `value.table_array`, `value.array`, `scope.toml_lexical_scope` from
`(table_array_element)`, `semantic_hint.toml_literal` from `(quoted_key)`), so
`value.document` stored the entire file as one name, and every table stored its
own whole text again inside it. The five `relation.*_contains_*` templates were
named from the container capture, storing the container's bytes once per child.

**Five `relation.*` kinds were not relations.** `document_contains_pair`,
`document_contains_table`, `table_contains_pair`, `table_array_contains_pair`,
`object_contains_pair` -- none is one of the six the host knows, so each arrived
as a plain reference with a long name.

**Six patterns stated containment the tree already holds.**
`(document (pair))`, `(document (table))`, `(document (table_array_element))`,
`(table (pair))`, `(table_array_element (pair))` and `(inline_table (pair))`,
on top of three more `structure-v2` patterns rooting on `document`, `table` and
`table_array_element` a second time. Each is one match per (container, child)
pair, to say what the parent link already says.

**Eleven templates were syntax highlighting.** The whole nvim highlights
baseline was pinned into the query file and given a template each:
`semantic_hint.toml_syntax_role` on every `=` in the corpus,
`semantic_hint.toml_member` on every bare key, `semantic_hint.toml_literal` on
every string, integer, float, boolean, date and escape sequence. A capture that
exists to colour a token is not a semantic identity; the Pack's own guard said
so (`toml_highlight_capture_not_semantic_identity`) and it emitted them anyway.
The `[ "." "," ] @punctuation.delimiter` pattern was matched in every file for
a capture no template read at all.

**Four `structured.entry` templates were three spellings of one pair.** The
`context_entries`, `root_string_pairs` and `table_array_string_elements`
blocks each re-matched a pair, from a different depth, with the container
hard-coded into the pattern -- so a string-valued pair in a table matched three
of them and one key-value line was stated up to three times over.

**Five of seven guards were labels, not limitations.**
`toml_highlight_capture_not_semantic_identity`,
`toml_dotted_key_merge_and_consumer_schema_semantics_are_not_implicitly_expanded`,
`table_context_is_syntactic; terminal_static_ceiling__...` -- generator
vocabulary, with `terminal_static_ceiling` appearing twice and the same
dotted-key limitation written out in two different spellings.

**`literal.*` markers with nothing to suppress.** `literal.boolean`,
`literal.number` (x2) and `literal.string` are dropped by the host, and their
spans only suppress kinds starting `reference_context.`. This Pack emitted no
such kind, so they were four matches per literal in every file for four
emissions the host threw away.

## What it should extract

TOML exists to be read by one tool per file: Cargo, pip, poetry, ruff, Netlify,
Hugo, a service's own config. The questions an agent asks are *where is this
setting declared*, *what is it set to*, *what sections does this file define*
and *which names does it list*. Everything below answers one of those; nothing
else is stated.

| what | node | emitted as | family |
|---|---|---|---|
| a section header, `[server.http]` | `table` via its first key | `definition.config_table` | Config |
| an element of an array of tables, `[[bin]]` | `table_array_element` via its first key | `definition.config_table_array` | Config |
| a key set to a scalar, `edition = "2021"` | `pair` via its key | `definition.config_key`, value unquoted into the attribute `value` | Config |
| a key set to an array or inline table | `pair` via its key | `definition.config_key`, no value | Config |
| a name listed in an array, `features = ["derive"]` | `string` inside `array` | `relation.data`, unquoted | data occurrence |
| a key inside a table or an inline table | -- | nothing extra: it is already inside the enclosing declaration | -- |
| the file, comments, escapes, punctuation, syntax roles | `document`, `comment`, `escape_sequence`, `"="`, `"."`, `","` | nothing | -- |

Three things follow from this shape:

- **Containment is free.** `[dependencies]` is a declaration spanning the whole
  table and `serde = "1"` is a declaration inside it, so the host derives
  `dependencies.serde` from the nesting. No pattern, and no `scope.*`, is
  needed to say it. This is also why the Pack no longer declares `scopes`.
- **Every declaration lands in Config.** `entity_family` splits the kind into
  whole words and the last matching one wins; `config` is the only matching
  word in all three kinds (`table`, `table_array` and `key` match nothing), so
  a TOML file's contents are reachable as configuration, which is what they are.
- **Array strings are the one link TOML has.** A workspace member, a feature
  name, an extension id is a name that lives somewhere else in the repository.
  Stated as `relation.data` under the unquoted text, it is a `data` occurrence
  the resolver can match by name, and it is the only mention the Pack makes.

Five patterns, each rooted at one node, replace 26. The three guards say what
the Pack genuinely cannot see: that tables are not merged, that a compound
value is not stored as text, and that an array string's link is by name only.

## Still to decide

1. **Whether every pair should be a declaration.** A `Cargo.lock`-shaped file
   or a large generated TOML declares one Config entity per line. Provisionally
   yes: the alternative is guessing which keys matter, which is a per-tool
   judgement and therefore an overlay's. Revisit against row counts on a real
   corpus.
2. **Whether array strings should be `relation.data` or `relation.depends`.**
   `depends` is what the members of `[dependencies]` are, but the Pack cannot
   tell a dependency list from a keyword list without knowing the consuming
   tool's schema, and that knowledge belongs in `frameworks/`. `data` is the
   honest weaker claim.
3. **Numbers and dates inside arrays** are not emitted. A bare number in a list
   names nothing; if a use appears for it, it belongs as an attribute on the
   key, not as a mention.
