# omega-framework-unreal-engine

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

24 overlay rules, 12 detection rules. **0 can match, 24 cannot.**

Selector: `framework:unreal-engine`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ReflectionAnnotation` | 6 |
| `ReflectionSpecifier` | 6 |
| `AssetReference` | 2 |
| `Subobject` | 1 |
| `SpawnUse` | 1 |
| `WorldUse` | 1 |
| `EngineTypeReference` | 1 |
| `ReflectedClass` | 1 |
| `ReflectedStruct` | 1 |
| `ReflectedEnum` | 1 |
| `ReflectedInterface` | 1 |
| `ReflectedFunctionCandidate` | 1 |
| `ReflectedPropertyCandidate` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 6 |
| `annotates` | 4 |
| `uses_api` | 3 |
| `uses_resource` | 2 |
| `specializes` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.cpp_direct_call_site_context` | 11 | **no** |
| `reference.cpp_adjacent_macro_argument_context` | 6 | **no** |
| `reference.cpp_adjacent_macro_type_context` | 4 | **no** |
| `reference.cpp_adjacent_macro_member_context` | 2 | **no** |
| `relation.inherits_candidate` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x24, `field_equals` x23, `field_present` x21, `path_glob` x6.

Fields read: `macro_name`, `owner_name`, `call_name`, `argument`, `member_declaration`, `source.start`.

Path globs: `**/*.{h,hpp,cpp,cc,cxx}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `unreal.uclass-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.ustruct-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.uenum-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.uinterface-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.ufunction-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.uproperty-source-site` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.api.createdefaultsubobject` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.api.spawnactor` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.api.loadobject` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.api.findobject` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.api.getworld` | kind `reference.cpp_direct_call_site_context`; field `call_name` |
| `unreal.inheritance` | kind `relation.inherits_candidate` |
| `unreal.macro-owner.uclass` | kind `reference.cpp_adjacent_macro_type_context`; field `macro_name`, `owner_name` |
| `unreal.macro-owner.ustruct` | kind `reference.cpp_adjacent_macro_type_context`; field `macro_name`, `owner_name` |
| `unreal.macro-owner.uenum` | kind `reference.cpp_adjacent_macro_type_context`; field `macro_name`, `owner_name` |
| `unreal.macro-owner.uinterface` | kind `reference.cpp_adjacent_macro_type_context`; field `macro_name`, `owner_name` |
| `unreal.macro-member.ufunction` | kind `reference.cpp_adjacent_macro_member_context`; field `macro_name`, `member_declaration`, `owner_name` |
| `unreal.macro-member.uproperty` | kind `reference.cpp_adjacent_macro_member_context`; field `macro_name`, `member_declaration`, `owner_name` |
| `unreal.specifier.uclass` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |
| `unreal.specifier.ustruct` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |
| `unreal.specifier.uenum` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |
| `unreal.specifier.uinterface` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |
| `unreal.specifier.ufunction` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |
| `unreal.specifier.uproperty` | kind `reference.cpp_adjacent_macro_argument_context`; field `argument`, `macro_name`, `owner_name` |

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
