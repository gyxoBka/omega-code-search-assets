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
