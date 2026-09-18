# omega-framework-nuxt

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

18 overlay rules, 4 detection rules. **0 can match, 18 cannot.**

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
