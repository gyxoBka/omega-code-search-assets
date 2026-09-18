# omega-framework-electron

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before this rewrite

32 overlay rules, 4 detection rules. **3 counted live, 29 cannot match** --
and the 3 were dead too; see "What was wrong with it".

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

## What was wrong with it

**32 rules, 3 counted live, and in practice none of them matched.**

*Twenty-nine died on the kind.* Twelve spellings of the old ECMAScript carrier
vocabulary carried the whole file: `call.ecmascript_nested_member_string_identifier_context`
(12 rules), `import.ecmascript_commonjs_binding_context` /
`_namespace_binding_context` / `_default_binding_context` (5 each),
`call.ecmascript_constructor_identifier_context` (3),
`import.ecmascript_named_binding_context` (3),
`call.ecmascript_constructor_member_context` (3), plus one each of
`call.ecmascript_member_string_identifier_context`,
`import.ecmascript_commonjs_named_binding_context`, `call.target_candidate` and
`import.target_candidate`. No Pack emits any of them.

*The three the audit called live were dead too.* `electron.window.load-file`,
`electron.context-bridge` and `electron.app-lifecycle` match `call.member` —
emitted by omega-c, omega-cpp and omega-c-sharp, and by no JavaScript,
TypeScript or TSX Pack. An Electron overlay keyed to a C++ fact kind matched
nothing in an Electron project. Nine more rules matched `call.member` *and*
read `call.arg0`, and were counted dead for the field.

*Twenty-four rules were one construct written four ways.* `new BrowserWindow()`
had four rules (named ESM import, CommonJS destructure, CommonJS namespace, ESM
namespace, ESM default) and `ipcMain.handle` had five per method across four
methods — twenty rules that differed only in which import spelling bound the
name. The Pack states `import ... from 'electron'` and `require('electron')`
under the same `import.module` kind now, so all of that is one clause.

*Every rule depended on machinery that does not exist for JavaScript.* Nineteen
rules used `fact_join_by_field` on `local_name` / `module_source` /
`imported_name`; the JS, TS and TSX Packs publish **no fields at all** — every
template in all three has `"fields": {}`. Thirteen used `external_path_matches`,
which resolves through `ExternalEnvironment`, built in
`framework/materialize.rs:541` from bindings whose `target_hint` is the
occurrence `qualifier` — which those three Packs never publish either
(`00-INDEX.md` already records `qualifier` as owed). So `external.package` is
always `None` for every JavaScript fact, and every `external_path_matches` clause in
the file was unsatisfiable independently of its kind.

*Two rules restated their input.* `electron.generic-api-call.electron` and
`electron.generic-dependency.electron` emitted an entity and then a relation
from `current` to that same entity's own canonical key — a self-loop carrying
no information.

**12 rules now, all live.** The file is 38% of its former size and states more.

## What it states now

Every rule is written against `definition.name`, `path`, `source.start` and
span containment — the names a fact answers with no published field — plus one
shared clause that proves the file is Electron's:

```
fact_join_by_field  import.module  current_field: path  join_field: path
                    same_path: true
                    where definition.name in [electron, electron/main,
                          electron/renderer, electron/common,
                          electron/utility, @electron/remote]
```

`path` is a built-in name on every fact, so joining `path` to `path` in the
same file needs no Pack field on either side and means exactly *this file
imports Electron*. That binding is what makes a bare `ipcMain`, `handle` or
`BrowserWindow` safe to interpret.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| Which files are Electron code, and which entry point they use | `import.module`, name in the six Electron specifiers (the JS Pack emits `require('electron')` under this kind too) | `ElectronFile electron:file:{path}`, `ElectronModule electron:module:{name}`, `depends_on` |
| Which part of the Electron API a file uses | `import.symbol`, name in the 42 top-level Electron modules + the Electron-file join | `ElectronApi electron:api:{name}`, `uses_api` |
| Is this main-process code | `import.symbol`, name in the 33 main-only modules (`app`, `ipcMain`, `BrowserWindow`, `dialog`, `session`, …) + the join | `ProcessRole electron:process:main`, `runs_in` |
| Is this renderer or preload code | `import.symbol` in `ipcRenderer`, `contextBridge`, `webFrame`, `webUtils` + the join | `ProcessRole electron:process:renderer`, `runs_in` |
| Where are the application's windows created | `call.constructor`, name in `BrowserWindow`, `BaseWindow`, `BrowserView`, `WebContentsView` + the join | `Window electron:window:{path}:{source.start}`, `creates` from the file |
| Which function opens the window | the same, plus `fact_join_by_span` `within` a `definition.function` | `ElectronFunction electron:function:{path}:{fn.name}`, `creates` |
| Where is a window given its content | `call.method`, name `loadFile` / `loadURL` + the join | `WindowResource electron:window-resource:{path}:{source.start}`, `uses_resource` |
| Where does the main process register an IPC endpoint | `call.method`, name `handle` / `handleOnce` + the join | `IpcHandler electron:ipc-handler:{path}:{source.start}`, `handles` from the file |
| Which function registers it | the same, plus `fact_join_by_span` `within` a `definition.function` | `ElectronFunction`, `handles` from the function |
| Where does a renderer talk to the main process | `call.method`, name in `invoke`, `send`, `sendSync`, `sendTo`, `sendToHost`, `postMessage` + the join | `IpcCall electron:ipc-call:{path}:{source.start}`, `uses_api` |
| What does the preload script expose, and which file is the preload | `call.method`, name `exposeInMainWorld` / `exposeInIsolatedWorld` + the join | `ContextBridge electron:bridge:{path}:{source.start}` + `ProcessRole electron:process:preload`, `configures` and `runs_in` |
| Where is application startup decided | `call.method`, name `whenReady`, `requestSingleInstanceLock`, `setAsDefaultProtocolClient`, `disableHardwareAcceleration` + the join | `LifecycleHook electron:lifecycle:{path}:{source.start}`, `configures` |

Keys minted: `electron:file:{path}`, `electron:module:{name}`,
`electron:api:{name}`, `electron:process:{main,renderer,preload}`,
`electron:window:…`, `electron:function:…`, `electron:window-resource:…`,
`electron:ipc-handler:…`, `electron:ipc-call:…`, `electron:bridge:…`,
`electron:lifecycle:…`. Every relation end is one of those; none dangles. Both
two-rule pairs (`window.create` / `window.create.function`,
`ipc.main.handler` / `ipc.main.handler.function`) carry identical clauses apart
from the span join, so the key the second addresses is always minted by the
first. No relation uses `current`, so the wave-2 "`current` is the first output"
trap cannot bite.

## A field only the Pack can supply

**Pack: `omega-javascript`, `omega-typescript`, `omega-tsx`. Kind:
`call.method`, `call.function`, `call.constructor`. Field: `receiver` and
`literal_value` (the call's first string argument).**

Electron's IPC graph is channel-keyed: `ipcRenderer.invoke('dialog:open')` in a
renderer is answered by `ipcMain.handle('dialog:open')` in main. That edge is
the single most valuable thing an agent could ask an Electron overlay for, and
it is unreachable:

- the channel is the call's **first argument**, a string literal. The three
  ECMAScript Packs publish no fields and no `literal_value`, and the emission's
  `name` is only the property identifier (`queries.scm`:
  `(call_expression function: (member_expression property: (property_identifier) @call.method))`).
  `definition.name`, `path`, `path.dir`, `path.stem`, `external.*` cannot derive
  a value that is not in the graph.
- no join reaches it. `fact_join_by_span` with `within` relates a member to an
  enclosing declaration; a string argument is not a declaration and the Packs
  emit nothing spanning it. `fact_join_by_field` needs a published field on one
  side, which is the thing that is missing.

The same absence costs `receiver`: because `call.method`'s name is the property
alone, `ipcMain.on`, `app.on` and `emitter.on` are one indistinguishable fact,
which is why `electron.ipc.renderer.call` is candidate-confidence and why the
`on`/`once` listener rules the old file carried were dropped rather than ported.
`receiver` is also read by the host itself (`overlay.rs` `facts_of_surface`
checks `fields["receiver"]` first when resolving a construct's external
identity), so it is not an Electron-only cost.

## Still to decide

1. **`external_path_matches` is a dead clause for all of JavaScript.** Wave 2's
   `next.api.call` uses it and the audit calls it live, but `qualifier` is
   unpublished by the three ECMAScript Packs, so `ExternalEnvironment::imports`
   is always empty and `OverlayFact::external` is always `None`. This overlay
   avoids the clause entirely; whether the other ECMAScript frameworks should
   is a cross-framework call, not this file's.
2. **`send` and `postMessage` are common method names.** Gating them on a
   same-file Electron import is the strongest filter available without
   `receiver`. The rule is `confidence: "candidate"` and says so; the
   alternative — dropping them and losing every CommonJS preload, where the
   destructured `ipcRenderer` is not emitted as an `import.symbol` — states
   less.
3. **`main`, `renderer` and `preload` are not exclusive.** A file that imports
   both `ipcMain` and `shell` gets one `runs_in`; a preload that imports
   `ipcRenderer` gets both `renderer` and `preload`. That is what the source
   says, and the overlay does not arbitrate between the two.
