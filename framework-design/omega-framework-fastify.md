# omega-framework-fastify

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**15 overlay rules, 4 detection rules. All 15 match; 0 cannot.**

```text
before: omega-framework-fastify: 15 overlay rules, 4 detection rules -- 15 live, 0 cannot match
after:  omega-framework-fastify: 15 overlay rules, 4 detection rules -- 15 live, 0 cannot match
```

`python pack-design/key_collisions.py fastify` reports
`0 entity outputs are overwritten by a same-key rule that sorts first`, before
and after.

Selector: `framework:fastify`. Maturity: `semantic-overlay-full`.
`host.required_packs`: `omega-javascript`, `omega-typescript`.
Entity kinds emitted: 10 (was 11 — `PluginRegistration` is gone).
Relation kinds emitted: 6 (unchanged).

This is the second pass. The first pass fixed the kinds; this one fixes the
identities, because the argument text the first pass recorded as unreachable is
now published.

## What was wrong with it

Every rule matched. Nothing the file said about *what* it matched was wrong.
What was wrong is that it was written against a Pack that published no call
arguments, and that stopped being true.

**1. The claim the whole "Coverage gaps" section rested on is false.** The file
said, in bold, that `omega-javascript` and `omega-typescript` "publish **no
field on any of their 103 templates**". Measured with
`dump_call_emissions.exe packs/omega-javascript grammars/omega-javascript`
against a 15-line Fastify module, both Packs publish five fields on
`call.function` and six on `call.method`:

```text
214-217  call.method  name=get   call.arg0="'/users/:id'" call.arg0_text="/users/:id"
                                 call.arg1="getUser" call.arg2=None
                                 call.last_arg="getUser" receiver="app"
338-345  call.method  name=addHook  call.arg0_text="onRequest" call.arg1="authHook"
373-388  call.method  name=decorateRequest  call.arg0_text="user" call.arg1="null"
175-183  call.method  name=register  call.arg0_text="cors"
```

Four of the five coverage-gap sentences were therefore untrue, and all four are
deleted rather than softened.

**2. Not one of the 15 rules read an argument, so 13 entities were located by
byte offset.** Ten of the eleven key spaces were `fastify:<thing>:{path}:{source.start}`
or `{path}:{name}`. A `Route` was `fastify:route:src/routes/users.ts:214` — a
coordinate, not an identity. *Which route serves `/users/:id`* was
unanswerable, and the same URL declared under Express and under Fastify were
two unrelated entities.

**3. Every one of the 15 rules emitted exactly one relation, and all 15 ran
from the module hub.** `FastifyApp -> Route`, `FastifyApp -> Handler`,
`FastifyApp -> FrameworkHook`. No edge ever ran between two framework
constructs, so the graph was a star: a module with a bag of unrelated things
hanging off it. The old file said so itself — "`handles` runs from the module to
the route and from the module to the handler, but **not from the route to its
handler**".

**4. Five entities carried no attribute at all or only their own call name.**
`FrameworkHook` had no hook name, `Decoration` no property name,
`PluginRegistration` no plugin, `Listener` nothing whatever. `PluginRegistration`
existed only to be an anonymous offset where `register` was written; it stated
nothing that `Route`'s offset did not already state about `get`.

**5. One `emits` entry was dead weight.** `PluginRegistration` is removed: the
question it gestured at — *which plugins does this app mount* — is now answered
by a `mounts` edge onto the `Plugin` the register call names.

## What it states now

Every rule that is not itself about an import carries one shared gate:

```json
{"kind": "fact_join_by_field", "fact_kind": "import.module",
 "current_field": "path", "join_field": "path", "same_path": true,
 "where": [{"kind": "field_prefix", "field": "definition.name",
            "value": "fastify"}]}
```

*this file imports a module whose name begins `fastify`*. It is what keeps
`call.method get` from meaning `Map.prototype.get`, and `fastify.route.verb`
now adds a second discriminator on top of it: `field_prefix call.arg0_text "/"`,
because a Fastify route's first argument is a URL and `map.get(key)`'s is not.

Every rule also mints the hub `fastify:app:{path}`, kind `FastifyApp`, with the
single attribute `framework: "fastify"` — one kind and one attribute set in all
fifteen rules. Every relation addresses a key by explicit template; `current` is
used nowhere, so brief §3b's first-output trap cannot bite. No attribute is
named `path`, `name` or any other built-in (§3k), so `{path}` in a hub key is
always the artifact path.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **Which route serves `GET /users/:id`** | `call.method` named `get`/`post`/`put`/`patch`/`delete`/`options`/`head`/`all`, `call.arg0_text` beginning `/` | `Route` at **`http:{method}:{normalized_route}`**, attrs `method`, `route` |
| **Which handler answers that route** | the same call's `call.last_arg` | `Handler` `fastify:handler:{call.last_arg}`; `handles` route → handler |
| Which module declares that route | same call, artifact path | `declares` app → route |
| Which routes are declared as an options object | `call.method` named `route` | `Route` `fastify:route:{path}:{source.start}`, attr `declaration`; `declares` app → route |
| **Which lifecycle point does this hook run at** | `call.method` `addHook`, `call.arg0_text` | `FrameworkHook` `fastify:hook:{path}:{source.start}`, attr `hook` |
| **Which function runs at that lifecycle point** | the same call's `call.arg1` | `Handler` `fastify:handler:{call.arg1}`; `handles` hook → handler |
| **Which plugin is mounted here** | `call.method` `register`, `call.arg0_text` | `Plugin` `fastify:plugin:{call.arg0_text}`; `mounts` app → plugin |
| Which function in this repo *is* that plugin | `type_use.name` in the five `FastifyInstance`/`FastifyPlugin*` types, joined `within` a `definition.function` or `definition.variable` | `Plugin` `fastify:plugin:{fn.definition.name}` — the **same key space**, so a registered plugin and its declaration are one entity; `declares` app → plugin |
| Which function answers a request | `type_use.name` in the eleven `FastifyRequest`/`FastifyReply`/`Route*`/`*HookHandler` types, joined `within` a `definition.function`, `definition.variable` or `definition.method` | `Handler` `fastify:handler:{fn.definition.name}` — the **same key space** a route's last argument renders; `handles` app → handler |
| **What does this app add to the instance, request or reply** | `call.method` in `decorate`/`decorateRequest`/`decorateReply`, `call.arg0_text` | `Decoration` `fastify:decoration:{scope}:{call.arg0_text}`, attrs `scope`, `property`; `configures` app → decoration |
| **Which media types does this app parse, which function is its error handler** | `call.method` in the twelve `addSchema`…`withTypeProvider` names, `call.arg0_text` | `FrameworkConfig` `fastify:config:{path}:{source.start}`, attrs `operation`, `subject`; `configured_by` app → config |
| Which module builds the server | `call.function` named `Fastify`/`fastify`/`fastifyFactory` | `Server` `fastify:server:{path}:{source.start}`, attr `factory`; `declares` app → server |
| Which module starts it | `call.method` named `listen` | `Listener` `fastify:listener:{path}:{source.start}`; `configured_by` app → listener |
| Which Fastify packages does this module pull in | `import.module` name prefix `fastify` | `Dependency` `fastify:dependency:{name}`; `depends_on` app → dependency |
| …including the scoped official plugins | `import.module` name prefix `@fastify/` | same key space and kind |

Rows in bold are questions the previous file could not answer at all.

### What changed, rule by rule

| rule | change |
|---|---|
| `fastify.route.verb` | key `fastify:route:{path}:{start}` → `http:{method}:{normalized_route}`; gains attr `route`, a `Handler` output and a `handles` route → handler edge; `declares` replaces `handles` for the app edge; confidence `candidate` → `exact` |
| `fastify.hook.add` | gains attr `hook`, a `Handler` output and a `handles` hook → handler edge |
| `fastify.plugin.register` | `PluginRegistration` at an offset → `Plugin` at `fastify:plugin:{call.arg0_text}`, which the declaration rules also mint |
| `fastify.decorate` | key by offset → `fastify:decoration:{scope}:{property}`; gains attr `property` |
| `fastify.config.set` | gains attr `subject` |
| `fastify.handler.*` (3), `fastify.plugin.declaration.*` (2) | key `{path}:{fn.definition.name}` → `{fn.definition.name}`, so a route or a register call in another file addresses the same entity |
| `fastify.route.declarative` | `handles` → `declares` on the app edge |
| the remaining 4 | unchanged apart from coverage notes |

### Key containment (brief §3a)

Keys minted: `fastify:app:{path}`, `fastify:dependency:{definition.name}`,
`fastify:server:…`, `http:{method}:{normalized_route}`,
`fastify:route:{path}:{start}`, `fastify:plugin:{call.arg0_text}`,
`fastify:plugin:{fn.definition.name}`, `fastify:handler:{call.last_arg}`,
`fastify:handler:{call.arg1}`, `fastify:handler:{fn.definition.name}`,
`fastify:hook:…`, `fastify:decoration:{scope}:{property}`, `fastify:config:…`,
`fastify:listener:…`. Every key any relation addresses is minted by the rule
that addresses it, so the containment check holds by construction; the
cross-file joins (`fastify:handler:{…}`, `fastify:plugin:{…}`) are extra
agreement between rules, not the only source of an end.

### Attribute-drop guards (brief §3b)

`call.arg0_text` is a `default` to the empty string, so it always resolves and
needs no guard. `call.arg1` and `call.last_arg` are `None` when the call has too
few arguments, so `fastify.route.verb` carries
`field_present call.arg1` **and** `field_present call.last_arg`, and
`fastify.hook.add` carries `field_present call.arg1`. Without them a one-argument
call would drop the `Handler` entity and still render the `handles` edge.

## Coverage gaps, restated truthfully

Two remain, and both are the shape of the argument rather than the absence of
one.

- **An options object is one argument.** `fastify.route({ method, url, handler })`,
  `Fastify({ logger })` and `fastify.listen({ port, host })` put everything in a
  single object literal, and `call.arg0_text` is that literal verbatim —
  `{ method: 'GET', url: '/health', handler: health }`. So the declarative route
  form has no URL, the server has no options and the listener has no port. These
  three are still located by file and byte offset. Reaching inside would need the
  Pack to emit the object's properties as facts, which is a Pack question and not
  one Fastify should ask alone.
- **An inline handler has no name.** `fastify.get('/x', async (req, reply) => {})`
  renders `fastify:handler:async (req, reply) => {}` — a `Handler` whose name is
  its own source text. The route still resolves, and the edge still lands on
  something; it just lands on an anonymous function. `omega-framework-express`
  makes the same trade on `call.last_arg`.

The handler and plugin *declaration* rules remain TypeScript-only, because
`type_use.name` is a TypeScript emission. A plain-JavaScript Fastify project now
gets its routes **with their URLs**, its handlers by name from the route's last
argument, its hooks by lifecycle point, its decorations by property, its
registered plugins by name, its dependencies, server, configuration and
listener — but no type-derived `Handler` or `Plugin` declaration.

## A field only the Pack can supply

None requested. Everything above is reachable from a fact's kind, its own name,
its path, its span, the published call view, and the two joins
(`fact_join_by_field` on `path`, `fact_join_by_span` `within`).

## Still to decide

1. **The handler and plugin key spaces are no longer path-qualified.**
   `fastify:handler:{name}` is what makes `handles` reach a handler declared in
   another file, which is the whole point of the route rule. The cost is that two
   unrelated functions both called `handler` in two files become one entity. The
   values are identical apart from origin (both carry only `name`), so the
   `key_collisions.py` failure mode does not apply, but the merge is real.
   `omega-framework-express` keeps its type-derived handlers path-qualified and
   accepts that its route → handler edge never reaches them; this file made the
   opposite trade deliberately. If cross-framework consistency is wanted, express
   should move rather than fastify.
2. **`field_prefix call.arg0_text "/"` on the route verbs excludes a computed
   route.** ``fastify.get(`${prefix}/users`, h)`` has `call.arg0_text` starting
   with `$`, so it does not match. Per brief §3f that is a deletion and it is
   made knowingly: without the clause, every `map.get(k)` and
   `searchParams.get('q')` in a file that imports `fastify` becomes an HTTP route
   with an identity like `http:get:k`, which is worse than a missed template
   literal. The import gate alone is file-scoped and cannot separate them.
3. **`Decoration` is keyed project-wide, not per module.**
   `fastify:decoration:decorateRequest:user` is one entity however many plugins
   write it, which is right — it is one property on one request object — but it
   means the `configures` edge is many-to-one and *where* a decoration is
   declared is only recoverable from the edges.
4. **`Server` and `Listener` are close neighbours.** Both answer "where does this
   app start". Kept apart because a Fastify app is often built in one module
   (`buildApp()` for tests) and listened on in another, and knowing which is
   which is the difference between the test entry point and the production one.

## Not this Framework's problem

`omega-javascript` and `omega-typescript` **do** publish a field literally named
`qualifier`, on `binding.import_default`, `binding.import_symbol` and
`binding.import_namespace` — measured:
`binding.import_default name=Fastify qualifier=String("fastify")`. Per brief
§3i, `external_environment` builds `OverlayFact.external` from exactly that, so
the claim in `FRAMEWORK-BRIEF.md` §3i and in `00-INDEX.md`'s `OWED.md` item 7a
that "JS/TS facts carry no `external` at all" is at least partly stale for
binding facts. This file does not depend on it — the import join reaches the
same answer and works on `import.module`, which still publishes no qualifier —
but the brief's blanket statement is worth remeasuring before another JS
framework is written against it.
