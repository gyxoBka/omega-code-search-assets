# Frameworks: where the rewrite starts

One `.md` per Framework in this folder, `00-CONTRACT.md` is the spec they are
read against, and `pack-design/overlay_audit.py` is the measurement. This file
is the cross-Framework reading.


> Work this rewrite created and did not finish is tracked in `OWED.md`
> at the repository root, not in these wave notes.

## The state, measured

**1 415 of 1 525 overlay rules cannot match anything a Pack emits.** 110 can.

That is not how they shipped. The same measurement against the Packs as they
were before the language-Pack rewrite:

| Pack vocabulary | distinct kinds | overlay rules that cannot match |
|---|---|---|
| before the rewrite | 2 257 | 308 of 1 525 (20%) |
| now | 443 | **1 415 of 1 525 (93%)** |

So 308 rules were already dead, and the Pack rewrite killed 1 107 more. This is
the cost of that work, and it is recorded here rather than argued away.

## Why, exactly

| cause | rules |
|---|---|
| the fact kind it matches is emitted by no Pack | 1 380 |
| a field it reads is published by no Pack | 34 |
| an attribute it reads is published by no Pack | 1 |

**It is almost entirely the kind.** The overlays were keyed to the generator's
old vocabulary — 2 257 kinds, most of them one language's private spelling of
something every language has:

| kind no Pack emits | rules |
|---|---|
| `structured.entry` | 238 |
| `call.target_candidate` | 145 |
| `import.target_candidate` | 63 |
| `data.file` | 49 |
| `import.ecmascript_named_binding_context` | 42 |
| `call.ruby_string_arg_context` | 28 |
| `data.yaml_document_identity_context` | 25 |
| `definition.ecmascript_exported_variable_context` | 24 |
| `reference.hcl_block_traversal3_context` | 23 |
| `definition.python_class_member_constructor_context` | 15 |
| … 234 more | |

## What this means for the rewrite

Restoring the old kinds is not the answer: they are the Defect-E and
carrier-that-never-folds vocabulary the Pack rewrite removed on purpose, and
`call.kotlin_direct_call_context` was never a good thing for a framework rule to
be keyed to — it answered for one language and broke the moment that Pack
changed.

The replacement is better and smaller. `call.function` is the same fact in
every language now, so **one rule covers every language** where the old file
needed one per spelling. Expect a rewritten overlay to be shorter than the one
it replaces and to answer more.

Two cases need care rather than translation:

- **`structured.entry`, 238 rules.** The data formats now emit
  `definition.config_key` — json, json5, jsonc, yaml and toml alike — plus
  `definition.config_table` in toml and `definition.anchor`/`reference.anchor`
  in yaml. What the old rules got from `a0`…`a6` (the ancestor key path,
  published by one Pack pattern per nesting depth) is now the host's business:
  a nested key lies inside its parent's span, so `fact_join_by_span` with
  `within` reaches the parent, and the declaration's own nesting is already in
  the graph. This is the piece `pack-design/00-INDEX.md` recorded as owed work.
- **`call.target_candidate` and `import.target_candidate`, 208 rules.** These
  were carriers the host never folded, so they were stored as references to
  nothing even before the rewrite. `call.function`, `call.method` and
  `import.module` state the same thing and resolve.

## Order

Worst first, by rules that cannot match:

| Framework | rules | dead |
|---|---|---|
| kubernetes-config, node-js, openapi-v3, terraform, unity | the five largest files | |
| laravel 32, asp-net-core 19, symfony 20, nuxt 18, wordpress 18 | | 19–20 each |
| the rest | | |

Run `python pack-design/overlay_audit.py <name>` for any one of them.

## Not in scope here

`detection_rules` is a separate program with its own vocabulary (rows and
atoms, `rules.rs`). It is not affected by the Pack rewrite and is not measured
above; a Framework rewrite should leave a working detector alone unless it says
something untrue.

---

# Framework wave 1 (kubernetes-config, node-js, terraform, openapi-v3, unity)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-kubernetes-config | 153 -> 35 | 0 | 35 |
| omega-framework-node-js | 98 -> 13 | 0 | 13 |
| omega-framework-terraform | 86 -> 40 | 0 | 40 |
| omega-framework-openapi-specification-v3 | 73 -> 6 | 0 | 6 |
| omega-framework-unity | 56 -> 17 | 2 | 17 |

**466 rules became 111, and all 111 match.** Every one of the five came out at
zero dead rules, and each is between a third and a twelfth of its former size.
That is the shape the contract predicted: the old files carried one rule per
language spelling of a construct, and per nesting depth of a YAML document, and
the new vocabulary states each of those once.

omega-kubernetes-config is the clearest case: 153 rules, one per Kubernetes kind
per depth per namespace spelling, reading `a0`…`a3`, `doc_kind`, `doc_name`,
`kind_key`, `metadata_key` — became 35 over `definition.config_key` with span
joins.

## One blocking defect: a relation whose source nobody mints

omega-framework-unity emitted 12 relations sourced at
`unity:type:{cls.definition.name}`, bound by a `fact_join_by_span` with **no
`where`** — so any enclosing class at all. But that key is minted by only four
rules, each of which requires the class to name `MonoBehaviour`,
`ScriptableObject`, one of nine editor bases, or to carry `[Serializable]`. So
`static class SceneLoader { SceneManager.LoadScene("Main"); }` emitted a
`depends` from a key nothing in the graph ever creates.

`overlay_audit.py` cannot see this: both ends parse, both kinds exist, and the
rule matches. **A dangling canonical key is invisible to the audit and only a
reader can catch it**, which is what the review pass is for. Each of the 12
rules now mints the class it points at, under a neutral `UnityType`, so the
source always exists.

## The finding four of five agents brought back: an attribute is write-only

`OverlayFact::field` (overlay.rs:56) resolves the `fields` map and then a fixed
list of built-in names. **It never consults `attributes`.** The only clause that
reads an attribute is `attribute_equals`, which compares it to one literal
constant — there is no `attribute_in`, no `attribute_prefix`, and `field_ref`
and `{placeholder}` rendering both go through `field`.

So a value a Pack publishes as an *attribute* can be tested for equality against
a constant and used for nothing else: it cannot become a canonical key, a
relation end, an entity attribute, or a join key.

Four frameworks hit this independently and all four named the same remedy —
**move the value from `attributes` to `fields` in the Pack template**, which is
the same bytes in a different map:

| Pack | kind | value published as an attribute |
|---|---|---|
| omega-yaml, omega-json | `definition.config_key` | `value` |
| omega-hcl | `definition.config_block` | `block_type`, `type_label` |
| omega-hcl | `reference.traversal` | `root` |
| omega-javascript, omega-typescript, omega-tsx | `binding.import_alias`, `import.symbol` | `qualifier` — which the host also reads for external resolution |

A fifth is not a field at all: omega-c-sharp spans `definition.field` on the
`variable_declarator`, while `reference.attribute` spans the `attribute` node,
and the attribute is a direct child of `field_declaration` while the declarator
is a grandchild — so `[SerializeField] private float speed;` cannot be joined
`within`, and *which fields does the inspector show* is unanswerable.

**These are collected, not acted on.** The overlays written in this wave do not
depend on them; they are written against what the Packs emit today. The Pack
change is one deliberate edit at the end of the framework work, not five edits
scattered through it.

Totals: **1 525 -> 1 170 overlay rules; 1 415 -> 951 that cannot match.**

---

# Framework wave 2 (gitlab-ci, next-js, django, react, github-action)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-gitlab-ci | 48 -> 19 | 0 | 19 |
| omega-framework-next-js | 43 -> 20 | 0 | 20 |
| omega-framework-django | 38 -> 17 | 3 | 17 |
| omega-framework-react | 35 -> 17 | 1 | 17 |
| omega-framework-github-action | 34 -> 14 | 0 | 14 |

198 rules became 87, all of them live.

omega-gitlab-ci is worth reading as a design: GitLab CI has no `jobs:` heading,
so a job is a top-level key whose name GitLab does not own — a thing defined by
what it is *not*. The old file recognised it with an `a0`…`a2` /
`parent_key` / `owner_key` / `grandparent_key` ancestor ladder across 48 rules.
The new one carries **one shared clause** — `fact_join_by_span` / `within` /
`field_not_in definition.name [55 GitLab keywords]`, bound as `job` — and that
binding *is* the job. `workflow: rules: - when: always` binds nothing, because
every enclosing key is GitLab's own; `deploy: rules: - when: manual` binds
`deploy`.

## Three blocking defects, all one family, none visible to the audit

Every one was a relation end addressing an entity nothing mints — the class
wave 1 established. Two carried a new detail worth keeping:

**`Reference::Current` is the rule's *first* entity output, not the one you
meant.** `emit()` sets `own_key` once, in output order. Three gitlab-ci rules
emitted the Pipeline first and their real entity second, then a relation
`pipeline -> current`: a Pipeline-contains-Pipeline self-loop, with the Stage,
the IncludedFile and the CiVariable never linked to anything. Their targets are
addressed by explicit canonical key now.

**A rule that mints a key must carry the same conditions as the rule that
addresses it.** `next.pages.route` excludes `_app`, `_document`, `_error` and
`_middleware`; `next.pages.data_fetching` did not, so a `getServerSideProps` in
`pages/_app.tsx` emitted a `handles` edge from `http:*:/_app`, a route key no
rule mints. The exclusion is on both now.

**An unresolvable attribute drops the entity but not the relation.**
`next.api.call` set an attribute from `external.member`, which is
`segments.last()` and is `None` for a bare `import next from 'next'`.
`evaluate_attributes` then returns None and the entity is dropped with
`overlay_attribute_unresolved`, while the relation is evaluated in a second loop
and its target template still renders — an edge to an entity that was never
created. The rule now requires `external.member` to be present.

Totals: **1 170 -> 1 059 overlay rules; 951 -> 757 that cannot match.** Ten
frameworks are clean; 45 to go.

---

# Framework wave 3 (ruby-on-rails, swiftui, sveltekit, electron, pytorch)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-ruby-on-rails | 33 -> 19 | 3 | 19 |
| omega-framework-electron | 32 -> 12 | 3 | 12 |
| omega-framework-pytorch | 29 -> 20 | 1 | 20 |
| omega-framework-swiftui | 29 -> 9 | 0 | 9 |
| omega-framework-sveltekit | 29 -> 15 | 0 | 15 |

omega-ruby-on-rails shows what the collapse looks like when a framework is a set
of macros: 12 model-macro rules became 1, 4 association rules 1, 8 route rules
1, 5 migration rules 1. omega-ruby publishes **no field on any of its 25
templates**, so the overlay has only kind, name, path and span — and that was
enough for 19 rules, including the two cross-file edges Ruby actually has, both
built on the constant, the one Ruby name that resolves across files.

## Two more clauses that match nothing, and the audit now sees both

**A brace in a path glob is a literal byte.** `glob_here` implements `**`, `*`
and `?` and nothing else, so `**/*.{js,jsx,ts,tsx,mjs,cjs}` matches only a path
that literally ends in that text. Every rule carrying one emitted nothing while
the audit reported it live. **75 clauses across 9 frameworks**: webpack 19,
electron 12, terraform-template 12, nuxt 8, terraform-providers 7,
unreal-engine 6, astro 5, vite 5, vue 1.

All 75 are gone. Where the extension list only restated what the fact kind
already implies — a JS fact comes from a JS file — the clause was dropped
entirely rather than rewritten: 37 of them were exactly that.

**`external_path_matches` cannot name a scoped npm package.**
`parse_external_path` takes the first `/`-separated part as the package, so
`@sveltejs/kit` is package `@sveltejs` with segments `["kit"]`. 40 clauses in 5
frameworks depend on a match that is unreachable for every possible input:
nestjs 23, angular 10, tauri 4, sveltekit 2, astro 1.

That is a host fix, recorded as `OWED.md` item 7 and **decided**: a scoped npm
package's name is `@scope/name`, no other ecosystem this function serves emits a
leading `@` segment, and `materialize.rs` needs its design-set obligations
re-run for it. **nestjs, angular, tauri and astro are deliberately scheduled
after that fix**, so they are written against a correct host instead of around a
bug. sveltekit's two rules were deleted rather than worked around.

Compounding it, and also now recorded (item 7a): **JS/TS facts carry no
`external` at all.** `external_environment` registers only a binding whose
`target_hint` is set; `target_hint` is `occurrence.qualifier`; and `qualifier` is
read only from a field or attribute literally named `qualifier`, which the JS/TS
Packs do not publish. So every `external_path_matches` clause in every
JavaScript framework fails regardless of scoping. That is the same `qualifier`
row already in item 1, now known to carry the whole `external.*` mechanism for
the largest language family Omega has.

Totals: **1 059 -> 982 overlay rules; 757 -> 630 that cannot match.** Fifteen
frameworks are clean.
