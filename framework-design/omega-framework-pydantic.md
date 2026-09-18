# omega-framework-pydantic

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **5 can match, 9 cannot.**

Selector: `framework:pydantic`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Model` | 3 |
| `Field` | 1 |
| `Validator` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `FieldConfig` | 1 |
| `FieldValidator` | 1 |
| `ModelValidator` | 1 |
| `ComputedField` | 1 |
| `FieldSerializer` | 1 |
| `ModelSerializer` | 1 |
| `ModelConfig` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configures` | 6 |
| `configured_by` | 2 |
| `has_field` | 1 |
| `validates` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.decorator` | 6 | yes |
| `reference.python_from_import_class_base_context` | 3 | **no** |
| `definition.python_class_field_context` | 1 | **no** |
| `definition.class` | 1 | yes |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.direct` | 1 | **no** |
| `definition.python_from_import_constructor_binding_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x14, `external_path_matches` x14, `field_present` x5, `fact_join_by_field` x1, `(join)` x1.

Fields read: `source.start`, `owner_class`, `field_name`, `definition.container`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `pydantic.model` | kind `reference.python_from_import_class_base_context` |
| `pydantic.field` | kind `definition.python_class_field_context`; field `field_name`, `owner_class` |
| `pydantic.validator` | field `definition.container` |
| `pydantic.generic-api-call.pydantic` | kind `call.target_candidate` |
| `pydantic.generic-dependency.pydantic` | kind `import.target_candidate` |
| `pydantic.model.basemodel` | kind `reference.python_from_import_class_base_context` |
| `pydantic.model.rootmodel` | kind `reference.python_from_import_class_base_context` |
| `pydantic.field.call` | kind `call.direct` |
| `pydantic.configdict` | kind `definition.python_from_import_constructor_binding_context` |

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
