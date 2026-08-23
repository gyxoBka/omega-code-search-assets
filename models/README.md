# Model Descriptors

This directory will own official model descriptor sources.

Omega model assets are installed from validated descriptors and local model
files. The signed catalog should publish `MODEL_DESCRIPTOR` raw JSON entries,
not mutable model repositories as trusted runtime input.

Required work:

- add descriptor JSON for each supported Model2Vec model;
- pin provider, provider version, dimension, normalization, license, and
  recommended immutable upstream revision;
- publish descriptors as raw catalog assets;
- keep model file acquisition explicit in Omega CLI/Web UI.
