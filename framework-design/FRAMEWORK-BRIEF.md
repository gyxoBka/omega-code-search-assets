# Rewriting one Framework: everything you need

You are being sent to rewrite exactly one Framework overlay.

## Required reading, before you touch anything

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
