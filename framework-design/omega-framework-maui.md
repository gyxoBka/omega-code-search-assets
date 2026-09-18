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

9 rules replace the 12. Every one is live, and `overlay_audit.py` reports zero
that cannot match.

## What it states now

The hub is `maui:type:{ClassName}` — a C# type by its simple name, deliberately
path-free, so that a page declared in `Pages/DetailsPage.xaml.cs`, registered in
`MauiProgram.cs` and navigated to from `AppShell.xaml.cs` is one entity. Every
relation end below is minted by the same rule that addresses it, so nothing
dangles.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which classes are pages, shells or views | `relation.implements` named one of 13 MAUI base types, `fact_join_by_span`/`within` → `definition.class` | entity `MauiPage` at `maui:type:{class}` with `base` and `code_behind` |
| Which classes are view models | `relation.implements` named `ObservableObject`, `ObservableRecipient`, `ObservableValidator`, `INotifyPropertyChanged`, joined `within` its class | entity `MauiViewModel` at `maui:type:{class}` |
| Which class is the application root, and where the host is built | `reference.type` (the `<App>` type argument) joined `within` `call.method UseMauiApp` | entities `MauiApplication` at `maui:type:{App}` and `MauiApp` at `maui:app:{path}`, relation `bootstraps` |
| What is in the DI container and with what lifetime | `reference.type` (each generic argument) joined `within` `call.method` named `Add*`/`TryAdd*` with a `receiver_hint` | entity `MauiService` at `maui:type:{type}` with `lifetime` and `container`, relation `provides` from `maui:app:{path}` |
| Which pages are registered for Shell routing, and from which class | `reference.type` (the `typeof(Page)`) joined `within` `call.method RegisterRoute` and `within` `definition.class` | entities `MauiRouteTarget` + `MauiRouteRegistrar`, relation `routes_to` |
| Which page navigates to which page | `reference.type` (the `new Page()`) joined `within` `call.method PushAsync`/`PushModalAsync` and `within` `definition.class` | entities `MauiNavigationSource` + `MauiNavigationTarget`, relation `navigates_to` with `via` |
| Which pages receive Shell query parameters | `reference.attribute QueryProperty` joined `within` `definition.class` | entity `MauiShellQueryReceiver` at `maui:type:{class}` |
| Which commands a view model exposes to XAML `Command="{Binding …}"` | `reference.attribute RelayCommand` joined `within` `definition.method` and `within` `definition.class` | entity `MauiCommand` at `maui:command:{class}.{method}`, relation `exposes` |
| Which XAML file declares a page's visual tree | `definition.config_attribute` named `xmlns` whose `value` attribute equals the MAUI 2021 schema URI, joined `within` `definition.config_element` (the root tag) | entities `MauiXamlView` at `maui:xaml:{path}` + `MauiXamlBackedType` at `maui:type:{path.stem}`, relation `renders` |

Everything was measured, not assumed, with
`target/release/examples/dump_call_emissions.exe` over a hand-written
`MauiProgram.cs` and `AppShell.xaml`. The three span containments the file
depends on were confirmed there: `reference.type App` at 218–221 lies inside
`call.method UseMauiApp` at 186–224; `reference.attribute QueryProperty` at
545–580 lies inside `definition.class DetailsPage` at 544–748;
`reference.attribute RelayCommand` at 1153–1165 lies inside
`definition.method LoadAsync` at 1152–1205.

## A field only the Pack can supply

**omega-c-sharp, `call.method`: the call's first string-literal argument.**

MAUI's two route statements are
`Routing.RegisterRoute("details", typeof(DetailsPage))` and
`Shell.Current.GoToAsync("//details")`. The overlay can reach the *page type*
of the first, because `typeof(DetailsPage)` produces a `reference.type` inside
the call's span. It can reach nothing of the route *name*, which is the thing a
person asks about — *which URL reaches this page*. `definition.name` on the
call is `RegisterRoute`; `receiver_hint` is `Routing`; `fact_join_by_span` has
nothing to join to, because omega-c-sharp emits no fact at all for a
`string_literal` argument. There is no derivation and no join that reaches it;
only a Pack field can.

This is the same field omega-framework-django asked omega-python for in wave 2
(`OWED.md` item 1, "the call's first string-or-identifier argument"), so it is
one row on an existing request, not a new mechanism.

**omega-xml, `definition.config_attribute`: move `value` from `attributes` to
`fields`.** Already recorded in `OWED.md` item 1 for omega-yaml and omega-json
on `definition.config_key`; omega-xml has the identical shape. Until it moves,
`Route="home"`, `x:Class="MyApp.AppShell"`, `ContentTemplate="{DataTemplate
local:MainPage}"` and every `{Binding …}` can be compared to one literal
constant and used for nothing else. The one rule this file keeps against XAML
exploits exactly that single comparison — `xmlns` equals the MAUI schema URI —
and takes the code-behind identity from `path.stem` instead of from `x:Class`.

## Still to decide

1. **`.xaml` and `.cs` reach no parser.** `grammars/omega-xml/manifest.toml` and
   `grammars/omega-c-sharp/manifest.toml` both declare `extensions = []`, and
   `ParserRegistry::detect_path` matches on filename, shebang, then extension
   only. So `by_language("xaml")`, `by_language("xml")` and `by_language("cs")`
   all miss, and no MAUI file is parsed at all today. omega-ruby has the same
   empty list. This is a grammar-manifest gap, not a Pack or Framework one, and
   it is outside this file's scope — but every rule here, and every
   omega-framework-asp-net-core and omega-framework-ruby-on-rails rule, is inert
   until `extensions` is filled in. omega-xml's `language = "msbuild"` suggests
   the intended list is `["xml", "xaml", "csproj", "props", "targets", "axml",
   "resx"]`.
2. **`maui.xaml.view` is `heuristic`, not `exact`.** It equates the code-behind
   class with the XAML file stem, which is the MAUI project template's
   convention and what `x:Class` normally says — but `x:Class` is what actually
   decides it, and that value is unreachable (above). If the omega-xml `value`
   field lands, the rule should key on `x:Class`'s last dot-segment instead and
   be promoted to `exact`.
3. **`[ObservableProperty]` is unreachable and stays that way.** Measured here:
   the attribute spans 1101–1119 while `definition.field title` spans
   1140–1145, because omega-c-sharp spans a field on the `variable_declarator`
   and the attribute node is a sibling of the enclosing `field_declaration`. So
   *which properties does this view model publish* cannot be answered from the
   attribute. This is the same span mismatch wave 1 recorded for
   `[SerializeField]` in omega-framework-unity; one fix serves both, and it is a
   Pack span change rather than a field.
4. **`AddSingleton<IFoo, Foo>()` yields two `reference.type` facts in one call
   span with no order.** Both become a `MauiService` and both get a `provides`
   edge, so the graph says the container provides `IFoo` and `Foo` without
   saying that `Foo` implements `IFoo` for this container. Argument order is
   exactly the "shape belongs in the Pack as a named fact" case of
   `00-CONTRACT.md` §5; it is not worth a Pack field on its own and is left
   stated as two registrations.
