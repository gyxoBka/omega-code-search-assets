; --- call_targets ---

(function_call
  name: (_) @call.target) @call.expression

; --- declaration_category_field ---

(field
  name: (_) @definition.category.name
) @definition.category.owner

; --- declaration_category_function ---

(function_call
  name: (_) @definition.category.name
) @definition.category.owner

(function_declaration
  name: (_) @definition.category.name
) @definition.category.owner

; --- definition_identity_hints ---

(function_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

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

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=lua kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/lua/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Scopes
[
  (chunk)
  (do_statement)
  (while_statement)
  (repeat_statement)
  (if_statement)
  (for_statement)
  (function_declaration)
  (function_definition)
] @local.scope

; Definitions
(assignment_statement
  (variable_list
    (identifier) @local.definition.var))

(assignment_statement
  (variable_list
    (dot_index_expression
      .
      (_) @local.definition.associated
      (identifier) @local.definition.var)))

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

(for_generic_clause
  (variable_list
    (identifier) @local.definition.var))

(for_numeric_clause
  name: (identifier) @local.definition.var)

(parameters
  (identifier) @local.definition.parameter)

; References
(identifier) @local.reference

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/lua/locals.scm
; sha256=826bec7f13e70d25dc78ac06bd4bd67e89a2011ebd1dc6b8442cf67c2bd2290b

; Scopes
[
  (chunk)
  (do_statement)
  (while_statement)
  (repeat_statement)
  (if_statement)
  (for_statement)
  (function_declaration)
  (function_definition)
] @local.scope

; Definitions
(assignment_statement
  (variable_list
    (identifier) @local.definition.var))

(assignment_statement
  (variable_list
    (dot_index_expression
      .
      (_) @local.definition.associated
      (identifier) @local.definition.var)))

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

(for_generic_clause
  (variable_list
    (identifier) @local.definition.var))

(for_numeric_clause
  name: (identifier) @local.definition.var)

(parameters
  (identifier) @local.definition.parameter)

; References
(identifier) @local.reference

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

(break_statement) @keyword

(do_statement
  [
    "do"
    "end"
  ] @keyword)

(while_statement
  [
    "while"
    "do"
    "end"
  ] @keyword.repeat)

(repeat_statement
  [
    "repeat"
    "until"
  ] @keyword.repeat)

(if_statement
  [
    "if"
    "elseif"
    "else"
    "then"
    "end"
  ] @keyword.conditional)

(elseif_statement
  [
    "elseif"
    "then"
    "end"
  ] @keyword.conditional)

(else_statement
  [
    "else"
    "end"
  ] @keyword.conditional)

(for_statement
  [
    "for"
    "do"
    "end"
  ] @keyword.repeat)

(function_declaration
  [
    "function"
    "end"
  ] @keyword.function)

(function_definition
  [
    "function"
    "end"
  ] @keyword.function)

; Operators
(binary_expression
  operator: _ @operator)

(unary_expression
  operator: _ @operator)

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
(identifier) @variable

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
  (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

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
(parameters
  (identifier) @variable.parameter)

(vararg_expression) @variable.parameter.builtin

(function_declaration
  name: [
    (identifier) @function
    (dot_index_expression
      field: (identifier) @function)
  ])

(function_declaration
  name: (method_index_expression
    method: (identifier) @function.method))

(assignment_statement
  (variable_list
    .
    name: [
      (identifier) @function
      (dot_index_expression
        field: (identifier) @function)
    ])
  (expression_list
    .
    value: (function_definition)))

(table_constructor
  (field
    name: (identifier) @function
    value: (function_definition)))

(function_call
  name: [
    (identifier) @function.call
    (dot_index_expression
      field: (identifier) @function.call)
    (method_index_expression
      method: (identifier) @function.method.call)
  ])

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
  (#lua-match? @comment.documentation "^[-][-][-]"))

((comment) @comment.documentation
  (#lua-match? @comment.documentation "^[-][-](%s?)@"))

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
  (#lua-match? @injection.content "^%s*;+%s?query")
  (#set! injection.language "query"))

(comment
  content: (_) @injection.content
  (#lua-match? @injection.content "^[-][%s]*[@|]")
  (#set! injection.language "luadoc")
  (#offset! @injection.content 0 1 0 0))

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
      content: (string_content) @injection.content
      (#set! injection.language "luap")
      (#set! injection.include-children))))

;("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "find" "match" "gmatch" "gsub"))
  arguments: (arguments
    .
    (string
      content: (string_content) @injection.content
      (#set! injection.language "luap")
      (#set! injection.include-children))))

; string.format("pi = %.2f", 3.14159)
((function_call
  (dot_index_expression
    field: (identifier) @_method)
  arguments: (arguments
    .
    (string
      (string_content) @injection.content)))
  (#eq? @_method "format")
  (#set! injection.language "printf"))

; ("pi = %.2f"):format(3.14159)
((function_call
  (method_index_expression
    table: (_
      (string
        (string_content) @injection.content))
    method: (identifier) @_method))
  (#eq? @_method "format")
  (#set! injection.language "printf"))

(comment
  content: (_) @injection.content
  (#set! injection.language "comment"))

; vim.filetype.add({ pattern = { ["some lua pattern here"] = "filetype" } })
((function_call
  name: (_) @_filetypeadd_identifier
  arguments: (arguments
    (table_constructor
      (field
        name: (_) @_pattern_key
        value: (table_constructor
          (field
            name: (string
              content: _ @injection.content)))))))
  (#set! injection.language "luap")
  (#eq? @_filetypeadd_identifier "vim.filetype.add")
  (#eq? @_pattern_key "pattern"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=826bec7f13e70d25dc78ac06bd4bd67e89a2011ebd1dc6b8442cf67c2bd2290b
; resolved_query_sha256=70020b86d8ae33ffedd0cdca69a54ff0856a0f2595173eaff6ef535f3738f053
; parser_revision=10fe0054734eec83049514ea2e718b2a56acd0c9
; source_name=lua
; direct_inherits=
; resolved_sources=lua

; ----- resolved nvim locals source: lua sha256=826bec7f13e70d25dc78ac06bd4bd67e89a2011ebd1dc6b8442cf67c2bd2290b -----
; Scopes
[
  (chunk)
  (do_statement)
  (while_statement)
  (repeat_statement)
  (if_statement)
  (for_statement)
  (function_declaration)
  (function_definition)
] @local.scope

; Definitions
(assignment_statement
  (variable_list
    (identifier) @local.definition.var))

(assignment_statement
  (variable_list
    (dot_index_expression
      .
      (_) @local.definition.associated
      (identifier) @local.definition.var)))

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

(for_generic_clause
  (variable_list
    (identifier) @local.definition.var))

(for_numeric_clause
  name: (identifier) @local.definition.var)

(parameters
  (identifier) @local.definition.parameter)

; References
(identifier) @local.reference

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

[(table_constructor) (string) (number) (true) (false) (nil)] @data.literal

; --- three_segment_call_context ---

(function_call
  name: (dot_index_expression
    table: (dot_index_expression
      table: (identifier) @lua.three_call.root
      field: (identifier) @lua.three_call.namespace)
    field: (identifier) @lua.three_call.member)) @lua.three_call.context

; --- upstream_tags ---

(function_declaration
  name: [
    (identifier) @name
    (dot_index_expression
      field: (identifier) @name)
  ]) @definition.function

(function_declaration
  name: (method_index_expression
    method: (identifier) @name)) @definition.method

(assignment_statement
  (variable_list
    .
    name: [
      (identifier) @name
      (dot_index_expression
        field: (identifier) @name)
    ])
  (expression_list
    .
    value: (function_definition))) @definition.function

(table_constructor
  (field
    name: (identifier) @name
    value: (function_definition))) @definition.function

(function_call
  name: [
    (identifier) @name
    (dot_index_expression
      field: (identifier) @name)
    (method_index_expression
      method: (identifier) @name)
  ]) @reference.call
