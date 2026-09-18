# omega-framework-unreal-engine

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

19 overlay rules, 12 detection rules. **19 can match, 0 cannot.** (Was 24 rules,
0 live.)

Selector: `framework:unreal-engine`. Maturity: `semantic-overlay-full`.
Host: `omega-cpp` only; it publishes **no field on any of its 35 templates**, so
the overlay has the kind, the name, the path and the span and nothing else.

### Entities it declares

| entity_kind | rules | key space |
|---|---|---|
| `UnrealType` | 18 | `unreal:type:{name}` -- the hub, one kind, minted by every rule that needs a type as a relation end |
| `Actor`, `Pawn`, `ActorComponent`, `GameFrameworkType`, `Subsystem`, `Widget`, `DataAsset`, `BlueprintExposedType`, `ReflectedObject`, `ReflectedInterface`, `GameModule`, `DataTableRow`, `ReflectedType` | 1 each | one key space each (`unreal:actor:{name}`, `unreal:pawn:{name}`, ...) |
| `DefaultSubobject`, `SpawnSite`, `ObjectConstruction`, `AssetLoad`, `SubsystemUse`, `ModuleEntryPoint` | 1 each | one call-site key space each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `depends` | 18 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `relation.implements` (+ `within` join to `definition.class` / `definition.struct`) | 12 | yes, omega-cpp |
| `reference.type` (+ `within` join to `call.function` / `call.method`) | 5 | yes, omega-cpp |
| `import.include` (+ same-path join to `definition.class`) | 1 | yes, omega-cpp |
| `call.function` | 1 | yes, omega-cpp |

Clause vocabulary in use: `fact_kind` x19, `field_in` x18, `fact_join_by_span`
x17, `field_prefix` x5, `fact_join_by_field` x1, `path_glob` x1 (over a field,
brace-free). No `field_equals` on a Pack field, because there are none.

## What was wrong with it

**24 of 24 overlay rules matched nothing.** Every rule was keyed to a fact kind
from the pre-rewrite generator vocabulary, and no Pack emits any of the five:

| kind it matched | rules | emitted by |
|---|---|---|
| `reference.cpp_direct_call_site_context` | 11 | no Pack |
| `reference.cpp_adjacent_macro_argument_context` | 6 | no Pack |
| `reference.cpp_adjacent_macro_type_context` | 4 | no Pack |
| `reference.cpp_adjacent_macro_member_context` | 2 | no Pack |
| `relation.inherits_candidate` | 1 | no Pack |

It also read six Pack fields — `macro_name`, `owner_name`, `call_name`,
`argument`, `member_declaration`, `macro_arguments` — and **omega-cpp publishes
no field on any of its 35 templates**. All six were unreachable independently of
the kind.

Three further defects, none of which the audit reports:

- **Six brace path globs.** Every rule carrying `**/*.{h,hpp,cpp,cc,cxx}` was
  matching only a path that literally ends in that text; `glob_here` implements
  `**`, `*` and `?` and treats `{` as a byte. All six are gone, and none was
  replaced: `relation.implements`, `definition.class`, `call.method` and
  `import.include` are emitted by omega-cpp and not by omega-c, so the kind
  already decides the language.
- **Eleven relations dangled.** `unreal.macro-owner.*` and
  `unreal.macro-member.*` sourced an `annotates` edge at
  `unreal:annotation:UCLASS:{path}:{source.start}`, a key minted only by
  `unreal.uclass-source-site` — from a *different* fact, at a *different* span,
  so the two `{source.start}` values could never agree. The five `uses_api` /
  `uses_resource` rules were worse: source `current` and target
  `by_canonical_key` rendered **the same template**, so each was a self-loop
  from an entity to itself.
- **Language-spelling duplication.** Six `unreal.*-source-site` rules differed
  only in a macro name, six `unreal.specifier.*` only in a macro name, four
  `unreal.macro-owner.*` only in a macro name. A `field_in` clause states each
  of those once.

Twelve of the 24 rules produced an entity whose only content was its own input
(`unreal:annotation:UCLASS:{path}:{source.start}`, attributes `macro: "UCLASS"`
and `source_only: true`) and no relation at all. Those are deleted, not ported.

**The reflection macros cannot be reached at all, and that is the real finding.**
`UCLASS()`, `USTRUCT()`, `UENUM()`, `UINTERFACE()`, `UFUNCTION(...)`,
`UPROPERTY(...)` and `GENERATED_BODY()` are written with no terminating
semicolon, so they are not `expression_statement`s and omega-cpp's
`(call_expression function: (identifier) @call.name)` never sees them. There is
no fact to match and no join that reaches one. The overlay infers reflection
from the one reflected-header artefact that *is* ordinary C++ — the
`#include "MyClass.generated.h"` that UHT requires — and says so in
`coverage.gaps` rather than pretending to the macro.

**24 rules became 19, and all 19 are live.**

### And what was still wrong after that: one key, thirteen kinds

The wave that made all 19 rules live put **thirteen different entity kinds on one
canonical key template**. `unreal.actor`, `unreal.pawn`,
`unreal.actor-component`, `unreal.game-framework`, `unreal.subsystem`,
`unreal.widget`, `unreal.data-asset`, `unreal.blueprint-library`,
`unreal.uobject`, `unreal.interface`, `unreal.game-module` and
`unreal.reflected-header` all rendered `unreal:type:{cls.definition.name}`, and
`unreal.data-table-row` rendered the same string through a differently-named
bind (`unreal:type:{st.definition.name}`). The five engine-API rules rendered it
a third way, as `unreal:type:{definition.name}`, under kind `UnrealType`.

`Entity::named` builds its id from the key alone -- the kind is not part of the
identity -- and `apply_overlay_runs` does `entities.entry(id).or_insert(entity)`,
with candidates sorted by `rule_id`. `unreal.actor` sorts first. So for

    class AMyPawn : public ACharacter { ... };   // in MyPawn.h, which includes MyPawn.generated.h

the graph got **one** entity, kind `Actor`, carrying `unreal.actor`'s
attributes, and `Pawn` and `ReflectedType` were computed and thrown away. Across
the file, `python pack-design/key_collisions.py unreal-engine` counted **11
entity outputs dropped** -- every classification but `Actor`. Every answer in the
table below except *is it an actor* was unreachable in the graph, however live
the audit said the rules were. `overlay_audit.py` cannot see this, and did not.

**The fix is brief 3g remedy 2, a key space per classification, related back to
the hub.** Each of the thirteen classification rules now emits three outputs:

1. its own entity, with its own kind and its own attributes, at its own key --
   `unreal:actor:{cls.definition.name}`, `unreal:pawn:{...}`,
   `unreal:component:{...}`, `unreal:game-framework:{...}`,
   `unreal:subsystem:{...}`, `unreal:widget:{...}`, `unreal:data-asset:{...}`,
   `unreal:blueprint-exposed:{...}`, `unreal:uobject:{...}`,
   `unreal:interface:{...}`, `unreal:game-module:{...}`,
   `unreal:data-table-row:{...}`, `unreal:reflected:{...}`;
2. the hub, `UnrealType` at `unreal:type:{cls.definition.name}`, with the single
   attribute `type` -- the same kind and the same attributes from all eighteen
   rules that mint it, which is what makes the shared key correct rather than a
   collision;
3. a `depends` edge from its own key to the hub, carrying the classification as a
   literal `role` attribute.

Remedy 1 -- one neutral kind and nothing else -- was rejected because it would
have discarded `base` and `declared_in` as well: only the first rule's
attributes survive a shared key, so a classification carried as an attribute is
no safer than one carried as a kind. Remedy 2 keeps all thirteen kinds and all
thirteen attribute sets, and each is separately addressable.

`key_collisions.py` now reports **0 entity outputs overwritten**, and a check of
minted-versus-addressed keys shows all 20 addressed key templates are minted by
this file. Rule count is unchanged at 19; the outputs went from 24 to 50.

## What it states now

Every rule is built from what omega-cpp actually emits: a kind, a name, a path
and a span. The Pack publishes no fields, so every value below is
`definition.name`, `path`, `path.stem`, `source.start`, or the same read through
a span join.

| what it answers | Pack fact it reads | entity / relation it states |
|---|---|---|
| which classes are level actors | `relation.implements` named `AActor`/`AInfo`/`AVolume`/... (15 bases), joined `within` `definition.class` | `Actor` at `unreal:actor:{class}` **depends** `unreal:type:{class}` |
| which classes are possessable pawns | `relation.implements` named `APawn`/`ACharacter`/... (6) + `within` `definition.class` | `Pawn` at `unreal:pawn:{class}` **depends** `unreal:type:{class}` |
| which classes are actor components | `relation.implements` named `UActorComponent`/`USceneComponent`/... (25) + `within` `definition.class` | `ActorComponent` at `unreal:component:{class}` **depends** `unreal:type:{class}` |
| which class fills which gameplay-framework role | `relation.implements` named `AGameModeBase`/`APlayerController`/... (17) + `within` `definition.class` | `GameFrameworkType` at `unreal:game-framework:{class}`, `base` = the role, **depends** `unreal:type:{class}` |
| which classes are engine subsystems | `relation.implements` named `UGameInstanceSubsystem`/`UWorldSubsystem`/... (8) + `within` `definition.class` | `Subsystem` at `unreal:subsystem:{class}` **depends** `unreal:type:{class}` |
| which classes are UMG or Slate widgets | `relation.implements` named `UUserWidget`/`SCompoundWidget`/... (11) + `within` `definition.class` | `Widget` at `unreal:widget:{class}` **depends** `unreal:type:{class}` |
| which classes are content, not code | `relation.implements` named `UDataAsset`/`UPrimaryDataAsset`/`UDeveloperSettings`/... (6) + `within` `definition.class` | `DataAsset` at `unreal:data-asset:{class}` **depends** `unreal:type:{class}` |
| which classes publish members to Blueprint | `relation.implements` named `UBlueprintFunctionLibrary`/`UAnimInstance`/`UGameplayAbility`/... (5) + `within` `definition.class` | `BlueprintExposedType` at `unreal:blueprint-exposed:{class}` **depends** `unreal:type:{class}` |
| which classes are plain reflected UObjects | `relation.implements` named `UObject` + `within` `definition.class` | `ReflectedObject` at `unreal:uobject:{class}` **depends** `unreal:type:{class}` |
| which classes are the UInterface half of an interface pair | `relation.implements` named `UInterface` + `within` `definition.class` | `ReflectedInterface` at `unreal:interface:{class}` **depends** `unreal:type:{class}` |
| which class is this module's `IModuleInterface` implementation | `relation.implements` named `IModuleInterface`/`FDefaultGameModuleImpl`/... + `within` `definition.class` | `GameModule` at `unreal:game-module:{class}` **depends** `unreal:type:{class}` |
| which struct is a data-table row type | `relation.implements` named `FTableRowBase` + `within` `definition.struct` | `DataTableRow` at `unreal:data-table-row:{struct}` **depends** `unreal:type:{struct}` |
| which types are UHT-reflected | `import.include` whose name globs `**/*.generated.h`, joined by `path` to every `definition.class` in the same file | `ReflectedType` at `unreal:reflected:{class}`, `generated_header` = the include, **depends** `unreal:type:{class}` |
| what is known about one type at all | any of the thirteen above, or any of the five below | `UnrealType` at `unreal:type:{name}` -- the hub every classification and every use site points at |
| which component types a class builds in its constructor | `reference.type` starting `U`, `within` a `call.function` named `CreateDefaultSubobject`/`CreateOptionalDefaultSubobject`/... | `DefaultSubobject` at `unreal:subobject:{path}:{call start}:{type}` **depends** `unreal:type:{type}` |
| which actor classes this code spawns | `reference.type` starting `A`, `within` a `call.method` named `SpawnActor`/`SpawnActorDeferred`/`SpawnActorAbsolute` | `SpawnSite` **depends** `unreal:type:{type}` |
| which UObjects this code constructs at run time | `reference.type` starting `U`, `within` a `call.function` named `NewObject`/`DuplicateObject`/`CreateWidget` | `ObjectConstruction` **depends** `unreal:type:{type}` |
| which content types this code resolves from the asset registry | `reference.type` starting `U`, `within` a `call.function` named `LoadObject`/`LoadClass`/`FindObject`/`StaticLoadObject`/... | `AssetLoad` **depends** `unreal:type:{type}` |
| who uses which subsystem | `reference.type` starting `U`, `within` a `call.method` named `GetSubsystem`/`GetWorldSubsystem`/... | `SubsystemUse` **depends** `unreal:type:{type}` -- and `unreal.subsystem`'s `Subsystem` entity **depends** on that same hub key, so the two meet in one node across files |
| where a module registers itself with the engine | `call.function` named `IMPLEMENT_MODULE`/`IMPLEMENT_PRIMARY_GAME_MODULE`/... | `ModuleEntryPoint` at `unreal:module-entry:{path}` |

**Keys minted vs keys addressed.** Twenty-one key templates are minted: the hub
`unreal:type:{...}` (two placeholder spellings, `{cls.definition.name}` from the
thirteen classification rules and `{definition.name}` from the five engine-API
rules, both under the single kind `UnrealType` and the single attribute `type`,
which is why they may share a key), thirteen classification key spaces, five
call-site key spaces and `unreal:module-entry:{path}`. Twenty are addressed by a
relation end, and **every one of them is minted by the rule that addresses it**,
so no relation dangles. No key template is minted under two kinds, in this file
or across the repository -- `unreal:` is this Framework's prefix alone, so the
global interning that `key_collisions.py` also checks cannot bring another
Framework onto these keys.

Both ends of every relation are named by explicit `by_canonical_key` rather than
`current`, because every relation-emitting rule now emits two entities and
`current` binds whichever `emit()` walked first.

Two engine-API rules share the `U`/`A` naming prefix as a filter. That is not a
guess about Unreal: `field_prefix definition.name "U"` is what keeps
`FActorSpawnParameters` and `TSubclassOf` — other `type_identifier`s inside the
same `call_expression` span — from being read as the spawned class. Both rules
are `confidence: "candidate"` for that reason.

`detection_rules` is untouched: 12 rules over `.uasset`, `.uproject` and the
`UCLASS`/`UPROPERTY` textual signatures, in the row/atom program, which the Pack
rewrite did not affect.

## A field only the Pack can supply

**None is requested.** Two things this overlay would use are recorded as gaps
rather than as Pack asks, because neither is a field on an existing emission:

- **The reflection macros.** `UCLASS()` and its siblings are not expressions and
  omega-cpp has no template that could carry a field for them. Supplying them
  means a *new query pattern* in omega-cpp for bare macro invocations adjacent to
  a declaration — which is exactly the `cpp_adjacent_macro_*_context` machinery
  the Pack rewrite removed on purpose, and it would cost every C++ repository in
  the index for one framework. The `.generated.h` include answers *is this type
  reflected* well enough; the specifier arguments (`BlueprintReadWrite`,
  `EditAnywhere`, `Category=`) stay unanswerable.
- **Asset paths.** `LoadObject<UTexture2D>(nullptr, TEXT("/Game/UI/T_Icon"))`
  names a content file, and omega-cpp captures no call argument at all, so
  `TEXT("…")` never reaches the overlay. Neither a built-in name nor a span join
  can reach it: there is no fact over the string literal to join to. Making it
  answerable is a Pack question — a string-argument emission on `call_expression`
  — that belongs to more than Unreal (the same absence stops any C++ framework
  from reading a registered name), so it is written here and not requested as a
  field.

## Still to decide

1. **`unreal.reflected-header` is a file-level inference applied to a class.** It
   marks *every* `definition.class` in a header that includes a `.generated.h` as
   a `ReflectedType`, including the `IMyInterface` half of an interface pair and
   any non-reflected helper class in the same header. It is `confidence:
   "candidate"` for that. The alternative — drop it and say nothing about
   reflection — loses the only signal Unreal's defining feature leaves in
   parseable C++. Kept, with the imprecision stated.
2. **Engine-API uses are keyed to their call site, not to the type that performs
   them.** omega-cpp spans `definition.function` on the `function_declarator`,
   which excludes the body, and emits no `scope.function_body`, so a call inside
   `void AMyActor::BeginPlay()` in a `.cpp` file lies within no declaration span
   at all. *Which actor spawns which actor* is therefore not answerable; *which
   actors are spawned, and from where* is. Closing this needs a body span from
   the Pack, which is a larger question than Unreal.
3. **The hub carries one attribute and no classification.** `UnrealType` holds
   only `type`. That is deliberate: eighteen rules mint it, and only the first
   rule's attributes survive a shared key, so anything else put there would be
   whichever rule happened to sort first. The classification lives in the
   `role` attribute on the `depends` edge and in the kind of the entity at the
   other end of it, both of which are per-rule and therefore safe.
4. **The classification edges are `depends`, the loosest of the six relations
   the host knows.** `Actor -> UnrealType` is really *is a facet of*, and none of
   `implements`, `data`, `config`, `handles`, `tests` says that either. `depends`
   is also the direction the five call-site rules already use, so every edge in
   the file points the same way -- into the hub -- and a query on
   `unreal:type:AMyPawn` finds its classifications and its use sites in one
   incoming set. Revisit if the host gains a facet relation.
5. **`SpawnActor` is matched on `call.method` only.** `World->SpawnActor<T>()`
   and `GetWorld()->SpawnActor<T>()` are the written forms; a bare
   `SpawnActor<T>()` inside `UWorld` itself would be a `call.function` and is not
   matched. Adding it would double the rule for engine-source coverage the
   overlay is not aimed at.
