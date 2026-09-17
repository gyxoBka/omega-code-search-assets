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

## What is wrong with it

**Sixteen of 21 templates say only that one node is inside another.** Six
families of "context" pattern hard-code a tree shape two and three edges deep
-- `parent_child`, `ancestor_grandchild`, `depth3`, `two_attr`,
`coordinate_entries`, `parent_child_text` -- and `structure-v2` adds
`(document (element))`, `(element (start_tag (attribute)))`,
`(element (element))` and `(element (empty_elem_tag))`. The tree already states
containment, and each of these costs a match per tuple: the depth-3 pattern
matches once for every (ancestor, child, intermediate, descendant) combination
in the document. On a deeply nested file that is cubic.

**The four `relation.*_contains_*` kinds are not relations.** The host knows
`relation.implements`, `.tests`, `.depends`, `.config`, `.data` and `.handles`.
`relation.document_contains_element` matches none of them and arrives as a
plain reference, indistinguishable from the seven `structured.entry` mentions
and the four `value.*` ones. Thirteen mention kinds, one occurrence kind.

**Four templates store the file as a name.** `value.document` is named from
`(document) @data.document` and `value.text` from `(text) @data.text`, and the
`relation.*_contains_*` templates are named from the container capture. A
capture_ref name is the capture's source text, so the bytes of an element are
written once as its own value, again as its parent's child, and again inside
the document -- the file repeated once per level of nesting. Nothing can be
asked of a name that is a whole document.

**Almost nothing in the file is declared.** Two declarations: `element_decl`
and `attribute_def`, both DTD, both routed to Value. The elements and
attributes that an XML file actually consists of are emitted as references --
references to nothing, since a reference resolves against declarations and
there are none to resolve against. An agent asking where `<connectionStrings>`
is configured gets no declaration back.

**The whole DTD and prolog are ignored.** `entity_decl`, `ge_decl`, `pe_decl`,
`notation_decl`, `attlist_decl`, `doctype_decl`, `external_id`,
`processing_instructions`, `cdata_sect`, `comment`, `xml_decl` -- 53 of 67 node
types. Two of them, `entity_ref` and `pe_reference`, are already emitted as
references, so the Pack references entities whose declarations it never
records: the one resolvable link XML has, left half-built.

## What it should extract

XML is the file format of configuration, project definitions and schemas. The
questions asked of it are *where is this element configured*, *what does this
attribute set*, *what does this document depend on*, and *what does this
entity or notation refer to*.

| what | node | emitted as | family |
|---|---|---|---|
| an element | `element`, `empty_elem_tag` via `tag_name` | `definition.config.element` | Config |
| its attributes | `attribute` | `config_candidate` carrier on the element | attribute on the declaration |
| a leaf element's text | `text` | the element's own value attribute, not a mention | -- |
| an element's extent | `element` | `scope.element` | region |
| the document's root | `doctype` | `reference.relation.depends` | occurrence |
| an external DTD or notation | `external_id` via `system_literal`, `pubid_literal` | `reference.relation.depends` | occurrence |
| a processing instruction | `pi_target` | `definition.config.instruction` | Config |
| DTD element declaration | `element_decl` via `element_name` | `definition.schema_element` | Value* |
| DTD attribute declaration | `attribute_def` via `attribute_name` | carrier on the element declaration | attribute |
| DTD attribute list | `attlist_decl` via `attlist_name` | `reference.relation.data` on the element | occurrence |
| general entity declaration | `ge_decl` | `definition.entity` | Value |
| parameter entity declaration | `pe_decl` | `definition.entity` | Value |
| notation declaration | `notation_decl` via `notation_name` | `definition.notation` | Value |
| `&name;` | `entity_ref` | `reference.entity` | reference |
| `%name;` | `pe_reference` | `reference.entity` | reference |
| CDATA and comments | `cdata_sect`, `comment` | nothing | -- |

\* the DTD declarations are the one place XML declares a shape. They are not
types in the host's vocabulary and `definition.schema_element` lands in Value,
which is right: a DTD element declaration names a permitted element, and the
question asked of it is which element it constrains -- answered by the
`attlist_decl` and `entity_ref` occurrences pointing at it.

With the elements declared, `entity_ref` and `pe_reference` finally resolve,
and containment is answered by `scope.element` regions rather than by a pattern
per depth. The Pack goes from 27 patterns to roughly a dozen, each rooted at
one node, and stops naming anything with a document.

The entity name is an anonymous token in this grammar, so `ge_decl` and
`pe_decl` are captured whole and named by `split` + `first` over their text --
the expression vocabulary the runtime already has and no Pack yet uses.

## Still to decide

1. Whether an element occurrence should be a declaration in *every* XML file
   or only where it names something -- an `<item>` repeated 400 times in a list
   declares 400 entities with one name. Provisionally: declare it, and let the
   resolver merge by name as it does elsewhere; revisit against the row count.
2. Whether attribute values that are paths (`.xsd`, `.dll`, `Include=`) should
   be `relation.depends` occurrences. That is close to a framework overlay, and
   the contract says a language Pack states syntax; left out.
