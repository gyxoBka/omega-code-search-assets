# omega-framework-django

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

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

*One rule per spelling, 15 of them.* `django.model.field.charfield`,
`.textfield`, `.integerfield` … `.manytomanyfield` were fifteen copies of one
rule differing only in a one-element `member_in`. omega-python now states every
one of them as `call.method` with the constructor's name, so `field_in` over a
list replaces all fifteen with two rules — one for scalar fields, one for
relational ones, because the two differ in the `field_role` they assert.
The four `django.setting.*` rules and the three `django.setting.*_list` rules
collapse the same way into one `django.setting`.

*Fields no Pack publishes, 9 names.* `setting_name`, `class_name`, `field_name`,
`item0`, `item1`, `callee_object`, `keyword_name` in match clauses; and in
canonical keys and relation ends, `definition.qname`, `owner_class`,
`call.arg0/1/2`, `decorator.arg0`, `item`, `base_name`. omega-python publishes
**no fields at all** — every template has `"fields": {}` — so a Django rule has
exactly `definition.name`, `path`, the span and the kind to work with, and
everything else has to come from a span join. `owner_class` and `field_name`
are now `cls.definition.name` and `fld.definition.name` off two
`fact_join_by_span` `within` joins; `class_name` is `cls.definition.name` off
one.

*The 3 "live" rules were live only to the audit.* `django.model.class`,
`django.signal.receiver` and `django.admin.register` match kinds that exist
(`definition.class`, `reference.decorator`) but every one of them gates on
`external_path_matches`, and `OverlayFact.external` is populated nowhere in the
host — `OverlayFact` is constructed only in `crates/omega-semantic/tests`.
`ExternalMatch::matches` returns `false` on `None`, so all three matched zero
facts. Their keys also read `definition.qname` and `decorator.arg0`, neither of
which is a built-in name, so `render` would have dropped the output anyway.
`external_path_matches` appeared in 28 of the 38 rules and is used in none of
the 17 now.

*A relation with no source, 17 of them.* The 15 `django.model.field.*` rules
and `django.admin.register`/`django.signal.receiver` sourced relations at
`django:model:{owner_class}` and `django:admin:{definition.qname}` — keys no
rule in the file ever minted under that spelling (`django.model.class` minted
`django:model:{definition.qname}`). Every rule that emits a relation now mints
both of its ends.

**38 rules became 17, and all 17 match.**

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which classes are Django models | `relation.implements` named `Model`/`AbstractUser`/`AbstractBaseUser`, joined `within` `definition.class` | `Model` at `django:model:{Class}` |
| which columns a model declares, and of what type | `call.method` named `CharField`…`UUIDField` in `**/models**.py`, joined `within` `definition.field` then `within` `definition.class` | `ModelField` at `django:model-field:{Model}.{field}`; `Model` --contains--> `ModelField` |
| which of a model's fields are links to other models | the same, for `ForeignKey`, `OneToOneField`, `ManyToManyField`, `GenericForeignKey`, `GenericRelation` | same, with `field_role: relation` |
| which classes handle requests | `relation.implements` named `View`, `ListView`, `DetailView`, `CreateView` … joined `within` `definition.class` | `View` at `django:view:{Class}` |
| which functions handle requests | `definition.function` in `**/views**.py`, name not `_`-prefixed | `View` at `django:view:{name}`, `style: function` |
| which classes are forms | `relation.implements` named `Form`/`ModelForm` | `Form` at `django:form:{Class}` |
| which classes configure the admin | `relation.implements` named `ModelAdmin`/`TabularInline`/`StackedInline`/`AdminSite` | `AdminComponent` at `django:admin:{Class}` |
| which apps this project declares, and where each lives | `relation.implements` named `AppConfig` | `AppConfig` at `django:app:{Class}`, `app_dir` = `path.dir` |
| which classes are middleware | `relation.implements` named `MiddlewareMixin` | `Middleware` at `django:middleware:{Class}` |
| what `manage.py <x>` can run | `definition.class` named `Command` under `**/management/commands/*.py` | `ManagementCommand` at `django:command:{path.stem}` |
| which files are URLconfs, and where each pattern is declared | `call.function` named `path`/`re_path`/`url`, joined `within` the `definition.variable` named `urlpatterns` | `UrlConfiguration` at `django:urlconf:{path}`; `Route` at `django:route:{path}:{offset}`; `UrlConfiguration` --contains--> `Route` |
| where one URLconf mounts another | the same, for `include` | `RouteMount`; `UrlConfiguration` --mounts--> `RouteMount` |
| where a setting is configured, and by which settings module | `definition.variable` in `**/settings**.py` | `Setting` at `django:setting:{NAME}`; `SettingsModule` at `django:settings-module:{path}`; `SettingsModule` --configures--> `Setting` |
| what migration history an app has | `definition.class` named `Migration` under `**/migrations/*.py` | `Migration` at `django:migration:{path}`; `MigrationHistory` at `django:migration-set:{path.dir}` --contains--> `Migration` |
| what a migration does to the schema | `call.method` named `CreateModel`, `AddField`, `AlterField`, `RunPython` … under `**/migrations/*.py`, joined `within` the `Migration` class | `MigrationOperation`; `Migration` --contains--> `MigrationOperation` |
| which modules wire up signal receivers | `reference.decorator` named `receiver` | `SignalModule` --declares--> `SignalHandler` |
| where the WSGI/ASGI entry point is | `call.function` named `get_wsgi_application`/`get_asgi_application` | `ApplicationEntry` at `django:application:{path}` |

Every canonical key a relation addresses is minted by the same rule that emits
the relation, so nothing dangles: `django:model:*` (minted by
`django.model.class`, `django.model.field`, `django.model.relation-field`),
`django:urlconf:*` (`django.url.pattern`, `django.url.include`),
`django:settings-module:*` and `django:setting:*` (`django.setting`),
`django:migration-set:*` and `django:migration:*` (`django.migration`, and
`django.migration.operation` only fires when the `Migration` class it joins is
in the same file, which is exactly the condition `django.migration` mints on),
`django:signal-module:*` (`django.signal.receiver`).

## A field only the Pack can supply

**omega-python, every `call.*` kind, a field naming the call's first string
argument.** `queries.scm` captures `(call function: (identifier) @call.name)`
and `(call function: (attribute attribute: (identifier) @call.method))` — the
argument list is captured nowhere, and no other template spans it. So

- `path("orders/<int:pk>/", …)` — the route is not stated. `Route` is keyed by
  file and byte offset, and *which route serves this path* is unanswerable for
  Django.
- `include("blog.urls")` — the mounted URLconf is not stated, so `RouteMount`
  points at nothing downstream.
- `ForeignKey("shop.Order", …)` / `ForeignKey(Order, …)` — the target model is
  not stated, so a relational `ModelField` cannot become an edge between two
  `Model` entities. This is the single largest thing the overlay cannot say.
- `admin.site.register(Author, AuthorAdmin)` — which model an admin class
  serves is not stated.

Neither a built-in name nor a join reaches it: `definition.name` on a
`call.method` is the callee's own identifier, and `fact_join_by_span` can only
bind a fact the Pack already emits over those bytes — there is none inside the
argument list. It is a Pack `field` (or a `reference.string_argument`-shaped
emission) or nothing.

**omega-python, `reference.decorator`, the declaration it decorates.** The span
is `@decorator.name`; `definition.function` spans the `function_definition`,
and tree-sitter's `decorated_definition` is the parent of *both*, so neither
span contains the other and `fact_join_by_span` `within` cannot relate them in
either direction. That leaves *which views require login*
(`@login_required`), *which function handles `post_save`* (`@receiver`) and
*which model an admin class registers* (`@admin.register`) unanswerable, and is
why `django.signal.receiver` attaches its handler to the module rather than to
a function. Spanning `reference.decorator` on the `decorated_definition` node,
or emitting a second fact over it, would fix all three at once — this is the
same shape as the omega-c-sharp `[SerializeField]` finding already recorded in
`00-INDEX.md`.

## Still to decide

- **`django.view.function` is convention-only.** Every non-`_`-prefixed
  function in `**/views**.py` becomes a `View`. Django has no marker on a
  function view — the only signal is the `request` first parameter, and
  omega-python emits `definition.parameter_shape_candidate` as a carrier that
  the host folds onto the declaration as an attribute, which the overlay cannot
  read (`00-INDEX.md`: an attribute is write-only). Kept at
  `confidence: candidate`; the alternative is not answering *which handler
  answers it* for function views at all.
- **Model fields are gated on `**/models**.py`.** `forms.CharField(...)` and
  `models.CharField(...)` are the same `call.method` fact — the qualifier is
  not captured — so path is the only discriminator. A model declared in
  `api/schema.py` gets no fields; a form declared in `models.py` would get a
  spurious `Model`. The path convention holds in practice and is the reason
  `django.model.class` is deliberately *not* path-gated: a base class is
  unambiguous evidence, a constructor name is not.
- **`django.middleware.class` only sees `MiddlewareMixin` subclasses.** Modern
  Django middleware is a plain callable taking `get_response`, indistinguishable
  from any other class, and the `MIDDLEWARE` setting lists them as strings the
  Pack does not capture. The rule answers for the legacy spelling and is silent
  on the modern one rather than guessing from `**/middleware.py`.
- **`Setting` is keyed by name alone**, not by name and module, so `DEBUG` in
  `settings/base.py` and `settings/prod.py` are one entity with two
  `configures` edges. That is the right answer for *where is `DEBUG` set*; it
  is the wrong one if a reader wants the two values distinguished, and the
  values are not published in any case.
