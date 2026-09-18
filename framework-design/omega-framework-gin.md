# omega-framework-gin

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**15 overlay rules, 4 detection rules. 15 live, 0 cannot match.** (Wave 5: 12
rules, 12 live. Wave 1: 12 rules, 0 live.)

Selector: `framework:gin`. Maturity: `semantic-overlay-full`. One language, one
Pack: `omega-go`.

`python pack-design/key_collisions.py gin` reports nothing, and
`python pack-design/dangling_ends.py gin` reports nothing.

### Entities it declares

| entity_kind | rules that mint it |
|---|---|
| `Handler` | 6 (`gin:handler:{name}`, deliberately path-free so a route in one file reaches a handler declared in another) |
| `Router` | 8 (`gin:router:{path}:{function}` — one neutral hub kind, one attribute set) |
| `Route` | 3 (`http:{method}:{normalized_route}` for the verb form, `gin:route:{path}:{start}` for `Handle`/`Match`) |
| `Middleware` | 3 |
| `RouterConstructor` | 2 |
| `Controller`, `RouterGroup`, `StaticResource`, `Dependency`, `Package`, `RequestModel`, `ValidatedField`, `RequestBinding` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `mounts` | 3 |
| `handles`, `declares`, `configured_by` | 2 each |
| `uses_resource`, `depends_on`, `validates`, `binds_request` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 6 + 2 joins | yes (omega-go) |
| `definition.return_type_candidate` | 3 | yes |
| `definition.parameter_shape_candidate` | 2 | yes |
| `import.package` | 1 + 9 joins | yes |
| `reference.member` | 1 | yes |
| `definition.tag_candidate` | 1 | yes |
| `call.function` | 1 | yes |
| `scope.function_body` | 6 joins | yes |
| `definition.function` | 3 joins | yes |
| `definition.method`, `definition.receiver_candidate`, `definition.field`, `definition.struct` | 1 join each | yes |

---

## What was wrong with it

This is the second pass. The first pass (wave 5) killed the eight private Go
fact kinds and the thirteen invented fields the generator had written against;
that part of the history is below under *the wave-1 file*. What was wrong with
the **wave-5 file** is one thing, and it was not the rules' fault:

**`omega-go` published no argument of a call, so a route had no URL.** All
twelve rules were live and none of them could say what any route served. The
file said so itself, four times: the first `coverage.gaps` entry, the
`Route` key `gin:route:{path}:{method}:{handler}`, the whole *A field only the
Pack can supply* section, and *Still to decide* items 2 and 3. `omega-go` now
publishes `call.arg0`, `call.arg0_text`, `call.arg1`, `call.arg2`,
`call.last_arg` and `receiver` on `call.method` and `call.function`. Measured on
the fixture in this document:

```
470-503  call.method  name=GET  call.arg0="\"/users/:id\""  call.arg0_text="/users/:id"
                                call.arg1="ctrl.GetUser"     call.last_arg="ctrl.GetUser"
                                receiver="r"
580-598  call.method  name=Group  call.arg0_text="/api/v1"   receiver="r"
536-571  call.method  name=Handle call.arg0_text="GET"  call.arg1="\"/legacy\""  call.last_arg="Healthz"
627-658  call.method  name=Static call.arg0_text="/assets"   call.arg1="\"./public\""
405-426  call.method  name=Use    call.arg0_text="cors.Default()"  receiver="r"
```

So, concretely, what was wrong with the twelve rules that were all "live":

| defect | rules affected |
|---|---|
| a `Route` keyed by method + handler name rather than by the URL it serves, so gin's routes shared no identity with the ten other HTTP frameworks in this repository | 1 |
| a route registered with a bare identifier handler (`r.GET("/healthz", Healthz)`) minted **no Route at all**, because the rule was written with the handler's `reference.member` as the current fact and a bare identifier emits none | 1 |
| `StaticResource` keyed `gin:static:{path}:{source.start}` — a byte offset, so the same mount moves identity on every edit above it, and the URL it serves was not recorded | 1 |
| no rule for `r.Group("/api/v1")` at all: the sub-router and its prefix were invisible | 0 (missing) |
| **`role` on the shared `Router` hub was computed and thrown away.** Six rules minted `gin:router:{path}:{fn}` with three different `role` values; `candidate_order` sorts by rule id, so `gin.middleware.use_function_result` wins over `gin.router.engine_builder` and `role=engine_builder` never materialized in any file that also called `r.Use(...)`. The old document asserted the opposite — "`gin.router.engine_builder` … run first so their `role` attribute wins the first-materialization race" — and that claim was false. `key_collisions.py` could not see it because the kind was the same in all six. | 6 |
| every call-keyed rule matched on the bare method name with no gate, so `X.GET(...)`, `X.Use(...)`, `X.Group(...)` and `X.Static(...)` in an Echo or Fiber file in the same repository would have been read as gin | 5 |
| `parameter_shape` / `return_shape` / `form` / `source_form` carried as entity attributes on keys several rules mint, so the same first-rule-wins rule silently dropped them | 5 |

### What the wave-1 file got wrong, kept for the record

All 12 rules were dead, and 10 of them twice over: eight private Go fact kinds
(`call.go_receiver_string_identifier_context` and friends), thirteen fields no
Pack publishes (`receiver`, `method_name`, `path_literal`, `handler_identifier`,
…), one attribute (`symbol_category`), and two `external_path_matches` clauses
that could never resolve because `omega-go` publishes no `qualifier`. Five of
them were one Go spelling apiece of the same construct. Two restated their
input. The detail is in the wave-5 revision of this file.

---

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **Which route serves `GET /users/:id`, and which handler answers it** | `call.method` named `GET`/`POST`/`PUT`/`PATCH`/`DELETE`/`HEAD`/`OPTIONS`/`Any`, `call.arg0_text` for the URL, `call.last_arg` for the handler, gated by an `import.package` join on `github.com/gin-` | `Route` `http:{method}:{normalized_route}` (`method`, `route`) + `Handler` + `Router`; `Route handles Handler`, `Router mounts Route` carrying `registered_in` and `via_receiver` |
| **…and which *declared* function that handler is**, across files | `reference.member` (not a router method name) joined `within` the same verb `call.method`, reading `reg.call.arg0_text` for the URL | the same `Route` key + `Handler` `gin:handler:{member}`, `Route handles Handler` |
| **Which functions are gin HTTP handlers** | `definition.parameter_shape_candidate` globbing `**gin.Context*`, joined `same`-span to `definition.function` | `Handler` `gin:handler:{name}` |
| **Which methods are gin handlers, and on which controller** | same, joined `same`-span to `definition.method` **and** `definition.receiver_candidate` | `Handler` + `Controller`, `Controller declares Handler` |
| **Which routes are registered through `Handle`/`Match`, with which verb** | `call.method` named `Handle`/`Match`, `call.arg0_text` is the verb, `call.last_arg` the handler | `Route` `gin:route:{path}:{start}` + `Handler` + `Router`; `handles`, `mounts` |
| **Which sub-routers exist, and at what URL prefix** | `call.method` named `Group`, `call.arg0_text` | `RouterGroup` `gin:group:{path}:{normalized_prefix}`, `Router mounts RouterGroup` |
| **Where is the router constructed, and what does it return** | `definition.return_type_candidate` globbing `**gin.Engine*` / `**gin.RouterGroup*`, joined `same`-span to `definition.function` | `RouterConstructor` `gin:router-constructor:{path}:{fn}` (`return_shape`), `RouterConstructor declares Router` |
| **Which functions are gin middleware** | `definition.return_type_candidate` globbing `**gin.HandlerFunc*` + `same`-span `definition.function` | `Middleware` `gin:middleware:{name}` |
| **Which middleware is installed on which router, and how it is written** | `call.function` (local) or `call.method` (package) joined `within` a `call.method` named `Use`, reading `use.call.arg0_text` and `use.receiver` | `Middleware` + `Router`, `Router configured_by Middleware` carrying `installed_as`, `via_receiver`, `source_form` |
| **What a router serves statically, and from which URL prefix** | `call.method` named `Static`/`StaticFS`/`StaticFile`/`StaticFileFS`/`LoadHTMLGlob`/`LoadHTMLFiles`, `call.arg0_text` | `StaticResource` `gin:static:{path}:{directive}:{mount}` + `Router`, `Router uses_resource StaticResource` |
| **Which Go packages pull in gin or a gin-contrib middleware** | `import.package` whose name prefixes `github.com/gin-` | `Dependency` + `Package`, `Package depends_on Dependency` |
| **Which request payloads gin validates, and with which rules** | `definition.tag_candidate` globbing `**binding:*`, `same`-span `definition.field`, `within` `definition.struct` | `ValidatedField` (the whole struct tag) + `RequestModel`, `RequestModel validates ValidatedField` |
| **Which handlers parse a request body, with which binder and into what** | `call.method` named `ShouldBind*`/`Bind*`/`MustBindWith`, `call.arg0_text` for the bound variable, `within` `scope.function_body` | `RequestBinding` + `Handler`, `Handler binds_request RequestBinding` |

### What is new since wave 5

Three answers the overlay could not give at all:

1. **A route has a URL.** `http:{method}:{normalized_route}` is the same key
   space express, fastapi, rails, laravel and vapor mint, so `/users/:id`,
   `/users/{id}` and `/users/[id]` are one route and a gin route can be asked
   for by what it serves. A bare-identifier handler now mints a Route too,
   because the rule's current fact is the call and not the handler reference.
2. **A sub-router has a prefix.** `r.Group("/api/v1")` is a `RouterGroup` the
   enclosing router `mounts`.
3. **A static mount has a URL**, and a `Use(...)` edge carries the expression as
   it was written (`cors.Default()`), which is the only place the middleware's
   package survives.

And one defect removed: the `Router` hub now carries **one** attribute set
(`router_name`, `declared_in`) in all eight rules that mint it, so nothing it
computes depends on rule-id ordering. The classification that used to live in
`role` moved to its own key space, `gin:router-constructor:{path}:{fn}`, related
back to the hub by `declares` — remedy 2 in brief §3g, chosen over remedy 1
because `return_shape` is a real value and not just a label.

### The three joins that carry the file

`definition.parameter_shape_candidate` and `definition.return_type_candidate`
are emitted on a span **byte-identical** to the declaration's own, so
`fact_join_by_span` with `relation: "same"` reaches the declaration from the
signature text with no Pack field at all. That is what makes *which functions
take a `*gin.Context`* — the only reliable definition of a gin handler —
statable.

`call.method`'s span covers the whole call expression, so everything written
inside a gin call lies *within* it. The handler-reference rule and the two
middleware rules are written with the **argument as the current fact** and the
call joined `within`, which is also how they read the call's own
`call.arg0_text` back out through the bind (`reg.call.arg0_text`,
`use.call.arg0_text`).

`fact_join_by_field` on `import.package` with `same_path` is the gate. Every
rule keyed on a bare method name (`GET`, `Use`, `Group`, `Static`,
`ShouldBindJSON`, `Handle`) carries it, because Echo spells its routes `e.GET`
and Fiber spells its groups `app.Group`, and without the gate a repository
holding two Go web frameworks would attribute both to gin. `external_path_matches`
is not an option here: `omega-go` publishes no `qualifier`, so `external` is
empty on every Go fact (brief §3i).

### Key containment

Canonical keys minted: `http:{method}:{normalized_route}`,
`gin:route:{path}:{start}`, `gin:handler:{name}`,
`gin:controller:{path}:{name}`, `gin:middleware:{name}`,
`gin:router:{path}:{fn}`, `gin:router-constructor:{path}:{fn}`,
`gin:group:{path}:{normalized_prefix}`,
`gin:static:{path}:{directive}:{mount}`, `gin:dependency:{module}`,
`gin:package:{dir}`, `gin:request-model:{path}:{name}`,
`gin:validated-field:{path}:{model}:{field}`,
`gin:request-binding:{path}:{start}`.

Every key a relation end addresses is minted by the same rule that addresses it,
under the same clauses, with one deliberate exception:
`gin.route.handler_reference` addresses `http:{method}:{normalized_route}` and
mints it as its own first output with attribute expressions that render the same
values as `gin.route.registration`'s, because that rule's clauses are a strict
superset of this one's (any handler reference inside a verb call implies the verb
call). Both mint it as kind `Route`, so §3g's first-rule-wins costs nothing.

In every rule the entity meant by `current` is the **first** entity output, per
the `emit()` rule that sets `own_key` once in output order.

---

## A field only the Pack can supply

**Pack `omega-go`, kinds `call.method` and `call.function`, field
`call.arg1_text`** (and `call.arg2_text`, `call.last_arg_text`).

`call.arg0_text` exists precisely because a canonical key template has no strip
and a value carrying its quote bytes can never be an identity (brief §3l). The
same is true of every other argument, and `omega-go` publishes `call.arg1` and
`call.arg2` raw. Two gin constructs put their route in argument **1**, not 0:

- `r.Handle("GET", "/legacy", h)` and `r.Match([]string{...}, "/x", h)` — the
  verb is `arg0`, the URL is `arg1`, and it arrives as `"\"/legacy\""`. So the
  one route form gin shares with `net/http`'s vocabulary cannot join the
  `http:{method}:{normalized_route}` key space that every other route in this
  file uses.
- `r.Static("/assets", "./public")` and `r.StaticFS`, whose served directory is
  `arg1`. The mount's URL is recorded; what it serves is not.

Why neither of the first two options in the brief reaches it:

1. **Derivation.** The built-ins give `path`, `path.dir`, `path.stem`,
   `definition.name` and the span. A route's second argument is none of those,
   and gin is not a file-routed framework, so `normalized_file_route` has
   nothing to derive from. `normalize_route` does not strip quotes either —
   `normalize_http_path("\"/legacy\"")` trims `/` and returns `/"/legacy"`.
2. **A join.** `omega-go` emits no fact at an `interpreted_string_literal`'s
   span, so there is no emission to join to. `fact_join_by_span` relates two
   emissions and this one does not exist.

The shape is already decided: `call.arg0_text` is a `default` to `""` wrapped in
one `strip_prefix`/`strip_suffix` pair per quote style, and Go has two (`"` and
`` ` ``). `call.arg1_text` is the identical expression over `select(…, 1)`. It
costs the same bytes on the same emissions that already carry `call.arg1`.

This is not a gin concern. Every framework whose registration API puts a path in
the second argument has it — `omega-framework-echo`'s `e.Static(prefix, root)`,
`omega-framework-fiber`'s `app.Add(method, path, h)` and `app.Static`, and
`net/http`'s `mux.Handle(pattern, h)`.

A second, much smaller item, unchanged from wave 5: **`reference.member` is
named by the selected member alone and publishes no receiver.** `call.method`
now publishes `receiver`, but `reference.member` does not, so
`r.Use(cors.Default())` still keys the middleware `gin:middleware:Default` and
collides with `gin.Default`. A `receiver` field on `reference.member` — the same
capture the `call.method` template already takes — would fix it.

---

## Still to decide

1. **Is `gin:handler:{name}` path-free correctly?** The key deliberately omits
   the path so `r.GET("/x", ctrl.GetUser)` in `routes.go` reaches the
   `func (c *UserController) GetUser(c *gin.Context)` declared in
   `controllers/user.go` — the one edge a language Pack cannot state. The price
   is that two unrelated `GetUser` handlers in two Go packages become one
   entity. It can be tightened to `gin:handler:{path.dir}:{name}` if
   same-package registration turns out to be the norm, which would keep most
   real edges and lose cross-package ones.
2. **A qualified registration mints two Handler entities.** For
   `r.GET("/users/:id", ctrl.GetUser)`, `gin.route.registration` mints
   `gin:handler:ctrl.GetUser` from `call.last_arg` and
   `gin.route.handler_reference` mints `gin:handler:GetUser` from the inner
   `reference.member`; the Route has a `handles` edge to both. Only the second
   meets the declaration. The first is kept because it is the *only* thing that
   works for the bare-identifier form (`r.GET("/healthz", Healthz)`), which is
   the commoner spelling in small gin services, and there is no clause that can
   ask whether `call.last_arg` contains a dot. Collapsing it needs either
   `call.last_arg_text` split on `.` in the Pack, or a `field_contains` clause
   in the overlay — neither exists, and neither is worth asking for to remove
   one duplicate edge.
3. **A route's full path is the route as written, not the composed path.**
   `api := r.Group("/api/v1"); api.GET("/ping", h)` mints
   `http:GET:/ping`, not `http:GET:/api/v1/ping`. Composing them needs to know
   that the receiver `api` is the value of that `Group` call, and Go's short
   variable declaration emits no `definition.variable` at all (measured: `var
   req CreateReq` emits one, `api := r.Group(...)` emits none). Both halves are
   published — the group's prefix on the `RouterGroup`, the receiver name on the
   `mounts` edge — so a consumer can compose them; the overlay does not, because
   the binding from `api` to the call is a fact no Pack states.
4. **`gin.middleware.use_package_result` still cannot tell gin middleware from
   any other method call inside a `Use(...)`.** `r.Use(a.B(c.D()))` mints
   `gin:middleware:B` *and* `gin:middleware:D`, because both lie within the
   `Use` call's span. `use.call.arg0_text` now records the written expression on
   the edge, which makes the over-naming legible but does not prevent it.
   Narrowing it needs argument-position information the Pack does not publish.
   Kept as-is: the overlay only runs on projects the detector says are gin, and
   over-naming a middleware is a cheaper error than naming none.
5. **`LoadHTMLGlob` / `LoadHTMLFiles` are in the static list.** They mount HTML
   templates, not a static directory. They are now distinguishable — the
   `directive` attribute is in the key and the glob is the `mount` — so folding
   them into `StaticResource` costs nothing an agent cannot undo with one field
   read. Splitting them into their own entity kind is still open.
