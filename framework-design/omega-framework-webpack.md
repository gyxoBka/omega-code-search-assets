# omega-framework-webpack

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

21 overlay rules, 4 detection rules. **0 can match, 21 cannot.**

Selector: `framework:webpack`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `OutputSetting` | 7 |
| `BuildSetting` | 3 |
| `BuildProject` | 2 |
| `Dependency` | 2 |
| `BuildTarget` | 2 |
| `BuildOutput` | 1 |
| `ApiUse` | 1 |
| `BuildMode` | 1 |
| `BuildContext` | 1 |
| `Alias` | 1 |
| `LoaderConfig` | 1 |
| `ModuleRuleSetting` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 11 |
| `uses_plugin` | 1 |
| `contains` | 1 |
| `produces` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.ecmascript_assignment_export_nested_object_string_context` | 8 | **no** |
| `data.ecmascript_assignment_export_object_string_context` | 7 | **no** |
| `data.ecmascript_assignment_export_nested_object_array_object_field_context` | 2 | **no** |
| `data.ecmascript_assignment_export_object_array_new_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.ecmascript_assignment_export_three_level_object_string_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x67, `fact_kind` x21, `path_glob` x19, `field_present` x14, `field_in` x3, `external_path_matches` x2.

Fields read: `owner_identifier`, `owner_property`, `key`, `outer_key`, `value`, `source.start`, `array_key`, `item_key`, `item_value`, `field_key`, `constructor_name`, `middle_key`.

Path globs: `**/webpack.config.{js,cjs}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `webpack.config.direct-plugin-constructor` | kind `data.ecmascript_assignment_export_object_array_new_context`; field `constructor_name`, `field_key`, `owner_identifier`, `owner_property` |
| `webpack.config.entry-string` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.config.output-filename` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.generic-api-call.webpack` | kind `call.target_candidate` |
| `webpack.generic-dependency.webpack` | kind `import.target_candidate` |
| `webpack.config.mode` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property` |
| `webpack.config.devtool` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property` |
| `webpack.config.target` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property` |
| `webpack.config.context` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property` |
| `webpack.output.filename` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property` |
| `webpack.output.path` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property` |
| `webpack.output.publicpath` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property` |
| `webpack.output.chunkfilename` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property` |
| `webpack.config.name` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.config.externalstype` | kind `data.ecmascript_assignment_export_object_string_context`; field `key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.output.assetmodulefilename` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.output.librarytarget` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.output.globalobject` | kind `data.ecmascript_assignment_export_nested_object_string_context`; field `key`, `outer_key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.config.resolve.alias` | kind `data.ecmascript_assignment_export_three_level_object_string_context`; field `key`, `middle_key`, `outer_key`, `owner_identifier`, `owner_property`, `value` |
| `webpack.config.module-rule.loader` | kind `data.ecmascript_assignment_export_nested_object_array_object_field_context`; field `array_key`, `item_key`, `item_value`, `outer_key`, `owner_identifier`, `owner_property` |
| `webpack.config.module-rule.setting` | kind `data.ecmascript_assignment_export_nested_object_array_object_field_context`; field `array_key`, `item_key`, `item_value`, `outer_key`, `owner_identifier`, `owner_property` |

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
