# omega-framework-kubernetes-config

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

153 overlay rules, 16 detection rules. **0 can match, 153 cannot.**

Selector: `framework:kubernetes-config`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Container` | 16 |
| `ContainerField` | 16 |
| `Resource` | 9 |
| `ProbeConfiguration` | 9 |
| `CRDName` | 8 |
| `CRDVersionField` | 8 |
| `Workload` | 6 |
| `CRDProperty` | 6 |
| `Image` | 4 |
| `SecretReference` | 4 |
| `Config` | 2 |
| `KubernetesObject` | 2 |
| `Namespace` | 2 |
| `CustomResourceDefinition` | 2 |
| `Ingress` | 2 |
| `IngressClass` | 2 |
| `PersistentVolumeClaim` | 2 |
| `PersistentVolume` | 2 |
| `Role` | 2 |
| `ClusterRole` | 2 |
| `RoleBinding` | 2 |
| `ClusterRoleBinding` | 2 |
| `NetworkPolicy` | 2 |
| `HorizontalPodAutoscaler` | 2 |
| `PodDisruptionBudget` | 2 |
| `StorageClass` | 2 |
| `PriorityClass` | 2 |
| `ResourceQuota` | 2 |
| `LimitRange` | 2 |
| `Gateway` | 2 |
| `HTTPRoute` | 2 |
| `Label` | 2 |
| `Annotation` | 2 |
| `EnvironmentVariable` | 2 |
| `ContainerPortField` | 2 |
| `EnvironmentSource` | 2 |
| `VolumeMountField` | 2 |
| `ConfigMapReference` | 2 |
| `PersistentVolumeClaimReference` | 2 |
| `ServicePortField` | 2 |
| `IngressHost` | 2 |
| `ServiceAccountReference` | 2 |
| `StorageClassReference` | 2 |
| `PersistentVolumeReference` | 2 |
| `ScaleTargetField` | 2 |
| `SelectorField` | 2 |
| `PermissionField` | 2 |
| `SubjectReference` | 2 |
| `RoleReference` | 2 |
| `EnvironmentReference` | 2 |
| `EnvironmentSourceReference` | 2 |
| `VolumeSourceReference` | 2 |
| `ServiceAccount` | 1 |
| `Service` | 1 |
| `BackendReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 41 |
| `references` | 24 |
| `contains` | 22 |
| `uses_image` | 4 |
| `selects` | 3 |
| `has_label` | 2 |
| `has_annotation` | 2 |
| `in_namespace` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 27 | **no** |
| `data.yaml_document_identity_context` | 25 | **no** |
| `data.yaml_document_identity_no_namespace_context` | 21 | **no** |
| `data.yaml_document_depth2_context` | 9 | **no** |
| `data.yaml_document_named_mapping2_context` | 9 | **no** |
| `data.yaml_document_no_namespace_depth2_context` | 8 | **no** |
| `data.yaml_document_depth1_context` | 7 | **no** |
| `data.yaml_document_no_namespace_depth1_context` | 7 | **no** |
| `data.yaml_document_depth1_sequence_item_field_context` | 6 | **no** |
| `data.yaml_document_no_namespace_depth1_sequence_item_field_context` | 6 | **no** |
| `data.yaml_document_depth3_sequence_nested_context` | 5 | **no** |
| `data.yaml_document_depth3_named_sequence_item_field_context` | 5 | **no** |
| `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context` | 5 | **no** |
| `data.yaml_document_depth1_named_sequence_item_field_context` | 5 | **no** |
| `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context` | 5 | **no** |
| `data.yaml_document_depth3_nested_sequence_item_field_context` | 3 | **no** |
| `data.yaml_document_no_namespace_depth3_nested_sequence_item_field_context` | 3 | **no** |
| `data.yaml_document_no_namespace_depth3_sequence_nested_context` | 3 | **no** |
| `data.yaml_document_top_sequence_item_field_context` | 2 | **no** |
| `data.yaml_document_no_namespace_top_sequence_item_field_context` | 2 | **no** |
| `data.yaml_document_named_nested2_context` | 2 | **no** |
| `data.yaml_document_named_nested_sequence_mapping_context` | 2 | **no** |
| `data.yaml_document_named_projected_sequence_context` | 2 | **no** |
| `data.yaml_document_depth3_context` | 1 | **no** |
| `data.yaml_document_depth4_context` | 1 | **no** |
| `data.yaml_document_depth3_nested_named_sequence_item_field_context` | 1 | **no** |
| `data.yaml_document_no_namespace_depth3_nested_named_sequence_item_field_context` | 1 | **no** |
| `data.yaml_document_depth3_sequence_item_field_context` | 1 | **no** |
| `data.yaml_document_no_namespace_depth3_sequence_item_field_context` | 1 | **no** |
| `data.yaml_document_nested_route_backend_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x584, `field_present` x203, `fact_kind` x153, `field_in` x78, `attribute_equals` x27, `(join)` x23, `fact_join_by_owner` x18, `fact_join_by_field` x5.

Fields read: `doc_kind`, `key`, `value`, `a0`, `a1`, `doc_name`, `sequence_key`, `a2`, `owner_name_key`, `owner_name`, `outer_sequence_key`, `nested1_key`, `nested2_key`, `parent_key`, `kind_key`, `owner_key`, `nested_sequence_key`, `metadata_key`, `name_key`, `inner_sequence_key`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `k8s.serviceaccount.entity` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name`, `kind_key`, `metadata_key`, `name_key` |
| `k8s.workload.serviceaccount` | kind `data.yaml_document_depth3_context`, `data.yaml_document_identity_context`; field `a0`, `a1`, `a2`, `doc_kind`, `doc_name`, `key`, `kind_key`, `value` |
| `k8s.service.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.deployment.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.statefulset.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.daemonset.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.job.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.cronjob.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.pod.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.configmap.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.secret.entity` | kind `structured.entry`; field `key`, `parent_key`, `value`; attribute `role` |
| `k8s.service.selects.workload.explicit-namespace` | kind `data.yaml_document_depth2_context`, `data.yaml_document_depth4_context`; field `a0`, `a1`, `a2`, `a3`, `doc_kind`, `doc_name`, `doc_namespace`, `key`, `kind_key`, `metadata_key`, `name_key`, `namespace_key`, `value` |
| `k8s.workload.volume.configmap` | kind `data.yaml_document_depth3_sequence_nested_context`, `data.yaml_document_identity_context`; field `a0`, `a1`, `a2`, `doc_kind`, `doc_name`, `doc_namespace`, `key`, `kind_key`, `metadata_key`, `name_key`, `namespace_key`, `owner_key`, `sequence_key`, `value` |
| `k8s.workload.volume.secret` | kind `data.yaml_document_depth3_sequence_nested_context`, `data.yaml_document_identity_context`; field `a0`, `a1`, `a2`, `doc_kind`, `doc_name`, `doc_namespace`, `key`, `kind_key`, `metadata_key`, `name_key`, `namespace_key`, `owner_key`, `sequence_key`, `value` |
| `k8s.object.any.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.namespace.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.customresourcedefinition.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.ingress.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.ingressclass.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.persistentvolumeclaim.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.persistentvolume.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.role.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.clusterrole.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.rolebinding.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.clusterrolebinding.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.networkpolicy.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.horizontalpodautoscaler.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.poddisruptionbudget.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.storageclass.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.priorityclass.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.resourcequota.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.limitrange.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.gateway.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.httproute.identity.explicit` | kind `data.yaml_document_identity_context`; field `doc_kind`, `doc_name` |
| `k8s.object.namespace-membership.explicit` | kind `data.yaml_document_identity_context`, `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name`, `doc_namespace` |
| `k8s.object.any.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.namespace.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.customresourcedefinition.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.ingress.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.ingressclass.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.persistentvolumeclaim.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.persistentvolume.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.role.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.clusterrole.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.rolebinding.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.clusterrolebinding.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.networkpolicy.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.horizontalpodautoscaler.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.poddisruptionbudget.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.storageclass.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.priorityclass.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.resourcequota.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.limitrange.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.gateway.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.httproute.identity.unspecified` | kind `data.yaml_document_identity_no_namespace_context`; field `doc_kind`, `doc_name` |
| `k8s.metadata.labels.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `key`, `value` |
| `k8s.metadata.annotations.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `key`, `value` |
| `k8s.metadata.labels.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `key`, `value` |
| `k8s.metadata.annotations.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `key`, `value` |
| `k8s.crd.spec-group.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.spec-scope.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.spec-conversion.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.spec-group.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.spec-scope.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.spec-conversion.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-kind.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-plural.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-singular.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-listKind.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-kind.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-plural.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-singular.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.names-listKind.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.crd.version-name.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-served.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-storage.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-deprecated.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-name.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-served.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-storage.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.crd.version-deprecated.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.container.image.workload-explicit` | kind `data.yaml_document_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.imagePullPolicy.workload-explicit` | kind `data.yaml_document_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.command.workload-explicit` | kind `data.yaml_document_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.args.workload-explicit` | kind `data.yaml_document_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image-ref.workload-explicit` | kind `data.yaml_document_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image.workload-unspecified` | kind `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.imagePullPolicy.workload-unspecified` | kind `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.command.workload-unspecified` | kind `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.args.workload-unspecified` | kind `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image-ref.workload-unspecified` | kind `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image.pod-explicit` | kind `data.yaml_document_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.imagePullPolicy.pod-explicit` | kind `data.yaml_document_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.command.pod-explicit` | kind `data.yaml_document_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.args.pod-explicit` | kind `data.yaml_document_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image-ref.pod-explicit` | kind `data.yaml_document_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image.pod-unspecified` | kind `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.imagePullPolicy.pod-unspecified` | kind `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.command.pod-unspecified` | kind `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.args.pod-unspecified` | kind `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.image-ref.pod-unspecified` | kind `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `owner_name`, `owner_name_key`, `sequence_key`, `value` |
| `k8s.container.env-value.explicit` | kind `data.yaml_document_depth3_nested_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_name`, `inner_name_key`, `key`, `nested_sequence_key`, `outer_name`, `outer_name_key`, `outer_sequence_key`, `value` |
| `k8s.container.env-value.unspecified` | kind `data.yaml_document_no_namespace_depth3_nested_named_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_name`, `inner_name_key`, `key`, `nested_sequence_key`, `outer_name`, `outer_name_key`, `outer_sequence_key`, `value` |
| `k8s.container.ports.explicit` | kind `data.yaml_document_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.container.envFrom.explicit` | kind `data.yaml_document_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.container.volumeMounts.explicit` | kind `data.yaml_document_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.container.ports.unspecified` | kind `data.yaml_document_no_namespace_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.container.envFrom.unspecified` | kind `data.yaml_document_no_namespace_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.container.volumeMounts.unspecified` | kind `data.yaml_document_no_namespace_depth3_nested_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `nested_sequence_key`, `outer_sequence_key`, `owner_name`, `owner_name_key`, `value` |
| `k8s.volume.configMap.explicit` | kind `data.yaml_document_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.volume.secret.explicit` | kind `data.yaml_document_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.volume.persistentVolumeClaim.explicit` | kind `data.yaml_document_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.volume.configMap.unspecified` | kind `data.yaml_document_no_namespace_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.volume.secret.unspecified` | kind `data.yaml_document_no_namespace_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.volume.persistentVolumeClaim.unspecified` | kind `data.yaml_document_no_namespace_depth3_sequence_nested_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `owner_key`, `sequence_key`, `value` |
| `k8s.image-pull-secret.explicit` | kind `data.yaml_document_depth3_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.image-pull-secret.unspecified` | kind `data.yaml_document_no_namespace_depth3_sequence_item_field_context`; field `a0`, `a1`, `a2`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.service.port.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.ingress.host.explicit` | kind `data.yaml_document_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.service.port.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.ingress.host.unspecified` | kind `data.yaml_document_no_namespace_depth1_sequence_item_field_context`; field `a0`, `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.pod.serviceAccountName.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.persistentvolumeclaim.storageClassName.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.persistentvolumeclaim.volumeName.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.pod.serviceAccountName.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.persistentvolumeclaim.storageClassName.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.persistentvolumeclaim.volumeName.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.hpa.scale-target.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.networkpolicy.selector.explicit` | kind `data.yaml_document_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.hpa.scale-target.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.networkpolicy.selector.unspecified` | kind `data.yaml_document_no_namespace_depth2_context`; field `a0`, `a1`, `doc_kind`, `key`, `value` |
| `k8s.rbac.rule-field.explicit` | kind `data.yaml_document_top_sequence_item_field_context`; field `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.rbac.subject-field.explicit` | kind `data.yaml_document_top_sequence_item_field_context`; field `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.rbac.rule-field.unspecified` | kind `data.yaml_document_no_namespace_top_sequence_item_field_context`; field `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.rbac.subject-field.unspecified` | kind `data.yaml_document_no_namespace_top_sequence_item_field_context`; field `doc_kind`, `key`, `sequence_key`, `value` |
| `k8s.rbac.role-ref.explicit` | kind `data.yaml_document_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.rbac.role-ref.unspecified` | kind `data.yaml_document_no_namespace_depth1_context`; field `a0`, `doc_kind`, `key`, `value` |
| `k8s.env.valueFrom.configMapKeyRef` | kind `data.yaml_document_named_nested2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.env.valueFrom.secretKeyRef` | kind `data.yaml_document_named_nested2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.envFrom.name.configMapRef` | kind `data.yaml_document_named_nested_sequence_mapping_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `outer_sequence_key`, `value` |
| `k8s.envFrom.name.secretRef` | kind `data.yaml_document_named_nested_sequence_mapping_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `outer_sequence_key`, `value` |
| `k8s.probe.livenessProbe.httpGet` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.livenessProbe.tcpSocket` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.livenessProbe.exec` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.readinessProbe.httpGet` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.readinessProbe.tcpSocket` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.readinessProbe.exec` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.startupProbe.httpGet` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.startupProbe.tcpSocket` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.probe.startupProbe.exec` | kind `data.yaml_document_named_mapping2_context`; field `a0`, `a1`, `a2`, `doc_kind`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.projected.secret` | kind `data.yaml_document_named_projected_sequence_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.projected.configMap` | kind `data.yaml_document_named_projected_sequence_context`; field `a0`, `a1`, `a2`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `nested2_key`, `outer_sequence_key`, `value` |
| `k8s.ingress.backend-service` | kind `data.yaml_document_nested_route_backend_context`; field `a0`, `doc_kind`, `inner_sequence_key`, `key`, `nested1_key`, `nested2_key`, `nested3_key`, `outer_sequence_key`, `path_key`, `value` |

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
