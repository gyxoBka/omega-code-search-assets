# Owed work

Everything this rewrite created and did not finish, in one place so it is not
lost between commits. Each item says what it is, why it was deferred, and what
"done" looks like.

Last updated after framework wave 4. Numbers come from
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

## 5. README is stale

`README.md:18` says "Pack query sections retain their former logical names as
comments in `main.scm`; query patterns, captures, output kinds, and rule
identities are unchanged." No Pack has a `main.scm` — they have `queries.scm` —
and after this work the patterns, captures, output kinds and rule identities are
all different by design.

**Done looks like:** that line replaced by what is true now, and the layering
paragraph above it kept, because it is the statement the whole framework
contract rests on.

---

## 6. The framework waves themselves

35 of 55 frameworks still hold rules that cannot match: **503 of 926**. The
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

## 8. omega-cpp does not see a class declared with a module API macro

Measured with `dump_call_emissions` over `packs/omega-cpp` on a canonical
Unreal header:

```cpp
class MYGAME_API AHero : public ACharacter { GENERATED_BODY() int Health; };
struct MYGAME_API FRow : public FTableRowBase { GENERATED_BODY() int V; };
```

Total emissions for both declarations: `reference.type MYGAME_API` twice and
`call.function GENERATED_BODY` twice. **No `definition.class`, no
`definition.struct`, no `relation.implements`.** The export macro between
`class` and the name defeats tree-sitter-cpp, and with it every rule that joins
a class — 13 of omega-framework-unreal-engine's 19.

`class EXPORT_MACRO Name` is not an Unreal peculiarity: it is how every C++
library that ships a DLL declares a public class (`MYLIB_API`, `CORE_EXPORT`,
`__declspec(dllexport)` behind a macro).

**Done looks like:** omega-cpp declaring the class in that shape, or a guard
saying it cannot and why. Until then the Unreal overlay is written against the
macros that do emit — `UCLASS`, `UPROPERTY`, `GENERATED_BODY` arrive as
`call.function` — rather than against the class.
