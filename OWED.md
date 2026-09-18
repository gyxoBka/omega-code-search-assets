# Owed work

Everything this rewrite created and did not finish, in one place so it is not
lost between commits. Each item says what it is, why it was deferred, and what
"done" looks like.

Last updated after framework wave 13, the last one. Numbers come from
`python pack-design/audit.py` and `python pack-design/overlay_audit.py`.

---

## 1. Pack fields the Frameworks need

**`qualifier` is done for JavaScript, TypeScript and TSX.** It was the gate on
everything else: `OverlayFact.external` is built from bindings whose
`target_hint` is set, `target_hint` is `occurrence.qualifier`, and the host reads
a qualifier only from a field or attribute literally named `qualifier`. Two Packs
published one. Now five.

The obstacle was not the name but the query. `@import.module` was captured on the
`import_statement`'s source in one pattern and `@import.default` /
`@import.namespace` / `@import.symbol` in separate patterns, and a template can
only reference captures from its own match -- so no template could see both the
local name and the module it came from. The three Packs now carry patterns that
capture them together, and three bindings that carry the specifier:

| binding | from | `qualifier` |
|---|---|---|
| `binding.import_default` | `import express from "express"` | `express` |
| `binding.import_namespace` | `import * as path from "node:path"`, `import fs = require("fs")`, `const fs = require("fs")` | `node:path`, `fs`, `fs` |
| `binding.import_symbol` | `import { Router } from "express"` | `express` |

`binding.import_alias` is unchanged and still carries `target`: for `import
{ json as parseJson }` the alias resolves `parseJson -> json` and
`binding.import_symbol` resolves `json -> express`, which is the chain
`ExternalEnvironment::resolve` walks. The kinds matter: `external_environment`
sends anything whose kind contains `alias` to `env.alias` and only the rest to
`env.import`, so a binding that names a package must not be spelled as an alias.
That is why `import fs = require("fs")` moved from `binding.import_alias` to
`binding.import_namespace` -- it binds a whole module to one name, which is what
a namespace import does. No Framework matched any `binding.import_*` kind, so
nothing downstream broke.

Measured with `dump_call_emissions` on all three Packs; the three versions are
bumped to 2.1.0, because the store rejects a changed asset under an unchanged
version.

**What is not yet shown end to end:** that `qualifier` arrives as
`surface_bindings.target_hint` in a built index. The engine's own test
(`omega-ingest/tests/ai15_static_test_entities.rs:307`) asserts that a template
field named `qualifier` becomes `occurrence.qualifier`, and `surface.rs:376`
copies that into `target_hint`, so the chain is sound by construction -- but a
local index kept reusing its cached analysis component after the Pack was
re-selected, and the rows still read `target_hint = NULL`. The deferred
framework wave is the real consumer and will settle it.

### Still collecting

**Status: the call rows are done** — item 17 restored the canonical call view in
nine Packs, which closed every row that asked for a call's first argument or its
receiver. What is left is the config-shaped rows, and they are all the same
one-word move.

`OverlayFact::field` (`omega-semantic/src/framework/overlay.rs:56`) resolves the
`fields` map and a fixed list of built-in names. It **never consults
`attributes`**, and the only clause that reads an attribute is
`attribute_equals`, against one literal constant. So a value a Pack publishes as
an *attribute* can be tested for equality and used for nothing else: not as a
canonical key, a relation end, an entity attribute, or a join key.

**Same bytes, a different map** is the whole of most rows below.

| Pack | kind | move to `fields` | asked by |
|---|---|---|---|
| omega-yaml, omega-json | `definition.config_key` | `value` | kubernetes-config, openapi-v3, gitlab-ci, github-action |
| omega-hcl | `definition.config_block` | `block_type`, `type_label` | terraform |
| omega-hcl | `reference.traversal` | `root` | terraform |
| omega-javascript, omega-typescript, omega-tsx | `import.symbol` | `module` — the specifier the symbol came from | react |
| omega-caddyfile | `definition.config_matcher_condition` | `operand` — what the condition tests for | caddyfile |
| omega-php | `reference.attribute` | the attribute's argument text — `#[Route('/orders/{id}')]` is where a Symfony URL is stated | symfony |
| omega-xml | `definition.config_attribute` | `value` | maui — `Route="home"`, `x:Class="MyApp.DetailsPage"` |
| omega-prisma | `definition.config_setting` | `value` | prisma — `provider = "postgresql"` is the most-asked fact about a schema |
| omega-razor | `reference.attribute_value` | `attribute` — which event a handler is bound to | blazor |
| omega-hcl | `definition.config_block` | `type_label` — the resource type, which is what attributes a resource to a provider | terraform-providers |
| omega-python | `reference.decorator` | `target` — the declaration the decorator is attached to; in tree-sitter-python they are siblings, so no span join reaches it | flask |
| omega-python | `reference.decorator` | the decorator's first argument — the call templates have it now, a decorator is a separate pattern with no argument capture | pydantic, pytorch-extensions, django |

`qualifier` is the one with a second consumer: the host reads it for external
package resolution (`content_builder.rs::mention_fields` accepts a qualifier
only under that literal name, and `materialize.rs::external_environment` builds
`OverlayFact.external` from bindings whose `target_hint` is set).

**Done looks like:** one commit moving those values, re-running both audits, and
a second pass over the frameworks that asked, so they actually use what they
now can reach. Add to this table as later waves report; the workflow prompt
collects `pack_fields_needed` from every agent.

### 1a. Not a field: a span that cannot be joined

omega-c-sharp spans `definition.field` on the `variable_declarator` while
`reference.attribute` spans the `attribute` node. The attribute is a direct
child of `field_declaration`; the declarator is a grandchild through
`variable_declaration`. So neither span contains the other and
`fact_join_by_span` cannot relate them — `[SerializeField] private float speed;`
cannot be answered, and *which fields does the inspector show* is unanswerable
for Unity.

**Done looks like:** the field declaration spanned so an attribute on it is
`within` it, without breaking the `within:` namespace segment that the
declarator span gives a member.

---

## 2. A framework overlay for nixpkgs stdenv

omega-nix carried 22 injection patterns keyed on nixpkgs and home-manager
library names — `writeShellApplication`, `runCommand*`, `writeBash*`,
`nixosTest`, `testScript`, `^[A-Za-z]+Phase$`, `^pre[A-Za-z]+$` — which is a
framework overlay inside a language Pack and was removed on that ground.

Parsing the bash inside `buildPhase` is worth having. It now has nowhere to
live: there is no `frameworks/omega-framework-nixpkgs-stdenv`.

**Done looks like:** that framework exists, or the index records a decision not
to have it.

---

## 3. Defect classes still open in the Packs

From `python pack-design/audit.py`, after all 61 rewrites:

| class | count | what it needs |
|---|---|---|
| carrier that may overwrite itself | 57 | **mostly a false positive.** `node-types.json` cannot express "at most one of this child", so a grammar that puts every child of a statement in one repeat group — tree-sitter-sql, tree-sitter-batch, the modifier groups in tree-sitter-typescript — reports every correct carrier. Either the check learns to tell a genuine repeat from an undifferentiated group, or this list records the known-ungroupable grammars so each agent does not rediscover it |
| carrier under a name nothing assembles | 27 | real, and not fixable as stated: a carrier is the only way to attach an *optional* attribute to a declaration, and only five carried names build the signature line. The check needs a notion of "deliberately not a signature component", or `expr.rs` needs an unbound capture to yield an empty string instead of skipping the template — `default` cannot help, because `CaptureRef` errors before `default` sees it |
| D2 the name is the span itself | 9 | each is argued for in its Pack's `.md`; re-read them once rather than trusting the count |
| K2 same span and name, two kinds | 6 | decide which spelling is right and delete the other |
| J a name that is a constant | 2 | both are a language's single spelling for a construct with no name of its own (`_init` in GDScript). Worth a sentence in the J row of `pack-design/00-INDEX.md` distinguishing that from a J that collapses distinct constructs onto one string |
| D the name is a whole node | 2 | real |

---

## 4. Grammars that cannot carry their language

`grammars/omega-vbscript` (JJK96/tree-sitter-vbscript@6d9548e) has no node for
`Class`/`End Class`, `Property Get/Let/Set`, `Const`, `Set`, `Select Case`,
`With`, `On Error` or `Option Explicit`, and parses a parenthesised call
statement (`Helper(n)`, legal and common) as an `ERROR` node. Its bundle already
says `status = "experimental"`. omega-vbscript is at that grammar's ceiling and
the remaining gap is entirely upstream.

**Done looks like:** a list in `pack-design/00-INDEX.md` of grammars whose
ceiling a Pack has reached, so nobody re-opens a closed question.

---

## 5. README is stale — fixed

`README.md:18` claimed Pack query sections keep their former logical names in
`main.scm` and that patterns, captures, output kinds and rule identities are
unchanged. No Pack has a `main.scm`, and after this work all four are different
by design. Replaced by what is true now, with the layering paragraph above it
kept, because that is the statement the whole framework contract rests on.

---

## 6. The framework waves themselves -- done

**754 overlay rules across 55 frameworks; 0 cannot match any Pack emission.**
`key_collisions.py` reports 0, `dangling_ends.py` 3 candidates, all pydantic and
all read. From 1525 rules of which 1217 could not match, in thirteen waves.

---

## 7. A scoped npm package can never be matched -- fixed

`parse_external_path` (`omega-semantic/src/framework/materialize.rs`) split the
target on `/` and took the first part, so `@sveltejs/kit` became package
`@sveltejs` with segments `["kit"]`. 40 clauses in five frameworks depended on a
match that was unreachable for every possible input.

Fixed in the engine at `af46af8`: when the first part begins with `@` and there
is a second, they are the package together. **No freeze re-stamp was needed** --
the frozen design-set file is `crates/omega-semantic/src/materialize.rs`, a
different file from `crates/omega-semantic/src/framework/materialize.rs`. The
six design-set obligations pass unchanged.

### 7a. Almost no fact anywhere carries `external`

Separately and compounding it: `facts_of_surface` resolves external identity
through `external_environment`, which only registers a binding whose
`target_hint` is set. `target_hint` is `occurrence.qualifier`, and `qualifier` is
read only from an emission field or attribute literally named `qualifier`. The
JS/TS Packs publish `target` and `module`, never `qualifier` — so
`external.package` and `external.member` are empty for every JavaScript and
TypeScript fact, and every `external_path_matches` clause in a JS framework
fails regardless of scoping.

This is the same `qualifier` row already in item 1, now known to be load-bearing
for the whole `external.*` mechanism in the largest language family Omega has.

Measured again in wave 10 across Python, and then across every Pack: exactly
**two** publish a `qualifier` — omega-c-sharp and omega-docker-compose. So
`external.package` and `external.member` are empty on every fact in every other
language, and an `external_path_matches` clause is false for every possible
input whether or not the package is scoped. `overlay_audit.py` now reports that.

**This demotes item 7.** Teaching `parse_external_path` about scoped packages
fixes nothing until a Pack publishes `qualifier` at all: the four frameworks
deferred behind it — nestjs, angular, tauri, astro — are JavaScript, and would
still see an empty `external`. The order is now: publish `qualifier` from the
JS/TS Packs (item 1), *then* the host fix, *then* those four. In the meantime
the import join is the answer, and fastify and next-js are written that way.

---

## 8. omega-cpp does not see a class declared with an export macro before its name

Measured with `dump_call_emissions` over `packs/omega-cpp` on a canonical
Unreal header:

```cpp
class MYGAME_API AHero : public ACharacter { GENERATED_BODY() int Health; };
struct MYGAME_API FRow : public FTableRowBase { GENERATED_BODY() int V; };
```

Total emissions for both declarations: `reference.type MYGAME_API` twice and
`call.function GENERATED_BODY` twice. **No `definition.class`, no
`definition.struct`, no `relation.implements`.**

It is the macro **between `class` and the name** that does it, and nothing else.
Measured alongside it, `UCLASS() class ATwo : public AActor { GENERATED_BODY()
int H; };` emits `definition.class ATwo`, `relation.implements AActor` and
`definition.field H` — everything a rule needs. A wave-5 agent generalised the
first measurement to all Unreal headers and deleted 13 working rules on that
basis; the deletion was reverted.

`class EXPORT_MACRO Name` is not an Unreal peculiarity: it is how every C++
library that ships a DLL declares a public class (`MYLIB_API`, `CORE_EXPORT`,
`__declspec(dllexport)` behind a macro).

**Done looks like:** omega-cpp declaring the class in that shape. Until then
omega-framework-unreal-engine answers for the plain spelling only, and its
`coverage.gaps` says so.

---

## 9. Eight frameworks mint several entity kinds on one canonical key

Entity identity is the rendered canonical key **alone**:
`EntityId::from_binding(Canonical { key })` (`omega-domain/src/ir/view.rs:425`)
never sees the descriptor, and `apply_overlay_runs` interns with `or_insert`
(`omega-semantic/src/framework/overlay_ir.rs:96`), candidates ordered by
`rule_id` string (`overlay.rs:566`). First rule wins, with its kind **and** its
attributes; every other rule's output for that key is discarded in silence.

`python pack-design/key_collisions.py` counted **62 dropped entity outputs in 8
frameworks**. Wave 11 closed unity, unreal-engine and ruby-on-rails; **26 remain**,
listed in item 15.

A shared key with **one** kind is the hub pattern and is correct — it is how a
relation from another file lands on a type. Several kinds on one key is the
defect.

**Done looks like:** each of the eight either minting one neutral kind per key
space and carrying the classification in its relations, or giving each
classification its own key space related back to the hub; and
`key_collisions.py` reporting zero. Scheduled as its own wave, after the
matchability waves. angular is behind item 7.

---

## 10. Two things omega-rust cannot say, both measured

**A scoped path emits a fact at every nesting level.** `(scoped_identifier name:
(identifier) @reference.path.name) @reference.path` fires on each
`scoped_identifier` in the nest, so `get(crate::handlers::users::list)` emits
three `reference.path` facts — `handlers` at 56-71, `users` at 56-78, `list` at
56-84. Only the widest is the thing referred to. omega-framework-axum's handler
rule therefore mints `axum:handler:users` and `axum:handler:handlers` beside the
real one, and **the overlay has no clause for "not contained in another fact of
this kind"** — `fact_join_by_span` only affirms containment. Either omega-rust
emits the outermost path only, or the overlay gains a negative span join.

**`[dependencies.axum]` is invisible.** omega-toml names a table from its header
text, so the ordinary Cargo spelling

```toml
[dependencies.axum]
version = "0.7"
```

names the table `dependencies.axum` and puts one `definition.config_key` named
`version` under it. Every rule that gates on *a config_key named axum inside a
config_table named dependencies* is silent for it — in omega-framework-axum that
is all twelve rules. The inline spellings (`axum = "0.7"`, `axum = { version =
… }`) do match. A `field_prefix` on the table name would reach it if the
config_key gate moved; noted, not yet decided.

---

## 11. A call's string arguments are unreachable in Go, Rust and C#

Four frameworks this wave asked for the same thing and none can get it by a join:
these Packs emit **no fact at all** over a string literal, so `fact_join_by_span`
has nothing to bind, and they publish no field to derive from either.

| Pack | what is lost |
|---|---|
| omega-go | every Fiber/Gin/Echo route's URL, a `Group("/api/v1")` prefix, a `Static` mount's directory, the verb in `Handle("GET", …)` |
| omega-rust | every axum `.route("/users/:id", …)` path and `.nest("/api", …)` prefix |
| omega-c-sharp | MAUI's `Routing.RegisterRoute("details", typeof(P))` and `GoToAsync("//details")` |

omega-python has the same row in item 1 already (asked by django in wave 2).

It is bigger than a field: the honest shape is **one `literal.string` template
per Pack**, named by the literal's text and spanned on the literal node, which
every framework overlay can then reach with a span join — rather than a
per-kind `arg0_literal` field that has to be added to every calling template.
Decide the shape once and apply it to all four Packs.

Two of the three also publish **no field on any template at all** (omega-go 47
templates, omega-rust 71), the same shape the index already records for
omega-ruby. Those overlays have kind, name, path and span and nothing else.

---

## 12. Grammars that could not be reached by their own file extensions — fixed

`ParserRegistry::detect_path` (`omega-ingest/src/parser_registry.rs:377`) tries
`filenames`, then `shebang_regexes`, then the extension through `by_language`,
whose alias map is `language` + `aliases` + `extensions`. A grammar declaring
`extensions = []` was therefore reachable by extension **only when the extension
happened to spell its language name** — `.go` found `go`, `.rb` did not find
`ruby`.

**51 of 59 grammar manifests declared `extensions = []`**, and the eight that did
not are exactly the packs the control index had installed, which is why this was
never seen. 27 grammars had at least one unreachable extension, `.xml`/`.xaml`,
`.rb`, `.cs`, `.kt`, `.md`, `.tf`, `.hpp`, `.sh`, `.ps1`, `.gd` among them —
every framework overlay over one of those languages was inert on a real
repository whatever its rules said.

**Done.** 31 manifests now declare the extensions their language uses, plus
filenames for `Makefile`, `GNUmakefile`, `CMakeLists.txt`, `nginx.conf`,
`.editorconfig`, the shell rc files and Ruby's `Gemfile`/`Rakefile`/`Guardfile`/
`Podfile`/`Brewfile`, and shebang regexes for bash, python, ruby and php. Every
detection key is globally unique — `check_identity_available` drops a whole
bundle on a duplicate — so the three contested extensions were decided:
`.h` stays with omega-c, `.conf` is too generic to belong to nginx (which is
reached by the filename `nginx.conf` instead), and `.sc` goes to scala.

Proved end to end rather than by reading: a ten-file polyglot fixture indexed
with those grammars and packs installed gives

| file | definitions |
|---|---|
| `repo.kt` | Repo, find, name, id, app |
| `main.tf` | aws_s3_bucket, bucket, b |
| `app.csproj` | Project, PropertyGroup, TargetFramework, Sdk |
| `Service.cs` | Service, Add, App |
| `widget.hpp` | Widget, size |
| `readme.md` | Title |
| `greeter.rb` | Greeter, hello |
| `thing.ps1` | Get-Thing, Name |
| `player.gd` | _ready |
| `Gemfile` | none — but two reference intents and six coverage rows, so the Ruby pack ran on it |

Two things learned doing it, both worth keeping:

**A changed manifest under an unchanged version is rejected by the store** —
`Store(AssetLogicalRebind { kind: "GRAMMAR_BUNDLE", logical_id:
"tree-sitter-markdown", version: "0.1.0-source-staged" })`. Every touched bundle
got a patch bump, suffix preserved.

**A grammar cannot declare a filename that spells its own language.**
`validate_manifest` lowercases `language`, `aliases`, `extensions` and
`filenames` into one set and rejects a repeat, so omega-dockerfile cannot list
`Dockerfile` and omega-caddyfile cannot list `Caddyfile`. Both files have no
extension, so **a file literally named `Dockerfile` or `Caddyfile` reaches no
parser today.** That is a host rule to relax — the identity check should compare
filenames against filenames, not against the language name — and until then
those two languages are reachable only through `Containerfile` and `.caddyfile`.

### 12a. `.blade.php` — fixed

`Path::extension` of `home.blade.php` is `php`, so every Blade template in
existence went to omega-php and omega-blade could never claim one. Nine of
omega-framework-laravel's eighteen rules matched a Pack that could not run, and
all three audits scored them live, because `overlay_audit.py` builds its surface
from `packs/*/rules.json` and never looks at the grammar's detection keys.

`detect_path` now walks the whole suffix chain, longest first, and omega-blade
declares `blade.php`. The same mechanism serves `.d.ts` and any other compound
suffix. `parser_registry.rs` is frozen: the six obligations were re-run and
`freeze.json` re-stamped, and the behaviour has its own test in
`migrated_parser_registry.rs`.

**Still true and worth knowing:** the audits cannot see whether a Pack's grammar
is reachable at all. Twenty grammars are reachable only because their extension
spells their language name, which is correct for `.go`, `.vue` and `.sql`; the
one real remainder is `Caddyfile`, which has no extension and cannot declare its
own filename because a manifest may not repeat its language as a filename.

---

## 13. The file-shaped rules -- restored

`OverlayFact::artifact` pushes one synthetic `data.file` fact per artifact, and
`overlay_audit.py` built its kind set from `packs/*/rules.json` and reported it
dead. On that false premise the rewrite waves deleted the file-shaped rules of
the frameworks whose whole subject is the file tree: next-js 20, nuxt 11,
sveltekit 10, vue 3, blazor 2.

Restored in second-pass wave D, each minting the same key with the same entity
kind as the declaration-entered rule beside it, with a `.file` suffix so the
declaration rule sorts first and keeps its attributes. A `page.tsx` that is
static markup, a `+page.svelte` that declares nothing, a script-only
`components/*.vue` and `app/robots.txt` are all entities again.

**Worth keeping:** a `data.file` rule sees **every artifact in the view**, not
only the Framework's own languages -- `.png`, `.txt`, `.md` included. That is
what makes a static metadata file reachable, and it is why such a rule must pin
an extension or a distinctive stem.

---

## 14. A Pack value that keeps its quote bytes cannot be an identity

omega-godot-resource has three templates written for the overlay —
`structured.godot_section_attribute_context`,
`structured.godot_ext_resource_id_path_context`,
`structured.godot_node_script_ext_resource_context` — and all three capture the
`(string)` node raw. So `attribute_value`, `resource_path`, `node_name` and
`resource_id` arrive as `"res://player.gd"`, quotes included, while the same
Pack's `definition.scene_node`, `definition.resource` and `relation.depends`
strip them.

The overlay cannot repair it. `fact_join_by_field` takes `current_strip_prefix`
and `join_strip_prefix`, there is no strip_suffix, and a canonical key template
has no strip at all. A quoted value therefore cannot be an identity and cannot
meet the unquoted form of the same string — which is why the old godot overlay's
one live sub-graph never joined anything.

**The general rule, now in the Pack contract's terms:** a value a Framework will
key on must be normalized by the Pack that publishes it. The rewrite left those
three templates read for one thing only (the `[connection]` section's span), so
four of their five fields are now read by nobody.

**Done looks like:** those templates stripping their strings like the rest of
the Pack, and the fields nothing reads removed.

---

## 15. Key collisions -- closed

`python pack-design/key_collisions.py` reports **zero** after wave 13 closed
angular's three. unity, unreal-engine, ruby-on-rails, vapor, swiftui,
maui and nuxt are all silent, and so is the cross-framework check.

vapor settled the remedy. A type is routinely several things at once -- `final
class Todo: Model, Content` -- and remedy 1 keeps only the first rule's
attribute set, so a key space per classification with a relation back to the
neutral hub is the default for this shape, not a per-framework judgement.

**Done looks like:** angular's three closed in the deferred wave.

---

## 16. A dangling relation end now has a check -- and it is a candidate finder

`pack-design/dangling_ends.py` collects the canonical key templates a file's
`entity_candidate` outputs render, collects the ones its `relation_candidate`
ends address, and reports the difference. That is the class wave 1 found three
times and every wave since has checked by reading.

It compares text, so it finds candidates rather than verdicts: two templates
that differ textually can render the same string. `{op.path}` and `{path}` are
normalized to the same thing, but omega-framework-pydantic mints
`pydantic:model:{definition.container}` from a base-class reference and
addresses `pydantic:model:{model.definition.name}` from the class itself, and a
nested join makes those the same name by construction. Read the pair before
believing a row.

Across all 55: **37 rows, 34 of them in angular and nestjs**, which have not
been rewritten at all and are deferred; pydantic's 3 were read and are sound.

**Done looks like:** the deferred wave closing angular's and nestjs's, and the
check run beside the other two from then on.

---

## 17. The canonical call view -- restored in nine Packs

An engine test
(`crates/omega-ingest/tests/injection_regions.rs::the_canonical_call_view_reaches_the_emission_fields`)
reads the live omega-typescript Pack, executes `app.get("/users/:id", mw,
getUser)` and asserts the call publishes `call.arg0`, `call.arg1`,
`call.last_arg` and `receiver`. It failed: the Pack rewrite deleted the two
templates that did it, as restating their match. They do not restate it -- each
argument is `first`/`select`/`last` over `ordered_children` of the captured
argument list, ops `expr.rs` has always had.

That view is what nine Frameworks asked for across the waves as "a field only
the Pack can supply". Restored, on the current kind names, in nine Packs:

| Pack | now answers |
|---|---|
| omega-typescript, omega-javascript, omega-tsx | `app.get("/users/:id", mw, getUser)` -- the URL, the middleware, the handler, the receiver |
| omega-go | `r.GET("/users/:id", ctrl.GetUser)`, `app.Static("/assets", "./public")` |
| omega-rust | `.route("/users/:id", get(handlers::list))`, `.nest("/api", …)` |
| omega-python | `path("admin/", admin.site.urls)`, `include_router(users.router, prefix="/api")` |
| omega-c-sharp | `Routing.RegisterRoute("details", typeof(DetailsPage))` |
| omega-kotlin | `composable("home") { … }`, `navController.navigate("details")` |
| omega-ruby | `belongs_to :author`, `validates :title, presence: true` |

The engine test now names the current spelling: the kind is `call.method`,
because the rewrite gave every language one spelling for a call on a receiver,
and the callee's name is the emission's name rather than a field repeating it.

### Where the arguments are a fact of their own

In most languages a call always has an argument-list node, empty parentheses
included, so the arguments are fields on the call itself. **Ruby and Kotlin are
not like that**: `save`, `run { }` and `launch { }` have no argument node at
all, and an unbound capture skips a whole template -- which silently deleted
every trailing-lambda call from omega-kotlin when it was first tried. In those
two the arguments are a second emission, `call.arguments`, on the same span as
the call, read with `fact_join_by_span` `relation: "same"`.

That is the general rule: **an optional capture is not optional, it is a filter
on the whole template.** `default` cannot rescue it, because `CaptureRef` fails
before `default` sees it.

### Still to do

**omega-swift -- done.** Its call pattern ends in `(call_suffix)` and a
trailing-closure call has no `value_arguments`, so it took the Ruby/Kotlin
treatment: a `call.arguments` emission on the **same span** as `call.swift`.
`app.get("todos", ":id") { req in … }` now gives `todos` and `:id`, and
`Task { }` is still a call. Ten Packs carry the view.

**The second pass over the Frameworks.** fastify, express, bun, gin, fiber,
axum, vapor, maui, django, pydantic, pytorch-extensions, jetpack-compose and
ruby-on-rails all wrote "a Route has no URL" into their `coverage.gaps` and
keyed routes by byte offset. They can now say it. Items 1 and 11 close with that
pass.

**The quote bytes -- decided.** `call.arg0` is the argument as written, quote
bytes and all, which is what the engine test asserts. Beside it the nine Packs
now publish `call.arg0_text`, the same value without its quotes, because a
canonical key template has no strip and a value that carries its quotes can
never meet the unquoted form of the same string. Frameworks key on
`call.arg0_text`.

**Done so far:** omega-framework-express keys its routes by URL again --
`http:{method}:{normalized_route}` from `call.arg0_text`, with `handles` to the
handler named by `call.last_arg` -- and the engine test that asserts it passes.
omega-framework-astro's file routes are back in their own `astro:page:` key
space, which is what the other engine test asserts. The other twelve are the
pass that remains.

---

## 18. No JS/TS Pack states a string-keyed object-literal property

Measured by the bun reviewer against omega-javascript and omega-typescript on

```js
Bun.serve({ routes: { "/api/users": listUsers, "/health"(req) { … } } })
```

Neither Pack emits **any** fact for a quoted-key property. An identifier key
does emit `definition.method` in omega-javascript, so it is the quoting that
breaks it: omega-javascript's pair query requires a `property_identifier` key
and omega-typescript only emits for the shorthand method form.

That is Bun's entire route table, and it is not Bun's alone: Vite's
`resolve.alias`, Webpack's loader and alias maps, Jest's `moduleNameMapper`,
every `exports` map in a `package.json`-shaped literal. Any framework `.md` that
claims to read one of these is claiming a fact no Pack states.

No join reaches it either. The route table lies outside the `call.method serve`
span, which is the six bytes of the `serve` token, and the only fact containing
the whole thing -- `definition.variable server` over `server = Bun.serve({…})` --
covers every route in the table equally, which is the stated limit of the
span-wide grouping idiom.

**Done looks like:** a `definition.config_key`-shaped emission for
`(pair key: (string) value: _)` in omega-javascript, omega-typescript and
omega-tsx, with the key unquoted and the value's last identifier segment
published the way `call.last_arg_name` is.
