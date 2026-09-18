# omega-framework-gitlab-ci

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

25 overlay rules, 2 detection rules. **25 can match, 0 cannot.**
`key_collisions.py gitlab-ci` reports nothing.

Selector: `framework:gitlab-ci`. Maturity: `semantic-overlay-full`.
Path glob `**/.gitlab-ci.y*ml` throughout. Pack: `omega-yaml` only.

### Entities it declares

| entity_kind | key template |
|---|---|
| `Pipeline` | `ci:gitlab:pipeline:{path}` |
| `Job` | `ci:gitlab:job:{path}:{name}` |
| `Stage` | `ci:gitlab:stage:{path}:{name}` |
| `Command` | `ci:gitlab:command:{path}:{job}:{phase}:{line}` |
| `ContainerImage` | `ci:gitlab:image:{value}` |
| `ServiceImage` | `ci:gitlab:service:{name}` |
| `Environment` | `ci:gitlab:environment:{value}` |
| `RunnerTag` | `ci:gitlab:runner-tag:{name}` |
| `ArtifactPath` | `ci:gitlab:artifact:{path}:{job}:{glob}` |
| `CachePath` | `ci:gitlab:cache:{path}:{job}:{glob}` |
| `IncludedFile` | `ci:gitlab:include:{value}` |
| `CiProject` | `ci:gitlab:project:{value}` |
| `CiVariable` | `ci:gitlab:variable:{path}:{name}` (pipeline scope) and `ci:gitlab:variable:{path}:{job}:{name}` (job scope) |

### Relations it declares

`caches`, `contains`, `defines`, `depends_on`, `deploys_to`, `extends`,
`includes`, `includes_from`, `needs`, `produces`, `requires_runner`, `runs`,
`runs_in`, `runs_in_image`, `triggers`, `uses_service`.

### Fact kinds it matches

| kind | rules entered from it | joined |
|---|---|---|
| `definition.config_key` | 15 | 25 (every join is a `definition.config_key` join) |
| `relation.data` | 10 | — |

Both are emitted by `omega-yaml`, which is the only Pack this Framework
declares.

---

## What was wrong with it

This overlay was rewritten once before, from 48 dead rules to 19 live ones. The
19 were live; three things about them were still wrong, and all three are
measurements that had gone stale or had never been taken.

### 1. The `value` field the file said did not exist now exists — 11 rules' worth

The previous pass wrote a 30-line section headed *"A field only the Pack can
supply"*, arguing that `omega-yaml` published a scalar key's value only in
`attributes`, where `attribute_equals` against a single literal is the only
thing that can read it. That was true when it was written. It is no longer
true. Measured today on a 55-line `.gitlab-ci.yml` with
`dump_call_emissions.exe packs/omega-yaml grammars/omega-yaml <file>`:

```
245-257  definition.config_key  name=stage    value=String("build")  ... value=String("build")
260-281  definition.config_key  name=image    value=String("node:20-alpine")  ... value=String("node:20-alpine")
284-298  definition.config_key  name=extends  value=String(".base")  ... value=String(".base")
```

The value is printed twice because `scalar_pair` now publishes it in **both**
`attributes` and `fields`. In `fields` it is an ordinary field: readable by
`field_present`, renderable in a canonical key, usable as a relation end.

The cost of the stale measurement, in rules:

| what the old file did | why |
|---|---|
| **five** rules `gitlab.job.stage.pre/.build/.test/.deploy/.post`, one `attribute_equals` each | the only way to read an attribute; `stage: integration` was silently unanswerable |
| stated **no** image at all | `image: node:20` was "unanswerable" |
| stated **no** environment at all | `environment: production` was "unanswerable" |
| stated `extends` only in its list form | `extends: .base`, the common spelling, was unanswerable |
| stated an include only in its bare-string form | `include: - local: /templates/base.yml` — the spelling GitLab's own docs use — was unanswerable |
| stated **no** downstream trigger | `trigger: project: group/deploy` was unanswerable |

Five rules collapse to one; six answers that did not exist are now stated by
ten rules.

### 2. A 55-word exclusion list stood in for "this key is top-level"

Every rule that needed *which job is this inside* bound the enclosing key with
`fact_join_by_span` / `within` / `field_not_in definition.name [55 GitLab
keywords]`. That list was doing two jobs at once: excluding GitLab's global
keys (`stages`, `default`, `include`, …) **and** excluding every nested
container key (`artifacts`, `rules`, `environment`, `changes`, `exclude`,
`forward`, …) that would otherwise be mistaken for a job. It is a blocklist, so
every GitLab keyword it did not list was a false job — `reports`, `matrix`,
`pre_get_sources_script` and every other nested key were one GitLab release
away from minting a `Job`.

The host already computes the exact fact that is wanted. `enclosing.qname` is
the chain of named `definition.*` facts whose spans contain this one
(`overlay.rs:1213-1249`), and `omega-yaml` now emits `definition.config_document`
spanning each document, named `document`. So a **top-level** key is exactly a
key whose `enclosing.qname` is the single word `document`. Measured:

```
0-66     definition.config_document  name=document     <- document 1
4-21     definition.config_key       name=stages       enclosing.qname = document
22-66    definition.config_key       name=web          enclosing.qname = document
29-41    definition.config_key       name=stage        enclosing.qname = document.web
67-116   definition.config_document  name=document     <- document 2
71-116   definition.config_key       name=svc          enclosing.qname = document
```

The job binding is now `enclosing.qname == "document"` plus an allowlist-shaped
exclusion of the **11** keys GitLab owns at the top level. 55 → 11, and the
test is now a statement of what a job *is* rather than a list of what it is
not.

### 3. A job-level variable was stated as a pipeline variable

`gitlab.variable` matched any `definition.config_key` inside any key named
`variables` and emitted `Pipeline defines CiVariable`. A job's own
`variables: NODE_ENV: production` is inside a key named `variables`, so it was
stated as a variable of the pipeline; and because both rules rendered the same
key `ci:gitlab:variable:{path}:{name}`, a job variable and a global variable of
the same name were **one entity**. *Where is `NODE_ENV` set* answered "at the
top of the file", which is wrong.

Both halves are fixed by the same clause as (2): `gitlab.variable` now requires
the `variables` key it joins to be top-level, and `gitlab.variable.job` keys its
entity under `ci:gitlab:variable:{path}:{job}:{name}`. The two rules are now
mutually exclusive and address two key spaces.

### What was checked and found already right

- **No `fact_join_by_field` anywhere in the file**, so the n² defect this wave
  hunts for — `current_field: path` joined to `join_field: path`, which binds
  every key of that name in the whole file — cannot occur here. Every join in
  this overlay is a `fact_join_by_span`, and a span join is inherently
  document-scoped: the measurement above shows document 1 spans 0-66 and
  document 2 spans 67-116, so no key of one document is ever inside a key of
  the other. A two-document pipeline file states exactly two jobs, `web` and
  `svc`, and no `Job web` in document 2.
- **`within` is the right direction here and `contains` is not.** This overlay
  is entered from a *member* (`stage:`, a script line, a tag) and reaches up to
  the job that owns it. Entering from `definition.config_document` and reaching
  down with `contains` would bind every key in the document and produce exactly
  the cross product `within` avoids. `config_document` earns its place in this
  file as the root of `enclosing.qname`, not as a join target.
- Every canonical key a relation addresses is minted by a rule in this file
  (checked mechanically: `addressed - minted` is empty).
- No key template carries more than one entity kind, which is why
  `key_collisions.py` reports nothing.

**19 rules → 25 rules, 25 live.** Entities 10 → 13, relations 12 → 16.

---

## What it states now

| what it answers | which Pack fact | what it emits |
|---|---|---|
| this file is a GitLab pipeline | `definition.config_key` named `stages`/`workflow`/`default`/`include`/`spec`, `enclosing.qname` = `document` | `Pipeline` |
| which jobs does this pipeline define | `definition.config_key` named by one of 34 job-only keywords, `within` a top-level non-global key | `Job`, `Pipeline contains Job` |
| which stages exist, in order | `relation.data` `within` the top-level `stages` key | `Stage`, `Pipeline contains Stage` |
| which stage does this job run in | `definition.config_key` `stage` with a `value`, `within` a job | `Stage`, `Job runs_in Stage` |
| what must finish before this job starts | `relation.data` `within` `needs`, `within` a job | `Job`, `Job needs Job` |
| whose artifacts does this job download | `relation.data` `within` `dependencies`, `within` a job | `Job`, `Job depends_on Job` |
| which template does this job inherit (list form) | `relation.data` `within` `extends`, `within` a job | `Job`, `Job extends Job` |
| which template does this job inherit (scalar form) | `definition.config_key` `extends` with a `value`, `within` a job | `Job`, `Job extends Job` |
| what does this job actually run | `relation.data` `within` `script`/`before_script`/`after_script`, `within` a job | `Command`, `Job runs Command` |
| which image does this job run in | `definition.config_key` `image` with a `value`, `within` a job | `ContainerImage`, `Job runs_in_image ContainerImage` |
| …written as `image: name: node:20` | `definition.config_key` `name` with a `value`, `within` `image`, `within` a job | the same |
| which image does the pipeline default to | `definition.config_key` `image` with a `value`, `within` the top-level `default` | `ContainerImage`, `Pipeline runs_in_image ContainerImage` |
| which environment does this job deploy to | `definition.config_key` `environment` with a `value`, `within` a job | `Environment`, `Job deploys_to Environment` |
| …written as `environment: name: staging` | `definition.config_key` `name` with a `value`, `within` `environment`, `within` a job | the same |
| which runner does this job need | `relation.data` `within` `tags`, `within` a job | `RunnerTag`, `Job requires_runner RunnerTag` |
| which service containers does this job run | `relation.data` `within` `services`, `within` a job | `ServiceImage`, `Job uses_service ServiceImage` |
| which job produces `dist/` | `relation.data` `within` `paths` `within` `artifacts` `within` a job | `ArtifactPath`, `Job produces ArtifactPath` |
| what does this job cache between runs | `relation.data` `within` `paths` `within` `cache` `within` a job | `CachePath`, `Job caches CachePath` |
| which other CI files does this pipeline pull in (bare string) | `relation.data` `within` the top-level `include` | `IncludedFile`, `Pipeline includes IncludedFile` |
| …written as `local:`/`file:`/`remote:`/`template:`/`component:` | `definition.config_key` so named with a `value`, `within` the top-level `include` | the same |
| which other projects does it pull CI from | `definition.config_key` `project` with a `value`, `within` the top-level `include` | `CiProject`, `Pipeline includes_from CiProject` |
| which downstream pipeline does this job start | `definition.config_key` `project` with a `value`, `within` `trigger`, `within` a job | `CiProject`, `Job triggers CiProject` |
| …written as `trigger: group/app` | `definition.config_key` `trigger` with a `value`, `within` a job | the same |
| where is global CI variable `X` set | `definition.config_key` `within` the top-level `variables` | `CiVariable`, `Pipeline defines CiVariable` |
| which job sets `X` | `definition.config_key` `within` a `variables` key, `within` a job | `CiVariable`, `Job defines CiVariable` |

### Why some keys carry no `{path}`

`ContainerImage`, `ServiceImage`, `Environment`, `RunnerTag` and `CiProject`
are keyed without the artifact path on purpose. *Which jobs run `node:20`*,
*which jobs need the `gpu` runner*, *what deploys to `production`* and *which
projects do we pull CI from* are repository questions, and these keys converge
across every `.gitlab-ci.yml` in the tree. `Pipeline`, `Job`, `Stage`,
`Command`, `ArtifactPath`, `CachePath` and `CiVariable` are file-scoped, because
two repositories' `build` jobs are not the same job.

`IncludedFile` is keyed on the target string with no path, so two pipeline files
that include the same template converge on one node — which is the point of
asking.

### Every relation end is minted

- `ci:gitlab:pipeline:{path}` — `gitlab.pipeline`, and again by every rule that
  sources a relation at it.
- `ci:gitlab:job:{path}:{job.definition.name}` — `gitlab.job`, which fires for
  any of the 34 job keywords; every rule that sources a relation there joins
  through one of those same keywords, so the `Job` always exists. Each such rule
  also re-mints it, under the same kind and the same key, so the end is minted
  by the rule that addresses it as well.
- `ci:gitlab:job:{path}:{definition.name}` and `…:{value}` — the *named* end of
  `needs`, `depends_on` and `extends`, which may be a job defined in an included
  file, is minted by the rule that names it. Hidden `.dot-prefixed` templates
  are minted as `Job` deliberately: excluding them, as the pre-2024 file did,
  left every `extends` pointing at nothing.
- `ci:gitlab:stage:{path}:…` — by `gitlab.stage` from the `stages:` list *and*
  by `gitlab.job.stage` from the job's own `stage:`, so a pipeline that omits
  `stages:` and relies on the defaults still has the stage entity its jobs point
  at.

`detection_rules` is untouched: two candidate-signature rows on `specifier` and
`name`, which is still true and is a different program.

## A field only the Pack can supply

**None.** The one entry this document carried — `omega-yaml`,
`definition.config_key`, the field `value` — has been granted: the `scalar_pair`
template now publishes `value` in `fields` as well as `attributes`, and the
eleven rules above are what it bought. The request is closed.

## Still to decide

1. **`enclosing.qname == "document"` is the whole load-bearing clause.** All
   twenty-five rules carry it, seven directly and eighteen inside the job
   binding, so every one of them depends on `omega-yaml` emitting
   `definition.config_document` and on its name being the literal `document`.
   That is one string in one Pack template, and if it is renamed the whole
   overlay stops matching in silence — `overlay_audit.py` cannot see a
   `field_equals` whose literal no longer occurs. The alternative is the
   55-word blocklist, which is wrong in a different and quieter way. The
   clause is kept, and this paragraph is the note to re-measure it: as of
   2026-09-18 `config.document` emits `name=document` for every document in a
   stream, verified on a two-document file.
2. **`Command` puts a shell line in a canonical key.**
   `ci:gitlab:command:…:npm run build` is long, and `resource_budget` caps
   `max_string_bytes` at 64 KiB per emission, so no single key can overflow.
   Block scalars (`script: |`) carry no value and are not emitted by omega-yaml
   at all, so only one-line sequence items arrive here. It earns its place —
   *which job runs `docker push`* is a real question and nothing else in the
   graph answers it — but it is the one rule whose output is closest to its
   input.
3. **`include: - project: g/a` and the `file:` beside it are two statements.**
   A YAML sequence item is not itself a fact, so there is nothing spanning one
   include entry to join on; the project and the file are both stated, and
   which file came from which project is not. Reaching it would need omega-yaml
   to emit a per-sequence-item fact, which is a Pack change that would cost
   every YAML file in every repository for one framework's benefit. Not
   requested.
4. **The glob** is `**/.gitlab-ci.y*ml`, which picks up the `.yaml` spelling and
   per-directory pipeline files. It does not reach `.gitlab/ci/*.yml`, which is
   a naming convention rather than a GitLab-recognised path; a file there is
   reached only through the `includes` relation.
