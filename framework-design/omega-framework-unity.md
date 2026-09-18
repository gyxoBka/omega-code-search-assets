# omega-framework-unity

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

56 overlay rules, 12 detection rules. **2 can match, 54 cannot.**

Selector: `framework:unity`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `SerializedObject` | 18 |
| `SerializedField` | 13 |
| `LifecycleHook` | 12 |
| `AssetReference` | 2 |
| `GameComponent` | 1 |
| `Asset` | 1 |
| `AssetMenu` | 1 |
| `ComponentRequirement` | 1 |
| `SerializedName` | 1 |
| `ScriptAssetReference` | 1 |
| `GameObjectReference` | 1 |
| `PrefabReference` | 1 |
| `SourceObjectReference` | 1 |
| `SerializedChildren` | 1 |
| `SerializedParent` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 12 |
| `configured_by` | 8 |
| `references` | 7 |
| `contains` | 5 |
| `uses_resource` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 33 | **no** |
| `definition.csharp_lifecycle_method_context` | 12 | **no** |
| `definition.csharp_class_base_context` | 12 | **no** |
| `reference.csharp_attributed_field_context` | 5 | **no** |
| `definition.class` | 2 | yes |
| `reference.csharp_attributed_class_string_context` | 2 | **no** |
| `call.csharp_class_member_string_context` | 2 | **no** |

Clause vocabulary in use: `fact_kind` x56, `field_equals` x56, `attribute_equals` x33, `path_glob` x33, `field_present` x30, `fact_join_by_field` x12, `field_in` x12, `(join)` x12, `external_path_matches` x2.

Fields read: `key`, `parent_key`, `value`, `method_name`, `base_name`, `attribute_name`, `receiver`, `member`.

Path globs: `**/*.{unity,prefab,asset}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `unity.lifecycle.awake` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.onenable` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.start` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.fixedupdate` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.update` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.lateupdate` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.ondisable` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.ondestroy` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.ontriggerenter` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.ontriggerexit` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.oncollisionenter` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.lifecycle.oncollisionexit` | kind `definition.csharp_class_base_context`, `definition.csharp_lifecycle_method_context`; field `base_name`, `method_name` |
| `unity.field.serializefield` | kind `reference.csharp_attributed_field_context`; field `attribute_name` |
| `unity.field.hideininspector` | kind `reference.csharp_attributed_field_context`; field `attribute_name` |
| `unity.field.header` | kind `reference.csharp_attributed_field_context`; field `attribute_name` |
| `unity.field.tooltip` | kind `reference.csharp_attributed_field_context`; field `attribute_name` |
| `unity.field.range` | kind `reference.csharp_attributed_field_context`; field `attribute_name` |
| `unity.class-attr.createassetmenu` | kind `reference.csharp_attributed_class_string_context`; field `attribute_name` |
| `unity.class-attr.requirecomponent` | kind `reference.csharp_attributed_class_string_context`; field `attribute_name` |
| `unity.resources.load` | kind `call.csharp_class_member_string_context`; field `member`, `receiver` |
| `unity.resources.loadasync` | kind `call.csharp_class_member_string_context`; field `member`, `receiver` |
| `unity.serialized-object.gameobject` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.transform` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.recttransform` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.monobehaviour` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.prefabinstance` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.prefab` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.scriptableobject` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.meshrenderer` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.skinnedmeshrenderer` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.camera` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.light` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.rigidbody` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.collider` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.boxcollider` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.spherecollider` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.capsulecollider` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.audiosource` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-object.animator` | kind `structured.entry`; field `key`; attribute `role` |
| `unity.serialized-field.m_name` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_script` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_gameobject` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_prefabinstance` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_correspondingsourceobject` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_children` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-field.m_father` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-custom-field.monobehaviour` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-custom-field.scriptableobject` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-tagstring` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-layer` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-isactive` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-staticeditorflags` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-enabled` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `unity.serialized-config.m-editorclassidentifier` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |

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
