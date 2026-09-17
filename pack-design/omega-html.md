# omega-html

Language `omega-html`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. The tables below describe the Pack as it now stands; the state it
replaced is in **What was wrong with it**.

## What it states today

9 templates over 13 query patterns (9 feeding templates, 4 feeding the
injection layer), 6 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 5 |
| `references` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.element_id` | Value | 1 |
| `definition.form_field` | Value | 1 |
| `definition.config_meta` | Config | 1 |
| `definition.page_title` | Value | 1 |
| `definition.section_heading` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 1 |
| `reference.element_id` | reference | 2 |
| `reference.custom_element` | reference | 1 |

### Regions

None. An HTML element's extent is not stated: see **What it should extract**.

### Injections

Four patterns, no template. `<style>` and `<script>` raw text, a `<script>` or
`<style>` whose `type`/`lang` names a language, and an `on*` handler attribute.
The media types are mapped onto grammars by the Pack's `language_aliases`
table, so `type="text/javascript"`, `type="module"`, `type="importmap"` and
`type="application/ld+json"` all resolve.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 19 node types. The Pack looks at 13 of them.

Untouched, and why:

- `document` — the file itself. It has no name a question could reach; naming
  it stores the page as a string, which is what the old Pack did.
- `doctype` — `<!DOCTYPE html>` is the same three words in every file.
- `comment` — not a declaration and not a link.
- `entity` — `&amp;` is fixed by the HTML specification. Nothing declares an
  HTML entity, so a mention of one resolves against nothing.
- `erroneous_end_tag`, `erroneous_end_tag_name` — a parse error, not a
  construct.

## What was wrong with it

Measured with `pack-design/audit.py omega-html` before the rewrite:
**15 templates over 32 patterns, 3 guards**, touching 14 node types.

**Six of nine of its emission kinds named themselves with a whole node**
(audit: D2 = 6, D = 2). `scope.lexical` and `scope.html_lexical_scope` were
both `(element) @local.scope` named by the element's own text, so every
`<div>` in the corpus was stored twice under a name that is its whole subtree
— the page written out again once per level of nesting. `value.element`,
`value.attribute`, `value.embedded_script_region` and
`value.embedded_style_region` did the same for `(self_closing_tag)`,
`(attribute)`, `(script_element)` and `(style_element)`; the last two store
every line of embedded JavaScript and CSS as the *name* of a mention.

**The same fact under two kinds** (audit: K2 = 1). `@local.scope` fed both
`scope.lexical` and `scope.html_lexical_scope`: one region emitted twice, the
generator's two passes never reconciled.

**Two of three guards were labels** (audit: G = 2):
`terminal_static_ceiling__html_exact_helix_highlights_roles` and
`html_embedded_language_semantics_require_injection_runtime`. Neither says
anything about HTML that a reader could act on.

**The Pack declared nothing at all.** Not one `definition.*` kind, and
therefore not one name any question could resolve to. Nine of its fifteen
templates were mentions, and every one of them arrived as a plain reference —
`data.*`, `value.*`, `semantic_hint.*` and `reference.*` alike — resolving
against a declaration set that was empty. An agent asking *where is `#main`*,
*where is the field the login form posts*, or *which page loads `app.js`* got
nothing back.

**Five templates were a highlighting model, not an answer set.** `(tag_name)
@tag`, `(attribute_name) @attribute`, `(doctype) @constant`, `(entity)
@string.special.symbol` and `(attribute) @data.attribute` are one emission per
token of every file. `semantic_hint.html_tag` stored every opening and closing
tag name in the corpus — `div` about as often as there are `<div>`s — as a
mention of nothing. This is Defect I in its second spelling: a bare capture on
a leaf the grammar produces everywhere.

**One emission per attribute of every page, named by its tag.**
`data.html_attribute_context` captured `(start_tag (tag_name) (attribute
(attribute_name) (attribute_value)))` with no filter, and named the emission
with the **tag**, so every attribute in the repository was stored under the
name `div`, `a` or `span`, with the real content in fields. Two templates of
it (start tag and self-closing tag), plus `data.html_element_text_context`
naming an element's text by the tag, plus
`reference.html_resource_url_context`, which was the same pattern again with
`#any-of? @attr "href" "src"` — four patterns over the same node to say four
things one match could carry.

**The nvim-treesitter inheritance.** `(element) @local.scope`, its two scope
templates, and an `asset-exact-helix-highlights` block of six patterns
(`@markup.bold`, `@markup.italic`, `@markup.strikethrough`,
`@markup.link.label`, `"=" @punctuation.delimiter`) that exist to colour an
editor. `00-INDEX.md` names omega-html as one of the three Packs still
carrying a wired-up `locals.scm` baseline; that is now gone, and with it the
provenance headers naming nvim-treesitter and helix.

**Three `#offset!` directives in the injections.** tree-sitter has no
`#offset!`; it parses into the bucket nothing reads, so the two lit-html
`${...}` injections fired on the raw attribute value with its quotes and
braces still attached. Both patterns are removed. (`audit.py`'s
`NOT_TREE_SITTER` list does not include `offset!`, so this class was not
measured — see the cross-Pack note.)

## What it should extract

HTML is the page and template layer of a project. What is asked of it is
*which element is `#main`*, *where is the form field the server reads*, *what
does this page load*, *which component is used here*, and *what does the page
say about itself*.

| what | node | emitted as | family |
|---|---|---|---|
| an element with an `id` | `start_tag`, `self_closing_tag` via the `id` attribute | `definition.element_id`, carrying `tag` | Value |
| a form control's `name` | `start_tag`, `self_closing_tag` on `input`/`select`/`textarea`/`button`/`output`/`fieldset`/`form` | `definition.form_field`, carrying `control` | Value |
| `<meta name=... content=...>` | `start_tag`, `self_closing_tag` | `definition.config_meta`, carrying `content` | Config |
| `<title>` | `element` + anchored `text` | `definition.page_title` | Value |
| `<h1>`…`<h6>` | `element` + anchored `text` | `definition.section_heading`, carrying `level` | Value |
| a script, stylesheet, image, iframe or form target | `src`, `href`, `action`, `formaction`, `poster` | `relation.depends`, carrying `tag` and `attribute` | depends |
| `href="#main"` | the `href` attribute, `#` stripped | `reference.element_id` | reference |
| `for=`, `form=`, `list=` | the attribute | `reference.element_id` | reference |
| `<my-widget>` | `tag_name` containing a hyphen | `reference.custom_element` | reference |
| `<script>`, `<style>`, `on*=` | `raw_text`, `attribute_value` | injection, no emission | — |
| `class`, `style`, every other attribute | — | nothing | — |
| containment, the document, doctype, comments, entities | — | nothing | — |

Three decisions behind that table.

**`id` is the only name HTML declares, and it is global to the document.** So
there is no scope region and no containment pattern: an element's ancestry is
not a namespace for its id, and the tree already holds the ancestry for
everything else. The span of an id declaration is the opening tag, not the
element, which also makes the shape uniform across `<div id=..>`,
`<img id=..>`, `<br id=../>` and `<script id=..>` — the last is a
`script_element`, not an `element`, so an element-rooted pattern would have
missed it.

**A fragment and a resource are the same attribute with different meanings.**
`href="#main"` resolves onto a declaration in this file; `href="/docs/"`
names something outside it. They are split in the query by `^#`, not in a
template, because a template cannot filter. The `#` is stripped so the
reference and the declaration are the same string.

**Names are matched case-insensitively.** HTML is; `<INPUT NAME=x>` is the
same declaration as `<input name=x>`. Every tag and attribute filter is a
`#match?` with `(?i)`, and `tag`, `control`, `level` and `attribute` values
are lowered before they are stored, so they collate.

Every kind was checked against `entity_family` (§5 of the brief): none of
`element_id`, `form_field`, `page_title` or `section_heading` contains a word
from the Type, Callable, Namespace or Test rows, so all four are Value, which
is what they are — named things in a document, not types. `config_meta`
contains `config` and is Config, which is what a `<meta>` is: page
configuration, a key with a value. `relation.depends` is one of the six
relations the host knows.

## Still to decide

1. **`class`.** The link from a page to its stylesheet is the class attribute,
   and it is not stated. A class attribute holds a whitespace-separated list;
   a template produces one name per emission, and `select(split(v, " "), "2")`
   would state a fixed number of them and silently drop the rest. Against
   that, a Tailwind or Bootstrap page carries a dozen utility names on every
   element, so the emission count would dwarf everything else in the Pack for
   names that are a styling vocabulary rather than an identity. Left out, with
   a guard. Revisit if omega-css's declarations turn out to be worth resolving
   against at that price.
2. **`<slot name=..>` and `slot=..`.** A real declaration/reference pair in
   web components, spelled as two ordinary attributes. Not stated, because
   `slot` is one tag and the pair would need two more patterns; add it if
   custom elements turn out to be used in the corpus.
3. **`data-*` attributes.** `data-controller`, `data-testid`, `data-action`
   are read by JavaScript by name, but each convention belongs to a framework,
   and a language Pack states syntax. Left to overlays.

## A cross-asset consequence

`omega-framework-angular` has six rules (`angular.template.input-binding`,
`.event-binding`, `.structural-directive`, `.reference`, `.router-link`,
`.element`) that match `fact_kind = data.html_attribute_context` and
`data.html_element_text_context` on `**/*.component.html`, reading the fields
`tag`, `attribute_name` and `attribute_value`. Those two kinds were the
unfiltered per-attribute emission described above, and they are gone, so
**those six rules now match nothing**. This is the same shape as the
omega-json / OpenAPI finding in `00-INDEX.md` wave 6, and the same answer: the
overlay should be rewritten against what the language Pack states, not the
language Pack kept emitting every attribute of every page so that an overlay
can filter it by a prefix. Angular's `[foo]`, `(foo)`, `*ngIf` and `#ref`
spellings are Angular's, and a pattern that recognises them belongs in
`frameworks/`, which can carry its own query.
