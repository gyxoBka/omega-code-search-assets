# omega-framework-fastapi

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**14 overlay rules, 4 detection rules. All 14 can match, and no canonical key
is minted under more than one kind.** (Wave 6: 22 rules, 6 live, 16 dead.
Wave 7, the first rewrite: 12 rules, 12 live. This is the second pass, written
after omega-python began publishing the canonical call view.)

Selector: `framework:fastapi`. Maturity: `semantic-overlay-full`.
Language: Python only — every rule reads `omega-python`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ApiModule` | 14 (the hub every rule mints) |
| `Handler` | 4 |
| `Route` | 2 |
| `Router`, `ExceptionHandler`, `DependencyProvider` | 2 each |
| `Application`, `LifecycleHook`, `Middleware`, `RequestParameter`, `HttpResponseContract`, `SecurityScheme`, `SchemaModel` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 9 |
| `contains` | 3 |
| `produces` | 2 |
| `handles`, `injects`, `mounts` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 7 | yes |
| `call.function` | 6 | yes |
| `relation.implements` | 1 | yes |

Joined kinds: `import.from_module` (13), `definition.function` (3),
`definition.variable` (3), `reference.decorator` (4, `same` span),
`definition.class` (1).

Fields read: the built-ins `definition.name`, `path`, `path.stem`,
`source.start`, and the six omega-python call fields `call.arg0_text`,
`call.arg0_name`, `call.arg1_name` and `receiver`.

---

## What was wrong with it

The wave-7 file was clean — 12 rules, 12 live, zero key collisions — and it is
not being replaced because a rule was dead. It is being replaced because
**every question it deferred was deferred to one missing Pack field, and that
field now exists.** omega-python publishes `call.arg0`, `call.arg0_text`,
`call.arg0_name`, `call.arg1`/`_text`/`_name`, `call.arg2*`, `call.last_arg*`
and `receiver` on `call.function` and `call.method` (measured with
`dump_call_emissions` — see below).

Measured with `python pack-design/overlay_audit.py fastapi`,
`python pack-design/key_collisions.py fastapi`, and `dump_call_emissions.exe`
over `packs/omega-python` on a hand-written module carrying every FastAPI
construct.

**1. A route had no URL. Five of twelve entities were addressed by a byte
offset.** `fastapi:route:{path}:{source.start}`,
`fastapi:lifecycle:{path}:{source.start}`,
`fastapi:middleware:{path}:{source.start}`,
`fastapi:exception-handler:{path}:{source.start}` and
`fastapi:router-mount:{path}:{source.start}` all named *a place in a file*, not
a thing. Two of them — `RouterMount` and `DependencyInjection` — had no content
at all beyond their offset and the name of the call that produced them, which is
the shape §5 of the contract forbids. **Six rules now key on a published value**
and the Route uses the cross-framework identity
`http:{method}:{normalized_route}`, so `@app.get("/users/{id}")` in FastAPI,
`app.get('/users/:id')` in Express and `/users/[id]` in a file router are one
node.

**2. `coverage.gaps` asserted something that is now false.** The sentence
*"omega-python captures no call argument on `call.function` or `call.method`, so
the URL path of `@app.get(...)`, the phase of `@app.on_event(...)`, the target of
`Depends(...)`, the router passed to `include_router(...)` and the class passed
to `add_middleware(...)` are not stated"* named five answers. **All five are
stated now.** The gap list is rewritten; what remains of it is the keyword
argument (below), the decorator-to-function span, the missing `qualifier`, the
factory pattern and runtime state.

**3. One rule carried a value that could never fire.** `fastapi.exception-handler`
matched `reference.decorator` with `field_in definition.name
["exception_handler", "add_exception_handler"]`. `add_exception_handler` is
never written as a decorator, so half that list matched nothing while the audit
scored the rule live. It is now two rules — the decorator form and the
registration form — and the registration form is the **only** place in this
Framework where a handler edge is reachable, because
`app.add_exception_handler(ValueError, handle_exc)` passes its handler as
`call.arg1_name = handle_exc`, which is exactly the name
`definition.function handle_exc` is declared under.

**4. A Router could not be mounted.** `fastapi.router.declaration` minted
`fastapi:router:{path}:{var}` and `fastapi.router.include` minted an unrelated
`RouterMount`. Nothing joined the two, so *which router does `main.py` include*
had no edge. The Router key is now the variable name —
`fastapi:router:{var.definition.name}` on the declaring side,
`fastapi:router:{call.arg0_name}` on the including side — which is the only
spelling the two sides share across files. `app.include_router(handlers.admin_router)`
reaches `admin_router` because `call.arg0_name` is the **last segment** of the
qualified name; keying on `call.arg0` or `call.arg0_text` would have given
`handlers.admin_router` and met nothing. `RouterMount` is deleted and replaced
by the `mounts` edge itself.

**5. `Depends(get_db)` named nothing.** The old `DependencyInjection` entity was
an offset with the word `Depends` on it. It is now a `DependencyProvider` at
`fastapi:provider:{call.arg0_name}` — name-keyed, so every handler in every
module that injects `get_db` reaches one node, and *what depends on `get_db`*
is a graph question. `fastapi.security.scheme` mints the same key for the
scheme variable, because `oauth2_scheme` is itself written `Depends(oauth2_scheme)`,
and joins the two with `produces`.

**6. The lifecycle phase was a documented loss and is not one any more.**
`@app.on_event("startup")` gives `call.arg0_text = startup`; the hook is keyed
and attributed on its phase.

**7. Two spellings of one construct, written as two rules.** A route path is a
literal in essentially all FastAPI code, but `@app.get(PREFIX + "/x")` exists.
`fastapi.route.decorator` requires `field_prefix call.arg0_text "/"` (FastAPI
itself asserts a route begins with `/`) and states the URL;
`fastapi.route.decorator.computed` takes the complement with
`field_not_prefix` and states the method and the object it was registered on at
its offset. Writing only the first would have been a silent deletion, and
writing only the second would have thrown away the URL — the brief's §3l case.
Collapsing them into one rule is worse than either: a call with no literal
argument renders `http:get:` and every such route in the repository becomes one
entity.

Counts, wave 7 -> now: 12 rules -> 14; 5 offset-only keys -> 1 (the request
parameter, which is positional by nature; the response contract and the computed
route keep an offset too, deliberately); 2 entities that restated their input
-> 0; 0 relation ends that address an unminted key -> 0; 6 gap sentences -> 7,
of which 1 is deleted outright, 2 are narrowed and 1 is new.

### Measured, not assumed

`dump_call_emissions.exe packs/omega-python grammars/omega-python app.py`:

- `@app.get("/items/{item_id}")` emits `call.method get` **and**
  `reference.decorator get` at the same span (530-533). The `call.method`
  carries `call.arg0_text = /items/{item_id}` and `receiver = app`; the
  `reference.decorator` carries **no fields at all** — omega-python's decorator
  template has an empty `fields` map. So the route rules now match the
  `call.method` and use the `reference.decorator` at `relation: "same"` purely
  as the discriminator that says *this is a decorator, not `session.get(url)`*.
  The current fact had to be swapped from the decorator to the call; matching
  the decorator and joining the call would have left `call.arg0_text` reachable
  only as `joined.call.arg0_text`, which works, but the entity reads better
  from the side that owns the value.
- A keyword argument is captured whole and positionally:
  `FastAPI(title="demo")` gives `call.arg0_text = title="demo"`, and
  `@router.post("/users/{uid}", response_model=Item, status_code=201)` gives
  `call.arg1_text = response_model=Item`, `call.arg2_text = status_code=201`.
  There is no clause that splits a field on `=`, so `response_model`,
  `status_code`, `prefix=` and `tokenUrl=` remain unstated. This is the one
  Pack request that survives.
- `Depends(get_db)` gives `call.arg0_name = get_db`; `Path(...)` gives
  `call.arg0_text = ...` and `call.arg0_name = ` (empty — `...` splits to
  nothing on `.`), which is why every rule that keys on an argument carries a
  `field_present` guard on it.
- `app.add_exception_handler(ValueError, handle_exc)` gives
  `call.arg0_name = ValueError`, `call.arg1_name = handle_exc`.
- The decorator span still ends before `def` begins (`reference.decorator get`
  at 530-533, `definition.function read_item` at 554-676), because
  `function_definition` does not include its decorators. **No span join relates
  a decorator to the function it decorates, in either direction.** That has not
  changed and is why a Route still has no handler edge.
- `Query(...)` and `Depends(...)` lie inside the enclosing `definition.function`
  span, because they are parameter default values. That join is what makes the
  handler-to-parameter and handler-to-provider edges real.

---

## What it states now

Every rule mints `ApiModule` at `fastapi:module:{path}` as its hub, and every
relation end is an explicit `by_canonical_key` that some output of the same rule
also mints — no `Reference::Current`, no dangling end. `key_collisions.py`
reports nothing: each key space carries exactly one entity kind, and rules that
share a key (`fastapi:module:`, `fastapi:router:`, `fastapi:handler:`,
`fastapi:exception-handler:`, `fastapi:provider:`) mint it with identical
attributes, so which one sorts first does not matter.

Twelve of the fourteen carry a same-file **import gate** —
`fact_join_by_field` on `import.from_module` with `path == path` and
`field_prefix definition.name "fastapi"` — which is the only way left to say
"this name came from FastAPI" while `external.*` is empty for Python.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Where is the ASGI app created, and what is the variable `uvicorn main:app` names? | `call.function` **FastAPI** joined `within` `definition.variable` | `Application` `fastapi:app:{path}:{var}`; `ApiModule` *declares* it |
| Which routers exist, and in which module is each declared? | `call.function` **APIRouter** joined `within` `definition.variable` | `Router` `fastapi:router:{var}`; `ApiModule` *declares* it |
| **Which router does this module mount, and on what?** | `call.method` **include_router**, `call.arg0_name` + `receiver` | `ApiModule` *mounts* `Router` `fastapi:router:{call.arg0_name}` — the edge that crosses files |
| **Which URL does this endpoint serve, with which method, registered on which object?** | `call.method` in the eleven route verbs, `call.arg0_text` starting `/`, confirmed by a `same`-span `reference.decorator`, `receiver` | `Route` **`http:{method}:{normalized_route}`** with `method`, `route`, `registered_on`; `ApiModule` *contains* it |
| Where is an endpoint whose path is computed rather than written? | the same, with `field_not_prefix call.arg0_text "/"` | `Route` `fastapi:route:{path}:{offset}` with `method` and `registered_on`, no URL |
| **Does this app run work at startup or at shutdown, and where?** | `call.method` **on_event**, `call.arg0_text` | `LifecycleHook` `fastapi:lifecycle:{path}:{phase}` with `phase`; `ApiModule` *declares* it |
| **Which middleware is installed, written which way, on which object?** | `call.method` in {middleware, add_middleware}, `call.arg0_name` | `Middleware` with `form`, `middleware`, `installed_on`; `ApiModule` *declares* it |
| **Which exception gets a custom handler?** | `call.method` **exception_handler** + `same`-span `reference.decorator`, `call.arg0_name` | `ExceptionHandler` `fastapi:exception-handler:{path}:{exception}`; `ApiModule` *declares* it |
| **Which function answers that exception?** | `call.method` **add_exception_handler**, `call.arg0_name` + `call.arg1_name` | `ExceptionHandler` *handles* `Handler` `fastapi:handler:{path}:{call.arg1_name}` — the one handler edge the Packs can reach |
| Which inputs does this handler read, and from query, path, header, cookie, body, form or file? | `call.function` in {Query, Path, Header, Cookie, Body, Form, File} joined `within` `definition.function` | `RequestParameter` with `source`; `Handler` *contains* it |
| **What does this handler inject, and which providers does the whole project depend on?** | `call.function` in {Depends, Security}, `call.arg0_name`, joined `within` `definition.function` | `Handler` *injects* `DependencyProvider` `fastapi:provider:{name}` — name-keyed, so it is shared across modules |
| What kind of response does this handler build — JSON, a redirect, a stream, a file? | `call.function` in the eight Starlette response classes joined `within` `definition.function` | `HttpResponseContract` with `response_class`; `Handler` *produces* it |
| How does this API authenticate, and which provider is the scheme injected as? | `call.function` in the ten `fastapi.security` scheme classes joined `within` `definition.variable` | `SecurityScheme` with `scheme`; `ApiModule` *declares* it, and it *produces* `DependencyProvider` `fastapi:provider:{var}` |
| Which classes are the request/response schemas? | `relation.implements` in {BaseModel, BaseSettings, RootModel} joined `within` `definition.class`, gated on a `pydantic` import | `SchemaModel` with `base`; `ApiModule` *declares* it |

The bold rows are what this pass added; the rest were already stated and are
unchanged apart from their keys.

The four rules that reach an enclosing `definition.function` all mint `Handler`
at `fastapi:handler:{path}:{fn}` with identical attributes and under conditions
they share, so the key is never addressed by a rule that does not create it.

`fastapi.response.class` is the one rule without the import gate: the response
classes are equally often imported from `starlette.responses`, and their names
are distinctive enough to stand alone. It is `confidence: candidate` for that
reason, as is `fastapi.route.decorator.computed`; the other twelve are `high`.

---

## A field only the Pack can supply

**Pack: omega-python. Kinds: `call.function`, `call.method`. Field: the value of
a keyword argument, separately from its keyword.**

This is what is left of the old request. The positional argument fields solved
the rest, but a keyword argument arrives as one string:

| question | what the field holds today |
|---|---|
| what does this endpoint return | `call.arg1_text` = `response_model=Item` |
| what status does it return | `call.arg2_text` = `status_code=201` |
| what prefix does this router carry | `call.arg0_text` = `prefix="/users"` |
| which token URL does this scheme use | `call.arg0_text` = `tokenUrl="token"` |

Neither route in the contract's order reaches the value. It is not derivable
from `definition.name`, `path`, `path.stem` or `external.*`. No join reaches it
either: omega-python emits no fact for a `keyword_argument` node, so there is no
span to join `within` and no field to join by. And the overlay has no string
operation — `fact_join_by_field` offers `current_strip_prefix` and
`join_strip_prefix` and nothing else, so a rule cannot split `response_model=Item`
on `=`, and a canonical key template has no strip at all. The only thing a rule
can do with it is `field_prefix call.arg1 "response_model="`, which tests that a
response model was declared without ever naming it.

The shape that would fix it is the one the call view already uses: a
`call.kwarg.<name>` family, or a pair `call.arg1_key` / `call.arg1_value`
produced by splitting a `keyword_argument` at its `=`. `prefix=` on an
`APIRouter` is the more valuable of the two, because it is the missing piece of
a route's full URL: a `Route` declared on a router with `prefix="/users"` is
served at `/users` + its own path, and the overlay states the second half only.

**A second, independent Pack change, unchanged from the last pass:**

**Pack: omega-python. Kind: `binding.import_alias` (and `import.symbol`).
Field: `qualifier`.** omega-python publishes the imported module as an attribute
named `module` or `target`. The host reads a qualifier only under the literal
name `qualifier` (`content_builder.rs::mention_fields`), so no Python binding
gets a `target_hint`, `external_environment` is empty for every Python artifact,
and `OverlayFact.external` is `None` on every Python fact. **Every
`external_path_matches` clause in every Python framework overlay fails for every
possible input.** This is `OWED.md` item 7a, recorded there for JavaScript and
TypeScript; it holds for Python for exactly the same reason. It is the same
bytes in a different map, and it would let this overlay say *this `Path` is
FastAPI's, not `pathlib`'s* instead of gating on a same-file import. Note also
that omega-python's `binding.import_alias` values live in `attributes`, which
the overlay can only compare against one literal constant; they need to be in
`fields` regardless.

---

## Still to decide

1. **A Router is identified by its variable name, and two modules that both
   call it `router` become one entity.** This is deliberate and it is the whole
   reason the mount edge works: `from .users import router` /
   `app.include_router(router)` gives the including side the name `router` and
   nothing else, so any key carrying the declaring file's path can never meet
   it. The alternative — a path-keyed Router plus a dangling mount — is what the
   last pass had, and it answered nothing. The false merge is recorded in
   `coverage.gaps`. A real fix needs import resolution, which for Python needs
   the `qualifier` field above.
2. **`Path` and `File` are ambiguous names.** `fastapi.request.parameter`
   matches `call.function Path` inside a function in a file that imports from
   `fastapi`. `pathlib.Path(...)` in such a file is a false positive, and the
   import gate cannot tell them apart because `from pathlib import Path` and
   `from fastapi import Path` both emit `import.symbol Path`. Dropping the two
   names would lose the genuinely common `item_id: int = Path(...)`. Kept, with
   the ambiguity in `coverage.gaps`; the `qualifier` field resolves it properly.
3. **Is a Pydantic model FastAPI's to declare?** `fastapi.schema.model` matches
   `pydantic` bases in a project detected as FastAPI. If an
   `omega-framework-pydantic` is ever written the two will mint the same classes
   under different keys. Kept here because FastAPI is the reason anyone asks.
4. **A `Route` reaches its handler in no framework where the registration is a
   decorator.** `add_exception_handler` works because the function is an
   argument. `@app.get(...)` cannot, because `function_definition` excludes its
   decorators and `decorated_definition` encloses both as siblings. Reaching it
   needs either an omega-python emission spanning the whole
   `decorated_definition`, or a `decorates` field on `reference.decorator`
   naming the declaration below it. This is not asked for above because it is a
   span change rather than a field, and it is the same question Django's file
   records; it belongs in `00-INDEX.md` as a cross-framework item rather than in
   one Framework's request.
5. **The factory pattern is not seen.** `definition.variable` is emitted for
   module-level assignments only, so `def create_app(): app = FastAPI()` states
   nothing. Reaching it would mean matching `call.function FastAPI` with no
   variable join, which mints an `Application` with no name. Left unstated.
