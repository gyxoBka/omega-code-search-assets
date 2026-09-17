# omega-xml

Language `omega-xml`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

21 templates over 27 query patterns, 10 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `data` | yes | 17 |
| `definitions` | yes | 2 |
| `references` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.xml_attribute_decl` | Value | 1 |
| `definition.xml_element_decl` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `data.xml_element_two_attribute_context` | reference | 1 |
| `relation.document_contains_element` | reference | 1 |
| `relation.element_contains_attribute` | reference | 1 |
| `relation.element_contains_child` | reference | 1 |
| `relation.empty_element_contains_attribute` | reference | 1 |
| `semantic_hint.xml_structural_attribute` | reference | 1 |
| `structured.entry` | reference | 7 |
| `value.attribute` | reference | 1 |
| `value.document` | reference | 1 |
| `value.element` | reference | 1 |
| `value.text` | reference | 1 |
| `reference.xml_entity` | reference | 1 |
| `reference.xml_parameter_entity` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 67 node types. The Pack looks at 14 of them.

Untouched:

- `attlist_decl`
- `attlist_name`
- `attribute_type`
- `cdata`
- `cdata_sect`
- `char_ref`
- `children`
- `comment`
- `conditional_sect`
- `content_spec`
- `cp`
- `default_decl`
- `doctype`
- `doctype_decl`
- `element_choice`
- `element_seq`
- `encoding_decl`
- `end_tag`
- `entity_decl`
- `entity_def`
- `entity_value`
- `enumeration`
- `external_id`
- `external_subset_decl`
- `ge_decl`
- `ignore`
- `ignore_sect`
- `ignore_sect_contents`
- `include_sect`
- `langcode`
- `mixed`
- `ndata_decl`
- `ndata_name`
- `nm_token`
- `notation_decl`
- `notation_name`
- `notation_type`
- `notation_type_name`
- `pe_decl`
- `pe_def`
- `pi_target`
- `processing_instructions`
- `prolog`
- `pubid_char`
- `pubid_literal`
- `public_id`
- `reference`
- `standalone_decl`
- `sub_code`
- `system_literal`
- `text_decl`
- `version_info`
- `xml_decl`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
