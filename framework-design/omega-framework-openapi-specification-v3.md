# omega-framework-openapi-specification-v3

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

6 overlay rules, 2 detection rules. **6 can match, 0 cannot.**

Selector: `framework:openapi-specification-v3`. Maturity: `semantic-overlay-full`.
Languages: json, yaml — the whole surface is `definition.config_key` (the key,
in both Packs) and `relation.data` (a scalar listed in a sequence or array).

| entity_kind | rules | relation_kind | rules |
|---|---|---|---|
| `ApiOperation` | 2 | `contains` | 2 |
| `ApiDocument` | 1 | `declared_in` | 2 |
| `PathItem` | 1 | `responds` | 1 |
| `Response` | 1 | `tagged` | 1 |
| `Tag` | 1 | `secured_by` | 1 |
| `SecurityScheme` | 1 | | |
| `Webhook` | 1 | | |

Clause vocabulary in use: `fact_join_by_span` (`within`) x16, `field_equals`
x10, `fact_kind` x6, `field_in` x6, `field_prefix` x4, `fact_join_by_field` x1.
Fields read: `definition.name` and `path` — both built-ins. No rule reads a
published field or attribute, so nothing here can be broken by a Pack's field
budget.

## What was wrong with it

**73 rules, every one of them dead**, and they had been dead since the Pack
rewrite. Concretely:

- **73 of 73 matched `structured.entry`**, a kind no Pack emits. json and yaml
  now emit `definition.config_key`.
- **73 of 73 read `attribute role`** (`yaml_depth3_pair`, `json_depth7_pair`,
  `yaml_owned_pair`, …). That attribute was the old generator's name for *how
  deep in the tree this pair sits*. Nothing publishes it.
- **64 of 73 read `a0`…`a7`**, the ancestor key path published one field per
  nesting depth, or `owner_key`/`grandparent_key`/`root_key`/`sequence_key`/
  `item_key`/`array_key` — the same idea under other names. All gone: nesting is
  now spans, and a span join reads it.
- **The file was 73 rules for roughly 12 constructs.** `openapi3.ref.any` was
  spelled 9 times (`yaml_depth3`, `yaml_depth4`, `yaml_depth7`, `yaml_depth8`,
  `json_depth3`…`json_depth7`) because the old Pack needed one pattern per
  depth; `openapi3.component.*` was 10 sections x 2 formats = 20 rules;
  `response-links`/`response-headers`/`response-examples` were 9 rules for 3
  constructs; `operation-meta` was 6 rules for 3 keys; `operation-callback` was
  5 rules for one. Depth and format are not part of what a rule means, so all of
  that collapses.
- **32 rules emitted no relation at all**, and 22 of those restated their
  input: every `openapi3.component.<section>.*` rule and both
  `openapi3.webhook.*` rules emitted an entity whose canonical key was the key
  it had just matched, with nothing pointing at it and nothing pointed at. An
  entity no relation reaches is not an answer.

The new file states the same six questions in 6 rules, matching two kinds, with
no depth, no format and no language spelling anywhere in it. 825 lines replace
4 983.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files in this repository are OpenAPI 3 documents? | `definition.config_key` named `openapi`, joined by path to a `definition.config_key` named `info` in the same file (json, yaml) | entity `ApiDocument` `openapi3:document:{document}` |
| Which operations does this API expose, and under which path? | `definition.config_key` whose name is an HTTP method, `within` a key beginning `/` that is itself `within` a key named `paths` | entities `ApiOperation` `openapi3:operation:{method}:{normalized_path}` and `PathItem` `openapi3:path:{normalized_path}`; relation `contains` PathItem -> ApiOperation |
| Which document declares this operation? | the same fact's `path` | relation `declared_in` ApiOperation -> ApiDocument |
| What does this operation answer with? | `definition.config_key` whose name is an HTTP status code or `default`, `within` a key named `responses`, `within` the method key, `within` the path item | entity `Response` `openapi3:response:{method}:{normalized_path}:{status}`; relation `responds` ApiOperation -> Response |
| Which operations belong to this tag? | `relation.data` (a sequence/array scalar) `within` a key named `tags`, `within` the method key, `within` the path item | entity `Tag` `openapi3:tag:{tag}`; relation `tagged` ApiOperation -> Tag |
| What secures this operation? | `definition.config_key` `within` a key named `security`, `within` the method key, `within` the path item | entity `SecurityScheme` `openapi3:security_scheme:{scheme}`; relation `secured_by` ApiOperation -> SecurityScheme |
| Which webhooks does this API declare, and with which method? | `definition.config_key` whose name is an HTTP method, `within` a key that is itself `within` a key named `webhooks` | entities `Webhook` `openapi3:webhook:{event}` and `ApiOperation` `openapi3:operation:{method}:webhooks/{event}`; relations `contains`, `declared_in` |

Every relation end is an entity some rule in this file emits, so nothing
dangles. `{normalized_path}` is the contract's route normalization, so
`/pets/{petId}` shares an identity with a route the express or fastapi overlay
emits for the same path — which is the point: **the OpenAPI document and the
implementation meet at `http:`/`openapi3:` route keys, not at a file name.**

## A field only the Pack can supply

**omega-json and omega-yaml, kind `definition.config_key`: the scalar value is
published as the attribute `value`, and it must be a *field* to be usable.**

`OverlayFact::field` (overlay.rs) resolves fields and a fixed set of built-ins;
it never consults `attributes`. Attributes are reachable by exactly one clause,
`attribute_equals`, which compares for equality — there is no `attribute_in`, no
`attribute_prefix`, and `field_ref`/`{placeholder}` cannot render one. So a key
whose *value* is the answer cannot be named or related at all. That is what
killed, and still blocks:

| construct | the value that is unreachable | rules lost |
|---|---|---|
| `$ref: '#/components/schemas/Pet'` | the JSON pointer, i.e. the whole reference | 9 `Reference` + 4 `CompositionReference` + 2 `Discriminator` |
| `operationId:`, `summary:`, `description:` | the operation's own identifier | 6 `OperationMetadata` |
| `servers: - url:` | the server URL | 1 `Server` |
| `parameters: - name:`, `in:` | the parameter's name and location | 1 `Parameter` |

Neither route out of §2 of the contract reaches it: it is not derivable from
`definition.name`, the path or the span, and no join helps, because the value
is not a fact of its own — the Pack folds it into the key's emission. The fix
is one line in each Pack's template: move `value` from `attributes` to
`fields`. It costs nothing new — the bytes are already emitted — and it is
cross-framework: kubernetes-config, docker-compose, terraform-template and
every other overlay over a data format needs a key's value for the same reason.
Reported in `pack_fields_needed`.

## Still to decide

1. **`within` reaches every enclosing key, not the nearest one.** The index
   says a span join "reaches the parent"; overlay.rs joins any fact whose span
   contains the current one, so `components -> schemas -> Pet -> properties ->
   id` gives `id` the ancestors `properties`, `Pet`, `schemas`, `components`
   alike. There is no nearest-enclosing relation and no negation over a join, so
   a rule cannot say *a key whose parent is `schemas`* — it can only say *a key
   somewhere under `schemas`*, which is every property of every schema. That is
   why this file emits **no `Schema`, `ResponseComponent`, `ParameterComponent`,
   `RequestBody`, `Example`, `Header`, `Link`, `PathItem`-component entity**: the
   overlay cannot tell a component's name from a key nested inside it, and
   guessing would put `properties`, `type` and `format` into the graph as
   schemas. The cheap fix is host-side and costs no Pack bytes: a third
   `SpanRelation`, `nearest`, on `fact_join_by_span`, binding only the smallest
   containing fact. Failing that, `definition.config_key` would have to publish
   the enclosing key's name as a field. This is not this Framework's problem
   alone — every overlay over json/yaml/toml hits it — so it belongs in
   `00-INDEX.md`.
2. **Callbacks.** A callback nests a path-item-shaped object inside an
   operation, so a status code inside `callbacks/<name>/<expr>/post/responses`
   is `within` a method key and `within` a path item, and the response rule
   attributes it to the enclosing path as well. With `nearest` above this is
   exact; without it, a rule for callbacks emits one junk entity per callback
   (the `{$request.body#/callbackUrl}` expression key binds as readily as the
   callback's name), so the 5 old `operation-callback` rules were dropped rather
   than ported wrong. Specs with callbacks are a small minority; the
   mis-attribution is recorded here rather than hidden.
3. **Media types.** `content: application/json:` would answer *what does this
   operation consume and produce*, but a media type is an open set and only
   `field_prefix` can test one, so it would take one rule per top-level type
   (`application/`, `text/`, `image/`, …). Not worth 9 rules; revisit if a
   `field_matches` clause ever exists.
4. **Document identity.** `openapi3.document` recognizes a file by the pair of
   keys `openapi` and `info` rather than by its version string, because
   `attribute_equals` would need one rule per published 3.x version. A file with
   both keys and no `paths` (a 3.1 webhook-only or components-only document) is
   still recognized, which is correct.
