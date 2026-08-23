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
harness-definitions/
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

Release automation must publish:

- `catalog.json`
- asset archives referenced by `catalog.json`
- optional offline snapshot archive

The catalog is signed with Ed25519 over the RFC 8785/JCS canonical form of the
`signed` payload. Omega release builds embed the public key and catalog URL:

```text
OMEGA_OFFICIAL_CATALOG_URL
OMEGA_OFFICIAL_CATALOG_KEY_ID
OMEGA_OFFICIAL_CATALOG_PUBLIC_KEY_B64
```

The private signing key must never be stored in the Omega runtime repository.

## Local Catalog Build

Unsigned catalog:

```powershell
node tools/build-catalog.mjs `
  --release-base-url https://github.com/<org>/omega-code-search-assets/releases/download/assets-v1 `
  --catalog-version assets-v1 `
  --out dist/catalog.json
```

Signed catalog:

```powershell
$env:OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM = Get-Content .secrets/catalog-ed25519.pem -Raw
$env:OMEGA_ASSET_CATALOG_KEY_ID = "omega-assets-2026-08"
node tools/build-catalog.mjs `
  --release-base-url https://github.com/<org>/omega-code-search-assets/releases/download/assets-v1 `
  --catalog-version assets-v1 `
  --out dist/catalog.json
```

## Cleanup Policy

Production assets should move here. The runtime repo should keep only validators,
protocols, and crate-local test fixtures. Runtime tests should install assets
through product-control paths or use small local fixtures, not root-level
production asset trees.
