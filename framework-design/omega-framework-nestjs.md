# omega-framework-nestjs

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**8 overlay rules, 4 detection rules. All 8 match.** (Was 31, of which 0
matched once the audit was scoped to `omega-typescript`.)

Selector: `framework:nestjs`. Maturity: `semantic-overlay-full`.
Language: TypeScript only; `host.required_packs = ["omega-typescript"]`.

## What was wrong with it

The audit reported **0 live, 31 cannot match**. Four separate causes, and each
one is worth naming because each was a different mistake.

**1. Twenty-three clauses named a scoped npm package (17 rules).** Every
class-level and method-level rule gated on
`external_path_matches package @nestjs/common` or `package_in [@nestjs/common,
@nestjs/websockets]`. Two things made that false for every possible input:
`parse_external_path` split on the first `/`, so the package was `@nestjs`;
and no JavaScript Pack published a field named `qualifier`, so
`OverlayFact.external` was `None` on every TypeScript fact and the clause
returned `false` before it read anything.

Both are fixed now — `parse_external_path` keeps a scoped package whole, and
`packs/omega-typescript` publishes `qualifier` on `binding.import_default`,
`binding.import_namespace` and `binding.import_symbol`. **The clause is still
not usable here**, for a third reason measured in this wave and written up
under *Cross-framework* below: `resolve_module_bindings` normalizes a binding's
`target_hint` through `import_module_keys`, whose default `ImportBasePolicy` is
`RootAndCurrent`, so `@nestjs/common` yields **two** candidate module keys and
`target_hint` is set to `None` for being ambiguous. The whole file is therefore
written on the import join instead, which needs no external environment at all.

**2. Five fact kinds no Pack emits (19 rules).**
`reference.typescript_method_parameter_decorator_context` (11 rules),
`import.ecmascript_named_binding_context` (15 clauses),
`reference.typescript_class_decorator_object_array_identifier_context` (5),
`reference.typescript_constructor_parameter_type_context` (1),
`call.target_candidate` and `import.target_candidate` (1 each). Each of these
named the shape of its own match rather than a fact; `omega-typescript` has 60
templates and 24 distinct output kinds, none of them these.

**3. Ten field names no Pack publishes**: `decorator_name`, `module_source`,
`imported_name`, `field_name`, `owner_class`, `item_identifier`,
`parameter_name`, `parameter_type`, `method_name`, `local_name` — plus
`decorator.arg0` and `decorator.member`, read in four canonical keys and eight
attributes. `omega-typescript` publishes exactly **one** field on exactly
**three** of its sixty templates: `qualifier` on the import bindings. Every
other value a rule wants must be the fact's name, its path, its span, or a
host built-in.

**4. Eleven rules that were one rule.** `nestjs.param.param`,
`.query`, `.body`, `.headers`, `.req`, `.res`, `.session`, `.ip`,
`.hostparam`, `.uploadedfile`, `.uploadedfiles` were byte-identical apart from
one string in a `field_equals` and one constant attribute. They are one rule
with a `field_in` now. The four enhancer rules (`guard`, `interceptor`,
`pipe`, `filter`) and the two `Catch`/`gateway` rules collapsed the same way.

`dangling_ends.py` reported **17 relation ends** addressing three key templates
nothing minted: `nestjs:handler:{path}:{owner_class}:{method_name}` (11),
`nestjs:module:{path}:{owner_class}` (5) and `nestjs:type:{path}:{owner_class}`
(1). All three are gone; every relation end in the new file is minted by the
rule that addresses it. `key_collisions.py` reported nothing before and
reports nothing now.

### Four rules were deleted rather than ported

`nestjs.module.imports`, `.providers`, `.controllers` and `.exports` read the
identifiers inside `@Module({ imports: [...], providers: [...] })`. Measured
with `dump_call_emissions` against `omega-typescript`: between the `@Module`
decorator name and the `class` keyword the Pack emits **nothing at all** — not
a call, not a reference, not a type use. The module graph is unreachable and
saying so is the complete answer. `nestjs.inject.token` went the same way: it
keyed on `decorator.arg0`, and a decorator's arguments are not published.

## What it states now

Measured on a hand-written Nest fixture with
`dump_call_emissions.exe packs/omega-typescript grammars/omega-typescript`.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files use NestJS, and which `@nestjs/*` packages does this project pull in | `import.module`, name prefixed `@nestjs/` | `Dependency` `nestjs:package:{name}`, `NestSourceFile` `nestjs:file:{path}`, `depends_on` |
| Which class is a controller / provider / module / gateway / exception filter | `definition.class` + same-path `reference.decorator` in {Controller, Injectable, Module, WebSocketGateway, Catch} | `NestClass` `nestjs:class:{name}`, `NestRole` `nestjs:role:{Role}`, `contains` role→class, `declares` file→class |
| Which HTTP verb does this controller method serve, and on which controller | `reference.decorator` named `Get`…`All`, with `definition.container` present | `Route` `nestjs:route:{path}:{offset}`, `handles` class→route |
| Which class answers websocket messages | `reference.decorator` named `SubscribeMessage`, container present | `MessageHandler`, `handles` class→handler |
| What does this handler read off the request, and which method is it | `reference.decorator` in {Param, Body, Query, …} joined `within` `definition.method` and `within` `definition.class` | `RequestBinding`, `Handler` `nestjs:handler:{path}:{Class}.{method}`, `contains` class→handler, `configured_by` handler→binding |
| **Which provider does this class inject** (the DI graph, across files) | `definition.field` (a constructor parameter property) `within` `definition.method constructor` and `within` `definition.class`, with `definition.return_type_candidate` on the **same span** carrying the type | `injects` `nestjs:class:{Consumer}` → `nestjs:class:{Provider}`, parameter name as a relation attribute |
| Which guards / interceptors / pipes / filters are bound inside a class | `reference.decorator` in {UseGuards, UseInterceptors, UsePipes, UseFilters}, container present | `EnhancerBinding`, `configured_by` class→binding |
| Which Nest contract does this class implement — is it a guard, a pipe, a lifecycle receiver | `relation.implements` named in a 14-value contract list, `within` `definition.class` | `NestContract` `nestjs:contract:{Name}`, `implements` class→contract |

Every rule but `nestjs.dependency.package` carries the same gate, the one the
fastify and next-js overlays use:

```json
{"kind": "fact_join_by_field", "fact_kind": "import.module",
 "current_field": "path", "join_field": "path", "same_path": true,
 "where": [{"kind": "field_prefix", "field": "definition.name",
            "value": "@nestjs/"}]}
```

*This file imports something from `@nestjs/`* is what keeps `@Injectable` from
meaning Angular's and `@Get` from meaning some other library's decorator, and
it depends on nothing outside the file.

### The measurement the whole design turns on

`omega-typescript` spans `definition.class` from the `class` keyword and
`reference.decorator` on the decorator's name identifier. For the spelling
every Nest file uses —

```ts
@Controller('users')
export class UsersController { @Get(':id') findOne(@Param('id') id: string) {} }
```

— the decorator is a child of the `export_statement`, **before** the
`class_declaration`, so `@Controller` at bytes 238–248 is neither inside the
class at 287–644 nor carried by it. The same holds for method decorators:
`@Get` at 415–418, `findOne` at 428–546. A decorator is a **sibling** of what
it decorates, and there is no sibling or precedes clause.

Three consequences, all of them load-bearing:

- A **member** decorator is still inside the *class*, so the host's
  `definition.container` names the class for `@Get`, `@UseGuards` and
  `@SubscribeMessage`. `field_present definition.container` is a genuine test
  here — the host writes that field only when some definition encloses the fact
  — and it is exactly what separates a method decorator from a class decorator.
- A **class** decorator has no enclosing definition at all, so `@Controller`
  cannot name its class. `nestjs.class.role` joins the two on the artifact path
  instead. That is right for the one-decorated-class-per-file layout the Nest
  CLI generates and over-attributes in a file declaring several classes.
- A **parameter** decorator is the one that *does* lie inside what it
  decorates, because the formal parameter list is inside the method. That is
  why `nestjs.handler.request-binding` is the only rule that reaches a handler
  method by name.

Measured alongside it, and worth keeping: for a class that is **not** exported,
`@Injectable() class Plain {}`, the decorator *is* inside `definition.class`.
It is `export` that moves it out. Do not generalise either way without
re-running the spelling.

## A field only the Pack can supply

**Pack `omega-typescript` (and `omega-tsx`), kind `reference.decorator`, field
`arguments` — the decorator call's argument text.**

Nest writes its identities into decorator arguments and nowhere else:
`@Controller('users')`, `@Get(':id')`, `@SubscribeMessage('events')`,
`@Inject('CONFIG')`, `@UseGuards(AuthGuard)`, and the whole of
`@Module({ imports, controllers, providers, exports })`. Without them this
overlay can say *this method serves a GET on UsersController* but never *this
method serves `GET /users/:id`* — the single question an agent most wants to
ask of a Nest project.

Neither of the two cheaper routes reaches it:

- **No built-in name carries it.** `OverlayFact::field` serves `path`,
  `path.dir`, `path.stem`, `definition.name`, `enclosing.qname`,
  `definition.container`, `definition.qname`, `source.start`/`end`,
  `external.*` and `row_kind`. The argument is source text inside the
  decorator's own node; none of those is it.
- **No join reaches it**, because the Pack emits no fact over the argument.
  `@Get(':id')` produces exactly two emissions, `reference.decorator Get` and
  `call.function Get`, both spanning the identifier `Get` alone. There is
  nothing at `':id'` to join `within` or `same` to. The same holds for
  `@Module({...})`: measured with `dump_call_emissions`, the 129 bytes between
  `@Module(` and `class UsersModule` produce **zero** emissions, so the array
  identifiers `[UsersService]` cannot be reached either.

This is the same shape as the row `OWED.md` already carries for omega-go
(`app.Get("/users/:id", h)` has its path in a string literal and omega-go
publishes no argument text). It is one field on one template, and it would give
nestjs, angular, tauri and astro their URLs at once.

## Still to decide

1. **The class key is path-free — `nestjs:class:{Name}`.** That is deliberate:
   a Nest provider token *is* the class, and the injection site
   (`users.controller.ts`) and the declaration (`users.service.ts`) are always
   in different files, so a path-scoped key could never join them. The cost is
   that two unrelated classes with the same name anywhere in a repository
   become one node. kotlin-multiplatform made the same trade for `expect`, and
   for the same reason. If this proves wrong, the fix is a second key space
   scoped by `path.dir` and a relation back to the hub — not a path in the hub
   key.

2. **`nestjs.class.role` joins a decorator to a class on the artifact path.**
   It is the only rule in the file that asserts something the spans do not
   prove, and it is there because the alternative is losing *which class is a
   controller* entirely. It is exact for Nest CLI layout. The honest
   alternative is to delete it and let the role be inferred from the edges
   (a class with `handles` edges is a controller, a class that is the target of
   `injects` is a provider) — which would be strictly true but would leave
   `@Injectable` services with no in-edges unclassified.

3. **`NestRole` is a global classification node, not an entity kind per role.**
   Brief §3g prefers one neutral kind per key space with the classification in
   the relations, and that is what this is: `nestjs:role:Controller` holds every
   controller as `contains` out-edges. The alternative — `Controller`,
   `Service`, `Module`, `Gateway` and `ExceptionFilter` as five entity kinds on
   five key spaces — would be five near-identical rules and would put the
   classification back on the key, which is what collided in maui.

## Cross-framework: `external_path_matches` is still false in TypeScript, and the reason has moved

The `qualifier` change landed and `parse_external_path` keeps a scoped package
whole, so the two causes `OWED.md` items 7 and 7a name are both closed. The
clause is still unusable for JS/TS, one layer further down:

`resolve_module_bindings` (`omega-runtime/src/build/production.rs:4310-4321`)
overwrites every binding's `target_hint` with
`import_module_keys(&candidates, &raw, rules, 64)`, and sets it to `None`
unless exactly one key survives. `omega-typescript`'s manifest declares no
module policy, so `ModuleRuleSet::default()` applies and `import_base` is
`RootAndCurrent` — which seeds `bases` with **both** the empty root and the
current artifact's own module key. For `@nestjs/common` in
`src/users/users.controller.ts` that yields
`{"@nestjs/common", "src/users/users.controller.ts/@nestjs/common"}`: two exact
keys, `target_hint = None`, no entry in the `ExternalEnvironment`, and
`OverlayFact.external` is `None` on every fact in the file.

This is not a nestjs problem — it is every JavaScript and TypeScript Framework,
and any Pack that declares no module policy. The remedy is one of: give the
JS/TS Packs a `[module]` policy with `import_base = "root"` for a bare
specifier; or teach `import_module_keys` that a specifier which is not relative
(no `.`/`..` marker) has no current-relative form. Neither is a Framework's
edit. Until it lands, `external_path_matches` should be treated as false in
every language but C# and docker-compose, exactly as brief §3i says, and the
import join is the gate. Angular, tauri and astro are still scheduled behind
item 7 and should be written on the join too.
