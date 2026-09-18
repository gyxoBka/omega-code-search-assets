# omega-framework-gin

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

12 overlay rules, 4 detection rules. **0 can match, 12 cannot.**

Selector: `framework:gin`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 5 |
| `Handler` | 5 |
| `Controller` | 2 |
| `StaticResource` | 2 |
| `Service` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Middleware` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 5 |
| `uses_resource` | 2 |
| `mounts` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `configured_by` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.go_receiver_string_identifier_context` | 5 | **no** |
| `definition.go_import_alias_constructor_binding_context` | 2 | **no** |
| `definition.go_import_alias_group_binding_context` | 2 | **no** |
| `definition.category_candidate` | 2 | **no** |
| `call.go_receiver_method_chain_string_argument_context` | 2 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `call.go_receiver_identifier_argument_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x27, `fact_kind` x12, `field_in` x10, `field_equals` x8, `path_glob` x4, `fact_join_by_field` x4, `(join)` x4, `attribute_equals` x2, `external_path_matches` x2.

Fields read: `method_name`, `receiver`, `path_literal`, `handler_identifier`, `import_path`, `constructor_name`, `group_method`, `source.start`, `arg1`, `binding`, `root_binding`, `group_binding`, `prefix`, `arg1_identifier`.

Path globs: `**/*.go`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `gin.router.root` | kind `definition.go_import_alias_constructor_binding_context`; field `binding`, `constructor_name`, `import_path` |
| `gin.router.group` | kind `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_binding`, `group_method`, `import_path`, `prefix`, `root_binding` |
| `gin.route.root` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_constructor_binding_context`; field `constructor_name`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `gin.route.group` | kind `call.go_receiver_string_identifier_context`, `definition.category_candidate`, `definition.go_import_alias_group_binding_context`; field `constructor_name`, `group_method`, `handler_identifier`, `import_path`, `method_name`, `path_literal`, `receiver`; attribute `symbol_category` |
| `gin.generic-api-call.github-com-gin-gonic-gin` | kind `call.target_candidate` |
| `gin.generic-dependency.github-com-gin-gonic-gin` | kind `import.target_candidate` |
| `gin.route.any` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `gin.route.handle` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `gin.route.match` | kind `call.go_receiver_string_identifier_context`; field `handler_identifier`, `method_name`, `path_literal`, `receiver` |
| `gin.middleware.use` | kind `call.go_receiver_identifier_argument_context`; field `arg1_identifier`, `method_name`, `receiver` |
| `gin.static.static` | kind `call.go_receiver_method_chain_string_argument_context`; field `arg1`, `method_name`, `receiver` |
| `gin.static.staticfile` | kind `call.go_receiver_method_chain_string_argument_context`; field `arg1`, `method_name`, `receiver` |

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
