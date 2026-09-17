; --- completeness_imports_6 ---

(include) @import.expression

; --- completeness_scopes ---

(script_block) @scope.lexical

; --- distributed_highlights ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-pug
; parser_revision=13e9195370172c86a8b88184cc358b23b677cc46
; source_sha256=cc01b3f32d5365626882269eaf3ac30f006f093fb9bd5dc8f2da39d695073714

(comment) @comment @spell

(tag_name) @tag

((tag_name) @constant.builtin
  ; https://www.script-example.com/html-tag-liste
  (#any-of? @constant.builtin
    "head" "title" "base" "link" "meta" "style" "body" "article" "section" "nav" "aside" "h1" "h2"
    "h3" "h4" "h5" "h6" "hgroup" "header" "footer" "address" "p" "hr" "pre" "blockquote" "ol" "ul"
    "menu" "li" "dl" "dt" "dd" "figure" "figcaption" "main" "div" "a" "em" "strong" "small" "s"
    "cite" "q" "dfn" "abbr" "ruby" "rt" "rp" "data" "time" "code" "var" "samp" "kbd" "sub" "sup" "i"
    "b" "u" "mark" "bdi" "bdo" "span" "br" "wbr" "ins" "del" "picture" "source" "img" "iframe"
    "embed" "object" "param" "video" "audio" "track" "map" "area" "table" "caption" "colgroup" "col"
    "tbody" "thead" "tfoot" "tr" "td" "th " "form" "label" "input" "button" "select" "datalist"
    "optgroup" "option" "textarea" "output" "progress" "meter" "fieldset" "legend" "details"
    "summary" "dialog" "script" "noscript" "template" "slot" "canvas"))

(id) @constant

(class) @type

(doctype) @keyword.directive

(content) @none

(tag
  (attributes
    (attribute
      (attribute_name) @tag.attribute
      "=" @operator)))

((tag
  (attributes
    (attribute
      (attribute_name) @keyword)))
  (#match? @keyword "^(:|v-bind|v-|\\@)"))

(quoted_attribute_value) @string

(include
  (keyword) @keyword.import)

(extends
  (keyword) @keyword.import)

(filename) @string.special.path

(block_definition
  (keyword) @keyword)

(block_append
  (keyword)+ @keyword)

(block_prepend
  (keyword)+ @keyword)

(block_name) @module

(conditional
  (keyword) @keyword.conditional)

(case
  (keyword) @keyword.conditional
  (when
    (keyword) @keyword.conditional)+)

(each
  (keyword) @keyword.repeat)

(while
  (keyword) @keyword.repeat)

(mixin_use
  "+" @punctuation.delimiter
  (mixin_name) @function.call)

(mixin_definition
  (keyword) @keyword.function
  (mixin_name) @function)

(mixin_attributes
  (attribute_name) @variable.parameter)

(filter
  ":" @punctuation.delimiter
  (filter_name) @function.method.call)

(filter
  (attributes
    (attribute
      (attribute_name) @variable.parameter)))

[
  "("
  ")"
  "#{"
  "}"
  ; unsupported
  ; "!{"
  ; "#[" "]"
] @punctuation.bracket

[
  ","
  "."
  "|"
] @punctuation.delimiter

(buffered_code
  "=" @punctuation.delimiter)

(unbuffered_code
  "-" @punctuation.delimiter)

(unescaped_buffered_code
  "!=" @punctuation.delimiter)

; --- distributed_injections ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-pug
; parser_revision=13e9195370172c86a8b88184cc358b23b677cc46
; source_sha256=fd88cb919d82f0332510d2f0f87f758060c91e5d34cf365821cdeb9fce838f9a

((comment) @injection.content
  (#set! injection.language "comment"))

((javascript) @injection.content
  (#set! injection.language "javascript"))

((attribute_name) @_attribute_name
  (quoted_attribute_value
    (attribute_value) @injection.content
    (#set! injection.language "javascript"))
  (#match? @_attribute_name "^(:|v-bind|v-|\\@)"))

; --- highlights ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-pug
; parser_revision=13e9195370172c86a8b88184cc358b23b677cc46
; source_sha256=cc01b3f32d5365626882269eaf3ac30f006f093fb9bd5dc8f2da39d695073714



((tag_name) @constant.builtin
  ; https://www.script-example.com/html-tag-liste
  (#any-of? @constant.builtin
    "head" "title" "base" "link" "meta" "style" "body" "article" "section" "nav" "aside" "h1" "h2"
    "h3" "h4" "h5" "h6" "hgroup" "header" "footer" "address" "p" "hr" "pre" "blockquote" "ol" "ul"
    "menu" "li" "dl" "dt" "dd" "figure" "figcaption" "main" "div" "a" "em" "strong" "small" "s"
    "cite" "q" "dfn" "abbr" "ruby" "rt" "rp" "data" "time" "code" "var" "samp" "kbd" "sub" "sup" "i"
    "b" "u" "mark" "bdi" "bdo" "span" "br" "wbr" "ins" "del" "picture" "source" "img" "iframe"
    "embed" "object" "param" "video" "audio" "track" "map" "area" "table" "caption" "colgroup" "col"
    "tbody" "thead" "tfoot" "tr" "td" "th " "form" "label" "input" "button" "select" "datalist"
    "optgroup" "option" "textarea" "output" "progress" "meter" "fieldset" "legend" "details"
    "summary" "dialog" "script" "noscript" "template" "slot" "canvas"))






((tag
  (attributes
    (attribute
      (attribute_name) @keyword)))
  (#match? @keyword "^(:|v-bind|v-|\\@)"))


















[
  "("
  ")"
  "#{"
  "}"
  ; unsupported
  ; "!{"
  ; "#[" "]"
] @punctuation.bracket





; --- injections ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-pug
; parser_revision=13e9195370172c86a8b88184cc358b23b677cc46
; source_sha256=fd88cb919d82f0332510d2f0f87f758060c91e5d34cf365821cdeb9fce838f9a

((comment) @injection.content
  (#set! injection.language "comment"))

((javascript) @injection.content
  (#set! injection.language "javascript"))

((attribute_name) @_attribute_name
  (quoted_attribute_value
    (attribute_value) @injection.content
    (#set! injection.language "javascript"))
  (#match? @_attribute_name "^(:|v-bind|v-|\\@)"))

; --- terminal_source_semantics_v1 ---

(include (filename) @pug.import.path) @pug.import.include
(extends (filename) @pug.import.path) @pug.import.extends

(mixin_definition (mixin_name) @pug.mixin.definition.name) @pug.mixin.definition
(mixin_use (mixin_name) @pug.mixin.call.name) @pug.mixin.call
(mixin_definition (mixin_attributes (attribute_name) @pug.mixin.parameter)) @pug.mixin.parameter.context

(each (iteration_variable) @pug.each.binding) @pug.each.owner
(each (iteration_iterator) @pug.each.iterator) @pug.each.iterator.owner

(block_definition (block_name) @pug.block.definition.name) @pug.block.definition
(block_append (block_name) @pug.block.reference.name) @pug.block.reference
(block_prepend (block_name) @pug.block.reference.name) @pug.block.reference

(tag (tag_name) @pug.tag.name) @pug.tag
(attribute (attribute_name) @pug.attribute.name) @pug.attribute
(attribute
  (attribute_name) @pug.attribute.value.name
  (quoted_attribute_value) @pug.attribute.value) @pug.attribute.with_value

(filter (filter_name) @pug.filter.name) @pug.filter

[
  (mixin_definition)
  (each)
  (conditional)
  (while)
] @pug.scope
