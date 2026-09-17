# omega-ini

Language `omega-ini`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

3 templates over 3 query patterns, 2 distinct root node types
(`section`, `setting`).

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_section` | Config | 1 |
| `definition.config_key` | Config | 2 |

`definition.config_key` is two templates over two mutually exclusive patterns --
a setting whose `setting_name` is followed by a `setting_value`, which carries
the trimmed value as the attribute `value`, and a setting whose `setting_name`
is its last named child, which carries none. They are one construct in the only
two shapes it has, not the same fact stated twice; the trailing anchor is what
keeps them apart, since tree-sitter cannot say "no value" any other way.

### Mentions

None. INI has no syntax that says a value names something declared elsewhere:
a value is an opaque string whose meaning belongs to the application reading
it. Anything stated as a mention here would resolve by bare text alone.

### Regions

None. A setting written under a section header already lies inside that
section's declaration span, so the host derives the qualified name from the
nesting and a `scope.*` region would state it a second time.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 8 node types. The Pack looks at 6 of them
(`section`, `section_name`, `text`, `setting`, `setting_name`, `setting_value`).

Untouched:

- `document`
- `comment`

`document` is the file; it names nothing, and a declaration inside it is already
in the file. `comment` is prose -- the old Pack emitted every comment as a
mention named by its own text, which is one row per comment line in every INI
file in a repository, resolving against nothing.

## What is wrong with it

The Pack that was here stated 9 templates over 7 patterns and 1 guard, and
almost none of it answered a question.

**It declared nothing at all.** Zero of its 9 templates passed
`is_definition_kind`: five were `semantic_hint.ini_lexical_role`, one
`semantic_hint.ini_literal_hint`, one `semantic_hint.ini_value_hint`, one
`structured.ini_section` and one `structured.ini_setting`. Its only declared
capability was `data`. So an INI file -- `tox.ini`, `setup.cfg`, `.gitconfig`,
`php.ini`, a systemd unit, `my.cnf` -- contributed no declaration to the index.
An agent asking *where is `max_connections` set* or *what sections does this
file define* got nothing, while all nine kinds arrived as the same
undifferentiated plain reference.

**Seven of the nine templates were syntax highlighting.** The whole
nvim-treesitter highlights baseline was pinned into the query file with a
provenance header naming its upstream, and given a template each:
`@markup.heading`, `@comment`, `@spell`, `@punctuation.bracket`, `@operator`,
`@property`, `@string`. Two of those are one capture under two names -- the
`(comment)` node is captured as both `@comment` and `@spell`, so every comment
line in the corpus produced **two identical emissions**. The
`["[" "]"] @punctuation.bracket` and `"=" @operator` patterns matched every
bracket and every `=` in every INI file in the repository, for an emission whose
name is the single character `[`, `]` or `=`. That is three matches and three
rows per settings line, naming punctuation.

**Three templates named an emission with a whole node** (audit classes D and
D2): `@comment` and `@spell` both named a `comment` from its own span, and that
node has a named `text` child, so the entire comment's subtree was the name;
`@markup.heading` named the `section_name` from its own span, brackets
included, so a header stored `[client]` where the name is `client`.

**The one guard was a label.** `"INI section and key/value structure is exact
authored data; interpolation, application-specific schema and effective
configuration semantics remain external to this Pack"` is generator vocabulary
stating that the Pack is a Pack. Three of the words in it -- interpolation,
dialect schema, merge -- name real limitations, and they are written out as
three guards now, each in language terms.

**Two patterns asked for the node the other already had.** The highlights block
rooted separately at `(section_name (text))` and at `(setting (setting_name))`,
and the `terminal_structured_ini_v1` block rooted at `(section ...)` and
`(setting ...)` again, so a single settings line was matched twice over and a
header three times. One pattern per node, several templates over it.

**The value was a `field`, not an attribute.** `structured.ini_setting` put
`setting_value` in `fields`, which the framework overlay layer matches on, and
no framework Pack in this repository reads any `ini` fact at all
(`grep -r ini_setting frameworks/` is empty). The value is stored where a
question can read it now, as the attribute `value`, the same spelling
omega-toml and omega-json use.

## What it should extract

An INI file is read by exactly one tool: pip, tox, flake8, git, PHP, systemd,
MySQL. The questions an agent asks are *where is this setting declared*, *what
is it set to*, and *what sections does this file define*. Everything below
answers one of those; nothing else is stated.

| what | node | emitted as | family |
|---|---|---|---|
| a section header, `[client]` | `section`, named by the `text` inside `section_name` | `definition.config_section`, span = the whole section | Config |
| a setting with a value, `port = 3306` | `setting`, named by `setting_name` | `definition.config_key`, value trimmed into the attribute `value` | Config |
| a setting written with no value, `no_auto_abbrev=` | `setting` whose `setting_name` is its last named child | `definition.config_key`, no value | Config |
| a setting written under a section header | -- | nothing extra: it is already inside that section's declaration | -- |
| the file, comments, brackets, the `=` | `document`, `comment`, `"["`, `"]"`, `"="` | nothing | -- |

Three things follow from this shape:

- **Containment is free.** `[mysqld]` is a declaration spanning the whole
  section and `port = 3306` is a declaration inside it, so the host derives
  `mysqld.port` from the nesting. No pattern, and no `scope.*`, is needed to
  say it.
- **Every declaration lands in Config.** `entity_family` splits the kind into
  whole words and the last matching word wins; in `definition.config_section`
  and `definition.config_key` the only matching word is `config` (`section` and
  `key` match nothing), so an INI file's contents are reachable as
  configuration, which is what they are.
- **The Pack makes no mention at all**, and `references` is not declared. That
  is the honest position for this format: a value is an opaque string, and a
  string that happens to match a declaration elsewhere is not evidence of a
  link. If a particular tool's INI keys do name code -- `console_scripts` in
  `setup.cfg`, a unit's `ExecStart=` -- that is the consuming tool's schema and
  belongs in `frameworks/`.

Three patterns, each rooted at one node, replace seven. The three guards say
what the Pack genuinely cannot see: that sections are not merged, that a value
is authored text with no interpolation expanded, and that this grammar knows
only one of INI's several dialects.

## Still to decide

1. **Whether to strip quotes from a value.** omega-toml unquotes, because TOML
   has one quoting rule. INI has none: `.gitconfig` and `php.ini` quote,
   `my.cnf` and `.editorconfig` do not, and `strip_prefix`/`strip_suffix` are
   independent, so an unbalanced quote in a Windows path would be half-stripped.
   The value is trimmed and otherwise stored as authored. Revisit if a consumer
   needs the unquoted form; the right place for it may be the overlay that
   knows the dialect.
2. **Whether an empty-valued setting should be declared at all.** It is here,
   because `key=` is how several dialects spell "present but unset" and the
   question *is this set in this file* is a real one. If it proves to be noise
   on a real corpus, the pattern is one block to delete.
3. **Whether a repeated section header should be one declaration or two.** Two
   today, with a guard saying so. Merging would need a rule about which dialect
   appends and which replaces, which the Pack cannot know.

## The audit after the rewrite

`python pack-design/audit.py omega-ini` reports
`omega-ini: 3 templates over 3 patterns, 3 guards` and no defect class.
