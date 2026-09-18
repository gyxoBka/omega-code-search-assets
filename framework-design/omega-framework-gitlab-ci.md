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

## What was wrong with it

**48 rules, 0 of which could match.** The whole file was keyed to the old
generator vocabulary:

| what it read | rules | why it is dead |
|---|---|---|
| kind `structured.entry` | 47 | no Pack emits it; yaml emits `definition.config_key` |
| kind `value.document` | 1 | no Pack emits it |
| attribute `role` (`yaml_top_level_pair`, `yaml_nested_pair`, `yaml_top_level_sequence_item`, …) | 47 | omega-yaml publishes no `role`; depth is the host's business now |
| fields `key`, `parent_key`, `owner_key`, `grandparent_key`, `sequence_key`, `item_key`, `item_value`, `value`, `a2` | 48 | the ancestor-key ladder the old Pack published one pattern per nesting depth; omega-yaml publishes none of them |

Beyond the dead kinds, the shape was wrong in three ways that the rewrite fixes
rather than ports:

1. **26 of 48 rules were one `JobSetting` per GitLab keyword** —
   `gitlab.job.config.stage`, `.image`, `.environment`, `.when`,
   `.allow_failure`, `.interruptible`, `.resource_group`, `.extends`,
   `.trigger`, `.retry`, and 15 `gitlab.job.nested.*` rules for
   `artifacts.name`, `artifacts.expire-in`, `cache.policy`,
   `environment.deployment-tier`, `release.tag-name` and the rest. Each minted
   an entity whose canonical key was the key it had just read and hung a
   `configured_by` off it. That restates the input: the graph learns that
   `.gitlab-ci.yml` contains a key spelled `expire_in`, which grepping the file
   already tells you. All 26 are gone.
2. **Three rules per include form and two per step form** — one for the scalar
   spelling, one for the sequence spelling, one for the mapping-in-sequence
   spelling. The nesting ladder is no longer a rule's problem, so the surviving
   spellings are one rule each.
3. **`gitlab.step.field` sourced `contains_step` at
   `ci:gitlab:job:{path}:{parent_key}`** with no rule constraining `parent_key`
   to a job — the dangling-key defect `00-INDEX.md` records against
   omega-framework-unity. Every relation end in the new file is minted by a
   rule in this file.

**48 rules -> 19 rules, 19 live.** Entity kinds 15 -> 10, relation kinds 5 ->
12: fewer things named, more things related.

### The one structural idea the rewrite turns on

omega-yaml emits `definition.config_key` for every mapping key, spanning the
whole pair, and `relation.data` for every scalar in a sequence. A nested key or
a sequence item therefore lies **inside** its parent key's span, so
`fact_join_by_span` with `within` walks up the document and needs no field on
either side.

GitLab CI has no `jobs:` heading — a job is a top-level key whose name GitLab
does not own. There is no "has no enclosing key" clause, so the file does not
try to recognise a job by what it is *not*. Instead every rule binds the
enclosing key that is **not a GitLab keyword** (`fact_join_by_span` /
`within` / `field_not_in definition.name [55 keywords]`, bound as `job`), and
that binding *is* the job. `workflow: rules: - when: always` binds nothing,
because every key enclosing `when` there is GitLab's own; `deploy: rules: -
when: manual` binds `deploy`. One clause, reused in 14 rules, replaces the
`a0`…`a2` ancestor ladder.

## What it states now

19 rules. Path glob `**/.gitlab-ci.y*ml` throughout.

| what it answers | which Pack fact | what it emits |
|---|---|---|
| this file is a GitLab pipeline | `definition.config_key` named `stages`/`workflow`/`default`/`include`/`spec` | entity `Pipeline` `ci:gitlab:pipeline:{path}` |
| which jobs does this pipeline define | `definition.config_key` named by one of 34 job-only keywords, `within` a non-keyword key | entity `Job`, relation `contains` Pipeline -> Job |
| which stages exist, in order | `relation.data` `within` the `stages` key | entity `Stage`, relation `contains` Pipeline -> Stage |
| which stage does this job run in (x5: `.pre`, `build`, `test`, `deploy`, `.post`) | `definition.config_key` named `stage` with attribute `value` equal to that stage, `within` a job | entity `Stage`, relation `runs_in` Job -> Stage |
| what must finish before this job starts | `relation.data` `within` `needs`, `within` a job | entity `Job` (the named one), relation `needs` Job -> Job |
| whose artifacts does this job download | `relation.data` `within` `dependencies`, `within` a job | entity `Job`, relation `depends_on` Job -> Job |
| which template does this job inherit | `relation.data` `within` `extends`, `within` a job | entity `Job`, relation `extends` Job -> Job |
| what does this job actually run | `relation.data` `within` `script`/`before_script`/`after_script`, `within` a job | entity `Command`, relation `runs` Job -> Command |
| which runner does this job need | `relation.data` `within` `tags`, `within` a job | entity `RunnerTag` (repo-wide key), relation `requires_runner` Job -> RunnerTag |
| which service containers does this job run | `relation.data` `within` `services`, `within` a job | entity `ServiceImage` (repo-wide key), relation `uses_service` Job -> ServiceImage |
| which job produces `dist/` | `relation.data` `within` `paths` `within` `artifacts` `within` a job | entity `ArtifactPath`, relation `produces` Job -> ArtifactPath |
| what does this job cache between runs | `relation.data` `within` `paths` `within` `cache` `within` a job | entity `CachePath`, relation `caches` Job -> CachePath |
| which other CI files does this pipeline pull in | `relation.data` `within` `include` | entity `IncludedFile`, relation `includes` Pipeline -> IncludedFile |
| where is CI variable `X` set | `definition.config_key` `within` a `variables` key | entity `CiVariable`, relation `defines` Pipeline -> CiVariable |
| which job sets it | the same, also `within` a job | relation `defines` Job -> CiVariable |

`RunnerTag` and `ServiceImage` are keyed without `{path}` on purpose: *which
jobs need the `gpu` runner* and *which jobs run `postgres:14`* are repository
questions, and the two keys converge across every `.gitlab-ci.yml` in the tree.

**Every relation end is minted.** `ci:gitlab:pipeline:{path}` is minted by
`gitlab.pipeline`, `gitlab.job`, `gitlab.stage`, `gitlab.include.file` and
`gitlab.variable`; `ci:gitlab:job:{path}:{job.definition.name}` by `gitlab.job`,
which fires for any job carrying any of the 34 keywords the other rules join
through, so a job that has `needs:` or `script:` is always already an entity;
`ci:gitlab:job:{path}:{definition.name}` (the *named* end of `needs`,
`depends_on` and `extends`, which may be a job defined in an included file) is
minted by the rule that names it; `ci:gitlab:stage:{path}:…` by `gitlab.stage`
**and** by each of the five `runs_in` rules, so a pipeline that omits `stages:`
and relies on the defaults still has the stage entity its jobs point at.
Hidden `.dot-prefixed` templates are minted as `Job` — the old file excluded
them with `field_not_prefix "."`, which left every `extends` pointing at
nothing.

`detection_rules` is untouched: two candidate-signature rows on `specifier` and
`name`, which is still true and is a different program.

## A field only the Pack can supply

**Pack `omega-yaml`, kind `definition.config_key`, value `value`: published as
an attribute, needed as a field.**

The `scalar_pair` template carries the key's scalar value, but it carries it in
`attributes`. `OverlayFact::field` (overlay.rs:56) resolves `fields` and a fixed
list of built-in names and never consults `attributes`; the only clause that
reads one is `attribute_equals`, against a single literal constant. So the value
can be tested for equality and used for nothing else — not as a canonical key,
not as a relation end, not as a join key.

Neither of the two cheaper options reaches it. It is not derivable: the
built-ins answer the key's *name* (`definition.name`), never the scalar to its
right. And no join reaches it either — `fact_join_by_span` relates the pair to
its ancestors, and `fact_join_by_field` would need the value already published
as a field to join on. The remedy is the same bytes in a different map: move
`value` from `attributes` to `fields` in the `scalar_pair` template. This is
the finding `00-INDEX.md` already records for omega-yaml and omega-json from
wave 1; this Framework is the sixth to hit it, and it costs more here than
anywhere else.

What it costs, concretely:

| question | the fact that holds the answer | state today |
|---|---|---|
| which stage does this job run in | `stage: integration` | only the five default stage names, one `attribute_equals` rule each |
| which image does this job run in | `image: node:20` | unanswerable |
| which environment does this job deploy to | `environment: production`, `environment: name: staging` | unanswerable |
| which template does this job extend | `extends: .base` (scalar form) | only the `extends: [.a, .b]` list form, which the Pack states as `relation.data` |
| which file does `include: - local: x.yml` pull in | `local: x.yml` | only the bare-string form `include: - x.yml` |
| which project/ref does `trigger:` start | `trigger: project: group/app` | unanswerable |

With `value` as a field, five of those six become one rule each and the five
`gitlab.job.stage.*` rules collapse into one.

## Still to decide

1. **The five stage rules are a bet on GitLab's defaults.** `.pre`, `build`,
   `test`, `deploy`, `.post` are what GitLab uses when `stages:` is absent and
   are what most authored pipelines name, so the five rules answer *which stage
   does this job run in* for the common case and answer nothing (rather than
   something wrong) for a custom stage name. The alternative — enumerating
   twenty guessed stage names — encodes a guess, and the alternative after that
   is to state nothing until the Pack publishes `value`. Kept as five, to be
   deleted in favour of one rule the day `value` is a field.
2. **`Command` puts a shell line in a canonical key.** `ci:gitlab:command:…:npm
   run build` is long, and the `resource_budget` caps `max_string_bytes` at
   64 KiB per emission, so no single key can overflow. Block scalars
   (`script: |`) are not emitted by omega-yaml at all, by design, so only
   one-line sequence items arrive here. It earns its place — *which job runs
   `docker push`* is a real question and nothing else in the graph answers it —
   but it is the one rule whose output is closest to its input.
3. **The glob was widened** from `.gitlab-ci.yml` to `**/.gitlab-ci.y*ml`, which
   picks up the `.yaml` spelling and per-directory pipeline files. It does not
   reach `.gitlab/ci/*.yml`, which is a naming convention rather than a
   GitLab-recognised path; a file there is reached only through the `includes`
   relation.
