# Official HarnessDefinition source assets

This tree contains reviewable source inputs for independently distributed HarnessDefinition assets. Runtime code does not embed these definitions as the only update authority; release automation packages them into immutable Official Asset Catalog artifacts.

- `official/<id>/<version>/harness-definition.toml` is the exact versioned definition source.
- `fixtures/` contains clean, existing-user-content, foreign-same-key, malformed and path-precedence fake-home evidence consumed by the generic U24 Rust lifecycle suite.
- `support-matrix.json` records platform, activation, actually-managed capability and evidence level without claiming real-harness verification before U30.
- `packages/*.zip` are deterministic one-definition release payloads.
- `catalog-source.json` records exact package/source digests and compatibility requirements without inventing a GitHub repository URL.
- Release automation owns catalog payload generation when an explicit immutable GitHub Releases base URL and catalog version are supplied.
- `held-out-proof.json` records the Antigravity held-out definition and fixture.

Repository content cannot activate these assets. Installation still traverses the signed U06 catalog or explicit local-definition path, then U05/U17 validation and inventory. A definition asset never becomes ownership authority merely by existing in this tree.
