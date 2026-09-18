# omega-framework-android

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**12 overlay rules, 12 detection rules. All 12 live, 0 cannot match.**
(Was 21 rules, 0 live.)

Selector: `framework:android`. Maturity: `semantic-overlay-full`.
Languages: kotlin, java, xml. Packs: omega-kotlin, omega-java, omega-xml.

### Entities it declares

`AndroidManifest`, `ManifestComponent`, `Permission`, `ManifestRequirement`,
`Layout`, `View`, `NavGraph`, `NavDestination`, `AndroidComponent`,
`LifecycleCallback`.

### Relations it declares

`declares`, `contains`, `requests_permission`, `requires_feature`.

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.config_element` | 6 | yes (omega-xml) |
| `definition.config_attribute` | 3 | yes (omega-xml) |
| `relation.implements` | 1 | yes (omega-kotlin, omega-java) |
| `definition.function` | 1 | yes (omega-kotlin) |
| `definition.method` | 1 | yes (omega-java) |
| `definition.class` (join target) | 3 | yes (omega-kotlin, omega-java) |

## What was wrong with it

All 21 rules were dead, and they were dead for one reason with two spellings.

**18 of 21 rules matched `structured.entry`** and required the attribute
`role` to equal `xml_element_attribute`,
`xml_parent_child_attribute_context` or
`xml_ancestor_intermediate_descendant_context`. No Pack emits
`structured.entry` and no Pack emits a `role` attribute. The old XML Pack
published one template per *shape of XML nesting* — element+attribute,
parent+child+attribute, ancestor+intermediate+descendant — and the overlay was
written against that ladder. omega-xml now emits two facts and lets the host do
the nesting: `definition.config_element` (name = the tag, span = the whole
element) and `definition.config_attribute` (name = the attribute name, span =
the attribute). A nested element or an attribute lies inside its ancestor's
span, so `fact_join_by_span` / `within` replaces the entire ladder. The three
`role` spellings collapse to one join.

**The remaining 4 rules matched `data.xml_element_two_attribute_context`**,
reading `attribute1_name` and `attribute2_name` — a Pack template that existed
only to let a rule see two attributes of the same element at once. No Pack emits
it. Those four rules (`android:exported`, `android:enabled`,
`android:permission`, `android:process` on a component) were four spellings of
one question, "what is set on this component"; one of them,
`android:exported`, is answerable today and is kept, and the other three are
not, for the reason in the next paragraph.

**Sixteen distinct field names, none of which any Pack publishes.**
`element_tag`, `attribute_name`, `attribute_value`, `ancestor_tag`,
`ancestor_attribute_name`, `intermediate_tag`, `descendant_tag`,
`descendant_attribute_name`, `parent_tag`, `parent_attribute_name`,
`parent_attribute_value`, `child_tag`, `child_attribute_name`,
`child_attribute_value`, `attribute1_name`, `attribute2_name`. `element_tag`
and `attribute_name` are `definition.name` now. The four `*_value` fields are
the blocking one: omega-xml publishes an attribute's value as an **attribute**
named `value`, and `OverlayFact::field` never consults `attributes`
(`overlay.rs:56`). An attribute value can therefore be compared to one literal
constant by `attribute_equals` and used for nothing else. See "A field only the
Pack can supply".

**Per-manifest-tag rules that only restated their input.** Ten rules —
`android.manifest.application`, `.activity`, `.activity-alias`, `.service`,
`.receiver`, `.provider`, `.uses-permission`, `.permission`, `.uses-feature`,
and the four component-setting rules — differed from each other only in the tag
they matched and the entity kind they named after that tag (`Activity`,
`Service`, `Receiver`, `Provider`, `Feature`, …). Seventeen entity kinds for
what is one entity with a `component_tag`. They are three rules now
(`component`, `permission`, `requirement`), each carrying a `field_in` over
the tags and an attribute that says which tag it was.

**Two rules that pointed at nothing.** `android.navigation.action_destination`
emitted `navigates_to` between two `android:route:{path}:{value}` keys, both
rendered from `attribute_value`; `android.navigation.deep-link` did the same
for `accepts_deep_link`. Both ends are unreachable now, and the destination
half of a Navigation graph edge stays unreachable until the Pack change lands —
these are deleted rather than faked.

**Nothing in the file looked at Kotlin or Java at all**, although the manifest
declares the `host.languages` `kotlin` and `java` and the whole point of the
framework is to connect a declaration to the class that implements it. Four of
the twelve rules are source-side now, and they are the only ones that can name
a thing.

`detection_rules` was left alone: all 12 match `binding`/`reference`/`contract`
rows for the Gradle plugin ids `com.android.application` and
`com.android.library`, which is a different program with a different vocabulary
and is still true.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| where is this project's Android manifest | `definition.config_element` name `manifest`, path `**/AndroidManifest.xml` (omega-xml) | `AndroidManifest android:manifest:{path}` |
| which components does the manifest declare, and of what kind | `definition.config_element` name in `application`, `activity`, `activity-alias`, `service`, `receiver`, `provider` | `ManifestComponent` keyed by file and span, `component_tag`; `AndroidManifest -declares-> ManifestComponent` |
| which components are reachable from other applications | `definition.config_attribute` name `android:exported`, `attribute_equals value=true`, joined `within` its component element | same `ManifestComponent` key with `exported=true`; `declares` edge marked `exported` |
| which activity launches the app | `definition.config_attribute` name `android:name`, `attribute_equals value=android.intent.action.MAIN`, joined `within` the enclosing `activity` / `activity-alias` | same `ManifestComponent` key with `launcher=true` |
| which component answers an inbound VIEW intent (a deep link or a share target) | same, `value=android.intent.action.VIEW` | same `ManifestComponent` key with `accepts_view_intent=true` |
| what permissions does this app request, and which does it define | `definition.config_element` name in `uses-permission`, `uses-permission-sdk-23`, `permission`, `permission-group`, `permission-tree` | `Permission` with `declaration_tag`; `AndroidManifest -requests_permission-> Permission` |
| what does this app require of the device and the platform | `definition.config_element` name in `uses-feature`, `uses-library`, `uses-native-library`, `uses-sdk`, `supports-screens`, `compatible-screens`, `queries` | `ManifestRequirement` with `requirement_tag`; `AndroidManifest -requires_feature-> ManifestRequirement` |
| which views does this layout resource use | `definition.config_element` under `**/res/layout*/*.xml` — the tag **is** the view class | `View` with `view_class`; `Layout android:layout:{path.stem}` (the `R.layout` name) `-contains-> View` |
| what destinations does this navigation graph hold | `definition.config_element` name in `fragment`, `activity`, `dialog`, `navigation` under `**/res/navigation*/*.xml` | `NavDestination` with `destination_kind`; `NavGraph android:nav-graph:{path.stem} -contains-> NavDestination` |
| which classes in this project are Android components, and of what kind | `relation.implements` whose name is one of 38 Android base types, joined `within` `definition.class` (omega-kotlin, omega-java) | `AndroidComponent android:component:{class}` with `base_type` |
| which lifecycle callbacks does a class override (Kotlin) | `definition.function` named one of 34 Android callbacks, joined `within` `definition.class` | `LifecycleCallback` with `callback`; `AndroidComponent -declares-> LifecycleCallback` |
| same, for Java | `definition.method`, same list, same join | same |

Two notes on the shape of that table.

**`android:layout:{path.stem}` is the resource name.** `res/layout/activity_main.xml`
and `res/layout-land/activity_main.xml` are the same resource `activity_main`,
and `path.stem` gives exactly that, so the two orientations' views land under
one `Layout`. That key is what a future `setContentView(R.layout.activity_main)`
rule will address once a Pack publishes the argument.

**Every relation end is minted.** The eight canonical-key templates the file
mints are the eight it addresses; `android:component:{cls.definition.name}` is
emitted by the lifecycle rules as well as by the component-class rule, so the
`declares` edge never sources at a key nothing created (the
omega-framework-unity defect). No rule uses `current`; both ends of every
relation are explicit `by_canonical_key`, so the wave-2 "`current` is the
first output" trap does not apply.

## A field only the Pack can supply

**Pack:** `omega-xml`. **Kind:** `definition.config_attribute`.
**Field:** `value` — today published in `attributes`, needed in `fields`.

An XML attribute's value is where Android puts every identity it has:

| construct | the value that is the answer |
|---|---|
| `<activity android:name=".MainActivity"/>` | which class implements this component |
| `<uses-permission android:name="android.permission.CAMERA"/>` | which permission |
| `<uses-feature android:name="android.hardware.camera"/>` | which feature |
| `<fragment android:id="@+id/homeFragment" android:name="…HomeFragment"/>` | which destination, and which class it shows |
| `<action app:destination="@id/detailFragment"/>` | where this navigation edge goes |
| `<data android:scheme="https" android:host="example.com"/>` | which deep-link URI this activity accepts |
| `<TextView android:id="@+id/title"/>` | which view a `findViewById` refers to |

Neither of the first two options in the brief reaches it.

1. **Derivation.** None of the built-in names carries it. `definition.name` on
   a `definition.config_attribute` is the attribute's *name*
   (`android:name`), not its value; `path`, `path.dir`, `path.stem`,
   `source.start`, `source.end` describe the file and the span; `external.*`
   is empty for XML.
2. **A join.** `fact_join_by_span` relates an attribute to the element that
   contains it, which the overlay already does here and which is how
   `android:exported` finds its component. But every join returns another
   `OverlayFact`, and the value is not a field on any of them either — the
   value is in the `attributes` map of the very fact we already have. There is
   no clause and no template that reads it: `OverlayFact::field`
   (`overlay.rs:56`) resolves `fields` then a fixed list of built-ins and never
   consults `attributes`, and `field_ref`, `{placeholder}` rendering and every
   join key all go through `field`. The one clause that reads an attribute is
   `attribute_equals`, against a single literal constant — which is why three
   rules in this file can test `android:exported="true"`,
   `android:name="android.intent.action.MAIN"` and
   `android:name="android.intent.action.VIEW"` and no rule can name a class.

This is the same row already recorded in `00-INDEX.md` wave 1 for omega-yaml
and omega-json's `definition.config_key` — the value in `attributes` instead of
`fields`. omega-xml's `definition.config_attribute` belongs on that list, and
it is the same edit: the same bytes in a different map. With it, five rules in
this file gain real identities and three deleted rules (the navigation
action edge, the deep-link `<data>` rule, the layout id → view rule) come back.

## Still to decide

- **The manifest component's key is `{path}:{source.start}`.** That is unique
  and locatable but not addressable from source: no Kotlin or Java rule can
  emit an edge to it, because the class name is in the attribute value. Once
  omega-xml publishes `value`, the right key is
  `android:component:{class}` — the same key the source-side rules already
  mint — and `<activity android:name=".MainActivity"/>` becomes an edge to
  `MainActivity`. That is the single change that turns this overlay from two
  disconnected halves into one graph, and it should be made in the same pass as
  the Pack edit rather than guessed at now.
- **`android:enabled`, `android:permission`, `android:process`** on a
  component are dropped rather than ported. `android:enabled` is testable
  (`attribute_equals value=false`) and would answer "which declared components
  are switched off", but it is rare enough that a rule per literal is not
  worth the file. `android:permission` and `android:process` carry values, so
  they are blocked on the same Pack field.
- **`View` is in the base-type list** of `android.source.component-class`, so a
  custom view extending `View`/`ViewGroup` is an `AndroidComponent` with
  `base_type=View`. That is correct for Android but makes `AndroidComponent`
  a broad kind; if a consumer wants "only the four manifest component types",
  it filters on `base_type`, which is why the attribute is there.
- **The lifecycle rules mint `AndroidComponent`** for any class declaring one
  of the 34 callbacks, even if its supertype is not in the base list (a
  subclass of a project's own `BaseActivity`, for instance). That is the
  omega-framework-unity remedy — mint what you point at — and in a project the
  detector has already identified as Android it is a true statement, but it is
  a deliberately loose one.
- **`setContentView` / `inflate` / `startActivity` arguments** would connect
  a component class to its layout and to the components it launches. The
  language Packs publish no call argument, so these are not attempted; that is
  a Pack question larger than this framework and is not asked for here.
