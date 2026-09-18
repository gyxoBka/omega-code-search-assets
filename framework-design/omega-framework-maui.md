# omega-framework-maui

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State before the rewrite

12 overlay rules, 12 detection rules. **0 can match, 12 cannot.**

Selector: `framework:maui`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `Component` | 3 |
| `Binding` | 3 |
| `Route` | 2 |
| `View` | 1 |
| `XamlResource` | 1 |
| `ServiceRegistration` | 1 |
| `ResourceDictionaryImport` | 1 |
| `TemplateReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `contains` | 1 |
| `renders` | 1 |
| `navigates_to` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `structured.entry` | 9 | **no** |
| `call.csharp_class_member_string_context` | 2 | **no** |
| `call.csharp_class_nested_member_string_context` | 1 | **no** |
| `call.csharp_service_registration_generic_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x16, `field_present` x14, `fact_kind` x12, `path_glob` x11, `attribute_equals` x9, `field_in` x4, `field_prefix` x3, `fact_join_by_field` x1, `(join)` x1.

Fields read: `attribute_name`, `element_tag`, `attribute_value`, `member`, `receiver`, `arg1`, `receiver_member`, `parent_attribute_name`, `child_attribute_name`, `parent_attribute_value`, `child_attribute_value`, `receiver_root`, `owner_class`, `owner_base`, `service_type`.

Path globs: `**/*.xaml`, `**/*.cs`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `maui.xaml.class_named-child` | kind `structured.entry`; field `child_attribute_name`, `child_attribute_value`, `parent_attribute_name`, `parent_attribute_value`; attribute `role` |
| `maui.route.literal_registration` | kind `call.csharp_class_member_string_context`; field `arg1`, `member`, `receiver` |
| `maui.navigation.literal_registered_route` | kind `call.csharp_class_member_string_context`, `call.csharp_class_nested_member_string_context`; field `arg1`, `member`, `owner_base`, `owner_class`, `receiver`, `receiver_member`, `receiver_root` |
| `maui.xaml.component` | kind `structured.entry`; field `attribute_name`; attribute `role` |
| `maui.shell.route` | kind `structured.entry`; field `attribute_name`, `element_tag`; attribute `role` |
| `maui.xaml.resource-reference` | kind `structured.entry`; field `attribute_name`; attribute `role` |
| `maui.services.registration` | kind `call.csharp_service_registration_generic_context`; field `member`, `receiver_member`, `service_type` |
| `maui.xaml.binding-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.staticresource-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.dynamicresource-expression` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.resource-dictionary-source` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |
| `maui.xaml.shell-content-template` | kind `structured.entry`; field `attribute_name`, `attribute_value`, `element_tag`; attribute `role` |

## What was wrong with it

### Wave 1: 12 rules, none of which could match

**All 12 rules were dead, and 9 of them could never have been anything else.**

- **9 of 12 matched `structured.entry`** with `attribute_equals role =
  xml_element_attribute` or `xml_parent_child_attribute_context`. No Pack emits
  that kind and no Pack publishes that attribute. XML is stated today by
  omega-xml as `definition.config_element` (name = the tag) and
  `definition.config_attribute` (name = the attribute name, value in the
  `attributes` map).
- **3 of 12 matched a private C# spelling** — `call.csharp_class_member_string_context`,
  `call.csharp_class_nested_member_string_context`,
  `call.csharp_service_registration_generic_context` — kinds the language-Pack
  rewrite removed. omega-c-sharp emits one `call.method` for all four call
  shapes, with `receiver_hint` or `qualifier`.
- **15 distinct field names were read that no Pack publishes**:
  `attribute_name`, `attribute_value`, `element_tag`, `member`, `receiver`,
  `receiver_member`, `receiver_root`, `arg1`, `owner_class`, `owner_base`,
  `service_type`, `parent_attribute_name`, `parent_attribute_value`,
  `child_attribute_name`, `child_attribute_value` — plus `implementation_type`
  and `child_tag`, read in outputs and not even declared in the matches.
- **4 rules were one rule written four times.** `binding-expression`,
  `staticresource-expression`, `dynamicresource-expression` and
  `resource-reference` were byte-identical apart from one `field_prefix`
  literal, and all four emitted the same `Binding` entity keyed
  `maui:binding:{path}:{source.start}` — an offset in a file, which nothing can
  address and which restates only *there was some markup here*.
- **5 of the 8 entity kinds were keyed by position and carried no relation.**
  `XamlResource`, `Binding`, `ServiceRegistration`, `ResourceDictionaryImport`
  and `TemplateReference` were all `…:{path}:{source.start}`. The file declared
  3 relations in total, and 3 of the 4 pointed at keys only one other rule
  minted under strictly narrower conditions.
- **The one join in the file was unreachable twice over**: a
  `fact_join_by_field` on `arg1` between two kinds no Pack emits, on a field no
  Pack publishes.

9 rules replaced the 12, all live.

### Wave 2: 9 live rules, 7 of whose entities never reached the graph

The 9 rules audited clean — `overlay_audit.py` reported 9 live, 0 dead, both
before and after this pass — and were still wrong in the way the audit cannot
see. `pack-design/key_collisions.py maui` reported **7 entity outputs
overwritten by a same-key rule that sorts first**, across three key templates:

| key template | kind that materialized | kinds computed and discarded |
|---|---|---|
| `maui:type:{cls.definition.name}` | `MauiCommandOwner` (`maui.mvvm.relay_command`) | `MauiPage`, `MauiShellQueryReceiver`, `MauiViewModel` |
| `maui:type:{definition.name}` | `MauiApplication` (`maui.app.root`) | `MauiNavigationTarget`, `MauiService`, `MauiRouteTarget` |
| `maui:type:{owner.definition.name}` | `MauiNavigationSource` (`maui.navigation.push`) | `MauiRouteRegistrar` |

`Entity::named` builds the entity id from the canonical key alone — the kind is
not part of the identity — and `apply_overlay_runs` does
`entities.entry(id).or_insert(entity)`, so the alphabetically first rule id wins
with **its kind and its attributes**, and every other rule's output for that key
is dropped silently. The practical cost was total: in a CommunityToolkit.Mvvm
app every view model carries `[RelayCommand]`, so `maui.mvvm.relay_command`
sorted first on every view-model class and **`MauiViewModel` never materialized
once**. `MauiPage` lost its `base` and `code_behind` attributes the same way, so
*which file is this page's code-behind* had no answer although a rule computed
it. Eleven entity kinds in total were being written to one key space.

Two smaller collisions of the same shape: `maui:app:{path}` was minted by
`maui.app.root` with `{host_file, root_class}` and by
`maui.services.registration` with `{host_file}` alone — same kind, different
attributes, and only the first rule's attributes survive; and
`maui:type:{path.stem}` carried an eleventh kind, `MauiXamlBackedType`.

**The fix, brief §3g.** `maui:type:{…}` is now one neutral kind, `MauiType`,
minted by every rule that needs a C# type as a relation end, carrying exactly
one attribute (`class`) with the same value computed the same way in every rule
— so a shared key is now the intended hub behaviour rather than a defect. Each
classification that carries attributes of its own moved to its own key space
(remedy 2) — `maui:page:{class}`, `maui:viewmodel:{class}`,
`maui:application:{class}`, `maui:query_receiver:{class}`,
`maui:service:{path}:{type}` — and is tied back to the hub by a `classifies`
relation carrying an `as` attribute. The two classifications that carried no
attributes of their own (`MauiRouteTarget`/`MauiRouteRegistrar`,
`MauiNavigationTarget`/`MauiNavigationSource`) needed no entity at all (remedy
1): being the source or the target of a `routes_to` or `navigates_to` edge
between two `MauiType`s is the whole of what they said. `MauiApp` now carries
`{host_file}` in both rules that mint it, and the root class it boots is stated
by the `bootstraps` edge instead of by an attribute one of the two rules would
have lost.

Net: 14 declared entity kinds became 9, 6 relations became 8, the rule count is
unchanged at 9, every canonical key template is minted under exactly one kind
with one attribute set, and `key_collisions.py maui` reports nothing.

### Wave 3: nine live, collision-free rules that could not name a single route

The 9 rules audited clean and collided on nothing, and the file still could not
answer the one question a MAUI Shell app is organised around: **which route
reaches this page.** `coverage.gaps[0]` said so in as many words -- "omega-c-sharp
emits no call argument, so the route string of
`Routing.RegisterRoute("details", typeof(DetailsPage))` and the target of
`Shell.Current.GoToAsync("//details")` are not stated" -- and
"A field only the Pack can supply" asked omega-c-sharp for the field.

That is no longer true. omega-c-sharp's `call.member` and `call.plain` templates
now publish `call.arg0`, `call.arg0_text`, `call.arg0_name`, `call.arg1`,
`call.arg1_text`, `call.arg2`, `call.last_arg`, `call.last_arg_name` and
`receiver`. Measured with `dump_call_emissions.exe` over a hand-written
`AppShell.cs`:

```
157-210  call.method  RegisterRoute  call.arg0="details"  call.arg0_text=details
                                     call.arg1=typeof(DetailsPage)  receiver_hint=Routing
197-208  reference.type  DetailsPage
341-377  call.method  GoToAsync      call.arg0="//details"  call.arg0_text=//details
                                     receiver_hint=Shell.Current
393-436  call.method  GoToAsync      call.arg0=$"details?id={Id}"
                                     call.arg0_text=$"details?id={Id}
126-147  call.method  InitializeComponent  call.arg0=None  call.arg0_text=""
```

Concretely wrong, with counts:

- **Two of nine rules named a route construct and threw the route away.**
  `maui.shell.registered_route_target` matched `Routing.RegisterRoute` and emitted
  `MauiType(AppShell) -routes_to-> MauiType(DetailsPage)` -- a page-to-page edge
  with the route string, the only thing that makes it a *route*, dropped. There
  was no rule for `GoToAsync` at all, so **0 of the 3 navigation calls in the
  measured file** produced anything.
- **`GoToAsync` was 1 of 2 navigation spellings and the file covered the other
  one only.** `maui.navigation.push` covered `PushAsync`/`PushModalAsync`, which
  is the pre-Shell API; Shell navigation, which is what a .NET MAUI 6+ app
  actually uses, was uncovered.
- **1 stale coverage gap and 1 stale Pack request.** `coverage.gaps[0]` and the
  omega-c-sharp half of "A field only the Pack can supply" both asserted the
  absence of a field that exists; both are deleted here.

What changed: `maui.shell.registered_route_target` became
`maui.shell.route_registration` and now mints the route itself; a tenth rule,
`maui.shell.goto_route`, states the navigation side. 9 rules became 10, 9 entity
kinds became 10 (`MauiRoute`), 8 relations became 9 (`registers`).

**The two sides do meet.** This is the check the brief warns about -- both keys
being minted proves nothing if they are different keys. `maui:route:{route}` is
keyed on the `route` attribute, and that attribute is
`{"kind": "normalize_route", "source": "...call.arg0_text"}` in **both** rules,
so the host's `normalize_http_path` runs on both sides: it does
`trim_matches('/')` before splitting, so the registration's `"details"` and the
navigation's `"//details"` both render `/details`, one entity. The route's page
end meets the declaration side the same way: `routes_to` targets
`maui:type:{definition.name}` where `definition.name` is the `reference.type`
`DetailsPage` emitted inside the call span, and `maui.page` mints
`maui:type:{cls.definition.name}` for the class `DetailsPage` in
`DetailsPage.xaml.cs`. Same simple name, same path-free hub key.

**Both rules require a string literal**, `field_prefix call.arg0 = "\""`. That
one clause does the work of three guards: a call with no arguments has
`call.arg0` absent (measured above on `InitializeComponent()`), a variable
argument has no quote byte, and an interpolated string starts with `$` -- and
the measurement shows exactly why the last one matters, since
`$"details?id={Id}"` survives `call.arg0_text`'s single strip pair as
`$"details?id={Id}` and would have minted the route `/$"details?id={Id}`.
`call.arg0_text` is keyed on rather than `call.arg0`, because `call.arg0` keeps
its quote bytes and a canonical-key template has no strip.

## What it states now

The hub is `maui:type:{ClassName}` — a C# type by its simple name, deliberately
path-free, so that a page declared in `Pages/DetailsPage.xaml.cs`, registered in
`MauiProgram.cs` and navigated to from `AppShell.xaml.cs` is one entity. It has
**one** kind, `MauiType`, and one attribute; everything that distinguishes a
type is a relation or a separately-keyed facet entity. Every relation end below
is minted by the same rule that addresses it, under the same clauses, so nothing
dangles.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which classes are pages, shells or views, and which file is the code-behind | `relation.implements` named one of 13 MAUI base types, `fact_join_by_span`/`within` → `definition.class` | `MauiPage` at `maui:page:{class}` with `base` and `code_behind`; `MauiType` at `maui:type:{class}`; relation `classifies` (`as` = page) |
| Which classes are view models | `relation.implements` named `ObservableObject`, `ObservableRecipient`, `ObservableValidator`, `INotifyPropertyChanged`, joined `within` its class | `MauiViewModel` at `maui:viewmodel:{class}` with `base`; `MauiType`; relation `classifies` (`as` = view_model) |
| Which class is the application root, and where the host is built | `reference.type` (the `<App>` type argument) joined `within` `call.method UseMauiApp` | `MauiApplication` at `maui:application:{class}`, `MauiApp` at `maui:app:{path}`, `MauiType`; relations `classifies` and `bootstraps` |
| What is in the DI container, with what lifetime, and which type it resolves to | `reference.type` (each generic argument) joined `within` `call.method` named `Add*`/`TryAdd*` with a `receiver_hint` | `MauiService` at `maui:service:{path}:{type}` with `lifetime` and `container`; relations `provides` from `maui:app:{path}` and `resolves_to` to `maui:type:{type}` |
| Which route reaches this page, and which class registered it | `reference.type` (the `typeof(Page)`) joined `within` `call.method RegisterRoute` whose `call.arg0` is a string literal, and `within` `definition.class` | `MauiRoute` at `maui:route:{route}`, route = `normalize_route(reg.call.arg0_text)`; two `MauiType`s; relation `routes_to` from the route to the page, relation `registers` from the registrar class to the route |
| Which class navigates to which Shell route | `call.method GoToAsync` with a string-literal `call.arg0`, joined `within` `definition.class` | `MauiRoute` at `maui:route:{route}` (same normalization, so it is the entity the registration minted); `MauiType`; relation `navigates_to` with `via` and `declared_in` |
| Which page pushes which page on the pre-Shell navigation stack | `reference.type` (the `new Page()`) joined `within` `call.method PushAsync`/`PushModalAsync` and `within` `definition.class` | two `MauiType`s; relation `navigates_to` with `via` and `declared_in` |
| Which pages receive Shell query parameters | `reference.attribute QueryProperty` joined `within` `definition.class` | `MauiShellQueryReceiver` at `maui:query_receiver:{class}`; `MauiType`; relation `classifies` (`as` = shell_query_receiver) |
| Which commands a view model exposes to XAML `Command="{Binding …}"` | `reference.attribute RelayCommand` joined `within` `definition.method` and `within` `definition.class` | `MauiCommand` at `maui:command:{class}.{method}`; `MauiType`; relation `exposes` from `maui:type:{class}` |
| Which XAML file declares a page's visual tree | `definition.config_attribute` named `xmlns` whose `value` attribute equals the MAUI 2021 schema URI, joined `within` `definition.config_element` (the root tag) | `MauiXamlView` at `maui:xaml:{path}`; `MauiType` at `maui:type:{path.stem}`; relation `renders` |

Everything was measured, not assumed, with
`target/release/examples/dump_call_emissions.exe` over a hand-written
`MauiProgram.cs` and `AppShell.xaml`. The three span containments the file
depends on were confirmed there: `reference.type App` at 218–221 lies inside
`call.method UseMauiApp` at 186–224; `reference.attribute QueryProperty` at
545–580 lies inside `definition.class DetailsPage` at 544–748;
`reference.attribute RelayCommand` at 1153–1165 lies inside
`definition.method LoadAsync` at 1152–1205.

There is a second hub, `maui:route:{route}`, kind `MauiRoute`, one attribute
`route` holding the route-normalized string. It is minted by the two route rules
above and by nothing else, with the same kind and the same attribute computed the
same way, so a route registered in `AppShell.xaml.cs` and navigated to from
`MainPage.xaml.cs` is one entity. MAUI Shell routes have no HTTP method, so the
key is `maui:route:{route}` rather than the `http:{method}:{normalized_route}`
the HTTP frameworks here use; the normalization is the same function.

An agent can now walk `MainPage -navigates_to-> /details -routes_to-> DetailsPage`
and `AppShell -registers-> /details`, and from `DetailsPage` on to its `MauiPage`
facet (base class, code-behind file), its `MauiXamlView`, its `[QueryProperty]`
classification and its `[RelayCommand]`s -- none of which the file could reach
from a route before, because it had no route.

All 10 rules are live; none is kept against a fact no Pack emits.

## A field only the Pack can supply

**None outstanding for omega-c-sharp.** The request this file carried in wave 2
-- `call.method`'s first string-literal argument -- has landed as
`call.arg0` / `call.arg0_text` on the `call.member` and `call.plain` templates,
and is what the two route rules key on. The request is withdrawn.

**omega-xml, `definition.config_attribute`: move `value` from `attributes` to
`fields`.** Already recorded in `OWED.md` item 1 for omega-yaml and omega-json
on `definition.config_key`; omega-xml has the identical shape. No built-in fact
name reaches it -- `definition.name` is the attribute's *name* -- and no
`fact_join_by_span` reaches it either, because the value is carried on the
attribute fact itself, so there is no second fact to join to; `attribute_equals`
is the only clause that reads an attribute at all, and it compares against one
literal constant. Until it moves, `Route="home"` on a `ShellContent`,
`x:Class="MyApp.AppShell"`, `ContentTemplate="{DataTemplate local:MainPage}"`
and every `{Binding ...}` can be tested for equality with one constant and used
for nothing else. The cost is specific now that routes exist: a route declared
**only** in XAML, by `Route=` on a `ShellContent` element, is the one MAUI route
spelling this file still cannot mint, and it would meet `maui:route:{route}`
exactly if the value were a field. The one rule this file keeps against XAML
exploits the single available comparison -- `xmlns` equals the MAUI schema URI
-- and takes the code-behind identity from `path.stem` instead of from
`x:Class`.

## Still to decide

1. **`.xaml` and `.cs` reach no parser.** `grammars/omega-xml/manifest.toml` and
   `grammars/omega-c-sharp/manifest.toml` both declare `extensions = []`, and
   `ParserRegistry::detect_path` matches on filename, shebang, then extension
   only. So `by_language("xaml")`, `by_language("xml")` and `by_language("cs")`
   all miss, and no MAUI file is parsed at all today. omega-ruby has the same
   empty list. This is a grammar-manifest gap, not a Pack or Framework one, and
   it is outside this file's scope -- but every rule here, and every
   omega-framework-asp-net-core and omega-framework-ruby-on-rails rule, is inert
   until `extensions` is filled in. omega-xml's `language = "msbuild"` suggests
   the intended list is `["xml", "xaml", "csproj", "props", "targets", "axml",
   "resx"]`.
2. **`RegisterRoute(nameof(DetailsPage), typeof(DetailsPage))` mints no route,
   deliberately.** It is a common MAUI spelling, and `call.arg0_text` delivers it
   as the literal text `nameof(DetailsPage)` -- which is not the route the
   runtime uses, so keying on it would mint a wrong identity that the `GoToAsync`
   side would nonetheless agree with, producing a confidently wrong answer rather
   than no answer. The `nameof` call does emit its own `call.method nameof` fact
   with `call.arg0_text=DetailsPage` inside the outer call's span (measured at
   517-527 inside 502-534 for the `[QueryProperty]` case), so a
   `fact_join_by_span` / `within` could unwrap it -- but that join cannot tell the
   route argument's `nameof` from the type argument's, and a `RegisterRoute`
   written this way has one of each. Excluding it is the honest answer until the
   Pack states argument position on the inner call.
3. **A query string stays in the route identity.** `GoToAsync("details?id=1")`
   normalizes to `/details?id=1` and does not meet the `/details` that
   `RegisterRoute("details", ...)` mints. Splitting the query off is
   route-normalization behaviour, not this file's, and `normalize_http_path` is
   shared by every HTTP framework in the repository; it is not worth diverging
   for here.
4. **`maui.xaml.view` is `heuristic`, not `exact`.** It equates the code-behind
   class with the XAML file stem, which is the MAUI project template's
   convention and what `x:Class` normally says -- but `x:Class` is what actually
   decides it, and that value is unreachable (above). If the omega-xml `value`
   field lands, the rule should key on `x:Class`'s last dot-segment instead and
   be promoted to `exact`.
5. **`[ObservableProperty]` is unreachable and stays that way.** Measured here:
   the attribute spans 1101-1119 while `definition.field title` spans
   1140-1145, because omega-c-sharp spans a field on the `variable_declarator`
   and the attribute node is a sibling of the enclosing `field_declaration`. So
   *which properties does this view model publish* cannot be answered from the
   attribute. This is the same span mismatch wave 1 recorded for
   `[SerializeField]` in omega-framework-unity; one fix serves both, and it is a
   Pack span change rather than a field.
6. **`AddSingleton<IFoo, Foo>()` yields two `reference.type` facts in one call
   span with no order.** Both become a `MauiService` and both get a `provides`
   edge, so the graph says the container provides `IFoo` and `Foo` without
   saying that `Foo` implements `IFoo` for this container. Argument order is
   exactly the "shape belongs in the Pack as a named fact" case of
   `00-CONTRACT.md` section 5; it is not worth a Pack field on its own and is
   left stated as two registrations. The new `call.arg0` / `call.arg1` fields do
   not help: these are *generic type* arguments, not value arguments, and
   `call.args` captures the `argument_list` only.
