# omega-framework-github-action

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**21 overlay rules, 2 detection rules. 21 live, 0 cannot match.**

Selector: `framework:github-action`. Maturity: `semantic-overlay-full`.
Language: yaml, Pack `omega-yaml`.

| entity_kind | key space |
|---|---|
| `Pipeline` | `ci:github:{path}` |
| `Job` | `ci:github:job:{path}:{job}` |
| `Step` | `ci:github:step:{path}:{job}:{offset}` |
| `Action` | `ci:github:action:{ref}` |
| `ReusableWorkflow` | `ci:github:reusable-workflow:{ref}` |
| `Runner` | `ci:github:runner:{label}` |
| `Trigger` | `ci:github:trigger:{path}:{event}` |
| `JobOutput` | `ci:github:job-output:{path}:{job}:{name}` |
| `MatrixAxis` | `ci:github:matrix-axis:{path}:{job}:{axis}` |
| `JobContainer` | `ci:github:container:{path}:{job}` |
| `JobService` | `ci:github:service:{path}:{job}:{id}` |
| `EnvironmentBinding` | `ci:github:env:{path}[:{job}]:{name}` |
| `PermissionPolicy` | `ci:github:permission:{path}[:{job}]:{scope}` |
| `WorkflowContractField` | `ci:github:contract:{path}:{event}:{section}:{name}` |

Relations: `contains`, `contains_step`, `needs`, `uses`, `runs_on`,
`configured_by`.

## The two history layers

The file has been rewritten twice and the two passes fixed different things.

**Wave 1** found 34 rules and 0 live: 32 matched `structured.entry` and 2
matched `value.document`, neither of which any Pack emits; all 32 read the old
generator's per-depth ancestry fields (`a0`…`a4`, `parent_key`,
`grandparent_key`, `item_key`, `sequence_key`) and required an attribute `role`;
and all 32 carried the path glob `.github/workflows/*.{yml,yaml}`, whose brace is
a literal byte to `glob_here` (`overlay.rs:1125`), so they could never have fired
even against the Packs they were written for. 11 of the 34 emitted a `JobSetting`
per job-level key whose whole content was the key's own name. That pass produced
14 rules, all live.

**This pass** is about the 14, all of which matched. What follows is what was
wrong with them.

## What was wrong with it

**14 rules, 14 live, and three defects the audit cannot see.**

1. **Five hand-written exclusion lists standing in for "the enclosing job".**
   8 of the 14 rules found the job by joining `within` a `definition.config_key`
   and then ruling out every intermediate key name GitHub fixes:
   `field_not_in definition.name` appeared **7 times with 24 excluded names** —
   `["steps","with","strategy","matrix","include","exclude","defaults"]`,
   `["strategy","matrix","include","exclude"]`, `["steps","with"]`,
   `["outputs"]`, `["needs"]`, `["include","exclude"]`, and the seven
   `workflow_call` descriptor names. Each list was a bet that every level between
   a key and its job carries a name GitHub chose, and the bet was wrong three
   ways: a job legally named `steps` or `matrix` was silently dropped; a
   `workflow_call` input literally named `type` or `default` was never stated;
   and `services.<id>` broke the idiom outright, because a service id is
   user-chosen and cannot be excluded by name — so `github.service` attributed a
   redis container to the *workflow file* rather than to the job that starts it,
   and the old document recorded that as an unfixable "Still to decide".

   None of it was needed. `definition.container` — the host's innermost enclosing
   definition, computed from spans before the program runs (contract §2) — names
   the immediate owner. **A job is a `definition.config_key` whose
   `definition.container` is `jobs`:** one clause, exact, no list. Measured on a
   workflow: `build` at 251-564 has ancestors `document`, `jobs`; innermost is
   `jobs`. All five lists are gone, `field_not_in` drops from 7 uses to 3, and
   `fact_join_by_span` from 24 uses to 17 **across 7 more rules**.

2. **The value was write-only, and is not any more.** The previous pass wrote a
   "A field only the Pack can supply" section arguing that `omega-yaml` published
   a scalar key's value only in `attributes`, that `OverlayFact::field` never
   consults `attributes`, and that `attribute_equals` against one literal
   constant was therefore the whole of what the overlay could do with it. **That
   request has landed.** `omega-yaml`'s `scalar_pair` template now publishes
   `value` in `fields` as well, measured:

       497-522  definition.config_key  name=uses  value=String("actions/checkout@v4")

   The two rules that had bent around it — `github.permission.write` and
   `github.permission.write-all`, the file's only two `attribute_equals` clauses
   — could see the single literal `write` and were blind to `read`, `none` and
   `read-all`. They are replaced by rules that state the access level whatever it
   is. And **nine answers the old document listed as lost are back**: which
   action a step runs, which reusable workflow a job calls, what runner a job
   asks for, `needs:` and `on:` in their bare-scalar spellings, an env var's
   value, a job output's expression, and the image of a job container and of a
   service container.

3. **`Pipeline` was minted from the key `jobs`.** Every relation in the file
   except `needs` and `contains_step` is sourced at `ci:github:{path}`, and that
   key existed only if the file had a top-level `jobs:` key — so a reusable
   workflow fragment or a malformed workflow lost its `Trigger`, `permissions`
   and `workflow_call` edges to a dangling end. `github.workflow` now enters from
   **`definition.config_document`**, the fact `omega-yaml` added this wave, so
   every workflow file has a `Pipeline` and every end resolves.

**The n² join this wave went looking for is not in this file.**
`fact_join_by_field` occurs **0 times** in the version this pass replaced; all
24 joins were already `fact_join_by_span`. There is no `current_field: path` →
`join_field: path` pair to fix. A `.github/workflows/*.yml` is also a single
YAML document in practice, so `definition.config_document` buys correctness at
the `Pipeline` rule rather than de-duplication: measured on a two-document file,
the two `config_document` facts render the same key `ci:github:{path}` and
intern to **one** `Pipeline`, and the three jobs across the two documents come
out as three `Job` entities, not nine.

**14 rules became 21.** The seven added rules are the second spelling of a
construct the file already stated (`needs:`/`on:` as scalars, a trigger list),
or an answer the `value` field made reachable for the first time (`Action`,
`ReusableWorkflow`, `Runner`, job-level `env`). Every one of them is named in
the table below with the question it answers.

## What it states now

`ci:github:{path}` is the workflow; `ci:github:job:{path}:{job}` is the job.
Everything else hangs off one of those two.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which files are workflows | `definition.config_document` under `**/.github/workflows/*.y*ml` | `Pipeline` `ci:github:{path}` |
| which jobs a workflow declares | `definition.config_key` with `definition.container` = `jobs` | `Job`; `contains` `Pipeline` → `Job` |
| what a job depends on, `needs: [a, b]` | `relation.data` with container `needs`, + job join | `needs` `Job` → `Job` |
| …written `needs: a` | `config_key` named `needs` with a `value`, + job join | `needs` `Job` → `Job` |
| **what runner a job asks for** | `config_key` named `runs-on` with a `value`, + job join | `Runner` `ci:github:runner:{value}`; `runs_on` `Job` → `Runner` |
| **which reusable workflow a job calls** | `config_key` named `uses`, container not `steps`/`with`, with a `value`, + job join | `ReusableWorkflow` `ci:github:reusable-workflow:{value}`; `uses` `Job` → it |
| which steps a job has, and where | `config_key` named `uses`/`run` with container `steps`, + job join | `Step` keyed by `{source.start}`; `contains_step` `Job` → `Step` |
| **which action a step runs** | the same fact, with a `value` | `Action` `ci:github:action:{value}`; `uses` `Step` → `Action` |
| what a job publishes downstream | `config_key` with container `outputs` and a `value`, + job join | `JobOutput`, attribute `expression`; `configured_by` `Job` → it |
| what a job fans out over | `config_key` with container `matrix`, minus `include`/`exclude`, + job join | `MatrixAxis`; `configured_by` `Job` → it |
| **which image a job runs in** | `config_key` named `image` with container `container` and a `value`, + job join | `JobContainer`, attribute `image`; `configured_by` `Job` → it |
| **which service containers a job needs** | `config_key` named `image` joined `within` a key whose container is `services`, + job join | `JobService` `ci:github:service:{path}:{job}:{id}`, attribute `image`; `configured_by` `Job` → it |
| which env vars a workflow sets | `config_key` with container `env`, whose `env` key has container `document` | `EnvironmentBinding` `ci:github:env:{path}:{name}`, attribute `value`; `configured_by` `Pipeline` → it |
| which env vars a job sets | the same, with the `env` key's container not `document`/`steps`/`with`/`inputs`/`secrets`/`outputs`, + job join | `EnvironmentBinding` `ci:github:env:{path}:{job}:{name}`; `configured_by` `Job` → it |
| **which token scopes a workflow asks for, and at what level** | `config_key` with container `permissions`, whose `permissions` key has container `document` | `PermissionPolicy`, attributes `scope` and `access`; `configured_by` `Pipeline` → it |
| …the same for one job | the same, + job join | `PermissionPolicy` `ci:github:permission:{path}:{job}:{scope}` |
| …or wholesale, `permissions: write-all` | `config_key` named `permissions` with container `document` and a `value` | `PermissionPolicy` `ci:github:permission:{path}:all`, `access` = the value |
| what starts a workflow, `on: {push: …}` | `config_key` whose name is one of 35 GitHub events and whose container is `on` | `Trigger`; `configured_by` `Pipeline` → it |
| …`on: [push, pull_request]` | `relation.data` with the same name set and container `on` | the same `Trigger` key |
| …`on: push` | `config_key` named `on`, container `document`, `value` in the event set | the same `Trigger` key |
| what a reusable workflow takes and returns | `config_key` with container `inputs`/`secrets`/`outputs`, joined `within` a key named `workflow_call`/`workflow_dispatch` | `WorkflowContractField`; `configured_by` `Pipeline` → it |

Questions the graph now answers across files, which is the point of keying
`Action`, `ReusableWorkflow` and `Runner` on the value rather than on the path:
*every workflow in this repository that runs `actions/checkout@v4`*, *every job
that asks for a self-hosted runner*, *every caller of
`org/repo/.github/workflows/release.yml@v2`*.

### Reachability check

Every canonical key a relation addresses is minted by a rule in this file, under
**one** entity kind (`key_collisions.py` reports 0):

| addressed key | minted by | conditions match |
|---|---|---|
| `ci:github:{path}` | `github.workflow` | every workflow file has a document |
| `ci:github:job:{path}:{job}` | `github.job` | every addressing rule binds `job` with the identical clause `definition.container = jobs` |
| `ci:github:step:{path}:{job}:{source.start}` | `github.job.step` | `github.job.step.action`'s match is `github.job.step`'s with `name = uses` and `value` present — a strict subset, so the Step always exists |

`Action`, `ReusableWorkflow`, `Runner`, `Trigger`, `MatrixAxis`, `JobOutput`,
`JobContainer`, `JobService`, `EnvironmentBinding`, `PermissionPolicy` and
`WorkflowContractField` are each the `current` of the rule that relates them, so
they cannot dangle.

No attribute can drop an entity (contract §3b): every `field_ref` is a built-in
(`path`, `path.stem`, `source.start`, `definition.name`, `definition.container`),
a bound join's field, or `value` under a `field_present value` clause in the same
rule's match.

### Verification of this pass

    python pack-design/overlay_audit.py github-action
    omega-framework-github-action: 21 overlay rules, 2 detection rules -- 21 live, 0 cannot match

    python pack-design/key_collisions.py github-action
    0 entity outputs are overwritten by a same-key rule that sorts first

    cargo run --release -j 6 -p omega-runtime --example validate_external_assets -- <assets>
    asset validation passed

Rule firing was measured by replaying `dump_call_emissions` output for
`omega-yaml` through the clauses this file uses, on a full workflow (jobs,
matrix, services, container, `workflow_call` contract, permissions, env, two
steps) and on a two-document file exercising the scalar spellings of `on:`,
`needs:` and `permissions:`. Every rule fired on the input it is written for,
no join bound more than one candidate, and no entity was dropped for an
unresolvable attribute.

## A field only the Pack can supply

**None.** The one request this document carried — `omega-yaml` publishing a
scalar key's `value` as a field rather than only as an attribute — has been
granted, and this pass is largely the consequence. The previous text is kept
below only as the record of what it cost while it was outstanding, and is no
longer a claim about the Pack:

> `github.job.step` mints a `Step` located by `{source.start}` with only its
> form; the moment `value` is a field, that same rule keys the step by the
> action ref and a `uses` relation to an `Action` entity becomes one line.

It became two lines. `github.job.step.action` is that rule.

## Still to decide

1. **A step-level `env:` block is not stated.** A job's `env` key and a step's
   `env` key are told apart by the container of the `env` key itself — the job
   id for one, `steps` for the other — so `github.job.env` excludes `steps` and
   nothing claims the step's bindings. Stating them needs a `Step` to hang them
   on, and the step's identity is its byte offset, which the `env` key does not
   carry. A `fact_join_by_span` meaning *the nearest enclosing fact of this kind*
   would give it directly; that is a host change, not a Pack field.
2. **`Step` is still keyed by `{source.start}`.** Nothing in a workflow names a
   step uniquely — `name:` is optional and free text — so the byte offset is the
   only identity available, and it changes when the file is edited above the
   step. It is stable enough for navigation and for the `uses` edge to the
   `Action`, and no cross-file question keys on it.
3. **`run: |` states a script and not its text.** `omega-yaml` deliberately does
   not carry a block scalar as a value (its coverage note: *a name is not a place
   to put a whole file*), which is right, so `run` steps are `Step` nodes with
   `form = run` and nothing else. Whether the shell commands a workflow runs
   deserve their own fact is an `omega-yaml` question, not this Framework's.
4. **A job named `env`, `permissions`, `matrix`, `steps` or `outputs`** is still
   a job, and `github.job` states it correctly — but the three rules that read
   `definition.container` against those literals would then read the job's own
   name as a section header. The exclusion lists that used to guard this are gone
   and the remaining exposure is the container literals a rule tests
   (`env`, `permissions`, `matrix`, `outputs`, `steps`, `on`, `services`,
   `container`, `inputs`, `secrets`) rather than 24 excluded names; it is stated
   rather than hidden.
5. **`runs-on: [self-hosted, linux]` states no runner.** A sequence-valued
   `runs-on` carries no scalar value; the list form could be read from
   `relation.data` with container `runs-on`, which would mint one `Runner` per
   label. Left out because a label set is not a runner and two `Runner` nodes
   would misrepresent one machine.
