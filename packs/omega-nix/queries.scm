; --- attrpath_string_binding_context ---

(binding
  attrpath: (attrpath
    attr: (identifier) @nix.attrpath.root .
    attr: (identifier) @nix.attrpath.segment1 .
    attr: (identifier) @nix.attrpath.segment2 .)
  expression: (string_expression
    . (string_fragment) @nix.attrpath.string_value .)) @nix.attrpath.string_binding

; --- binding_call_context ---

(binding
  attrpath: (attrpath
    attr: (identifier) @nix.binding.name .)
  expression: (apply_expression
    function: (select_expression
      attrpath: (attrpath
        attr: (identifier) @nix.callee.name .)) @nix.callee)) @nix.binding.call

; --- binding_path_list_context ---

(binding
  attrpath: (attrpath
    attr: (identifier) @nix.path_list.binding .)
  expression: (list_expression
    element: (path_expression) @nix.path_list.item)) @nix.path_list.context

; --- call_targets ---

(apply_expression
  function: (_) @call.target) @call.expression

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=nix kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/nix/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; let bindings
(let_expression
  (binding_set
    (binding
      .
      (attrpath) @local.definition.var))) @local.scope

; rec attrsets
(rec_attrset_expression
  (binding_set
    (binding
      .
      (attrpath) @local.definition.field))) @local.scope

; functions and parameters
(function_expression
  .
  [
    (identifier) @local.definition.parameter
    (formals
      (formal
        .
        (identifier) @local.definition.parameter))
  ]) @local.scope

((formals)
  "@"
  (identifier) @local.definition.parameter) ; I couldn't get this to work properly inside the (function)

(variable_expression
  (identifier) @local.reference)

(inherited_attrs
  attr: (identifier) @local.reference)

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/nix/locals.scm
; sha256=7534473cf89cfcc51d590b8fe2b88a9ce94b64ee6c0104f550f0ff6c35e5a900

; let bindings

; rec attrsets

; functions and parameters




; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=56fd3a06df812415ea583b363624539d625dd7b2dfbc37522a1653eb07ac9fef
; source_name=nix

; ----- resolved nvim highlights source: nix sha256=56fd3a06df812415ea583b363624539d625dd7b2dfbc37522a1653eb07ac9fef -----
; basic keywords
[
  "assert"
  "in"
  "inherit"
  "let"
  "rec"
  "with"
] @keyword

; if/then/else
[
  "if"
  "then"
  "else"
] @keyword.conditional

; field access default (`a.b or c`)
"or" @keyword.operator

; comments
(comment) @comment @spell

; strings
(string_fragment) @string

(string_expression
  "\"" @string)

(indented_string_expression
  "''" @string)

; paths and URLs
[
  (path_expression)
  (hpath_expression)
  (spath_expression)
] @string.special.path

(uri_expression) @string.special.url

; escape sequences
(escape_sequence) @string.escape

; delimiters
[
  "."
  ";"
  ":"
  ","
] @punctuation.delimiter

; brackets
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

; `?` in `{ x ? y }:`, used to set defaults for named function arguments
(formal
  name: (identifier) @variable.parameter
  "?"? @operator)

; `...` in `{ ... }`, used to ignore unknown named function arguments (see above)
(ellipses) @variable.parameter.builtin

; universal is the parameter of the function expression
; `:` in `x: y`, used to separate function argument from body (see above)
(function_expression
  universal: (identifier) @variable.parameter
  ":" @punctuation.special)
(apply_expression function: (variable_expression name: (identifier) @function.call @name)) @reference.call

; basic identifiers
(variable_expression) @variable

(variable_expression
  name: (identifier) @keyword.import
  (#eq? @keyword.import "import"))

(variable_expression
  name: (identifier) @boolean
  (#any-of? @boolean "true" "false"))

; string interpolation (this was very annoying to get working properly)
(interpolation
  "${" @punctuation.special
  (_)
  "}" @punctuation.special) @none

(select_expression
  expression: (_) @_expr
  attrpath: (attrpath
    attr: (identifier) @variable.member)
  (#not-eq? @_expr "builtins"))

(attrset_expression
  (binding_set
    (binding
      .
      (attrpath
        (identifier) @variable.member))))

(rec_attrset_expression
  (binding_set
    (binding
      .
      (attrpath
        (identifier) @variable.member))))

function: (select_expression
  attrpath: (attrpath
    attr: (identifier) @function.call .))

; builtin functions (with builtins prefix)
(select_expression
  expression: (variable_expression
    name: (identifier) @_id)
  attrpath: (attrpath
    attr: (identifier) @function.builtin)
  (#eq? @_id "builtins"))

; builtin functions (without builtins prefix)
(variable_expression
  name: (identifier) @function.builtin
  (#any-of? @function.builtin
    ; nix eval --impure --expr 'with builtins; filter (x: !(elem x [ "abort" "import" "throw" ]) && isFunction builtins.${x}) (attrNames builtins)'
    "add" "addErrorContext" "all" "any" "appendContext" "attrNames" "attrValues" "baseNameOf"
    "bitAnd" "bitOr" "bitXor" "break" "catAttrs" "ceil" "compareVersions" "concatLists" "concatMap"
    "concatStringsSep" "deepSeq" "derivation" "derivationStrict" "dirOf" "div" "elem" "elemAt"
    "fetchGit" "fetchMercurial" "fetchTarball" "fetchTree" "fetchurl" "filter" "filterSource"
    "findFile" "floor" "foldl'" "fromJSON" "fromTOML" "functionArgs" "genList" "genericClosure"
    "getAttr" "getContext" "getEnv" "getFlake" "groupBy" "hasAttr" "hasContext" "hashFile"
    "hashString" "head" "intersectAttrs" "isAttrs" "isBool" "isFloat" "isFunction" "isInt" "isList"
    "isNull" "isPath" "isString" "length" "lessThan" "listToAttrs" "map" "mapAttrs" "match" "mul"
    "parseDrvName" "partition" "path" "pathExists" "placeholder" "readDir" "readFile" "removeAttrs"
    "replaceStrings" "scopedImport" "seq" "sort" "split" "splitVersion" "storePath" "stringLength"
    "sub" "substring" "tail" "toFile" "toJSON" "toPath" "toString" "toXML" "trace" "traceVerbose"
    "tryEval" "typeOf" "unsafeDiscardOutputDependency" "unsafeDiscardStringContext"
    "unsafeGetAttrPos" "zipAttrsWith"
    ; primops, `__<tab>` in `nix repl`
    "__add" "__filter" "__isFunction" "__split" "__addErrorContext" "__filterSource" "__isInt"
    "__splitVersion" "__all" "__findFile" "__isList" "__storeDir" "__any" "__floor" "__isPath"
    "__storePath" "__appendContext" "__foldl'" "__isString" "__stringLength" "__attrNames"
    "__fromJSON" "__langVersion" "__sub" "__attrValues" "__functionArgs" "__length" "__substring"
    "__bitAnd" "__genList" "__lessThan" "__tail" "__bitOr" "__genericClosure" "__listToAttrs"
    "__toFile" "__bitXor" "__getAttr" "__mapAttrs" "__toJSON" "__catAttrs" "__getContext" "__match"
    "__toPath" "__ceil" "__getEnv" "__mul" "__toXML" "__compareVersions" "__getFlake" "__nixPath"
    "__trace" "__concatLists" "__groupBy" "__nixVersion" "__traceVerbose" "__concatMap" "__hasAttr"
    "__parseDrvName" "__tryEval" "__concatStringsSep" "__hasContext" "__partition" "__typeOf"
    "__currentSystem" "__hashFile" "__path" "__unsafeDiscardOutputDependency" "__currentTime"
    "__hashString" "__pathExists" "__unsafeDiscardStringContext" "__deepSeq" "__head" "__readDir"
    "__unsafeGetAttrPos" "__div" "__intersectAttrs" "__readFile" "__zipAttrsWith" "__elem"
    "__isAttrs" "__replaceStrings" "__elemAt" "__isBool" "__seq" "__fetchurl" "__isFloat" "__sort"))

; constants
(variable_expression
  name: (identifier) @constant.builtin
  (#any-of? @constant.builtin
    ; nix eval --impure --expr 'with builtins; filter (x: !(isFunction builtins.${x} || isBool builtins.${x})) (attrNames builtins)'
    "builtins" "currentSystem" "currentTime" "langVersion" "nixPath" "nixVersion" "null" "storeDir"))

; function definition
(binding
  attrpath: (attrpath
    attr: (identifier) @function)
  expression: (function_expression))

; unary operators
(unary_expression
  operator: _ @operator)

; binary operators
(binary_expression
  operator: _ @operator)

[
  "="
  "@"
  "?"
] @operator

; integers, also highlight a unary -
[
  (unary_expression
    "-"
    (integer_expression))
  (integer_expression)
] @number

; floats, also highlight a unary -
[
  (unary_expression
    "-"
    (float_expression))
  (float_expression)
] @number.float

; exceptions
(variable_expression
  name: (identifier) @keyword.exception
  (#any-of? @keyword.exception "abort" "throw"))

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=09f896a93b39001e83eff743b00e5f4f48b34f9859b04a24e5aca72598fbd30e
; source_name=nix

; ----- resolved nvim injections source: nix sha256=09f896a93b39001e83eff743b00e5f4f48b34f9859b04a24e5aca72598fbd30e -----
((comment) @injection.content
  (#set! injection.language "comment"))

((comment) @injection.language
  . ; this is to make sure only adjacent comments are accounted for the injections
  [
    (string_expression
      (string_fragment) @injection.content)
    (indented_string_expression
      (string_fragment) @injection.content)
  ]
  (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
  (#set! injection.combined))

; #-style Comments
((comment) @injection.language
  . ; this is to make sure only adjacent comments are accounted for the injections
  [
    (string_expression
      (string_fragment) @injection.content)
    (indented_string_expression
      (string_fragment) @injection.content)
  ]
  (#gsub! @injection.language "#%s*([%w%p]+)%s*" "%1")
  (#set! injection.combined))

(apply_expression
  function: (_) @_func
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "regex")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "regex")))
  ]
  (#lua-match? @_func "^%a*%.*match$")
  (#set! injection.combined))

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ]
  (#lua-match? @_path "^%a+Phase$")
  (#set! injection.combined))

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ]
  (#lua-match? @_path "^pre%a+$")
  (#set! injection.combined))

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ]
  (#lua-match? @_path "^post%a+$")
  (#set! injection.combined))

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ]
  (#lua-match? @_path "^script$")
  (#set! injection.combined))

(apply_expression
  function: (_) @_func
  argument: (_
    (_)*
    (_
      (_)*
      (binding
        attrpath: (attrpath
          (identifier) @_path)
        expression: [
          (string_expression
            ((string_fragment) @injection.content
              (#set! injection.language "bash")))
          (indented_string_expression
            ((string_fragment) @injection.content
              (#set! injection.language "bash")))
        ])))
  (#lua-match? @_func "^%a*%.*writeShellApplication$")
  (#lua-match? @_path "^text$")
  (#set! injection.combined))

(apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ]
  (#lua-match? @_func "^%a*%.*runCommand%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ])
  (#lua-match? @_func "^%a*%.*writeBash%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ])
  (#lua-match? @_func "^%a*%.*writeDash%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "bash")))
  ])
  (#lua-match? @_func "^%a*%.*writeShellScript%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "fish")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "fish")))
  ])
  (#lua-match? @_func "^%a*%.*writeFish%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "haskell")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "haskell")))
  ])
  (#lua-match? @_func "^%a*%.*writeHaskell%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "javascript")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "javascript")))
  ])
  (#lua-match? @_func "^%a*%.*writeJS%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "perl")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "perl")))
  ])
  (#lua-match? @_func "^%a*%.*writePerl%a*$")
  (#set! injection.combined))

((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "python")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "python")))
  ])
  (#lua-match? @_func "^%a*%.*writePy%a*%d*%a*$")
  (#set! injection.combined))

((apply_expression
  function: (_) @_func
  argument: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "rust")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "rust")))
  ])
  (#lua-match? @_func "^%a*%.*writeRust%a*$")
  (#set! injection.combined))

; (runTest) testScript
(apply_expression
  function: (_) @_func
  argument: (_
    (_)*
    (_
      (binding
        attrpath: (attrpath) @_func_name
        expression: (_
          (string_fragment) @injection.content
          (#set! injection.language "python")))
      (#eq? @_func_name "testScript")
      (#lua-match? @_func "^.*%.*runTest$")
      (#set! injection.combined))))

; (nixosTest) testScript
(apply_expression
  function: (_) @_func
  argument: (_
    (_)*
    (_
      (binding
        attrpath: (attrpath) @_func_name
        expression: (_
          (string_fragment) @injection.content
          (#set! injection.language "python")))
      (#eq? @_func_name "testScript")
      (#lua-match? @_func "^.*%.*nixosTest$")
      (#set! injection.combined))))

; home-manager Neovim plugin config
(attrset_expression
  (binding_set
    (binding
      attrpath: (attrpath) @_ty_attr
      (_
        (string_fragment) @_ty)
      (#eq? @_ty_attr "type")
      (#eq? @_ty "lua"))
    (binding
      attrpath: (attrpath) @_cfg_attr
      (_
        (string_fragment) @injection.content
        (#set! injection.language "lua"))
      (#eq? @_cfg_attr "config")))
  (#set! injection.combined))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=7534473cf89cfcc51d590b8fe2b88a9ce94b64ee6c0104f550f0ff6c35e5a900
; resolved_query_sha256=b88bd9d05c98aed0bfe55aa671395ab24ea6248a5e9bd4ec9a70be20a60c7fd7
; parser_revision=70f34e95e30b7ebcc40815d4385d68576c4a15cd
; source_name=nix
; direct_inherits=
; resolved_sources=nix

; ----- resolved nvim locals source: nix sha256=7534473cf89cfcc51d590b8fe2b88a9ce94b64ee6c0104f550f0ff6c35e5a900 -----
; let bindings

; rec attrsets

; functions and parameters




; --- static_delta ---

((apply_expression
  function: (variable_expression name: (identifier) @import.api)
  argument: (_) @import.target) @import.expression
  (#eq? @import.api "import"))

[(attrset_expression) (rec_attrset_expression) (list_expression) (string_expression) (integer_expression) (float_expression) (path_expression) (spath_expression) (hpath_expression) (uri_expression)] @data.value

; --- upstream_tags ---

;; https://tree-sitter.github.io/tree-sitter/4-code-navigation.html
;;
;; The Nix data model is "everything is an attrset of expressions";
;; functions and values share the same binding form. We capture
;; definitions broadly (any binding) and mark function-valued bindings
;; as @definition.function specifically so GitHub's code-nav can
;; distinguish them.

;; ----- Definitions -----

;; Generic binding — any top-level or nested attrset attribute.
;; Anchor @name to the LEAF of the attrpath so `foo.bar.baz = …`
;; tags `baz` rather than the whole dotted path.
(binding
  attrpath: (attrpath
    attr: (identifier) @name .)
  expression: (_)) @definition

;; Function-valued bindings — `foo = x: …`.
(binding
  attrpath: (attrpath
    attr: (identifier) @name .)
  expression: (function_expression)) @definition.function

;; inherit — definitions brought from another scope.
(inherit
  attrs: (inherited_attrs attr: (identifier) @name)) @definition
(inherit_from
  attrs: (inherited_attrs attr: (identifier) @name)) @definition

;; ----- References -----

;; Any bare identifier used as a value expression is a reference.
(variable_expression
  name: (identifier) @name) @reference

;; Method-style call: `foo.bar.baz arg` — tag the leaf attrname.
(apply_expression
  function: (select_expression
    attrpath: (attrpath
      attr: (identifier) @name .))) @reference.call

;; Attribute access (non-call) — `foo.bar.baz` lookup.
(select_expression
  attrpath: (attrpath
    attr: (identifier) @name .)) @reference
