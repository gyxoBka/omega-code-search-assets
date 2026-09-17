; omega-svelte
;
; A `.svelte` file is a component: a `<script>` of JavaScript or TypeScript, a
; `<style>` of CSS, and markup with Svelte's own block and tag syntax. The
; script and the style are handed to their own Packs by the injections at the
; end of this file, so everything a question could ask about imports, props,
; stores or selectors is answered there. What is left for this Pack is the
; markup, and the questions asked of it are:
;
;   which components does this file use, and where
;   what snippets does it declare, and where are they rendered
;   which action, transition or attachment function does it apply
;   which events does it handle
;   what name does a block bind over its body, and how far does that body reach
;
; Two rules shape every pattern below.
;
; Containment is never stated. The tree already holds it; the three blocks that
; bind a name emit one `scope.*` region so the extent is available once.
;
; The content of `{...}` is raw JavaScript or TypeScript that this grammar does
; not parse -- it is one `js` or `ts` token. Storing that token as a name is how
; the old Pack turned every expression in a file into a reference to nothing.
; Here an expression is stated only when it is a single identifier, which is the
; case where it resolves onto something the script Pack declared.

; --- a snippet ---
;
; `{#snippet row(item)}` declares a callable that `{@render row(x)}` invokes.
; One match carries the declaration, its signature, and the region its
; parameters are bound over.

(snippet_block
  name: (snippet_name) @snippet.name
  type_parameters: (snippet_type_parameters)? @snippet.type_parameters
  parameters: (snippet_parameters)? @snippet.parameters) @snippet

; --- rendering a snippet ---
;
; The callee is taken from the text before `(`, so `{@render row(item)}`
; resolves onto the `row` declared above.

(render_tag expression: (expression_value) @render.expression) @render

; --- an attachment ---
;
; `{@attach tooltip(text)}` applies an attachment function to the element.

(attach_tag expression: (expression_value) @attach.expression) @attach

; --- a local constant ---
;
; `{@const total = items.length}` names `total` for the rest of the block.

(const_tag expression: (expression_value) @const.expression) @const

; --- `{@html expr}` ---

((html_tag expression: (expression_value [(js) (ts)] @html.name)) @html
 (#match? @html.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

; --- `{#each list as item, i}` ---
;
; The names the loop binds. The item name is required to be an identifier: a
; destructured binding has no single name and its pattern text is not one.

((each_block
   binding: (pattern [(js) (ts)] @each.item.name) @each.item
   index: (pattern [(js) (ts)] @each.index.name)? @each.index)
 (#match? @each.item.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

(each_block) @each.body

; --- `{#await promise then value}` ---

((await_block
   binding: (pattern [(js) (ts)] @await.value.name) @await.value)
 (#match? @await.value.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

(await_block) @await.body

; `{:then value}` and `{:catch error}` bind on the branch instead.

; The binding is a plain `pattern` child. It is not reachable through
; `branch:`, which carries only the braces and the keyword, and the query
; compiler rejects the `binding:` field this grammar's node-types names -- so
; the pattern is written without a field at all.

((await_branch
   (pattern [(js) (ts)] @branch.value.name)) @branch.value
 (#match? @branch.value.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

; --- a component tag ---
;
; Svelte tells a component from an element by the capital letter, exactly as
; JSX does. `<Foo.Bar/>` is reduced to `Foo`, the value `<script>` imported.

([(start_tag name: (tag_name) @component.name) @component.tag
  (self_closing_tag name: (tag_name) @component.name) @component.tag]
 (#match? @component.name "^[A-Z]"))

; --- a `svelte:` element ---
;
; `<svelte:options>`, `<svelte:window>`, `<svelte:head>` and the rest are the
; language's own configuration elements, not markup.

([(start_tag name: (tag_name namespace: (tag_namespace) @special.namespace) @special.name) @special.tag
  (self_closing_tag name: (tag_name namespace: (tag_namespace) @special.namespace) @special.name) @special.tag]
 (#eq? @special.namespace "svelte"))

; --- `use:action` ---
;
; The identifier after the directive is a function declared or imported in the
; script, so it resolves.

((attribute
   name: (attribute_name
     (attribute_directive) @use.directive
     (attribute_identifier) @use.name)) @use
 (#match? @use.directive "^use:?$"))

; --- `transition:`, `in:`, `out:`, `animate:` ---

((attribute
   name: (attribute_name
     (attribute_directive) @transition.directive
     (attribute_identifier) @transition.name)) @transition
 (#match? @transition.directive "^(transition|in|out|animate):?$"))

; --- `on:click={handler}` ---

((attribute
   name: (attribute_name
     (attribute_directive) @event.directive
     (attribute_identifier) @event.name)) @event
 (#match? @event.directive "^on:?$"))

; --- `onclick={handler}` ---
;
; Svelte 5 spells an event handler as an ordinary attribute. Anchored to the
; first child so the `on:` form above does not match here as well.

; `attribute_name` has children only when a directive is present, so
; `onclick={handler}` -- the Svelte 5 spelling, and the common one -- is a bare
; `attribute_name` leaf and the child pattern matched nothing. Both forms now:
; the leaf, and the `on:click|modifier` directive spelling.

((attribute
   name: (attribute_name) @event.attribute.name) @event.attribute
 (#match? @event.attribute.name "^on[a-z][a-z]+$"))

((attribute
   name: (attribute_name
           (attribute_directive) @_on
           (attribute_identifier) @event.attribute.name)) @event.attribute
 (#match? @_on "^on$"))

; --- an expression that is one identifier ---
;
; `{count}`, `{#if ready}`, `label={caption}`, `bind:value={name}`. Anything
; longer is JavaScript and is left to the script.

((expression [(js) (ts)] @expression.name) @expression
 (#match? @expression.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

; --- `<Foo {value}/>` ---

((shorthand_attribute content: [(js) (ts)] @shorthand.name) @shorthand
 (#match? @shorthand.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

; --- the script and the style ---
;
; Where the rest of the component is. `lang="ts"` and `lang="scss"` are read
; from the attribute; without one the default is JavaScript and CSS.

((element
  (start_tag name: (tag_name) @_tag) @_start
  (raw_text) @injection.content)
  (#eq? @_tag "script")
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "javascript"))

(element
  (start_tag
    name: (tag_name) @_tag
    (attribute
      name: (attribute_name) @_lang
      value: (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_tag "script")
  (#eq? @_lang "lang"))

((element
  (start_tag name: (tag_name) @_tag) @_start
  (raw_text) @injection.content)
  (#eq? @_tag "style")
  (#not-match? @_start "(?i)\\blang\\s*=")
  (#set! injection.language "css"))

(element
  (start_tag
    name: (tag_name) @_tag
    (attribute
      name: (attribute_name) @_lang
      value: (quoted_attribute_value (attribute_value) @injection.language)))
  (raw_text) @injection.content
  (#eq? @_tag "style")
  (#eq? @_lang "lang"))
