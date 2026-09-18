# omega-framework-next-js

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

43 overlay rules, 4 detection rules. **0 can match, 43 cannot.**

Selector: `framework:next-js`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Metadata` | 8 |
| `RouteSegmentConfig` | 7 |
| `MetadataAsset` | 4 |
| `Component` | 3 |
| `MetadataRoute` | 3 |
| `ServerAction` | 3 |
| `Page` | 2 |
| `Route` | 2 |
| `RouteHandler` | 2 |
| `Layout` | 1 |
| `Middleware` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Template` | 1 |
| `DefaultSlot` | 1 |
| `ErrorBoundary` | 1 |
| `ClientBoundary` | 1 |
| `ServerBoundary` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 2 |
| `route_to_component` | 1 |
| `layout_of` | 1 |
| `contains` | 1 |
| `renders` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.file` | 20 | **no** |
| `definition.ecmascript_exported_variable_context` | 13 | **no** |
| `definition.ecmascript_exported_function_context` | 6 | **no** |
| `data.ecmascript_module_directive_context` | 4 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.ecmascript_function_directive_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x43, `path_glob` x39, `field_equals` x20, `field_present` x5, `(join)` x3, `external_path_matches` x2, `field_in` x2, `fact_join_by_field` x2, `path_segment` x1, `fact_join_by_path_ancestor` x1.

Fields read: `exported_name`, `directive`, `source.start`, `owner_function`.

Path globs: `**/app/**/*.{js,jsx,ts,tsx}`, `**/app/**/route.{js,jsx,ts,tsx}`, `**/app/**/page.{js,jsx,ts,tsx}`, `**/app/**/layout.{js,jsx,ts,tsx}`, `**/*.{js,jsx,ts,tsx}`, `**/pages/**/*.{js,jsx,ts,tsx}`, `**/middleware.{js,ts}`, `**/app/**/loading.{js,jsx,ts,tsx}`, `**/app/**/error.{js,jsx,ts,tsx}`, `**/app/**/not-found.{js,jsx,ts,tsx}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `next.app.page` | kind `data.file` |
| `next.app.layout` | kind `data.file` |
| `next.pages.route` | kind `data.file` |
| `next.app.route_handler` | kind `data.file` |
| `next.middleware.file` | kind `data.file` |
| `next.special.loading` | kind `data.file` |
| `next.special.error` | kind `data.file` |
| `next.special.not_found` | kind `data.file` |
| `next.app.layout_hierarchy` | kind `data.file` |
| `next-js.generic-api-call.next` | kind `call.target_candidate` |
| `next-js.generic-dependency.next` | kind `import.target_candidate` |
| `next.special.template.file` | kind `data.file` |
| `next.special.default.file` | kind `data.file` |
| `next.special.global_error.file` | kind `data.file` |
| `next.special.sitemap.file` | kind `data.file` |
| `next.special.robots.file` | kind `data.file` |
| `next.special.manifest.file` | kind `data.file` |
| `next.special.icon.file` | kind `data.file` |
| `next.special.apple_icon.file` | kind `data.file` |
| `next.special.opengraph_image.file` | kind `data.file` |
| `next.special.twitter_image.file` | kind `data.file` |
| `next.route-handler.exported-http-method` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `next.route-handler.exported-http-variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.module.use-client` | kind `data.ecmascript_module_directive_context`; field `directive` |
| `next.module.use-server` | kind `data.ecmascript_module_directive_context`; field `directive` |
| `next.server-action.function-directive` | kind `data.ecmascript_function_directive_context`; field `directive`, `owner_function` |
| `next.server-action.module-export-function` | kind `data.ecmascript_module_directive_context`, `definition.ecmascript_exported_function_context`; field `directive`, `exported_name` |
| `next.server-action.module-export-variable` | kind `data.ecmascript_module_directive_context`, `definition.ecmascript_exported_variable_context`; field `directive`, `exported_name` |
| `next.metadata.metadata.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `next.metadata.metadata.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.metadata.viewport.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `next.metadata.viewport.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.metadata.generateMetadata.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `next.metadata.generateMetadata.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.metadata.generateViewport.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `next.metadata.generateViewport.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.dynamic` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.dynamicParams` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.revalidate` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.fetchCache` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.runtime` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.preferredRegion` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `next.route-segment-config.maxDuration` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |

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
