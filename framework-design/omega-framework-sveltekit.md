# omega-framework-sveltekit

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind —
with one exception the audit used to hide, `data.file`, which the host
synthesizes per artifact (`OverlayFact::artifact`, overlay.rs:41).

## State

**23 overlay rules, 4 detection rules. All 23 match; 0 cannot.**
It was 29 rules, 0 of which could match; the first rewrite cut it to 15.

Selector: `framework:sveltekit`. Maturity: `semantic-overlay-full`.
Packs it reads: `omega-svelte`, `omega-javascript`, `omega-typescript`.

### Fact kinds it matches

| kind | rules | who emits it |
|---|---|---|
| `data.file` | 8 | the host, one per artifact, before any Pack emission |
| `definition.variable` | 6 | javascript, typescript |
| `definition.function` | 5 | javascript, typescript |
| `reference.svelte_component` | 3 | svelte |
| `import.module` | 1 | javascript, typescript |

Clause vocabulary: `fact_kind` x23, `path_glob` x14, `field_equals` x10,
`field_in` x10, `fact_join_by_span` x1, `fact_join_by_path_ancestor` x1,
`field_prefix` x1.

Fields read: `definition.name` x12, `path.stem` x9 — both built-ins
`OverlayFact::field` resolves. **No Pack field is read.**

Path globs: `**/+page.svelte` x3, `**/+layout.svelte` x3, `**/params/*.*` x3,
`**/+page.*`, `**/+layout.*`, `**/+server.*`, `**/+error.svelte`,
`**/src/hooks.*`. No glob spells a brace; the `*` after a `+name.` stands for
the extension, which is `.js` or `.ts` and which no rule needs to know.

### Entities it declares

| entity_kind | rules | entity_kind | rules |
|---|---|---|---|
| `Route` | 14 | `Loader` | 2 |
| `HookModule` | 3 | `RouteModule` | 2 |
| `Layout` | 3 | `Component` | 2 |
| `Page` | 3 | `Action` | 1 |
| `ParamMatcher` | 3 | `Endpoint` | 1 |
| `Actions` | 2 | `ErrorPage` | 1 |
| `EndpointHandler` | 2 | `KitFile` | 1 |
| `HookHandler` | 2 | `KitModule` | 1 |
| | | `RouteOption` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 5 |
| `handles` | 4 |
| `layout_applies_to` | 3 |
| `route_to_component` | 3 |
| `loads` | 2 |
| `renders` | 2 |
| `config` | 1 |
| `depends_on` | 1 |

## What was wrong with it

Two rounds of damage, and the second was done by the rewrite that fixed the
first.

### Round one: the file as it shipped, 29 rules, 0 live

**The kind, 29 of 29.** Every rule was keyed to the generator's old vocabulary:
10 to `data.file`, 8 to `definition.ecmascript_exported_function_context`, 8 to
`definition.ecmascript_exported_variable_context`, and one each to
`call.target_candidate`, `import.target_candidate` and
`data.ecmascript_exported_object_field_context`. Five of the six are emitted by
no Pack. The sixth, `data.file`, is emitted by no Pack **and matches every
artifact anyway** — see round two.

**The field, 17 of 29.** 16 rules read `exported_name` and one read `field_key`
and `owner_export`. None of the three is published by any Pack, and all three
are reachable without a field: the name of an export is `definition.name`, and
an action held by a property of the `actions` object is reached by
`fact_join_by_span` / `within` against the declarator the Pack already spans.

**The glob, 23 of 27.** Every glob that spelled an extension spelled it
`{js,ts}` — `**/+server.{js,ts}`, `**/params/*.{js,ts}`,
`**/hooks.{server,client}.{js,ts}`. `glob_matches` (overlay.rs:1120) handles
`*`, `**` and `?` and **nothing else**: a brace is matched as a literal brace.
Those 23 rules could never have fired, in any Pack vocabulary, ever.

**The key, 6 rules dangling and 2 relation ends pointing nowhere.** Six rules
rendered `{path.route}`, which is not a Pack field, not one of the built-in
names `OverlayFact::field` resolves, and not an attribute any of those rules
computed — `render` returns `None` and the entity is dropped. Separately,
`sveltekit.action.member` sourced a `contains` at `sveltekit:file:{path}`, a key
no rule in the file ever minted, and `sveltekit.layout.file` addressed a
relation end `by_field path.dir`, which is a bare directory string and not a
canonical key at all.

**What only restated its input, 14 of 29.** The 14 `sveltekit.export.*` rules
minted one entity per declaration, keyed `{path}:{exported_name}`, with no
relation to anything — which is what the Packs already said.

### Round two: the rewrite deleted the ten rules that were not dead

The first rewrite dropped all ten `data.file` rules on the audit's word. That
was wrong, and this file's own "Still to decide" section said so while doing it:
`facts_of_surface` (overlay.rs:1199) pushes one synthetic
`OverlayFact::artifact(path)` of kind `data.file` per artifact, before any Pack
emission, with field `path` and therefore with `path.dir` and `path.stem`.
`overlay_audit.py` built its kind set from `packs/*/rules.json` alone and could
not see it. It can now.

The cost was exact, and it is the cost every file-based router paid (next-js 20,
nuxt 11, sveltekit 10, vue 3, blazor 2): **a SvelteKit file that declares
nothing produced no entity at all.** Measured against the 15 rules that
survived:

| file | what it declares | what the graph had |
|---|---|---|
| `routes/about/+page.svelte` that is plain markup with no child component | nothing — `reference.svelte_component` needs a component tag | no `Page`, and no `Route` unless a sibling `+page.server.ts` existed |
| `routes/+layout.svelte` that is a header, a `<slot/>` and a footer | nothing | no `Layout`, so nothing wrapped anything |
| `routes/+error.svelte` | nothing | nothing at all — the framework had no error-boundary answer of any kind |
| `routes/api/+server.ts` with `export { GET, POST } from './impl'` | a re-export, not a declaration | no `EndpointHandler`, no `Route` |
| `routes/x/+page.ts` whose only export is a re-export | nothing | no `Route` |
| `params/integer.ts` with `export { match } from './shared'` | nothing | no `ParamMatcher`, and `[id=integer]` resolved to nothing |
| `src/hooks.server.ts` with `export { handle } from './mw'` | nothing | no `HookModule` |

Eight rules are restored for exactly those seven questions, and only for
questions the file answers and a declaration does not. Every restored rule mints
the **same key with the same entity kind** as the declaration-entered rule that
states the same thing — `sveltekit:route:{path.dir}`, `sveltekit:page:{path}`,
`sveltekit:layout:{path}`, `sveltekit:hooks:{path}`,
`sveltekit:param-matcher:{path.stem}` — so a page recognised by its markup and a
page recognised by its filename are one entity. Their attribute sets are
identical, so `or_insert` discards nothing whichever id sorts first, and
`key_collisions.py` reports `0 entity outputs are overwritten`.

No rule that worked was deleted. 15 rules become **23, all live.**

## What it states now

The route is the route directory: `sveltekit:route:{path.dir}`. Every file of a
SvelteKit route — `+page.svelte`, `+page.server.ts`, `+server.ts` — shares one
directory, so every rule below reaches the same route key from `path.dir`
without any Pack publishing a route, and without depending on which of those
files a project happens to have.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which route serves this path, from the file tree alone | `data.file` under `**/+page.*` or `**/+layout.*` | `Route`, `RouteModule`, `Route -contains-> RouteModule` |
| what this route renders, when the page is static markup | `data.file` under `**/+page.svelte` | `Page`, `Route`, `Route -route_to_component-> Page` |
| what this route renders, when the page mounts components | `reference.svelte_component` in `**/+page.svelte` | `Page`, `Route`, `Component`, `Route -route_to_component-> Page`, `Page -renders-> Component` |
| what wraps every page below this directory, when the layout is plain markup | `data.file` under `**/+layout.svelte` | `Layout`, `Route`, `Layout -layout_applies_to-> Route` |
| what wraps every page below this directory, when the layout mounts components | `reference.svelte_component` in `**/+layout.svelte` | `Layout`, `Route`, `Component`, `Layout -layout_applies_to-> Route`, `Layout -renders-> Component` |
| which layouts wrap this page | the page's component tag joined `fact_join_by_path_ancestor` to a layout whose `path.dir` is an ancestor | `Layout -layout_applies_to-> Page` |
| where this route's error boundary is | `data.file` under `**/+error.svelte` | `ErrorPage`, `Route`, `Route -route_to_component-> ErrorPage` (attr `role=error`) |
| which routes have a server endpoint at all | `data.file` under `**/+server.*` | `Endpoint`, `Route`, `Route -handles-> Endpoint` |
| which handler answers `POST /orders` | `definition.function` / `definition.variable` named for an HTTP method, `path.stem` = `+server` | `EndpointHandler`, `Route`, `Route -handles-> EndpointHandler` |
| what data this route loads, and whether it loads on the server | `definition.function` / `definition.variable` named `load`, `path.stem` in `+page`, `+page.server`, `+layout`, `+layout.server` | `Loader` (attribute `module` = the stem), `Loader -loads-> Route` |
| which route accepts form posts | `definition.variable` named `actions`, `path.stem` = `+page.server` | `Actions`, `Route -handles-> Actions` (method `POST`) |
| which named action `?/create` reaches | `definition.function` inside the `actions` declarator, reached by `fact_join_by_span` / `within` | `Action`, `Actions -contains-> Action` |
| what runs before every request | `definition.function` / `definition.variable` named `handle`, `handleError`, `handleFetch`, `handleValidationError`, `init`, `reroute`, `transport`, `path.stem` in `hooks`, `hooks.server`, `hooks.client` | `HookHandler`, `HookModule`, `HookModule -contains-> HookHandler` |
| whether this project installs hooks at all | `data.file` under `**/src/hooks.*` | `HookModule` |
| where the matcher `[id=integer]` names is defined | `definition.function` / `definition.variable` named `match` under `**/params/*.*`, and `data.file` under the same glob | `ParamMatcher`, keyed `sveltekit:param-matcher:{path.stem}` — the name the route spells, not the file |
| which routes set `prerender`, `ssr`, `csr`, `trailingSlash`, `config`, `entries` | `definition.variable` so named in a `+page`/`+layout`/`+server` module | `RouteOption`, `Route -config-> RouteOption` |
| which files read a server-only secret or an app store | `import.module` whose specifier starts `$` (`$env/static/private`, `$app/state`, `$lib`) | `KitModule`, `KitFile`, `KitFile -depends_on-> KitModule` |

Every canonical key a relation addresses is minted by a rule with the same
clauses that address it, in the same rule. `sveltekit:layout:{layout.path}` is
minted in `sveltekit.layout.ancestry` itself, under the same `**/+layout.svelte`
glob that `sveltekit.layout.renders` uses, so the ancestry edge cannot outrun the
entity. No rule relies on `Reference::Current`; both ends of every relation are
explicit canonical keys, so output order cannot misaddress one. No rule names an
attribute `path` or `name`, so no later output in the same rule picks up an
earlier one's value through `resolve_placeholder` (brief 3k).

### Why four rules are still a `.function` / `.variable` pair

This is not a language spelling that collapsed. The two Packs disagree about
which fact an arrow function bound to a name is:

- **omega-javascript** has a `function.binding` pattern, so
  `export const GET = async (e) => {…}` is `definition.function`, and its
  `module_variable` pattern excludes function-valued bindings.
- **omega-typescript** has no such pattern: every module-scope declarator is
  `definition.variable`, and `definition.function` is only
  `function_declaration` / `function_signature`.

So `export function GET` and `export const GET =` are different kinds, and which
one a given file produces depends on the Pack, not on the framework. Four
constructs — endpoint handler, `load`, hook, param matcher — therefore keep both
rules.

### Why nothing here matches `@sveltejs/kit` by package

Two rules of an earlier draft (`KitApi`, `ApiUse`) matched `@sveltejs/kit` by
resolved external package. Both were removed before this wave, for the reason
brief §3i states: `OverlayFact.external` is built from a qualifier only
omega-c-sharp and omega-docker-compose publish, so the clause is false for every
possible input in a JavaScript project — and `parse_external_path` would read
`@sveltejs/kit` as package `@sveltejs` in any case. `emits.entities` still
advertised `KitApi` and `ApiUse` and `emits.relations` still advertised
`uses_api` after those rules were removed; the three are dropped, so the emit
lists now match what the rules actually output.

## A field only the Pack can supply

**Pack: `omega-typescript`. Kind: `definition.function`. What is missing: a
template for a function held by a property of an object literal.**

`omega-javascript` states this — the `object_function` pattern, `(pair key:
(property_identifier) value: [arrow_function | function_expression …])`, emitted
as `definition.function` named for the key. `omega-typescript` has no
equivalent pattern, so in a `+page.server.ts`

```ts
export const actions = {
  create: async ({ request }) => { … },
  delete: async ({ request }) => { … }
};
```

the Pack states the `actions` declarator and nothing inside it. The individual
form actions — the things a `?/create` POST actually reaches — do not exist as
facts, so `sveltekit.action.member` answers for `.js` projects and not for `.ts`
ones, which is most SvelteKit projects.

None of the three cheaper options reaches it. A built-in name cannot:
`definition.name` is the name of a fact, and there is no fact. A
`fact_join_by_span` cannot: a join binds an existing fact by its span, and the
span of `create` is inside the declarator but carries no emission of any kind.
And `data.file` cannot: this is a question about a declaration inside a file, not
about the file. This is not a `field` on an existing kind — it is a missing
template, the same one `omega-javascript` already ships, and the fix is to port
that pattern (`pair`/`arrow_function`) into `omega-typescript`'s queries. It
would pay for itself well beyond SvelteKit: handler tables, reducer maps and
route objects in object literals are how a great deal of TypeScript declares its
callables.

## Still to decide

**The route key is a directory, and `{normalized_file_route}` cannot replace
it.** The wave brief asks the restored file rules to key on
`{normalized_file_route}`, "as they did". They did not: the ten deleted rules
keyed on `{path.route}`, which resolves to nothing at all, and that is one of
the reasons they were deleted. `{normalized_file_route}` is a real placeholder,
and it is still the wrong key here, for a reason that is in the host and is
measurable. `file_route` (overlay.rs:1076) takes the routing root from the
glob's literal segments and then drops the file name **only** when its stem is
one of `page`, `route`, `index`, `layout`, `_index`. SvelteKit spells those
`+page`, `+page.server`, `+layout`, `+layout.server`, `+server`, so the stem is
kept: under `**/routes/**/+page.svelte` the route of
`src/routes/orders/[id]/+page.svelte` comes out `/orders/{id}/+page`, and that of
`src/routes/orders/[id]/+page.server.ts` `/orders/{id}/+page.server`. Two keys
for one route — precisely what a shared key exists to prevent, and it would split
every route this wave was sent to reunite. Worse, the globs these rules need are
`**/+page.svelte` and `**/+server.*`, which name no `routes` segment at all:
`glob_root` returns `["+page.svelte"]`, `find_root` lands past the file name, and
the route is the empty string for every file in the project.

So this overlay keys `sveltekit:route:{path.dir}`, which is stable, is shared by
every file of the route, and is what the 15 surviving rules already used; the URL
form is published alongside it as the `route` attribute,
`normalize_route(path.dir)`. **Adding the five `+`-prefixed stems to
`file_route`'s leaf list is a one-line change to `overlay.rs`** and would let
SvelteKit join the shared `http:*:{normalized_file_route}` namespace that next-js
uses, so an agent could ask "what serves `/orders/{}`" across frameworks. It is a
host change, not an asset change, and is reported rather than made.

**`**/src/hooks.*` is narrower than the declaration rules.** The hook rules match
on `path.stem` in `hooks`, `hooks.client`, `hooks.server` with no directory
constraint, so `src/lib/util/hooks.ts` would satisfy them if it exported a
function called `handle`. The file-shaped rule cannot afford that looseness — a
file named `hooks.ts` anywhere is common and means nothing on its own — so it
requires the `src/` parent SvelteKit itself requires. The two therefore do not
cover exactly the same set, deliberately.

**`**/params/*.*` matches any `params/` directory.** It is inherited from the
surviving declaration rules rather than introduced here, and tightening it to
`**/src/params/*.*` would be the same judgement as the hooks one. It is left
alone because narrowing a glob on a rule that works today is a deletion, and this
wave adds.

**`RouteModule` is a new entity kind and is the one genuinely arguable
addition.** `sveltekit.route.file.page` and `sveltekit.route.file.layout` exist
to mint the `Route` for a directory whose `+page.ts` or `+layout.server.ts`
declares nothing the other rules recognise. A `Route` with no relation would be
an entity restating its input, so those rules also mint the module file and a
`Route -contains-> RouteModule` edge, which answers *which files make up this
route* — a question SvelteKit's five-file-per-directory convention makes real.
If a later wave decides that is one entity too many, the `Route` output and its
glob are the part that must survive.
