# omega-framework-terraform-template

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**9 overlay rules, 2 detection rules; 9 live, 0 cannot match.**
It shipped as 15 rules of which 0 could match; what follows records that state
and what replaced it.

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

## What was wrong with it

**15 of 15 rules could not match.** Seven fact kinds, none of them emitted by
any Pack: `scope.hcl_body`, `definition.hcl_block_labeled`,
`reference.hcl_block_list_traversal_context`,
`reference.hcl_block_traversal_context`, `reference_context.template_interpolation`,
`reference_context.template_condition`, `call.hcl_function_context`. Five fields
no Pack publishes: `block_kind`, `owner_kind`, `target_root`, `attribute_key`,
`function_name` -- omega-hcl publishes **no field at all** on any of its nine
templates.

Three separate defects, beyond the kind rename:

1. **Eight of the fifteen rules were a second copy of omega-framework-terraform.**
   `terraform-template.resource`, `.module`, the four `depends_on.*` and the four
   `references.*` rules state resources, modules and their edges -- which is the
   whole of what the sibling overlay, rewritten in wave 1, already states over
   `definition.config_block` and `reference.traversal`, with 40 live rules. They
   are deleted rather than ported: two frameworks minting the same edges under
   two key namespaces is worse than one minting them once.

2. **The 2x2 expansion was per-spelling, not per-question.**
   `depends_on.{resource,module}_{resource,module}` and
   `references.{resource,module}_{resource,module}` are eight rules whose only
   difference is a literal in `owner_kind`/`target_root`. Nothing in this
   framework needs that product.

3. **Four rules matched `.tftpl` files, which no Pack parses.** `TemplateFile`,
   `TemplateReference` and `TemplateControl` were built on
   `reference_context.template_interpolation` / `.template_condition` in
   `**/*.tftpl`. No grammar in the repository claims that extension, so even a
   correctly-named kind would see zero facts. That family is gone; what it tried
   to answer is now answered from the `.tf` side, where the render site and its
   variables *are* stated. Three of its four `path_glob`s were the brace globs
   recorded in `00-INDEX.md` wave 3 (`**/*.{tf,hcl}`, `**/*.{tf,hcl,tftpl}`),
   which `glob_here` treats as literal bytes and which matched nothing anyway.

4. **`terraform-template.source-authored.config-document` restated its input:**
   one entity per HCL file, keyed by the path, attribute `path`, no relation.

**15 rules -> 9, all live.** The scope is now the one thing the sibling does not
cover: templating.

## What it states now

Every rule is over omega-hcl, in `**/*.tf`. omega-hcl emits nine templates and
no fields, so everything below runs on `definition.name`, `path`, `span` and the
three attributes `block_type`, `type_label` and `root`, which `attribute_equals`
can test against a literal.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| Where does this configuration render a template? | `call.function` named `templatefile` or `templatestring` | `TemplateRender` `terraform-template:render:{path}:{source.start}` |
| Which declared block renders it? | the same call, `fact_join_by_span`/`within` a `definition.config_block` | `TemplatingBlock` + `contains` block -> render |
| Which setting is computed by rendering a template (`user_data`, `content`, `command`)? | the same call, `within` a `definition.config_attribute` | `TemplatedSetting` + `configured_by` setting -> render |
| Which input variable does a render read? | `reference.traversal`, `root == var`, `within` the templatefile call | `Variable` + `depends_on` render -> variable |
| Which local value does a render read? | `reference.traversal`, `root == local`, `within` the call | `Local` + `depends_on` render -> local |
| Which template variables does this render site set -- the names the template will interpolate? | `definition.config_entry` `within` the call | `TemplateVariable` + `configured_by` render -> variable |
| Where is the deprecated `template_file` data source still declared? | `definition.config_block`, `block_type == data`, `type_label == template_file` | `TemplateDataSource` `terraform-template:template-file:{name}` |
| Where is a whole directory rendered by `template_dir`? | `definition.config_block`, `block_type == resource`, `type_label == template_dir` | `TemplateDirectory` |
| Which variables does a `template_file` set in its `vars` object? | `definition.config_entry` `within` a `definition.config_attribute` named `vars` `within` that block | `TemplateVariable` + `configured_by` data source -> variable |

The call's span is the whole `function_call` node, which is what makes six of
the nine work: a traversal or an object entry written inside
`templatefile("init.tftpl", { host = var.host })` lies inside that span, so
`fact_join_by_span`/`within` reaches the render site with no field on either
side.

### Keys minted, keys addressed

Minted: `render:{path}:{start}`, `block:{path}:{start}`, `setting:{path}:{start}`,
`variable:{name}`, `local:{name}`, `render-var:{path}:{start}:{name}`,
`template-file:{name}`, `template-dir:{name}`,
`template-file-var:{owner}:{name}`. Addressed by a relation: `render` (minted by
`terraform-template.render` under strictly weaker clauses than every rule that
addresses it), `block`, `template-file` (minted by
`terraform-template.legacy.template-file` under exactly the clauses the `.variable`
rule carries in its join). Nothing dangles, and no relation points at the
sibling `terraform:` namespace.

## Still to decide

- **The rendered file is not linked to its render site.** `templatefile("x.tftpl", ...)`
  states the call by name only; the first argument is a string literal inside the
  call and omega-hcl emits no fact for it. So *which template does this resource
  render* is unanswerable, and would stay unanswerable even if a Pack claimed
  `.tftpl`, because there is nothing to join the two files on. This is a Pack
  query question (a pattern for a function call's first string argument), not an
  overlay one, and it is not requested here: it would cost a fact on every
  function call in every HCL file to serve one framework.
- **`.tftpl` is unclaimed.** No grammar in `grammars/` lists the extension, so a
  template's own `${...}`, `%{ if }` and `%{ for }` are invisible. Whether Omega
  should have a template grammar at all is a wider decision than this overlay.
- **Only `var` and `local` roots are stated as render inputs.** `each`, `count`,
  `data` and a bare resource traversal inside a `templatefile` call are real
  inputs too, but each needs its own rule because `attribute_equals` takes one
  literal and there is no `attribute_in`. Two rules cover the two roots that are
  asked about; adding four more for the rest is a size judgement, not a
  correctness one.
- **`template_cloudinit_config`** is the third member of the legacy `template`
  provider and is omitted for the same reason: one rule per literal label, and it
  assembles parts rather than rendering a template.

## A field only the Pack can supply

None. Every rule above runs on `definition.name`, `path`, `span` and the three
attributes omega-hcl already publishes. The one value this framework would
benefit from -- the template path argument of `templatefile()` -- is not a field
on an existing emission but a fact omega-hcl does not emit at all, and is
recorded above as a deliberate non-request.
