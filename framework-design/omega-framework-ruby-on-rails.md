# omega-framework-ruby-on-rails

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

33 overlay rules, 4 detection rules. **3 can match, 30 cannot.**

Selector: `framework:ruby-on-rails`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ModelRule` | 12 |
| `Association` | 4 |
| `ResourceRoute` | 2 |
| `SchemaTable` | 2 |
| `SchemaReference` | 2 |
| `Route` | 1 |
| `Controller` | 1 |
| `Model` | 1 |
| `Job` | 1 |
| `RouteNamespace` | 1 |
| `RouteScope` | 1 |
| `RouteConstraint` | 1 |
| `MountedEngine` | 1 |
| `SchemaIndex` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 18 |
| `uses_model` | 5 |
| `configures` | 5 |
| `handles` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.ruby_string_arg_context` | 28 | **no** |
| `definition.class` | 5 | yes |
| `call.ruby_string_kwarg_context` | 1 | **no** |
| `reference.ruby_class_association_explicit_target_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x33, `field_equals` x29, `path_glob` x9, `field_present` x6, `external_path_matches` x4, `field_in` x3, `fact_join_by_field` x2, `(join)` x2.

Fields read: `call_name`, `definition.qname`, `source.path`, `kwarg_key`, `kwarg_value`, `macro`, `option_key`, `owner_class`, `option_value`.

Path globs: `**/db/migrate/*.rb`, `**/config/routes.rb`, `**/app/jobs/**/*.rb`, `**/app/models/**/*.rb`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `rails.route.dsl` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.to_handler` | kind `call.ruby_string_kwarg_context`; field `call_name`, `kwarg_key`, `kwarg_value` |
| `rails.model.explicit_class_name_association` | kind `reference.ruby_class_association_explicit_target_context`; field `definition.qname`, `macro`, `option_key`, `option_value`, `owner_class` |
| `rails.route.resources` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.resource` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.namespace` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.scope` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.constraints` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.route.mount` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.association.declaration.belongs_to` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.association.declaration.has_one` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.association.declaration.has_many` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.association.declaration.has_and_belongs_to_many` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.validates` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.validate` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.before_validation` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.after_validation` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.before_save` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.after_save` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.before_create` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.after_create` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.before_update` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.after_update` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.before_destroy` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.model.after_destroy` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.migration.create_table` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.migration.change_table` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.migration.add_index` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.migration.add_reference` | kind `call.ruby_string_arg_context`; field `call_name` |
| `rails.migration.add_foreign_key` | kind `call.ruby_string_arg_context`; field `call_name` |

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
