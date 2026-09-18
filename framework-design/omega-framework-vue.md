# omega-framework-vue

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind —
with one exception the audit used to get wrong, `data.file`, which the **host**
emits once per artifact and which is the only way to address the file rather
than a declaration inside it (`OverlayFact::artifact`, `overlay.rs:41`).

## State

**17 overlay rules, 4 detection rules. All 17 match.**
(Wave 1: 17 rules, 1 nominally live and 0 producing anything. Wave 2: 16 rules,
16 live, but with every file-shaped rule deleted. Now: 17 rules, 17 live.)

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
| `Composable` | 4 |
| `Dependency` | 4 |
| `ComponentName` | 2 |
| `ApiUse`, `App`, `Component`, `ComponentApi`, `Event`, `LifecycleHook`, `Route`, `Router`, `Slot`, `Store`, `TemplateBinding` | 1 each |

### Relations it declares

`declares`, `declares_component`, `declares_slot`, `depends_on`, `listens_to`,
`provides_store`, `renders`, `uses_api`, `uses_binding`, `uses_composable`,
`uses_lifecycle`.

### Fact kinds it matches

| kind | rules | emitter |
|---|---|---|
| `call.function` | 6 | omega-javascript, omega-typescript |
| `data.file` | 2 primary + 1 join | the **host**, one per artifact, before any Pack runs |
| `data.vue_element` | 2 | omega-vue |
| `data.vue_directive_value` | 1 | omega-vue |
| `definition.slot` | 1 | omega-vue |
| `reference.event` | 1 | omega-vue |
| `definition.function`, `definition.variable` | 1 each | omega-javascript, omega-typescript |
| `import.module` | 1 primary + 1 join | omega-javascript, omega-typescript |
| `import.symbol` | 1 join | omega-javascript, omega-typescript |

Fields read: `directive`, `value` (both published by omega-vue on
`data.vue_directive_value`). Everything else is a built-in: `definition.name`,
`path`, `path.dir`-family (`path.stem`), `source.start`, `row_kind`.

Path globs: `**/*.vue`, `**/pages/**/*.vue`, `**/composables/**`. No braces, so
none of them is the literal-byte glob of brief §3c.

## What was wrong with it

### Wave 1: 17 rules, nothing in the graph

The file shipped 17 rules. **16 of them could not match any emission**, and the
one that could (`vue.template.directive-binding`) matched on a directive list
that named no spelling the Pack publishes — so in practice **0 of 17 rules
produced anything.**

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

2. **The one "live" rule matched nothing anyway.** `vue.template.directive-binding`
   filtered `directive` against `["v-bind","bind","v-model","model","v-on","on",
   "v-if","if","v-for","for","v-show","show"]`. Measured, omega-vue publishes the
   *authored* directive text: `:`, `@`, `v-bind`, `v-on`, `v-if`, `v-for`,
   `v-model`, `v-slot`, `v-html`, `v-text`. Six of the twelve listed values
   (`bind`, `model`, `on`, `if`, `for`, `show`) are spellings that cannot occur;
   the two most common directives in any real template, `:` and `@`, were absent
   from the list.

3. **Two rules read `name` as a field.** `data.vue_element` and
   `reference.vue_interpolation` publish no fields at all — the value is the
   emission's *name*, reachable as the built-in `definition.name`. A one-word
   mistake that killed both.

4. **One relation was a self-loop.** `vue.generic-api-call.vue` emitted
   `uses_api` from `current` to `vue:api-use:{path}:{source.start}` — the key
   `current` had just been minted under.

5. **`external_path_matches` was used four times** against packages `vue` and
   `vue-router`. `OWED.md` item 7a: JS/TS facts carry no `external` at all,
   because `target_hint` comes from `occurrence.qualifier` and the JS/TS Packs
   publish `target`/`module` instead. All four clauses were unreachable for every
   possible input.

6. **Four `Declaration` entity kinds restated their input.** `PropsDeclaration`,
   `EmitsDeclaration`, `SlotsDeclaration` and `ExposeDeclaration` were four
   byte-identical rules differing only in one string. They are one rule now, over
   a `field_in` of six macro names.

### Wave 2: the file itself stopped being addressable — `OWED.md` item 13

Wave 2 fixed all of the above and left 16 live rules, but it deleted **three
uses of `data.file`** on a false premise. `overlay_audit.py` built its kind set
from `packs/*/rules.json` alone, and no Pack emits `data.file` — because the
**host** does, once per artifact, before any Pack emission. The brief's porting
table compounded it by listing `data.file` as a kind to retire. Five frameworks
whose subject *is* the file tree lost file-shaped rules this way (next-js 20,
nuxt 11, sveltekit 10, vue 3, blazor 2).

The three uses vue lost, and what each cost:

| deleted rule | what it addressed | what replaced it | what that could no longer answer |
|---|---|---|---|
| `vue.sfc.component` | `data.file` under `**/*.vue` → `Component vue:component:{path}` | `vue.sfc.component.template` + `vue.sfc.component.script`, two byte-identical rules over `scope.template_block` / `scope.script_block` | an SFC that omega-vue emits neither block for — a style-only `.vue`, a file whose `<script lang="…">` the injection could not resolve, a malformed template — produced **no `Component` entity at all**, and so every `declares_slot`, `listens_to`, `uses_binding`, `declares` and `depends_on` edge sourced at `vue:component:{path}` for that file dangled |
| `vue.template.exact-file-component-render` | `data.vue_element` joined by field to the `data.file` whose `path.stem` is the tag | `vue.template.renders`, a name hub `vue:component-name:{tag}` | *which file does `<UserCard/>` render* — the name hub says the tag and something called `UserCard` are the same thing, but never names `src/components/UserCard.vue` |
| `vue.router.inline-literal-route-component` | the `createRouter({routes:[…]})` object literal joined to a `data.file` | nothing | nothing was lost: its primary fact kind was `data.ecmascript_call_object_array_object_string_identifier_context`, and the JS/TS Packs emit a fact for an object key **only when its value is a function**, so no rewrite of this rule can reach a route entry. It stays a `coverage.gaps` entry |

Two of the three were restorable, and are restored. The wave also left Vue with
**no answer at all to *which route serves this path***, which `vue.pages.route`
now gives where a project has opted into file-based routing.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files are Vue components | `data.file` (host synthetic) under `**/*.vue` | `Component vue:component:{path}`, `ComponentName vue:component-name:{path.stem}`, `declares_component` between them |
| Which route serves this path, in a file-routed Vue app | `data.file` under `**/pages/**/*.vue`, gated on an `import.module` of a generated-routes specifier existing anywhere in the project | `Route vue:route:{normalized_file_route}`, `renders` → `vue:component:{path}` |
| What does this component render (by name) | `data.vue_element` (omega-vue emits it only for component-shaped tags, never for `div`/`p`/`input`) | `ComponentName vue:component-name:{tag}`, `renders`: `vue:component:{path}` → it |
| Which **file** does this tag render | `data.vue_element` joined `by_field` to the `data.file` whose `path.stem` is the tag | `renders`: `vue:component:{path}` → `vue:component:{target file}` |
| What content contract does this component expose | `definition.slot` | `Slot vue:slot:{path}:{name}`, `declares_slot` from the component |
| Which component handles the `submit` event | `reference.event` (`@evt` and `v-on:evt` alike) | `Event vue:event:{name}`, `listens_to` from the component |
| Where is unescaped HTML rendered; what is two-way bound; what is iterated | `data.vue_directive_value` with `directive` in `v-html`, `v-model`, `v-for`, … | `TemplateBinding vue:template-binding:{path}:{start}`, `uses_binding` from the component |
| Does this component declare props / emits / slots / expose / model / options | `call.function` named `defineProps`…`defineOptions` in `**/*.vue` | `ComponentApi vue:component-api:{path}:{macro}`, `declares` from the component |
| Which components do work on mount, unmount or error | `call.function` named `onMounted`…`onRenderTriggered` | `LifecycleHook vue:lifecycle:{path}:{hook}`, `uses_lifecycle` from the component |
| Which composables does this component use | `call.function` `use*` joined `by_field` to an `import.symbol` of the same name in the same file | `Composable vue:composable:{name}`, `uses_composable` from the component |
| Where is `useSession` defined | `definition.function` (JS arrow + `function`) / `definition.variable` (TS arrow) named `use*` under `**/composables/**` | the same `Composable vue:composable:{name}`, now carrying `file` |
| Which components pull in vue / vue-router / pinia / vuex / vue-i18n | `import.module` (its name is the authored specifier, unquoted) in `**/*.vue` | `Dependency vue:package:{pkg}`, `depends_on` from the component |
| Where does the app start | `call.function createApp` | `App vue:app:{path}`, `depends_on` → `vue:package:vue` |
| Which file builds the router | `call.function createRouter` | `Router vue:router:{path}`, `depends_on` → `vue:package:vue-router` |
| Which components are route-aware, or reach for slots/attrs | `call.function` in `useRouter`, `useRoute`, `useSlots`, `useAttrs`, … in `**/*.vue` | `ApiUse vue:api:{name}`, `uses_api` from the component |
| Which stores exist, and which components use them | `call.function defineStore` span-joined `within` its `definition.variable` | `Store vue:store:{binding}`, `Composable vue:composable:{binding}`, `provides_store`, `depends_on` → `vue:package:pinia` |

### Why the file count went up by one

Two rules removed (`vue.sfc.component.template`, `vue.sfc.component.script` —
byte-identical to each other and a strictly narrower spelling of
`vue.sfc.component.file`, which mints the same two keys with the same
attributes from a fact that is guaranteed to exist for every `.vue` file).
Three added (`vue.sfc.component.file`, `vue.pages.route`,
`vue.template.renders.file`). Net 16 → 17, and the extra rule is
`vue.pages.route`, the only answer in the file to *which route serves this
path*.

### `data.file` in three rules, and why each is about the file

- `vue.sfc.component.file` — *is this file a component* is a question about the
  artifact. Nothing inside an SFC declares it; the extension does.
- `vue.pages.route` — *which URL is this file* is a question only the path can
  answer, and `{normalized_file_route}` is the placeholder that answers it
  (`overlay.rs:1047`, `file_route`). A `pages/about.vue` that is ten lines of
  static markup declares nothing and would have no entity under any
  declaration-entered rule.
- `vue.template.renders.file` joins **to** `data.file` because the thing it
  needs is the target file's path, which no declaration inside that file
  carries.

### Key reachability (brief §3a)

Keys minted: `vue:component:{path}`, `vue:component-name:{…}`,
`vue:route:{normalized_file_route}`, `vue:slot:{path}:{name}`,
`vue:event:{name}`, `vue:template-binding:{path}:{start}`,
`vue:component-api:{path}:{macro}`, `vue:lifecycle:{path}:{hook}`,
`vue:composable:{name}`, `vue:package:{pkg}`, `vue:app:{path}`,
`vue:router:{path}`, `vue:api:{name}`, `vue:store:{name}`.

Keys addressed by a relation end: the same set, with no member outside it.
`vue.template.renders.file`'s target is rendered from the joined file's own
`path` into `vue:component:{value}`, which is exactly the key
`vue.sfc.component.file` mints — and the join's `where` carries the **same**
`**/*.vue` glob and the **same** `path_segment` exclusion as that rule's match,
so it can never address a key the minting rule declined to create (brief §3b,
second trap). `vue.pages.route`'s `renders` target is `vue:component:{path}` for
its own file, which `vue.sfc.component.file` mints under the same exclusion
list.

No rule uses `Reference::current`, so the §3b "first output" trap does not
apply. Every relation whose ends could have been minted by a rule with
*different* clauses instead mints them in the same rule: `vue.app.bootstrap`
mints `vue:package:vue` itself rather than relying on `vue.dependency`, which is
gated to `**/*.vue` while `main.ts` is not an SFC; `vue.router.definition` and
`vue.store.definition` do the same for `vue-router` and `pinia`;
`vue.composable.use` mints its own `vue:composable:{name}` hub so a composable
defined outside `**/composables/**` still has a node.

Every entity attribute resolves from a field the match clauses guarantee
(`path`, `path.stem`, `definition.name`, `source.start`, `directive`, `value`,
`binding.definition.name`), so none of them can trip the §3b "unresolvable
attribute drops the entity and keeps the relation" fault. In particular
`{normalized_file_route}` appears **only** in key and relation-end templates,
never as a `field_ref` attribute, which is the fault that cost
omega-framework-nuxt its four principal entities (brief §3e).

### Key collisions (brief §3g)

`python pack-design/key_collisions.py vue` reports nothing. Two rules share
`vue:component:{path}` as a relation end but only `vue.sfc.component.file` mints
an entity there. Two rules mint `ComponentName` — `vue.sfc.component.file` at
`vue:component-name:{path.stem}` and `vue.template.renders` at
`vue:component-name:{definition.name}` — which are different templates that
deliberately render to the same string for a matching tag and file. They agree
on the kind **and** on the single attribute (`name`, the same value both ways),
so whichever interns first, the graph is identical. `vue.sfc.component.file`
sorts before `vue.template.renders` and is the richer of the two, which is the
order brief §3l asks for.

## A field only the Pack can supply

**None is needed, and one was considered and rejected.**

- `provide('themeKey', …)` / `inject('themeKey')` and `defineEmits(['select'])`
  need the string-literal *arguments* of a call, and omega-javascript and
  omega-typescript **publish them**: `call.function` carries `call.arg0`,
  `call.arg0_text`, `call.arg0_name` and the rest of the family in brief §3l,
  the same as the other nine Packs. An earlier draft of this note said the
  opposite and recorded a permanent gap that does not exist; `vue.injection.key`
  states the provide/inject pair on `call.arg0_text` now.
- `createRouter({ routes: [{ path: '/x', component: Home }] })` is a different
  shape: it lives at object-literal depth, and the JS/TS Packs emit a fact for
  an object key **only when its value is a function**, so a route entry emits
  nothing whatever fields the call carries. That is a Pack *template* question —
  `OWED.md` item 18, the string-keyed property — not a field question, and it is
  why `vue.router.inline-literal-route-component` was not restored with the
  other `data.file` rules.

The one place a Pack field looked necessary — naming a Pinia store — was reached
with `fact_join_by_span`/`within` to the `definition.variable` the
`defineStore(…)` call sits inside, exactly the contract §2 order: derive, then
join, then ask.

## Still to decide

1. **`vue.pages.route` gates on a project-wide import, using `row_kind` as the
   join key.** Vue Router is configured, not file-based; `pages/` only means a
   route when `unplugin-vue-router` or `vite-plugin-pages` is installed. The
   only way the overlay can ask *does this project use file-based routing* is a
   `fact_join_by_field` whose `current_field` and `join_field` are both
   `row_kind` — which is `"fact"` on every fact (`overlay.rs:79`), so the join
   degenerates into an existence quantifier over `import.module` facts anywhere
   in the view, filtered by a `where` on the generated-routes specifiers. It is
   correct and it is cheap, but it is an idiom, not a clause; if a
   `fact_exists` clause is ever added to `overlay.rs`, this is its first caller.
   Without the gate, every plain-Vue `src/pages/Foo.vue` would become a false
   `Route`; with it, a Nuxt project (which imports none of those specifiers)
   correctly yields nothing here and is left to omega-framework-nuxt.
2. **Tag-to-file resolution is by stem, not by import.** `<UserCard/>` now
   reaches `components/UserCard.vue` through `vue.template.renders.file`, but a
   kebab-case tag (`<user-card/>`) does not, because no clause or key template
   can case-fold, and two files with the same stem in different directories both
   receive the edge. The alternative — joining `data.vue_element` to a
   `binding.import_default` of the same name in the same file — proves the tag
   *is* a local import but still cannot name the target file, because
   `import.module` (which carries the specifier) and `binding.import_default`
   (which carries the local name) have disjoint spans and no shared field. A
   host-side kebab/Pascal normalizer, or a Pack field pairing an import's local
   name with its specifier, would close both halves; neither exists today.
3. **`use` as a prefix is a convention, not a marker.** `field_prefix` cannot
   require `use` + an uppercase letter, so `used()` or `user()` would match
   `vue.composable.use` if the same file also imported a symbol of that name.
   The import join makes that unlikely rather than impossible.
4. **Pinia is not Vue.** There is no `omega-framework-pinia`, and *where is
   application state defined* is a question every Vue project asks, so
   `vue.store.definition` lives here. If a Pinia framework is ever written, that
   rule and the `pinia` entry in `vue.dependency` move to it.
5. **Five omega-vue kinds are still unread**: `reference.prop`,
   `reference.slot`, `reference.template_expression`,
   `definition.template_binding`, `definition.template_ref`. They are live facts
   and would answer *which props does the parent pass*, *which named slot is
   filled here* and *what does `ref="x"` address*. This wave was scoped to
   restoring the file-shaped rules and did not add them; they are the obvious
   next increment.
