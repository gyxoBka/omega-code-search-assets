# omega-framework-terraform-providers

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before this rewrite

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

## What was wrong with it

Eight rules, **zero of which could match**. Measured by
`python pack-design/overlay_audit.py terraform-providers` before the rewrite:

| cause | rules |
|---|---|
| fact kind emitted by no Pack | 8 of 8 |
| distinct dead kinds | 6 |
| fields read that no Pack publishes | 8 (`owner_kind`, `key`, `value`, `block_kind`, `label0`, `attribute_key`, `object_key`, `object_value`) |

The file was written against omega-hcl's pre-rewrite vocabulary, which spelled
out the tree: `data.hcl_block_attribute_context`,
`data.hcl_unlabeled_block_attribute_context`,
`data.hcl_block_string_attribute_context`,
`data.hcl_block_object_entry_unlabeled_context` — one kind per *shape of
enclosure*, each carrying the owner's identity as `owner_kind` / `owner_label0`
fields. omega-hcl now emits four declaration kinds and states containment
through spans alone (`packs/omega-hcl/queries.scm`: "There is no pattern for
containment"), so every one of those kinds and every one of those fields is
gone. Three of the eight rules — `selection.resource`, `selection.data`,
`selection.module` — were the same rule three times, differing only in the
`owner_kind` literal; the enclosure is now one `fact_join_by_span` / `within`.

Two further defects the audit could not see:

- **`terraform-providers.provider-alias` addressed a key nothing mints.** Its
  `configured_by` relation was sourced at
  `terraform:provider:{path}:{owner_label0}:{source.start}`, but
  `terraform-providers.provider-block` minted
  `terraform:provider:{path}:{label0}:{source.start}` — a different placeholder
  on a different fact with a different span. The edge dangled at both ends even
  in the vocabulary it was written for.
- **`terraform-providers.required-provider` and
  `terraform-providers.required-provider-entry` are two kinds on overlapping
  intent** (`ProviderRequirement` on `terraform:required-provider:{path}:{key}`
  and on `terraform:required-provider:{path}:{source.start}`), and
  `terraform-providers.source-authored.config-document` emitted a
  `ConfigDocument` whose canonical key was the path, with no relation to
  anything — an entity named after its own input.

8 rules became **5**, all live, no key minted under two kinds
(`python pack-design/key_collisions.py terraform-providers` reports nothing).

## What it states now

omega-hcl emits exactly five things in a `.tf` file: `definition.config_block`
(name = the block's last label, or its type when unlabeled),
`definition.config_attribute` (name = the setting's name),
`definition.config_entry` (name = an object entry's key), `call.function` and
`reference.traversal` (name = the first segment after the root). Everything a
rule reads below is one of those names, the artifact path, or a span join.

| what it answers | Pack fact it reads | entity / relation |
|---|---|---|
| Which providers does this configuration configure, and where is each `provider` block? | `definition.config_block`, `block_type = provider` (attribute), name = local name | `ProviderConfiguration` @ `terraform-providers:provider-config:{path}:{source.start}`; `TerraformProvider` @ `terraform-providers:provider:{name}`; `configures` |
| Is this `provider` block the default configuration or an additional, aliased one? | `definition.config_attribute` named `alias`, joined `within` its `provider` block | `ProviderAlias` @ `terraform-providers:provider-alias:{path}:{blk.source.start}`; `aliased_by` from the `ProviderConfiguration` |
| Which providers does this module require, and in which file is the requirement written? | `definition.config_attribute`, joined `within` a `definition.config_block` named `required_providers` | `ProviderRequirement` @ `terraform-providers:requirement:{path}:{name}`; `TerraformProvider`; `requires` |
| Which providers does this `module` block pass down to the child module? | `definition.config_entry`, joined `within` the `providers` attribute, joined `within` a `module` block | `ProviderConsumer` @ `terraform-providers:consumer:{path}:{blk.source.start}`; `TerraformProvider`; `passes_provider` |
| Which declarations are pinned to a non-default provider configuration, and to which alias? | `reference.traversal`, joined `within` a `provider` attribute, joined `within` its block | `ProviderConsumer`; `ProviderSelection` @ `terraform-providers:selection:{path}:{source.start}`; `selects` |

`TerraformProvider` is the hub: three rules mint it, all under
`terraform-providers:provider:{definition.name}`, all with the one kind and the
one attribute `name`, and the classification is carried by the edges that point
at it (`configures`, `requires`, `passes_provider`). `ProviderConsumer` is
minted by two rules under one key template, one kind and identical attributes,
so neither rule loses its outputs to the other (brief 3g).

Every canonical key a relation addresses is minted by a rule in this file:
`terraform-providers:provider:{definition.name}` (rules `configuration`,
`requirement`, `module-providers`),
`terraform-providers:provider-config:{path}:{...source.start}` (rule
`configuration` — and `configuration.alias` carries the same
`block_type = provider` and `**/*.tf` conditions that decide whether that key
exists), and `terraform-providers:selection:...` (minted in the rule that
addresses it). The key space is `terraform-providers:`, deliberately separate
from omega-framework-terraform's `terraform:` — `terraform-providers.*` sorts
before `terraform.*` (`-` < `.`), so sharing a key template would silently
replace that framework's `Provider` entity with this one's.

## A field only the Pack can supply

**Pack `omega-hcl`, kind `definition.config_block`, field `type_label`.** The
resource type label — `aws_instance` in `resource "aws_instance" "web"` — is
what attributes a resource or data source to a provider: Terraform's own rule is
that the provider is the type's prefix up to the first underscore. omega-hcl
computes this value already and publishes it as an **attribute**
(`packs/omega-hcl/rules.json`, the `block2` template), and
`OverlayFact::field` never consults `attributes` — the only clause that reads
one is `attribute_equals` against a single literal, so it cannot be a canonical
key, a relation end, an entity attribute or a join key. No join reaches it
either: `fact_join_by_span` only relates the block to facts that contain or
equal it, and the type label is not a separate emission. Without it, *which
provider does this resource use* is answerable only for the minority of
declarations that carry an explicit `provider =` argument. The same defect, on
the same kind, blocks `block_type` from being usable as anything but an equality
test.

Two more values in the same file are attributes for the same reason and cost
this overlay real answers: `value` on `definition.config_attribute` and
`definition.config_entry` (so a provider alias string, a `source =
"hashicorp/aws"` and a `version = "~> 5.0"` are all declarations without their
values), and `root` on `reference.traversal` (so `provider = aws.west` states
the alias `west` but not the provider `aws`). `framework-design/00-INDEX.md`
already records the first two under wave 1; `root` is recorded there too. This
framework is the case that makes them expensive rather than cosmetic: with
`type_label` and `value` as fields, three more rules — implicit provider
attribution for `resource`/`data`, the registry source of a requirement, and the
version constraint — become writable, and `ProviderAlias` and `ProviderSelection`
can be joined to each other instead of standing apart.

## Still to decide

- **`terraform-providers.requirement` recognises its container by name alone.**
  An unlabeled block is named by its type, so `definition.name =
  "required_providers"` is exact for the real thing — but a labelled block that
  happens to carry `required_providers` as its label (`variable
  "required_providers"`) would match too. omega-hcl's `block0` template publishes
  no attributes at all, so there is no `block_type` to test against and no
  clause that asserts an attribute is *absent*. Judged not worth a rule that
  cannot be written; it becomes exact the moment `block_type` is a field on
  every block emission.
- **`terraform-providers.selection` does not constrain the enclosing block's
  type.** `provider =` is legal in `resource`, `data`, `import` and `moved`
  blocks, and `attribute_equals` takes one literal with no set form, so
  constraining it would mean one rule per block type — the shape this rewrite
  removed. The join therefore binds whatever block encloses the attribute, and
  the `ProviderConsumer` it mints is named by that block's label. In a nested
  block a second binding is possible; no Terraform spelling puts `provider =`
  inside a nested block, so it is left open rather than split into three rules.
