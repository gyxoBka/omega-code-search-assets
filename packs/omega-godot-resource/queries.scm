; omega-godot-resource
;
; The Godot text resource format: `.tscn` scenes, `.tres` resources,
; `project.godot`, `.godot/*.cfg`, `*.import`. It is an INI-like file of
; `[section attr=value]` headers followed by `key = value` properties, and
; every question asked of one is about a name written in it:
;
;   where is the scene node `Player` declared, and under which parent;
;   what file does this scene depend on;
;   what does `ExtResource("1_abc")` point at;
;   what Godot class is this node, sub-resource or value;
;   which method is a signal connected to;
;   where is the setting `application/config/name` set.
;
; Containment is deliberately not stated. A `section` node already spans the
; properties written under its header, so a property inside `[node name="X"]`
; carries `X` through the host's `within:` segment for free; a pattern that
; re-stated it would cost one match per (section, property) pair.
;
; The grammar exposes no fields, so every child position here is pinned with
; an anchor and every section kind and attribute name with a predicate that
; the runtime actually applies (`#eq?`, `#any-of?`, `#not-any-of?`,
; `#match?`). Attribute order is not pinned: each pattern asks for the one
; attribute it needs by name, so `[ext_resource type=... path=... id=...]`
; and `[ext_resource id=... path=... type=...]` are one pattern, not two.

; --- a configuration section ---
;
; `[application]`, `[rendering]`, `[gd_scene]`, `[gd_resource]`, `[resource]`,
; `[editable]`: a section whose header identifier is its own name. The four
; section kinds that name something else -- and are stated below under that
; name -- are excluded, so a scene with 400 `[node ...]` headers does not
; declare the word `node` 400 times.

((section . (identifier) @section.kind) @section
 (#not-any-of? @section.kind "ext_resource" "sub_resource" "node" "connection"))

; --- a setting ---
;
; `config/name="My Game"`, `run/main_scene="res://main.tscn"`, `radius = 16.0`.
; The key is a `path` leaf and is the declaration's name. The value is not
; stored: it is unbounded (a `PackedVector2Array` property of a tilemap runs to
; megabytes) and the parts of it that answer a question -- a `res://` path, a
; resource id, a Godot class -- are each stated on their own span below.

(property . (path) @property.key) @property

; --- an external or inline resource, by the id that refers to it ---
;
; `[ext_resource type="Script" path="res://player.gd" id="1_abc"]` and
; `[sub_resource type="CircleShape2D" id="Shape_x1y2"]` both declare an id,
; and the id is what `ExtResource(...)` / `SubResource(...)` writes. Godot 3
; spells the id as a bare integer, Godot 4 as a string; both are taken.

((section . (identifier) @resource.section_kind
   (attribute . (identifier) @resource.id_key . [(string) (integer)] @resource.id)) @resource
 (#any-of? @resource.section_kind "ext_resource" "sub_resource")
 (#eq? @resource.id_key "id"))

; --- a scene node ---
;
; `[node name="Player" type="CharacterBody2D" parent="Level"]`. The span is the
; whole section, so the properties written under the header are reported inside
; the node they configure.

((section . (identifier) @node.section_kind
   (attribute . (identifier) @node.name_key . (string) @node.name)) @node
 (#eq? @node.section_kind "node")
 (#eq? @node.name_key "name"))

; --- the Godot class a section declares itself to be ---
;
; `type="CharacterBody2D"` on a node, `type="CircleShape2D"` on a sub-resource,
; `type="Script"` on an ext_resource. A mention of a class, spanning the class
; name only.

((section . (identifier) @typed.section_kind
   (attribute . (identifier) @typed.type_key . (string) @typed.type))
 (#any-of? @typed.section_kind "ext_resource" "sub_resource" "node")
 (#eq? @typed.type_key "type"))

; --- a node named by a path ---
;
; `parent="Level/Enemies"` on a node, `from="Area2D"` / `to="."` on a
; connection. The name is reduced to the last segment of the path so that it
; resolves against the `name=` of the node section that declares it. `"."` is
; the scene root written as itself and names nothing.

((section . (identifier) @node_path.section_kind
   (attribute . (identifier) @node_path.key . (string) @node_path.target))
 (#any-of? @node_path.section_kind "node" "connection")
 (#any-of? @node_path.key "parent" "from" "to")
 (#not-eq? @node_path.target "\".\""))

; --- a signal connection ---
;
; `[connection signal="body_entered" from="Area2D" to="." method="_on_hit"]`
; is the only place in a Godot project where a signal name and the method it
; runs are written down. Both are mentions: the signal is declared by the
; engine class or by a `signal` statement in GDScript, the method by the script
; the `to` node carries.

((section . (identifier) @connection.signal_section
   (attribute . (identifier) @connection.signal_key . (string) @connection.signal))
 (#eq? @connection.signal_section "connection")
 (#eq? @connection.signal_key "signal"))

((section . (identifier) @connection.method_section
   (attribute . (identifier) @connection.method_key . (string) @connection.method))
 (#eq? @connection.method_section "connection")
 (#eq? @connection.method_key "method"))

; --- what the file points at ---
;
; Any string in the file that is a Godot resource URI is a dependency on the
; file it names: `path=` on an ext_resource, `path=` on an `[editable]`, a
; script path inside an array, a texture inside a dictionary. One pattern over
; `string` reaches all of them, which is why no pattern above captures a path.
;
; `uid://` is deliberately not matched -- see the coverage guard.

((string) @dependency.path
 (#match? @dependency.path "^\"(res|user)://"))

; --- a value written as a Godot constructor ---
;
; `Vector2(0, 32)`, `Color(1, 1, 1, 1)`, `NodePath("Sprite2D")`,
; `Resource("res://x.tres")`: the identifier is a Godot class, and the mention
; spans that identifier alone. `ExtResource` and `SubResource` are excluded --
; they are not classes, they are the reference form, taken next.

((constructor . (identifier) @constructor.class)
 (#not-any-of? @constructor.class "ExtResource" "SubResource"))

; --- the reference a resource id makes ---
;
; `ExtResource("1_abc")` / `SubResource("Shape_x1y2")`, and the Godot 3
; spelling `ExtResource( 1 )`. The name is the bare id, so it resolves against
; the `[ext_resource]` / `[sub_resource]` header that declares it.

((constructor . (identifier) @resource_ref.form
   . (arguments . [(string) (integer)] @resource_ref.id)) @resource_ref
 (#any-of? @resource_ref.form "ExtResource" "SubResource"))

; --- what the Godot framework overlay reads ---
;
; These three state one specific triple each about a scene file, and
; frameworks/omega-framework-godot joins them by resource id to build Scene,
; GameEntity and the script attachment. They are not a path of ancestor keys
; restated per depth; removing them killed four of that overlay's nine rules.

(section
  (identifier) @godot.section.kind
  (attribute
    (identifier) @godot.section.attribute_name
    (_) @godot.section.attribute_value)) @godot.section.owner
((section
  (identifier) @godot.ext_resource.section_kind
  (attribute
    (identifier) @godot.ext_resource.path_attribute
    (string) @godot.ext_resource.path)
  (attribute
    (identifier) @godot.ext_resource.id_attribute
    (string) @godot.ext_resource.resource_id)) @godot.ext_resource.owner
(#eq? @godot.ext_resource.section_kind "ext_resource")
(#eq? @godot.ext_resource.path_attribute "path")
(#eq? @godot.ext_resource.id_attribute "id"))

((section
  (identifier) @godot.ext_resource.section_kind
  (attribute
    (identifier) @godot.ext_resource.id_attribute
    (string) @godot.ext_resource.resource_id)
  (attribute
    (identifier) @godot.ext_resource.path_attribute
    (string) @godot.ext_resource.path)) @godot.ext_resource.owner
(#eq? @godot.ext_resource.section_kind "ext_resource")
(#eq? @godot.ext_resource.id_attribute "id")
(#eq? @godot.ext_resource.path_attribute "path"))

((section
  (identifier) @godot.node_script.section_kind
  (attribute
    (identifier) @godot.node_script.name_attribute
    (string) @godot.node_script.node_name)
  (property
    (path) @godot.node_script.property_name
    (constructor
      (identifier) @godot.node_script.constructor_name
      (arguments
        (string) @godot.node_script.resource_id)))) @godot.node_script.owner
(#eq? @godot.node_script.section_kind "node")
(#eq? @godot.node_script.name_attribute "name")
(#eq? @godot.node_script.property_name "script")
(#eq? @godot.node_script.constructor_name "ExtResource"))
