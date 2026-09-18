# omega-framework-next-js

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**20 overlay rules, 4 detection rules. All 20 match; 0 cannot.**
It was 43 rules, 0 of which could match.

Selector: `framework:next-js`. Maturity: `semantic-overlay-full`.
Packs it reads: `omega-javascript`, `omega-typescript`, `omega-tsx`.

### Fact kinds it matches

| kind | rules | who emits it |
|---|---|---|
| `definition.function` | 11 | javascript, typescript, tsx |
| `definition.variable` | 5 | javascript, typescript, tsx |
| `reference.jsx_component` | 1 | tsx |
| `reference.component` | 1 | javascript |
| `import.module` | 1 | all three |
| `call.function` | 1 | all three |

Clause vocabulary: `fact_kind` x20, `field_in` x21, `path_glob` x19,
`external_path_matches` x1, `fact_join_by_path_ancestor` x1, `field_not_in` x1
(the join's own `fact_kind`, `path_glob` and `field_in` are counted here too).
Fields read: only the built-ins — `path.stem` x15 and `definition.name` x7 in
match clauses, `path`, `path.dir`, `definition.name`, `path.stem`,
`external.member` and `source.start` in keys and attributes. **No Pack field at
all.**

---

## What was wrong with it

**All 43 rules were dead, and 20 of them were dead twice over.**

### 1. Every fact kind it named had been deleted (43 of 43)

| kind it matched | rules | no Pack emits it because |
|---|---|---|
| `data.file` | 20 | never a Pack fact; the host synthesises it, the Packs do not |
| `definition.ecmascript_exported_variable_context` | 13 | the ECMAScript Packs now emit `definition.variable` |
| `definition.ecmascript_exported_function_context` | 6 | now `definition.function` |
| `data.ecmascript_module_directive_context` | 4 | deleted outright; nothing replaced it |
| `call.target_candidate` | 1 | now `call.function` |
| `import.target_candidate` | 1 | now `import.module` |
| `data.ecmascript_function_directive_context` | 1 | deleted outright; nothing replaced it |

Four fields went with them — `exported_name`, `directive`, `owner_function`,
and `source.start` used as a proxy for "this is a real emission". Of those,
`exported_name` is `definition.name`, `owner_function` is what a
`fact_join_by_span` `within` a `scope.function_body` answers, and `directive`
has no replacement at all (see *A fact only the Pack can supply*).

### 2. Every path glob in the file used brace alternation, which the host does not implement

All 39 `path_glob` patterns were of the form `**/app/**/page.{js,jsx,ts,tsx}`.
`glob_here` (overlay.rs:1131) implements `*`, `**` and `?` and nothing else, so
`{` and `}` are matched as literal bytes. **No Next.js file has ever matched any
of these globs**, and no `normalized_file_route` has ever been derived, because
`file_route` is only computed when the glob matches. The audit cannot see this —
it reads kinds and fields, not glob syntax — so the 20 `data.file` rules were
counted dead once when they were dead twice.

The replacement is `path_glob: "**/app/**/*.*"` plus
`field_in` over the built-in `path.stem`. That is strictly better than the brace
form even if braces worked: one glob and one `field_in` states six reserved file
names in one rule where the old file spent six.

### 3. One rule per language spelling of one construct (19 rules collapsed to 6)

`next.metadata.metadata.function` / `.variable`, `viewport.function` /
`.variable`, `generateMetadata.*`, `generateViewport.*` — eight rules that
differ only in a name and in which of two dead `*_exported_*_context` kinds
they matched. They are now two rules (`definition.function`,
`definition.variable`) with a five-value `field_in`. The seven
`next.route-segment-config.*` rules are now one: every one of `dynamic`,
`revalidate`, `runtime` and the rest is an `export const`, so
`definition.variable` states all seven. The eleven `next.special.*` file rules
are now three, keyed by `path.stem`.

The two spellings that did **not** collapse are `definition.function` and
`definition.variable`: `export function Page()` and `export const Page = () =>`
are the same construct to a reader, but omega-javascript folds the arrow binding
into `definition.function` while omega-typescript and omega-tsx state it as
`definition.variable`. That split is real, so page, layout and route-handler
each keep two rules.

### 4. Rules that restated their input, or pointed at nothing

- `next-js.generic-api-call.next` emitted an `ApiUse` entity and then a
  `uses_api` relation from `current` — that is, from the `ApiUse` entity — to
  the same canonical key. A self-loop is not an answer. It now runs from a
  `NextFile` to the `ApiUse`, so *which files call into Next.js* resolves.
  `next-js.generic-dependency.next` had the identical self-loop.
- `next.app.layout_hierarchy` emitted **three** relations (`layout_of`,
  `contains`, `renders`) over the same source/target pair. One edge, stated
  once, is now `layout_of`.
- That same rule joined the layout by `path` and asked whether it was a path
  ancestor of the page. `is_path_ancestor("app/layout.tsx", "app/blog/page.tsx")`
  is false: a file is never a directory prefix. The join now uses the built-in
  `path.dir`, which is what "the segment this layout governs" actually means.
- Fourteen rules (`ClientBoundary`, `ServerBoundary`, three `ServerAction`
  spellings, and the nine `Metadata`/`RouteSegmentConfig` rules that read
  `exported_name`) minted an entity whose whole content was its own file path
  and its own name, with no relation to anything. The nine that had a real
  question behind them now hang off the route segment they configure; the five
  directive rules are deleted, because the fact is gone.

### 5. A relation with no source

`next.route-handler.exported-http-method` emitted `handles` from
`next:route-handler:{normalized_file_route}`. Only `next.app.route_handler`
minted that key — and it was a `data.file` rule with a brace glob, so it minted
nothing, ever. Each handler rule now mints the route it is handled by, in the
same rule, under a method-scoped key.

---

## What it states now

Every rule reads only built-in fact names. `{route}` below is
`normalized_file_route` / `normalized_pages_route`, the URL the host derives
from the artifact path under the glob's routing root — route groups `(x)`
dropped, `[id]`, `:id` and `{id}` normalized to one spelling.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which URL does this app-router directory serve, and which module serves it | `definition.function` in `**/app/**/*.*`, `path.stem` = `page` | `Route http:*:{route}`, `Page next:page:{route}`, `RouteSegment next:segment:{path.dir}`; `route_to_component` Route→Page; `contains` Segment→Page |
| the same when the component is a named binding (`const Page = () =>`) | `definition.variable`, same glob and stem | the same three entities and two relations |
| where is the layout for this segment | `definition.function` / `definition.variable`, `path.stem` = `layout` | `Layout next:layout:{path}`; `contains` Segment→Layout |
| which layouts wrap this page | `definition.function` in a `page.*`, joined `fact_join_by_path_ancestor` to a `definition.function` whose `path.dir` is an ancestor and whose `path.stem` is `layout` | `layout_of` Layout→Page — every ancestor layout, which is how the App Router nests them |
| which handler answers `POST /api/orders` | `definition.function` / `definition.variable` in a `route.*`, `definition.name` in the seven HTTP methods | `Route http:POST:{route}`, `RouteHandler next:handler:{path}:POST`; `handles` Route→RouteHandler |
| what is the loading / error / not-found / template / default UI of this segment | `definition.function`, `path.stem` in those six | `AppFile next:app-file:{path}` with `role` = the stem; `contains` Segment→AppFile |
| does this segment generate a sitemap, robots or manifest route | `definition.function`, `path.stem` in those three | `MetadataRoute next:metadata-route:{path}`; `contains` Segment→MetadataRoute |
| does this segment generate an icon, apple-icon, opengraph or twitter image | `definition.function`, `path.stem` in those four | `MetadataAsset next:metadata-asset:{path}`; `contains` Segment→MetadataAsset |
| what metadata does this segment declare | `definition.function` / `definition.variable` under `app/`, `definition.name` in `metadata`, `viewport`, `generateMetadata`, `generateViewport`, `generateImageMetadata` | `Metadata next:metadata:{path}:{name}`; `contains` Segment→Metadata |
| how is this segment rendered — dynamic, revalidate, runtime, maxDuration | `definition.variable` under `app/`, `definition.name` in the eight segment options | `RouteSegmentConfig next:route-segment-config:{path}:{name}`; `config` Segment→Config |
| what does this segment file render | `reference.jsx_component` (tsx) or `reference.component` (javascript/jsx) in a reserved segment file | `Component next:component:{name}`; `renders` Segment→Component |
| which URL does this pages-router file serve | `definition.function` in `**/pages/**/*.*`, `path.stem` not `_app`/`_document`/`_error`/`_middleware` | `Route http:*:{route}`, `Page next:page:{route}`; `route_to_component` Route→Page |
| does this pages route render per request, at build, or on the client | `definition.function` under `pages/`, `definition.name` in `getServerSideProps`, `getStaticProps`, `getStaticPaths`, `getInitialProps` | `DataFetching next:data-fetching:{path}:{name}`; `handles` Route→DataFetching |
| where is the request middleware | `definition.function` in `**/middleware.*` | `Middleware next:middleware:{path}` |
| which files depend on which part of Next.js | `import.module` whose `definition.name` is one of 21 `next/*` specifiers | `NextFile next:file:{path}`, `NextModule next-js:module:{specifier}`; `depends_on` File→Module |
| which files call a Next.js API, and which one | `call.function` whose resolved `external.package` is `next` | `NextFile`, `ApiUse next-js:api-use:{path}:{start}` carrying `api` and the `next/*` submodule; `uses_api` File→ApiUse |

### Every relation end is minted

Checked by running the program (20 rules parsed, `complete: true`) over a
synthetic App Router + Pages Router fact set: 23 entities, 18 relations, **zero
relation ends addressing a key no rule mints**. The rule that could have
dangled is `renders`, whose source is `next:segment:{path.dir}` — so both
`renders` rules mint that segment themselves rather than trusting the page,
layout and special-file rules to have fired first.

---

## A fact only the Pack can supply

**Pack:** `omega-javascript`, `omega-typescript`, `omega-tsx`.
**Kind:** none — the fact does not exist under any name.
**What is missing:** the module and function directives `"use client"` and
`"use server"`.

This killed five rules with no replacement: `next.module.use-client`,
`next.module.use-server`, and the three `next.server-action.*` rules. It is the
one thing the overlay used to state that it now cannot, and it is the single
most-asked question about a Next.js codebase — *is this a Server Component or a
Client Component, and which functions are Server Actions.*

Neither of the first two options in the brief reaches it:

- **No built-in name.** A directive is an `expression_statement` holding a
  string literal, at the top of a `program` or of a `statement_block`. It is not
  a declaration, so it has no `definition.name`; no fact is emitted for it at
  all, so there is nothing whose `path`, `path.stem` or `source.start` could
  carry it. `path.stem` cannot help either: `"use client"` is a property of the
  module's first statement, not of its file name.
- **No join.** `fact_join_by_span` relates one emitted fact to another emitted
  fact. There is no fact on either side of this join to bind.

What is wanted is a **fact, not a field** — which is the cheaper of the two,
because it costs nothing on any other emission:

```
(program . (expression_statement (string (string_fragment) @directive.module)))
    -> output_kind "directive.module", name = @directive.module
(statement_block . (expression_statement (string (string_fragment) @directive.function)))
    -> output_kind "directive.function", name = @directive.function
```

With the directive text as the emission's **name**, a rule reads it as the
built-in `definition.name` and needs no published field. The function case then
needs no `owner_function` field either: `directive.function` lies inside the
`scope.function_body` the Pack already emits, so `fact_join_by_span` with
`within` names the owning function. Both halves of the old design become
reachable with one new fact kind and no new field.

### A second, smaller one: export-ness

`module.export` exists in all three Packs, but in omega-typescript and
omega-tsx it is emitted only for `export_specifier`, `namespace_export` and
`export default <identifier>` — not for `export function GET() {}` or
`export const metadata = {}`, which are the spellings Next.js actually uses.
So *is this declaration exported* is unanswerable for the dominant form, and
this overlay identifies a page, a handler and a metadata export by **file plus
name** instead. That is right often enough to be useful and wrong for a local
helper that happens to be called `GET`.

The fix is again a query, not a field: add
`(export_statement declaration: (_ name: (identifier) @export.name)))` to the
existing `module.export` template, spanned on the name, so a framework can
`fact_join_by_span` `same` from the declaration to its export. Reported, not
acted on.

---

## Still to decide

1. **`next:segment:{path.dir}` is the hub of this file and it is a directory,
   not a route.** `app/(marketing)/about` and `app/about` are the same URL and
   two different segments. That is deliberate — a segment is where the files
   live and a route is where the request goes, and the `Route` entity carries
   the URL — but if a consumer wants "everything that configures `/about`" it
   must go Route → Page → ... → Segment rather than reading it off one key. If
   that turns out to be the common question, the segment should be keyed by
   `{normalized_file_route}` instead, at the cost of losing the group
   directories.

2. **`next.middleware` matches `**/middleware.*` anywhere.** Next.js only
   honours `middleware.ts` at the project root or under `src/`, but the overlay
   has no notion of a project root, so a `src/lib/middleware.ts` helper is
   stated as the app's middleware. Tightening it means two rules with literal
   globs (`middleware.*`, `src/middleware.*`), which is a false-negative risk in
   monorepos. Left broad, with `file` on the entity so a consumer can judge.

3. **`next.pages.route` mints a `Route` for every `definition.function` in
   `pages/`,** including a file that exports only helpers. A pages-router file
   that is reachable at a URL is exactly a file under `pages/`, so this is
   right by the framework's own rule — but it means a `pages/utils/format.ts`
   that should not be there is stated as `/utils/format`. No Pack fact
   distinguishes them.

4. **Anonymous default exports are invisible.** `export default () => <div/>`
   declares no name, so neither omega-javascript nor omega-typescript emits a
   definition, and a `page.tsx` written only that way produces no `Page`, no
   `Route` and no segment. Rare in App Router code, common enough in small
   components. Nothing but a Pack change reaches it, and it is not worth one.
