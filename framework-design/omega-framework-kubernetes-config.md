# omega-framework-kubernetes-config

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**35 overlay rules, 16 detection rules. 35 live, 0 cannot match.** It replaces
153 rules of which 0 could match.

Selector: `framework:kubernetes-config`. Maturity: `semantic-overlay-full`.
Host languages: yaml, json. The only Pack that carries these manifests is
`omega-yaml`.

### What `omega-yaml` emits, which is the whole of what a rule can match

| kind | name | attributes | span |
|---|---|---|---|
| `definition.config_key` | the mapping key | `value`, when the value is a scalar | the whole pair |
| `definition.config_key` | the mapping key | — (a key set to a map, a sequence or a block scalar) | the whole pair |
| `relation.data` | the scalar itself | — | the sequence element |
| `definition.anchor` / `reference.anchor` / `reference.tag` / `definition.tag_shorthand` | the anchor, alias or tag name | — | the node |

There is no document fact, no mapping fact, no sequence-item fact and no
ancestry field. A key nested under another key lies inside that key's span, so
`fact_join_by_span` with `within` and `same_path` is how this overlay reaches
`spec.template.spec.containers` and every other path it used to spell out in a
field.

## What was wrong with it

- **All 153 rules were dead.** Every one of them was keyed to a fact kind no
  Pack emits: 30 distinct kinds across the file, 144 rules entering on 29
  spellings of `data.yaml_document_*_context` and 9 on `structured.entry`. The old
  omega-yaml published one pattern per shape of ancestry
  (`..._depth3_named_sequence_item_field_context`) with the ancestor keys in
  `a0`…`a3`; that whole family is gone, and with it every field the overlay
  read: `doc_kind`, `doc_name`, `doc_namespace`, `key`, `value`, `a0`…`a3`,
  `sequence_key`, `owner_key`, `owner_name`, `nested1_key`, `nested2_key` and
  eight more. 20 field names, none of them published by any Pack today.
- **The file was written twice.** 51 rules existed only as the `.unspecified`
  half of an `.explicit` / `.unspecified` pair, because the old Pack had a
  separate kind for a document with a `metadata.namespace` and one without. One Pack fact now covers both,
  and the namespace is not a fact the overlay can read at all (below), so the
  pairing is not just redundant, it is unstateable.
- **It restated Kubernetes' own schema rather than answering questions.** 41
  `configured_by` and 22 `contains` relations dressed up leaf scalars as
  entities — `ContainerField` (16 rules), `CRDVersionField` (8),
  `ServicePortField`, `ScaleTargetField`, `PermissionField`, `SelectorField`
  (2 each): entity kinds whose canonical key was the key name they were read
  from and whose only relation pointed back at the document they came from. `served:
  true` under a CRD version is not a fact an agent asks the graph for; it is the
  YAML re-emitted.
- **Its identity model cannot be rebuilt.** 106 of the 153 rules rendered
  `{doc_name}` — the object's `metadata.name` — into a canonical key or a
  relation end, across 55 entity kinds. The value of a scalar key is now
  an *attribute*, and an attribute is testable (`attribute_equals`) but never
  renderable into a canonical key. So those 106 rules are not portable at
  all; what replaces them keys on the path and the declared kind.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are Kubernetes manifests | `definition.config_key` named `apiVersion` | entity `KubernetesManifest` `k8s:manifest:{path}` |
| where the Deployment / Service / Ingress / CRD / Role … is declared (26 kinds, one rule each) | `definition.config_key` named `kind` with `value` = that kind, in a file that also has an `apiVersion` key | entity `KubernetesObject` `k8s:object:{path}:<Kind>`, relation `contains` from the manifest |
| which keys a ConfigMap provides, and where `nginx.conf` is defined | a `definition.config_key` inside the span of the key `data`, in a file declaring `kind: ConfigMap` | entity `ConfigKey` `k8s:config-key:ConfigMap:{path}:{key}`, relation `contains` from `k8s:object:{path}:ConfigMap` |
| which keys a Secret provides (`data`, `stringData`) | the same, against `kind: Secret` | entity `ConfigKey` `k8s:config-key:Secret:…`, relation `contains` |
| which manifests set a given label, and which labels a project uses | `definition.config_key` inside the span of `labels`, itself inside `metadata` | entity `LabelKey` `k8s:label:{key}`, relation `has_label` from the manifest |
| the same for annotations (`kubernetes.io/ingress.class`, `argocd.argoproj.io/*`) | `definition.config_key` inside `annotations` inside `metadata` | entity `AnnotationKey`, relation `has_annotation` |
| which API resources an RBAC role grants access to | `relation.data` (a sequence scalar) inside `resources` inside `rules` | entity `ApiResource` `k8s:rbac:resource:{name}`, relation `grants` from the manifest |
| which verbs it grants | `relation.data` inside `verbs` inside `rules` | entity `Verb` `k8s:rbac:verb:{name}`, relation `grants` |
| which hostnames the cluster terminates TLS for | `relation.data` inside `hosts` inside `tls`, in a file declaring `kind: Ingress` | entity `IngressHost` `k8s:host:{name}`, relation `serves` from `k8s:object:{path}:Ingress` |

Every rule reaches its context with `fact_join_by_span` `within` + `same_path`,
or with `fact_join_by_field` on the built-in `path` for "somewhere else in this
same document". No rule reads a published field: the only names it uses are
`definition.name` and `path`, both of which any fact answers, and the one
attribute `omega-yaml` publishes, `value`.

26 of the 35 rules are the per-kind rules, and they are near-identical on
purpose: `attribute_equals` compares against one constant, so naming 26 kinds
costs 26 rules. They collapse to one the moment the Pack publishes `value` as a
field.

## A field only the Pack can supply

**Pack `omega-yaml`, kind `definition.config_key`, field `value`.**

`omega-yaml` already computes the scalar value of a key and publishes it as the
*attribute* `value`. `OverlayFact::field` (overlay.rs:56) resolves fields and
the built-in names; it does not fall back to attributes, and neither
`render` nor `evaluate_attributes` nor `fact_join_by_field` ever reads an
attribute. An attribute can only be compared to a literal constant by
`attribute_equals`. So for a Kubernetes manifest the overlay can ask *is this
`kind: Deployment`* but can never learn:

- `metadata.name` — the object's identity, and the key every relation in the old
  file was keyed on;
- `metadata.namespace`;
- `spec.template.spec.containers[].image` — which image a workload runs;
- `spec.selector.matchLabels.*` values — which pods a Service selects;
- `configMap.name` / `secret.name` / `claimName` in a volume,
  `serviceAccountName`, `storageClassName`, `roleRef.name`, an HPA's
  `scaleTargetRef.name`, an Ingress backend's `service.name` — i.e. every
  reference from one Kubernetes object to another.

Neither of the first two options in the brief reaches it. `definition.name` is
the *key* (`image`), not the value; `path`, `path.dir`, `path.stem` describe the
file. `fact_join_by_span` relates a fact to the facts around it but carries no
value across, and `fact_join_by_field` compares fields, which is exactly what
the value is not. This is not a new byte on any emission — the Pack emits the
same text today as an attribute; the ask is that it also be a field, or that the
host flatten attributes into the field namespace on read.

With that one field, this overlay regains object identity
(`k8s:object:{value}`), the workload→image, workload→ConfigMap,
workload→Secret, Service→workload, RoleBinding→Role and Ingress→Service
relations, and the 26 per-kind rules become one.

## Still to decide

- **A file is not a document.** A path is the only identity the overlay has, and
  a manifest file commonly holds several `---`-separated documents. A same-file
  join (`fact_join_by_field` on `path`) therefore relates a data key to *a*
  ConfigMap in that file rather than to the one document it belongs to, and a
  file holding both a ConfigMap and a Secret makes both `k8s.configmap.data-key`
  and `k8s.secret.data-key` fire for the same key. Span joins are exact; only
  the same-file joins carry this. The exact form needs a document fact from the
  Pack (span of one `---` document), which is a bigger ask than the `value`
  field and is not made here.
- **`enclosing.qname` is real at runtime but not auditable.**
  `facts_of_surface` (overlay.rs:1200) synthesizes `definition.qname`,
  `enclosing.qname` and `definition.container` on every fact from the enclosing
  definitions' spans — for YAML that is the dotted key path,
  `spec.template.spec.containers.image`, which is precisely what `a0`…`a3` used
  to publish. A rule could match `field_prefix definition.qname
  "spec.template.spec.containers."` in one clause instead of chaining `within`
  joins. `overlay_audit.py`'s `BUILTIN` set does not list those three names, so
  such a rule would be counted dead by the audit although the host resolves it.
  This overlay uses span joins and stays auditable; the gap belongs in
  `00-INDEX.md`, not in one framework.
- **`apiGroups`** is reachable the same way `resources` is, but its commonest
  value is the empty string (the core group), which renders an empty canonical
  key. Left out rather than emitted as `k8s:rbac:api-group:`.
