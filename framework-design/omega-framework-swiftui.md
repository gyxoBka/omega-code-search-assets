# omega-framework-swiftui

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before the rewrite

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

## What was wrong with it

Rewritten. **29 rules -> 9; 0 live -> 9 live, 0 dead.**

**Every one of the six fact kinds was the generator's private Swift spelling,
and no Pack has ever emitted any of them.** `omega-swift` emits 43 templates
over 22 kinds; not one is a `*_context`. The 29 rules divided as
`reference.swift_property_attribute_context` 11, `call.target_candidate` 8,
`call.swift_named_string_argument_context` 7,
`reference.swift_nominal_conformance_context` 3,
`call.swift_computed_property_direct_call_context` 1,
`import.module_path_candidate` 1.

**Six of the seven fields read were published by nobody** --
`attribute_name`, `call_name`, `inherited_type`, `owner_type`,
`property_name`, `callee_name`. The seventh, `source.start`, is a built-in.
`omega-swift` publishes **no fields and no attributes at all**: every template
has `"fields": {}` and `"attributes": {}`, so the whole overlay had to be
rewritten onto `definition.name`, `path`, the span and the kind.

**Twelve rules required `external_path_matches` with `package: "SwiftUI"`.**
`OverlayFact::external` is `None` unless the Pack's import resolved to an
external package; `omega-swift` emits `import.swift_module` with a bare module
name and resolves nothing. Those twelve could not have matched even with their
kinds restored. The rewrite uses no `external_path_matches` clause.

**Sixteen rules emitted a relation from an entity to itself.**
`emit()` sets `own_key` from the rule's *first* entity output, and in
`swiftui.api.*` (7), `swiftui.modifier.*` (7), `swiftui.generic-api-call` and
`swiftui.generic-dependency` the relation's `source` was `current` while its
`target` was `by_canonical_key` rendering the **same template** the entity had
just been minted under. Each was `X configured_by X`. Nothing in the graph was
connected by any of them.

**Eleven more relations pointed at a key no reachable rule minted.** The
property rules emitted `configured_by` from `swiftui:view:{path}:{owner_type}`,
a key minted only by `swiftui.view.conformance` -- which additionally demanded
the SwiftUI external resolution above. Even granting the kinds, the source end
dangled.

**Twenty-five of the 29 were one literal apart from a sibling.** Eleven
property rules differed only in the wrapper string; seven modifier rules only
in `call_name`; seven API rules only in `member_in`. They are now three rules.

## What it states now

Nine rules. All nine are live.

| what it states | which Pack fact | entity or relation |
|---|---|---|
| this file is a SwiftUI file and imports SwiftUI / SwiftData / WidgetKit / Charts | `import.swift_module`, name in list | `SwiftUIFile` `swiftui:file:{path}`, `Dependency` `swiftui:package:{name}`, `depends_on` |
| this authored type is a SwiftUI view (View, Shape, ViewModifier, a UIKit/AppKit representable, Layout, PreviewProvider, …) | `relation.implements` named after the protocol, joined `within` `definition.swift_type` | `View` `swiftui:type:{path}:{Name}`, `ViewName` `swiftui:view-name:{Name}`, `declares_view` name -> declaration |
| this type is where the app starts, or is one of its scenes (App, Scene, Widget, WidgetBundle, Commands, ToolbarContent) | `relation.implements`, same join | `App` at the same type key, `ViewName`, `declares_view` |
| this class is an observable model a view can watch | `relation.implements` `ObservableObject`, same join | `ObservableModel` `swiftui:type:{path}:{Name}` |
| …written with the Observation macro instead | `reference.type` `Observable` (an attribute spelled with a type is a type mention), same join | `ObservableModel`, `form: Observable` |
| this view holds this piece of state, under this property wrapper | `reference.type` with the wrapper's name, joined `within` `definition.swift_property` and `within` `definition.swift_type` | `StateBinding` `swiftui:state:{path}:{Owner}:{prop}`, `SwiftUIType`, `holds_state` |
| this view renders that view | `call.swift`, callee not lowercase-initial, joined `within` the `body` property and `within` the enclosing type | `SwiftUIType`, `ViewName` `swiftui:view-name:{callee}`, `renders` |
| this view presents a sheet / cover / alert / navigation destination / toolbar | `call.swift`, callee in the presentation list, same two joins | `Presentation` `swiftui:presentation:{modifier}`, `presents` |
| this view runs work on appear, takes an injected environment value, or handles a gesture | `call.swift`, callee in the lifecycle/environment list, same two joins | `ViewModifier` `swiftui:modifier:{modifier}`, `configured_by` |

Every canonical key a relation addresses is minted by the rule that addresses
it: `swiftui:file:{path}`, `swiftui:package:{name}`,
`swiftui:type:{path}:{Name}`, `swiftui:view-name:{Name}`,
`swiftui:state:{path}:{Owner}:{prop}`, `swiftui:presentation:{name}`,
`swiftui:modifier:{name}`. Addressed-minus-minted is empty. No relation uses
`current`; both ends of every relation are explicit templates, so no rule can
repeat the self-loop the old file shipped sixteen times.

The questions it now answers: *which files use SwiftUI*, *which types are
views*, *where does the app start*, *what does this view render* (resolving
across files through the shared `ViewName` node), *what state does this view
hold and under which wrapper*, *which views present a sheet or an alert*,
*which views run a `.task`*, *which types are observable models*.

## A field only the Pack can supply

**Pack `omega-swift`, kind `definition.swift_property`, field `type`.**

*Which model backs this view* is the one SwiftUI question the overlay still
cannot answer. `@StateObject private var model = CartModel()` needs the
property's written type, `CartModel`, to be joined to the `ObservableModel`
that `swiftui.model.observableobject` mints.

- A built-in name cannot reach it: `definition.name` of the property is
  `model`, and the Pack publishes no fields at all.
- `fact_join_by_span` cannot reach it either. The written type *is* emitted, as
  a `reference.type` inside the property's span -- but so is the wrapper
  (`StateObject`), and so is every generic argument. `Within` yields the set of
  mentions in the property with no way to say which one is the annotation; the
  only discriminator, being the child of the `type_annotation` node, is syntax
  the overlay is forbidden to see.
- The Pack already computes the value. `definition.type_candidate` carries
  `property.type` and is folded onto the declaration as the attribute
  `omega.pack.type` -- and an attribute is write-only to the overlay
  (`OverlayFact::field` never consults `attributes`).

So the ask is the wave-1 remedy again: the same bytes in a different map --
publish `property.type` as a **field** on `definition.swift_property`, instead
of (or as well as) as the carrier attribute. The same one edit would give
`definition.swift_parameter` and `definition.swift_property_requirement` their
types.

## Still to decide

1. **The twenty-six `field_not_prefix` clauses in `swiftui.view.renders`.**
   A Swift type is UpperCamelCase and a view modifier is lowerCamelCase, so
   excluding each lowercase initial separates `ItemRow(item)` from
   `.padding()`. It is a naming convention read off `definition.name`, not a
   tree shape, and the clause language has no case test and no disjunction --
   but if `omega-swift` ever emitted constructor calls under a kind of their
   own (`call.constructor`, as eight Packs already do), the rule would be one
   `fact_kind` and the twenty-six clauses would go.
2. **`extension Foo: View`.** The Pack states an extension as
   `relation.depends`, not `definition.swift_type`, so a conformance declared
   in an extension is not attributed to a view. Reaching it means joining the
   `relation.implements` to the extension's `scope.type_body` -- which the
   inheritance clause sits *outside* of. Left unanswered rather than guessed.
3. **`ViewName` is keyed by bare name.** Two `ContentView`s in two modules are
   one node. Resolving by path would need a Pack fact tying a constructor call
   to the module that declares the callee, which Swift's implicit module
   imports do not give.
