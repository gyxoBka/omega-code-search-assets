# omega-framework-kotlin-multiplatform

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before this rewrite

17 overlay rules, 4 detection rules. **0 could match, 17 could not.**

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

## What was wrong with it

Measured, not argued: `python pack-design/overlay_audit.py kotlin-multiplatform`
reported **0 of 17 rules live**. The reasons, by count:

- **10 rules** matched `call.kotlin_direct_call_context` with a field
  `call_name`. No Pack emits that kind and omega-kotlin publishes no field at
  all. Nine of those ten were one rule per target name — `kmp.target.jvm`,
  `kmp.target.js`, `kmp.target.iosArm64`, … — byte-identical apart from the
  literal in a `field_equals`, and a tenth (`kmp.target.direct-call`) carried
  the same seventeen names in a `field_in`. That is the per-spelling
  proliferation the contract forbids twice over: once per language, once per
  target.
- **6 rules** matched `definition.kotlin_platform_{class,function,property}_context`
  with a field `modifier`. No Pack emits any of the three kinds, and the fields
  those rules read (`modifier`, `declaration_name`) exist nowhere.
- **1 rule** matched `call.kotlin_member_string_arg_context` with fields
  `receiver`, `member`, `arg0`. No Pack emits it. omega-kotlin emits no call
  argument of any kind, so `sourceSets.getByName("androidMain")` is
  unreachable in principle, not just in spelling.

Two defects would have survived a mechanical translation, and were designed out instead:

- **Six self-loops.** All six `expect`/`actual` rules emitted
  `configured_by` from `current` to the canonical key `current` had just been
  minted under — the shape wave 2 and wave 6 found in gitlab-ci and symfony.
  Six of the seventeen relations in the file went from an entity to itself.
- **Nine one-entity rules with nothing to connect to.** The nine
  `kmp.target.<name>` rules minted a `PlatformTarget` keyed
  `kmp:target:<name>:{path}:{source.start}` — a key containing a byte offset,
  so nothing else could ever address it — and `kmp.target.direct-call` minted
  a `BuildTarget` under a different key for the same call. Two entity kinds,
  two keys, one fact.

Also untrue: `emits` declared a `BuildTarget` that duplicated `PlatformTarget`,
and `coverage.gaps` claimed that "authored expect/actual declarations … are
materialized" while every rule that would have materialized them was dead.

**17 rules became 13, and all 13 are live.**

## What it states now

`definition.modifier_candidate` is the piece that makes this framework
possible. omega-kotlin emits it for every declaration that carries modifiers,
its **name is the modifier text** (`expect`, `actual`, `expect annotation`),
and its span is `@decl.span` — *exactly* the declaration's own span. So
`fact_join_by_span` with `relation: "same"` reaches the declaration from the
modifier and needs no Pack field. Measured with `dump_call_emissions` on
`expect class Beta`, `actual class Alpha`, `internal expect class Gamma`,
`expect object Delta`, `actual object Epsilon`, `expect annotation class Zeta`,
`actual typealias Eta = String` and `actual class Theta { actual fun go() {} }`
— all eight emit the declaration and the modifier carrier at one span.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which platforms does this module build for | `call.function` named `jvm`, `androidTarget`, `iosArm64`, `js`, `wasmJs`, `linuxX64`, … (28 target DSL names) in `**/*.gradle.kts` | `PlatformTarget kmp:target:{path}:{name}`, `BuildProject kmp:project:{path}`, `BuildProject -declares-> PlatformTarget` |
| which source sets does this build script declare | `call.function` named `getting`/`creating`/`registering`/`existing` in `**/*.gradle.kts`, joined `within` the enclosing `definition.property` that delegates to it | `SourceSet kmp:source-set:{path}:{name}`, `BuildProject -declares-> SourceSet` |
| which API must every platform supply (`expect class`/`interface`/`object`/`fun`/`val`) | `definition.modifier_candidate` with name prefix `expect`, joined `same`-span to `definition.class` / `definition.interface` / `definition.object_class` / `definition.function` / `definition.property` | `PlatformDeclaration kmp:expect:<kind>:{name}` (5 rules) |
| which platform implementation supplies it, and **which expect does this actual satisfy** | the same carrier with name prefix `actual`, joined `same`-span to the same five kinds | `PlatformDeclaration kmp:actual:<kind>:{path}:{name}` + `-implements-> kmp:expect:<kind>:{name}` (5 rules) |
| `actual typealias Foo = Bar`, the usual way a JVM/native source set satisfies an `expect class` | the carrier with prefix `actual`, joined `same`-span to `definition.type_alias` | `PlatformDeclaration kmp:actual:type-alias:{path}:{name}` + `-implements-> kmp:expect:class:{name}` |

The `implements` edge is the one answer the language Pack cannot give. An
`expect fun getPlatform()` in `commonMain` and an `actual fun getPlatform()` in
`jvmMain` are two unrelated `definition.function` facts in two files; the
expect key is deliberately **path-free**, so every platform's actual in the
repository lands on the same target entity and the question *who implements
this expect, and on how many platforms* is one hop.

**Key discipline** (brief §3a). Keys minted: `kmp:project:{path}`,
`kmp:target:{path}:{definition.name}`,
`kmp:source-set:{path}:{decl.definition.name}`,
`kmp:expect:<kind>:{decl.definition.name}` for five kinds,
`kmp:actual:<kind>:{path}:{decl.definition.name}` for six. Keys addressed by a
relation: the project key, the target key, the source-set key, the six actual
keys and the five expect keys — all of them minted, with `kmp:expect:class`
addressed by both `kmp.actual.class` and `kmp.actual.type-alias` and minted by
`kmp.expect.class` under the same conditions. No relation uses `current`; both
ends of every relation are explicit templates, so brief §3b's first trap cannot
bite. Every attribute resolves through `OverlayFact::field` or a bound fact's
`definition.name` / `path`, so no entity is dropped for an unresolvable
attribute.

## Still to decide

1. **`by getting` is not only a source set.** `val jar by getting` inside
   `tasks { }` is the same three facts as `val commonMain by getting` inside
   `sourceSets { }`. The `sourceSets` call spans only its own name — the Pack's
   `span_capture` for `call.function` is `@call.function.name`, not the call
   expression — so no span join can tell a source set from a task. The rule is
   `confidence: candidate` for that reason. A `scope.call_block` on the
   trailing lambda would settle it, and would serve every Gradle-shaped and
   DSL-shaped framework, not this one.
2. **Prefix, not containment, for the modifier.** `field_prefix` on the
   carrier's name catches `expect`, `expect annotation`, `actual`, and misses
   `internal expect` and `public actual`, where Kotlin's modifier order puts
   visibility first. There is no `field_contains` and no `field_suffix` clause
   in `overlay.rs`, and enumerating `field_in` over the cross product of
   visibility and the twenty other modifiers is not a rule anyone should
   maintain. Public is the default for a KMP `expect` and the redundant
   spelling is rare, so the loss is small and stated in `coverage.gaps`.
3. **A file's source set is its directory, and the overlay cannot read one.**
   `src/iosMain/kotlin/Platform.kt` says which platform compiles that file, but
   the only path derivations `OverlayFact::field` offers are `path`, `path.dir`
   and `path.stem`, and `normalized_file_route` under a glob root returns the
   whole tail (`iosMain/kotlin/Platform`), not the segment. So
   `PlatformDeclaration` and `SourceSet` stay two islands, and the question
   *which target does this actual serve* is unanswered. Writing one `path_glob`
   rule per known source-set name would answer it, at the cost of the
   per-spelling proliferation this rewrite removed; it is not worth 20 rules.
4. **Pairing is by name and kind, not by package.** omega-kotlin emits
   `definition.package` spanning only the `package` header, so no span join
   reaches it from a top-level declaration and the package cannot enter the
   expect key. Two same-named `expect class Config` in different packages of
   one project would collapse onto one entity. In practice a KMP project's
   expects are few and named distinctly; the case is recorded in
   `coverage.gaps`.

## A field only the Pack can supply

None. Every rule in the rewritten file runs on `kind`, `name`, `path` and
`span` alone — omega-kotlin publishes no field on any of its 28 templates and
none was needed. Item 1 above wants a *span*, not a field: `call.function`
spanning the call expression (or a `scope.call_block` over a trailing lambda)
rather than only the callee name. That is a Pack change, it is not specific to
this framework, and nothing here depends on it.
