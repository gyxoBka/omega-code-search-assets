# omega-framework-node-js

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

98 overlay rules, 4 detection rules. **0 can match, 98 cannot.**

Selector: `framework:node-js`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ApiUse` | 41 |
| `Dependency` | 41 |
| `Server` | 4 |
| `Task` | 3 |
| `FileResource` | 2 |
| `Process` | 2 |
| `EventChannel` | 2 |
| `Resource` | 1 |
| `RuntimeComponent` | 1 |
| `EnvironmentConfig` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_api` | 41 |
| `depends_on` | 41 |
| `creates_server` | 4 |
| `uses_resource` | 4 |
| `spawns` | 4 |
| `uses_config` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 53 | **no** |
| `import.target_candidate` | 41 | **no** |
| `call.ecmascript_constructor_identifier_context` | 3 | **no** |
| `import.ecmascript_named_binding_context` | 3 | **no** |
| `reference.ecmascript_root_member_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x98, `field_present` x97, `external_path_matches` x94, `field_equals` x8, `fact_join_by_field` x3, `(join)` x3, `path_glob` x3.

Fields read: `source.start`, `constructor_name`, `module_source`, `imported_name`, `root`, `member`.

Path globs: `**/*.{js,mjs,cjs}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `node-js.source-authored.worker-task` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_named_binding_context`; field `constructor_name`, `imported_name`, `module_source` |
| `node-js.source-authored.message-channel-resource` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_named_binding_context`; field `constructor_name`, `imported_name`, `module_source` |
| `node-js.source-authored-async-local-storage` | kind `call.ecmascript_constructor_identifier_context`, `import.ecmascript_named_binding_context`; field `constructor_name`, `imported_name`, `module_source` |
| `node-js.generic-api-call.node` | kind `call.target_candidate` |
| `node-js.generic-dependency.node` | kind `import.target_candidate` |
| `node-js.api.node-fs` | kind `call.target_candidate` |
| `node-js.dependency.node-fs` | kind `import.target_candidate` |
| `node-js.api.fs` | kind `call.target_candidate` |
| `node-js.dependency.fs` | kind `import.target_candidate` |
| `node-js.api.node-fs-promises` | kind `call.target_candidate` |
| `node-js.dependency.node-fs-promises` | kind `import.target_candidate` |
| `node-js.api.fs-promises` | kind `call.target_candidate` |
| `node-js.dependency.fs-promises` | kind `import.target_candidate` |
| `node-js.api.node-http` | kind `call.target_candidate` |
| `node-js.dependency.node-http` | kind `import.target_candidate` |
| `node-js.api.http` | kind `call.target_candidate` |
| `node-js.dependency.http` | kind `import.target_candidate` |
| `node-js.api.node-https` | kind `call.target_candidate` |
| `node-js.dependency.node-https` | kind `import.target_candidate` |
| `node-js.api.https` | kind `call.target_candidate` |
| `node-js.dependency.https` | kind `import.target_candidate` |
| `node-js.api.node-events` | kind `call.target_candidate` |
| `node-js.dependency.node-events` | kind `import.target_candidate` |
| `node-js.api.events` | kind `call.target_candidate` |
| `node-js.dependency.events` | kind `import.target_candidate` |
| `node-js.api.node-stream` | kind `call.target_candidate` |
| `node-js.dependency.node-stream` | kind `import.target_candidate` |
| `node-js.api.stream` | kind `call.target_candidate` |
| `node-js.dependency.stream` | kind `import.target_candidate` |
| `node-js.api.node-child_process` | kind `call.target_candidate` |
| `node-js.dependency.node-child_process` | kind `import.target_candidate` |
| `node-js.api.child_process` | kind `call.target_candidate` |
| `node-js.dependency.child_process` | kind `import.target_candidate` |
| `node-js.api.node-net` | kind `call.target_candidate` |
| `node-js.dependency.node-net` | kind `import.target_candidate` |
| `node-js.api.net` | kind `call.target_candidate` |
| `node-js.dependency.net` | kind `import.target_candidate` |
| `node-js.api.node-path` | kind `call.target_candidate` |
| `node-js.dependency.node-path` | kind `import.target_candidate` |
| `node-js.api.path` | kind `call.target_candidate` |
| `node-js.dependency.path` | kind `import.target_candidate` |
| `node-js.api.node-url` | kind `call.target_candidate` |
| `node-js.dependency.node-url` | kind `import.target_candidate` |
| `node-js.api.url` | kind `call.target_candidate` |
| `node-js.dependency.url` | kind `import.target_candidate` |
| `node-js.api.node-worker_threads` | kind `call.target_candidate` |
| `node-js.dependency.node-worker_threads` | kind `import.target_candidate` |
| `node-js.api.worker_threads` | kind `call.target_candidate` |
| `node-js.dependency.worker_threads` | kind `import.target_candidate` |
| `node-js.api.node-process` | kind `call.target_candidate` |
| `node-js.dependency.node-process` | kind `import.target_candidate` |
| `node-js.api.process` | kind `call.target_candidate` |
| `node-js.dependency.process` | kind `import.target_candidate` |
| `node-js.api.node-crypto` | kind `call.target_candidate` |
| `node-js.dependency.node-crypto` | kind `import.target_candidate` |
| `node-js.api.crypto` | kind `call.target_candidate` |
| `node-js.dependency.crypto` | kind `import.target_candidate` |
| `node-js.api.node-os` | kind `call.target_candidate` |
| `node-js.dependency.node-os` | kind `import.target_candidate` |
| `node-js.api.os` | kind `call.target_candidate` |
| `node-js.dependency.os` | kind `import.target_candidate` |
| `node-js.api.node-async_hooks` | kind `call.target_candidate` |
| `node-js.dependency.node-async_hooks` | kind `import.target_candidate` |
| `node-js.api.async_hooks` | kind `call.target_candidate` |
| `node-js.dependency.async_hooks` | kind `import.target_candidate` |
| `node-js.api.node-timers` | kind `call.target_candidate` |
| `node-js.dependency.node-timers` | kind `import.target_candidate` |
| `node-js.api.timers` | kind `call.target_candidate` |
| `node-js.dependency.timers` | kind `import.target_candidate` |
| `node-js.api.node-buffer` | kind `call.target_candidate` |
| `node-js.dependency.node-buffer` | kind `import.target_candidate` |
| `node-js.api.buffer` | kind `call.target_candidate` |
| `node-js.dependency.buffer` | kind `import.target_candidate` |
| `node-js.api.node-util` | kind `call.target_candidate` |
| `node-js.dependency.node-util` | kind `import.target_candidate` |
| `node-js.api.util` | kind `call.target_candidate` |
| `node-js.dependency.util` | kind `import.target_candidate` |
| `node-js.api.node-zlib` | kind `call.target_candidate` |
| `node-js.dependency.node-zlib` | kind `import.target_candidate` |
| `node-js.api.zlib` | kind `call.target_candidate` |
| `node-js.dependency.zlib` | kind `import.target_candidate` |
| `node-js.api.node-readline` | kind `call.target_candidate` |
| `node-js.dependency.node-readline` | kind `import.target_candidate` |
| `node-js.api.readline` | kind `call.target_candidate` |
| `node-js.dependency.readline` | kind `import.target_candidate` |
| `node-js.process-env` | kind `reference.ecmascript_root_member_context`; field `member`, `root` |
| `node-js.special.node-http-Server` | kind `call.target_candidate` |
| `node-js.special.http-Server` | kind `call.target_candidate` |
| `node-js.special.node-https-Server` | kind `call.target_candidate` |
| `node-js.special.https-Server` | kind `call.target_candidate` |
| `node-js.special.node-fs-FileResource` | kind `call.target_candidate` |
| `node-js.special.fs-FileResource` | kind `call.target_candidate` |
| `node-js.special.node-child_process-Process` | kind `call.target_candidate` |
| `node-js.special.child_process-Process` | kind `call.target_candidate` |
| `node-js.special.node-worker_threads-Task` | kind `call.target_candidate` |
| `node-js.special.worker_threads-Task` | kind `call.target_candidate` |
| `node-js.special.node-events-EventChannel` | kind `call.target_candidate` |
| `node-js.special.events-EventChannel` | kind `call.target_candidate` |

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
