# omega-framework-ruby-on-rails

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**19 overlay rules, 4 detection rules. 19 live, 0 cannot match, and 0 entity
outputs overwritten by a same-key rule.** (Wave 3: 33 rules -> 19, 3 live -> 19.
This pass: 19 rules -> 19, and **9 of 21 entity outputs that were computed and
silently discarded now materialize**.)

Selector: `framework:ruby-on-rails`. Maturity: `semantic-overlay-full`.
The only language is Ruby, so the only Pack that feeds it is `omega-ruby`.

### What omega-ruby actually emits

This is the whole of what a rule can match, and it is small:

| kind | name it carries |
|---|---|
| `definition.class`, `scope.class_body` | the class's own constant, qualified names reduced to the last constant |
| `definition.module`, `scope.module_body` | the module's constant |
| `definition.method`, `definition.singleton_method`, `scope.method_body` | the method name |
| `definition.attribute_method`, `definition.alias_method`, `reference.method` | `attr_*` / `alias` names |
| `call.method` | the *method name only* — the span is the name node, not the call |
| `reference.constant`, `definition.constant` | a constant mention / assignment |
| `definition.variable`, `reference.variable` | `@ivar`, `@@cvar`, `$global` |
| `relation.implements` | a superclass **or** an `include`/`extend`/`prepend` argument |
| `import.require` | the required path as written |

**No omega-ruby template publishes a single `field`.** Every template's `fields`
map is empty. So the overlay has exactly the kind, the name, the path and the
span to work with, plus `fact_join_by_span` over those spans.

One more thing the table above under-sold, and this rewrite uses:
`definition.superclass_candidate` is emitted for `class X < Y` with **the whole
class node as its span** and `Y` as its name, alongside the `relation.implements`
that spans only `Y`. `definition.class` and `scope.class_body` carry that same
whole-class span. So a `fact_join_by_span` with `relation: "same"` reaches the
class from its superclass with no field and no ambiguity, and — unlike
`relation.implements` — it cannot be a mixin.

## What was wrong with it

The wave-3 file audited clean: **19 rules, 19 live, 0 that cannot match**, and
that is still true. What it did not survive is `pack-design/key_collisions.py`,
and the defect it found is the whole of this rewrite.

- **9 of the file's 21 entity outputs never reached the graph.** Entity identity
  is the rendered canonical key alone (`Entity::named` builds its id from
  `EntityBindingSeed::Canonical { key }`; the kind is not part of it), and
  `apply_overlay_runs` interns with `entities.entry(id).or_insert(entity)`, so
  the alphabetically first `rule_id` that renders a key wins **with its kind and
  its attributes**. The file put **seven** entity kinds on one key space:

  | key template | kept | dropped |
  |---|---|---|
  | `rails:class:{path}:{cls.definition.name}` | `RailsClass` (`rails.class.mixes_in`) | `Controller`, `Job`, `Mailer`, `Model` — all four `*.by_superclass` rules |
  | `rails:class:{path}:{definition.name}` | `Channel` (`rails.channel`) | `Controller`, `Job`, `Mailer`, `Migration`, `Model` |

  Nine is `key_collisions.py`'s static count, and it is worth being exact about
  which of the nine bite at runtime, because the path globs are mutually
  exclusive: no file is in both `app/channels` and `app/controllers`, so
  `rails.channel` and `rails.controller` never actually contend for one key.
  **What contends is `rails.class.mixes_in`.** Its glob is `**/app/**/*.rb` —
  every layer — it mints `RailsClass` with no `layer` and no `base_class`, and
  `rails.class.mixes_in` sorts before `rails.controller`, `rails.job`,
  `rails.mailer` and `rails.model`. So **every controller, model, job and mailer
  that includes a concern** — in a Rails app of any size, most of them — reached
  the graph as a bare `RailsClass`, its layer gone, and the matching
  `*.by_superclass` rule's `Model`/`Controller`/`Job`/`Mailer` and its
  `base_class` attribute were computed and thrown away with it. `rails.migration`
  escaped only because `db/migrate` is not under `app/`, and `rails.model.usage`
  (also `RailsClass`) never won because its id sorts after every layer rule.
  The audit cannot see any of this — both kinds exist, both rules match — which
  is why `key_collisions.py` exists.

- **The classification could not be moved into an attribute either.** The
  previous file already carried `layer` as an entity attribute; attributes are
  interned with the entity, so `layer: "model"` was discarded by exactly the same
  `or_insert`. Only the winner's attribute map survives.

- **`rails:module:{definition.name}` had two attribute maps.**
  `rails.class.mixes_in` minted it with `{name}` and `rails.concern` with
  `{name, role, source_file}`; `rails.cl…` sorts before `rails.co…`, so the
  concern's `role` and `source_file` were dropped. Same defect, below
  `key_collisions.py`'s kind-level resolution.

- **The four `*.by_superclass` rules bound the wrong class in a nested file.**
  They matched `relation.implements` (span: the superclass constant) joined
  `within` `definition.class`, and `within` is *every* enclosing class, not the
  nearest — `module Admin; class Base < ApplicationController` also bound any
  outer class. `definition.superclass_candidate` joined `same` binds exactly one.

- **`relation.implements` does not distinguish a superclass from a mixin**, so
  those four rules were also matching `include ApplicationRecord`-shaped source.
  `definition.superclass_candidate` is emitted only by the `class X < Y` pattern.

Rule count is unchanged at 19: nothing was deleted, because every rule already
matched a fact omega-ruby emits. Nine entity outputs that were computed and
discarded now materialize.

## What it states now

One key space, one kind. `rails:class:{path}:{name}` holds exactly one
`RailsClass` whoever mints it, and **which Rails layer a class belongs to is a
`declares` edge from a `RailsLayer`, not an entity kind** — brief §3g remedy 1,
the pattern unity established. `rails:module:{name}` holds exactly one
`RailsModule` with one attribute map. So a relation from any rule can address a
class or a module without knowing its layer, and no rule's output is discarded.

| what it states | which Pack fact | which entity or relation |
|---|---|---|
| this class exists, and it is a Rails class | `definition.class` (or a joined `cls`) — minted by 11 rules | entity `RailsClass` at `rails:class:{path}:{name}`, attributes `name`, `source_file` |
| this class is a controller / model / job / mailer / channel, by where it lives | `definition.class` + path glob `app/controllers\|models\|jobs\|mailers\|channels/**` | entity `RailsLayer` at `rails:layer:<layer>`; relation **`declares`** RailsLayer -> RailsClass |
| this class is a migration, and its version | `definition.class` + `**/db/migrate/*.rb`, `path.stem` | relation **`declares`** `rails:layer:migration` -> RailsClass, attribute `version` |
| this class is a model / controller / job / mailer *because of what it inherits*, wherever it lives | `definition.superclass_candidate` named `ApplicationRecord` / `ApplicationController` / `ApplicationJob` / `ApplicationMailer`, joined `same`-span to its `definition.class` | relation **`declares`** RailsLayer -> RailsClass, attributes `base_class`, `via: superclass` — so a model in `lib/` or an engine coalesces with one in `app/models` |
| this method is an action of that controller | `definition.method` joined `within` `scope.class_body`, under `app/controllers` | entity `Action` at `rails:action:{path}:{Controller}#{name}`; relation **`handles`** RailsClass -> Action |
| this filter runs around that controller's actions | `call.method` named `before_action`/`around_action`/`rescue_from`/… (16 macros) joined `within` `scope.class_body` | entity `ControllerFilter`; relation **`configured_by`** RailsClass -> filter |
| this model declares an association here | `call.method` named `belongs_to`/`has_one`/`has_many`/… (7 macros) joined `within` `scope.class_body`, under `app/models` | entity `Association`; relation **`depends_on`** RailsClass -> Association |
| this model declares this validation, callback, scope or enum | `call.method` named one of 35 ActiveRecord macros joined `within` `scope.class_body` | entity `ModelRule`; relation **`configured_by`** RailsClass -> ModelRule |
| the routing table is here and declares these route macros | `call.method` named one of 26 routing-DSL methods in `**/config/routes.rb` | entities `RouteDefinition`, `RouteTable`; relation **`configures`** RouteTable -> RouteDefinition |
| this migration performs this schema operation | `call.method` named one of 26 schema methods in `**/db/migrate/*.rb`, joined `within` `scope.class_body` | entity `SchemaChange`; relation **`configures`** RailsClass -> SchemaChange |
| this module is a concern | `definition.module` + `**/app/**/concerns/**/*.rb` | entity `RailsModule` at `rails:module:{name}`; relation **`declares`** `rails:layer:concern` -> RailsModule |
| this class mixes in that concern | `relation.implements` joined `within` `scope.class_body`, **and** `fact_join_by_field` to a `definition.module` of the same name under `app/**` | relation **`depends_on`** RailsClass -> `rails:module:{name}`; both ends minted in the rule |
| this controller / job / service uses that model | `reference.constant` joined `within` `scope.class_body`, **and** `fact_join_by_field` to a `definition.class` of the same name under `app/models` | relation **`uses_model`** RailsClass -> `rails:class:{model path}:{name}` |

The last two are the only cross-file edges the Ruby Pack can support, and both
come from the one Ruby name that resolves across files: the constant. They are
what the overlay adds that `omega-ruby` alone cannot say.

Questions this now answers that it did not: *list every controller in this app*
(sources of `declares` from `rails:layer:controller` — previously every one that
included a concern had lost its `Controller` kind and its `layer` attribute to
`rails.class.mixes_in`), *which base class does this class inherit*, *which
migration version is this*, *is this module a concern*.

### Key reachability and collision

`python pack-design/key_collisions.py ruby-on-rails` reports nothing.

| key space | kind | minted by | addressed by |
|---|---|---|---|
| `rails:class:{path}:{name}` | `RailsClass`, only | 11 rules — 6 layer, 4 `*.by_superclass`, plus every rule that points at a class (`action`, `filter`, `association`, `model.rule`, `schema_change`, `mixes_in`, `model.usage` mint it themselves) | `declares`, `handles`, `configured_by` x2, `depends_on` x2, `configures`, `uses_model` |
| `rails:layer:<literal>` | `RailsLayer`, only | the 6 layer rules, the 4 superclass rules, `rails.concern` | `declares` |
| `rails:module:{name}` | `RailsModule`, only | `rails.concern`, `rails.class.mixes_in` — with the **same** attribute map, `{name, source_file}`, `source_file` taken from `mod.path` in the second so both render the same value | `depends_on`, `declares` |
| `rails:route-table:{path}` | `RouteTable` | `rails.route.declaration` | `configures`, in the same rule |
| `rails:action`, `rails:filter`, `rails:association`, `rails:model-rule`, `rails:route`, `rails:schema-change` | one kind each | their own rule | `current`, in the minting rule |

Every relation end is contained in the set of minted keys. Every rule that
addresses `rails:class:{path}:{cls.definition.name}` now **mints it in the same
rule**, so the minter's conditions are the addresser's conditions by
construction (brief §3b, second case) and the edge cannot dangle even in a file
the layer globs do not cover.

`current` is the rule's **first** entity output everywhere it is used, checked
against `emit()` (overlay.rs:884), and in every rule that emits more than one
entity the entity the relation is about is the **first** output: the
`RailsClass` in the six layer rules, the four superclass rules,
`rails.class.mixes_in` and `rails.model.usage`; the `RailsModule` in
`rails.concern`; the macro entity in `rails.controller.action`,
`rails.controller.filter`, `rails.model.association`, `rails.model.rule` and
`rails.migration.schema_change`, whose hub is the third output and is addressed
by explicit key; the `RouteDefinition` in `rails.route.declaration`.
No attribute depends on an optional value — every one is
`definition.name`, `path`, `path.stem`, `source.start`, a literal or a bound
fact's name or path, all of which the Pack guarantees.

No `rails:` key template is minted by any other Framework, so the global
interning `key_collisions.py` checks across frameworks is clean too.

## A field only the Pack can supply

**Pack `omega-ruby`, kind `call.method`, field `arg0`** — the first argument of
the call, when it is a simple symbol or a string literal.

Rails is a DSL of one-argument macros. `resources :posts`, `belongs_to :author`,
`create_table :orders`, `get "/health"`, `mount Sidekiq::Web`, `validates :email`
— in every case the *name* is what the framework is about, and omega-ruby emits
only the macro (`resources`, `belongs_to`, …) and the span of that macro's
identifier.

Neither of the first two options in `FRAMEWORK-BRIEF.md` §2 reaches it:

- **No built-in name carries it.** `definition.name` of a `call.method` fact is
  the method name; `path`, `path.stem`, `external.*` are about the file and the
  import environment. The argument is a different node.
- **No join reaches it.** `fact_join_by_span` relates a fact to a fact whose
  span *contains* it. omega-ruby emits nothing at all for `:posts`: a
  `simple_symbol` is not captured by any pattern in `queries.scm` except the
  three special-cased macros (`attr_*`, `define_method`) and `require`'s string.
  There is no fact to join to. `fact_join_by_field` needs a field, which is the
  thing being asked for.

The cost of this absence, concretely: **which URL a route serves and which
`controller#action` answers it is unanswerable**, and so is *which table this
migration creates* and *which model this `belongs_to` points at*. Those are the
three questions a person asks about a Rails app first. The overlay currently
says a route macro exists at a byte offset; with `arg0` it would say
`GET /orders -> OrdersController#index`.

The narrow, cheap version of the ask: publish `arg0` only on calls whose first
argument is a `simple_symbol` or a `string`, which is one extra capture and one
extra field on a subset of `call.method` emissions. `kwarg` support (for
`to:`, `class_name:`, `through:`) would answer the association target and the
route handler as well, but `arg0` alone unlocks the route path, the table name
and the association name.

Reported in `pack_fields_needed`. Not acted on here — the Pack is not mine to
edit, and the 19 rules above are written against what omega-ruby emits today.

## Still to decide

1. **`RailsLayer` is a hub named after a constant, and that is deliberate.**
   Brief §1 says a rule whose output is an entity named after its own input adds
   nothing. `rails:layer:controller` is close to that line: it carries one
   attribute equal to its own key. It survives because it is the *only* way the
   host lets a classification reach the graph once the class hub is fixed — a
   kind collides, an attribute collides, and only a relation does not. The
   alternative, remedy 2 of §3g (a key space per layer: `rails:controller:{…}`,
   `rails:model:{…}`), keeps both kinds and both attribute sets but costs the
   property this framework is built on: `rails.controller.action`,
   `rails.model.rule` and `rails.model.usage` address a class **without knowing
   its layer**, and would each have to fan out into one rule per layer. Seven
   rules would become twenty-odd. Chosen: remedy 1.
2. **A controller's private helpers are indistinguishable from its actions.**
   Ruby's `private` is a bare `call.method` that changes the visibility of
   everything after it; the Pack emits it as a call and attaches nothing to the
   methods that follow. `rails.controller.action` therefore reports every
   instance method of a controller class as an `Action`, with
   `confidence: "candidate"`. Deciding otherwise would need either a Pack
   visibility field or a span comparison the overlay cannot express
   (`source.start` is a string, and there is no ordering clause).
3. **A nested class fires the enclosing class's `within` rules too.** `within`
   binds *every* enclosing `scope.class_body`, so a method of `Admin::Base`
   nested inside `Admin` emits an `Action` for both. This is the same behaviour
   every wave-1 and wave-2 framework accepts; there is no "nearest enclosing"
   clause. The four `*.by_superclass` rules no longer have this problem — they
   join `same`, not `within` — but the six `call.method` macro rules and
   `rails.controller.action` still do.
4. **`rails.model.usage` emits a self-edge** when a model mentions its own
   constant inside its own body (`Post.where(...)` in `class Post`). Harmless
   but visible; suppressing it would need an inequality clause the overlay does
   not have.
5. **`rails.class.mixes_in` still matches `relation.implements`, which omega-ruby
   emits for both `class X < Y` and `include M`.** It proves the target is a
   module by joining to a `definition.module` of that name under `app/**`, and
   its relation attribute `via` records the ambiguity honestly. It could now be
   narrowed — a superclass also emits a `definition.superclass_candidate` on the
   class's own span — but the overlay has no negation clause, so "this
   `relation.implements` is *not* a superclass" is not expressible. Left as is.
6. **`ActiveRecord::Base` cannot be told from any other `::Base`.** omega-ruby
   reduces a qualified constant to its last segment, so `ActiveRecord::Base`,
   `ActionController::Base` and `Struct::Base` all arrive as `Base`. The four
   `*.by_superclass` rules therefore key on the unambiguous Rails-generated
   parents (`ApplicationRecord`, `ApplicationController`, `ApplicationJob`,
   `ApplicationMailer`), which is the Rails 5+ convention, and leave pre-5 apps
   to the path globs.
