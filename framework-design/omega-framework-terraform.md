# omega-framework-terraform

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**33 overlay rules, 2 detection rules. 33 live, 0 cannot match.**
`python pack-design/key_collisions.py terraform` reports nothing.

Selector: `framework:terraform`. Maturity: `semantic-overlay-full`.
Pack: `omega-hcl` only. Path glob: `**/*.tf`.

The five kinds omega-hcl emits, and what this file does with each:

| kind | fields it publishes | used for |
|---|---|---|
| `definition.config_block` | `block_type`, `type_label` (two-label blocks only) | every declaration, and every owner join |
| `definition.config_attribute` | none (`value` is an attribute) | `locals`, `required_providers`, `count`/`for_each`, and the slot a reference sits in |
| `definition.config_entry` | none (`value` is an attribute) | not matched |
| `reference.traversal` | `root` | every reference, every `depends_on` entry, every provider selection |
| `call.function` | none | not matched |

Clause census: `field_equals` x36, `field_in` x23, `field_present` x13,
`fact_join_by_span` x30, `fact_join_by_field` x5, `attribute_equals` x0.

## What was wrong with it

The previous revision was already 40 live rules — the dead-kind port happened a
wave earlier. What was wrong with it is that **omega-hcl's three identifying
values were attributes, and an attribute is write-only**: `OverlayFact::field`
never consults `attributes`, so `block_type`, `type_label` and `root` could be
tested against a constant with `attribute_equals` and used for nothing else.
They are now published as **fields** as well. Measured on a hand-written
`main.tf` with `dump_call_emissions`:

```
449-734  definition.config_block  name=assets  block_type=String("resource") type_label=String("aws_s3_bucket")
867-873  reference.traversal      name=assets  root=String("aws_s3_bucket")
517-521  reference.traversal      name=west    root=String("aws")
```

Five concrete defects follow from that, all fixed here.

1. **A declaration was keyed by its last label alone** — 5 rules
   (`terraform.resource`, `.data-source`, `.ephemeral`, and the two entity
   spaces every relation addressed). `aws_vpc.main` and `aws_subnet.main` both
   rendered `terraform:resource:main` and, by `or_insert`, became one entity.
   The key is now `terraform:resource:{type_label}.{definition.name}` — the
   real Terraform address.
2. **The owner cross-product was written out by hand** — 16 `references.*`
   rules, one per (owner block type × target namespace), differing only in two
   literal key prefixes. With `block_type` renderable the source end is one
   template, `terraform:{owner.block_type}:{owner.definition.name}`, and 16
   rules become 8: two owner families (typed blocks that carry a `type_label`,
   named blocks that do not) × four targets.
3. **A resource reference was resolved by name alone and scored `high`** — 7
   rules joined `definition.name` to `definition.name` and accepted any
   `resource` block of that name, so `var.main` and `aws_vpc.main` were the
   same target. The join now carries `current_field: root` →
   `join_field: type_label` with `definition.name` as an
   `additional_field_equality`: the full address on both sides. All 33 rules
   are `confidence: exact`; none is `high`.
4. **58 `attribute_equals` clauses, 44 of them on `block_type`.** Every one was
   a test against a constant that could not also be read. They are now
   `field_equals`/`field_in`, and the same value doubles as a key segment.
5. **Three answers were absent because their value was unreachable.**
   `provider = aws.west`, `providers = { aws = aws.west }` and a `moved`/
   `import`/`removed` address were dropped in the previous revision (the .md
   said so under "Still to decide" 3 and under the Pack-field request). All
   three are traversals whose `root` is the answer, and all three are stated
   now.

Rules removed: the 8 duplicated owner-family `references.*`, one duplicated
`dynamic-block` rule (owner block type is a field, so resource and data are one
rule). Rules added: `terraform.ephemeral` (it was declared, its entity was
minted, but no reference rule could name it as an owner),
`terraform.state-operation.address`, `terraform.provider-selection.typed`,
`terraform.provider-selection.module`. Net 40 → 33.

`detection_rules` was left alone: two atoms on `specifier`/`name`, still true.

Withdrawn from `coverage.gaps`, because the measurement no longer holds:

- *"a declaration is identified by its last label alone … aws_vpc.main and
  aws_subnet.main share one key"* — `type_label` is a field; the key is the
  address.
- *"provider alias … materialized as declarations without their values"* — the
  alias is the traversal's `definition.name` and the provider is its `root`;
  the selection is a relation now, not a value.

## What it states now

33 rules. Key spaces minted: `terraform:{resource,data,ephemeral}:{type}.{name}`,
`terraform:{module,variable,output,provider,check,local}:{name}`,
`terraform:terraform:{path}`, `terraform:backend:{path}:{name}`,
`terraform:state-op:{path}:{offset}`, and the three derived spaces
`terraform:lifecycle:…`, `terraform:dynamic:…`, `terraform:meta:…`,
`terraform:assert:…`. Every relation end renders into one of those templates.

### Declarations — 13 rules

| what | which Pack fact | entity / relation |
|---|---|---|
| a resource, data source, ephemeral resource (3 rules) | `definition.config_block`, `field_equals block_type`, `field_present type_label` | `Resource` / `DataSource` / `EphemeralResource` at `terraform:<space>:{type_label}.{definition.name}`, attribute `type` |
| a module, variable, output, provider, check (5 rules) | `definition.config_block`, `field_equals block_type` | `Module`, `Variable`, `Output`, `Provider`, `Check` at `terraform:<space>:{definition.name}` |
| a local value | `definition.config_attribute` `within` the block named `locals` | `Local` at `terraform:local:{definition.name}` |
| the `terraform` block of a file | `definition.config_block` named `terraform` | `TerraformConfig` at `terraform:terraform:{path}` |
| where state lives | `definition.config_block` `block_type=backend` `within` the `terraform` block | `Backend` + `contains` from `TerraformConfig` |
| which providers the configuration requires | `definition.config_attribute` `within` the block named `required_providers` | `Provider` + `depends_on` from `TerraformConfig` |
| a pending `moved` / `import` / `removed` | `definition.config_block`, `field_in definition.name` | `StateOperation` at `terraform:state-op:{path}:{source.start}` |

Answers: *what does this configuration declare, and at what address*; *which
resources are of type `aws_s3_bucket`*; *where is state stored*; *which
providers does it need*; *what refactors are pending*.

### The address a state operation names — 1 rule

| what | which Pack fact | relation |
|---|---|---|
| `moved { from = aws_s3_bucket.old \n to = aws_s3_bucket.assets }` | `reference.traversal` `within` a `definition.config_attribute` named `from`/`to` (bound `slot`) `within` the operation block (bound `op`), joined `root`→`type_label` + name→name to a `resource` block | `references` StateOperation → Resource, relation attribute `role` = `from` or `to` |

Answers: *what was this resource moved from*, *which resource is this import
adopting*. The `slot` join is what makes `from` and `to` distinguishable; no
Pack field states it.

### Containment — 5 rules

| what | which Pack fact | entity / relation |
|---|---|---|
| a `lifecycle` block | `definition.config_block` named `lifecycle`, owner `within` a typed block | `Lifecycle` + `contains` from the owner |
| a `dynamic "x"` block | `definition.config_block` `block_type=dynamic`, owner `within` a typed block | `DynamicBlock` + `contains` |
| an `assert` block | `definition.config_block` named `assert`, owner a `check` | `Assertion` + `contains` from `Check` |
| `count` / `for_each` on a typed block, and on a module (2 rules) | `definition.config_attribute`, `field_in ["count","for_each"]`, owner `within` | `MetaArgument` + `contains` |

Answers: *is this resource multi-instance*; *does it have lifecycle rules*;
*which nested blocks are generated*.

### References — 8 rules

Current fact is `reference.traversal`; the owner is one `fact_join_by_span`
`within` `definition.config_block`. Two owner families, four targets.

| owner family | owner clause | source end |
|---|---|---|
| `typed` | `field_in block_type ["resource","data","ephemeral"]` + `field_present type_label` | `terraform:{owner.block_type}:{owner.type_label}.{owner.definition.name}` |
| `named` | `field_in block_type ["module","output"]` | `terraform:{owner.block_type}:{owner.definition.name}` |

| target | which Pack fact | relation |
|---|---|---|
| `var.x` | `field_equals root var` | `configured_by` → `terraform:variable:{definition.name}` |
| `local.x` | `field_equals root local` | `configured_by` → `terraform:local:{definition.name}` |
| `module.m.out` | `field_equals root module` | `references` → `terraform:module:{definition.name}` |
| `aws_x.y.attr` | `fact_join_by_field root`→`type_label`, name→name, `block_type=resource` | `references` → `terraform:resource:{target.type_label}.{target.definition.name}` |

Answers: *which variables configure this module*, *which resources does this
output expose*, *what breaks if I delete this local*, *who reads
`aws_s3_bucket.assets`* — and the last one is now exact rather than
name-matched.

### Explicit ordering — 4 rules

Same two owner families, plus a `fact_join_by_span` `within` the
`definition.config_attribute` named `depends_on`; targets module and resource.
`depends_on` deliberately overlaps `references`: a `depends_on` entry is both a
reference and an ordering constraint, and the two relation kinds answer
different questions.

### Provider wiring — 2 rules

| what | which Pack fact | relation |
|---|---|---|
| `provider = aws.west` in a resource/data/ephemeral | `reference.traversal` `within` the attribute named `provider` | `configured_by` owner → `terraform:provider:{root}`, relation attribute `alias` = `{definition.name}` |
| `providers = { aws = aws.west }` in a module | `reference.traversal` `within` the attribute named `providers` | `configured_by` module → `terraform:provider:{root}`, attribute `alias` |

Answers: *which provider configuration does this resource use*, *which provider
is passed into this module*. `root` is the provider name and the traversal's own
name is the alias; the enclosing attribute name is the only thing that separates
the two spellings, and it comes from a span join, not a field.

## A field only the Pack can supply

**Pack `omega-hcl`, kinds `definition.config_attribute` and
`definition.config_entry`, field `value`.**

The Pack computes it — `attribute.scalar.value` / `object.scalar.value`,
unquoted and trimmed — and publishes it under `attributes` only
(`packs/omega-hcl/rules.json`, both templates have `"fields": {}`). `render()`
and `field_ref` go through `Binding::resolve` → `OverlayFact::field`, which
reads `fields` and the built-in names and never looks at `attributes`, and
`fact_join_by_field` compares fields only, so no join reaches it either.

What it costs, exactly:

1. **`module { source = "./modules/network" }` is not stated.** A `Module`
   entity cannot carry where its code comes from, and a local module source
   cannot be related to the directory it names. This is the one place a
   Terraform graph is genuinely cross-file and the overlay cannot cross it.
2. **A `backend "s3"` block's settings** (`bucket`, `key`, `region`) are
   declarations without values, so *which bucket holds this state* is not
   answerable.
3. **`count = 2` / `for_each = var.x`** materialize as `MetaArgument` with no
   value. (`for_each = var.x` is partly recovered by the traversal inside it;
   `count = 2` is not.)

Three sibling facts already publish the same shape as a field —
`omega-yaml`/`omega-json`/`omega-toml` `definition.config_key` `value`,
`omega-xml` `definition.config_attribute` `value`, `omega-prisma`
`definition.config_setting` `value` — so this is a one-line alignment, not a new
capability.

Nothing else is asked of the Pack. The owner of a nested construct, the
attribute a reference sits in, the enclosing block of a local and the `from`/`to`
slot of a state operation are all reached by `fact_join_by_span` with `within`.

## Still to decide

1. **`data.aws_ami.web` is still not a reference to the data source.** The
   traversal pattern captures the root and the *first* segment; for a data
   source the first segment is the type, so the emission is `root=data`,
   `name=aws_ami` and the instance name `web` is never captured. Re-measured
   this wave, unchanged. Fixing it means a second `get_attr` capture in
   `packs/omega-hcl/queries.scm` — a Pack pattern change, not a field move — so
   it is left in `coverage.gaps` rather than requested here.
2. **`provider = aws` without an alias emits nothing.** A bare identifier with
   no `get_attr` is not a traversal (the query requires a segment, deliberately:
   in this grammar `type = string` is also a bare `variable_expr`). So the
   default-provider case of `terraform.provider-selection.typed` is silent,
   while the aliased case is exact. Recorded as a gap; widening the Pack pattern
   would make every object key and type keyword a reference.
3. **`definition.container` / `enclosing.qname` are usable but would replace a
   join with a field read.** The host synthesizes both on every fact, and
   `definition.container` would state *this reference sits in the attribute
   named `provider`* without a span join — three rules here could drop a clause.
   `overlay_audit.py`'s `BUILTIN` set does list them now, so the objection in the
   previous revision is withdrawn; the joins are kept because they also bind the
   slot fact, which `definition.container` does not (it is a name, not a
   binding, so `role` in `terraform.state-operation.address` still needs the
   join).
