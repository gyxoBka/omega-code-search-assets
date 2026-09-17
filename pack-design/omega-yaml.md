# omega-yaml

Language `omega-yaml`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

7 templates over 7 query patterns, 7 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 4 |
| `references` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_key` | Config | 2 |
| `definition.anchor` | Value | 1 |
| `definition.tag_shorthand` | Value | 1 |

`definition.config_key` is two templates over two patterns, not two kinds: a key
set to a scalar carries the value as an attribute, a key set to a mapping, a
sequence, an alias or a block scalar does not.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.data` | data | 1 |
| `reference.anchor` | reference | 1 |
| `reference.tag` | reference | 1 |

### Attributes

| attribute | on | what it answers |
|---|---|---|
| `value` | `definition.config_key` (scalar form) | what this key is set to |
| `prefix` | `definition.tag_shorthand` | what the `%TAG` handle expands to |

Nothing else is stored. There are no constant attributes.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 36 node types. The Pack looks at 18 of them:
`block_mapping_pair`, `flow_pair`, `flow_node`, `block_node`, `plain_scalar`,
`double_quote_scalar`, `single_quote_scalar`, `flow_mapping`, `flow_sequence`,
`block_sequence_item`, `alias`, `alias_name`, `anchor`, `anchor_name`, `tag`,
`tag_directive`, `tag_handle`, `tag_prefix`.

Untouched, and why:

- `document`, `stream` — a document is a place, not a name. Emitting one would
  mean naming it with its own bytes (Defect D) or with a constant (Defect J).
  See *Still to decide*.
- `block_mapping`, `block_sequence` — the containers. The tree already holds
  containment and the host derives the qualified name from the nesting.
- `block_scalar` — the body of a `run: |` step or a ConfigMap file. Reached as
  the value of the compound-key pattern, deliberately not stored: it is a
  script, and a name is not a place to put one.
- `boolean_scalar`, `integer_scalar`, `float_scalar`, `null_scalar`,
  `string_scalar`, `timestamp_scalar` — the typed children of `plain_scalar`.
  The scalar's text is taken from `plain_scalar`; which of the six the grammar
  chose is the implicit typing the Pack does not claim to infer (guard 6).
- `comment` — names nothing a question resolves to.
- `escape_sequence` — the Pack does not decode escapes.
- `yaml_directive`, `yaml_version` — `%YAML 1.2` states the spec revision the
  file is written against, which is not a name anything in a repository
  resolves to.
- `reserved_directive`, `directive_name`, `directive_parameter` — reserved by
  the spec, with no defined meaning to state.

## What is wrong with it

These are the defects of the Pack this one replaces: **65 templates over 67
patterns, 7 guards**, all under one capability, `data`, and all of them
mentions. It declared nothing at all.

**Thirty-five of the 65 templates were the ancestor path of a key, one
template per shape of ancestry.** `data.yaml_document_depth1_context` through
`data.yaml_document_depth6_context`, each in a `_no_namespace_` variant, plus
`_sequence_item_field_`, `_nested_sequence_item_field_`, `_sequence_nested_`,
`_named_projected_sequence_`, `_nested_route_backend_` — the last one a
Kubernetes Ingress written out as a tree shape. Their patterns nested
`block_mapping_pair` inside `block_node` inside `block_mapping` up to eight
deep, and their `fields` were named `a0` … `a7`: the keys on the path from the
document root. This is Defect E in its purest form. The depth-7 pattern costs
one match per tuple of seven pairs on a root-to-leaf path, and a Kubernetes
manifest or a Helm values file is exactly the input that maximises it. The
tree already holds that path, and the host already derives it from the nesting
of the declarations — which the old Pack never made, because it declared
nothing.

**Nineteen more were `structured.entry`**, the generic depth-N pair under
another spelling, with the same `a0`…`a6` fields.

**Three kinds were `relation.*` that the host does not know.**
`relation.document_value`, `relation.object_contains_pair`,
`relation.array_contains_value` are none of the six the host matches exactly,
so each arrived as a plain reference — indistinguishable from the other 62
mention templates, all of which also arrived as plain references. Forty-eight
distinct kinds, one occurrence kind.

**Eight templates named an emission with a container node.** `value.document`
named itself from `(document)`, `value.object` from `(block_mapping)`,
`value.array` from `(block_sequence)`, and the three `relation.*_contains_*`
templates named themselves from their container too. A `capture_ref` name is
the capture's source text, so a 400-line Kubernetes manifest was stored as a
name once for the document, again for every mapping in it, and again for every
sequence. This is where a YAML file's contribution to the row count came from.

**Two guards out of seven gave a single token as the reason** —
`yaml_schema_specific_implicit_scalar_typing_not_inferred`,
`yaml_alias_merge_and_tag_resolution_not_semantically_expanded` — and two more
were a sentence of the same underscores. They are generator labels, not
limitations a human can act on. Both facts are now stated in English, in
guards 4 and 6.

**The two names YAML actually has were not stated at all.** `anchor_name` and
`alias_name` were among the 15 untouched node types. `&defaults` declares a
name and `*defaults` refers to it — the one link in the language that resolves
within a file — and the Pack indexed neither. Nor `tag`, `tag_directive`,
`tag_handle` or `tag_prefix`, which is the only syntax in which a YAML file
names something outside itself; a CloudFormation template's `!Ref` and
`!GetAtt` were invisible.

**An earlier sweep had already removed 8 `literal.*` templates** from this Pack
(00-INDEX.md, *the literal-marker rule is narrower than the brief said*): the
Pack emits no `reference_context.*` kind, so they suppressed nothing.

## What it should extract

YAML is where a project is configured and where its infrastructure is
described. The questions asked of a YAML file are *where is this setting
declared and to what*, *what does this file list*, *what is reused from what*,
and *where is this tag used*.

| what | node | emitted as | family |
|---|---|---|---|
| a key set to a scalar | `block_mapping_pair`, `flow_pair` via `flow_node` scalars | `definition.config_key` + `value` attribute | Config |
| a key set to a mapping, sequence, alias or block scalar | same, value `block_node` / `flow_mapping` / `flow_sequence` / `alias` | `definition.config_key`, no value | Config |
| a scalar listed in a sequence | `block_sequence_item`, `flow_sequence` via `flow_node` | `relation.data` | data occurrence |
| an anchor `&defaults` | `anchor` via `anchor_name` | `definition.anchor` | Value |
| an alias `*defaults`, incl. `<<:` | `alias` via `alias_name` | `reference.anchor` | reference |
| a tag `!Ref`, `!include` | `tag`, excluding `!!` core tags | `reference.tag` | reference |
| a `%TAG` shorthand | `tag_directive` via `tag_handle` | `definition.tag_shorthand` + `prefix` | Value |
| the document, mapping, sequence, item, comment | — | nothing | — |
| containment | — | nothing; the host derives it from nesting | — |
| a particular key spelling (`kind`, `steps`, `image`) | — | nothing; that is a framework overlay | — |

With the keys declared, a nested key carries its containers through the host's
`within:` namespace segment, which is the same information the 35 depth
patterns encoded and costs one match per pair instead of one per tuple. With
`anchor_name` and `alias_name` stated, YAML's one internal link resolves.

## A cross-asset consequence, recorded not papered over

This is the same finding 00-INDEX.md records for omega-json, an order of
magnitude larger. Ten framework overlays read this Pack's output, and the ones
that read the depth-context kinds now match nothing:

| overlay | rules reading YAML facts | of |
|---|---|---|
| `omega-framework-kubernetes-config` | 153 | 153 |
| `omega-framework-gitlab-ci` | 47 | 48 |
| `omega-framework-github-action` | 32 | 34 |
| `omega-framework-unity` | 33 | 56 |
| `omega-framework-android` | 17 | 21 |
| `omega-framework-maui` | 9 | 12 |
| `omega-framework-openapi-specification-v3` | 73 | 73 |
| `omega-framework-tauri`, `-flutter`, `-caddyfile` | 8, 6, 4 | 14, 20, 28 |

All 153 kubernetes-config rules match on `data.yaml_document_*_context` or
`structured.entry` and read the fields `a0`…`a6`, `doc_kind`, `doc_name`,
`sequence_key`, `owner_key` — the ancestor key path. That is Defect E written
into a cross-asset contract, and restoring it would restore the reason YAML and
JSON files were the largest producers of rows in the index. It is not restored.
The overlays have to be rewritten against `definition.config_key`, whose
`within:` namespace segment carries the same path. Until that is done, those
rules match nothing. This belongs in `00-INDEX.md`; it is not this Pack's
problem alone.

## Still to decide

1. **Multi-document files.** A file of several `---`-separated documents has
   several independent top-level mappings, and their keys are stated as
   siblings. A `scope.document` region would separate them, but a scope
   template with no `name` takes its span capture's own text as the name —
   the whole document, which is Defect D — and a literal name is Defect J.
   Left out, and stated in guard 3. The clean fix is a host that lets a scope
   be nameless; that is a host question, not a Pack one.
2. **A key written with no value.** `volumes:` with nothing after it is not
   declared, because a query cannot ask for the absence of a field and a
   pattern that matched the key alone would declare every other key twice.
   Guard 3 says so. If it turns out to matter, the fix is a host-side
   "declare only if no other template claimed this span", not another pattern.
3. **The tag's spelling.** `reference.tag` and `definition.tag_shorthand` are
   both stored as written, with the `!` sigils intact, so `!e!thing` and the
   handle `!e!` do not resolve onto each other. Stripping the sigils would not
   make them resolve either, and as-written is what a person greps for.
   Revisit if `%TAG` turns out to be used anywhere real.
