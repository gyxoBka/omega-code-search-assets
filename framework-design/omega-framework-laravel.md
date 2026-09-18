# omega-framework-laravel

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

32 overlay rules, 4 detection rules. **19 can match, 13 cannot.**

Selector: `framework:laravel`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 9 |
| `FrameworkConfig` | 6 |
| `ResourceRoute` | 2 |
| `QueueUse` | 2 |
| `Model` | 1 |
| `View` | 1 |
| `Controller` | 1 |
| `ApiUse` | 1 |
| `ViewRoute` | 1 |
| `RedirectRoute` | 1 |
| `FallbackRoute` | 1 |
| `InjectionPoint` | 1 |
| `SchemaMigration` | 1 |
| `EventDispatch` | 1 |
| `EventListener` | 1 |
| `MailUse` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 11 |
| `handles` | 9 |
| `uses_api` | 6 |
| `renders` | 1 |
| `depends_on` | 1 |
| `injects` | 1 |
| `configures` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 26 | yes |
| `definition.class` | 4 | yes |
| `call.direct` | 1 | **no** |
| `reference.php_class_relation_explicit_target_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `reference.php_constructor_parameter_type_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x32, `external_path_matches` x30, `field_present` x23, `path_glob` x2, `fact_join_by_field` x2, `(join)` x2, `field_equals` x1, `field_in` x1.

Fields read: `call.arg0`, `source.start`, `owner_class`, `definition.qname`, `source.path`, `call.name`, `relation_method`, `target_class`, `parameter_type`.

Path globs: `**/app/Http/Controllers/**/*.php`, `**/app/Models/**/*.php`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `laravel.view.call` | kind `call.direct`; field `call.name` |
| `laravel.model.explicit-relation-target` | kind `reference.php_class_relation_explicit_target_context`; field `definition.qname`, `owner_class`, `relation_method`, `target_class` |
| `laravel.generic-api-call.laravel-framework` | kind `call.target_candidate` |
| `laravel.route.get` | field `call.arg0` |
| `laravel.route.post` | field `call.arg0` |
| `laravel.route.put` | field `call.arg0` |
| `laravel.route.patch` | field `call.arg0` |
| `laravel.route.delete` | field `call.arg0` |
| `laravel.route.options` | field `call.arg0` |
| `laravel.route.any` | field `call.arg0` |
| `laravel.route.match` | field `call.arg0` |
| `laravel.constructor.di` | kind `reference.php_constructor_parameter_type_context`; field `owner_class`, `parameter_type` |
| `laravel.schema.create` | field `call.arg0` |

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
