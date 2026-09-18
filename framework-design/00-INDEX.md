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

---

# Framework wave 4 (caddyfile, tokio, spring-boot, unreal-engine, webpack)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-caddyfile | 28 -> 16 | 0 | 16 |
| omega-framework-tokio | 27 -> 14 | 0 | 14 |
| omega-framework-spring-boot | 27 -> 12 | 0 | 12 |
| omega-framework-unreal-engine | 24 -> 19 | 0 | 19* |
| omega-framework-webpack | 21 -> 10 | 0 | 10 |

127 rules became 71. omega-caddyfile is the clean case: 21 per-directive rules,
each declaring an entity kind that only named its own directive, became one
generic Directive rule plus four operand-bearing ones that each answer a
distinct question -- where does this site proxy to, which directory is served,
how is TLS provisioned, which path does this handler serve.

## *unreal-engine is not done, and the reason is a Pack limitation

Its review found two things, both measured with `dump_call_emissions` rather
than argued:

**The file's own `coverage.gaps` was false.** It asserted that `UCLASS`,
`UPROPERTY` and `GENERATED_BODY` are bare macro invocations that omega-cpp
emits no fact for. They arrive as `call.function` named exactly that, which is
the one thing in an Unreal header the Pack does see.

**And the canonical Unreal class emits nothing.** For

```cpp
class MYGAME_API AHero : public ACharacter { GENERATED_BODY() int Health; };
```

the Pack emits `reference.type MYGAME_API` and `call.function GENERATED_BODY`,
and no `definition.class`, no `definition.struct`, no `relation.implements`. The
export macro between `class` and the name defeats tree-sitter-cpp. 13 of the 19
rules join a class, so they match nothing in real Unreal code while the audit
reports them live.

That is `OWED.md` item 8, and it is not an Unreal peculiarity: `class
EXPORT_MACRO Name` is how every C++ library that ships a DLL declares a public
class. omega-framework-unreal-engine goes back through a wave, to be written
against the macros that do emit.

Totals: **982 -> 926 overlay rules; 630 -> 503 that cannot match.** Twenty
frameworks are clean.

---

# Framework wave 5 (vite, android, jakarta-ee, flutter, unreal-engine)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-vite | 21 -> 8 | 0 | 8 |
| omega-framework-android | 21 -> 12 | 0 | 12 |
| omega-framework-jakarta-ee | 20 -> 12 | 0 | 12 |
| omega-framework-flutter | 20 -> 10 | 0 | 10 |
| omega-framework-unreal-engine | 19 (reverted) | 19 | 19 |

omega-vite is the sharpest deletion so far: 18 of its 21 rules read a config
scalar — `base`, `root`, `publicDir`, `build.outDir`, `server.proxy`,
`resolve.alias` — and every one of them was unreachable *in principle*, because
a Vite config is an object literal and the JS/TS Packs emit a fact for an object
key only when its value is a function. Each also minted an entity keyed by the
value it had just read. Eight rules replace them, built on two hubs: the build
and the module.

## unreal-engine: a measurement generalised too far, and reverted

Wave 4's review measured that `class MYGAME_API AHero : public ACharacter`
emits nothing — true. The wave-5 agent read that as *Unreal classes are not
declared* and deleted the 13 class-joined rules.

Measured here, directly:

| source | what omega-cpp emits |
|---|---|
| `UCLASS() class ATwo : public AActor { GENERATED_BODY() int H; };` | `definition.class ATwo`, `relation.implements AActor`, `definition.field H` |
| `UCLASS() class MYGAME_API AHero : public ACharacter { ... };` | `reference.type MYGAME_API` and `call.function GENERATED_BODY`, nothing else |

**It is the export macro between `class` and the name, and nothing else.** The
rewrite was reverted to the wave-4 file, which works for the plain spelling, and
its `coverage.gaps` now states the macro limitation instead of the false claim
that `UCLASS` and `GENERATED_BODY` emit no fact — they arrive as `call.function`
named exactly that.

`OWED.md` item 8 is narrowed to what was measured. The lesson is in the brief as
§3d: reproduce a "this emits nothing" claim on the exact spelling *and its
neighbours* before acting on it, with `dump_call_emissions`.

Totals: **926 -> 886 overlay rules; 503 -> 421 that cannot match.** Twenty-four
frameworks are clean.

---

# Framework wave 6 (symfony, asp-net-core, laravel, wordpress, nuxt)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-laravel | 32 -> 16 | 19 | 16 |
| omega-framework-symfony | 20 -> 10 | 1 | 10 |
| omega-framework-asp-net-core | 19 -> 10 | 0 | 10 |
| omega-framework-wordpress | 18 -> 17 | 0 | 17 |
| omega-framework-nuxt | 18 -> 15 | 0 | 15 |

107 rules became 68. omega-symfony collapsed 15 per-attribute rules that were
byte-identical apart from one string in a `member_in` list of length one.

## Three blocking defects, two of them a new kind of vacuity

**A `field_present` on a built-in name is always true.** `OverlayFact::field`
falls back to `path` when the fields map has none, so symfony's
`{"kind":"field_present","field":"path"}` guarded nothing and its Twig rules
matched every `relation.depends` from every Pack in the repository — 30-odd
Packs publish that kind. Gated on `**/*.twig` now.

**A placeholder is not a field.** `normalized_file_route` resolves in
`resolve_placeholder`, which serves `{...}` templates in canonical keys and
relation ends. A `field_ref` attribute goes through `OverlayFact::field`, which
has never heard of it. omega-nuxt gave its four principal entities an attribute
`"route": {"kind":"field_ref","field":"normalized_file_route"}`, so all four
were dropped as unresolvable — and eight relations addressing `nuxt:page:{path}`
and `nuxt:server-handler:{path}` dangled, including the two answers the overlay
exists for: *which URL does this page serve* and *which handler answers this
API path*. The attribute is redundant with the relation's own end and is gone.

The third was the same self-loop shape wave 2 found: symfony's
`generic-api-call` ran `uses_api` from `current` to the key `current` had just
been minted under.

Totals: **886 -> 847 overlay rules; 421 -> 334 that cannot match.** Twenty-nine
frameworks are clean.

---

# Framework wave 7 (kotlin-multiplatform, vue, fastapi, vapor, terraform-template)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-fastapi | 22 -> 12 | 6 | 12 |
| omega-framework-vue | 17 -> 16 | 1 | 16 |
| omega-framework-kotlin-multiplatform | 17 -> 13 | 0 | 13 |
| omega-framework-vapor | 15 -> 12 | 0 | 12 |
| omega-framework-terraform-template | 15 -> 9 | 0 | 9 |

86 rules became 62.

omega-kotlin-multiplatform found the join this whole programme was looking for.
omega-kotlin publishes **no field on any of its 28 templates**, yet
`definition.modifier_candidate` carries the modifier text as its *name* --
`expect`, `actual`, `internal expect` -- on a span byte-identical to the
declaration's own. So `fact_join_by_span` with `relation: "same"` reaches the
declaration from the modifier with no Pack field at all, and `expect`/`actual`
becomes statable. The expect key is deliberately path-free, so every platform's
`actual` across a repository lands on one entity and *who implements this expect,
and on how many platforms* is one hop. That edge is the one thing a language
Pack cannot state: an `expect fun` in commonMain and an `actual fun` in jvmMain
are two unrelated `definition.function` facts in two files.

## The blocking defect: narrowing a list is a deletion

omega-framework-vue cut its directive list from twelve values to three, on the
stated ground that the old list "named no spelling the Pack publishes". False:
omega-vue emits `data.vue_directive_value` for **any** `directive_attribute`
with a quoted value, so the `directive` field holds whatever was written and the
list was the Framework's own choice. `v-bind`, `v-if` and `v-show` lost their
only coverage. Restored, and widened to the full set that carries an expression.

This is the second time a value set has been narrowed on a false premise —
omega-framework-unreal-engine lost 13 rules to the same shape a wave earlier —
so it is now §3f of the brief: read the Pack pattern that produces the field
before shortening any `field_in`, `member_in` or `#any-of?` list.

Totals: **847 -> 823 overlay rules; 334 -> 255 that cannot match.** Thirty-four
frameworks are clean.

---

# Framework wave 8 (fiber, gin, maui, prisma, axum)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-prisma | 12 -> 16 | 0 | 16 |
| omega-framework-fiber | 14 -> 10 | 0 | 10 |
| omega-framework-gin | 12 -> 12 | 0 | 12 |
| omega-framework-axum | 12 -> 12 | 0 | 12 |
| omega-framework-maui | 12 -> 9 | 0 | 9 |

Five frameworks that answered **nothing at all** before this wave: 62 rules, not
one of them live. Every one was keyed to a composite fact kind of the old
vocabulary -- `call.go_receiver_string_identifier_context`,
`definition.go_unaliased_import_group_binding_context`,
`call.csharp_class_nested_member_string_context`, `data.prisma_model_typed_field`
-- a kind naming the shape of its own match rather than a fact. 59 rules now, all
live.

omega-go is the limit case of the new Pack vocabulary: 47 templates, **zero
fields and zero attributes on every one of them**. So fiber and gin have kind,
name, path and span, and nothing else. Both came out whole anyway, on joins: a
Fiber handler is a `type_use.name` named `Ctx` inside a `definition.function`;
its owning controller is reachable because `definition.receiver_candidate` spans
the entire method declaration and is named for the receiver type, so a second
span join names the struct with no Pack field at all. What neither can state is
the URL: `app.Get("/users/:id", h)` has its path in a string literal, and
omega-go publishes no argument text. That is now a row in `OWED.md`.

## The blocking defect: a canonical key holds exactly one entity

omega-framework-maui minted eleven entity kinds on one key template,
`maui:type:{class}`. Entity identity in the host is the rendered canonical key
**alone** -- `EntityId::from_binding(Canonical { key })` never sees the
descriptor -- and `overlay_ir.rs` interns with `or_insert`, first one wins,
candidates ordered by `rule_id` string. So a page that is also a route target, a
navigation target, a query receiver and carries a `[RelayCommand]` reaches the
graph as exactly one entity: `MauiCommandOwner`, because `maui.mvvm.relay_command`
sorts before the rest. Every CommunityToolkit.Mvvm view model loses its
`MauiViewModel` the same way. Two of the nine answers the file advertised never
arrive.

This is invisible to `overlay_audit.py`, which reads matchability and nothing
else, so it now has its own measurement, `pack-design/key_collisions.py`. Across
all 55 frameworks it finds **62 entity outputs overwritten in 8 frameworks**:

| framework | dropped outputs |
|---|---|
| omega-framework-unity | 17 |
| omega-framework-unreal-engine | 12 |
| omega-framework-ruby-on-rails | 10 |
| omega-framework-maui | 9 |
| omega-framework-vapor | 8 |
| omega-framework-swiftui | 7 |
| omega-framework-angular | 3 |
| omega-framework-nuxt | 1 |

A shared key is right when the rules agree on the kind -- that is the hub
pattern wave 1 established for unity, where every rule mints one neutral
`UnityType` so a relation from another file can land on it. It is a defect the
moment they disagree, and eight frameworks disagree. Attributes collide on the
same rule, so moving the classification into an attribute does not help either;
it needs either one neutral kind per key space or a key space per
classification. Recorded as `OWED.md` item 9 and scheduled as its own wave.

Two more things measured rather than read, both now in `OWED.md` item 10:
omega-rust emits a `reference.path` at **every** nesting level of a scoped path,
so `get(crate::handlers::users::list)` gives three facts and axum's handler rule
mints `axum:handler:users` and `axum:handler:handlers` alongside the real one --
and the overlay has no way to say "not contained in another fact of this kind".
And `[dependencies.axum]` with `version = "0.7"` under it names the table
`dependencies.axum`, so axum's twelve-rule dependency gate is silent for that
perfectly ordinary Cargo spelling.

Totals: **823 -> 820 overlay rules; 255 -> 193 that cannot match.** Thirty-nine
frameworks match everything they name; sixteen still hold dead rules, four of
them deferred behind the host fix in item 7.

---

# Framework wave 9 (blazor, express, svelte, bun, jetpack-compose)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-bun | 20 -> 11 | 10 | 11 |
| omega-framework-express | 19 -> 11 | 8 | 11 |
| omega-framework-blazor | 11 -> 11 | 0 | 11 |
| omega-framework-svelte | 11 -> 11 | 0 | 11 |
| omega-framework-jetpack-compose | 10 -> 9 | 0 | 9 |

71 rules became 53, all live, and no review found a blocking defect.

blazor is the wave's best answer to *what does a Framework add*. omega-razor
publishes no field on any of its 56 templates, so every rule works from kind,
name, path, span and the host's built-ins — and the overlay still states which
URL a component serves, which layout wraps it, what it inherits, how it renders,
which services it injects, what its `[Parameter]` API is, which lifecycle hooks
it implements, and which method a `@onclick` in the markup calls. The injection
edge is the shape worth copying: `definition.injected_service` (the variable)
joined `same`-span to `definition.declared_type_candidate` (its type), keyed by
the **type**, with the local name carried as a relation attribute. A carrier at
the same span is how a fieldless Pack is read.

The one edge that joins a component to its code-behind is that both sides land
on `blazor:component:{name}` — `path.stem` for `Counter.razor`, the enclosing
class name for `Counter.razor.cs`.

## Three defects in the audit itself, all found by the agents

**`data.file` is host-synthesized and the audit called it dead.**
`OverlayFact::artifact` pushes one `data.file` fact per artifact, with field
`path`, before any Pack emission — it is how a file-shaped rule addresses the
file itself. The audit built its kind set from `packs/*/rules.json` alone, so it
reported every such rule dead, and this index's own missing-kind table carried
`data.file 49` as if no Pack emitted it. Seeded now. **That mismeasurement cost
coverage**: next-js had 20 `data.file` rules, nuxt 11, sveltekit 10, and all of
them were deleted across waves 2 and 3. Those three still answer file-based
routing through a declaration inside the file plus a path glob, which is
narrower — a `+page.svelte` with no script has nothing to hang on. Recorded as
`OWED.md` item 13 and scheduled as its own pass.

**Liveness was per-repository, not per-language.** A rule counted as live if
*any* Pack in the repository emitted its kind. Ten bun rules matched
`call.member`, which omega-c, omega-cpp and omega-c-sharp emit and no JavaScript
Pack does, so the audit said ten live where the true figure was zero. Every
framework declares `host.required_packs`, so the surface is now built from that
list, and a kind only another language emits is reported dead with the emitters
named — because it is either a rule written against the wrong language or a
manifest that under-declares its packs, and the reader has to decide which.
omega-framework-axum was the second: it reads `Cargo.toml` and declared only
`omega-rust`, so all twelve of its rules were scoped-dead. Manifest fixed.

Scoping pushed the count the other way and the two corrections nearly cancel:
**802 overlay rules; 193 -> 168 that cannot match.**

Seven non-deferred frameworks still hold dead rules — fastify 20, flask 8,
pydantic 8, pytorch-extensions 8, terraform-providers 8, godot 6,
pytorch-inductor 5 — and four are deferred behind item 7.

---

# Framework wave 10 (fastify, flask, pydantic, pytorch-extensions, terraform-providers)

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-fastify | 20 -> 15 | 0 | 15 |
| omega-framework-flask | 14 -> 12 | 6 | 12 |
| omega-framework-pydantic | 14 -> 7 | 6 | 7 |
| omega-framework-terraform-providers | 8 -> 5 | 0 | 5 |
| omega-framework-pytorch-extensions | 8 -> 8 | 0 | 8 |

64 rules became 47, all live, no blocking defect.

fastify shows what replaces `external_path_matches` where it never worked: one
shared gate, `fact_join_by_field` on `import.module` in the same path whose name
has prefix `fastify`. That is what keeps `call.method get` from meaning
`Map.prototype.get`, and it is reachable in every language, unlike the external
environment. Ten byte-identical `set*Compiler`/`set*Handler` rules collapsed into
one `field_in` over twelve names that states more than the ten did.

## `external_path_matches` is false in every language but two

Three agents traced the same chain independently this wave.
`OverlayFact.external` is built by `external_environment` from bindings whose
`target_hint` is set; `target_hint` is `occurrence.qualifier`; and the host reads
a qualifier only from a field or attribute **literally named `qualifier`**.
Exactly two Packs publish one: omega-c-sharp and omega-docker-compose. In every
other language `external.package` and `external.member` are empty on every fact,
so an `external_path_matches` clause is false for every possible input.

The audit only flagged the *scoped* npm case, so twenty fastify rules and six
flask rules were scored live while matching nothing. It now reports any
`external_path_matches` in a Framework none of whose declared Packs publishes a
`qualifier`. One rule survived that check across the other 50 frameworks —
`next.api.call` — and it is rewritten on the same import join fastify uses.

This widens `OWED.md` item 7a from JavaScript to everything, and it moves item 7
from *decided and worth doing* to *not sufficient*: fixing `parse_external_path`
for scoped packages does nothing until a Pack publishes `qualifier` at all.

## Interning is global, so Frameworks collide with each other too

`key_collisions.py` read one framework at a time, but `apply_overlay_runs`
interns across every overlay in the run. Checked now: exactly one key template
is minted under two kinds by two Frameworks — `http:*:{normalized_file_route}`,
where astro, next-js and nuxt all mint `Route`, which is the point of a shared
key space, and `nuxt.server.route` mints `ServerRoute` on it, which is not.
Folded into the collision wave.

Totals: **785 overlay rules; 168 -> 104 that cannot match.** Only godot (6) and
pytorch-inductor (5) are left outside the four deferred behind item 7.

---

# Framework wave 11 (godot, pytorch-inductor, unity, unreal-engine, ruby-on-rails)

| Framework | rules | live before | live after | dropped outputs before | after |
|---|---|---|---|---|---|
| omega-framework-godot | 9 -> 18 | 3 | 18 | 0 | 0 |
| omega-framework-ruby-on-rails | 19 -> 19 | 19 | 19 | 10 | 0 |
| omega-framework-unity | 17 -> 17 | 17 | 17 | 17 | 0 |
| omega-framework-unreal-engine | 19 -> 19 | 19 | 19 | 12 | 0 |
| omega-framework-pytorch-inductor | 5 -> 8 | 0 | 8 | 0 | 0 |

The last two frameworks with dead rules outside the deferred four, and the three
worst key collisions, in one wave. **Zero non-deferred frameworks now hold a rule
that cannot match**, and dropped entity outputs fall 62 -> 26.

The collision fix came out the same way in all three: the match clauses are
byte-identical before and after — no rule was deleted and none was narrowed —
and the change is entirely on the output side. unreal-engine went from 24
outputs to 50: one neutral kind on the shared `unreal:type:{class}` hub, and
each classification moved to its own key space (`unreal:actor:`, `unreal:pawn:`,
`unreal:subsystem:`) with a relation back to the hub. That is brief 3g's second
remedy, and it keeps both kinds and both attribute sets where the first remedy
would have kept one.

godot is the wave's real gain: 9 rules to 18, and for the first time a GDScript
file and the `.tscn` that runs it share keys. `godot:signal:{name}` is minted
both by a GDScript `signal` statement and by a scene's `[connection signal=…]`;
`godot:method:{name}` both by a `func` and by a connection's `method=`;
`godot:class:{name}` by `class_name`, by `extends`, by a node's `type=` and by an
exported property's declared type. *Which script is attached to this node*,
*which method runs when this signal fires* and *which scenes place a
`CharacterBody2D`* are each one or two hops, and no language Pack can state any
of them.

## Two idioms worth copying, both from godot

**`definition.container` as a discriminator.** Where a Pack spans a container
declaration over its members, the host's synthesized container names *which
property a value was written under* with no join and no Pack field:
`field_equals definition.container script` is the whole test for "this
`ExtResource` reference is the node's script", and the same field separates a
node header's `type=` from a `Vector2(…)` written inside a property value. Any
config-shaped Framework can use it the same way.

**A section that declares nothing is grouped by a fact that spans it.** Godot's
`[connection]` has `signal=`, `method=`, `from=` and `to=` as four siblings with
no definition between them, so the grouping comes from joining `within` the
span-wide `structured.godot_section_attribute_context` and keying on its start
offset. The limit is worth recording with the idiom: because the span-wide fact
covers every sibling equally, the join cannot tell which sibling the current
fact is, so `from=` and `to=` stay indistinguishable.

## A value that carries its quotes cannot be an identity

omega-godot-resource's three overlay-specific templates capture `(string)` nodes
raw, so `attribute_value`, `resource_path`, `node_name` and `resource_id` all
arrive as `"res://player.gd"` **with the quote bytes**, while the same Pack's
`definition.scene_node`, `definition.resource` and `relation.depends` strip
them. The old godot overlay's one live sub-graph was keyed on the quoted form
and could therefore never meet any other fact. `fact_join_by_field` takes
`current_strip_prefix` and `join_strip_prefix`, but there is no strip_suffix and
no strip at all in a key template — **a Pack value destined for a key has to be
normalized by the Pack.** Recorded as `OWED.md` item 14.

Totals: **797 overlay rules; 104 -> 93 that cannot match, all 93 in the four
deferred frameworks.** Key collisions 62 -> 26: vapor 8, swiftui 7, maui 7,
angular 3, nuxt 1.

---

# Framework wave 12 (vapor, swiftui, maui, nuxt) -- the key collisions

| Framework | rules | dropped outputs before | after |
|---|---|---|---|
| omega-framework-vapor | 12 -> 12 | 8 | 0 |
| omega-framework-swiftui | 9 -> 8 | 7 | 0 |
| omega-framework-maui | 9 -> 9 | 7 | 0 |
| omega-framework-nuxt | 15 -> 15 | 1 | 0 |

**`key_collisions.py` is now silent except for angular's three**, which are
behind item 7 with the rest of that framework; and the one cross-framework
collision is gone — `nuxt.server.route` no longer mints `ServerRoute` on
`http:*:{normalized_file_route}`, the key space astro, next-js and nuxt share
for `Route`.

vapor settled which of the two remedies is the default for this shape. A Vapor
type is routinely several things at once — `final class Todo: Model, Content` is
the ordinary spelling — and remedy 1, one neutral kind with the classification
in the relations, keeps only the **first rule's attribute set**, so `conforms_to`
would be lost for every role but one. Remedy 2, a key space per classification
with a `has_role` edge back to the neutral hub, keeps every kind and every
attribute set. The same argument holds for maui (a page that is also a
navigation target and a query receiver) and for unity, so:

**A hub key and a classification cannot be the same key.** The moment a
Framework has a per-declaration hub that several rules mint as a relation end,
every rule that also wants to say *what kind of thing this is* needs its own key
space. That is now the stated default for the MVC / protocol-conformance shape,
not a judgement call per framework.

## A clean audit says nothing about whether the answers reach the graph

vapor audited 12 of 12 live throughout, while eight of its twenty-one entity
outputs — five of the six headline answers its `.md` advertised — were being
discarded by the first-rule-wins intern. Two checks measure two different
things and both have to be run.

A third is worth writing: **every canonical key template a relation addresses
must be one the file mints.** That is the wave-1 dangling-relation class, it is
a ten-line pass over the JSON, and it is still done by hand.

## The `data.file` premise is corrected where it was written down

nuxt's design note still argued that `data.file` is "by construction outside the
Pack vocabulary", which is the premise brief 3h names as false and the reason
eleven file-shaped rules were re-entered on declarations inside the file. The
note now says what is true: a declaration is the better witness **when there is
one**, and where there is not — a `pages/about.vue` that is markup with no
`definePageMeta`, a script-only `components/*.vue` — the file produces no entity
at all. The restoration itself is `OWED.md` item 13, with next-js and sveltekit.

Totals: **796 overlay rules; 93 that cannot match, all in the four deferred
frameworks. 3 dropped entity outputs, all in angular.**

---

# Framework wave 13 (nestjs, angular, tauri, astro) -- the four that were deferred

| Framework | rules | live before | live after |
|---|---|---|---|
| omega-framework-nestjs | 31 -> 8 | 0 | 8 |
| omega-framework-angular | 31 -> 14 | 0 | 14 |
| omega-framework-tauri | 14 -> 12 | 0 | 12 |
| omega-framework-astro | 20 -> 20 | 3 | 20 |

These four were held back twice: first behind `parse_external_path`, which split
a scoped npm package so `@nestjs/common` could never be matched, and then behind
the discovery that `external.*` was empty in JavaScript altogether. Both are
fixed -- the JS/TS Packs publish `qualifier`, and a scoped package is now one
package -- and all four are rewritten against a correct host rather than around
a bug.

Most of them did not need `external_path_matches` in the end. nestjs went from
31 rules to 8 by reading what NestJS actually writes down: a class's role is a
`reference.decorator` named `Controller`, `Injectable`, `Module`,
`WebSocketGateway` or `Catch` joined to the `definition.class`, and an HTTP
route is a decorator named for the verb with `definition.container` present.
Eleven of the old 31 died on the scoped-package clause alone; the rest were
keyed to composite kinds of the old vocabulary.

## All three measurements are clean

```
754 overlay rules across 55 frameworks; 0 cannot match any Pack emission (0%)
0 entity outputs are overwritten by a same-key rule that sorts first
3 relation ends address a key template no rule mints textually  (all pydantic, all read and sound)
```

From **1525 rules of which 1217 could not match** at the start of this
programme, to **754 rules of which none cannot match**. Every Framework states
only what some Pack actually emits, no Framework's entity is silently
overwritten by another's, and every relation lands on an entity something mints.

## What the programme leaves behind

Two things, both measured and both written down rather than guessed at:

**The canonical call view** (`OWED.md` item 17). An engine test reads the live
omega-typescript Pack and asserts a call publishes `call.arg0`, `call.arg1`,
`call.last_arg` and `receiver`; it fails, because the Pack rewrite deleted the
two templates that did it as restating their match. They do not restate it --
each argument is `first`/`select`/`last` over `ordered_children` of the captured
argument list. That view is what nine Frameworks in these waves asked for as "a
field only the Pack can supply": a route's URL in fastify, express, bun, gin,
fiber, axum and vapor, a Shell route in maui, a decorator argument in django and
pydantic. Items 1 and 11 are both it.

**The file-shaped rules** (`OWED.md` item 13). next-js, nuxt and sveltekit lost
20, 11 and 10 `data.file` rules while the audit wrongly reported that kind dead.
They answer file-based routing through a declaration inside the file instead,
which is narrower at the edges.

---

# Second pass, wave A (gin, fiber, axum, vapor, fastify)

The first wave written against a call that has arguments. Every one of these
keyed its routes by the byte offset they were written at and said so in
`coverage.gaps`; all five now key by the URL they serve, in the shared
`http:{method}:{normalized_route}` space express and fastapi already used, so
`/users/:id`, `/users/{id}` and `/users/[id]` are one identity across languages.

| Framework | rules | what it can now say |
|---|---|---|
| omega-framework-gin | 12 -> 15 | the URL, `r.Group("/api/v1")` prefixes, a static mount by what it serves |
| omega-framework-axum | 12 -> 14 | `.route("/users/:id", get(h))` and `.nest("/api", …)` |
| omega-framework-vapor | 12 -> 14 | `app.get("todos", ":id")` |
| omega-framework-fiber | 10 -> 11 | the URL and the handler behind it |
| omega-framework-fastify | 15 -> 15 | the URL, a registration's prefix |

## Four of the five traded an edge for the URL, and the reviews caught it

The same defect in gin, fiber, axum and vapor: the new rule keyed the handler on
`call.last_arg`, **the argument as written**. A handler is written
`ctrl.GetUser`, `handlers.ListUsers`, `handlers::show_user` at the registration
and declared as `GetUser`, `ListUsers`, `show_user`, so the route key and the
declaration key never met and *which function answers this route* — the one
cross-file edge these overlays have — was silently gone. `overlay_audit.py`,
`key_collisions.py` and `dangling_ends.py` all report clean on it: both keys are
minted, they just never meet.

Fixed once, in the Packs rather than four times in the Frameworks. The ten
call-bearing Packs now publish:

| field | `r.GET("/users/:id", ctrl.GetUser)` |
|---|---|
| `call.arg0_text` | `/users/:id` |
| `call.arg0_name` | `/users/:id` — the last segment, for when argument 0 is a name |
| `call.arg1_text` | `ctrl.GetUser` |
| `call.last_arg_name` | **`GetUser`** — the name it refers to |

The separators are the language's own: omega-rust splits on `::` before `.`, so
`get(handlers::show_user)` reaches `show_user`.

`call.arg1_text` closed the other half of it. gin's `r.Handle("GET", "/legacy",
h)` and fiber's `app.Add(method, path, h)` put the verb in argument 0 and the
URL in argument 1; both were keyed by offset and both now join the shared route
space.

## A registration whose path is not an argument

vapor's reviewer measured its own canonical `TodoController` and found that four
of six registrations have no path literal at all — `todos.get(use: index)`
inherits the group's prefix, `todos.on(.PATCH, ":todoID", use: update)` puts the
method first. The rewrite had guarded on `field_prefix call.arg0 = "\""` and
dropped them entirely, which is a deletion dressed as a narrowing. Both forms
are stated now: the path form in the `http:` space, the bare form as
`vapor:route:{path}:{source.start}` with its handler — real, located where it is
written, and honest that its URL is not derivable there.

762 overlay rules, 0 that cannot match, 0 collisions, 3 dangling candidates (all
pydantic, all read). Engine suite green.

---

# Second pass, wave B (bun, maui, django, pydantic, pytorch-extensions)

| Framework | rules | what it can now say |
|---|---|---|
| omega-framework-django | 17 -> 21 | `path("admin/", admin.site.urls)` -- the URL and the view behind it |
| omega-framework-bun | 11 -> 13 | `Bun.serve` vs anything's `.serve`, a data file by name, a native library by name |
| omega-framework-pytorch-extensions | 8 -> 11 | which sources an extension compiles |
| omega-framework-maui | 9 -> 11 | `Routing.RegisterRoute("details", typeof(P))`, both spellings |
| omega-framework-pydantic | 7 -> 9 | a validator's target field |

bun is the honest negative result of the wave. It has no route-registration
call: a Bun route is a **quoted key in an object literal**,
`Bun.serve({ routes: { "/api/users": listUsers } })`, and the reviewer measured
that no JS/TS Pack emits any fact for a string-keyed property -- not for
`"/api/users": listUsers`, not for `"/health"(req) {...}`. An identifier key
does emit. So bun states no routes, says so in `coverage.gaps`, and did not
invent them. The same blindness covers Vite's `resolve.alias`, Webpack's loader
maps and Jest's `moduleNameMapper`; recorded as `OWED.md` item 18.

What bun could do instead is worth copying: four of its rules were `candidate`
because they matched `serve`, `spawn`, `file`, `write` **by member name alone**,
so `stream.write()` matched too. `field_equals receiver Bun` makes them `exact`.

## `call.arg0_text` was wrong, and a Pack could not fix it

pydantic measured the defect: `strip_prefix` and `strip_suffix` do not know
about each other, so a Python keyword argument in argument zero --
`Field(alias="userId")`, `ConfigDict(env_prefix="APP_")`,
`model_validator(mode="after")` -- lost its **trailing** quote although the
leading one was never there. `alias="userId` is neither the source text nor the
string, and no Pack could repair it: a key template has no strip,
`fact_join_by_field` offers no strip_suffix, and no clause compares two fields.

Fixed in the engine with one op. `unquote` returns a string literal's text
without its delimiters and anything else unchanged, and it replaced the nested
pairs in all ten Packs -- `call.arg0_text` in omega-python went from 76 lines of
nesting to 32. `expr.rs` is a frozen design-set file, so the six behavioural
obligations were re-run and `freeze.json` re-stamped with a dated note.

`call.constructor` carried no fields in any JS/TS Pack while `call.function` and
`call.method` carried the whole view, so `new Database("app.sqlite")` named no
file. It carries it now.

## A guard that skips a spelling is a deletion

maui repeated wave A's vapor defect exactly: a `field_prefix call.arg0 = "\""`
inside a join's `where`, which kills the **whole binding**, not just the output
that wanted a literal. `Routing.RegisterRoute(nameof(DetailsPage),
typeof(DetailsPage))` -- the spelling in the .NET MAUI docs and the Visual
Studio item template -- has no quote byte, so *which page does AppShell
register* went from stated to absent. Both spellings are rules now: the literal
one states the route, the `nameof` one states the registration without
pretending to a route name.

775 overlay rules, 0 that cannot match, 0 collisions, 5 dangling candidates --
all pydantic, all read: `{enclosing.qname}.{call.arg0_text}` and
`{definition.qname}` render the same string, as do `{receiver}` and
`{definition.name}` for a model used by its own class name.
