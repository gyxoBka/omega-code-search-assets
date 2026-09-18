# omega-framework-jetpack-compose

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

9 overlay rules, 12 detection rules. **9 can match, 0 cannot.** (Was 10 rules,
0 live.)

Selector: `framework:jetpack-compose`. Maturity: `semantic-overlay-full`.
Language: Kotlin only, so every rule reads `omega-kotlin`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComposeComponent` | 2 |
| `ComposeState` | 2 |
| `ComposeEffect` | 1 |
| `ComposeNavGraph` | 1 |
| `ComposeNavigationAction` | 1 |
| `ComposeEntryPoint` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 3 |
| `renders` | 1 |
| `hosts` | 1 |
| `navigates` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.function` | 5 | yes |
| `call.method` | 2 | yes |
| `definition.modifier_candidate` | 2 (+7 as a nested join) | yes |
| `definition.function` | 9 (as a join) | yes |
| `definition.class` | 1 (as a join) | yes |

Fields read: none. Every value comes from a built-in name — `definition.name`,
`path`, `source.start` — or from a bound join.

## What was wrong with it

All ten rules were keyed to the generator's old Kotlin-private vocabulary, and
no Pack emits any of it:

| dead kind | rules using it |
|---|---|
| `definition.kotlin_annotated_function_context` | 10 |
| `call.kotlin_direct_call_context` | 4 |
| `call.kotlin_annotated_owner_direct_call_context` | 2 |
| `call.kotlin_member_string_arg_context` | 2 |
| `call.kotlin_string_arg_context` | 1 |

and to eight fields no Pack publishes — `annotation_name`, `function_name`,
`call_name`, `callee_name`, `owner_name`, `member`, `receiver`, `arg0`. The
whole file answered nothing.

Beyond the translation, four things were wrong on their own terms:

1. **Three rules restated their input.** `compose.composable.nested-call` minted
   a `ComposeCall` keyed `compose:call:{path}:{source.start}` whose only
   attribute was the callee name it had just read, with no relation to anything.
   `compose.navigation.navigate-literal` and `.popbackstack-literal` each minted
   a `RouteReference` keyed by the very string they matched and pointed a
   `navigates_to` at it — an edge from a call site to its own argument. Gone.

2. **Three relation kinds for one fact.** `compose.composable.direct-child` and
   `compose.composable.nested-child` each emitted `calls`, `contains` *and*
   `renders` between the same two keys, with the same evidence attribute. In
   Compose those are one statement. One `renders` edge now.

3. **Two rules were the same rule twice.** `direct-child` and `nested-child`
   differed only in which dead composite kind carried the owner — the annotated
   owner was baked into the fact in one and reached by a span join in the other.
   `compose.remember.call` and `compose.state.nested` were likewise one question
   asked of two spellings. Each pair is one rule now.

4. **Every key was path-local.** `compose:component:{path}:{name}` meant a
   composable declared in `HomeScreen.kt` and called from `AppNav.kt` were two
   different entities, so the one cross-file question Compose has — *which screen
   does this navigation host render* — could never be answered even if the kinds
   had existed. Components are keyed by name alone now, and the callee join runs
   repository-wide.

Three rules could not be ported at all and are deleted rather than rewritten:
`compose.navigation.route`, `.navigate-literal` and `.popbackstack-literal` all
read `arg0`, the text of a string-literal argument. omega-kotlin publishes no
argument text on any of its 28 templates, so a route literal is not reachable by
any clause — see *A field only the Pack can supply* below.

## What it states now

Measured, not assumed: `dump_call_emissions` over a hand-written Compose file
(`@Composable fun Greeting`, `remember { mutableStateOf(0) }`, `NavHost { }`,
`navController.navigate("details/1")`, `setContent { }`) is what every row below
is written against. The one fact that makes this framework statable is
`definition.modifier_candidate`: omega-kotlin emits the trimmed text of a
declaration's whole modifier run as the *name* of a carrier whose span is
byte-identical to the declaration's, so `@Composable` arrives as
`definition.modifier_candidate "@Composable"` on the exact span of the
`definition.function` — and `fact_join_by_span` with `relation: "same"` reaches
the function with no Pack field at all.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| Which functions are UI components? | `definition.modifier_candidate` name prefixed `@Composable`, span-`same` join to `definition.function` | `ComposeComponent` at `compose:composable:{name}` |
| Which of them are preview harnesses, not real UI? | the same carrier prefixed `@Preview` (the Android Studio template order) | the same `ComposeComponent`, with `preview_harness` |
| Which composable renders which, across files? | `call.function` inside a composable, whose name joins a `@Composable` `definition.function` anywhere in the repository | `renders` from the caller's component key to the callee's |
| What state does this screen hold? | `call.function` in the `remember` / `mutableStateOf` / `derivedStateOf` family, inside a composable | `ComposeState` + `declares` from the component |
| What does this screen observe from a ViewModel? | `call.method` `collectAsState` / `collectAsStateWithLifecycle` / `observeAsState`, inside a composable | `ComposeState` + `declares` from the component |
| What side effects does this screen run? | `call.function` `LaunchedEffect` / `DisposableEffect` / `SideEffect` / `produceState` / `rememberCoroutineScope`, inside a composable | `ComposeEffect` + `declares` from the component |
| Which composable hosts the navigation graph? | `call.function` `NavHost` / `AnimatedNavHost`, inside a composable | `ComposeNavGraph` + `hosts` from the component |
| Which screens move the back stack, and how? | `call.method` `navigate` / `popBackStack` / `navigateUp` / `clearBackStack`, inside a composable | `ComposeNavigationAction` + `navigates` from the component |
| Where does the Compose tree start? | `call.function` `setContent` inside a `definition.class` | `ComposeEntryPoint` at `compose:entry-point:{class}` |

"Inside a composable" is one shared clause in seven rules: `fact_join_by_span`
`within` a `definition.function`, bound `owner`, whose nested `where` requires a
span-`same` `definition.modifier_candidate` prefixed `@Composable`. That binding
*is* the screen, and it is what every relation above is sourced at.

### Keys minted and keys addressed

| key template | minted by | addressed by |
|---|---|---|
| `compose:composable:{name}` | `compose.composable.declaration`, `compose.composable.preview` | the source end of `renders`, `declares` x3, `hosts`, `navigates`; the target end of `renders` |
| `compose:state:{path}:{start}` | `compose.state.remember`, `compose.state.observed` | their own `declares` |
| `compose:effect:{path}:{start}` | `compose.effect` | its own `declares` |
| `compose:nav-graph:{path}:{start}` | `compose.navigation.host` | its own `hosts` |
| `compose:nav-action:{path}:{start}` | `compose.navigation.action` | its own `navigates` |
| `compose:entry-point:{class}` | `compose.entry-point` | — |

Every addressed key is minted (brief §3a), and every rule that addresses
`compose:composable:{name}` carries the same `@Composable`-prefix condition as
the rule that mints it (brief §3b). `compose:composable:{name}` is a hub with
**one** kind, `ComposeComponent`, from both rules that mint it (brief §3g);
`pack-design/key_collisions.py jetpack-compose` reports nothing.

## A field only the Pack can supply

**Pack `omega-kotlin`, kind `call.function` / `call.method`, field: the text of a
literal string argument.** Navigation Compose declares a destination as
`composable("home") { HomeScreen() }` and requests one as
`navController.navigate("details/1")`. The route is a string literal in the
argument list. omega-kotlin's `call_expression` patterns capture only
`@call.function.name` / `@call.method.name` and publish no fields at all, so:

- no built-in name reaches it — the built-ins are path, span, name and the
  enclosing-definition chain, none of which is argument text;
- no join reaches it — `fact_join_by_span` needs the Pack to have emitted a fact
  *for the literal*, and it emits none; the call fact's own span covers only the
  callee identifier, so the argument is not even inside it.

Without it, `which URL does this screen serve` and `which screen does this button
navigate to` are unanswerable for Compose. This is the same gap `OWED.md`
already records for omega-go and Fiber/Gin route strings; it is a language-Pack
question, not a Compose one.

**Pack `omega-kotlin`, a missing kind: `reference.annotation`.** Contract §6
lists `reference.annotation` in the cross-language vocabulary, and omega-kotlin
does not emit it. An annotation reaches the overlay only as (a) the trimmed text
of the whole modifier run, as one `definition.modifier_candidate` name, and (b) a
`reference.type` on the annotation's identifier, which is indistinguishable from
a `@Composable` lambda *parameter type*. So `@Composable` can be tested only by
prefix on the run, and `@Inject @Composable fun Screen()` is not recognised. One
`reference.annotation` per annotation, spanned on the declaration the way
`definition.modifier_candidate` already is, would make this exact and would serve
every annotation-driven Kotlin framework (Dagger/Hilt, Room, kotlinx.serialization)
rather than this one.

## Still to decide

- **Annotation order.** `@Composable`-first and `@Preview`-first are both
  matched; `private @Composable fun` and `@Inject @Composable fun` are not. Two
  prefixes cover the two orderings that actually occur in Compose source, and
  widening further would mean matching `reference.type Composable` inside the
  function, which also fires for `content: @Composable () -> Unit` parameters and
  would call every Compose *wrapper* a component. Left narrow deliberately;
  the clean fix is the `reference.annotation` kind above.
- **Simple-name resolution.** `compose.composable.renders` joins callee to
  declaration by simple name across the whole repository, because the overlay has
  no Kotlin import environment. Two composables named `Header` in two feature
  modules are one node. The alternative — `same_path: true` — would lose every
  cross-file `renders` edge, which is the main thing this overlay exists for.
  Repository-wide is the right trade, but it is a trade.
- **`compose.entry-point` emits an entity and no relation.** It is keyed on the
  Activity class reached by a join, not on its own input, so it is not a
  restatement — but the edge one would want, *the entry point renders this
  composable*, is not reachable: a call fact spans only the callee identifier, so
  nothing relates `setContent` to the composable inside its lambda. A rule that
  instead took any composable call inside a `definition.class` as the evidence
  was considered and rejected: it would call any class holding a member
  composable an entry point.
