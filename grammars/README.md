# Grammar Bundles

This directory will own production GrammarBundle source/build inputs.

`legacy-manifest.toml` was copied from the runtime repository for audit only. It
does not contain production GrammarBundle archives and currently declares
`wasm_loading = false`, while Omega production parser registry expects installed
WASM GrammarBundle assets.

A production GrammarBundle archive must contain:

- `manifest.toml`
- `grammar.wasm`
- `node-types.json`
- `LICENSE`
- `NOTICE`

Each archive must be validated by Omega's GrammarBundle validator before it is
published into the signed Official Asset Catalog.

Current required work:

- build or acquire `tree-sitter-rust` WASM bundle;
- build or acquire `tree-sitter-json` WASM bundle;
- record exact upstream revision and tree-sitter ABI;
- compute grammar identity and compatible language pack identities;
- add `GRAMMAR_BUNDLE` entries to the catalog source.
