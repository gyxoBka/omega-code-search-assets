# omega-framework-svelte

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 4 detection rules. **11 can match, 0 cannot.**

Selector: `framework:svelte`. Maturity: `semantic-overlay-full`.
`detection_rules` is unchanged: its four rows say Svelte is present when a
binding specifier, a reference name or a contract identity names `svelte`, and
all four are still true.

### Entities it declares

| entity_kind | rules |
|---|---|
| `SvelteComponent` (the file hub) | 10 |
| `SvelteComponentName` | 2 |
| `SvelteSnippet` | 2 |
| `SvelteBehavior` | 3 |
| `SvelteEventHandler` | 1 |
| `SvelteHandlerFunction` | 1 |
| `SvelteStoreSubscription` | 1 |
| `SvelteRuneUse` | 1 |

### Relations it declares

`declares` (2), `renders` (2), `handles`, `event_calls`, `uses_action`,
`uses_transition`, `uses_attachment`, `subscribes`, `uses_rune`.

### Fact kinds it matches

| kind | Pack | rules |
|---|---|---|
| `reference.svelte_value` | omega-svelte | 4 |
| `reference.svelte_component` | omega-svelte | 1 |
| `definition.snippet_function` | omega-svelte | 1 |
| `call.snippet` | omega-svelte | 1 |
| `relation.handles` (joined) | omega-svelte | 2 |
| `reference.svelte_action` | omega-svelte | 1 |
| `reference.svelte_transition` | omega-svelte | 1 |
| `call.svelte_attachment` | omega-svelte | 1 |
| `call.function` | omega-javascript, omega-typescript | 1 |
| `definition.function` (joined) | omega-javascript, omega-typescript | 1 |

Path globs: `**/*.svelte` only. No brace glob, no `external_path_matches`.

## What was wrong with it

All 11 rules were dead, and every one of them for the same reason: the file was
keyed to the generator's pre-rewrite vocabulary.

- **9 of 11 rules named a fact kind no Pack emits.** `data.svelte_element` (2
  rules), `data.svelte_event_directive_binding_context` (2),
  `data.svelte_event_attribute_context` (2), `data.svelte_directive_context`,
  `definition.svelte_snippet`, `reference.svelte_render_expression`,
  `reference.svelte_expression`, plus two JS spellings —
  `call.ecmascript_direct_context` and
  `import.ecmascript_named_binding_context`. The rewritten omega-svelte Pack
  emits `reference.svelte_component`, `definition.snippet_function`,
  `call.snippet`, `reference.svelte_value`, `reference.svelte_action`,
  `reference.svelte_transition`, `call.svelte_attachment` and
  `relation.handles`; none of the old names survived.
- **Every rule also read a Pack field, and omega-svelte publishes none.** All 22
  of its templates carry `"fields": {}` and `"attributes": {}`, as do the fields maps of all 45
  omega-javascript and 58 omega-typescript templates. The 8 field names the old
  file read — `handler_expression`, `directive`, `event_name`,
  `attribute_name`, `module_source`, `call_name`, `expression`, `name` — are
  published by nobody. The whole overlay now runs on built-ins: `definition.name`,
  `path`, `path.stem`, `source.start`.
- **Four rules were two constructs, each spelled twice.**
  `svelte.event.resolved-handler.svelte_event_directive_binding_context` and
  `...svelte_event_attribute_context` differed only in matching `on:click=`
  versus `onclick=`. omega-svelte emits `relation.handles` for **both**
  spellings, so they are one rule now.
  `svelte.authored-event-binding` and `svelte.authored-modern-event-attribute`
  were the same pair again, minting an `EventBinding` with
  `handler_resolved: false` — an entity named after its own input with no
  relation at all. Four rules became two, and the two that survive carry edges.
- **Three rules only restated their input.** `svelte.render.expression` minted
  a `RenderReference` holding the expression text it had just read;
  `svelte.template.directive-use` minted a `DirectiveUse` holding the directive
  name; `svelte.component_view` minted a `View` per element and pointed both a
  `contains` **and** a `renders` edge at the same key, which is the same
  statement twice. All three are gone.
- **One rule could not have worked even with the kinds restored.**
  `svelte.template.imported-component-render` joined `import.*` by
  `local_name`/`module_source`; omega-javascript spans `import.module` on the
  specifier string and the local binding on a sibling node, so the two cannot
  be joined by span, and neither publishes a field to join by. Its answer is
  reached a different way now (see *Still to decide*).
- **Every relation in the old file dangled.** Nine of the ten relations were
  sourced at `svelte:component:{path}`, and the only rule that minted that key
  was `svelte.component_view` — which was dead, and in any case matched
  `data.svelte_element`, a kind that would not have fired in the same places.
  In the rewrite the hub is minted by the same rule that addresses it, in all
  ten rules that use it, with one kind (`SvelteComponent`) and one attribute
  set. `python pack-design/key_collisions.py svelte` reports nothing.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which file is this component? | any `reference.svelte_value` in `**/*.svelte` | `SvelteComponent` `svelte:component:{path}` — the hub every other rule hangs off |
| Which file declares the component named `Button`? | same fact, read as `path.stem` | `SvelteComponentName` `svelte:component-name:{path.stem}` `--declares->` the hub |
| Which components does this file render, and who renders `Button`? | `reference.svelte_component` (capitalised tag, first dotted segment) | hub `--renders->` `SvelteComponentName` `svelte:component-name:{definition.name}` — the cross-file edge, closed by the row above |
| Which snippets does this component declare? | `definition.snippet_function` | hub `--declares->` `SvelteSnippet` `svelte:snippet:{path}:{name}` |
| Where is snippet `row` rendered? | `call.snippet` (`{@render row(x)}`) | hub `--renders->` the same `SvelteSnippet` key |
| Which DOM events does this component handle, and with what? | `reference.svelte_value` joined `within` `relation.handles` | hub `--handles->` `SvelteEventHandler` `svelte:event-handler:{path}:{source.start}`, carrying `event` from the joined fact and `handler` from its own name |
| Which function in this file answers that event? | the same, plus `definition.function` joined by `definition.name`, `same_path` | `SvelteEventHandler` `--event_calls->` `SvelteHandlerFunction` |
| Which actions does this component apply? | `reference.svelte_action` (`use:enhance`) | hub `--uses_action->` `SvelteBehavior` `svelte:action:{path}:{name}` |
| Which transitions or animations? | `reference.svelte_transition` (`transition:`, `in:`, `out:`, `animate:`) | hub `--uses_transition->` `SvelteBehavior` `svelte:transition:{path}:{name}` |
| Which attachments (Svelte 5)? | `call.svelte_attachment` (`{@attach tooltip(x)}`) | hub `--uses_attachment->` `SvelteBehavior` `svelte:attachment:{path}:{name}` |
| Which stores does this component auto-subscribe to? | `reference.svelte_value` with `definition.name` prefixed `$` | hub `--subscribes->` `SvelteStoreSubscription` `svelte:store:{path}:{name}` |
| Is this component on runes, and which ones? | `call.function` named `$state`, `$derived`, `$props`, `$effect`, `$bindable`, `$inspect`, `$host` in a `.svelte` file | hub `--uses_rune->` `SvelteRuneUse` `svelte:rune:{path}:{source.start}` |

The two framework facts a language Pack cannot state are the last column's
point: **`$name` in markup is a store subscription, not a variable**, and **a
capitalised tag is a component whose file is named after it**. Everything else
in the table is Svelte's own vocabulary — snippet, rune, action, transition,
attachment — carried onto a graph the Packs only spell out syntactically.

### Keys minted vs. keys addressed

Minted: `svelte:component:{path}`, `svelte:component-name:{path.stem}`,
`svelte:component-name:{definition.name}`,
`svelte:snippet:{path}:{definition.name}`,
`svelte:event-handler:{path}:{source.start}`,
`svelte:handler-function:{path}:{definition.name}`,
`svelte:action|transition|attachment:{path}:{definition.name}`,
`svelte:store:{path}:{definition.name}`,
`svelte:rune:{path}:{source.start}`.

Addressed: the same set. The only key a rule addresses without minting in that
same rule is `svelte:event-handler:{path}:{source.start}`, addressed by
`svelte.event.handler.function` and minted by `svelte.event.handler` — whose
match is a strict subset of it (the same fact kind, the same glob, the same
span join, minus the `definition.function` join), so the key always exists.
Both `svelte:component-name:` templates carry the one kind
`SvelteComponentName`, and the hub carries `SvelteComponent` in all ten rules
that mint it.

## Still to decide

1. **The hub is anchored on `reference.svelte_value`.** omega-svelte emits no
   per-file fact, so a component's own identity has to be minted off something
   its markup contains. `reference.svelte_value` — every single-identifier
   `{expr}`, `{@html x}` and `<Foo {value}/>` shorthand — is the most common
   such fact, but a purely presentational component with no expression at all
   in its markup is never registered under its name. Adding the same three
   outputs to the other nine rules would close most of the remainder at the
   cost of nine repetitions; a one-line "this artifact is a Svelte component"
   emission from the Pack would close all of it. Left as it is for now, and
   recorded in `coverage.gaps`.
2. **`<Foo/>` is resolved by filename, not by import.** Svelte's convention is
   that `Button.svelte` declares `Button`, and that is what the two
   `svelte:component-name:` templates encode. Two `Button.svelte` files in
   different directories therefore both `declares` the same name, and the
   consumer sees two candidate files. Resolving it properly needs the module
   specifier of the import that bound `Foo` (see below).
3. **Actions, transitions and attachments are not resolved to their function.**
   The same `fact_join_by_field` on `definition.name` that
   `svelte.event.handler.function` uses would resolve a locally declared
   `use:` action, but most are imported, so the join would drop more than it
   resolved. Three more rules for a partial answer did not look worth it.

## A field only the Pack can supply

None is required for the rules above; all 11 run on built-ins. One is required
for item 2, and it is the same `qualifier` row already recorded as `OWED.md`
item 1 / 7a rather than a new ask:

- **omega-javascript / omega-typescript**, kinds `import.default`,
  `import.symbol`, `binding.import_alias` — a field naming the **module
  specifier** of the import statement the binding came from.
  `import.module` states the specifier but spans only the quoted string, and
  the local binding spans a sibling identifier inside the same
  `import_statement`; neither contains the other, so `fact_join_by_span` with
  `within` cannot relate them, and there is no `definition.*` ancestor for
  `definition.container` to pick up. `binding.import_alias` publishes `target`
  as an **attribute**, which is write-only (brief §3a), and it names the
  imported symbol rather than the module in any case. With that field,
  `<Foo/>` would resolve to `./lib/Button.svelte` instead of to every file
  whose stem is `Button`. This is not Svelte's problem alone — every
  JavaScript framework overlay that wants to follow an import needs it.
