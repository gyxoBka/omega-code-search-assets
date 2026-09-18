# Owed work

Everything this rewrite created and did not finish, in one place so it is not
lost between commits. Each item says what it is, why it was deferred, and what
"done" looks like.

Last updated after framework wave 1. Numbers come from
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
| omega-yaml, omega-json | `definition.config_key` | `value` | kubernetes-config, openapi-v3 |
| omega-hcl | `definition.config_block` | `block_type`, `type_label` | terraform |
| omega-hcl | `reference.traversal` | `root` | terraform |
| omega-javascript, omega-typescript, omega-tsx | `binding.import_alias`, `import.symbol` | `qualifier` | node-js |

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

50 of 55 frameworks still hold rules that cannot match: **951 of 1 170**. The
loop is running in waves of five, worst first, and this file is updated when it
finishes.
