# omega-framework-django

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

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
