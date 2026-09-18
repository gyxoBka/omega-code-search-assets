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
## What was wrong with it

Everything above this line describes the file as it was. It is kept as the
record. The rewritten overlay is **13 rules, all live** (was 98 rules, 0 live).

Concretely, what was wrong:

1. **Every rule was keyed to a kind no Pack emits.** 53 rules on
   `call.target_candidate`, 41 on `import.target_candidate`, 3 on
   `call.ecmascript_constructor_identifier_context`, 3 on
   `import.ecmascript_named_binding_context`, 1 on
   `reference.ecmascript_root_member_context`. 98 of 98 could not match.
2. **94 of 98 rules gated on `external_path_matches`, which can never fire for
   JavaScript or TypeScript.** The host resolves a fact's external package from
   `ExternalEnvironment`, which is built in
   `framework/materialize.rs::external_environment` from surface bindings whose
   `target_hint` is set. `target_hint` is `occurrence.qualifier`, and
   `content_builder.rs::mention_fields` only reads a field or attribute literally
   named `qualifier`. `omega-javascript` and `omega-typescript` publish `target`
   and `module` on `binding.import_alias`, never `qualifier`, so the environment
   is empty and `fact.external` is `None` for every JS/TS fact. This was dead
   twice over, and it is why the Pack-side note below exists.
3. **41 `api.*` + 41 `dependency.*` rules were the same rule written 82 times**,
   once per core module and once per `node:`-prefixed spelling of the same core
   module. The `node:` / bare distinction is a `field_in` value, not a rule.
4. **The `api.*` rules restated their input.** Each emitted one `ApiUse` entity
   keyed `node:api-use:<mod>:{path}:{source.start}` and one `uses_api` relation
   whose source was `current` and whose target was *that same rendered key* — a
   self-edge on a per-site node connected to nothing. 41 rules, 41 self-edges.
   The `dependency.*` rules did the same with `current -> node:dependency:<mod>`,
   where `current` **is** that entity, because `current` resolves to the rule's
   first emitted entity (`overlay.rs::emit`, `own_key`).
5. **The three `source-authored.*` rules used `fact_join_by_field` on
   `local_name`/`module_source`/`imported_name`**, three fields no Pack has ever
   published, to tie `new Worker(...)` to its import. The join that works uses
   only `path`, which every fact answers.
6. **The path globs never matched anything.** `**/*.{js,mjs,cjs}` was written
   for a glob engine with brace alternation; `overlay.rs::glob_here` has `*`,
   `**` and `?` and treats `{`, `,` and `}` as literal characters. Three rules
   carried a pattern that can only match a file literally named `*.{js,mjs,cjs}`.
7. **`node-js.process-env` had no fact to stand on.** It matched
   `reference.ecmascript_root_member_context`; neither JS nor TS emits any fact
   for a member expression that is not a call, so `process.env` is invisible.
   Deleted rather than ported — see "Still to decide".

## What it states now

The overlay's claim is the one a language Pack cannot make: *this specifier is a
Node core module, and this call site is the Node runtime construct it builds.*

Three entity keys carry identity across files and rules:

- `node:file:{path}` — a file that imports at least one Node core module.
- `node:module:{specifier}` — a Node core module, shared by every file that
  imports it.
- `node:<construct>:{path}:{source.start}` — one construct at one call site.

| what it states | which Pack fact | which entity or relation | question it answers |
|---|---|---|---|
| this file imports a Node core module | `import.module`, `definition.name` in 112 core spellings (bare and `node:`-prefixed, incl. `fs/promises`, `node:test`) | entity `NodeFile` `node:file:{path}`, entity `NodeCoreModule` `node:module:{definition.name}`, relation `depends_on` file → module | which core modules does this project use, and which files use `node:child_process`? |
| a listening server is built here | `call.function` / `call.method` named `createServer`, `createSecureServer`, joined to an `import.module` of `http`/`https`/`http2`/`net`/`tls` in the same file | entity `Server` `node:server:{path}:{source.start}`, relation `creates_server` file → server | where does this service start listening? |
| a child process is started here | `call.function` / `call.method` named `spawn`, `exec`, `execFile`, `fork` (and the `*Sync` forms), joined to an `import.module` of `child_process` | entity `Process` `node:process:{path}:{source.start}`, relation `spawns` file → process | what shells out, and from where? |
| the filesystem is touched here | `call.function` / `call.method` in 39 `fs` API names, joined to an `import.module` of `fs` or `fs/promises` | entity `FileResource` `node:file-resource:{path}:{source.start}`, relation `uses_resource` file → resource | which code reads or writes files? |
| an outbound HTTP request is issued here | `call.function` / `call.method` named `request`, `get`, `connect`, joined to an `import.module` of `http`/`https`/`http2` | entity `ApiUse` `node:outbound-request:{path}:{source.start}`, relation `uses_api` file → use | where does this service call out? |
| a worker thread is started here | `call.constructor` named `Worker`, joined to an `import.module` of `worker_threads` | entity `Task` `node:task:{path}:{source.start}`, relation `spawns` file → task | what runs off the main thread? |
| a message channel is opened here | `call.constructor` named `MessageChannel`, `BroadcastChannel`, joined to `worker_threads` | entity `Resource` `node:message-channel:{path}:{source.start}`, relation `uses_resource` | how do the threads talk? |
| an event emitter is created here | `call.constructor` named `EventEmitter`, `EventEmitterAsyncResource`, joined to `events` | entity `EventChannel` `node:event-channel:{path}:{source.start}`, relation `uses_resource` | where are the event hubs? |
| async context is established here | `call.constructor` named `AsyncLocalStorage`, `AsyncResource`, joined to `async_hooks` | entity `RuntimeComponent` `node:async-context:{path}:{source.start}`, relation `uses_resource` | what carries request context across awaits? |

Thirteen rules: one import rule, four construct families × two call spellings
(`createServer()` after a named import is `call.function`, `http.createServer()`
is `call.method`), four `call.constructor` rules.

**How a call reaches its module without a Pack field.** Every construct rule
carries

```json
{"kind": "fact_join_by_field", "fact_kind": "import.module",
 "current_field": "path", "join_field": "path", "same_path": true,
 "bind": "module",
 "where": [{"kind": "field_in", "field": "definition.name", "values": [...]}]}
```

`path` and `definition.name` are both built-ins that `OverlayFact::field`
answers for any fact, so this join needs nothing published on either side. It is
file-granular, not binding-granular: it says *this file imports
`node:child_process` and calls `spawn`*, not *this `spawn` is that module's*.
That is weaker than a binding-level link and it is the strongest thing the
current Packs support — see below. The selective `field_in` on the call name is
placed **before** the join so only a handful of facts per file ever reach it.

## A field only the Pack can supply

**Pack:** `omega-javascript`, `omega-typescript`, `omega-tsx`.
**Kind:** `binding.import_alias` (and `import.symbol`, `binding.import_default`,
`binding.import_namespace`).
**Field:** `qualifier` — the module specifier the binding came from.

These Packs already capture the specifier: `omega-typescript` publishes it as
the attribute `module` on the `import.require.name` template, and both publish
`target` on `binding.import_alias`. The host reads neither. `content_builder.rs`
accepts a mention's qualifier only under the literal name `qualifier`
(`mention_fields`, which also accepts `receiver_hint`/`receiver` and
`explicit_type_hint`/`type_hint` as older spellings, but has no alias for
`target` or `module`). Without it, `SurfaceBinding::target_hint` is `None`,
`external_environment` returns an empty environment, and every JS/TS fact
arrives at the overlay with `external: None`.

Why neither of the first two options reaches it:

- **Not derivable.** `definition.name` of a `call.function` is the callee
  identifier (`createServer`); `queries.scm` captures only
  `(call_expression function: (identifier))` and
  `(member_expression property: (property_identifier))`, so no fact carries the
  receiver or the module.
- **Not reachable by `fact_join_by_span`.** `import.module`'s span is the module
  string literal and `import.symbol`'s span is the imported name. Neither
  contains the other, and no Pack emits a fact spanning the whole import
  statement, so `within` has nothing to bind. Changing the span capture would be
  a Pack change too.

The cost is one field on import bindings only, in three Packs. What it buys is
the difference between *this file imports `node:fs` and calls `writeFile`* and
*this `writeFile` is `node:fs`'s* — and it would revive
`external_path_matches`, which 336 clauses across the other 54 overlays are
still written against.

## Still to decide

- **`.jsx` and `.tsx` are excluded.** The overlay's language guard has to be a
  path glob, because `import.module`, `call.function` and `call.method` are
  emitted by a dozen other Packs and `import os` in Python would otherwise
  become `node:module:os`. `glob_here` has no brace alternation, so one pattern
  has to cover six extensions: `**/*.*s` covers `.js`, `.mjs`, `.cjs`, `.ts`,
  `.mts`, `.cts` and excludes `.py`, `.lua`, `.jl`, `.zig`, `.erl`, `.sol`,
  `.cpp`, `.ps1`. It also admits `.rs` (which emits no `import.module`) and
  `.exs` (whose module names are `Foo.Bar` and collide with nothing here). It
  does **not** cover `.jsx`/`.tsx`. Node runtime code in a JSX file is rare
  enough that one pattern beats thirteen more rules, but if that turns out to be
  wrong the fix is a second glob clause and a duplicate rule set, or brace
  support in `glob_here`.
- **Bare core specifiers are claimed as core.** `import util from 'util'` is
  recorded as `node:module:util` with `scope: "core"`, even though a repo could
  shadow it with an npm package of that name. Node itself resolves core first,
  so this is the right default, but it is a claim and not a proof.
- **`process.env` is gone, not ported.** Reviving it needs a fact for a member
  expression that is not a call — a new `reference.member` template in the JS/TS
  Packs. That is a bigger ask than one field and it is not Node-specific
  (`import.meta`, `globalThis`, `window` all want it), so it belongs in
  `00-INDEX.md` rather than here.
- **A construct is located but not parameterised.** No JS/TS Pack publishes call
  arguments, so the port a server binds, the command a child process runs and
  the path a filesystem call touches are all absent. The entity says *there is a
  server here*; it cannot say *this server serves :3000*.
