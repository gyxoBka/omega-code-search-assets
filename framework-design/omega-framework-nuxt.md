# omega-framework-nuxt

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before the rewrite

18 overlay rules, 4 detection rules. **0 could match, 18 could not.**
After the first rewrite: **15 overlay rules, 15 live, 0 dead** -- but one of
the fifteen was computing an entity the host threw away. After the key-collision
pass: **15 overlay rules, 15 live, 0 dead, 0 key collisions.** After this pass,
which restores the eleven file-shaped rules the first rewrite deleted on a false
premise: **26 overlay rules, 26 live, 0 dead, 0 key collisions.** Everything
from here to "What was wrong with it" describes the file that was replaced.

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
| `data.file` | 11 | not a Pack -- the host synthesises one per artifact |
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

**11 of 18 rules were keyed to `data.file`** -- Page, Layout, Middleware,
ServerRoute x2, ServerMiddleware, Plugin, Composable, Module and the two
`definePageMeta` joins all entered on it. They were re-entered on a fact the
Packs publish -- a page as `scope.template_block` under `pages/`, a plugin as
the `defineNuxtPlugin()` call, a server handler as the `defineEventHandler()`
call -- **on a premise that was wrong.** `data.file` is real: the host pushes one
per artifact with field `path` before any Pack emission
(`OverlayFact::artifact`, overlay.rs:41), and `path.dir`, `path.stem` and
`normalized_file_route` all work on it. It is the only way to address the file
itself, and `overlay_audit.py` reported it dead because the audit built its kind
set from `packs/*/rules.json` alone. That is fixed.

A declaration inside the file is a better witness **when there is one**. Where
there is not -- a `pages/about.vue` that is markup with no `definePageMeta`, a
server file whose handler is not one of the five named calls, a script-only
`components/*.vue` -- the file produced no entity at all, and Nuxt is a framework
whose whole subject is the file tree.

**This pass closes that: 11 file-shaped rules are back**, one for each of the
eleven the first rewrite deleted, and the file goes from 15 rules to 26. They are
`nuxt.page.file`, `nuxt.layout.file`, `nuxt.middleware.file`,
`nuxt.component.file`, `nuxt.composable.file`, `nuxt.plugin.file`,
`nuxt.module.file`, `nuxt.config.file`, `nuxt.server.api.file`,
`nuxt.server.route.file` and `nuxt.server.middleware.file`. Every one enters on
`data.file`, is gated by a `path_glob` over the artifact path, and uses
`{normalized_file_route}`, `{path}` or `{path.stem}` in its key exactly as the
deleted rules did. Nothing was removed to make room: all 15 declaration-entered
rules are untouched, so a page is stated twice and interned once.

Three things were fixed while restoring them, none of which the old file got
right:

- **The old keys were not the new keys.** The deleted rules keyed pages on
  `nuxt:route:{path.route}` and `nuxt:page:{path.route}` -- `path.route` is not a
  placeholder `resolve_placeholder` serves, so those keys rendered nothing -- and
  server files on `nuxt:server-api:{path}` / `nuxt:server-route:{path}`, a key
  space no rule in the current file addresses. Each restored rule mints **the
  same key template, the same entity kind and the same attribute set** as its
  declaration-entered twin: `nuxt.page.file` mints exactly what `nuxt.page`
  mints, `nuxt.server.api.file` exactly what `nuxt.server.api` mints. So a page
  recognised by its `<template>` block and the same page recognised by its path
  are one `Page` and one `Route`, not two.
- **The richer rule gets the shorter id.** The host interns with `or_insert` and
  sorts candidates by `rule_id`, so the first rule by id keeps its kind *and* its
  attributes. Every declaration rule's id is a prefix of its file rule's
  (`nuxt.page` / `nuxt.page.file`, `nuxt.server.api` / `nuxt.server.api.file`,
  `nuxt.composable.declaration` / `nuxt.composable.file`), so the declaration
  rule always sorts first. Since the two agree on kind and attributes anyway,
  this is belt and braces rather than the load-bearing part.
- **The old globs carried braces.** `**/server/api/**/*.{js,ts,mjs,mts}` and six
  more matched only a path that literally ends in that text. The restored globs
  are `*.*`, or `*.vue` where the file must be an SFC.

Two of the eleven needed a clause the deleted version did not have.
`nuxt.middleware.file` carries `path_segment exclude: ["server"]`, because
`**/middleware/*.*` also matches `server/middleware/auth.ts`, which is Nitro's
and already has its own rule -- the old `nuxt.middleware.file` claimed those
files as route middleware. `nuxt.composable.file` carries
`field_not_in path.stem: ["index"]`, because `composables/index.ts` names no
composable.

next-js and sveltekit lost 20 and 10 rules the same way and are separate items.

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

**And the rewrite that fixed those four introduced a fifth: two kinds on one
key template.** `nuxt.page` and `nuxt.page.meta` minted `Route` on
`http:*:{normalized_file_route}`; `nuxt.server.route` minted `ServerRoute` on
the same template. A canonical key holds exactly one entity and the first rule
by id wins with its kind *and* its attributes, so `nuxt.page` sorted first and
**1 of 15 rules had its principal entity output computed and discarded** --
every Nitro root-mounted route that spelled the same URL as a page lost its
`ServerRoute`, its `role` and its `file`. The same key space is minted as
`Route` by `astro.page.route` and by `next.app.page`, and interning is global
across every overlay in a run, so this was never a Nuxt-local disagreement: it
was three Frameworks agreeing on one kind for the URL space and one rule
dissenting.

The fix is remedy 1 of brief §3g -- **one neutral kind per key space, with the
classification in the relations**. All three of this file's `http:*:` templates
(`{normalized_file_route}` for pages and for `server/routes`,
`/api{normalized_file_route}` for `server/api`) now mint `Route`, and what
serves that URL is read off the `handles` edge: a `Route` that handles a `Page`
is rendered by vue-router, a `Route` that handles a `ServerHandler` is served
by Nitro. `ServerRoute` is gone from `emits.entities`; nothing else in the file
addressed it. The `router` / `runtime` attributes (`pages` + `vue-router`,
`server/routes` + `nitro`, `server/api` + `nitro`) are kept for the ordinary
case where one URL has one source, but they are *not* where the answer lives --
per §3g an attribute collides exactly as a kind does, so the relation is the
carrier. A URL that a page and a server route both spell is now one `Route`
with two `handles` edges, which is what Nuxt actually builds.

`python pack-design/key_collisions.py nuxt` reports nothing.

15 rules replace the 18: 6 relation kinds over 14 entity kinds, with **every
relation end minted by a rule in this file**. Checked key by key, the set of keys
addressed is contained in the set minted, and in all 15 rules both ends of every
relation are minted by the rule that emits it, so no end depends on another
rule's conditions.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which URL does this page serve? | `scope.template_block` under `**/pages/**/*.vue` (omega-vue) | `Route http:*:{normalized_file_route}` -`handles`-> `Page nuxt:page:{path}` |
| ...and the same page when it renders from script | `call.function definePageMeta` under `pages/` (omega-javascript / omega-typescript, injected into the SFC `<script>`) | the same `Route`, `Page`, `handles` |
| ...and the same page when nothing inside it says so | `data.file` (host-synthesized, one per artifact) under `**/pages/**/*.vue` | the same `Route`, `Page`, `handles` -- `nuxt.page.file` |
| Which layouts exist, under the name a page addresses them by? | `scope.template_block` under `**/layouts/**/*.vue` | `Layout nuxt:layout:{path.stem}`; `NuxtApp` -`extends`-> it |
| ...including a layout that is pure markup | `data.file` under `**/layouts/**/*.vue` | the same `Layout`, `extends` -- `nuxt.layout.file` |
| Which route middleware exists? | `call.function defineNuxtRouteMiddleware` | `Middleware nuxt:middleware:{path.stem}`; `NuxtApp` -`extends`-> it |
| ...including the file Nuxt registers by placement alone | `data.file` under `**/middleware/*.*`, excluding paths with a `server` segment | the same `Middleware`, `extends` -- `nuxt.middleware.file` |
| What runs while the app is being created? | `call.function defineNuxtPlugin` | `Plugin nuxt:plugin:{path}`; `NuxtApp` -`extends`-> it |
| ...including a plugin that exports a plain function | `data.file` under `**/plugins/**/*.*` | the same `Plugin`, `extends` -- `nuxt.plugin.file` |
| Which parts of the app are generated rather than written? | `call.function defineNuxtModule` | `Module nuxt:module:{path}`; `NuxtApp` -`extends`-> it |
| ...including a local module Nuxt loads by directory | `data.file` under `**/modules/**/*.*` | the same `Module`, `extends` -- `nuxt.module.file` |
| Which file configures this app? | `call.function defineNuxtConfig` | `NuxtConfig nuxt:config:{path}` -`config`-> `NuxtApp nuxt:app` |
| ...including a config exported directly | `data.file` matching `**/nuxt.config.*` | the same `NuxtConfig`, `config` -- `nuxt.config.file` |
| Which handler answers `/api/orders`? | `call.function defineEventHandler` (and the lazy / cached / `eventHandler` spellings) under `**/server/api/**/*.*` | `Route http:*:/api{normalized_file_route}` -`handles`-> `ServerHandler nuxt:server-handler:{path}` |
| ...and the root-mounted ones | the same calls under `**/server/routes/**/*.*` | `Route http:*:{normalized_file_route}` -`handles`-> `ServerHandler` |
| ...and either of them when the default export is a bare function | `data.file` under `**/server/api/**/*.*` and `**/server/routes/**/*.*` | the same `Route`, `ServerHandler`, `handles` -- `nuxt.server.api.file`, `nuxt.server.route.file` |
| Is this URL served by Nitro or rendered by a page? | -- | the kind at the far end of `handles`: `ServerHandler` means Nitro, `Page` means vue-router. One kind, `Route`, in the whole `http:*:` key space |
| What runs before every server route? | the same calls under `**/server/middleware/**/*.*` | `ServerMiddleware nuxt:server-middleware:{path}`; `NuxtApp` -`extends`-> it |
| ...including one Nitro registers by placement | `data.file` under `**/server/middleware/**/*.*` | the same `ServerMiddleware`, `extends` -- `nuxt.server.middleware.file` |
| Which composables does this project define? | `definition.function` under `**/composables/**/*.*` | `Composable nuxt:composable:{definition.name}` -- keyed by name, because the name is what Nuxt auto-imports |
| ...including one whose default export is anonymous | `data.file` under `**/composables/**/*.*`, stem not `index` | `Composable nuxt:composable:{path.stem}` -- the same key space, because the stem is the auto-import name -- `nuxt.composable.file` |
| Who calls `useCart()`? | `call.function` joined by `definition.name` to a `definition.function` under `composables/` | `NuxtFile nuxt:file:{path}` -`depends_on`-> `Composable nuxt:composable:{name}` |
| Which auto-imported components exist? | `scope.template_block` under `**/components/**/*.vue` | `Component nuxt:component:{path}` |
| ...including a script-only SFC with no template | `data.file` under `**/components/**/*.vue` | the same `Component nuxt:component:{path}` -- `nuxt.component.file` |
| What does this page render? | `data.vue_element` (omega-vue: a tag that is capitalised or hyphenated) joined by tag name to a `components/` file stem | `NuxtFile nuxt:file:{path}` -`renders`-> `Component nuxt:component:{cmp.path}` |
| Which files are coupled to Nuxt's own API? | `import.module` named `nuxt`, `nuxt/kit`, `#imports`, `#app`, `h3`, ... | `NuxtFile` -`depends_on`-> `Dependency nuxt:dependency:{module}` |

The eleven `data.file` rows are not extra answers; they are the same answers
reached from the file tree when nothing inside the file states them. Each mints
the key, kind and attributes of the declaration-entered rule beside it, so the
graph gains coverage and no new entities.

`NuxtFile nuxt:file:{path}` is the hub every rule mints for its own artifact, so
from one file an agent reaches its Nuxt role, the components it renders, the
composables it calls and the framework packages it imports. `NuxtApp nuxt:app`
is the second hub: the plugins, modules, layouts, route middleware and server
middleware that extend the application, and the config that defines it.
`Route http:*:...` is the third, and it is not this Framework's: astro and
next-js mint the same kind on the same template, so a question about a URL
crosses Frameworks, and nothing in this file may dissent about what lives
there.

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

1. ~~**A page with neither `<template>` nor `definePageMeta`.**~~ **Closed.**
   `nuxt.page.file` catches it. The premise that `data.file` was outside the
   vocabulary was wrong: the host pushes it per artifact at `overlay.rs:41` and
   the audit now scores it live. The same correction closed the equivalent gap
   for layouts, components, composables, plugins, modules, the config and all
   three `server/` directories.

   What remains open is the reverse risk the file rules carry: a directory name
   is weaker evidence than a declaration. `plugins/`, `modules/`,
   `composables/`, `components/` and `middleware/` are ordinary directory names
   that a non-Nuxt project in the same repository may also use, and the overlay
   has no clause for *this subtree is the Nuxt srcDir*. The rules are gated only
   by the glob, so a Vite `plugins/` directory beside a Nuxt app contributes
   `Plugin` entities. This is accepted as the same trade the framework's own
   convention makes -- Nuxt registers by directory too -- and it is bounded by
   the detector: the overlay runs only where `framework:nuxt` was detected.

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
5. **`Route` for Nitro, rather than a `nitro:` key space.** Remedy 2 of §3g --
   `nuxt:server-route:{normalized_file_route}` -- would have kept the
   `ServerRoute` kind and its own attribute set, and would have been separately
   addressable. It was rejected because the value of `http:*:` is that it is the
   one key space in which *which route serves this path* is asked, across every
   routing Framework; moving Nitro out of it would make `/api/orders`
   unanswerable from the URL side, and Nitro routes are exactly the ones an
   agent asks that about. The cost is that when a page and a server route spell
   the same URL, one `Route` entity carries the earlier rule's `router` and
   `runtime` attributes for both. That is inherent to interning, not to this
   choice, and the `handles` edges -- which are not interned -- both survive and
   both name their handler.
6. **`http:*:/api{normalized_file_route}` can still render a page's key.** A
   file at `pages/api/orders.vue` renders `http:*:/api/orders`, the same string
   `server/api/orders.ts` renders. Both are now `Route`, so nothing is dropped
   and both `handles` edges stand; but it is worth knowing that the two
   templates are not disjoint even though `key_collisions.py`, which compares
   template text, cannot see it.
7. **Whether the file rules should carry a weaker `confidence`.** They are
   published `exact`, like their declaration-entered twins, because Nuxt's
   registration really is by path. But the evidence is strictly weaker, and
   since the two rules mint one interned entity the distinction would be lost
   anyway: the declaration rule sorts first and its `exact` is what survives.
   Left as `exact` rather than publishing a value that cannot be read back.

8. **`nuxt:composable:{path.stem}` and `nuxt:composable:{definition.name}` are
   two templates in one key space.** `key_collisions.py` compares template text
   and cannot see that they meet, and for the conventional
   `composables/useCart.ts` exporting `useCart` they render the same string and
   the same kind, which is what is wanted. Where they differ -- a file exporting
   several composables, or a stem that is not a function name -- the extra
   `Composable` is keyed by the stem and is reachable from its file by the
   `contains` edge, but `nuxt.composable.use` will not point at it, because that
   rule resolves a call against declared names. Deliberate: Nuxt's own
   auto-import resolves the declared name first.
