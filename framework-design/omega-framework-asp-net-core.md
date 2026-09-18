# omega-framework-asp-net-core

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**10 overlay rules, 4 detection rules. 10 live, 0 cannot match.**

Selector: `framework:asp-net-core`. Maturity: `semantic-overlay-full`.
It was 19 rules, all dead.

### Entities it declares

| entity_kind | minted by |
|---|---|
| `Controller` | `aspnet.controller.base`, `aspnet.controller.api-attribute`, `aspnet.action.http-attribute` |
| `Handler` | `aspnet.action.http-attribute`, `aspnet.action.authorization`, `aspnet.razor-page.handler` |
| `AuthorizationRule` | `aspnet.action.authorization` |
| `PageModel` | `aspnet.razor-page.model`, `aspnet.razor-page.handler` |
| `Pipeline` | `aspnet.pipeline.middleware`, `aspnet.endpoint.map` |
| `Middleware` | `aspnet.pipeline.middleware` |
| `Endpoint` | `aspnet.endpoint.map` |
| `Service` | `aspnet.services.registration`, `aspnet.injection.constructor` |
| `ServiceContainer` | `aspnet.services.registration` |
| `Component` | `aspnet.injection.constructor` |

### Relations it declares

| relation_kind | source -> target |
|---|---|
| `handles` | `Controller` -> `Handler`; `PageModel` -> `Handler` |
| `guards` | `AuthorizationRule` -> `Handler` |
| `configured_by` | `Pipeline` -> `Middleware` |
| `declares` | `Pipeline` -> `Endpoint` |
| `registers` | `ServiceContainer` -> `Service` |
| `injects` | `Component` -> `Service` |

Every canonical key a relation addresses is minted by the same rule that emits
the relation, so no end dangles.

---

## What was wrong with it

The file shipped **19 overlay rules and not one of them could match**, because
every rule was keyed to a fact kind from the generator's pre-rewrite C#
vocabulary. The breakdown, from `overlay_audit.py`:

| what it matched | rules | who emits it |
|---|---|---|
| `call.target_candidate` | 9 | nobody — the carrier the host never folded |
| `definition.csharp_class_base_context` | 2 | nobody |
| `definition.csharp_attributed_method_route_context` | 1 | nobody |
| `call.csharp_minimal_api_route_context` | 1 | nobody |
| `reference.csharp_attributed_class_string_context` | 1 | nobody |
| `reference.csharp_constructor_parameter_context` | 1 | nobody |
| `call.csharp_service_registration_generic_context` | 1 | nobody |
| `call.csharp_global_nested_member_string_context` | 1 | nobody |
| `definition.csharp_attributed_method_context` | 1 | nobody |
| `call.csharp_service_registration_typeof_context` | 1 | nobody |
| `call.csharp_global_member_string_context` | 1 | nobody |

Eleven distinct kinds, **all eleven private spellings for one language**, and
omega-c-sharp emits none of them. Its 38 templates publish 24 kinds, two fields
in total (`receiver_hint`, `qualifier`) and no attributes.

Four concrete defects on top of the dead kinds:

1. **Nine rules for nine spellings of one construct.**
   `aspnet.middleware.useauthentication` through `aspnet.middleware.usehsts`
   were nine copies of the same rule with a different literal in each, hard-coding
   nine of the ~40 `Use*` extensions ASP.NET ships. They are now **one** rule
   with a 29-name `field_in` list, and adding `UseRateLimiter` is one string.
2. **Eleven of its 16 relations were self-loops.** Every middleware rule and both
   of `aspnet.services.registration.typeof` / `aspnet.minimal-api-map-group`
   emitted `configured_by` from `{"kind": "current"}` to the very key the rule's
   own first `entity_candidate` had just minted. `Reference::Current` is the
   rule's first entity output (`emit()` sets `own_key` once, in output order), so
   each of those eleven edges ran `Middleware -> itself`. They stated nothing and
   are gone.
3. **Twelve fields no Pack publishes.** `base_name`, `attribute_name`, `route`,
   `path_literal`, `handler_identifier`, `argument_string`, `member`,
   `receiver_member`, `service_type`, `implementation_type`, `arg1`,
   `method_name`, plus `owner_class`, `parameter_name`, `parameter_type` and
   `receiver` used in key templates. omega-c-sharp publishes exactly two fields.
   Of the sixteen, thirteen are now reached by `definition.name` on the right
   fact or by a `fact_join_by_span` / `within`; the three that carry a string
   literal are unreachable and are recorded below and in `coverage.gaps`.
4. **Three entities that restated their input.** `RoutePrefix` keyed
   `{path}:{owner_class}:{argument_string}` with the prefix as its only
   attribute, `ConfigKey` keyed `{member}:{arg1}`, and `AuthorizationRule` keyed
   by its own attribute name — each with no relation to anything. `RoutePrefix`
   and `ConfigKey` are deleted; `AuthorizationRule` survives only because it now
   carries a `guards` edge to the action it protects.

Measured, not assumed: every claim about what omega-c-sharp emits was checked
with `dump_call_emissions.exe` against a hand-written controller, a `Startup`,
a `PageModel` and a top-level-statement `Program.cs`.

## What it states now

| what it states | which Pack fact | which entity or relation |
|---|---|---|
| this class is an MVC/API controller | `relation.implements` named `Controller`/`ControllerBase`/`ODataController`, joined `within` `definition.class` | `Controller` `aspnet:controller:{class}` |
| this class is an API controller by attribute | `reference.attribute` named `ApiController`, joined `within` `definition.class` | `Controller`, same key |
| this method is an action of that controller, answering this verb | `reference.attribute` named `HttpGet`…`HttpOptions`/`Route`/`AcceptVerbs`, joined `within` `definition.method` and `within` `definition.class` | `Handler` `aspnet:handler:{class}.{action}`; `Controller` --`handles`--> `Handler` |
| this action is guarded, and by what | `reference.attribute` named `Authorize`/`AllowAnonymous`/`RequireHttps`/`ValidateAntiForgeryToken`, joined to method and class | `AuthorizationRule` --`guards`--> `Handler` |
| this class is a Razor Page code-behind | `relation.implements` named `PageModel`/`RazorPageBase`, joined `within` `definition.class` | `PageModel` `aspnet:page:{class}` |
| this method answers a Razor Page verb | `definition.method` named `OnGet`…`OnPatchAsync`, joined `within` `definition.class` | `Handler`; `PageModel` --`handles`--> `Handler` |
| this file builds a request pipeline, out of these stages, in this order | `call.method` named one of 29 `Use*` extensions with `receiver_hint` present | `Middleware` `aspnet:middleware:{path}:{source.start}` with `order` = `source.start`; `Pipeline` --`configured_by`--> `Middleware` |
| this file maps these endpoints | `call.method` named one of 22 `Map*` extensions with `receiver_hint` present | `Endpoint` `aspnet:endpoint:{path}:{source.start}`; `Pipeline` --`declares`--> `Endpoint` |
| this type is registered in the container, with this lifetime | `reference.type` joined `within` a `call.method` named `AddScoped`/`AddSingleton`/`AddTransient`/`TryAdd*`/`AddHostedService`/`AddDbContext*`/`AddHttpClient`/`AddOptions`/`Configure` | `Service` `aspnet:service:{type}` with `lifetime`; `ServiceContainer` --`registers`--> `Service` |
| this class is handed this service by the container | `reference.type` joined `within` `definition.constructor` and `within` `definition.class` | `Component` `aspnet:component:{class}` --`injects`--> `Service` `aspnet:service:{type}` |

The two hubs are what make it worth having. `aspnet:service:{type}` is minted by
both the registration rule and the injection rule, so *where is `IOrderService`
registered, with what lifetime, and which classes take it in their constructor*
is one node with edges on both sides — and the two sides are usually in
different files (`Program.cs` and `OrdersController.cs`), which is exactly the
cross-file edge a language Pack cannot make. `aspnet:controller:{class}` is
minted by all three controller rules under identical conditions, so the
`handles` edges never point at a key no rule creates.

The `order` attribute on `Middleware` is `source.start`: ASP.NET middleware is
order-dependent, and the byte offset within `Program.cs` is the order.

## A field only the Pack can supply

**Pack `omega-c-sharp`; kinds `reference.attribute` and `call.method`; field: the
first string-literal argument.**

Three questions this framework exists to answer are unanswerable without it:

- *which URL does this action serve* — `[Route("api/[controller]")]`,
  `[HttpGet("{id}")]`
- *which path does this minimal API endpoint serve* — `app.MapGet("/orders", …)`
- *which configuration section is read here* — `Configuration.GetSection("Auth")`

Neither of the first two options in the brief reaches it:

- **No built-in name carries it.** `definition.name` on `reference.attribute` is
  the attribute's *name* (`Route`), measured; `definition.name` on `call.method`
  is the method's name (`MapGet`). Nothing else in the built-in list is
  argument text.
- **No join reaches it, because there is nothing to join to.** A
  `fact_join_by_span` binds another *emission*, and omega-c-sharp emits no fact
  for a string literal at all — its 38 templates cover namespaces, types,
  callables, members, `relation.implements`, `reference.type`,
  `reference.attribute`, `call.method` and imports, and none has a literal
  pattern. The attribute's span does cover the literal's bytes, but the overlay
  sees a span as two integers, never as source text.

The cheapest shape is a field on the templates that already exist rather than a
new kind: `argument_string` (or `arg0`) on the `attribute` and `call.member`
templates, taking the first `string_literal` child of the argument list when
there is one, absent otherwise. It costs bytes only on attributes and calls that
actually carry a literal, and a rule gates on it with `field_present`.

Note that it must be a **field**, not an attribute: `OverlayFact::field` never
consults `attributes`, so a value in `attributes` cannot become a canonical key,
a relation end or an entity attribute.

## Still to decide

- **Which type argument is the service.** `AddScoped<IOrderService, OrderService>`
  emits two `reference.type` facts inside the call span and nothing orders them
  for the overlay, so `aspnet.services.registration` states both as registered
  types with the same lifetime. That is honest but coarse. Distinguishing them
  needs either an ordinal on `reference.type` (a Pack field, and one with a cost
  on every type reference in every C# file) or a host clause that compares two
  bound facts' `source.start` — neither exists, and neither is worth buying for
  this alone. Recorded in `coverage.gaps`.
- **Constructor bodies are inside the constructor span.** `aspnet.injection.constructor`
  matches every `reference.type` within a `definition.constructor`, so
  `new Helper()` and `List<string> y` in the body are stated as injected
  alongside the real parameters (measured). The Pack spans the constructor as
  one node and emits no separate parameter-list region, so `within` cannot be
  narrowed. Restricting it to constructors of classes already known to be
  controllers is not expressible either: from the attribute or the type
  reference, `within definition.class` binds the class, but a join's `where`
  can only look *up* the span tree — `SpanRelation` has `Same` and `Within` and
  no "contains" — so a rule anchored on an inner fact cannot ask whether its
  enclosing class has a `relation.implements` inside it.
- **A class-level `[Authorize]` is invisible.** It lies within the class span
  exactly as a method-level one does, and the overlay has no negative join, so a
  rule that joined only the class would attribute every action's `[Authorize]` to
  the controller as well. `aspnet.action.authorization` therefore requires the
  method join and says nothing about controller-wide authorization. A
  `fact_join_absent` clause would settle it; that is a host change, not a Pack
  one.
- **C# 12 primary constructors.** `class Primary(IThing thing)` puts the
  parameter type inside `definition.class` and there is no `definition.constructor`
  (measured), so the injection rule misses it. Matching `reference.type` within a
  bare `definition.class` would sweep up every type named anywhere in the class,
  which is worse than the gap.
- **`path_glob "**/*.cs"` on `aspnet.injection.constructor` only.** That rule is
  the one whose fact kinds (`reference.type`, `definition.constructor`,
  `definition.class`) are generic enough to fire on Java or Dart in a mixed
  repository; the other nine are gated by ASP.NET-specific names. The glob costs
  Razor: omega-razor emits the same kinds for `.cshtml`/`.razor`, and clauses are
  conjunctive with no alternation, so one glob cannot name both extensions. The
  other nine rules carry no glob and therefore do cover Razor files.
