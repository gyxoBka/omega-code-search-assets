# omega-julia

Language `omega-julia`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

69 templates over 129 query patterns, 62 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 5 |
| `data` | yes | 32 |
| `definitions` | yes | 9 |
| `imports` | yes | 9 |
| `modules` | yes | 2 |
| `references` | yes | 4 |
| `scopes` | yes | 3 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.julia_function` | Callable | 2 |
| `definition.julia_import_bound_member_binding_context` | Value | 1 |
| `definition.julia_macro` | Value | 1 |
| `definition.julia_struct` | Type | 1 |
| `definition.julia_type` | Type | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.julia_candidate` | `omega.pack.julia` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `import.julia_candidate` | `omega.pack.julia` | 1 |
| `import.module_path_candidate` | `omega.pack.module_path` | 1 |
| `import.target_candidate` | `omega.pack.target` | 1 |
| `module.declaration_path_candidate` | `omega.pack.declaration_path` | 1 |
| `module.julia_candidate` | `omega.pack.julia` | 1 |
| `reference.julia_identifier_candidate` | `omega.pack.julia_identifier` | 2 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.julia_declaration_candidate` | `omega.pack.julia_declaration` | 1 |

### Regions

- `scope.julia_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.julia_variable` | reference | 2 |
| `import_binding.julia_import` | binding | 2 |
| `call.julia_broadcast` | call | 1 |
| `call.julia_broadcast_direct` | call | 1 |
| `call.julia_macro` | call | 1 |
| `semantic_hint.julia_callable` | call | 3 |
| `semantic_hint.julia_documentation` | reference | 1 |
| `semantic_hint.julia_literal` | reference | 9 |
| `semantic_hint.julia_module` | reference | 1 |
| `semantic_hint.julia_syntax_role` | reference | 11 |
| `semantic_hint.julia_type` | reference | 3 |
| `semantic_hint.julia_value` | reference | 4 |
| `import.julia_import` | binding | 1 |
| `import.julia_import_path` | binding | 1 |
| `import.julia_selected` | binding | 1 |
| `import.julia_selected_entry` | binding | 1 |
| `import.julia_using` | binding | 1 |
| `import.julia_using_path` | binding | 1 |
| `reference.julia_field_expression` | reference | 1 |
| `reference.julia_import_bound_callable_invocation_context` | call | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 89 node types. The Pack looks at 73 of them.

Untouched:

- `_definition`
- `_expression`
- `_statement`
- `compound_assignment_expression`
- `comprehension_expression`
- `generator`
- `global_statement`
- `index_expression`
- `juxtaposition_expression`
- `local_statement`
- `macro_argument_list`
- `matrix_expression`
- `matrix_row`
- `parenthesized_expression`
- `splat_expression`
- `vector_expression`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
