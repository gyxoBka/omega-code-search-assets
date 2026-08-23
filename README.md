# Omega Code Search Assets

This repository is the source and registry surface for Omega assets.

The Omega runtime repository owns code, protocols, validators, and product
control flows. This repository owns independently distributed assets:

- GrammarBundle sources.
- Language Pack sources.
- Framework Pack sources.
- HarnessDefinition sources.
- Model descriptors.

The production trust boundary is the signed Official Asset Catalog plus exact
SHA-256 digests. GitHub is transport, not trust.

## Layout

```text
packs/
  catalog-source.json
  json-basic/
  rust-basic/
framework-packs/
harness/
  catalog-source.json
  official/
  held-out/
grammars/
  legacy-manifest.toml
models/
tools/
  build-catalog.mjs
  build-packages.mjs
  push-ghcr-artifacts.mjs
```

`grammars/legacy-manifest.toml` is not a production GrammarBundle catalog. It is
old metadata copied out of the runtime repo so it can be audited here. A real
GrammarBundle release item must contain a validated `grammar.wasm`,
`node-types.json`, `manifest.toml`, `LICENSE`, and `NOTICE`.

## Registry Contract

Automation publishes asset packages and signed domain catalogs to GitHub
Container Registry (GHCR) as OCI artifacts. Do not mix unrelated domains in one
catalog.

Current domains:

- `packs`: Language Packs and Framework Packs.
- `harness`: HarnessDefinition assets.
- `grammars`: future GrammarBundle assets.
- `models`: future ModelDescriptor assets.

Stable catalog entry points:

```text
oci://ghcr.io/gyxobka/omega-code-search-assets/catalog/packs:current
oci://ghcr.io/gyxobka/omega-code-search-assets/catalog/harness:current
```

Asset package references use their own domain/name/version:

```text
oci://ghcr.io/gyxobka/omega-code-search-assets/packs/omega-rust-basic:2.3.0
oci://ghcr.io/gyxobka/omega-code-search-assets/harness/claude:1.0.0
```

The catalog is signed with Ed25519 over the RFC 8785/JCS canonical form of the
`signed` payload. Omega release builds embed the public key and catalog
references:

```text
OMEGA_OFFICIAL_PACK_CATALOG_REF
OMEGA_OFFICIAL_HARNESS_CATALOG_REF
OMEGA_OFFICIAL_CATALOG_KEY_ID
OMEGA_OFFICIAL_CATALOG_PUBLIC_KEY_B64
```

The private signing key must never be stored in the Omega runtime repository.

Source branches do not store generated zip packages. CI builds package archives
from source, pushes them to GHCR, records immutable OCI digests, then emits
signed catalogs whose entries point at `oci://...@sha256:...` immutable package
references. Omega verifies both the signed catalog and the archive SHA-256
before install.

CI publishes only changed domains:

- changes under `packs/` publish `packs` assets and the packs catalog;
- changes under `harness/` publish `harness` assets and the harness catalog;
- changes under `tools/` or workflow files publish all currently supported
  domains because packaging semantics may have changed.

## Local Catalog Build

Build package archives:

```powershell
node tools/build-packages.mjs --out dist/packages --update-catalog-source
```

Build signed catalogs after OCI push:

```powershell
$env:OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM = Get-Content .secrets/catalog-ed25519.pem -Raw
$env:OMEGA_ASSET_CATALOG_KEY_ID = "omega-assets-2026-08"
node tools/build-catalog.mjs `
  --domain harness `
  --registry-digests dist/oci-digests.json `
  --catalog-version harness-<commit-sha> `
  --out dist/catalog.json
```

Asset versions remain independent inside each catalog. For example,
`omega-rust-basic@2.3.0` can be published in a current packs catalog, while
`omega-json-basic@1.0.0` remains unchanged.

## Cleanup Policy

Production assets should move here. The runtime repo should keep only validators,
protocols, and crate-local test fixtures. Runtime tests should install assets
through product-control paths or use small local fixtures, not root-level
production asset trees.
