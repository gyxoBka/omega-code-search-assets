# omega-framework-angular

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

14 overlay rules, 4 detection rules. **14 live, 0 cannot match.**
`key_collisions.py` and `dangling_ends.py` both report nothing.

Selector: `framework:angular`. Maturity: `semantic-overlay-full`.
Packs: `omega-typescript`, `omega-html`.

---

## What was wrong with it

The file held **31 rules and not one of them could match**. Three separate
defects, each measurable.

### 1. Twenty-five rules were keyed to the old generator vocabulary

Ten fact kinds, no Pack emits any of them:

| kind no Pack emits | rules |
|---|---|
| `import.ecmascript_named_binding_context` | 15 |
| `reference.typescript_class_decorator_object_array_identifier_context` | 8 |
| `data.html_attribute_context` | 5 |
| `reference.typescript_class_decorator_object_string_field_context` | 3 |
| `reference.typescript_class_member_decorator_context` | 2 |
| `reference.typescript_class_member_marker_decorator_context` | 2 |
| `call.target_candidate` | 1 |
| `import.target_candidate` | 1 |
| `reference.typescript_class_decorator_object_array_string_context` | 1 |
| `reference.typescript_constructor_parameter_type_context` | 1 |
| `data.html_element_text_context` | 1 |

With them went **thirteen field names no Pack publishes** — `owner_class`,
`decorator_name`, `module_source`, `imported_name`, `field_name`,
`item_identifier`, `item_string`, `string_value`, `member_name`,
`parameter_name`, `parameter_type`, `attribute_name`, `tag`. Of the file's 118
`field_present` and `field_equals` clauses, only the handful naming `path`,
`definition.name` and `source.start` could ever have resolved. The names describe the *shape of the intended match*, not facts: a Pack
that spells one kind per decorator-metadata-container-shape is the vocabulary
the Pack rewrite deleted on purpose.

### 2. The remaining six rules gated on `external_path_matches` for a scoped package

Eight rules carried ten `external_path_matches` clauses naming
`@angular/core`, six of them as the rule's only discriminator. Two things were
wrong with that and only one is now fixed.

`parse_external_path` (`materialize.rs:560`) **now** keeps a scoped npm package
whole, so `@angular/core` is the package. But **`member_in` was never
reachable**: the segments left after the package name are the member, and for
`import { Component } from '@angular/core'` there are none. `external.member` is
`None` for every bare package import in every language. The six
`member_in: ["Component"]` clauses were false for every possible input even with
the host fix.

And the package side is, by a reading of the build path, still empty for
TypeScript. See **A finding that is not this Framework's alone** below. The
rewrite therefore uses **no `external_path_matches` clause at all**.

### 3. Both invisible defects were present

`key_collisions.py` reported **3 entity outputs discarded**: four template rules
minted `angular:template-binding:{path}:{source.start}` under four different
kinds, and `angular.template.event-binding` sorts first, so an `[input]`, a
`#ref` and an `*ngIf` all reached the graph as `EventBinding` — when the rules
matched anything at all, which they did not.

`dangling_ends.py` reported **17 relation ends addressing a key template no rule
mints**: sixteen rules sourced their relation at `angular:type:{path}:
{owner_class}` and one at `angular:component:{path}:{owner_class}`, while the
only rules that minted a key in those spaces wrote `{definition.name}` — and
`definition.name` on a `reference.decorator` fact is the *decorator's* name, so
the key they minted was `angular:type:…:Component`, not `…:HeroComponent`.
Nothing in the file would ever have met.

Four rules also only restated their input: `angular.generic-dependency` minted
one `Dependency` named `@angular/core` for an import that the Pack already
states as `import.module @angular/core`, and `angular.generic-api-call` minted
an `ApiUse` keyed by its own byte offset and pointed a relation at it from
itself.

---

## What it states now

Every rule is written against measured emissions. The measurements are
`dump_call_emissions` over a hand-written `hero.component.ts`,
`sig.component.ts` and `hero.component.html`.

Two idioms carry the file.

**The import join replaces `external_path_matches`.** `binding.import_symbol`
publishes a `qualifier` field holding the module specifier, so

```json
{"kind": "fact_join_by_field", "fact_kind": "binding.import_symbol",
 "current_field": "definition.name", "join_field": "definition.name",
 "same_path": true,
 "where": [{"kind": "field_equals", "field": "qualifier", "value": "@angular/core"}]}
```

says *the name `Component` written here is bound by a named import from
`@angular/core`* — exactly what the broken clause was reaching for, through
fields, with no dependency on the external environment. Ten rules carry it on
the construct's own name; two carry the same join on `path`, as a
does-this-file-use-Angular gate.

**A class decorator is not inside its class.** Measured: for
`@Component({…})\nexport class HeroComponent`, the decorator spans 201–210 and
`definition.class` spans 372–722. The decorator is a sibling of the
`export_statement`, so neither `definition.container` nor a `within` span join
reaches the class, and the class is bound by a same-path join instead. A
*member* decorator is different — `@Input() hero: Hero` puts the decorator at
415–420 inside `definition.field` at 414–433 — so those rules use `within`, and
they must: `definition.container` on a member decorator resolves to
`definition.return_type_candidate` (`Hero`), which shares the field's span and
can sort last in the ancestor chain.

| what it states | which Pack fact | which entity or relation |
|---|---|---|
| this class is an Angular component | `reference.decorator` `Component` + `binding.import_symbol qualifier=@angular/core` + `definition.class` in the same file | `Component` `angular:component:{path}:{class}`, `specializes` from the `AngularType` hub |
| …and it renders this template file | the same, plus `path.dir`/`path.stem` | `Template` `angular:template:{dir}/{stem}`, `renders` component -> template |
| this class is a directive / an NgModule / a pipe | the same with `Directive` / `NgModule` / `Pipe` | `Directive`, `Module`, `Pipe`, each `specializes` from the hub |
| this class is an injectable service | the same with `Injectable` | `Injectable` `angular:injectable:{class}` — path-free, so a consumer in another file lands on it |
| this file is a component template | `data.file` + `**/*.component.html` | `Template` `angular:template:{dir}/{stem}` |
| this template places `<app-hero-detail>` | `reference.custom_element` (omega-html) in `**/*.component.html` | `TemplateElement` `angular:element:{tag}` — path-free, so every use of a tag is one entity — and `contains` template -> element |
| this member is a declared input | `reference.decorator` `Input` joined `within` `definition.field` and `within` `definition.class` | `Input` `angular:input:{path}:{class}:{member}`, `has_input` from the hub |
| …in the signal spelling | `call.function` `input`/`model` joined the same way | the same key and the same relation |
| this member is a declared output | `reference.decorator` `Output`, or `call.function` `output` | `Output`, `has_output` from the hub |
| this member is reactive state | `call.function` `signal`/`computed`/`linkedSignal`/`toSignal` | `ReactiveState`, `has_state` carrying which factory made it |
| this Angular type injects this service | `definition.field` `within` the `constructor` method, `same`-span `definition.return_type_candidate` for the written type | `injects` hub -> `angular:injectable:{type}`, carrying the parameter name |
| this component runs code on this lifecycle hook | `definition.method` named `ngOnInit`…`ngOnDestroy` `within` `definition.class` | `LifecycleHook`, `has_lifecycle` from the hub |

**The two answers no language Pack can give**, and the reason the overlay
exists:

- *Which template does this component render, and which class owns this
  template file?* The `.ts` and the `.html` are two artifacts with no reference
  between them that any Pack states; they meet because `hero.component.ts` and
  `hero.component.html` have the same `path.stem`. This is the blazor idiom.
- *Which components inject `HeroService`?* `angular:injectable:{class}` is minted
  both by the `@Injectable` class and by every constructor parameter typed with
  it, in any file, so the edge crosses files on the one name TypeScript writes
  in both places.

### Key spaces

One kind per key space, per brief §3g. `angular:type:{path}:{class}` is the
neutral hub every member, injection and lifecycle rule points at, and every rule
that addresses it mints it in the same rule under `AngularType` with the same
one attribute. The classifications each have their own space
(`angular:component:`, `angular:directive:`, `angular:module:`, `angular:pipe:`,
`angular:injectable:`) and reach the hub by `specializes`, which keeps every
kind and every attribute set — remedy 2, the stated default for a type that is
several things at once.

Two key spaces are deliberately path-free, because their whole purpose is to be
met from another file: `angular:injectable:{class}` and `angular:element:{tag}`.

---

## A finding that is not this Framework's alone

**`external.package` is, by a reading of the build path, still empty for
TypeScript after the `qualifier` fix**, and an overlay that trusts it will
silently match nothing. The chain:

1. `packs/omega-typescript/rules.json` now publishes `qualifier` on
   `binding.import_symbol` — measured, `qualifier="@angular/core"`.
2. `surface.rs:376` copies `occurrence.qualifier` into
   `SurfaceBinding::target_hint`.
3. `production.rs:4310-4321` then **overwrites every binding's `target_hint`**
   with `import_module_keys(current, raw, rules, 64)`, keeping it only when
   exactly one candidate survives.
4. `module.rs:184-197`: `@angular` is not a root, current or parent marker, so
   `bases` is empty and the default `ImportBasePolicy::RootAndCurrent`
   (`policy.rs:37`) inserts **both** the empty base and the current artifact's
   module key. `omega-typescript` declares no module rules, so the default
   applies, and the result is two candidates — `@angular/core` and
   `<this file>/@angular/core`.
5. Two candidates means `exact.len() != 1`, so `target_hint` becomes `None`,
   so `external_environment` registers nothing, so `OverlayFact.external` is
   `None`.

This is the "not yet shown end to end" caveat of commit `e93e8ef` and `OWED`
item 1, and it is worth resolving before another JavaScript-family Framework is
written against `external_path_matches`: the fix is one `[module_rules]` block
(`import_base = "root"`) in the JS/TS Pack manifests, or a bare-specifier branch
in `import_module_keys`. **This overlay does not depend on it either way** — the
`binding.import_symbol` / `qualifier` join reaches the same answer through
fields.

Second, smaller: `external.member` can never hold for a bare package import in
any language, because `parse_external_path` puts the whole specifier into
`package` and leaves `segments` empty. `member_in` is reachable only for a
dotted or `::`-scoped target.

---

## A field only the Pack can supply

Nothing in this rewrite needs one. Two answers are out of reach and both are the
same shape — **a value written as a call argument or an object-literal
property** — which is not a field on an existing emission but a fact the Pack
does not state at all:

- `omega-typescript`, a new `definition.decorator_metadata`-shaped fact, would
  be needed for `selector`, `templateUrl`, `styleUrls`, `imports`, `providers`,
  `declarations`, `exports`. Without `selector` an `<app-hero-detail>` in a
  template cannot be resolved to the class that declares it; without
  `templateUrl` the component/template edge rests on the filename convention.
  No join reaches it: the metadata object is not a declaration, so it produces
  no fact to join `within` or `same`.
- the same Pack, for a call argument: `inject(HeroService)` and
  `@ViewChild(ChildComponent)` name their subject as an argument identifier,
  which no Pack publishes. This is `OWED` item 10's family (omega-go and the
  route strings), not an Angular-specific ask, and it is why DI is stated only
  for the constructor-parameter spelling.

Neither is worth a field on `definition.field` or `call.function`; both are new
Pack patterns, and they belong in the Pack design, not here.

---

## Still to decide

1. **The same-path class join is the file's one loose clause.** A class
   decorator cannot be span-joined to its class, so `angular.type.*` binds
   *every* `definition.class` in the file. In an Angular file that is the one
   decorated class; in `@Injectable() export class FooService {}` plus
   `export class FooError extends Error {}` it mints `FooError` as a service
   too. The alternative — matching `definition.class` and joining the decorator
   by path — is exactly as loose in the same case and loses nothing, so it was
   not worth the churn. A `fact_join_by_span` with a `nearest_following`
   relation would settle it, and that is a host change.
2. **`angular:template:{dir}/{stem}` is a convention, not a stated fact.** It
   is right for every project the Angular CLI generates and wrong for a
   `templateUrl` that points across directories. Stated in `coverage.gaps`
   rather than hidden.
3. **`toSignal` is in the `state-signal` list but comes from
   `@angular/core/rxjs-interop`, not `@angular/core`**, so the
   `qualifier = "@angular/core"` join drops it. Left in the list rather than
   removed: widening the join to `field_prefix qualifier "@angular/core"` would
   also admit `@angular/core/testing`, and the list costs nothing.
