# omega-framework-vite

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State as found (the diagnosis this rewrite acted on)

21 overlay rules, 4 detection rules. **0 can match, 21 cannot.**
After the rewrite: **8 overlay rules, 4 detection rules -- 8 live, 0 cannot match.**

Selector: `framework:vite`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `BuildSetting` | 8 |
| `BuildProject` | 2 |
| `Dependency` | 2 |
| `EnvironmentSetting` | 2 |
| `BuildTarget` | 1 |
| `BuildOutput` | 1 |
| `ApiUse` | 1 |
| `BasePath` | 1 |
| `BuildRoot` | 1 |
| `StaticDirectory` | 1 |
| `CacheDirectory` | 1 |
| `Alias` | 1 |
| `ProxyRoute` | 1 |
| `BuildInput` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 10 |
| `contains` | 2 |
| `uses_plugin` | 1 |
| `produces` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.ecmascript_call_nested_object_string_context` | 7 | **no** |
| `data.ecmascript_call_object_string_field_context` | 7 | **no** |
| `data.ecmascript_call_three_level_object_string_context` | 3 | **no** |
| `data.ecmascript_call_object_array_direct_call_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.ecmascript_call_object_string_array_item_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x49, `fact_kind` x21, `path_glob` x19, `field_present` x16, `external_path_matches` x2.

Fields read: `key`, `call_name`, `outer_key`, `value`, `middle_key`, `source.start`, `item_call_name`.

Path globs: `**/vite.config.*`, `**/vite.config.{js,ts,mjs,mts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `vite.config.direct-plugin-call` | kind `data.ecmascript_call_object_array_direct_call_context`; field `call_name`, `item_call_name`, `key` |
| `vite.config.build-outdir` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key`, `value` |
| `vite.generic-api-call.vite` | kind `call.target_candidate` |
| `vite.generic-dependency.vite` | kind `import.target_candidate` |
| `vite.config.base` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key` |
| `vite.config.root` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key` |
| `vite.config.publicdir` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key` |
| `vite.config.cachedir` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key` |
| `vite.config.build.assetsdir` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key` |
| `vite.config.build.sourcemap` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key` |
| `vite.config.server.host` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key` |
| `vite.config.server.origin` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key` |
| `vite.config.envdir` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key`, `value` |
| `vite.config.apptype` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key`, `value` |
| `vite.config.loglevel` | kind `data.ecmascript_call_object_string_field_context`; field `call_name`, `key`, `value` |
| `vite.config.envprefix-item` | kind `data.ecmascript_call_object_string_array_item_context`; field `call_name`, `key`, `value` |
| `vite.config.build.target` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key`, `value` |
| `vite.config.server.open` | kind `data.ecmascript_call_nested_object_string_context`; field `call_name`, `key`, `outer_key`, `value` |
| `vite.config.resolve.alias` | kind `data.ecmascript_call_three_level_object_string_context`; field `call_name`, `key`, `middle_key`, `outer_key`, `value` |
| `vite.config.server.proxy` | kind `data.ecmascript_call_three_level_object_string_context`; field `call_name`, `key`, `middle_key`, `outer_key`, `value` |
| `vite.config.rollup.input` | kind `data.ecmascript_call_three_level_object_string_context`; field `call_name`, `key`, `middle_key`, `outer_key`, `value` |

## What was wrong with it

**21 of 21 rules matched nothing.** The audit before the rewrite reported
`0 live, 21 cannot match`.

The whole file was written against one idea: that a Pack reads the shape of the
object literal passed to `defineConfig({...})` and publishes each config key as
a fact. Seven kinds encoded that shape by nesting depth, and no Pack has ever
emitted any of them:

| dead kind | rules | what it was supposed to say |
|---|---|---|
| `data.ecmascript_call_object_string_field_context` | 7 | a one-level key: `base`, `root`, `publicDir`, `cacheDir`, `envDir`, `appType`, `logLevel` |
| `data.ecmascript_call_nested_object_string_context` | 7 | a two-level key: `build.outDir`, `build.assetsDir`, `build.target`, `build.sourcemap`, `server.host`, `server.open`, `server.origin` |
| `data.ecmascript_call_three_level_object_string_context` | 3 | `resolve.alias`, `server.proxy`, `build.rollupOptions.input` |
| `data.ecmascript_call_object_array_direct_call_context` | 1 | a call item inside `plugins: [...]` |
| `data.ecmascript_call_object_string_array_item_context` | 1 | a string item inside `envPrefix: [...]` |
| `call.target_candidate` | 1 | a call to a Vite API |
| `import.target_candidate` | 1 | an import of `vite` |

That is 19 of the 21 rules keyed to a "call context" vocabulary that is one
language's spelling of an AST shape — exactly what §5 of the contract forbids —
and the remaining 2 keyed to carriers the host never folded.

Three further counts:

- **49 `field_equals` and 16 `field_present` clauses read 7 field names** —
  `key`, `outer_key`, `middle_key`, `value`, `call_name`, `item_call_name`,
  `source.start`. Six of the seven are published by no Pack in any language;
  only `source.start` is a built-in. omega-javascript, omega-typescript and
  omega-tsx publish **zero fields across all 45, 58 and 60 of their
  templates**, so a rule reading any field at all was dead on arrival.
- **11 of the 14 declared entity kinds existed only to name a config key** —
  `BuildSetting` (8 rules, one per key), plus `BasePath`, `BuildRoot`,
  `StaticDirectory`, `CacheDirectory`, `BuildTarget`, `BuildOutput`, `Alias`,
  `ProxyRoute`, `BuildInput` and `EnvironmentSetting`, one rule each, keyed by
  the value they had just read. That is the "entity that
  restates its input" the brief names: `vite:base-path:{path}:{value}` answers
  nothing that `value` did not already answer.
- **5 brace globs were already removed in wave 3.** This file was one of the
  nine that carried `**/vite.config.{js,ts,mjs,mts}`, which `glob_here` reads as
  five literal bytes and never matches; vite contributed 5 of that tally of 75.
  All 19 `path_glob` clauses in the file as it stood are `**/vite.config.*`, so
  the glob was not what killed them — the kind was, in all 21.

**The underlying fact, which is not going to change:** a Vite config is a
JavaScript object literal, and the JS/TS Packs emit a fact for an object key
**only when its value is a function** (`definition.method`, from the
`object_function` pattern). A key whose value is a string, a number, an array or
a nested object produces nothing. So `base`, `outDir`, `proxy` and `alias` are
not unreachable because the rules were written badly; they are unreachable
because nothing in the pipeline states them. Eighteen of the twenty-one rules
were asking a question the Packs cannot answer, and they are deleted rather than
ported.

## What it states now

**8 rules, all live.** 21 -> 8.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which file configures the Vite build | `call.function` named `defineConfig` under `**/vite.config.*` | `BuildProject vite:build:{path}` |
| Which packages the build configuration pulls in | `import.module` under `**/vite.config.*`, specifier not relative, absolute, `node:`-prefixed or a bare Node built-in | `Dependency vite:package:{name}`; `BuildProject depends_on Dependency` |
| Which plugins the build invokes | `call.function` under `**/vite.config.*` whose name is none of Vite's own config helpers and none of the Node path/url helpers | `BuildPlugin vite:plugin:{path}:{name}`; `BuildProject uses_plugin BuildPlugin` |
| Whether the build reads `.env` at config time | `call.function` named `loadEnv` under `**/vite.config.*` | `EnvironmentSetting vite:env:{path}`; `BuildProject configured_by EnvironmentSetting` |
| Which source modules belong to the build rather than the app | `import.module` named `vite`, `vite/client`, `vite/types`, `vite/module-runner`, `vite/dynamic-import-polyfill`, `vite-node`, `vite-node/client` | `BuildModule vite:module:{path}`; `Dependency vite:package:vite`; `BuildModule depends_on Dependency` |
| Which files drive Vite programmatically, through which API | `call.function` in Vite's programmatic API set, joined `fact_join_by_field` on `path` = `path` to an `import.module` named `vite` in the same file | `ApiUse vite:api:{name}`; `BuildModule uses_api ApiUse` |
| Which files implement a Vite plugin, and which hooks | `definition.method` named one of 23 Vite/Rollup plugin hooks | `PluginHook vite:hook:{path}:{name}`; `BuildPlugin vite:plugin-module:{path} contains PluginHook` |
| What the plugin factory a hook object is returned from is called | the same `definition.method`, plus `fact_join_by_span` `within` on `scope.function_body` bound as `factory` | `BuildPlugin vite:plugin-factory:{path}:{factory name}` contains `PluginHook` |

Three things the rewrite leans on that the old file never used:

- **`definition.name` is the whole answer for an import.** The specifier is the
  emission's own name, so no `value` field is needed for `depends_on`.
- **`path` is a joinable built-in.** `fact_join_by_field` with
  `current_field: path`, `join_field: path`, `same_path: true` against
  `import.module` is "this file imports X", and it costs no Pack field. That is
  what disambiguates a bare `build(...)` call from a local function of the same
  name.
- **`fact_join_by_span` / `within` on `scope.function_body`** gives a plugin
  hook the name of the factory that returns it, which is the name the config
  calls — the only cross-rule link Vite's source actually supports.

**Key audit.** Nine canonical keys are minted: `vite:build:{path}`,
`vite:package:{name}`, `vite:plugin:{path}:{name}`, `vite:env:{path}`,
`vite:module:{path}`, `vite:api:{name}`, `vite:hook:{path}:{name}`,
`vite:plugin-module:{path}`, `vite:plugin-factory:{path}:{factory}`. Every
relation end addresses one of those nine, and in every case the rule that
addresses a key also mints it, with the same clauses. No relation dangles. No
rule uses `Reference::Current`, so the first-output trap does not apply, and no
attribute reads `external.*`, so no entity can be dropped under a surviving
relation.

## A field only the Pack can supply

**Pack:** `omega-javascript` and `omega-typescript` (and `omega-tsx`).
**Kind:** `import.default` (omega-javascript) and `binding.import_default`
(omega-typescript / omega-tsx).
**Field:** `module` — the specifier the default binding came from.

`import react from '@vitejs/plugin-react'` followed by `plugins: [react()]` is
the single most-asked question about a Vite project: *which plugin packages does
this build use, by package name*. Today the overlay states the call
(`call.function react`) and the package (`import.module @vitejs/plugin-react`)
as two unrelated facts.

Neither of the two cheaper options reaches it:

- **No built-in name helps.** `external.package` is the intended route and is
  unavailable for JS/TS: `external_environment` registers a binding only when
  `target_hint` is set, `target_hint` is `occurrence.qualifier`, and neither JS
  Pack publishes a `qualifier` field or attribute. That is `OWED.md` item 7a,
  already recorded.
- **No join reaches it.** `import.module`'s `span_capture` is the source string
  (`import.module`), and `import.default`'s is the identifier
  (`import.default`). They are siblings under `import_statement`: neither span
  contains the other, so `fact_join_by_span` with `within` or `same` matches
  nothing. `fact_join_by_field` needs a field, which is the request itself.
  Joining on `path` only says "somewhere in this file", which for a config with
  five plugin imports is five wrong answers out of six.

There is precedent inside the same Pack: `omega-typescript`'s
`binding.import_alias` for `require()` already carries the specifier, as the
**attribute** `module`. The ask is that specifier, on the default and namespace
import bindings, **in `fields` rather than `attributes`** — an attribute is
write-only to the overlay (`OverlayFact::field` never consults `attributes`), so
the existing `module` and `target` attributes cannot be used for this either.
This is the same row as the `qualifier` finding in `00-INDEX.md`, widened: it is
not only external resolution that is blocked, it is every framework question of
the form *which package supplied this name*. react, vue, svelte, astro, nuxt and
webpack all hit it.

## Still to decide

1. **`vite.config.plugin-call` is a negative rule.** It claims that a bare
   function call in a `vite.config.*` file is a plugin unless it is on a
   30-name exclusion list of Vite config helpers and Node path/url helpers. It
   is right for `react()`, `vue()`, `tsconfigPaths()`; it will over-claim for a
   locally defined helper invoked in the config. The alternative was to require
   the call name to match a default or named import in the same file, which
   needs three rules (`import.default` for JS, `binding.import_default` for TS,
   `import.symbol` for both) and still does not name the package. The negative
   rule is one rule and answers the same question; the cost is a `candidate`
   confidence rather than `exact`. If the Pack field above lands, this rule
   should be replaced by a joined one.
2. **Which hook names count as evidence.** 23 hooks are listed. `load`,
   `transform`, `name`, `enforce`, `apply` and `options` are left out: as bare
   object keys they are common English and would claim any object literal with
   a `transform` method as a Vite plugin. `config` and `buildStart` are in, and
   are the weakest two on the list. Trimming or extending this list is a
   precision/recall call that wants real-corpus measurement, not argument.
3. **`import.meta.glob` is not claimed.** The Packs emit `call.method` named
   `glob`, with no way to see the receiver, so it is indistinguishable from
   `fg.glob()` or `fs.glob()`. A Vite project's glob imports are a real part of
   its module graph; stating them would need the Pack to name the receiver of a
   member call, which is a larger ask than the field above and is not made here.
