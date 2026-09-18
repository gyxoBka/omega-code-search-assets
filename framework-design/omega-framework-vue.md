# omega-framework-vue

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

17 overlay rules, 4 detection rules. **1 can match, 16 cannot.**

Selector: `framework:vue`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ContextKey` | 2 |
| `Component` | 1 |
| `Route` | 1 |
| `Composable` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `ComponentReference` | 1 |
| `PropsDeclaration` | 1 |
| `EmitsDeclaration` | 1 |
| `SlotsDeclaration` | 1 |
| `ExposeDeclaration` | 1 |
| `Event` | 1 |
| `TemplateBinding` | 1 |
| `TemplateExpression` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `renders` | 2 |
| `uses_binding` | 2 |
| `route_to_component` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `declares_props` | 1 |
| `declares_emits` | 1 |
| `declares_slots` | 1 |
| `declares_expose` | 1 |
| `emits` | 1 |
| `provides_context` | 1 |
| `injects_context` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.ecmascript_direct_context` | 4 | **no** |
| `data.file` | 3 | **no** |
| `call.direct` | 2 | **no** |
| `data.vue_element` | 2 | yes |
| `call.ecmascript_direct_string_argument_context` | 2 | **no** |
| `definition.function` | 1 | yes |
| `data.ecmascript_call_object_array_object_string_identifier_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `import.ecmascript_named_binding_context` | 1 | **no** |
| `data.ecmascript_direct_array_string_item_context` | 1 | **no** |
| `data.vue_directive_value` | 1 | yes |
| `reference.vue_interpolation` | 1 | yes |

Clause vocabulary in use: `fact_kind` x17, `path_glob` x15, `field_present` x11, `field_equals` x11, `external_path_matches` x4, `(join)` x4, `fact_join_by_field` x3, `field_prefix` x1, `fact_join_by_span` x1, `field_in` x1.

Fields read: `call_name`, `name`, `source.start`, `arg1`, `definition.name`, `definition.qname`, `array_key`, `string_key`, `identifier_key`, `module_source`, `item`, `directive`, `value`.

Path globs: `**/*.vue`, `**/composables/**/*.{js,ts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `vue.sfc.component` | kind `data.file` |
| `vue.router.route` | kind `call.direct` |
| `vue.composable` | field `definition.qname` |
| `vue.template.exact-file-component-render` | kind `data.file`; field `name` |
| `vue.router.inline-literal-route-component` | kind `call.direct`, `data.ecmascript_call_object_array_object_string_identifier_context`, `data.file`; field `array_key`, `call_name`, `identifier_key`, `string_key` |
| `vue.generic-api-call.vue` | kind `call.target_candidate` |
| `vue.generic-dependency.vue` | kind `import.target_candidate` |
| `vue.template.imported-component-render` | kind `import.ecmascript_named_binding_context`; field `module_source`, `name` |
| `vue.macro.defineProps` | kind `call.ecmascript_direct_context`; field `call_name` |
| `vue.macro.defineEmits` | kind `call.ecmascript_direct_context`; field `call_name` |
| `vue.macro.defineSlots` | kind `call.ecmascript_direct_context`; field `call_name` |
| `vue.macro.defineExpose` | kind `call.ecmascript_direct_context`; field `call_name` |
| `vue.defineEmits.literal-event` | kind `data.ecmascript_direct_array_string_item_context`; field `call_name`, `item` |
| `vue.context.provide.literal` | kind `call.ecmascript_direct_string_argument_context`; field `arg1`, `call_name` |
| `vue.context.inject.literal` | kind `call.ecmascript_direct_string_argument_context`; field `arg1`, `call_name` |
| `vue.template.interpolation-expression` | field `name` |

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
