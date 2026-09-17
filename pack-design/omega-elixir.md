# omega-elixir

Language `omega-elixir`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

42 templates over 79 query patterns, 19 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 9 |
| `calls` | yes | 7 |
| `definitions` | yes | 11 |
| `implements` | yes | 2 |
| `imports` | yes | 3 |
| `references` | yes | 6 |
| `scopes` | yes | 3 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.elixir_exception` | Value | 1 |
| `definition.elixir_function` | Callable | 3 |
| `definition.elixir_module` | Value | 1 |
| `definition.elixir_module_used_function_context` | Callable | 1 |
| `definition.elixir_struct` | Type | 1 |
| `definition.elixir_type` | Type | 2 |
| `definition.function` | Callable | 1 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `relation.protocol_implementation_candidate` | `omega.pack.protocol_implementation` | 1 |
| `reference.elixir_identifier_candidate` | `omega.pack.elixir_identifier` | 2 |
| `type.typespec_candidate` | `omega.pack.typespec` | 1 |

### Regions

- `scope.elixir_lexical_scope` (2)
- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.elixir_parameter` | reference | 2 |
| `binding.elixir_variable` | reference | 2 |
| `binding.import` | binding | 1 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `import_binding.elixir_import` | binding | 2 |
| `call.elixir_call` | call | 1 |
| `call.elixir_module_call_context` | call | 1 |
| `call.elixir_module_imported_function_direct_call_context` | call | 1 |
| `call.elixir_module_imported_function_literal_keyword_in_context` | call | 1 |
| `call.elixir_module_string_call_context` | call | 1 |
| `call.elixir_pipe` | call | 1 |
| `import.elixir_alias` | binding | 1 |
| `import.elixir_import` | binding | 1 |
| `import.elixir_require` | binding | 1 |
| `reference.elixir_module` | reference | 1 |
| `reference.elixir_module_attribute` | reference | 1 |
| `reference.elixir_use` | reference | 1 |
| `reference.local` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.literal` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 33 of them.

Untouched:

- `after_block`
- `anonymous_function`
- `bitstring`
- `block`
- `body`
- `catch_block`
- `else_block`
- `map`
- `map_content`
- `rescue_block`
- `source`
- `struct`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
