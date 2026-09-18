# omega-framework-axum

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 4 detection rules. **12 can match, 0 cannot.**

Selector: `framework:axum`. Maturity: `semantic-overlay-full`.
Language: Rust only; the whole overlay is written against `omega-rust` plus the
`omega-toml` facts of the crate's own `Cargo.toml`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Handler` | 2 |
| `Middleware` | 2 |
| `Service` | 2 |
| `AxumApp` | 1 |
| `Router` | 1 |
| `Route` | 1 |
| `Mount` | 1 |
| `StateBinding` | 1 |
| `Fallback` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `depends_on` | 5 |
| `configured_by` | 3 |
| `mounts` | 2 |
| `handles` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 6 | yes (omega-rust and 20-odd others) |
| `definition.config_key` | 12 (11 as the Cargo gate) | yes (omega-toml) |
| `definition.config_table` | 12 (nested in the gate) | yes (omega-toml) |
| `scope.function_body` | 7 | yes (omega-rust) |
| `call.function` | 2 | yes |
| `definition.function` | 1 | yes |
| `reference.type` | 1 | yes |
| `reference.path` | 1 | yes |
| `import.use` | 1 | yes |
| `call.path` | 1 | yes |

## What was wrong with it

**All 12 rules were dead, and every one of them for the same reason.** The file
was keyed to the pre-rewrite generator vocabulary — eight fact kinds, and no
Pack emits any of them:

| kind the old file matched | rules | emitted by |
|---|---|---|
| `definition.rust_fq_router_binding_context` | 11 | nobody |
| `call.rust_receiver_identifier_context` | 6 | nobody |
| `call.rust_receiver_string_identifier_context` | 2 | nobody |
| `call.rust_fq_router_route_context` | 1 | nobody |
| `definition.category_candidate` | 1 | nobody |
| `call.rust_fq_router_nest_context` | 1 | nobody |
| `call.rust_receiver_route_nested_call_context` | 1 | nobody |
| `import.path_origin_candidate` | 1 | nobody |

On top of the kinds it read **14 fields that no Pack publishes** — `binding`,
`router_type`, `module_root`, `constructor_name`, `method`, `route_method`,
`method_root`, `method_module`, `method_wrapper`, `path_literal`,
`handler_identifier`, `nest_method`, `child_binding`, `prefix_literal` — and one
attribute, `symbol_category`. **omega-rust publishes no field on any of its 71
templates**, so all 14 were unreachable in principle, not just under the current
spelling. The overlay has exactly kind, name, path and span to work with.

Three structural faults beyond the dead kinds:

1. **Eleven of the twelve rules joined a `router binding`** — a synthetic fact
   asserting *this local variable holds a `Router` built by `Router::new`*.
   Nothing in the Pack vocabulary states variable identity or value flow, and
   the contract forbids the Framework from inventing it. Every rule that asked
   "which binding is this method called on" had to be re-keyed to something the
   Packs do state: **the enclosing function**, reached by `fact_join_by_span`
   with `within` against `scope.function_body`, which costs no Pack field at all.
2. **One rule per receiver spelling.** `merge`, `layer`, `with_state`,
   `route_layer`, `fallback-handler` and `fallback-service` were six rules
   byte-identical apart from one string in a `field_equals` on `method`. They
   are four rules now, grouped by the question each answers rather than by the
   method name.
3. **Two entity kinds restated their input and are gone.** `Controller` was
   minted from a `definition.category_candidate` carrying an attribute
   `symbol_category` and related to nothing; `RouterDependency` named the
   receiver variable the rule had just read. Neither was reachable from a
   question. `AxumApp` replaces them as the one hub every rule hangs off.

Nothing was lost by deletion that a Pack still states: the two answers the old
file claimed and this one does not — the **path literal** of a route and the
**bare identifier** of a handler — were already unreachable, because the fields
that carried them (`path_literal`, `handler_identifier`) exist in no Pack. They
are declared in `coverage.gaps` instead of pretended at.

## What it states now

Every rule is gated on the crate's `Cargo.toml` actually naming an axum crate in
a dependency table, reached with `fact_join_by_path_ancestor` — the same shape
omega-framework-tokio uses. That gate is what makes generic method names like
`layer`, `merge` and `fallback` particular to axum.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| does this crate use axum, and which axum crates | `definition.config_key` named `axum`/`axum-extra`/… `within` a `definition.config_table` named `dependencies`… in `**/Cargo.toml` (omega-toml) | `AxumApp` `axum:app:{path.dir}` |
| where is the router assembled, and in which function | `call.method` in the 11 `Router` builder methods, `within` `scope.function_body` | `Router` `axum:router:{path}:{fn}` — `depends_on` → `AxumApp` |
| which HTTP methods does this router register | `call.function` named `get`/`post`/… `within` a `call.method` named `route`/`route_service` | `Route` `axum:route:{path}:{start}` — `Router` `mounts` → `Route` |
| which function answers this route | `reference.path` `within` the verb call `within` the `.route(..)` call | `Handler` `axum:handler:{name}` — `Handler` `handles` → `Route` |
| which functions are axum handlers, and what do they extract | `reference.type` in the 21 extractor/response types, `within` `definition.function` | `Handler` `axum:handler:{fn}` — `depends_on` → `AxumApp` |
| what does this router nest or merge | `call.method` named `nest`/`nest_service`/`merge`/`route_service` | `Mount` — `Router` `mounts` → `Mount` |
| where is middleware applied, and to all routes or only matched ones | `call.method` named `layer`/`route_layer` | `Middleware` — `Router` `configured_by` → `Middleware` |
| which tower / tower-http / axum middleware does this crate use | `import.use` in the 23 known layer and `from_fn*` names | `Middleware` `axum:middleware-kind:{name}` — `depends_on` → `AxumApp` |
| is this router stateful, and where is state attached | `call.method` named `with_state` | `StateBinding` — `Router` `configured_by` → `StateBinding` |
| what catches an unmatched request | `call.method` named `fallback`/`fallback_service`/`method_not_allowed_fallback` | `Fallback` — `Router` `configured_by` → `Fallback` |
| where is the Router handed to hyper | `call.method` named `into_make_service`/`into_make_service_with_connect_info` | `Service` — `depends_on` → `AxumApp` |
| where does the process start serving | `call.path` named `serve` (`axum::serve(listener, app)`) | `Service` — `depends_on` → `AxumApp` |

### Canonical keys: minted against addressed

Three keys are addressed by a relation end; all three are minted, under the same
conditions as the rule that addresses them (brief §3b):

| addressed | minted by | conditions match |
|---|---|---|
| `axum:app:{cargo.path.dir}` | `axum.crate.dependency` as `axum:app:{path.dir}` | the gate's `where` is the same clause list, literally |
| `axum:router:{path}:{fn.definition.name}` | `axum.router.assembly` | its builder set is a superset of every method name that addresses it, and both sides carry the same `scope.function_body` join and the same Cargo gate |
| `axum:route:{path}:{verb.source.start}` | `axum.route.registration` as `{source.start}` of the same verb call | `axum.route.handler`'s `verb` join carries the verb-name list, and both rules require the enclosing `.route(..)`, the function scope and the gate |

The other eight minted keys are each this rule's own `current` entity, emitted
first in `outputs` so that `Reference::Current` addresses it and not a container.
No attribute reads anything outside `fields` and the built-in names, so no entity
is dropped as unresolvable.

## A field only the Pack can supply

**omega-rust, `call.method` / `call.function` / `call.path`: the literal text of
a string argument.** Neither a built-in name nor a join can reach it, because
omega-rust emits **no fact of any kind for a literal node** — there is nothing on
the other side of a join to bind. `string_literal` appears in no pattern in
`packs/omega-rust/queries.scm`, and the one bare capture the Pack makes is
`(type_identifier) @reference.type`.

Two of the three questions an HTTP framework exists to answer depend on it:

- **which URL does this route serve** — `.route("/users/:id", get(h))`;
- **under which prefix is this sub-router mounted** — `.nest("/api", api())`.

The whole of axum's routing is string-literal-keyed, so without it the overlay
can state that a router registers a `GET` route and that it nests something, but
never *which path*. A field on the call templates carrying the first literal
argument (say `arg0_literal`, populated only where the argument is a
`string_literal`) would answer both, and would do the same for every other Rust
framework whose API is string-keyed — `sqlx::query!`, `tracing` targets,
`clap` argument names, `#[command(name = "..")]`. It is not an axum-only cost,
which is the case for paying it once in the Pack.

Reported in `pack_fields_needed`. Not acted on here: the Pack is not mine to
edit, and the twelve rules above are written against what omega-rust emits today.

## Still to decide

1. **`axum:handler:{name}` is deliberately path-free.** A route registration in
   `routes.rs` and the handler declaration in `handlers/users.rs` are two facts
   in two files with nothing in common but the name, so a path-qualified key
   would never meet. The cost is that two handlers named `index` in different
   modules become one entity. Rails took the same trade on the Ruby constant
   (wave 3). If the host ever resolves `reference.path` to a declaration, this
   key should become the resolved one.
2. **`routing::get(..)` is not matched.** omega-rust spells a bare `get(..)` as
   `call.function` and a qualified `routing::get(..)` as `call.path`, and
   `fact_kind` takes one value, so covering both doubles `axum.route.registration`
   and `axum.route.handler` to four rules. The bare spelling is what axum's own
   documentation and examples use. If a measurement over real crates shows the
   qualified form is common, the two extra rules are cheap and mechanical.
3. **The applied layer is not named.** `.layer(TraceLayer::new_for_http())` gives
   `call.path` named `new_for_http`; the type `TraceLayer` is the *path* segment
   of a `scoped_identifier` and so is not a `type_identifier`, so no
   `reference.type` is emitted for it. Joining the inner call to the enclosing
   `.layer(..)` by span would work syntactically, but a chained
   `call_expression` spans every earlier link of the builder chain, so `.layer`
   at the end of a chain contains every call in it and the join would report
   the whole router as its argument. `axum.middleware.import` names the layer
   types the crate imports instead, without claiming any of them is applied
   at a particular call site. Closing this needs either a Pack field for the
   receiver path of a scoped call, or the literal-argument field above.
