# omega-framework-openapi-specification-v3

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 2 detection rules. **11 can match, 0 cannot.**
`key_collisions.py` reports nothing.

Selector: `framework:openapi-specification-v3`. Maturity: `semantic-overlay-full`.
Languages: json, yaml — the whole surface is `definition.config_key` (the key,
in both Packs) and `relation.data` (a scalar listed in a sequence or array).

| entity_kind | outputs | relation_kind | outputs |
|---|---|---|---|
| `ApiDocument` | 5 | `declared_in` | 4 |
| `ApiComponent` | 3 | `contains` | 2 |
| `ApiOperation` | 2 | `references` | 2 |
| `SecurityScheme` | 2 | `identified_by` | 1 |
| `ApiOperationId` | 1 | `responds` | 1 |
| `PathItem` | 1 | `secured_by` | 1 |
| `Response` | 1 | `tagged` | 1 |
| `Tag` | 1 | | |
| `Webhook` | 1 | | |

Clause vocabulary in use: `fact_join_by_span` (`within`) x20, `field_equals`
x18, `fact_kind` x11, `field_in` x10, `field_prefix` x7, `field_present` x3.
**`fact_join_by_field` no longer appears anywhere in the file.**

Fields read: `definition.name`, `definition.container` and `path` (built-ins),
plus `value` — the config key's scalar, which omega-json and omega-yaml now
publish as a *field* and not only as an attribute. That single Pack change is
what this pass is built on.

## What was wrong with it

The file inherited from the previous wave was already all-live (6 rules, 6
live), so this pass is not a port. It was wrong in four measured ways.

**1. The one `fact_join_by_field` was the n-squared shape, and it was
unnecessary.** `openapi3.document` matched the key `openapi` and then joined

```json
{"kind": "fact_join_by_field", "fact_kind": "definition.config_key",
 "current_field": "path", "join_field": "path", "same_path": true,
 "where": [{"kind": "field_equals", "field": "definition.name", "value": "info"}]}
```

`current_field: path` joined to `join_field: path` is a full cross product over
the file: it pushes a binding for **every** key named `info` anywhere in the
artifact, in any document of a YAML stream, at any depth. It was used only as a
gate ("this file has an `openapi` key and an `info` key"), so the cross product
cost bindings rather than junk entities — but it is the exact shape that minted
n squared objects in omega-framework-kubernetes-config, and it was the only
reason the rule needed a join at all. It is deleted: with `value` published as a
field, `field_prefix value "3."` on the `openapi` key is a stronger gate, it
needs no join, and it also states the spec version, which the old rule threw
away. **Count after the rewrite: 0 joins of the `path`-to-`path` shape, 0
`fact_join_by_field` clauses of any shape.**

**2. Six ancestor joins existed only to read the immediate parent key, which is
a built-in field.** `definition.container` (contract §2) is the innermost
enclosing definition — for OpenAPI that is exactly the parent key — and it is
computed by the host from spans, so it is document-scoped for free. Measured
with `dump_call_emissions` on both Packs: the `get` key under
`paths: /pets/{petId}:` has `definition.container = /pets/{petId}` in YAML and
in JSON alike. Four `within` ladders (`openapi3.operation`'s path-item bind,
and the `responses`/`tags`/`security` parent tests in the three operation-child
rules) collapse to one `field_equals`/`field_prefix` each.

**3. Two of the three documented "gaps" were no longer true, and one of them
was a whole section of OpenAPI missing from the graph.** The file asserted that
a config key's value is attribute-only and therefore that `$ref`, `operationId`
and every other value-bearing construct "cannot be named or related here".
omega-json and omega-yaml now publish `value` in `fields` (measured: `$ref:
'#/components/schemas/Pet'` arrives as `value=#/components/schemas/Pet`,
**unquoted, in both Packs** — so it is usable directly in a canonical key). The
second gap said components could not be told apart from keys nested inside
them, because `within` reaches every ancestor. `definition.container` reaches
exactly one level and settles it. Between them these two facts were costing the
graph **every schema, every reusable response/parameter/header/link/callback,
every declared security scheme, every `$ref` edge and every `operationId`** —
which is to say, the entire "what shape does this endpoint speak" half of an
API description.

**4. Attribute naming was one output away from the §3k hazard.**
`openapi3.operation` set an attribute literally named `path` to the route
(`/pets/{petId}`) and then needed a second attribute `document` to get at the
artifact path, because `resolve_placeholder` consults the rule's attributes
before the fact. The route attribute is now named `route`, and `path` means the
file again.

Grown from 6 rules to 11. The five new rules are `openapi3.component`,
`openapi3.component.ref`, `openapi3.component.security_scheme`,
`openapi3.operation.operation_id` and `openapi3.operation.ref`; each is named in
the table below with the question it answers.

### Measured, on a two-document YAML stream

`dump_call_emissions` over a 989-byte file holding two `---`-separated OpenAPI
documents (document 1: `/pets/{petId}` get + post, a webhook, components;
document 2: `/things` delete) gives 58 facts. Running the rewritten program over
them yields **4 ApiOperations — 3 from document 1, 1 from document 2 — and no
others**: no cross-document pairing, because every remaining join is a span
join and a span cannot straddle a `---`. The same fixture in JSON gives the same
keys. Every relation end rendered is a key some rule in the same run minted;
nothing dangles.

`definition.config_document` is deliberately **not** used. It exists only in
omega-yaml (omega-json emits no such fact), so any rule entered from it would
answer for YAML specs and not for JSON ones, and this Framework's two languages
have to agree. It is also not needed: an OpenAPI Document is by definition a
single JSON or YAML document (OAS 3.1 §4.1), so a multi-document stream is not a
spelling this Framework has to reconcile, and every sibling-reaching question
here is answered by `definition.container` instead, which works in both
languages.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files are OpenAPI 3 documents, and at which spec version? | `definition.config_key` named `openapi` whose **`value`** starts `3.` (json, yaml) | entity `ApiDocument` `openapi3:document:{document}`, attribute `spec_version` |
| Which operations does this API expose, and under which path? | `definition.config_key` whose name is an HTTP method, whose `definition.container` starts `/`, `within` a key named `paths` | entities `ApiOperation` `openapi3:operation:{method}:{normalized_route}` and `PathItem` `openapi3:path:{normalized_route}`; relation `contains` PathItem -> ApiOperation |
| Which document declares this operation / component / security scheme? | the same fact's `path` | relation `declared_in` -> `ApiDocument` (each such rule also mints the `ApiDocument` so the end can never dangle) |
| Which operation is `getPet`? | `definition.config_key` named `operationId` with a `value`, whose `definition.container` is an HTTP method, `within` the path item | entity `ApiOperationId` `openapi3:operation_id:{operation_id}`; relation `identified_by` ApiOperation -> ApiOperationId |
| What does this operation answer with? | `definition.config_key` whose name is a status code or `default` and whose `definition.container` is `responses`, `within` the method key and the path item | entity `Response` `openapi3:response:{method}:{normalized_route}:{status}`; relation `responds` ApiOperation -> Response |
| Which operations belong to this tag? | `relation.data` (a sequence/array scalar) whose `definition.container` is `tags`, `within` the method key and the path item | entity `Tag` `openapi3:tag:{tag}`; relation `tagged` ApiOperation -> Tag |
| What secures this operation? | `definition.config_key` whose `definition.container` is `security`, `within` the method key and the path item | entity `SecurityScheme` `openapi3:security_scheme:{scheme}`; relation `secured_by` ApiOperation -> SecurityScheme |
| Where is the security scheme `apiKey` declared? | `definition.config_key` whose `definition.container` is `securitySchemes`, `within` a key named `components` | the **same** `SecurityScheme` key; relation `declared_in` -> ApiDocument |
| Which reusable components does this document declare? | `definition.config_key` whose `definition.container` is one of the nine component sections, `within` a key named `components` | entity `ApiComponent` `openapi3:component:#/components/{section}/{component}` |
| Which schemas does this operation use? | `definition.config_key` named `$ref` with a `value`, `within` the method key and the path item | relation `references` ApiOperation -> `ApiComponent` `openapi3:component:{ref}` |
| Which components does this component reference? | `definition.config_key` named `$ref` with a `value`, `within` a component (a key whose `definition.container` is a component section, itself `within` `components`) | relation `references` ApiComponent -> ApiComponent |
| Which webhooks does this API declare, and with which method? | `definition.config_key` whose name is an HTTP method, `within` a key named `webhooks` | entities `Webhook` `openapi3:webhook:{event}` and `ApiOperation` `openapi3:operation:{method}:webhooks/{event}`; relations `contains`, `declared_in` |

**The `$ref` graph closes because both ends render the same string.** A
component declaration is keyed
`openapi3:component:#/components/{section}/{component}` — built from
`definition.container` and `definition.name` — and a reference is keyed
`openapi3:component:{ref}` from the `value` field. For `components/schemas/Pet`
and `$ref: '#/components/schemas/Pet'` both render
`openapi3:component:#/components/schemas/Pet`. This only works because the Packs
strip the quote bytes before publishing `value`; a raw `"#/..."` could never
have met the declaration's form, since a canonical key template has no strip
(brief §3j).

**Key spaces and their single kind** (checked with `key_collisions.py`, which
reports nothing): `openapi3:document:*` is always `ApiDocument`,
`openapi3:operation:*` always `ApiOperation`, `openapi3:component:*` always
`ApiComponent`, `openapi3:security_scheme:*` always `SecurityScheme`. Four
rules mint `ApiDocument` and three mint `ApiComponent`; they agree on the kind,
so the first rule by id supplies the attributes and nothing is discarded.
`securitySchemes` is deliberately absent from `openapi3.component`'s section
list: a declared scheme belongs in the `openapi3:security_scheme:` space where
an operation's `security` reference can reach it, and putting it in both spaces
would mean two entities for one construct.

`{normalized_route}` is the contract's route normalization, so `/pets/{petId}`
shares an identity with a route the express or fastapi overlay emits for the
same path — which is the point: **the OpenAPI document and the implementation
meet at `http:`/`openapi3:` route keys, not at a file name.** `ApiOperationId`
is the second meeting point, for generated servers and clients that name their
handler after the `operationId`.

## A field only the Pack can supply

**Nothing.** The request the previous wave filed here — omega-json and
omega-yaml must publish `definition.config_key`'s scalar as a *field* and not
only as an attribute — has landed, and it is what five of the eleven rules are
built on. Measured 2026-09-18 on both Packs: `fields.value` is present on the
scalar/string pair templates, and is quote-stripped.

No further Pack field is asked for. Everything else this Framework reads is a
built-in: `definition.name`, `definition.container`, `path`.

## Still to decide

1. **A component's grandparent is still not reachable, and one shape rides on
   it.** `definition.container` gives exactly one level and `within` gives all
   of them; there is no two-level test. So `openapi3.component` says *a key
   whose parent is `schemas`/`responses`/… and which is somewhere under
   `components`*. For every real spec that is the component. The one shape it
   over-accepts is `components/pathItems/<name>/<method>/responses/<code>`: the
   status-code key's parent is `responses` and it is under `components`, so it
   is minted as `openapi3:component:#/components/responses/200`. `pathItems`
   components are rare and the junk entity is inert (no relation sources at it
   except a `declared_in` to the document). Recorded rather than papered over.
   The host-side fix is still the cheap one: a third `SpanRelation`, `nearest`,
   on `fact_join_by_span`. That belongs in `00-INDEX.md`, not here — every
   overlay over json/yaml/toml wants it.
2. **A webhook operation has no `operationId` edge.**
   `openapi3.operation.operation_id` keys the operation end on the enclosing
   path item, and a webhook has an event name instead. Adding a second rule for
   the webhook spelling is three lines of match and would mint into the same
   `openapi3:operation_id:` space; it was left out because webhooks with
   `operationId` are rare enough that the rule would be mostly unexercised.
   Revisit if a 3.1-heavy corpus shows otherwise.
3. **`servers: - url:` is not stated.** The value is now reachable (`url`'s
   `definition.container` is `servers`), but there is no gate: a bare
   `servers`/`url` pair is common in non-OpenAPI YAML, and this Framework has no
   cross-language way to say *at the top level of an OpenAPI document*
   (`definition.config_document` is omega-yaml only; see above). One rule would
   mint a `Server` for every CI file in the repository that lists a server URL.
   Left unstated rather than stated wrongly. If a `nearest` span relation lands,
   the gate becomes *`servers` whose parent is the document root*, and this is
   one rule.
4. **Media types.** `content: application/json:` would answer *what does this
   operation consume and produce*, but a media type is an open set and only
   `field_prefix` can test one, so it would take one rule per top-level type
   (`application/`, `text/`, `image/`, …). Not worth nine rules; revisit if a
   `field_matches` clause ever exists.
5. **Callbacks.** A callback nests a path-item-shaped object inside an
   operation, so a status code inside `callbacks/<name>/<expr>/post/responses`
   is `within` a method key and `within` a path item, and
   `openapi3.operation.response` attributes it to the enclosing path as well as
   the callback's own. `definition.container` does not help here — the parent
   really is `responses`. With `nearest` this becomes exact; until then the
   mis-attribution is recorded rather than hidden, and no dedicated callback
   rule is written.
