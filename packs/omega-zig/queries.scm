; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

; --- calls ---

; Omega static call facts for Zig.

; --- completeness_imports_5 ---

(using_namespace_declaration) @import.expression @zig.usingnamespace

; --- completeness_types_high_confidence ---

(enum_declaration) @type.expression
(struct_declaration) @type.expression
(union_declaration) @type.expression

; --- declaration_category_field ---

(container_field
  name: (_) @definition.category.field.name
) @definition.category.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(function_signature
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---

; --- external_highlights ---

; OMEGA PINNED EXTERNAL HIGHLIGHTS — SYNTAX-ROLE EVIDENCE ONLY
; sha256=cbff0fe14e8aeffd64b146ac68fd797c1e38cd66f43a1e3273db8f4b4d753876

; Variables
(identifier) @variable @local.reference

; Parameters
(parameter
  name: (identifier) @variable.parameter @local.definition.parameter)

(payload
  (identifier) @variable.parameter @local.definition.var)

; Types
(parameter
  type: (identifier) @type)

((identifier) @type
  (#match? @type "^[A-Z_][a-zA-Z0-9_]*"))

(variable_declaration
  (identifier) @type
  "="
  [
    (struct_declaration)
    (enum_declaration)
    (union_declaration)
    (opaque_declaration)
  ])

[
  (builtin_type)
  "anyframe"
] @type.builtin

; Constants
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z_0-9]+$"))

[
  "null"
  "unreachable"
  "undefined"
] @constant.builtin

(field_expression
  .
  member: (identifier) @constant)

(enum_declaration
  (container_field
    type: (identifier) @constant))

; Labels
(block_label
  (identifier) @label @local.definition)

(break_label
  (identifier) @label @local.reference)

; Fields
(field_initializer
  .
  (identifier) @variable.member)

(field_expression
  (_)
  member: (identifier) @variable.member)

(container_field
  name: (identifier) @variable.member @local.definition.field)

(initializer_list
  (assignment_expression
    left: (field_expression
      .
      member: (identifier) @variable.member)))

; Functions
(builtin_identifier) @function.builtin

(call_expression
  function: (identifier) @function.call)

(call_expression
  function: (field_expression
    member: (identifier) @function.call))

(function_declaration
  name: (identifier) @function @local.definition.function)

; Modules
(variable_declaration
  (identifier) @module
  (builtin_function
    (builtin_identifier) @keyword.import
    (#any-of? @keyword.import "@import" "@cImport")))

; Builtins
[
  "c"
  "..."
] @variable.builtin

((identifier) @variable.builtin
  (#eq? @variable.builtin "_"))

(calling_convention
  (identifier) @variable.builtin)

; Keywords
[
  "asm"
  "defer"
  "errdefer"
  "test"
  "error"
  "const"
  "var"
] @keyword

[
  "struct"
  "union"
  "enum"
  "opaque"
] @keyword.type

[
  "async"
  "await"
  "suspend"
  "nosuspend"
  "resume"
] @keyword.coroutine

"fn" @keyword.function

[
  "and"
  "or"
  "orelse"
] @keyword.operator

"return" @keyword.return

[
  "if"
  "else"
  "switch"
] @keyword.conditional

[
  "for"
  "while"
  "break"
  "continue"
] @keyword.repeat

[
  "usingnamespace"
  "export"
] @keyword.import

[
  "try"
  "catch"
] @keyword.exception

[
  "volatile"
  "allowzero"
  "noalias"
  "addrspace"
  "align"
  "callconv"
  "linksection"
  "pub"
  "inline"
  "noinline"
  "extern"
  "comptime"
  "packed"
  "threadlocal"
] @keyword.modifier

; Operator
[
  "="
  "*="
  "*%="
  "*|="
  "/="
  "%="
  "+="
  "+%="
  "+|="
  "-="
  "-%="
  "-|="
  "<<="
  "<<|="
  ">>="
  "&="
  "^="
  "|="
  "!"
  "~"
  "-"
  "-%"
  "&"
  "=="
  "!="
  ">"
  ">="
  "<="
  "<"
  "^"
  "|"
  "<<"
  ">>"
  "<<|"
  "+"
  "++"
  "+%"
  "+|"
  "-|"
  "*"
  "/"
  "%"
  "**"
  "*%"
  "*|"
  "||"
  ".*"
  ".?"
  "?"
  ".."
] @operator

; Literals
(character) @character

([
  (string)
  (multiline_string)
] @string
  (#set! "priority" 95))

(integer) @number

(float) @number.float

(boolean) @boolean

(escape_sequence) @string.escape

; Punctuation

[
  ";"
  "."
  ","
  ":"
  "=>"
  "->"
] @punctuation.delimiter

(payload
  "|" @punctuation.bracket)

; Comments
(comment) @comment @spell

((comment) @comment.documentation
  (#match? @comment.documentation "^//!"))

; --- external_injections ---

; OMEGA PINNED EXTERNAL INJECTIONS — BOUNDED CANDIDATE EVIDENCE ONLY
; sha256=6c68bd360ae39e7e04e64ca647d925a0eae1dc9ce98de6088b8af34956f5c6a0

((comment) @injection.content
  (#set! injection.language "comment"))

((asm_output_item [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))
((asm_input_item [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))
((asm_clobbers [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))

; --- external_locals ---

; OMEGA EXTERNAL LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim legacy immutable snapshot
; sha256=a2d345afc59d9a9b514984f9101030bfb774631f2e4ae2ee4ace83dbb3171be5

; Definitions

(variable_declaration
  (identifier) @local.definition.var)

(variable_declaration
  (identifier) @local.definition.type
  (enum_declaration))

(container_field
  type: (identifier) @local.definition.field)

(enum_declaration
  (function_declaration
    name: (identifier) @local.definition.method))

(variable_declaration
  (identifier) @local.definition.type
  (struct_declaration))

(struct_declaration
  (function_declaration
    name: (identifier) @local.definition.method))

(variable_declaration
  (identifier) @local.definition.type
  (union_declaration))

(union_declaration
  (function_declaration
    name: (identifier) @local.definition.method))

; References

(parameter
  type: (identifier) @local.reference
  (#set! reference.kind "type"))

(pointer_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(nullable_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(struct_initializer
  (identifier) @local.reference
  (#set! reference.kind "type"))

(array_type
  (_)
  (identifier) @local.reference
  (#set! reference.kind "type"))

(slice_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(field_expression
  member: (identifier) @local.reference
  (#set! reference.kind "field"))

(call_expression
  function: (field_expression
    member: (identifier) @local.reference
    (#set! reference.kind "function")))

[
  (for_statement)
  (if_statement)
  (while_statement)
  (function_declaration)
  (block)
  (source_file)
  (enum_declaration)
  (struct_declaration)
] @local.scope

; --- member_access_hints ---

(field_expression
  object: (_) @reference.receiver @reference.qualified_chain.base
  member: (_) @reference.member @reference.qualified_chain.leaf) @reference.member_expression @reference.qualified_chain.span

; --- named_scope_owners ---

(function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=cbff0fe14e8aeffd64b146ac68fd797c1e38cd66f43a1e3273db8f4b4d753876
; source_name=zig

; ----- resolved nvim highlights source: zig sha256=cbff0fe14e8aeffd64b146ac68fd797c1e38cd66f43a1e3273db8f4b4d753876 -----
; Variables

; Parameters

; Types

((identifier) @type
  (#match? @type "^[A-Z_][a-zA-Z0-9_]*"))

; Constants
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z_0-9]+$"))

; Labels

; Fields

; Functions

; Modules
(variable_declaration
  (identifier) @module
  (builtin_function
    (builtin_identifier) @keyword.import
    (#any-of? @keyword.import "@import" "@cImport")))

; Builtins

((identifier) @variable.builtin
  (#eq? @variable.builtin "_"))

; Keywords

; Operator

; Literals

([
  (string)
  (multiline_string)
] @string
  (#set! "priority" 95))

; Punctuation

; Comments

((comment) @comment.documentation
  (#match? @comment.documentation "^//!"))

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=6c68bd360ae39e7e04e64ca647d925a0eae1dc9ce98de6088b8af34956f5c6a0
; source_name=zig

; ----- resolved nvim injections source: zig sha256=6c68bd360ae39e7e04e64ca647d925a0eae1dc9ce98de6088b8af34956f5c6a0 -----
((comment) @injection.content
  (#set! injection.language "comment"))

((asm_output_item [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))
((asm_input_item [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))
((asm_clobbers [(string) (multiline_string)] @injection.content)
  (#set! injection.language "asm"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=a2d345afc59d9a9b514984f9101030bfb774631f2e4ae2ee4ace83dbb3171be5
; resolved_query_sha256=a57f0e039dbda098104942282dc352e76f9df86036af51a60b91b135039ab75b
; parser_revision=6479aa13f32f701c383083d8b28360ebd682fb7d
; source_name=zig
; direct_inherits=
; resolved_sources=zig

; ----- resolved nvim locals source: zig sha256=a2d345afc59d9a9b514984f9101030bfb774631f2e4ae2ee4ace83dbb3171be5 -----
; Definitions

; References

(parameter
  type: (identifier) @local.reference
  (#set! reference.kind "type"))

(pointer_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(nullable_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(struct_initializer
  (identifier) @local.reference
  (#set! reference.kind "type"))

(array_type
  (_)
  (identifier) @local.reference
  (#set! reference.kind "type"))

(slice_type
  (identifier) @local.reference
  (#set! reference.kind "type"))

(field_expression
  member: (identifier) @local.reference
  (#set! reference.kind "field"))

(call_expression
  function: (field_expression
    member: (identifier) @local.reference
    (#set! reference.kind "function")))

; --- qualified_chain_hints ---

; --- signature_return_type ---

(function_declaration
  name: (_) @definition.signature.name
  type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_signature
  name: (_) @definition.signature.name
  type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- semantic_closure_v3_146_batch2 ---

(test_declaration) @zig.test
(error_set_declaration (identifier) @zig.error_set.name @zig.error.member) @zig.error_set @zig.error.member.owner
(comptime_declaration) @zig.comptime.declaration
(comptime_statement) @zig.comptime.statement

; --- semantic_closure_v3_146_batch4 ---

(test_declaration
  [(identifier) (string)] @zig.test.name
  (block) @zig.test.body) @zig.test.named

(using_namespace_declaration
  (expression) @zig.usingnamespace.target) @zig.usingnamespace.typed

(comptime_expression) @zig.comptime.expression
(comptime_type_expression) @zig.comptime.type_expression

