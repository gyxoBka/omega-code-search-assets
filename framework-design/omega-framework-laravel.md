# omega-framework-laravel

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**18 overlay rules, 4 detection rules. All 18 match.**
(Wave 6 left 16 of 16 live, from 32 of which 0 could ever emit an edge.)

Selector: `framework:laravel`. Maturity: `semantic-overlay-full`.
Languages: `php`, `blade` — packs `omega-php`, `omega-blade`.

### Audit

```
wave 6 before   omega-framework-laravel: 32 overlay rules, 4 detection rules -- 19 live, 13 cannot match
wave 6 after    omega-framework-laravel: 16 overlay rules, 4 detection rules -- 16 live, 0 cannot match
wave 7 before   omega-framework-laravel: 16 overlay rules, 4 detection rules -- 16 live, 0 cannot match
wave 7 after    omega-framework-laravel: 18 overlay rules, 4 detection rules -- 18 live, 0 cannot match
```

`python pack-design/key_collisions.py laravel` reports
`0 entity outputs are overwritten by a same-key rule that sorts first`,
before and after.

---

## What was wrong with it

### Wave 7: the premise of the wave does not hold for PHP, and that is the finding

This wave exists because ten Packs now publish the canonical call view —
`call.arg0`, `call.arg0_text`, `call.arg1_text`, `call.last_arg_name`,
`receiver` — on their call templates, so a Framework that had keyed its routes
by byte offset can now key them `http:{method}:{normalized_route}`.

**omega-php is not one of the ten.** Measured, not read:

```
$ grep -l "call.arg0" packs/*/rules.json
packs/omega-c-sharp packs/omega-go packs/omega-javascript packs/omega-kotlin
packs/omega-python packs/omega-ruby packs/omega-rust packs/omega-swift
packs/omega-tsx packs/omega-typescript
```

All 51 `omega-php` templates carry `"fields": {}` and `"attributes": {}`, and
its five call templates (`call.function`, two `call.method`,
`call.static_method`, `call.constructor`) publish a name and a span and nothing
else. Reproduced on a hand-written `routes/web.php` with
`dump_call_emissions.exe packs/omega-php grammars/omega-php web.php`:

```
 86-91    reference.class      name=Route           | Route
 86-144   call.static_method   name=get             | Route::get('/users/{id}', [UserController::class, 'show'])
113-127   reference.class      name=UserController  | UserController
245-264   call.function        name=view            | view('pages.about')
270-319   call.static_method   name=resource        | Route::resource('photos', PhotoController::class)
296-311   reference.class      name=PhotoController | PhotoController
```

The only field on any of those lines is `nearest_scope_shadowing`, which the
host's scope policy injects (`omega-ingest/src/pack/runtime.rs:803`), not the
Pack. `'/users/{id}'`, `'photos'` and `'pages.about'` produce **no fact of any
kind**, so there is nothing to read, nothing to join to, and no
`{normalized_route}` to render. The `http:{method}:{normalized_route}` key the
brief asks for cannot be built for Laravel until `omega-php` states an
argument. **Nothing was ported, because there was nothing to port.** The case
is written up under *A field only the Pack can supply* below and reported in
`pack_fields_needed`.

The route→handler edge was checked by hand against the brief's warning: it is
keyed on `reference.class` `definition.name`, which `omega-php` computes as
`last(split(qualified, "\\"))` — the same short name `definition.class` emits at
the declaration. `UserController` at the registration and `UserController` at
the declaration are the same key. They meet.

### Three real defects found and fixed this wave

**1. Two Blade directives that the Pack states were not stated here.**
`coverage.gaps` claimed `@includeIf` and `@each` could not be covered because
`directive` is an attribute and `attribute_equals` compares against one
constant. That is a reason to write more rules, not to drop the answers.
Measured on a hand-written `page.blade.php`:

```
 87-103  relation.depends  name=partials.maybe  directive=String("@includeif")
113-141  relation.depends  name=partials.row    directive=String("@each")
```

Both are emitted; the attribute is lowercased by the Pack's `op: lower`, so the
literal to compare against is `@includeif`, not `@includeIf`. Two rules added.
Every `@includeIf` and `@each` partial in every Blade template in the repository
was an edge the graph did not have.

The same measurement settles the other half of that gap sentence, which was
wrong in the other direction: `@includeWhen($cond, 'partials.admin')` emitted
**nothing at all**. `queries.scm` captures it as `@view.conditional.directive`
and no template consumes that capture, so the `directive` attribute expression
has no binding and the template is skipped. The gap now names the three
spellings that really are unstated (`@includeWhen`, `@includeUnless`,
`@includeFirst`) instead of two that are.

**2. `LaravelClass` was minted under two different attribute names.**
Six rules minted `laravel:class:{definition.name}` with an attribute
`named_class`; one rule minted `laravel:class:{cls.definition.name}` with
`class` and `file`. Those two templates render to the **same key** whenever the
class is both declared and referenced, and per brief 3g only the first rule's
attributes survive — so whether a given `LaravelClass` carried `class` or
`named_class` depended on which rule id sorted first for that class. Six
renames; every `LaravelClass` now carries `class`.

**3. The three view-dependency edges were indistinguishable.**
`@include` and the two new directives all emit `renders`. The relation now
carries `directive`, so *is this partial pulled in unconditionally* is an
answerable question rather than a guess.

### Wave 6, for the record

The audit said 13 dead of 32; measured, **all 32 matched nothing**, for four
independent reasons: 26 rules were keyed to `call.member`, a fact only `omega-c`
emits; all 28 `external_path_matches` clauses were false for every input because
no PHP fact carries an `external` package; 58 reads of `call.arg0`/`call.arg1`
named a field no Pack published; and 22 of the 32 could not have added an edge
anyway — 20 emitted `relation source: current, target: K` where `current` **is**
`K`, and 2 emitted an entity and no relation. Nine rules described the same
construct, and eleven of sixteen entity kinds were named after the call that
produced them.

---

## What it states now

Every rule is reached by `fact_kind`, a name test, a `path_glob`, or
`fact_join_by_span` with `within` and `same_path: true`. **No rule reads a
Pack-published field on the PHP side**, because `omega-php` publishes none;
everything comes from the kind, the name, the path and the span. On the Blade
side the one Pack value available is the `directive` attribute, read by
`attribute_equals`. Entity identity is one namespace per entity kind, so two
rules naming the same class agree on its key and on its kind.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which classes are models, controllers, jobs, migrations, form requests, providers, commands, mailables, notifications, API resources, seeders, factories, tests, Blade/Livewire components, validation rules | `relation.implements` (PHP spells `extends`, `implements` and `use Trait` all as this) named one of 54 Laravel bases, joined `within` `definition.class` | `LaravelClass laravel:class:{Class}` —**extends**→ `LaravelBase laravel:base:{Base}` |
| which models this model relates to, by which accessor and which relation kind | `reference.class` (`Post::class`) `within` `call.method hasMany`/`belongsTo`/… `within` `definition.method` `within` `definition.class` | `LaravelClass` —**depends_on**→ `LaravelClass`, attributes `relation`, `accessor` |
| which models a controller or job reads and writes | `reference.class` `within` `call.static_method` named one of 32 Eloquent statics (`all`, `find`, `create`, `where`, `paginate`, …) `within` `definition.class`; 43 facade names excluded | `LaravelClass` —**depends_on**→ `LaravelClass`, attribute `via` |
| which route registrations a file declares, and with which verb | `reference.class Route` `within` `call.static_method` named one of 18 routing verbs | `RouteFile laravel:route-file:{path}` —**declares**→ `Route laravel:route:{path}:{offset}`, attribute `method` |
| **which class answers a route** | the *other* `reference.class` in the same `Route::verb(...)` call, under `**/routes/*.php` | `Route` —**handles**→ `LaravelClass` |
| what a class asks the container for | `type_use.name` `within` `definition.method __construct` `within` `definition.class` | `LaravelClass` —**injects**→ `LaravelClass` |
| which jobs a class dispatches | `reference.class` `within` `call.static_method dispatch`/`dispatchSync`/… `within` `definition.class` | `LaravelClass` —**depends_on**→ `LaravelClass`, attribute `via` |
| which events a class fires | `call.constructor` `within` `call.function event`/`broadcast`/`dispatch`/`report`, `within` `definition.class` | `LaravelClass` —**depends_on**→ `LaravelClass`, attribute `via` |
| which classes are middleware (the one Laravel role with no base class) | `definition.class` under `app/Http/Middleware/**` | `LaravelClass` —**extends**→ `LaravelBase laravel:base:Middleware` |
| which layout a template extends | `relation.depends`, `directive = @extends` | `View laravel:view:{path}` —**extends**→ `ViewName laravel:view-name:{dotted}` |
| which partial a template includes, and whether conditionally | `relation.depends`, `directive` = `@include` / `@includeif` / `@each` (three rules) | `View` —**renders**→ `ViewName`, attribute `directive` |
| which Blade components a template renders | `reference.blade_component` (`<x-forms.input>` and `@component('…')`) | `View` —**renders**→ `BladeComponent laravel:blade-component:{name}` |
| **which template fills the section a layout yields** | `definition.template_section` (`@section`) and `reference.template_section` (`@yield`), keyed by section name so the two files meet | `View` —**provides**/**depends_on**→ `ViewSection laravel:view-section:{name}` |
| which template pushes onto the stack a layout renders | `definition.template_stack` (`@push`) and `reference.template_stack` (`@stack`) | `View` —**provides**/**depends_on**→ `ViewStack laravel:view-stack:{name}` |

Eleven canonical-key templates are minted; the set of keys addressed by a
relation end is exactly contained in them, and every relation's two ends are
minted by the rule that emits them, so nothing dangles. No key template is
minted under more than one entity kind, and every rendering of `laravel:class:…`
carries the same attribute name.

### What it still cannot answer, and why

*Which URL does this route serve* — and the same for the view name, the table
name, the queue name, the gate ability and the config key. All six are string
literals in a call argument, and `omega-php` emits no fact for a string literal.
This is the whole of the next section.

### Rules deliberately kept against nothing

None. All 18 match a fact `omega-php` or `omega-blade` emits today, reproduced
with `dump_call_emissions` on hand-written Laravel and Blade source.

---

## A field only the Pack can supply

**Pack `omega-php`; kinds `call.function`, `call.method`, `call.static_method`,
`call.constructor`; the canonical call view — at minimum `call.arg0_text`, and
`call.arg1_text` for the two-literal forms.**

This is the same request wave 6 made, and wave 7 makes it sharper: ten Packs
have since been given exactly this and `omega-php` was not, so Laravel is now
the largest framework in the repository whose routes have no URL while
Express's, Django's, gin's and Rails' do.

```php
Route::get('/users', [UserController::class, 'index']);   // the URL
return view('users.index', $data);                        // the template
Schema::create('users', function (Blueprint $t) { ... }); // the table
config('services.stripe.key');                            // the config key
Gate::define('update-post', ...);                         // the ability
```

With `call.arg0_text` on `call.static_method`, `laravel.route.declaration`
becomes one line different — canonical key `http:{method}:{normalized_route}`,
attribute `route` from `verb.call.arg0_text`, method from
`verb.definition.name` — and the byte-offset key and its `RouteFile` container
go away. Nothing else in the file has to change.

Neither of the first two options in the brief reaches it:

- **Derivation cannot.** `definition.name` of the call is the method name
  (`get`), not its argument; `path`, `path.dir` and `path.stem` describe the
  file; `definition.qname` and `definition.container` describe the ancestor
  chain. Nothing built in names an argument.
- **A join cannot.** `fact_join_by_span` relates two *facts*, and `omega-php`
  emits no fact for a string literal at all — no `literal.string`, no
  `definition.constant` for an inline argument — so there is nothing inside the
  call's span to join to. The span join reaches `UserController::class` only
  because a class name happens to be a `reference.class`; `'/users'` produces
  nothing. Verified by the `dump_call_emissions` run quoted above: the two
  emissions inside the `Route::get` span are both `reference.class`.

**Pack `omega-blade`; kind `relation.depends`; `directive` published as a
`field` rather than an `attribute`.** An attribute is write-only:
`attribute_equals` compares against one constant, so covering four directives
costs four rules (this file now has three of them plus `@extends`) and none can
put the Pack's own value on the edge — each rule has to restate the directive as
a literal it already matched on. As a field it is one rule with `field_in`, and
the relation carries which directive it was, from the Pack. Same bytes,
different map. `reference.template_section` publishes `directive` the same way,
for `@yield` / `@hasSection` / `@sectionMissing`, which this file therefore
cannot tell apart at all.

**Pack `omega-blade`; the `@includeWhen` / `@includeUnless` capture is dead.**
`queries.scm` has a pattern binding `@view.conditional.directive` and
`@view.target`, and no template consumes `@view.conditional.directive`; the
`relation.depends` template reads `@view.directive`, which that pattern never
binds, so the template is skipped and the pattern emits nothing. Measured. This
is a one-line Pack fix, not a Framework one.

---

## Still to decide

1. **The Eloquent-statics list is a heuristic, and the only one in the file.**
   `laravel.model.query` fires on `Something::create(...)` where `Something` is
   not in the 43-name facade exclusion list, so a helper class of one's own with
   a static `create` is recorded as a model. The alternative is to require the
   class to have been minted as a Model elsewhere, which the overlay cannot
   express — a relation end is a rendered key, not a query. The statics were
   chosen to exclude every name a Laravel facade uses (`Cache::get`, `DB::table`,
   `Log::info`, `Str::of` do not fire). Left as it is, with the false-positive
   shape named here rather than hidden.

2. **`LaravelClass` is one entity kind for every class, and the declaring rule
   wins its attributes.** Giving models, controllers and jobs their own
   `entity_kind` would read better, but a canonical key holds exactly one entity
   and the first rule by id wins with its kind *and* its attributes (brief 3g),
   so one key, one kind, and the role carried by the `extends` edge to a
   `LaravelBase` is the shape that survives. A consequence worth naming: a class
   that is declared with a known base gets `class` **and** `file` from
   `laravel.class.role` (which sorts first); a class that is only ever referenced
   gets `class` alone. Both carry `class`, which is the part that matters for a
   consumer; `file` is best-effort. *Which classes are migrations* is an
   incoming-edge query on `laravel:base:Migration`, not an entity filter.

3. **`config/*.php` is not read.** A Laravel config file is `return [ ... ];` —
   an array literal of string keys, and `omega-php` emits no fact for an array
   entry, so `config('services.stripe.key')` cannot be related to
   `config/services.php`. No rule pretends otherwise.

4. **Routes registered outside `routes/*.php` get a `Route` entity but no
   handler edge.** `laravel.route.declaration` is unrestricted by path, so a
   `Route::get` in a service provider is still recorded;
   `laravel.route.handler` carries the `**/routes/*.php` glob, because outside
   that directory a second `reference.class` in a `Something::get(...)` call is
   not reliably a controller. The two rules mint the same `Route` key with the
   same kind and the same attributes, and the narrower rule mints it itself, so
   it never addresses a key the broader one failed to create.

5. **Whether the string-literal answer should be `call.arg0_text` on PHP or a
   cross-language `literal.string` fact is still open, and is bigger than
   Laravel.** A `literal.string` spanned on the literal would be reached by the
   `fact_join_by_span`/`within` this file already uses everywhere, with no new
   field and no new clause, and would serve Rails, Symfony, WordPress and
   Laravel from one emission. `call.arg0_text` is the shape the ten Packs
   actually shipped, so it is the cheaper ask and the one this file is written
   to consume. Either closes the gap; the consistency argument is the only
   reason to prefer the first.
