# Rewriting one Framework: everything you need

You are being sent to rewrite exactly one Framework overlay.

## Required reading, before you touch anything

If you find something that has to be done later and not by you, add it to
`OWED.md` at the repository root -- that is the one place deferred work is
tracked, and anything left only in a report is lost.


1. **This file.**
2. **`framework-design/00-CONTRACT.md`** — what the overlay sees, every match
   clause, every join, every output, and the Pack vocabulary to write against.
3. **`framework-design/00-INDEX.md`** — why 1 415 of 1 525 rules currently match
   nothing, and the two cases that need care rather than translation.
4. **`framework-design/<your-framework>.md`** — your own document: what it
   declares, what it matches, and a table of every rule that cannot match and
   why. Read it to the end.

Also read, for the shape of the thing you are interpreting:
`pack-design/00-CONTRACT.md` §5 (the kind string is a protocol) and the
`packs/<lang>/rules.json` of the one or two languages your framework lives in.

## 1. What a Framework is for

```text
source -> Grammar -> AST -> Pack -> normalized Omega IR -> Framework -> enriched graph
```

A Pack says *there is a function here called `handleSubmit`*. A Framework says
*that function is the handler for `POST /orders`*. The Framework adds meaning
the language cannot know, and nothing else.

So every rule must answer a question an agent would actually ask about a project
using this framework: **which route serves this path, which handler answers it,
what does this component render, which model backs this table, what does this
job depend on.** A rule whose output is an entity named after its own input,
with no relation to anything, has added nothing to the graph and should not
exist.

## 2. The one rule that governs everything

**A Framework never invents a fact a Pack did not state** (`README.md`). If the
Pack does not emit it, the answer is "not found", and that is a complete
answer.

This has a corollary that decides most design questions: when you want
something a Pack does not publish, your options in order are

1. derive it from what the fact already answers — `definition.name`, `path`,
   `path.dir`, `path.stem`, `external.package` (contract §2);
2. reach it with a join — `fact_join_by_span` with `within` relates a member to
   its enclosing declaration using spans the Pack already emits, and needs no
   field on either side;
3. only then, ask for a Pack `field`. A field costs bytes on **every** emission
   of that kind in **every** repository, whether or not this framework is
   present. Say in your `.md` why the first two could not do it.

## 3. How to port a dead rule

Your document lists each dead rule with the kind no Pack emits. The translation
is usually mechanical:

| old kind | what states it now |
|---|---|
| `call.target_candidate`, `call.direct`, `call.<lang>_*_context` | `call.function`, `call.method`, `call.constructor` |
| `import.target_candidate`, `import.<lang>_named_binding_context` | `import.module`, `import.symbol`, `binding.import_alias` |
| `definition.<lang>_exported_*_context` | `definition.function` / `definition.variable` + `module.export` |
| `structured.entry`, `data.yaml_document_identity_context`, `data.file` | `definition.config_key` (json, json5, jsonc, yaml, toml), `definition.config_table` (toml) |
| `definition.<lang>_class_*_context` | `definition.class` + a join |
| `annotations.annotation_normal`, `reference.<lang>_decorator_*` | `reference.annotation`, `reference.decorator`, `reference.attribute` |
| a `*_context` kind in general | a declaration, plus the join that gave it its context |

Three things to do while porting, not after:

- **Collapse the language spellings.** If the old file had one rule for Kotlin,
  one for Java and one for Scala matching the same construct, they are now one
  rule on `call.function`. Expect your file to get shorter.
- **Drop what only restated its input.** An `entity_candidate` whose canonical
  key is `{name}` and whose rule emits no relation is not an answer.
- **Check the output is reachable.** A relation's ends are rendered canonical
  keys; if nothing else in this file (or in a Pack) ever emits an entity under
  the key you point at, the relation dangles.

## 3a. Two things wave 1 proved

**An attribute is write-only.** `OverlayFact::field` resolves the `fields` map
and a fixed list of built-in names, and **never consults `attributes`**. The
only clause that reads one is `attribute_equals`, against a single literal
constant. So a value published as an attribute can be tested for equality and
used for nothing else -- not as a canonical key, not as a relation end, not as
an entity attribute, not as a join key. If you need a value, it must be in
`fields`; if the Pack has it in `attributes`, that is a Pack change to report,
not a rule to bend around.

**The audit cannot see a dangling relation.** A relation's ends are rendered
canonical keys. If no rule anywhere ever mints an entity under the key you point
at, the relation goes nowhere -- and both kinds exist, both clauses parse, and
`overlay_audit.py` reports the rule as live. omega-framework-unity shipped 12
such relations, sourced at a key that four strictly-conditioned rules minted.
**Before you finish: list every canonical key your file mints, list every key
your relations address, and check the second set is contained in the first.** If
a relation needs an entity that no rule mints, mint it in the same rule.

## 3b. Three more ways a relation end goes nowhere

Wave 2 found all three, and none of them is visible to `overlay_audit.py`.

**`current` is your rule's FIRST entity output, not the one you meant.**
`emit()` sets `own_key` once, walking outputs in order. If your rule emits a
container entity first and the thing it is about second, `current` addresses the
container -- three gitlab-ci rules emitted `Pipeline contains Pipeline` this
way, and the Stage, the IncludedFile and the CiVariable were linked to nothing.
Either put the entity you mean first, or address it by explicit
`by_canonical_key`.

**A rule that addresses a key must carry the same conditions as the rule that
mints it.** `next.pages.route` excluded `_app`, `_document`, `_error` and
`_middleware`; `next.pages.data_fetching` did not, so it emitted an edge from a
route key that no rule mints. When two rules share a key template, they must
share the clauses that decide whether the key exists.

**An unresolvable attribute drops the entity and keeps the relation.** If any
attribute expression yields nothing -- `external.member` is `segments.last()`
and is absent for a bare `import x from 'pkg'` -- `evaluate_attributes` returns
None and the entity is dropped, while the relation is evaluated in a second loop
and still renders its ends. Add a `field_present` clause for anything an
attribute depends on.

## 3c. Two clauses that silently match nothing

**A brace in a path glob is a literal byte.** `glob_here` implements only `**`,
`*` and `?`. `**/*.{js,ts,tsx}` therefore matches only a path that literally
ends in that text, so every rule carrying one emitted nothing — 75 clauses
across 9 frameworks, all reported "live" by the audit. If a fact kind already
implies its language, the extension filter was restating what the Pack decided:
drop it. `overlay_audit.py` flags these now.

**`external_path_matches` cannot name a scoped npm package.**
`parse_external_path` takes the first `/`-separated part as the package, so
`@sveltejs/kit` is package `@sveltejs`. Until the host fix in `OWED.md` item 7
lands, do not write a rule against a scoped package; and note `OWED.md` item 7a:
JS/TS facts carry no `external` at all, because the Packs publish `target` and
`module` rather than `qualifier`.

## 3d. Measure the exact spelling, and do not generalise one measurement

A wave-4 review measured that omega-cpp emits nothing for

    class MYGAME_API AHero : public ACharacter { GENERATED_BODY() int Health; };

which is true. A wave-5 agent read that as "Unreal classes are not declared" and
deleted 13 working rules. Measured alongside it,

    UCLASS() class ATwo : public AActor { GENERATED_BODY() int H; };

emits `definition.class ATwo`, `relation.implements AActor` and
`definition.field H`. **It is the export macro between `class` and the name that
breaks the parse, and nothing else.** The deletion was reverted.

So: when a review tells you a construct emits nothing, reproduce it yourself on
the exact spelling, and on the neighbouring spellings, before you act on it.
`target/release/examples/dump_call_emissions.exe <pack-dir> <grammar-dir> <file>`
takes a hand-written file and prints every emission with its span and name. One
run settles what an hour of reading `node-types.json` cannot.

And when you write a `coverage.gaps` entry, it is a claim like any other: the
same file asserted that `UCLASS` and `GENERATED_BODY` produce no fact, and they
arrive as `call.function` named exactly that.

## 3e. A built-in name makes a guard vacuous, and a placeholder is not a field

**`field_present` on a built-in is always true.** `OverlayFact::field` falls
back to `path`, `path.dir`, `path.stem`, `definition.name` and the rest when the
fields map has none, so `{"kind":"field_present","field":"path"}` guards
nothing: omega-framework-symfony's Twig rules carried it and matched every
`relation.depends` from every Pack in the repository. Gate on something that is
actually particular — a `path_glob`, a name set, a joined fact.

**`normalized_file_route` is a placeholder, not a field.** It resolves in
`resolve_placeholder`, which serves `{...}` templates in canonical keys and
relation ends. A `field_ref` attribute goes through `OverlayFact::field`, which
has never heard of it — so the attribute is unresolvable, the entity is dropped,
and every relation addressing that entity's key dangles. omega-framework-nuxt
lost its four principal entities this way. Use the name in a template; if you
want it as an attribute, there is no route to it.

## 3f. Narrowing a value list is a deletion, and needs the same evidence

Twice now an agent has narrowed a set of literals on the ground that "the Pack
does not publish these" and been wrong. omega-framework-vue cut a directive list
from twelve values to three, saying the old list "named no spelling the Pack
publishes" — but omega-vue emits `data.vue_directive_value` for **any**
`directive_attribute` carrying a quoted value, so the `directive` field holds
whatever was written and the list was the Framework's own choice. `v-bind`,
`v-if` and `v-show` lost their only coverage. The same shape cost
omega-framework-unreal-engine 13 rules a wave earlier.

Before you shorten a `field_in`, `member_in` or `#any-of?` list, read the Pack
pattern that produces the field. If the Pack captures the value generically, the
list constrains nothing but your own rule, and every value you drop is an answer
you delete.

## 3g. A canonical key holds exactly one entity, and the first rule wins

`Entity::named` builds its id from `EntityBindingSeed::Canonical { key }`
(`omega-domain/src/ir/view.rs:425`) — **the entity kind is not part of the
identity** — and `apply_overlay_runs` does

    entities.entry(id).or_insert(entity);

(`omega-semantic/src/framework/overlay_ir.rs:96`). Candidates are sorted by
`candidate_order`, whose first component is the `rule_id` string
(`overlay.rs:566`). So when two rules render the same canonical key, the one
whose id sorts alphabetically first materializes, **with its kind and its
attributes**, and everything the other rules computed for that key is silently
discarded. The host's own comment states the intent: "Two rules describing the
same construct agree on its key."

That is exactly what a hub entity is for: every rule that needs a type as a
relation end mints it under one key with **one** kind, and the relations carry
the meaning. It becomes a defect the moment two rules disagree about the kind.

Measured in omega-framework-maui, which put eleven kinds on `maui:type:{...}`:
for

    [QueryProperty(...)] public partial class DetailsPage : ContentPage
    { [RelayCommand] private async Task LoadAsync() {} }

five rules render `maui:type:DetailsPage`; `maui.mvvm.relay_command` sorts
first, so the graph gets a `MauiCommandOwner` carrying one attribute, and
`MauiPage` (with its base class and code-behind file), `MauiShellQueryReceiver`,
`MauiRouteTarget` and `MauiNavigationTarget` are all computed and thrown away.
A view model with a `[RelayCommand]` — in a CommunityToolkit.Mvvm app, every
view model — never materializes as `MauiViewModel` at all.

**The audit cannot see this**, the same way it cannot see a dangling relation
end. Measure it:

```bash
python pack-design/key_collisions.py <your-framework>
```

It prints every canonical key template minted under more than one kind, which
rule wins, and which outputs are dropped.

**The remedy, in order of preference:**

1. One neutral kind per key space, carrying the classification in the relations
   that point at it — `unity:type:{name}` is a `UnityType`, and it is a
   component because a `declares` edge from a `GameComponent` rule says so.
   Note that attributes collide too: only the first rule's attributes survive,
   so a classification carried as an attribute is no safer than one carried as
   a kind.
2. A key space per classification — `maui:page:{class}`, `maui:viewmodel:
   {class}` — related back to the hub. Heavier, but it keeps both kinds and both
   attribute sets, and each is separately addressable.

Never: several kinds on one key template.

## 3h. Two facts about matching the audit used to get wrong

**`data.file` exists, and it is the only way to address a file.** The host
pushes one synthetic fact per artifact before any Pack emission
(`OverlayFact::artifact`, `overlay.rs:41`): kind `data.file`, field `path`,
empty name, zero span. A rule about the file tree rather than about a
declaration — file-based routing, a migration, a manifest — matches it, and
`path.dir`, `path.stem` and the `normalized_file_route` placeholder all work on
it. The audit used to report it dead and three routing frameworks lost twenty,
eleven and ten rules to that. Do not delete a `data.file` rule on the grounds
that no Pack emits the kind.

**A kind is only live in the language your Framework runs on.** `call.member`
is emitted by omega-c, omega-cpp and omega-c-sharp and by no JavaScript Pack,
so a Node framework matching it matches nothing however many Packs in the
repository do emit it. `overlay_audit.py` now scopes its surface to your
`host.required_packs`, and reports a kind that only another language emits as
dead, naming the emitters. When you see that line, decide which of the two it
is: a rule written against the wrong language — delete it — or a manifest that
under-declares its packs, which is the case when your Framework legitimately
reads a second language's file, the way axum reads `Cargo.toml` and fastify
reads `package.json`. Then add the Pack to `host.required_packs`.

## 3i. `external_path_matches` is false in every language but two

`OverlayFact.external` is built by `external_environment` from bindings whose
`target_hint` is set; `target_hint` is `occurrence.qualifier`; and the host reads
a qualifier only from an emission field or attribute **literally named
`qualifier`**. Exactly two Packs publish one — omega-c-sharp and
omega-docker-compose. Everywhere else `external.package` and `external.member`
are empty on every fact, so an `external_path_matches` clause, scoped or not, is
false for every possible input. Twenty fastify rules and six flask rules were
scored live by the audit while matching nothing.

Use the import join instead. It reaches the same answer in any language:

```json
{"kind": "fact_join_by_field", "fact_kind": "import.module",
 "current_field": "path", "join_field": "path", "same_path": true,
 "where": [{"kind": "field_prefix", "field": "definition.name",
            "value": "fastify"}]}
```

*This file imports something whose module name starts with `fastify`* is what
keeps `call.method get` from meaning `Map.prototype.get`, and it is the gate
every rule in a package-scoped Framework should carry.

## 3j. Two idioms for a Pack that publishes nothing, and one thing to check first

**`definition.container` tells you which property a value was written under.**
Where a Pack spans a container declaration over its members — a `[node …]`
section over its properties, a class over its fields — the host's synthesized
container is a free discriminator: `field_equals definition.container script`
is the whole test for *this reference is the node's script*, and it separates a
node header's `type=` from a `Vector2(…)` written inside a property value. No
join, no Pack field.

**A section that declares nothing is grouped by a fact that spans it.** Where a
Pack emits per-attribute facts with no per-record declaration — Godot's
`[connection]` has `signal=`, `method=`, `from=` and `to=` as four siblings with
nothing between them — join `within` whatever fact covers the whole section and
key on its start offset. Its limit: the span-wide fact covers every sibling
equally, so the join cannot tell which sibling you are on, and `from=` and `to=`
stay indistinguishable.

**Check the quotes before you key on a value.** `fact_join_by_field` takes
`current_strip_prefix` and `join_strip_prefix`; there is no strip_suffix, and a
canonical key template has no strip at all. A Pack field captured from a raw
`(string)` node arrives as `"res://player.gd"` with its quote bytes and can
never meet the unquoted form of the same string — which is how the old godot
overlay's one live sub-graph ended up joining nothing. If the value you want as
an identity is quoted, that is a Pack fix, not something to work around.

## 3k. A rule's attributes accumulate across its outputs, in order

`{path}` in a canonical key does not always mean the artifact path.
`resolve_placeholder` looks in the rule's attributes **before** it looks at the
fact, and the attribute bag carries forward from one output to the next in
output order. omega-framework-express minted a Route with an attribute `path`
set to the route's URL, and the `express:app:{path}` entity two outputs later
came out as `express:app:/users/:id`.

Name an attribute for what it is -- `route`, `module`, `class` -- and keep
`path`, `name` and the other built-in names for the built-ins. If you do want the
normalized form of your own attribute, that is what `{normalized_<attribute>}`
is for: `{normalized_route}` is the route-normalized value of the attribute
`route`, so `/users/:id`, `/users/{id}` and `/users/[id]` are one identity.

## 3l. The first argument of a call is published, in two forms

Nine Packs publish the canonical call view on their call templates:

| field | value for `app.get("/users/:id", mw, getUser)` |
|---|---|
| `call.arg0` | `"/users/:id"` -- as written, quote bytes and all |
| `call.arg0_text` | `/users/:id` -- without the quotes |
| `call.arg1`, `call.arg2` | `mw`, `getUser` |
| `call.arg1_text` | the second argument unquoted -- `r.Handle("GET", "/legacy", h)` puts the URL there |
| `call.last_arg` | `getUser` |
| `receiver` | `app` |

| `call.arg0_name`, `call.last_arg_name` | `GetUser` -- the last segment of a qualified name |

Every argument slot carries all three: `call.arg1_text` and `call.arg1_name`,
`call.last_arg_text` and `call.last_arg_name`, and so on. Django's route puts
the view in argument one, gin's `Handle` puts the URL there.

**A guard that a spelling fails is a deletion, and inside a join's `where` it
kills the whole binding.** vapor and maui each lost a real answer to
`field_prefix call.arg0 = "\""`: `todos.get(use: index)` and
`Routing.RegisterRoute(nameof(DetailsPage), typeof(DetailsPage))` have no quote
byte, and both are the spelling their own documentation uses. Where a construct
has two spellings and only one carries a literal, write two rules -- the literal
one stating the value, the other stating what it can.

**In omega-ruby and omega-kotlin, `call.arguments` is not every call.** Its
pattern requires an argument list, and neither language needs one: `before_save
do … end`, `default_scope { … }`, `run { }` emit `call.method` and no
`call.arguments` at all. Matching only `call.arguments` deletes every block form.
Write both rules and have them mint the same key with the same kind, and give
the argument-bearing one the **shorter id** -- the host interns with
`or_insert`, so the first rule by id is the one whose attributes survive.

**A `data.file` rule sees every artifact in the view**, not only the ones your
Framework's languages parse -- `.png`, `.txt`, `.json`, `.md`. That is what
makes a static `app/robots.txt` or `app/icon.png` reachable, and it is why such
a rule must pin an extension or a distinctive stem: a bare `**/pages/**/*.*`
mints a Route for every stylesheet and README under `pages/`.

**A measurement you write down has a date.** Three times now a `coverage.gaps`
sentence or a "field only the Pack can supply" note has outlived the thing it
measured, and the next agent inherited a conclusion instead of a fact --
omega-framework-vue recorded `provide('themeKey')` as permanently unreachable
two waves after the JS Packs started publishing `call.arg0_text`. Before you
repeat a gap the previous author wrote, measure it again.

**`fact_join_by_field` is a full cross product.** It pushes a binding for every
matching candidate, not the first, so joining on the built-in `path` binds every
fact of that kind **in the whole file**. That is only safe when the file holds
exactly one of them. omega-framework-kubernetes-config tied a manifest's `kind`
to its `metadata.name` that way and minted n² objects for an n-document YAML
stream. If you need "the other key of the same record", join through a fact that
spans the record -- and reach its members with `contains`, not `within`.

**`definition.container` is the innermost enclosing definition, and a tie is
broken by emission order.** Where a Pack puts several definition facts on one
span -- a Prisma field, its modifier and its type all span the field -- the
innermost is whichever the Pack emitted last, which is not the one you meant.
Check with `dump_call_emissions` before keying on it; `enclosing.qname` or a
span join is often what you actually want.

**A value literal is a measurement with a date, and no check sees it go stale.**
A Pack adding one named `definition.*` fact changes every `definition.qname`,
`enclosing.qname` and `definition.container` under it, because the host builds
those from the nesting of named definition facts. When a YAML document fact was
added as a declaration, 25 shipped kubernetes-config rules went from stating a
graph to stating **nothing** -- and `overlay_audit.py` still reported 25 live
and `key_collisions.py` nothing, because both are structural and neither can see
a literal that no longer occurs. Run the rules over real `dump_call_emissions`
output before you believe a value comparison.

**`field_absent` is how a rule says "at the top level".** A construct with no
enclosing declaration has no `enclosing.qname` at all, and every other clause
needs a value to compare against.

**An audit cannot tell you whether the Pack's grammar can run.**
`overlay_audit.py` builds its surface from `packs/*/rules.json` and never looks
at a grammar's detection keys. Nine laravel rules matched omega-blade and scored
live for a whole programme while every `.blade.php` in existence was being
routed to omega-php by its tail. If your Framework's language is reached by an
unusual filename or a compound suffix, check `grammars/<slug>/manifest.toml`
yourself.

**Key a handler on `*_name`, never on the argument as written.** A handler is
written `ctrl.GetUser`, `handlers.ListUsers`, `handlers::show_user` at the
registration and declared as `GetUser`, `ListUsers`, `show_user`. Four
frameworks in one wave keyed the route end on `call.last_arg` and lost *which
function answers this route* -- and all three checks reported clean, because
both keys are minted, they simply never meet. The separators are the language's
own: omega-rust splits on `::` before `.`.

**Key on `call.arg0_text`, never on `call.arg0`**: a canonical key template has
no strip, so a value that carries its quote bytes cannot be an identity and can
never meet the unquoted form of the same string.

`call.arg0_text` is one `unquote` over a `default` to the empty string.
`unquote` returns a string literal's text without its delimiters and anything
else unchanged. It exists because the pair of independent strips that came
before it turned a Python keyword argument `alias="userId"` into `alias="userId`
-- `strip_prefix` and `strip_suffix` do not know about each other, so the
trailing quote came off although the leading one was never there. The `default`
is load-bearing too: a call with no arguments has no first argument, and an op
over a None is a type error that skips the whole template, which quietly stopped
`app.listen()` being a call at all.

In omega-ruby, omega-kotlin and omega-swift the arguments are a separate
emission, `call.arguments`, on the **same span** as the call -- a Ruby call
needs no parentheses and a Kotlin or Swift call can be all trailing closure, so
there is no argument node to capture and an unbound capture would skip the whole
call template. Read it with `fact_join_by_span` `relation: "same"`.

## 4. Verification

```bash
cd D:/WebProjects/omega-code-search
cargo run --release -j 6 -p omega-runtime --example validate_external_assets -- D:/WebProjects/omega-code-search-assets
```

`asset validation passed` means the JSON parses, the selector matches the
manifest, and both programs validate. It does **not** mean your rules match
anything.

For that:

```bash
cd D:/WebProjects/omega-code-search-assets
python pack-design/overlay_audit.py <your-framework>
```

Run it before you start and after you finish, and report both verbatim. Every
rule should be live at the end, or your `.md` must say why one is deliberately
kept against a fact no Pack emits yet.

Other agents are rewriting other Frameworks in the same repository at the same
time, so the validator may report an error naming an asset that is not yours.
Only errors naming your framework are yours.

## 5. Hard rules

- Touch **only** `frameworks/<your-framework>/` and
  `framework-design/<your-framework>.md`. Nothing else in the repository — not
  another framework, not a Pack, not a grammar, not the contract, not the index,
  not `overlay_audit.py`.
- **If you conclude a Pack must publish a field**, do not edit the Pack. Write
  the case in your `.md` under a heading "A field only the Pack can supply",
  naming the Pack, the kind, the field and why a join cannot reach it, and
  report it in `cross_framework_findings`.
- Run **no** git command that changes anything. Read-only `git log`, `git show`,
  `git diff` are fine and useful for seeing what a rule used to match.
- Do not modify anything in `D:/WebProjects/omega-code-search`. Read it to check
  a rule; `crates/omega-semantic/src/framework/overlay.rs` is the authority.
- Do not run `node tools/build-source.mjs`.
- Leave `detection_rules` alone unless it says something untrue. It is a
  different program, unaffected by the Pack rewrite.

## 6. Done means

- `python pack-design/overlay_audit.py <framework>` reports zero rules that
  cannot match.
- Every surviving rule answers a question a person would ask, and your `.md`
  says what each one answers.
- `framework-design/<framework>.md` has **What was wrong with it** (concrete,
  with counts) and **What it states now** (a table: what → which Pack fact →
  which entity or relation).
- `validate_external_assets` passes for your asset.
- The file is not longer than the one it replaced unless you can say what the
  extra rules answer.

Report back: the audit before and after, the rule count either way, what the
overlay now lets an agent ask, anything that belongs in `00-INDEX.md` because it
is not one Framework's problem, and any field you need a Pack to publish.
