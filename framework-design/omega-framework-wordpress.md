# omega-framework-wordpress

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before this rewrite

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

## What was wrong with it

**All 18 rules were dead, and every one of them died on the fact kind.** The
file was written against omega-php's pre-rewrite vocabulary, which spelled a
call four different ways depending on the shape of its argument list:

| kind the old file matched | rules | a Pack emits it |
|---|---|---|
| `call.php_function_string_arg_context` | 11 | no |
| `call.php_function_string_identifier_args_context` | 3 | no |
| `call.php_function_two_string_args_context` | 2 | no |
| `call.target_candidate` | 2 | no |

Four further faults, each of which would have killed a rule even if the kinds
had survived:

1. **Every rule read a field omega-php has never published.** 16 of the 18 read
   `call_name` in a match clause, 2 read `arg0` and 1 reads `arg1`, and **16 of
   the 20 entity outputs keyed on an argument** (`wordpress:hook:{arg0}`,
   `wordpress:option:{arg0}`, `wordpress:route:{arg0}/{arg1}`). **omega-php
   publishes no `fields` and no `attributes` on any of its 51 templates** — the
   overlay sees kind, name, path and span and nothing else. So the design of the
   old file was unreachable in principle, not merely out of date.
2. **Thirteen of the 18 rules emitted a relation from an entity to itself.**
   `wordpress.get_option` minted `Option` keyed `{arg0}` and then emitted
   `configured_by` from `current` to `wordpress:option:{arg0}` — and `current`
   *is* that entity, because `emit()` sets `own_key` from the rule's first entity
   output. The same shape is in both `register_*` pairs, both `wp_enqueue_*`
   rules, `rest-route`, all three option rules and both generic-api-call rules.
   An entity keyed by the value just read, with a self-loop for an edge, adds
   nothing to the graph.
3. **Fourteen rules were one spelling of one thing.** `wordpress.get_option`,
   `wordpress.update_option` and `wordpress.add_option` differed only in the
   `call_name` constant, as did the six registration rules and the two enqueue
   rules. Those are `field_in` lists on one rule now.
4. **The two `external_path_matches` rules could never have fired.** They asked
   for package `@wordpress-plugin`, which is an npm package name; no PHP
   emission carries an `external` package at all, and the kind they matched
   (`call.target_candidate`) was a carrier the host never folded.

The `coverage.gaps` block was also false: it claimed that "literal
hook/filter/shortcode names, direct identifier callbacks, REST route
namespace/path ... and literal asset/option keys are materialized". None of them
were or can be. It now says the opposite, with the reason.

18 rules became **17, all live.**

## What it states now

The governing constraint is the one in fault 1: **omega-php publishes no field,
so no call argument is visible.** A WordPress fact therefore has three possible
subjects — the file, the enclosing PHP function reached by a span join, and the
WordPress API function itself, which is the call's own `definition.name`. The
overlay is built on those three plus the path conventions WordPress imposes.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| which PHP files are plugin or mu-plugin code | `call.function` under `**/wp-content/*plugins/**/*.php` | `ExtensionFile` `wordpress:file:{path}`, `surface=plugin` |
| which PHP files are theme code | `call.function` under `**/wp-content/themes/**/*.php` | `ExtensionFile`, `surface=theme` |
| which file renders which view (the template hierarchy) | `call.function`, `path.stem` in the 22 template names | `Template` `wordpress:template:{path}` --`handles`--> `View` `wordpress:view:{path.stem}` |
| which files wire behaviour onto hooks | `call.function` named `add_action`, `add_filter`, `remove_*`, `has_*` | `ExtensionFile` --`uses_api`--> `WpApi` `wordpress:api:add_action`, `capability=hook-wiring` |
| which files define extension points of their own | `call.function` named `do_action`, `apply_filters`, the `_ref_array` and `_deprecated` forms | `uses_api`, `capability=hook-dispatch` |
| which files define the content model | `register_post_type`, `register_taxonomy`, `register_*_meta`, … | `uses_api`, `capability=content-model` |
| which files register editor blocks, patterns and styles | `register_block_type*`, `register_block_pattern*`, `register_block_style` | `uses_api`, `capability=block` |
| which files serve REST surface | `register_rest_route`, `register_rest_field`, … | `uses_api`, `capability=rest` |
| which files build the wp-admin screens | `add_menu_page`, `add_meta_box`, `register_setting`, `add_settings_*`, … | `uses_api`, `capability=admin` |
| which files register shortcodes, widgets, sidebars, nav menus | `add_shortcode`, `register_widget`, `register_sidebar*`, `register_nav_menu*`, `add_theme_support` | `uses_api`, `capability=presentation` |
| which files put scripts and styles on the page | `wp_enqueue_*`, `wp_register_script/style`, `wp_localize_script`, … | `uses_api`, `capability=assets` |
| which files touch persistent settings | `get_option`, `update_option`, `*_site_option`, `*_transient`, `*_theme_mod` | `uses_api`, `capability=options` |
| which files read or write posts, terms, users, meta | `get_posts`, `wp_insert_post`, `*_post_meta`, `get_terms`, `*_user_meta`, `wp_cache_*` | `uses_api`, `capability=data` |
| which files build a WordPress query or response object | `call.constructor` named `WP_Query`, `WP_User_Query`, `WP_Error`, … | `uses_api`, `capability=data-query` |
| which files check a capability or a nonce | `current_user_can`, `wp_verify_nonce`, `check_*_referer`, `wp_create_nonce`, … | `uses_api`, `capability=security` |
| which named PHP function performs a registration | `call.function` in the union of the registration names, `fact_join_by_span` `within` `scope.function_body` bound as `fn` | `Registrar` `wordpress:function:{path}:{fn.definition.name}` --`registers`--> `WpApi`; `ExtensionFile` --`declares`--> `Registrar` |
| which blocks the project defines | `definition.config_key` named `apiVersion` in `**/block.json` (omega-json) | `Block` `wordpress:block:{path}` --`configures`--> `wordpress:api:register_block_type` |

Six entity kinds — `ExtensionFile`, `Template`, `View`, `WpApi`, `Registrar`,
`Block` — and five relations: `uses_api`, `handles`, `registers`, `declares`,
`configures`.

Three design points worth stating, because each is a trap the earlier waves
recorded:

- **`WpApi` is the hub that makes the file edges worth having.** *Which files
  register a custom post type* is the neighbours of
  `wordpress:api:register_post_type`; *which plugin ships an admin screen* is
  that set intersected with `surface=plugin`. The hub is minted by every rule
  that points at it, so no relation end dangles. The key-minting check was run
  mechanically: the set of keys the 17 rules address is exactly contained in the
  set they mint.
- **No relation uses `current`.** Every end is an explicit `by_canonical_key`,
  so the wave-2 defect (`current` is the rule's *first* entity output) cannot
  occur here.
- **The 13 API rules carry no `wp-content` glob.** A plugin repository is
  normally checked out with the plugin directory as its root, so requiring the
  WordPress install layout would answer nothing for the commonest case. The
  WordPress API names are themselves the evidence; the layout globs appear only
  in the three rules whose whole subject *is* the layout. All 17 exclude
  `node_modules`, `vendor`, `wp-admin` and `wp-includes`, so a full WordPress
  install does not drown the graph in core's own calls.

## A field only the Pack can supply

**omega-php, every `call.*` template, an argument field.** This is the one thing
that would change the overlay qualitatively rather than incrementally.
`add_action('init', 'my_bootstrap')` is the single most important statement in
any WordPress codebase, and with a first-argument field the overlay could mint
`wordpress:hook:init` and relate the registering function to it — the real *what
runs when* graph, including the `wp_ajax_*`, `rest_api_init` and
`save_post_{type}` conventions that carry a plugin's whole control flow.

Neither of the two cheaper routes reaches it:

- **No built-in name carries it.** The built-ins are path, span,
  `definition.name` and `external.*`; `definition.name` on a call is the
  callee's name, not an argument.
- **No join reaches it.** `fact_join_by_span` relates a fact to an enclosing
  fact, and omega-php emits nothing at all for a string literal — there is no
  fact inside the call's span to join to. `fact_join_by_field` needs a published
  field on both sides, which is the thing being asked for.

It is deliberately *not* asked for as a WordPress convenience: omega-php
publishes no field on any of its 51 templates, so this is a Pack-wide gap that
every PHP framework overlay (laravel, symfony, wordpress) meets at the same
place, and it belongs in `00-INDEX.md` rather than here. Note also that the
value must land in `fields`, not `attributes`: `OverlayFact::field` never reads
attributes.

The same paragraph applies to omega-json's `definition.config_key`, whose
`value` is published as an attribute — already recorded in `00-INDEX.md` as the
wave-1 finding. It is what stops `wordpress.block.metadata` from naming the
block instead of its file.

## Still to decide

- **`ExtensionFile` is per file, not per plugin.** A plugin's identity is its
  directory under `wp-content/plugins/`, and no built-in extracts "the segment
  after `wp-content/plugins`" — `path.dir` is the file's own directory, which is
  the plugin root only for files that sit directly in it. Grouping files into
  plugins is therefore left to the host's path structure rather than asserted
  wrongly here.
- **`apiVersion` as the block.json marker.** It is matched instead of `name`
  because `name` also occurs as a nested key inside `attributes`, and a nested
  key emits `definition.config_key` too. `apiVersion` is top-level-only in
  practice, but a block.json written without it emits no `Block`. The
  alternative — a span join to exclude nested keys — costs a clause on every
  block and buys nothing until the config value itself is readable.
- **`WP_Error` and `rest_ensure_response` are in the lists.** They are not
  registrations; they are there because they are the WordPress response idiom
  and a reader looking for "which files talk WordPress at all" wants them. If
  the capability sets are ever used for a precision judgement they should come
  out.
