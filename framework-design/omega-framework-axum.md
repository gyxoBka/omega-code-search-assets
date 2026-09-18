# omega-framework-axum

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **14 can match, 0 cannot.**
`key_collisions.py axum` reports nothing.

Selector: `framework:axum`. Maturity: `semantic-overlay-full`.
Language: Rust only; the whole overlay is written against `omega-rust` plus the
`omega-toml` facts of the crate's own `Cargo.toml`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Handler` | 4 |
| `Middleware` | 2 |
| `Service` | 2 |
| `AxumApp` | 1 |
| `Router` | 1 |
| `Route` | 1 |
| `Mount` | 1 |
| `StateBinding` | 1 |
| `Fallback` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `depends_on` | 5 |
| `configured_by` | 3 |
| `handles` | 3 |
| `mounts` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 8 | yes (omega-rust) |
| `definition.config_key` | 14 (13 as the Cargo gate) | yes (omega-toml) |
| `definition.config_table` | 14 (nested in the gate) | yes (omega-toml) |
| `scope.function_body` | 9 | yes (omega-rust) |
| `call.path` | 2 | yes (omega-rust) |
| `call.function` | 1 | yes (omega-rust) |
| `definition.function` | 1 | yes (omega-rust) |
| `reference.type` | 1 | yes (omega-rust) |
| `import.use` | 1 | yes (omega-rust) |

## What was wrong with it

This is the second pass. The first pass moved the file off the pre-rewrite
generator vocabulary — eight fact kinds and fourteen fields that no Pack
emitted — and it has been at 12 live, 0 dead ever since. What was wrong with
*that* file is that it was written while a call's arguments were unreachable,
and it said so five times in `coverage.gaps`:

| the old file claimed | measured today |
|---|---|
| "the URL a route serves is not stated: omega-rust emits no fact for a string literal" | **false.** `.route("/users/:id", get(show))` is one `call.method` named `route` carrying `call.arg0="\"/users/:id\""`, `call.arg0_text="/users/:id"`, `call.arg1="get(show)"`, `receiver="Router::new()"` |
| "a handler named by a bare identifier — `get(list_users)` — is an uncaptured identifier argument" | **false.** `get(list_users)` is a `call.function` named `get` with `call.arg0_text="list_users"` |
| "the qualified routing verb `routing::get(..)` arrives as `call.path` and is not matched" | **true, and now matched** by its own rule; `routing::post(two)` is `call.path` named `post`, `call.arg0_text="two"` |
| "a layer value is named by its constructor call … an applied layer cannot be joined to the type" | **half false.** The applied value is now stated verbatim — `.layer(TraceLayer::new_for_http())` has `call.arg0_text="TraceLayer::new_for_http()"`. It is still expression text and not a resolved type |
| "middleware/state/merge/fallback/service registrations are authored configuration" | still true, kept |

Counted concretely, the second pass changed:

- **11 of the 14 rules now read a call argument.** `route`, `nest`, `nest_service`,
  `merge`, `route_service`, `layer`, `route_layer`, `with_state`, `fallback`,
  `fallback_service`, `method_not_allowed_fallback`, `into_make_service` and
  `serve` all had exactly *kind, name, path, span* to publish and now publish
  what they were called with.
- **The Route entity was keyed by byte offset.** `axum:route:{path}:{source.start}`
  is an identity no question can reach: nobody asks "what is at byte 138 of
  `routes.rs`". It is `http:*:{normalized_route}` now, the same key space as
  omega-framework-express, omega-framework-astro and omega-framework-next-js,
  so `/users/:id`, `/users/{id}` and `/users/[id]` are one URL.
- **The handler rule reached only the qualified spelling.** It matched
  `reference.path` inside the verb call, which exists for
  `get(handlers::show_user)` and not for `get(show_user)` — the spelling axum's
  own documentation uses throughout. It is replaced by three rules keyed on
  `call.arg0_text`, one per spelling of the verb call (`call.function` for
  `get(..)`, `call.path` for `routing::get(..)`, `call.method` for the second
  and later verbs of a chained `get(..).post(..)`), which between them cover
  every way axum names a handler at a route.
- **Five entities are still keyed by byte offset, deliberately.** `Mount`,
  `Middleware`, `StateBinding`, `Fallback` and `Service` are *events in a
  builder chain*, not identities — two `.layer(..)` calls on two routers are two
  facts — so the call site is the right key. What changed is that each now
  carries the argument that says what the event did: `prefix`/`mounted`,
  `layer`, `state`, `fallback`, `router`/`listener`/`served`.
- **Fourteen `field_present` guards were added**, on `call.arg0_text`, `call.arg1`,
  `call.last_arg` and `receiver`. Brief §3b: an unresolvable attribute drops the
  entity and keeps the relation, and `call.arg1` is `None` for a one-argument
  call. `field_present` is present-and-non-empty (`overlay.rs:613`), which also
  makes it the right guard for `call.arg0_text`, whose `default` is `""`.

### The one thing that could not be done, and why

The obvious shape — `http:{method}:{normalized_route}`, method from the verb
call, route from the enclosing `.route(..)` — **fabricates routes in axum**, and
was rejected for that reason. Measured:

```
Router::new()
    .route("/a", get(one))      call.method route  span 25-84   arg0_text /a
    .route("/b", post(two))     call.method route  span 25-125  arg0_text /b
                                call.function get  span 60-83
```

A chained builder's `call_expression` starts at the head of the chain, so the
`.route("/b")` fact **contains** the `get(one)` of `/a`. `fact_join_by_span`
`within` is a cartesian product — `push_joined` pushes one binding per candidate
(`overlay.rs:733-755`) — so the verb of route *i* binds routes *i..N*, and the
rule would mint `http:get:/b` for a URL that serves no GET. There is no clause
that selects the innermost enclosing fact: `within` is the only containment
relation, `additional_field_equalities` exists on `fact_join_by_field` alone, and
no field of the verb call carries its own source text to meet the route's
`call.arg1`.

So the URL identity is `http:*:{normalized_route}` — the spelling
omega-framework-astro and omega-framework-next-js already use for a route whose
method is not determined — and the method-router expression (`get(list).post(create)`,
which literally names the verbs) is published as the Route attribute `methods`.
The method is still stated per call site, on the Handler the verb registers.

## What it states now

Every rule is gated on the crate's `Cargo.toml` naming an axum crate in a
dependency table, reached with `fact_join_by_path_ancestor`. That gate is what
makes generic method names like `layer`, `merge`, `get` and `fallback`
particular to axum.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| does this crate use axum, and which axum crates | `definition.config_key` named `axum`/`axum-extra`/… `within` a `definition.config_table` named `dependencies`… in `**/Cargo.toml` (omega-toml) | `AxumApp` `axum:app:{path.dir}` |
| where is the router assembled, in which function, and onto what | `call.method` in the 11 `Router` builder methods + `receiver`, `within` `scope.function_body` | `Router` `axum:router:{path}:{fn}` — `depends_on` → `AxumApp` |
| **which URL does this route serve** | `call.method` `route`/`route_service`, `call.arg0_text` | `Route` `http:*:{normalized_route}`, attributes `route`, `methods` — `Router` `mounts` → `Route` |
| which HTTP method, and which handler answers it | `call.function` / `call.path` / `call.method` named `get`/`post`/… `within` a `route`/`route_service` call, `call.arg0_text` | `Handler` `axum:handler:{handler}` with attribute `method` — `Handler` `handles` → `Router` |
| which functions are axum handlers, and what do they extract | `reference.type` in the 21 extractor/response types, `within` `definition.function` | `Handler` `axum:handler:{fn}` — `depends_on` → `AxumApp` |
| **under which prefix is a sub-router mounted, and what is mounted there** | `call.method` `nest`/`nest_service`/`merge`/`route_service`, `call.arg0_text` + `call.last_arg` | `Mount`, attributes `prefix`, `mounted` — `Router` `mounts` → `Mount` |
| **which middleware is applied here**, and to all routes or only matched ones | `call.method` `layer`/`route_layer`, `call.arg0_text` | `Middleware`, attributes `application`, `layer` — `Router` `configured_by` → `Middleware` |
| which tower / tower-http / axum middleware does this crate import | `import.use` in the 23 known layer and `from_fn*` names | `Middleware` `axum:middleware-kind:{name}` — `depends_on` → `AxumApp` |
| **what state is attached to this router** | `call.method` `with_state`, `call.arg0_text` | `StateBinding`, attribute `state` — `Router` `configured_by` → `StateBinding` |
| **what catches an unmatched request, and what answers it** | `call.method` `fallback`/`fallback_service`/`method_not_allowed_fallback`, `call.arg0_text` | `Fallback`, attributes `fallback_kind`, `fallback` — `Router` `configured_by` → `Fallback` |
| **which router is handed to hyper** | `call.method` `into_make_service`/`into_make_service_with_connect_info`, `receiver` | `Service`, attribute `router` — `depends_on` → `AxumApp` |
| **what does the process serve, and on which listener** | `call.path` `serve`, `call.arg0_text` + `call.arg1` | `Service`, attributes `listener`, `served` — `depends_on` → `AxumApp` |

The rows in bold are the ones that did not exist before this pass.

### Canonical keys: minted against addressed

| addressed by a relation | minted by | conditions match |
|---|---|---|
| `axum:app:{cargo.path.dir}` | `axum.crate.dependency` as `axum:app:{path.dir}` | the gate's `where` is that rule's clause list, literally |
| `axum:router:{path}:{fn.definition.name}` | `axum.router.assembly` | its builder set is a superset of every method name that addresses it; the three handler rules require a `route`/`route_service` call in the same function, which is in that set; and every side carries the same `scope.function_body` join and the same Cargo gate |
| `http:*:{normalized_route}` | `axum.route.registration`, as its own `current` | — |

Every other minted key is the rule's own `current` entity, emitted **first** in
`outputs` so `Reference::Current` addresses it and not a container (brief §3b).
No two rules put two entity kinds on one key template — `key_collisions.py`
reports nothing — and the two `Handler` templates
(`axum:handler:{call.arg0_text}` and `axum:handler:{fn.definition.name}`) carry
the same kind by design: they are the two ends that meet when a handler is
registered by its bare name.

No attribute reads anything outside `fields` and the built-in names, and every
field an attribute depends on carries a `field_present` clause, so no entity is
dropped as unresolvable.

## A field only the Pack can supply

**None.** The case the previous pass filed here — omega-rust publishing the
literal text of a call's first argument — has been answered: `call.arg0`,
`call.arg0_text`, `call.arg1`, `call.arg2`, `call.last_arg` are fields on
`call.function`, `call.path` and `call.method`, and `receiver` on `call.method`.
Nothing this overlay now wants is out of reach of a built-in name, a field on
those templates, or a `fact_join_by_span`.

## Still to decide

1. **A verb cannot be tied to its own `.route(`.** See "The one thing that could
   not be done" above. Closing it needs either a Pack fact per argument with its
   own span (so the verb call could join `within` the *argument*, which does not
   contain the receiver), or a host clause that selects the innermost of several
   `within` candidates. Both are host/Pack changes, not overlay ones, and both
   would let axum use `http:{method}:{normalized_route}` like every other HTTP
   framework here. This is the one remaining thing that keeps axum's routes from
   being addressable the way express's are.
2. **`axum:handler:{call.arg0_text}` is the handler as written.** `get(show_user)`
   gives `axum:handler:show_user`, which meets the declaration key;
   `get(handlers::show_user)` gives `axum:handler:handlers::show_user`, which
   does not. There is no strip in a key template and no way to take a last
   segment, so the qualified spelling stays qualified. If the host ever resolves
   a call argument to a declaration, this key should become the resolved one.
   The alternative — keeping the old `reference.path` rule as well, which names
   the last segment — was rejected: it would mint two `Handler` entities and two
   `handles` edges for one qualified registration.
3. **`on(MethodFilter::GET, h)` names its handler second.** `on` and `on_service`
   are excluded from the three handler rules rather than made to publish
   `MethodFilter::GET` as a handler. `call.arg1` holds the handler; a fourth
   spelling of the handler rule keyed on `call.arg1` would cover it, and is
   cheap if a measurement over real crates shows `on(..)` is used at all.
4. **A sub-router mounted by `nest` is named, not linked.** `Mount.mounted` is
   `api_router()` as written, and the `Router` that `api_router` builds is keyed
   `axum:router:{path}:{fn}` — path-qualified, so a `nest` in `main.rs` cannot
   address a router built in `api/mod.rs`. Making the Router key path-free would
   link them at the cost of collapsing two same-named builder functions in
   different modules; that is the same trade as note 2 and should be taken, or
   not taken, for both at once.
