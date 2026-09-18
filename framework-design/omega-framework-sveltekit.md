# omega-framework-sveltekit

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

29 overlay rules, 4 detection rules. **0 can match, 29 cannot.**

Selector: `framework:sveltekit`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Loader` | 4 |
| `Actions` | 4 |
| `Route` | 2 |
| `EndpointHandler` | 2 |
| `ParamMatcherFunction` | 2 |
| `HookHandler` | 2 |
| `Page` | 1 |
| `Endpoint` | 1 |
| `Layout` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `PageServer` | 1 |
| `LoaderModule` | 1 |
| `LayoutServer` | 1 |
| `LayoutLoader` | 1 |
| `ErrorPage` | 1 |
| `HookModule` | 1 |
| `ParamMatcher` | 1 |
| `Action` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 3 |
| `layout_applies_to` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `contains` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.file` | 10 | **no** |
| `definition.ecmascript_exported_function_context` | 8 | **no** |
| `definition.ecmascript_exported_variable_context` | 8 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.ecmascript_exported_object_field_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x29, `path_glob` x27, `field_in` x16, `field_present` x3, `external_path_matches` x2, `field_equals` x1.

Fields read: `exported_name`, `source.start`, `owner_export`, `field_key`.

Path globs: `**/+server.{js,ts}`, `**/+page*.{js,ts}`, `**/+layout*.{js,ts}`, `**/params/*.{js,ts}`, `**/+page.server.{js,ts}`, `**/hooks*.{js,ts}`, `**/+page.svelte`, `**/+server.*`, `**/+layout.svelte`, `**/+page.{js,ts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `sveltekit.page.file` | kind `data.file` |
| `sveltekit.endpoint.file` | kind `data.file` |
| `sveltekit.layout.file` | kind `data.file` |
| `sveltekit.generic-api-call.sveltejs-kit` | kind `call.target_candidate` |
| `sveltekit.generic-dependency.sveltejs-kit` | kind `import.target_candidate` |
| `sveltekit.file.page-server` | kind `data.file` |
| `sveltekit.file.page-load` | kind `data.file` |
| `sveltekit.file.layout-server` | kind `data.file` |
| `sveltekit.file.layout-load` | kind `data.file` |
| `sveltekit.file.error` | kind `data.file` |
| `sveltekit.file.hooks` | kind `data.file` |
| `sveltekit.file.param-matcher` | kind `data.file` |
| `sveltekit.export.endpointhandler.function.xx-+server.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.loader.function.xx-+pagex.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.loader.function.xx-+layoutx.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.actions.function.xx-+pagex.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.actions.function.xx-+layoutx.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.parammatcherfunction.function.xx-params-x.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.hookhandler.function.xx-hooksx.{js,ts}` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.export.endpointhandler.variable.xx-+server.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.loader.variable.xx-+pagex.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.loader.variable.xx-+layoutx.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.actions.variable.xx-+pagex.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.actions.variable.xx-+layoutx.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.parammatcherfunction.variable.xx-params-x.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.export.hookhandler.variable.xx-hooksx.{js,ts}` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.endpoint.handles.function` | kind `definition.ecmascript_exported_function_context`; field `exported_name` |
| `sveltekit.endpoint.handles.variable` | kind `definition.ecmascript_exported_variable_context`; field `exported_name` |
| `sveltekit.action.member` | kind `data.ecmascript_exported_object_field_context`; field `field_key`, `owner_export` |

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
