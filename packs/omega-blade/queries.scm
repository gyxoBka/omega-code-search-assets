; omega-blade
;
; Blade is Laravel's template language: a `.blade.php` file is HTML with a
; layer of `@`-directives over it. The questions asked of one are: which
; layout does this view extend, which views does it pull in, where is the
; section this layout yields, what goes on this stack, which component is
; used here, which element is `#main`, what does the page load, and what PHP
; runs inside it. Every pattern below answers one of them.
;
; Three things are deliberately not stated.
;
; Containment. The tree already holds it. There is no pattern for `document`,
; `element`, `conditional`, `loop`, `switch`, `once` or `verbatim` as
; containers, and no `@if`/`@foreach` control-flow emission: a conditional is
; not a name anything resolves to.
;
; The bare directive. The previous Pack emitted every `(directive)` and every
; `(parameter)` in the file, so `@endif` was a reference named `@endif` and
; `$items as $item` was a binding named by its own text. A directive that
; names nothing answers nothing.
;
; Laravel's own directives. `@csrf`, `@method`, `@auth`, `@can`, `@error`,
; `@livewire` and `<livewire:...>` are the framework's vocabulary, not the
; template language's, and belong in `frameworks/omega-framework-laravel`.
; `@extends`, `@section`, `@yield`, `@include`, `@push`, `@stack`,
; `@component` and `<x-...>` are Blade's own and are stated here.
;
; A directive and its argument are *siblings*, not parent and child, and the
; node that wraps them differs by directive -- `@push` makes a `stack`,
; `@component` makes a `conditional`, `@extends` makes nothing at all and sits
; directly under `document`. So the pairs below are anchored sibling pairs
; under a wildcard parent, which is what the grammar actually gives, and is
; why the previous Pack's `(section (directive) (parameter))` patterns for
; `@extends`, `@yield`, `@include` and `@component` matched nothing.
;
; Every name is unquoted and cut at the first comma in the rules, so
; `@yield('content')` and `@section('content')` are the same string.

; --- a section this view defines ---
;
; `@section('content') ... @endsection` and the inline
; `@section('title', 'Dashboard')`. A layout's `@yield('content')` resolves
; onto it. The second argument is bound only in the inline form -- anchored,
; so a nested directive's parameter inside a block section cannot supply it --
; and is carried on the declaration as its text rather than emitted on its own.

((section
   [(directive) (directive_start)] @section.directive .
   (parameter) @section.name .
   (parameter)? @section.value) @section
 (#match? @section.directive "^@section$"))

; --- content pushed onto a named stack ---
;
; `@push('scripts') ... @endpush` is where the content of `@stack('scripts')`
; is written.

((stack
   (directive_start) @push.directive .
   (parameter) @push.name) @push
 (#match? @push.directive "^@(push|pushOnce|prepend|prependOnce|pushIf)$"))

; --- the section a layout asks for ---
;
; `@yield('content')`, and the two tests that name a section without
; rendering it.

((_ [(directive) (directive_start)] @yield.directive .
    (parameter) @yield.name)
 (#match? @yield.directive "^@(yield|hasSection|sectionMissing)$"))

; --- the stack a layout renders ---

((_ (directive) @stack.directive .
    (parameter) @stack.name)
 (#match? @stack.directive "^@stack$"))

; --- another view this one needs ---
;
; `@extends` is the layout; `@include` and its variants, and `@each`, pull a
; partial in. Both are a dependency on another template file, and the
; directive that produced it is kept so the two can be told apart.

; Only the directives whose FIRST argument is the view. `@includeWhen` and
; `@includeUnless` put the condition first and the view second, and
; `@includeFirst` takes an array of views -- measured, those three emitted
; `$user->isAdmin`, `$guest` and `['custom.admin'` as the templates depended on.
; They are stated by the pattern below, or not at all.

((_ (directive) @view.directive .
    (parameter) @view.target)
 (#match? @view.directive "^@(extends|include|includeIf|each)$"))

; `@includeWhen($cond, 'view')` and `@includeUnless($cond, 'view')`: the view is
; the second argument, so the first is skipped rather than named.

((_ (directive) @view.conditional.directive .
    (parameter)
    (parameter) @view.target)
 (#match? @view.conditional.directive "^@include(When|Unless)$"))

; --- a component ---
;
; Blade has two spellings. `@component('components.layout')` names a view;
; `<x-forms.input />` names the component `forms.input`, which Laravel
; resolves to either a class or an anonymous view. The `x-` is stripped in
; the rules so the tag and the component's own name are the same string.

((_ [(directive) (directive_start)] @component.directive .
    (parameter) @component.target)
 (#match? @component.directive "^@component$"))

([(start_tag (tag_name) @component.tag)
  (self_closing_tag (tag_name) @component.tag)]
 (#match? @component.tag "^(?i)x-[A-Za-z0-9][A-Za-z0-9._-]*$"))

; --- the HTML underneath ---
;
; A Blade file is the only place Omega sees this markup: omega-html never
; opens a `.blade.php`. The three HTML facts another language looks up by
; string are stated, and nothing else about an element is.

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

; `name` on a form control is the key the controller reads out of the request.

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

; What the page loads: a script, a stylesheet, an image, a form target.
; Fragments and the non-fetching schemes are excluded; a fragment is a
; reference to an id and is stated as one below. A value that is entirely a
; Blade expression parses as `php_statement`, not `attribute_value`, so
; `href="{{ route('home') }}"` binds nothing here and is not stated.

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

; `href="#main"` links to the element declared `id="main"`; the `#` is
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

; `for`, `form` and `list` hold an id and nothing else.

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

; --- embedded languages ---
;
; `{{ $user->name }}`, `{!! $html !!}`, `@php ... @endphp` and `<?php ?>` all
; parse to `php_statement (php_only)`, and the PHP inside states its own
; facts. `<script>` and `<style>` feed omega-javascript and omega-css.

((php_statement (php_only) @injection.content)
 (#set! injection.language "php"))

((script_element
   (start_tag) @_script_tag
   (raw_text) @injection.content)
 (#not-match? @_script_tag "\\s(lang|type)\\s*=")
 (#set! injection.language "javascript"))

((style_element
   (start_tag) @_style_tag
   (raw_text) @injection.content)
 (#not-match? @_style_tag "\\s(lang|type)\\s*=")
 (#set! injection.language "css"))
