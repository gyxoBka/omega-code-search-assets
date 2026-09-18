# omega-framework-vue

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**16 overlay rules, 4 detection rules. All 16 match.** (Was 17 rules, 1 live.)

Selector: `framework:vue`. Maturity: `semantic-overlay-full`.

Vue is the one framework in the set whose Pack is a *host* language: an SFC is
parsed by omega-vue, and its `<script>` block is an injection region that
`run_language_packs_bounded` re-analyses with omega-javascript or
omega-typescript, mapping the child spans back into the `.vue` file's byte
coordinates. So a `call.function defineProps` fact carries the `.vue` path, and
`**/*.vue` is a real gate on the script side as well as the template side. Every
claim below was measured with

    target/release/examples/dump_call_emissions.exe <pack-dir> <grammar-dir> <file>

against hand-written SFC and `.ts` fixtures.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Component` | 2 |
| `ComponentName` | 3 |
| `Composable` | 4 |
| `Dependency` | 4 |
| `ApiUse`, `App`, `ComponentApi`, `Event`, `LifecycleHook`, `Router`, `Slot`, `Store`, `TemplateBinding` | 1 each |

### Relations it declares

`declares`, `declares_component`, `declares_slot`, `depends_on`, `listens_to`,
`provides_store`, `renders`, `uses_api`, `uses_binding`, `uses_composable`,
`uses_lifecycle`.

### Fact kinds it matches

| kind | rules | Pack |
|---|---|---|
| `call.function` | 6 | omega-javascript, omega-typescript |
| `data.vue_element` | 1 | omega-vue |
| `data.vue_directive_value` | 1 | omega-vue |
| `definition.slot` | 1 | omega-vue |
| `reference.event` | 1 | omega-vue |
| `scope.template_block`, `scope.script_block` | 1 each | omega-vue |
| `definition.function`, `definition.variable` | 1 each | omega-javascript, omega-typescript |
| `import.module` | 1 | omega-javascript, omega-typescript |
| `import.symbol` (join) | 1 | omega-javascript, omega-typescript |

Fields read: `directive`, `value` (both published by omega-vue on
`data.vue_directive_value`). Everything else is a built-in: `definition.name`,
`path`, `path.stem`, `source.start`.

Path globs: `**/*.vue`, `**/composables/**`. No braces, so none of them is the
literal-byte glob of brief §3c.

## What was wrong with it

The file shipped 17 rules. **16 of them could not match any emission**, and the
one that could (`vue.template.directive-binding`) matched on a directive list
that named no spelling the Pack publishes — so in practice **0 of 17 rules
produced anything.**

Concretely:

1. **Eleven rules were keyed to the generator's old private JS vocabulary.**
   `call.ecmascript_direct_context` (4 rules: the four `define*` macros),
   `call.ecmascript_direct_string_argument_context` (2: `provide`/`inject`),
   `data.ecmascript_direct_array_string_item_context` (1),
   `data.ecmascript_call_object_array_object_string_identifier_context` (1),
   `import.ecmascript_named_binding_context` (1), `call.target_candidate` (1),
   `import.target_candidate` (1). No Pack has emitted any of these since the
   language-Pack rewrite. The JS/TS Packs now publish **no field at all** on any
   template, so every rule reading `call_name`, `arg1`, `item`, `array_key`,
   `string_key`, `identifier_key`, `module_source` or `definition.qname` — nine
   distinct field names across nine rules — was dead twice over.

2. **Three rules matched `data.file`,** the synthetic per-artifact fact. It does
   exist (`OverlayFact::artifact`), but the audit counts it dead and the brief's
   porting table retires it; omega-vue emits `scope.template_block`,
   `scope.script_block` and `scope.style_block` once per SFC, which is the same
   statement made by a Pack.

3. **The one "live" rule matched nothing anyway.** `vue.template.directive-binding`
   filtered `directive` against `["v-bind","bind","v-model","model","v-on","on",
   "v-if","if","v-for","for","v-show","show"]`. Measured, omega-vue publishes the
   *authored* directive text: `:`, `@`, `v-bind`, `v-on`, `v-if`, `v-for`,
   `v-model`, `v-slot`, `v-html`, `v-text`. Six of the twelve listed values
   (`bind`, `model`, `on`, `if`, `for`, `show`) are spellings that cannot occur;
   the two most common directives in any real template, `:` and `@`, were absent
   from the list.

4. **Two rules read `name` as a field.** `data.vue_element` and
   `reference.vue_interpolation` publish no fields at all — the value is the
   emission's *name*, reachable as the built-in `definition.name`. A one-word
   mistake that killed both.

5. **One relation was a self-loop.** `vue.generic-api-call.vue` emitted
   `uses_api` from `current` to `vue:api-use:{path}:{source.start}` — the key
   `current` had just been minted under. The same shape wave 2 found in
   gitlab-ci and wave 6 in symfony.

6. **Four relations pointed at keys nothing minted.** `vue.macro.define*`,
   `vue.defineEmits.literal-event`, `vue.context.provide.literal` and
   `vue.context.inject.literal` all sourced at `vue:component:{path}`, a key only
   `vue.sfc.component` minted — from `data.file`, which the audit treats as
   unavailable. Had the macros ever matched, every one of their edges would have
   dangled.

7. **`external_path_matches` was used four times** against packages `vue` and
   `vue-router`. `OWED.md` item 7a: JS/TS facts carry no `external` at all,
   because `target_hint` comes from `occurrence.qualifier` and the JS/TS Packs
   publish `target`/`module` instead. All four clauses were unreachable for every
   possible input.

8. **Four `Declaration` entity kinds restated their input.** `PropsDeclaration`,
   `EmitsDeclaration`, `SlotsDeclaration` and `ExposeDeclaration` were four
   byte-identical rules differing only in one string. They are one rule now, over
   a `field_in` of six macro names.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files are Vue components | `scope.template_block` / `scope.script_block` in `**/*.vue` (omega-vue) | `Component vue:component:{path}`, `ComponentName vue:component-name:{path.stem}`, `declares_component` between them |
| What does this component render | `data.vue_element` (omega-vue emits it only for component-shaped tags, never for `div`/`p`/`input`) | `renders`: `vue:component:{path}` -> `vue:component-name:{tag}` |
| What content contract does this component expose | `definition.slot` | `Slot vue:slot:{path}:{name}`, `declares_slot` from the component |
| Which component handles the `submit` event | `reference.event` (`@evt` and `v-on:evt` alike) | `Event vue:event:{name}`, `listens_to` from the component |
| Where is unescaped HTML rendered; what is two-way bound; what is iterated | `data.vue_directive_value` with `directive` in `v-html`, `v-model`, `v-for` | `TemplateBinding vue:template-binding:{path}:{start}`, `uses_binding` from the component |
| Does this component declare props / emits / slots / expose / model / options | `call.function` named `defineProps`…`defineOptions` in `**/*.vue` | `ComponentApi vue:component-api:{path}:{macro}`, `declares` from the component |
| Which components do work on mount, unmount or error | `call.function` named `onMounted`…`onRenderTriggered` | `LifecycleHook vue:lifecycle:{path}:{hook}`, `uses_lifecycle` from the component |
| Which composables does this component use | `call.function` `use*` joined `by_field` to an `import.symbol` of the same name in the same file | `Composable vue:composable:{name}`, `uses_composable` from the component |
| Where is `useSession` defined | `definition.function` (JS arrow + `function`) / `definition.variable` (TS arrow) named `use*` under `**/composables/**` | the same `Composable vue:composable:{name}`, now carrying `file` |
| Which components pull in vue / vue-router / pinia / vuex / vue-i18n | `import.module` (its name is the authored specifier, unquoted) in `**/*.vue` | `Dependency vue:package:{pkg}`, `depends_on` from the component |
| Where does the app start | `call.function createApp` | `App vue:app:{path}`, `depends_on` -> `vue:package:vue` |
| Which file builds the router | `call.function createRouter` | `Router vue:router:{path}`, `depends_on` -> `vue:package:vue-router` |
| Which components are route-aware, or reach for slots/attrs | `call.function` in `useRouter`, `useRoute`, `useSlots`, `useAttrs`, … in `**/*.vue` | `ApiUse vue:api:{name}`, `uses_api` from the component |
| Which stores exist, and which components use them | `call.function defineStore` span-joined `within` its `definition.variable` | `Store vue:store:{binding}`, `Composable vue:composable:{binding}`, `provides_store`, `depends_on` -> `vue:package:pinia` |

### Key reachability (brief §3a)

Keys minted: `vue:component:{path}`, `vue:component-name:{…}`,
`vue:slot:{path}:{name}`, `vue:event:{name}`,
`vue:template-binding:{path}:{start}`, `vue:component-api:{path}:{macro}`,
`vue:lifecycle:{path}:{hook}`, `vue:composable:{name}`, `vue:package:{pkg}`,
`vue:app:{path}`, `vue:router:{path}`, `vue:api:{name}`, `vue:store:{name}`.
Keys addressed by a relation end: the same set, with no member outside it. No
rule uses `Reference::current`, so the §3b "first output" trap does not apply.
Every relation whose ends could have been minted by a rule with *different*
clauses instead mints them in the same rule: `vue.app.bootstrap` mints
`vue:package:vue` itself rather than relying on `vue.dependency`, which is gated
to `**/*.vue` while `main.ts` is not an SFC; `vue.router.definition` and
`vue.store.definition` do the same for `vue-router` and `pinia`;
`vue.composable.use` mints its own `vue:composable:{name}` hub so a composable
defined outside `**/composables/**` still has a node.

Every entity attribute resolves from a field the match clauses guarantee
(`path`, `path.stem`, `definition.name`, `source.start`, `directive`, `value`,
`binding.definition.name`), so none of them can trip the §3b
"unresolvable attribute drops the entity and keeps the relation" fault.

## A field only the Pack can supply

**None is needed, and two were considered and rejected.**

- `provide('themeKey', …)` / `inject('themeKey')` and `defineEmits(['select'])`
  would need the string-literal *arguments* of a call. omega-javascript and
  omega-typescript emit `call.function` with the callee name and no fields at
  all; there is no argument fact to join to, and no span to join `within`
  (arguments are not definitions). The value could only come from a new Pack
  field or a new Pack template. It is not requested here: it would cost bytes on
  every `call.function` in every repository, and the same argument-literal need
  recurs across most JS frameworks — it is one decision for the JS/TS Packs, not
  a Vue one. Recorded as a gap in `coverage.gaps` instead.
- `createRouter({ routes: [{ path: '/x', component: Home }] })` has the same
  shape at object-literal depth, with the extra constraint wave 5 measured for
  omega-vite: the JS/TS Packs emit a fact for an object key **only when its value
  is a function**, so a route entry emits nothing whatever field were added to
  the call. This is a Pack *template* question, not a field question.

The one place a Pack field looked necessary — naming a Pinia store — was reached
with `fact_join_by_span`/`within` to the `definition.variable` the
`defineStore(…)` call sits inside, exactly the contract §2 order: derive, then
join, then ask.

## Still to decide

1. **Tag-to-file resolution is by name, not by import.** `<UserCard/>` and
   `components/UserCard.vue` meet at `vue:component-name:UserCard`. A
   kebab-case tag (`<user-card/>`) does not, because no clause or key template
   can case-fold. The alternative — joining `data.vue_element` to a
   `binding.import_default` of the same name in the same file — proves the tag
   *is* a local import but still cannot name the target file, because
   `import.module` (which carries the specifier) and `binding.import_default`
   (which carries the local name) have disjoint spans and no shared field. A
   host-side kebab/Pascal normalizer, or a Pack field pairing an import's local
   name with its specifier, would close this; neither exists today.
2. **`use` as a prefix is a convention, not a marker.** `field_prefix` cannot
   require `use` + an uppercase letter, so `used()` or `user()` would match
   `vue.composable.use` if the same file also imported a symbol of that name.
   The import join makes that unlikely rather than impossible.
3. **Pinia is not Vue.** There is no `omega-framework-pinia`, and *where is
   application state defined* is a question every Vue project asks, so
   `vue.store.definition` lives here. If a Pinia framework is ever written, that
   rule and the `pinia` entry in `vue.dependency` move to it.
