# omega-framework-fastify

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**15 overlay rules, 4 detection rules. All 15 match; 0 cannot.**
It was 20 rules, 0 of which could match.

Selector: `framework:fastify`. Maturity: `semantic-overlay-full`.
`host.required_packs`: `omega-javascript`, `omega-typescript` (unchanged;
`required_capabilities` gains `types`, because `type_use.name` is how a handler
and a plugin are recognised).

## What was wrong with it

The audit reported 0 live, 20 dead. Four separate causes, and most rules carried
more than one of them.

**1. Every one of the 20 rules matched `external_path_matches package: "fastify"`,
which cannot match in JavaScript or TypeScript at all.** `external_environment`
registers a binding only when its `target_hint` is set, `target_hint` is
`occurrence.qualifier`, and `qualifier` is read only from a field or attribute
literally named `qualifier` — which neither `omega-javascript` (45 templates,
zero fields) nor `omega-typescript` (58 templates, zero fields) publishes.
`00-INDEX.md` records this as `OWED.md` item 7a. So all 20 rules were dead on
that clause alone, independently of their kind. All 20 clauses are gone; a
module is now recognised by the name of the `import.module` fact itself, which
is the module string with its quotes stripped.

**2. 18 of the 20 matched `fact_kind: "call.member"`.** That kind is emitted by
`omega-c`, `omega-cpp` and `omega-c-sharp` and by no JavaScript Pack. JS/TS
spell the same fact `call.method`, named for the property identifier. This is
the rule-written-against-the-wrong-language case of brief §3h, not an
under-declared manifest: Fastify is a Node framework and the two Packs it
declares are the right ones.

**3. The remaining 2 matched carriers the Pack rewrite deleted** —
`call.target_candidate` (`fastify.generic-api-call.fastify`) and
`import.target_candidate` (`fastify.generic-dependency.fastify`).
`fastify.generic-api-call.fastify` was additionally the self-loop shape wave 6
found in symfony: it ran `uses_api` from `current` to the very key `current` had
just been minted under. Both rules are deleted; the dependency question they
gestured at is answered properly by `fastify.dependency.core`.

**4. 18 of the 20 read argument fields that no Pack publishes** —
`call.arg0` (15 rules), `call.last_arg`, `call.member` as a *field*,
`call.arg0.method`, `call.arg0.url`, `call.arg1.prefix`, `call.kwarg.host`.
The audit only flags the four that read them in a `match` clause; the other
fourteen read them in an entity's `attributes`, which is worse: per brief §3b,
`evaluate_attributes` returns `None` when any expression is unresolvable, so the
entity is dropped while the relation is still rendered in the second loop. Had
the kinds been right, those 18 rules would have produced 18 dangling relations
and no entities. Every argument-derived attribute is gone; what a Fastify call
does is now carried by the call's own name, and what it does it *to* is recorded
as a coverage gap.

**And the file was ten copies of one rule.** Ten `fastify.config.*` rules were
byte-identical apart from one string in a `member_in` list of length one
(`addHook`, `addSchema`, `setValidatorCompiler`, `setSerializerCompiler`,
`setErrorHandler`, `setNotFoundHandler`, `addContentTypeParser`,
`addConstraintStrategy`, `setReplySerializer`, `withTypeProvider`,
`setGenReqId`); three `fastify.decorate.*` rules were the same shape. Those
thirteen are now two rules — `fastify.config.set` over a twelve-name list and
`fastify.decorate` over a three-name list — each carrying the method name as an
attribute, which is strictly more than the old file stated.

Nothing in `detection_rules` was untrue, so it is untouched.

## What it states now

Every rule that is not itself about an import carries one shared gate:

```json
{"kind":"fact_join_by_field","fact_kind":"import.module",
 "current_field":"path","join_field":"path","same_path":true,
 "where":[{"kind":"field_prefix","field":"definition.name","value":"fastify"}]}
```

*this file imports a module whose name begins `fastify`* — `fastify`,
`fastify-plugin`, `fastify-*`. It is what keeps `call.method get` from meaning
`Map.prototype.get`, and it replaces the `external_path_matches` clause that
could never fire.

Every rule also mints the hub `fastify:app:{path}`, kind `FastifyApp`, with the
single attribute `framework: "fastify"` — one kind and one attribute set in all
fifteen rules, so `key_collisions.py` reports nothing and no relation end
dangles. Every relation addresses a key by explicit template; `current` is not
used anywhere, so brief §3b's first-output trap cannot bite.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which modules make up this Fastify app | `import.module` name prefix `fastify` | `FastifyApp` `fastify:app:{path}` — the hub every rule mints |
| Which Fastify packages does this module pull in | `import.module` name prefix `fastify` | `Dependency` `fastify:dependency:{name}`; `depends_on` app → dependency |
| …including the scoped official plugins | `import.module` name prefix `@fastify/` | same `Dependency` key space and kind |
| Which module builds the server | `call.function` named `Fastify`/`fastify`/`fastifyFactory` + gate | `Server` `fastify:server:{path}:{start}`; `declares` app → server |
| Which routes does this module declare, and with what HTTP method | `call.method` named `get`/`post`/`put`/`patch`/`delete`/`options`/`head`/`all` + gate | `Route` `fastify:route:{path}:{start}`, attr `method`; `handles` app → route |
| …and the declarative form | `call.method` named `route` + gate | same `Route` key space and kind, attr `declaration: route-object` |
| Where does this app mount plugins | `call.method` named `register` + gate | `PluginRegistration` `fastify:registration:{path}:{start}`; `mounts` app → registration |
| Which function in this repo *is* a Fastify plugin | `type_use.name` in `FastifyInstance`/`FastifyPluginAsync`/`FastifyPluginCallback`/`FastifyPluginOptions`/`FastifyRegisterOptions`, joined `within` a `definition.function` or a `definition.variable` | `Plugin` `fastify:plugin:{path}:{fn}`; `declares` app → plugin |
| Which function answers a request | `type_use.name` in `FastifyRequest`/`FastifyReply`/`RouteHandlerMethod`/`RouteShorthandMethod`/`RouteOptions`/`RouteGenericInterface`/`FastifyError`/the four `*HookHandler` types, joined `within` a `definition.function`, `definition.variable` or `definition.method` | `Handler` `fastify:handler:{path}:{fn}`; `handles` app → handler |
| Which module installs lifecycle hooks | `call.method` named `addHook` + gate | `FrameworkHook` `fastify:hook:{path}:{start}`; `configured_by` app → hook |
| What does this app add to the instance, request or reply | `call.method` in `decorate`/`decorateRequest`/`decorateReply` + gate | `Decoration` `fastify:decoration:{path}:{start}`, attr `scope`; `configures` app → decoration |
| How is validation, serialization, error handling and content-type parsing configured | `call.method` in the twelve `addSchema`…`withTypeProvider` names + gate | `FrameworkConfig` `fastify:config:{path}:{start}`, attr `operation`; `configured_by` app → config |
| Which module starts the server | `call.method` named `listen` + gate | `Listener` `fastify:listener:{path}:{start}`; `configured_by` app → listener |

Key spaces minted: `fastify:app:{path}`, `fastify:dependency:{name}`,
`fastify:server:…`, `fastify:route:…`, `fastify:registration:…`,
`fastify:plugin:…`, `fastify:handler:…`, `fastify:hook:…`,
`fastify:decoration:…`, `fastify:config:…`, `fastify:listener:…`. Every key any
relation addresses is minted by the same rule that addresses it, so the
containment check of brief §3a is trivially satisfied. `key_collisions.py`
reports nothing: each template carries exactly one entity kind, and the two
rules sharing `fastify:route:…` and the two sharing `fastify:dependency:…` and
the five sharing `fastify:plugin:…`/`fastify:handler:…` all agree on it.

## Coverage gaps, restated truthfully

`omega-javascript` and `omega-typescript` publish **no field on any of their 103
templates**, so no call argument is reachable. That costs Fastify more than it
costs most frameworks:

- a `Route` has no URL — `fastify.get('/users/:id', h)` puts the path in a string
  literal, so a route is located by file and byte offset, and *which route serves
  `/users/:id`* is unanswerable;
- a `FrameworkHook` has no hook name, a `Decoration` no property name, a
  `PluginRegistration` no plugin reference and no `prefix`, a `Listener` no port;
- `handles` runs from the module to the route and from the module to the
  handler, but **not from the route to its handler** — the handler is the call's
  last argument, and with no argument text there is nothing to join on.

This is the same wall `omega-framework-express`, `omega-framework-fiber` and
`omega-framework-gin` hit, and it is already recorded in `OWED.md` as the
argument-text row. Nothing here adds a new claim on a Pack.

The handler and plugin rules are TypeScript-only, because `type_use.name` is a
TypeScript emission. A plain-JavaScript Fastify project still yields its
dependencies, server, routes, registrations, hooks, decorations, configuration
and listener — but no `Handler` and no `Plugin`.

## A field only the Pack can supply

None requested. Everything above is reachable from a fact's kind, its own name,
its path, its span, and the two joins (`fact_join_by_field` on `path`,
`fact_join_by_span` `within`). The one thing a Pack field *would* buy is call
argument text, and that is the existing cross-framework `OWED.md` row rather
than a Fastify field.

## Still to decide

1. **The gate is a prefix, not a package match.** `field_prefix "fastify"` on
   `import.module` admits any module name beginning `fastify` and, more
   importantly, *excludes* a file that imports only `@fastify/cors` and takes its
   instance as a parameter. A second gate clause cannot be OR-ed with the first
   in a conjunction, so widening it means duplicating every gated rule. Left
   narrow deliberately: a Fastify route file in TypeScript almost always imports
   a type from `'fastify'`, and the express overlay makes exactly the same
   trade.
2. **`fastify.app.instance` names its factory binding.** `call.function` is named
   for the identifier the developer bound the default import to, so the rule
   lists `Fastify`, `fastify` and `fastifyFactory`. Per brief §3f this is a
   Framework choice, not a Pack constraint — the list can be widened at any time
   and nothing else depends on it. A binding-aware join would be better but
   there is no fact linking `binding.import_default` to its `import.module`:
   the two spans are disjoint and neither publishes the other's value.
3. **`Server` and `Listener` are close neighbours.** Both answer "where does this
   app start". They are kept apart because a Fastify app is often built in one
   module (`buildApp()` for tests) and listened on in another, and knowing which
   is which is the difference between the test entry point and the production
   one.
