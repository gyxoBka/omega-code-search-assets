# omega-framework-terraform-providers

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

8 overlay rules, 4 detection rules. **0 can match, 8 cannot.**

Selector: `framework:terraform-providers`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ProviderSelection` | 3 |
| `ProviderRequirement` | 2 |
| `ConfigDocument` | 1 |
| `ProviderConfig` | 1 |
| `ProviderAlias` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `data.hcl_block_attribute_context` | 3 | **no** |
| `scope.hcl_body` | 1 | **no** |
| `definition.hcl_block_labeled` | 1 | **no** |
| `data.hcl_block_string_attribute_context` | 1 | **no** |
| `data.hcl_unlabeled_block_attribute_context` | 1 | **no** |
| `data.hcl_block_object_entry_unlabeled_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x12, `field_present` x9, `fact_kind` x8, `path_glob` x7.

Fields read: `owner_kind`, `key`, `value`, `block_kind`, `label0`, `attribute_key`, `object_key`, `object_value`.

Path globs: `**/*.{tf,hcl}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `terraform-providers.source-authored.config-document` | kind `scope.hcl_body` |
| `terraform-providers.provider-block` | kind `definition.hcl_block_labeled`; field `block_kind`, `label0` |
| `terraform-providers.provider-alias` | kind `data.hcl_block_string_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform-providers.required-provider` | kind `data.hcl_unlabeled_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform-providers.selection.resource` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform-providers.selection.data` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform-providers.selection.module` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform-providers.required-provider-entry` | kind `data.hcl_block_object_entry_unlabeled_context`; field `attribute_key`, `object_key`, `object_value`, `owner_kind` |

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
