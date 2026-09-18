# Owed work

Everything this rewrite created and did not finish, in one place so it is not
lost between commits. Each item says what it is, why it was deferred, and what
"done" looks like.

Last updated after framework wave 9. Numbers come from
`python pack-design/audit.py` and `python pack-design/overlay_audit.py`.

---

## 1. Pack fields the Frameworks need — one deliberate change, not five

**Status: collecting. Do not edit a Pack until the framework waves are done.**

`OverlayFact::field` (`omega-semantic/src/framework/overlay.rs:56`) resolves the
`fields` map and a fixed list of built-in names. It **never consults
`attributes`**, and the only clause that reads an attribute is
`attribute_equals`, against one literal constant. So a value a Pack publishes as
an *attribute* can be tested for equality and used for nothing else: not as a
canonical key, a relation end, an entity attribute, or a join key.

Four frameworks hit this in wave 1 and all named the same remedy — move the
value from `attributes` to `fields` in the Pack template. **Same bytes, a
different map.**

| Pack | kind | move to `fields` | asked by |
|---|---|---|---|
| omega-yaml, omega-json | `definition.config_key` | `value` | kubernetes-config, openapi-v3, gitlab-ci, github-action |
| omega-hcl | `definition.config_block` | `block_type`, `type_label` | terraform |
| omega-hcl | `reference.traversal` | `root` | terraform |
| omega-javascript, omega-typescript, omega-tsx | `binding.import_alias`, `import.symbol` | `qualifier` | node-js |
| omega-javascript, omega-typescript, omega-tsx | `import.symbol` | `module` — the specifier the symbol came from | react |
| omega-python | `call.function`, `call.method` | the call's first string-or-identifier argument | django |
| omega-caddyfile | `definition.config_matcher_condition` | `operand` — what the condition tests for | caddyfile |
| omega-php | `reference.attribute` | the attribute's argument text — `#[Route('/orders/{id}')]` is where a Symfony URL is stated | symfony |
| omega-xml | `definition.config_attribute` | `value` | maui — `Route="home"`, `x:Class="MyApp.DetailsPage"` |
| omega-prisma | `definition.config_setting` | `value` | prisma — `provider = "postgresql"` is the most-asked fact about a schema |
| omega-razor | `reference.attribute_value` | `attribute` — which event a handler is bound to | blazor |
| omega-javascript, omega-typescript, omega-tsx | `call.method`, `call.function` | `arg0` (first string-literal argument), `receiver` | express, bun, fastify |
| omega-kotlin | `call.function`, `call.method` | first string-literal argument — a Navigation Compose destination | jetpack-compose |

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

## 6. The framework waves themselves

11 of 55 frameworks still hold rules that cannot match: **168 of 802**, measured with the surface scoped to each framework's own `host.required_packs`. The
loop is running in waves of five, worst first, and this file is updated when it
finishes.

---

## 7. A scoped npm package can never be matched — a host fix, decided

`parse_external_path` (`omega-semantic/src/framework/materialize.rs:560`) splits
the target on `/` and takes the **first** part as the package. So
`@sveltejs/kit` becomes package `@sveltejs` with segments `["kit"]`, and an
`external_path_matches` clause naming `@sveltejs/kit` is unreachable for every
possible input.

**40 clauses in 5 frameworks depend on this**: nestjs 23, angular 10, tauri 4,
sveltekit 2, astro 1. A scoped npm package's name *is* `@scope/name`; no other
ecosystem this function serves produces a leading `@` segment, so joining the
first two parts when the first begins with `@` is a small, generic rule.

`materialize.rs` is frozen, so the fix needs the design-set obligations re-run
and `tests/fixtures/design-set/freeze.json` re-stamped with a dated note.

**Decided, not yet done.** The five frameworks above are deliberately scheduled
*after* the fix, so they are written against a correct host rather than around a
bug. sveltekit's two rules were deleted rather than worked around; the others
have not been rewritten yet.

### 7a. JS/TS facts never carry `external` at all

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

`python pack-design/key_collisions.py` counts **62 dropped entity outputs in 8
frameworks**: unity 17, unreal-engine 12, ruby-on-rails 10, maui 9, vapor 8,
swiftui 7, angular 3, nuxt 1.

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

### 12a. Still unreachable by extension: `.blade.php`

`Path::extension` of `home.blade.php` is `php`, so a Blade template goes to
omega-php and omega-blade can never claim it. It needs a suffix rule — matching
the tail of the filename rather than the extension — which `detect_path` does
not have.

---

## 13. The file-shaped rules deleted while the audit called `data.file` dead

`OverlayFact::artifact` (`overlay.rs:41`) pushes one synthetic `data.file` fact
per artifact, with field `path`, before any Pack emission. It is how a rule
addresses the file itself — file-based routing, a migration, a manifest.
`overlay_audit.py` built its kind set from `packs/*/rules.json` only, so it
reported every such rule dead, and the frameworks whose whole subject is the
file tree were rewritten against that mismeasurement:

| framework | `data.file` rules at the baseline | now |
|---|---|---|
| omega-framework-next-js | 20 | 0 |
| omega-framework-nuxt | 11 | 0 |
| omega-framework-sveltekit | 10 | 0 |
| omega-framework-astro | 3 | 3 |
| omega-framework-vue | 3 | 0 |
| omega-framework-blazor | 2 | 0 |
| omega-framework-django | 1 | 0 |

All three routing frameworks still answer *which URL does this file serve*, but
through a **declaration inside the file** plus a path glob — `next.pages.route`
matches a `definition.function` under `pages/`, `nuxt.page` a
`scope.template_block`. That is narrower than the file itself in a way that
shows at the edges: a `+page.svelte` that is static markup, a `pages/about.vue`
with only a template, a route file whose default export the Pack does not
declare, all produce no Route.

The audit is fixed. **Done looks like:** one pass over those seven, restoring a
file-shaped rule wherever the question is about the file and not about a
declaration in it, with `normalized_file_route` / `normalized_pages_route` used
in the key as before.
