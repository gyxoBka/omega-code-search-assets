# omega-framework-blazor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 12 detection rules. **0 can match, 11 cannot.**

Selector: `framework:blazor`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Component` | 1 |
| `View` | 1 |
| `Route` | 1 |
| `Dependency` | 1 |
| `RenderMode` | 1 |
| `BaseType` | 1 |
| `Interface` | 1 |
| `TypeParameter` | 1 |
| `Section` | 1 |
| `EventBinding` | 1 |
| `HandlerReference` | 1 |
| `RouteReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 5 |
| `navigates_to` | 2 |
| `renders` | 1 |
| `injects` | 1 |
| `configures` | 1 |
| `references_handler` | 1 |
| `routes_to` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.file` | 2 | **no** |
| `data.razor_page_route` | 1 | **no** |
| `reference.razor_literal_href_context` | 1 | **no** |
| `binding.razor_inject` | 1 | **no** |
| `data.razor_rendermode` | 1 | **no** |
| `type_relation.razor_inherits` | 1 | **no** |
| `type_relation.razor_implements` | 1 | **no** |
| `definition.razor_type_parameter` | 1 | **no** |
| `definition.razor_section` | 1 | **no** |
| `reference.razor_named_attribute_identifier_context` | 1 | **no** |
| `call.csharp_global_member_string_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x11, `path_glob` x11, `field_present` x10, `field_prefix` x2, `field_equals` x2, `field_not_prefix` x1, `fact_join_by_field` x1, `(join)` x1.

Fields read: `href`, `type`, `name`, `route`, `declaration`, `mode`, `attribute_name`, `handler_name`, `receiver`, `member`, `arg1`.

Path globs: `**/*.razor`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `blazor.component_view` | kind `data.file` |
| `blazor.page.route` | kind `data.razor_page_route`; field `route` |
| `blazor.literal_href.navigation` | kind `data.file`, `reference.razor_literal_href_context`; field `href` |
| `blazor.inject` | kind `binding.razor_inject`; field `declaration` |
| `blazor.rendermode` | kind `data.razor_rendermode`; field `mode` |
| `blazor.basetype` | kind `type_relation.razor_inherits`; field `type` |
| `blazor.interface` | kind `type_relation.razor_implements`; field `type` |
| `blazor.typeparameter` | kind `definition.razor_type_parameter`; field `name` |
| `blazor.section` | kind `definition.razor_section`; field `name` |
| `blazor.event-binding` | kind `reference.razor_named_attribute_identifier_context`; field `attribute_name`, `handler_name` |
| `blazor.navigationmanager.navigate-to` | kind `call.csharp_global_member_string_context`; field `arg1`, `member`, `receiver` |

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
