# omega-framework-jakarta-ee

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **0 can match, 20 cannot.**

Selector: `framework:jakarta-ee`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 7 |
| `Handler` | 7 |
| `MethodPolicy` | 4 |
| `Service` | 2 |
| `MediaContract` | 2 |
| `Controller` | 1 |
| `RouterGroup` | 1 |
| `InjectionPoint` | 1 |
| `Servlet` | 1 |
| `Filter` | 1 |
| `Listener` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 7 |
| `configured_by` | 5 |
| `guards` | 4 |
| `mounts` | 1 |
| `injects` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.java_package_method_marker_annotation_context` | 11 | **no** |
| `reference.java_package_method_direct_string_annotation_context` | 9 | **no** |
| `reference.java_package_class_direct_string_annotation_context` | 4 | **no** |
| `annotations.annotation_normal` | 2 | **no** |
| `reference.java_package_constructor_parameter_import_bound_type_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x34, `fact_kind` x20, `external_path_matches` x17, `field_equals` x9, `fact_join_by_span` x7, `(join)` x7.

Fields read: `annotation_name`, `package_name`, `class_name`, `argument_string`, `method_name`, `enclosing.qname`, `target_type_import_path`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `jakarta-ee.jaxrs.resource.mount` | kind `reference.java_package_class_direct_string_annotation_context`; field `argument_string`, `class_name`, `package_name` |
| `jakarta-ee.jaxrs.get.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.post.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.put.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.patch.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.delete.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.options.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.jaxrs.head.literal` | kind `reference.java_package_method_direct_string_annotation_context`, `reference.java_package_method_marker_annotation_context`; field `argument_string`, `class_name`, `method_name`, `package_name` |
| `jakarta-ee.service.cdi-context` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `jakarta-ee.service.jakarta-singleton` | kind `annotations.annotation_normal`; field `enclosing.qname` |
| `jakarta.constructor.di` | kind `reference.java_package_constructor_parameter_import_bound_type_context`; field `target_type_import_path` |
| `jakarta.servlet.webservlet` | kind `reference.java_package_class_direct_string_annotation_context`; field `annotation_name` |
| `jakarta.servlet.webfilter` | kind `reference.java_package_class_direct_string_annotation_context`; field `annotation_name` |
| `jakarta.servlet.weblistener` | kind `reference.java_package_class_direct_string_annotation_context`; field `annotation_name` |
| `jakarta.security.rolesallowed` | kind `reference.java_package_method_marker_annotation_context`; field `annotation_name` |
| `jakarta.security.permitall` | kind `reference.java_package_method_marker_annotation_context`; field `annotation_name` |
| `jakarta.security.denyall` | kind `reference.java_package_method_marker_annotation_context`; field `annotation_name` |
| `jakarta.security.transactional` | kind `reference.java_package_method_marker_annotation_context`; field `annotation_name` |
| `jakarta.media.produces` | kind `reference.java_package_method_direct_string_annotation_context`; field `annotation_name` |
| `jakarta.media.consumes` | kind `reference.java_package_method_direct_string_annotation_context`; field `annotation_name` |

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
