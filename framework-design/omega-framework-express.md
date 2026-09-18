# omega-framework-express

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

19 overlay rules, 4 detection rules. **8 can match, 11 cannot.**

Selector: `framework:express`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Middleware` | 5 |
| `ConfigEntry` | 5 |
| `RouterGroup` | 2 |
| `Route` | 1 |
| `Handler` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Application` | 1 |
| `Router` | 1 |
| `StaticResource` | 1 |
| `Listener` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 6 |
| `handles` | 1 |
| `mounts` | 1 |
| `middleware_wraps` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 11 | yes |
| `call.target_candidate` | 6 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.ecmascript_direct_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x19, `external_path_matches` x18, `field_present` x8, `field_equals` x3, `field_prefix` x1, `field_not_prefix` x1.

Fields read: `source.start`, `call.arg0`, `call.member`, `call_name`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `express.mount.use` | field `call.arg0`, `call.member` |
| `express.middleware.use` | field `call.arg0`, `call.member` |
| `express.generic-api-call.express` | kind `call.target_candidate` |
| `express.generic-dependency.express` | kind `import.target_candidate` |
| `express.app.construct` | kind `call.ecmascript_direct_context`; field `call_name` |
| `express.static.resource` | kind `call.target_candidate` |
| `express.route.builder` | field `call.arg0` |
| `express.middleware-factory.json` | kind `call.target_candidate` |
| `express.middleware-factory.urlencoded` | kind `call.target_candidate` |
| `express.middleware-factory.raw` | kind `call.target_candidate` |
| `express.middleware-factory.text` | kind `call.target_candidate` |

## What was wrong with it

**19 overlay rules; the audit called 8 live, and in a real repository all 19
matched nothing.**

| defect | rules |
|---|---|
| keyed to a fact kind no Pack emits (`call.target_candidate` x6, `import.target_candidate` x1, `call.ecmascript_direct_context` x1) | 8 |
| read a Pack field no Pack publishes (`call.arg0`, `call.member`, `call_name`, `call.last_arg`) | 12 -- 4 in `match`, 11 in an attribute or a canonical key |
| carried `external_path_matches` against package `express` | 18 |
| emitted a relation from an entity to itself | 11 |
| emitted no relation at all | 7 |
| keyed an entity by a field that cannot be read | 3 |

Only the first two rows are visible to `overlay_audit.py`. The other four are
the ones that mattered, and a reader had to find them.

**`external_path_matches` cannot match a JavaScript or TypeScript fact at all.**
`external_environment` (`materialize.rs:541`) registers an import only when the
binding has a `target_hint`; `target_hint` is `occurrence.qualifier`
(`surface.rs:376`); and `content_builder.rs:883,903` reads `qualifier` only from
a field or attribute literally named `qualifier`. omega-javascript publishes
`target` on `binding.import_alias`, omega-typescript publishes `target` and
`module`, and neither publishes `qualifier`. So `OverlayFact::external` is
`None` for every JS/TS fact, `ExternalMatch::matches` returns `false` on its
first line, and **18 of the 19 rules were gated on a clause that is false for
every possible input** — including all 8 the audit reported live. This is
`00-INDEX.md` / `OWED.md` item 7a, confirmed here by reading the chain end to
end. No rule in the new file uses the clause.

**omega-javascript, omega-typescript and omega-tsx publish zero fields on every
one of their 45, 58 and 60 templates.** The old file read `call.arg0`,
`call.last_arg`, `call.member` and `call_name`; none of those has ever existed
in the new Pack vocabulary, so the route URL, the mount prefix, the config key,
the static root, the listen port and the handler name were all unreachable.
Eleven rules put one of those fields in an attribute and three keyed an entity
by one -- `express:handler:{call.last_arg}`, `express:middleware:{call.arg0}`,
`express:router:{call.last_arg}`. An unresolvable attribute drops the entity and
keeps the relation (brief 3b), so those three rules emitted edges to entities
that were never created.

**Eleven rules emitted a relation from an entity to itself.** Every rule that
emitted a relation at all sourced it at `current` and targeted the canonical-key
template of its own first entity output -- `express.generic-api-call.express`
ran `uses_api` from `express:api-use:{path}:{source.start}` to
`express:api-use:{path}:{source.start}`, and the ten others did the same. That
is the self-loop wave 2 and wave 6 both found, here in every relation the file
had. **Seven more rules emitted no relation at all**, so no rule in the old file
put an edge between two different entities. The four
`express.middleware-factory.*` rules (`json`, `urlencoded`, `raw`, `text`)
minted a `Middleware` named after the literal in the rule id, with no relation
to anything; and with no receiver published, `express.json()` and `res.json()`
are the same fact, so those four would have fired on every JSON response in
the project. Deleted rather than ported.

**Eleven of the nineteen were one spelling of one construct.** `mount.use` and
`middleware.use` differed only by a `field_prefix "/"` on `call.arg0`, which
does not exist; the five `config.*` rules differed only by one string in a
`member_in` list of length one; the four `middleware-factory.*` rules likewise.

### Two decisions taken from evidence rather than from the old file

`call.method` in all three Packs is
`(call_expression function: (member_expression property: (property_identifier) @call.method))`
— **the property alone**, with the span of the property identifier. There is no
receiver, so `app.get` and `map.get` are one fact. Every call rule is therefore
gated on the artifact importing `express`, with a
`fact_join_by_field` on `path` against an `import.module` named `express`. That
join uses only built-in field names on both sides, so it costs no Pack field,
and `import.module` covers `import express from 'express'`, `import { Router }
from 'express'` and `const express = require('express')` alike (the Packs strip
the quotes in the template's `name` expression).

The list of HTTP verbs, config operations and handler type names was **not**
narrowed. Per brief 3f: the Packs capture the method name generically, so those
lists are the Framework's own choice, and every value dropped would be an answer
deleted.

## What it states now

**11 rules, all live, one key space per construct.** `express:app:{path}` is the
hub: every rule mints it, all of them as `Application` with the same one
attribute, and every relation is sourced there. `key_collisions.py express`
reports nothing.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which module creates the Express application | `call.function` named `express`, in a file importing `express` | `Application` at `express:app:{path}` |
| which modules depend on Express, and through what | `import.module` named `express` (ESM, named, or `require`) | `Dependency` at `express:dependency:express`; `Application depends_on Dependency` |
| which modules register routes, and with which HTTP method | `call.method` named `get`/`post`/`put`/`patch`/`delete`/`options`/`head`/`all` | `Route` at `express:route:{path}:{source.start}`, attribute `method`; `Application handles Route` |
| where middleware is installed | `call.method` named `use` | `Middleware` at `express:middleware:{path}:{source.start}`; `Application middleware_wraps Middleware` |
| which modules declare a router (i.e. are route modules) | `call.method` named `Router` (`express.Router()`), or `call.function` named `Router` (named import) | `Router` at `express:router:{path}:{source.start}`; `Application mounts Router` |
| which module starts the server | `call.method` named `listen` | `Listener` at `express:listener:{path}:{source.start}`; `Application configured_by Listener` |
| where the application is configured, and by which operation | `call.method` named `set`/`enable`/`disable`/`engine`/`param` | `ConfigEntry` at `express:config:{path}:{source.start}`, attribute `operation`; `Application configured_by ConfigEntry` |
| which modules serve static files | `call.method` named `static` | `StaticResource` at `express:static:{path}:{source.start}`; `Application uses_resource StaticResource` |
| **which functions are request handlers, and what they are called** | `type_use.name` in `Request`/`Response`/`NextFunction`/`RequestHandler`/`ErrorRequestHandler`, `fact_join_by_span` `within` a `definition.function` or a `definition.variable` | `Handler` at `express:handler:{path}:{fn.definition.name}`, attribute `name`; `Application handles Handler` |

The handler rules are the pair that states something no language Pack can: a
TypeScript function is an Express handler because of the types of its
parameters, which is a framework fact, not a syntax one. It is the same shape
omega-framework-fiber and omega-framework-gin use for `Ctx`. Two rules rather
than one because TypeScript emits `definition.function` for
`function listUsers(req: Request, ...)` and `definition.variable` for
`const listUsers = (req: Request, ...) => ...`, and both are ordinary Express;
they share one key template and one entity kind, so they are one entity either
way.

`definition.container` would have been cheaper than the span join and is
**wrong** here: the innermost `definition.*` fact containing a parameter type is
omega-typescript's `definition.parameter_shape_candidate`, whose name is the
whole parameter list text. That is the carrier caution in contract §2, measured
rather than assumed.

Every key a relation addresses is minted by the same rule that addresses it, or
is the hub that all eleven mint. Nothing dangles.

## A field only the Pack can supply

**Pack:** omega-javascript, omega-typescript, omega-tsx.
**Kind:** `call.method` and `call.function`.
**Field:** the text of the first argument when it is a string literal — call it
`arg0` — and the receiver spelling, `receiver_hint`.

Without `arg0` the overlay can say *this module registers a GET route* and never
*this module serves `GET /users/:id`*, which is the one question Express exists
to answer and the one the `Route` entity is shaped for. It cannot be derived:
`definition.name` is the method name, `path`/`path.stem` are the file, and
`fact_join_by_span` reaches only facts whose spans nest — the argument is a
sibling of the `@call.method` property identifier, never a container of it and
never contained by it, so no span relation exists between them. This is the same
row `OWED.md` already carries for omega-go and `app.Get("/users/:id", h)`; it is
a language-Pack gap, not an Express one, and the fix serves gin, fiber, axum,
vapor and every other route-by-call framework at once.

`receiver_hint` is the second half: `content_builder.rs:884` already reads a
field named `receiver_hint`, and `facts_of_surface` already prefers
`fields["receiver"]` + `fields["member"]` when resolving a fact's external path.
Publishing the receiver identifier on `call.method` would let `app.get` be told
from `map.get` without the per-file import gate, and — together with the
`qualifier` row of `OWED.md` item 1 — would make `external_path_matches` work
for the whole JavaScript family.

## Still to decide

- **The import gate is a module-level claim.** A file that imports `express` and
  also uses a `Map` will emit a `ConfigEntry` for `map.set(...)` and a `Route`
  for `cache.get(...)`. The alternative was to drop the verb, `use` and config
  rules entirely, which deletes the framework's principal answers; the gate
  keeps them at the cost of false positives in mixed files. `receiver_hint`
  closes this for good.
- **`handles` from `Application` to both `Route` and `Handler`, with no edge
  between them.** Which handler serves which route is exactly what `arg0` (the
  URL) plus the handler argument would give; until the Pack publishes argument
  text, the two are related only through the module, and inventing the edge
  would be inventing a fact.
- **JavaScript handlers are invisible.** `(req, res) => ...` in a `.js` file
  carries no type, so `express.handler.*` answers for TypeScript projects only.
  A `req`/`res` parameter-name heuristic was rejected: parameter names reach the
  overlay only through `definition.parameter_shape_candidate`'s name, which is
  the raw text of the whole parameter list, and matching on it would be encoding
  syntax (contract §5).
