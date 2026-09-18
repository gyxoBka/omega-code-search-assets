# omega-framework-vapor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

15 overlay rules, 8 detection rules. **0 can match, 15 cannot.**

Selector: `framework:vapor`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Route` | 7 |
| `Service` | 2 |
| `ApiUse` | 2 |
| `Dependency` | 2 |
| `RouteGroup` | 2 |
| `RouteSegment` | 1 |
| `WebSocketRoute` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `handles` | 6 |
| `contains` | 3 |
| `uses_api` | 2 |
| `depends_on` | 2 |
| `mounts` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.swift_receiver_member_string_argument_context` | 10 | **no** |
| `call.target_candidate` | 2 | **no** |
| `import.module_path_candidate` | 2 | **no** |
| `call.swift_receiver_member_string_segment_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x24, `fact_kind` x15, `field_equals` x9, `external_path_matches` x4, `field_in` x2, `path_glob` x2.

Fields read: `member`, `arg0`, `receiver`, `source.start`, `literal`.

Path globs: `**/*.swift`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `vapor.route.member-string` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.generic-api-call.https-github-com-vapor-vapor-git` | kind `call.target_candidate` |
| `vapor.generic-dependency.https-github-com-vapor-vapor-git` | kind `import.module_path_candidate` |
| `vapor.generic-api-call.vapor` | kind `call.target_candidate` |
| `vapor.generic-dependency.vapor` | kind `import.module_path_candidate` |
| `vapor.route.get` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.route.post` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.route.put` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.route.patch` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.route.delete` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.route.on` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |
| `vapor.group.grouped` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member` |
| `vapor.group.group` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member` |
| `vapor.route.literal-segment` | kind `call.swift_receiver_member_string_segment_context`; field `literal`, `member`, `receiver` |
| `vapor.route.websocket` | kind `call.swift_receiver_member_string_argument_context`; field `arg0`, `member`, `receiver` |

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
