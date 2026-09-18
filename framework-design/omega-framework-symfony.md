# omega-framework-symfony

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

20 overlay rules, 4 detection rules. **1 can match, 19 cannot.**

Selector: `framework:symfony`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `FrameworkAttribute` | 15 |
| `Template` | 3 |
| `Controller` | 1 |
| `Handler` | 1 |
| `Route` | 1 |
| `ApiUse` | 1 |
| `ServiceDependency` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 15 |
| `handles` | 1 |
| `includes` | 1 |
| `uses_api` | 1 |
| `injects` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 15 | **no** |
| `definition.php_attributed_method_route_context` | 2 | **no** |
| `data.twig_template` | 1 | **no** |
| `import.twig_path` | 1 | yes |
| `reference.php_constructor_parameter_type_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x20, `external_path_matches` x16, `field_present` x12, `path_glob` x3, `field_in` x1.

Fields read: `source.start`, `attribute_name`, `route`, `path`, `parameter_type`.

Path globs: `**/*.twig`, `**/*.php`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `symfony.route-attribute` | kind `definition.php_attributed_method_route_context`; field `attribute_name`, `route` |
| `symfony.twig-template` | kind `data.twig_template` |
| `symfony.generic-api-call.symfony-symfony` | kind `call.target_candidate` |
| `symfony.constructor.di` | kind `reference.php_constructor_parameter_type_context`; field `parameter_type` |
| `symfony.attribute.route` | kind `definition.php_attributed_method_route_context` |
| `symfony.attribute.isgranted` | kind `call.target_candidate` |
| `symfony.attribute.cache` | kind `call.target_candidate` |
| `symfony.attribute.maprequestpayload` | kind `call.target_candidate` |
| `symfony.attribute.mapquerystring` | kind `call.target_candidate` |
| `symfony.attribute.autowire` | kind `call.target_candidate` |
| `symfony.attribute.required` | kind `call.target_candidate` |
| `symfony.attribute.ascommand` | kind `call.target_candidate` |
| `symfony.attribute.aseventlistener` | kind `call.target_candidate` |
| `symfony.attribute.mapuploadedfile` | kind `call.target_candidate` |
| `symfony.attribute.currentuser` | kind `call.target_candidate` |
| `symfony.attribute.autoconfigure` | kind `call.target_candidate` |
| `symfony.attribute.autoconfiguretag` | kind `call.target_candidate` |
| `symfony.attribute.taggediterator` | kind `call.target_candidate` |
| `symfony.attribute.target` | kind `call.target_candidate` |

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
