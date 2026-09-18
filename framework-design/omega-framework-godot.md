# omega-framework-godot

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

9 overlay rules, 12 detection rules. **3 can match, 6 cannot.**

Selector: `framework:godot`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Asset` | 3 |
| `GameComponent` | 1 |
| `Scene` | 1 |
| `GameEntity` | 1 |
| `Signal` | 1 |
| `GameType` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 2 |
| `asset_references` | 1 |
| `script_attached_to` | 1 |
| `configured_by` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.godot_section_attribute_context` | 2 | yes |
| `definition.category_candidate` | 1 | **no** |
| `call.gdscript_direct_candidate` | 1 | **no** |
| `value.document` | 1 | **no** |
| `structured.godot_node_script_ext_resource_context` | 1 | yes |
| `structured.godot_ext_resource_id_path_context` | 1 | yes |
| `definition.gdscript_signal` | 1 | **no** |
| `definition.gdscript_class_name` | 1 | **no** |
| `reference.gdscript_resource_load` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x9, `field_present` x6, `path_glob` x6, `field_equals` x4, `attribute_equals` x1, `field_in` x1, `fact_join_by_field` x1, `(join)` x1.

Fields read: `name`, `section_kind`, `attribute_name`, `attribute_value`, `node_name`, `resource_id`, `resource_path`.

Path globs: `**/*.tscn`, `**/*.gd`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `godot.node.class` | kind `definition.category_candidate`; field `name`; attribute `symbol_category` |
| `godot.asset.load.call` | kind `call.gdscript_direct_candidate`; field `name` |
| `godot.scene.document` | kind `value.document` |
| `godot.signal` | kind `definition.gdscript_signal` |
| `godot.class-name` | kind `definition.gdscript_class_name` |
| `godot.resource-load` | kind `reference.gdscript_resource_load` |

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
