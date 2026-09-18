# Omega Code Search Assets

This repository contains the canonical production asset source for Omega Code Search.

```text
source -> Grammar -> AST -> Pack -> normalized Omega IR -> Framework -> enriched graph
```

Dependency direction is strict: `Framework -> Pack -> Grammar`. Grammars provide parser syntax, Packs provide framework-neutral normalized facts, and Frameworks interpret those facts. Frameworks never parse AST directly or invent absent Pack facts.

## Layout

- `grammars/<slug>/`: manifest, parser WASM, node types, and required license/provenance files.
- `packs/<slug>/`: `manifest.toml`, `rules.json`, and optional `queries.scm`.
- `frameworks/<slug>/`: `manifest.toml` and one canonical rule JSON: `semantic-v2.json` for v2 or `rules.json` for detector-only.
- `tools/`: compact structural validators and build tooling.

Every Pack was rewritten against this layering in 2026: a Pack states what the
language says and nothing more, and a rule that restated its own match was
deleted rather than ported. `pack-design/` carries the contract, the per-pack
design note and `audit.py`; `framework-design/` does the same for the overlays,
with `overlay_audit.py` for what a rule can still match and `key_collisions.py`
for entities that overwrite one another. A Pack's queries live in `queries.scm`.

## Validation

```bash
npm run build
```

The build creates release output under `dist/` only during validation. `dist/` is generated and must not be committed or included in the source repository.

The canonical contracts preserve the binding invariants: Pack P0 = 2, Pack P1 = 0, zero precision exceptions, zero synthetic static roles, zero generic reference semantic edges, zero generic semantic target relations, zero generic/broad-call entity debt, and zero declared-output mismatch.
