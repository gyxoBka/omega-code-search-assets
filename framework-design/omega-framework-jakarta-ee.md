# omega-framework-jakarta-ee

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**20 overlay rules -> 12. 0 live -> 12 live, 0 cannot match.** 4 detection rules,
unchanged.

Selector: `framework:jakarta-ee`. Maturity: `semantic-overlay-full`.

The whole framework lives in one Pack, `omega-java`, which publishes **no field
on any of its 40 templates**. So the overlay has exactly four things to work
with: the fact kind, the fact's name, the artifact path, and the span. Every
rule below is built out of those.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Handler` | 4 |
| `Controller` | 2 |
| `Service` | 3 |
| `InjectionPoint` | 2 |
| `Route`, `RouteParameter`, `MethodPolicy`, `ScheduledTask` | 1 each |
| `Servlet`, `Filter`, `Listener`, `PersistentEntity` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `injects` | 2 |
| `handles` | 2 |
| `mounts`, `guards`, `configured_by` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.annotation` | 12 | yes (omega-java) |
| `definition.class` | 5 | yes |
| `definition.method` | 5 | yes |
| `scope.class_body` | 6 | yes |
| `definition.parameter` | 1 | yes |
| `definition.constructor` | 1 | yes |

Clause vocabulary in use: `fact_kind` x12, `field_in` x12, `fact_join_by_span`
x19. Fields read: `definition.name` and `path`, both built-ins. No Pack field is
demanded anywhere in the file.

## What was wrong with it

**All 20 rules were dead, and every one of them died the same way.** The file was
keyed to the pre-rewrite generator vocabulary, five kinds of it, none of which
any Pack emits:

| kind no Pack emits | rules |
|---|---|
| `reference.java_package_method_marker_annotation_context` | 11 |
| `reference.java_package_method_direct_string_annotation_context` | 9 |
| `reference.java_package_class_direct_string_annotation_context` | 4 |
| `annotations.annotation_normal` | 2 |
| `reference.java_package_constructor_parameter_import_bound_type_context` | 1 |

(The counts exceed 20 because seven rules matched one kind and joined another.)

Three more defects, each independent of the kind:

1. **Seven fields no Pack publishes.** `annotation_name`, `package_name`,
   `class_name`, `method_name`, `argument_string`, `enclosing.qname`,
   `target_type_import_path` — 34 `field_present` / `field_equals` clauses
   against them. omega-java publishes no field at all, so none of these would
   have resolved even if the kinds had survived.

2. **Seventeen `external_path_matches` clauses that cannot match.**
   `external` is populated only from a binding whose `target_hint` is set, and
   `target_hint` is `occurrence.qualifier` — a field literally named
   `qualifier`. omega-java publishes no fields, so **no Java fact carries an
   `external` at all** and every one of the 17 clauses failed regardless of what
   was written in it. All 17 are gone; the annotation is now recognised by its
   own name, in the simple and both fully-qualified spellings.

3. **Two self-loop relations.** `jakarta.servlet.webservlet` and the other
   servlet-family rules emitted `configured_by` from `current` to
   `jakarta:servlet:{package_name}.{class_name}:{argument_string}` — which is
   the key the same rule had just minted as its first (and only) entity. Per
   `overlay.rs` `emit()`, `Reference::Current` *is* that key, so the edge was
   `Servlet configured_by Servlet`. Deleted rather than ported.

**Eight rules were one construct spelled eight ways.** `jakarta-ee.jaxrs.get
.literal` through `…head.literal` were seven byte-identical rules differing only
in the HTTP verb in a `member:` clause and in a literal in the canonical key.
They are one rule now, `jakarta-ee.jaxrs.handler`, with a `field_in` over the
seven verbs and the verb read back out of `definition.name`. Likewise
`service.cdi-context` + `service.jakarta-singleton` -> one `cdi.bean`, and the
four `security.*` rules + `security.transactional` -> one `method.policy`.

**Two rules only restated their input and were deleted, not ported.**
`jakarta.media.produces` and `jakarta.media.consumes` minted a `MediaContract`
whose whole content was the media type string — and the media type is an
annotation *element value*, which omega-java deliberately does not read (see
below). Without it the entity would have said no more than "this method has a
`@Produces` on it", which is the fact it matched. `RouterGroup` went the same
way: its only content was the `@Path` literal.

**Net:** 20 -> 12 rules, 5 dead kinds -> 6 live ones, 7 unpublished fields -> 0,
17 unreachable `external` clauses -> 0, 2 self-loops -> 0. Three entity kinds
were retired (`RouterGroup`, `MediaContract`, and the string-valued form of
`Servlet`) and three added (`RouteParameter`, `PersistentEntity`,
`ScheduledTask`), the last two covering the two questions the old file never
asked: *which classes does the persistence unit map* and *what does the
container run on a timer*.

## What it states now

Every rule matches `reference.annotation` — the one thing omega-java emits for
an annotation — and reaches its subject with `fact_join_by_span` / `within`,
which works because omega-java spans a class, a method, a constructor and a
parameter on the *whole* declaration including its `(modifiers)`, so the
annotation node lies inside the thing it annotates.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which classes are REST resources? | `reference.annotation` `Path` **within** `definition.class` | `Controller` |
| Which method answers which HTTP verb, in which resource? | `reference.annotation` `GET`…`OPTIONS` **within** `definition.method` **within** `scope.class_body` | `Route` + `Handler` + `Controller`, `Route -handles-> Handler`, `Controller -mounts-> Route` |
| What does a handler read out of the request? | `reference.annotation` `PathParam`/`QueryParam`/… **within** `definition.parameter` **within** `definition.method` **within** `scope.class_body` | `RouteParameter` + `Handler`, `Handler -configured_by-> RouteParameter` |
| Which methods are access-controlled or transactional, and how? | `reference.annotation` `RolesAllowed`/`PermitAll`/`DenyAll`/`Transactional`/`Asynchronous`/`Lock`/`AccessTimeout` **within** `definition.method` **within** `scope.class_body` | `MethodPolicy` + `Handler`, `MethodPolicy -guards-> Handler` |
| Which classes are container-managed beans, and with what lifecycle? | `reference.annotation` `ApplicationScoped`/`RequestScoped`/`SessionScoped`/`ConversationScoped`/`Dependent`/`Named`/`Singleton`/`Stateless`/`Stateful`/`MessageDriven` **within** `definition.class` | `Service`, attribute `lifecycle` |
| Which beans take collaborators through a constructor? | `reference.annotation` `Inject` **within** `definition.constructor` **within** `scope.class_body` | `InjectionPoint` + `Service`, `Service -injects-> InjectionPoint` |
| …through a setter? | `reference.annotation` `Inject` **within** `definition.method` **within** `scope.class_body` | `InjectionPoint` + `Service`, `Service -injects-> InjectionPoint` |
| Which classes the servlet container registers, and as what? | `reference.annotation` `WebServlet` / `WebFilter` / `WebListener` **within** `definition.class` | `Servlet` / `Filter` / `Listener` (three rules, three entity kinds) |
| Which classes does the persistence unit map? | `reference.annotation` `Entity`/`MappedSuperclass`/`Embeddable` **within** `definition.class` | `PersistentEntity`, attribute `mapping` |
| What does the container run on a timer? | `reference.annotation` `Schedule`/`Schedules` **within** `definition.method` **within** `scope.class_body` | `ScheduledTask` + `Handler`, `ScheduledTask -handles-> Handler` |

### Every key this file mints, and every key it addresses

Checked per `FRAMEWORK-BRIEF.md` §3a, because the audit cannot see a dangling
relation.

Minted: `jakarta-ee:controller:…`, `:route:…`, `:handler:…`, `:param:…`,
`:policy:…`, `:service:…`, `:inject:…`, `:servlet:…`, `:filter:…`,
`:listener:…`, `:persistent-entity:…`, `:schedule:…`.

Addressed by a relation: `:route:`, `:handler:`, `:controller:`, `:param:`,
`:policy:`, `:service:`, `:inject:`, `:schedule:` — **every one of them minted
by the same rule that addresses it**, with the same clauses by construction. No
relation crosses a rule boundary, so the wave-2 "same key, different
conditions" failure cannot occur here. In particular `Handler` is minted by all
four rules that point at it (`jaxrs.handler`, `jaxrs.parameter`,
`method.policy`, `ejb.schedule`) under one template, so a `@RolesAllowed` on a
plain EJB method and a `@Schedule` on a timer both land on a `Handler` that
exists.

No relation uses `Reference::Current`; every end is an explicit
`by_canonical_key`, so the §3b "`current` is your first output" trap does not
apply. No attribute depends on `external.*` or on anything that can be absent —
each is either a constant or `definition.name` off a fact the match already
bound — so the §3b "unresolvable attribute drops the entity and keeps the
relation" trap does not apply either. No `path_glob` is used, so there is no
brace-glob clause.

## A field only the Pack can supply

**omega-java, every annotation, the annotation's element values.**
`packs/omega-java/queries.scm:220-223` captures only the annotation's *name*:

```scheme
[(marker_annotation name: [(identifier) (scoped_identifier)] @annotation.name)
 (annotation name: [(identifier) (scoped_identifier)] @annotation.name)] @annotation
```

and the file's own comment says "Its element values are deliberately not read --
see the coverage guard." That single decision is why this overlay can say *which
method serves GET* but not *at what URL*:

| lost answer | annotation | the element value |
|---|---|---|
| which URL a resource is mounted at | `@Path("/orders")` | the single unnamed value |
| which URL a servlet is mapped to | `@WebServlet("/upload")` | `value` / `urlPatterns` |
| which roles may call a method | `@RolesAllowed({"admin"})` | the array value |
| what a handler produces/consumes | `@Produces(APPLICATION_JSON)` | the value |
| which table backs a class | `@Table(name = "orders")` | `name` |
| when a timer fires | `@Schedule(hour = "*")` | the named elements |

Neither route reaches it. It is not one of the built-in names in
`OverlayFact::field`; `definition.name` is the annotation's own name, not its
argument. And `fact_join_by_span` cannot reach it either, because **the Pack
emits no fact at the element-value node at all** — there is nothing inside the
annotation's span to join to. A string literal in Java source is not published
under any kind. So the only route is a Pack field.

The minimal ask is one field on the existing annotation template:
`value` — the trimmed text of the annotation's argument list (or of its single
unnamed element), the same shape omega-yaml and omega-json were asked for on
`definition.config_key`. It must be a **field**, not an attribute, because the
overlay would use it as a canonical key and a relation end, and per
`00-INDEX.md` an attribute is write-only. This is a cost on every Java
annotation emission in every repository, which is why it is stated as a case and
not taken.

A second, smaller ask, for completeness rather than for a rule this file
currently wants: **omega-java `import.binding` publishes only the simple name**
(`queries.scm:184`, `@import.name` is the trailing `(identifier)` of the
`scoped_identifier`). So an overlay cannot tell `jakarta.ws.rs.Path` from any
other `Path`, and this file falls back on the detector having already
established that the project is Jakarta EE. The fix would be a `package` field
on `import.binding` carrying the leading segments. It is genuinely optional: a
`@Path`, `@Stateless` or `@WebServlet` in a project the detector matched is
not ambiguous in practice.

## Still to decide

1. **Class-level `@RolesAllowed` and `@DenyAll` are not covered.** They are
   common — securing a whole EJB — but `within definition.class` also matches
   every *method*-level annotation in that class, and there is no negative join
   ("not within `scope.class_body`") to separate them. The choice was to cover
   the method case exactly rather than the class case approximately. If a
   `not_within` span relation is ever added to `SpanRelation`, this becomes one
   more rule.

2. **`jakarta-ee.jaxrs.resource` deliberately accepts a method-level `@Path`.**
   It joins `within definition.class`, so a sub-resource `@Path` on a method
   also marks its class as a `Controller`. That is correct — a class with a
   `@Path` anywhere on it *is* a JAX-RS resource — and it mints the same key
   either way, so it de-duplicates rather than over-mints. Recorded because it
   is a judgement, not an accident.

3. **Nested classes produce one entity per enclosing class.** A `@Path` inside
   an inner class lies within both class declarations, so both are minted as
   `Controller`. Inner JAX-RS resources are rare and the extra entity is a true
   statement about a class that does contain a resource; picking the innermost
   join is not expressible.

4. **Field injection is out of reach, and it is the Pack's span choice, not a
   missing field.** omega-java spans `definition.field` on the
   `variable_declarator` (`queries.scm:95-99`), while `@Inject` sits on the
   enclosing `field_declaration`, so the annotation is *not* within the field.
   This is exactly the omega-c-sharp `[SerializeField]` case already recorded in
   `00-INDEX.md` wave 1, now confirmed for Java. `@Inject` on a field currently
   matches nothing in this file; `@Id`, `@Column` and `@ManyToOne` are
   unreachable for the same reason, which is why the JPA rule stops at the class.
