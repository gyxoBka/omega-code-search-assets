# omega-godot-resource

Language `omega-godot-resource`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

11 templates over 11 query patterns, 9 distinct grammar node types reached.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 4 |
| `references` | yes | 7 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_section` | Config | 1 |
| `definition.config_key` | Config | 1 |
| `definition.resource` | Value | 1 |
| `definition.scene_node` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 1 |
| `type_use.godot_class` | reference | 2 |
| `reference.resource` | reference | 1 |
| `reference.scene_node` | reference | 1 |
| `reference.signal` | reference | 1 |
| `reference.signal_handler` | reference | 1 |

No carriers, no scopes, no decoders, no injections, no `data` capability.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 18 node types. The Pack looks at 9 of them: `section`,
`identifier`, `attribute`, `property`, `path`, `string`, `integer`,
`constructor`, `arguments`.

Untouched, and why:

- `resource` — the file's root. Naming it names the document; that was the old
  Pack's `value.document` and it is defect D2.
- `array`, `dictionary`, `pair` — the interior of a property's value. A
  `PackedVector2Array` of a tilemap runs to megabytes of numbers and a
  dictionary pair key is data, not a name a question resolves to. The parts of
  a value that *do* name something — a `res://` path, a resource id, a Godot
  class — are reached through `string` and `constructor` wherever they are
  nested, so nothing is lost by leaving the containers alone.
- `float`, `true`, `false`, `null` — scalar values with no name.
- `comment` — `; ...` lines; Godot writes none of its own.

## What is wrong with it

The Pack that was here had 7 templates over 8 patterns and 6 guards, declared
`data` and `references`, and declared **nothing at all**: not one of its seven
kinds passed `is_definition_kind`, so a Godot project indexed with it contained
no scene node, no resource, no setting that a question could resolve to. Every
emission was a mention, and every mention resolved against nothing, because
there was nothing on the other side.

Concretely:

1. **Nothing was a declaration (7 of 7 templates).** `structured.entry`,
   `structured.godot_ext_resource_id_path_context`,
   `structured.godot_node_script_ext_resource_context`,
   `structured.godot_section_attribute_context`, `value.document` and
   `reference.godot_resource_constructor` are all mentions: none contains
   `definition` and none ends in `.type`, `.function`, `.class`, `.method` or
   `.trait`. (`value.document` is not even caught by the `value_` prefix
   exclusion — it never had to be.)
   The manifest therefore declared no `definitions` capability and the Pack
   answered "not found" for every symbol in every `.tscn` and `.tres` file.
2. **Defect D, twice.** `structured.godot_ext_resource_id_path_context` and
   `structured.godot_node_script_ext_resource_context` took their name from a
   `(string)` capture without stripping the quotes, so the stored name was
   `"1_abc"` with the quote characters in it. Nothing referring to that id is
   ever spelled that way, so the two sides could never have met even if the
   declaration had existed.
3. **Defect D2, once.** `value.document` had `span_capture: godot.resource` and
   `name: capture_ref godot.resource` — the whole file, root node text, stored
   as a name, once per file.
4. **Defect E, and the cartesian cost of it.** Both `ext_resource` patterns
   were written as `(section (identifier) (attribute …) (attribute …))` with
   `#eq?` on each attribute name, once for each of the two attribute orders the
   author could think of. With N attributes in the header that is N² matches
   per section to ask for two of them, the whole thing duplicated, and any
   third ordering — Godot 4 writes `type= path= id=`, Godot 4.2 adds `uid=`
   between them — silently unmatched. The `node_script` pattern nested four
   levels of the same shape for one `script = ExtResource("…")` line.
5. **Defect G, six times of six.** Every guard's reason was generator prose
   about "Pack truth", "bounded source symbol resolution" and "runtime
   semantics" — three of them said the same thing in different words, and none
   named a limitation a reader could act on. Two guards named the `data`
   capability for facts that were about references.
6. **Defect L, denied in the file.** Four comment lines asserted
   "Framework-neutral" over patterns keyed on the literal strings
   `ext_resource`, `node`, `script` and `ExtResource`. The denial is the tell.
   Here the verdict goes the other way — see *Is this a framework overlay?*
   below — but the comments were doing no work except reassurance.
7. **An `unread` baseline.** A six-line block headed
   `external-neovim-distributed-locals` carried a provenance header for an
   nvim-treesitter `locals.scm` and no patterns; the `NOTICE` and
   `license = "MIT AND Apache-2.0"` rested on it.
8. **`fields` used as if it were `attributes`, and mis-typed.** Two templates
   wrote `"fields": {"value": "godot.property.value"}` — a bare string, which
   the expression reader lifts to a *literal* whose value is the text
   `godot.property.value`. Every property in the corpus carried the field
   `value = "godot.property.value"`. The `arguments` field on
   `reference.godot_resource_constructor` was the same mistake, and the ones
   that were spelled correctly stored a whole `(arguments)` subtree per
   emission.
9. **The whole section's attributes stored per attribute.**
   `structured.godot_section_attribute_context` emitted once per attribute of
   every section, named with the attribute's identifier, spanning the whole
   section, with the attribute value as a field. A `.tscn` with 400 nodes
   produced 1 200 mentions named `name`, `type` and `parent`.

Nine untouched node types, no declarations, and the one link the format has —
`ExtResource("1_abc")` back to `[ext_resource id="1_abc"]` — spelled on the
declaration side with quotes and on the reference side without.

## What it should extract

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| a configuration section: `[application]`, `[rendering]`, `[gd_scene]`, `[resource]`, `[editable]` | `section` header `identifier` | `definition.config_section`, span = whole section | Config |
| a setting: `config/name=…`, `run/main_scene=…`, `radius = 16.0` | `property` → `path` | `definition.config_key`, span = the property | Config |
| an external or inline resource, by the id that refers to it | `section` `ext_resource` / `sub_resource` with `id=` | `definition.resource`, span = whole section, attribute `section` = which of the two | Value |
| a scene node | `section` `node` with `name=` | `definition.scene_node`, span = whole section | Value |
| the Godot class a section declares | `type=` attribute of `node` / `ext_resource` / `sub_resource` | `type_use.godot_class`, span = the class name | reference |
| a Godot class written as a value constructor: `Vector2(…)`, `Color(…)`, `NodePath(…)` | `constructor` → `identifier` | `type_use.godot_class`, span = the identifier | reference |
| `ExtResource("1_abc")` / `SubResource("Shape_x")`, and the Godot 3 integer form | `constructor` + first `arguments` child | `reference.resource`, name = the bare id | reference |
| a node named by a path: `parent=`, `from=`, `to=` | `node` / `connection` attribute | `reference.scene_node`, name = last `/` segment | reference |
| a signal connection's signal | `connection` `signal=` | `reference.signal` | reference |
| a signal connection's handler method | `connection` `method=` | `reference.signal_handler` | reference |
| anything the file points at: `res://…`, `user://…` | any `string` matching the URI | `relation.depends` | depends |

Every name that comes from a `(string)` node is unquoted with a
`strip_prefix`/`strip_suffix` pair, so `[ext_resource id="1_abc"]` and
`ExtResource("1_abc")` name the same thing and resolve to each other. That is
the one link this format has and it is now made.

Containment is not stated. A `section` node spans the properties written under
its header, so `definition.config_key` emissions land inside the
`definition.scene_node` or `definition.config_section` that owns them and the
host's `within:` segment carries the scene node's name for free.

Attribute order is not pinned either: each pattern asks for the one attribute
it needs by name with `#eq?`/`#any-of?` on the `identifier`, so the two
patterns the old Pack needed for the two orders of `[ext_resource]` are one
pattern that also survives a third order and Godot 4.2's added `uid=`.

### Is this a framework overlay? (defect L)

The patterns key on the literal section names `ext_resource`, `sub_resource`,
`node` and `connection` and on the constructor names `ExtResource` and
`SubResource`. That is not defect L. The grammar
`tree-sitter-godot-resource` parses an INI-like shape and nothing else; the
*language* is Godot's text resource format, in which those six words are the
format's own vocabulary, defined by the serializer, not by a library built on
top of it. `frameworks/omega-framework-godot` exists and is where anything
about a particular Godot API belongs. The four "Framework-neutral" comments
are gone; the reasoning is stated once, here.

### The NOTICE

The rewritten `queries.scm` carries no line derived from the nvim-treesitter
baseline — the only trace of it was an empty, pattern-free provenance block.
`NOTICE` is deleted and the manifest licence is back to `MIT`, as omega-twig
and omega-json5 did.

## Still to decide

- **`(string)` is captured at pattern root.** The `res://` dependency pattern
  matches every string node in the file and then filters with `#match?`. That
  is one match per string in a `.tscn`, which is the most numerous named node
  in the format. The alternative is two or three narrower patterns
  (`attribute` value, `property` value, `arguments` member) that between them
  cost about as much and miss a path nested in an array or a dictionary. The
  root capture is not defect I or I2 — `string` is not the language's general
  identifier node and the predicate is applied — but `max_matches` was raised
  from 10 000 to 20 000 on its account. If a large scene is ever seen to hit
  the budget, this is the pattern to narrow.
- **`uid://` is not stated.** A `uid` is an opaque alias only Godot's
  project-wide UID table can turn into a path. Emitting it as a dependency
  would create a name with nothing on the other side. It is named in a guard
  instead. If a future Pack ever reads `.godot/uid_cache.bin`, this changes.
- **A property's value is not stored.** Keeping it would be defect D at scale
  — a single tilemap property is megabytes of packed array. The parts that
  name something are stated on their own spans. The cost is that
  `config/name="My Game"` is located by key and not by value.
