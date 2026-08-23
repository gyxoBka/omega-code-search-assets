# Omega Code Search Assets

This repository is the source and release surface for Omega assets.

The Omega runtime repository owns code, protocols, validators, and product
control flows. This repository owns independently distributed assets:

- GrammarBundle sources and release archives.
- Language Pack sources and release archives.
- Framework Pack sources and release archives.
- HarnessDefinition sources and release archives.
- Model descriptors.

The production trust boundary is the signed Official Asset Catalog plus exact
SHA-256 digests. GitHub Releases are only transport.

## Layout

```text
packs/
  catalog-source.json
  json-basic/
  rust-basic/
  packages/
framework-packs/
harness/
  catalog-source.json
  official/
  held-out/
  packages/
grammars/
  legacy-manifest.toml
models/
tools/
  build-catalog.mjs
```

`grammars/legacy-manifest.toml` is not a production GrammarBundle catalog. It is
old metadata copied out of the runtime repo so it can be audited here. A real
GrammarBundle release item must contain a validated `grammar.wasm`,
`node-types.json`, `manifest.toml`, `LICENSE`, and `NOTICE`.

## Release Contract

Release automation publishes separate asset-domain catalogs. Do not mix
unrelated domains in one release.

Current release domains:

- `packs`: Language Packs and Framework Packs.
- `harness`: HarnessDefinition assets.
- `grammars`: future GrammarBundle assets.
- `models`: future ModelDescriptor assets.

Each domain release must publish:

- `catalog.json`
- asset archives referenced by `catalog.json`
- optional offline snapshot archive for that same domain

The catalog is signed with Ed25519 over the RFC 8785/JCS canonical form of the
`signed` payload. Omega release builds embed the public key and catalog URL:

```text
OMEGA_OFFICIAL_CATALOG_URL
OMEGA_OFFICIAL_CATALOG_KEY_ID
OMEGA_OFFICIAL_CATALOG_PUBLIC_KEY_B64
```

The private signing key must never be stored in the Omega runtime repository.

## Local Catalog Build

Unsigned packs catalog:

```powershell
node tools/build-catalog.mjs `
  --domain packs `
  --release-base-url https://github.com/<org>/omega-code-search-assets/releases/download/packs-v1 `
  --catalog-version packs-v1 `
  --out dist/catalog.json
```

Signed harness catalog:

```powershell
$env:OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM = Get-Content .secrets/catalog-ed25519.pem -Raw
$env:OMEGA_ASSET_CATALOG_KEY_ID = "omega-assets-2026-08"
node tools/build-catalog.mjs `
  --domain harness `
  --release-base-url https://github.com/<org>/omega-code-search-assets/releases/download/harness-v1 `
  --catalog-version harness-v1 `
  --out dist/catalog.json
```

Recommended tag naming:

```text
packs-v1
harness-v1
grammars-v1
models-v1
```

Asset versions remain independent inside each catalog. For example,
`omega-rust-basic@2.3.0` can be published in `packs-v1`, while
`omega-json-basic@1.0.0` remains unchanged.

## Cleanup Policy

Production assets should move here. The runtime repo should keep only validators,
protocols, and crate-local test fixtures. Runtime tests should install assets
through product-control paths or use small local fixtures, not root-level
production asset trees.
