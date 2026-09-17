; omega-pug
;
; Pug is the template layer of a Node project: a layout is extended, partials
; are included, named blocks are overridden, and mixins are the reusable pieces
; of markup. The questions asked of a `.pug` file are: which layout does this
; template extend, which partials does it pull in, which block does it
; override, where is this mixin defined and where is it used, which element is
; `#main`, and what does the page load. Every pattern below answers one of
; them.
;
; Four things are deliberately not stated.
;
; The tag. `div`, `p`, `li` name nothing a question can reach, and one emission
; per tag of every template was the single largest thing the previous Pack
; produced. Only a hyphenated tag -- a custom element defined elsewhere -- and
; a heading's or a title's text are stated.
;
; The bare attribute. An attribute whose name the Pack does not recognise
; answers no question. `id`, and the attributes that fetch something, are
; stated; the rest are not. The attribute patterns are rooted at `attributes`
; rather than at `attribute`, because this grammar spells a mixin's *arguments*
; with the same `attribute` node: `+link(href='/x')` passes an argument named
; `href`, it does not load a page.
;
; Containment. The tree already holds it, and an `id` in the rendered document
; is global, so a tag's ancestry is not a namespace for it. There is no scope
; region and no parent/child pattern.
;
; The JavaScript expression. This grammar holds every expression -- an
; interpolation, an attribute's unquoted value, a loop's iterator, a condition
; -- as one opaque `javascript` token with no structure inside it, so a name
; read in a template cannot be stated as a reference to anything. The two
; places the token is a whole program rather than a fragment, `script.` and
; `- ...`, are handed to the JavaScript grammar as injections instead.

; --- what this template pulls in ---
;
; `extends layout` and `include ../partials/head` are the same fact: this file
; is not complete without that one.

[(extends (filename) @dependency.path)
 (include (filename) @dependency.path)] @dependency

; A filter names a jstransformer package the project must have installed --
; `:markdown-it`, `:scss`, `:babel` -- whether it is written on a block, on a
; tag's text or after `include:`. The same pattern reaches all three.

(filter (filter_name) @filter.name) @filter

; --- named blocks: the joints of template inheritance ---
;
; A layout declares `block content`; a child overrides it with `block content`,
; `append content` or `prepend content`. The declaration and the override are
; recorded under the same name so they meet.

(block_definition (block_name) @block.definition.name) @block.definition

[(block_append (block_name) @block.override.name)
 (block_prepend (block_name) @block.override.name)] @block.override

; --- mixins: the callables of the language ---
;
; One pattern, two templates: the declaration and its parameter list. The
; parameter list is optional -- `mixin spacer` is legal -- and the carrier
; template is skipped on a match that did not bind it.

(mixin_definition
  (mixin_name) @mixin.definition.name
  (mixin_attributes)? @mixin.definition.parameters) @mixin.definition

(mixin_use (mixin_name) @mixin.use.name) @mixin.use

; --- the names the rendered document carries ---
;
; `#main` is the one name Pug itself declares: a CSS `#main` rule, an
; `href="#main"` and `getElementById("main")` all resolve onto it. `.card` is
; the other direction -- the template uses a class a stylesheet declares -- so
; it is stated as a reference to that declaration. The sigil is stripped either
; way so both sides are the same string; `strip_prefix` returns its input
; unchanged when the affix is absent, so this is correct whether or not the
; grammar folds the sigil into the token.

(id) @element.id

(class) @element.class

; A tag name with a hyphen is not HTML's; it is a component registered by
; `customElements.define("my-widget", ...)` or by a framework. The use is
; stated so the definition can be found from it.

((tag_name) @custom.element
 (#match? @custom.element "^[A-Za-z][A-Za-z0-9]*(-[A-Za-z0-9]+)+$"))

; The `id="main"` spelling of the same declaration, for the templates that
; compute it or copy it from HTML.

((attributes
   (attribute
     (attribute_name) @_id
     (quoted_attribute_value (attribute_value) @attribute.id.value)) @attribute.id)
 (#match? @_id "^(?i)id$"))

; --- what the page loads ---
;
; Only a literal, quoted value: `a(href='/about')` names a page, `a(href=url)`
; names a variable this Pack cannot resolve. Fragments and the non-fetching
; schemes are excluded; a fragment is a reference to an id, and this grammar
; gives no structure to tell which id.

((attributes
   (attribute
     (attribute_name) @_resource
     (quoted_attribute_value (attribute_value) @attribute.resource.value)) @attribute.resource)
 (#match? @_resource "^(?i)(href|src|srcset|action|formaction|poster)$")
 (#not-match? @attribute.resource.value "^(?i)(#|javascript:|data:|mailto:|tel:|about:|blob:)"))

; --- what the page says about itself ---
;
; `title My Page` and `h1 Welcome`. `content` is the tag's own inline text, so
; a heading whose content is nested markup (`h1: span Hi`) binds nothing and is
; not stated rather than stated wrongly.

((tag (tag_name) @_title (content) @title.text) @title
 (#match? @_title "^(?i)title$"))

((tag (tag_name) @heading.tag (content) @heading.text) @heading
 (#match? @heading.tag "^(?i)h[1-6]$"))

; --- the one local Pug itself binds ---
;
; `each item in items` binds `item` for the block below it. The iterator on the
; right is an opaque JavaScript token and is not stated; the name on the left
; is the template's own declaration. `each user, i in users` binds two, and
; both are declared.

(each (iteration_variable (javascript) @loop.variable.name) @loop.variable)

; --- embedded JavaScript ---
;
; A `script.` block and a `- ...` code line are whole JavaScript programs and
; are parsed as such by omega-javascript, which states its own facts about
; them. Interpolations and attribute values are expression fragments and are
; not injected.

((script_block (javascript) @injection.content)
 (#set! injection.language "javascript"))

((unbuffered_code (javascript) @injection.content)
 (#set! injection.language "javascript"))
