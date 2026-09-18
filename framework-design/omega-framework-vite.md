# omega-framework-vite

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

21 overlay rules, 4 detection rules. **0 can match, 21 cannot.**

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
