# omega-nix

Language `omega-nix`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

25 templates over 75 query patterns, 23 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 7 |
| `calls` | yes | 2 |
| `data` | yes | 2 |
| `definitions` | yes | 5 |
| `imports` | yes | 2 |
| `references` | yes | 4 |
| `scopes` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.nix_binding_call_context` | Value | 1 |
| `definition.nix_field` | Value | 2 |
| `definition.nix_function` | Callable | 1 |
| `definition.nix_symbol` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.target_candidate` | `omega.pack.target` | 1 |
| `reference.nix_identifier_candidate` | `omega.pack.nix_identifier` | 2 |

### Regions

- `scope.lexical` (1)
- `scope.nix_lexical_scope` (2)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.field` | reference | 1 |
| `binding.nix_parameter` | reference | 2 |
| `binding.nix_variable` | reference | 2 |
| `binding.parameter` | reference | 1 |
| `binding.var` | reference | 1 |
| `call.nix_call` | call | 1 |
| `structured.entry` | reference | 2 |
| `import.import_expression` | binding | 1 |
| `value.nix_value` | reference | 1 |
| `reference.local` | reference | 1 |
| `reference.nix_identifier` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 32 of them.

Untouched:

- `_expression`
- `assert_expression`
- `block_comment`
- `doc_comment`
- `dollar_escape`
- `has_attr_expression`
- `if_expression`
- `let_attrset_expression`
- `line_comment`
- `parenthesized_expression`
- `path_fragment`
- `source_code`
- `with_expression`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
