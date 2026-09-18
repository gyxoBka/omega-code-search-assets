# omega-framework-astro

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **0 can match, 20 cannot.**

Selector: `framework:astro`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 3 |
| `Component` | 2 |
| `EndpointHandler` | 2 |
| `StaticPathGenerator` | 2 |
| `Page` | 1 |
| `Integration` | 1 |
| `ContentCollection` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `ComponentReference` | 1 |
| `PropsAccess` | 1 |
| `ParamsAccess` | 1 |
| `RequestAccess` | 1 |
| `UrlAccess` | 1 |
| `RedirectAccess` | 1 |
| `CookieAccess` | 1 |
| `LocalsAccess` | 1 |
| `SiteAccess` | 1 |
| `GeneratorAccess` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_context` | 9 |
| `handles` | 2 |
| `route_to_component` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `renders` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.ecmascript_root_member_context` | 9 | **no** |
| `data.file` | 3 | **no** |
| `definition.ecmascript_exported_function_context` | 2 | **no** |
| `definition.ecmascript_exported_variable_context` | 2 | **no** |
| `import.statement` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.astro_element` | 1 | **no** |
| `import.ecmascript_named_binding_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x20, `field_equals` x20, `path_glob` x17, `field_present` x4, `external_path_matches` x3, `field_in` x2, `fact_join_by_field` x1, `(join)` x1.

Fields read: `root`, `member`, `exported_name`, `source.start`, `name`, `module_source`.

Path globs: `**/*.astro`, `**/src/pages/**/*.{astro,js,ts,mjs,mts}`, `**/src/pages/**/*.astro`, `**/src/content.config.{js,ts,mjs,mts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `astro.page.route` | kind `data.file` |
| `astro.component.authored-file` | kind `data.file` |
| `astro.integration.import` | kind `import.statement` |
| `astro.content.config` | kind `data.file` |
| `astro.generic-api-call.astro` | kind `call.target_candidate` |
| `astro.generic-dependency.astro` | kind `import.target_candidate` |
| `astro.template.imported-component-render` | kind `data.astro_element`, `import.ecmascript_named_binding_context`; field `module_source`, `name` |
| `astro.context.props` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.params` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.request` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.url` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.redirect` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.cookies` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.locals` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.site` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.context.generator` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `astro.endpoint.export.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `astro.get-static-paths.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `astro.endpoint.export.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `astro.get-static-paths.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
