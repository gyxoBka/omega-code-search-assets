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
## What was wrong with it

The file shipped 56 overlay rules. **54 could not match any Pack emission**, and
the 2 that the audit called live were live only on paper.

| what was wrong | rules |
|---|---|
| keyed to a `structured.entry` kind no Pack emits, on `.unity`/`.prefab`/`.asset` paths no grammar claims | 33 |
| keyed to C#-private `*_context` kinds the Pack rewrite removed (`definition.csharp_lifecycle_method_context`, `definition.csharp_class_base_context`, `reference.csharp_attributed_field_context`, `reference.csharp_attributed_class_string_context`, `call.csharp_class_member_string_context`) | 21 |
| matched a live kind but through `external_path_matches` on `definition.class`, which carries no `external` -- a `definition.class` fact never resolves to a package, so the clause could not be true | 2 |

Underneath the dead kinds, three habits:

1. **One rule per literal.** 12 lifecycle rules differing only in a method name,
   18 `SerializedObject` rules differing only in a YAML key, 5 field-attribute
   rules differing only in an attribute name, 7 `serialized-field` rules and 6
   `serialized-config` rules the same way. 48 of the 56 rules were one rule
   written out by hand N times.
2. **Restating the input.** `unity.serialized-object.camera` emitted an entity
   named `Camera` for a line that said `Camera:`, with no relation to anything.
   18 of the 33 YAML rules produced an entity and nothing else.
3. **Reaching the enclosing class by a published field.** Every lifecycle rule
   did `fact_join_by_field` on `owner_class`, a field the Pack had to publish on
   every C# method in every repository. A lifecycle method lies inside its class
   declaration's span, so `fact_join_by_span` with `within` reaches the class
   with no field on either side.

The 33 YAML rules are not portable at all, and not because of the kind. **No
grammar registers `.unity`, `.prefab`, `.asset` or `.meta`**
(`grammars/omega-yaml/manifest.toml` declares `extensions = ["yml"]` and
`language = "yaml"`), so a Unity scene, prefab or ScriptableObject instance is
never parsed and no Pack emits a single fact about one. Porting them to
`definition.config_key` would have made the audit green while every rule stayed
silent on every repository. They are deleted, and the reason is recorded under
"Still to decide".

**56 rules -> 17.** All 17 live.

## What it states now

The overlay is C# only. Every rule gates on `path_glob **/*.cs`, and every rule
that needs the declaring type reaches it with `fact_join_by_span` `within` --
no Pack field is asked for anywhere except `receiver_hint`, which
`omega-c-sharp` already publishes on `call.method`.

One key namespace holds every Unity-derived type: `unity:type:{ClassName}`.
It is path-free on purpose, so `[RequireComponent(typeof(PlayerMover))]` in one
file lands on the `PlayerMover` entity declared in another, which is the whole
point of a rendered canonical key.

| what it states | which Pack fact | entity / relation |
|---|---|---|
| this class is a component | `relation.implements` named `MonoBehaviour` + `within` `definition.class` | entity `GameComponent` at `unity:type:{Class}` |
| this class is a ScriptableObject asset type | `relation.implements` named `ScriptableObject` + `within` `definition.class` | entity `Asset` at `unity:type:{Class}` |
| this class extends the editor | `relation.implements` in {Editor, EditorWindow, PropertyDrawer, DecoratorDrawer, ScriptableWizard, AssetPostprocessor, AssetModificationProcessor, EditorTool, MaterialEditor} + `within` `definition.class` | entity `EditorExtension` at `unity:type:{Class}` |
| this plain class is inspector-serializable | `reference.attribute` named `Serializable` + `within` `definition.class` | entity `SerializedType` at `unity:type:{Class}` |
| which engine callbacks this component answers | `definition.method` whose `definition.name` is one of 44 Unity messages + `within` `definition.class` | entity `LifecycleHook`, relation `handles` from `unity:type:{Class}` |
| which coroutines it runs | `reference.type` named `IEnumerator` + `within` `definition.method` + `within` `definition.class` | entity `Coroutine`, relation `handles` from `unity:type:{Class}` |
| which components this component requires on the same GameObject | `reference.type` (the `typeof` argument) + `within` `reference.attribute` named `RequireComponent` + `within` `definition.class` | entity `GameComponent` for the required type, relation `depends` from `unity:type:{Class}` |
| which type this custom inspector draws | `reference.type` + `within` `reference.attribute` named `CustomEditor` | entity `GameComponent` for the target, relation `handles` from `unity:type:{Editor}` |
| which type this property drawer draws | `reference.type` + `within` `reference.attribute` named `CustomPropertyDrawer` | entity `SerializedType` for the target, relation `handles` from `unity:type:{Drawer}` |
| which ScriptableObjects a designer can create from the Assets menu | `reference.attribute` named `CreateAssetMenu` + `within` `definition.class` | entity `AssetMenu`, relation `configured_by` from `unity:type:{Class}` |
| which components run in edit mode, forbid duplicates or set an execution order | `reference.attribute` in {ExecuteAlways, ExecuteInEditMode, DisallowMultipleComponent, SelectionBase, DefaultExecutionOrder, AddComponentMenu, HelpURL, ContextMenu, ImageEffectAllowedInSceneView} + `within` `definition.class` | entity `ComponentPolicy`, relation `configured_by` from `unity:type:{Class}` |
| which components are tuned from the inspector, and with what constraint | `reference.attribute` in {SerializeField, SerializeReference, HideInInspector, Header, Tooltip, Range, Min, Space, TextArea, Multiline, ColorUsage, FormerlySerializedAs, NonSerialized} + `within` `definition.class` | entity `InspectorField`, relation `configured_by` from `unity:type:{Class}` |
| which component this component looks up at runtime | `reference.type` (the generic argument) + `within` `call.method` in {GetComponent(s), …InChildren, …InParent, TryGetComponent, FindObjectOfType, FindObjectsByType, …} + `within` `definition.class` | entity `GameComponent` for the looked-up type, relation `depends` from `unity:type:{Class}` |
| what this component spawns | `reference.type` + `within` `call.method` in {Instantiate, AddComponent, CreateInstance} + `within` `definition.class` | entity `GameComponent` for the spawned type, relation `depends` (`mode: instantiate`) |
| which scripts load from `Resources/` -- the build-size and stripping question | `call.method` named Load/LoadAsync/LoadAll/LoadAllAsync/UnloadAsset with `receiver_hint = Resources` + `within` `definition.class` | entity `ResourceLoad`, relation `depends` from `unity:type:{Class}` |
| which scripts change the scene | `call.method` named LoadScene/LoadSceneAsync/UnloadSceneAsync/GetSceneByName/SetActiveScene with `receiver_hint = SceneManager` + `within` `definition.class` | entity `SceneTransition`, relation `depends` from `unity:type:{Class}` |
| which scripts are editor-only and must not reach a player build | `import.namespace` whose name starts with `UnityEditor` | entity `EditorOnlyScript` at `unity:editor-script:{path}` |

Every relation end is a key some rule in this file materializes: the member
rules point their source at `unity:type:{Class}`, which the four role rules
emit, and the three `typeof`/generic-argument rules emit the referenced type
themselves before pointing at it, so nothing dangles even when the referenced
type is an engine type like `Rigidbody`.

The collapse: 12 lifecycle rules -> 1 `field_in` over 44 message names;
5 field-attribute rules -> 1 over 13 attribute names; 2 class-attribute rules ->
`unity.create-asset-menu` plus `unity.requires-component`; 2 `Resources.Load`
rules -> 1.

## A field only the Pack can supply

**Pack `omega-c-sharp`, kind `definition.field`: its span.**

`[SerializeField] private float speed;` is the single most-asked Unity question
-- *which fields of this component are authored in the inspector* -- and the
overlay cannot name the field. `omega-c-sharp` spans `definition.field` on
`@member.field`, which `queries.scm` binds to the `variable_declarator`
(`packs/omega-c-sharp/queries.scm`, the `field_declaration` pattern), while
`reference.attribute` spans the `attribute` node. The attribute is a child of
the `field_declaration`; the declarator is a grandchild through
`variable_declaration`. Neither span contains the other, so
`fact_join_by_span` with `within` cannot relate them in either direction, and
there is no owner or name they share for `fact_join_by_field`. The only other
span that contains both is `definition.class`, which is what this overlay uses
-- so it can say *this component has an inspector-authored `[Range]` field* but
not *`speed` is that field*.

Two ways out, both the Pack's: span `definition.field` on the
`field_declaration` rather than the declarator (which would cost nothing and
also fix the same join for every other framework reading C# field attributes),
or publish an `owner_span`/`declaration_span` field on `definition.field`. The
first is a span change, not a new field, and is the cheaper of the two.
`unity.inspector-field` is written to work today without it: it keys the entity
by attribute span and attaches it to the enclosing type.

## Still to decide

1. **Unity's own data files are unreachable, and it is not the Pack's fault.**
   `.unity`, `.prefab`, `.asset` and `.meta` are YAML, but
   `grammars/omega-yaml/manifest.toml` registers `extensions = ["yml"]` and no
   grammar registers those four. Until one does, no Pack emits a fact about a
   scene or a prefab and the whole `fileID`/`guid` half of Unity -- *which
   prefab uses this script*, *which scene contains this object* -- is "not
   found". This is a grammar-manifest decision with the same shape for
   `omega-godot-resource` (`extensions = []`, so `.tres`/`.tscn` are equally
   unreachable), so it belongs in `00-INDEX.md` rather than here. When the
   extensions are registered, the port is
   `structured.entry` -> `definition.config_key` plus `fact_join_by_span`
   `within` for the parent key, exactly as `00-INDEX.md` describes -- and the
   `guid:` inside an `m_Script:` mapping is reachable that way with no new
   field.
2. **`unity.coroutine` keys on `IEnumerator`, which is not Unity's.** A
   `reference.type` named `IEnumerator` in a method body, rather than in the
   return position, produces the same fact -- the Pack spans `@return_use` and
   `@type_use` under one kind -- so a method holding a local `IEnumerator` is
   claimed as a coroutine. Inside a Unity project the over-claim is small and
   the entity merges on the same key, but it is an over-claim. Narrowing it
   needs the Pack to distinguish the return position, which is a field, so the
   rule is kept as it is.
3. **`unity.spawns` folds `Instantiate` together with `AddComponent` and
   `CreateInstance`.** They differ -- one clones a prefab, one attaches a
   component, one allocates a ScriptableObject -- and the rule records which in
   its `via` attribute rather than splitting into three rules. If a question
   ever needs to separate them, the attribute is already there.
