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
