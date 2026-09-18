# omega-framework-ruby-on-rails

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**19 overlay rules, 4 detection rules. 19 live, 0 cannot match.** (Was 33 rules,
3 live, 30 dead.)

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

## What was wrong with it

- **30 of 33 rules matched a kind no Pack emits.** 28 were keyed to
  `call.ruby_string_arg_context`, one to `call.ruby_string_kwarg_context`, one
  to `reference.ruby_class_association_explicit_target_context`. All three were
  omega-ruby's private pre-rewrite spellings; none survives.
- **Every one of those 28 read a field named `arg0` (and `call_name`,
  `kwarg_key`, `kwarg_value`, `macro`, `option_key`, `option_value`,
  `owner_class`).** omega-ruby publishes none of them, and never did after the
  rewrite. `arg0` is what made the old design work at all: `resources :posts`
  was keyed `rails:resourceroute:posts:…`. Without it, the *argument of every
  Rails macro is invisible*, which is the single fact that shapes the whole
  rewrite (see "A field only the Pack can supply").
- **25 of the 33 rules were a self-loop.** The pattern was: emit
  `entity_candidate` under key `K`, then emit
  `relation_candidate { source: current, target: by_canonical_key K }` — and
  `current` *is* `K`. So `rails.model.validates` stated
  `ModelRule -> configured_by -> the same ModelRule`. Twenty-five relations
  that pointed a node at itself, and no rule anywhere related a model, a
  controller or a migration to anything else.
- **Twelve of those 25 were the same rule twelve times.** `rails.model.validates`,
  `validate`, `before_validation`, `after_validation`, `before_save`,
  `after_save`, `before_create`, `after_create`, `before_update`,
  `after_update`, `before_destroy`, `after_destroy` differed only in one literal
  string. They are now one rule with one `field_in` over 35 macros. The four
  `rails.association.declaration.*` rules collapse the same way, as do the eight
  `rails.route.*` rules and the five `rails.migration.*` rules.
- **The 3 rules the audit called "live" were live on paper only.**
  `rails.controller.class` and `rails.model.class` matched
  `definition.class` + `external_path_matches { package: "ActionController" }`.
  `OverlayFact.external` is filled from the artifact's *import environment*
  (`facts_of_surface`, overlay.rs:1202), and Ruby's only import is a `require`
  path string. `ActionController` and `ApplicationRecord` never resolve there,
  so both clauses were permanently false. `rails.job.class` (path glob on
  `app/jobs`) was the one rule that could actually fire — and it emitted an
  entity and no relation.
- **Two rules read `definition.qname`.** That field *does* exist — the host
  synthesizes it in `facts_of_surface` from the chain of enclosing definitions —
  but it is not a Pack field and not in `OverlayFact::field`'s built-in list, so
  `overlay_audit.py` counts it dead. The new file keys classes on
  `{path}:{definition.name}` instead, which is stable without it.

## What it states now

Every class-shaped entity shares one key space, `rails:class:{path}:{name}`, so
a relation can address a class without knowing which Rails layer it belongs to.

| what it states | which Pack fact | which entity or relation |
|---|---|---|
| this class is a controller / model / job / mailer / channel | `definition.class` + path glob `app/controllers\|models\|jobs\|mailers\|channels/**` | entity `Controller` / `Model` / `Job` / `Mailer` / `Channel` at `rails:class:{path}:{name}` |
| this class is a migration, and its version | `definition.class` + `**/db/migrate/*.rb`, `path.stem` | entity `Migration`, attribute `version` |
| this class is a model / controller / job / mailer *because of what it inherits*, wherever it lives | `relation.implements` named `ApplicationRecord` / `ApplicationController` / `ApplicationJob` / `ApplicationMailer`, joined `within` its `definition.class` | the same four entities, same key — so a model in `lib/` or an engine coalesces with one in `app/models` |
| this method is an action of that controller | `definition.method` joined `within` `scope.class_body`, under `app/controllers` | entity `Action` at `rails:action:{path}:{Controller}#{name}`; relation **`handles`** Controller -> Action |
| this filter runs around that controller's actions | `call.method` named `before_action`/`around_action`/`rescue_from`/… (16 macros) joined `within` `scope.class_body` | entity `ControllerFilter`; relation **`configured_by`** Controller -> filter |
| this model declares an association here | `call.method` named `belongs_to`/`has_one`/`has_many`/… (7 macros) joined `within` `scope.class_body`, under `app/models` | entity `Association`; relation **`depends_on`** Model -> Association |
| this model declares this validation, callback, scope or enum | `call.method` named one of 35 ActiveRecord macros joined `within` `scope.class_body` | entity `ModelRule`; relation **`configured_by`** Model -> ModelRule |
| the routing table is here and declares these route macros | `call.method` named one of 26 routing-DSL methods in `**/config/routes.rb` | entities `RouteDefinition`, `RouteTable`; relation **`configures`** RouteTable -> RouteDefinition |
| this migration performs this schema operation | `call.method` named one of 26 schema methods in `**/db/migrate/*.rb`, joined `within` `scope.class_body` | entity `SchemaChange`; relation **`configures`** Migration -> SchemaChange |
| this module is a concern | `definition.module` + `**/app/**/concerns/**/*.rb` | entity `RailsModule` at `rails:module:{name}`, `role=concern` |
| this class mixes in that concern | `relation.implements` joined `within` `scope.class_body`, **and** `fact_join_by_field` to a `definition.module` of the same name under `app/**` | relation **`depends_on`** class -> `rails:module:{name}`; both ends minted in the rule |
| this controller / job / service uses that model | `reference.constant` joined `within` `scope.class_body`, **and** `fact_join_by_field` to a `definition.class` of the same name under `app/models` | relation **`uses_model`** class -> `rails:class:{model path}:{name}` |

The last two are the only cross-file edges the Ruby Pack can support, and both
come from the one Ruby name that resolves across files: the constant. They are
what the overlay adds that `omega-ruby` alone cannot say.

### Key reachability

Every canonical key a relation addresses is minted:

| key minted by | addressed by |
|---|---|
| `rails:class:{path}:{name}` — 11 rules (5 layer, 4 superclass, `rails.class.mixes_in`, `rails.model.usage`) | `handles`, `configured_by` x2, `depends_on`, `configures`, `uses_model` |
| `rails:module:{name}` — `rails.concern`, `rails.class.mixes_in` | `depends_on` |
| `rails:route-table:{path}` — `rails.route.declaration` | `configures`, in the same rule |
| `rails:action`, `rails:filter`, `rails:association`, `rails:model-rule`, `rails:route`, `rails:schema-change` | `current`, in the minting rule |

`current` is the rule's **first** entity output everywhere it is used, checked
against `emit()` (overlay.rs:884). `rails.route.declaration` and
`rails.class.mixes_in` each emit two entities; in both, the entity the relation
means is first. Conditions match between minter and addresser: every rule that
addresses `rails:class:{path}:{cls.definition.name}` carries the same path glob
as the layer rule that mints it. No attribute depends on an optional value —
every one is `definition.name`, `path`, `path.stem`, `source.start` or a bound
fact's name, all of which the Pack guarantees.

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

1. **A controller's private helpers are indistinguishable from its actions.**
   Ruby's `private` is a bare `call.method` that changes the visibility of
   everything after it; the Pack emits it as a call and attaches nothing to the
   methods that follow. `rails.controller.action` therefore reports every
   instance method of a controller class as an `Action`, with
   `confidence: "candidate"`. Deciding otherwise would need either a Pack
   visibility field or a span comparison the overlay cannot express
   (`source.start` is a string, and there is no ordering clause).
2. **A nested class fires the enclosing class's rules too.** `within` binds
   *every* enclosing `scope.class_body`, so a method of `Admin::Base` nested
   inside `Admin` emits an `Action` for both. This is the same behaviour every
   wave-1 and wave-2 framework accepts; there is no "nearest enclosing" clause.
3. **`rails.model.usage` emits a self-edge** when a model mentions its own
   constant inside its own body (`Post.where(...)` in `class Post`). Harmless
   but visible; suppressing it would need an inequality clause the overlay does
   not have.
4. **`relation.implements` does not say whether it came from `class X < Y` or
   from `include M`.** omega-ruby emits the same kind for both. Hence
   `rails.class.mixes_in` proves the target is a module by joining to a
   `definition.module` of that name, rather than trusting the kind, and its
   relation attribute `via` records the ambiguity honestly.
5. **`ActiveRecord::Base` cannot be told from any other `::Base`.** omega-ruby
   reduces a qualified constant to its last segment, so `ActiveRecord::Base`,
   `ActionController::Base` and `Struct::Base` all arrive as `Base`. The four
   `*.by_superclass` rules therefore key on the unambiguous Rails-generated
   parents (`ApplicationRecord`, `ApplicationController`, `ApplicationJob`,
   `ApplicationMailer`), which is the Rails 5+ convention, and leave pre-5 apps
   to the path globs.
