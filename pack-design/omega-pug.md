# omega-pug

Language `omega-pug`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

15 templates over 57 query patterns, 29 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 2 |
| `calls` | yes | 2 |
| `data` | yes | 3 |
| `definitions` | yes | 2 |
| `imports` | yes | 3 |
| `references` | yes | 1 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.pug_block` | Value | 1 |
| `definition.pug_mixin` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `import.pug_candidate` | `omega.pack.pug` | 1 |

### Regions

- `scope.lexical` (1)
- `scope.pug_construct` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.pug_iteration` | reference | 1 |
| `binding.pug_mixin_parameter` | reference | 1 |
| `call.pug_filter` | call | 1 |
| `call.pug_mixin` | call | 1 |
| `data.pug_attribute` | reference | 1 |
| `data.pug_attribute_value` | reference | 1 |
| `data.pug_tag` | reference | 1 |
| `import.pug_path` | binding | 2 |
| `reference.pug_block` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 46 node types. The Pack looks at 38 of them.

Untouched:

- `attribute_modifier`
- `children`
- `doctype_name`
- `else`
- `pipe`
- `quoted_javascript`
- `self_close_slash`
- `source_file`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
