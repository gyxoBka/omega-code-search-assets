; --- call_targets ---

(access_call
  target: (_) @call.target) @call.expression

(call
  target: (_) @call.target) @call.expression

; --- elixir_imported_function_literal_keyword_in_context ---

; Framework-neutral Elixir D1: module + imported module + direct def/defp
; whose returned call has a literal `in` source plus one keyword whose value
; is another literal `in` expression.  The Pack does not interpret call/keyword
; names (e.g. Ecto from/join); Framework overlays own that meaning.
((call
  target: (identifier) @_defmodule
  (arguments (alias) @elixir.literal_kw.module)
  (do_block
    (call
      target: (identifier) @_import
      (arguments (alias) @elixir.literal_kw.imported_module))
    (call
      target: (identifier) @_def
      (arguments
        (call target: (identifier) @elixir.literal_kw.function_name))
      (do_block
        (call
          target: (identifier) @elixir.literal_kw.call_name
          (arguments
            (binary_operator
              left: (identifier) @elixir.literal_kw.root_binding
              operator: "in"
              right: (string) @elixir.literal_kw.root_source)
            (keywords
              (pair
                key: (keyword) @elixir.literal_kw.keyword_key
                value: (binary_operator
                  left: (identifier) @elixir.literal_kw.keyword_binding
                  operator: "in"
                  right: (string) @elixir.literal_kw.keyword_source)))) @elixir.literal_kw.call)) @elixir.literal_kw.function)) @elixir.literal_kw.body)
(#eq? @_defmodule "defmodule")
(#eq? @_import "import")
(#any-of? @_def "def" "defp")
(#not-match? @elixir.literal_kw.root_source "#\\{")
(#not-match? @elixir.literal_kw.keyword_source "#\\{"))

; --- elixir_module_imported_function_call_context ---

; Framework-neutral Elixir module + import + function + direct returned call context.
((call
  target: (identifier) @_defmodule
  (arguments (alias) @elixir.imported_call.module)
  (do_block
    (call
      target: (identifier) @_import
      (arguments (alias) @elixir.imported_call.imported_module))
    (call
      target: (identifier) @_def
      (arguments
        (call target: (identifier) @elixir.imported_call.function_name))
      (do_block
        (call target: (identifier) @elixir.imported_call.call_name) @elixir.imported_call.call)) @elixir.imported_call.function) @elixir.imported_call.body)
(#eq? @_defmodule "defmodule")
(#eq? @_import "import")
(#any-of? @_def "def" "defp"))

; --- elixir_module_used_call_context ---

((call
  target: (identifier) @_defmodule
  (arguments (alias) @elixir.ctx.module)
  (do_block
    (call
      target: (identifier) @_use
      (arguments (alias) @elixir.ctx.used_module))
    (call
      target: (identifier) @elixir.ctx.call_name) @elixir.ctx.call) @elixir.ctx.body)
(#eq? @_defmodule "defmodule")
(#eq? @_use "use"))

; --- elixir_module_used_function_context ---

; Framework-neutral Elixir module + use + function declaration context.
((call
  target: (identifier) @_defmodule
  (arguments (alias) @elixir.used_fn.module)
  (do_block
    (call
      target: (identifier) @_use
      (arguments (alias) @elixir.used_fn.used_module))
    (call
      target: (identifier) @_def
      (arguments
        (call target: (identifier) @elixir.used_fn.function_name))
      (do_block)?) @elixir.used_fn.function) @elixir.used_fn.body)
(#eq? @_defmodule "defmodule")
(#eq? @_use "use")
(#any-of? @_def "def" "defp"))

; --- elixir_module_used_string_call_context ---

((call
  target: (identifier) @_defmodule
  (arguments (alias) @elixir.ctx.module)
  (do_block
    (call
      target: (identifier) @_use
      (arguments (alias) @elixir.ctx.used_module))
    (call
      target: (identifier) @elixir.ctx.call_name
      (arguments
        (string (quoted_content) @elixir.ctx.label)) @elixir.ctx.arguments) @elixir.ctx.call) @elixir.ctx.body)
(#eq? @_defmodule "defmodule")
(#eq? @_use "use"))

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=elixir kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/elixir/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; References
(identifier) @local.reference @variable

(alias) @local.reference @module @name @reference.module

; Module Definitions

; Pattern Match Definitions
(binary_operator
  ; format-ignore
  left: 
    [
      (identifier) @local.definition.var
      (_ (identifier) @local.definition.var)
      (_ (_ (identifier) @local.definition.var))
      (_ (_ (_ (identifier) @local.definition.var)))
      (_ (_ (_ (_ (identifier) @local.definition.var))))
      (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))
      (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))
      (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))))
      (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))))
    ]
  operator: "=")

; Stab Clause Definitions
; format-ignore
(stab_clause
  left:
    [
     (arguments
      [
        (identifier) @local.definition.var
        (_ (identifier) @local.definition.var)
        (_ (_ (identifier) @local.definition.var))
        (_ (_ (_ (identifier) @local.definition.var)))
        (_ (_ (_ (_ (identifier) @local.definition.var))))
        (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))
        (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))
        (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))))
        (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))))
      ])

    (binary_operator
      left:
        (arguments
          ; format-ignore
          [
            (identifier) @local.definition.var
            (_ (identifier) @local.definition.var)
            (_ (_ (identifier) @local.definition.var))
            (_ (_ (_ (identifier) @local.definition.var)))
            (_ (_ (_ (_ (identifier) @local.definition.var))))
            (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))
            (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))
            (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var)))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.var))))))))))))))))))))
          ])
      operator: "when")
    ])

; Aliases
; format-ignore

; Local Function Definitions & Scopes
; format-ignore

; ExUnit Test Definitions & Scopes
; format-ignore

; Stab Clause Scopes
(stab_clause) @local.scope

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/elixir/locals.scm
; sha256=e5cf2d79b4872bec580e66be8ec4b5ab559efdbe2d0bcb633786ce8ffeb0e95b

; References

; Module Definitions
(call
  target: ((identifier) @_identifier
    (#eq? @_identifier "defmodule"))
  (arguments
    (alias) @local.definition.type))

; Pattern Match Definitions

; Stab Clause Definitions
; format-ignore

; Aliases
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#any-of? @_identifier "require" "alias" "use" "import"))
  (arguments
    [
      (alias) @local.definition.import
      (_ (alias) @local.definition.import)
      (_ (_ (alias) @local.definition.import))
      (_ (_ (_ (alias) @local.definition.import)))
      (_ (_ (_ (_ (alias) @local.definition.import))))
    ]))

; Local Function Definitions & Scopes
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#any-of? @_identifier "def" "defp" "defmacro" "defmacrop" "defguard" "defguardp" "defn" "defnp" "for"))
  (arguments
    [
      (identifier) @local.definition.function
      (binary_operator
        left: (identifier) @local.definition.function
        operator: "when")
      (binary_operator
        (identifier) @local.definition.parameter)
      (call
        target: (identifier) @local.definition.function
        (arguments
          [
            (identifier) @local.definition.parameter
            (_ (identifier) @local.definition.parameter)
            (_ (_ (identifier) @local.definition.parameter))
            (_ (_ (_ (identifier) @local.definition.parameter)))
            (_ (_ (_ (_ (identifier) @local.definition.parameter))))
            (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))
            (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))
            (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))))
          ]))
    ]?)
  (#set! definition.function.scope parent)(do_block)?) @local.scope

; ExUnit Test Definitions & Scopes
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#eq? @_identifier "test"))
  (arguments
    [
      (string)
      ((string)
        .
        ","
        .
        [
          (identifier) @local.definition.parameter
          (_ (identifier) @local.definition.parameter)
          (_ (_ (identifier) @local.definition.parameter))
          (_ (_ (_ (identifier) @local.definition.parameter)))
          (_ (_ (_ (_ (identifier) @local.definition.parameter))))
          (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))
          (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))
          (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))))
        ])
    ])
  (do_block)?) @local.scope

; Stab Clause Scopes

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=a5ba25c44d681d11af4d611a8e229463f91219ced15a3ca240a6c215df1f869a
; source_name=elixir

; ----- resolved nvim highlights source: elixir sha256=a5ba25c44d681d11af4d611a8e229463f91219ced15a3ca240a6c215df1f869a -----
; Punctuation
[
  ","
  ";"
] @punctuation.delimiter

[
  "("
  ")"
  "<<"
  ">>"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

"%" @punctuation.special

; Identifiers

; Unused Identifiers
((identifier) @comment
  (#match? @comment "^_"))

; Comments
(comment) @comment @spell

; Strings
(string) @string

; Modules

; Atoms & Keywords
[
  (atom)
  (quoted_atom)
  (keyword)
  (quoted_keyword)
] @string.special.symbol

; Interpolation
(interpolation
  [
    "#{"
    "}"
  ] @string.special)

; Escape sequences
(escape_sequence) @string.escape

; Integers
(integer) @number

; Floats
(float) @number.float

; Characters
[
  (char)
  (charlist)
] @character

; Booleans
(boolean) @boolean

; Nil
(nil) @constant.builtin

; Operators
(operator_identifier) @operator

(unary_operator
  operator: _ @operator)

(binary_operator
  operator: _ @operator)
(binary_operator operator: "|>" right: (identifier) @function @name) @reference.call

(dot
  operator: _ @operator)

(stab_clause
  operator: _ @operator)

; Local Function Calls
(call
  target: (identifier) @function.call)

; Remote Function Calls
(call
  target: (dot
    left: [
      (atom) @type
      (_)
    ]
    right: (identifier) @function.call)
  (arguments))

; Definition Function Calls
(call
  target: ((identifier) @keyword.function
    (#any-of? @keyword.function
      "def" "defdelegate" "defexception" "defguard" "defguardp" "defimpl" "defmacro" "defmacrop"
      "defmodule" "defn" "defnp" "defoverridable" "defp" "defprotocol" "defstruct"))
  (arguments
    [
      (call
        (identifier) @function)
      (identifier) @function
      (binary_operator
        left: (call
          target: (identifier) @function)
        operator: "when")
    ])?)

; Kernel Keywords & Special Forms
(call
  target: ((identifier) @keyword
    (#any-of? @keyword
      "alias" "case" "catch" "cond" "else" "for" "if" "import" "quote" "raise" "receive" "require"
      "reraise" "super" "throw" "try" "unless" "unquote" "unquote_splicing" "use" "with")))

; Special Constants
((identifier) @constant.builtin
  (#any-of? @constant.builtin "__CALLER__" "__DIR__" "__ENV__" "__MODULE__" "__STACKTRACE__"))

; Reserved Keywords
[
  "after"
  "catch"
  "do"
  "end"
  "fn"
  "rescue"
  "when"
  "else"
] @keyword

; Operator Keywords
[
  "and"
  "in"
  "not in"
  "not"
  "or"
] @keyword.operator

; Capture Operator
(unary_operator
  operator: "&"
  operand: [
    (integer) @operator
    (binary_operator
      left: [
        (call
          target: (dot
            left: (_)
            right: (identifier) @function))
        (identifier) @function
      ]
      operator: "/"
      right: (integer) @operator)
  ])

; Non-String Sigils
(sigil
  "~" @string.special
  (sigil_name) @string.special @_sigil_name
  quoted_start: _ @string.special
  quoted_end: _ @string.special
  ((sigil_modifiers) @string.special)?
  (#not-any-of? @_sigil_name "s" "S"))

; String Sigils
(sigil
  "~" @string
  (sigil_name) @string @_sigil_name
  quoted_start: _ @string
  (quoted_content) @string
  quoted_end: _ @string
  ((sigil_modifiers) @string)?
  (#any-of? @_sigil_name "s" "S"))

; Module attributes
(unary_operator
  operator: "@"
  operand: [
    (identifier)
    (call
      target: (identifier))
  ] @constant) @constant

; Documentation
(unary_operator
  operator: "@"
  operand: (call
    target: ((identifier) @_identifier
      (#any-of? @_identifier "moduledoc" "typedoc" "shortdoc" "doc")) @comment.documentation
    (arguments
      [
        (string)
        (boolean)
        (charlist)
        (sigil
          "~" @comment.documentation
          (sigil_name) @comment.documentation
          quoted_start: _ @comment.documentation
          (quoted_content) @comment.documentation
          quoted_end: _ @comment.documentation)
      ] @comment.documentation))) @comment.documentation

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=9e436fad887a835f04d5eae6376c791e3eecee0feb3bd3903ef7407cf60c25bb
; source_name=elixir

; ----- resolved nvim injections source: elixir sha256=9e436fad887a835f04d5eae6376c791e3eecee0feb3bd3903ef7407cf60c25bb -----
; Comments
((comment) @injection.content
  (#set! injection.language "comment"))

; Documentation
(unary_operator
  operator: "@"
  operand: (call
    target: ((identifier) @_identifier
      (#any-of? @_identifier "moduledoc" "typedoc" "shortdoc" "doc"))
    (arguments
      [
        (string
          (quoted_content) @injection.content)
        (sigil
          (quoted_content) @injection.content)
      ])
    (#set! injection.language "markdown")))

; HEEx
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#any-of? @_sigil_name "H" "LVN")
  (#set! injection.language "heex"))

; Surface
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#eq? @_sigil_name "F")
  (#set! injection.language "surface"))

; Zigler
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#any-of? @_sigil_name "E" "L")
  (#set! injection.language "eex"))

(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#any-of? @_sigil_name "z" "Z")
  (#set! injection.language "zig"))

; Regex
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#any-of? @_sigil_name "r" "R")
  (#set! injection.language "regex"))

; Json
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#any-of? @_sigil_name "j" "J")
  (#set! injection.language "json"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=e5cf2d79b4872bec580e66be8ec4b5ab559efdbe2d0bcb633786ce8ffeb0e95b
; resolved_query_sha256=0506c3a46fff8784096eafd7775f355a119270210a702ffa43405500619ddcd4
; parser_revision=7937d3b4d65fa574163cfa59394515d3c1cf16f4
; source_name=elixir
; direct_inherits=
; resolved_sources=elixir

; ----- resolved nvim locals source: elixir sha256=e5cf2d79b4872bec580e66be8ec4b5ab559efdbe2d0bcb633786ce8ffeb0e95b -----
; References

; Module Definitions
(call
  target: ((identifier) @_identifier
    (#eq? @_identifier "defmodule"))
  (arguments
    (alias) @local.definition.type))

; Pattern Match Definitions

; Stab Clause Definitions
; format-ignore

; Aliases
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#any-of? @_identifier "require" "alias" "use" "import"))
  (arguments
    [
      (alias) @local.definition.import
      (_ (alias) @local.definition.import)
      (_ (_ (alias) @local.definition.import))
      (_ (_ (_ (alias) @local.definition.import)))
      (_ (_ (_ (_ (alias) @local.definition.import))))
    ]))

; Local Function Definitions & Scopes
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#any-of? @_identifier "def" "defp" "defmacro" "defmacrop" "defguard" "defguardp" "defn" "defnp" "for"))
  (arguments
    [
      (identifier) @local.definition.function
      (binary_operator
        left: (identifier) @local.definition.function
        operator: "when")
      (binary_operator
        (identifier) @local.definition.parameter)
      (call
        target: (identifier) @local.definition.function
        (arguments
          [
            (identifier) @local.definition.parameter
            (_ (identifier) @local.definition.parameter)
            (_ (_ (identifier) @local.definition.parameter))
            (_ (_ (_ (identifier) @local.definition.parameter)))
            (_ (_ (_ (_ (identifier) @local.definition.parameter))))
            (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))
            (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))
            (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))))
            (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))))
          ]))
    ]?)
  (#set! definition.function.scope parent)(do_block)?) @local.scope

; ExUnit Test Definitions & Scopes
; format-ignore
(call
  target:
    ((identifier) @_identifier
      (#eq? @_identifier "test"))
  (arguments
    [
      (string)
      ((string)
        .
        ","
        .
        [
          (identifier) @local.definition.parameter
          (_ (identifier) @local.definition.parameter)
          (_ (_ (identifier) @local.definition.parameter))
          (_ (_ (_ (identifier) @local.definition.parameter)))
          (_ (_ (_ (_ (identifier) @local.definition.parameter))))
          (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))
          (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))
          (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter)))))))))))))))))))
          (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (identifier) @local.definition.parameter))))))))))))))))))))
        ])
    ])
  (do_block)?) @local.scope

; Stab Clause Scopes

; --- static_delta ---

(call
  target: (identifier) @relation.impl.api
  (arguments (alias) @relation.impl.protocol)
  (#eq? @relation.impl.api "defimpl")) @relation.impl

(unary_operator
  operator: "@"
  operand: (call
    target: (identifier) @type.attribute)
  (#any-of? @type.attribute "spec" "type" "typep" "opaque" "callback" "macrocallback")) @type.declaration

[(list) (tuple) (string) (integer) (float) (boolean)] @data.literal

; --- upstream_tags ---

; Definitions

; * modules and protocols
(call
  target: (identifier) @ignore
  (arguments (alias) @name)
  (#any-of? @ignore "defmodule" "defprotocol")) @definition.module

; * functions/macros
(call
  target: (identifier) @ignore
  (arguments
    [
      ; zero-arity functions with no parentheses
      (identifier) @name
      ; regular function clause
      (call target: (identifier) @name)
      ; function clause with a guard clause
      (binary_operator
        left: (call target: (identifier) @name)
        operator: "when")
    ])
  (#any-of? @ignore "def" "defp" "defdelegate" "defguard" "defguardp" "defmacro" "defmacrop" "defn" "defnp")) @definition.function

; References

; ignore calls to kernel/special-forms keywords
(call
  target: (identifier) @ignore
  (#any-of? @ignore "def" "defp" "defdelegate" "defguard" "defguardp" "defmacro" "defmacrop" "defn" "defnp" "defmodule" "defprotocol" "defimpl" "defstruct" "defexception" "defoverridable" "alias" "case" "cond" "else" "for" "if" "import" "quote" "raise" "receive" "require" "reraise" "super" "throw" "try" "unless" "unquote" "unquote_splicing" "use" "with"))
(unary_operator operator: "@" operand: (call target: (identifier) @ignore @elixir.attribute.name)) @elixir.attribute

; * function call
(call
  target: [
   ; local
   (identifier) @name
   ; remote
   (dot
     right: (identifier) @name)
  ]) @reference.call

; * modules

; --- semantic_closure_v3_146_batch2 ---

((call target: (identifier) @_op (arguments (alias) @elixir.module.target)) @elixir.module.alias (#eq? @_op "alias"))
((call target: (identifier) @_op (arguments (alias) @elixir.module.target)) @elixir.module.import (#eq? @_op "import"))
((call target: (identifier) @_op (arguments (alias) @elixir.module.target)) @elixir.module.require (#eq? @_op "require"))
((call target: (identifier) @_op (arguments (alias) @elixir.module.target)) @elixir.module.use (#eq? @_op "use"))

; --- semantic_closure_v3_146_batch3 ---
((call target: (identifier) @_op (arguments) @elixir.struct.fields) @elixir.struct (#eq? @_op "defstruct"))
((call target: (identifier) @_op (arguments) @elixir.exception.fields) @elixir.exception (#eq? @_op "defexception"))
(binary_operator left: (_) @elixir.pipe.input operator: "|>" right: (_) @elixir.pipe.target) @elixir.pipe

