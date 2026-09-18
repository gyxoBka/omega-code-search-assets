# omega-framework-astro

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **20 match, 0 cannot.**

Selector: `framework:astro`. Maturity: `semantic-overlay-full`.
Packs read: `omega-astro` (the markup), `omega-javascript` and
`omega-typescript` (the frontmatter, which `omega-astro` injects as TypeScript,
and the `.js`/`.ts` files under `src/pages` and `src/middleware`).

`python pack-design/key_collisions.py astro` and
`python pack-design/dangling_ends.py astro` both report nothing.

## What was wrong with it

The file shipped 20 rules and **17 of them could not match any emission**; the
three the audit scored live were the `data.file` rules, which the audit itself
used to mis-report. Concretely:

| cause | rules | detail |
|---|---|---|
| a `*_context` kind from the pre-rewrite generator vocabulary | 13 | `reference.ecmascript_root_member_context` (9), `definition.ecmascript_exported_function_context` (2), `definition.ecmascript_exported_variable_context` (2) |
| a carrier kind the host never folded | 2 | `call.target_candidate`, `import.target_candidate` |
| a kind no Pack ever emitted under that name | 2 | `import.statement`, `data.astro_element` |
| fields no Pack publishes | 6 rules' worth | `root`, `member`, `exported_name`, `module_source`, `local_name` |
| `external_path_matches` against a scoped package | 3 | `@astrojs/` and `astro`, false for every input until the scoped-package and `qualifier` fixes landed |

Beyond the mechanical deaths, three design faults:

1. **Nine rules for one construct.** `astro.context.props`, `.params`,
   `.request`, `.url`, `.redirect`, `.cookies`, `.locals`, `.site`,
   `.generator` were nine copies of one rule differing only in a `member`
   literal, each minting its own entity kind (`PropsAccess`, `ParamsAccess`, …)
   whose canonical key was `{path}:{source.start}` — an entity named after its
   own offset. They are all gone, and not replaced: **no JavaScript or
   TypeScript Pack emits a member reference at all**, so `Astro.props` produces
   no fact. See "A field only the Pack can supply".
2. **Two rules that restated their input.** `astro.generic-api-call.astro`
   minted `ApiUse` at `{path}:{source.start}` and pointed a relation from it to
   itself; `astro.generic-dependency.astro` minted the constant key
   `astro:dependency:astro` and did the same. Neither said anything the
   detector does not already say.
3. **`Component` under two attribute sets.** `astro.component.authored-file`
   and `astro.page.route` both minted `astro:component:{path}` as `Component`,
   one with `role: authored_astro_component` and one with `role: page`. Only
   the first rule's attributes survive interning (brief 3g), so `role: page`
   was computed and discarded on every page. The hub is now one neutral
   `AstroComponent` with no role attribute, and *page* is stated by the
   `route_to_component` edge that points at it.

The Astro markup Pack was never read: `omega-astro` emits nine kinds —
component tags, hydration directives, slots, element ids, fragment links, page
resources, single-identifier interpolations — and the old file matched exactly
one of them, under a name (`data.astro_element`) the Pack does not use. Slots,
ids, in-page links and page assets were unanswerable.

The file is the same length, 20 rules, and answers a different set of
questions: 8 of the 20 are now markup rules that had no counterpart before.

## What it states now

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which files are Astro components | `data.file`, `**/*.astro` | `AstroComponent` at `astro:component:{path}` — the file hub every markup rule points at |
| which URL a page file serves | `data.file`, `**/src/pages/**/*.astro` | `Route` at `http:*:{route}`, `route_to_component` -> the component file |
| which function answers `POST /api/cart` | `definition.function` / `definition.variable` named `GET`…`ALL` under `src/pages` | `EndpointHandler`, `Route` at `http:{METHOD}:{route}`, `handles` |
| which function enumerates a dynamic route's params | `definition.function` / `definition.variable` named `getStaticPaths` under `src/pages` | `StaticPathGenerator`, `provides_paths` from the route |
| where the request middleware is | `definition.function` / `definition.variable` named `onRequest` under `src/middleware*` | `Middleware` at `astro:middleware:{path}` |
| which integrations and adapters the project enables | `import.module` whose name starts `@astrojs/`, in `astro.config.*` | `Integration` at `astro:integration:{package}`, `depends_on` from `AstroConfig` |
| where the config is | `data.file`, `**/astro.config.*` | `AstroConfig` at `astro:config:{path}` |
| which content collections exist, and where | `call.function defineCollection` + the host's `definition.container` | `ContentCollection` at `astro:collection:{name}`, `declares_collection` from `ContentConfig` |
| which components a page renders, and from which module | `reference.astro_component` joined to `binding.import_default` / `binding.import_symbol` on `definition.name` in the same path, `qualifier` present | `ComponentReference` carrying `module`, `renders` from the file |
| which components ship JavaScript | `reference.astro_hydration` | `HydratedComponent`, `hydrates` from the file |
| which frontmatter value the markup renders | `reference.astro_value` joined to `definition.variable` of the same name in the same path | `FrontmatterValue`, `renders_value` from the file |
| which slots a component declares | `definition.slot` | `Slot` at `astro:slot:{path}:{name}`, `declares_slot` |
| which slot a component fills | `reference.slot` | `SlotFill`, `fills_slot` |
| which element is `#main` | `definition.element_id` | `ElementAnchor` at `astro:element:{path}:{id}`, `declares_element` |
| where an in-page `href="#main"` points | `reference.element_id` | `links_to_element` -> the `ElementAnchor` |
| what a page loads (script, stylesheet, image, font) | `relation.depends` from `omega-astro`, gated to `**/*.astro` | `Asset` at `astro:asset:{url}`, `depends_on` |

Sixteen entity kinds, twelve relations, one kind per canonical key space.
`http:*:{normalized_file_route}` and `http:{definition.name}:{normalized_file_route}`
are minted as `Route`, the same kind omega-framework-next-js and
omega-framework-nuxt mint them as, so the shared route hub stays one entity
across Frameworks.

### Why `external_path_matches` is still not used

It is usable now — the JS/TS Packs publish `qualifier`, and a scoped package is
kept whole — but nothing here needs the *member*, only the package. For the one
rule that wants a package name, `import.module`'s own `definition.name` **is**
the specifier, unquoted, so `field_prefix definition.name @astrojs/` gives the
exact answer with no dependency on the resolved external environment. The
component-render rules take the brief's import join instead, and get the
specifier out of it as `imp.qualifier`, which `external.package` could not have
given them (a relative `../components/Card.astro` resolves to no package).

## A field only the Pack can supply

**omega-javascript / omega-typescript / omega-tsx, a member reference.** There
is no kind for `Astro.props`. `call.method` states `Astro.redirect(…)` by its
property alone (`redirect`), and a bare member expression produces nothing, so
*which Astro context does this component read* has no fact behind it. A span
join cannot reach it: there is no emission on either side to join. This is a
kind, not a field — `reference.member` with a `root` field, or the existing
`call.method` with a `root` field for the method half — and it is worth stating
because `Astro.props`, `ctx.locals`, `event.context` and `req.query` are the
same unanswered question in every JS framework overlay, not Astro's alone.

**omega-astro, `reference.astro_hydration`, the `directive` field.** The Pack
publishes `client:load` / `client:idle` / `client:visible` / `client:media` /
`client:only` as an **attribute**, and an attribute is write-only (brief 3a):
it can be compared to one literal and used for nothing else, so it cannot be a
canonical key, an entity attribute or a relation end. `client:only` means *this
component never renders on the server*, which is a different answer from
`client:visible`, and the overlay cannot state which one it is. The fix is one
line in `packs/omega-astro/rules.json` — move `directive` from `attributes` to
`fields` — the same bytes in a different map. I have not made it: it is a Pack
edit, and the rule is written against what the Pack emits today.

## Still to decide

- **The endpoint and `getStaticPaths` rules carry no framework gate.** Their
  only guards are the `**/src/pages/**` glob and the exported name. The brief
  recommends the `fact_join_by_field` on `import.module` as the *does this file
  use the framework at all* gate, and I deliberately left it off these four:
  an Astro endpoint commonly imports nothing but `import type { APIRoute } from
  'astro'`, and files that import nothing at all are legitimate, so the gate
  would delete real answers. `src/pages` plus an export named exactly `GET` is
  already narrow — Next's `pages/api` uses a default export, SvelteKit uses
  `+server.ts` — but a Nuxt or Vite project with a `src/pages` directory and a
  function called `GET` would be claimed. If that is measured in the wild, the
  gate goes on and the cost is endpoints with no imports.
- **`astro.frontmatter.render` joins only `definition.variable`.** A rendered
  `{Card}` that came from an import, not a `const`, is not stated. Covering it
  needs a second rule on `binding.import_default`, which is close to what
  `astro.component.render.default` already says for the tag spelling. Left at
  one rule until someone wants the import spelling of an interpolation.
- **`astro.page.asset` keys an `Asset` by the URL as written.** `/logo.svg` and
  `../assets/logo.svg` are two entities for one file. There is no path
  resolution in a canonical key template, so this is as far as it goes without
  a Pack that resolves the reference.
