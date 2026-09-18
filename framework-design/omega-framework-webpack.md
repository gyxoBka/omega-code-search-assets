# omega-framework-webpack

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**10 overlay rules, 4 detection rules. 10 live, 0 cannot match.** It was 21
rules, 0 live.

Selector: `framework:webpack`. Maturity: `semantic-overlay-full`.
Languages: javascript, typescript, tsx.

```
omega-framework-webpack: 21 overlay rules, 4 detection rules -- 0 live, 21 cannot match
omega-framework-webpack: 10 overlay rules, 4 detection rules -- 10 live, 0 cannot match
```

`detection_rules` is untouched: its four exact-signature rows say the project
depends on the `webpack` package, which is true and is a different program.

## What was wrong with it

**All 21 rules were dead, and 19 of them for the same reason.** The file was
written against the generator's private ECMAScript spellings of *a property of
an object literal assigned to `module.exports`*, one kind per nesting depth:

| kind it matched | rules | what emits it now |
|---|---|---|
| `data.ecmascript_assignment_export_nested_object_string_context` | 8 | nothing |
| `data.ecmascript_assignment_export_object_string_context` | 7 | nothing |
| `data.ecmascript_assignment_export_nested_object_array_object_field_context` | 2 | nothing |
| `data.ecmascript_assignment_export_object_array_new_context` | 1 | nothing |
| `data.ecmascript_assignment_export_three_level_object_string_context` | 1 | nothing |
| `call.target_candidate` | 1 | `call.function` / `call.method` / `call.constructor` |
| `import.target_candidate` | 1 | `import.module` |

The five `data.ecmascript_*` kinds were the depth ladder: one kind for
`{ mode: "x" }`, one for `{ output: { path: "x" } }`, one for
`{ resolve: { alias: { "@": "x" } } }`, one for
`{ module: { rules: [ { loader: "x" } ] } }`. Nothing emits any of them.

On top of the kind, **67 `field_equals` clauses read 11 field names no Pack
publishes** — `owner_identifier`, `owner_property`, `key`, `outer_key`,
`middle_key`, `value`, `array_key`, `item_key`, `item_value`, `field_key`,
`constructor_name` — so even restoring a kind would not have revived a rule.
(The 19 brace path globs this file used to carry, `**/webpack.config.{js,cjs}`,
were already replaced with `**/webpack.config.*` in wave 3; that defect is not
re-counted here.)

**Seven rules were one-key-per-rule restatements.** `webpack.config.mode`,
`.devtool`, `.target`, `.context`, `.name`, `.externalstype` and
`webpack.output.*` differed from each other only in the literal key they
compared against; five more differed only in nesting depth. Each emitted an
entity named after the key it had just matched.

**The hard finding: the ladder is not portable, because the rung it stood on
does not exist.** The rewritten JavaScript and TypeScript Packs emit **no fact
at all for a property of an object literal whose value is a scalar**.
`definition.property` in omega-typescript is a `property_signature` — an
interface or object *type* member — not an object literal entry; omega-javascript
has nothing of the sort. So `mode: "production"`, `output.filename: "[name].js"`,
`resolve.alias`, `module.rules[].test` and the loader strings inside `use[]` are
invisible to any overlay, and no join reaches them because there is no fact on
either end to join. Thirteen of the 21 rules asked for exactly that and were
deleted rather than ported.

What is left of a webpack config after that is: its **imports**, its **`new`
expressions**, and its **function-valued options**. All three turn out to answer
the questions people actually ask, which is what the new file is built from.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files are the build configuration, and what each pulls in | `import.module` under `**/webpack.*` | `BuildConfig webpack:config:{path}`, `Dependency webpack:package:{name}`, `depends_on` |
| which loaders transform source in this build | `import.module`, name in 38 known loader packages, under `**/webpack.*` | `Loader webpack:loader:{name}`, `uses_loader` from the config |
| which published webpack plugins the build installs | `import.module`, name in 31 known plugin packages, under `**/webpack.*` | `PluginPackage webpack:plugin-package:{name}`, `uses_plugin` from the config |
| which plugins the build actually constructs | `call.constructor` under `**/webpack.*` | `Plugin webpack:plugin:{name}`, `uses_plugin` from the config |
| which base config a per-environment config is built on | `import.module` with specifier prefix `./webpack.`, under `**/webpack.*` | `ConfigModule webpack:config-module:{specifier}`, `extends` from the config |
| which build options are computed by a function rather than stated | `definition.method`, name in 39 webpack option names, under `**/webpack.*` | `BuildSetting webpack:setting:{path}:{option}`, `configured_by` from the config |
| which files use webpack as a library, not as a command | `import.module`, name in the 9 `webpack*` toolchain packages, anywhere | `WebpackFile webpack:file:{path}`, `Dependency`, `depends_on` |
| which entry points opt into hot module replacement | `import.module` with specifier prefix `webpack/hot` | `WebpackApi webpack:api:hot-module-replacement`, `uses_api` from the file |
| which classes in this repository are webpack plugins | `definition.method` named `apply`, span-joined `within` `scope.class_body`, plus a same-file `call.method` in `tap`/`tapAsync`/`tapPromise` | `WebpackPlugin webpack:plugin-class:{class}`, `implements` → `webpack:api:plugin-interface` |
| where a plugin registers on the compiler, and how | `call.method` in `tap`/`tapAsync`/`tapPromise`, span-joined `within` a `scope.function_body` named `apply` and `within` `scope.class_body` | `WebpackPlugin webpack:plugin-class:{class}`, `uses_api` → `webpack:api:compiler-hooks` |

Three things worth naming in that table:

- **`call.constructor` is the whole of webpack's plugin array.** Every entry of
  `plugins: []` is a `new X(...)`, and omega-javascript names a `new`
  expression on a member expression by its *property*, so
  `new webpack.DefinePlugin({...})` is stated as `DefinePlugin` exactly like
  `new HtmlWebpackPlugin({...})`. The old file needed
  `data.ecmascript_assignment_export_object_array_new_context` plus a
  `field_key = "plugins"` clause for this; one `fact_kind` clause and a path
  glob state it now, and it works for a plugin constructed in a variable, in a
  conditional, or in a function-returning config, which the old rule did not.
- **Two span joins replace the whole class ladder.** `apply` inside a class body
  with a `tap` in the same file is the webpack plugin interface. Neither join
  needs a Pack field.
- **Both plugin-class rules mint the key they address.** `webpack.plugin.class`
  and `webpack.plugin.hook` both emit `webpack:plugin-class:{cls.definition.name}`
  and both require a named enclosing class plus tap evidence, so neither
  relation can source at a key the other did not create — the wave-1 and wave-2
  dangling-end defect.

The path glob widened from `**/webpack.config.*` to `**/webpack.*`, which
covers `webpack.config.js`, `webpack.config.ts`, `webpack.dev.js`,
`webpack.prod.cjs` and the `build/webpack.base.conf.js` layout with one clause.
A brace list would have matched nothing (`glob_here` treats `{` as a literal
byte), and the rules are keyed to JavaScript/TypeScript fact kinds anyway, so a
`webpack.lock` or `webpack.md` contributes no facts. Every config rule carries
`path_segment exclude ["node_modules"]`.

## A field only the Pack can supply

**omega-javascript and omega-typescript: a property of an object literal.**

| Pack | kind that does not exist | why nothing else reaches it |
|---|---|---|
| omega-javascript, omega-typescript, omega-tsx | a `definition.config_key`-equivalent for `(pair key: (property_identifier) value: (string\|number\|true\|false\|array\|object))` inside an object literal, with the value in `fields` | There is no fact on either end, so there is nothing to join. `definition.method` covers only the function-valued case; `definition.property` in omega-typescript is a `property_signature` from an interface or object type, not an object literal entry. `definition.name`, `path`, `path.stem` and `external.*` say nothing about it. A `fact_join_by_span within` needs a fact inside the span to start from, and there is none. |

This is not a webpack-sized problem. Every declarative JavaScript configuration
is one object literal: `webpack.config.js`, `vite.config.ts`, `rollup.config.js`,
`babel.config.js`, `jest.config.js`, `tailwind.config.js`, `next.config.js`,
`nuxt.config.ts`, `eslint.config.js`, `playwright.config.ts`. The JSON, YAML and
TOML Packs all publish `definition.config_key`; the JavaScript family publishes
nothing equivalent, so the same configuration expressed as `.json` is fully
readable and expressed as `.js` is invisible. Whether the value goes in `fields`
rather than `attributes` matters too, per the wave-1 finding — an attribute is
write-only.

**Second, smaller: `import.module` states the specifier, not the target.**
`webpack.config.extends` can only key its target by `./webpack.common.js` as
written, because the Pack does not resolve a relative specifier to an artifact
path and no built-in name or join derives one. That is `OWED.md` item 7a
territory (JS/TS facts carry no `external` at all) and it caps every JS
framework overlay at specifier-level file-to-file edges.

## Still to decide

1. **`webpack.config.computed-setting` is keyed to a name list, not a position.**
   `definition.method` names a function-valued property, but not where in the
   config it sits: a `filename()` under `output` and a `filename()` under a
   `module.rules[]` entry are the same fact. The rule states the option name and
   the file, and deliberately does not claim the path to it. If the object-literal
   fact above ever lands, this rule should gain a `within` join to its parent key
   and say `output.filename` properly.
2. **The loader and plugin package lists are curated, and will age.** 38 loaders
   and 31 plugins cover what a person is likely to meet, but `-loader` and
   `-webpack-plugin` are suffix conventions and `field_prefix` only matches
   prefixes, so there is no way to state "any package whose name ends in
   `-loader`". A `field_suffix` clause in `overlay.rs` would replace both lists
   with one clause each; that is a host change, not a framework one, and it is
   not required for correctness today.
3. **`webpack.config.plugin-instance` matches every `new` in a webpack config.**
   `new RegExp(...)` or `new URL(...)` in a config file is claimed as a plugin.
   Narrowing it to names ending in `Plugin` needs the same `field_suffix`; a
   name list would be worse, because most of the value of the rule is that it
   finds plugins nobody has heard of. Left broad on purpose.
