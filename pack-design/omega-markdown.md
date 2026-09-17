# omega-markdown

Language `omega-markdown`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

32 templates over 52 query patterns, 21 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 29 |
| `definitions` | yes | 2 |
| `references` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.markdown_link_reference` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.markdown_candidate` | `omega.pack.markdown` | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.markdown_pipe_table` | reference | 1 |
| `data.markdown_pipe_table_header` | reference | 1 |
| `data.markdown_pipe_table_row` | reference | 1 |
| `semantic_hint.markdown_code_block` | reference | 1 |
| `semantic_hint.markdown_heading` | reference | 6 |
| `semantic_hint.markdown_lexical_role` | reference | 15 |
| `semantic_hint.markdown_link_label` | reference | 1 |
| `semantic_hint.markdown_literal` | reference | 1 |
| `structured.entry` | reference | 2 |
| `reference.markdown_link_target` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 51 node types. The Pack looks at 46 of them.

Untouched:

- `document`
- `entity_reference`
- `numeric_character_reference`
- `pipe_table_align_left`
- `pipe_table_align_right`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
