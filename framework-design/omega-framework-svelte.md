# omega-framework-svelte

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 4 detection rules. **0 can match, 11 cannot.**

Selector: `framework:svelte`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `EventBinding` | 2 |
| `HandlerReference` | 2 |
| `Component` | 1 |
| `View` | 1 |
| `ComponentReference` | 1 |
| `RuneUse` | 1 |
| `DirectiveUse` | 1 |
| `Snippet` | 1 |
| `RenderReference` | 1 |
| `StoreReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 2 |
| `renders` | 2 |
| `event_calls` | 2 |
| `uses_rune` | 1 |
| `uses_directive` | 1 |
| `renders_expression` | 1 |
| `subscribes` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.svelte_element` | 2 | **no** |
| `data.svelte_event_directive_binding_context` | 2 | **no** |
| `data.svelte_event_attribute_context` | 2 | **no** |
| `definition.function` | 2 | yes |
| `import.ecmascript_named_binding_context` | 1 | **no** |
| `call.ecmascript_direct_context` | 1 | **no** |
| `data.svelte_directive_context` | 1 | **no** |
| `definition.svelte_snippet` | 1 | **no** |
| `reference.svelte_render_expression` | 1 | **no** |
| `reference.svelte_expression` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x11, `field_present` x10, `path_glob` x9, `fact_join_by_field` x3, `(join)` x3, `field_prefix` x2, `field_in` x2, `field_equals` x1.

Fields read: `handler_expression`, `directive`, `name`, `event_name`, `attribute_name`, `module_source`, `call_name`, `expression`.

Path globs: `**/*.svelte`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `svelte.component_view` | kind `data.svelte_element` |
| `svelte.authored-event-binding` | kind `data.svelte_event_directive_binding_context`; field `directive`, `event_name`, `handler_expression` |
| `svelte.authored-modern-event-attribute` | kind `data.svelte_event_attribute_context`; field `attribute_name`, `handler_expression` |
| `svelte.template.imported-component-render` | kind `data.svelte_element`, `import.ecmascript_named_binding_context`; field `module_source`, `name` |
| `svelte.rune.use` | kind `call.ecmascript_direct_context`; field `call_name` |
| `svelte.template.directive-use` | kind `data.svelte_directive_context`; field `directive` |
| `svelte.snippet.owned` | kind `definition.svelte_snippet`; field `name` |
| `svelte.render.expression` | kind `reference.svelte_render_expression`; field `expression` |
| `svelte.event.resolved-handler.svelte_event_directive_binding_context` | kind `data.svelte_event_directive_binding_context`; field `handler_expression` |
| `svelte.event.resolved-handler.svelte_event_attribute_context` | kind `data.svelte_event_attribute_context`; field `handler_expression` |
| `svelte.store.reference` | kind `reference.svelte_expression`; field `name` |

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
