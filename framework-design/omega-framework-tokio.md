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
