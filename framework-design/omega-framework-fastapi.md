# omega-framework-fastapi

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 4 detection rules. All 12 can match.** (Was 22 rules, 6 live,
16 dead.)

Selector: `framework:fastapi`. Maturity: `semantic-overlay-full`.
Language: Python only — every rule reads `omega-python`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ApiModule` | 12 (the hub every rule mints) |
| `Handler` | 3 |
| `Application`, `Router`, `RouterMount`, `Route`, `LifecycleHook`, `Middleware`, `ExceptionHandler`, `RequestParameter`, `DependencyInjection`, `HttpResponseContract`, `SecurityScheme`, `SchemaModel` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 9 |
| `contains` | 2 |
| `injects` | 1 |
| `mounts` | 1 |
| `produces` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.function` | 6 | yes |
| `reference.decorator` | 3 | yes |
| `call.method` | 2 | yes |
| `relation.implements` | 1 | yes |

Joined kinds: `import.from_module` (11), `definition.variable` (3),
`definition.function` (3), `call.method` (3, `same` span),
`definition.class` (1).

Clause vocabulary: `fact_kind` x12, `path_glob` x12, `field_in` x8,
`fact_join_by_field` x11, `fact_join_by_span` x9, `field_equals` x4.

Fields read in match clauses: `definition.name` and `path` only — both
built-ins. **The overlay asks omega-python for no published field at all**,
which is just as well: omega-python publishes none.

---

## What was wrong with it

Measured with `python pack-design/overlay_audit.py fastapi`, with
`dump_call_emissions` over `packs/omega-python` on a hand-written FastAPI
module, and by reading `overlay.rs`, `materialize.rs::external_environment` and
`content_builder.rs::mention_fields`.

**16 of 22 rules could not match, and the other 6 could not match either.**

1. **Nine rules were keyed to `call.direct`** — `fastapi.depends` plus the eight
   `fastapi.request.*` rules. No Pack has emitted that kind since the language-Pack
   rewrite; `call.function` states the same thing. The eight request rules were
   byte-identical apart from one string in a `member_in` list of length one
   (`Query`, `Path`, `Header`, `Cookie`, `Body`, `Form`, `File`, `UploadFile`).
   They are now **one** rule with a seven-name `field_in`, and `UploadFile` is
   dropped because it is a type annotation, not a call — omega-python emits it as
   `type_use.name`.
2. **Three rules were keyed to carrier kinds the host never folded**:
   `call.target_candidate` (`generic-api-call`), `import.target_candidate`
   (`generic-dependency`) and
   `definition.python_from_import_constructor_binding_context`
   (`api-router.construct`). The first two were also the self-loop shape wave 2
   and wave 6 found: `uses_api`/`depends_on` ran from `current` to the key
   `current` had just been minted under, so each stated only "fastapi is
   imported here", which is the detector's job and is already in
   `detection_rules`. Both are deleted rather than ported.
3. **Four rules read a Pack field that does not exist**: `decorator.arg0`
   (`event.startup`, `event.shutdown`), `decorator.kwarg.response_model`
   (`response-model`) and `decorator.kwarg.status_code` (`status-code`).
   **omega-python publishes no `fields` on any of its 30 templates.** The two
   event rules collapse into one `fastapi.lifecycle.event` that states the hook
   without its phase; the two keyword rules are deleted, and the loss is written
   into `coverage.gaps`.
4. **All 22 rules carried `external_path_matches` with `package: "fastapi"`, and
   every one of them was unreachable — including the 6 the audit called live.**
   `facts_of_surface` builds `OverlayFact.external` from
   `external_environment`, which registers only a binding whose `target_hint` is
   set; `target_hint` is `occurrence.qualifier`; and `mention_fields` reads a
   qualifier only from an emission field or attribute literally named
   `qualifier`. `grep -c qualifier packs/omega-python/rules.json` is **0** — the
   Pack publishes `module` and `target` instead. So **no Python fact carries an
   external package path at all**, and this overlay matched nothing whatsoever
   before the rewrite. This is `OWED.md` item 7a, previously recorded for JS/TS
   only; it holds for Python identically and is the cross-framework finding of
   this rewrite.
5. **Four relations were unreachable by construction.** `include_router` and
   `depends` targeted `by_field: call.arg0`, a field no Pack emits, so the
   relation end never rendered. `exception_handler` targeted
   `by_field: decorator.arg0`, likewise. The old `route.decorator` minted a
   `Handler` at `fastapi:handler:{definition.qname}` — but the fact is the
   *decorator*, and a decorator's `definition.qname` is the decorator's own
   name, so `@app.get(...)` minted a handler called `get` and pointed `handles`
   at it.
6. **Two entities only restated their input**: `ApiUse`
   (`fastapi:api-use:{path}:{source.start}`, attributes `package: "fastapi"`)
   and `HttpResponseContract` keyed on the status-code literal it had just read.

Counts: 22 rules -> 12; 9 `call.direct` rules -> 2; 8 request-parameter
spellings -> 1; 2 lifecycle spellings -> 1; 22 `external_path_matches`
clauses -> 0; 4 dangling or self-looping relations -> 0.

### Two things measured, not assumed

`dump_call_emissions.exe packs/omega-python grammars/omega-python app.py` on a
module containing every FastAPI construct:

- `@app.get("/items/{item_id}")` emits **`reference.decorator get`** and
  **`call.method get`** at the *same* span (the bare identifier `get`). The path
  string is not emitted, and neither is the receiver `app`. The route rule joins
  the two at `relation: same` so that a bare `@get` decorator, which produces no
  `call.method`, does not match.
- The decorator's span ends before `def` begins: `reference.decorator get` at
  215-218, `definition.function read_item` at 277-385. `function_definition`
  does not include its decorators — `decorated_definition` encloses both
  separately — so **no span join relates a decorator to the function it
  decorates**, in either direction. Django's file records the same measurement.
- What *is* within the function span: `Query(...)` at 320-325 and
  `Depends(...)` at 336-343 both lie inside `read_item` at 277-385, because they
  are default values in the parameter list. That join is what makes the
  handler-to-parameter and handler-to-dependency edges real.
- `app = FastAPI()` emits `definition.variable app` over the whole assignment
  (129-144) with `call.function FastAPI` inside it (135-142), so the application
  object's variable name is reachable by a `within` join. Same for
  `router = APIRouter(...)`.

---

## What it states now

Every rule mints `ApiModule` at `fastapi:module:{path}` as its hub, so no
relation end addresses a key that the same rule did not mint. No rule uses
`Reference::Current`; every end is an explicit `by_canonical_key`.

Each rule but one carries a same-file **import gate** —
`fact_join_by_field` on `import.from_module` with `path == path` and
`field_prefix definition.name "fastapi"` — which is the only way left to say
"this name came from FastAPI" now that `external.*` is empty for Python.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Where is the ASGI app created, and what is the variable `uvicorn main:app` names? | `call.function` **FastAPI** joined `within` `definition.variable` | `Application` `fastapi:app:{path}:{var}`; `ApiModule` *declares* it |
| Which routers does this project declare, and in which module? | `call.function` **APIRouter** joined `within` `definition.variable` | `Router` `fastapi:router:{path}:{var}`; `ApiModule` *declares* it |
| Where is a router composed into another? | `call.method` **include_router** | `RouterMount`; `ApiModule` *mounts* it |
| Where are the HTTP and WebSocket endpoints, and what method does each use? | `reference.decorator` in {get, post, put, patch, delete, options, head, trace, api_route, websocket, websocket_route}, confirmed by a `same`-span `call.method` | `Route` with `method`; `ApiModule` *contains* it |
| Does this app register startup/shutdown work, and where? | `reference.decorator` **on_event** | `LifecycleHook`; `ApiModule` *declares* it |
| What middleware is installed, and written which way? | `call.method` in {middleware, add_middleware} | `Middleware` with `form`; `ApiModule` *declares* it |
| Which exceptions get a custom handler, and where? | `reference.decorator` in {exception_handler, add_exception_handler} | `ExceptionHandler`; `ApiModule` *declares* it |
| **Which inputs does this handler read, and from query, path, header, cookie, body, form or file?** | `call.function` in {Query, Path, Header, Cookie, Body, Form, File} joined `within` `definition.function` | `RequestParameter` with `source`; `Handler` *contains* it |
| **Which handlers use dependency injection or a security dependency?** | `call.function` in {Depends, Security} joined `within` `definition.function` | `DependencyInjection` with `form`; `Handler` *injects* it |
| What kind of response does this handler build — JSON, a redirect, a stream, a file? | `call.function` in the eight Starlette response classes joined `within` `definition.function` | `HttpResponseContract` with `response_class`; `Handler` *produces* it |
| How does this API authenticate? | `call.function` in the ten `fastapi.security` scheme classes joined `within` `definition.variable` | `SecurityScheme` with `scheme` and its variable name; `ApiModule` *declares* it |
| Which classes are the request/response schemas? | `relation.implements` in {BaseModel, BaseSettings, RootModel} joined `within` `definition.class`, gated on a `pydantic` import | `SchemaModel` with `base`; `ApiModule` *declares* it |

The three rules that reach the enclosing `definition.function` all mint
`Handler` at `fastapi:handler:{path}:{fn}` under identical conditions, so the
key is never addressed by a rule that does not create it.

`fastapi.response.class` is the one rule without the import gate: the response
classes are equally often imported from `starlette.responses`, and their names
are distinctive enough to stand alone. It is `confidence: candidate` for that
reason; the other eleven are `high`.

---

## A field only the Pack can supply

**Pack: omega-python. Kinds: `call.function`, `call.method`,
`reference.decorator`. Field: the call's first argument, when it is a string
literal or an identifier.**

Every unanswered FastAPI question is the same missing field:

| question | what the argument holds |
|---|---|
| which URL does this route serve | `@app.get("/items/{item_id}")` |
| does this hook run at startup or shutdown | `@app.on_event("startup")` |
| what does this handler depend on | `Depends(get_db)` |
| which router is mounted here | `app.include_router(users_router)` |
| which middleware class is installed | `app.add_middleware(CORSMiddleware)` |
| which exception does this handler catch | `@app.exception_handler(HTTPException)` |

Neither route in the contract's order reaches it. It is not derivable from
`definition.name`, `path`, `path.dir`, `path.stem` or `external.*` — the
argument is a sibling node of the callee, not part of any of them. And no join
reaches it, because **omega-python emits no fact for the argument at all**: a
string literal produces nothing, and an identifier argument such as `get_db` in
`Depends(get_db)` produces nothing either (measured — the only emissions inside
`read_item`'s parameter list are `type_use.name int`, `type_use.name str`,
`call.function Query` and `call.function Depends`). There is no span to join
`within` and no field to join by.

This is already `OWED.md` item 1, row *omega-python / `call.function`,
`call.method` / the call's first string-or-identifier argument*, asked by
django. FastAPI asks for the same field and additionally for it on
`reference.decorator`, which django does not need.

**A second, independent Pack change**, and the one that matters more:

**Pack: omega-python. Kind: `binding.import_alias` (and `import.symbol`).
Field: `qualifier`.** omega-python publishes the imported module as an
attribute named `module` (for `import a.b as c`) or `target` (for
`from a.b import c as d`). The host reads a qualifier only under the literal
name `qualifier` (`content_builder.rs::mention_fields`), so no Python binding
gets a `target_hint`, `external_environment` is empty for every Python artifact,
and `OverlayFact.external` is `None` on every Python fact. **Every
`external_path_matches` clause in every Python framework overlay fails for every
possible input.** This is `OWED.md` item 7a, recorded there for JavaScript and
TypeScript; it is true of Python for exactly the same reason. It is the same
bytes in a different map, and it would let this overlay say *this `Path` is
FastAPI's, not `pathlib`'s* instead of gating on a same-file import.

Also worth noting for the same eventual pass: omega-python's
`binding.import_alias` values are in `attributes`, which the overlay can only
compare against one literal constant. They need to be in `fields` regardless.

---

## Still to decide

1. **Is a Pydantic model FastAPI's to declare?** `fastapi.schema.model` matches
   `pydantic` bases in a project detected as FastAPI. It is the right answer to
   *which model backs this endpoint* as far as the Packs can go, but if an
   `omega-framework-pydantic` is ever written the two will mint the same classes
   under different keys. Kept here because FastAPI is the reason anyone asks.
2. **`Path` and `File` are ambiguous names.** `fastapi.request.parameter`
   matches `call.function Path` inside a function in a file that imports from
   `fastapi`. `pathlib.Path(...)` in such a file is a false positive, and the
   import gate cannot tell the two apart because `from pathlib import Path` and
   `from fastapi import Path` both emit `import.symbol Path`. Dropping the two
   names would lose the genuinely common `item_id: int = Path(...)`. Kept, with
   the ambiguity in `coverage.gaps`; the `qualifier` field above resolves it
   properly.
3. **The factory pattern is not seen.** `definition.variable` is emitted for
   module-level assignments only, so `def create_app(): app = FastAPI()` states
   nothing. Reaching it would mean matching `call.function FastAPI` with no
   variable join at all, which mints an `Application` with no name — an entity
   that restates its input. Left unstated.
