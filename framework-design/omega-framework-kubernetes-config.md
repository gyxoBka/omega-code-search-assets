# omega-framework-kubernetes-config

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**25 overlay rules, 16 detection rules. 25 live, 0 cannot match.**
`key_collisions.py` reports nothing. It replaced a 35-rule file (itself a
rewrite of 153 rules of which 0 could match).

Selector: `framework:kubernetes-config`. Maturity: `semantic-overlay-full`.
Host languages: yaml, json. The only Pack that carries these manifests is
`omega-yaml`.

### What `omega-yaml` emits, which is the whole of what a rule can match

| kind | name | fields | span |
|---|---|---|---|
| `definition.config_key` | the mapping key | **`value`** — the scalar the key is set to, trimmed and unquoted (also published as an attribute of the same name) | the whole pair |
| `definition.config_key` | the mapping key | — (a key set to a map, a sequence, an alias or a block scalar) | the whole pair, covering its members |
| `relation.data` | the scalar itself | — | the sequence element |
| `definition.anchor` / `reference.anchor` / `reference.tag` / `definition.tag_shorthand` | the anchor, alias or tag name | — | the node |

Two things about that surface decide the whole file:

- **`value` is a field now.** It used to be an attribute only, which meant it
  could be compared to a constant and used for nothing else. It is a field, so
  it is a canonical key, a relation end, an entity attribute and a join key —
  measured with `dump_call_emissions` against `packs/omega-yaml`, which publishes
  it in both `fields` and `attributes` on the `scalar_pair` template.
- **The host's `enclosing.qname` / `definition.container` are the dotted key
  path.** A key set to a block spans its members, so the ancestor chain the host
  synthesizes (`overlay.rs:1200`) is exactly the YAML path: `image` under
  `spec.template.spec.containers` has `enclosing.qname =
  "spec.template.spec.containers"` and `definition.container = "containers"`,
  and a top-level key has neither, which is how `kind:` at the document root is
  told from `roleRef.kind` and `spec.names.kind`. All three names are in
  `overlay_audit.py`'s `BUILTIN` set, so rules using them audit correctly.

## What was wrong with it

The file it replaced was correct and fully live. It was also written against a
Pack surface that no longer holds, and it was small because of what it could not
reach, not because of what it chose to leave out.

- **26 of its 35 rules were one rule.** `k8s.object.Deployment`,
  `k8s.object.StatefulSet`, … `k8s.object.Namespace` differed only in one string
  literal, because `attribute_equals` compares against a single constant and the
  kind could not be *read*. They are now one rule matching `definition.config_key`
  named `kind` with `definition.qname` exactly `kind`, which also means the file
  covers every CRD instance (`kind: Certificate`, `kind: Application`) instead of
  a hand-written list of 26 built-in kinds.
- **No object had an identity.** All 35 rules keyed on the artifact path:
  `k8s:object:{path}:Deployment`. Two objects of the same kind in two files were
  two unrelated nodes, and *nothing* could cross a file. Every reference a
  Kubernetes repository is actually made of — a Deployment's image, its
  ConfigMap, its Secret, its ServiceAccount, its PVC; an Ingress's Service; a
  RoleBinding's Role; an HPA's scale target; a Service's pod selector — was
  absent, and the previous `.md` said so at length under "A field only the Pack
  can supply". That section is deleted: the field it asked for is published, and
  the eleven relations it listed as unreachable (`deployed_in`, `runs_image`,
  `uses` × 5, `binds`, `scales`, `routes_to`, `selects`) are all stated below.
- **One clause of guard had been written as two joins.** `k8s.metadata.label`
  chained `fact_join_by_span within labels` and `fact_join_by_span within
  metadata`, which says *a key somewhere under `labels` somewhere under
  `metadata`* — true of `spec.template.spec.containers[].env[].valueFrom` shapes
  it never meant. One `field_in enclosing.qname ["metadata.labels",
  "spec.template.metadata.labels"]` says what was meant, in one clause. The same
  substitution applies to the three ConfigMap/Secret rules, the annotation rule
  and the three RBAC and Ingress-host rules: all 13 `fact_join_by_span` clauses
  in the old file are replaced by 8 single `enclosing.qname` clauses.
- **`apiGroups` was deliberately dropped** on the ground that the core group is
  the empty string and would render an empty key. `field_present` requires a
  non-empty value, so the empty string is filtered and the rule is safe; it is
  back.
- **The `.explicit`/`.unspecified` pairing and the `LabelKey`-without-its-value
  model are gone.** A label is now the pair `k8s:label:app=web`, minted from both
  the `metadata.labels` side and the `spec.selector.matchLabels` side, so
  *which workload does this Service front* is a two-hop path through one node
  rather than a question the graph could not hold.
- **Three sentences in `coverage.gaps` and one whole `.md` section had outlived
  their measurement.** The claim that the scalar value "cannot be rendered into a
  canonical key" was true when written and is now false; the "Still to decide"
  note that a rule on `enclosing.qname` "would be counted dead by the audit"
  was true when written and is now false (`overlay_audit.py` lists all three
  synthesized names in `BUILTIN`). Both are deleted rather than qualified.

Net: 35 rules → 25, and the number of distinct questions answered goes from 9 to
23.

## What it states now

Every rule that needs the owning object reaches it with three same-file joins:
the top-level `apiVersion` (the manifest gate, carrying the same
`field_present value` condition as the rule that mints `k8s:manifest:{path}`),
the top-level `kind` bound as `k`, and `metadata.name` bound as `n`. The owner
key is therefore `k8s:object:{k.value}:{n.value}`, which is the same string
`k8s.object.declaration` mints as `k8s:object:{value}:{n.value}` under the same
conditions — the one entity kind `KubernetesObject` on that whole key space, per
brief 3g.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are Kubernetes manifests, and at what API version | `definition.config_key`, `definition.qname` = `apiVersion`, field `value` | entity `KubernetesManifest` `k8s:manifest:{path}` |
| which objects a repository declares, of any kind including CRD instances | `definition.config_key`, `definition.qname` = `kind`, field `value`, joined to `metadata.name` | entity `KubernetesObject` `k8s:object:{kind}:{name}`; relation `contains` from the manifest; relation `instance_of` to `KubernetesObjectKind` `k8s:object-kind:{kind}` |
| where every object of a given kind is declared | the same rule's third output | entity `KubernetesObjectKind`, addressed by `instance_of` |
| which namespace an object is declared in | `definition.qname` = `metadata.namespace`, field `value` | entity `KubernetesNamespace` `k8s:namespace:{value}`; relation `deployed_in` from the object |
| which keys a ConfigMap provides (`nginx.conf`, `application.yaml`) | a `definition.config_key` whose `enclosing.qname` is `data`, in a file whose top-level `kind` is `ConfigMap` | entity `ConfigKey` `k8s:config-key:ConfigMap:{name}:{key}`; relation `contains` from the ConfigMap object |
| which keys a Secret provides (`data`, `stringData`) | `enclosing.qname` in `data`/`stringData`, `kind: Secret` | entity `ConfigKey` `k8s:config-key:Secret:{name}:{key}`; relation `contains` |
| which objects carry a given label, and which pods a Deployment templates | `enclosing.qname` in `metadata.labels` / `spec.template.metadata.labels`, fields `definition.name` + `value` | entity `LabelPair` `k8s:label:{key}={value}`; relation `has_label` from the object |
| which pods a Service (or a NetworkPolicy, or a workload) selects — and so which workload a Service fronts | `enclosing.qname` in `spec.selector` / `spec.selector.matchLabels` / `spec.podSelector.matchLabels` | the **same** `LabelPair` key; relation `selects` from the object |
| which annotations an object carries (`kubernetes.io/ingress.class`, `argocd.argoproj.io/*`) | `enclosing.qname` in `metadata.annotations` / `spec.template.metadata.annotations` | entity `AnnotationKey` `k8s:annotation:{key}`; relation `has_annotation` |
| which API resources an RBAC role grants | `relation.data`, `enclosing.qname` = `rules.resources` | entity `ApiResource` `k8s:rbac:resource:{name}`; relation `grants` from the Role/ClusterRole |
| which verbs it grants | `relation.data`, `enclosing.qname` = `rules.verbs` | entity `Verb` `k8s:rbac:verb:{name}`; relation `grants` |
| which API groups it grants over | `relation.data`, `enclosing.qname` = `rules.apiGroups` | entity `ApiGroup` `k8s:rbac:api-group:{name}`; relation `grants` |
| which Role a RoleBinding binds, resolved across files | `definition.container` = `roleRef`, name `name`, field `value`, plus the sibling `roleRef.kind` bound as `rk` | relation `binds` from the RoleBinding to `KubernetesObject` `k8s:object:{rk.value}:{value}` |
| who a RoleBinding binds it to | `definition.container` = `subjects`, name `name`, field `value` | entity `RbacSubject` `k8s:rbac:subject:{value}`; relation `binds_subject` |
| which hostnames an Ingress terminates TLS for | `relation.data`, `enclosing.qname` = `spec.tls.hosts`, `kind: Ingress` | entity `IngressHost` `k8s:host:{name}`; relation `serves` |
| which hostnames it routes | `definition.name` = `host`, `enclosing.qname` = `spec.rules`, field `value` | the same `IngressHost` key space; relation `serves` |
| which Service an Ingress routes to | `definition.container` = `service`, name `name`, field `value`, `kind: Ingress` | relation `routes_to` to `KubernetesObject` `k8s:object:Service:{value}` |
| which image a workload runs, and everywhere an image is used | `definition.name` = `image`, `definition.container` in `containers`/`initContainers`/`ephemeralContainers`, field `value` | entity `ContainerImage` `k8s:image:{value}`; relation `runs_image` from the object |
| which ConfigMap a workload consumes | `definition.container` in `configMap`/`configMapRef`/`configMapKeyRef`, name `name` | relation `uses` to `k8s:object:ConfigMap:{value}` |
| which Secret it consumes, including an Ingress's TLS certificate | `definition.container` in `secret`/`secretRef`/`secretKeyRef`/`tls`, name `name` or `secretName` | relation `uses` to `k8s:object:Secret:{value}` |
| which PVC, StorageClass, ServiceAccount or IngressClass it uses | `claimName` under `persistentVolumeClaim`; `storageClassName`; `serviceAccountName`; `ingressClassName` — one rule each, field `value` | relation `uses` to `k8s:object:<Kind>:{value}` |
| what an autoscaler scales | `definition.container` = `scaleTargetRef`, name `name`, plus the sibling `scaleTargetRef.kind` bound as `rk` | relation `scales` to `k8s:object:{rk.value}:{value}` |
| which CRD defines a given custom kind | `definition.name` = `kind`, `enclosing.qname` = `spec.names`, `kind: CustomResourceDefinition` | entity `KubernetesObjectKind` `k8s:object-kind:{value}`; relation `defines` from the CRD object — and `instance_of` from every instance lands on the same key |

No rule reads a Pack field other than `value`. Everything else is
`definition.name`, `path`, `enclosing.qname`, `definition.qname` and
`definition.container`, all of which any fact answers.

Key spaces and kinds: `k8s:object:*` is `KubernetesObject` in all nine rules that
mint it, `k8s:object-kind:*` is `KubernetesObjectKind` in both, `k8s:label:*` is
`LabelPair` in both, `k8s:host:*` is `IngressHost` in both, and every attribute
bag on a shared key space is the same pair (`object_kind`, `object_name`), so it
does not matter which rule sorts first. `key_collisions.py` reports nothing.

## Still to decide

- **A file is still not a document.** This is now the file's one real defect and
  it got sharper, not softer: with identity keyed on `{kind}:{name}`, a
  multi-document file makes the `kind` ↔ `metadata.name` pairing a cross product,
  so a file holding a Deployment `web` and a Service `web-svc` also mints
  `k8s:object:Deployment:web-svc` and `k8s:object:Service:web`. Single-object
  files — the Kustomize convention and what every operator ships — are exact.
  Span joins (`enclosing.qname`, `definition.container`) are exact in every file.
  The fix is a Pack fact, below; it was not worth surrendering cross-file
  identity to avoid.
- **An RBAC subject keeps no kind.** `subjects:` is a sequence of mappings and
  omega-yaml emits no per-item fact, so joining the sibling `kind` of subject *n*
  would cross-produce across subjects in the same way. `RbacSubject` is keyed on
  the name alone and does not claim to be the ServiceAccount object of that name.
  A per-sequence-item fact would settle it; so would the document fact.
- **`spec.selector` for a Service versus `spec.selector.matchLabels` for a
  workload** are both in the selector rule's list. A Service's `spec.selector` has
  scalar children and a workload's does not, so the list costs nothing; it is
  listed rather than prefix-matched because there is no suffix clause and
  `field_prefix "spec.selector"` would also take `spec.selectorPolicy`.
- **Container-level identity is not modelled.** `k8s:image:{value}` answers
  *where is this image used*; *which named container in this pod* would need the
  sibling `name:` under `containers`, which is the same sequence-item problem as
  the RBAC subjects.

## A fact only the Pack can supply

**Pack `omega-yaml`, a document fact — kind `definition.document` or
`scope.document`, spanning one `---`-separated document, name empty.**

Its own coverage guard states the omission: *"Several documents separated by
`---` in one file are also not separated: their top-level keys are stated as
siblings."* Because of that, `apiVersion`, `kind` and `metadata` in document 2
are span-siblings of the same keys in document 1, and the only join that can
pair a `kind` with its `metadata.name` is `fact_join_by_field` on the built-in
`path` — which is the whole file.

Neither of the first two options in the brief reaches it. There is no derivable
name: `path`, `path.dir` and `path.stem` describe the file, and
`enclosing.qname` is empty for every top-level key in every document, by
construction. There is no join: `fact_join_by_span within` needs a fact whose
span contains the document's keys, and that fact is precisely what is missing.
A field on `definition.config_key` would not do either — a document *index* as a
field would work, but it is the same Pack change and a span is the cheaper and
more general one, since `fact_join_by_span within` then makes every rule in this
file document-exact with no further field reads.

This is not a byte on every emission: it is one extra emission per document,
which is one per file in the common case.

## Not asked for

`value` — the previous version of this document asked for it under this heading.
It is published as a field now, and that request is closed.
