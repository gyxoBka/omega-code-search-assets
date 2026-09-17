# omega-yaml

Language `omega-yaml`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

73 templates over 77 query patterns, 19 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 73 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.yaml_document_depth1_context` | reference | 1 |
| `data.yaml_document_depth1_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth1_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth2_context` | reference | 1 |
| `data.yaml_document_depth3_context` | reference | 1 |
| `data.yaml_document_depth3_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth3_nested_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth3_nested_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth3_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_depth3_sequence_nested_context` | reference | 1 |
| `data.yaml_document_depth4_context` | reference | 1 |
| `data.yaml_document_depth5_context` | reference | 1 |
| `data.yaml_document_depth6_context` | reference | 1 |
| `data.yaml_document_identity_context` | reference | 1 |
| `data.yaml_document_identity_no_namespace_context` | reference | 1 |
| `data.yaml_document_named_mapping2_context` | reference | 1 |
| `data.yaml_document_named_nested2_context` | reference | 1 |
| `data.yaml_document_named_nested_sequence_mapping_context` | reference | 1 |
| `data.yaml_document_named_projected_sequence_context` | reference | 1 |
| `data.yaml_document_nested_route_backend_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth1_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth1_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth1_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth2_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_nested_named_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_nested_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth3_sequence_nested_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth4_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth5_context` | reference | 1 |
| `data.yaml_document_no_namespace_depth6_context` | reference | 1 |
| `data.yaml_document_no_namespace_top_sequence_item_field_context` | reference | 1 |
| `data.yaml_document_top_sequence_item_field_context` | reference | 1 |
| `relation.array_contains_value` | reference | 1 |
| `relation.document_value` | reference | 1 |
| `relation.object_contains_pair` | reference | 1 |
| `structured.entry` | reference | 19 |
| `value.array` | reference | 1 |
| `value.array_item` | reference | 1 |
| `value.comment` | reference | 1 |
| `value.document` | reference | 1 |
| `value.object` | reference | 1 |
| `value.object_key` | reference | 1 |
| `value.object_pair` | reference | 1 |
| `value.value` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.block_scalar` (1)
- `literal.boolean` (1)
- `literal.null` (1)
- `literal.number` (2)
- `literal.scalar` (1)
- `literal.string` (1)
- `literal.timestamp` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 36 node types. The Pack looks at 21 of them.

Untouched:

- `alias`
- `alias_name`
- `anchor`
- `anchor_name`
- `directive_name`
- `directive_parameter`
- `escape_sequence`
- `reserved_directive`
- `stream`
- `tag`
- `tag_directive`
- `tag_handle`
- `tag_prefix`
- `yaml_directive`
- `yaml_version`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
