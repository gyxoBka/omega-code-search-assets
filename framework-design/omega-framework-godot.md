# omega-framework-godot

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

18 overlay rules, 12 detection rules. **18 can match, 0 cannot.**

Selector: `framework:godot`. Maturity: `semantic-overlay-full`.
Packs: `omega-gdscript`, `omega-godot-resource`.

### Entities it declares

| entity_kind | key space |
|---|---|
| `GodotScript` | `godot:script:{path}` |
| `GodotScene` | `godot:scene:{path}` |
| `GodotClass` | `godot:class:{name}` |
| `GodotSceneNode` | `godot:node:{path}:{name}` |
| `GodotSignal` | `godot:signal:{name}` |
| `GodotSignalConnection` | `godot:connection:{path}:{offset}` |
| `GodotMethod` | `godot:method:{name}` |
| `GodotResource` | `godot:res:{uri}` |
| `GodotResourceRef` | `godot:res-id:{path}:{id}` |
| `GodotExportedProperty` | `godot:export:{path}:{name}` |
| `GodotProjectSetting` | `godot:setting:{path}:{qname}` |
| `GodotAnnotation` | `godot:annotation:{name}` |

One kind and one attribute name per key space; `key_collisions.py godot`
reports nothing, and every canonical key a relation addresses is minted by the
same rule that addresses it.

### Fact kinds it matches

`definition.class`, `definition.function`, `definition.signal`,
`definition.exported_field`, `definition.declared_type_candidate`,
`reference.annotation`, `relation.implements`, `relation.depends`
(omega-gdscript); `definition.scene_node`, `definition.resource`,
`definition.config_key`, `reference.resource`, `reference.scene_node`,
`reference.signal`, `reference.signal_handler`, `type_use.godot_class`,
`relation.depends`, `structured.godot_section_attribute_context`
(omega-godot-resource).

Path globs: `**/*.gd`, `**/project.godot`. Neither contains a brace.

## What was wrong with it

**Six of nine rules matched a kind no Pack emits** — two thirds of the file.
`definition.category_candidate`, `call.gdscript_direct_candidate`,
`value.document`, `definition.gdscript_signal`,
`definition.gdscript_class_name` and `reference.gdscript_resource_load` are all
pre-rewrite spellings; omega-gdscript emits `definition.class`,
`definition.signal`, `call.function` and `relation.depends` instead, and
`value.document` was never a Godot kind at all. The rule that read the
attribute `symbol_category` was doubly dead: an attribute is write-only
(brief §3a), so even had the kind survived, the value could only have been
compared to a literal.

**Three of the nine outputs restated their input.** `godot.signal`,
`godot.class-name` and `godot.resource-load` each minted one entity and then
emitted a relation from `current` to *the key `current` had just been minted
under* — the self-loop wave 2 found in gitlab-ci and symfony. Three of the five
relations the file declared were `X -> X`.

**The one live sub-graph was keyed on quoted text.** The three surviving rules
read `structured.godot_*_context`, whose `attribute_value`, `resource_path` and
`node_name` fields are raw `(string)` captures and therefore carry their
surrounding `"` bytes. So `godot:asset:"res://player.gd"` from a scene could
never meet `res://player.gd` as any other fact names it, and
`godot:node:{path}:{node_name}` (quoted) addressed a node minted under
`godot:node:{path}:{attribute_value}` — quoted too, so that pair happened to
agree, but nothing else in the graph could reach either.

**Nothing crossed the file boundary.** A `.gd` script and the `.tscn` that runs
it shared no key. The single question a Godot overlay exists to answer —
*which script is attached to this node, and which method runs when this signal
fires* — was not answerable.

**Four dead kinds were a language spelling of something now spelled once.**
`definition.gdscript_class_name` and `definition.gdscript_signal` became
`definition.class` and `definition.signal`; `call.gdscript_direct_candidate`
over `["preload","load"]` and `reference.gdscript_resource_load` are both now
the single `relation.depends` omega-gdscript emits for a `res://` argument,
with the path already unquoted for you.

Counts: 9 rules -> 18; 6 dead -> 0; 5 relation kinds (3 of them self-loops) ->
19; 6 entity kinds on 6 key spaces -> 12 kinds on 12 key spaces, each with one
kind.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which nodes does this scene declare? | `definition.scene_node` | `GodotScene` -`contains_node`-> `GodotSceneNode` |
| What is the scene tree shape? | `reference.scene_node` (`parent=`) joined `within` `definition.scene_node` | `GodotSceneNode` -`parent_of`-> `GodotSceneNode` |
| What engine or user class is this node? | `type_use.godot_class` joined to `definition.scene_node` by `definition.container` | `GodotSceneNode` -`node_of_class`-> `GodotClass` |
| **Which script runs on this node?** | `reference.resource` whose `definition.container` is `script`, joined `within` `definition.scene_node` | `GodotSceneNode` -`has_script`-> `GodotResourceRef` |
| What file does `ExtResource("1_abc")` point at? | `relation.depends` joined `within` `definition.resource` | `GodotResourceRef` -`resolves_to`-> `GodotResource` |
| What does this scene depend on? | same fact | `GodotScene` -`depends_on`-> `GodotResource` |
| Which signal does this connection carry? | `reference.signal` joined `within` `structured.godot_section_attribute_context` (`section_kind=connection`) | `GodotScene` -`contains_connection`-> `GodotSignalConnection` -`connects_signal`-> `GodotSignal` |
| **Which method runs when it fires?** | `reference.signal_handler` on the same section span | `GodotSignalConnection` -`handled_by`-> `GodotMethod` |
| Which nodes does a connection wire? | `reference.scene_node` on the same section span | `GodotSignalConnection` -`connection_node`-> `GodotSceneNode` |
| Which scene does the project boot into? | `relation.depends` in `project.godot` joined `within` `definition.config_key` | `GodotProjectSetting` -`setting_points_to`-> `GodotResource` |
| Where is a project setting written? | `definition.config_key` under `**/project.godot` | `GodotProjectSetting` keyed by `definition.qname` (section + key) |
| Where is class `Player` declared? | `definition.class` in `**/*.gd` | `GodotClass` -`declared_in`-> `GodotScript` |
| What does this script extend? | `relation.implements` in `**/*.gd` | `GodotScript` -`extends`-> `GodotClass` |
| What does this script preload? | `relation.depends` in `**/*.gd` | `GodotScript` -`loads`-> `GodotResource` |
| Which signals does this script declare? | `definition.signal` | `GodotScript` -`declares_signal`-> `GodotSignal` |
| Which script declares the handler a scene names? | `definition.function` in `**/*.gd` | `GodotScript` -`defines_method`-> `GodotMethod` |
| What does this script show in the inspector? | `definition.exported_field` | `GodotScript` -`exports_property`-> `GodotExportedProperty` |
| What type does the inspector expect there? | `definition.declared_type_candidate` joined on the **same span** as the export | `GodotExportedProperty` -`typed_as`-> `GodotClass` |
| Which scripts are `@tool` / use `@rpc`? | `reference.annotation` in `**/*.gd` | `GodotScript` -`annotated_with`-> `GodotAnnotation` |

The three joins that carry the file are worth naming, because none of them
needs a Pack field:

- **`definition.container` as a discriminator.** omega-godot-resource spans
  `definition.scene_node` over the whole `[node ...]` section and
  `definition.config_key` over each property, so the host's synthesized
  container of `ExtResource("1_abc")` inside `script = ...` is the string
  `script`. `field_equals definition.container script` is the entire test for
  *this reference is the node's script*, and the same field distinguishes a
  node header's `type="CharacterBody2D"` (container: the node) from a
  `Vector2(0, 32)` written in a property value (container: that property).
- **A section span as a grouping key.** A `[connection]` section declares
  nothing, so the signal, the method and the two node paths inside it have no
  common ancestor in the definition chain. `structured.godot_section_attribute_context`
  spans the whole section, so joining `within` it and keying on
  `{sec.source.start}` gives every attribute of one connection the same
  identity without any Pack field.
- **Two halves of one question, one key.** `godot:signal:{name}` is minted by
  `definition.signal` in GDScript and by `[connection signal=...]` in a scene;
  `godot:method:{name}` by `definition.function` and by `method=`;
  `godot:class:{name}` by `class_name`, by `extends`, by a node's `type=` and by
  an export's declared type. Those shared keys are the only place a `.gd` file
  and a `.tscn` file meet, and they are what neither Pack can state alone.

### Why 18 rules and not 9

The old file answered three questions (a scene's nodes, a scene's ext_resource
paths, a node's script) and answered the third under a key nothing else could
reach. The new file answers nineteen, one relation kind each, with no rule
duplicating another's match. Nothing was collapsed because nothing was
duplicated: the old file had no two rules matching the same construct.

## Still to decide

- **A connection's `from` and `to` are not distinguishable.** They are sibling
  attributes of one section, and `structured.godot_section_attribute_context`
  spans the whole section for each of them, so a `within` join from a
  `reference.scene_node` binds the section whichever attribute it came from.
  `godot.scene.connection.endpoint` therefore states *this connection involves
  this node* rather than *this node emits* / *this node receives*, and is marked
  `candidate`. Reaching the stronger statement needs the Pack to span
  `reference.scene_node` differently or to publish the attribute name on it;
  neither is worth a field for one framework, and the weaker edge is still the
  scene's wiring graph.
- **`godot:method:{name}` is path-free.** A `.tscn` connection names its handler
  by a bare string and Godot resolves it at run time against whatever script the
  `to` node carries, so name is the only identity available. Every `func` of
  that name in the repository lands on one entity. This is faithful to the
  engine and lossy as a graph; the alternative is no edge at all.
- **`res://` is not resolved to a repository path.** `godot:res:{uri}` holds the
  URI as written. Mapping `res://player.gd` to `src/player.gd` needs the project
  root, which is the directory of `project.godot`; `fact_join_by_path_ancestor`
  can find that file, but a canonical key template cannot strip the `res://`
  prefix (only joins take a `strip_prefix`), so the two cannot be spliced.
  Recorded here rather than acted on.

## A field only the Pack can supply

None. Every rule is built from a fact kind, a name, a path, a span and the
host's synthesized `definition.container` / `definition.qname`. The only Pack
fields read anywhere in the file are `section_kind` and `attribute_name` on
`structured.godot_section_attribute_context`, both of which omega-godot-resource
already publishes.

The three `structured.godot_*_context` templates the Pack added for this overlay
are now used for one thing only — the connection grouping span — and their
`attribute_value`, `resource_path`, `node_name` and `resource_id` fields are no
longer read by any rule, because they carry the source's quote bytes and so
cannot be spliced into a key that any other fact reaches. That is a Pack
simplification to consider, not a field to add, and it belongs to whoever owns
`omega-godot-resource`.
