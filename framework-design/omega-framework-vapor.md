# omega-framework-vapor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**13 overlay rules, 8 detection rules. 13 live, 0 cannot match.** (Was 12 rules,
12 live; before that 15 rules, 0 live.)

Selector: `framework:vapor`. Maturity: `semantic-overlay-full`. One language,
one Pack: `omega-swift`.

### Entities it declares

| entity_kind | key space | rules |
|---|---|---|
| `VaporType` | `vapor:type:{path}:{type}` -- the neutral hub | 9, all minting it identically |
| `VaporTypeName` | `vapor:type-name:{name}` | 7 |
| `Route` | `http:{method}:{normalized_route}` | 2, minting it identically |
| `RouteRegistrar` | `vapor:registrar:{path}:{fn}` | 2, minting it identically |
| `RouteGroup` | `vapor:group:{path}:{fn}:{normalized_prefix}` | 1 |
| `Controller`, `Model`, `Migration`, `Middleware`, `Payload`, `Worker` | one key space each: `vapor:controller:`, `vapor:model:`, ... | 1 each |
| `VaporFile`, `Dependency`, `RequestHandler`, `ModelField`, `Application` | one key space each | 1 each |

No key template is minted under more than one entity kind:
`python pack-design/key_collisions.py vapor` reports
`0 entity outputs are overwritten by a same-key rule that sorts first`.

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 7 |
| `has_role` | 6 |
| `depends_on`, `registers_route`, `serves`, `handles`, `has_field`, `mounts` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `relation.implements` | 6 | yes (omega-swift) |
| `call.arguments` | 3 | yes -- new, and the whole of this wave |
| `reference.type` | 2 | yes |
| `call.swift` | 1 + 1 join | yes |
| `import.swift_module` | 1 + 5 joins | yes |
| `definition.swift_type` | 9 joins | yes |
| `definition.swift_function` | 4 joins | yes |
| `definition.swift_property` | 1 join | yes |

Three rules now read Pack `fields`: `call.arg0` and `call.arg0_text` on
`call.arguments`. Everything else is a built-in -- `definition.name`, `path` --
or a `<bind>.definition.name` from a join.

---

## What was wrong with it

### This wave: a route had no URL, and the file said so in four places

The previous rewrite was written against a Pack that captured a call's callee
and nothing else. It said, correctly for the time:

> `vapor:route:{path}:{receiver}:{member}:{arg0}` was a key made of three
> things that do not exist.

and it keyed the `Route` entity by **file, declaring function, method and byte
offset** instead:

    vapor:route:{path}:{fn.definition.name}:{definition.name}:{source.start}

That is an identity no question reaches. *Which route serves `GET /todos`* was
unanswerable; *which file byte 167 of `TodoController.swift` is in* was the only
thing the key could be looked up by. Both route rules carried it, so **2 of 12
rules, 2 of the file's 30 entity outputs and 2 of its 18 relation ends** addressed an identity
that exists nowhere else in the graph and could never meet another framework's
route or a consumer's URL.

omega-swift now emits `call.arguments` on the same span as the call, with
`call.arg0`, `call.arg0_text`, `call.arg1`, `call.arg2` and `call.last_arg`.
Measured on a hand-written Vapor file with
`dump_call_emissions.exe packs/omega-swift grammars/omega-swift routes.swift`:

| source | fact | `call.arg0` | `call.arg0_text` |
|---|---|---|---|
| `routes.grouped("todos")` | `call.arguments grouped` | `"todos"` | `todos` |
| `todos.get(":todoID", use: show)` | `call.arguments get` | `":todoID"` | `:todoID` |
| `todos.get(use: index)` | `call.arguments get` | `use: index` | `use: index` |
| `todos.on(.PATCH, ":todoID", use: update)` | `call.arguments on` | `.PATCH` | `.PATCH` |
| `app.get("hello") { req in "hi" }` | `call.arguments get` | `"hello"` | `hello` |

So **four `coverage.gaps` sentences were false** as of this Pack version, and
one line of the "A field only the Pack can supply" section -- *"a string literal
in omega-swift is not a fact: the Pack's 43 templates emit no kind for a
`line_string_literal` anywhere"* -- was the reason the whole route design was
built around the byte offset. It is a 44th template now.

Three further things the measurement settled, each of which shaped a clause:

1. **`call.arguments` carries the callee as its own `name`.** It is not a bare
   argument bag, so the three route rules match it **directly** rather than
   matching `call.swift` and joining `fact_join_by_span relation: "same"` back
   to it. One fact, one clause, identical result.
2. **`call.arg0_text` is not always a path.** `todos.get(use: index)` is the
   ordinary Vapor spelling for a root route, and its first argument is the
   labelled handler. Keying on it would have minted `http:get:/use: index`. The
   gate is `field_prefix call.arg0 "\""` -- *the first argument is a string
   literal* -- which is exactly the discriminator, and it also drops
   `dictionary.get(key)`.
3. **`on` cannot be keyed by URL.** Its first argument is the method
   (`.PATCH`), its path is `call.arg1`, and `call.arg1` has **no** text form:
   the Pack strips quotes for `arg0` only. A canonical key template has no
   strip (brief 3l), so `":todoID"` with its quote bytes can never meet
   `:todoID`. `on` is out of the verb list, and that is now a gap sentence
   rather than a silent miss.

### The previous wave: the type classification was computed and thrown away

Nine rules minted an entity on the single key template
`vapor:type:{path}:{owner.definition.name}` under **seven different entity
kinds**, so `vapor.controller.declaration` sorted first and the graph lost
`Model`, `Migration`, `Middleware`, `Payload`, `Worker` and three `VaporType`
hubs -- **8 entity outputs overwritten**. The fix was brief 3g remedy 2, a key
space per classification, with the neutral hub minted identically by all nine
rules. It is untouched this wave, and `key_collisions.py` still reports nothing.

### The wave before: all 15 rules were dead

10 matched `call.swift_receiver_member_string_argument_context`, 1 matched
`call.swift_receiver_member_string_segment_context`, 2 matched
`call.target_candidate`, 2 matched `import.module_path_candidate` -- four kinds
no Pack emits -- and 11 of them **also** read `member`, `receiver`, `arg0` or
`literal`, fields no Pack published. Eleven of them were the same rule with one
string changed; four restated their input as `vapor:api-use:{path}:{source.start}`
with a `uses_api` self-loop; two named the package
`https://github.com/vapor/vapor.git`, which `parse_external_path` reads as the
package `https:`.

---

## What it states now

`{owner}`, `{fn}`, `{prop}`, `{reg}` below are `fact_join_by_span` / `within`
bindings on the current fact -- the enclosing type, function, property, or the
enclosing call. "hub" is the neutral `VaporType` at `vapor:type:{path}:{owner}`:
every rule that needs a type as a relation end mints it, all nine with the
identical kind and the identical two attributes.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **which URL a route serves, and with which method** | `call.arguments` named `get`…`webSocket` whose `call.arg0` begins with a quote, in a `Vapor`-importing file, + `{fn}` `definition.swift_function` | `Route http:{method}:{normalized_route}` (attributes `method`, `route`), `RouteRegistrar vapor:registrar:{path}:{fn}`, `registers_route` |
| **which URLs a controller serves** | the same, plus `{owner}` `definition.swift_type` | hub, `Route` at the identical key, `serves` |
| **which path prefix a function's routes sit under** | `call.arguments` named `grouped`/`group` with a literal first argument + `{fn}` | `RouteGroup vapor:group:{path}:{fn}:{normalized_prefix}`, `RouteRegistrar`, `declares` |
| which files are Vapor server files, and which part of the stack each pulls in (router, Fluent, **which database driver**, Leaf, JWT, Queues) | `import.swift_module` named in a 27-module list | `VaporFile vapor:file:{path}`, `Dependency vapor:package:{name}`, `depends_on` |
| which types register routes | `relation.implements` named `RouteCollection`/`AsyncRouteCollection` + `{owner}` | hub, `Controller vapor:controller:{path}:{owner}`, `VaporTypeName`, `declares`, `has_role` |
| which types back database tables | `relation.implements` in 6 `Model*` protocols + `{owner}` | hub, `Model vapor:model:{path}:{owner}`, `declares`, `has_role` |
| which types change the schema | `relation.implements` `Migration`/`AsyncMigration` + `{owner}` | hub, `Migration vapor:migration:{path}:{owner}`, `declares`, `has_role` |
| what sits in front of a handler (middleware, authenticators, lifecycle) | `relation.implements` in 13 protocols + `{owner}` | hub, `Middleware vapor:middleware:{path}:{owner}`, `declares`, `has_role` |
| which types cross the wire, and which are validated | `relation.implements` in 7 protocols (`Content`, `Validatable`, …) + `{owner}` | hub, `Payload vapor:payload:{path}:{owner}`, `declares`, `has_role` |
| what runs outside a request (queued job, scheduled job, CLI command) | `relation.implements` in 6 protocols + `{owner}` | hub, `Worker vapor:worker:{path}:{owner}`, `declares`, `has_role` |
| which functions answer a request | `reference.type` named `Request`/`WebSocket`, Vapor-importing file, + `{fn}` + `{owner}` | hub, `RequestHandler vapor:handler:{path}:{owner}:{fn}`, `handles` |
| which columns back a model, and which are associations (`@Parent`, `@Children`, `@Siblings`) rather than scalars | `reference.type` named in 15 Fluent wrappers + `{prop}` `definition.swift_property` + `{owner}` | hub, `ModelField vapor:model-field:{path}:{model}:{prop}`, `has_field` |
| which controllers, middleware, migrations and jobs the app **installs** | `call.swift` (upper-case initial) whose span lies inside `{reg}` a `call.swift` named `register`/`add`/`use`/`grouped`/`group`, Vapor-importing file | `Application vapor:app:{path}`, `VaporTypeName vapor:type-name:{name}`, `mounts` |

### What is newly answerable

Before this wave, *"where does `GET /todos` get served"* had no answer at all in
a Vapor project, and a `Route` node could not be reached except by knowing the
file and the byte offset it was written at. Now:

- `http:get:/todos` is one identity across the whole graph, and
  `http:get:/users/{}` is the same node whether it was written `:id` in Vapor,
  `{id}` in Spring or `[id]` in Next -- `normalize_http_path` folds all three.
- A controller's URL surface is a one-hop query: `serves` from
  `vapor:type:{path}:{Controller}`.
- A function's group prefix is stated, so *"what lives under `/api`"* has a
  partial answer where it previously had none.

### Three mechanisms worth naming

**"This file imports Vapor" is a `fact_join_by_field` on `path` against
itself.** `{"fact_kind": "import.swift_module", "current_field": "path",
"join_field": "path", "same_path": true, "where": [definition.name == "Vapor"]}`.
Both sides are the built-in `path`, so it needs no Pack field and is a real
gate: without it, `call.arguments` named `get` matches every `.get("…")` in
every Swift file in the repository. Five rules carry it. It is not the vacuous
`field_present` on a built-in that wave 6 found in symfony -- it constrains the
file, not the fact.

**`field_prefix` on `call.arg0` is how you ask whether an argument is a
literal.** `call.arg0` is the argument as written, quote bytes and all;
`call.arg0_text` is the same value stripped. Testing the quoted form and keying
on the stripped form (brief 3l) is what separates `todos.get(":todoID", …)` from
`todos.get(use: index)` without a Pack field.

**An entity's canonical key renders against its own attributes only.**
`emit()` calls `render(&canonical_key.template, binding, &values)` with that
output's `values`, and only *relation* ends see the accumulated `scope`
(`overlay.rs:884-955`). So `http:{method}:{normalized_route}` works inside the
`Route` output because `method` and `route` are its own attributes, and the
`registers_route` end two outputs later works because the scope carries them
forward. The `RouteRegistrar` and `RouteGroup` entities name their file
attribute `file`, not `path`, so nothing in the accumulated scope can shadow the
built-in `{path}` in a later relation end (brief 3k, the express `express:app:`
bug).

### Every relation end is minted by a rule with at least the conditions of the rule that addresses it

| key addressed | minted by |
|---|---|
| `vapor:file:{path}`, `vapor:package:{name}` | `vapor.dependency.import` (the only rule addressing either) |
| `vapor:type:{path}:{owner}` | all nine type-scoped rules, each as `VaporType` with the same two attributes |
| `vapor:controller:…`, `vapor:model:…`, `vapor:migration:…`, `vapor:middleware:…`, `vapor:payload:…`, `vapor:worker:…` | one rule each, the only minter and the only addresser of its key space |
| `http:{method}:{normalized_route}` | `vapor.route.registration` and `vapor.controller.route`, both as `Route` with the identical attributes; the second is the first's match plus one join, so the key always exists |
| `vapor:registrar:{path}:{fn}` | `vapor.route.registration` and `vapor.route.group`, both as `RouteRegistrar` with the identical attributes |
| `vapor:group:…`, `vapor:handler:…`, `vapor:model-field:…`, `vapor:app:{path}` | minted in the same rule that addresses them |
| `vapor:type-name:{name}` | the six role rules (from `{owner}`) and `vapor.component.mounted` (from the constructor's own name) |

`vapor:type-name:` is the one cross-file node. Swift resolves a type by its bare
name and omega-swift emits no qualifier, so `app.register(collection:
TodoController())` in `routes.swift` and `struct TodoController:
RouteCollection` in `Controllers/TodoController.swift` meet at
`vapor:type-name:TodoController`. No relation in this file addresses a key no
rule mints. No rule uses `Reference::current`, so the wave-2 "`current` is the
first output" trap does not apply. No attribute depends on `external.*`, so no
entity can be dropped as unresolvable while its relation still renders.

---

## Still to decide

- **Whether a `Route` should be keyed by the composed URL rather than the
  registration call's first argument.** `todos.get("todos", ":id")` states
  `/todos`, not `/todos/{}`; a route inside `routes.grouped("api")` states its
  own path, not `/api/…`. Composing either needs string concatenation of two
  facts, which the overlay has no operator for -- `expr.rs` lives in the Pack,
  and a canonical key template only substitutes. The alternative designs are
  both worse: keying by the whole argument list would produce quoted bytes in an
  identity (brief 3l), and keeping the old byte-offset key answers nothing. One
  path component that agrees with every other framework's identity beats a
  precise identity that agrees with nothing, so this stands until either a Pack
  publishes a composed `call.args_text` or the host gains a join operator.

- **`vapor.route.registration` and `vapor.controller.route` stay
  `confidence: candidate`.** omega-swift publishes no `receiver`, so a rule
  cannot tell `app.get("hello")` from `cache.get("hello")` in a file that
  happens to import Vapor. The literal-argument gate narrows it considerably --
  a dictionary lookup keyed by a literal in a Vapor file is rarer than a bare
  `.get(` was -- but it does not close it.

- **Whether `has_role` should be six relation kinds instead of one.**
  `is_model` / `is_middleware` / … would let a query reach a classification
  without reading a relation attribute, at the cost of six relation kinds in
  `emits`. One kind plus the role entity's own `entity_kind` already answers it
  twice over, so this stays one kind until a consumer asks.

- **`vapor.component.mounted` is heuristic.** It keeps a constructed type whose
  name does not begin with a lower-case letter, using twenty-six
  `field_not_prefix` clauses. `call.arg0_text` does not improve it:
  `app.register(collection: TodoController())` yields
  `collection: TodoController()`, label and parentheses included, while the
  nested `call.swift` named `TodoController` is the clean statement of the same
  thing. Left as it was.

## A field only the Pack can supply

The `arg0` half of this section is **discharged**: omega-swift publishes
`call.arg0` and `call.arg0_text` on `call.arguments`, and the three route rules
above are written against them.

What remains:

**Pack `omega-swift`, kind `call.arguments`, field `receiver`** -- the
`navigation_expression` prefix of the call, `app` in `app.get("hello")`. Ten
Packs publish the canonical call view; omega-swift publishes the five argument
fields but not `receiver`. It cannot be reached otherwise:

- **Not derivable.** The built-ins are `path`, `path.dir`, `path.stem`,
  `definition.name`, `enclosing.name`, `source.*`, `external.*`, `row_kind`.
  `definition.name` on this fact is the callee, `get`.
- **Not joinable.** The receiver is a `simple_identifier` inside the
  `navigation_expression`; omega-swift emits no fact spanning it (a property
  read outside call position is not recorded -- the Pack's own coverage guard
  says so), so there is nothing at that span for `fact_join_by_span` to bind,
  and `fact_join_by_field` would need the field being asked for.

It would retire `confidence: candidate` on `vapor.route.registration`,
`vapor.controller.route` and `vapor.route.group`, and it is one capture on a
query that already matches the node. This is reported for `OWED.md` rather than
acted on here; the thirteen rules above are written against what omega-swift
emits today.

**Pack `omega-swift`, kind `call.arguments`, field `call.arg1_text`** (and
`arg2_text`) -- the same strip applied to the later arguments. Without it,
`routes.on(.PATCH, ":id", use: update)` and the multi-component spelling
`todos.get("todos", ":id")` cannot contribute their path to an identity, because
a canonical key template has no strip. Lower priority than `receiver`: it buys
one Vapor spelling, where `receiver` buys precision for every Swift framework.
