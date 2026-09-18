# omega-editorconfig

Language `omega-editorconfig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

3 templates over 3 query patterns, 2 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_section` | Config | 1 |
| `definition.config_key` | Config | 2 |

### Mentions

None. An `.editorconfig` file references nothing: a key is a name the
specification fixes, a value is a token, and a glob is a pattern over paths,
not a mention of a declaration anywhere in the repository.

### Carried attributes

| attribute | on | what it answers |
|---|---|---|
| `value` | `definition.config_key` | what the setting is set to |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 17 node types. The Pack looks at 6 of them:
`section`, `header`, `glob`, `pair`, `property`, `string`.

Untouched, and why:

- `editorconfig` -- the document. It names nothing.
- `preamble` -- the run of pairs before the first header. It is not a construct;
  it is a position, and the host already gives a pair its position by whether it
  lies inside a `section` span.
- `comment` -- prose.
- `brace_expansion`, `character_choice`, `character_range`, `integer_range`,
  `wildcard`, `character_escape`, `character`, `integer` -- the glob's own
  sub-syntax. These describe *how* a pattern matches, not what it names. A
  question about `[*.{js,ts}]` is a question about that section; there is no
  question whose answer is the brace expansion inside it.

## What is wrong with it

**Both of its two templates existed to restate containment.** The Pack had one
kind for a pair in the preamble (`structured.editorconfig_global_setting`) and
another for a pair inside a section (`structured.editorconfig_section_setting`),
which is the same node under two patterns telling apart two *places*. The
section pattern spelled the containment out --
`(section (header (glob)) (pair ...))` -- so it matched once for every
(section, header, pair) tuple, and the section's glob was copied into a `pattern`
field on every setting in it. The tree already holds that, and the host already
carries it through the `within:` namespace segment. That is Defect E, at 100% of
the Pack's templates.

**Nothing in the file was declared.** Both kinds began `structured.`, which
contains no `definition` and ends in none of the five suffixes, so both fell to
the mention branch and became **plain references** -- references with nothing to
resolve against, because the Pack declared nothing anywhere. An agent asking
where `indent_style` is configured in a repository got no declaration back. The
`data` capability was the only one declared, for two kinds the `data`/`literal.*`
rule does not even drop, so it was carrying mentions under a capability meant
for values.

**The section header was never stated at all.** `[*.py]` -- the single thing an
`.editorconfig` file is organised around -- was emitted only as a `pattern`
field hung off each setting. There was no emission whose name was the glob and
no span covering the section, so "which file patterns does this project
configure" had no answer and the settings had no container to nest inside.

**A guard that described the generator rather than the language.** Two guards,
and the second -- *"Universal named-node capture provides syntax-aware indexing
only. Language-specific definitions/references/types/calls are intentionally
outside this Pack static source contract."* -- named a universal capture that
does not exist in the file. Below it in `queries.scm` sat a `structural-fallback`
header with a comment promising "every named syntax node" and no pattern under
it: a section title, a claim, and nothing that does it. The first guard was one
267-character sentence stacking four separate limitations.

## What it should extract

An `.editorconfig` file is read by every editor, most formatters and several
linters. The questions asked of one are *which file patterns does this project
configure*, *where is this setting declared*, and *what is it set to*.

| what | node | emitted as | family |
|---|---|---|---|
| a section header `[*.{js,ts}]` | `section` via `header (glob)` | `definition.config_section`, named by the glob, spanning the whole section | Config |
| a setting `indent_style = space` | `pair` via `key: (property)`, `value: (string)` | `definition.config_key`, named by the lowercased key, `value` attribute | Config |
| a setting with an empty value | `pair` with `property` as its last named child | `definition.config_key`, no `value` | Config |
| the preamble's `root = true` | the same `pair` pattern | `definition.config_key`, outside every section span | Config |
| which section a setting is in | -- | the host's `within:` segment, from the section span | -- |
| the glob's sub-syntax | `wildcard`, `brace_expansion`, `character_range`, `integer_range` | nothing | -- |
| a comment, the document, the preamble node | `comment`, `editorconfig`, `preamble` | nothing | -- |

Three patterns, one per node, and no pattern that reaches through one node to
another to say where it sits. `definition.config_section` and
`definition.config_key` both split to a word list whose last matching word is
`config`, so both land in **Config**, which is what they are.

The key is stored lowercased. The specification defines EditorConfig keys as
case-insensitive, so `Indent_Style` and `indent_style` are one declaration and
resolve to each other; the authored spelling is still in the span. The value is
trimmed and otherwise left as authored -- it is *not* lowercased, because values
such as a `charset` or a `file_type_ext` are not uniformly case-folded.

Three guards, one limitation each: the glob is not expanded or matched, the
cascade across parent directories and the later-section-wins override are not
evaluated, and the value is stored as written.

## Still to decide

1. Whether a setting should also be a `relation.config` occurrence pointing at
   something. It has nothing to point at: a `relation.config` needs a Config
   target, and the thing an `.editorconfig` setting configures is the editor,
   which is not in the index. Left as a declaration only.
2. Whether a glob that names one concrete file -- `[Makefile]`, `[package.json]`
   -- should be a `relation.depends` occurrence onto that file. It would resolve
   for the literal cases and for nothing else, and `relation.depends` admits only
   Artifact, Namespace, Callable and Contract at either end, so a section (Config)
   could not be its source. Left out.
