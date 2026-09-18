# omega-framework-terraform-template

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

15 overlay rules, 2 detection rules. **0 can match, 15 cannot.**

Selector: `framework:terraform-template`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ConfigDocument` | 1 |
| `Resource` | 1 |
| `Module` | 1 |
| `TemplateFile` | 1 |
| `TemplateReference` | 1 |
| `TemplateControl` | 1 |
| `TemplateCall` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `references` | 5 |
| `depends_on` | 4 |
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.hcl_block_list_traversal_context` | 4 | **no** |
| `reference.hcl_block_traversal_context` | 4 | **no** |
| `definition.hcl_block_labeled` | 2 | **no** |
| `reference_context.template_interpolation` | 2 | **no** |
| `scope.hcl_body` | 1 | **no** |
| `reference_context.template_condition` | 1 | **no** |
| `call.hcl_function_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x19, `fact_kind` x15, `path_glob` x15, `field_not_in` x4.

Fields read: `owner_kind`, `target_root`, `attribute_key`, `block_kind`, `function_name`.

Path globs: `**/*.{tf,hcl}`, `**/*.tftpl`, `**/*.{tf,hcl,tftpl}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `terraform-template.source-authored.config-document` | kind `scope.hcl_body` |
| `terraform-template.resource` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform-template.module` | kind `definition.hcl_block_labeled`; field `block_kind` |
| `terraform-template.depends_on.resource_resource` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform-template.depends_on.resource_module` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform-template.depends_on.module_resource` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform-template.depends_on.module_module` | kind `reference.hcl_block_list_traversal_context`; field `attribute_key`, `owner_kind`, `target_root` |
| `terraform-template.references.resource_resource` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform-template.references.resource_module` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform-template.references.module_resource` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform-template.references.module_module` | kind `reference.hcl_block_traversal_context`; field `owner_kind`, `target_root` |
| `terraform-template.template-file` | kind `reference_context.template_interpolation` |
| `terraform-template.template-interpolation` | kind `reference_context.template_interpolation` |
| `terraform-template.template-condition` | kind `reference_context.template_condition` |
| `terraform-template.templatefile-call` | kind `call.hcl_function_context`; field `function_name` |

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
