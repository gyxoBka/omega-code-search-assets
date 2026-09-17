# omega-erlang

Language `omega-erlang`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

31 templates over 32 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 4 |
| `data` | yes | 4 |
| `definitions` | yes | 11 |
| `imports` | yes | 2 |
| `references` | yes | 6 |
| `scopes` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.erlang_behaviour_context` | Value | 1 |
| `definition.erlang_callback` | Value | 1 |
| `definition.erlang_function_context` | Callable | 1 |
| `definition.function` | Callable | 1 |
| `definition.module` | Value | 1 |
| `definition.record` | Value | 1 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `reference.qualified_chain_candidate` | `omega.pack.qualified_chain` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.parameter` | reference | 1 |
| `call.erlang_send` | call | 1 |
| `call.function_call` | call | 1 |
| `reference.erlang_qualified_call_context` | call | 1 |
| `data.erlang_attribute` | reference | 1 |
| `data.erlang_export` | binding | 1 |
| `data.erlang_zero_arity_atom_list_item_context` | reference | 1 |
| `semantic_hint.syntax_node` | reference | 1 |
| `import.erlang_include` | binding | 1 |
| `import.module_import` | binding | 1 |
| `reference.erlang_behaviour` | reference | 1 |
| `reference.erlang_function_capture` | reference | 1 |
| `reference.erlang_on_load` | reference | 1 |
| `reference.function_capture` | reference | 1 |
| `reference.variable` | reference | 1 |
| `type.erlang_spec` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 48 node types. The Pack looks at 14 of them.

Untouched:

- `after`
- `anonymous_function`
- `bitstring`
- `body`
- `case`
- `character`
- `clause`
- `comment`
- `comment_content`
- `escape_sequence`
- `float`
- `function_type`
- `guard`
- `if`
- `integer`
- `line_comment`
- `map`
- `map_content`
- `map_update`
- `maybe`
- `parenthesized_expression`
- `quoted_content`
- `receive`
- `record_content`
- `shebang`
- `sigil`
- `sigil_prefix`
- `sigil_suffix`
- `source`
- `string`
- `tripledot`
- `try`
- `tuple`
- `unary_operator`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
