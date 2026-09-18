# omega-framework-ruby-on-rails

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**23 overlay rules, 4 detection rules. 23 live, 0 cannot match, and 0 entity
outputs overwritten by a same-key rule.** (Wave 3: 33 rules -> 19, 3 live -> 19.
Wave 4: 19 -> 19, 9 discarded entity outputs recovered. This pass: 19 -> 23, and
**a route now has a URL**.)

Selector: `framework:ruby-on-rails`. Maturity: `semantic-overlay-full`.
The only language is Ruby, so the only Pack that feeds it is `omega-ruby`.

### What omega-ruby actually emits

This is the whole of what a rule can match:

| kind | name it carries |
|---|---|
| `definition.class`, `scope.class_body` | the class's own constant, qualified names reduced to the last constant |
| `definition.module`, `scope.module_body` | the module's constant |
| `definition.method`, `definition.singleton_method`, `scope.method_body` | the method name |
| `definition.attribute_method`, `definition.alias_method`, `reference.method` | `attr_*` / `alias` names |
| `call.method` | the *method name only* — the span is the name node, not the call |
| **`call.arguments`** | **the method name, on the same span as `call.method`, carrying twelve argument fields** |
| `reference.constant`, `definition.constant` | a constant mention / assignment |
| `definition.variable`, `reference.variable` | `@ivar`, `@@cvar`, `$global` |
| `relation.implements` | a superclass **or** an `include`/`extend`/`prepend` argument |
| `definition.superclass_candidate` | `Y` of `class X < Y`, spanning the whole class node |
| `import.require` | the required path as written |

`call.arguments` is the change this pass is built on. It is a **separate
emission on the same span as `call.method`** — a Ruby call needs no parentheses,
so an unbound argument capture would have skipped the whole call template and
`save` would have stopped being a call at all. It carries `call.arg0`,
`call.arg1`, `call.arg2`, `call.last_arg` and the `_text` / `_name` view of each.
Because it carries the method name as its own `definition.name`, a rule matches
it **directly**; the `fact_join_by_span relation: "same"` the brief describes is
only needed when a rule must keep matching calls that have no arguments at all.

Measured with `dump_call_emissions` against a hand-written `config/routes.rb`,
model, controller and migration (the exact spellings, per brief §3d):

| written | `call.arg0` | `call.arg0_text` |
|---|---|---|
| `get "/users/:id", to: "users#show"` | `"/users/:id"` | `/users/:id` |
| `get "photos/index", to: "photos#index"` | `"photos/index"` | `photos/index` |
| `get "photos/:id" => "photos#show"` | `"photos/:id" => "photos#show"` | `photos/:id" => "photos#show` |
| `get :preview` (member block) | `:preview` | `:preview` |
| `root to: "home#index"` | `to: "home#index"` | `to: "home#index"` |
| `resources :posts` | `:posts` | `:posts` |
| `belongs_to :author, class_name: "User"` | `:author` | `:author` |
| `before_action :authenticate_user!, only: [:edit]` | `:authenticate_user!` | `:authenticate_user!` |
| `create_table :orders` | `:orders` | `:orders` |
| `enum status: { draft: 0 }` | `status: { draft: 0 }` | `status: { draft: 0 }` |

Three facts follow from that table and shape every rule below.
**`unquote` strips string delimiters only**, so a Ruby symbol keeps its leading
colon and `call.arg0_text` of `belongs_to :author` is `:author`, not `author`.
**A keyword argument arrives as its whole written text**, `to: "users#show"`, so
`root` and `enum` put a pair in argument zero and a route's handler is not
separable. **`call.arg1_text` is a pair too**, so the `to:` of a `get` is not
reachable either.

## What was wrong with it

The wave-4 file audited clean and collided clean — 19 rules, 19 live, 0
overwritten — and it still does. What was wrong is what it *said*, and the file
said so itself: its first `coverage.gaps` sentence was

> omega-ruby publishes a call's name and span but not its arguments, so the path
> a route serves, the table a migration touches and the model an association
> points at are not stated by any Pack and are not invented here

That sentence is now false. Concretely:

- **A route had no URL. 1 rule covered the entire routing table**, keyed
  `rails:route:{path}:{source.start}`, and the only thing it stated about a
  route was the DSL macro's own name. `get "/users/:id"` and `get "/orders"`
  were two `RouteDefinition`s distinguishable only by byte offset, and
  *which route serves `/users/:id`* was unanswerable in a Rails project while
  every other HTTP framework in the repository answered it under
  `http:{method}:{normalized_route}`.
- **6 macro rules restated their input.** `rails.controller.filter`,
  `rails.model.association`, `rails.model.rule`, `rails.migration.schema_change`
  and `rails.route.declaration` each minted an entity whose only content was the
  macro name it matched on plus a byte offset — `belongs_to` at offset 33,
  `validates` at offset 116. The thing a person asks for (*which association*,
  *which field*, *which table*) is the first argument, and it was unreachable.
- **1 relation carried an apology as an attribute.**
  `rails.model.association` emitted `depends_on` with
  `"target_name_not_published_by_pack": true`. Half of that is no longer true:
  the association's own name is published now, only the class it resolves to is
  not, and that is a Rails inflection rather than a missing Pack field.
- **3 route DSL values could never match.** `member`, `collection` and `shallow`
  take a block and no argument list, so they produce no `call.arguments` fact;
  they were in the `field_in` list and named nothing even before. Dropping them
  is not the §3f narrowing the brief warns about — the Pack pattern requires an
  `argument_list` to fire at all, which is a measured fact and not a guess.
- **`before_action :authenticate_user!` pointed at nothing.** A controller
  filter names a method of its own controller, and that method was already
  minted as an `Action`; the edge between them simply could not be written.

Nothing was deleted for being dead. 19 rules became 23: five rules changed the
kind they match from `call.method` to `call.arguments`, `rails.route.declaration`
split into three (a DSL entry that names something, an HTTP verb route, and
`root`), and two rules are new (`rails.controller.filter.callback`,
`rails.migration.table`). Each of the four extra rules exists because a guard
that would have folded it into its neighbour **is a deletion** (brief §3l): the
symbol spelling `get :preview` is not a URL, `enable_extension "plpgsql"` is not
a table, and a `rescue_from ActiveRecord::RecordNotFound` names no method — so
the guarded rule states the strong thing and the unguarded one still states what
it can.

## What it states now

The key spaces are unchanged from wave 4 and still one kind each:
`rails:class:{path}:{name}` holds exactly one `RailsClass` whoever mints it, and
which Rails layer a class belongs to is a `declares` edge from a `RailsLayer`,
not an entity kind (brief §3g remedy 1). Two key spaces are new: the
cross-framework `http:{method}:{normalized_route}` and `rails:table:{name}`.

| what it states | which Pack fact | which entity or relation |
|---|---|---|
| **which URL this route serves, and with which method** | `call.arguments` named `get`/`post`/`put`/`patch`/`delete`/`options`/`head`/`match` in `**/config/routes.rb`, `call.arg0_text` not starting `:` | entity **`Route`** at **`http:{method}:{normalized_route}`**, attributes `method`, `route`, `source_file`; relation `configures` RouteTable -> Route |
| **`root` serves `GET /`** | `call.arguments` named `root` in `**/config/routes.rb` | the same `Route` key with literal `method: get`, `route: /` — the one thing the macro means but does not spell |
| which routing-DSL entry names what | `call.arguments` named one of 14 DSL methods, `call.arg0_text` | entity `RouteDefinition`, attributes `dsl`, `declared`; relation `configures` RouteTable -> RouteDefinition |
| **which table a migration creates, alters or indexes** | `call.arguments` named one of 24 table-shaped schema macros in `**/db/migrate/*.rb`, `call.arg0_text` starting `:` | entity **`DatabaseTable`** at `rails:table:{arg0}`; relation `configures` SchemaChange -> DatabaseTable |
| this migration performs this schema operation, on this target | `call.arguments` named one of 26 schema methods, joined `within` `scope.class_body` | entity `SchemaChange`, attributes `operation`, **`target`**; relation `configures` RailsClass -> SchemaChange |
| **which association a model declares, by name** | `call.arguments` named `belongs_to`/`has_one`/`has_many`/… (7 macros) under `app/models`, joined `within` `scope.class_body` | entity `Association`, attributes `macro`, **`association`**; relation `depends_on` RailsClass -> Association |
| **which attribute or scope a model macro is about** | `call.arguments` named one of 35 ActiveRecord macros under `app/models` | entity `ModelRule`, attributes `macro`, **`target`**; relation `configured_by` RailsClass -> ModelRule |
| **which callback a controller filter names** | `call.arguments` named one of 16 filter macros under `app/controllers` | entity `ControllerFilter`, attributes `macro`, **`target`**; relation `configured_by` RailsClass -> ControllerFilter |
| **which method that filter actually runs** | the same fact, `call.arg0_text` joined with `current_strip_prefix: ":"` to a `definition.method` of that name in the same file | relation **`depends_on`** ControllerFilter -> `Action`, both ends minted |
| this class exists, and it is a Rails class | `definition.class` (or a joined `cls`) — minted by 17 rules | entity `RailsClass` at `rails:class:{path}:{name}` |
| this class is a controller / model / job / mailer / channel, by where it lives | `definition.class` + path glob | entity `RailsLayer`; relation `declares` RailsLayer -> RailsClass |
| this class is a migration, and its version | `definition.class` + `**/db/migrate/*.rb`, `path.stem` | relation `declares` `rails:layer:migration` -> RailsClass, attribute `version` |
| this class is a model / controller / job / mailer *because of what it inherits* | `definition.superclass_candidate` named `ApplicationRecord` / `ApplicationController` / `ApplicationJob` / `ApplicationMailer`, joined `same`-span to its `definition.class` | relation `declares` RailsLayer -> RailsClass, attributes `base_class`, `via: superclass` |
| this method is an action of that controller | `definition.method` joined `within` `scope.class_body` under `app/controllers` | entity `Action`; relation `handles` RailsClass -> Action |
| this module is a concern | `definition.module` + `**/app/**/concerns/**/*.rb` | entity `RailsModule`; relation `declares` `rails:layer:concern` -> RailsModule |
| this class mixes in that concern | `relation.implements` joined `within` `scope.class_body` **and** by field to a `definition.module` of the same name under `app/**` | relation `depends_on` RailsClass -> RailsModule |
| this controller / job / service uses that model | `reference.constant` joined `within` `scope.class_body` **and** by field to a `definition.class` under `app/models` | relation `uses_model` RailsClass -> RailsClass |

**What it now answers that it could not.** *Which route serves `/users/:id`*
and *what does this app expose over HTTP* — a Rails `Route` is now addressed by
the same `http:{method}:{normalized_route}` identity as express, gin, django and
the rest, so `get "photos/index"` and `get "/photos/index"` are one route and
`:id`/`{id}`/`[id]` agree. *Which migrations touch the `orders` table* — every
`create_table`, `add_column` and `add_index` on `:orders` reaches one
`DatabaseTable`, across files. *Which associations does `Post` declare* and
*which field does this validation validate* — by name, not by byte offset.
*Which method does this `before_action` run* — the first cross-entity edge in
this Framework that comes from a call argument rather than a constant.

### Key reachability and collision

`python pack-design/key_collisions.py ruby-on-rails` reports nothing.

| key space | kind | minted by | addressed by |
|---|---|---|---|
| `rails:class:{path}:{name}` | `RailsClass`, only | 17 rules; every rule that points at a class mints it in the same rule | `declares`, `handles`, `configured_by` x2, `depends_on` x2, `configures`, `uses_model` |
| `rails:layer:<literal>` | `RailsLayer`, only | 6 layer rules, 4 superclass rules, `rails.concern` | `declares` |
| `rails:module:{name}` | `RailsModule`, only | `rails.concern`, `rails.class.mixes_in`, same attribute map | `depends_on`, `declares` |
| `http:{method}:{normalized_route}` | `Route`, only | `rails.route.http`, `rails.route.root` | `configures`, in the minting rule |
| `rails:route-table:{path}` | `RouteTable`, only | `rails.route.declaration`, `.http`, `.root`, same attribute map | `configures`, in the minting rule |
| `rails:table:{arg0}` | `DatabaseTable`, only | `rails.migration.table` | `configures`, in the minting rule |
| `rails:action:{path}:{class}#{method}` | `Action`, only | `rails.controller.action`, `rails.controller.filter.callback`, same attribute names | `handles`, `depends_on` |
| `rails:filter`, `rails:association`, `rails:model-rule`, `rails:route`, `rails:schema-change` | one kind each | their own rule | `current`, or an explicit key minted by a rule whose conditions are a strict subset |

Two ends are addressed by a key another rule mints, and both satisfy brief §3b
(the addresser carries the minter's conditions):
`rails.controller.filter.callback` addresses `rails:filter:{path}:{source.start}`
and its match is `rails.controller.filter`'s plus one join;
`rails.migration.table` addresses `rails:schema-change:{path}:{source.start}`
and **also mints it itself**, so the edge cannot dangle in either direction.

`current` is the rule's **first** entity output everywhere it is used, checked
against `emit()` (`overlay.rs:884`): the `Route` is not addressed by `current`
at all but by its explicit key, because `emit` renders an entity's key from that
output's **own** attribute map (`render(&canonical_key.template, binding,
&values)`) while a relation end is rendered from the accumulated scope — so
`{method}` and `{normalized_route}` in the relation resolve to what the `Route`
output computed, and nothing leaks into the `rails:route-table:{path}` key
beside it (brief §3k).

No attribute depends on an optional value: `call.arg0_text` is an `unquote` over
a `default` to the empty string and is present on every `call.arguments`
emission, and everything else is `definition.name`, `path`, `path.stem`,
`source.start`, a literal or a bound fact's name.

## A field only the Pack can supply

The wave-4 ask — `arg0` on `call.method` — **has been answered** by
`call.arguments`, and the 12 fields it carries are what this rewrite spends.
What remains is narrower and one level down.

**Pack `omega-ruby`, kind `call.arguments`, fields `call.arg<n>_key` and
`call.arg<n>_value`** — for an argument that is a `pair` node, its key and its
value separately, the value unquoted.

Rails states a route's handler, an association's class and a mount point as
keyword arguments: `to: "users#show"`, `class_name: "User"`, `through: :memberships`.
`call.arg1_text` gives the whole pair as written, `to: "users#show"`, which can
be published as an attribute but is not an identity and cannot meet the
declaration side of anything.

Neither of the first two options in `FRAMEWORK-BRIEF.md` §2 reaches it:

- **No built-in name carries it.** `definition.name` of a `call.arguments` fact
  is the method name; `call.arg1_name` splits the pair's text on `.` and returns
  the same text.
- **No join reaches it.** `fact_join_by_span` needs a fact on the pair's span,
  and omega-ruby emits nothing for a `pair` — `queries.scm` captures the
  argument list as a whole and reads it with `ordered_children`, so the pair's
  key and value are never separate nodes in any emission.
  `fact_join_by_field` needs a field, which is the thing being asked for.

What it would buy, concretely: `handles` from `http:get:/users/{}` to the
controller action that answers it. Note the honest limit — even with
`call.arg1_value` = `users#show`, turning that into
`rails:action:app/controllers/users_controller.rb:UsersController#show` needs a
split on `#` and a camelize, and the overlay has no string operation. So the
realistic gain is a **`handler` attribute on the Route** reading `users#show`,
which is what a person wants to see, rather than a graph edge. That is worth
saying plainly before anyone spends a Pack field on it.

Reported in `pack_fields_needed`. Not acted on here.

## Still to decide

1. **`RailsLayer` is a hub named after a constant, and that is deliberate.**
   Unchanged from wave 4: a kind collides and an attribute collides, and only a
   relation does not, so the classification is an edge. Remedy 2 of §3g (a key
   space per layer) would force `rails.controller.action`, `rails.model.rule`
   and `rails.model.usage` — which address a class *without knowing its layer* —
   to fan out into one rule per layer. Chosen: remedy 1.
2. **A symbol argument keeps its leading colon.** `unquote` strips string
   delimiters only, so `belongs_to :author` publishes `association: ":author"`
   and `rails:table::orders` is the key for the `orders` table. It is a stable
   identity and an honest attribute, and `current_strip_prefix: ":"` removes it
   wherever a join has to *meet* an unprefixed name (which is why
   `rails.controller.filter.callback` works). A canonical key template has no
   strip, so the colon stays in the key. Changing it would be a Pack change to
   `call.arg0_text` that every other language's rules depend on not happening.
3. **The legacy `get "photos/:id" => "photos#show"` spelling mangles the
   route.** The whole association is argument zero, and `unquote` takes the
   outer quotes off the pair's text, so `call.arg0_text` is
   `photos/:id" => "photos#show` and the Route identity is that whole string.
   No clause can tell it from a bare `get "photos/index"`: `field_prefix` and
   `field_not_prefix` are the only string tests, there is no *contains*, and
   `call.arg1` is absent for both. Requiring a leading `/` would fix it and
   delete `get "photos/index"`, which is the current Rails-guide spelling —
   the §3l deletion the brief warns about. Left stating the strong, common
   spellings exactly and the deprecated one loudly wrong, and recorded in
   `coverage.gaps`.
4. **A controller's private helpers are indistinguishable from its actions.**
   Unchanged: Ruby's `private` is a bare call and the Pack attaches nothing to
   what follows, so `rails.controller.action` reports every instance method with
   `confidence: "candidate"`. `rails.controller.filter.callback` now adds a
   *second* way a method becomes an `Action` — being named by a `before_action`
   — which is, if anything, evidence it is *not* an action. It mints the same
   key so the two agree, and `rails.controller.action` sorts first and keeps its
   attributes.
5. **A nested class fires the enclosing class's `within` rules too.** `within`
   binds *every* enclosing `scope.class_body` and there is no "nearest
   enclosing" clause, so a method of `Admin::Base` nested in `Admin` emits for
   both. The four `*.by_superclass` rules join `same` and are exempt; the six
   macro rules and `rails.controller.action` are not.
6. **`rails.model.usage` emits a self-edge** when a model mentions its own
   constant in its own body. Suppressing it needs an inequality clause the
   overlay does not have.
7. **`rails.class.mixes_in` still matches `relation.implements`**, which
   omega-ruby emits for both `class X < Y` and `include M`. It proves the target
   is a module by joining to a `definition.module` under `app/**`, and its `via`
   attribute records the ambiguity. Narrowing it needs a negation clause the
   overlay does not have.
8. **`ActiveRecord::Base` cannot be told from any other `::Base`.** omega-ruby
   reduces a qualified constant to its last segment, so the four
   `*.by_superclass` rules key on the Rails 5+ generated parents and leave
   pre-5 apps to the path globs.
