# omega-svelte

Language `omega-svelte`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

22 templates over 22 query patterns, 29 distinct grammar node types touched.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 2 |
| `definitions` | yes | 5 |
| `references` | yes | 8 |
| `scopes` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.snippet_function` | Callable | 1 |
| `definition.config_element` | Config | 1 |
| `definition.const` | Value | 1 |

### Carriers

| kind | folded onto the declaration as | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `definition.type_parameter_shape_candidate` | `omega.pack.type_parameter_shape` | 1 |

Both are emitted with the `snippet_block` span, which is the span of
`definition.snippet_function`, so both fold onto it and the card reads
`row<T>(item: T)`.

### Regions

- `scope.snippet_body` (1)
- `scope.each_body` (1)
- `scope.await_body` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.snippet` | call | 1 |
| `call.svelte_attachment` | call | 1 |
| `relation.handles` | handles | 2 |
| `reference.svelte_component` | reference | 1 |
| `reference.svelte_action` | reference | 1 |
| `reference.svelte_transition` | reference | 1 |
| `reference.svelte_value` | reference | 3 |
| `binding.each_item` | reference | 1 |
| `binding.each_index` | reference | 1 |
| `binding.await_value` | reference | 1 |
| `binding.await_branch_value` | reference | 1 |

### Injections

Four patterns, unchanged: `<script>` and `<style>` bodies go to the JavaScript,
TypeScript or CSS Pack, with `lang=` read from the attribute when present.
These are the reason a `.svelte` file has any imports, props or selectors in
the index at all.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 68 node types. The Pack looks at 29 of them.

Untouched:

- `attribute_expected_equals_tail`
- `attribute_modifier`
- `attribute_modifiers`
- `attribute_sequence_recovery_tail`
- `await_branch_children`
- `await_pending`
- `block_close`
- `block_comment`
- `block_end`
- `block_keyword`
- `block_open`
- `block_sigil`
- `branch_kind`
- `comment`
- `debug_tag`
- `declaration_kind`
- `declaration_tag`
- `doctype`
- `document`
- `else_clause`
- `else_if_clause`
- `end_tag`
- `entity`
- `erroneous_end_tag`
- `erroneous_end_tag_name`
- `if_block`
- `incomplete_attribute_expression`
- `key_block`
- `line_comment`
- `malformed_block`
- `orphan_branch`
- `shorthand_kind`
- `snippet_header_trailing`
- `tag_comment`
- `tag_local_name`
- `tag_member`
- `tag_missing_whitespace_trailing`
- `text`
- `unquoted_attribute_value`

Of these, four groups are deliberate silences rather than gaps, and the rest
are punctuation, recovery and error nodes that carry no name:

- **block punctuation** (`block_open`, `block_close`, `block_end`,
  `block_keyword`, `block_sigil`, `branch_kind`, `declaration_kind`,
  `shorthand_kind`, `*_trailing`) — the sigils of `{#…}{:…}{/…}`. Nothing to name.
- **error recovery** (`malformed_block`, `orphan_branch`, `erroneous_end_tag*`,
  `incomplete_attribute_expression`, `attribute_expected_equals_tail`,
  `attribute_sequence_recovery_tail`) — a half-typed file, not a construct.
- **control flow without a binding** (`if_block`, `key_block`, `else_clause`,
  `else_if_clause`, `debug_tag`, `await_pending`, `await_branch_children`) —
  these bracket markup but bind no name, so a region over them would answer
  nothing that the containing snippet, each or component does not already
  answer. `{#if}` and `{#key}` expressions are reached through the generic
  identifier-expression pattern like any other `{...}`.
- **text and markup** (`document`, `text`, `entity`, `end_tag`, `comment`,
  `line_comment`, `block_comment`, `tag_comment`, `doctype`,
  `unquoted_attribute_value`) — naming a document or a run of text is Defect D
  and is what made the old Pack expensive.

`attribute_modifiers`/`attribute_modifier` (`on:click|preventDefault`) and
`tag_member` are reached through their parents (`attribute_name`, `tag_name`)
but not captured separately; a modifier changes how an event is delivered, not
what is handled, and a dotted component is reduced to its first segment.

## What is wrong with it

This section describes the Pack as it was found, at version 1.0.0: 23 templates
over 28 patterns, 5 coverage guards, 24 node types touched.

**Two declarations in the whole Pack, both of the same construct.** The only
`definitions` templates were `definition.snippet` and `definition.svelte_snippet`
— Defect K's second spelling, the same `snippet_block` declared twice under two
kinds, one per generator pass. Both landed in **Value**: `snippet` is not a word
in the host's Callable row, so a Svelte snippet — a parameterised, invocable
block, the closest thing the markup language has to a function — was filed
beside string constants. Everything else in a `.svelte` file was a mention, and
mentions resolve against declarations, of which this Pack offered one name.

**Fifteen of 23 templates were `data.*` mentions that resolve against nothing.**
`data.svelte_element`, `data.svelte_attribute`, `data.svelte_attribute_value`,
`data.svelte_if_block`, `data.svelte_each_block`, `data.svelte_await_block`,
`data.svelte_render_tag`, `data.svelte_declaration_tag`, `data.svelte_directive`,
`data.svelte_directive_context`, `data.svelte_event_attribute_context`,
`data.svelte_event_directive_binding_context`, `data.svelte_key`,
`data.svelte_key_block`, `data.svelte_shorthand_attribute`. Fifteen kinds, one
occurrence: **reference**. `(attribute name: (attribute_name) @n) @a` fired on
every attribute of every element in every file — `class`, `id`, `href`, `alt` —
storing each under its own attribute name as a reference to a declaration that
does not exist. On markup, which is most of a `.svelte` file, that is the
largest emission class in the Pack and none of it is an answer.

**Four patterns asked for the same node separately.** `(each_block)` was matched
three times (`data_each_block`, `each_bindings`, the closure pass's
`(each_block binding: … expression: …)`), `(key_block)` three times, `(attribute
name: (attribute_name) …)` four times across the terminal, event, modern-event
and directive-context passes. One node, one pattern, several templates is the
contract; this was the opposite.

**Defect D2, one template.** `(expression) @svelte.expression` with
`reference.svelte_expression` naming itself. Every `{...}` in the file — and
`expression` is the node for every mustache, every attribute value, every `{#if}`
condition — was stored under its own full source text. `{items.filter((x) => x.ok
&& x.n > 3)}` became a reference by that name. One match per mustache per file,
for a name nothing can be asked of.

**Defect J, two templates.** `data.svelte_key_block` was named with the literal
`"key"` and `data.svelte_key` with the literal `"svelte_key"`, so every `{#key}`
in a repository collapsed onto one of two strings, while the expression that
identifies the key sat in a field.

**Defect G, four of five guards.** Four read `bounded_structural_semantics_only`.
That is the generator's confidence tier, not a limitation of Svelte, and a query
reading it learns nothing about what the answer is missing.

**Defect L's tell, twice.** Two header comments asserted "Framework-neutral
Svelte attribute directive…" and the pass names carried
`semantic_closure_v3_146_batch2`. The patterns under them were not framework
overlays — they were the duplicate attribute patterns above — but the header is
the generator's, and the `nvim_pinned_locals` block (an nvim-treesitter
provenance header with two resolved-source hashes and no pattern under it) is the
same inheritance found in twelve other Packs.

**The three things a Svelte file is for were not stated at all.** No component
usage: `<Card title="x"/>` produced only `data.svelte_element` named `Card`, a
reference under the `data` capability, tied to nothing, and lowercase `<div>`
produced the identical shape so the two could not be told apart. No
`{@render}`→`{#snippet}` link: `reference.svelte_render_expression` stored
`row(item)` verbatim, which cannot match the `snippet` declared as `row`. No
`use:`/`transition:` function references, although those name a function the
script imports and are the Pack's most resolvable link after the component tag.

**One capability was misapplied throughout.** `data` carried fifteen mention
kinds; `bindings` carried `binding.svelte_each`, which duplicated
`binding.loop` over the same `each_block` under a second name (Defect K again).

## What it should extract

A `.svelte` file is a component. Its script and style belong to other languages
and are injected; what is left is the markup, and the questions asked of the
markup are: *which components does this one use*, *what snippets does it declare
and where are they rendered*, *which action, transition or attachment does it
apply*, *which events does it handle*, and *what name does a block bind*.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| `{#snippet row(item)}` | `snippet_block` via `snippet_name` | `definition.snippet_function` | Callable |
| its parameter list | `snippet_parameters` | `definition.parameter_shape_candidate` on the snippet span | `omega.pack.parameter_shape` |
| its type parameters | `snippet_type_parameters` | `definition.type_parameter_shape_candidate` on the snippet span | `omega.pack.type_parameter_shape` |
| the snippet's body | `snippet_block` | `scope.snippet_body` | region |
| `{@render row(x)}` | `render_tag` via `expression_value` | `call.snippet`, named by the text before `(` | call |
| `{@attach tooltip(t)}` | `attach_tag` via `expression_value` | `call.svelte_attachment`, same reduction | call |
| `{@const total = …}` | `const_tag` via `expression_value` | `definition.const`, named by the text before `=` | Value |
| `{@html body}` | `html_tag` | `reference.svelte_value` | reference |
| `<Card/>`, `<Foo.Bar/>` | `start_tag`, `self_closing_tag` via `tag_name` | `reference.svelte_component`, first dotted segment | reference |
| `<svelte:options>`, `<svelte:window>` | the same, `tag_namespace` = `svelte` | `definition.config_element` | Config |
| `use:clickOutside` | `attribute_name` via `attribute_identifier` | `reference.svelte_action` | reference |
| `transition:fade`, `in:`, `out:`, `animate:` | the same | `reference.svelte_transition` | reference |
| `on:click={h}` | the same | `relation.handles`, named `click` | handles |
| `onclick={h}` | `attribute_identifier`, first child | `relation.handles`, `on` stripped | handles |
| `{#each list as item, i}` | `each_block` via `pattern` | `binding.each_item`, `binding.each_index` | reference |
| the loop body | `each_block` | `scope.each_body` | region |
| `{#await p then v}` | `await_block` via `pattern` | `binding.await_value` | reference |
| `{:then v}`, `{:catch e}` | `await_branch` via `pattern` | `binding.await_branch_value` | reference |
| the await body | `await_block` | `scope.await_body` | region |
| `{count}`, `attr={caption}`, `bind:value={name}` | `expression` via `js`/`ts` | `reference.svelte_value`, only when it is one identifier | reference |
| `<Foo {value}/>` | `shorthand_attribute` | `reference.svelte_value` | reference |
| `<script>`, `<style>` | `element` via `raw_text` | injection to javascript / typescript / css | — |
| plain attributes, lowercase tags, text, entities, comments, `{#if}`, `{#key}` | | nothing | — |

Three decisions carry the design.

**An expression is stated only when it is one identifier.** This grammar does
not parse the inside of `{...}`; it hands back one `js` or `ts` token. The old
Pack stored that token as a name, which is Defect D2 on the most common node in
the file. A `#match?` on `^[A-Za-z_$][A-Za-z0-9_$]*$` keeps exactly the case that
resolves — `{count}`, `label={caption}`, `bind:value={name}`, `{#if ready}` — and
drops the rest to the script, where omega-javascript and omega-typescript state
it properly from the real `<script>` body. The same filter is applied to the
names an `{#each}` or `{#await}` binds, so a destructured binding is not declared
under the text of its pattern.

**The capital letter is the whole component/element distinction**, exactly as in
JSX, and omega-tsx settled this in wave 5. `<Card/>` resolves onto the `Card`
that `<script>` imported; `<div/>` is stated nowhere. `<Foo.Bar/>` is reduced to
`Foo`, its **first** segment rather than its last, because in Svelte `Foo` is the
imported value and `Bar` is a property of it — the opposite reduction from the
one omega-tsx chose for JSX member expressions, and the one that resolves here.

**Containment is a region only where a name is bound.** `snippet_block`,
`each_block` and `await_block` bind names over their bodies, and those three get
one `scope.*` each. `if_block`, `key_block` and `else_clause` bind nothing, so
they get none: a pattern for them would restate what the tree holds. No pattern
in the file is nested more than the one edge it needs to reach a name.

## Still to decide

1. **Whether `{expression}` should be a JavaScript injection instead of a
   filtered reference.** Injecting `(expression (js))` into omega-javascript
   would state every identifier in every mustache correctly, and it is not a
   framework fact — it is what Svelte means. It is left out because the cost is
   one extra parse per mustache and could not be measured here; the identifier
   filter is the cheap 80% of it. If mustache references turn out to matter,
   this is the change to make, and the injection layer already carries the
   language aliases for it.
2. **`declaration_tag`.** The grammar has `declaration_tag` with fields
   `kind: declaration_kind` and `declaration: expression_value`, distinct from
   `const_tag`, `html_tag`, `debug_tag`, `render_tag` and `attach_tag`, and no
   corpus in this repository exercises it. The old Pack emitted it as an unnamed
   `data.*` mention, which told nobody what it was. It is left untouched until
   someone can say which `{@…}` form it parses.
3. **`<svelte:*>` as a declaration.** `definition.config_element` names
   `svelte:head` once per use, so every `<svelte:head>` in a repository is a
   declaration under one name — the same trade omega-xml made for elements and
   recorded as provisional. It answers *which components set `svelte:options`*
   and *which listen on `svelte:window`*, which is a real question; revisit
   against the row count if `<svelte:head>` turns out to be on every page.
