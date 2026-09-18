# omega-framework-wordpress

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

18 overlay rules, 12 detection rules. **0 can match, 18 cannot.**

Selector: `framework:wordpress`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `HookRegistration` | 3 |
| `Option` | 3 |
| `Hook` | 2 |
| `ApiUse` | 2 |
| `HookDispatch` | 1 |
| `Shortcode` | 1 |
| `ContentType` | 1 |
| `Taxonomy` | 1 |
| `BlockType` | 1 |
| `Menu` | 1 |
| `Sidebar` | 1 |
| `Route` | 1 |
| `ScriptResource` | 1 |
| `StyleResource` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configures` | 5 |
| `configured_by` | 4 |
| `handles` | 3 |
| `uses_api` | 2 |
| `uses_resource` | 2 |
| `registers_for` | 1 |
| `dispatches` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.php_function_string_arg_context` | 11 | **no** |
| `call.php_function_string_identifier_args_context` | 3 | **no** |
| `call.php_function_two_string_args_context` | 2 | **no** |
| `call.target_candidate` | 2 | **no** |

Clause vocabulary in use: `fact_kind` x18, `field_equals` x14, `field_present` x5, `field_in` x2, `path_glob` x2, `external_path_matches` x2.

Fields read: `call_name`, `arg0`, `source.start`, `arg1`.

Path globs: `**/*.php`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `wordpress.register-hook-two-string` | kind `call.php_function_two_string_args_context`; field `arg0`, `arg1`, `call_name` |
| `wordpress.dispatch-hook` | kind `call.php_function_string_arg_context`; field `arg0`, `call_name` |
| `wordpress.generic-api-call.wordpress-plugin` | kind `call.target_candidate` |
| `wordpress.generic-api-call.wp-content-plugins` | kind `call.target_candidate` |
| `wordpress.add_action.identifier` | kind `call.php_function_string_identifier_args_context`; field `call_name` |
| `wordpress.add_filter.identifier` | kind `call.php_function_string_identifier_args_context`; field `call_name` |
| `wordpress.add_shortcode.identifier` | kind `call.php_function_string_identifier_args_context`; field `call_name` |
| `wordpress.register_post_type` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.register_taxonomy` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.register_block_type` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.register_nav_menu` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.register_sidebar` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.rest-route` | kind `call.php_function_two_string_args_context`; field `call_name` |
| `wordpress.wp_enqueue_script` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.wp_enqueue_style` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.get_option` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.update_option` | kind `call.php_function_string_arg_context`; field `call_name` |
| `wordpress.add_option` | kind `call.php_function_string_arg_context`; field `call_name` |

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
