# omega-framework-flask

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **8 can match, 6 cannot.**

Selector: `framework:flask`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `LifecycleHook` | 3 |
| `Route` | 2 |
| `Handler` | 2 |
| `Blueprint` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Application` | 1 |
| `Command` | 1 |
| `ConfigSource` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 2 |
| `mounts` | 2 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.decorator` | 6 | yes |
| `definition.python_from_import_constructor_binding_context` | 4 | **no** |
| `call.member` | 3 | yes |
| `call.python_receiver_identifier_argument_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x14, `external_path_matches` x12, `field_equals` x10, `field_present` x6, `path_glob` x2, `fact_join_by_field` x2, `(join)` x2.

Fields read: `module_name`, `imported_name`, `callee_name`, `source.start`, `binding_name`, `member`, `receiver`, `arg0_identifier`, `call.arg0`.

Path globs: `**/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `flask.blueprint.construct` | kind `definition.python_from_import_constructor_binding_context`; field `binding_name`, `callee_name`, `imported_name`, `module_name` |
| `flask.blueprint.mount.proven-bindings` | kind `call.python_receiver_identifier_argument_context`, `definition.python_from_import_constructor_binding_context`; field `arg0_identifier`, `callee_name`, `imported_name`, `member`, `module_name`, `receiver` |
| `flask.generic-api-call.flask` | kind `call.target_candidate` |
| `flask.generic-dependency.flask` | kind `import.target_candidate` |
| `flask.app.construct` | kind `definition.python_from_import_constructor_binding_context` |
| `flask.add-url-rule` | field `call.arg0` |

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
