# omega-framework-express

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

19 overlay rules, 4 detection rules. **8 can match, 11 cannot.**

Selector: `framework:express`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Middleware` | 5 |
| `ConfigEntry` | 5 |
| `RouterGroup` | 2 |
| `Route` | 1 |
| `Handler` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Application` | 1 |
| `Router` | 1 |
| `StaticResource` | 1 |
| `Listener` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 6 |
| `handles` | 1 |
| `mounts` | 1 |
| `middleware_wraps` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 11 | yes |
| `call.target_candidate` | 6 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.ecmascript_direct_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x19, `external_path_matches` x18, `field_present` x8, `field_equals` x3, `field_prefix` x1, `field_not_prefix` x1.

Fields read: `source.start`, `call.arg0`, `call.member`, `call_name`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `express.mount.use` | field `call.arg0`, `call.member` |
| `express.middleware.use` | field `call.arg0`, `call.member` |
| `express.generic-api-call.express` | kind `call.target_candidate` |
| `express.generic-dependency.express` | kind `import.target_candidate` |
| `express.app.construct` | kind `call.ecmascript_direct_context`; field `call_name` |
| `express.static.resource` | kind `call.target_candidate` |
| `express.route.builder` | field `call.arg0` |
| `express.middleware-factory.json` | kind `call.target_candidate` |
| `express.middleware-factory.urlencoded` | kind `call.target_candidate` |
| `express.middleware-factory.raw` | kind `call.target_candidate` |
| `express.middleware-factory.text` | kind `call.target_candidate` |

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
