# omega-framework-sveltekit

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**17 overlay rules, 4 detection rules. All 17 match; 0 cannot.**
It was 29 rules, 0 of which could match.

Selector: `framework:sveltekit`. Maturity: `semantic-overlay-full`.
Packs it reads: `omega-svelte`, `omega-javascript`, `omega-typescript`.

### Fact kinds it matches

| kind | rules | who emits it |
|---|---|---|
| `definition.variable` | 7 | javascript, typescript |
| `definition.function` | 5 | javascript, typescript |
| `reference.svelte_component` | 4 | svelte |
| `import.module` | 1 | javascript, typescript |
| `import.symbol` | 1 | javascript, typescript |
| `call.function` | 1 | javascript, typescript |

Clause vocabulary: `fact_kind` x17, `field_equals` x10, `field_in` x10,
`path_glob` x6, `external_path_matches` x2, `field_present` x2,
`fact_join_by_span` x1, `fact_join_by_path_ancestor` x1, `field_prefix` x1.

Fields read: `definition.name` x12, `path.stem` x9, `external.member` x2 — all
three are built-ins `OverlayFact::field` resolves. **No Pack field is read.**

Path globs: `**/+page.svelte`, `**/+layout.svelte`, `**/params/*.*`. Extensions
are never spelled in a glob; `path.stem` carries them.

### Entities it declares

| entity_kind | rules | entity_kind | rules |
|---|---|---|---|
| `Route` | 8 | `Layout` | 2 |
| `EndpointHandler` | 2 | `KitFile` | 2 |
| `Loader` | 2 | `KitApi` | 2 |
| `Actions` | 2 | `Action` | 1 |
| `HookHandler` | 2 | `RouteOption` | 1 |
| `HookModule` | 2 | `KitModule` | 1 |
| `ParamMatcher` | 2 | `ApiUse` | 1 |
| `Page` | 2 | `Component` | 2 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 3 |
| `contains` | 3 |
| `loads` | 2 |
| `renders` | 2 |
| `layout_applies_to` | 2 |
| `depends_on` | 2 |
| `route_to_component` | 1 |
| `config` | 1 |
| `uses_api` | 1 |

## What was wrong with it

29 rules, 0 live. Four separate defects, each fatal on its own.

**The kind, 29 of 29.** Every rule was keyed to the generator's old vocabulary:
10 to `data.file`, 8 to `definition.ecmascript_exported_function_context`, 8 to
`definition.ecmascript_exported_variable_context`, and one each to
`call.target_candidate`, `import.target_candidate` and
`data.ecmascript_exported_object_field_context`. No Pack emits any of the six.

**The field, 17 of 29.** 16 rules read `exported_name` and one read `field_key`
and `owner_export`. None of the three is published by any Pack, and all three
are reachable without a field: the name of an export is `definition.name`, and
an action held by a property of the `actions` object is reached by
`fact_join_by_span` / `within` against the declarator the Pack already spans.

**The glob, 23 of 27.** Every glob that spelled an extension spelled it
`{js,ts}` — `**/+server.{js,ts}`, `**/params/*.{js,ts}`,
`**/hooks.{server,client}.{js,ts}`. `glob_matches` (overlay.rs:1120) handles
`*`, `**` and `?` and **nothing else**: a brace is matched as a literal brace.
Those 23 rules could never have fired, in any Pack vocabulary, ever. The
rewrite does not use globs for extensions at all — `path.stem` of
`+page.server.ts` is `+page.server`, which is exact and does not care whether
the file is JavaScript or TypeScript.

**The key, 6 rules dangling and 2 relation ends pointing nowhere.** Six rules
rendered `{path.route}`, which is not a Pack field, not one of the built-in
names `OverlayFact::field` resolves, and not an attribute any of those rules
computed — `render` returns `None` and the entity is dropped. Separately,
`sveltekit.action.member` sourced a `contains` at `sveltekit:file:{path}`,
a key no rule in the file ever minted, and `sveltekit.layout.file` addressed a
relation end `by_field path.dir`, which is a bare directory string and not a
canonical key at all.

**What only restated its input, 22 of 29.** Seven `sveltekit.file.*` rules and
`sveltekit.endpoint.file` minted one entity per file, keyed on the file, with no
relation to anything — `PageServer`, `LoaderModule`, `LayoutServer`,
`LayoutLoader`, `ErrorPage`, `HookModule`, `ParamMatcher`. The 14
`sveltekit.export.*` rules did the same for a declaration, keyed on
`{path}:{exported_name}`, again with no relation. Twenty-two entities that say
"this file exists" and "this name is declared" — which the Packs already said.

**What was one construct spelled twice, 16 of 29.** Eight constructs
(endpoint handler, page loader, layout loader, page actions, layout actions,
param matcher, hook handler, and the endpoint `handles` edge) each had a
`.function` rule and a `.variable` rule differing only in the `_context` kind.
Six of those pairs collapse here into one rule; the handler/loader/hook/matcher
pairs survive as pairs for a different reason, stated below.

29 rules become **17, all live.**

## What it states now

The route is the route directory: `sveltekit:route:{path.dir}`. Every file of a
SvelteKit route — `+page.svelte`, `+page.server.ts`, `+server.ts` — shares one
directory, so every rule below reaches the same route key from `path.dir`
without any Pack publishing a route.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which handler answers `POST /orders` | `definition.function` / `definition.variable` named for an HTTP method, `path.stem` = `+server` | `EndpointHandler`, `Route`, `Route -handles-> EndpointHandler` |
| what data this route loads, and whether it loads on the server | `definition.function` / `definition.variable` named `load`, `path.stem` in `+page`, `+page.server`, `+layout`, `+layout.server` | `Loader` (attribute `module` = the stem), `Loader -loads-> Route` |
| which route accepts form posts | `definition.variable` named `actions`, `path.stem` = `+page.server` | `Actions`, `Route -handles-> Actions` (method `POST`) |
| which named action `?/create` reaches | `definition.function` inside the `actions` declarator, reached by `fact_join_by_span` / `within` | `Action`, `Actions -contains-> Action` |
| what runs before every request | `definition.function` / `definition.variable` named `handle`, `handleError`, `handleFetch`, `handleValidationError`, `init`, `reroute`, `transport`, `path.stem` in `hooks`, `hooks.server`, `hooks.client` | `HookHandler`, `HookModule`, `HookModule -contains-> HookHandler` |
| where the matcher `[id=integer]` names is defined | `definition.function` / `definition.variable` named `match` under `**/params/*.*` | `ParamMatcher`, keyed `sveltekit:param-matcher:{path.stem}` — the name the route spells, not the file |
| what this route renders | `reference.svelte_component` in `**/+page.svelte` | `Page`, `Route`, `Component`, `Route -route_to_component-> Page`, `Page -renders-> Component` |
| what wraps every page below this directory | `reference.svelte_component` in `**/+layout.svelte` | `Layout`, `Component`, `Layout -layout_applies_to-> Route`, `Layout -renders-> Component` |
| which layouts wrap this page | the page's component tag joined `fact_join_by_path_ancestor` to a layout whose `path.dir` is an ancestor | `Layout -layout_applies_to-> Page` |
| which routes set `prerender`, `ssr`, `csr`, `trailingSlash`, `config`, `entries` | `definition.variable` so named in a `+page`/`+layout`/`+server` module | `RouteOption`, `Route -config-> RouteOption` |
| which files read a server-only secret or an app store | `import.module` whose specifier starts `$` (`$env/static/private`, `$app/state`, `$lib`) | `KitModule`, `KitFile`, `KitFile -depends_on-> KitModule` |
| which files import `redirect`, `error`, `fail`, `json` | `import.symbol` resolved external to `@sveltejs/kit`, with `external.member` present | `KitApi`, `KitFile`, `KitFile -depends_on-> KitApi` |
| where this route bails out — every `redirect(303, …)` and `error(404)` site | `call.function` resolved external to `@sveltejs/kit`, with `external.member` present | `ApiUse`, `KitApi`, `ApiUse -uses_api-> KitApi` |

Every canonical key a relation addresses is minted by a rule with the same
clauses that address it. `sveltekit:layout:{layout.path}` is minted in
`sveltekit.layout.ancestry` itself, under the same `**/+layout.svelte` glob that
`sveltekit.layout.renders` uses, so the ancestry edge cannot outrun the entity.
No rule relies on `Reference::Current`; both ends of every relation are explicit
canonical keys, so output order cannot misaddress one.

Two `field_present external.member` clauses are there for the wave-2 reason:
`external.member` is `segments.last()` and is absent for a bare
`import kit from '@sveltejs/kit'`, and an unresolvable attribute drops the
entity while the relation still renders its ends.

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
rules. The pairs that *did* collapse are the ones the old file had split by
path: one `load` rule instead of `+page` and `+layout` rules, one `actions` rule
instead of `+page` and `+layout`, one hook rule instead of per-file rules.

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
facts, so `sveltekit.action.member` answers for `.js` projects and not for
`.ts` ones, which is most SvelteKit projects.

Neither of the two cheaper options reaches it. A built-in name cannot:
`definition.name` is the name of a fact, and there is no fact. A
`fact_join_by_span` cannot: a join binds an existing fact by its span, and the
span of `create` is inside the declarator but carries no emission of any kind.
This is not a `field` on an existing kind — it is a missing template, the same
one `omega-javascript` already ships, and the fix is to port that pattern
(`pair`/`arrow_function`) into `omega-typescript`'s queries. It would pay for
itself well beyond SvelteKit: handler tables, reducer maps and route objects in
object literals are how a great deal of TypeScript declares its callables.

## Still to decide

**The route key is a directory, not a URL.** `next-js` keys its routes
`http:*:{normalized_file_route}`, which is the host's shared route namespace, so
an agent can ask "what serves `/orders/{}`" across frameworks.
`normalized_file_route` cannot be used here: `file_route` (overlay.rs:1065)
drops the file name only when its stem is one of `page`, `route`, `index`,
`layout`, `_index`, and SvelteKit spells them `+page`, `+page.server`,
`+layout`, `+layout.server`, `+server`. The stem is therefore kept, and
`+page.svelte` and `+page.server.ts` in one directory would produce two
different routes — the opposite of what the key is for. So this overlay keys on
`sveltekit:route:{path.dir}`, which is stable and shared by every file of the
route, and publishes the normalized directory as a `route` attribute. Adding
the five `+`-prefixed stems to `file_route`'s leaf list is a one-line host
change that would let SvelteKit join the shared `http:*:` namespace; it is a
change to `overlay.rs`, not to this asset, and is reported rather than made.

**A page with no components is not a Page.** `sveltekit.page.renders` is
anchored on `reference.svelte_component`, because that is the only fact the
Svelte Pack states by name for markup. A `+page.svelte` that renders plain HTML
emits no component tag and no `Page` entity — though its route is still minted
by whichever `+page.server.ts` or `+server.ts` sits beside it. The alternative
was a `data.file` rule, and that is deliberately not taken: see below.

**`data.file` is live at run time and dead to the audit.** `facts_of_surface`
(overlay.rs:1199) pushes a synthetic `OverlayFact::artifact(path)` of kind
`data.file` for every artifact, so the ten `data.file` rules this file used to
carry would in fact have matched — `overlay_audit.py` builds its kind set from
`packs/*/rules.json` alone and cannot see a fact the host synthesizes. They are
still dropped here, because every framework rewritten in waves 1 and 2 dropped
theirs and a per-file entity with no relation answers nothing either way. But
four assets still key rules to `data.file` — `omega-framework-astro`,
`omega-framework-blazor`, `omega-framework-nuxt`, `omega-framework-vue` — and
whoever rewrites them should be told that those rules are not dead in the way
the audit says. That belongs in `00-INDEX.md`, not here.
