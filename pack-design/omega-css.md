# omega-css

Language `omega-css`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

10 templates over 10 query patterns, 8 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 5 |
| `references` | yes | 5 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.style_classname` | Value | 1 |
| `definition.custom_property` | Value | 1 |
| `definition.keyframes_animation` | Value | 1 |
| `definition.font_family` | Value | 1 |
| `definition.namespace_prefix` | Namespace | 1 |

`definition.custom_property` carries one attribute, `value`: the declaration's
own text with the property name, the colon and the terminator removed, so
`--pad: 4px 8px` keeps both tokens.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `reference.element_id` | reference | 1 |
| `reference.custom_property` | reference | 1 |
| `reference.keyframes_animation` | reference | 1 |
| `relation.depends` | depends | 2 |

No carriers, no scopes, no injections, no decoders. Five coverage guards.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 64 node types. The Pack looks at 19 of them: `at_rule`,
`at_keyword`, `block`, `arguments`, `call_expression`, `class_selector`,
`class_name`, `declaration`, `function_name`, `id_selector`, `id_name`,
`import_statement`, `keyframes_statement`, `keyframes_name`,
`namespace_statement`, `namespace_name`, `plain_value`, `property_name`,
`string_value`.

Untouched, and why each is right to leave alone:

- The selector combinators and the selector container -- `selectors`,
  `rule_set`, `descendant_selector`, `child_selector`, `adjacent_sibling_selector`,
  `sibling_selector`, `namespace_selector`, `nesting_selector`,
  `universal_selector`, `stylesheet`, `block`. These are containment, which the
  tree already holds; a pattern per combinator is Defect E.
- The vocabularies that are not this repository's -- `tag_name`,
  `pseudo_class_selector`, `pseudo_element_selector`, `attribute_selector`,
  `attribute_name`, `feature_name`, `keyword_query`. `div`, `:hover` and
  `max-width` are HTML's and CSS's own names and resolve against nothing.
- The literals and the arithmetic -- `color_value`, `integer_value`,
  `float_value`, `unit`, `important`, `important_value`, `grid_value`,
  `binary_expression`, `parenthesized_value`, `string_content`,
  `escape_sequence`, `identifier`. A colour is not a name. The Pack emits no
  `reference_context.*` kind, so `literal.*` templates here would suppress
  nothing and are the pure cost the brief describes (§5).
- The conditional statements -- `media_statement`, `supports_statement`,
  `scope_statement`, `feature_query`, `binary_query`, `unary_query`,
  `parenthesized_query`, `selector_query`. A rule inside
  them is stated exactly like one outside; guard 2 says so.
- `keyframe_block`, `keyframe_block_list`, `from`, `to` -- the steps of an
  animation. The animation is declared and referenced by name; `0%` and `to`
  name nothing.
- `charset_statement`, `postcss_statement`, `comment`, `js_comment` -- an
  encoding declaration, a preprocessor's leftovers, and prose.

## What is wrong with it

Measured on the Pack as found: **32 templates over 34 patterns, 6 guards, 31 of
the grammar's 64 node types touched.**

**Nineteen of 32 templates were an editor's highlighting model.** The file
carried an nvim-treesitter `highlights.scm` verbatim, under a provenance header
naming the snapshot and its sha256 -- and then wired every one of its captures
to a template. `semantic_hint.css_lexical_role` (7), `semantic_hint.css_member`
(3), `semantic_hint.css_literal` (3), `semantic_hint.css_value` (2),
`semantic_hint.css_module` (2), `semantic_hint.css_type` (1),
`semantic_hint.css_callable` (1). Every keyword, operator, unit, number,
string, comment, `!important`, tag name and pseudo-class in every stylesheet
became one emission named by **its own source text** -- `>` , `2px`, `and`,
`solid`, and the body of every comment, each stored as a reference that resolves
against nothing. This is the whole of the `data` capability: 20 of 32 templates.
Six of them are Defect D2 outright, which is all the audit could see of it.

**Two constructs were declared twice each, on the same bytes.** One pattern
captured the same node under two names --
`(call_expression ...) @css.call @css.function.call` and
`(keyframes_statement ...) @css.keyframes @css.keyframes.strong` -- and
`rules.json` ran a template over each. Every `@keyframes spin` was two
identical declarations of `spin`, and every function call two calls. The audit's
K2 check cannot see it, because the two name captures are spelled differently
while pointing at the same node.

**Two carriers the host will not fold, naming themselves with a whole
statement.** `import.css_candidate` and `module.css_candidate` are named from
`(import_statement)` and `(namespace_statement)` entire -- so the name of the
emission was the text `@import url("vendor/reset.css") screen;`. Both start
with `import`/`module`, neither contains `definition`, so `is_definition_kind`
is false and the fold never happens; both would carry `omega.pack.css`, a name
nothing in the engine assembles. Three defect classes stacked in two templates.

**A CSS class was filed as a Type.** `definition.css_class_selector` splits to
`[definition, css, class, selector]` and `class` wins, so every `.btn` in the
repository sat in the Type family beside the structs and interfaces of every
compiled language. There are more class selectors in a front-end repository
than declarations of any other sort.

**Two templates stated calls to built-ins.** `call.css_function` fired on every
`rgba()`, `calc()`, `translate()` and `format()`. Plain CSS has no user-defined
functions, so not one of these could ever resolve to a declaration.

**One template stated every property declaration.** `data.css_declaration`,
named by the property name: one emission per line of every stylesheet, naming
CSS's own vocabulary.

**The injection was to a language that does not exist here.**
`((comment) @injection.content (#set! injection.language "comment"))` is
nvim-treesitter's comment-tag parser; no grammar in this repository provides
it. It came with a 24-entry alias table mapping `php`, `sql`, `graphql` and
twenty more onto grammars, in a language that can contain none of them.

**Six guards, one of them a label** (`css_highlight_capture_not_symbol_truth`),
and four of the other five describing the absent `imports`/`modules` resolver
in the generator's own vocabulary ("the generic bounded source symbol/import
resolver for project-local identity and alias resolution") rather than naming
anything an agent could act on.

**Four of six declared capabilities have gone**: `calls`, `data`, `imports`
and `modules` were programmed only by the templates above.

## What it should extract

CSS is the presentation layer. The questions asked of a stylesheet are: where
is `.btn` styled, where is `--brand-color` set and who reads it, which
animation is `spin` and where is it used, which font does this project ship,
and what files does this stylesheet pull in.

| what | node | emitted as | family |
|---|---|---|---|
| a class selector | `class_selector` via `class_name` | `definition.style_classname` | Value |
| an id selector | `id_selector` via `id_name` | `reference.element_id` | occurrence |
| a custom property | `declaration` via `property_name` matching `^--` | `definition.custom_property`, with its value as an attribute | Value |
| `var(--x)` | `call_expression` named `var`, first argument | `reference.custom_property` | occurrence |
| `url(...)` | `call_expression` named `url`, first argument | `relation.depends` | depends |
| `@import "x.css"` | `import_statement` via its own first `string_value` | `relation.depends` | depends |
| `@keyframes spin` | `keyframes_statement` via `keyframes_name` | `definition.keyframes_animation` | Value |
| `animation[-name]: spin` | `declaration` via `plain_value` | `reference.keyframes_animation` | occurrence |
| `@font-face { font-family: X }` | `at_rule` via `block > declaration` | `definition.font_family` | Value |
| `@namespace svg url(...)` | `namespace_statement` via `namespace_name` | `definition.namespace_prefix` | Namespace |
| selectors, combinators, properties, literals, at-rule conditions | -- | nothing | -- |

Three of these cross a language boundary, and the spelling is chosen so that
they resolve:

- **id.** omega-html declares `definition.element_id` named without the `#`;
  omega-css strips the `#` too, so `#main { }` is a reference to the element
  that declares `id="main"`, and CSS does not declare it a second time. CSS
  does not style an id it invents.
- **class.** Nothing else in the repository declares a class name -- HTML and
  JSX spell it inside a `class`/`className` string, and neither Pack states a
  bare attribute -- so the CSS selector is the declaration, and the resolver
  merges the many sites by name.
- **custom property.** The declaration and the `var()` reference are both kept
  with their leading `--`, so the two strings are equal.

`definition.style_classname` is spelled to avoid the whole word `class` on
purpose: `entity_family` would put every class selector in a front-end
repository into the Type family, ahead of the language's real types. A CSS
class is a named style, which is what Value means.

## Still to decide

1. **A class has many declaration sites and no canonical one.** The span is the
   selector, not the rule set, because a rule set may carry several selectors
   and a selector may name several classes (`.card .btn`), so no single rule is
   "the" definition of `.btn`. The consequence is that a card for `.btn` shows
   `.btn` and not the declarations it sets. Taking the rule set as the span
   instead would show the body but needs an alternation per combinator to reach
   a nested class name, which is Defect E. Left as the selector; revisit if the
   cards read poorly.
2. **A custom property does not record the rule it sits in.** `--bg` in `:root`
   and `--bg` in `.dark` are two declarations of one name. The host's `within:`
   segment would separate them if a class declaration's span contained the
   block, which is the same decision as 1.
3. **`font-family: Inter` is not stated as a reference** to the `@font-face`
   that declares it. Most values of that property are built-in stacks
   (`sans-serif`, `system-ui`) or the OS's font names, so the emission would be
   one mention per stylesheet rule resolving against nothing in the common case.
   The declaration is stated; the use is not.
4. **CSS nesting** (`&`, and a `rule_set` inside a `block`) needs no new
   pattern: a nested `class_selector` is matched by the same pattern as a
   top-level one. What is lost is that `&-large` composes a name the Pack
   cannot compute. Not stated, and not guarded, because the grammar pinned here
   parses it as an ordinary nested rule.
