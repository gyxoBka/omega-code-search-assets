# omega-framework-gitlab-ci

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

48 overlay rules, 2 detection rules. **0 can match, 48 cannot.**

Selector: `framework:gitlab-ci`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `JobSetting` | 26 |
| `Dependency` | 4 |
| `PolicyClause` | 3 |
| `Step` | 2 |
| `Variable` | 2 |
| `Pipeline` | 1 |
| `Job` | 1 |
| `Stage` | 1 |
| `ImageConfig` | 1 |
| `WorkflowPolicy` | 1 |
| `DefaultConfig` | 1 |
| `CacheConfig` | 1 |
| `VariableGroup` | 1 |
| `ServiceDependency` | 1 |
| `RunnerTag` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 31 |
| `uses` | 3 |
| `contains` | 2 |
| `contains_step` | 2 |
| `needs` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 47 | **no** |
| `value.document` | 1 | **no** |

Clause vocabulary in use: `field_equals` x60, `fact_kind` x48, `path_glob` x48, `attribute_equals` x47, `field_not_in` x15, `field_not_prefix` x15, `field_in` x3, `field_present` x3.

Fields read: `key`, `grandparent_key`, `owner_key`, `sequence_key`, `item_value`, `value`, `item_key`, `parent_key`, `a2`.

Path globs: `.gitlab-ci.yml`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `gitlab.pipeline` | kind `value.document` |
| `gitlab.job` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.stage` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.step.field` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.step.sequence` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.needs` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.include.literal` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `gitlab.include.sequence` | kind `structured.entry`; field `item_value`, `sequence_key`; attribute `role` |
| `gitlab.include.mapping-sequence-field` | kind `structured.entry`; field `item_key`, `item_value`, `sequence_key`; attribute `role` |
| `gitlab.top.image` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.top.workflow` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.top.default` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.top.cache` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.top.variables` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.variable.top` | kind `structured.entry`; field `parent_key`; attribute `role` |
| `gitlab.job.config.stage` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.image` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.environment` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.when` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.allow_failure` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.interruptible` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.resource_group` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.extends` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.trigger` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.config.retry` | kind `structured.entry`; field `key`; attribute `role` |
| `gitlab.job.variable` | kind `structured.entry`; field `a2`; attribute `role` |
| `gitlab.sequence.rules` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.sequence.only` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.sequence.except` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.sequence.services` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.sequence.dependencies` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.sequence.tags` | kind `structured.entry`; field `sequence_key`; attribute `role` |
| `gitlab.job.nested.artifacts.name` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.artifacts.expire-in` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.artifacts.expose-as` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.artifacts.when` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.cache.key` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.cache.policy` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.cache.unprotect` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.environment.name` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.environment.url` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.environment.action` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.environment.deployment-tier` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.release.tag-name` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.release.name` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.nested.release.description` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `gitlab.job.sequence.artifacts.paths` | kind `structured.entry`; field `owner_key`, `sequence_key`; attribute `role` |
| `gitlab.job.sequence.cache.paths` | kind `structured.entry`; field `owner_key`, `sequence_key`; attribute `role` |

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
