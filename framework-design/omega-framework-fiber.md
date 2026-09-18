# omega-framework-fiber

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State, as it was before this rewrite

14 overlay rules, 4 detection rules. **0 can match, 14 cannot.**

Selector: `framework:fiber`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 6 |
| `Handler` | 6 |
| `Controller` | 4 |
| `Service` | 2 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Middleware` | 1 |
| `StaticResource` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 6 |
| `mounts` | 2 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `configured_by` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.go_receiver_string_identifier_context` | 6 | **no** |
| `definition.category_candidate` | 4 | **no** |
| `definition.go_import_alias_constructor_binding_context` | 2 | **no** |
| `definition.go_import_alias_group_binding_context` | 2 | **no** |
| `definition.go_unaliased_import_constructor_binding_context` | 2 | **no** |
| `definition.go_unaliased_import_group_binding_context` | 2 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.go_receiver_identifier_argument_context` | 1 | **no** |
| `call.go_receiver_method_chain_string_argument_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x32, `field_in` x20, `fact_kind` x14, `field_equals` x12, `path_glob` x8, `fact_join_by_field` x8, `(join)` x8, `attribute_equals` x4, `external_path_matches` x2.

Fields read: `import_path`, `constructor_name`, `method_name`, `receiver`, `path_literal`, `handler_identifier`, `group_method`, `package_receiver`, `binding`, `root_binding`, `group_binding`, `prefix`, `source.start`, `arg1_identifier`, `arg1`.

Path globs: `**/*.go`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `fiber.router.root` | kind `definition.go_import_alias_constructor_binding_context`; field `binding`, `constructor_name`, `import_path` |
| `fiber.router.group` | kind `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_binding`, `group_method`, `import_path`, `prefix`, `root_binding` |
| `fiber.route.root` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_constructor_binding_context`; field `constructor_name`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.route.group` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_method`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.router.root.unaliased` | kind `definition.go_unaliased_import_constructor_binding_context`; field `binding`, `constructor_name`, `import_path`, `package_receiver` |
| `fiber.router.group.unaliased` | kind `definition.go_unaliased_import_group_binding_context`; field `constructor_name`, `group_binding`, `group_method`, `import_path`, `package_receiver`, `prefix`, `root_binding` |
| `fiber.route.root.unaliased` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_unaliased_import_constructor_binding_context`; field `constructor_name`, `handler_identifier`, `import_path`, `method_name`, `package_receiver`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.route.group.unaliased` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_unaliased_import_group_binding_context`; field `constructor_name`, `group_method`, `handler_identifier`, `import_path`, `method_name`, `package_receiver`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.generic-api-call.github-com-gofiber-fiber-v2` | kind `call.target_candidate` |
| `fiber.generic-dependency.github-com-gofiber-fiber-v2` | kind `import.target_candidate` |
| `fiber.route.all` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `fiber.route.add` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `fiber.middleware.use` | kind `call.go_receiver_identifier_argument_context`; field `arg1_identifier`, `method_name`, `receiver` |
| `fiber.static.static` | kind `call.go_receiver_method_chain_string_argument_context`; field `arg1`, `method_name`, `receiver` |

## What was wrong with it

Two rewrites, two different faults. Both are recorded because the second one is
invisible unless you know the first.

### Pass 1: every rule was dead (14 of 14)

Measured before the first rewrite:

    omega-framework-fiber: 14 overlay rules, 4 detection rules -- 0 live, 14 cannot match

**Ten fact kinds, none of which any Pack emits (14 of 14 rules).** Every rule was
keyed to the old generator's private Go spellings —
`call.go_receiver_string_identifier_context` (6 rules),
`definition.category_candidate` (4), the four
`definition.go_*_import_*_binding_context` kinds (2 each),
`call.go_receiver_identifier_argument_context`,
`call.go_receiver_method_chain_string_argument_context`, plus the two carriers
the host never folded, `call.target_candidate` and `import.target_candidate`.

**Fifteen fields, none of which any Pack published.** `import_path`,
`constructor_name`, `method_name`, `receiver`, `path_literal`,
`handler_identifier`, `group_method`, `package_receiver`, `binding`,
`root_binding`, `group_binding`, `prefix`, `arg1_identifier`, `arg1`, and the
attribute `symbol_category`: 32 `field_present`, 20 `field_in` and 12
`field_equals` clauses reading values that could not exist.

**Eight rules were four rules written twice** — `.root` / `.root.unaliased`,
`.group` / `.group.unaliased` and so on, differing only in `binding` versus
`package_receiver`. Two more (`fiber.generic-api-call.*`,
`fiber.generic-dependency.*`) minted an entity named after their own input.

That pass produced 10 live rules.

### Pass 2: a route had no URL (7 of 10 rules)

The pass-1 file was clean by the audit and still could not answer the one
question a router framework exists to answer. Its own `coverage.gaps` said so:

> omega-go publishes no call argument, so no route path literal, no mounted
> directory and no Group prefix is reachable; a Route is identified by its
> registration site, and the URL it serves is not stated.

That sentence is now false. omega-go publishes `call.arg0`, `call.arg0_text`,
`call.arg1`, `call.arg2`, `call.last_arg` and `receiver` as fields on
`call.method` and `call.function`. Measured with `dump_call_emissions` on a
hand-written `main.go`:

    347-377  call.method  name=Get  call.arg0="\"/users/:id\""  call.arg0_text="/users/:id"
                                    call.arg1="getUser"  call.last_arg="getUser"  receiver="app"

The concrete damage in the pass-1 file, with counts:

| what was wrong | rules affected |
|---|---|
| `Route` keyed `fiber:route:{path}:{source.start}` — a byte offset, so the same URL in two files was two entities and no question could reach it by URL | 2 (`fiber.route.registration`, `fiber.route.registrar`) |
| the handler edge was guessed from `reference.member` inside the call span, which fires for every middleware argument as well as the handler, and misses a plain `getUser` that emits no member reference at all | 1 (`fiber.route.handler_reference`, 25 hand-maintained exclusions) |
| `RouteGroup` said a sub-router existed but not its prefix | 1 |
| `StaticResource` said files were served but not under which URL or from which directory | 1 |
| `Middleware` said a `Use()` happened but not which middleware | 1 |
| `Service` said the server started but not on which address | 1 |
| no rule at all for `fiber.New()`, because `New` could not be told from any other `New` without the receiver | 0 (missing) |

**10 rules -> 11, all live.**

    omega-framework-fiber: 11 overlay rules, 4 detection rules -- 11 live, 0 cannot match

Net: one rule deleted (`fiber.route.handler_reference`, superseded by
`call.last_arg`), two added (`fiber.app.construct`, made possible by `receiver`;
`fiber.route.add`, split out because `Add` puts the verb in argument 0), and
`fiber.route.registration` renamed `fiber.route.verb` and rekeyed by URL.

## What it states now

Every rule is gated on the same clause — a `fact_join_by_field` on `path`
requiring the file to import something under `github.com/gofiber/` — so
`call.method Get` never means `Map.Get`.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **Which URL does this route serve, and under which verb** | `call.method` named `Get`…`All`, `call.arg0_text` | `Route` `http:{method}:{normalized_route}`, `declares` from the `FiberFile` |
| **Which handler answers it** | the same call's `call.last_arg` | `HandlerName` `fiber:handler-name:{call.last_arg}`, `handles` Route -> HandlerName |
| Which files are Fiber files, and which part of the stack each pulls in | `import.package`, name prefixed `github.com/gofiber/` | `FiberFile` `fiber:file:{path}`, `Dependency` `fiber:package:{module}`, `depends_on` |
| Where the application object is constructed | `call.method` named `New` with `receiver` = `fiber` | `Application` `fiber:app:{path}:{offset}`, `declares` from the `FiberFile` |
| Which function wires the routing table up — *where do I add a route* | the same verb call, `within` `scope.function_body` | `RouteRegistrar` `fiber:registrar:{path}:{fn}`, `registers_route` -> the Route's URL key |
| A route registered with a non-standard verb | `call.method` named `Add`, `call.arg0_text` = the verb, `call.arg1` = the URL | `Route` `fiber:route:{path}:{offset}`, `handles`, `declares` |
| Which middleware are installed, and in which function | `call.method` named `Use`, `call.last_arg` | `Middleware` `fiber:middleware:{path}:{call.last_arg}`, `configured_by` from the `FiberFile` |
| Which URL subtree a sub-router owns | `call.method` named `Group`/`Route`/`Mount`, `call.arg0_text` | `RouteGroup` `fiber:group:{normalized_prefix}`, `mounts` from the `FiberFile` |
| Which URL prefix serves files off disk, and from which directory | `call.method` named `Static`, `call.arg0_text` + `call.arg1` | `StaticResource` `fiber:static:{normalized_mount}`, `uses_resource` from the `FiberFile` |
| Which function starts the server, on which address, and whether over TLS | `call.method` named `Listen`…`Listener`, `call.arg0_text` | `Service` `fiber:service:{path}:{fn}`, `declares` from the `FiberFile` |
| Which plain functions are Fiber handlers | `type_use.name` named `Ctx`, `within` `definition.function` | `Handler` `fiber:handler:{path}:{fn}`, `HandlerName` `fiber:handler-name:{fn}`, `declares` |
| Which types are controllers and which of their methods answer requests | `type_use.name` `Ctx` `within` `definition.method` **and** `within` `definition.receiver_candidate` | `Handler`, `Controller` `fiber:controller:{path}:{type}`, `declares` |

Three joins carry the file. `scope.function_body` is emitted for every function
and method body, so *which function does this* costs no Pack field.
`definition.receiver_candidate` spans the whole `method_declaration` and is named
for the receiver's type, so `within` reaches the owning struct — the only place
in Go where the link between a method and its type is written down. The import
join is the package gate.

**Key hygiene.** `http:{method}:{normalized_route}` is minted only by
`fiber.route.verb`; `fiber.route.registrar` addresses it and carries that rule's
clauses byte for byte, including `field_present call.arg1`, so it can never point
at a key that was not minted. `fiber:handler-name:{…}` is minted by
`fiber.route.verb` and `fiber.route.add` at the registration side and by
`fiber.handler.function` / `fiber.handler.method` at the declaration side, under
one kind, so an unrecognised handler still lands on an entity that exists. Every
FiberFile emission carries the identical attribute pair (`file`, `framework`), so
the first-rule-wins overwrite in `apply_overlay_runs` cannot lose anything.
No attribute is named `path`, `name` or any other built-in (brief 3k);
`{normalized_route}`, `{normalized_prefix}` and `{normalized_mount}` are the
route-normalized forms of the attributes `route`, `prefix` and `mount`.

    python pack-design/key_collisions.py fiber
    0 entity outputs are overwritten by a same-key rule that sorts first

## A field only the Pack can supply

**Pack: omega-go. Kind: `call.method` (and `call.function`). Field:
`call.arg1_text` — the second argument with its quote bytes stripped.**

`call.arg0_text` exists and is exactly what was needed; its sibling does not.
Two constructs in Fiber put the value that is an identity in argument 1:

- `app.Add("PURGE", "/cache", h)` — argument 0 is the verb, argument 1 is the
  URL. `call.arg1` arrives as `"\"/cache\""`.
- `app.Static("/assets", "./public")` — argument 1 is the directory served.

A canonical key template has no strip (`resolve_placeholder` renders a value
verbatim) and an attribute value is a constant, a `field_ref` or a
`normalize_route`, none of which strips. So:

- no built-in name reaches it — `definition.name` is `Add`, `path` is the file;
- no join reaches it — `fact_join_by_span` binds another *emission*, and omega-go
  emits nothing over a Go `interpreted_string_literal`; `fact_join_by_field`
  would have to join a quoted value against an unquoted one, which is precisely
  the mismatch brief 3j warns about.

The fix is the one already applied to argument 0: wrap `call.arg1` (and, for
symmetry, `call.arg2` and `call.last_arg`) in the same
`strip_prefix`/`strip_suffix` pair per quote style. It is not a new field in the
sense of new information — the bytes are already published — only a second
spelling of what is already there. This is not a Fiber peculiarity: `Add` is how
every Go router spells a custom verb, and a static mount everywhere names a
directory as its second argument.

**Second, smaller: omega-go emits no `definition.variable` for a short variable
declaration.** `api := app.Group("/api/v2")` publishes the `Group` call and its
prefix, but nothing binds the name `api`. That is an emission, not a field, and
it is what stops a route registered on a group from being nested under it — see
the second `coverage.gaps` entry.

## Still to decide

**The Route key does not include a group prefix.** `api.Get("/health", h)` is
keyed `http:Get:/health`, not `http:Get:/api/v2/health`. The receiver `api` is
now published, and the group's prefix is now published, but nothing links the
two because omega-go does not declare `api`. Recorded as a gap rather than
guessed at; the `receiver` attribute is carried on every Route so an agent can
at least see that the route was registered on something other than the app.

**`{method}` is the call's own name, so it is `Get`, not `GET` or `get`.**
The task's shape — `http:{method}:{normalized_route}`, method from the call name
— is followed literally. omega-framework-express follows the same shape and its
call names are lowercase, so a Go route and a Node route serving the same URL do
not unify on one key. There is no case-folding operator in
`resolve_placeholder`, and the alternative (ten per-verb rules each carrying a
literal `"GET"`) trades one rule for ten. Belongs in `00-INDEX.md` as a
cross-framework decision, not in this file.

**The `Ctx` handler test is still a heuristic, and is the only one in the file.**
A Fiber handler is `func(c *fiber.Ctx) error`; the fact the overlay sees is
`type_use.name` named `Ctx` somewhere inside the declaration. It will also fire
for a helper that merely mentions one. The alternative,
`definition.parameter_shape_candidate` — whose name is the literal parameter-list
text `(c *fiber.Ctx)`, measured — needs a substring test the clause vocabulary
does not have. It matters less than it did: the route -> handler edge no longer
depends on it, because `call.last_arg` names the handler at the registration.

**`field_present call.arg1` gates the route rules.** A verb call with a single
argument is not a valid Fiber registration (the handler is required), and
without the guard `call.last_arg` would fall back to argument 0 and mint a
`HandlerName` whose name is a quoted URL. The cost is that a malformed
registration is not reported at all.

**`fiber.app.construct` matches `receiver` = `fiber` literally,** so an aliased
import (`f "github.com/gofiber/fiber/v2"`) hides the constructor. Recorded in
`coverage.gaps`; the overlay has no access to an import's alias relative to a
call, and matching any `New` in a gofiber file would pick up `cors.New()`,
`limiter.New()` and every other middleware constructor.
