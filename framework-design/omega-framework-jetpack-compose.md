# omega-framework-jetpack-compose

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

10 overlay rules, 12 detection rules. **0 can match, 10 cannot.**

Selector: `framework:jetpack-compose`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `State` | 2 |
| `NavigationAction` | 2 |
| `RouteReference` | 2 |
| `Component` | 1 |
| `ComposeCall` | 1 |
| `Effect` | 1 |
| `Route` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `calls` | 2 |
| `contains` | 2 |
| `renders` | 2 |
| `navigates_to` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.kotlin_annotated_function_context` | 10 | **no** |
| `call.kotlin_direct_call_context` | 4 | **no** |
| `call.kotlin_annotated_owner_direct_call_context` | 2 | **no** |
| `call.kotlin_member_string_arg_context` | 2 | **no** |
| `call.kotlin_string_arg_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x15, `field_present` x11, `fact_kind` x10, `(join)` x9, `fact_join_by_span` x7, `path_glob` x3, `field_in` x3, `fact_join_by_field` x2.

Fields read: `annotation_name`, `call_name`, `arg0`, `callee_name`, `owner_name`, `member`, `receiver`, `function_name`.

Path globs: `**/*.kt`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `compose.composable.function` | kind `definition.kotlin_annotated_function_context`; field `annotation_name`, `function_name` |
| `compose.remember.call` | kind `call.kotlin_annotated_owner_direct_call_context`; field `annotation_name`, `callee_name`, `owner_name` |
| `compose.composable.direct-child` | kind `call.kotlin_annotated_owner_direct_call_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `callee_name`, `owner_name` |
| `compose.composable.nested-call` | kind `call.kotlin_direct_call_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `call_name` |
| `compose.composable.nested-child` | kind `call.kotlin_direct_call_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `call_name` |
| `compose.state.nested` | kind `call.kotlin_direct_call_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `call_name` |
| `compose.effect.nested` | kind `call.kotlin_direct_call_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `call_name` |
| `compose.navigation.route` | kind `call.kotlin_string_arg_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `arg0`, `call_name` |
| `compose.navigation.navigate-literal` | kind `call.kotlin_member_string_arg_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `arg0`, `member`, `receiver` |
| `compose.navigation.popbackstack-literal` | kind `call.kotlin_member_string_arg_context`, `definition.kotlin_annotated_function_context`; field `annotation_name`, `arg0`, `member`, `receiver` |

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
