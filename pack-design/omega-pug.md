# omega-pug

Language `omega-pug`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

15 templates over 16 query patterns, 28 of the grammar's 46 named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 8 |
| `references` | yes | 6 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.mixin_function` | Callable | 1 |
| `definition.template_block` | Value | 1 |
| `definition.element_id` | Value | 2 |
| `definition.page_title` | Value | 1 |
| `definition.section_heading` | Value | 1 |
| `definition.loop_variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |

### Regions

None. Pug's structure is indentation, the declarations it has already nest
through the host's `within:` segment, and an `id` in the rendered document is
global rather than scoped to the tag that holds it.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 3 |
| `reference.template_block` | reference | 1 |
| `reference.style_classname` | reference | 1 |
| `reference.custom_element` | reference | 1 |
| `call.mixin` | call | 1 |

### Injections

`script.` blocks and `- ...` code lines are handed to `javascript`. Nothing
else is.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 46 node types. The Pack looks at 28 of them.

Untouched:

- `attribute_modifier`
- `buffered_code`
- `case`
- `children`
- `comment`
- `conditional`
- `doctype`
- `doctype_name`
- `else`
- `iteration_iterator`
- `keyword`
- `pipe`
- `quoted_javascript`
- `self_close_slash`
- `source_file`
- `unescaped_buffered_code`
- `when`
- `while`

Every one of these is either punctuation (`keyword`, `self_close_slash`,
`attribute_modifier`, `children`, `source_file`), prose (`comment`, `pipe`,
`doctype`, `doctype_name`), or a control form whose only content is an opaque
`javascript` token (`case`, `when`, `conditional`, `else`, `while`,
`iteration_iterator`, `buffered_code`, `unescaped_buffered_code`,
`quoted_javascript`). The second guard in `rules.json` states that silence.

## What is wrong with it

These are the defects of the Pack as found, measured with
`python pack-design/audit.py omega-pug`: **14 templates over 21 patterns, 3
guards, 24 node types touched.**

**Four of 21 patterns were syntax highlighting, and nothing read them.** Two
copies each of an `#any-of?` list of 104 HTML tag names captured as
`@constant.builtin`, and `[ "(" ")" "#{" "}" ] @punctuation.bracket`. The
whole `; --- highlights ---` block and its byte-identical `; ---
distributed_highlights ---` twin were an nvim-treesitter baseline copied in
whole: a 104-alternative predicate run against every `tag_name` of every
template, for an emission no template produces. (Defect I, `unread` = 4.)

**Nine of the 14 templates were the tag and the attribute, unfiltered.**
`data.pug_tag` fired once per tag, `data.pug_attribute` once per attribute and
`data.pug_attribute_value` once per attribute with a value. On a real template
that is one row per line of markup, named `div`, `li`, `span`, `class`,
`href` -- mentions of nothing, since the Pack declared no tag and no attribute
for them to resolve against. omega-html deleted exactly this and said so:
"one emission per attribute of every page ... was the largest thing the
previous Pack produced."

**Two templates named a span with itself, and one of those was a whole
program.** `scope.lexical` had span `(script_block)` and name
`capture_ref(script_block)`, so the name of the region was *the entire body of
the `script.` block* -- every line of embedded JavaScript stored as a name.
`import.pug_candidate` did the same with the whole `(include)` node, `include
./partials/head` and all. (Defect D2 = 2.)

**The one carrier could not fold, and carried a name nothing assembles.**
`import.pug_candidate` ends with `_candidate` so `is_carrier_kind` is true, but
it starts with `import`, so `is_definition_kind` is false and the fold
`is_definition_kind && is_carrier_kind` never ran: it fell through to the
mention branch and was stored as a binding to a whole `include` statement. Had
it folded, it would have folded under `omega.pack.pug`, which no part of the
engine reads. (`carrier` = 1, `carrier_unread` = 1.)

**The same fact was stated twice.** `(include)` was matched by
`completeness_imports_6` as `import.pug_candidate` and again by
`terminal_source_semantics_v1` as `import.pug_path` -- two patterns over the
same node for one question, which is the one-pattern-per-question shape §5 of
the brief warns about. The `javascript` injection was likewise both a query
capture and, separately, the reason the `script_block` scope existed.

**One guard's reason was a label**:
`syntactic_scope_boundaries_only_no_runtime_scope_inference`. A second was the
generator's boilerplate about "exact-parser highlight captures" -- which named
the highlight patterns that answer nothing as though they were a limitation of
Pug. (Defect G = 1, and one more that is a label with spaces in it.)

**A framework overlay lived in the injection block.** The second injection
pattern was `(#match? @_attribute_name "^(:|v-bind|v-|\\@)")` -- Vue's
directive spellings, `:prop`, `v-bind:`, `v-if`, `@click`. Pug has no such
attributes; that is a Vue-SFC convention, and encoding one library's attribute
naming in a language Pack is Defect L. Removed.

**Five capabilities were declared that nothing now needs.** `bindings`,
`data`, `imports` and `scopes` all went with the templates above; `calls`,
`definitions` and `references` remain.

**Two real constructs were declared with the wrong family.**
`definition.pug_mixin` splits to `[definition, pug, mixin]` and `mixin` is a
Type word, so every Pug mixin -- which is a callable, invoked as `+name(a, b)`
-- was filed as a **Type** beside classes and interfaces. It is
`definition.mixin_function` now, whose last matching word is `function`, so it
lands in **Callable**, which is what asking Omega for a callable should return.
(Defect A.) The mixin's parameter list was `binding.pug_mixin_parameter`, a
mention with a `mixin_attributes` span, so it appeared as a reference rather
than building the mixin's signature line; it is the `parameter_shape` carrier
now.

**Nothing linked Pug to the rest of the project.** The Pack stated no `id`, no
class, no custom element, no `href`/`src`, no heading and no title, so a
`.pug` file in an indexed repository had no edge to the CSS that styles it, the
JavaScript that queries it or the pages it links to -- the only cross-file
facts a template layer has.

## What it should extract

Pug is the template layer of a Node project. The questions asked of a `.pug`
file are: *which layout does this extend and which partials does it pull in*,
*which block does this override*, *where is this mixin defined and where is it
used*, *which element is `#main`*, *what does this page load*, and *what does
this page say about itself*.

| what | node | emitted as | family / occurrence |
|---|---|---|---|
| `extends layout` | `extends` via `filename` | `relation.depends` | depends |
| `include ./partial` | `include` via `filename` | `relation.depends` | depends |
| `:markdown-it`, `:scss` | `filter` via `filter_name` | `relation.depends` | depends |
| `block content` | `block_definition` via `block_name` | `definition.template_block` | Value |
| `block`/`append`/`prepend` in a child | `block_append`, `block_prepend` | `reference.template_block` | reference |
| `mixin card(a, b)` | `mixin_definition` via `mixin_name` | `definition.mixin_function` | Callable |
| its parameter list | `mixin_attributes` | `definition.parameter_shape_candidate` on the mixin's span | `omega.pack.parameter_shape` |
| `+card(1, 2)` | `mixin_use` via `mixin_name` | `call.mixin` | call |
| `#main` | `id` | `definition.element_id` | Value |
| `id='main'` | `attributes > attribute` | `definition.element_id` | Value |
| `.card` | `class` | `reference.style_classname` | reference |
| `my-widget` | `tag_name`, hyphenated | `reference.custom_element` | reference |
| `a(href='/about')`, `img(src=...)` | `attributes > attribute` | `relation.depends` | depends |
| `title My Page` | `tag` + `content` | `definition.page_title` | Value |
| `h1 Welcome` | `tag` + `content` | `definition.section_heading` | Value |
| `each item in items` | `iteration_variable` | `definition.loop_variable` | Value |
| `script.`, `- var x = 1` | `script_block`, `unbuffered_code` | injection into `javascript` | -- |
| every other tag and attribute | `tag`, `attribute` | nothing | -- |
| every JavaScript expression | `javascript` | nothing | -- |

The three names are chosen to meet the Packs on the other side of the link.
`definition.element_id` and `reference.custom_element` are omega-html's own
kinds, so a Pug `#main` and an HTML `href="#main"` are one name; and
omega-css declares `definition.style_classname` for a `.card` selector, so a
Pug `.card` is stated as a reference onto it and a CSS `#main` selector is
already a `reference.element_id` onto ours. The sigils are stripped on both
sides with `strip_prefix`, which returns its input unchanged when the affix is
absent -- so the Pack is correct whether or not this grammar folds the `.` and
the `#` into the `class` and `id` tokens.

Two anchoring decisions are load-bearing:

- The attribute patterns are rooted at `attributes`, not at `attribute`. This
  grammar spells a mixin's **arguments** with the same `attribute` node, so
  `+link(href='/x')` passes an argument named `href` that an unanchored pattern
  would report as a page the template loads. This is the recurring shape
  00-INDEX names -- one node type in two roles under one parent -- and it
  produces a confidently wrong answer, not a missing one.
- The resource attribute requires a `quoted_attribute_value`. `a(href=url)` is
  a JavaScript expression, and stating `url` as a dependency would be a lie;
  the guard says so.

## Still to decide

1. **`extends`/`include` as `relation.depends` rather than the `imports`
   capability.** omega-twig, the nearest sibling, uses `import.twig_path` under
   `imports`, which becomes a *binding* occurrence; omega-html, omega-css and
   omega-xml use `relation.depends`, which becomes the dedicated *depends*
   occurrence. A Pug `include` is a file dependency, not a name binding -- it
   introduces no identifier -- so `relation.depends` is taken here. If the
   template languages are ever unified, this and omega-twig should move
   together.
2. **Whether a filter belongs under `depends` at all.** `:markdown-it` names an
   npm package nothing in an indexed repository declares, so the occurrence
   resolves to nothing. It is kept because "what does this template need
   installed" is a real question and `depends` is its channel; delete it if the
   unresolved-mention count ever matters more.
3. **`definition.loop_variable` currently answers half a question.** The local
   is declared, but nothing references it, because `#{item.name}` is one opaque
   `javascript` token in this grammar. It is kept for parity with omega-twig
   and because a future decoder over the `javascript` token would make it
   resolve; it is the first thing to delete if that never happens.

## The one audit class that is not zero, and why

```
   carrier that may overwrite itself     1
      definition.parameter_shape_candidate: (mixin_attributes) repeats inside (mixin_definition)
```

This is the grammar-grouping false positive 00-INDEX records for omega-sql and
omega-typescript, in its purest form: **tree-sitter-pug declares no fields at
all**, and puts every child of every node into one `"multiple": true` group. So
`node-types.json` says `mixin_attributes` may repeat inside `mixin_definition`
in exactly the same way it says `mixin_name` and `keyword` may. Pug's syntax
allows one parenthesised parameter list per `mixin` line and no more, so the
carrier is written once per mixin and overwrites nothing. Every other class the
audit measures is zero.
