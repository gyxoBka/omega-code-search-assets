# omega-framework-tauri

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 4 detection rules. All 12 match; 0 cannot.**
Before this wave: 14 overlay rules, **0 live, 14 dead**.

Selector: `framework:tauri`. Maturity: `semantic-overlay-full`.

`host.required_packs` was `omega-json, omega-json5, omega-rust, omega-toml,
omega-typescript`; it now also lists `omega-javascript` and `omega-tsx`,
because a Tauri frontend is `.js`/`.jsx`/`.tsx` as often as `.ts` and all three
Packs emit the `import.module` and `call.function` facts the frontend rules
read. That is brief §3h's second case: a manifest that under-declared its packs.

### Entities it declares

| entity_kind | rules minting it |
|---|---|
| `PlatformComponent` | 5 (frontend file, backend entry, plugin, window declaration, window label) |
| `Resource` | 2 (capability file, permission) |
| `Configuration` | 3 (Cargo manifest, Tauri config) |
| `Dependency` | 2 (npm module, cargo crate) |
| `ApiUse` | 2 (API symbol, builder step) |
| `CommandInvocation`, `EventSubscription`, `EventEmission` | 1 each |

### Relations it declares

`applies_to`, `calls`, `configures`, `depends_on`, `grants`, `handles`,
`uses_api`.

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.function` | 4 | yes (omega-typescript, omega-javascript, omega-tsx) |
| `definition.config_key` | 3 | yes (omega-toml, omega-json, omega-json5) |
| `relation.data` | 2 | yes (omega-json, omega-json5) |
| `import.module` | 1 | yes |
| `call.macro` | 2 (one as a join) | yes (omega-rust) |
| `call.method` | 1 | yes (omega-rust) |

## What was wrong with it

Every one of the 14 rules was dead, and there were four separate causes.

**Eight rules matched `structured.entry`, a kind no Pack has emitted since the
Pack rewrite** — `tauri.window.config`, `tauri.capability.config`,
`tauri.config.toml-entry` and their `-json5` / `-toml` twins. They also read
`key`, `value`, `parent_key`, `array_key` and `container`, none of which any
data Pack publishes, and tested an attribute `role`
(`json_nested_array_object_string_pair`, `toml_table_pair`, …) that was the old
generator's per-nesting-depth vocabulary. The data formats now emit
`definition.config_key` for every pair in json, json5 and toml alike, with the
key as the **name**; the nesting the old `parent_key`/`array_key`/`container`
fields carried is the host's synthesized `definition.container` and
`enclosing.qname` (contract §2), which cost no Pack field at all.

**Six of those eight were one construct spelled three times.** `window.config`,
`window.config-json5` and `window.config-toml` differed only in the `role`
attribute and the path glob, as did the three `capability.*` rules and the two
`config.*-entry` rules. json, json5 and toml are one kind now, so they are one
rule, and the glob `**/tauri*.conf.json*` covers `.json` and `.json5` in one
pattern.

**Two rules matched carriers the host never folded** — `call.target_candidate`
(`tauri.generic-api-call.tauri`) and `import.target_candidate`
(`tauri.generic-dependency.tauri`). `generic-api-call` also emitted the
self-loop wave 2 and wave 6 both found: a `uses_api` relation from `current` to
the very key `current` had just been minted under.

**Three rules read `call.arg0`, a field no Pack publishes** —
`tauri.invoke`, `tauri.event.listen`, `tauri.event.emit`. They were also keyed
to `call.member`, which omega-c, omega-cpp and omega-c-sharp emit and no
JavaScript Pack does, so they were scoped-dead twice over, and their
`external_path_matches` named `@tauri-apps/api/core` and
`@tauri-apps/api/event` — a member path, not a package, and unreachable even
now that scoped packages are kept whole (`@tauri-apps/api/core` parses as
package `@tauri-apps/api` with member `core`).

**One rule matched `reference.rust_function_scoped_attribute_context`** with
fields `attribute_path` and `function_name` — one language's private spelling
of `#[tauri::command]`, and the one construct this rewrite could **not**
recover (see below).

Clause vocabulary before: `field_present` ×16, `fact_kind` ×14, `field_equals`
×12, `path_glob` ×9, `attribute_equals` ×8, `external_path_matches` ×5 — with
**zero joins**. The new file carries one join, and reads the host's
`definition.container` / `enclosing.qname` where the old one read Pack fields.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which frontend files talk to Tauri, and which `@tauri-apps` modules they pull in | `import.module`, name prefix `@tauri-apps/` (omega-typescript / -javascript / -tsx) | `PlatformComponent tauri:frontend:{path}`, `Dependency tauri:module:{module}`, `depends_on` between them |
| Where the frontend crosses the IPC bridge into Rust | `call.function` named `invoke`, resolved to package prefix `@tauri-apps` | `CommandInvocation tauri:invoke:{path}:{offset}`, `calls` from the frontend file |
| Where the frontend subscribes to a backend event | `call.function` named `listen`/`once`, external member `event` | `EventSubscription tauri:event-listener:{path}:{offset}`, `handles` from the frontend file |
| Where the frontend emits an event | `call.function` named `emit`/`emitTo`, external member `event` | `EventEmission tauri:event-emitter:{path}:{offset}`, `uses_api` from the frontend file |
| Which part of the Tauri API surface a call reaches (`window`, `path`, `webview`, `dialog`…) | `call.function` with `external.member` present, package prefix `@tauri-apps` | `ApiUse tauri:api:{member}:{symbol}`, `uses_api` from the frontend file |
| Which file assembles the Tauri app | `call.macro` named `generate_handler` / `generate_context` (omega-rust) | `PlatformComponent tauri:backend:{path}` |
| What the Builder chain configures — plugins, managed state, the setup hook, the invoke handler | `call.method` in an 11-name set, joined to a `generate_*` macro in the same path | `ApiUse tauri:builder-step:{path}:{step}`, `configures` from the backend entry |
| Which Tauri crates and `tauri-plugin-*` crates the backend depends on | `definition.config_key` in `Cargo.toml` whose `definition.container` is a dependency table (omega-toml) | `Dependency tauri:crate:{name}`, `Configuration tauri:manifest:{path}`, `depends_on` between them |
| Which plugins the app config configures | `definition.config_key` whose `definition.container` is `plugins`, in `**/tauri*.conf.json*` | `PlatformComponent tauri:plugin:{name}`, `configures` from `Configuration tauri:config:{path}` |
| Where windows are declared in the app config | `definition.config_key` named `label` whose `enclosing.qname` is `app.windows` (v2) or `tauri.windows` (v1) | `PlatformComponent tauri:window-declaration:{path}:{offset}`, `configures` from the config |
| **Which permissions this app grants** | `relation.data` (an array element) whose `definition.container` is `permissions`, in `**/capabilities/*.json*` | `Resource tauri:permission:{identifier}`, `grants` from `Resource tauri:capability:{path}` |
| Which window labels a capability applies to | `relation.data` whose `definition.container` is `windows`, same glob | `PlatformComponent tauri:window:{label}`, `applies_to` from the capability |

Two things worth naming, because they are what the language Packs alone cannot
say. The **permission set** is the question anyone auditing a Tauri app asks
first, and it is reachable exactly because a JSON array element arrives as
`relation.data` with its quotes already stripped, unlike a pair's value. And
`external.member` in JavaScript is the *module segment the binding came from* —
`@tauri-apps/api/window` gives member `window` — so it classifies a call by API
area with no Pack field beyond the `qualifier` the JS/TS Packs now publish.

### Checks run

- `overlay_audit.py tauri`: 12 live, 0 dead.
- `dangling_ends.py tauri`: nothing. Every key a relation addresses
  (`tauri:frontend:{path}`, `tauri:backend:{path}`, `tauri:config:{path}`,
  `tauri:capability:{path}`, `tauri:manifest:{path}`) is minted by a rule in
  this file, and the condition parity brief §3b asks for holds: a call that
  resolves through an `@tauri-apps` binding *requires* an `@tauri-apps`
  `import.module` in the same file, which is exactly what mints
  `tauri:frontend:{path}`.
- `key_collisions.py tauri`: nothing. Two key templates are shared, and both
  times by rules that agree on the kind **and** the attributes:
  `tauri:config:{path}` (`Configuration`, minted by `tauri.config.plugin` and
  `tauri.config.window`) and `tauri:capability:{path}` (`Resource`, minted by
  `tauri.capability.permission` and `tauri.capability.window`). Every
  classification has its own key space, per brief §3g remedy 2.
- `validate_external_assets`: `asset validation passed`.

### Two clauses that needed care

`external_path_matches` is now usable here — the JS/TS Packs publish
`qualifier`, so `external.package` and `external.member` are populated — but a
scoped package still cannot be *named* with a `/` in it without
`overlay_audit.py` scoring the rule dead, so the four rules that need it use
`package_prefix: "@tauri-apps"`, which is both audit-clean and correct at
runtime for `@tauri-apps/api` and every `@tauri-apps/plugin-*`.

The import join the brief prefers is used where it is the right tool: the
Rust builder rule gates on `fact_join_by_field` over `call.macro` in the same
path, because `run`, `plugin`, `manage` and `setup` are otherwise the most
ordinary method names in the language.

## A field only the Pack can supply

Three, in the order they cost coverage.

**omega-javascript / omega-typescript / omega-tsx, `call.function`: the first
string argument.** `invoke("greet")`, `listen("saved")` and `emit("ready")` put
the whole answer — *which command*, *which event* — in argument 0, and no JS/TS
Pack publishes call arguments. Neither a built-in name nor a join can reach it:
the argument is not a declaration, so nothing spans it and `fact_join_by_span`
has nothing to bind; `definition.name` is the callee. Without it, the three IPC
rules can state the call site and not what it calls, and `tauri:command:{name}`
cannot exist as a key that a Rust command and a JS invocation would both land
on. This is the same shape as the `OWED` row for Go's `app.Get("/users/:id", h)`.

**omega-rust, `reference.attribute`: which item the attribute decorates.**
Measured with `dump_call_emissions` on
`#[tauri::command] fn greet(name: &str) -> String { … }`: the Pack emits
`reference.attribute name=command` spanning bytes 54–68 (the `attribute` node)
and `definition.function name=greet` spanning 70–130. tree-sitter-rust makes
`attribute_item` a **sibling** of the item it decorates, not its parent, so the
two spans are disjoint and `fact_join_by_span` with `within` binds nothing in
either direction; `definition.container` for the attribute is the enclosing
`impl` block or nothing at all. The Pack already solves this once — the
`derive.owner` capture anchors `#[derive(..)]` to the declaration that follows
it — so the ask is to anchor `reference.attribute` the same way, either by
spanning the attribute run together with its item or by publishing the
decorated item's name as a field. Until then *which functions are Tauri
commands* is unanswerable and this overlay does not pretend otherwise. (The
attribute's name is also only the last path segment, `command`, not
`tauri::command`, so even the file-level signal would not distinguish Tauri's
attribute from clap's.)

**omega-json / omega-json5 / omega-toml, `definition.config_key`: `value` is an
attribute, not a field.** This is the row already recorded in `00-INDEX.md`
from wave 1. It costs this framework the window **label** in
`tauri.conf.json`, the capability **identifier**, and `productName` /
`identifier` / `version`: an attribute can only be compared to one literal
constant, so none of them can be a canonical key, an entity attribute or a
relation end. The window label survives only because capability files list
labels in an *array*, and an array element is a `relation.data` **name**. Move
`value` from `attributes` to `fields` — the same bytes in a different map — and
`tauri:window:{label}` would be minted by the config file too, joining the
config declaration to the capability that targets it.

## Still to decide

**`tauri.backend.entry` mints an entity and no relation.** It is the hub
`tauri.backend.builder` points at, and it answers *which file assembles this
app*, which is a real question in a workspace with several binaries — but it is
the one rule here whose output is a single entity. If the Rust attribute anchor
above ever lands, it becomes the natural source of a `declares` edge to each
`#[tauri::command]` function and the question disappears.

**`[dependencies.tauri-plugin-fs]` is not covered.** omega-toml names that
section `definition.config_table dependencies.tauri-plugin-fs`, so the crate
name is a suffix of the table name rather than a key inside it, and a canonical
key template has no strip (brief §3j). Covering it would mean a second rule
minting `tauri:crate:dependencies.tauri-plugin-fs`, a key the inline spelling
never produces — two entities for one crate. Left out deliberately; it is the
same defect `00-INDEX.md` records against axum.

**The Tauri config and the Cargo manifest are not joined to each other or to
the frontend.** Both are per-path hubs. A project-level hub (`tauri:app`, no
path) would join them, but it merges every Tauri app in a monorepo into one
entity, and nothing in the facts distinguishes them. Left as separate hubs.
