; omega-vue
;
; A `.vue` file is one single-file component: a `<template>` of markup, a
; `<script>` block in JavaScript or TypeScript, and a `<style>` block. The
; questions asked of it are: which components does this template render, which
; slots does it offer and fill, which props and events does it wire, and which
; symbols of the script does the template reach for.
;
; The script's own declarations are not this Pack's business -- they are
; reached through the injections at the bottom of this file and parsed by the
; JavaScript or TypeScript Pack. What is left is what Vue's own template
; syntax names, and that is what is stated here.
;
; Containment is deliberately not stated. The tree already holds it; the three
; blocks of the file are emitted as regions and no pattern says that one node
; is inside another for its own sake.

; --- a component this template renders ---
;
; A tag that starts with a capital or contains a hyphen is a component, not an
; HTML element: those are the two spellings Vue resolves against an import or
; a registered component, and the two the Vue overlay joins against a `.vue`
; file stem and against an ECMAScript import binding. `<div>` and `<span>`
; resolve to nothing and name nothing anyone asks about, so they are not
; emitted.

([(start_tag (tag_name) @component.use)
  (self_closing_tag (tag_name) @component.use)]
 (#match? @component.use "^[A-Z]|-"))

; --- a slot this component offers ---
;
; `<slot name="header"/>` is the one declaration Vue's template syntax makes
; that a different file resolves against: a parent's `#header` fills it.

([(start_tag (tag_name) @slot.tag
    (attribute (attribute_name) @slot.key
      (quoted_attribute_value (attribute_value) @slot.name)))
  (self_closing_tag (tag_name) @slot.tag
    (attribute (attribute_name) @slot.key
      (quoted_attribute_value (attribute_value) @slot.name)))] @slot
 (#eq? @slot.tag "slot")
 (#eq? @slot.key "name"))

; --- a template ref ---
;
; `ref="input"` names a node that the script reaches for by that name.

((attribute (attribute_name) @ref.key
   (quoted_attribute_value (attribute_value) @ref.name)) @ref
 (#eq? @ref.key "ref"))

; --- the event a listener handles ---
;
; `@click` and `v-on:click`. The argument is the event name: for a component
; it is the custom event the child emits, so the name is the link between the
; two files.

((directive_attribute (directive_name) @on.directive
   (directive_argument) @on.event)
 (#any-of? @on.directive "v-on" "@"))

; --- the prop or attribute a binding sets ---
;
; `:title` and `v-bind:title`.

((directive_attribute (directive_name) @bind.directive
   (directive_argument) @bind.prop)
 (#any-of? @bind.directive "v-bind" ":"))

; --- the slot a template fills ---
;
; `#footer` and `v-slot:footer`, resolving against the `<slot name="footer"/>`
; declared above.

((directive_attribute (directive_name) @slot.use.directive
   (directive_argument) @slot.use.name)
 (#any-of? @slot.use.directive "v-slot" "#"))

; --- what `v-for` binds, and what it iterates ---
;
; `v-for="item in items"` introduces `item` into the template, so that the
; `{{ item.id }}` below it has something to resolve to, and reads `items` from
; the script. Restricted to the plain form: an alias list `(item, i)` or a
; destructuring pattern binds names this Pack does not take apart, and the
; coverage guard says so.

((directive_attribute (directive_name) @for.directive
   (quoted_attribute_value (attribute_value) @for.expression)) @for
 (#eq? @for.directive "v-for")
 (#match? @for.expression "^[A-Za-z_$][A-Za-z0-9_$]*[ \t]+(in|of)[ \t]+[A-Za-z_$][A-Za-z0-9_$.]*$"))

; --- what a directive is bound to ---
;
; The value of a directive is a JavaScript expression evaluated against the
; component. Its head identifier is the script symbol it reaches for, and the
; expression itself is carried in a field for the overlay that builds a
; template binding out of it.

(directive_attribute
  (directive_name) @directive.name
  (quoted_attribute_value (attribute_value) @directive.value))

; --- a script symbol a dynamic argument reaches for ---
;
; `:[attributeName]="value"` computes the argument from a script symbol.

(directive_attribute
  (directive_dynamic_argument
    (directive_dynamic_argument_value) @dynamic.value))

; --- what an interpolation renders ---
;
; `{{ message }}`. Same rule as a directive value: the head of the path is the
; script symbol, and it is the name so that it resolves.

(interpolation (raw_text) @interpolation.value)

; --- the three blocks of the file ---
;
; A `.vue` file is three languages in one file, so which block a span falls in
; is a question of its own. Rooted at `component` so that a `<template #slot>`
; inside the markup is not mistaken for the file's own template block.

(component (template_element (start_tag (tag_name) @block.template.name)) @block.template)

(component (script_element (start_tag (tag_name) @block.script.name)) @block.script)

(component (style_element (start_tag (tag_name) @block.style.name)) @block.style)

; --- the script and the style are other languages ---

((script_element
   (start_tag) @_start
   (raw_text) @injection.content)
 (#not-match? @_start "(?i)\\blang\\s*=")
 (#set! injection.language "javascript"))

((script_element
   (start_tag
     (attribute
       (attribute_name) @_lang
       (quoted_attribute_value (attribute_value) @injection.language)))
   (raw_text) @injection.content)
 (#eq? @_lang "lang"))

((style_element
   (start_tag) @_start
   (raw_text) @injection.content)
 (#not-match? @_start "(?i)\\blang\\s*=")
 (#set! injection.language "css"))

((style_element
   (start_tag
     (attribute
       (attribute_name) @_lang
       (quoted_attribute_value (attribute_value) @injection.language)))
   (raw_text) @injection.content)
 (#eq? @_lang "lang"))
