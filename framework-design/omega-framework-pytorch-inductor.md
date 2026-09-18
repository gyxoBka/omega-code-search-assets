# omega-framework-pytorch-inductor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

5 overlay rules, 12 detection rules. **2 can match, 3 cannot.**

Selector: `framework:pytorch-inductor`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `CompiledFunction` | 3 |
| `CompileConfig` | 2 |
| `CompilerModule` | 1 |
| `CompileOption` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 3 |
| `configures` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.member` | 2 | yes |
| `call.direct` | 1 | **no** |
| `definition.python_import_bound_member_call_literal_keyword_context` | 1 | **no** |
| `definition.python_import_bound_member_two_keyword_identifiers_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x5, `field_equals` x4, `external_path_matches` x3, `field_present` x3, `path_glob` x2, `field_in` x1.

Fields read: `module_name`, `callee_member`, `binding_name`, `keyword_name`, `keyword_string`.

Path globs: `**/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `inductor.compile.call` | kind `call.direct` |
| `inductor.torch-compile.literal-option` | kind `definition.python_import_bound_member_call_literal_keyword_context`; field `binding_name`, `callee_member`, `keyword_name`, `keyword_string`, `module_name` |
| `inductor.torch-compile.identifier-options` | kind `definition.python_import_bound_member_two_keyword_identifiers_context`; field `binding_name`, `callee_member`, `module_name` |

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
