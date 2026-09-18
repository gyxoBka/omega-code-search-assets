# omega-framework-unity

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

17 overlay rules, 12 detection rules. **17 live, 0 cannot match.**
`key_collisions.py` reports nothing.

Selector: `framework:unity`. Maturity: `semantic-overlay-full`.
Language: C# only (`host.required_packs = ["omega-c-sharp"]`), every rule gated
on `path_glob **/*.cs`.

### Fact kinds it matches

| kind | rules | omega-c-sharp emits it |
|---|---|---|
| `reference.type` | 6 | yes |
| `reference.attribute` | 4 | yes |
| `relation.implements` | 3 | yes |
| `call.method` | 2 | yes |
| `definition.method` | 1 | yes |
| `import.namespace` | 1 | yes |

Joined kinds: `definition.class` (16 rules, `fact_join_by_span` `within`),
`definition.method` (1), `reference.attribute` (3), `call.method` (2).
The only Pack-published field read anywhere is `receiver_hint`, which
`omega-c-sharp` already publishes on `call.method`. Everything else is a
built-in name (`definition.name`, `path`, `source.start`).

### Key spaces it mints

| key template | entity kind | minted by |
|---|---|---|
| `unity:type:{Class}` | `UnityType` | all 16 class-scoped rules (the hub) |
| `unity:component:{Class}` | `GameComponent` | `unity.component` |
| `unity:scriptable-object:{Class}` | `Asset` | `unity.scriptable-object` |
| `unity:editor-extension:{Class}` | `EditorExtension` | `unity.editor-extension` |
| `unity:serializable-type:{Class}` | `SerializedType` | `unity.serializable-type` |
| `unity:lifecycle:{Class}:{Method}` | `LifecycleHook` | `unity.lifecycle` |
| `unity:coroutine:{Class}:{Method}` | `Coroutine` | `unity.coroutine` |
| `unity:asset-menu:{Class}` | `AssetMenu` | `unity.create-asset-menu` |
| `unity:policy:{Class}:{Attribute}` | `ComponentPolicy` | `unity.component-policy` |
| `unity:inspector-field:{path}:{start}` | `InspectorField` | `unity.inspector-field` |
| `unity:resources-load:{path}:{start}` | `ResourceLoad` | `unity.resources-load` |
| `unity:scene-transition:{path}:{start}` | `SceneTransition` | `unity.scene-load` |
| `unity:editor-script:{path}` | `EditorOnlyScript` | `unity.editor-only-script` |

Every key template is minted under exactly one entity kind, with one attribute
set. Every relation end in the file addresses a template in this table.

## What was wrong with it

### Wave 1: the kinds (56 rules -> 17)

The file shipped 56 overlay rules and **54 could not match any Pack emission**.

| what was wrong | rules |
|---|---|
| keyed to a `structured.entry` kind no Pack emits, on `.unity`/`.prefab`/`.asset` paths no grammar claims | 33 |
| keyed to C#-private `*_context` kinds the Pack rewrite removed (`definition.csharp_lifecycle_method_context`, `definition.csharp_class_base_context`, `reference.csharp_attributed_field_context`, `reference.csharp_attributed_class_string_context`, `call.csharp_class_member_string_context`) | 21 |
| matched a live kind but through `external_path_matches` on `definition.class`, which carries no `external` | 2 |

Underneath, three habits: **one rule per literal** (12 lifecycle rules differing
only in a method name, 18 `SerializedObject` rules differing only in a YAML key,
5 field-attribute rules differing only in an attribute name -- 48 of the 56 were
one rule written out by hand N times); **restating the input**
(`unity.serialized-object.camera` emitted an entity named `Camera` for a line
that said `Camera:`, with no relation -- 18 of the 33 YAML rules produced an
entity and nothing else); and **reaching the enclosing class by a published
field** (`fact_join_by_field` on `owner_class`, a field the Pack would have had
to carry on every C# method in every repository, where `fact_join_by_span`
`within` reaches the class with no field on either side).

The 33 YAML rules were not portable at all, and not because of the kind. **No
grammar registers `.unity`, `.prefab`, `.asset` or `.meta`**
(`grammars/omega-yaml/manifest.toml` declares `extensions = ["yml"]`), so a
Unity scene, prefab or ScriptableObject instance is never parsed. Porting them
to `definition.config_key` would have made the audit green while every rule
stayed silent on every repository. They were deleted; see "Still to decide" 1.

### Wave 2: the 17 live rules did not reach the graph

The audit reported 17 live, and it was still wrong about what the file
produced. Two defects the audit cannot see, both fixed here.

**1. Five entity kinds on one canonical key -- 16 of the 29 entity outputs
discarded.** `key_collisions.py unity` reported:

```
   unity:type:{cls.definition.name}
      kept    GameComponent   unity.component
      DROPPED UnityType x12, EditorExtension, Asset, SerializedType   (15 rules)
   unity:type:{definition.name}
      kept    GameComponent   unity.component-lookup
      DROPPED SerializedType  unity.custom-property-drawer
```

`Entity::named` builds the id from the canonical key alone and
`entities.entry(id).or_insert(entity)` keeps the first candidate in `rule_id`
order, **with its kind and its attributes**. `unity.component` sorts before
everything else, so any type that happened to derive from `MonoBehaviour` fixed
the whole `unity:type:` space as `GameComponent` with a `base: MonoBehaviour`
attribute -- and a `ScriptableObject` asset type, an `Editor`, a `[Serializable]`
plain class, and the neutral hub the other 12 rules minted for their relation
source, were all computed and thrown away. In a project with no MonoBehaviour at
all, the kind on the hub was whichever rule happened to fire.

Fixed by brief 3g remedy 1 + 2 together: `unity:type:{Class}` now carries the
single neutral kind `UnityType` with the single attribute `name` in **all 16**
rules that mint it, so the merge is a no-op rather than a race; and each of the
four role classifications moved to its own key space
(`unity:component:`, `unity:scriptable-object:`, `unity:editor-extension:`,
`unity:serializable-type:`), attached to the hub by an `implements` relation.
Both kinds and both attribute sets survive, and each is separately addressable.

**2. All twelve relations were self-loops.** `emit()` sets `own_key` from a rule's
**first** entity output (`overlay.rs:885-912`), and every multi-output rule here
emitted the hub first and the thing it was about second, then wrote its relation
as `source: by_canonical_key unity:type:{cls}` / `target: current`. `current`
therefore resolved to the hub, and the graph got

    unity:type:PlayerMover  handles  unity:type:PlayerMover

for every lifecycle hook, every coroutine, every `[CreateAssetMenu]`, every
inspector attribute, every `Resources.Load`, every `SceneManager.LoadScene` --
and for the five type-to-type rules the edge pointed back at the source instead
of at the required/looked-up/spawned/inspected type, so
`[RequireComponent(typeof(Rigidbody))]` said *PlayerMover depends on
PlayerMover*. Every `LifecycleHook`, `Coroutine`, `AssetMenu`,
`ComponentPolicy`, `InspectorField`, `ResourceLoad` and `SceneTransition`
entity in the graph was reachable by search and connected to nothing.

Fixed by removing `current` from the file entirely: all 32 ends of the now 16 relations are
explicit `by_canonical_key` templates, checked mechanically against the set of
templates the file mints.

No rule was added or removed in wave 2. **17 rules before, 17 after**; only the
`outputs` arrays changed, and `emits` was corrected to list the 13 entity kinds
and 4 relation kinds actually produced.

## What it states now

One key namespace holds every Unity-derived type: `unity:type:{ClassName}`,
kind `UnityType`. It is path-free on purpose, so
`[RequireComponent(typeof(PlayerMover))]` in one file lands on the same entity
as `class PlayerMover : MonoBehaviour` in another -- that is the whole point of
a rendered canonical key, and it is why the hub must have one kind.

| what it states | which Pack fact | entity / relation |
|---|---|---|
| this class exists as a Unity type | any of the 16 rules below | entity `UnityType` at `unity:type:{Class}` |
| it is a component | `relation.implements` `MonoBehaviour` + `within` `definition.class` | entity `GameComponent` at `unity:component:{Class}`; `UnityType implements` it |
| it is a ScriptableObject asset type | `relation.implements` `ScriptableObject` + `within` `definition.class` | entity `Asset` at `unity:scriptable-object:{Class}`; `implements` |
| it extends the editor | `relation.implements` in {Editor, EditorWindow, PropertyDrawer, DecoratorDrawer, ScriptableWizard, AssetPostprocessor, AssetModificationProcessor, EditorTool, MaterialEditor} + `within` `definition.class` | entity `EditorExtension` at `unity:editor-extension:{Class}` (attribute `base` = which one); `implements` |
| this plain class is inspector-serializable | `reference.attribute` `Serializable` + `within` `definition.class` | entity `SerializedType` at `unity:serializable-type:{Class}`; `implements` |
| which engine callbacks this component answers | `definition.method` whose `definition.name` is one of 44 Unity messages + `within` `definition.class` | entity `LifecycleHook`; relation `handles` `unity:type:{Class}` -> `unity:lifecycle:{Class}:{Method}` |
| which coroutines it runs | `reference.type` `IEnumerator` + `within` `definition.method` + `within` `definition.class` | entity `Coroutine`; `handles` -> `unity:coroutine:{Class}:{Method}` |
| which components it requires on the same GameObject | `reference.type` (the `typeof` argument) + `within` `reference.attribute` `RequireComponent` + `within` `definition.class` | `depends` `unity:type:{Class}` -> `unity:type:{Required}`, both hubs minted |
| which type this custom inspector draws | `reference.type` + `within` `reference.attribute` in {CustomEditor, CustomEditorForRenderPipeline} + `within` `definition.class` | `handles` (`role: inspector`) `unity:type:{Editor}` -> `unity:type:{Target}` |
| which type this property drawer draws | `reference.type` + `within` `reference.attribute` `CustomPropertyDrawer` + `within` `definition.class` | `handles` (`role: property_drawer`) `unity:type:{Drawer}` -> `unity:type:{Target}` |
| which ScriptableObjects a designer can create from the Assets menu | `reference.attribute` `CreateAssetMenu` + `within` `definition.class` | entity `AssetMenu`; `configured_by` -> `unity:asset-menu:{Class}` |
| which components run in edit mode, forbid duplicates or set an execution order | `reference.attribute` in {ExecuteAlways, ExecuteInEditMode, DisallowMultipleComponent, SelectionBase, DefaultExecutionOrder, AddComponentMenu, HelpURL, ContextMenu, ImageEffectAllowedInSceneView} + `within` `definition.class` | entity `ComponentPolicy`; `configured_by` -> `unity:policy:{Class}:{Attribute}` |
| which components are tuned from the inspector, and with what constraint | `reference.attribute` in {SerializeField, SerializeReference, HideInInspector, Header, Tooltip, Range, Min, Space, TextArea, Multiline, ColorUsage, FormerlySerializedAs, NonSerialized} + `within` `definition.class` | entity `InspectorField`; `configured_by` -> `unity:inspector-field:{path}:{start}` |
| which component this component looks up at runtime | `reference.type` (the generic argument) + `within` `call.method` in {GetComponent(s), ...InChildren, ...InParent, TryGetComponent, FindObjectOfType, FindObjectsByType, ...} + `within` `definition.class` | `depends` (`via` = the call) `unity:type:{Class}` -> `unity:type:{Looked-up}` |
| what this component spawns | `reference.type` + `within` `call.method` in {Instantiate, AddComponent, CreateInstance} + `within` `definition.class` | `depends` (`via`, `mode: instantiate`) -> `unity:type:{Spawned}` |
| which scripts load from `Resources/` -- the build-size and stripping question | `call.method` in {Load, LoadAsync, LoadAll, LoadAllAsync, UnloadAsset} with `receiver_hint = Resources` + `within` `definition.class` | entity `ResourceLoad`; `depends` -> `unity:resources-load:{path}:{start}` |
| which scripts change the scene | `call.method` in {LoadScene, LoadSceneAsync, UnloadSceneAsync, GetSceneByName, SetActiveScene} with `receiver_hint = SceneManager` + `within` `definition.class` | entity `SceneTransition`; `depends` -> `unity:scene-transition:{path}:{start}` |
| which scripts are editor-only and must not reach a player build | `import.namespace` whose name starts with `UnityEditor` | entity `EditorOnlyScript` at `unity:editor-script:{path}` |

`unity.editor-only-script` is the one rule with no relation: it is a property of
a file, not of a type, and there is no class to join a file-level `using` to. It
is kept because "which scripts are editor-only" is a real question and the
entity carries the path that answers it.

Because the hub is minted by the reference rules as well as the declaration
rules, a relation to an engine type the project never declares -- `Rigidbody`,
`Animator` -- still has both ends: the `UnityType` for `Rigidbody` is minted by
the `GetComponent<Rigidbody>()` rule itself. Nothing dangles.

## A field only the Pack can supply

**Pack `omega-c-sharp`, kind `definition.field`: its span.**

`[SerializeField] private float speed;` is the single most-asked Unity question
-- *which fields of this component are authored in the inspector* -- and the
overlay cannot name the field. `omega-c-sharp` spans `definition.field` on
`@member.field`, which `queries.scm` binds to the `variable_declarator`, while
`reference.attribute` spans the `attribute` node. The attribute is a child of
the `field_declaration`; the declarator is a grandchild through
`variable_declaration`. Neither span contains the other, so
`fact_join_by_span` with `within` cannot relate them in either direction, and
they share no name or owner for `fact_join_by_field`. The only span containing
both is `definition.class`, which is what this overlay uses -- so it can say
*this component has an inspector-authored `[Range]` field* but not *`speed` is
that field*.

Two ways out, both the Pack's: span `definition.field` on the
`field_declaration` rather than on the declarator (which costs nothing and fixes
the same join for every framework reading C# field attributes), or publish an
`owner_span`/`declaration_span` field on `definition.field`. The first is a span
change, not a new field, and is the cheaper. `unity.inspector-field` works today
without it: it keys the entity by attribute span and attaches it to the
enclosing type.

## Still to decide

1. **Unity's own data files are unreachable, and it is not the Pack's fault.**
   `.unity`, `.prefab`, `.asset` and `.meta` are YAML, but
   `grammars/omega-yaml/manifest.toml` registers `extensions = ["yml"]` and no
   grammar registers those four. Until one does, no Pack emits a fact about a
   scene or a prefab, and the whole `fileID`/`guid` half of Unity -- *which
   prefab uses this script*, *which scene contains this object* -- is "not
   found". Same shape as `omega-godot-resource` (`extensions = []`, so
   `.tres`/`.tscn` are equally unreachable), so it belongs in `00-INDEX.md`
   rather than here. When the extensions are registered the port is
   `structured.entry` -> `definition.config_key` plus `fact_join_by_span`
   `within` for the parent key, and the `guid:` inside an `m_Script:` mapping is
   reachable that way with no new field.
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
4. **The four role entities duplicate the hub's name.** `unity:component:Player`
   holds only `class`, `base` and `declared_in`; it exists because brief 3g
   forbids a second kind on `unity:type:Player`. The alternative -- dropping the
   role entities and classifying purely by the presence of an outgoing edge --
   would make "list every MonoBehaviour in this project" a two-hop query instead
   of one entity-kind lookup. The duplication is the cheaper of the two and is
   the reason the file emits 13 entity kinds for 17 rules.
