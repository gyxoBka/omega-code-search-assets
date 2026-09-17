; omega-css
;
; CSS is the presentation layer of a project. The questions asked of a
; stylesheet are: where is `.btn` styled, where is `--brand-color` set and who
; reads it, which animation is `spin` and where is it used, and what files does
; this stylesheet pull in. Every pattern below answers one of them.
;
; Four things are deliberately not stated.
;
; The syntax-highlighting model. The previous Pack was an nvim-treesitter
; `highlights.scm` wired to templates: every keyword, operator, unit, number,
; string and `!important` in every stylesheet became an emission named by its
; own text. A colour is not a name and `>` resolves against nothing.
;
; The ordinary property declaration. `color: red` names a property of CSS
; itself, not anything this repository declares, so a mention of it resolves
; against nothing. Only a custom property -- which the repository does declare
; and `var()` does reference -- is stated.
;
; Tag names, pseudo-classes and attribute selectors, for the same reason: they
; name HTML's vocabulary. A CSS function call other than `var()` and `url()` is
; a call to a built-in and has no declaration anywhere to resolve to.
;
; Containment. The tree already holds it. There is no pattern for `stylesheet`,
; `rule_set`, `block`, `selectors` or any combinator, and no pattern that
; descends two node types to say one sits inside the other.

; --- a class ---
;
; `.btn { }` is the only place in a repository where a class name is declared;
; HTML and JSX spell it in a `class`/`className` string, which no Pack declares.
; The span is the selector, not the rule: `.card .btn`, `.btn.large` and a
; second rule for `.btn` in another file are all declarations of it, and CSS
; has no one site among them.

(class_selector (class_name) @class.name) @class

; --- an id ---
;
; An id is declared by the HTML element that carries it (omega-html emits
; `definition.element_id` named without the `#`). `#main { }` styles that
; element, so it is a reference to it, under the same spelling.

(id_selector (id_name) @id.name) @id

; --- a custom property ---
;
; `--brand: #2b6;` is a declaration, and its value is the answer to the only
; question asked of it. The value is taken as the declaration's text with the
; property name, the colon and the terminator removed, so a multi-token value
; (`--pad: 4px 8px`) is kept whole rather than truncated to its first token.

((declaration (property_name) @custom.name) @custom
 (#match? @custom.name "^--"))

; `var(--brand, fallback)`: the first argument is the name, anchored so a
; fallback is not mistaken for one. It is spelled exactly as the declaration
; spells it, dashes included, so the two resolve onto each other.

((call_expression
   (function_name) @_var
   (arguments . (plain_value) @custom.ref.name)) @custom.ref
 (#match? @_var "^(?i)var$")
 (#match? @custom.ref.name "^--"))

; --- what the stylesheet pulls in ---
;
; `url(...)` is every file a stylesheet loads: a font, an image, a mask, and
; the target of `@import url("theme.css")` and `@namespace url(...)`. One
; pattern covers all of them, quoted or bare.

((call_expression
   (function_name) @_url
   (arguments . [(string_value) (plain_value)] @url.target)) @url
 (#match? @_url "^(?i)url$"))

; `@import "theme.css" screen;` -- the other spelling, where the target is the
; statement's own first child and no `url()` is written.

(import_statement . (string_value) @import.target) @import

; --- an animation ---

(keyframes_statement (keyframes_name) @keyframes.name) @keyframes

; `animation-name: spin` and the `animation: spin 2s linear` shorthand. In the
; shorthand the name sits among CSS's own timing, direction and fill keywords,
; which are excluded by name: they are the language's vocabulary, not a
; library's. Durations and easing functions are not `plain_value` and need no
; exclusion. `animation-name: a, b` names two animations and both are stated,
; which is why this is not anchored.

((declaration (property_name) @_anim (plain_value) @animation.name) @animation
 (#match? @_anim "^(?i)animation(-name)?$")
 (#not-any-of? @animation.name
   "none" "initial" "inherit" "unset" "revert" "revert-layer"
   "normal" "reverse" "alternate" "alternate-reverse"
   "forwards" "backwards" "both" "running" "paused" "infinite"
   "linear" "ease" "ease-in" "ease-out" "ease-in-out"
   "step-start" "step-end"))

; --- a font the stylesheet defines ---
;
; `@font-face { font-family: "Inter"; src: url(...) }` declares a family name
; that `font-family: Inter` elsewhere uses. The first value after the property
; name is the family; the `src` is already stated by the `url()` pattern.

((at_rule
   (at_keyword) @_at
   (block
     (declaration (property_name) @_family . [(string_value) (plain_value)] @font.name))) @font
 (#match? @_at "^(?i)@font-face$")
 (#match? @_family "^(?i)font-family$"))

; --- a namespace prefix ---
;
; `@namespace svg url(...)` binds a prefix used by `svg|circle` selectors.

(namespace_statement (namespace_name) @namespace.name) @namespace
