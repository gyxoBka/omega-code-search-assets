# omega-framework-maui

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 12 detection rules. **0 can match, 12 cannot.**

Selector: `framework:maui`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Component` | 3 |
| `Binding` | 3 |
| `Route` | 2 |
| `View` | 1 |
| `XamlResource` | 1 |
| `ServiceRegistration` | 1 |
| `ResourceDictionaryImport` | 1 |
| `TemplateReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 1 |
| `renders` | 1 |
| `navigates_to` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 9 | **no** |
| `call.csharp_class_member_string_context` | 2 | **no** |
| `call.csharp_class_nested_member_string_context` | 1 | **no** |
| `call.csharp_service_registration_generic_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x16, `field_present` x14, `fact_kind` x12, `path_glob` x11, `attribute_equals` x9, `field_in` x4, `field_prefix` x3, `fact_join_by_field` x1, `(join)` x1.

Fields read: `attribute_name`, `element_tag`, `attribute_value`, `member`, `receiver`, `arg1`, `receiver_member`, `parent_attribute_name`, `child_attribute_name`, `parent_attribute_value`, `child_attribute_value`, `receiver_root`, `owner_class`, `owner_base`, `service_type`.

Path globs: `**/*.xaml`, `**/*.cs`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `maui.xaml.class_named-child` | kind `structured.entry`; field `child_attribute_name`, `child_attribute_value`, `parent_attribute_name`, `parent_attribute_value`; attribute `role` |
| `maui.route.literal_registration` | kind `call.csharp_class_member_string_context`; field `arg1`, `member`, `receiver` |
| `maui.navigation.literal_registered_route` | kind `call.csharp_class_member_string_context`, `call.csharp_class_nested_member_string_context`; field `arg1`, `member`, `owner_base`, `owner_class`, `receiver`, `receiver_member`, `receiver_root` |
| `maui.xaml.component` | kind `structured.entry`; field `attribute_name`; attribute `role` |
| `maui.shell.route` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `maui.xaml.resource-reference` | kind `structured.entry`; field `attribute_name`; attribute `role` |
| `maui.services.registration` | kind `call.csharp_service_registration_generic_context`; field `member`, `receiver_member`, `service_type` |
| `maui.xaml.binding-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.staticresource-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.dynamicresource-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.resource-dictionary-source` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.shell-content-template` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |

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
