# omega-framework-electron

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

32 overlay rules, 4 detection rules. **3 can match, 29 cannot.**

Selector: `framework:electron`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `IpcHandler` | 16 |
| `PlatformComponent` | 5 |
| `IpcUse` | 4 |
| `Command` | 1 |
| `Resource` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `WindowResource` | 1 |
| `ContextBridge` | 1 |
| `LifecycleHook` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 16 |
| `uses_api` | 5 |
| `depends_on` | 1 |
| `uses_resource` | 1 |
| `configures` | 1 |
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.ecmascript_nested_member_string_identifier_context` | 12 | **no** |
| `call.member` | 11 | yes |
| `import.ecmascript_commonjs_binding_context` | 5 | **no** |
| `import.ecmascript_namespace_binding_context` | 5 | **no** |
| `import.ecmascript_default_binding_context` | 5 | **no** |
| `call.ecmascript_constructor_identifier_context` | 3 | **no** |
| `import.ecmascript_named_binding_context` | 3 | **no** |
| `call.ecmascript_constructor_member_context` | 3 | **no** |
| `call.ecmascript_member_string_identifier_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `import.ecmascript_commonjs_named_binding_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x57, `field_present` x55, `fact_kind` x32, `fact_join_by_field` x19, `(join)` x19, `path_glob` x19, `external_path_matches` x13.

Fields read: `module_source`, `member`, `arg0`, `arg1`, `object_member`, `root`, `call.arg0`, `operator`, `imported_name`, `constructor_name`, `object`, `source.start`, `receiver`.

Path globs: `**/*.{js,jsx,ts,tsx,mjs,cjs,mts,cts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `electron.browser-window.imported-constructor` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_named_binding_context`; field `constructor_name`, `imported_name`, `module_source` |
| `electron.ipc-main-handle.imported` | kind `call.ecmascript_member_string_identifier_context`, `import.ecmascript_named_binding_context`; field `arg0`, `arg1`, `imported_name`, `member`, `module_source`, `receiver` |
| `electron.message-channel-main.resource` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_named_binding_context`; field `constructor_name`, `imported_name`, `module_source` |
| `electron.generic-api-call.electron` | kind `call.target_candidate` |
| `electron.generic-dependency.electron` | kind `import.target_candidate` |
| `electron.ipc-main.handle` | field `call.arg0` |
| `electron.ipc-main.handleonce` | field `call.arg0` |
| `electron.ipc-main.on` | field `call.arg0` |
| `electron.ipc-main.once` | field `call.arg0` |
| `electron.ipc-renderer.invoke` | field `call.arg0` |
| `electron.ipc-renderer.send` | field `call.arg0` |
| `electron.ipc-renderer.sendsync` | field `call.arg0` |
| `electron.ipc-renderer.postmessage` | field `call.arg0` |
| `electron.browser-window.commonjs-named-constructor` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_commonjs_named_binding_context`; field `constructor_name`, `imported_name`, `module_source`, `operator` |
| `electron.browser-window.commonjs-namespace-constructor` | kind `call.ecmascript_constructor_member_context`, `import.ecmascript_commonjs_binding_context`; field `member`, `module_source`, `object`, `operator` |
| `electron.browser-window.esm-namespace-constructor` | kind `call.ecmascript_constructor_member_context`, `import.ecmascript_namespace_binding_context`; field `member`, `module_source`, `object` |
| `electron.browser-window.esm-default-constructor` | kind `call.ecmascript_constructor_member_context`, `import.ecmascript_default_binding_context`; field `member`, `module_source`, `object` |
| `electron.ipc-main.handle.commonjs-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `operator`, `root` |
| `electron.ipc-main.handle.namespace-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.handle.default-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.handleonce.commonjs-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `operator`, `root` |
| `electron.ipc-main.handleonce.namespace-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.handleonce.default-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.on.commonjs-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `operator`, `root` |
| `electron.ipc-main.on.namespace-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.on.default-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.once.commonjs-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `operator`, `root` |
| `electron.ipc-main.once.namespace-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |
| `electron.ipc-main.once.default-root` | kind `call.ecmascript_nested_member_string_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `arg1`, `member`, `module_source`, `object_member`, `root` |

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
