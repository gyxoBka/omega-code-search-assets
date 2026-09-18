# omega-framework-fiber

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **0 can match, 14 cannot.**

Selector: `framework:fiber`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 6 |
| `Handler` | 6 |
| `Controller` | 4 |
| `Service` | 2 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Middleware` | 1 |
| `StaticResource` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 6 |
| `mounts` | 2 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `configured_by` | 1 |
| `uses_resource` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.go_receiver_string_identifier_context` | 6 | **no** |
| `definition.category_candidate` | 4 | **no** |
| `definition.go_import_alias_constructor_binding_context` | 2 | **no** |
| `definition.go_import_alias_group_binding_context` | 2 | **no** |
| `definition.go_unaliased_import_constructor_binding_context` | 2 | **no** |
| `definition.go_unaliased_import_group_binding_context` | 2 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.go_receiver_identifier_argument_context` | 1 | **no** |
| `call.go_receiver_method_chain_string_argument_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x32, `field_in` x20, `fact_kind` x14, `field_equals` x12, `path_glob` x8, `fact_join_by_field` x8, `(join)` x8, `attribute_equals` x4, `external_path_matches` x2.

Fields read: `import_path`, `constructor_name`, `method_name`, `receiver`, `path_literal`, `handler_identifier`, `group_method`, `package_receiver`, `binding`, `root_binding`, `group_binding`, `prefix`, `source.start`, `arg1_identifier`, `arg1`.

Path globs: `**/*.go`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `fiber.router.root` | kind `definition.go_import_alias_constructor_binding_context`; field `binding`, `constructor_name`, `import_path` |
| `fiber.router.group` | kind `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_binding`, `group_method`, `import_path`, `prefix`, `root_binding` |
| `fiber.route.root` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_constructor_binding_context`; field `constructor_name`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.route.group` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_method`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.router.root.unaliased` | kind `definition.go_unaliased_import_constructor_binding_context`; field `binding`, `constructor_name`, `import_path`, `package_receiver` |
| `fiber.router.group.unaliased` | kind `definition.go_unaliased_import_group_binding_context`; field `constructor_name`, `group_binding`, `group_method`, `import_path`, `package_receiver`, `prefix`, `root_binding` |
| `fiber.route.root.unaliased` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_unaliased_import_constructor_binding_context`; field `constructor_name`, `handler_identifier`, `import_path`, `method_name`, `package_receiver`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.route.group.unaliased` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_unaliased_import_group_binding_context`; field `constructor_name`, `group_method`, `handler_identifier`, `import_path`, `method_name`, `package_receiver`, `path_literal`, `receiver`; attribute `symbol_category` |
| `fiber.generic-api-call.github-com-gofiber-fiber-v2` | kind `call.target_candidate` |
| `fiber.generic-dependency.github-com-gofiber-fiber-v2` | kind `import.target_candidate` |
| `fiber.route.all` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `fiber.route.add` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `fiber.middleware.use` | kind `call.go_receiver_identifier_argument_context`; field `arg1_identifier`, `method_name`, `receiver` |
| `fiber.static.static` | kind `call.go_receiver_method_chain_string_argument_context`; field `arg1`, `method_name`, `receiver` |

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
