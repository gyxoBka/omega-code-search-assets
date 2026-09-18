# omega-framework-tokio

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

27 overlay rules, 4 detection rules. **0 can match, 27 cannot.**

Selector: `framework:tokio`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Task` | 5 |
| `Resource` | 4 |
| `NetworkResource` | 4 |
| `Channel` | 3 |
| `Timer` | 3 |
| `RuntimeComponent` | 2 |
| `Join` | 2 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `TaskYield` | 1 |
| `Select` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_resource` | 13 |
| `configured_by` | 8 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 19 | **no** |
| `call.macro_scoped` | 3 | **no** |
| `reference.rust_function_scoped_attribute_context` | 1 | **no** |
| `reference.rust_two_segment_scoped_call_context` | 1 | **no** |
| `definition.rust_scoped_constructor_binding_context` | 1 | **no** |
| `reference.rust_three_segment_scoped_call_context` | 1 | **no** |
| `import.module_path_candidate` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x27, `external_path_matches` x23, `field_equals` x8, `field_present` x5, `path_glob` x4, `field_in` x2.

Fields read: `call_root`, `source.start`, `call_member`, `attribute_path`, `function_name`, `call_module`, `type_name`, `constructor_name`, `binding_name`, `call_namespace`.

Path globs: `**/*.rs`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `tokio.runtime-main.scoped-attribute` | kind `reference.rust_function_scoped_attribute_context`; field `attribute_path`, `function_name` |
| `tokio.explicit-spawn-task-site` | kind `reference.rust_two_segment_scoped_call_context`; field `call_member`, `call_root` |
| `tokio.explicit-sync-resource-binding` | kind `definition.rust_scoped_constructor_binding_context`; field `binding_name`, `call_module`, `call_root`, `constructor_name`, `type_name` |
| `tokio.explicit-task-module-spawn` | kind `reference.rust_three_segment_scoped_call_context`; field `call_member`, `call_namespace`, `call_root` |
| `tokio.generic-api-call.tokio` | kind `call.target_candidate` |
| `tokio.generic-dependency.tokio` | kind `import.module_path_candidate` |
| `tokio.task.spawn` | kind `call.target_candidate` |
| `tokio.task.spawn_blocking` | kind `call.target_candidate` |
| `tokio.task.yield_now` | kind `call.target_candidate` |
| `tokio.macro.select` | kind `call.macro_scoped` |
| `tokio.macro.join` | kind `call.macro_scoped` |
| `tokio.macro.try_join` | kind `call.macro_scoped` |
| `tokio.resource.tokio-sync-mpsc-channel` | kind `call.target_candidate` |
| `tokio.resource.tokio-sync-oneshot-channel` | kind `call.target_candidate` |
| `tokio.resource.tokio-sync-broadcast-channel` | kind `call.target_candidate` |
| `tokio.resource.tokio-time-sleep` | kind `call.target_candidate` |
| `tokio.resource.tokio-time-interval` | kind `call.target_candidate` |
| `tokio.resource.tokio-net-tcplistener` | kind `call.target_candidate` |
| `tokio.timer.timeout` | kind `call.target_candidate` |
| `tokio.network.tcpstream` | kind `call.target_candidate` |
| `tokio.network.udpsocket` | kind `call.target_candidate` |
| `tokio.network.unixstream` | kind `call.target_candidate` |
| `tokio.fs.file` | kind `call.target_candidate` |
| `tokio.process.command` | kind `call.target_candidate` |
| `tokio.signal.ctrl_c` | kind `call.target_candidate` |
| `tokio.runtime.builder` | kind `call.target_candidate` |
| `tokio.task.joinset` | kind `call.target_candidate` |

## What was wrong with it

**27 overlay rules, 0 of which could match a fact any Pack emits.** The whole
file was keyed to the generator's pre-rewrite Rust vocabulary:

| dead fact kind | rules | what states the same thing now |
|---|---|---|
| `call.target_candidate` | 19 | `call.path`, `call.method` |
| `call.macro_scoped` | 3 | `call.macro` |
| `reference.rust_function_scoped_attribute_context` | 1 | `reference.attribute` |
| `reference.rust_two_segment_scoped_call_context` | 1 | `call.path` |
| `reference.rust_three_segment_scoped_call_context` | 1 | `call.path` |
| `definition.rust_scoped_constructor_binding_context` | 1 | nothing -- see below |
| `import.module_path_candidate` | 1 | `import.use` |

Four of those seven kinds were Rust's private spelling of a construct every
language now spells the same way, and none of the seven survives in any Pack.

It also read **ten fields no Pack publishes** -- `call_root`, `call_member`,
`call_module`, `call_namespace`, `attribute_path`, `function_name`,
`type_name`, `constructor_name`, `binding_name`, plus `source.start` (the one
built-in among them). **omega-rust publishes no `fields` on any of its 71
templates** -- its only `attributes` entry is `path` on `import.alias`, and an
attribute is write-only -- so every one of those reads was already answering
nothing. The whole overlay had only kind, name, path and span to work with and
was written as though it had a parsed call path.

Three structural faults beyond the dead kinds:

1. **23 of 27 rules carried `external_path_matches` with `package: "tokio"`.**
   `external_environment` resolves a fact's external identity from a
   `receiver`/`object`/`call_root` field plus a `member`/`call_member` field,
   or from an alias table keyed on `qualifier`. omega-rust publishes none of
   those, so `external.package` is `None` on every Rust fact and all 23 clauses
   were false for every possible input. This is the Rust half of `OWED.md`
   item 7a, which recorded the same for JS/TS.
2. **All 23 relations were self-loops.** Every one of them was
   `source: current` -> `target: by_canonical_key` rendering the *same*
   template the rule's own single entity output had just minted. So
   `tokio.task.spawn` emitted `Task uses_resource Task` over one byte offset,
   and `tokio.generic-dependency.tokio` emitted
   `tokio:dependency:tokio depends_on tokio:dependency:tokio`. Nothing was
   connected to anything; the remaining 4 rules emitted a bare entity with no
   relation at all. There was no entity for the function a task is spawned
   from, so *which function spawns this* could not be asked. This is the
   `Pipeline contains Pipeline` defect wave 2 found in gitlab-ci, at 23 of 23
   instead of 3 -- and `overlay_audit.py` cannot see it.
3. **The 19 `call.target_candidate` rules were one rule per tokio API name.**
   They differed only in the name matched and the entity kind emitted. One
   `field_in` on `definition.name` states each family once.

Deleted rather than ported: `tokio.explicit-sync-resource-binding` (it wanted a
binding name, a type name and a constructor name from one fact -- omega-rust
emits a call and a definition separately and joins them only by span, and a
`let` binding is not a fact at all), `tokio.task.yield_now` (a `yield_now` site
restates its own input and answers no question about structure), and
`tokio.fs.file` / `tokio.process.command` (`File` and `Command` as bare type
names are overwhelmingly `std::fs` and `std::process`; claiming them for tokio
would be inventing a fact).

**27 rules became 14, all live.**

## What it states now

Two shared joins carry the file. The eleven site rules carry both; the two
file-level rules (`tokio.runtime.entrypoint`, `tokio.facility.import`) carry
only the second, because an attribute item and a `use` declaration are not
inside any function; `tokio.crate.dependency` carries neither, because it *is*
the second one's target.

- `fact_join_by_span` / `within` on `definition.function`, bound `owner` -- the
  function the site is written in. This is what makes the graph connected, and
  it needs no Pack field.
- `fact_join_by_path_ancestor` on `definition.config_key`, bound `cargo`, whose
  `where` is character-for-character the match of `tokio.crate.dependency`: a
  key named `tokio` in a `**/Cargo.toml`, inside a `definition.config_table`
  named `dependencies`, `dev-dependencies`, `build-dependencies`,
  `workspace.dependencies` or `target.dependencies`, whose `path.dir` is a
  directory ancestor of this source file. Because omega-rust drops the
  qualifier of every scoped path, **this join is the only evidence the overlay
  has that a `spawn` is tokio's `spawn`**, and every rule is gated on it.

| what it answers | Pack fact it reads | entity / relation |
|---|---|---|
| which crates in this workspace depend on tokio | omega-toml `definition.config_key` named `tokio`, `within` a `definition.config_table` named `dependencies`/`dev-dependencies`/`build-dependencies`/`workspace.dependencies`/`target.dependencies`, in `**/Cargo.toml` | `TokioCrate` `tokio:crate:{path.dir}` |
| where the runtime is entered from a synchronous `main` | omega-rust `reference.attribute` named `main` | `RuntimeEntrypoint` -> `depends_on` -> `TokioCrate` |
| which tokio facilities a file pulls in (mpsc, oneshot, broadcast, watch, Notify, JoinSet, the socket types, the `AsyncRead/Write` traits) | omega-rust `import.use` | `TokioFacility` -> `depends_on` -> `TokioCrate` |
| which function spawns a background task | `call.path` named `spawn`/`spawn_blocking`/`spawn_local` + `owner` | `AsyncFunction` -> `spawns` -> `Task` |
| which function spawns onto a `JoinSet` or a `Handle` | `call.method` named `spawn`/`spawn_blocking`/`spawn_local` + `owner` | `AsyncFunction` -> `spawns` -> `Task` |
| where the runtime is configured | `call.path` named `new_multi_thread`/`new_current_thread` + `owner` | `AsyncFunction` -> `uses_runtime` -> `RuntimeComponent` |
| where synchronous code enters the runtime | `call.method` named `block_on` + `owner` | `AsyncFunction` -> `uses_runtime` -> `RuntimeComponent` |
| which function creates a channel | `call.path` named `channel`/`unbounded_channel` + `owner` | `AsyncFunction` -> `uses_resource` -> `Channel` |
| which function waits on the clock or bounds a future in time | `call.path` named `sleep`/`sleep_until`/`interval`/`interval_at`/`timeout`/`timeout_at` + `owner` | `AsyncFunction` -> `uses_resource` -> `Timer` |
| which function listens for shutdown | `call.path` named `ctrl_c` + `owner` | `AsyncFunction` -> `uses_resource` -> `SignalHandler` |
| which function awaits several futures at once | `call.macro` named `select`/`join`/`try_join` + `owner` | `AsyncFunction` -> `awaits` -> `ConcurrencySite` |
| which function declares or returns a task handle | `reference.type` named `JoinHandle`/`JoinSet`/`LocalSet`/`AbortHandle` + `owner` | `AsyncFunction` -> `uses_resource` -> `TaskHandle` |
| which function holds a synchronization primitive or a channel end | `reference.type` named `Mutex`/`RwLock`/`Semaphore`/`Notify`/`Barrier`/`Sender`/`Receiver`/`UnboundedSender`/`UnboundedReceiver` + `owner` | `AsyncFunction` -> `uses_resource` -> `SyncPrimitive` |
| which function handles a socket | `reference.type` named `TcpListener`/`TcpStream`/`UdpSocket`/`UnixListener`/`UnixStream` + `owner` | `AsyncFunction` -> `uses_resource` -> `NetworkResource` |

Canonical keys minted: `tokio:crate:{path.dir}`, `tokio:entry:{path}:{source.start}`,
`tokio:facility:{path}:{definition.name}`, `tokio:fn:{path}:{owner.definition.name}`,
`tokio:task:`, `tokio:runtime:`, `tokio:channel:`, `tokio:timer:`, `tokio:signal:`,
`tokio:concurrency:`, `tokio:handle:`, `tokio:sync:`, `tokio:net:` (each
`:{path}:{source.start}`). Keys addressed by a relation: the same set, minus none.
Every site rule mints its `AsyncFunction` in the same rule that addresses it, and
`tokio.runtime.entrypoint` and `tokio.facility.import` each mint the `TokioCrate`
they point at, so no relation end is a key nothing creates. The site entity is
the **first** output of every site rule, so `Reference::Current` addresses the
site and not the function.

`detection_rules` is unchanged: it is the atom/row program, it reads
`binding.specifier`, `reference.name` and `contract.identity`, and nothing it
says became untrue.

## A field only the Pack can supply

**Pack `omega-rust`, kinds `call.path`, `reference.attribute`, `reference.path`
and `import.use`; field `qualifier` -- the scoped path in front of the name.**

`queries.scm` captures only the final `(identifier)` of a `scoped_identifier`,
so `tokio::spawn(..)`, `rayon::spawn(..)` and `thread::spawn(..)` are three
emissions of `call.path` named `spawn` and nothing distinguishes them.
Likewise `#[tokio::main]` and `#[main]` are both `reference.attribute` named
`main`, and `use tokio::sync::mpsc` and `use std::sync::mpsc` are both
`import.use` named `mpsc`.

Neither of the two cheaper options reaches it:

- **No built-in name carries it.** `definition.name` is the emission's own name,
  `definition.qname` is the chain of enclosing *definitions*, and
  `external.package` is `None` on every Rust fact -- `external_environment`
  builds its alias table from a `qualifier` field or a
  `receiver`+`member` field pair, and omega-rust publishes no field at all.
- **No join reaches it.** `fact_join_by_span` can only bind a fact the Pack
  emits, and the Pack emits nothing covering the `tokio::` segment of
  `tokio::spawn`: it is an `(identifier)` inside the `scoped_identifier` that
  no pattern captures. `fact_join_by_field` needs a published field on both
  sides, and there is none.

The workaround in this file -- gating every rule on a `Cargo.toml` tokio
dependency reached by `fact_join_by_path_ancestor` -- proves the crate uses
tokio, not that *this* call is tokio's. Publishing `qualifier` as a **field**
(not an attribute: `OverlayFact::field` never consults `attributes`) on those
four kinds would make `tokio.task.spawn`, `tokio.channel.create`,
`tokio.time.timer`, `tokio.sync.primitive`, `tokio.net.resource` and
`tokio.runtime.entrypoint` exact instead of crate-scoped, would let
`#[tokio::test]` be matched at all, and would give `external_environment` the
one input it needs to resolve Rust externals -- which is `OWED.md` item 7a for
Rust, and is the same `qualifier` row already recorded there for JS/TS.

## Still to decide

1. **Is a crate-scoped gate honest enough?** `Mutex`, `RwLock`, `Sender`,
   `Receiver`, `channel`, `sleep`, `timeout`, `bind`, `spawn`, `select!` and
   `join!` all exist outside tokio. In a crate that depends on tokio these
   rules will report some `std`, `parking_lot`, `crossbeam` and `futures` uses
   as tokio ones. The alternative is to match nothing at all until the Pack
   publishes `qualifier`. The choice taken here is to report the site, name the
   ambiguity in every rule's `coverage_note`, and keep the entity kinds neutral
   (`SyncPrimitive`, not `TokioMutex`). If the graph is expected to be exact
   rather than indicative, the six ambiguous rules should be deleted and the
   Pack change taken first.
2. **`target.'cfg(unix)'.dependencies`.** The dependency-table filter is a
   `field_in` over five literal spellings. omega-toml names a table by its full
   dotted key, so platform-conditional dependency tables -- whose middle
   segment is an arbitrary quoted `cfg` expression -- cannot be enumerated and
   are not matched. A `field_suffix` clause would fix it; there is none in
   `overlay.rs`.
3. **Two same-named methods in one file.** `AsyncFunction` is keyed
   `tokio:fn:{path}:{owner.definition.name}`, so `impl A { fn run() }` and
   `impl B { fn run() }` in one file collapse to one entity. The span would
   separate them, but `definition.function` and `scope.function_body` have
   different spans for the same function, and both are needed (a
   `reference.type` in a signature is outside the body). Keying on the name
   keeps every rule addressing the same key; the collapse is the price.
