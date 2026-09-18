# omega-framework-asp-net-core

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

19 overlay rules, 4 detection rules. **0 can match, 19 cannot.**

Selector: `framework:asp-net-core`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Middleware` | 9 |
| `Route` | 2 |
| `Handler` | 2 |
| `ServiceRegistration` | 2 |
| `Controller` | 1 |
| `RoutePrefix` | 1 |
| `Dependency` | 1 |
| `Service` | 1 |
| `ConfigKey` | 1 |
| `AuthorizationRule` | 1 |
| `RouteGroup` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 11 |
| `handles` | 2 |
| `depends_on` | 1 |
| `injects` | 1 |
| `registers` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 9 | **no** |
| `definition.csharp_class_base_context` | 2 | **no** |
| `definition.csharp_attributed_method_route_context` | 1 | **no** |
| `call.csharp_minimal_api_route_context` | 1 | **no** |
| `reference.csharp_attributed_class_string_context` | 1 | **no** |
| `reference.csharp_constructor_parameter_context` | 1 | **no** |
| `call.csharp_service_registration_generic_context` | 1 | **no** |
| `call.csharp_global_nested_member_string_context` | 1 | **no** |
| `definition.csharp_attributed_method_context` | 1 | **no** |
| `call.csharp_service_registration_typeof_context` | 1 | **no** |
| `call.csharp_global_member_string_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x19, `field_present` x18, `field_in` x10, `external_path_matches` x9, `path_glob` x3, `field_equals` x3, `fact_join_by_field` x1, `(join)` x1.

Fields read: `source.start`, `member`, `attribute_name`, `receiver_member`, `base_name`, `service_type`, `arg1`, `route`, `path_literal`, `handler_identifier`, `argument_string`, `method_name`.

Path globs: `**/*.cs`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `aspnet.controller-base` | kind `definition.csharp_class_base_context`; field `base_name` |
| `aspnet.attribute-route` | kind `definition.csharp_attributed_method_route_context`; field `attribute_name`, `route` |
| `aspnet.minimal-api-route` | kind `call.csharp_minimal_api_route_context`; field `handler_identifier`, `member`, `path_literal` |
| `aspnet.controller.route-prefix` | kind `reference.csharp_attributed_class_string_context`; field `argument_string`, `attribute_name` |
| `aspnet.controller.constructor-di` | kind `definition.csharp_class_base_context`, `reference.csharp_constructor_parameter_context`; field `base_name` |
| `aspnet.services.registration` | kind `call.csharp_service_registration_generic_context`; field `member`, `receiver_member`, `service_type` |
| `aspnet.configuration.get-section` | kind `call.csharp_global_nested_member_string_context`; field `arg1`, `member`, `receiver_member` |
| `aspnet.authorization.attribute` | kind `definition.csharp_attributed_method_context`; field `attribute_name`, `method_name` |
| `aspnet.services.registration.typeof` | kind `call.csharp_service_registration_typeof_context`; field `member`, `receiver_member`, `service_type` |
| `aspnet.minimal-api-map-group` | kind `call.csharp_global_member_string_context`; field `arg1`, `member` |
| `aspnet.middleware.useauthentication` | kind `call.target_candidate` |
| `aspnet.middleware.useauthorization` | kind `call.target_candidate` |
| `aspnet.middleware.userouting` | kind `call.target_candidate` |
| `aspnet.middleware.useendpoints` | kind `call.target_candidate` |
| `aspnet.middleware.usecors` | kind `call.target_candidate` |
| `aspnet.middleware.usehttpsredirection` | kind `call.target_candidate` |
| `aspnet.middleware.usestaticfiles` | kind `call.target_candidate` |
| `aspnet.middleware.useexceptionhandler` | kind `call.target_candidate` |
| `aspnet.middleware.usehsts` | kind `call.target_candidate` |

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
