# omega-astro

Language `omega-astro`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

9 templates over 13 query patterns (4 of them injections), 6 distinct root node
types: `start_tag`, `self_closing_tag`, `attribute`, `interpolation`,
`frontmatter`, and `script_element`/`style_element`.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 2 |
| `references` | yes | 7 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.element_id` | Value | 1 |
| `definition.slot` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `reference.astro_component` | reference | 1 |
| `reference.astro_hydration` | reference | 1 |
| `reference.astro_value` | reference | 1 |
| `reference.custom_element` | reference | 1 |
| `reference.element_id` | reference | 1 |
| `reference.slot` | reference | 1 |
| `relation.depends` | depends | 1 |

### Injections

The frontmatter and a `<script>` without `lang` go to TypeScript, a `<style>`
without `lang` to CSS, and a `lang` attribute on either overrides both through
the alias table. Everything an `.astro` file imports, computes and defines is
stated by those Packs, not by this one.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 20 node types. The Pack looks at 12 of them.

Untouched:

- `comment`
- `doctype`
- `element`
- `end_tag`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `fragment`
- `text`

`element` and `fragment` are containers and are deliberately not stated: the
tree already holds containment (Defect E), and a page has no lexical scope for
an `id`, which is global to the document. `end_tag` restates the `start_tag`
name, and the two `erroneous_end_tag` types are a parse error. `text` is prose;
see the guard. `doctype` and `comment` name nothing a question resolves to.

## What is wrong with it

The Pack that was here declared **nothing at all**. Its nine templates were all
under `data` and every one of them was a mention: `data.astro_element`,
`data.astro_frontmatter`, `data.astro_interpolation`,
`data.astro_script_section`, `data.astro_style_section`,
`structured.astro_attribute_value`, `structured.entry`, plus the two
`scope.astro_*` regions a repository-wide sweep had already removed by the time
this rewrite began -- the state found on disk was 7 templates over 12 patterns
with 1 guard. An `.astro` file therefore contributed no declaration to the
index, and the seven mention kinds all arrived as the same occurrence sort, a
plain reference, so nothing could be asked of them and nothing could resolve to
them.

Concretely, of the 7 templates found:

- **Four named nothing.** `data.astro_frontmatter`, `data.astro_interpolation`,
  `data.astro_script_section` and `data.astro_style_section` carried no `name`
  expression, and a template with no name is named by its span capture's own
  text. So one emission stored *the whole frontmatter*, one *the whole
  `<script>`* and one *the whole `<style>`* of every file as a name -- the
  largest strings in an Astro repository, written into the index once each, for
  a fact (*there is a frontmatter here*) no question asks. This is Defect D in
  its worst form.
- **Two stated every attribute of every tag.** `structured.entry` fired on each
  `attribute` node, named by its attribute name, and
  `structured.astro_attribute_value` fired again on each attribute that had a
  value, repeating the name and carrying the value in a field. On a page of
  twenty tags that is forty-odd emissions whose names are `class`, `id`,
  `href`, `alt`, resolving to nothing.
- **One stated every tag**, named by its tag name, so `div`, `p` and `span`
  were among the most-mentioned names in the corpus.
- **The Astro language was not visible in it.** No component tag, no `client:`
  directive, no slot, no expression -- nothing that distinguishes an `.astro`
  file from an HTML file with a header. The only Astro-specific statement in
  the whole Pack was the frontmatter injection.
- **One guard, whose reason was one token**: `bounded_structural_semantics_only`
  (Defect G) -- the single defect the audit flagged.
- **An nvim-treesitter locals provenance block** of eleven comment lines sat in
  the middle of `queries.scm`, with a `; inherits: html` marker and two resolved
  source hashes, carrying no pattern and documenting a baseline the Pack no
  longer contained.
- The manifest declared `capabilities = ["data"]` -- a capability under which
  every emission was either dropped or stored as a nameless reference -- and
  `source = "Omega clean production normalization"`.

## What it should extract

An `.astro` file is a page or a component in an Astro site. Its frontmatter is
TypeScript and its script and style are handed to their own Packs, so the
questions left to this Pack are about the markup: *which components does this
page use*, *which of them ship JavaScript to the browser*, *what slots does
this component offer and which one does this child fill*, *which element is
`#main`*, *what does this page load*, and *which frontmatter value is rendered
here*.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a component tag, `<Card>`, `<Ui.Button>` | `start_tag`, `self_closing_tag` via `tag_name` matching `^[A-Z]`, reduced to the first dotted segment | `reference.astro_component` | reference |
| a hydrated component, `client:load`, `client:only` | the `client:` `attribute` on such a tag, named by the component | `reference.astro_hydration`, attribute `directive` | reference |
| a web component, `<my-widget>` | `tag_name` containing a hyphen, lowered | `reference.custom_element` | reference |
| `<slot name="header"/>` | `start_tag`/`self_closing_tag` of `slot` with `name` | `definition.slot` | Value |
| `slot="header"` on any tag | `attribute` | `reference.slot` | reference |
| `id="main"` | `start_tag`/`self_closing_tag` with `id`, attribute `tag` | `definition.element_id` | Value |
| `href="#main"` | `attribute`, `#` stripped | `reference.element_id` | reference |
| `src`, `href`, `action`, `poster` | `start_tag`/`self_closing_tag`, attributes `tag` and `attribute` | `relation.depends` | depends |
| `{title}`, `title={heading}` | `interpolation` via `raw_text`, only when it is one identifier | `reference.astro_value` | reference |
| the frontmatter, `<script>`, `<style>` | `frontmatter`, `script_element`, `style_element` | injection only | -- |
| an element, the fragment, an end tag, a doctype, a comment, prose text | -- | nothing | -- |
| any other attribute | -- | nothing | -- |

Two of these make the one loop the language closes on its own: an `id` is
declared once, and `href="#..."`, a `#main` selector in the injected `<style>`
and `getElementById` in the injected `<script>` all resolve onto it. The slot
pair is the second: `definition.slot` and `reference.slot` share a spelling and
meet. Everything else resolves outward, onto the import the frontmatter
declares -- which is why a component name is reduced to its first dotted
segment, the segment the `import` binds.

`definition.slot` lands in Value, which is right: a slot is a named extension
point, not a type and not a callable, and the question asked of it is which
children fill it. `definition.element_id` is Value for the same reason.
`relation.depends` is one of the six relations the host knows and its target is
an Artifact -- a file -- which is a family `relation.depends` admits at either
end.

The `client:` directive is Astro's own template syntax, not a framework's API,
so it belongs in the language Pack; *which* UI framework renders a
`client:only="react"` island is a fact about React or Vue and is left to the
overlays, which is also why only the directive name is stated and not its
value.

Every class the audit reports is zero after the rewrite.

## Still to decide

1. **The component this file is has no declaration.** `<Card />` resolves onto
   the `import Card from '../components/Card.astro'` in the same file, and that
   import is stated by the TypeScript Pack; but nothing declares `Card` inside
   `Card.astro`. The name is the file stem, and a Pack expression cannot read
   the file path -- `stem`, `module_stem` and `relative` all take a string
   argument, and `EvalContext` carries captures, fields, parents, ordered
   children and `source_root`, with no value holding the artifact's own path.
   A per-file declaration named from the path would need either a host-provided
   path value or an artifact-level rule, and neither is a language fact, so it
   is recorded as a coverage guard rather than invented here. It is not
   Astro-specific: every single-file component language (svelte, vue, astro)
   has the same hole.
2. **Props passed to a component** (`<Card title="Hello" size="lg">`) are not
   stated. They are the arguments of a call and there is a real question behind
   them, but stating each one is one emission per attribute of every component
   tag -- the volume the old Pack was mostly made of -- and the name stored
   would be the prop, not the component. Left out; revisit against the row
   count if the resolver gains a way to attach them to the component reference.
3. **`set:html`, `is:inline`, `is:global`, `define:vars`, `transition:name`**
   are stated as nothing. `transition:name` is the one with a name of its own,
   and it could pair a declaration with a reference across two pages; it is
   rare enough that it is not worth a pattern until a corpus says otherwise.
