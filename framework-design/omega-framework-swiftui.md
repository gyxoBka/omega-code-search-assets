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

Two rewrites are recorded here. The first turned 29 dead rules into 9 live
ones; the second, this one, fixed what the audit cannot see — **seven of the
nine rules' principal entity output was computed and thrown away.**

### This wave: one key, four kinds (9 rules -> 8, 7 dropped entities -> 0)

`python pack-design/key_collisions.py swiftui` reported:

```
   swiftui:type:{path}:{owner.definition.name}
      kept    App                                swiftui.app.declaration
      DROPPED ObservableModel                    swiftui.model.observable-macro
      DROPPED ObservableModel                    swiftui.model.observableobject
      DROPPED SwiftUIType                        swiftui.view.configured-by
      DROPPED View                               swiftui.view.declaration
      DROPPED SwiftUIType                        swiftui.view.presents
      DROPPED SwiftUIType                        swiftui.view.renders
      DROPPED SwiftUIType                        swiftui.view.state
```

**Eight of the nine rules minted the same canonical key under four different
entity kinds** — `App`, `View`, `ObservableModel`, `SwiftUIType`. `Entity::named`
builds its id from the key alone and `apply_overlay_runs` does
`entities.entry(id).or_insert(entity)`, so the alphabetically first rule id
wins with its kind *and* its attributes (brief 3g). `swiftui.app.declaration`
sorts first. The consequence, on the ordinary case of

```swift
struct ContentView: View { @State private var n = 0; var body: some View { ItemRow(n) } }
```

in a file that also declares `struct CartApp: App`: **`ContentView` never
materialized as a `View` at all.** Where a file declared both, the App's entity
took the key; where it did not, whichever of the remaining seven rules sorted
first took it, so the same `ContentView` was an `ObservableModel` in one file
and a bare `SwiftUIType` in the next. `View`, the entity the whole overlay
exists to state, reached the graph only when a file had no App, no
`@Observable` and no `ObservableObject` — and even then its `conforms_to`
attribute was whatever the winning rule published, because attributes collide
with the kind.

The three questions the document advertised — *which types are views*, *where
does the app start*, *which types are observable models* — were all answered by
a kind on a shared key, which is the one place a kind cannot survive.

**The fix is remedy 1 from brief 3g: one neutral kind per key space.**
`swiftui:type:{path}:{Name}` now holds exactly one kind, `SwiftUIType`, with
exactly one attribute set (`name`, `path`), minted identically by all seven
rules that need it as a relation end. The classification moved into an edge:
`conforms_to`, from the type to `swiftui:protocol:{Name}`, one node per
protocol. *Which types are views* is now the incoming edges of
`swiftui:protocol:View`, *where does the app start* is `swiftui:protocol:App`,
*which types are observable models* is `swiftui:protocol:ObservableObject` plus
`swiftui:protocol:Observable`. Nothing is dropped, and the answer is finer than
the kind was: it names the protocol, not the bucket.

That also collapsed `swiftui.view.declaration` and `swiftui.app.declaration`,
which after the move differed only in their `field_in` list, into one
`swiftui.type.conformance` — 9 rules to 8.

### The previous wave, for the record

**All six fact kinds were the generator's private Swift spelling, and no Pack
ever emitted any of them** (11 `reference.swift_property_attribute_context`,
8 `call.target_candidate`, 7 `call.swift_named_string_argument_context`,
3 `reference.swift_nominal_conformance_context`, 1
`call.swift_computed_property_direct_call_context`, 1
`import.module_path_candidate`). **Six of the seven fields read were published
by nobody**; `omega-swift` has `"fields": {}` and `"attributes": {}` on all 43
templates. **Twelve rules required `external_path_matches` package `SwiftUI`**,
which omega-swift never resolves. **Sixteen relations ran from an entity to
itself**, and **eleven more addressed a key only the unmatched conformance rule
minted.** **Twenty-five of the 29 were one literal apart from a sibling.**

## What it states now

Eight rules. All eight are live; no canonical key carries two kinds.

| what it states | which Pack fact | entity or relation |
|---|---|---|
| this file is a SwiftUI file, and which Apple UI module it imports | `import.swift_module`, name in {SwiftUI, SwiftData, WidgetKit, Charts} | `SwiftUIFile` `swiftui:file:{path}`, `Dependency` `swiftui:package:{name}`, `depends_on` |
| this authored type conforms to a SwiftUI protocol — a view (View, Shape, ViewModifier, Layout, a UIKit/AppKit representable, PreviewProvider) or an app entry point (App, Scene, Widget, WidgetBundle, Commands, ToolbarContent) | `relation.implements` named after the protocol, joined `within` `definition.swift_type` | `SwiftUIType` `swiftui:type:{path}:{Name}`, `SwiftUIProtocol` `swiftui:protocol:{Proto}`, `conforms_to`; plus `ViewName` `swiftui:view-name:{Name}` and `declares_view` |
| this class is an observable model a view can watch | `relation.implements` `ObservableObject`, same join | `SwiftUIType`, `SwiftUIProtocol` `swiftui:protocol:ObservableObject`, `conforms_to` (`via: conformance`) |
| …written with the Observation macro instead | `reference.type` `Observable` — an attribute spelled with a type is a `user_type`, so the Pack states it as a type mention — same join | `SwiftUIType`, `SwiftUIProtocol` `swiftui:protocol:Observable`, `conforms_to` (`via: macro`) |
| this type holds this piece of state, under this property wrapper | `reference.type` with the wrapper's name, joined `within` `definition.swift_property` and `within` `definition.swift_type` | `StateBinding` `swiftui:state:{path}:{Owner}:{prop}`, `SwiftUIType`, `holds_state` |
| this view renders that view | `call.swift`, callee not lowercase-initial, joined `within` the `body` property and `within` the enclosing type | `SwiftUIType`, `ViewName` `swiftui:view-name:{callee}`, `renders` |
| this view presents a sheet / cover / alert / navigation destination / toolbar | `call.swift`, callee in the presentation list, same two joins | `SwiftUIType`, `Presentation` `swiftui:presentation:{modifier}`, `presents` |
| this view runs work on appear, takes an injected environment value, or handles a gesture | `call.swift`, callee in the lifecycle/environment list, same two joins | `SwiftUIType`, `ViewModifier` `swiftui:modifier:{modifier}`, `configured_by` |

Keys minted: `swiftui:file:{path}`, `swiftui:package:{name}`,
`swiftui:type:{path}:{Name}`, `swiftui:protocol:{Proto}`,
`swiftui:view-name:{Name}`, `swiftui:state:{path}:{Owner}:{prop}`,
`swiftui:presentation:{name}`, `swiftui:modifier:{name}`. Every key a relation
addresses is minted by the rule that addresses it, so addressed-minus-minted is
empty. No relation uses `current`; both ends of every relation are explicit
templates. Every one of the seven rules that mints `swiftui:type:…` mints it
with kind `SwiftUIType` and attributes `{name, path}` — byte-identical — so
which rule sorts first no longer decides anything. All eight key spaces are
`swiftui:`-prefixed, so no other Framework interns against them.

The questions it answers: *which files use SwiftUI*, *which types are views*
(incoming edges of `swiftui:protocol:View`), *where does the app start*
(`swiftui:protocol:App`), *which types are observable models*, *what does this
view render* (resolving across files through the shared `ViewName` node), *what
state does this view hold and under which wrapper*, *which views present a
sheet or an alert*, *which views run a `.task`*.

## A field only the Pack can supply

**Pack `omega-swift`, kind `definition.swift_property`, field `type`.**

*Which model backs this view* is the one SwiftUI question the overlay still
cannot answer. `@StateObject private var model = CartModel()` needs the
property's written type, `CartModel`, to join the type key the conformance rule
mints.

- A built-in name cannot reach it: `definition.name` of the property is
  `model`, and the Pack publishes no fields at all.
- `fact_join_by_span` cannot reach it either. The written type *is* emitted, as
  a `reference.type` inside the property's span — but so is the wrapper
  (`StateObject`), and so is every generic argument. `within` yields the set of
  mentions in the property with no way to say which one is the annotation; the
  only discriminator, being the child of the `type_annotation` node, is syntax
  the overlay is forbidden to see.
- The Pack already computes the value. `definition.type_candidate` carries
  `property.type` and is folded onto the declaration as the attribute
  `omega.pack.type` — and an attribute is write-only to the overlay
  (`OverlayFact::field` never consults `attributes`).

So the ask is the wave-1 remedy again: the same bytes in a different map —
publish `property.type` as a **field** on `definition.swift_property` instead
of (or as well as) as the carrier attribute. The same one edit would give
`definition.swift_parameter` and `definition.swift_property_requirement` their
types.

## Still to decide

1. **The twenty-six `field_not_prefix` clauses in `swiftui.view.renders`.**
   A Swift type is UpperCamelCase and a view modifier is lowerCamelCase, so
   excluding each lowercase initial separates `ItemRow(item)` from
   `.padding()`. It is a naming convention read off `definition.name`, not a
   tree shape, and the clause language has no case test and no disjunction —
   but if `omega-swift` ever emitted constructor calls under a kind of their
   own (`call.constructor`, as eight Packs already do), the rule would be one
   `fact_kind` and the twenty-six clauses would go.
2. **`extension Foo: View`.** The Pack states an extension as
   `relation.depends`, not `definition.swift_type`, so a conformance declared
   in an extension is not attributed to a view. Reaching it means joining the
   `relation.implements` to the extension's `scope.type_body` — which the
   inheritance clause sits *outside* of. Left unanswered rather than guessed.
3. **`ViewName` is keyed by bare name.** Two `ContentView`s in two modules are
   one node. Resolving by path would need a Pack fact tying a constructor call
   to the module that declares the callee, which Swift's implicit module
   imports do not give.
4. **`@main` is stated and unused.** `(attribute . (simple_identifier))` gives
   `reference.attribute main`, a second and independent statement of where the
   app starts, and it would cover a type that reaches `App` through a type
   alias. Not added: it would be a ninth rule answering a question
   `swiftui:protocol:App` already answers for every ordinary spelling.
