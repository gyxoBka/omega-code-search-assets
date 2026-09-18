# What a Framework is, and what the host does with it

```text
source -> Grammar -> AST -> Pack -> normalized Omega IR -> Framework -> enriched graph
```

The dependency direction is strict: **Framework -> Pack -> Grammar**. A Grammar
provides syntax. A Pack provides framework-neutral normalized facts. A Framework
interprets those facts. **A Framework never parses an AST and never invents a
fact a Pack did not state.** (`README.md`.)

Everything below is a literal reading of
`crates/omega-semantic/src/framework/overlay.rs` and `rules.rs`.

## 1. A Framework asset is two programs in one file

`frameworks/<slug>/` holds `manifest.toml` and `semantic-v2.json`. That one JSON
carries **two** programs, and the host runs them differently:

| key | what it is | who runs it |
|---|---|---|
| `detection_rules` | the detector: does this project use this framework at all | `FrameworkRuleFile.rules`, the atom/row program in `rules.rs` |
| `rules` | the semantic overlay: what the framework's constructs mean | `OverlayProgram`, the match/join/output program in `overlay.rs` |

In a v1 file the detector lives in `rules` and there is no overlay. In v2 the
detector is `detection_rules` and `rules` is the overlay. Both are validated at
load; a malformed either half fails the whole asset.

`manifest.toml` declares `framework_selectors`, and `semantic-v2.json`'s
`selector` must be one of them.

## 2. What the overlay sees: a Pack emission, nothing more

The overlay matches `OverlayFact`, which is one Pack emission:

| part | where it comes from |
|---|---|
| `kind` | the template's `output_kind` |
| `name` | the template's evaluated `name` |
| `path` | the artifact's project-relative path |
| `span` | the template's `span_capture` range |
| `fields` | the template's `fields`, flattened to text |
| `attributes` | the template's `attributes`, flattened to text |
| `external` | the resolved external package and member, when the Pack's import resolved to one |

There is no AST, no resolved entity, no other file's IR. If a Pack does not say
it, the overlay cannot know it.

### The names a fact answers without any published field

`OverlayFact::field` resolves these itself, so a rule may read them from any
fact whatever the Pack published:

`path`, `file.path`, `source.path`, `path.value`, `path.dir`, `path.stem`,
`source.start`, `source.end`, `definition.name`, `enclosing.name`,
`external.package`, `external.member`, `row_kind`.

**`definition.name` is the emission's name.** Most rules need nothing beyond it,
the kind, and the path. Reach for a Pack `field` only when the answer is not
derivable from those and not reachable by a join.

## 3. Match clauses

A rule's `match` is a conjunction. Field and attribute clauses read the current
fact; join clauses bind one more fact and apply their own nested `where` to it.

| clause | reads |
|---|---|
| `fact_kind` | the emission's `output_kind`, exactly |
| `field_equals`, `field_present`, `field_in`, `field_not_in`, `field_prefix`, `field_not_prefix` | a field name, including the built-ins above |
| `attribute_equals` | an attribute name (spelled `attribute`, or `field` in older rules) |
| `path_glob` | a glob over the artifact path, or over a named field |
| `path_segment` | the path must contain none of the listed segments |
| `external_path_matches` | the resolved external package: `package`, `package_in`, `package_prefix` |
| `fact_join_by_field` | another fact whose `join_field` equals this one's `current_field`, with optional prefix stripping, `same_path`, and further `additional_field_equalities` |
| `fact_join_by_owner` | another fact by owner field |
| `fact_join_by_span` | another fact whose span is `same` as, or contains (`within`), this one's |
| `fact_join_by_path_ancestor` | another fact whose path is an ancestor |

Every join takes `fact_kind`, an optional `where` of nested clauses, and an
optional `bind` name. A bound fact is addressed in later templates as
`<bind>.<field>`; the most recent join is `joined.<field>`.

**`fact_join_by_span` with `within` is the join to reach for.** It relates a
member to its enclosing declaration using spans the Pack already emits, and it
needs no field on either side. `fact_join_by_field` is the only join that
requires a Pack to publish something.

## 4. Outputs

| output | what it produces |
|---|---|
| `entity_candidate` | an entity of `entity_kind`, addressed by a rendered `canonical_key`, with `attributes` |
| `relation_candidate` | a relation of `relation_kind` between two `Reference`s |

A `Reference` is `current` (the entity this rule emitted for this fact),
`by_canonical_key` (a rendered template), `by_field`, or `by_joined_field`.
Because both ends are rendered keys, **a relation emitted by one rule in one
file can point at an entity emitted by another rule in another file.** That is
how a route in one file reaches the handler declared in another.

A `canonical_key` template renders `{placeholder}` against, in order: the
rule's own computed attributes, `normalized_file_route` /
`normalized_pages_route` (the route derived from the artifact path under the
glob's routing root), `normalized_<attr>` (an attribute with HTTP path
parameters normalized so `:id`, `{id}` and `[id]` agree), then any fact field
including the built-ins, and `joined.x` / `<bind>.x` for joined facts.

An attribute value is a constant scalar, `{"kind":"field_ref","field":...}`,
`{"kind":"literal","value":...}` or
`{"kind":"normalize_route","source":...}`.

`evidence_class` defaults to `structurally_derived`.

## 5. What a Framework must not do

- **Never invent a fact.** If the Pack does not emit it, the answer is "not
  found". Adding a Pack field for one framework's convenience is the last
  resort, not the first: it costs bytes on every emission of that kind in every
  repository, whether or not the framework is present.
- **Never encode syntax.** Matching a tree shape is the Pack's job; the overlay
  sees kinds and names. If a rule needs to know that a call has three arguments
  in a particular order, that shape belongs in the Pack as a named fact.
- **Never key a rule to one language's spelling.** `call.function` is the same
  fact in every language now. A rule keyed to `call.kotlin_direct_call_context`
  answers for Kotlin alone and stops answering the moment that Pack is rewritten
  — which is exactly what happened to 1 380 rules.
- **Never write a rule whose only output restates its input.** An entity whose
  canonical key is its own name, with no attributes and no relation, adds
  nothing to the graph.

## 6. The vocabulary a Framework writes against

The Packs were rewritten to one cross-language vocabulary. These are the kinds a
rule should be keyed to, with the number of Packs emitting each:

| kind | what it is |
|---|---|
| `definition.function`, `definition.method`, `definition.procedure` | a callable |
| `definition.class`, `definition.interface`, `definition.enum`, `definition.type_alias` | a type |
| `definition.variable`, `definition.field`, `definition.constant`, `definition.property` | a value |
| `definition.namespace`, `definition.module` | a namespace |
| `definition.config_key`, `definition.config_table` | a key in a configuration or data file (json, json5, jsonc, yaml, toml) |
| `call.function`, `call.method`, `call.constructor` | a call |
| `import.module`, `import.symbol`, `binding.import_alias` | what a file pulls in |
| `reference.type`, `type_use.name` | a type named in source |
| `reference.annotation`, `reference.decorator`, `reference.attribute` | an annotation |
| `relation.implements`, `relation.depends`, `relation.data`, `relation.config`, `relation.handles`, `relation.tests` | the six relations the host knows |
| `scope.function_body`, `scope.class_body` | a region to join `within` |

A carrier (`definition.*_candidate`) is folded onto its declaration by the host
and is **not** visible to the overlay as a separate fact under that name; what
it carries arrives as an attribute `omega.pack.<name>` on the declaration.

## 7. What a Framework is judged by

1. Every rule matches something a Pack actually emits — `overlay_audit.py`
   reports zero dead rules.
2. Every rule's output is an entity or a relation a question could reach: *which
   route serves this path*, *which handler answers it*, *what does this
   component render*, *which model backs this table*.
3. No rule is keyed to one language's spelling of a construct that every
   language now spells the same way.
4. No Pack was asked for a field that a join could have supplied.
5. The detector says what it detects, in one or two rules, and does not
   duplicate the overlay.
