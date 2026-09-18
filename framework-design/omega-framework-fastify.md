# omega-framework-fastify

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **15 can match, 5 cannot.**

Selector: `framework:fastify`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `FrameworkConfig` | 10 |
| `Decoration` | 3 |
| `Route` | 2 |
| `Handler` | 1 |
| `Plugin` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `FrameworkHook` | 1 |
| `Listener` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 12 |
| `configures` | 3 |
| `depends_on` | 2 |
| `handles` | 1 |
| `mounts` | 1 |
| `uses_api` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 18 | yes |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x20, `external_path_matches` x20, `field_present` x4, `field_equals` x2.

Fields read: `call.member`, `source.start`, `call.last_arg`, `call.arg0`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `fastify.route.verb` | field `call.last_arg` |
| `fastify.route.object` | field `call.member` |
| `fastify.register` | field `call.arg0`, `call.member` |
| `fastify.generic-api-call.fastify` | kind `call.target_candidate` |
| `fastify.generic-dependency.fastify` | kind `import.target_candidate` |

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
