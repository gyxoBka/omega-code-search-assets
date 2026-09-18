# omega-framework-pytorch-extensions

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

8 overlay rules, 12 detection rules. **1 can match, 7 cannot.**

Selector: `framework:pytorch-extensions`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ExtensionModule` | 7 |
| `BuildOption` | 3 |
| `BuildInput` | 2 |
| `BuildTool` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 6 |
| `builds` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.python_from_import_constructor_keyword_identifier_list_context` | 4 | **no** |
| `definition.python_from_import_constructor_binding_context` | 1 | **no** |
| `call.member` | 1 | yes |
| `call.direct` | 1 | **no** |
| `definition.python_from_import_constructor_keyword_identifier_context` | 1 | **no** |

Clause vocabulary in use: `field_in` x13, `field_present` x12, `field_equals` x10, `fact_kind` x8, `path_glob` x6, `external_path_matches` x2.

Fields read: `module_name`, `imported_name`, `callee_name`, `binding_name`, `keyword_name`, `list_item`, `source.start`, `keyword_identifier`.

Path globs: `**/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `pytorch-extensions.source-authored.extensionmodule-cppextension` | kind `definition.python_from_import_constructor_binding_context`; field `binding_name`, `callee_name`, `imported_name`, `module_name` |
| `pytorch.ext.buildextension` | kind `call.direct` |
| `pytorch.ext.constructor-source-item` | kind `definition.python_from_import_constructor_keyword_identifier_list_context`; field `binding_name`, `callee_name`, `imported_name`, `keyword_name`, `list_item`, `module_name` |
| `pytorch.ext.constructor-include-dir-item` | kind `definition.python_from_import_constructor_keyword_identifier_list_context`; field `binding_name`, `callee_name`, `imported_name`, `keyword_name`, `list_item`, `module_name` |
| `pytorch.ext.constructor-extra-compile-arg-item` | kind `definition.python_from_import_constructor_keyword_identifier_list_context`; field `binding_name`, `callee_name`, `imported_name`, `keyword_name`, `list_item`, `module_name` |
| `pytorch.ext.constructor-extra-link-arg-item` | kind `definition.python_from_import_constructor_keyword_identifier_list_context`; field `binding_name`, `callee_name`, `imported_name`, `keyword_name`, `list_item`, `module_name` |
| `pytorch.ext.constructor-identifier-option` | kind `definition.python_from_import_constructor_keyword_identifier_context`; field `binding_name`, `callee_name`, `imported_name`, `keyword_identifier`, `keyword_name`, `module_name` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
