# omega-framework-tauri

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **0 can match, 14 cannot.**

Selector: `framework:tauri`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `PlatformComponent` | 3 |
| `Resource` | 3 |
| `Configuration` | 2 |
| `Command` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `CommandInvocation` | 1 |
| `EventSubscription` | 1 |
| `EventEmission` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_api` | 2 |
| `depends_on` | 1 |
| `calls` | 1 |
| `handles` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 8 | **no** |
| `call.member` | 3 | yes |
| `reference.rust_function_scoped_attribute_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |

Clause vocabulary in use: `field_present` x16, `fact_kind` x14, `field_equals` x12, `path_glob` x9, `attribute_equals` x8, `external_path_matches` x5.

Fields read: `key`, `value`, `call.arg0`, `parent_key`, `array_key`, `source.start`, `attribute_path`, `function_name`, `container`.

Path globs: `**/tauri*.conf.json5`, `**/Tauri.toml`, `**/*.rs`, `**/tauri*.conf.json`, `**/capabilities/*.json`, `**/capabilities/*.json5`, `**/capabilities/*.toml`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `tauri.command.scoped-attribute` | kind `reference.rust_function_scoped_attribute_context`; field `attribute_path`, `function_name` |
| `tauri.window.config` | kind `structured.entry`; field `array_key`, `key`, `parent_key`, `value`; attribute `role` |
| `tauri.capability.config` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `tauri.generic-api-call.tauri` | kind `call.target_candidate` |
| `tauri.generic-dependency.tauri` | kind `import.target_candidate` |
| `tauri.invoke` | field `call.arg0` |
| `tauri.event.listen` | field `call.arg0` |
| `tauri.event.emit` | field `call.arg0` |
| `tauri.window.config-json5` | kind `structured.entry`; field `array_key`, `key`, `parent_key`, `value`; attribute `role` |
| `tauri.capability.config-json5` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `tauri.window.config-toml` | kind `structured.entry`; field `container`, `key`, `value`; attribute `role` |
| `tauri.capability.config-toml` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `tauri.config.toml-entry` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `tauri.config.json5-entry` | kind `structured.entry`; field `key`, `value`; attribute `role` |

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
