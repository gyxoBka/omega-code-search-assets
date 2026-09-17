; --- ext_resource_id_path_context ---

; Framework-neutral authored Godot ext_resource identity/path pair.
; Both common attribute orders are accepted; no resource resolution is performed here.
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

; --- external-neovim-distributed-locals ---

; Omega coverage-first adapted external query
; source=neovim-distributed language=godot-resource kind=locals
; original baseline: audit-baselines/external/neovim-distributed/godot-resource/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; --- godot_resource_semantics ---

(resource) @godot.resource
(section (identifier) @godot.section.kind) @godot.section

(property (path) @godot.property.path (_) @godot.property.value) @godot.property
(constructor (identifier) @godot.constructor.kind (arguments) @godot.constructor.arguments) @godot.constructor

; --- node_script_ext_resource_context ---

; Framework-neutral authored Godot scene-node script binding.
; Captures only a [node name="..."] section whose script property is a literal ExtResource("id").
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

; --- section_attribute_context ---

; Framework-neutral Godot text-resource section attribute context.
(section
  (identifier) @godot.section.kind
  (attribute
    (identifier) @godot.section.attribute_name
    (_) @godot.section.attribute_value)) @godot.section.owner
