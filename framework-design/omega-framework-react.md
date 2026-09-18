# omega-framework-react

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**17 overlay rules, 4 detection rules. 17 live, 0 cannot match.** (Was 35 rules,
1 live, 34 dead.)

Selector: `framework:react`. Maturity: `semantic-overlay-full`.
Packs: `omega-javascript`, `omega-typescript`, `omega-tsx`.

```
omega-framework-react: 17 overlay rules, 4 detection rules -- 17 live, 0 cannot match
```

## What was wrong with it

**34 of 35 rules could not match a fact.** The one survivor,
`react.custom-hook.definition-function`, matched `definition.function` with a
`use` prefix — everything else was keyed to the pre-rewrite generator
vocabulary.

Counted by cause:

| cause | rules |
|---|---|
| kind `call.ecmascript_member_identifier_context` | 12 |
| kind `call.direct` | 5 |
| kind `import.ecmascript_{commonjs,namespace,default}_binding_context` | 12 (as join sides) |
| kind `import.ecmascript_named_binding_context` | 3 |
| kind `reference.javascript_*_jsx_*_context` (6 distinct spellings) | 9 |
| kind `call.target_candidate` / `import.target_candidate` | 2 |
| kind `reference.ecmascript_class_extends_{identifier,member}_context` | 2 |
| attribute `name_style` | 1 |

Three structural faults, not just stale kinds:

1. **Four APIs × four import spellings = 16 rules.** `createContext`, `memo`,
   `forwardRef` and `lazy` each had a `call.direct` rule plus one rule per
   CommonJS / namespace / default import root, reading `object`, `member`,
   `operator`, `arg0` and `module_source`. The Packs no longer distinguish an
   import root at all: a call is `call.function` or `call.method` and that is
   the whole distinction. **16 rules became 4** (two APIs' worth of rules ×
   direct/member).
2. **Nine rules restated their input.** `react.javascript.jsx-member-component-reference`
   minted `ComponentReference` keyed `react:component-ref:{path}:{source.start}`
   with the tag as an attribute and emitted no relation — an entity named after
   its own input, which `00-CONTRACT.md` §5 forbids. So did
   `react.generic-api-call.react` (`ApiUse` at `{path}:{source.start}`, related
   only to itself) and the four `ComponentWrapper` rules (a wrapper entity at a
   byte offset, with no edge to the component it wraps). These are deleted, not
   ported.
3. **The render graph did not connect.** `renders` pointed at
   `react:component-ref:{path}:{child}` and `react:component:{path}:{child}` —
   both path-scoped, so a component could only ever be recorded as rendering
   something declared in its own file. Four rules, all dead, none of which would
   have crossed a file boundary if they had lived.

One rule was also **untrue rather than merely dead**:
`react.component.definition` asserted that a PascalCase `definition.function` is
a React component, via an attribute `name_style` no Pack has ever published. A
PascalCase function is a class-like factory as often as a component. The new
file never guesses from casing; it requires JSX or a hook call.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are React files, and which React package each pulls in | `import.module`, name in the react/react-dom set | `ReactFile` `react:file:{path}`, `Dependency` `react:package:{name}`, `depends_on` |
| which function is a component (JS, incl. name-bound arrows) | `reference.component` within `scope.function_body` | `Component` `react:component:{path}:{owner}` + `ComponentName` |
| which binding is a component (TSX arrows, which emit no function scope) | `reference.jsx_component` within `definition.variable` | same |
| which class is a component | `reference.jsx_component` / `reference.component` within `definition.class` | same, `form=class` |
| **what a component renders** | the JSX tag's own name | `renders` `react:component:{path}:{owner}` → `react:component-name:{tag}` |
| which classes are React class components | `relation.implements` named `Component`/`PureComponent` within `definition.class` | `Component`, `base` attribute |
| which hooks a component uses | `call.function` prefixed `use`, within a non-`use` owner | `uses_hook` component → `react:hook:{name}` |
| which hooks a custom hook is built out of | `call.function` prefixed `use`, within a `use`-prefixed owner | `uses_hook` `react:hook:{owner}` → `react:hook:{callee}` |
| where a custom hook is declared | `definition.function` prefixed `use` | `Hook` (`custom=true`), `declares_hook` from `ReactFile` |
| which contexts exist, and under what name | `call.function`/`call.method` named `createContext`, within `definition.variable` | `Context` `react:context:{path}:{binding}`, `declares_context` |
| which components are memoized, ref-forwarded or code-split | `call.function`/`call.method` in `{memo,forwardRef,lazy}`, within `definition.variable` | `Component` with a `wrapper` attribute, `declares_component` |

Six canonical keys are minted and every relation end addresses one of them —
`react:file:{path}`, `react:package:{p}`, `react:component:{path}:{n}`,
`react:component-name:{n}`, `react:hook:{n}`, `react:context:{path}:{n}`. Every
rule that addresses a key also mints it, so nothing dangles (checked
mechanically; the audit cannot see this).

The two things the overlay adds that the Packs cannot:

- **Render edges cross files.** The target of `renders` is
  `react:component-name:{tag}`, a project-wide name, and every component-defining
  rule mints its own name key. So *who renders `Sidebar`* is answerable even
  though nothing ties `import { Sidebar }` to `./Sidebar` (see below).
- **The Rules of Hooks are used as evidence.** A `use`-prefixed call may only
  appear in a component or in another hook, so the enclosing owner's own name
  decides which of the two it is. That is what replaces the deleted
  casing-and-`name_style` guess.

## Still to decide

- **`renders` is keyed by name, not by path.** Two components called `Button` in
  two directories collapse into one `ComponentName`. The alternative is no
  cross-file edge at all, because the import cannot be resolved (below). Keyed
  by name is the better of the two and is stated explicitly as an attribute on
  the entity; if the Pack ever publishes a module on `import.symbol`, this should
  become `react:component:{resolved path}:{name}`.
- **`scope.function_body` named `render` is excluded** from the function-owner
  rules so a class component is attributed to its class rather than to a method
  called `render`. A genuine free function named `render` that returns JSX is
  therefore not recorded. It seemed the cheaper error.
- **A `use`-prefixed `call.function` is taken to be a hook.** A non-React
  function named `useX` would be recorded as one. No Pack fact distinguishes
  them, and the naming rule is a hard React requirement, so this is accepted.

## A field only the Pack can supply

**`omega-javascript`, `omega-typescript`, `omega-tsx` — `import.symbol` — a
`module` field.**

`import.symbol` spans the imported identifier; `import.module` spans the
specifier string. Neither span contains the other, and no third fact spans the
whole import statement, so `fact_join_by_span` with `within` cannot relate them.
`fact_join_by_field` has nothing to join on: neither side publishes any field at
all. `fact_join_by_path_ancestor` is about paths. `external.package` is populated
only when the host has already resolved the import, which is the thing being
asked for. So *which module does `Sidebar` come from* is unanswerable, and every
framework over JS/TS that wants a cross-file edge is reduced to matching by bare
name.

This is the same shape as the `qualifier` finding already recorded in
`00-INDEX.md` against `binding.import_alias` / `import.symbol`, and it should be
fixed in the same edit: `import.symbol` needs the specifier in `fields`, not in
`attributes` (an attribute is write-only to the overlay).

**Two further gaps, recorded but not blocking** — the overlay does not depend on
either:

- **`omega-tsx` — `reference.jsx_attribute` — the tag it belongs to.** The fact
  spans the prop identifier, and `reference.jsx_component` spans only the tag
  name, so the prop lies inside no fact that names the element. *Which props is
  `<Counter>` passed* cannot be stated. Either a `tag` field on
  `reference.jsx_attribute`, or spanning a fact over the whole JSX element,
  would reach it.
- **Props a component accepts.** `definition.parameter_shape_candidate` is a
  carrier, folded onto the declaration as `omega.pack.*` in `attributes`, and an
  attribute is write-only. Nothing the overlay can do with it.
