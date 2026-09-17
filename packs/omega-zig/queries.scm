; omega-zig -- what a Zig file declares, what it pulls in, what it calls and
; what it names. One pattern per construct; the templates over a pattern say
; the several things one match can answer.
;
; Zig has one node, `variable_declaration`, for a type declaration, a module
; alias, a container constant and a local. The patterns below separate them by
; the shape of the value and by the container they sit in, which is the only
; place the grammar records the difference.

; --- a function ---------------------------------------------------------
;
; The declaration, its visibility, its linkage, its signature and its body are
; one match. A prototype without a body (`extern fn`) is the same node with
; `body` absent, so the body capture is optional and the region template is
; skipped for it.

(function_declaration
  "pub"? @function.visibility
  ["extern" "export" "inline" "noinline"]? @function.modifier
  name: (identifier) @function.name
  (parameters) @function.parameters
  type: (_) @function.return_type
  body: (block)? @function.body) @function

; --- a container type ---------------------------------------------------
;
; `pub const Point = struct { ... };` is how Zig names a type. The value node
; is the only thing that says which sort of type it is. The trailing anchor
; makes the container the declaration's last named child, so one declaration is
; one match.

(variable_declaration
  "pub"? @struct.visibility
  .
  (identifier) @struct.name @container.name
  (struct_declaration) @container.body .) @struct

(variable_declaration
  "pub"? @enum.visibility
  .
  (identifier) @enum.name @container.name
  (enum_declaration) @container.body .) @enum

(variable_declaration
  "pub"? @union.visibility
  .
  (identifier) @union.name @container.name
  (union_declaration) @container.body .) @union

(variable_declaration
  "pub"? @opaque.visibility
  .
  (identifier) @opaque.name @container.name
  (opaque_declaration) @container.body .) @opaque

(variable_declaration
  "pub"? @error_set.visibility
  .
  (identifier) @error_set.name
  (error_set_declaration) .) @error_set

; Each member of an error set is the value an `error.X` mention resolves to.

(error_set_declaration
  (identifier) @error_value)

; --- a member of a container -------------------------------------------
;
; A struct or union field carries a type; a plain enum member does not. `!type`
; is what tells them apart, so neither pattern sees the other's nodes.

; `mode: enum { fast, small },` -- a field's type may be an inline declaration,
; and `type: (_)` stored that whole body as the carried type. Only the forms
; that name a type are carried.

(container_field
  name: (identifier) @field.name
  type: [(identifier)
         (builtin_type)
         (field_expression)
         (call_expression)
         (pointer_type)
         (nullable_type)
         (slice_type)
         (array_type)
         (error_union_type)
         (error_type)
         (anyframe_type)]? @field.type) @field

(container_field
  name: (identifier) @enum_member.name
  !type) @enum_member

; --- a named value declared by a container ------------------------------
;
; Anchored to the five containers a Zig declaration may sit in, so that the
; same node inside a function body is a local and is not declared: a repository
; of Zig otherwise declares `self`, `allocator` and `buf` thousands of times.
; tree-sitter cannot alternate the parent of a pattern that has children, so
; the five are written out.
;
; The value alternation excludes the container declarations and `@import`
; above, which have their own patterns and would otherwise be declared twice.

(source_file
  (variable_declaration
    "pub"? @value.visibility
    ["const" "var"] @value.mutability
    .
    (identifier) @value.name
    [(integer) (float) (boolean) (character) (string) (multiline_string)
     (identifier) (field_expression) (call_expression) (unary_expression)
     (binary_expression) (struct_initializer) (anonymous_struct_initializer)
     (error_type) (try_expression) (if_expression) (switch_expression)
     (labeled_type_expression) (comptime_expression) (index_expression)
     (parenthesized_expression) (block) (builtin_type) (pointer_type)
     (slice_type) (array_type) (nullable_type) (error_union_type)
     (function_signature) (anyframe_type)] .) @value)

(struct_declaration
  (variable_declaration
    "pub"? @value.visibility
    ["const" "var"] @value.mutability
    .
    (identifier) @value.name
    [(integer) (float) (boolean) (character) (string) (multiline_string)
     (identifier) (field_expression) (call_expression) (unary_expression)
     (binary_expression) (struct_initializer) (anonymous_struct_initializer)
     (error_type) (try_expression) (if_expression) (switch_expression)
     (labeled_type_expression) (comptime_expression) (index_expression)
     (parenthesized_expression) (block) (builtin_type) (pointer_type)
     (slice_type) (array_type) (nullable_type) (error_union_type)
     (function_signature) (anyframe_type)] .) @value)

(enum_declaration
  (variable_declaration
    "pub"? @value.visibility
    ["const" "var"] @value.mutability
    .
    (identifier) @value.name
    [(integer) (float) (boolean) (character) (string) (multiline_string)
     (identifier) (field_expression) (call_expression) (unary_expression)
     (binary_expression) (struct_initializer) (anonymous_struct_initializer)
     (error_type) (try_expression) (if_expression) (switch_expression)
     (labeled_type_expression) (comptime_expression) (index_expression)
     (parenthesized_expression) (block) (builtin_type) (pointer_type)
     (slice_type) (array_type) (nullable_type) (error_union_type)
     (function_signature) (anyframe_type)] .) @value)

(union_declaration
  (variable_declaration
    "pub"? @value.visibility
    ["const" "var"] @value.mutability
    .
    (identifier) @value.name
    [(integer) (float) (boolean) (character) (string) (multiline_string)
     (identifier) (field_expression) (call_expression) (unary_expression)
     (binary_expression) (struct_initializer) (anonymous_struct_initializer)
     (error_type) (try_expression) (if_expression) (switch_expression)
     (labeled_type_expression) (comptime_expression) (index_expression)
     (parenthesized_expression) (block) (builtin_type) (pointer_type)
     (slice_type) (array_type) (nullable_type) (error_union_type)
     (function_signature) (anyframe_type)] .) @value)

(opaque_declaration
  (variable_declaration
    "pub"? @value.visibility
    ["const" "var"] @value.mutability
    .
    (identifier) @value.name
    [(integer) (float) (boolean) (character) (string) (multiline_string)
     (identifier) (field_expression) (call_expression) (unary_expression)
     (binary_expression) (struct_initializer) (anonymous_struct_initializer)
     (error_type) (try_expression) (if_expression) (switch_expression)
     (labeled_type_expression) (comptime_expression) (index_expression)
     (parenthesized_expression) (block) (builtin_type) (pointer_type)
     (slice_type) (array_type) (nullable_type) (error_union_type)
     (function_signature) (anyframe_type)] .) @value)

; --- what the file pulls in --------------------------------------------

((builtin_function
  (builtin_identifier) @import.builtin
  (arguments (string) @import.path)) @import
 (#eq? @import.builtin "@import"))

; The name an import is bound to is the namespace every `std.mem.x` in the file
; resolves against, so it is declared, not only recorded as a binding.

((variable_declaration
  "pub"? @import.alias.visibility
  .
  (identifier) @import.alias.name
  (builtin_function (builtin_identifier) @import.alias.builtin) .) @import.alias
 (#eq? @import.alias.builtin "@import"))

((builtin_function
  (builtin_identifier) @c_include.builtin
  (arguments (string) @c_include.path)) @c_include
 (#eq? @c_include.builtin "@cInclude"))

((builtin_function
  (builtin_identifier) @embed.builtin
  (arguments (string) @embed.path)) @embed
 (#eq? @embed.builtin "@embedFile"))

(using_namespace_declaration
  (identifier) @using.name) @using

(using_namespace_declaration
  (field_expression member: (identifier) @using.qualified.name)) @using.qualified

; --- a test -------------------------------------------------------------

; A test's name is optional: `test { _ = @import("foo"); }` is idiomatic and
; appears throughout std. It is matched so the block is still a region, but it
; declares no test, which is why the coverage family below is partial.

(test_declaration
  [(string) (identifier)]? @test.name
  (block) @test.body) @test

; --- calls --------------------------------------------------------------

(call_expression
  function: (identifier) @call.name) @call

(call_expression
  function: (field_expression
    member: (identifier) @call.method.name)) @call.method

; --- mentions -----------------------------------------------------------
;
; The leaf of `a.b` is not stated on its own: tree-sitter-zig spells a method
; callee as a `field_expression` too and a pattern cannot see its parent, so
; every member mention would be a call reported as a field. The base of the
; chain is unambiguous and is what resolves to an import alias or a container.

(field_expression
  object: (identifier) @reference.qualifier)

(error_type
  (identifier) @reference.error_value)

; `.x = v` inside an initializer: a field_expression with no object, so it is
; never a method callee.

(initializer_list
  (assignment_expression
    left: (field_expression
      .
      member: (identifier) @reference.field)))

; A type is named by an identifier wherever the grammar says a type goes.

(parameter type: (identifier) @type.reference)
(pointer_type (identifier) @type.reference)
(slice_type (identifier) @type.reference)
(nullable_type (identifier) @type.reference)
(array_type (_) (identifier) @type.reference)
(struct_initializer (identifier) @type.reference)

; --- labels -------------------------------------------------------------

(block_label (identifier) @label.name) @label

(break_label (identifier) @label.reference.name) @label.reference
