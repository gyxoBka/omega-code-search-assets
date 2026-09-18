# omega-framework-github-action

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

34 overlay rules, 2 detection rules. **0 can match, 34 cannot.** That is the
state this document was written against; after the rewrite below it is **14
overlay rules, 14 live, 0 dead**. Everything from here to *What was wrong with
it* describes the file as it was.

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

## What was wrong with it

**34 rules, 0 live.** Three independent defects, any one of which was fatal.

1. **The fact kind.** 32 rules matched `structured.entry` and 2 matched
   `value.document`. No Pack emits either. `omega-yaml` states four things:
   `definition.config_key` (a mapping key, with its scalar value carried as the
   attribute `value`), `relation.data` (a scalar listed in a sequence),
   `definition.anchor`/`reference.anchor`, and `reference.tag`. There is no
   document fact and no nesting fact.

2. **The ancestry fields.** Every one of the 32 `structured.entry` rules read
   the old generator's per-depth ancestor path — `a0`…`a4` (12 rules),
   `parent_key`, `grandparent_key`, `key`, `value`, `item_key`, `item_value`,
   `sequence_key` — and all 32 also required the attribute `role`
   (`yaml_nested_pair`, `yaml_depth3_pair`, `yaml_owned_sequence_item`, …).
   That was one Pack pattern per nesting depth; `omega-yaml`'s header says
   plainly that the thirty-five depth patterns were replaced by span
   containment, so all of it is gone.

3. **The path glob, which was dead before the Pack rewrite.** 32 rules carried
   `path_glob` `.github/workflows/*.{yml,yaml}`. `glob_here`
   (`overlay.rs:1125`) implements `*`, `**` and `?` and **nothing else** —
   there is no brace expansion, so that pattern matches no path at all. Those
   32 rules could never have fired even against the old Packs. Of the remaining
   two, `github.workflow` globbed `*.yml` and `github.workflow.yaml` globbed
   `*.yaml`, i.e. the file was carrying two rules to do what one `*.y*ml` does.

4. **Restating the input.** 11 of the 34 rules emitted a `JobSetting` per
   job-level key (`if`, `timeout-minutes`, `continue-on-error`, `name`,
   `environment`, `concurrency`, `permissions`, `uses`, `runs-on`, …), whose
   whole content was the key's own name and its value. Every one of them is
   gone: the *value* is what a person asks about, and the value is not
   readable (see below). What survives is the handful where the **key name
   itself** is the answer — a job name, a trigger event, an output name, a
   matrix axis, a `workflow_call` input.

**34 rules became 14, all live.** Entities went from 17 kinds to 11; the
retired ones (`JobSetting`, `ContainerConfig`, `ServiceConfig`,
`EnvironmentConfig`, `ConcurrencyPolicy`, `Dependency`) all existed only to
hold an unreadable value. The relation `uses` is gone with them, for the same
reason.

### How nesting is stated now

`omega-yaml` spans a pair over key *and* value, so a nested key lies strictly
inside its parent's span and `fact_join_by_span` with `within` reaches every
ancestor — but *every* ancestor, with no way to ask for the nearest one. Two
idioms do the work:

- **anchor by name**: `within` a `definition.config_key` named `steps`,
  `matrix`, `outputs`, `on`, `env`, `permissions`, `needs`, `services`.
- **the job key**: an ancestor that is itself `within` a key named `jobs`,
  with this rule's own known intermediate key names ruled out by
  `field_not_in`. For `jobs.build.strategy.matrix.os` the ancestors inside
  `jobs` are `matrix`, `strategy` and `build`; excluding the two constants
  leaves the job. This is exact wherever every intermediate level has a name
  GitHub fixes, which is everywhere except `services.<id>` (see *Still to
  decide*).

## What it states now

`ci:github:{path}` is the workflow; every other key hangs off it.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which files are workflows | `definition.config_key` named `jobs` under `.github/workflows/*.y*ml` | `Pipeline` `ci:github:{path}` |
| which jobs a workflow declares | `config_key` named `runs-on`/`steps`/`uses`, span-joined up to the job key inside `jobs` | `Job` `ci:github:job:{path}:{job}`; `contains` from `Pipeline` |
| **what a job depends on** | `relation.data` (a sequence element) inside a key named `needs`, inside a job | `needs` from `Job` to `Job` |
| what starts a workflow | `config_key` whose name is one of 35 GitHub events, inside the key `on` | `Trigger` `ci:github:trigger:{path}:{event}`; `configured_by` from `Pipeline` |
| …written as `on: [push, …]` | `relation.data` with the same event name, inside `on` | same `Trigger` key — the two spellings agree |
| what a reusable workflow takes and returns | `config_key` inside `inputs`/`secrets`/`outputs` inside `workflow_call`/`workflow_dispatch` | `WorkflowContractField` `ci:github:contract:{path}:{event}:{section}:{name}`; `configured_by` from `Pipeline` |
| what a job publishes for downstream jobs | `config_key` inside `outputs` inside a job | `JobOutput` `ci:github:job-output:{path}:{job}:{name}`; `configured_by` from `Job` |
| what a job fans out over | `config_key` inside `matrix` inside a job, minus `include`/`exclude` | `MatrixAxis` `ci:github:matrix-axis:{path}:{job}:{axis}`; `configured_by` from `Job` |
| whether a job runs in a container | `config_key` named `container` inside a job | `JobContainer` `ci:github:container:{path}:{job}`; `configured_by` from `Job` |
| which steps a job has, and where | `config_key` named `uses`/`run` inside `steps` inside a job | `Step` `ci:github:step:{path}:{job}:{source.start}`; `contains_step` from `Job` |
| which service containers CI needs | `config_key` named `image` whose parent is a key inside `services` | `JobService` `ci:github:service:{path}:{id}`; `configured_by` from `Pipeline` |
| which environment variables a workflow sets | `config_key` inside a key named `env` | `EnvironmentBinding` `ci:github:env:{path}:{name}`; `configured_by` from `Pipeline` |
| **which token scopes a workflow asks to write** | `config_key` inside `permissions` with `attribute_equals value = write` | `PermissionPolicy` `ci:github:permission:{path}:{scope}`; `configured_by` from `Pipeline` |
| …or asks for wholesale | `config_key` named `permissions` with `attribute_equals value = write-all` | `PermissionPolicy` `ci:github:permission:{path}:write-all` |

Every canonical key a relation addresses is minted by a rule in this file:
`ci:github:{path}` by `github.workflow`, `ci:github:job:{path}:{name}` by
`github.job` (which is the target of `github.job.needs`), and every other end
is `current`.

## A field only the Pack can supply

**Pack `omega-yaml`, kind `definition.config_key`, value published as the
attribute `value` — it must be a `field`.**

`OverlayFact::field` (`overlay.rs:56`) resolves `fields` and a fixed list of
built-in names and never consults `attributes`; the only clause that reads an
attribute is `attribute_equals` against one literal constant. So a scalar
value can be compared to a constant and used for nothing else — not as a
canonical key, not as a relation end, not as an entity attribute, not as a
join key.

Neither of the first two options in the brief reaches it. It is not derivable:
`definition.name` is the *key*, not the value, and no path-derived name
contains it. No join reaches it either: `fact_join_by_span` relates a fact to
an enclosing fact, and the value is not a separate emission — the Pack's
`scalar_pair` template captures `scalar_pair.value` and puts the captured text
straight into `attributes.value`, so there is nothing else in the index to
join to. This is the same byte count in a different map.

What it costs this Framework, concretely:

- **which action does a step run** — `uses: actions/checkout@v4` — is
  unanswerable, and that is the single most-asked question about a workflow.
  `github.job.step` therefore mints a `Step` located by `{source.start}` with
  only its form (`uses` or `run`); the moment `value` is a field, that same
  rule keys the step by the action ref and a `uses` relation to an
  `Action` entity becomes one line.
- **which reusable workflow a job calls** (`jobs.<id>.uses`), **what runner a
  job asks for** (`runs-on`), **what environment it deploys to**
  (`environment`), **its concurrency group**, **its `if` condition** and
  **every env var's value** are all unreadable for the same reason.
- `on: push` and `needs: build` in their bare-scalar spellings are lost;
  only the mapping and sequence spellings are stated.

This is the finding `00-INDEX.md` already records for `omega-yaml` and
`omega-json`. Nothing here is a new request; this Framework is the loudest
case for it.

## Still to decide

1. **`services.<id>` is workflow-scoped, not job-scoped.** The job-key idiom
   needs every intermediate level to have a name GitHub fixes. A service id is
   user-chosen, so from `jobs.build.services.redis.image` the ancestors inside
   `jobs` are `redis`, `services` and `build`, and `redis` cannot be excluded
   by name. `github.service` therefore states *this workflow starts a redis
   service* rather than *this job does*. A `fact_join_by_span` relation
   meaning "is the nearest enclosing fact of this kind", or a `contains`
   direction, would fix it for every YAML framework at once; that is a host
   change, not a Pack field, so it is recorded here rather than under the
   heading above.
2. **`github.job.step` is kept deliberately** although it cannot yet name the
   action it runs. It is one rule, it gives the graph a node per step with a
   byte offset to navigate to, and it is the anchor the `uses` value attaches
   to on the day the Pack publishes it. If the reviewer would rather the graph
   carry no step at all until then, deleting it costs nothing else — no other
   rule addresses `ci:github:step:…`.
3. **The `workflow_call` contract rule excludes seven descriptor key names**
   (`required`, `type`, `default`, `description`, `deprecationMessage`,
   `options`, `value`) to keep an input's own properties from being mistaken
   for inputs. An input literally named `type` is therefore missed. The
   alternative — a nearest-ancestor join — is item 1.
4. **A job named `steps`, `matrix`, `strategy`, `with`, `include`, `exclude`,
   `defaults`, `outputs`, `needs` or `env` would be skipped** by the rule
   whose exclusion list names it. These are legal job ids and vanishingly rare
   ones; the trade is stated rather than hidden.
