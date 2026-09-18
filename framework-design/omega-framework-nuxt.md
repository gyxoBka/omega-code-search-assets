# omega-framework-nuxt

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before the rewrite

18 overlay rules, 4 detection rules. **0 could match, 18 could not.**
After the rewrite: **15 overlay rules, 15 live, 0 dead.** Everything from
here to "What was wrong with it" describes the file that was replaced.

Selector: `framework:nuxt`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ServerRoute` | 2 |
| `ServerHandler` | 2 |
| `ModuleDependency` | 2 |
| `Page` | 1 |
| `Component` | 1 |
| `Route` | 1 |
| `Layout` | 1 |
| `Middleware` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `ServerMiddleware` | 1 |
| `Plugin` | 1 |
| `Composable` | 1 |
| `Module` | 1 |
| `RouteRule` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configures` | 2 |
| `handles` | 1 |
| `layout_applies_to` | 1 |
| `middleware_wraps` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.file` | 11 | **no** |
| `data.ecmascript_call_object_string_array_item_context` | 2 | **no** |
| `data.ecmascript_call_object_string_field_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `definition.ecmascript_exported_function_context` | 1 | **no** |
| `definition.ecmascript_exported_variable_context` | 1 | **no** |
| `data.ecmascript_call_object_array_direct_call_context` | 1 | **no** |
| `data.ecmascript_call_object_array_object_string_identifier_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x18, `path_glob` x15, `field_equals` x10, `field_present` x8, `fact_join_by_field` x2, `(join)` x2, `external_path_matches` x2.

Fields read: `call_name`, `key`, `value`, `source.start`, `exported_name`, `item_call_name`, `array_key`.

Path globs: `**/pages/**/*.vue`, `**/layouts/*.vue`, `**/middleware/*.*`, `**/server/{api,routes}/**/*.{js,ts,mjs,mts}`, `**/server/api/**/*.{js,ts,mjs,mts}`, `**/server/routes/**/*.{js,ts,mjs,mts}`, `**/server/middleware/**/*.{js,ts,mjs,mts}`, `**/plugins/**/*.{js,ts,mjs,mts}`, `**/composables/**/*.{js,ts,mjs,mts}`, `**/modules/**/*.{js,ts,mjs,mts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `nuxt.page.file` | kind `data.file` |
| `nuxt.layout.file` | kind `data.file` |
| `nuxt.middleware.file` | kind `data.file` |
| `nuxt.page.explicit_layout` | kind `data.ecmascript_call_object_string_field_context`, `data.file`; field `call_name`, `key`, `value` |
| `nuxt.page.explicit_middleware` | kind `data.ecmascript_call_object_string_array_item_context`, `data.file`; field `call_name`, `key`, `value` |
| `nuxt.generic-api-call.nuxt` | kind `call.target_candidate` |
| `nuxt.generic-dependency.nuxt` | kind `import.target_candidate` |
| `nuxt.file.server-api` | kind `data.file` |
| `nuxt.file.server-route` | kind `data.file` |
| `nuxt.file.server-middleware` | kind `data.file` |
| `nuxt.file.plugin` | kind `data.file` |
| `nuxt.file.composable` | kind `data.file` |
| `nuxt.file.module` | kind `data.file` |
| `nuxt.server.authored-export.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `nuxt.server.authored-export.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `nuxt.config.modules.ecmascript_call_object_string_array_item_context` | kind `data.ecmascript_call_object_string_array_item_context`; field `call_name`, `key`, `value` |
| `nuxt.config.modules.ecmascript_call_object_array_direct_call_context` | kind `data.ecmascript_call_object_array_direct_call_context`; field `call_name`, `item_call_name`, `key` |
| `nuxt.config.route-rules` | kind `data.ecmascript_call_object_array_object_string_identifier_context`; field `array_key`, `call_name` |

## What was wrong with it

**18 rules, 0 of which could match a fact any Pack emits.** The failure was not
uniform; it had four separate causes.

**11 of 18 rules were keyed to `data.file`** -- a whole-file assertion with no
syntax behind it. Page, Layout, Middleware, ServerRoute x2, ServerMiddleware,
Plugin, Composable, Module and the two `definePageMeta` joins all entered on it.
No Pack emits `data.file`; the host synthesises one per artifact
(`OverlayFact::artifact`, overlay.rs:39), which is why these once appeared to
work, but it is by construction outside the Pack vocabulary the audit and the
contract are written against. Each of the 11 is now entered on a fact the Packs
actually publish, and in every case that fact is a better witness than the
filename: a page is `scope.template_block` under `pages/`, a plugin is the
`defineNuxtPlugin()` call, a server handler is the `defineEventHandler()` call.

**5 rules read fields no Pack publishes.** `call_name`, `key`, `value`,
`item_call_name`, `array_key` and `exported_name` came from the old
`data.ecmascript_call_object_*_context` family -- one kind per shape of a
literal inside an object argument, five distinct kinds across these 5 rules.
omega-javascript and omega-typescript publish **no field on any of their
templates**, so those five rules could not be ported. They are deleted, and the
reason is recorded under *A field only the Pack can supply*.

**2 rules used `call.target_candidate` / `import.target_candidate` with
`external_path_matches`** -- a carrier the host never folds, plus a clause that
cannot fire for JavaScript at all: JS/TS facts carry no `external`, because the
Packs publish `target` and `module` rather than `qualifier` (`OWED.md` 7a). Both
are replaced by one rule on `import.module`, whose emitted *name is the module
specifier* and therefore needs nothing resolved.

**8 path globs contained a brace.** `**/server/{api,routes}/**/*.*`,
`**/plugins/**/*.{js,ts,mjs,mts}` and six more. `glob_here` implements only
`**`, `*` and `?`, so a brace is a literal byte and those clauses matched only a
path that literally ends in that text -- nothing. Where the extension list only
restated what the fact kind already implies (a `call.function` came from a JS or
TS file) it is dropped rather than rewritten; `{api,routes}` became two rules,
which is honest because Nitro mounts the two directories at different URLs.

**And 9 of the 18 rules emitted a bare entity with no relation at all** --
ServerRoute x2, ServerMiddleware, Plugin, Composable, Module, Layout, Middleware
and ServerHandler -- an entity keyed by the path it had just read, with that path
as its only attribute. That restates the input. Every entity in the new file is
either an end of a relation emitted in the same rule or the target of one
emitted by another rule here.

15 rules replace the 18: 6 relation kinds over 15 entity kinds, with **every
relation end minted by a rule in this file**. Checked key by key, the set of keys
addressed is contained in the set minted, and in all 15 rules both ends of every
relation are minted by the rule that emits it, so no end depends on another
rule's conditions.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which URL does this page serve? | `scope.template_block` under `**/pages/**/*.vue` (omega-vue) | `Route http:*:{normalized_file_route}` -`handles`-> `Page nuxt:page:{path}` |
| ...and the same page when it renders from script | `call.function definePageMeta` under `pages/` (omega-javascript / omega-typescript, injected into the SFC `<script>`) | the same `Route`, `Page`, `handles` |
| Which layouts exist, under the name a page addresses them by? | `scope.template_block` under `**/layouts/**/*.vue` | `Layout nuxt:layout:{path.stem}`; `NuxtApp` -`extends`-> it |
| Which route middleware exists? | `call.function defineNuxtRouteMiddleware` | `Middleware nuxt:middleware:{path.stem}`; `NuxtApp` -`extends`-> it |
| What runs while the app is being created? | `call.function defineNuxtPlugin` | `Plugin nuxt:plugin:{path}`; `NuxtApp` -`extends`-> it |
| Which parts of the app are generated rather than written? | `call.function defineNuxtModule` | `Module nuxt:module:{path}`; `NuxtApp` -`extends`-> it |
| Which file configures this app? | `call.function defineNuxtConfig` | `NuxtConfig nuxt:config:{path}` -`config`-> `NuxtApp nuxt:app` |
| Which handler answers `/api/orders`? | `call.function defineEventHandler` (and the lazy / cached / `eventHandler` spellings) under `**/server/api/**/*.*` | `ServerRoute http:*:/api{normalized_file_route}` -`handles`-> `ServerHandler nuxt:server-handler:{path}` |
| ...and the root-mounted ones | the same calls under `**/server/routes/**/*.*` | `ServerRoute http:*:{normalized_file_route}` -`handles`-> `ServerHandler` |
| What runs before every server route? | the same calls under `**/server/middleware/**/*.*` | `ServerMiddleware nuxt:server-middleware:{path}`; `NuxtApp` -`extends`-> it |
| Which composables does this project define? | `definition.function` under `**/composables/**/*.*` | `Composable nuxt:composable:{definition.name}` -- keyed by name, because the name is what Nuxt auto-imports |
| Who calls `useCart()`? | `call.function` joined by `definition.name` to a `definition.function` under `composables/` | `NuxtFile nuxt:file:{path}` -`depends_on`-> `Composable nuxt:composable:{name}` |
| Which auto-imported components exist? | `scope.template_block` under `**/components/**/*.vue` | `Component nuxt:component:{path}` |
| What does this page render? | `data.vue_element` (omega-vue: a tag that is capitalised or hyphenated) joined by tag name to a `components/` file stem | `NuxtFile nuxt:file:{path}` -`renders`-> `Component nuxt:component:{cmp.path}` |
| Which files are coupled to Nuxt's own API? | `import.module` named `nuxt`, `nuxt/kit`, `#imports`, `#app`, `h3`, ... | `NuxtFile` -`depends_on`-> `Dependency nuxt:dependency:{module}` |

`NuxtFile nuxt:file:{path}` is the hub every rule mints for its own artifact, so
from one file an agent reaches its Nuxt role, the components it renders, the
composables it calls and the framework packages it imports. `NuxtApp nuxt:app`
is the second hub: the plugins, modules, layouts, route middleware and server
middleware that extend the application, and the config that defines it.

The three questions the old file *claimed* to answer and could not -- which
layout a page names, which middleware wraps it, which modules `nuxt.config`
registers -- are now absent rather than dead. The reason is below.

## A field only the Pack can supply

**Pack:** `omega-javascript` and `omega-typescript` (and therefore omega-vue's
injected `<script>` blocks).
**Kind:** a new emission for a key/value pair of an object literal -- there is
no existing kind to hang a field on.
**Field:** the key, and the string value, of an object property.

Nuxt states four of its most-asked-about facts as string literals inside an
object argument:

    definePageMeta({ layout: 'admin', middleware: ['auth'] })
    defineNuxtConfig({ modules: ['@pinia/nuxt'], routeRules: { '/blog/**': { swr: 600 } } })

Neither of the two cheaper routes in the contract reaches them:

- **No built-in name.** `definition.name` of the `call.function` fact is
  `definePageMeta`; `path`, `path.stem` and `external.*` say nothing about the
  argument. The value is in the source text and nowhere in the fact.
- **No `fact_join_by_span`.** A span join relates two *facts*, and the Packs
  emit no fact at all for `layout: 'admin'`: omega-javascript emits an object
  property only when its value is a function (`object_function.name` ->
  `definition.method`). A string-valued property produces nothing to join to, at
  any span. This is the limitation wave 5 measured on omega-vite, where 18 of 21
  rules read a config scalar and every one was unreachable in principle.
- **Not an attribute problem.** There is nothing in `attributes` either; the
  emission does not exist.

So this is not a field on an existing kind but one new template per Pack --
something like `data.object_property` with fields `key` and `value`, spanned on
the property. It would pay for itself well beyond Nuxt: vite, webpack, astro,
next-js and every `defineX({ ... })` configuration DSL in the JavaScript
ecosystem are blocked on exactly this, which is why it belongs in `00-INDEX.md`
and `OWED.md` rather than in one framework's notes.

## Still to decide

1. **A page with neither `<template>` nor `definePageMeta`.** `nuxt.page` enters
   on the SFC's template block and `nuxt.page.meta` on the metadata call. A page
   that is pure `<script setup>` with a render function and no `definePageMeta`
   is stated by neither. The host's synthetic `data.file` would catch it, but it
   is outside the Pack vocabulary this rewrite is written against, so the gap is
   recorded rather than closed that way.
2. **Method-suffixed server files.** `server/api/users/[id].get.ts` keys to
   `/users/[id].get`: `file_route` splits the stem at the last dot, so
   `[id].get` stays one segment, and `normalize_http_path` leaves it literal
   because it does not end in `]`. The key is deterministic and names the right
   file, but the HTTP method Nuxt reads from that suffix is not separated out and
   the parameter is not normalised to `{}`. Separating it is a host change to
   `file_route`, not a rule.
3. **`nuxt.composable.use` joins on name alone.** Any call whose name matches a
   function declared under `composables/` produces the edge, whether or not the
   composable is exported and whether or not the call site is in its scope. That
   is precisely Nuxt's own auto-import resolution, so it is deliberate -- but it
   will also link a local helper that happens to share the name.
4. **`extends` as one relation kind.** Plugins, modules, layouts, route
   middleware and server middleware all hang off `NuxtApp` under it. Splitting it
   per role would make each edge self-describing; keeping it one makes "what
   extends this app" a single query. Kept as one, with the role carried by the
   target entity's kind.
