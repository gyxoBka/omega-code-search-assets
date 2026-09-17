# omega-markdown

Language `omega-markdown`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

6 templates over 7 query patterns, 16 distinct node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 2 |
| `references` | yes | 2 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.section` | Value | 1 |
| `definition.link_reference` | Value | 1 |

### Regions

| kind | templates |
|---|---|
| `scope.section` | 1 |
| `scope.code_block` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 1 |
| `reference.documented_term` | reference | 1 |

### Injections

Fenced code by its info string, `html_block` as HTML (combined), and `---` YAML
front matter. No decoders, no carriers, no constant attributes.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 51 node types. The Pack looks at 16 of them.

Untouched:

- `atx_h1_marker`, `atx_h2_marker`, `atx_h3_marker`, `atx_h4_marker`, `atx_h5_marker`, `atx_h6_marker`
- `backslash_escape`
- `block_continuation`
- `block_quote`, `block_quote_marker`
- `document`
- `entity_reference`
- `fenced_code_block_delimiter`
- `indented_code_block`
- `link_title`
- `list`, `list_item`
- `list_marker_dot`, `list_marker_minus`, `list_marker_parenthesis`, `list_marker_plus`, `list_marker_star`
- `numeric_character_reference`
- `pipe_table`, `pipe_table_align_left`, `pipe_table_align_right`, `pipe_table_delimiter_cell`, `pipe_table_delimiter_row`, `pipe_table_header`
- `plus_metadata`
- `setext_h1_underline`, `setext_h2_underline`
- `task_list_marker_checked`, `task_list_marker_unchecked`
- `thematic_break`

Most of these are markers and punctuation: the six ATX markers, the two setext
underlines, the five list markers, the block-quote marker, the fence delimiter,
the thematic break. They say how a construct is spelled, not what it names, and
the construct itself is already stated. `document` is the file. `block_quote`,
`list` and `list_item` hold prose; the text inside them is in the tree as
`inline`, which this parser does not open. `task_list_marker_checked` and
`task_list_marker_unchecked` are declared by the grammar but **unreachable in
this parser**: no block node lists them as a child, because they are produced by
the inline grammar, which is not what `tree-sitter-markdown` pins here.
`link_title` is deliberately left out - see "Still to decide".

## What is wrong with it

The Pack that was here had **29 templates over 35 patterns and 5 guards**, and
**28 of the 29 templates were a syntax highlighter**.

**It was three editor colour schemes concatenated.** The file's own section
comments say so: `asset-exact-helix-highlights`,
`completeness_definitions_semantic2`, `nvim_pinned_injections`. Every capture
name is a highlight class - `@markup.heading.1`, `@markup.raw.block`,
`@markup.list`, `@string.escape`, `@markup.quote`, `@label`,
`@punctuation.special`. A highlight class is a colour, not a fact about a span,
and 23 of the 29 templates turned one into an emission whose kind was
`semantic_hint.markdown_lexical_role` - "this span is syntax of some sort". No
question reaches that.

**Twenty templates named a span with the span itself (D2).** Every heading
template was `span_capture: markup.heading.N`, `name: @markup.heading.N`, where
the capture is the whole `atx_heading` or the whole `setext_heading`. So the
name of a heading emission was `## Installing the daemon` including the marker -
and for setext, the whole underlined paragraph. `semantic_hint.markdown_code_block`
was named from `@markup.raw.block`, which is the entire fenced block: **every
code example in the repository was stored once as a name.** `markup.quote` was
the whole block quote. That is the single biggest cost in the old Pack and it is
the reason a docs-heavy repository indexes badly.

**Nine templates restated a fact the Pack had already stated (K2).** Each of the
six heading levels, plus the link label, the link URL and the code block, was
emitted twice over the same span with the same name: once as
`semantic_hint.markdown_heading` and again as
`semantic_hint.markdown_lexical_role`. Two kinds, one fact, double the rows.

**Two patterns hard-coded containment three levels deep (E).**
`section_h1_h2_h3_context` is `(section (section (section)))` with the headings
captured at each level, and `section_h1_h2_h3_list_item_context` is the same
shape plus `(list (list_item (paragraph (inline))))` - six levels. The tree
already nests sections, and the host already carries a declaration's container
through `within:`. Worse, the H1/H2/H3 shape only matches when the document uses
exactly three levels in exactly that order; a document that starts at H2, or
nests an H4, states nothing at all. And the list-item pattern was one emission
per bullet, named with the bullet's whole text.

**Only one thing in the whole Pack was declared under a name a question could
resolve to** - `definition.markdown_link_reference`, from
`link_reference_definition`. Headings, the only other named thing in Markdown,
were emitted as `semantic_hint.*` mentions: references to nothing. So "where is
the retry policy documented?" had nothing to match.

**One carrier that folded onto nothing.** `definition.markdown_candidate` over
`(atx_heading)`/`(setext_heading)`, carrying `omega.pack.markdown` - a name the
engine never assembles and never reads, folded onto a declaration at the
heading's span that the Pack did not emit.

**Three of five guards gave a label, not a limitation (G):**
`terminal_static_ceiling__markdown_exact_helix_highlights_roles`,
`markdown_highlight_capture_not_symbol_truth`, and a 90-character run-on ending
`_may_include_declaration_or_reference_overlap`. The other two described the two
containment patterns that are now gone.

**Two injections used `#offset!`,** which tree-sitter parses into a bucket this
runtime does not read. The front-matter injections were written assuming the
`---` / `+++` fences would be trimmed off. They were not: the YAML and TOML
parsers were handed the fences.

**`definitions` was declared for a carrier and a link label; `data` carried 29
templates of colour.** The manifest was honest about which capabilities had
templates and dishonest about there being anything to ask of them.

## What it should extract

Markdown is where a project's prose lives: READMEs, ADRs, design notes,
changelogs, guides, and the `docs/` tree. The questions an agent asks of it are
*where is this documented*, *what does this document point at*, *what language
is this example written in*, and *what section did this answer come from*.

Markdown names exactly two things - a section, by its heading, and a link
reference, by its label - and the Pack should declare both and state nothing
else as a name.

| what | node | emitted as | family |
|---|---|---|---|
| a section | `atx_heading` / `setext_heading` via `heading_content:` | `definition.section` | Value |
| the section's extent | `section` | `scope.section`, named by the heading | region |
| a link reference definition | `link_reference_definition` via `link_label` | `definition.link_reference`, lower-cased | Value |
| what that link points at | `link_destination` | `relation.depends` | depends |
| a fenced example's extent and language | `fenced_code_block` via `info_string`/`language` | `scope.code_block`, named by the language | region |
| the term a table row documents | `pipe_table_row` first `pipe_table_cell` | `reference.documented_term` | reference |
| fenced code, front matter, raw HTML | `code_fence_content`, `minus_metadata`, `html_block` | injections into the real grammar | - |
| markers, delimiters, breaks, escapes | `atx_h*_marker`, `list_marker_*`, `thematic_break`, `backslash_escape`, ... | nothing | - |

Four things follow from this that are worth saying plainly.

**A section is a Value, and that is right.** `definition.section` contains none
of the host's Type, Callable, Config or Test words, so `entity_family` files it
under Value. A documentation section is not a type and not a callable; what is
asked of it is where it is and what it says, and Value is where that lives.

**Heading level is not stated, on purpose.** The old Pack spent six templates on
it. The grammar already nests `section` inside `section`, so an H3's declaration
is inside its H2's region, and the host carries that through `within:`. Storing
`##` as an attribute as well would be the depth written twice. It would also
cost the one-pattern shape: the ATX marker capture does not exist on a setext
heading, and an attribute whose capture is unbound skips the template, so a
level attribute would silently delete every setext heading from the index.

**The regions are the point.** With `scope.section` and `scope.code_block` in
place, a definition the injected Python grammar finds inside a fenced block in
the "Configuration" section of `README.md` comes back with both. That is what
replaces 23 `semantic_hint.markdown_lexical_role` emissions: not a smaller
answer, a locatable one.

**The table row is the one judgement call that earns its place.** Documentation
tables are `name | meaning`: config keys, CLI flags, environment variables,
error codes. Its first cell is the term the row is about, so the row becomes a
mention that resolves onto the declaration of that term in the code - the edge
from "documented" to "implemented". It is anchored to the first cell of a
`pipe_table_row`, so the header row (whose first cell names a column, not a
term) and the prose cells are left alone: one emission per table row, not one
per cell.

## Still to decide

1. **`link_title` is not captured.** It is optional, and an attribute whose
   capture is unbound skips the whole template, so capturing it would drop every
   untitled link definition - which is nearly all of them. Stating it would take
   a second pattern for the titled form, which is defect K by another name. Left
   out; revisit if a question is ever asked of a link's title.
2. **TOML front matter is no longer injected.** Without `#offset!` the `+++`
   fences reach the parser, and `+++` is not valid TOML. `---` *is* a valid YAML
   document-start marker, so the YAML injection is correct untrimmed and is
   kept. Restoring TOML front matter needs the injection layer to support a
   byte-range offset; that is a host change, not a Pack one - see below.
3. **Inline content is invisible and always will be, with this grammar.**
   `tree-sitter-markdown` ships two grammars and the pinned one is the block
   grammar; `inline` is a leaf. So inline links `[text](./x.md)`, autolinks,
   code spans and emphasis are not in the tree. This is stated as a coverage
   guard rather than worked around. Pinning `tree-sitter-markdown-inline` as a
   second grammar and injecting it would open all of that, and is the single
   largest available improvement to this Pack - but it is a new grammar asset,
   which is outside the scope of a Pack rewrite.
4. **Nothing in Markdown is a test, a type or a callable.** No capability beyond
   `definitions`, `references` and `scopes` is declared, and none should be.

## A defect in the host

Not a blocker, and not fixed here. The injection layer reads
`injection.language`, `injection.combined` and `injection.include-children` from
`#set!`, but has no equivalent for nvim-treesitter's `#offset!`, which adjusts
the injected byte range. Every language whose embedded content is delimited by
fences the inner grammar cannot parse - TOML front matter in Markdown is the
clean example - either injects garbage or cannot be injected at all. A generic
`injection.offset` property on the injection config would close it without a
language branch. Reported rather than changed.
