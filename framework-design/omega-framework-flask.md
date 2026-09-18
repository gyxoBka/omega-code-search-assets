# omega-framework-flask

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 4 detection rules. 12 live, 0 cannot match.**
(Before this rewrite: 14 overlay rules, 6 dead by the audit and 6 more dead in
practice — see below.)

Selector: `framework:flask`. Maturity: `semantic-overlay-full`.
Language: Python only; `host.required_packs` is `omega-python`, which is correct
— Flask declares nothing in a second language that this overlay reads.

## What was wrong with it

**1. Six rules were keyed to kinds no Pack emits.** Four of them to one dead
kind, `definition.python_from_import_constructor_binding_context`
(`flask.app.construct`, `flask.blueprint.construct`, and it appeared twice more
inside `flask.blueprint.mount.proven-bindings`' two joins), plus
`call.python_receiver_identifier_argument_context`, `call.target_candidate` and
`import.target_candidate`. These are exactly the three families `00-INDEX.md`
names: a one-language `*_context` spelling, and two carriers the host never
folded.

**2. Nine fields were read that omega-python does not publish.**
`module_name`, `imported_name`, `callee_name`, `binding_name`, `member`,
`receiver`, `arg0_identifier`, `call.arg0`, `call.kwarg.*`. omega-python's
`rules.json` has **30 templates and `"fields": {}` on every one of them** — the
Pack publishes no fields at all, and two attributes (`module`, `target` on
`binding.import_alias`), which the overlay cannot read anyway (brief 3a). So
every rule that reached for an argument, a receiver or a binding name was
reaching into an empty map.

**3. Twelve clauses were `external_path_matches package flask`, and none of
them can match on Python.** The audit reported the six `reference.decorator`
rules as *live*, because the audit only checks kinds and fields. They are dead
all the same. `OverlayFact::external` is resolved in
`facts_of_surface` (`overlay.rs:1210-1235`) from the artifact's
`ExternalEnvironment`, which `materialize.rs:541` builds from
`SurfaceBinding.target_hint`, which is `occurrence.qualifier`
(`surface.rs:376`), which `content_builder.rs::mention_fields` fills only from a
field or attribute literally named `qualifier`. omega-python names its import
attributes `module` and `target`. **So no Python fact carries an `external` at
all** — the same defect `OWED.md` item 7a records for JS/TS, one language
further. Worse, the member it tested (`route`, `before_request`) is the
decorator's own last identifier; `@app.route` emits `reference.decorator` named
`route`, which is not an imported binding either way.

So the honest count is **12 of 14 rules matched nothing**, not 6. The two that
worked were `flask.app.mount-blueprint` and `flask.config.from-object` only up
to their `external_path_matches` clause — i.e. also nothing.

**4. Three rules were one construct written three times.**
`flask.decorator.before_request`, `.after_request` and `.teardown_request` are
the same rule with one literal changed; they are now one `field_in` list of 13
hook names, which also picks up the blueprint-scoped spellings
(`before_app_request`, `teardown_appcontext`, `url_value_preprocessor`) the old
file never had.

**5. Two rules only restated their input.** `flask.generic-api-call.flask`
minted `flask:api-use:{path}:{source.start}` and pointed a `uses_api` relation
from `current` — its own first entity — at itself: a self-edge on a
position-named entity, which is the `entity_candidate` with no answer that the
brief describes. `flask.generic-dependency.flask` did the same for imports; its
question ("which files use Flask") is kept, but as a relation from the module to
one `flask:dependency:flask` hub instead of a self-edge.

**6. Every relation end dangled.** `flask.app.mount-blueprint` and
`flask.add-url-rule` targeted `by_field call.arg0` / `call.kwarg.view_func` —
fields nothing publishes. `flask.blueprint.mount.proven-bindings` sourced and
targeted `flask:blueprint:{path}:{binding_name}`, a key only
`flask.blueprint.construct` minted, and that rule was itself dead. In the new
file **every relation end is minted by the same rule that addresses it**, so the
brief-3a/3b check is satisfied by construction: the key set minted is
`flask:app:{path}`, `flask:module:{path}`, `flask:app-factory:{path}:{fn}`,
`flask:blueprint:{path}:{off}`, `flask:blueprint-registration:{path}:{off}`,
`flask:route:{path}:{off}`, `flask:lifecycle-hook:{path}:{off}`,
`flask:error-handler:{path}:{off}`, `flask:command:{path}:{off}`,
`flask:config-source:{path}:{off}`, `flask:dependency:flask`, and the key set
addressed by relations is the same eleven.

`python pack-design/key_collisions.py flask` reports nothing: the two shared key
spaces, `flask:app:{path}` (four rules) and `flask:module:{path}` (nine rules),
are minted with **one** entity kind each — `Application` and `FlaskModule` — and
the same attributes, which is the hub shape brief 3g asks for. `flask:route:
{path}:{source.start}` is minted by two rules, both as `Route`.

`detection_rules` is untouched: its four atoms read `row_kind` /
`specifier` / `identity`, which is the detector's own vocabulary, and they say
nothing untrue.

## What it states now

Every rule matches `path_glob **/*.py` and reads `definition.name`, which for
omega-python is the emission's own name — the only thing the Pack states. This
is the same idiom omega-framework-django was rewritten to in wave 2.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| where the Flask application object is built | `call.function` named `Flask` | `Application` `flask:app:{path}`, `FlaskModule` `flask:module:{path}`, `FlaskModule declares Application` |
| which function is the app factory (`create_app`) | `call.function` `Flask` + `fact_join_by_span within definition.function` bound `fn` | `AppFactory` `flask:app-factory:{path}:{fn.definition.name}`, `AppFactory declares Application` |
| which modules declare a blueprint, and where | `call.function` named `Blueprint` | `Blueprint` `flask:blueprint:{path}:{source.start}`, `FlaskModule declares Blueprint` |
| where blueprints are wired into the app | `call.method` named `register_blueprint` | `BlueprintRegistration`, `Application mounts BlueprintRegistration` |
| which modules declare routes, how many, and by which HTTP method | `reference.decorator` named `route`/`get`/`post`/`put`/`patch`/`delete` | `Route` `flask:route:{path}:{source.start}` (attr `method`), `FlaskModule declares Route` |
| routes registered imperatively rather than by decorator | `call.method` named `add_url_rule` | same `Route` key space, attr `form = add_url_rule` |
| which request-lifecycle hooks a module installs | `reference.decorator` in 13 hook names (`before_request` … `url_defaults`) | `LifecycleHook` (attr `hook`), `FlaskModule declares LifecycleHook` |
| which modules handle errors | `reference.decorator` named `errorhandler`/`app_errorhandler` | `Handler`, `FlaskModule declares Handler` |
| which CLI commands the app adds | `reference.decorator` named `command` | `Command`, `FlaskModule declares Command` |
| how and where the app is configured | `call.method` in `from_object`, `from_pyfile`, `from_envvar`, `from_json`, `from_file`, `from_mapping`, `from_prefixed_env` | `ConfigSource` (attr `form`), `Application configured_by ConfigSource` |
| which files are part of the Flask app | `import.from_module` named `flask`; `import.module` named `flask` | `Dependency` `flask:dependency:flask`, `FlaskModule depends_on Dependency` |

Read together, an agent can ask: *which files make up this Flask app*, *which
module owns the application object*, *which function builds it*, *where are the
blueprints and where are they mounted*, *which modules serve routes and with
which methods*, *what runs before and after a request*, *where does
configuration come from*, *what CLI commands exist*. None of that is derivable
from omega-python alone, which states only "there is a call named `Flask` here".

## A field only the Pack can supply

Two, both in **omega-python**, and both blocking the one answer a Flask overlay
most wants to give: *which function serves `GET /orders`*.

**1. `reference.decorator` must state what it decorates.** The Pack should
publish a field — `target`, the name of the declaration the decorator is
attached to — on the `reference.decorator` template
(`packs/omega-python/rules.json`, `span_capture` `decorator.name`).

A join cannot reach it. `queries.scm` captures `@function` on the
`function_definition` node and `@decorator.name` on the decorator's last
identifier; in tree-sitter-python those are **siblings** under
`decorated_definition`, so the function's span does not contain the decorator's.
`fact_join_by_span` offers only `same` and `within`, and `within` means *the
candidate contains the current fact* (`overlay.rs:739-744`) — there is no
"contains" direction that would let a decorator reach the sibling declaration
below it. The built-ins do not help either: `definition.qname` and
`definition.container` are computed from definitions whose span **strictly
contains** the fact (`overlay.rs:1200-1249`), so for a module-level
`@app.route` they are empty and `definition.qname` is just `route`.
The equivalent alternative, if a field is unwanted, is to move the decorator
template's `span_capture` to the enclosing `decorated_definition`, which would
make `fact_join_by_span within definition.function` reach the handler; but that
widens a mention's span, which the Pack contract says is "the bytes that name
the thing", so the field is the smaller change.

Consequence today: `Route` is keyed by its declaration site and `handles` is not
emitted at all. It was in the old `emits` list, sourced from a route key derived
from `{decorator.arg0}` — a field that has never existed.

**2. No call or decorator argument is stated anywhere.** `@app.route("/users/
<id>")`, `app.config.from_object("config.Prod")` and `app.cli.command("seed")`
all turn into a bare name. A `literal_value` field on `call.function`,
`call.method` and `reference.decorator` — the slot `content_builder.rs::
mention_fields` already reads (`"literal_value" => &mut fields.literal_value`)
and that omega-python never fills — would give the route its URL, the config
source its module path and the command its name. Nothing derivable and no join
reaches an argument: omega-python emits no fact for a string literal at all.

This is not one framework's problem — every Python web framework wants it — so
it belongs in `00-INDEX.md` / `OWED.md` rather than here.

## Still to decide

- **`get`/`post`/`put`/`patch`/`delete` as route decorators.** These are Flask
  2.0 shorthands (`@app.get("/x")`), and they are the only way to know a route's
  method without the argument. Matched by bare name they will also catch an
  unrelated `@get` from another library in a repository that happens to contain
  Flask. Kept, because the detector has already established that this is a Flask
  project and the false-positive cost is one extra `Route` row; drop them if a
  measurement shows otherwise.
- **`@…command` for the CLI.** Flask's CLI *is* Click, so `@app.cli.command`
  and a plain `@click.command` are indistinguishable by name alone. Both are
  reported as `Command`, which is arguably right — they are the same registry —
  but it is a judgement, not a measurement.
- **One `Application` per module.** `flask:app:{path}` assumes a module builds
  at most one `Flask(...)`. Two in one file collapse to one entity. The
  alternative key, `{path}:{source.start}`, would be exact but unaddressable
  from `flask.blueprint.register` and `flask.config.source`, which see only the
  file. The collapse is the lesser loss.
