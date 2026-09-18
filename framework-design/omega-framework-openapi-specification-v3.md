# omega-framework-openapi-specification-v3

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

73 overlay rules, 2 detection rules. **0 can match, 73 cannot.**

Selector: `framework:openapi-specification-v3`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Reference` | 9 |
| `Callback` | 7 |
| `OperationMetadata` | 6 |
| `Example` | 5 |
| `Header` | 5 |
| `Link` | 5 |
| `Schema` | 4 |
| `CompositionReference` | 4 |
| `ApiOperation` | 3 |
| `SecurityScheme` | 3 |
| `Response` | 2 |
| `ResponseComponent` | 2 |
| `ParameterComponent` | 2 |
| `RequestBody` | 2 |
| `PathItem` | 2 |
| `Webhook` | 2 |
| `Discriminator` | 2 |
| `Server` | 1 |
| `Parameter` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 22 |
| `references` | 15 |
| `request_schema` | 2 |
| `response_schema` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 73 | **no** |

Clause vocabulary in use: `field_equals` x145, `field_present` x129, `fact_kind` x73, `attribute_equals` x73, `field_in` x16, `field_prefix` x7.

Fields read: `a0`, `a1`, `a2`, `key`, `value`, `a3`, `a4`, `a6`, `a5`, `root_key`, `method`, `path`, `ref`, `grandparent_key`, `owner_key`, `sequence_key`, `item_key`, `item_value`, `array_key`, `a7`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `openapi3.operation` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `openapi3.schema` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `openapi3.schema.json` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `openapi3.ref.direct.yaml` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.ref.direct.json` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.security_scheme` | kind `structured.entry`; field `grandparent_key`, `key`, `owner_key`; attribute `role` |
| `openapi3.server` | kind `structured.entry`; field `item_key`, `item_value`, `sequence_key`; attribute `role` |
| `openapi3.parameter` | kind `structured.entry`; field `a0`, `a1`, `a2`, `item_key`, `item_value`, `sequence_key`; attribute `role` |
| `openapi3.response` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `key`; attribute `role` |
| `openapi3.request_schema` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a6`, `key`, `value`; attribute `role` |
| `openapi3.response_schema` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a7`, `key`, `value`; attribute `role` |
| `openapi3.operation.json.request` | kind `structured.entry`; field `method`, `ref`, `root_key`; attribute `role` |
| `openapi3.operation.json.response` | kind `structured.entry`; field `method`, `ref`, `root_key`; attribute `role` |
| `openapi3.request_schema.json` | kind `structured.entry`; field `method`, `ref`, `root_key`; attribute `role` |
| `openapi3.response_schema.json` | kind `structured.entry`; field `method`, `ref`, `root_key`; attribute `role` |
| `openapi3.response.json` | kind `structured.entry`; field `method`, `ref`, `root_key`; attribute `role` |
| `openapi3.component.schemas.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.responses.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.parameters.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.examples.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.requestBodies.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.headers.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.securitySchemes.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.links.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.callbacks.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.pathItems.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.schemas.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.responses.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.parameters.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.examples.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.requestBodies.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.headers.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.securitySchemes.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.links.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.callbacks.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.component.pathItems.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`; attribute `role` |
| `openapi3.webhook.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`; attribute `role` |
| `openapi3.webhook.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`; attribute `role` |
| `openapi3.operation-callback.json_depth5_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`; attribute `role` |
| `openapi3.operation-callback.yaml_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`; attribute `role` |
| `openapi3.operation-callback.json_depth6_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`; attribute `role` |
| `openapi3.operation-callback.json_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`; attribute `role` |
| `openapi3.operation-callback.yaml_depth8_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`; attribute `role` |
| `openapi3.response-links.json_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-headers.json_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-examples.json_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-links.yaml_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-headers.yaml_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-examples.yaml_depth7_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-links.yaml_depth8_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-headers.yaml_depth8_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.response-examples.yaml_depth8_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `a4`, `a5`, `a6`; attribute `role` |
| `openapi3.schema.discriminator.yaml_depth4_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `key`, `value`; attribute `role` |
| `openapi3.schema.discriminator.json_depth4_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `a3`, `key`, `value`; attribute `role` |
| `openapi3.ref.any.yaml_depth3_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.yaml_depth4_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.yaml_depth7_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.yaml_depth8_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.json_depth3_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.json_depth4_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.json_depth5_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.json_depth6_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.ref.any.json_depth7_pair` | kind `structured.entry`; field `key`, `value`; attribute `role` |
| `openapi3.composition-ref.json_depth1_array_item_field` | kind `structured.entry`; field `array_key`, `key`, `value`; attribute `role` |
| `openapi3.composition-ref.json_depth2_array_item_field` | kind `structured.entry`; field `array_key`, `key`, `value`; attribute `role` |
| `openapi3.composition-ref.json_depth3_array_item_field` | kind `structured.entry`; field `array_key`, `key`, `value`; attribute `role` |
| `openapi3.composition-ref.yaml_depth3_sequence_mapping_field` | kind `structured.entry`; field `item_key`, `item_value`, `sequence_key`; attribute `role` |
| `openapi3.operation-meta.operationId.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.operation-meta.summary.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.operation-meta.description.yaml_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.operation-meta.operationId.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.operation-meta.summary.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |
| `openapi3.operation-meta.description.json_depth3_pair` | kind `structured.entry`; field `a0`, `a1`, `a2`, `key`, `value`; attribute `role` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
