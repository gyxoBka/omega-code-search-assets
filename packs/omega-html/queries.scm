; omega-html
;
; HTML is the page and template layer of a project. The questions asked of an
; HTML file are: what does this page load, which element is `#main`, where is
; the form field the server reads, which component is used here, and what does
; the page say about itself. Every pattern below answers one of them.
;
; Two things are deliberately not stated.
;
; Containment. The tree already holds it, and an `id` in HTML is global to the
; document, so an element's ancestry is not a namespace for it. There is no
; scope region and no parent/child pattern.
;
; The bare attribute. An attribute whose name the Pack does not recognise
; answers no question, and one emission per attribute of every page -- named by
; the tag it sat on -- was the largest thing the previous Pack produced.
;
; Tag and attribute names are matched case-insensitively, because HTML is:
; `<INPUT NAME=x>` is the same declaration as `<input name=x>`. An attribute
; value is taken from inside the quotes when there are quotes, and from the
; bare token when there are not.

; --- an element that declares an id ---
;
; `id` is the one name HTML itself declares. `href="#main"`, `for="email"`, a
; CSS `#main` selector and `getElementById("main")` all resolve onto it.

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

; --- a form control's name ---
;
; `name` on a control is the key the server reads out of the request. It is the
; one HTML name that code in another language looks up by string.

([(start_tag
    (tag_name) @field.tag
    (attribute
      (attribute_name) @_name
      [(attribute_value) @field.name
       (quoted_attribute_value (attribute_value) @field.name)]))
  (self_closing_tag
    (tag_name) @field.tag
    (attribute
      (attribute_name) @_name
      [(attribute_value) @field.name
       (quoted_attribute_value (attribute_value) @field.name)]))] @field
 (#match? @_name "^(?i)name$")
 (#match? @field.tag "^(?i)(input|select|textarea|button|output|fieldset|form)$"))

; --- what the page says about itself ---
;
; `<meta name=... content=...>`, and the `property=` and `http-equiv=`
; spellings of the same pair. The key attribute must come first and `content`
; must follow it directly: anchored, this is one match per start tag instead of
; one per pair of attributes on every start tag in the file.

([(start_tag
    (tag_name) @_meta .
    (attribute
      (attribute_name) @_key
      [(attribute_value) @meta.key
       (quoted_attribute_value (attribute_value) @meta.key)]) .
    (attribute
      (attribute_name) @_content
      [(attribute_value) @meta.content
       (quoted_attribute_value (attribute_value) @meta.content)]))
  (self_closing_tag
    (tag_name) @_meta .
    (attribute
      (attribute_name) @_key
      [(attribute_value) @meta.key
       (quoted_attribute_value (attribute_value) @meta.key)]) .
    (attribute
      (attribute_name) @_content
      [(attribute_value) @meta.content
       (quoted_attribute_value (attribute_value) @meta.content)]))] @meta
 (#match? @_meta "^(?i)meta$")
 (#match? @_key "^(?i)(name|property|http-equiv)$")
 (#match? @_content "^(?i)content$"))

; --- the page's own name, and its sections ---
;
; Anchored on both sides: the text is stated only when the element's whole
; content is that one text node. `<h1>Hello <em>you</em></h1>` has three
; children and no single name to give.

((element
   (start_tag (tag_name) @_title) .
   (text) @title.text .
   (end_tag)) @title
 (#match? @_title "^(?i)title$"))

((element
   (start_tag (tag_name) @heading.tag) .
   (text) @heading.text .
   (end_tag)) @heading
 (#match? @heading.tag "^(?i)h[1-6]$"))

; --- what the page loads ---
;
; A script, a stylesheet, an image, an iframe, a form target, a link to another
; page. Fragments and the non-fetching schemes are excluded here; a fragment is
; a reference to an id and is stated as one below.

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
 (#match? @resource.attribute "^(?i)(src|href|action|formaction|poster)$")
 (#not-match? @resource.url "^(?i)(#|javascript:|data:|mailto:|tel:|about:|blob:)"))

; --- a reference to an id in this document ---
;
; `href="#main"` is a link to the element declared `id="main"`; the `#` is
; stripped so the two names are the same string.

([(start_tag
    (attribute
      (attribute_name) @_href
      [(attribute_value) @fragment.target
       (quoted_attribute_value (attribute_value) @fragment.target)]))
  (self_closing_tag
    (attribute
      (attribute_name) @_href
      [(attribute_value) @fragment.target
       (quoted_attribute_value (attribute_value) @fragment.target)]))] @fragment
 (#match? @_href "^(?i)href$")
 (#match? @fragment.target "^#[^#]"))

; `for`, `form` and `list` hold an id and nothing else: `<label for="email">`
; is the label of the control declared `id="email"`.

([(start_tag
    (attribute
      (attribute_name) @idref.attribute
      [(attribute_value) @idref.target
       (quoted_attribute_value (attribute_value) @idref.target)]))
  (self_closing_tag
    (attribute
      (attribute_name) @idref.attribute
      [(attribute_value) @idref.target
       (quoted_attribute_value (attribute_value) @idref.target)]))] @idref
 (#match? @idref.attribute "^(?i)(for|form|list)$"))

; --- a custom element ---
;
; A tag name with a hyphen is not HTML's; it is a component defined elsewhere,
; by `customElements.define("my-widget", ...)` or by a framework's registry.
; The use is stated so the definition can be found from it.

([(start_tag (tag_name) @custom.element)
  (self_closing_tag (tag_name) @custom.element)]
 (#match? @custom.element "^[A-Za-z][A-Za-z0-9]*(-[A-Za-z0-9]+)+$"))

; --- embedded languages ---
;
; These feed the injection layer, not a template: the JavaScript in a
; `<script>` is parsed by omega-javascript and states its own facts.

((style_element
   (start_tag) @_style_tag
   (raw_text) @injection.content)
 (#not-match? @_style_tag "\\s(lang|type)\\s*=")
 (#set! injection.language "css"))

((script_element
   (start_tag) @_script_tag
   (raw_text) @injection.content)
 (#not-match? @_script_tag "\\s(lang|type)\\s*=")
 (#set! injection.language "javascript"))

; `type="module"`, `type="text/css"`, `type="importmap"`: the value names the
; language, and the Pack's alias table maps the media types onto a grammar.

([(script_element
    (start_tag
      (attribute
        (attribute_name) @_type
        (quoted_attribute_value (attribute_value) @injection.language)))
    (raw_text) @injection.content)
  (style_element
    (start_tag
      (attribute
        (attribute_name) @_type
        (quoted_attribute_value (attribute_value) @injection.language)))
    (raw_text) @injection.content)]
 (#match? @_type "^(?i)(type|lang)$"))

; An `onclick="..."` handler is a JavaScript program of its own.

((attribute
   (attribute_name) @_handler
   (quoted_attribute_value (attribute_value) @injection.content))
 (#match? @_handler "^(?i)on[a-z]+$")
 (#set! injection.language "javascript"))
