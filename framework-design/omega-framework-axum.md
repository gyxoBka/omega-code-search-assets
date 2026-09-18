# omega-framework-axum

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 4 detection rules. **0 can match, 12 cannot.**

Selector: `framework:axum`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Handler` | 3 |
| `Service` | 2 |
| `Route` | 2 |
| `Mount` | 2 |
| `Middleware` | 2 |
| `Fallback` | 2 |
| `Controller` | 1 |
| `RouterDependency` | 1 |
| `StateBinding` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `mounts` | 4 |
| `configured_by` | 4 |
| `handles` | 3 |
| `depends_on` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.rust_fq_router_binding_context` | 11 | **no** |
| `call.rust_receiver_identifier_context` | 6 | **no** |
| `call.rust_receiver_string_identifier_context` | 2 | **no** |
| `call.rust_fq_router_route_context` | 1 | **no** |
| `definition.category_candidate` | 1 | **no** |
| `call.rust_fq_router_nest_context` | 1 | **no** |
| `call.rust_receiver_route_nested_call_context` | 1 | **no** |
| `import.path_origin_candidate` | 1 | **no** |

Clause vocabulary in use: `field_equals` x42, `fact_kind` x12, `fact_join_by_field` x12, `(join)` x12, `field_present` x7, `path_glob` x3, `field_in` x2, `attribute_equals` x1, `external_path_matches` x1.

Fields read: `module_root`, `router_type`, `method`, `constructor_name`, `binding`, `route_method`, `method_root`, `method_module`, `method_wrapper`, `path_literal`, `handler_identifier`, `nest_method`, `child_binding`, `prefix_literal`.

Path globs: `**/*.rs`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `axum.router.binding` | kind `definition.rust_fq_router_binding_context`; field `binding`, `constructor_name`, `module_root`, `router_type` |
| `axum.route.registration` | kind `call.rust_fq_router_route_context`, `definition.category_candidate`; field `binding`, `constructor_name`, `handler_identifier`, `method_module`, `method_root`, `method_wrapper`, `module_root`, `path_literal`, `route_method`, `router_type`; attribute `symbol_category` |
| `axum.router.nest` | kind `call.rust_fq_router_nest_context`, `definition.rust_fq_router_binding_context`; field `binding`, `child_binding`, `constructor_name`, `module_root`, `nest_method`, `prefix_literal`, `router_type` |
| `axum.route.receiver-variable` | kind `call.rust_receiver_route_nested_call_context`, `definition.rust_fq_router_binding_context`, `import.path_origin_candidate`; field `method`, `module_root`, `router_type` |
| `axum.router.nest-service` | kind `call.rust_receiver_string_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.route-service` | kind `call.rust_receiver_string_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.merge` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.layer` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.with_state` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.route-layer` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.fallback-handler` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |
| `axum.router.fallback-service` | kind `call.rust_receiver_identifier_context`, `definition.rust_fq_router_binding_context`; field `method`, `module_root`, `router_type` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
