# omega-framework-gin

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 4 detection rules. 12 live, 0 cannot match.** (Was 12 rules,
0 live.)

Selector: `framework:gin`. Maturity: `semantic-overlay-full`. One language, one
Pack: `omega-go`.

### Entities it declares

| entity_kind | rules that mint it |
|---|---|
| `Handler` | 4 (`gin:handler:{name}`, deliberately path-free so a route in one file reaches a handler declared in another) |
| `Router` | 5 (shared hub key, minted by every rule that points at it) |
| `Middleware` | 3 |
| `Route`, `Controller`, `StaticResource`, `Dependency`, `Package`, `RequestModel`, `ValidatedField`, `RequestBinding` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 2 |
| `handles`, `mounts`, `declares`, `uses_resource`, `depends_on`, `validates`, `binds_request` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 3 + 3 joins | yes (omega-go) |
| `definition.return_type_candidate` | 3 | yes |
| `definition.parameter_shape_candidate` | 2 | yes |
| `import.package` | 1 | yes |
| `reference.member` | 1 | yes |
| `definition.tag_candidate` | 1 | yes |
| `call.function` | 1 | yes |
| `scope.function_body` | 5 joins | yes |
| `definition.function` | 3 joins | yes |
| `definition.method`, `definition.receiver_candidate`, `definition.field`, `definition.struct` | 1 join each | yes |

**No rule reads a Pack `field`.** `omega-go` publishes no `fields` and no
`attributes` on any of its 47 templates, so the overlay has kind, name, path and
span and nothing else. Everything a rule reads is a built-in — `definition.name`,
`path`, `path.dir`, `source.start` — or a `<bind>.definition.name` from a join.
Every span join carries `same_path: true`, because `same_path` defaults to
`false` and a bare span join would otherwise pair facts from unrelated files.

---

## What was wrong with it

**All 12 rules were dead, and 10 of them were dead twice over.**

| cause | rules |
|---|---|
| matched `call.go_receiver_string_identifier_context`, a kind no Pack emits | 5 |
| matched `call.go_receiver_method_chain_string_argument_context` | 2 |
| matched `definition.go_import_alias_constructor_binding_context` | 2 |
| matched `definition.go_import_alias_group_binding_context` | 2 |
| matched `definition.category_candidate` (join) | 2 |
| matched `call.go_receiver_identifier_argument_context` | 1 |
| matched `call.target_candidate` / `import.target_candidate`, carriers the Pack rewrite removed | 2 |
| **also** read `receiver`, `method_name`, `path_literal`, `handler_identifier`, `import_path`, `constructor_name`, `group_method`, `group_binding`, `root_binding`, `prefix`, `binding`, `arg1`, `arg1_identifier` — 13 fields no Pack publishes | 10 |
| **also** read the attribute `symbol_category`, which no Pack publishes | 2 |

Every one of the eight kinds was a private Go spelling invented by the old
generator, and every one of the thirteen fields was a piece of a call's argument
list that `omega-go` has never published. The file was written against a
vocabulary in which `r.GET("/users/:id", ctrl.GetUser)` arrived as one fact
carrying `receiver=r`, `method_name=GET`, `path_literal=/users/:id` and
`handler_identifier=ctrl.GetUser`. Measured with `dump_call_emissions` on
exactly that line, `omega-go` emits **two** facts:

```
629-636  reference.member  name=GET       | api.GET
629-664  call.method       name=GET       | api.GET("/users/:id", ctrl.GetUser)
651-663  reference.member  name=GetUser   | ctrl.GetUser
```

`call.method`'s name is the selected member alone, its span is the whole call
expression, and there is no string-literal fact anywhere. So the receiver, the
package qualifier and **the route path are all unreachable**, and the argument
that used to be `handler_identifier` is reachable only as a separate
`reference.member` whose span lies inside the call's.

That is the whole rewrite in one line: **the old file read a call's parts out of
one fact; the new one relates the facts the call is made of, by span.**

Two rules were also pure input-restatement and are gone rather than ported:
`gin.generic-api-call.github-com-gin-gonic-gin` minted an `ApiUse` keyed by the
call's own name with a `uses_api` edge to itself, and
`gin.generic-dependency.github-com-gin-gonic-gin` minted a `Dependency` keyed by
the import it had just read. The second is replaced by `gin.dependency.import`,
which keeps the Dependency but gives it an end — the Go package that imports it.

Five of the old rules were one Go spelling apiece of the same construct
(`gin.route.root`, `gin.route.group`, `gin.route.any`, `gin.route.handle`,
`gin.route.match`, differing only in which router binding and which method-name
list they demanded). They are now one rule, `gin.route.registration`, because a
`call.method` named `GET` and a `call.method` named `Any` are the same fact.

Two dead clauses the audit now flags were **not** present here: no brace glob
and no scoped-package `external_path_matches`. But `external` was unusable
anyway — `omega-go` publishes no `qualifier`, so the two `external_path_matches`
clauses in the old file could never have resolved even if their kinds existed.

---

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **Which functions are gin HTTP handlers** | `definition.parameter_shape_candidate` whose name globs `**gin.Context*`, joined `same`-span to `definition.function` | `Handler` `gin:handler:{name}` |
| **Which methods are gin handlers, and on which controller** | same, joined `same`-span to `definition.method` **and** `definition.receiver_candidate` | `Handler` + `Controller`, `Controller declares Handler` |
| **Which functions are gin middleware** | `definition.return_type_candidate` globbing `**gin.HandlerFunc*`, joined `same`-span to `definition.function` | `Middleware` `gin:middleware:{name}` |
| **Where is the engine built** | `definition.return_type_candidate` globbing `**gin.Engine*`, joined `same`-span to `definition.function` | `Router` `gin:router:{path}:{name}`, `role=engine_builder` |
| **Which function builds a sub-router** | same, globbing `**gin.RouterGroup*` | `Router`, `role=group_builder` |
| **Which handler answers which HTTP method, and where is it registered** | `reference.member` joined `within` a `call.method` named `GET`/`POST`/`PUT`/`PATCH`/`DELETE`/`HEAD`/`OPTIONS`/`Any`/`Handle`/`Match`, and `within` a `scope.function_body` | `Route` + `Handler` + `Router`; `Route handles Handler`, `Router mounts Route` |
| **Which middleware is installed on which router** (local factory) | `call.function` joined `within` a `call.method` named `Use`, and `within` a `scope.function_body` | `Middleware` + `Router`, `Router configured_by Middleware` |
| **…and from a third-party package** (`r.Use(cors.Default())`) | `call.method` joined `within` a `call.method` named `Use`, and `within` a `scope.function_body` | `Middleware` + `Router`, `Router configured_by Middleware` |
| **Which routers serve static files or HTML templates** | `call.method` named `Static`/`StaticFS`/`StaticFile`/`StaticFileFS`/`LoadHTMLGlob`/`LoadHTMLFiles`, joined `within` a `scope.function_body` | `StaticResource` + `Router`, `Router uses_resource StaticResource` |
| **Which Go packages pull in gin or a gin-contrib middleware** | `import.package` whose name prefixes `github.com/gin-` | `Dependency` + `Package`, `Package depends_on Dependency` |
| **Which request payloads gin validates, and with which rules** | `definition.tag_candidate` globbing `**binding:*`, joined `same`-span to `definition.field` and `within` `definition.struct` | `ValidatedField` (carries the whole struct tag) + `RequestModel`, `RequestModel validates ValidatedField` |
| **Which handlers parse a request body, and with which binder** | `call.method` named `ShouldBind*`/`Bind*`/`MustBindWith`, joined `within` a `scope.function_body` | `RequestBinding` + `Handler`, `Handler binds_request RequestBinding` |

### The two joins that carry the file

`definition.parameter_shape_candidate` and `definition.return_type_candidate`
are emitted on a span **byte-identical** to the declaration's own, so
`fact_join_by_span` with `relation: "same"` reaches the declaration from the
signature text with no Pack field at all. That is what makes
*which functions take a `*gin.Context`* — the only reliable definition of a gin
handler — statable, and the same trick answers *which function returns
`gin.HandlerFunc`* and *which returns `*gin.Engine`*. It is the same join
`omega-framework-kotlin-multiplatform` found on `definition.modifier_candidate`.

`call.method`'s span covers the whole call expression, so everything written
inside a gin call — the handler reference, the middleware constructor — lies
*within* it. Every rule about a call's arguments is therefore written with the
**argument as the current fact** and the call joined `within`, not the other way
round.

### Key containment

Canonical keys minted: `gin:handler:{name}`, `gin:controller:{path}:{name}`,
`gin:middleware:{name}`, `gin:router:{path}:{name}`,
`gin:route:{path}:{method}:{handler}`, `gin:static:{path}:{start}`,
`gin:dependency:{module}`, `gin:package:{dir}`,
`gin:request-model:{path}:{name}`, `gin:validated-field:{path}:{model}:{field}`,
`gin:request-binding:{path}:{start}`.

Keys addressed by a relation end: `gin:controller:…`, `gin:handler:…`,
`gin:router:…`, `gin:package:…`, `gin:request-model:…`, plus `current`. Every
one of them is minted **by the same rule that addresses it**, under the same
clauses, so no end can dangle — the failure wave 1 found in unity and wave 2
found in next-js. `gin:router:{path}:{name}` is the shared hub: the five rules
that point at a router each mint it, and `gin.router.engine_builder` /
`gin.router.group_builder` run first so their `role` attribute wins the
first-materialization race in `overlay_ir.rs`.

In every rule the entity meant by `current` is the **first** entity output, per
the `emit()` rule that sets `own_key` once in output order.

Measured end to end: a 60-line gin file (router constructor, group, controller
methods, middleware, static mounts, binding tags) put 11 of the 12 rules into
output — 38 entity candidates and 19 relation candidates, 0 unresolved attributes and 0 unresolved
keys. The twelfth, `gin.router.group_builder`, is byte-for-byte
`gin.router.engine_builder` with one glob changed and needs only a
`*gin.RouterGroup`-returning function in the fixture.

---

## A field only the Pack can supply

**Pack `omega-go`, kind `call.method` (and `call.function`), field
`arguments`** — or, better, a separate emission per string-literal argument.

`omega-go` emits no fact for a `interpreted_string_literal` anywhere. The
consequence is the single largest thing this overlay cannot say:

- **a route's path.** `r.GET("/users/:id", h)` is `call.method GET` and nothing
  more, so `Route` is keyed by method plus handler name and *which route serves
  `/users/:id`* has no answer. Every other HTTP framework in this repository —
  fastapi, rails, laravel, vapor — answers it, and gin cannot.
- **a group's prefix**, so nested `r.Group("/api/v1")` cannot be composed into a
  route's full path.
- **the directory and URL of a static mount**, so `StaticResource` records only
  that a mount exists and in which function.
- **the verb of `Handle("GET", …)` and `Match([]string{…}, …)`**, which are
  string arguments too.

Why neither of the first two options in the brief reaches it:

1. **Derivation.** The built-ins give `path`, `path.dir`, `path.stem`,
   `definition.name` and the span. A route path is neither the artifact path nor
   any emission's name; gin is not a file-routed framework, so
   `normalized_file_route` has nothing to derive from.
2. **A join.** `fact_join_by_span` relates two *emissions*. There is no emission
   at the literal's span to join to — the literal produces nothing at all. A
   join can only reach a fact that exists, and this one does not.

So this is the third case: a Pack field. The cheapest shape that fixes all four
bullets is one new template, `literal.string`, named by the literal's text and
spanned on the literal node — then the existing `within` join reaches it from
the enclosing `call.method` exactly as `reference.member` already does, at no
cost to any `call.*` emission that has no literal in it. It is not a gin
concern: every Go framework overlay (and `omega-framework-tokio`'s addresses,
and any SQL-in-Go rule) has the same hole.

A second, much smaller item: **`call.method` publishes the selected member but
not the receiver's package.** `r.Use(cors.Default())` yields `call.method
Default`, so the middleware is keyed `gin:middleware:Default` and collides with
`gin.Default`. `reference.member` has the same limitation — it spans
`cors.Default` but is named `Default`. A `qualifier` field on `reference.member`
would fix it, and is the same `qualifier` row already in `OWED.md` item 1 for
the JS/TS Packs.

---

## Still to decide

1. **Is `gin:handler:{name}` path-free correctly?** The key deliberately omits
   the path so a `r.GET("/x", ctrl.GetUser)` in `routes.go` reaches the
   `func (c *UserController) GetUser(c *gin.Context)` declared in
   `controllers/user.go` — the one edge a language Pack cannot state. The price
   is that two unrelated `GetUser` handlers in two Go packages become one
   entity. `omega-framework-kotlin-multiplatform` made the same trade
   deliberately for `expect`. It can be tightened to
   `gin:handler:{path.dir}:{name}` if same-package registration turns out to be
   the norm, which would keep most real edges and lose cross-package ones.
2. **`gin.middleware.use_package_result` has no way to tell gin middleware from
   any other method call inside a `Use(…)`.** `r.Use(a.B(c.D()))` mints
   `gin:middleware:B` *and* `gin:middleware:D`, because both lie within the
   `Use` call's span. Narrowing it needs argument-position information, which is
   the Pack change above. Kept as-is: the overlay only runs on projects the
   detector says are gin, and over-naming a middleware is a cheaper error than
   naming none.
3. **A bare-identifier handler is invisible to `gin.route.registration`.**
   `r.GET("/healthz", Healthz)` emits no `reference.member` for `Healthz` — a
   plain identifier is not a `selector_expression` — so no `Route` is minted,
   although `gin.handler.function` still declares `Healthz` as a `Handler`. This
   is the same literal/argument gap: `call.function` is emitted only for a call,
   not for an identifier passed as a value. Recording it rather than working
   around it, because the workaround (joining *any* identifier-shaped fact
   within the call) would have to invent a fact.
4. **`LoadHTMLGlob` / `LoadHTMLFiles` are in the static list.** They mount HTML
   templates, not a static directory, so they arguably want their own entity
   kind. Folded into `StaticResource` with a `directive` attribute for now,
   since without the literal argument the two are indistinguishable in what they
   can say.
