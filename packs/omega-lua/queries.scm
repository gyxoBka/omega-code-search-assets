; --- call_targets ---

(function_call
  name: (_) @call.target) @call.expression

; --- declaration_category_field ---

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---

; --- dsl_string_declarations ---

; Framework-neutral Lua DSL calls carrying an authored literal string.
(function_call
  name: (identifier) @lua.dsl.keyword
  arguments: (arguments
    (string) @lua.dsl.literal)) @lua.dsl.string_call_context

; Framework-neutral action/table declaration: function { trigger = "literal", ... }
((function_call
  name: (identifier) @lua.action.keyword
  arguments: (arguments
    (table_constructor
      (field
        name: (identifier) @_trigger_key
        value: (string) @lua.action.trigger)))) @lua.action.context
(#eq? @_trigger_key "trigger"))
[(chunk) (do_statement) (while_statement) (repeat_statement) (if_statement) (for_statement) (function_declaration) (function_definition)] @local.scope
(assignment_statement (variable_list (identifier) @local.definition.var))
(assignment_statement (variable_list (dot_index_expression . (_) @local.definition.associated (identifier) @local.definition.var)))

(for_generic_clause (variable_list (identifier) @local.definition.var))
(for_numeric_clause name: (identifier) @local.definition.var)
(parameters (identifier) @local.definition.parameter @variable.parameter)
(identifier) @local.reference @variable

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/lua/locals.scm
; sha256=826bec7f13e70d25dc78ac06bd4bd67e89a2011ebd1dc6b8442cf67c2bd2290b

; Scopes

; Definitions

; References

; --- named_scope_owners ---

(function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=ac7dfa89d16ba817c3681aa47c22bdb4441a78a89ed827a757efa755992de67f
; source_name=lua

; ----- resolved nvim highlights source: lua sha256=ac7dfa89d16ba817c3681aa47c22bdb4441a78a89ed827a757efa755992de67f -----
; Keywords
"return" @keyword.return

[
  "goto"
  "in"
  "local"
] @keyword

; Operators

"=" @operator

[
  "and"
  "not"
  "or"
] @keyword.operator

; Punctuations
[
  ";"
  ":"
  "::"
  ","
  "."
] @punctuation.delimiter

; Brackets
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

; Variables

((identifier) @constant.builtin
  (#eq? @constant.builtin "_VERSION"))

((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))

((identifier) @module.builtin
  (#any-of? @module.builtin "_G" "debug" "io" "jit" "math" "os" "package" "string" "table" "utf8"))

((identifier) @keyword.coroutine
  (#eq? @keyword.coroutine "coroutine"))

(variable_list
  (attribute
    "<" @punctuation.bracket
    (identifier) @attribute
    ">" @punctuation.bracket))

; Labels
(label_statement
  (identifier) @label)

(goto_statement
  (identifier) @label)

; Constants
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z_0-9]*$"))

(nil) @constant.builtin

[
  (false)
  (true)
] @boolean

; Tables
(field
  name: (identifier) @property)

(dot_index_expression
  field: (identifier) @variable.member)

(table_constructor
  [
    "{"
    "}"
  ] @constructor)

; Functions

(vararg_expression) @variable.parameter.builtin
(function_declaration name: [(identifier) @function @name (dot_index_expression field: (identifier) @function @name)]) @definition.function
(function_declaration name: (method_index_expression method: (identifier) @function.method @name)) @definition.method
(assignment_statement (variable_list . name: [(identifier) @function @name (dot_index_expression field: (identifier) @function @name)]) (expression_list . value: (function_definition))) @definition.function
(table_constructor (field name: (identifier) @function @name value: (function_definition))) @definition.function
(function_call name: [(identifier) @function.call @name (dot_index_expression field: (identifier) @function.call @name) (method_index_expression method: (identifier) @function.method.call @name)]) @reference.call

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
    ; built-in functions in Lua 5.1
    "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs" "load" "loadfile"
    "loadstring" "module" "next" "pairs" "pcall" "print" "rawequal" "rawget" "rawlen" "rawset"
    "require" "select" "setfenv" "setmetatable" "tonumber" "tostring" "type" "unpack" "xpcall"
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc" "__idiv"
    "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex" "__pairs"
    "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm"))

; Others
(comment) @comment @spell

((comment) @comment.documentation
  (#match? @comment.documentation "^[-][-][-]"))

((comment) @comment.documentation
  (#match? @comment.documentation "^[-][-](\\s?)@"))

(hash_bang_line) @keyword.directive

(number) @number

(string) @string

(escape_sequence) @string.escape

; string.match("123", "%d+")
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "find" "match" "gmatch" "gsub"))
  arguments: (arguments
    .
    (_)
    .
    (string
      content: (string_content) @string.regexp)))

;("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "find" "match" "gmatch" "gsub"))
  arguments: (arguments
    .
    (string
      content: (string_content) @string.regexp)))

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=a2ee92c2f00f39ebeeb1d0cc06302dba58c4f1dda77a2f0c9e5d7d7beab0b1ff
; source_name=lua

; ----- resolved nvim injections source: lua sha256=a2ee92c2f00f39ebeeb1d0cc06302dba58c4f1dda77a2f0c9e5d7d7beab0b1ff -----
((function_call
  name: [
    (identifier) @_cdef_identifier
    (_
      _
      (identifier) @_cdef_identifier)
  ]
  arguments: (arguments
    (string
      content: _ @injection.content)))
  (#set! injection.language "c")
  (#eq? @_cdef_identifier "cdef"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments
    (string
      content: _ @injection.content)))
  (#set! injection.language "vim")
  (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec2"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments
    (string
      content: _ @injection.content) .))
  (#set! injection.language "query")
  (#any-of? @_vimcmd_identifier "vim.treesitter.query.set" "vim.treesitter.query.parse"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments
    .
    (_)
    .
    (string
      content: (_) @_method)
    .
    (string
      content: (_) @injection.content)))
  (#any-of? @_vimcmd_identifier "vim.rpcrequest" "vim.rpcnotify")
  (#eq? @_method "nvim_exec_lua")
  (#set! injection.language "lua"))

; exec_lua [[ ... ]] in functionaltests
((function_call
  name: (identifier) @_function
  arguments: (arguments
    (string
      content: (string_content) @injection.content)))
  (#eq? @_function "exec_lua")
  (#set! injection.language "lua"))

; vim.api.nvim_create_autocmd("FileType", { command = "injected here" })
(function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments
    .
    (_)
    .
    (table_constructor
      (field
        name: (identifier) @_command
        value: (string
          content: (_) @injection.content))) .)
  ; limit so only 2-argument functions gets matched before pred handle
  (#eq? @_vimcmd_identifier "vim.api.nvim_create_autocmd")
  (#eq? @_command "command")
  (#set! injection.language "vim"))

(function_call
  name: (_) @_user_cmd
  arguments: (arguments
    .
    (_)
    .
    (string
      content: (_) @injection.content)
    .
    (_) .)
  (#eq? @_user_cmd "vim.api.nvim_create_user_command")
  (#set! injection.language "vim"))

(function_call
  name: (_) @_user_cmd
  arguments: (arguments
    .
    (_)
    .
    (_)
    .
    (string
      content: (_) @injection.content)
    .
    (_) .)
  ; Limiting predicate handling to only functions with 4 arguments
  (#eq? @_user_cmd "vim.api.nvim_buf_create_user_command")
  (#set! injection.language "vim"))

; rhs highlighting for vim.keymap.set/vim.api.nvim_set_keymap/vim.api.nvim_buf_set_keymap
; (function_call
;   name: (_) @_map
;   arguments:
;     (arguments
;       . (_)
;       . (_)
;       .
;       (string
;         content: (_) @injection.content))
;   (#any-of? @_map "vim.api.nvim_set_keymap" "vim.keymap.set")
;   (#set! injection.language "vim"))
;
; (function_call
;   name: (_) @_map
;   arguments:
;     (arguments
;       . (_)
;       . (_)
;       . (_)
;       .
;       (string
;         content: (_) @injection.content)
;       . (_) .)
;   (#eq? @_map "vim.api.nvim_buf_set_keymap")
;   (#set! injection.language "vim"))
; highlight string as query if starts with `;; query`
(string
  content: _ @injection.content
  (#match? @injection.content "^\\s*;+\\s?query")
  (#set! injection.language "query"))

; string.match("123", "%d+")

;("123"):match("%d+")

; string.format("pi = %.2f", 3.14159)

; ("pi = %.2f"):format(3.14159)

; vim.filetype.add({ pattern = { ["some lua pattern here"] = "filetype" } })

((function_declaration
  name: (identifier) @local.definition.function)
  (#set! definition.function.scope "parent"))

((function_declaration
  name: (dot_index_expression
    .
    (_) @local.definition.associated
    (identifier) @local.definition.function))
  (#set! definition.method.scope "parent"))

((function_declaration
  name: (method_index_expression
    .
    (_) @local.definition.associated
    (identifier) @local.definition.method))
  (#set! definition.method.scope "parent"))

; --- ownership_parameters ---

(function_declaration
  name: (_) @owner.name
  parameters: (parameters) @owned.parameters) @owner.span

; --- signature_parameters ---

(function_declaration
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- static_delta ---

((function_call
  name: (identifier) @import.api
  (arguments (string) @import.path)) @import.require
  (#eq? @import.api "require"))

; --- three_segment_call_context ---

(function_call
  name: (dot_index_expression
    table: (dot_index_expression
      table: (identifier) @lua.three_call.root
      field: (identifier) @lua.three_call.namespace)
    field: (identifier) @lua.three_call.member)) @lua.three_call.context
