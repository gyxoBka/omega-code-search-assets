# omega-framework-spring-boot

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

Rewritten. **12 overlay rules, 4 detection rules, all 12 live.** The record
below of what the file declared and why every one of its 27 rules was dead is
kept as the account of what was replaced.

Selector: `framework:spring-boot`. Maturity: `semantic-overlay-full`.

### Entities the old file declared

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

### Relations the old file declared

| relation_kind | rules |
|---|---|
| `depends_on` | 4 |
| `injects` | 3 |
| `handles` | 2 |
| `uses_model` | 2 |
| `guards` | 2 |
| `configured_by` | 1 |

### Fact kinds the old file matched

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

## Why each old rule could not match

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

## What was wrong with it

Measured: **27 overlay rules, 0 live, 27 dead**. Now **12 rules, 12 live, 0 dead.**

Every one of the 27 was keyed to a kind no Pack emits. The file was written
against a generator vocabulary that spelled out, in the fact kind itself, the
whole shape the rule wanted:

| what the old file did | count | why it could not work |
|---|---|---|
| matched `annotations.annotation_normal` | 15 rules | the kind is `reference.annotation` now, and only omega-java emits it |
| matched a `reference.java_package_*_context` kind | 10 rules | six distinct kinds, each a Java-only spelling of "annotation, plus the method/class/interface/parameter it sits on, plus one argument" — none survives, and the join that gave the context is now the overlay's own `fact_join_by_span`/`within` |
| matched a `reference.kotlin_*_context` kind | 2 rules | the Kotlin spelling of the same thing; both collapse into the cross-language rules |
| read a Pack field | 27 rules, 14 distinct fields | `omega-java` and `omega-kotlin` publish **no field on any template at all**. `package_name`, `class_name`, `method_name`, `argument_string`, `argument_name`, `owner_class`, `annotation_name`, `annotation_import_path`, `target_type_import_path`, `supertype_import_path`, `interface_name`, `first_type_argument_import_path`, `parameter_type` and `enclosing.qname` are all unavailable. 51 `field_present` clauses tested for them. |
| carried an `external_path_matches` clause | 26 of 27 rules | `external` is set from `ExternalEnvironment`, which is built from `SurfaceBinding.target_hint`, which is `occurrence.qualifier`, which is read only from a Pack field or attribute literally named `qualifier`. omega-java and omega-kotlin publish none, so **no `external_path_matches` clause can ever match in a JVM project** — the same defect `OWED.md` item 7a records for JS/TS. Every gate on `package: org.springframework...` was a gate that never opened. |

Three further faults the audit does not see:

- **Per-language duplication.** `spring.route.mapping` / `spring.route.mapping.named`,
  `spring.bean.marker` / `spring.bean.direct` / `spring.bean.named`,
  `spring.security.direct` / `spring.security.named`,
  `spring.route.class-prefix.direct` / `.named`, and the two `spring.kotlin.*`
  rules were 12 rules distinguished only by *how the annotation was written*
  (marker, one positional string, one named argument) or *which language wrote
  it*. That is syntax, which §5 of the contract says is the Pack's job. They are
  now 3 rules.
- **Three rules restated their input.** `spring.bean-owner.stereotype`,
  `spring.bean-owner.controller` and `spring.bean-owner.configuration` each
  minted `spring:bean-owner:{enclosing.qname}` from an annotation's enclosing
  name, with no relation and no attribute beyond the name. Deleted.
- **Dangling ends.** `spring.service.injected-repository` emitted
  `injects` into `spring:repository:{target_type_import_path}`, a key no rule in
  the file ever minted; `spring.jpa.relation-field` emitted `uses_model` into
  `spring:model:{target_type_import_path}`, likewise. Every relation in the new
  file mints both of its ends.

## What it states now

12 rules. The Java arm is keyed to `reference.annotation`, which omega-java
emits for every annotation with the annotation's simple name as
`definition.name`; the class, method, constructor or parameter it decorates is
reached by `fact_join_by_span` / `within`, because a Java annotation lives
inside the `modifiers` of the declaration and therefore inside its `@decl.span`.
No rule reads a Pack field: everything is `definition.name`, `path` and a span.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which classes does Spring manage, and as what stereotype | `reference.annotation` in `@Component/@Service/@Repository/@Controller/@RestController/@Configuration/@ControllerAdvice/@RestControllerAdvice` + `within` `definition.class` | `SpringBean` `spring:bean:{class}` |
| which class boots the application | `reference.annotation` `@SpringBootApplication` + `within` `definition.class` | `SpringApplication`, `SpringBean`, `declares` |
| which methods answer HTTP, and with which verb | `reference.annotation` in the six `*Mapping` + `within` `definition.method` + `within` `definition.class` | `HttpHandler` `spring:handler:{class}.{method}`, `SpringBean`, `handles` bean → handler |
| which classes are persisted, and by which mapping | `reference.annotation` in `@Entity/@MappedSuperclass/@Embeddable/@Document/@RedisHash` + `within` `definition.class` | `Model` `spring:model:{class}` |
| which interfaces are Spring Data repositories, over which base | `relation.implements` named as one of 15 repository bases + `within` `definition.interface` | `Repository`, `SpringBean`, `declares` — cross-language: omega-kotlin emits both kinds too, so this one rule serves Java and Kotlin |
| which methods build a bean by hand, and which configuration declares them | `reference.annotation` `@Bean` + `within` `definition.method` + `within` `definition.class` | `BeanMethod`, `SpringBean`, `declares` bean → bean-method |
| which methods are access-controlled, and by which guard | `reference.annotation` in the 8 method-security annotations + `within` `definition.method` + `within` `definition.class` | `SecuredMethod`, `SpringBean`, `guards` secured-method → bean |
| what container behaviour is attached to a method (transaction, schedule, async, event/message listener, cache, lifecycle, MVC binding) | `reference.annotation` in 18 names + `within` `definition.method` + `within` `definition.class` | `MethodRole`, `SpringBean`, `declares` bean → method-role |
| which classes are bound to external configuration | `reference.annotation` `@ConfigurationProperties` + `within` `definition.class` | `ConfigProperties`, `SpringBean`, `configured_by` |
| what a Spring-managed class is injected with through its constructor | `reference.type` + `within` `definition.parameter` + `within` `definition.constructor` + `within` `definition.class`, gated by a `fact_join_by_field` on `path` to a stereotype `reference.annotation` in the same file | `SpringBean` for the owner, `SpringBean` for the dependency type, `injects` owner → dependency |
| which Kotlin classes Spring manages | `reference.type` in the 9 bean-marker names + `within` `definition.class`, `**/*.kt` | `SpringBean` (confidence `candidate`) |
| which Kotlin functions answer HTTP | `reference.type` in the six `*Mapping` + `within` `definition.function` + `within` `definition.class`, `**/*.kt` | `HttpHandler`, `SpringBean`, `handles` |

Canonical keys minted: `spring:bean:*`, `spring:application:*`,
`spring:handler:*`, `spring:model:*`, `spring:repository:*`,
`spring:bean-method:*`, `spring:secured:*`, `spring:method-role:*`,
`spring:config-properties:*`. Every relation end is one of these, and every rule
that addresses `spring:bean:{X}` also mints it, so no edge dangles.

Keys are the **simple** class name, not a qualified name. That is deliberate:
`enclosing.qname` and `definition.qname` are synthesised by the host
(`overlay.rs` `facts_of_surface`) but are not in `overlay_audit.py`'s built-in
set, and more importantly the only cross-file handle Java gives an overlay is
the simple name — `reference.type` for an injected dependency says `UserService`
and nothing more. Keying beans on the simple name is what makes the `injects`
edge from one file reach the `@Service` minted in another.

## A field only the Pack can supply

**omega-java, `reference.annotation`, an annotation-argument field.** Spring
puts the answer to *which path does this route serve* inside the annotation:
`@GetMapping("/orders/{id}")`, `@ConfigurationProperties(prefix = "app.mail")`,
`@Bean(name = "clock")`, `@PreAuthorize("hasRole('ADMIN')")`. omega-java's
queries.scm says so explicitly — "Its element values are deliberately not read
-- see the coverage guard". A built-in name cannot reach it (it is neither the
emission's name nor its path) and no join can: the argument is a string literal
that the Pack emits no fact for at all, so there is nothing on the other side of
a `fact_join_by_span` to bind. Without it Spring Boot has **no Route entity**;
the overlay can say *this method answers a GET on this controller* and not
*which URL*. This is the single largest gap in the framework, and the same field
would serve asp-net-core, nestjs, symfony and jax-rs.

**omega-java, `definition.field`, its span.** The template captures
`@decl.span` on the `variable_declarator`, while `reference.annotation` spans
the whole annotation, which is a sibling of the declarator under
`field_declaration`. So `@Autowired private UserRepository repo;` has an
annotation that is *not* within the field's span, and `fact_join_by_span`
cannot relate them in either direction. Field injection, `@Value`, `@Id`,
`@Column` and every JPA association (`@OneToMany`, `@ManyToOne`,
`@JoinColumn`) are therefore unstatable. This is exactly the omega-c-sharp
`definition.field` finding in wave 1, in a second Pack: spanning the
declaration on `field_declaration` (or emitting the modifiers span) would fix
both. No field is needed — only the span.

**omega-java / omega-kotlin, `qualifier`.** Neither Pack publishes a field or
attribute named `qualifier`, so `ExternalEnvironment` is empty for every JVM
artifact and `external.package` / `external.member` are always absent. The old
file's 26 `external_path_matches` clauses were the whole of its precision. This
is `OWED.md` item 7a widened: it is not a JS/TS problem, it is every Pack that
does not publish `qualifier`, and for Java the value is already in the source —
`import org.springframework.stereotype.Service;` states it exactly.

**omega-java, `relation.implements`, a type-argument field.** `JpaRepository<User, Long>`
names the aggregate root in its first type argument. The Pack emits
`relation.implements` with name `JpaRepository`, and emits `User` as a separate
`reference.type` *within the same interface declaration* — but so is `Long`, and
so is every other type the interface mentions, and the overlay has no way to say
"the first one". So *which model does this repository manage* is unanswerable
and no `Repository -> Model` relation is emitted.

## Still to decide

1. **The Kotlin stereotype rule is a guess by construction.** omega-kotlin has
   no annotation template: `(type_identifier) @type.reference` captures an
   annotation, a supertype, a declared type and a type argument alike. So
   `@Service class Foo` and `class Foo : Service` are the same fact to the
   overlay. The rule is shipped at confidence `candidate` on the ground that a
   user type named exactly `RestController`, `SpringBootApplication` or
   `ControllerAdvice` is far rarer than the annotation. If omega-kotlin ever
   gains a `reference.annotation` template, this rule and
   `spring.kotlin.http.handler` collapse into the Java ones and the Kotlin arm
   disappears.
2. **Kotlin primary-constructor injection is not stated.** The Java rule works
   because `definition.constructor` exists and separates a constructor parameter
   from a method parameter. Kotlin has no such kind — a primary-constructor
   parameter and a member-function parameter are both `definition.parameter`
   within `definition.class` — and the overlay has no "not within" clause, so
   the rule would turn every method parameter type into an `injects` edge. It is
   left out rather than shipped noisy.
3. **The constructor-DI rule is gated at file granularity.** Its fifth clause is
   a `fact_join_by_field` on `path`, meaning "some class in this file carries a
   stereotype". One public top-level class per file is the Java convention, so
   this is nearly always exact; in a file with a `@Service` and a package-private
   helper, the helper's constructor parameters are also reported as injected.
   Tightening it needs the stereotype and the class to be joinable, which needs
   a join whose two sides are both *joined* facts — a clause the overlay does not
   have.
4. **`Model` emits no relation.** A JPA entity class is stated, but nothing
   links it to the repository that manages it or to the fields it maps, both for
   the Pack reasons above. It follows the shape `django.model.class` shipped
   with, and it is the rule that gains most if either Pack finding lands.
