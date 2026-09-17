; omega-gdscript -- what a GDScript file declares, what it references, what it calls.
;
; One pattern per node. Several templates hang off one match where one match
; answers several questions (a function and its signature, a field and its
; declared type). Containment is not stated: the tree already holds it and the
; host carries an inner class through the `within:` namespace segment.

; ---------------------------------------------------------------- declarations

; `class_name Player` -- the script's own globally registered type.
(class_name_statement
  (name) @class_name.name) @class_name

; `class Inner:` -- an inner class, and its body as a region.
(class_definition
  name: (name) @class.name
  body: (body) @class.body) @class

; `func move(delta: float) -> void:` -- the declaration, its parameter shape,
; its return type, and its body as a region.
(function_definition
  name: (name) @function.name
  parameters: (parameters) @function.parameters
  return_type: (type)? @function.return_type
  body: (body) @function.body) @function

; `func _init(...)` -- the constructor. This grammar spells `_init` as a
; keyword token of the rule, so the node carries no name of its own.
(constructor_definition
  parameters: (parameters) @constructor.parameters) @constructor

; `signal damaged(amount: int)`
(signal_statement
  .
  (name) @signal.name
  (parameters)? @signal.parameters) @signal

; `enum Direction { UP, DOWN }` and each of its members.
(enum_definition
  name: (name) @enum.name) @enum

(enumerator
  left: (identifier) @enumerator.name) @enumerator

; `var speed: float = 3.0` at file scope or in an inner class body -- a property
; of the script's class. A `var` anywhere else is a local; see the guard.
(source
  (variable_statement
    name: (name) @field.name
    type: (type)? @field.type) @field)

(class_definition
  body: (body
    (variable_statement
      name: (name) @field.name
      type: (type)? @field.type) @field))

; `const MAX_HP = 100`
(source
  (const_statement
    name: (name) @constant.name
    type: (type)? @constant.type) @constant)

(class_definition
  body: (body
    (const_statement
      name: (name) @constant.name
      type: (type)? @constant.type) @constant))

; `export(int) var speed` -- a field the editor's inspector shows.
(export_variable_statement
  name: (name) @export.name
  type: (type)? @export.type) @export

; `onready var sprite = $Sprite` -- a field initialised when the node enters
; the tree.
(onready_variable_statement
  name: (name) @onready.name
  type: (type)? @onready.type) @onready

; ------------------------------------------------------------------ references

; `extends Node2D` / `extends A.B` -- the base class this script derives from.
(extends_statement
  (type) @extends.type)

; `extends "res://actor.gd"` -- the same edge, spelled as a script path.
(extends_statement
  (string) @extends.path)

; `preload("res://enemy.tscn")` / `load(path)` -- a file this script depends on.
(call
  .
  (identifier) @load.function
  (arguments
    .
    (string) @load.path)
  (#any-of? @load.function "preload" "load"))

; `@export`, `@onready`, `@tool`, `@rpc(...)` -- the annotation by name.
(annotation
  .
  (identifier) @annotation.name) @annotation

; `var hp setget _set_hp, _get_hp` -- the accessor methods named on a property.
(setget
  set: (setter) @accessor.name)

(setget
  get: (getter) @accessor.name)

; Any type written in an annotation position: `var x: Enemy`, `-> Enemy`,
; `func f(e: Enemy)`.
(type
  (identifier) @type.reference)

; ----------------------------------------------------------------------- calls

; `move(1)` -- a free call with a named callee.
(call
  .
  (identifier) @call.function.name)

; `sprite.play("run")` -- a method call on a receiver.
(attribute_call
  .
  (identifier) @call.method.name)

; `.ready()` / `super.ready()` -- a call into the base class.
(base_call
  .
  (identifier) @call.method.name)
