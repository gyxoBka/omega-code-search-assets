# omega-framework-kotlin-multiplatform

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

17 overlay rules, 4 detection rules. **0 can match, 17 cannot.**

Selector: `framework:kotlin-multiplatform`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `PlatformTarget` | 9 |
| `PlatformDeclaration` | 6 |
| `BuildProject` | 2 |
| `BuildTarget` | 1 |
| `SourceSet` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 15 |
| `contains` | 2 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.kotlin_direct_call_context` | 10 | **no** |
| `definition.kotlin_platform_class_context` | 2 | **no** |
| `definition.kotlin_platform_function_context` | 2 | **no** |
| `definition.kotlin_platform_property_context` | 2 | **no** |
| `call.kotlin_member_string_arg_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x17, `field_equals` x16, `field_in` x2, `path_glob` x2, `field_present` x1.

Fields read: `call_name`, `modifier`, `receiver`, `member`, `arg0`.

Path globs: `**/*.gradle.kts`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `kmp.target.direct-call` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.source-set.named` | kind `call.kotlin_member_string_arg_context`; field `arg0`, `member`, `receiver` |
| `kmp.expect.class` | kind `definition.kotlin_platform_class_context`; field `modifier` |
| `kmp.actual.class` | kind `definition.kotlin_platform_class_context`; field `modifier` |
| `kmp.expect.function` | kind `definition.kotlin_platform_function_context`; field `modifier` |
| `kmp.actual.function` | kind `definition.kotlin_platform_function_context`; field `modifier` |
| `kmp.expect.property` | kind `definition.kotlin_platform_property_context`; field `modifier` |
| `kmp.actual.property` | kind `definition.kotlin_platform_property_context`; field `modifier` |
| `kmp.target.jvm` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.android` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.iosarm64` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.iossimulatorarm64` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.js` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.wasmjs` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.linuxx64` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.macosx64` | kind `call.kotlin_direct_call_context`; field `call_name` |
| `kmp.target.macosarm64` | kind `call.kotlin_direct_call_context`; field `call_name` |

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
