; omega-astro
;
; An `.astro` file is a page or a component: a `---` frontmatter of TypeScript,
; markup that is HTML plus Astro's own template syntax, and optional `<script>`
; and `<style>` blocks. The frontmatter, the script and the style are handed to
; their own Packs by the injections at the end of this file, so everything a
; question could ask about imports, props, functions and selectors is answered
; there. What is left for this Pack is the markup, and the questions asked of
; it are:
;
;   which components does this page use, and which of them are hydrated
;   what slots does this component declare, and which slot does this fill
;   which element is `#main`
;   what does this page load
;   which frontmatter value is rendered here
;
; Three rules shape every pattern below.
;
; Containment is never stated. The tree already holds it, and an `id` in a page
; is global to the document, so an element's ancestry is not a namespace for
; it. There is no region and no parent/child pattern.
;
; A bare attribute is never stated. An attribute whose name the Pack does not
; recognise answers no question, and one emission per attribute of every page
; was the largest thing the previous Pack produced.
;
; The content of `{...}` is JavaScript this grammar does not parse -- it is one
; `raw_text` token. Storing that token as a name would make every expression in
; a file a reference to nothing, so an expression is stated only when it is a
; single identifier, which is the case where it resolves onto something the
; frontmatter declared.
;
; HTML tag and attribute names are matched case-insensitively, because HTML is;
; an Astro component tag is not, because a capital letter is exactly what tells
; a component from an element.

; --- a component tag ---
;
; Astro tells a component from an element by the capital letter, as JSX and
; Svelte do. `<Ui.Button/>` is reduced to `Ui`, the value the frontmatter
; imported.

([(start_tag (tag_name) @component.name)
  (self_closing_tag (tag_name) @component.name)] @component
 (#match? @component.name "^[A-Z]"))

; --- a hydrated component ---
;
; `client:load`, `client:idle`, `client:visible`, `client:media`, `client:only`
; are Astro's own directives and the reason a component ships JavaScript. The
; emission is named by the component so it resolves onto the same import, and
; spans the directive rather than the tag, so it is a second fact about the
; tag rather than a second copy of the first one.

([(start_tag
    (tag_name) @hydrate.component
    (attribute (attribute_name) @hydrate.directive) @hydrate.attribute)
  (self_closing_tag
    (tag_name) @hydrate.component
    (attribute (attribute_name) @hydrate.directive) @hydrate.attribute)]
 (#match? @hydrate.component "^[A-Z]")
 (#match? @hydrate.directive "^client:"))

; --- a custom element ---
;
; A hyphenated tag name is not HTML's and is not an Astro component either; it
; is a web component defined by `customElements.define("my-widget", ...)`
; somewhere in the project. The use is stated so the definition is reachable
; from it.

([(start_tag (tag_name) @custom.name)
  (self_closing_tag (tag_name) @custom.name)] @custom
 (#match? @custom.name "^[A-Za-z][A-Za-z0-9]*(-[A-Za-z0-9]+)+$"))

; --- a slot this component declares ---
;
; `<slot name="header"/>` is the one extension point an Astro component
; declares, and `slot="header"` on a child of that component fills it.

([(start_tag
    (tag_name) @_slot
    (attribute
      (attribute_name) @_slot_name
      [(attribute_value) @slot.name
       (quoted_attribute_value (attribute_value) @slot.name)]))
  (self_closing_tag
    (tag_name) @_slot
    (attribute
      (attribute_name) @_slot_name
      [(attribute_value) @slot.name
       (quoted_attribute_value (attribute_value) @slot.name)]))] @slot
 (#match? @_slot "^(?i)slot$")
 (#match? @_slot_name "^(?i)name$"))

; --- filling a slot ---
;
; `slot="header"` is stated from the attribute itself: it may sit on any tag,
; including a component's, and the name it carries is the slot declared above.

((attribute
   (attribute_name) @_slot_attribute
   [(attribute_value) @slot.target
    (quoted_attribute_value (attribute_value) @slot.target)]) @slot.fill
 (#match? @_slot_attribute "^(?i)slot$"))

; --- an element that declares an id ---
;
; `id` is the one name the markup itself declares. `href="#main"`, a CSS
; `#main` selector in the `<style>` and `getElementById("main")` in the script
; all resolve onto it.

([(start_tag
    (tag_name) @element.tag
    (attribute
      (attribute_name) @_id
      [(attribute_value) @element.id
       (quoted_attribute_value (attribute_value) @element.id)]))
  (self_closing_tag
    (tag_name) @element.tag
    (attribute
      (attribute_name) @_id
      [(attribute_value) @element.id
       (quoted_attribute_value (attribute_value) @element.id)]))] @element
 (#match? @_id "^(?i)id$"))

; --- what the page loads ---
;
; A script, a stylesheet, an image, a font, a link to another page. A fragment
; and the non-fetching schemes are excluded. A value written `src={img.src}` is
; an `interpolation`, not an `attribute_value`, so it does not bind here and no
; expression is stored as a path.

([(start_tag
    (tag_name) @resource.tag
    (attribute
      (attribute_name) @resource.attribute
      [(attribute_value) @resource.url
       (quoted_attribute_value (attribute_value) @resource.url)]))
  (self_closing_tag
    (tag_name) @resource.tag
    (attribute
      (attribute_name) @resource.attribute
      [(attribute_value) @resource.url
       (quoted_attribute_value (attribute_value) @resource.url)]))] @resource
 (#match? @resource.attribute "^(?i)(src|href|action|poster)$")
 (#not-match? @resource.url "^(?i)(#|javascript:|data:|mailto:|tel:|about:|blob:)"))

; --- a link to an id in this page ---
;
; `href="#main"` is a link to the element declared `id="main"`; the `#` is
; stripped so the two names are the same string. It is stated from the
; attribute, because a fragment link is a fact about the link and not about the
; tag that carries it.

((attribute
   (attribute_name) @_href
   [(attribute_value) @fragment.target
    (quoted_attribute_value (attribute_value) @fragment.target)]) @fragment
 (#match? @_href "^(?i)href$")
 (#match? @fragment.target "^#[^#]"))

; --- an expression that is one identifier ---
;
; `{title}`, `<Card title={heading}/>`, `{posts}`. One `interpolation` node
; covers both the template and the attribute spellings, because the grammar
; gives an attribute value written in braces the same node.

((interpolation (raw_text) @expression.name) @expression
 (#match? @expression.name "^[A-Za-z_$][A-Za-z0-9_$]*$"))

; --- the frontmatter, the script and the style ---
;
; The frontmatter is TypeScript by definition. A `<script>` in an Astro file is
; compiled by Astro and may be TypeScript too, so it is parsed as TypeScript,
; which reads plain JavaScript unchanged. `lang` overrides both.

((frontmatter (raw_text) @injection.content)
 (#set! injection.language "typescript"))

((script_element
   (start_tag) @_script_tag
   (raw_text) @injection.content)
 (#not-match? @_script_tag "(?i)\\blang\\s*=")
 (#set! injection.language "typescript"))

((style_element
   (start_tag) @_style_tag
   (raw_text) @injection.content)
 (#not-match? @_style_tag "(?i)\\blang\\s*=")
 (#set! injection.language "css"))

([(script_element
    (start_tag
      (attribute
        (attribute_name) @_lang
        (quoted_attribute_value (attribute_value) @injection.language)))
    (raw_text) @injection.content)
  (style_element
    (start_tag
      (attribute
        (attribute_name) @_lang
        (quoted_attribute_value (attribute_value) @injection.language)))
    (raw_text) @injection.content)]
 (#match? @_lang "^(?i)lang$"))
