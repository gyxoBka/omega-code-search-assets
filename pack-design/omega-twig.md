# omega-twig

Language `omega-twig`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

25 templates over 43 query patterns, 28 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 2 |
| `data` | yes | 7 |
| `definitions` | yes | 2 |
| `imports` | yes | 6 |
| `scopes` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.twig_block` | Value | 1 |
| `definition.twig_macro` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `call.twig_candidate` | `omega.pack.twig` | 1 |
| `import.twig_candidate` | `omega.pack.twig` | 1 |

### Regions

- `scope.twig_apply` (1)
- `scope.twig_block_boundary` (1)
- `scope.twig_macro` (1)
- `scope.twig_with` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.symbol` | reference | 1 |
| `binding.twig_for` | reference | 1 |
| `binding.twig_macro_parameter` | reference | 1 |
| `binding.twig_set` | reference | 1 |
| `call.twig_function` | call | 1 |
| `data.twig_attribute` | reference | 1 |
| `data.twig_block_end` | reference | 1 |
| `data.twig_filter` | reference | 1 |
| `data.twig_macro` | reference | 1 |
| `data.twig_template` | reference | 1 |
| `data.twig_test` | reference | 1 |
| `data.twig_variable` | reference | 1 |
| `import.twig_from` | binding | 1 |
| `import.twig_from_path` | binding | 1 |
| `import.twig_import` | binding | 1 |
| `import.twig_path` | binding | 1 |
| `import.twig_template_relation` | binding | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 47 node types. The Pack looks at 30 of them.

Untouched:

- `argument`
- `argument_name`
- `argument_value`
- `arguments`
- `array`
- `arrow_function`
- `binary_expression`
- `binary_operator`
- `content`
- `hash_key`
- `hash_value`
- `if_statement`
- `output_directive`
- `statement_directive`
- `ternary_expression`
- `test_expression`
- `unary_expression`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
