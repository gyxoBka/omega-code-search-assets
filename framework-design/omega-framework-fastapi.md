# omega-framework-fastapi

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

22 overlay rules, 4 detection rules. **6 can match, 16 cannot.**

Selector: `framework:fastapi`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `RequestParameter` | 4 |
| `RequestBody` | 4 |
| `Handler` | 3 |
| `Route` | 2 |
| `Dependency` | 2 |
| `Middleware` | 2 |
| `LifecycleHook` | 2 |
| `ApiUse` | 1 |
| `Router` | 1 |
| `ModelReference` | 1 |
| `HttpResponseContract` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 9 |
| `handles` | 4 |
| `mounts` | 1 |
| `injects` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `uses_model` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.direct` | 9 | **no** |
| `reference.decorator` | 8 | yes |
| `call.member` | 2 | yes |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `definition.python_from_import_constructor_binding_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x22, `external_path_matches` x22, `field_present` x4, `field_equals` x2.

Fields read: `source.start`, `decorator.arg0`, `decorator.kwarg.response_model`, `decorator.kwarg.status_code`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `fastapi.depends` | kind `call.direct` |
| `fastapi.generic-api-call.fastapi` | kind `call.target_candidate` |
| `fastapi.generic-dependency.fastapi` | kind `import.target_candidate` |
| `fastapi.api-router.construct` | kind `definition.python_from_import_constructor_binding_context` |
| `fastapi.request.query` | kind `call.direct` |
| `fastapi.request.path` | kind `call.direct` |
| `fastapi.request.header` | kind `call.direct` |
| `fastapi.request.cookie` | kind `call.direct` |
| `fastapi.request.body` | kind `call.direct` |
| `fastapi.request.form` | kind `call.direct` |
| `fastapi.request.file` | kind `call.direct` |
| `fastapi.request.uploadfile` | kind `call.direct` |
| `fastapi.event.startup` | field `decorator.arg0` |
| `fastapi.event.shutdown` | field `decorator.arg0` |
| `fastapi.response-model` | field `decorator.kwarg.response_model` |
| `fastapi.status-code` | field `decorator.kwarg.status_code` |

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
