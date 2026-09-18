# omega-framework-vapor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 8 detection rules. 12 live, 0 cannot match.** (Was 15 rules,
0 live.)

Selector: `framework:vapor`. Maturity: `semantic-overlay-full`. One language,
one Pack: `omega-swift`.

### Entities it declares

| entity_kind | key space | rules |
|---|---|---|
| `VaporType` | `vapor:type:{path}:{type}` -- the neutral hub | 9, all minting it identically |
| `VaporTypeName` | `vapor:type-name:{name}` | 7 |
| `Route` | `vapor:route:{path}:{fn}:{method}:{start}` | 2 |
| `Controller`, `Model`, `Migration`, `Middleware`, `Payload`, `Worker` | one key space each: `vapor:controller:`, `vapor:model:`, ... | 1 each |
| `VaporFile`, `Dependency`, `RouteRegistrar`, `RequestHandler`, `ModelField`, `Application` | one key space each | 1 each |

No key template is minted under more than one entity kind:
`python pack-design/key_collisions.py vapor` reports nothing.

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 6 |
| `has_role` | 6 |
| `depends_on`, `registers_route`, `serves`, `handles`, `has_field`, `mounts` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `relation.implements` | 6 | yes (omega-swift) |
| `call.swift` | 3 | yes |
| `reference.type` | 2 | yes |
| `import.swift_module` | 1 + 3 joins | yes |
| `definition.swift_type` | 9 joins | yes |
| `definition.swift_function` | 3 joins | yes |
| `definition.swift_property` | 1 join | yes |

No rule reads a Pack `field`: **omega-swift publishes no field on any of its 43
templates**, so the overlay has kind, name, path and span and nothing else.
Everything a rule reads is a built-in — `definition.name`, `path`,
`source.start` — or a `<bind>.definition.name` from a join.

---

## What was wrong with it

### This wave: the whole type classification was computed and thrown away

`overlay_audit.py` reported 12 rules, 12 live, 0 dead -- and nine of those rules
minted an entity on the single key template

    vapor:type:{path}:{owner.definition.name}

under **seven different entity kinds**. `Entity::named` builds its id from the
canonical key alone and `apply_overlay_runs` does `entities.entry(id)
.or_insert(entity)`, so the alphabetically first rule id wins with its kind *and*
its attributes. `vapor.controller.declaration` sorts first, so the graph got a
`Controller` and lost, silently:

| kind dropped | rule | what the answer was |
|---|---|---|
| `Model` | `vapor.model.declaration` | which types back database tables |
| `Migration` | `vapor.migration.declaration` | which types change the schema |
| `Middleware` | `vapor.middleware.declaration` | what sits in front of a handler |
| `Payload` | `vapor.payload.declaration` | which types cross the wire |
| `Worker` | `vapor.worker.declaration` | what runs outside a request |
| `VaporType` x3 | `.controller.route`, `.controller.handler`, `.model.field` | the hub the `serves`/`handles`/`has_field` edges hang off |

**8 entity outputs overwritten.** In practice that meant: in any Vapor project,
a type that conformed to `RouteCollection` anywhere in the file swallowed every
other classification in the same file for that type name, and -- worse -- a
`Model` in a file with no controller still lost its `role` and `conforms_to`
attributes to whichever of the six role rules happened to fire, because the
attributes collide exactly as the kind does. Five of the six answers the
previous section of this document advertised did not reach the graph at all.

The fix is brief 3g remedy 2, a key space per classification. Each role rule now
mints **two** entities: the neutral hub `vapor:type:{path}:{type}` as a
`VaporType` with the same two attributes (`name`, `path`) that every one of the
nine rules gives it -- so the nine agree and the hub is stable no matter which
sorts first -- and its own `vapor:<role>:{path}:{type}` carrying the kind, the
`role` and the `conforms_to` protocol name. A `has_role` edge runs hub -> role
entity. Remedy 1 (one neutral kind, classification in the relations) was
rejected because a Vapor type is routinely several things at once -- `final class
Todo: Model, Content` is the ordinary spelling -- and remedy 1 keeps one
attribute set, so `conforms_to` would still be lost for all but one role.

### The previous wave: all 15 rules were dead, and 14 of them dead twice over

| cause | rules |
|---|---|
| matched `call.swift_receiver_member_string_argument_context`, a kind no Pack emits | 10 |
| matched `call.swift_receiver_member_string_segment_context`, a kind no Pack emits | 1 |
| matched `call.target_candidate`, a carrier kind the Pack rewrite removed | 2 |
| matched `import.module_path_candidate`, likewise | 2 |
| **also** read `member`, `receiver`, `arg0` or `literal` — fields no Pack publishes | 11 |

Beyond the dead kinds, four things were wrong in kind, not in degree:

1. **Eleven rules were the same rule.** `vapor.route.get`, `.post`, `.put`,
   `.patch`, `.delete`, `.on`, `.websocket`, `.member-string`,
   `.literal-segment`, `vapor.group.group` and `.grouped` were byte-identical
   apart from one string in a `field_equals` on `member`. That is one rule over
   the callee's own name. They are one rule now (two, counting the
   controller-scoped variant).

2. **Four rules restated their input.** The two `vapor.generic-api-call.*` rules
   minted `vapor:api-use:{path}:{source.start}` — an entity whose whole content
   is the file and byte offset it was found at — and then ran `uses_api` from
   `current` to the key `current` had just been minted under: the self-loop
   wave 2 and wave 6 both found. The two `vapor.generic-dependency.*` rules did
   the same for imports. All four are deleted.

3. **Two of them were also unreachable in principle.** The
   `external_path_matches` package was `https://github.com/vapor/vapor.git`, a
   whole URL; `parse_external_path` splits on `/` and takes the first part, so
   the package there is `https:`. No input could ever match.

4. **The framework's central fact is not stated by any Pack, and the old file
   pretended otherwise.** Every route rule read `arg0` — the route's URL. The
   omega-swift call query is

   ```scm
   (call_expression . [(simple_identifier) @call.callee
                       (navigation_expression suffix: (navigation_suffix
                         suffix: (simple_identifier) @call.callee))]
     (call_suffix)) @call
   ```

   The callee is captured; **no argument is, and neither is the receiver.** So
   `app.get("todos", ":id")` reaches the overlay as one fact, `call.swift` named
   `get`. There is no `arg0`, no `receiver`, no string literal anywhere in
   omega-swift's 43 templates. `vapor:route:{path}:{receiver}:{member}:{arg0}`
   was a key made of three things that do not exist.

   The rewrite does not work around this. It states what is there — the HTTP
   method, the function that declares the route, the controller that owns it —
   and `coverage.gaps` now says the URL is unreachable instead of claiming
   "literal route components are materialized in source order".

The old file also spent its whole budget on routing, which is the one thing
Swift's facts cannot carry, and said nothing about models, migrations,
middleware, payloads, jobs or handlers — all of which are stated by
`relation.implements` and reachable exactly.

---

## What it states now

`{owner}`, `{fn}`, `{prop}`, `{reg}` below are `fact_join_by_span` / `within`
bindings on the current fact — the enclosing type, function, property, or the
enclosing call. "hub" is the neutral `VaporType` at
`vapor:type:{path}:{owner}`: every rule that needs a type as a relation end
mints it, all nine with the identical kind and the identical two attributes, and
the classification hangs off it as its own entity in its own key space.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are Vapor server files, and which part of the stack each pulls in (router, Fluent, **which database driver**, Leaf, JWT, Queues) | `import.swift_module` named in a 27-module list | `VaporFile vapor:file:{path}`, `Dependency vapor:package:{name}`, `depends_on` |
| which types register routes | `relation.implements` named `RouteCollection`/`AsyncRouteCollection` + `{owner}` `definition.swift_type` | `VaporType vapor:type:{path}:{owner}` (hub), `Controller vapor:controller:{path}:{owner}`, `VaporTypeName`, `declares`, `has_role` |
| which types back database tables | `relation.implements` in 6 `Model*` protocols + `{owner}` | hub, `Model vapor:model:{path}:{owner}`, `declares`, `has_role` |
| which types change the schema | `relation.implements` `Migration`/`AsyncMigration` + `{owner}` | hub, `Migration vapor:migration:{path}:{owner}`, `declares`, `has_role` |
| what sits in front of a handler (middleware, authenticators, lifecycle) | `relation.implements` in 13 protocols + `{owner}` | hub, `Middleware vapor:middleware:{path}:{owner}`, `declares`, `has_role` |
| which types cross the wire, and which are validated | `relation.implements` in 7 protocols (`Content`, `Validatable`, …) + `{owner}` | hub, `Payload vapor:payload:{path}:{owner}`, `declares`, `has_role` |
| what runs outside a request (queued job, scheduled job, CLI command) | `relation.implements` in 6 protocols + `{owner}` | hub, `Worker vapor:worker:{path}:{owner}`, `declares`, `has_role` |
| where routes are declared and **which HTTP methods** they answer | `call.swift` named `get`…`on`/`webSocket`, in a file that imports `Vapor`, + `{fn}` `definition.swift_function` | `RouteRegistrar vapor:registrar:{path}:{fn}`, `Route vapor:route:{path}:{fn}:{method}:{start}`, `registers_route` |
| which HTTP methods **a controller** serves | the same, plus `{owner}` `definition.swift_type` | `VaporType`, `Route` (same key), `serves` |
| which functions answer a request | `reference.type` named `Request`/`WebSocket`, Vapor-importing file, + `{fn}` + `{owner}` | `VaporType`, `RequestHandler vapor:handler:{path}:{owner}:{fn}`, `handles` |
| which columns back a model, and which are associations (`@Parent`, `@Children`, `@Siblings`) rather than scalars | `reference.type` named in 15 Fluent wrappers + `{prop}` `definition.swift_property` + `{owner}` | `VaporType`, `ModelField vapor:model-field:{path}:{model}:{prop}`, `has_field` |
| which controllers, middleware, migrations and jobs the app **installs** | `call.swift` (upper-case initial) whose span lies inside `{reg}` a `call.swift` named `register`/`add`/`use`/`grouped`/`group`, Vapor-importing file | `Application vapor:app:{path}`, `VaporTypeName vapor:type-name:{name}`, `mounts` |

### Two mechanisms worth naming

**"This file imports Vapor" is a `fact_join_by_field` on `path` against itself.**
`{"fact_kind": "import.swift_module", "current_field": "path", "join_field":
"path", "same_path": true, "where": [definition.name == "Vapor"]}`. Both sides
are the built-in `path`, so this needs no Pack field and is a real gate: without
it, `call.swift` named `get` matches every `.get(` in every Swift file in the
repository. Three rules carry it. It is not the vacuous `field_present` on a
built-in that wave 6 found in symfony — it constrains the file, not the fact.

**Every relation end is minted by a rule with at least the conditions of the
rule that addresses it** (brief §3a, §3b):

| key addressed | minted by |
|---|---|
| `vapor:file:{path}` | `vapor.dependency.import` (only rule addressing it) |
| `vapor:package:{name}` | same rule |
| `vapor:type:{path}:{owner}` | all nine type-scoped rules, each as `VaporType` with the same two attributes — the six role rules, **and** `vapor.controller.route`, `.controller.handler`, `.model.field`, because a type need not conform to `RouteCollection` to serve a route |
| `vapor:controller:…`, `vapor:model:…`, `vapor:migration:…`, `vapor:middleware:…`, `vapor:payload:…`, `vapor:worker:…` | one rule each, the only minter and the only addresser of its key space |
| `vapor:route:{path}:{fn}:{method}:{start}` | `vapor.route.registration`; `vapor.controller.route` is that rule's match plus one join, so the key always exists, and it mints it again anyway |
| `vapor:handler:…`, `vapor:model-field:…`, `vapor:registrar:…`, `vapor:app:{path}` | minted in the same rule that addresses them |
| `vapor:type-name:{name}` | the six role rules (from `{owner}`) and `vapor.component.mounted` (from the constructor's own name) |

`vapor:type-name:` is the one cross-file node. Swift resolves a type by its bare
name and omega-swift emits no qualifier, so `app.register(collection:
TodoController())` in `routes.swift` and `struct TodoController:
RouteCollection` in `Controllers/TodoController.swift` meet at
`vapor:type-name:TodoController` — the same device omega-framework-swiftui uses
for `ViewName`. No relation in this file addresses a key no rule mints.

No rule uses `Reference::current`, so the wave-2 "`current` is the first output"
trap does not apply; every end is an explicit `by_canonical_key`. No attribute
depends on `external.*`, so no entity can be dropped as unresolvable while its
relation still renders.

## Still to decide

- **Whether `has_role` should be six relation kinds instead of one.**
  `is_model` / `is_middleware` / … would let a query reach a classification
  without reading a relation attribute, at the cost of six relation kinds in
  `emits`. One kind plus the role entity's own `entity_kind` already answers it
  twice over, so this stays one kind until a consumer asks.

- **`vapor.component.mounted` is heuristic.** It keeps a constructed type whose
  name does not begin with a lower-case letter, using the same twenty-six
  `field_not_prefix` clauses omega-framework-swiftui uses to separate a child
  view from a chained modifier. `add`, `use` and `grouped` are ordinary Swift
  names, so the Vapor-import gate plus the upper-case initial is the whole
  filter; it is `confidence: candidate` for that reason. A tighter rule would
  need the receiver (`app.migrations`, `app.middleware`), which omega-swift does
  not capture.
- **`vapor.route.registration` accepts any `.get`/`.on` in a Vapor-importing
  file**, including `dictionary.get(...)`. Also `candidate`. The alternative —
  gating on the enclosing function being named `boot`, `routes` or `configure` —
  would drop routes registered from a helper, and Vapor does not require those
  names, so the looser rule with an honest confidence is the better trade.
- **A `Route` with no URL.** The entity exists because "which HTTP methods does
  this controller serve, and where are they declared" is a question worth
  answering, and it is the most this Pack permits. If it later reads as noise,
  the remedy is a Pack change, not a rule change — see below.

## A field only the Pack can supply

**Pack `omega-swift`, kind `call.swift`, fields `arg0` (first string-literal
argument) and `receiver`.**

Vapor's routing table — the single question an agent asks about a Vapor project,
*which URL does this route serve* — is a string literal in a call argument:
`app.get("todos", ":id")`, `routes.grouped("api", "v2")`, `@Field(key: "title")`,
`static let schema = "todos"`.

Neither of the first two options in the brief §2 reaches it:

- **Not derivable.** The built-in names are `path`, `path.dir`, `path.stem`,
  `definition.name`, `enclosing.name`, `source.*`, `external.*`, `row_kind`.
  `definition.name` for this fact is the callee, `get`. Vapor routing is not
  file-based, so `normalized_file_route` says nothing about it.
- **Not joinable.** `fact_join_by_span` relates a fact to a fact. A string
  literal in omega-swift is not a fact: the Pack's 43 templates emit no kind for
  a `line_string_literal` anywhere, so there is nothing at that span to join to.
  `fact_join_by_field` needs a published field on one side, which is the thing
  being asked for.

So it is genuinely a Pack change, and it is two captures on a query that already
matches the node:

```scm
(call_expression
  .  [ … @call.callee … ]
  (call_suffix (value_arguments (value_argument
    (line_string_literal) @call.arg0))) ) @call
```

`receiver` (the `navigation_expression` prefix) would separate `app.get` from
`dictionary.get` and retire the `confidence: candidate` on two rules; `arg0`
would give Vapor, and every string-keyed API in Swift, its URLs back. The cost
is the one the contract names: bytes on every `call.swift` emission in every
Swift repository. **`arg0` is the one that earns it** — without it no Swift
framework overlay can ever state a route path, a table name or a column name.
`receiver` is a smaller win and can wait.

This is reported for `OWED.md` rather than acted on here — the Pack is not this
agent's to edit — and the twelve rules above are written against what
omega-swift emits today.
