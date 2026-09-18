# omega-vue

Language `omega-vue`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

Rewritten 2026-09-18. 14 templates over 17 query patterns (13 of them emitting,
4 injections), 18 of the grammar's 26 named node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 2 |
| `definitions` | yes | 3 |
| `references` | yes | 6 |
| `scopes` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.slot` | Value | 1 |
| `definition.template_ref` | Value | 1 |
| `definition.template_binding` | Value | 1 |

### Regions

- `scope.template_block` (1)
- `scope.script_block` (1)
- `scope.style_block` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.vue_element` | reference | 1 |
| `data.vue_directive_value` | reference | 1 |
| `reference.event` | reference | 1 |
| `reference.prop` | reference | 1 |
| `reference.slot` | reference | 1 |
| `reference.template_expression` | reference | 2 |
| `reference.vue_interpolation` | reference | 1 |

Every mention is a plain reference. No `relation.*` kind is emitted: a Vue
template sits inside a file that declares nothing, so a relation would have no
source entity, and the one role that reads as a Vue template wiring —
`relation.handles` — takes only a Contract target (`surface.rs`), which a Vue
event name never is. A plain reference resolves by name against whatever the
injected script declares, which is what the questions here actually need.

`data.vue_element` and `data.vue_directive_value` keep the kind strings and
field shapes the shipped `frameworks/omega-framework-vue` overlay reads; see
*Where the names come from* below.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 26 node types. The Pack looks at 18 of them.

Untouched, and why each is right to leave alone:

- `element` — the tree already holds containment; the tag is reached through
  `start_tag`/`self_closing_tag`, which is where the name is.
- `end_tag` — a second copy of a name the start tag already gave.
- `erroneous_end_tag`, `erroneous_end_tag_name` — a parse error, not a fact.
- `text` — literal markup text, which names nothing and resolves to nothing.
- `comment` — prose.
- `directive_modifiers`, `directive_modifier` — `.prevent`, `.trim`, `.enter`
  are runtime behaviour on a binding, not a name anything resolves to, and a
  pattern over them matches once per modifier, multiplying every other template
  on the same directive. Deliberately dropped; the old Pack emitted two.

## What is wrong with it

Measured on the Pack as found: **16 templates over 21 patterns, one coverage
guard, capabilities `data` and `references`.**

**It declared nothing at all.** Not one of the 16 templates was a
`definition.*`. A `.vue` file is full of names another file resolves against —
`<slot name="header">` that a parent fills, `ref="input"` that the script reads
back, the alias `v-for="item in items"` puts into template scope — and all
three were absent. Every emission the Pack made was a mention, so the Pack
referenced without ever declaring, and nothing in a Vue project could resolve
to anything a Vue file said.

**Five templates stored a whole span as a name, including the entire file.**
`data.vue_component`, `data.vue_script_section`, `data.vue_style_section`,
`data.vue_template_section` and `data.vue_interpolation` carried **no `name`
expression**, and with no name the host takes the span capture's own text. Their
spans are `(component)`, `(script_element)`, `(style_element)`,
`(template_element)` and `(interpolation)` — so every `.vue` file in a corpus
was stored once under the text of its whole `<script>` block, once under its
whole `<style>` block, once under its whole `<template>`, and once, as
`data.vue_component`, under **the entire file**. Four copies of the file per
file. This is Defect D in its worst form and neither `audit.py`'s D nor its D2
sees it, because both require a `capture_ref` name to look at (see *For
00-INDEX.md* below).

**Seven templates named a binding after the keyword that introduced it.**
`data.vue_directive`, `data.vue_directive_value`, `data.vue_directive_argument`,
`data.vue_directive_modifier` and `data.vue_directive_dynamic_argument` all took
their `name` from the `directive_name` capture, so every binding in a repository
was stored under one of about fifteen strings — `:`, `@`, `#`, `v-if`, `v-for`,
`v-model`. `structured.entry` and `structured.vue_attribute_value` did the same
with `attribute_name`, so every attribute in every template collapsed onto
`class`, `id`, `style`. This is Defect J by a different route: the name is a
capture, so the audit does not flag it, but the effect is the same collapse onto
a fixed vocabulary. Meanwhile the thing a question is actually about — the
expression `submit`, the prop `title`, the event `click` — sat one capture away
and was stored only in a field or not at all.

**Three facts were stated twice, by two generator passes.** The query file's
own section headers say so: the block marked `semantic_closure_v3_146_batch2`
re-captures nodes the earlier sections already had. `data.vue_directive_argument`
/ `reference.vue_directive_argument`, `data.vue_directive_dynamic_argument` /
`reference.vue_dynamic_argument`, and `data.vue_interpolation` /
`reference.vue_interpolation` are three pairs — six templates over six patterns
— each pair stating the same fact about the same node under two kinds and two
capabilities.

**Nothing was filtered.** `data.vue_element` fired on every `<div>`, `<span>`
and `<li>` in every template, and `structured.entry` on every static attribute.
On a real Vue application those two templates are the dominant row producers,
and not one of those names can resolve to anything: `div` is not declared
anywhere and never will be. The two spellings Vue itself resolves —
PascalCase and kebab-case — were not distinguished from the HTML ones.

**The one coverage guard described a pattern that no longer exists.** Its
reason begins "Universal named-node capture provides syntax-aware indexing
only", which is the `(_) @structural.node` pattern removed in the Defect I
sweep; the query file still carries its orphaned header comment
(`--- structural-fallback ---`) claiming to match "every named syntax node".
The rest of the reason — "Language-specific definitions/references/types/calls
are intentionally outside this Pack static source contract" — describes the
generator's scope, not anything about Vue, and it is an admission that the Pack
declared nothing rather than a limitation a reader could act on.

**The document's own tables were wrong.** They claimed 18 templates, 23
patterns, a `scopes` capability and a `scope.vue_element` region. The shipped
Pack had 16 templates, 21 patterns and no scope at all.

## What it should extract

A `.vue` file is one single-file component: a `<template>` of markup, a
`<script>` block of JavaScript or TypeScript, and a `<style>` block. The
questions asked of it are *which components does this one render*, *which slots
does it offer and which does it fill*, *which props and events are wired here*,
and *which symbols of the script does the template reach for*. Everything the
script itself declares belongs to the JavaScript or TypeScript Pack and arrives
through the injections.

| what | node | emitted as | family |
|---|---|---|---|
| a component this template renders | `start_tag`/`self_closing_tag` via `tag_name`, PascalCase or kebab only | `data.vue_element` | reference |
| a slot this component offers | `<slot name="x">` via `attribute_value` | `definition.slot` | Value |
| a template ref | `ref="x"` via `attribute_value` | `definition.template_ref` | Value |
| the alias `v-for` binds | `directive_attribute`, plain `a in b` form | `definition.template_binding` | Value |
| what `v-for` iterates | same node, tail of the expression | `reference.template_expression` | reference |
| the event a listener handles | `directive_argument` under `v-on`/`@` | `reference.event` | reference |
| the prop a binding sets | `directive_argument` under `v-bind`/`:` | `reference.prop` | reference |
| the slot a template fills | `directive_argument` under `v-slot`/`#` | `reference.slot` | reference |
| what a directive is bound to | `attribute_value` of any `directive_attribute` | `data.vue_directive_value` + fields `directive`, `value` | reference |
| a computed argument | `directive_dynamic_argument_value` | `reference.template_expression` | reference |
| what an interpolation renders | `raw_text` of `interpolation` | `reference.vue_interpolation` | reference |
| the three blocks of the file | `template_element`, `script_element`, `style_element` under `component` | `scope.template_block`, `scope.script_block`, `scope.style_block` | region |
| the script and the style themselves | `raw_text` | injection into javascript/typescript/css | — |
| an HTML tag, a static attribute, a modifier, text, a comment | `element`, `attribute`, `directive_modifier`, `text`, `comment` | nothing | — |

### Where the names come from

Every reference is named by the **head of its identifier path**, taken with
`first(split(trim(...), "."))`: `{{ user.name }}` is a mention of `user`,
`:key="item.id"` a mention of `item`, `v-for="item in items"` a declaration of
`item` and a mention of `items`. That head is what the injected script declares
— `const items = ref([])`, or the `item` the `v-for` above it bound — so the
mention has something to resolve to. Storing the whole expression would resolve
to nothing, which is what the old Pack did.

A component usage is named by its tag, which is the spelling Vue itself
resolves: against an `import MyButton from './MyButton.vue'` in the same file's
script, or against the file `MyButton.vue`. The Pack cannot do either join —
see the guards — but the overlay does both.

### Where the family lands, and why Value is right

The three declarations are Value, and that is deliberate. A slot, a template ref
and a `v-for` alias are none of them a type, a callable, a namespace or a
configuration key; they are names bound in a template. There is no word in the
host's Type or Callable vocabulary that would be honest here, and reaching for
one to move the family would be the mistake Defect A describes in reverse.

### Keeping faith with the overlay

`frameworks/omega-framework-vue` is the concrete reader of this Pack's output,
and it names three kinds directly:

- `data.vue_element` with the field `name` — joined against a `.vue` file stem
  (`vue.template.exact-file-component-render`) and against an ECMAScript import
  binding in the same file (`vue.template.imported-component-render`) to emit a
  `renders` relation;
- `data.vue_directive_value` with the fields `directive` and `value`
  (`vue.template.directive-binding` → `TemplateBinding`, `uses_binding`);
- `reference.vue_interpolation` with the field `name`
  (`vue.template.interpolation-expression` → `TemplateExpression`).

Nothing validates that coupling — `validate_external_assets` never compares an
overlay's `fact_kind` against any Pack — so renaming those three would have
broken four overlay rules silently, which is §10's "the host discards this kind,
so stop emitting it" trap wearing a different hat. They are kept, spelling and
field shape intact. The **content** is improved under them: `data.vue_element`
is now filtered to the tags that can join at all, and `data.vue_directive_value`
is named by the head of its expression instead of by `:`.

## A defect in the host

**A Pack cannot see the path of the file it is reading.** `expr.rs` ships
`stem`, `module_stem`, `path_parent`, `relative`, `extension`, `path_prefix`,
`path_suffix` and `normalize_separators` — eight operations that exist only to
take a path apart — but `runtime.rs:1310` builds the evaluation context with
`EvalContext::default()`, so `source_root` is `None` and no capture, field or
parent binding ever carries the artifact's path. There is no expression a Pack
can write that reaches it.

For Vue this is the difference between declaring the component and not. A
single-file component is named by its file name and by nothing inside the file:
`Button.vue` *is* the declaration of `Button`, and `<Button/>` in a sibling is
the reference to it. The Pack states the reference and cannot state the
declaration, so the resolution is finished outside the Pack, by an overlay rule
that joins the tag name to a `.vue` stem. Every other language with the same
convention — a Java public class, a Rust module file, a Go package directory —
pays the same price.

This is not language-specific and the fix is not a language branch: bind the
artifact path into `EvalContext` beside `source_root`, so that the path
operations already in the expression vocabulary have an input. `runtime.rs` and
`expr.rs` are both frozen (§15), so it is reported here rather than changed.

## For 00-INDEX.md

Reported rather than acted on, because neither is this Pack's alone:

1. **A template with no `name` expression is Defect D and is not measured.**
   The host falls back to the span capture's own text, so a nameless template
   over a container node stores that whole subtree exactly as a `capture_ref`
   name would. `audit.py` checks D and D2 only when `name` is a `capture_ref`,
   so a nameless one is invisible to both. Five of this Pack's 16 templates were
   this, one of them storing whole `.vue` files. Measured across all Packs after
   this rewrite: **3 remain, all in omega-svelte**, on spans whose node type the
   grammar says has named children. The check is three lines next to D2.
2. **The framework overlays read Pack kinds and fields, and nothing checks
   it.** `frameworks/*/semantic-v2.json` pins `fact_kind` strings and field
   names that Packs emit; `validate_external_assets` validates each side
   separately and never compares them. Any Pack rewrite that renames a kind
   silently disables the overlay rules that read it. A cross-check is cheap:
   collect every `fact_kind` and `field_ref` in the overlays, collect every
   `output_kind` and `fields` key in the Packs the overlay names in
   `host.required_packs`, and report the ones with no producer. While looking,
   `vue.template.directive-binding` filters `directive` to
   `["v-bind","bind","v-model","model","v-on","on","v-if","if","v-for","for","v-show","show"]`
   and so drops every shorthand — `:`, `@`, `#` — which is the majority of real
   Vue template code. That is the overlay's bug to fix, not this Pack's.

## Still to decide

1. Whether `reference.prop` should be emitted for every `v-bind` argument. It
   makes `:class` and `:style` into mentions of `class` and `style`, which
   resolve to nothing, in exchange for making `:variant` a mention of `variant`,
   which answers "who passes this prop". Kept, because the Pack cannot tell a
   component's prop from an HTML attribute without knowing the tag is a
   component — and the tag is one capture away, in the same pattern, if this
   turns out to cost more than it answers.
2. Whether the `v-for` alias list `(item, index) in items` should be taken
   apart. It needs either two patterns differing only by predicate or a `split`
   chain over punctuation; the plain form covers the large majority and the
   guard states the gap.
3. `<script setup>` and `<style scoped>` are facts about the file that this
   Pack does not state, because the only name available for them is the flag
   itself, which would collapse every component onto the name `setup`. If the
   host ever carries a boolean attribute that is not also a name, they belong
   on the block's region.
