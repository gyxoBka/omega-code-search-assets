# omega-framework-terraform

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

86 overlay rules, 2 detection rules. **0 can match, 86 cannot.**

Selector: `framework:terraform`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `MetaArgument` | 8 |
| `DynamicBlock` | 4 |
| `Resource` | 1 |
| `Module` | 1 |
| `Variable` | 1 |
| `DataSource` | 1 |
| `Provider` | 1 |
| `Local` | 1 |
| `Output` | 1 |
| `ModuleSource` | 1 |
| `ProviderAlias` | 1 |
| `Lifecycle` | 1 |
| `EphemeralResource` | 1 |
| `Check` | 1 |
| `Assertion` | 1 |
| `Import` | 1 |
| `Move` | 1 |
| `Removed` | 1 |
| `TerraformConfig` | 1 |
| `ProviderMapping` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `references` | 35 |
| `depends_on` | 16 |
| `configured_by` | 16 |
| `contains` | 6 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.hcl_block_traversal3_context` | 23 | **no** |
| `reference.hcl_block_traversal_context` | 17 | **no** |
| `reference.hcl_block_list_traversal3_context` | 12 | **no** |
| `definition.hcl_block_labeled` | 8 | **no** |
| `data.hcl_block_attribute_context` | 8 | **no** |
| `data.hcl_nested_block_context` | 6 | **no** |
| `reference.hcl_block_list_traversal_context` | 4 | **no** |
| `data.hcl_block_string_attribute_context` | 4 | **no** |
| `data.hcl_unlabeled_block_attribute_context` | 4 | **no** |
| `definition.hcl_local` | 1 | **no** |
| `data.hcl_block_object_entry_one_label_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x166, `fact_kind` x86, `path_glob` x85, `field_present` x23, `field_not_in` x13, `fact_join_by_field` x2, `(join)` x2.

Fields read: `owner_kind`, `target_root`, `attribute_key`, `key`, `value`, `block_kind`, `child_kind`, `child_label`, `owner_label0`, `target_name`, `object_key`, `object_value`.

Path globs: `**/*.tf`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `terraform.resource` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.module` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.variable` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.data-source` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.provider` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.local` | kind `definition.hcl_local`; field `block_kind` |
| `terraform.output` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.depends_on.resource_resource` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on.resource_module` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on.module_resource` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on.module_module` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.configured_by.resource_variable` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.configured_by.module_variable` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.configured_by.output_variable` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.resource_resource` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.resource_module` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.module_resource` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.module_module` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.output_resource` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.output_module` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.resource_data_source` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references.module_data_source` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references.output_data_source` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references.resource_local` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.module_local` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.output_local` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.resource_provider` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.module_provider` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.references.output_provider` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform.module.source` | kind `data.hcl_block_string_attribute_context`; field `key`, `owner_kind`, `owner_label0`, `value` |
| `terraform.provider.alias` | kind `data.hcl_block_string_attribute_context`; field `key`, `owner_kind`, `owner_label0`, `value` |
| `terraform.provider-selection.resource` | kind `data.hcl_block_string_attribute_context`, `reference.hcl_block_traversal_context`; field `attribute_key`, `key`, `owner_kind`, `target_name`, `target_root` |
| `terraform.provider-selection.module` | kind `data.hcl_block_string_attribute_context`, `reference.hcl_block_traversal_context`; field `attribute_key`, `key`, `owner_kind`, `target_name`, `target_root` |
| `terraform.meta.resource.count` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.resource.for_each` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.module.count` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.module.for_each` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.data.count` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.data.for_each` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.ephemeral.count` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.meta.ephemeral.for_each` | kind `data.hcl_block_attribute_context`; field `key`, `owner_kind`, `value` |
| `terraform.resource.lifecycle` | kind `data.hcl_nested_block_context`; field `child_kind`, `owner_kind` |
| `terraform.dynamic-block.resource` | kind `data.hcl_nested_block_context`; field `child_kind`, `child_label`, `owner_kind` |
| `terraform.dynamic-block.module` | kind `data.hcl_nested_block_context`; field `child_kind`, `child_label`, `owner_kind` |
| `terraform.dynamic-block.data` | kind `data.hcl_nested_block_context`; field `child_kind`, `child_label`, `owner_kind` |
| `terraform.dynamic-block.ephemeral` | kind `data.hcl_nested_block_context`; field `child_kind`, `child_label`, `owner_kind` |
| `terraform.ephemeral.entity` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.check.entity` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform.check.assert` | kind `data.hcl_nested_block_context`; field `child_kind`, `owner_kind`, `owner_label0` |
| `terraform.import.block` | kind `data.hcl_unlabeled_block_attribute_context`; field `owner_kind` |
| `terraform.moved.block` | kind `data.hcl_unlabeled_block_attribute_context`; field `owner_kind` |
| `terraform.removed.block` | kind `data.hcl_unlabeled_block_attribute_context`; field `owner_kind` |
| `terraform.terraform.block` | kind `data.hcl_unlabeled_block_attribute_context`; field `owner_kind` |
| `terraform.references3.resource.resource` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.resource.module` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.resource.var` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.resource.local` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.resource.provider` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.module.resource` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.module.module` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.module.var` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.module.local` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.module.provider` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.output.resource` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.output.module` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.output.var` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.output.local` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.output.provider` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.ephemeral.resource` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.ephemeral.module` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.ephemeral.var` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.ephemeral.local` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.references3.ephemeral.provider` | kind `reference.hcl_block_traversal3_context`; field `owner_kind`, `target_root` |
| `terraform.depends_on3.resource.module` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.resource.data` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.resource.resource` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.module.module` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.module.data` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.module.resource` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.output.module` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.output.data` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.output.resource` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.ephemeral.module` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.ephemeral.data` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.depends_on3.ephemeral.resource` | kind `reference.hcl_block_list_traversal3_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform.module-providers-mapping.data` | kind `data.hcl_block_object_entry_one_label_context`; field `attribute_key`, `object_key`, `object_value`, `owner_kind` |

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
