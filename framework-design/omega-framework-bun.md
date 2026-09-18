# omega-framework-bun

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **10 can match, 10 cannot.**

Selector: `framework:bun`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `RuntimeComponent` | 4 |
| `Task` | 3 |
| `ApiUse` | 3 |
| `Resource` | 2 |
| `ProcessTask` | 2 |
| `Handler` | 2 |
| `Dependency` | 1 |
| `FileWrite` | 1 |
| `Listener` | 1 |
| `Connection` | 1 |
| `FileResource` | 1 |
| `ConfigNamespace` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_api` | 5 |
| `configured_by` | 5 |
| `handles` | 3 |
| `uses_resource` | 3 |
| `uses` | 2 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 10 | yes |
| `data.ecmascript_root_member_object_identifier_context` | 3 | **no** |
| `reference.ecmascript_root_member_call_context` | 2 | **no** |
| `call.target_candidate` | 2 | **no** |
| `data.ecmascript_root_member_string_argument_context` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.ecmascript_root_member_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x20, `field_equals` x17, `field_present` x17, `external_path_matches` x13.

Fields read: `source.start`, `call_root`, `call_member`, `field_key`, `value_identifier`, `arg0`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `bun.source-authored.spawn-task` | kind `reference.ecmascript_root_member_call_context`; field `call_member`, `call_root` |
| `bun.source-authored.file-resource` | kind `data.ecmascript_root_member_string_argument_context`; field `arg0`, `call_member`, `call_root` |
| `bun.source-authored.serve-runtime-component` | kind `reference.ecmascript_root_member_call_context`; field `call_member`, `call_root` |
| `bun.source-authored.serve-fetch-handler` | kind `data.ecmascript_root_member_object_identifier_context`; field `call_member`, `call_root`, `field_key`, `value_identifier` |
| `bun.generic-api-call.bun` | kind `call.target_candidate` |
| `bun.generic-dependency.bun` | kind `import.target_candidate` |
| `bun.env` | kind `reference.ecmascript_root_member_context`; field `call_member`, `call_root` |
| `bun.sqlite.database-constructor` | kind `call.target_candidate` |
| `bun.serve.websocket-handler` | kind `data.ecmascript_root_member_object_identifier_context`; field `call_member`, `call_root`, `field_key`, `value_identifier` |
| `bun.serve.error-handler` | kind `data.ecmascript_root_member_object_identifier_context`; field `call_member`, `call_root`, `field_key`, `value_identifier` |

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
