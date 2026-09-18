# omega-framework-jetpack-compose

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 12 detection rules. **11 can match, 0 cannot.**
(Wave 1: 9 rules, 9 live. Before wave 1: 10 rules, 0 live.)

Selector: `framework:jetpack-compose`. Maturity: `semantic-overlay-full`.
Language: Kotlin only, so every rule reads `omega-kotlin`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComposeComponent` | 2 |
| `ComposeRoute` | 2 |
| `ComposeState` | 2 |
| `ComposeEffect` | 1 |
| `ComposeNavGraph` | 1 |
| `ComposeNavigationAction` | 1 |
| `ComposeEntryPoint` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `declares` | 4 |
| `navigates` | 2 |
| `renders` | 1 |
| `hosts` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.arguments` | 3 | yes (omega-kotlin) |
| `call.function` | 4 | yes |
| `call.method` | 2 | yes |
| `definition.modifier_candidate` | 2 (+9 as a nested join) | yes |
| `definition.function` | 10 (as a join) | yes |
| `definition.class` | 1 (as a join) | yes |

Fields read: `call.arg0_text`, `call.arg1_text` on `call.arguments`. Everything
else comes from a built-in name — `definition.name`, `path`, `source.start` —
or from a bound join.

## What was wrong with it

Wave 1 had already ported the file off the generator's dead Kotlin-private
vocabulary (10 rules keyed to `definition.kotlin_annotated_function_context`,
`call.kotlin_direct_call_context` and three more kinds no Pack emits, plus eight
fields no Pack publishes). That part stands. **What was wrong on this pass is
one thing, and it cost four sentences of `coverage.gaps` and two of the three
questions Navigation Compose exists to answer.**

Wave 1 measured, correctly at the time, that omega-kotlin publishes no argument
text, and concluded that a route literal "is not reachable by any clause". It
then wrote that conclusion into three places:

1. **`coverage.gaps` entry 2** — *"omega-kotlin publishes no argument text, so
   every Navigation Compose route literal … is unreachable. Navigation is stated
   as which composable hosts the graph and which composable moves the back
   stack, never as a route string."* False as of the `call.arguments` emission.
2. **"A field only the Pack can supply", first entry** — a request for exactly
   the field that now exists. Withdrawn.
3. **Two `coverage_note`s**, on `compose.navigation.host` and
   `compose.navigation.action`, each repeating that the route argument "is not
   published". Both rewritten.

The concrete loss was **three rules' worth of answers**:

- **`composable("home") { … }` produced nothing at all.** The whole
  `NavGraphBuilder` body — every destination in the application — was invisible.
  A project's route table did not exist in the graph.
- **`compose.navigation.action` had no target.** It minted a
  `ComposeNavigationAction` keyed `compose:nav-action:{path}:{source.start}` and
  pointed a `navigates` edge at it, so the edge went from a screen to *the byte
  offset of its own call site*. *Which screen does this button navigate to* was
  unanswerable, and `navigate` and `popBackStack` — one of which names a
  destination and one of which cannot — were lumped into one rule.
- **`compose.navigation.host` stated a nav graph with no start destination**,
  although `NavHost(navController, startDestination)` puts it in argument one.

Measured against the same hand-written file (`dump_call_emissions`, omega-kotlin
+ omega-kotlin grammar), omega-kotlin emits `call.arguments` on the **same span**
as `call.function`/`call.method`, carrying twelve fields:

```
251-261  call.arguments  name=composable  call.arg0="\"home\""  call.arg0_text="home"  …
776-784  call.arguments  name=navigate    call.arg0="\"details/1\""  call.arg0_text="details/1"  …
363-373  call.arguments  name=composable  call.arg0="Screen.Profile.route"  call.arg0_text="Screen.Profile.route"
816-824  call.arguments  name=navigate    call.arg0="Screen.Profile.route"  call.arg0_text="Screen.Profile.route"
```

Two things follow that decided the design. First, `call.arguments`' **name is
the callee**, so the three new rules match `call.arguments` directly rather than
joining it to `call.function`; the join would buy nothing. Second, the two Compose
route spellings each meet *themselves* — literal↔literal and constant↔constant —
so a single `compose:route:{normalized_route}` key space is a real identity for
both, and only the mixed case fails.

Three further corrections made on this pass:

4. **`compose.navigation.action` is split in two** (brief §3l: where a construct
   has two spellings and only one carries a literal, write two rules).
   `compose.navigation.navigate` states the destination; `compose.navigation.back`
   states that `popBackStack`/`navigateUp`/`clearBackStack` leave, and by which
   API, which is all they can state.
5. **The `navigate` edge now lands on a key another rule mints.** Both
   `compose.navigation.destination` and `compose.navigation.navigate` mint
   `ComposeRoute` — **one kind, one key space** (brief §3g) — so an edge to a
   route that no `NavHost` in this repository declares still reaches an entity
   rather than dangling (brief §3a). `compose.navigation.destination` sorts
   before `compose.navigation.navigate`, so where both fire it is the
   declaration's attributes that survive the `or_insert` (brief §3g);
   `key_collisions.py jetpack-compose` reports nothing.
6. **`navigation(...)` is deliberately excluded** from the destination rule. It
   is the one Navigation Compose builder whose arguments are conventionally all
   named, so `call.arg0_text` is the literal text `startDestination = "settings/main"`
   and not a route. Including it would have minted a junk route identity that
   nothing else can address (brief §3f cuts the other way here: this is not
   narrowing a value list the Pack fills generically, it is declining a value the
   Pack measurably cannot give).

## What it states now

Every row is written against a `dump_call_emissions` run over a hand-written
Compose file — `@Composable fun AppNav`, a `NavHost` with four `composable`
destinations in two spellings, a `dialog`, a nested `navigation`,
`remember { mutableStateOf(0) }`, `LaunchedEffect`, `navController.navigate` in
both spellings, `popBackStack`, `@Preview @Composable`, and a `MainActivity`
with `setContent`.

The fact that makes this framework statable at all remains
`definition.modifier_candidate`: omega-kotlin emits the trimmed text of a
declaration's whole modifier run as the *name* of a carrier whose span is
byte-identical to the declaration's, so `@Composable` arrives as
`definition.modifier_candidate "@Composable"` on the exact span of the
`definition.function`, and `fact_join_by_span` `relation: "same"` reaches the
function with no Pack field.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| Which functions are UI components? | `definition.modifier_candidate` name prefixed `@Composable`, span-`same` join to `definition.function` | `ComposeComponent` at `compose:composable:{name}` |
| Which of them are preview harnesses, not real UI? | the same carrier prefixed `@Preview` | the same `ComposeComponent`, with `preview_harness` |
| Which composable renders which, across files? | `call.function` inside a composable whose name joins a `@Composable` `definition.function` anywhere in the repository | `renders`, component key to component key |
| **What routes does this app declare?** | `call.arguments` named `composable`/`dialog`/`bottomSheet`, `call.arg0_text` | **`ComposeRoute` at `compose:route:{normalized_route}`** |
| **Which composable declares this route?** | the same fact, `within` join to the `@Composable` owner | **`declares`, component -> route** |
| **Where does this screen navigate to?** | `call.arguments` named `navigate`, `call.arg0_text`, inside a composable | **`navigates`, component -> `compose:route:{normalized_route}`** |
| Which screens leave without naming a destination? | `call.method` `popBackStack`/`navigateUp`/`clearBackStack`, inside a composable | `ComposeNavigationAction` + `navigates` from the component |
| Which composable hosts the navigation graph, **and where does it start**? | `call.arguments` named `NavHost`/`AnimatedNavHost`; `call.arg1_text` is the start destination | `ComposeNavGraph` + `hosts` from the component |
| What state does this screen hold? | `call.function` in the `remember`/`mutableStateOf`/`derivedStateOf` family, inside a composable | `ComposeState` + `declares` from the component |
| What does this screen observe from a ViewModel? | `call.method` `collectAsState`/`collectAsStateWithLifecycle`/`observeAsState`/`subscribeAsState`, inside a composable | `ComposeState` + `declares` from the component |
| What side effects does this screen run? | `call.function` `LaunchedEffect`/`DisposableEffect`/`SideEffect`/`produceState`/`rememberCoroutineScope`, inside a composable | `ComposeEffect` + `declares` from the component |
| Where does the Compose tree start? | `call.function` `setContent` inside a `definition.class` | `ComposeEntryPoint` at `compose:entry-point:{class}` |

"Inside a composable" is one shared clause in eight rules: `fact_join_by_span`
`within` a `definition.function`, bound `owner`, whose nested `where` requires a
span-`same` `definition.modifier_candidate` prefixed `@Composable`. That binding
*is* the screen, and it is what every relation above is sourced at.

The three bolded rows are new on this pass, and together they are the route
table: a project's declared destinations, who declares each one, and which
screen moves to which.

### Keys minted and keys addressed

| key template | minted by | addressed by |
|---|---|---|
| `compose:composable:{name}` | `compose.composable.declaration`, `.preview` | source of `renders`, `declares` x4, `hosts`, `navigates` x2; target of `renders` |
| `compose:route:{normalized_route}` | `compose.navigation.destination`, `compose.navigation.navigate` | target of `declares` (destination) and of `navigates` (navigate) |
| `compose:state:{path}:{start}` | `compose.state.remember`, `.observed` | their own `declares` |
| `compose:effect:{path}:{start}` | `compose.effect` | its own `declares` |
| `compose:nav-graph:{path}:{start}` | `compose.navigation.host` | its own `hosts` |
| `compose:nav-action:{path}:{start}` | `compose.navigation.back` | its own `navigates` |
| `compose:entry-point:{class}` | `compose.entry-point` | — |

Every addressed key is minted (brief §3a). Every rule that addresses
`compose:composable:{name}` carries the same `@Composable`-prefix condition as
the rule that mints it (brief §3b). Both hub key spaces carry exactly one entity
kind (brief §3g). No attribute is named `path`, `name` or any other built-in, so
no later output in a rule picks up an earlier output's value (brief §3k); the
one deliberate use of that mechanism is `{normalized_route}` reading the
attribute `route`.

## A field only the Pack can supply

**Withdrawn: "the text of a literal string argument."** Wave 1 asked omega-kotlin
for it. It exists — `call.arguments` with twelve fields, on the same span as the
call — and all three of this pass's new rules are built on it. Nothing is owed.

**Still standing: Pack `omega-kotlin`, a missing kind `reference.annotation`.**
Contract §6 lists it in the cross-language vocabulary and omega-kotlin does not
emit it. An annotation reaches the overlay only as (a) the trimmed text of the
whole modifier run, as one `definition.modifier_candidate` name — measured:
`@Preview\n@Composable` arrives as a single name with an embedded newline — and
(b) a `reference.type` on the annotation's identifier, which is
indistinguishable from a `@Composable` lambda *parameter* type. So `@Composable`
can be tested only by prefix on the run, and `@Inject @Composable fun Screen()`
is not recognised. Neither a built-in name nor a join reaches it: the built-ins
are path, span, name and the enclosing-definition chain, and a
`fact_join_by_span` needs a fact *per annotation*, which is the thing that does
not exist. One `reference.annotation` per annotation, spanned on the declaration
the way `definition.modifier_candidate` already is, would make this exact and
would serve every annotation-driven Kotlin framework (Dagger/Hilt, Room,
kotlinx.serialization) rather than this one.

**New, and worth more than it looks: Pack `omega-kotlin`, kind `call.arguments`,
a span over the whole `call_expression` rather than over the callee identifier.**
`span_capture` is `call.arguments.name`, the `simple_identifier`, so the fact
covers `composable` (bytes 251-261) and not the trailing lambda that follows it.
That is why `composable("home") { HomeScreen() }` cannot state *route home
renders HomeScreen*: the `call.function HomeScreen` at 272-282 is not inside any
span this framework can bind, and the only thing that contains both is the
enclosing `@Composable fun AppNav`. A second emission — or a widened span on
this one — would give every trailing-lambda DSL in Kotlin (Navigation Compose,
Gradle KTS, Ktor routing, kotlinx-serialization builders) a `within` join to its
own block. No join reaches it today, because a join can only relate spans the
Pack emitted, and no emitted span covers a call's lambda argument.

## Still to decide

- **Annotation order.** `@Composable`-first and `@Preview`-first are both
  matched; `private @Composable fun` and `@Inject @Composable fun` are not. Two
  prefixes cover the two orderings that occur in Compose source; widening would
  mean matching `reference.type Composable`, which also fires for
  `content: @Composable () -> Unit` parameters and would call every Compose
  *wrapper* a component. Left narrow deliberately; the clean fix is
  `reference.annotation` above.
- **Simple-name resolution.** `compose.composable.renders` joins callee to
  declaration by simple name across the whole repository, because the overlay has
  no Kotlin import environment. Two composables named `Header` in two feature
  modules are one node. `same_path: true` would lose every cross-file `renders`
  edge, which is the main thing this overlay exists for.
- **Two route identities for one route.** `composable("home")` keys
  `compose:route:/home`; `composable(Screen.Home.route)` keys
  `compose:route:/Screen.Home.route`. Each meets its own `navigate` spelling
  exactly, which is the common case, because a project picks one convention. A
  project that declares with the constant and navigates with the literal gets two
  disconnected nodes, and there is no clause that can resolve a constant to its
  value. Stated in `coverage.gaps` rather than papered over.
- **Named arguments.** `navigate(route = "home")` and
  `NavHost(navController = nc, startDestination = "home")` deliver `call.arg0` /
  `call.arg1` as the whole `value_argument` text, `startDestination = "home"`
  included. `start_destination` is therefore an **attribute** and never a key.
  `navigate(route = "home")` would mint `compose:route:/route = "home"` — junk,
  but rare enough in real Compose (the positional spelling is what the docs and
  every sample use) that excluding `navigate` on that ground would cost far more
  than it saves. `navigation(...)`, where the named spelling *is* the convention,
  is excluded.
- **`compose.entry-point` emits an entity and no relation.** It is keyed on the
  Activity class reached by a join, not on its own input, so it is not a
  restatement — but *the entry point renders this composable* needs the same
  widened span as the destination-content case above. `setContent { … }` has no
  `value_arguments` node at all and emits no `call.arguments`.
