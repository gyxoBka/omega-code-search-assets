# omega-framework-android

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

21 overlay rules, 12 detection rules. **0 can match, 21 cannot.**

Selector: `framework:android`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComponentSetting` | 4 |
| `Permission` | 2 |
| `ManifestComponent` | 2 |
| `DeepLink` | 2 |
| `Component` | 1 |
| `View` | 1 |
| `Route` | 1 |
| `Manifest` | 1 |
| `Application` | 1 |
| `Activity` | 1 |
| `ActivityAlias` | 1 |
| `Service` | 1 |
| `Receiver` | 1 |
| `Provider` | 1 |
| `Feature` | 1 |
| `IntentAction` | 1 |
| `IntentCategory` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 6 |
| `accepts_deep_link` | 2 |
| `contains` | 1 |
| `renders` | 1 |
| `navigates_to` | 1 |
| `requests_permission` | 1 |
| `declares_permission` | 1 |
| `requires_feature` | 1 |
| `handles_intent` | 1 |
| `has_category` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 18 | **no** |
| `data.xml_element_two_attribute_context` | 4 | **no** |

Clause vocabulary in use: `field_equals` x47, `fact_kind` x21, `path_glob` x21, `attribute_equals` x18, `field_in` x13, `field_prefix` x5, `fact_join_by_field` x1, `(join)` x1.

Fields read: `element_tag`, `attribute_name`, `attribute1_name`, `attribute2_name`, `attribute_value`, `ancestor_tag`, `ancestor_attribute_name`, `intermediate_tag`, `descendant_tag`, `descendant_attribute_name`, `parent_tag`, `parent_attribute_name`, `child_tag`, `child_attribute_name`, `parent_attribute_value`, `child_attribute_value`.

Path globs: `**/AndroidManifest.xml`, `**/res/navigation/**/*.xml`, `**/res/layout/**/*.xml`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `android.layout.id_view` | kind `structured.entry`; field `attribute_name`, `attribute_value`; attribute `role` |
| `android.navigation.route_declaration` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `android.navigation.action_destination` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `child_attribute_name`, `child_attribute_value`, `child_tag`, `element_tag`, `parent_attribute_name`, `parent_attribute_value`, `parent_tag`; attribute `role` |
| `android.manifest.package` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.application` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.activity` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.activity-alias` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.service` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.receiver` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.provider` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.uses-permission` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.permission` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.uses-feature` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `android.manifest.component-setting.android-exported` | kind `data.xml_element_two_attribute_context`; field `attribute1_name`, `attribute2_name`, `element_tag` |
| `android.manifest.component-setting.android-enabled` | kind `data.xml_element_two_attribute_context`; field `attribute1_name`, `attribute2_name`, `element_tag` |
| `android.manifest.component-setting.android-permission` | kind `data.xml_element_two_attribute_context`; field `attribute1_name`, `attribute2_name`, `element_tag` |
| `android.manifest.component-setting.android-process` | kind `data.xml_element_two_attribute_context`; field `attribute1_name`, `attribute2_name`, `element_tag` |
| `android.manifest.intent-action` | kind `structured.entry`; field `ancestor_attribute_name`, `ancestor_tag`, `descendant_attribute_name`, `descendant_tag`, `intermediate_tag`; attribute `role` |
| `android.manifest.intent-category` | kind `structured.entry`; field `ancestor_attribute_name`, `ancestor_tag`, `descendant_attribute_name`, `descendant_tag`, `intermediate_tag`; attribute `role` |
| `android.manifest.deep-link-data` | kind `structured.entry`; field `ancestor_attribute_name`, `ancestor_tag`, `descendant_attribute_name`, `descendant_tag`, `intermediate_tag`; attribute `role` |
| `android.navigation.deep-link` | kind `structured.entry`; field `child_attribute_name`, `child_tag`, `parent_attribute_name`, `parent_tag`; attribute `role` |

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
