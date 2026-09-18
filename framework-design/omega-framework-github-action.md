# omega-framework-github-action

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

34 overlay rules, 2 detection rules. **0 can match, 34 cannot.**

Selector: `framework:github-action`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `JobSetting` | 11 |
| `Pipeline` | 2 |
| `Trigger` | 2 |
| `JobContainer` | 2 |
| `ContainerConfig` | 2 |
| `JobService` | 2 |
| `ServiceConfig` | 2 |
| `Job` | 1 |
| `Step` | 1 |
| `Dependency` | 1 |
| `PermissionPolicy` | 1 |
| `ConcurrencyPolicy` | 1 |
| `EnvironmentConfig` | 1 |
| `EnvironmentBinding` | 1 |
| `MatrixAxis` | 1 |
| `WorkflowContractField` | 1 |
| `JobOutput` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 28 |
| `uses` | 2 |
| `contains` | 1 |
| `contains_step` | 1 |
| `needs` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 32 | **no** |
| `value.document` | 2 | **no** |

Clause vocabulary in use: `field_equals` x70, `fact_kind` x34, `path_glob` x34, `attribute_equals` x32, `field_present` x9, `field_in` x2.

Fields read: `key`, `a0`, `a2`, `grandparent_key`, `a3`, `sequence_key`, `a1`, `item_key`, `a4`, `value`, `parent_key`, `item_value`.

Path globs: `.github/workflows/*.{yml,yaml}`, `.github/workflows/*.yml`, `.github/workflows/*.yaml`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `github.workflow` | kind `value.document` |
| `github.workflow.yaml` | kind `value.document` |
| `github.job` | kind `structured.entry`; field `parent_key`; attribute `role` |
| `github.step` | kind `structured.entry`; field `grandparent_key`, `item_key`, `sequence_key`; attribute `role` |
| `github.needs` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.step.uses` | kind `structured.entry`; field `grandparent_key`, `item_key`, `item_value`, `sequence_key`; attribute `role` |
| `github.workflow.on` | kind `structured.entry`; field `key`; attribute `role` |
| `github.workflow.permissions` | kind `structured.entry`; field `key`; attribute `role` |
| `github.workflow.concurrency` | kind `structured.entry`; field `key`; attribute `role` |
| `github.workflow.env` | kind `structured.entry`; field `key`; attribute `role` |
| `github.workflow.trigger.sequence` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `github.job.config.runs-on` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.if` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.environment` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.concurrency` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.permissions` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.timeout-minutes` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.continue-on-error` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.uses` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.config.name` | kind `structured.entry`; field `grandparent_key`, `key`; attribute `role` |
| `github.job.env.entry` | kind `structured.entry`; field `a0`, `a2`; attribute `role` |
| `github.job.matrix.entry` | kind `structured.entry`; field `a0`, `a2`, `a3`; attribute `role` |
| `github.workflow-call.contract-field` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `github.job.output.entry` | kind `structured.entry`; field `a0`, `a2`; attribute `role` |
| `github.job.strategy.fail-fast` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.strategy.max-parallel` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.container.image` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.container.options` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.container.env.entry` | kind `structured.entry`; field `a0`, `a2`, `a3`; attribute `role` |
| `github.job.container.credentials.entry` | kind `structured.entry`; field `a0`, `a2`, `a3`; attribute `role` |
| `github.job.service.image` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.service.options` | kind `structured.entry`; field `a0`, `a2`, `key`; attribute `role` |
| `github.job.service.env.entry` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `key`, `value`; attribute `role` |
| `github.job.service.credentials.entry` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `key`, `value`; attribute `role` |

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
