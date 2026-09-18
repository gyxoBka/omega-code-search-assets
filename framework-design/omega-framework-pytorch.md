# omega-framework-pytorch

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

29 overlay rules, 4 detection rules. **1 can match, 28 cannot.**

Selector: `framework:pytorch`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComputeNode` | 7 |
| `ModelComponent` | 3 |
| `Loss` | 3 |
| `Submodule` | 2 |
| `Parameter` | 2 |
| `ComputeGraph` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `RegisteredState` | 1 |
| `Forward` | 1 |
| `Optimizer` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `compute_depends_on` | 6 |
| `contains` | 3 |
| `has_parameter` | 2 |
| `uses_loss` | 2 |
| `forward_calls` | 2 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `has_forward` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.python_import_bound_member_call_identifier_context` | 5 | **no** |
| `definition.python_class_method_self_member_call_identifier_context` | 5 | **no** |
| `definition.python_class_self_member_from_import_constructor_context` | 3 | **no** |
| `definition.python_class_self_member_import_alias_constructor_context` | 3 | **no** |
| `definition.python_import_bound_member_binding_context` | 2 | **no** |
| `definition.python_import_bound_member_call_two_identifier_context` | 2 | **no** |
| `definition.python_class_method_self_member_call_two_identifier_context` | 2 | **no** |
| `definition.python_import_bound_member_call_three_identifier_context` | 2 | **no** |
| `definition.python_class_method_self_member_call_three_identifier_context` | 2 | **no** |
| `definition.class` | 1 | yes |
| `definition.python_from_import_constructor_binding_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.python_from_import_class_base_context` | 1 | **no** |
| `reference.python_import_alias_class_member_base_context` | 1 | **no** |
| `call.python_class_self_registration_string_context` | 1 | **no** |
| `definition.python_class_method_context` | 1 | **no** |
| `call.python_class_method_self_member_return_identifier_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x60, `fact_kind` x29, `field_equals` x27, `field_in` x26, `path_glob` x7, `fact_join_by_field` x6, `(join)` x6, `external_path_matches` x3.

Fields read: `module_name`, `owner_function`, `source.start`, `binding_name`, `callee_member`, `member`, `member_name`, `imported_name`, `class_name`, `second_identifier`, `third_identifier`, `input_identifier`, `callee_name`, `base_member`, `name_string`, `method_name`.

Path globs: `**/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `pytorch.direct-functional-compute-node` | kind `definition.python_import_bound_member_call_identifier_context`; field `binding_name`, `callee_member`, `input_identifier`, `module_name`, `owner_function` |
| `pytorch.direct-functional-compute-dependency` | kind `definition.python_import_bound_member_call_identifier_context`; field `binding_name`, `callee_member`, `input_identifier`, `module_name`, `owner_function` |
| `pytorch.source-authored.fx-graph` | kind `definition.python_from_import_constructor_binding_context`; field `binding_name`, `callee_name`, `imported_name`, `module_name` |
| `pytorch.generic-api-call.torch` | kind `call.target_candidate` |
| `pytorch.generic-dependency.torch` | kind `import.target_candidate` |
| `pytorch.module.from-import` | kind `reference.python_from_import_class_base_context`; field `imported_name`, `module_name` |
| `pytorch.module.import-alias` | kind `reference.python_import_alias_class_member_base_context`; field `base_member`, `module_name` |
| `pytorch.submodule.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `class_name`, `imported_name`, `member_name`, `module_name` |
| `pytorch.parameter.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `class_name`, `imported_name`, `member_name`, `module_name` |
| `pytorch.loss-member.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `imported_name`, `member_name`, `module_name` |
| `pytorch.submodule.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `class_name`, `member_name`, `module_name` |
| `pytorch.parameter.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `class_name`, `member_name`, `module_name` |
| `pytorch.loss-member.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `member_name`, `module_name` |
| `pytorch.registration` | kind `call.python_class_self_registration_string_context`; field `member`, `name_string` |
| `pytorch.forward` | kind `definition.python_class_method_context`; field `method_name` |
| `pytorch.forward.self-call-node` | kind `definition.python_class_method_self_member_call_identifier_context`; field `binding_name`, `member`, `owner_function` |
| `pytorch.forward.self-return-node` | kind `call.python_class_method_self_member_return_identifier_context`; field `member`, `owner_function` |
| `pytorch.forward.self-call-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`; field `binding_name`, `input_identifier`, `owner_function` |
| `pytorch.optimizer.binding` | kind `definition.python_import_bound_member_binding_context`; field `member`, `module_name` |
| `pytorch.loss.binding` | kind `definition.python_import_bound_member_binding_context`; field `member`, `module_name` |
| `pytorch.direct-functional-second-input-metadata` | kind `definition.python_import_bound_member_call_two_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `second_identifier` |
| `pytorch.direct-functional-second-input-dependency` | kind `definition.python_import_bound_member_call_identifier_context`, `definition.python_import_bound_member_call_two_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `second_identifier` |
| `pytorch.forward.self-call-second-input-metadata` | kind `definition.python_class_method_self_member_call_two_identifier_context`; field `binding_name`, `member`, `owner_function`, `second_identifier` |
| `pytorch.forward.self-call-second-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`, `definition.python_class_method_self_member_call_two_identifier_context`; field `binding_name`, `owner_function`, `second_identifier` |
| `pytorch.direct-functional-third-input-metadata` | kind `definition.python_import_bound_member_call_three_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `third_identifier` |
| `pytorch.direct-functional-third-input-dependency` | kind `definition.python_import_bound_member_call_identifier_context`, `definition.python_import_bound_member_call_three_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `third_identifier` |
| `pytorch.forward.self-call-third-input-metadata` | kind `definition.python_class_method_self_member_call_three_identifier_context`; field `binding_name`, `member`, `owner_function`, `third_identifier` |
| `pytorch.forward.self-call-third-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`, `definition.python_class_method_self_member_call_three_identifier_context`; field `binding_name`, `owner_function`, `third_identifier` |

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
