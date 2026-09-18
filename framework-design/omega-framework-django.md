# omega-framework-django

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

Rewritten twice: once for the Pack vocabulary (38 rules -> 17, all live), and
once again — this pass — now that omega-python publishes a call's arguments
(17 -> 21, all live, 0 key collisions). The tables below are the *original*
38-rule state; "What was wrong with it" covers both passes.

## State before the rewrite

38 overlay rules, 4 detection rules. **3 can match, 35 cannot.**

Selector: `framework:django`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ModelField` | 15 |
| `Dependency` | 2 |
| `ApplicationEntry` | 2 |
| `Middleware` | 2 |
| `Route` | 1 |
| `Handler` | 1 |
| `Model` | 1 |
| `Migration` | 1 |
| `ApiUse` | 1 |
| `View` | 1 |
| `UrlConfiguration` | 1 |
| `ConfigKey` | 1 |
| `InstalledApp` | 1 |
| `HostPolicy` | 1 |
| `SignalHandler` | 1 |
| `AdminRegistration` | 1 |
| `FieldOption` | 1 |
| `Form` | 1 |
| `AdminComponent` | 1 |
| `AppConfig` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 15 |
| `configured_by` | 4 |
| `handles` | 2 |
| `depends_on` | 2 |
| `mounts` | 1 |
| `uses_model` | 1 |
| `uses_api` | 1 |
| `configures` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.python_class_member_constructor_context` | 15 | **no** |
| `reference.python_from_import_class_base_context` | 5 | **no** |
| `data.python_module_string_setting_context` | 4 | **no** |
| `call.direct` | 3 | **no** |
| `data.python_module_string_list_item_context` | 3 | **no** |
| `reference.decorator` | 2 | yes |
| `definition.class` | 1 | yes |
| `data.file` | 1 | **no** |
| `reference.python_class_list_string_tuple_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `data.python_class_member_constructor_keyword_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x38, `external_path_matches` x28, `field_equals` x10, `path_glob` x9, `field_present` x4, `path_segment` x1, `field_in` x1.

Fields read: `setting_name`, `source.start`, `class_name`, `field_name`, `item0`, `item1`, `callee_object`, `keyword_name`.

Path globs: `**/settings*.py`, `**/migrations/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `django.url.path` | kind `call.direct` |
| `django.url.include` | kind `call.direct` |
| `django.migration.file` | kind `data.file` |
| `django.model.relation` | kind `call.direct` |
| `django.migration.dependencies` | kind `reference.python_class_list_string_tuple_context`; field `class_name`, `field_name`, `item0`, `item1` |
| `django.generic-api-call.django` | kind `call.target_candidate` |
| `django.generic-dependency.django` | kind `import.target_candidate` |
| `django.model.field.charfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.textfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.integerfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.bigintegerfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.booleanfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.datefield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.datetimefield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.decimalfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.uuidfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.jsonfield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.filefield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.imagefield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.foreignkey` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.onetoonefield` | kind `definition.python_class_member_constructor_context` |
| `django.model.field.manytomanyfield` | kind `definition.python_class_member_constructor_context` |
| `django.view.class` | kind `reference.python_from_import_class_base_context` |
| `django.setting.root_urlconf` | kind `data.python_module_string_setting_context`; field `setting_name` |
| `django.setting.wsgi_application` | kind `data.python_module_string_setting_context`; field `setting_name` |
| `django.setting.asgi_application` | kind `data.python_module_string_setting_context`; field `setting_name` |
| `django.setting.default_auto_field` | kind `data.python_module_string_setting_context`; field `setting_name` |
| `django.setting.installed_apps` | kind `data.python_module_string_list_item_context`; field `setting_name` |
| `django.setting.middleware` | kind `data.python_module_string_list_item_context`; field `setting_name` |
| `django.setting.allowed_hosts` | kind `data.python_module_string_list_item_context`; field `setting_name` |
| `django.model.field-option` | kind `data.python_class_member_constructor_keyword_context`; field `callee_object`, `keyword_name` |
| `django.form.class` | kind `reference.python_from_import_class_base_context` |
| `django.admin.class` | kind `reference.python_from_import_class_base_context` |
| `django.app-config.class` | kind `reference.python_from_import_class_base_context` |
| `django.middleware.class` | kind `reference.python_from_import_class_base_context` |

## What was wrong with it

Two rewrites are recorded here. The first is kept because the counts in the
tables above are its input; the second is the one this file now describes.

### Pass one: 38 rules, 35 dead

**38 rules; 35 could not match any Pack emission, and the 3 the audit called
live matched nothing either.**

*The kind, 35 rules.* Every dead rule was keyed to a private spelling the
omega-python Pack no longer emits — or never emitted:

| dead kind | rules | what it was reaching for |
|---|---|---|
| `definition.python_class_member_constructor_context` | 15 | a model field assignment |
| `reference.python_from_import_class_base_context` | 5 | a class's base class |
| `data.python_module_string_setting_context` | 4 | a module-level setting |
| `call.direct` | 3 | `path()`, `include()`, `ForeignKey()` |
| `data.python_module_string_list_item_context` | 3 | an item of `INSTALLED_APPS` etc. |
| `call.target_candidate`, `import.target_candidate` | 2 | a call, an import |
| `data.file` | 1 | a migration file |
| `reference.python_class_list_string_tuple_context` | 1 | `Migration.dependencies` |
| `data.python_class_member_constructor_keyword_context` | 1 | `null=True` on a field |

*One rule per spelling, 15 of them.* `django.model.field.charfield` …
`.manytomanyfield` were fifteen copies of one rule differing only in a
one-element `member_in`; `field_in` over a list replaced all fifteen with two.
The four `django.setting.*` rules and the three `django.setting.*_list` rules
collapsed into one `django.setting`.

*Fields no Pack published, 9 names* — `setting_name`, `class_name`,
`field_name`, `item0`, `item1`, `callee_object`, `keyword_name`, `owner_class`,
`base_name`. All were replaced by `fact_join_by_span` `within` bindings.

*`external_path_matches` in 28 of 38 rules*, and `OverlayFact.external` is empty
for Python, so all 28 matched zero facts while the audit scored 3 of them live.

*A relation with no source, 17 of them* — `django:model:{owner_class}` and
`django:admin:{definition.qname}` were keys no rule in the file ever minted.

**38 rules became 17, and all 17 matched.**

### Pass two: 17 rules, all live, and a route with no URL

Pass one was written when omega-python captured no call argument. It left the
overlay stating *that* a route exists and never *which* route, and the file said
so in four `coverage.gaps` sentences and a four-item "A field only the Pack can
supply". omega-python now publishes `call.arg0`, `call.arg0_text`,
`call.arg0_name`, `call.arg1`, `call.arg1_text`, `call.arg2`, `call.last_arg`,
`call.last_arg_name` and `receiver` on `call.function` and `call.method`
(measured with `dump_call_emissions`, not read off a table), and three of those
four gaps closed.

Concretely wrong in the 17-rule file, all of it verified against the Pack rather
than argued:

| what it said | measured | rules affected |
|---|---|---|
| a Route is keyed `django:route:{path}:{source.start}` — a file and a byte offset, with no URL anywhere in the graph | `path("orders/<int:pk>/", …)` emits `call.arg0_text = orders/<int:pk>/` | 1 (`django.url.pattern`) |
| a `RouteMount` is keyed by offset and "points at nothing downstream" | `include("blog.urls")` emits `call.arg0_text = blog.urls` | 1 (`django.url.include`) |
| a relational `ModelField` "cannot become an edge between two `Model` entities … the single largest thing the overlay cannot say" | `ForeignKey("shop.Customer")` and `ForeignKey(Customer)` both emit `call.arg0_name = Customer` — the same identity `django:model:*` is keyed by | 1 (`django.model.relation-field`) |
| "which model an admin class serves is not stated" | `admin.site.register(Author, AuthorAdmin)` emits `receiver = admin.site`, `call.arg0_name = Author`, `call.arg1_text = AuthorAdmin` | 0 — the question had no rule at all |
| `django.signal.receiver` matched `reference.decorator` and minted a handler with nothing on it but a byte offset | the same `@receiver(post_save, …)` also emits `call.function receiver` with `call.arg0_text = post_save` | 1 |
| model fields were gated on `**/models**.py` because "`forms.CharField(...)` and `models.CharField(...)` are the same `call.method` fact — the qualifier is not captured" | the qualifier *is* captured: `receiver = models` vs `receiver = forms` | 2 |

Six statements in the file were untrue as of the Pack rewrite, four of them
recorded as permanent limits in `coverage.gaps` or in "A field only the Pack can
supply".

One thing pass one got right and pass two keeps: **the route-to-handler edge is
still not emitted.** Django writes `path("orders/", views.order_detail)`, so the
handler is the *second* argument, and omega-python publishes `call.arg1_text`
(`views.order_detail`, qualifier and all) but no `call.arg1_name`.
`call.last_arg_name` is not a substitute — it is `name="order-detail` whenever
the call carries the usual `name=` keyword, and `as_view()` for a class-based
view. Keying the edge on either would have produced a relation whose target no
rule ever mints while `overlay_audit.py`, `key_collisions.py` and
`validate_external_assets` all reported clean. The view expression is carried as
an **attribute** on the Route instead, and the missing field is reported below.

*Two deletions.* `SignalModule` (`django:signal-module:{path}`) is gone: the
signal itself is the better hub now that it can be named, and a module that
happens to contain a `@receiver` was never an answer to anything. `RouteMount`
(`django:url-mount:{path}:{offset}`) is gone for the same reason — the mounted
module has a name, so the entity is keyed by it.

**17 rules became 21, all 21 live, 0 key collisions.** The four extra rules are
`django.model.registration` (which model the admin exposes),
`django.signal.connect` (`post_save.connect(handler)` — the one signal spelling
where both ends are nameable), `django.view.render` (which template a view
renders) and `django.url.regex`, which is `django.url.pattern` split in two so
that a regex does not enter the `http:*` key space.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| **which URL does this route serve** | `call.function` named `path` in `**/urls**.py`, joined `within` the `definition.variable` named `urlpatterns`; URL from `call.arg0_text` | `Route` at `http:{method}:{normalized_route}` — `method` is the literal `ANY`, `route` is the URL as written; `UrlConfiguration` at `django:urlconf:{path}` --declares--> `Route` |
| which regex routes exist, and what pattern each carries | the same, for `re_path`/`url`; `call.arg0` (raw, quotes and `r` prefix kept — a regex is not an identity) | `RoutePattern` at `django:route-pattern:{path}:{offset}`; `UrlConfiguration` --declares--> `RoutePattern` |
| which URLconf module does this one mount | `call.function` named `include`, `call.arg0_text` | `UrlConfModule` at `django:urlconf-module:{module}`; `UrlConfiguration` --mounts--> `UrlConfModule` |
| which classes are Django models | `relation.implements` named `Model`/`AbstractUser`/`AbstractBaseUser`, joined `within` `definition.class` | `Model` at `django:model:{Class}` |
| which columns a model declares, and of what type | `call.method` with `receiver = models` named `CharField`…`UUIDField`, joined `within` `definition.field` then `within` `definition.class` | `ModelField` at `django:model-field:{Model}.{field}`; `Model` --contains--> `ModelField` |
| **which model does this foreign key point at** | the same for `ForeignKey`/`OneToOneField`/`ManyToManyField`/`GenericForeignKey`/`GenericRelation`, target from `call.arg0_name` | `ModelField` with `field_role: relation` and `target_model`; `Model` --references--> `Model` |
| **which models are exposed in the admin, and by which admin class** | `call.method` named `register` with `receiver` in `admin.site`/`admin`/`site`; model from `call.arg0_name`, admin class from `call.arg1_text` | `AdminRegistration` at `django:admin-registration:{path}:{offset}` --registers--> `Model` |
| which classes configure the admin | `relation.implements` named `ModelAdmin`/`TabularInline`/`StackedInline`/`AdminSite` | `AdminComponent` at `django:admin:{Class}` |
| which classes handle requests | `relation.implements` named `View`, `ListView`, `DetailView`, `CreateView` … | `View` at `django:view:{Class}` |
| which functions handle requests | `definition.function` in `**/views**.py`, name not `_`-prefixed | `View` at `django:view:{name}`, `style: function` |
| **which template does this view render** | `call.function` named `render`/`render_to_string`/`render_to_response` in `**/views**.py`, template from `call.arg1_text` globbed `**.html`, joined `within` `definition.function` | `Template` at `django:template:{name}`; `View` --renders--> `Template` |
| which classes are forms | `relation.implements` named `Form`/`ModelForm` | `Form` at `django:form:{Class}` |
| which apps this project declares, and where each lives | `relation.implements` named `AppConfig` | `AppConfig` at `django:app:{Class}`, `app_dir` = `path.dir` |
| which classes are middleware | `relation.implements` named `MiddlewareMixin` | `Middleware` at `django:middleware:{Class}` |
| what `manage.py <x>` can run | `definition.class` named `Command` under `**/management/commands/*.py` | `ManagementCommand` at `django:command:{path.stem}` |
| where a setting is configured, and by which settings module | `definition.variable` in `**/settings**.py` | `Setting` at `django:setting:{NAME}`; `SettingsModule` --configures--> `Setting` |
| what migration history an app has | `definition.class` named `Migration` under `**/migrations/*.py` | `Migration` at `django:migration:{path}`; `MigrationHistory` at `django:migration-set:{path.dir}` --contains--> `Migration` |
| what a migration does to the schema | `call.method` with `receiver = migrations` named `CreateModel`, `AddField`, `RunPython` … under `**/migrations/*.py`, joined `within` the `Migration` class | `MigrationOperation`; `Migration` --contains--> `MigrationOperation` |
| **which signal is this receiver listening for** | `call.function` named `receiver`, signal from `call.arg0_text` | `Signal` at `django:signal:{name}`; `SignalHandler` at `django:signal-receiver:{path}:{offset}` --handles--> `Signal` |
| **which function is connected to which signal** | `call.method` named `connect` whose `receiver` is one of Django's 18 built-in signals; handler from `call.arg0_name` | `SignalHandler` at `django:signal-handler:{function}` --handles--> `Signal` |
| where the WSGI/ASGI entry point is | `call.function` named `get_wsgi_application`/`get_asgi_application` | `ApplicationEntry` at `django:application:{path}` |

Bold rows are what the overlay could not answer before this pass.

**Every key a relation addresses is minted by the rule that emits it**, checked
by hand: `http:{method}:{normalized_route}` and `django:urlconf:{path}`
(`django.url.path`), `django:route-pattern:*` and `django:urlconf:*`
(`django.url.regex`), `django:urlconf-module:*` (`django.url.include`),
`django:model:{cls…}` and `django:model-field:*` and `django:model:{arg0_name}`
(`django.model.field`, `django.model.relation-field`,
`django.model.registration`), `django:migration:{path}` — minted by both
`django.migration` and `django.migration.operation`, so the operation edge does
not depend on the other rule having fired — `django:migration-set:*`,
`django:setting:*` and `django:settings-module:*` (`django.setting`),
`django:signal:*` with both handler key spaces (`django.signal.receiver`,
`django.signal.connect`), `django:view:*` and `django:template:*`
(`django.view.render`).

**Key spaces with more than one minting rule carry one kind each**
(`key_collisions.py` reports nothing): `django:model:*` is always `Model`,
minted by four rules whose ids sort so that `django.model.class` — the one with
the base class and the declaring file — wins the attribute set;
`django:view:*` is always `View`, with `django.view.class` first;
`django:urlconf:*` is always `UrlConfiguration`; `django:migration:*` is always
`Migration`; `django:signal:*` is always `Signal`.

## A field only the Pack can supply

**omega-python, `call.function` and `call.method`, a field `call.arg1_name`.**
The Pack publishes `call.arg0_name` — the last `.`-separated segment of the
first argument, unquoted — and it is what makes the ForeignKey edge and the
admin registration edge reach a real `django:model:*` key. It publishes no
equivalent for the second argument, and Django's route signature is
`path(route, view, kwargs=None, name=None)`: the handler is argument **one**,
not argument zero and not the last argument.

- `path("orders/", views.order_detail, name="order-detail")` —
  `call.arg1_text` is `views.order_detail`; the function's own declaration mints
  `django:view:order_detail`. The two keys never meet.
- `call.last_arg_name` is `name="order-detail` here, and `as_view()` for
  `path("orders/", OrderList.as_view())`. It is right only for the minority
  spelling `path("x/", views.foo)` with no trailing keyword, and wrong silently.
- A join cannot reach it: `fact_join_by_field` strips only a fixed literal
  prefix, and the qualifier is whatever the file imported (`views.`,
  `myapp.views.`, nothing at all); a canonical key template has no strip at all.
  `fact_join_by_span` cannot help either — the span of a `call.function` fact is
  the callee identifier (measured: 5 bytes for `path`), so nothing inside the
  argument list is contained by it.

The expression is exposed as the Route's `view` attribute so a reader can still
see it, but *which handler answers this route* is an edge Django does not get
until `call.arg1_name` exists. `call.arg1_name` is the same expression shape as
the `call.arg0_name` already in `packs/omega-python/rules.json`, applied to the
`select …, 1` argument the Pack already computes for `call.arg1_text`, so it
costs one more field on the two call templates and nothing new to capture.

**omega-python, `reference.decorator`, the declaration it decorates.** Unchanged
from pass one, and still the reason `@receiver` attaches to a byte offset rather
than to a function, `@admin.register` cannot name the class it decorates, and
`@login_required` cannot say which view requires login. The span is
`@decorator.name`; `definition.function` spans the `function_definition`; the
`decorated_definition` is the parent of both, so neither span contains the other
and `fact_join_by_span` `within` relates them in neither direction. Spanning
`reference.decorator` on the `decorated_definition` node would fix all three at
once. Same shape as the omega-c-sharp `[SerializeField]` finding in
`00-INDEX.md`.

## Still to decide

- **A Django route's `method` is the literal `ANY`.** A URLconf entry serves
  every HTTP verb; the verb is decided inside the view, by `if request.method`
  or by which `get`/`post` method a class-based view defines. The shared key
  shape is `http:{method}:{normalized_route}`, so Django's routes live in the
  same key space as Express's and ASP.NET's under one reserved method token. The
  alternative — a private `django:route:*` space — would keep a Django route
  from ever meeting the same URL declared in another framework's gateway or in
  an OpenAPI document, which is the case the shared space exists for.
- **`normalize_http_path` does not fold `<int:pk>`.** It folds `:id`, `{id}` and
  `[id]`; Django writes `<int:pk>`, which passes through as a literal segment.
  `/orders/<int:pk>` and `/orders/{id}` are therefore two identities. This is
  not one Framework's problem — it is a line in `composers.rs` — so it is
  recorded here and in `coverage.gaps` rather than worked around by rewriting
  the route in the rule, which the overlay has no operator for anyway.
- **Model fields are now gated on `receiver = models`, not on
  `**/models**.py`.** The receiver is captured generically, so the value is
  whatever was written, and choosing `models` is this Framework's own choice —
  the same shape `00-INDEX.md` warns about narrowing. The evidence for it:
  `models.CharField` and `forms.CharField` differ only in the receiver, and the
  old path gate answered wrongly in both directions (a model in
  `api/schema.py` got no columns; a form in `models.py` got a spurious `Model`).
  What it costs: `from django.db.models import CharField` followed by a bare
  `CharField(...)` is a `call.function` with no receiver and is not matched. A
  `path_segment` exclusion of `migrations` is still needed, because
  `operations = [migrations.CreateModel(fields=[("t", models.CharField())])]`
  puts a `models.*` call inside a `definition.field` inside a `definition.class`
  and would otherwise mint `django:model-field:Migration.operations`.
- **`django.view.function` is still convention-only.** Every non-`_`-prefixed
  function in `**/views**.py` becomes a `View`, including the methods of a
  class-based view declared there. Django puts no marker on a function view —
  the only signal is the `request` first parameter, and omega-python emits that
  as `definition.parameter_shape_candidate`, whose span is *identical* to the
  function's, so `within` excludes it (equal spans are excluded) and only
  `relation: "same"` could read it. Kept at `confidence: candidate`.
- **`definition.container` is unusable in Python.** The host fills it from the
  innermost `definition.*` fact strictly containing the fact, ties broken by
  emission order, and omega-python emits `definition.parameter_shape_candidate`
  named `(request, pk)` on exactly the same span as `definition.function`, after
  it. So `definition.container` for a call inside `def order_detail(request, pk)`
  is `(request, pk)`, not `order_detail`. `django.view.render` uses an explicit
  `fact_join_by_span` `within` `definition.function` instead. This is the
  carrier-in-the-chain caution in `00-CONTRACT.md` §2, measured.
- **`ForeignKey(to="Order")` is read as a model named `to="Order`.** The rule
  takes the first positional argument as the target, which is Django's
  documented spelling; the keyword form would need a "does not contain `=`"
  test, and the clause vocabulary has prefix tests only. `"self"` and the empty
  string are excluded explicitly so the common self-reference does not mint a
  model called `self`.
- **`Setting` is keyed by name alone**, not by name and module, so `DEBUG` in
  `settings/base.py` and `settings/prod.py` are one entity with two `configures`
  edges. That is the right answer for *where is `DEBUG` set*; the values are not
  published in any case.
- **`django.middleware.class` only sees `MiddlewareMixin` subclasses.** Modern
  Django middleware is a plain callable taking `get_response`, and the
  `MIDDLEWARE` setting lists them as strings inside a list literal that
  omega-python does not emit facts for. The rule answers for the legacy spelling
  and is silent on the modern one rather than guessing from `**/middleware.py`.
