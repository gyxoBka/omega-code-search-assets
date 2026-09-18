# omega-framework-blazor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 12 detection rules. **11 live, 0 cannot match.**

Selector: `framework:blazor`. Maturity: `semantic-overlay-full`.
Scope: `**/*.razor` and its `**/*.razor.cs` code-behind. The Pack behind almost
all of it is **omega-razor**; `**/*.razor.cs` is **omega-c-sharp**.

### Entities it declares

| entity_kind | key space | minted by |
|---|---|---|
| `BlazorComponent` | `blazor:component:{name}` | 8 rules (hub) |
| `BlazorRoute` | `blazor:route:{route}` | `blazor.page.route` |
| `BlazorType` | `blazor:type:{type}` | `blazor.base_type` |
| `BlazorRenderMode` | `blazor:rendermode:{mode}` | `blazor.rendermode` |
| `BlazorService` | `blazor:service:{type}` | `blazor.inject` |
| `BlazorParameter` | `blazor:parameter:{comp}.{prop}` | 2 rules |
| `BlazorMember` | `blazor:member:{comp}.{member}` | 2 rules |
| `BlazorLifecycleHook` | `blazor:lifecycle:{hook}` | `blazor.lifecycle` |

One kind per key space, so `key_collisions.py` reports nothing.

### Relations it declares

`serves`, `rendered_in_layout`, `derives_from`, `renders_as`, `injects`,
`declares_parameter`, `declares`, `implements_lifecycle`, `binds_handler`.

## What was wrong with it

**Every one of the 11 rules was dead, and every one for the same reason: it
named a fact kind of the pre-rewrite generator vocabulary.** Eleven distinct
kinds, not one of them emitted by any Pack in `packs/`:

`data.file` (2 rules), `data.razor_page_route`,
`reference.razor_literal_href_context`, `binding.razor_inject`,
`data.razor_rendermode`, `type_relation.razor_inherits`,
`type_relation.razor_implements`, `definition.razor_type_parameter`,
`definition.razor_section`, `reference.razor_named_attribute_identifier_context`,
`call.csharp_global_member_string_context`.

On top of that, **11 field names were read that no Pack publishes** — `href`,
`type`, `name`, `route`, `declaration`, `mode`, `attribute_name`,
`handler_name`, `receiver`, `member`, `arg1` — so even had the kinds survived,
ten of the eleven rules would still have matched nothing. omega-razor publishes
**no field on any of its 56 templates**; everything below is built from kind,
name, path, span and the host's own built-ins.

Four defects beyond the dead kinds, which is why this is a rewrite and not a
translation:

1. **`blazor.component_view` was four outputs carrying no information.** For
   each `.razor` file it minted a `Component` and a `View` under two keys
   derived from the same path, then emitted `contains` *and* `renders` between
   them. Two entities and two relations that restate "this file exists" — the
   `entity_candidate whose key is its own input` the brief names in §3.
   (Worth recording: `data.file` is not a Pack kind but the host *does*
   synthesize one per artifact, `overlay.rs:41`. The rule would have fired. It
   still answered nothing.)
2. **Twelve entity kinds for eleven rules, ten of them appearing once.**
   `BaseType`, `Interface`, `TypeParameter`, `Section`, `EventBinding`,
   `HandlerReference`, `RouteReference`, `RenderMode`, `Dependency`, `View` —
   each a kind invented for one rule, so nothing could join to anything.
3. **Every key was the file path**, so a component and its `.razor.cs`
   code-behind were two unrelated subgraphs, and a service injected into six
   components was six `Dependency` entities keyed
   `blazor:dependency:{path}:{source.start}` — by *byte offset*. *Which
   components use IWeatherService* was unaskable by construction.
4. **The one real cross-file edge dangled.** `blazor.literal_href.navigation`
   targeted `blazor:route:{href}` with the raw href, while `blazor.page.route`
   minted `blazor:route:{route}` with a raw `@page` template; `/orders/{id}`
   and `/orders/5` would never have met even with both fields published.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which URL does this component serve | omega-razor `definition.config_route` (the `@page` string), in `**/*.razor` | `BlazorRoute` keyed on the route with HTTP params normalized, + `BlazorComponent serves BlazorRoute` |
| which layout wraps this page | omega-razor `relation.depends` (the `@layout` directive, its only source in Razor) | `BlazorComponent rendered_in_layout BlazorComponent` — a component-to-component edge across files, minted at both ends |
| what does this component inherit or implement | omega-razor `relation.implements` (`@inherits`, `@implements`), gated to file top level by `definition.container` being absent | `BlazorComponent derives_from BlazorType` — one `BlazorType` per base, so *which components are `IDisposable`* / *are layouts* is one hop |
| how is this component configured to render | omega-razor `relation.config` (the `@rendermode` value) | `BlazorComponent renders_as BlazorRenderMode` — the mode is the key, so *which components are `InteractiveWebAssembly`* is one hop |
| which services does this component depend on | omega-razor `definition.injected_service` (the `@inject` variable) joined `same`-span to `definition.declared_type_candidate` (its type) | `BlazorComponent injects BlazorService`, keyed by the **service type**, with the local property name as a relation attribute |
| what is this component's public API | omega-razor / omega-c-sharp `reference.attribute` named `Parameter`, `CascadingParameter`, `EditorRequired`, `SupplyParameterFrom*`, joined `within` to `definition.property` | `BlazorComponent declares_parameter BlazorParameter` — two rules, one per file kind |
| what C# does this component declare | omega-razor `definition.method` in `**/*.razor`; omega-c-sharp `definition.method` joined `within` `definition.class` in `**/*.razor.cs` | `BlazorComponent declares BlazorMember` — **this is the edge that joins a component to its code-behind**, because both rules land on `blazor:component:{class name}` |
| what runs when this component initializes or is disposed | omega-razor `definition.method` named `OnInitialized(Async)`, `OnParametersSet(Async)`, `OnAfterRender(Async)`, `SetParametersAsync`, `ShouldRender`, `BuildRenderTree`, `Dispose(Async)` | `BlazorMember implements_lifecycle BlazorLifecycleHook` — the hook name is the key, so *which components render after first paint* is one hop |
| which method does this markup call | omega-razor `reference.attribute_value` (`@onclick="Increment"` — the value is one C# identifier) joined by name to a `definition.method` in the same file | `BlazorComponent binds_handler BlazorMember`; the name join is what stops the edge dangling on a loop variable |

The component hub carries exactly one attribute, `component`, so the eight rules
that mint it agree on its value as well as its kind (§3g: only the first rule's
attributes survive). No rule uses `current`; every relation end is an explicit
`by_canonical_key`, and every key a relation addresses is minted by a rule whose
conditions are a superset of the addressing rule's (§3a, §3b).

## A field only the Pack can supply

**omega-razor, `reference.attribute_value`, the value `attribute`.** The Pack
publishes the Razor attribute name — `onclick`, `onchange`, `bind-Value` — as an
**attribute**, not a field (`packs/omega-razor/rules.json`, last template). Per
§3a an attribute is write-only: it can be compared to one literal constant by
`attribute_equals` and used for nothing else, so it cannot be a canonical key
part, a relation end, an entity attribute or a join key. No join reaches it
either — it is a sibling capture inside one query match, not a separate fact
with its own span. So `blazor.markup.handler` can state *this markup binds
method `Increment`* but not *on the click event*, and the family of questions
"which handlers run on form submit" is unanswerable. The fix is the same
one-word move wave 1 collected for omega-yaml and omega-hcl: publish
`attribute` under `fields` instead of `attributes`. **Not acted on here** —
Pack edits are out of scope for a Framework rewrite.

## Still to decide

1. **The component hub is keyed by name, not path.** `blazor:component:Counter`,
   from `path.stem` on the Razor side and from the enclosing `definition.class`
   on the code-behind side. That is Blazor's own identity — a component is
   referenced in markup as `<Counter />` — and it is the only thing that lets
   `Counter.razor` and `Counter.razor.cs` land on one entity, which is the
   whole cross-file value of this overlay. The cost is real: two components
   named `Button` in two folders and two namespaces merge into one entity.
   Keying by path would be exact and would leave the code-behind unreachable,
   because `path.stem` of `Counter.razor.cs` is `Counter.razor` and the overlay
   has no suffix-stripping join. The name was chosen; revisit it if a host join
   ever strips a path suffix.
2. **Lifecycle overrides written in code-behind are classified as members, not
   as hooks.** `blazor.lifecycle` is gated to `**/*.razor` so that its relation
   source, `blazor:member:{path.stem}.{name}`, is exactly the key `blazor.member`
   mints. Covering `**/*.razor.cs` needs a twelfth rule keyed on the joined class
   name; it was left out to hold the file at its former size.
3. **`@section` is not matched.** omega-razor emits `definition.section`, but
   `@section` is a `.cshtml` construct that `.razor` does not accept, and
   `.cshtml` is omega-framework-asp-net-core's scope. The kind is live and
   unclaimed; if Blazor's scope ever widens to `_Host.cshtml`, it is one rule.

## What is out of reach, and why

- **Navigation targets.** `NavigationManager.NavigateTo("/counter")` arrives as
  `call.method` named `NavigateTo` with no argument text — omega-razor publishes
  no argument on any template — and `<a href="/counter">` is plain markup the
  Pack does not emit at all. Both of the old file's `navigates_to` edges are
  therefore gone rather than ported, and *which page links to which* stays
  unanswered.
- **A parameter's declared type.** `definition.declared_type_candidate` spans
  the whole property declaration and `reference.attribute` spans the marker
  inside it. `fact_join_by_span`/`within` reaches a fact that *contains* the
  current one, never one contained by it, so the marker reaches the property
  and nothing reaches the property's type from the marker.
- **Component composition in markup.** omega-razor emits nothing for
  `<Counter Title="x" />`, so the render tree between components is invisible;
  `@layout` is the only component-to-component edge available.
