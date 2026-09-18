# omega-framework-swiftui

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

29 overlay rules, 8 detection rules. **0 can match, 29 cannot.**

Selector: `framework:swiftui`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `StateBinding` | 11 |
| `ViewModifier` | 7 |
| `Navigation` | 3 |
| `ViewUse` | 2 |
| `Presentation` | 2 |
| `View` | 1 |
| `Component` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 23 |
| `renders` | 3 |
| `contains` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.swift_property_attribute_context` | 11 | **no** |
| `call.target_candidate` | 8 | **no** |
| `call.swift_named_string_argument_context` | 7 | **no** |
| `reference.swift_nominal_conformance_context` | 3 | **no** |
| `call.swift_computed_property_direct_call_context` | 1 | **no** |
| `import.module_path_candidate` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x29, `field_equals` x22, `external_path_matches` x12, `field_present` x5, `fact_join_by_field` x2, `(join)` x2.

Fields read: `attribute_name`, `call_name`, `inherited_type`, `owner_type`, `source.start`, `property_name`, `callee_name`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `swiftui.view.conformance` | kind `reference.swift_nominal_conformance_context`; field `inherited_type`, `owner_type` |
| `swiftui.body.direct-view-call` | kind `call.swift_computed_property_direct_call_context`, `reference.swift_nominal_conformance_context`; field `callee_name`, `inherited_type`, `owner_type`, `property_name` |
| `swiftui.generic-api-call.swiftui` | kind `call.target_candidate` |
| `swiftui.generic-dependency.swiftui` | kind `import.module_path_candidate` |
| `swiftui.property.state` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.stateobject` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.observedobject` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.environment` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.environmentobject` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.binding` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.appstorage` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.scenestorage` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.focusstate` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.fetchrequest` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.property.query` | kind `reference.swift_property_attribute_context`; field `attribute_name` |
| `swiftui.api.navigationlink` | kind `call.target_candidate` |
| `swiftui.api.navigationstack` | kind `call.target_candidate` |
| `swiftui.api.navigationsplitview` | kind `call.target_candidate` |
| `swiftui.api.list` | kind `call.target_candidate` |
| `swiftui.api.foreach` | kind `call.target_candidate` |
| `swiftui.api.sheet` | kind `call.target_candidate` |
| `swiftui.api.alert` | kind `call.target_candidate` |
| `swiftui.modifier.navigationtitle` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.navigationdestination` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.sheet` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.alert` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.task` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.onappear` | kind `call.swift_named_string_argument_context`; field `call_name` |
| `swiftui.modifier.ondisappear` | kind `call.swift_named_string_argument_context`; field `call_name` |

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
