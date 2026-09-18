# omega-framework-flutter

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **0 can match, 20 cannot.**

Selector: `framework:flutter`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `RouteReference` | 3 |
| `AppShell` | 2 |
| `WidgetUse` | 2 |
| `AsyncWidget` | 2 |
| `Resource` | 2 |
| `FlutterConfig` | 2 |
| `Component` | 1 |
| `Route` | 1 |
| `Page` | 1 |
| `StateProvider` | 1 |
| `StateConsumer` | 1 |
| `FlutterProject` | 1 |
| `FontFamily` | 1 |
| `FontFaceSetting` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 9 |
| `renders` | 5 |
| `routes_to` | 3 |
| `route_to_component` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 8 | **no** |
| `structured.entry` | 6 | **no** |
| `call.dart_receiver_member_route_context` | 3 | **no** |
| `definition.dart_class_extends_context` | 2 | **no** |
| `call.dart_named_string_builder_constructor_context` | 1 | **no** |
| `value.document` | 1 | **no** |

Clause vocabulary in use: `field_equals` x24, `fact_kind` x20, `field_present` x13, `path_glob` x9, `external_path_matches` x8, `attribute_equals` x6, `field_in` x3, `fact_join_by_field` x1, `(join)` x1.

Fields read: `owner_key`, `receiver`, `member`, `route`, `sequence_key`, `item_value`, `superclass_name`, `parent_key`, `key`, `value`, `class_name`, `call_name`, `string_label`, `builder_label`, `string_value`, `constructor_name`, `item_key`, `outer_sequence_key`, `identity_key`, `identity_value`.

Path globs: `**/pubspec.yaml`, `**/*.dart`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `flutter.widget.direct-subclass` | kind `definition.dart_class_extends_context`; field `class_name`, `superclass_name` |
| `flutter.go-route.literal-builder` | kind `call.dart_named_string_builder_constructor_context`, `definition.dart_class_extends_context`; field `builder_label`, `call_name`, `constructor_name`, `string_label`, `string_value`, `superclass_name` |
| `flutter.api.materialapp` | kind `call.target_candidate` |
| `flutter.api.cupertinoapp` | kind `call.target_candidate` |
| `flutter.api.scaffold` | kind `call.target_candidate` |
| `flutter.api.streambuilder` | kind `call.target_candidate` |
| `flutter.api.futurebuilder` | kind `call.target_candidate` |
| `flutter.api.hero` | kind `call.target_candidate` |
| `flutter.api.provider` | kind `call.target_candidate` |
| `flutter.navigator.pushnamed` | kind `call.dart_receiver_member_route_context`; field `member`, `receiver`, `route` |
| `flutter.navigator.pushreplacementnamed` | kind `call.dart_receiver_member_route_context`; field `member`, `receiver`, `route` |
| `flutter.navigator.popandpushnamed` | kind `call.dart_receiver_member_route_context`; field `member`, `receiver`, `route` |
| `flutter.api.provider-consumer` | kind `call.target_candidate` |
| `flutter.pubspec.project` | kind `value.document` |
| `flutter.pubspec.asset` | kind `structured.entry`; field `item_value`, `owner_key`, `sequence_key`; attribute `role` |
| `flutter.pubspec.uses-material-design` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `flutter.pubspec.shader` | kind `structured.entry`; field `item_value`, `owner_key`, `sequence_key`; attribute `role` |
| `flutter.pubspec.font-family` | kind `structured.entry`; field `item_key`, `item_value`, `owner_key`, `sequence_key`; attribute `role` |
| `flutter.pubspec.generate` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `flutter.pubspec.font-face-setting` | kind `structured.entry`; field `field_key`, `field_value`, `identity_key`, `identity_value`, `inner_sequence_key`, `outer_sequence_key`, `owner_key`; attribute `role` |

## What was wrong with it

**All 20 rules were dead, and they were dead in four distinct ways.**

- **8 rules matched `call.target_candidate`** — `flutter.api.materialapp`,
  `cupertinoapp`, `scaffold`, `streambuilder`, `futurebuilder`, `hero`,
  `provider`, `provider-consumer`. That kind was a carrier the host never
  folded, so it named nothing even before the Pack rewrite. All 8 also carried
  an `external_path_matches` clause naming `package:flutter/material.dart`, and
  **no Dart fact carries `external` at all**: `external_environment` registers a
  binding only when `target_hint` is set, `target_hint` is
  `occurrence.qualifier`, and omega-dart publishes **no field and no attribute
  on any of its 36 templates**. So each of those 8 rules had two independent
  reasons to match nothing. Two of them also read `call.name`, which is not a
  field name the overlay resolves.
- **6 rules matched `structured.entry`** and read an `a0`…`a6`-style ancestor
  ladder — `owner_key`, `sequence_key`, `parent_key`, `item_key`, `item_value`,
  `outer_sequence_key`, `inner_sequence_key`, `identity_key`, `identity_value`,
  `field_key`, `field_value`: **11 distinct field names, none published by any
  Pack**, plus an `attribute_equals role` against four role strings omega-yaml
  does not emit. One pubspec shape per nesting depth, which is exactly the
  238-rule pattern `00-INDEX.md` records.
- **5 rules matched a Dart-private `*_context` kind** —
  `definition.dart_class_extends_context` (2),
  `call.dart_receiver_member_route_context` (3) and
  `call.dart_named_string_builder_constructor_context` (1) — reading
  `class_name`, `superclass_name`, `receiver`, `member`, `route`, `call_name`,
  `string_label`, `builder_label`, `string_value`, `constructor_name`. The three
  Navigator rules were one rule written three times, once per method name.
- **1 rule matched `value.document`**, a kind no Pack emits; it existed only to
  mint the `flutter:project:{path}` key that nine `configured_by` relations were
  sourced at. Because it could never fire, **every one of those nine relations
  dangled** even in the counterfactual where the `structured.entry` rules had
  worked.

Two more defects the audit could not see. `flutter.api.provider-consumer`
emitted an entity and **no relation at all** — a `StateConsumer` keyed by its
own file and offset, which is the "output restates its input" case. And ten of
the twenty rules emitted a relation whose **source was `current`** and whose
target was the rule's only entity, so the edge ran from the rule's first entity
output to itself.

Of the 14 entity kinds it declared, 8 were one-per-API spellings of the same
thing (`AppShell`, `WidgetUse`, `AsyncWidget`, `StateProvider`, `StateConsumer`,
`Component`, `Route`, `Page`).

**20 rules -> 10. 0 live -> 10 live.**

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which classes are Flutter widgets, on which base, and where | omega-dart `relation.implements`, named after the supertype, span-joined `within` `definition.class` | `Widget` at `flutter:widget:{path}:{class}`, `WidgetName` at `flutter:widget-name:{class}`, `declares_widget` |
| What a widget builds with, `const`/`new` spelling | omega-dart `call.constructor`, span-joined `within` `definition.class` | `WidgetName` at both ends, `renders` |
| Which widget holds the app shell, a Scaffold, a Navigator, a StreamBuilder | omega-dart `call.function` whose name is one of Flutter's structural widgets, span-joined `within` `definition.class` | `WidgetName` at both ends, `renders` |
| Where the app starts | omega-dart `call.function` named `runApp` | `AppEntrypoint` at `flutter:entrypoint:{path}`, `DartFile`, `declares_entrypoint` |
| Which widgets navigate, by which operation | omega-dart `call.method` named `pushNamed` / `goNamed` / …, span-joined `within` `definition.class` | `RouteReference` at `flutter:route-ref:{path}:{offset}`, `routes_to` from the widget |
| Where state is provided or consumed, under which library | omega-dart `call.function` named `Provider` / `BlocBuilder` / `Consumer` / …, span-joined `within` `definition.class` | `StateBinding`, `configured_by` from the widget |
| Which files use which package | omega-dart `import.library`, whose name is the URI, prefixed `package:` | `DartFile` at `flutter:file:{path}`, `Dependency` at `flutter:package:{uri}`, `depends_on` |
| Which packages in the repo are Flutter packages | omega-yaml `definition.config_key` named `flutter` in `pubspec.yaml` | `FlutterProject` at `flutter:project:{path}` |
| Which assets and shaders a package ships | omega-yaml `relation.data` (the sequence element), span-joined `within` the `assets`/`shaders` key and again `within` the `flutter` key | `Resource` at `flutter:asset:{path}:{value}`, `configured_by` from the project |
| Which build switches are set under `flutter:` | omega-yaml `definition.config_key` in a name list, span-joined `within` the `flutter` key | `FlutterConfig`, `configured_by` from the project |

Ten rules, six relation kinds, ten entity kinds. Three collapses did the
shrinking: 8 `flutter.api.*` rules became 2 (one per call spelling), 3 Navigator
rules became 1 `field_in`, and 6 pubspec ladder rules became 3 span joins.

**Every canonical key a relation addresses is minted by a rule in this file, and
by a rule carrying the same clauses.** `flutter:widget-name:{…}` is minted by
all four rules that address it, including at the target end, so `renders ->
Scaffold` names a node even when no class in the project declares `Scaffold`.
`flutter:project:{path}` is minted by `flutter.pubspec.section` and re-minted by
both rules that source an edge at it, under the same "`flutter:` key in this
pubspec.yaml" condition — which is what the old file got wrong nine times over.

## A field only the Pack can supply

**omega-yaml, `definition.config_key`, the field `value`.** The Pack computes
the scalar value and publishes it as an **attribute**, and `OverlayFact::field`
(overlay.rs:56) resolves the `fields` map and a fixed list of built-in names and
never consults `attributes`; the only clause that reads one is
`attribute_equals` against a single literal. So `uses-material-design: true` is
reachable as a key and not as a truth value, and a font block's `family:
Raleway` cannot be keyed, related or carried — which is why `FontFamily` and
`FontFaceSetting` are deleted rather than ported. No join reaches it: a span
join binds another *fact*, and the value is not a fact, it is a map entry on
this one. This is the same row wave 1 already recorded for omega-yaml and
omega-json; this Framework is the second caller.

**omega-dart, `call.function` / `call.constructor`, the argument list.** Not
asked for as a field, and recorded here only so the gap is not rediscovered: a
Flutter route is `GoRoute(path: '/details', builder: ...)` and a navigation is
`Navigator.pushNamed(context, '/details')`. Neither the literal nor the argument
label is a fact, so the route *string* is unreachable by any join, and
`flutter.go-route.literal-builder` and the route side of the three Navigator
rules are deleted rather than ported. That is a named-fact question for
omega-dart (contract §5: "if a rule needs to know that a call has three
arguments in a particular order, that shape belongs in the Pack as a named
fact"), not a field request, so it is not filed as one.

## Still to decide

- **`flutter.widget.renders` carries a list of 62 Flutter widget names.** A bare
  `MyButton(...)` and a bare `setState(...)` are both `call.function` in Dart —
  the grammar has no call node, a call is an identifier followed by a selector —
  and nothing the Pack states separates them. The enclosing class cannot be
  tested for being a widget either, because a span join relates the call to its
  class but there is no join from a bound fact to a third one, so the class's
  own `relation.implements` is out of reach. The name list is the framework's
  own vocabulary and is defensible, but it means a project's own widgets are
  reached only through the `const`/`new` spelling
  (`flutter.widget.constructs`). If omega-dart ever states a class's supertype
  on the class itself, this rule should become a general one and the list should
  go.
- **`flutter.widget.constructs` carries a 28-name exclusion list** of value
  types a `const` expression commonly builds (`Duration`, `EdgeInsets`,
  `TextStyle`, …). It is a heuristic, and it is the only heuristic in the file.
  The alternative is to accept `renders -> Duration` edges, which is worse.
- **`State` is in the widget-base list**, so `class _HomeState extends
  State<HomePage>` is a `Widget` with `widget_base: State`. The type argument
  naming the widget it belongs to lies inside `type_arguments` and is not
  captured, so the State class cannot be linked to its StatefulWidget. Leaving
  it out would lose every stateful build method; leaving it in states one
  logical widget as two nodes. Kept in, and flagged.
