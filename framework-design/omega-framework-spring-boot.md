# omega-framework-spring-boot

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

27 overlay rules, 4 detection rules. **0 can match, 27 cannot.**

Selector: `framework:spring-boot`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `SpringBean` | 3 |
| `Bean` | 3 |
| `Dependency` | 3 |
| `Route` | 2 |
| `Handler` | 2 |
| `Repository` | 2 |
| `SecuredMethod` | 2 |
| `SecurityRule` | 2 |
| `RoutePrefix` | 2 |
| `Controller` | 1 |
| `Service` | 1 |
| `Model` | 1 |
| `Component` | 1 |
| `Configuration` | 1 |
| `ConfigProperties` | 1 |
| `OrmRelation` | 1 |
| `ModelReference` | 1 |
| `BeanType` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `depends_on` | 4 |
| `injects` | 3 |
| `handles` | 2 |
| `uses_model` | 2 |
| `guards` | 2 |
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `annotations.annotation_normal` | 15 | **no** |
| `reference.java_package_method_direct_string_annotation_context` | 3 | **no** |
| `reference.java_package_annotated_field_import_bound_type_context` | 3 | **no** |
| `reference.java_package_method_named_string_annotation_context` | 3 | **no** |
| `reference.java_package_interface_import_bound_generic_supertype_context` | 2 | **no** |
| `reference.java_package_class_named_string_annotation_context` | 2 | **no** |
| `reference.kotlin_annotated_class_context` | 2 | **no** |
| `reference.java_package_method_marker_annotation_context` | 1 | **no** |
| `reference.java_package_constructor_parameter_import_bound_type_context` | 1 | **no** |
| `reference.java_package_class_direct_string_annotation_context` | 1 | **no** |
| `reference.kotlin_primary_constructor_parameter_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x51, `fact_kind` x27, `external_path_matches` x26, `field_in` x8, `fact_join_by_field` x7, `(join)` x7, `field_equals` x2.

Fields read: `enclosing.qname`, `package_name`, `class_name`, `method_name`, `argument_string`, `target_type_import_path`, `argument_name`, `owner_class`, `annotation_import_path`, `supertype_import_path`, `interface_name`, `annotation_name`, `first_type_argument_import_path`, `parameter_type`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `spring.controller` | kind `annotations.annotation_normal` |
| `spring.route.mapping` | kind `reference.java_package_method_direct_string_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `spring.service.repo` | kind `annotations.annotation_normal` |
| `spring.repository` | kind `annotations.annotation_normal` |
| `spring.jpa.entity` | kind `annotations.annotation_normal` |
| `spring.service.injected-repository` | kind `annotations.annotation_normal`, `reference.java_package_annotated_field_import_bound_type_context`; field `annotation_import_path`, `enclosing.qname`, `owner_class`, `package_name`, `target_type_import_path` |
| `spring.data.repository.interface` | kind `reference.java_package_interface_import_bound_generic_supertype_context`; field `interface_name`, `package_name`, `supertype_import_path` |
| `spring.data.repository.model` | kind `annotations.annotation_normal`, `reference.java_package_interface_import_bound_generic_supertype_context`; field `enclosing.qname`, `first_type_argument_import_path`, `interface_name`, `package_name`, `supertype_import_path` |
| `spring.route.mapping.named` | kind `reference.java_package_method_named_string_annotation_context`; field `argument_name`, `argument_string`, `class_name`, `method_name`, `package_name` |
| `spring.bean-owner.stereotype` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `spring.bean-owner.controller` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `spring.bean-owner.configuration` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `spring.component` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `spring.configuration` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `spring.configuration-properties` | kind `reference.java_package_class_named_string_annotation_context`; field `argument_name`, `argument_string` |
| `spring.bean.marker` | kind `reference.java_package_method_marker_annotation_context`; field `class_name`, `method_name`, `package_name` |
| `spring.bean.direct` | kind `reference.java_package_method_direct_string_annotation_context`; field `class_name`, `method_name`, `package_name` |
| `spring.bean.named` | kind `reference.java_package_method_named_string_annotation_context`; field `argument_name`, `class_name`, `method_name`, `package_name` |
| `spring.constructor-di` | kind `annotations.annotation_normal`, `reference.java_package_constructor_parameter_import_bound_type_context`; field `enclosing.qname`, `target_type_import_path` |
| `spring.field-di` | kind `annotations.annotation_normal`, `reference.java_package_annotated_field_import_bound_type_context`; field `annotation_import_path`, `enclosing.qname`, `target_type_import_path` |
| `spring.jpa.relation-field` | kind `annotations.annotation_normal`, `reference.java_package_annotated_field_import_bound_type_context`; field `enclosing.qname`, `target_type_import_path` |
| `spring.security.direct` | kind `reference.java_package_method_direct_string_annotation_context`; field `argument_string`, `method_name` |
| `spring.security.named` | kind `reference.java_package_method_named_string_annotation_context`; field `argument_string`, `method_name` |
| `spring.route.class-prefix.direct` | kind `reference.java_package_class_direct_string_annotation_context`; field `argument_string`, `class_name` |
| `spring.route.class-prefix.named` | kind `reference.java_package_class_named_string_annotation_context`; field `argument_name`, `argument_string`, `class_name` |
| `spring.kotlin.stereotype` | kind `reference.kotlin_annotated_class_context`; field `annotation_name`, `owner_class` |
| `spring.kotlin.constructor-di` | kind `reference.kotlin_annotated_class_context`, `reference.kotlin_primary_constructor_parameter_context`; field `annotation_name`, `owner_class`, `parameter_type` |

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
