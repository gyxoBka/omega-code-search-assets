# omega-tsx staged build requirements

This directory is deliberately excluded from production asset enumeration by `.omega-staged`.

Codex finalization must, from upstream revision `f975a621f4e7f532fe322e13c4f79495e0a7b2e7`:

1. build the **tsx** grammar, not `typescript`;
2. produce ABI-14 `grammar.wasm` compatible with the retained Tree-sitter 0.25.10 runtime contract;
3. copy the exact generated TSX `node-types.json`;
4. compute and insert `wasm_sha256`, `node_types_sha256`, `query_compatibility`, and `bundle_size_bytes`;
5. compile every staged Pack query against the real TSX parser;
6. remove `.omega-staged` only after all production validators pass.
