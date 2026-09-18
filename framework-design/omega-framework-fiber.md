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

All 14 rules were dead. Measured before the rewrite:

    omega-framework-fiber: 14 overlay rules, 4 detection rules -- 0 live, 14 cannot match

Three separable faults, with counts.

**Ten fact kinds, none of which any Pack emits (14 of 14 rules).** Every rule was
keyed to the old generator's private Go spellings —
`call.go_receiver_string_identifier_context` (6 rules),
`definition.category_candidate` (4), the four
`definition.go_*_import_*_binding_context` kinds (2 each),
`call.go_receiver_identifier_argument_context`,
`call.go_receiver_method_chain_string_argument_context`, plus the two carriers
the host never folded, `call.target_candidate` and `import.target_candidate`.
omega-go emits 47 templates and not one of these.

**Fifteen fields, none of which any Pack publishes.** `import_path`,
`constructor_name`, `method_name`, `receiver`, `path_literal`,
`handler_identifier`, `group_method`, `package_receiver`, `binding`,
`root_binding`, `group_binding`, `prefix`, `arg1_identifier`, `arg1` — and one
attribute, `symbol_category`. **omega-go publishes no `fields` and no
`attributes` on any of its 47 templates at all**, so every `field_present`
(x32), `field_in` (x20) and `field_equals` (x12) clause in the file read
something that cannot exist. The whole file was written against a Pack that no
longer exists.

**Eight rules were four rules written twice.** `fiber.router.root` /
`fiber.router.root.unaliased`, `.group` / `.group.unaliased`, `fiber.route.root`
/ `.root.unaliased`, `fiber.route.group` / `.group.unaliased` were byte-identical
apart from reading `binding` versus `package_receiver` — the difference between
`f := fiber.New()` reached through an aliased import and through an unaliased
one. The overlay has no access to an import's alias relative to a call, so the
distinction was never real; the collapse is 8 rules to 2.

Two rules were pure restatement. `fiber.generic-api-call.*` minted an `ApiUse`
keyed by the thing it had just read, and `fiber.generic-dependency.*` a
`Dependency` likewise, both over carrier kinds that resolved to nothing. Both
are gone; the dependency question is answered properly by
`fiber.dependency.import` over `import.package`.

**14 rules -> 10, all live.**

    omega-framework-fiber: 10 overlay rules, 4 detection rules -- 10 live, 0 cannot match

## What it states now

omega-go is an extreme case of the rewritten Pack vocabulary: kind, name, path
and span, and nothing else. Every rule below is built from those four, plus
`fact_join_by_span`/`within` and one `fact_join_by_field` on `path` that gates
each rule on the file importing something under `github.com/gofiber/`.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which Go files are Fiber files, and which part of the stack each pulls in (router, `middleware/*`, storage driver, template engine, contrib) | `import.package`, name prefixed `github.com/gofiber/` | `FiberFile` `fiber:file:{path}`, `Dependency` `fiber:package:{module}`, `depends_on` |
| Where an HTTP route is registered and under which verb | `call.method` named `Get`…`Add` (11 verbs), in a file that imports gofiber | `Route` `fiber:route:{path}:{offset}`, `declares` from the `FiberFile` |
| Which function wires the routing table up — *where do I add a route* | the same call, `within` `scope.function_body` | `RouteRegistrar` `fiber:registrar:{path}:{fn}`, `registers_route` -> Route |
| Where the request pipeline is assembled | `call.method` named `Use`, `within` `scope.function_body` | `Middleware` `fiber:middleware:{path}:{offset}`, `configured_by` from the registrar |
| Where the URL tree branches into sub-routers | `call.method` named `Group`, `Route`, `Mount` | `RouteGroup` `fiber:group:{path}:{offset}`, `mounts` from the registrar |
| Whether the service also serves files off disk, and from where in the code | `call.method` named `Static` | `StaticResource` `fiber:static:{path}:{offset}`, `uses_resource` from the registrar |
| Which function starts the server, and whether it serves TLS — the process entry point | `call.method` named `Listen`, `ListenTLS`, `ListenMutualTLS`, … | `Service` `fiber:service:{path}:{fn}`, `declares` from the `FiberFile` |
| Which plain functions are Fiber handlers | `type_use.name` named `Ctx` (from `*fiber.Ctx`), `within` `definition.function` | `Handler` `fiber:handler:{path}:{fn}`, `HandlerName` `fiber:handler-name:{fn}`, `declares` |
| Which types are Fiber controllers and which of their methods answer requests | `type_use.name` `Ctx` `within` `definition.method` **and** `within` `definition.receiver_candidate` | `Handler`, `Controller` `fiber:controller:{path}:{type}`, `declares` controller -> handler |
| Which handler answers a given registration — the one cross-file edge | `reference.member` `within` a route-registering `call.method`, with the registration and middleware-constructor names excluded | `HandlerName` `fiber:handler-name:{name}`, `handles` -> the `Route` |

Two joins carry the file. `scope.function_body` is emitted by omega-go for every
function and method body, so *which function does this* costs no Pack field.
`definition.receiver_candidate` spans the whole `method_declaration` and is named
for the receiver's type, so `within` reaches the owning struct from anything
inside the method — the only place in Go where the link between a method and its
type is written down, and the same trick omega-kotlin-multiplatform used on
`definition.modifier_candidate`.

Key hygiene: every canonical key a relation addresses is minted by a rule with
the same or weaker conditions. `fiber:registrar:…` is minted by each of the four
rules that address it; `fiber:handler-name:…` is minted by the two handler rules
*and* by `fiber.route.handler_reference` itself, so a route pointing at a symbol
that is not recognisable as a handler still lands on an entity that exists;
`fiber:route:…` is minted by `fiber.route.registration`, whose clauses are a
strict subset of those in the two rules that point at it.

## A field only the Pack can supply

**Pack: omega-go. Kind: `call.method`. Fields: the call's string-literal
arguments, and the receiver expression.**

Fiber's central question — *which URL does this route serve* — is the path
literal in `app.Get("/users/:id", h)`. omega-go's `call.method` template captures
`(call_expression function: (selector_expression field: (field_identifier)))`
and names the fact after the field identifier alone. The argument list is inside
the emission's span but is not published, and there is no fact of any kind over a
Go `interpreted_string_literal`, so:

- no built-in name reaches it — `definition.name` is `Get`, `path` is the file;
- no join reaches it — `fact_join_by_span` can only bind *another emission*, and
  omega-go emits nothing over the argument; `fact_join_by_field` needs a field on
  one side and omega-go publishes none anywhere.

The same gap costs the receiver: `app.Get` and `api.Get` are indistinguishable,
so a route registered on a group cannot be attributed to that group, and
`fiber.router.group` can say a sub-router exists but not what it is mounted
under. It also costs `app.Static("/assets", "./public")` its directory and
`app.Use(cors.New())` the identity of the middleware, which is why
`fiber.middleware.use` leans on the import in the same file instead.

This is not a Fiber peculiarity: every router in every language identifies a
route by a string argument to a call. A `call.method` field carrying the first
string-literal argument (and one carrying the receiver's text, as
`definition.receiver_candidate` already does for method declarations) would be
the single highest-value addition to the Go Pack for framework work. It is
recorded here rather than acted on, per the hard rules.

## Still to decide

**The `Ctx` handler test is a heuristic, and is the only one in the file.** A
Fiber handler is `func(c *fiber.Ctx) error`; the fact the overlay sees is
`type_use.name` named `Ctx` somewhere inside the declaration. It will also fire
for a helper that takes no `*fiber.Ctx` but mentions one in its body, and it
would fire for an unrelated `Ctx` type in a file that happens to import a gofiber
package. Both are narrow, and the alternative — matching
`definition.parameter_shape_candidate`, whose name is the literal parameter-list
text `(c *fiber.Ctx)` — needs a substring test the clause vocabulary does not
have (`field_prefix` cannot skip the parameter name). Judged worth the false
positives; revisit if `call.method` ever gains argument fields, at which point
the handler can be identified from the registration instead of from its
signature.

**Byte offsets in Route keys.** `fiber:route:{path}:{source.start}` is stable
only while the file is unedited. There is no better discriminator without the
path literal; the alternative, keying on `{path}:{verb}`, would merge every GET
in a file into one entity, which answers less. Revisit with the Pack field above.

**`reference.member` inside a registration is not filtered by position.**
`app.Get("/x", mw.RequireAuth, h.List)` relates both `RequireAuth` and `List` to
the route. Fiber genuinely allows several handlers per route, so this is not
plainly wrong, but middleware and the final handler are not distinguished. Nine
names that are certainly not handlers (`New`, `Name`, `Next`, and the
registration verbs themselves) are excluded; nothing more is reachable.
