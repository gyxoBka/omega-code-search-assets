# omega-blade

Language `omega-blade`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

13 templates over 15 query patterns, 8 distinct pattern roots: `section`,
`stack`, `php_statement`, `script_element`, `style_element`, the
`start_tag`/`self_closing_tag` alternation, and the wildcard parent of a
directive/parameter pair.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 5 |
| `references` | yes | 8 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.template_section` | Value | 1 |
| `definition.template_stack` | Value | 1 |
| `definition.element_id` | Value | 1 |
| `definition.form_field` | Value | 1 |

### Carriers

| kind | folds onto | as |
|---|---|---|
| `definition.text_candidate` | the `definition.template_section` at the same span | `omega.pack.text` |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 2 |
| `reference.template_section` | reference | 1 |
| `reference.template_stack` | reference | 1 |
| `reference.blade_component` | reference | 2 |
| `reference.element_id` | reference | 2 |

### Injections

`php` from `php_statement (php_only)` — `{{ }}`, `{!! !!}`, `@php ... @endphp`
and `<?php ?>` are all that node. `javascript` and `css` from a `<script>` or
`<style>` that carries no `type` or `lang`.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 39 node types. The Pack looks at 17 of them:
`attribute`, `attribute_name`, `attribute_value`, `quoted_attribute_value`,
`directive`, `directive_start`, `parameter`, `section`, `stack`,
`php_statement`, `php_only`, `start_tag`, `self_closing_tag`, `tag_name`,
`script_element`, `style_element`, `raw_text`.

Untouched, and why:

- `document`, `element`, `end_tag` — containment, which the tree already holds.
- `conditional`, `loop`, `switch`, `once`, `verbatim`, `fragment`, `keyword`,
  `conditional_keyword`, `directive_end` — control flow and block terminators.
  `@if`, `@foreach` and `@endsection` are not names anything resolves to. The
  wrapper node types are still *reached* as the wildcard parent of a
  directive/parameter pair; they are not stated as facts of their own.
- `livewire`, `envoy` — a package's and a deployment tool's vocabulary, not the
  template language's; a framework overlay's business.
- `text`, `comment`, `entity`, `doctype`, `php_tag`, `php_end_tag` — prose,
  markup punctuation and the delimiters of an injection.
- `erroneous_end_tag`, `erroneous_end_tag_name` — error recovery.

## What is wrong with it

**Five of the twelve templates were bound to a pattern that cannot match, and
a sixth matched only a corner of its construct.** This is Defect M, and it is
the whole of the Pack's Blade coverage. In tree-sitter-blade a directive and
its argument are *siblings*, and the node that wraps them differs by
directive: `@push` makes a `stack`, `@component` makes a `conditional`,
`@section` makes a `section`, and `@extends`, `@include`, `@yield`, `@stack`
and `@livewire` make no wrapper at all and sit directly under `document` or
under whatever element contains them. The old Pack wrote all six of its Blade
patterns as `(section (directive) (parameter))` or `(stack (directive)
(parameter))`. Checked against the pinned grammar with a Blade file
containing every one of these directives:

| template | kind | matches |
|---|---|---|
| `reference.blade_yield` | `@yield` under `section` | none, ever |
| `import.blade_extends` | `@extends` under `section` | none, ever |
| `reference.blade_include` | `@include*`, `@each` under `section` | none, ever |
| `reference.blade_component` | `@component`, `@livewire` under `section` | none, ever |
| `reference.blade_stack` | `@stack`, `@push`, `@prepend` under `stack` with a `directive` | none, ever — a `@push` block opens with `directive_start` |
| `definition.blade_section` | `@section` under `section` with a `directive` | only the inline `@section('a', 'b')` form; the block `@section('x') … @endsection` opens with `directive_start` and was never declared |

So the Pack declared nothing in the ordinary Blade file, and its `references`
and `imports` capabilities were programs that never ran — while the manifest
went on claiming them.

**And the one pattern that did fire, fired twice and declared the wrong
thing.** The section pattern was unanchored, so `@section('title',
'Dashboard')` — two `parameter` siblings — matched once per parameter and
declared two sections, one named `'title'` and one named `' 'Dashboard''`.

**Every name kept its quotes.** All six Blade templates named their emission
with a bare `capture_ref` over the `parameter`, whose text is `'layouts.app'`,
apostrophes included. Even where a pattern had matched, `@yield('content')`
and `@section('content')` would have been the strings `'content'` and
`'content'` — identical here by luck, but `@include('partials.header',
['user' => $user])` is one `parameter` whose whole text, array literal and
all, would have been the name of the view it depends on. Nothing was cut at
the comma and nothing was unquoted.

**Three templates were the universal capture in another spelling.**
`(parameter) @binding.symbol` stored every directive argument in the file as a
binding named by its own source text — `$items as $item`, `$user->isAdmin`,
`['title']`. `(directive) @blade.directive` and the nvim highlights fragment
`[(directive) (directive_start) (directive_end)] @tag` stored every directive
*token*: `@endif`, `@else`, `@endforeach`, three times over in the second
case, since the same node fed both. That is three emissions per directive of
every Blade file in a repository, all of them references to nothing.

**Two more stored every attribute of every element.** `data.blade_attribute_
name_context` and `data.blade_attribute_value_context` emitted once per
`(attribute)` and once per attribute with a value, named `class`, `id`,
`wire:model`, `x-data`. omega-html deleted exactly these and recorded that the
bare attribute was the largest thing that Pack produced.

**One template was a framework overlay.** `data.blade_named_directive` listed
`@auth`, `@guest`, `@can`, `@cannot`, `@canany`, `@env`, `@production`,
`@csrf`, `@method`, `@error`, `@props`, `@aware` — Laravel's directives, not
Blade's — and emitted the directive token as a reference named by itself.

**Twelve mention kinds, one occurrence.** Every kind above arrives as a plain
`reference` except `import.blade_extends`, which becomes a binding. Not one
`relation.*` kind, so the dependency a `.blade.php` file has on its layout and
its partials — the most useful thing in the file — was stated as an
unclassified mention.

**Two of three guards were labels or provenance.**
`binding_nodes_are_syntactic_candidates_not_resolved_values` is Defect G in
its pure form. The second guard says "Editor highlighting captures are
syntax-role evidence" and then describes the release compile gate: it is the
Pack admitting that its `@tag` pattern came from a highlighting baseline, not
a limitation of Blade a query can act on.

**The HTML underneath was never reached.** `start_tag`, `self_closing_tag`,
`tag_name`, `script_element`, `style_element` and `raw_text` were all
untouched. A `.blade.php` file is the only place Omega sees this markup —
omega-html never opens one — so `id="main"`, `name="email"` and
`<script>` were invisible for the whole of a Laravel project's view layer.

**Counts.** 12 templates over 13 patterns and 3 guards, of which 5 templates
emitted nothing at all, 1 emitted a duplicate and a corrupted name, 6 emitted
once per token or per attribute of every file, and 0 declared anything in a
Blade file written the ordinary way.

## What it should extract

Blade is Laravel's template language: `resources/views/**/*.blade.php`, HTML
with a layer of `@`-directives over it. The questions asked of one are *which
layout does this view extend*, *which partials does it pull in*, *where is the
section this layout yields*, *what goes on this stack*, *which component is
used here*, *which element is `#main`*, *what does the page load*, and *what
PHP runs inside it*.

| what | node | emitted as | family |
|---|---|---|---|
| `@section('x') … @endsection`, `@section('x', 'v')` | `section` + anchored `directive`/`directive_start` and `parameter` | `definition.template_section` | Value |
| the inline section's second argument | the second anchored `parameter` | `definition.text_candidate` carrier on that section | attribute |
| `@push('x') … @endpush`, `@prepend`, `@pushOnce` | `stack` + `directive_start` and `parameter` | `definition.template_stack` | Value |
| `@yield('x')`, `@hasSection`, `@sectionMissing` | any parent + anchored `directive`/`directive_start` and `parameter` | `reference.template_section` | reference |
| `@stack('x')` | any parent + anchored `directive` and `parameter` | `reference.template_stack` | reference |
| `@extends`, `@include*`, `@each` | any parent + anchored `directive` and `parameter` | `relation.depends` | depends |
| `@component('x')` | any parent + anchored `directive`/`directive_start` and `parameter` | `reference.blade_component` | reference |
| `<x-forms.input/>` | `tag_name` on `start_tag`/`self_closing_tag` | `reference.blade_component` | reference |
| `id="main"` | `attribute` under a tag | `definition.element_id` | Value |
| `name="email"` on a control | `attribute` under a tag | `definition.form_field` | Value |
| `src`, `href`, `action`, `poster` | `attribute` under a tag | `relation.depends` | depends |
| `href="#main"`, `for=`, `form=`, `list=` | `attribute` under a tag | `reference.element_id` | reference |
| `{{ }}`, `{!! !!}`, `@php … @endphp` | `php_statement (php_only)` | php injection | — |
| `<script>`, `<style>` without `type`/`lang` | `raw_text` | javascript, css injections | — |
| `@if`, `@foreach`, `@switch`, `@once`, `@verbatim` | `conditional`, `loop`, … | nothing | — |
| `@csrf`, `@method`, `@can`, `@auth`, `@error`, `@livewire` | `directive` | nothing — framework overlay | — |

Two design decisions carry the rewrite.

**A directive and its argument are anchored siblings under a wildcard
parent.** `(_ [(directive) (directive_start)] @d . (parameter) @p)` with a
`#match?` on `@d` is what the grammar actually gives, and it is the same
pattern whether the directive was wrapped in a `section`, a `stack`, a
`conditional` or nothing at all. The wildcard is not Defect I: it carries no
capture of its own and only matches a parent that holds that adjacency, so its
cost is one match per directive-with-an-argument, not one per node. The
anchor is not cosmetic — unanchored, a block `@section('content')` would pick
up the `parameter` of any `@if` nested directly inside it.

**Every name is cut at the first comma and unquoted.** One chain —
`first(split(…, ","))`, `trim`, then `strip_prefix`/`strip_suffix` for both
quote styles, each a no-op when its affix is absent — turns `'content'` into
`content` and `'partials.header', ['user' => $user]` into `partials.header`.
That is what makes `@yield('content')` resolve onto `@section('content')`,
and `@extends('layouts.app')` onto whatever declares `layouts.app`. The old
Pack could not have resolved a single one of these even had its patterns
matched.

## Where the boundary with Laravel was drawn

Blade's own vocabulary is template composition: `@extends`, `@section`,
`@yield`, `@include`, `@push`, `@stack`, `@component`, `@props`, `@php`, and
the `<x-...>` component tag. Those are stated. `@csrf`, `@method`, `@can`,
`@auth`, `@guest`, `@env`, `@error` and `@livewire` are directives Laravel and
its packages register with Blade; `<livewire:search-users/>` is Livewire's tag.
Those name policies, gates, HTTP verbs and components a framework resolves, and
under §14 of the brief they belong in `frameworks/omega-framework-laravel`, not
here. The laravel overlay matches on nothing this Pack emitted before or emits
now, so nothing breaks; a Livewire or Blade-directive overlay is a gap this
rewrite leaves open and does not fill.

## The audit's remaining flag, and why it is right here

`python pack-design/audit.py omega-blade` reports one class:

```
carrier under a name nothing assembles 1
   omega.pack.text (definition.text_candidate)
```

The five carried names the signature line is built from are `visibility`,
`type_parameter_shape`, `parameter_shape`, `return_type` and `modifier`. A
Blade section has none of those: `@section('title', 'Dashboard')` sets the
section's whole content to a string, and the fact worth keeping is that the
section named `title` holds `Dashboard`. The carrier is the correct shape for
it — one attribute on the declaration at the same span, rather than a second
emission a resolver would try and fail to resolve — and it is exactly what
omega-xml does with a leaf element's text. The value is stored as
`omega.pack.text` and read back from the declaration's attribute bag; it is
not meant to reach the signature line.

## Licence

The old Pack shipped a `NOTICE` deriving query fragments from nvim-treesitter
and declared `license = "MIT AND Apache-2.0"` on that basis. The one derived
fragment was `[(directive) (directive_start) (directive_end)] @tag`, a
highlights capture, and it is gone. No line of the rewritten `queries.scm`
comes from that baseline, so the `NOTICE` is deleted and the licence reverts
to `MIT`, as omega-twig and omega-json5 did.

## Still to decide

1. **`@props(['title', 'color' => 'red'])`.** This is how an anonymous
   component declares its interface, and each name in it is something a
   `<x-alert color="red">` attribute should resolve onto. The grammar leaves
   the whole array as one `parameter` token, and picking names out of PHP
   array syntax with `split`/`strip_prefix` would get `'color' => 'red'` wrong
   more often than right. Not stated; a guard says so. The honest fix is the
   php injection reading it, which needs the injection to be opened on a
   directive argument rather than on a `php_statement`.
2. **Whether `<x-forms.input/>` should keep its `x-` prefix.** It is stripped,
   so the name is `forms.input` — closer to both
   `resources/views/components/forms/input.blade.php` and
   `App\View\Components\Forms\Input`, and the same string
   `@component('components.forms.input')` reduces to only after its
   `components.` segment is also dropped, which it is not. Neither spelling
   resolves without knowing the project's view paths; stripping is the closer
   of the two and the guard records that neither is resolved.
3. **A `scope` for a section or a loop.** Not emitted: the section
   declaration's own span already covers `@section … @endsection`, and a
   `@foreach` body is not a namespace — Blade has no lexical scope, and a
   variable in a view comes from the controller.
