# omega-framework-kubernetes-config

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind —
and, as this wave proves, by whether the *values* it compares against are still
the values the host computes.

## State

**24 overlay rules, 16 detection rules. 24 live, 0 cannot match.**
`key_collisions.py` reports nothing. It replaced a 25-rule file (itself a
rewrite of 35, itself a rewrite of 153).

Selector: `framework:kubernetes-config`. Maturity: `semantic-overlay-full`.
Host languages: yaml, json. The Pack that carries these manifests is
`omega-yaml`; `omega-json` reaches only the manifest rule, for the reason under
*Still to decide*.

### What `omega-yaml` emits, which is the whole of what a rule can match

| kind | name | fields | span |
|---|---|---|---|
| `definition.config_document` | `document` | — | one `---`-separated document, covering all of its keys |
| `definition.config_key` | the mapping key | **`value`** — the scalar the key is set to, trimmed and unquoted | the whole pair |
| `definition.config_key` | the mapping key | — (a key set to a map, a sequence, an alias or a block scalar) | the whole pair, covering its members |
| `relation.data` | the scalar itself | — | the sequence element |
| `definition.anchor` / `reference.anchor` / `reference.tag` / `definition.tag_shorthand` | the anchor, alias or tag name | — | the node |

Two things about that surface decide the whole file, and both are new since the
last rewrite:

- **`definition.config_document` is a document.** It is the fact the previous
  version of this document asked for under "A fact only the Pack can supply".
  That request is closed. A rule entered from it reaches the keys of *that*
  document — and of no sibling document — with `fact_join_by_span`
  `relation: "contains"`.
- **`document` is now the first element of every synthesized chain.** The host
  builds `enclosing.qname`, `definition.container` and `definition.qname` from
  every `definition.*` fact with a non-empty name whose span strictly contains
  the fact (`overlay.rs:1200-1249`). `definition.config_document` is named
  `document` and contains every key in its document, so in YAML a top-level
  `apiVersion` now has `definition.qname = "document.apiVersion"`,
  `definition.container = "document"`, and a label under `metadata` has
  `enclosing.qname = "document.metadata.labels"`. Measured with
  `dump_call_emissions` on a seven-document manifest; every dotted path in this
  file carries the prefix because of it. `omega-json` emits no document fact,
  so a JSON file's top-level keys carry no prefix — which is why the manifest
  rule reads `field_in definition.qname ["document.apiVersion", "apiVersion"]`
  and nothing else in the file tries to serve both.

## What was wrong with it

The file it replaced audited clean — 25 rules, 25 live, zero key collisions —
and stated nothing at all. Both halves of that were measurable and neither was
visible to `overlay_audit.py`.

- **All 25 rules were silently false.** Every one of them carried at least one
  clause comparing `definition.qname` or `enclosing.qname` to an unprefixed
  literal — 83 such clauses across the 25 rules, `"apiVersion"`, `"kind"`,
  `"metadata.name"`, `"data"`, `"rules.verbs"`, `"spec.names"` — and the host
  now computes `"document.apiVersion"`, `"document.kind"` and the rest. Run the
  old program over the two-document manifest below and it states **0 entities
  and 0 relations**; over a seven-document one, the same. The audit scored it
  25 live because every kind and every field it names still exists. This is the
  cost of a Pack adding one fact, and it is why a value literal is as much a
  measurement as a kind is.

- **73 `fact_join_by_field` clauses joined `path` to `path`, in 24 of the 25
  rules.** That is the whole file's owner model: *the kind of this object is
  whichever top-level `kind` is in this file*. `fact_join_by_field` pushes a
  binding for every matching candidate, so for a file holding a Deployment
  `web` and a Service `web-svc` it bound both kinds against both names.
  Measured, with the document fact suppressed to reproduce the Pack surface the
  file was written against: **4 `KubernetesObject` keys for a 2-document file**
  — `Deployment/web`, `Service/web-svc`, and the two that do not exist,
  `Deployment/web-svc` and `Service/web`. Every `uses`, `runs_image`, `binds`
  and `selects` edge in the file hung off one of those four indiscriminately.
  The same file under the rewrite states **exactly 2**, and every edge lands on
  the object whose document actually declares it.

- **Two rules were one rule.** `k8s.configmap.data-key` and
  `k8s.secret.data-key` differed only in the owner kind, which the old file
  could not read because it tested it with `field_equals ... "ConfigMap"` on a
  joined fact and then wrote the literal into the key. Bound as `k`, the kind
  is a field: one rule, `field_in ["ConfigMap", "Secret"]`, key
  `k8s:config-key:{k.value}:{n.value}:{t.definition.name}`.

- **The two remaining `fact_join_by_span within` guards were unnecessary.**
  `k8s.metadata.label` and `k8s.metadata.annotation` each chained
  `definition.container = labels` to a `within` join on a fact named
  `metadata`, which says *somewhere under some `metadata`* and was true of
  shapes under `spec.template.spec.containers[].env[]`. Both are now a single
  `field_in enclosing.qname` naming the two paths that are meant.

Net: 25 rules → 24, 73 path joins → 0, 93 `contains` joins across 23 rules, and
the file goes from stating nothing to stating 23 kinds of answer.

## What it states now

Twenty-three of the twenty-four rules are entered from
`definition.config_document` and open with the same three `contains` joins: the
document's `apiVersion` (unbound — the gate that says this document is a
Kubernetes object, and it carries the same `field_present value` condition as
the rule that mints `k8s:manifest:{path}`), its `kind` bound as `k`, and its
`metadata.name` bound as `n`. The owner key is therefore
`k8s:object:{k.value}:{n.value}` — one `KubernetesObject` kind on that whole
key space, per brief 3g — and every further key the rule needs is one more
`contains` join, bound as `t` (or `rk` for a sibling `kind`). Because the
current fact is the document, each of those bindings is a key of that document
and of no other; because a join pushes a binding per candidate, a pod with
three containers fires the image rule three times, once per image, which is
what is wanted.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are Kubernetes manifests, and at what API version | `definition.config_key`, `definition.qname` in `document.apiVersion`/`apiVersion`, field `value` | entity `KubernetesManifest` `k8s:manifest:{path}` |
| which objects a repository declares, of any kind including CRD instances | `definition.config_document` + `contains` `kind` and `metadata.name` | entity `KubernetesObject` `k8s:object:{kind}:{name}`; relation `contains` from the manifest; relation `instance_of` to `KubernetesObjectKind` `k8s:object-kind:{kind}` |
| where every object of a given kind is declared | the same rule's third output | entity `KubernetesObjectKind`, addressed by `instance_of` |
| which namespace an object is declared in | `contains` `document.metadata.namespace`, field `value` | entity `KubernetesNamespace` `k8s:namespace:{value}`; relation `deployed_in` from the object |
| which keys a ConfigMap or a Secret provides (`nginx.conf`, `tls.crt`) | `contains` a key whose `enclosing.qname` is `document.data` or `document.stringData`, in a document whose `kind` is `ConfigMap` or `Secret` | entity `ConfigKey` `k8s:config-key:{kind}:{name}:{key}`; relation `contains` from the object |
| which objects carry a given label, and which pods a Deployment templates | `contains` `enclosing.qname` in `document.metadata.labels` / `document.spec.template.metadata.labels`, name + `value` | entity `LabelPair` `k8s:label:{key}={value}`; relation `has_label` from the object |
| which pods a Service (or NetworkPolicy, or workload) selects — and so which workload a Service fronts | `contains` `enclosing.qname` in `document.spec.selector` / `document.spec.selector.matchLabels` / `document.spec.podSelector.matchLabels` | the **same** `LabelPair` key; relation `selects` from the object |
| which annotations an object carries (`kubernetes.io/ingress.class`, `argocd.argoproj.io/*`) | `contains` `enclosing.qname` in `document.metadata.annotations` / `document.spec.template.metadata.annotations` | entity `AnnotationKey` `k8s:annotation:{key}`; relation `has_annotation` |
| which API resources an RBAC role grants | `relation.data`, `enclosing.qname` = `document.rules.resources` | entity `ApiResource` `k8s:rbac:resource:{name}`; relation `grants` from the Role/ClusterRole |
| which verbs it grants | `relation.data`, `enclosing.qname` = `document.rules.verbs` | entity `Verb` `k8s:rbac:verb:{name}`; relation `grants` |
| which API groups it grants over | `relation.data`, `enclosing.qname` = `document.rules.apiGroups` | entity `ApiGroup` `k8s:rbac:api-group:{name}`; relation `grants` |
| which Role a RoleBinding binds, resolved across files | `contains` `document.roleRef.kind` as `rk` and `document.roleRef.name` as `t` | relation `binds` to `KubernetesObject` `k8s:object:{rk.value}:{t.value}` |
| who it binds it to | `contains` `document.subjects.name` | entity `RbacSubject` `k8s:rbac:subject:{value}`; relation `binds_subject` |
| which hostnames an Ingress terminates TLS for | `relation.data`, `enclosing.qname` = `document.spec.tls.hosts`, document `kind` = `Ingress` | entity `IngressHost` `k8s:host:{name}`; relation `serves` |
| which hostnames it routes | `contains` `document.spec.rules.host`, field `value` | the same `IngressHost` key space; relation `serves` |
| which Service an Ingress routes to | `contains` `definition.container` = `service`, name `name`, field `value`, document `kind` = `Ingress` | relation `routes_to` to `KubernetesObject` `k8s:object:Service:{value}` |
| which image a workload runs, and everywhere an image is used | `contains` name `image`, `definition.container` in `containers`/`initContainers`/`ephemeralContainers` | entity `ContainerImage` `k8s:image:{value}`; relation `runs_image` from the object |
| which ConfigMap a workload consumes | `contains` name `name`, container in `configMap`/`configMapRef`/`configMapKeyRef` | relation `uses` to `k8s:object:ConfigMap:{value}` |
| which Secret it consumes, including an Ingress's TLS certificate | `contains` name in `name`/`secretName`, container in `secret`/`secretRef`/`secretKeyRef`/`tls` | relation `uses` to `k8s:object:Secret:{value}` |
| which PVC, ServiceAccount, StorageClass or IngressClass it uses | `claimName` under `persistentVolumeClaim`; `serviceAccountName`; `storageClassName`; `ingressClassName` — one rule each | relation `uses` to `k8s:object:<Kind>:{value}` |
| what an autoscaler scales | `contains` `document.spec.scaleTargetRef.kind` as `rk` and `…ref.name` as `t` | relation `scales` to `k8s:object:{rk.value}:{t.value}` |
| which CRD defines a given custom kind | `contains` `document.spec.names.kind`, document `kind` = `CustomResourceDefinition` | entity `KubernetesObjectKind` `k8s:object-kind:{value}`; relation `defines` from the CRD object — and `instance_of` from every instance lands on the same key |

No rule reads a Pack field other than `value`. Everything else is
`definition.name`, `path`, `enclosing.qname`, `definition.qname` and
`definition.container`, all of which any fact answers.

Key spaces and kinds: `k8s:object:*` is `KubernetesObject` in all ten rules
that mint it and every one of them carries the same attribute pair
(`object_kind`, `object_name`); `k8s:object-kind:*` is `KubernetesObjectKind`
in both rules that mint it, `k8s:label:*` is `LabelPair` in both, `k8s:host:*`
is `IngressHost` in both. `key_collisions.py` reports nothing, and every
canonical key a relation addresses is minted by a rule in this file under the
same conditions.

### The measurement

`dump_call_emissions` over

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, labels: {app: web}}
spec: {template: {spec: {containers: [{name: app, image: nginx:1.25}]}}}
---
apiVersion: v1
kind: Service
metadata: {name: web-svc}
spec: {selector: {app: web}}
```

gives two `definition.config_document` facts, 0-175 and 176-266, each strictly
containing its own keys and none of the other's. Running the program over those
facts states exactly two `KubernetesObject` keys — `Deployment/web` and
`Service/web-svc` — with `runs_image` on the first and `selects` on the second.
The same program run with the document facts removed states four, which is the
defect this rewrite removes.

## Still to decide

- **A JSON manifest states only its file.** `omega-json` emits
  `definition.config_key` and `relation.data` but no document fact, so the
  twenty-three document-entered rules never fire on a `.json` manifest. A JSON
  file holds exactly one document, so the old `path`-join owner model was
  actually exact there — but writing a second family of twenty-three rules
  whose only difference is the missing `document.` prefix and a `path` join is
  not worth the file. It is recorded in `coverage.gaps`, and the cheap fix is a
  `definition.config_document` template on `omega-json` spanning the whole
  value — below.
- **An RBAC subject keeps no kind.** `subjects:` is a sequence of mappings and
  omega-yaml emits no per-sequence-item fact, so binding both
  `document.subjects.kind` and `document.subjects.name` would cross-produce
  across the subjects of one document in exactly the way the old file
  cross-produced across documents. `RbacSubject` is keyed on the name alone and
  does not claim to be the ServiceAccount object of that name. The same limit
  leaves a container unnamed: `k8s:image:{value}` answers *where is this image
  used*, and *which named container in this pod* would need the sibling `name:`
  under `containers`.
- **`spec.selector` for a Service versus `spec.selector.matchLabels` for a
  workload** are both in the selector rule's list. A Service's `spec.selector`
  has scalar children and a workload's does not, so the list costs nothing; it
  is listed rather than prefix-matched because there is no suffix clause and
  `field_prefix "document.spec.selector"` would also take
  `spec.selectorPolicy`.
- **`k8s.ingress.backend-service` keys on `definition.container = service`
  rather than on the full `document.spec.rules.http.paths.backend.service.name`
  chain.** The chain is exact for networking.k8s.io/v1 and wrong for every
  older spelling; the container test plus the `kind: Ingress` gate covers both
  and cannot reach outside an Ingress document.

## A field only the Pack can supply

**Pack `omega-json`, a document fact — kind `definition.config_document`,
spanning the whole JSON value, name `document`.**

`omega-yaml` publishes it and `omega-json` does not, so the two Packs disagree
about the shape of the same configuration file and a Framework over both cannot
write one rule. Neither of the first two options in the brief reaches it: there
is no derivable name (`path`, `path.dir` and `path.stem` describe the file) and
no join, because `fact_join_by_span` needs a fact spanning the document and
that fact is precisely what is missing. It costs one emission per file, and it
would make the rules in this file identical for JSON and YAML — the
`document.` prefix would then be present in both.

This is not blocking: Kubernetes manifests are written in YAML in practice, and
the detector reaches a JSON manifest either way.

## Not asked for

`value` on `definition.config_key`, and a document fact on `omega-yaml` — both
were asked for under this heading by earlier versions of this document, and
both are published now.
