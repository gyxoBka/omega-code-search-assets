# Frameworks: where the rewrite starts

One `.md` per Framework in this folder, `00-CONTRACT.md` is the spec they are
read against, and `pack-design/overlay_audit.py` is the measurement. This file
is the cross-Framework reading.

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
