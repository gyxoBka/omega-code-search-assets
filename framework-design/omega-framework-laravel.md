# omega-framework-laravel

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**16 overlay rules, 4 detection rules. All 16 match.** (Was 32 rules, 19 "live"
by the audit and, measured, 0 that could ever emit an edge.)

Selector: `framework:laravel`. Maturity: `semantic-overlay-full`.
Languages: `php`, `blade` — packs `omega-php`, `omega-blade`.

### Audit

```
before  omega-framework-laravel: 32 overlay rules, 4 detection rules -- 19 live, 13 cannot match
after   omega-framework-laravel: 16 overlay rules, 4 detection rules -- 16 live, 0 cannot match
```

---

## What was wrong with it

The audit said 13 of 32. The audit was being generous, because it asks whether
*any* Pack emits a kind, not whether the Pack this framework runs on does.
Measured against `packs/omega-php/rules.json` and against real emissions from
`dump_call_emissions`, **all 32 rules matched nothing**, for four independent
reasons that each on its own would have been fatal.

**1. `call.member` is a C fact. 26 of the 32 rules were keyed to it.**
`omega-php` emits `call.function`, `call.method`, `call.static_method` and
`call.constructor`. The only Pack in the repository that emits `call.member` is
`omega-c`. So 26 rules — every route rule, every route-config rule, every
facade rule, the schema rule and the five `api.*` rules — were keyed to a kind
their own language does not produce, and the audit reported them live.

**2. No PHP fact carries an `external` package, so all 28
`external_path_matches` clauses fail for every possible input.**
`facts_of_surface` fills `external` from `external_environment`, which reads
`binding.target_hint`; `target_hint` is `occurrence.qualifier`; and `qualifier`
is read only from a Pack field or attribute literally named `qualifier`.
`omega-php` publishes **no field and no attribute on any of its 51 templates**.
So `external_path_matches` with `package: "Illuminate\\Support\\Facades\\Route"`
could not match even if the kind had been right. (This is `OWED.md` item 7a,
already recorded for JS/TS; it is the same mechanism and it covers PHP too.)
For good measure `parse_external_path` splits on `/`, `::` and `.` and not on
`\`, so a PHP namespace would have arrived as one opaque package name anyway.

**3. 58 reads of `call.arg0` / `call.arg1`, a field no Pack publishes.**
36 uses of `call.arg0` and 22 of `call.arg1`, as canonical-key placeholders, as
entity attributes and as relation targets (`by_field: call.arg1`). The route
path, the view name, the table name and the handler were all taken from there.

**4. 22 of the 32 rules could not have added an edge even so.**
20 rules emitted `entity K` then `relation source: current, target: K` — and
`emit()` sets `own_key` from the rule's *first* entity output, so `current` **is**
`K`. Each of those 20 was an edge from a node to itself: `laravel.api.dispatch`,
`.listen`, `.mail`, `.push`, `.queue`, `laravel.constructor.di`,
`laravel.generic-api-call.laravel-framework`, the six `laravel.route-config.*`,
`laravel.route.apiresource`, `.fallback`, `.redirect`, `.resource`, `.view`,
`laravel.schema.create` and `laravel.view.call`. Two more —
`laravel.model.class` and `laravel.controller.class` — emitted an entity and no
relation at all, keyed by their own input's name. The remaining 10 aimed their
relation at `by_field: call.arg1`, which renders to nothing (reason 3), so the
relation was dropped. **The file, as shipped, could not put one edge in the
graph.**

Two further shapes of waste: nine rules (`laravel.route.facade` plus one per
HTTP verb) described the same construct, and sixteen entity kinds existed of
which eleven were named after the call that produced them (`QueueUse`,
`MailUse`, `ApiUse`, `ViewRoute`, `RedirectRoute`, `FallbackRoute`,
`EventDispatch`, `EventListener`, `InjectionPoint`, `SchemaMigration`,
`FrameworkConfig`) rather than after anything a person would ask about.

---

## What it states now

Every rule is reached by `fact_kind` plus `fact_join_by_span` with `within` and
`same_path: true`. **No rule reads a Pack-published field**, because neither
Pack publishes one; everything comes from the kind, the name, the path and the
span. Entity identity is one namespace per entity kind, so two rules naming the
same class agree on its key.

| what it answers | the Pack fact it reads | the entity or relation it states |
|---|---|---|
| which classes are models, controllers, jobs, migrations, form requests, providers, commands, mailables, notifications, API resources, seeders, factories, tests, Blade/Livewire components, validation rules | `relation.implements` (PHP spells `extends`, `implements` and `use Trait` all as this) named one of 54 Laravel bases, joined `within` `definition.class` | `LaravelClass laravel:class:{Class}` **extends** `LaravelBase laravel:base:{Base}` |
| which models this model relates to, by which accessor and which relation kind | `reference.class` (`Post::class`) inside `call.method hasMany`/`belongsTo`/… inside `definition.method` inside `definition.class` | `LaravelClass` **depends_on** `LaravelClass`, attributes `relation`, `accessor` |
| which models a controller or job reads and writes | `reference.class` inside `call.static_method` named one of 32 Eloquent statics (`all`, `find`, `create`, `where`, `paginate`, …), inside `definition.class`; facade names excluded | `LaravelClass` **depends_on** `LaravelClass`, attribute `via` |
| which route registrations a file declares, and with which verb | `reference.class Route` inside `call.static_method` named one of 18 routing verbs | `RouteFile laravel:route-file:{path}` **declares** `Route laravel:route:{path}:{offset}`, attribute `method` |
| **which class answers a route** | the *other* `reference.class` in the same `Route::verb(...)` call, in `routes/*.php` | `Route` **handles** `LaravelClass` |
| what a class asks the container for | `type_use.name` inside `definition.method __construct` inside `definition.class` | `LaravelClass` **injects** `LaravelClass` |
| which jobs a class dispatches | `reference.class` inside `call.static_method dispatch`/`dispatchSync`/… inside `definition.class` | `LaravelClass` **depends_on** `LaravelClass`, attribute `via` |
| which events a class fires | `call.constructor` inside `call.function event`/`broadcast`/`dispatch`/`report`, inside `definition.class` | `LaravelClass` **depends_on** `LaravelClass`, attribute `via` |
| which classes are middleware (the one Laravel role with no base class) | `definition.class` under `app/Http/Middleware/**` | `LaravelClass` **extends** `LaravelBase laravel:base:Middleware` |
| which layout a template extends | `relation.depends` with attribute `directive = @extends` | `View laravel:view:{path}` **extends** `ViewName laravel:view-name:{dotted}` |
| which partial a template includes | `relation.depends` with `directive = @include` | `View` **renders** `ViewName` |
| which Blade components a template renders | `reference.blade_component` (`<x-forms.input>` and `@component('…')`) | `View` **renders** `BladeComponent laravel:blade-component:{name}` |
| **which template fills the section a layout yields** | `definition.template_section` (`@section`) and `reference.template_section` (`@yield`), keyed by section name so the two files meet | `View` **provides** / **depends_on** `ViewSection laravel:view-section:{name}` |
| which template pushes onto the stack a layout renders | `definition.template_stack` (`@push`) and `reference.template_stack` (`@stack`) | `View` **provides** / **depends_on** `ViewStack laravel:view-stack:{name}` |

Eleven canonical-key templates are minted; eleven are addressed by a relation
end; the second set is contained in the first, and every relation's two ends are
minted by the rule that emits them, so nothing dangles.

### Rules deliberately kept against nothing

None. All 16 match a fact `omega-php` or `omega-blade` emits today, reproduced
with `dump_call_emissions` on hand-written Laravel source before the rule was
written.

---

## A field only the Pack can supply

**Pack `omega-php`; kinds `call.function`, `call.method`, `call.static_method`;
field `call.arg0` (the first argument when it is a string literal).**

Laravel names things with string literals in calls, and that is the whole of its
routing, view and schema vocabulary:

```php
Route::get('/users', [UserController::class, 'index']);   // the URL
return view('users.index', $data);                        // the template
Schema::create('users', function (Blueprint $t) { ... }); // the table
config('services.stripe.key');                            // the config key
```

Without it the overlay can say *this is a GET route handled by
`UserController`* but not *which URL it serves*; *this action renders a view*
but not *which one*; *this migration exists* but not *which table it builds*.
Those are four of the questions `FRAMEWORK-BRIEF.md` §1 names as the point of a
Framework, and all four are currently unanswerable for the most widely used PHP
framework.

Neither of the first two options in the brief reaches it:

- **Derivation cannot.** `definition.name` of the call is the method name
  (`get`), not its argument; `path`, `path.dir` and `path.stem` describe the
  file. Nothing built in names an argument.
- **A join cannot.** `fact_join_by_span` relates two *facts*. `omega-php` emits
  no fact for a string literal at all — no `literal.string`, no
  `definition.constant` for an inline argument — so there is no fact inside the
  call's span to join to. The span join works for `UserController::class` only
  because a class name happens to be a `reference.class`; `'/users'` produces
  nothing.

An alternative that costs the same and answers more: a Pack fact
`literal.string` for every string literal, spanned on the literal. Then the
existing `fact_join_by_span`/`within` reaches it from the call with no new field
and no new clause, and every framework that reads an argument — Rails, Django,
Symfony, WordPress — is served by one emission rather than by a per-language
`arg0`. **This is the shape worth deciding on, and it is bigger than Laravel.**

**Pack `omega-blade`; kind `relation.depends`; `directive` published as a
`field` rather than an `attribute`.** This is the wave-1 finding again. The
Pack states `@extends`, `@include`, `@includeIf` and `@each` in one template and
tells them apart with an attribute; an attribute is write-only, and
`attribute_equals` compares against one constant, so covering four directives
costs four rules and none of them can put the directive on the edge. As a field
it is one rule with `field_in`, and the relation carries which directive it was.
Same bytes, different map. `reference.template_section` publishes `directive`
the same way, for `@yield` / `@hasSection` / `@sectionMissing`.

---

## Still to decide

1. **The Eloquent-statics list is a heuristic, and the only one in the file.**
   `laravel.model.query` fires on `Something::create(...)` where `Something` is
   not in the 43-name facade exclusion list. A helper class of one's own with a
   static `create` is recorded as a model. The alternative is to require the
   class to have been minted as a Model elsewhere, which the overlay cannot
   express — a relation end is a rendered key, not a query. The list of statics
   was chosen to exclude every name a Laravel facade uses (`Cache::get`,
   `DB::table`, `Log::info`, `Str::of` do not fire); `Arr::first` and
   `Arr::where` are excluded by name. Left as it is, with the false-positive
   shape named here rather than hidden.

2. **`LaravelClass` is one entity kind for every class.** Giving models,
   controllers and jobs their own `entity_kind` would read better, but
   `overlay_ir` interns by canonical key and `Entity::named` hashes the
   descriptor with the key, so two rules that mint the same key under two kinds
   produce two ids and the relation resolves to whichever was seen first. One
   key, one kind, and the role carried by the `extends` edge to a `LaravelBase`
   is the shape that survives that. It also means *which classes are migrations*
   is an incoming-edge query on `laravel:base:Migration` rather than an entity
   filter.

3. **`config/*.php` is not read.** A Laravel config file is `return [ ... ];` —
   an array literal of string keys. `omega-php` emits no fact for an array
   entry, so `config('services.stripe.key')` cannot be related to
   `config/services.php`. No rule pretends otherwise; there is no
   `FrameworkConfig` entity in this file any more.

4. **Routes registered outside `routes/*.php` get a `Route` entity but no
   handler edge.** `laravel.route.declaration` is unrestricted by path, so a
   `Route::get` in a service provider or a package is still recorded;
   `laravel.route.handler` carries the `**/routes/*.php` glob, because outside
   that directory a second `reference.class` in a `Something::get(...)` call is
   not reliably a controller. The two rules mint the same `Route` key and the
   handler rule mints it itself, so the narrower rule never addresses a key the
   broader one failed to create.
