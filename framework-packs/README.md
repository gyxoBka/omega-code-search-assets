# Framework Packs

This directory will own framework-specific semantic packs.

Framework Packs do not contain parsers. They run over already extracted Omega
semantic surfaces and should declare framework selectors instead of `parser_id`.

Required work:

- define source layout for each framework pack;
- add catalog-source entries with `FRAMEWORK_PACK` class;
- validate rules against Omega framework pack runtime before release;
- keep project selection explicit through `omega pack enable`.
