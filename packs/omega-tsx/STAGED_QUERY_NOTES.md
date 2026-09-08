# omega-tsx staged query notes

The Pack begins from the retained `omega-typescript` query/rule surface and adds explicit JSX/TSX structural facts.

Required Codex work before production promotion:

- compile every query against the exact pinned TSX node-types;
- reconcile any AST differences between JavaScript JSX and TSX rather than deleting coverage silently;
- ensure JSX elements/fragments/self-closing elements, identifiers/member tags, props/attributes, string/expression attributes and owner-aware component references all emit;
- add TSX-specific fixtures for React/Next and source-chain proofs;
- replace `compatible_grammar_identities = []` with the exact revision/node hash identity;
- remove `.omega-staged` only when production validation succeeds.
