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

## What was wrong with it

Measured, before: **86 overlay rules, 0 live, 86 dead.** After: **40 rules, 40
live, 0 dead.**

1. **Every rule was keyed to a kind omega-hcl no longer emits.** All 11 fact
   kinds in the table above are gone. The old Pack published one kind per
   syntactic shape it wanted to reach — `reference.hcl_block_traversal_context`
   for a two-segment traversal, `reference.hcl_block_traversal3_context` for a
   three-segment one, `data.hcl_block_attribute_context` for an attribute inside
   a block, `data.hcl_unlabeled_block_attribute_context` for one inside an
   unlabeled block — and each carried the owner block's identity in fields
   (`owner_kind`, `owner_label0`, `attribute_key`). The rewritten omega-hcl emits
   five kinds in total: `definition.config_block`, `definition.config_attribute`,
   `definition.config_entry`, `call.function`, `reference.traversal`. Nothing
   carries its owner any more, because the owner's span already contains it.
2. **The `*3_context` split was a pure duplication.** 35 of the 86 rules
   (`terraform.references3.*`, 20; `terraform.depends_on3.*`, 12; the three
   `*_data_source` rules) existed only because the old Pack spelled a
   three-segment traversal under a different kind than a two-segment one. There
   is now one `reference.traversal`, so those 35 rules collapse into the 16
   `terraform.references.*` and 4 `terraform.depends_on.*` rules below.
3. **The owner/target cross-product was written out by hand.** `owner_kind` ×
   `target_root` produced 35 `references` rules and 16 `depends_on` rules. The
   owner is now one `fact_join_by_span` with `within`, which is the same clause
   in every one of them; only the two canonical-key prefixes differ.
4. **Eight `MetaArgument` rules stated `count` and `for_each` separately per
   owner kind.** `field_in` over `definition.name` does both in one rule, so
   8 became 2.
5. **Five rules could not be ported at all, because the value they read is no
   longer a field.** `terraform.module.source`, `terraform.provider.alias`,
   `terraform.provider-selection.{resource,module}` and
   `terraform.module-providers-mapping.data` all rendered a string *value*
   (`{value}`, `{object_value}`, `{target_name}`) into an entity key. omega-hcl
   carries a scalar value as an **attribute**, and `OverlayFact::field` — which
   is what `render()` and `field_ref` go through — reads fields only. An
   attribute is reachable by `attribute_equals` against a constant and in no
   other way, so those five entities (`ModuleSource`, `ProviderAlias`,
   `ProviderMapping`) are gone rather than half-stated. The same reason removes
   the *value* of `count`/`for_each` while keeping the fact that they are set.
6. **Three rules only restated their input.** `terraform.import.block`,
   `terraform.moved.block` and `terraform.removed.block` each emitted an entity
   named after the block type with no relation to anything. They are now one
   `StateOperation` rule plus one rule that relates the operation to the
   resource it names.
7. **The asset's own declarations were untrue.** `host.required_capabilities`
   demanded `bindings`, `data` and `scopes`; omega-hcl publishes
   `calls, definitions, references`. `coverage.gaps` claimed module provider
   mappings were "materialized as exact source mappings". Both corrected.

`detection_rules` was left alone: two atoms on `specifier`/`name`, still true.

## What it states now

40 rules. Every entity key is rendered from `definition.name`, `path` or
`source.start` — the only identifying values omega-hcl puts in fields — so both
ends of every relation are reachable.

### Declarations — 15 rules

| what | which Pack fact | entity / relation |
|---|---|---|
| a resource, data source, module, variable, output, provider, ephemeral resource, check (8 rules) | `definition.config_block` + `attribute_equals block_type` | `Resource`, `DataSource`, `Module`, `Variable`, `Output`, `Provider`, `EphemeralResource`, `Check` at `terraform:<kind>:{definition.name}` |
| a local value | `definition.config_attribute` inside the block named `locals` (`fact_join_by_span` `within`) | `Local` at `terraform:local:{definition.name}` |
| the `terraform` block of a file | `definition.config_block` named `terraform` | `TerraformConfig` at `terraform:terraform:{path}` |
| where state lives | `definition.config_block` `block_type=backend` inside the `terraform` block | `Backend` + `contains` from `TerraformConfig` |
| which providers the configuration requires | `definition.config_attribute` inside the block named `required_providers` | `Provider` + `depends_on` from `TerraformConfig` |
| a pending `moved` / `import` / `removed` | `definition.config_block`, `field_in definition.name` | `StateOperation` at `terraform:state-op:{path}:{source.start}` |
| which resource that operation names | `reference.traversal` inside it, joined by name to a `resource` block | `references` StateOperation -> Resource |

Question answered: *what does this configuration declare, and under what
address*; *where is state stored*; *which providers does it need*; *what
refactors are pending*.

### Containment — 6 rules

| what | which Pack fact | relation |
|---|---|---|
| a `lifecycle` block | `definition.config_block` named `lifecycle`, owner joined `within` a `resource` | `Lifecycle` + `contains` from Resource |
| a `dynamic "x"` block in a resource or data source (2 rules) | `definition.config_block` `block_type=dynamic`, owner joined `within` | `DynamicBlock` + `contains` |
| an `assert` block | `definition.config_block` named `assert`, owner a `check` | `Assertion` + `contains` from Check |
| `count` / `for_each` on a resource or module (2 rules) | `definition.config_attribute`, `field_in ["count","for_each"]`, owner joined `within` | `MetaArgument` + `contains` |

Question answered: *is this resource multi-instance*; *does it have lifecycle
rules*; *which nested blocks are generated*.

### References — 16 rules

Current fact is always `reference.traversal`; the owner block is a
`fact_join_by_span` `within` `definition.config_block` filtered by
`attribute_equals block_type`. Owner ∈ {resource, module, output, data} ×
target ∈ {variable, local, module, resource}.

| what | which Pack fact | relation |
|---|---|---|
| `var.x` read in a block | `reference.traversal`, `attribute_equals root=var` | `configured_by` owner -> `terraform:variable:{definition.name}` |
| `local.x` read in a block | `attribute_equals root=local` | `configured_by` owner -> `terraform:local:{definition.name}` |
| `module.m.out` read in a block | `attribute_equals root=module` | `references` owner -> `terraform:module:{definition.name}` |
| `aws_x.y.attr` read in a block | `fact_join_by_field` on `definition.name` to a `definition.config_block` with `block_type=resource` | `references` owner -> `terraform:resource:{target.definition.name}` |

Question answered: *which variables configure this module*, *which resources
does this output expose*, *what breaks if I delete this local*.

### Explicit ordering — 4 rules

| what | which Pack fact | relation |
|---|---|---|
| `depends_on = [module.m]` in a resource or module | `reference.traversal` `within` the `definition.config_attribute` named `depends_on`, `attribute_equals root=module` | `depends_on` owner -> Module |
| `depends_on = [aws_x.y]` in a resource or module | same, plus the join by name to a `resource` block | `depends_on` owner -> Resource |

The attribute a reference sits in is reached by a second `fact_join_by_span`
`within` on `definition.config_attribute` — no Pack field is needed for it.
These four rules overlap the `references.*` rules by design: a `depends_on`
entry is both a reference and an explicit ordering, and the two relation kinds
answer different questions.

## A field only the Pack can supply

**Pack `omega-hcl`, kind `definition.config_block`, field `type_label` (and
`block_type`); kind `reference.traversal`, field `root`.**

The Pack already computes all three — they are published as **attributes**. The
overlay can test an attribute against a constant (`attribute_equals`) but can
never render one: `render()` and `field_ref` both go through
`Binding::resolve` -> `OverlayFact::field`, which reads `fields` and the
built-in names and never looks at `attributes`. No join reaches them either;
`fact_join_by_field` and `additional_field_equalities` compare fields only.

Three consequences, all of them visible in `coverage.gaps`:

1. A resource is keyed `terraform:resource:{definition.name}` — its last label
   alone. `aws_vpc.main` and `aws_subnet.main` collide. With `type_label` as a
   field the key would be the real Terraform address `aws_vpc.main`.
2. A traversal's target kind cannot be discriminated except by the roots that
   are constants (`var`, `local`, `module`). "Root is a resource type" is
   `attribute_equals` against an open set, which does not exist, so the four
   resource-reference rules fall back to joining by name to a `resource` block —
   correct whenever a resource of that name exists, and a false positive when a
   variable and a resource share a name. Those rules carry `confidence: high`,
   not `exact`.
3. `data.aws_ami.web` is not stated at all. The traversal pattern captures only
   the first segment, which for a data source is the *type*, not the name, so
   the reference cannot be addressed to the `DataSource` entity's key. This one
   needs the Pack to capture the second segment as well, not just a field move.

No Pack was asked for anything else: the owner of a nested construct, the
attribute a reference sits in, and the enclosing block of a local are all
reached by `fact_join_by_span` with `within`.

## Still to decide

1. **`definition.container` / `enclosing.qname` are usable but unaudited.**
   `facts_of_surface` adds both to every fact's field map, and they would have
   let the `depends_on` rules read the enclosing attribute name directly instead
   of joining. `pack-design/overlay_audit.py`'s `BUILTIN` set does not list
   them, so a rule reading them is reported dead. The joins are used instead;
   either the audit's list should grow or the contract should say these are not
   for overlays.
2. **The owner cross-product is still 16 rules.** It collapses to 4 the day an
   entity key can carry the owner's block type — i.e. the day `block_type` is a
   field — because the source end could then be one rendered
   `terraform:{owner.block_type}:{owner.definition.name}`.
3. **`provider = aws.west`** (provider selection with an alias) is not stated:
   the traversal gives `west`, the alias, while the `Provider` entity is keyed
   by the provider name `aws`, which is the traversal's root attribute. Left
   out rather than pointed at a key nothing emits.
