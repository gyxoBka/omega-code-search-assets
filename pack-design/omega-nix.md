# omega-nix

Language `omega-nix`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

17 templates over 13 query patterns, 31 named node types touched, 5 guards.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 9 |
| `references` | yes | 5 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.attribute` | Value | 4 |
| `definition.function` | Callable | 1 |
| `definition.parameter` | Value | 2 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |

Both fold onto the `definition.function` at the same span -- the `binding`
node -- and they are the two spellings of a Nix parameter list, `{ a, b }:`
and `x:`. Each is an optional capture, so exactly one of the two templates
survives the skip rule on any given match.

### Regions

- `scope.function_body` (1) -- named by the binding that holds the function
- `scope.attribute_set_body` (1) -- named by the binding that holds the set

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `reference.attribute` | reference | 1 |
| `reference.variable` | reference | 1 |
| `relation.depends` | depends | 3 |

### Attributes stored

One, and it is not a constant: a scalar-valued binding carries the value it
binds, quote-stripped, as `value`. That is the answer to *what is this set
to*, which is the question most often asked of a Nix file.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 31 of them.

Untouched:

- `_expression` -- a supertype, never a node
- `binding_set` -- the list of bindings; each `binding` is matched on its own
- `block_comment`, `comment`, `doc_comment`, `line_comment` -- no name a
  question resolves to
- `dollar_escape`, `escape_sequence`, `string_fragment` -- the inside of a
  string literal
- `ellipses` -- `...` in a formal list; it names nothing
- `inherit`, `inherit_from` -- reached through their shared `inherited_attrs`
  child, so one pattern covers both spellings
- `interpolation` -- `${...}`; the expressions inside are matched by the
  reference and call patterns in their own right
- `source_code` -- the file node

## What is wrong with it

**The Pack was an editor's highlighting model, not an answer set.** Of its
roughly 75 source patterns, all but a handful came from three pasted
nvim-treesitter baselines (`highlights.scm`, `locals.scm`, `injections.scm`)
and one GitHub code-navigation `tags` file. `00-INDEX.md` names omega-nix as
the Pack where the locals inheritance survived the earlier sweeps, and it did:
`@local.definition.field`, `@local.definition.var`, `@local.definition.parameter`
and `@local.reference` each had a template on it.

**Nineteen templates, and eleven of them stated the same four facts twice.**
The `locals` half and the `upstream_tags`/`static_delta` half were written in
separate passes over the same constructs, so the audit reported **four K2
pairs** -- one span and one name emitted under two kinds:

| span | kinds |
|---|---|
| `@local.definition.field` | `binding.field` / `definition.nix_field` |
| `@local.definition.var` | `binding.var` / `binding.nix_variable` |
| `@local.reference` | `reference.local` / `reference.nix_identifier_candidate` |
| `@local.scope` | `scope.lexical` / `scope.nix_lexical_scope` |

**Six templates named an emission with a whole node (D2).** `binding.field`,
`binding.var`, `definition.nix_field` and `binding.nix_variable` were all named
from `@local.definition.var` / `@local.definition.field`, which is an
`(attrpath)` -- so `services.nginx.enable` was stored as the *name* of a
binding, dotted path and all, and `"${cfg.name}".value` stored an
interpolation. `scope.lexical` and `scope.nix_lexical_scope` were named from
`(let_expression)`: the name of the region was the entire text of the `let`,
bindings, body and all, written into the index twice.

**Two carriers the host will not fold, under names nothing assembles.**
`call.target_candidate` starts with `call.`, so `is_definition_kind` is false
and the fold never happens; its name was `@call.target`, which is the
`function:` child of an `apply_expression` -- any expression, so for
`(f x) y` the stored "target" was the whole inner application.
`reference.nix_identifier_candidate` starts with `reference`, same failure.
Even had they folded, `omega.pack.target` and `omega.pack.nix_identifier` are
read by nothing.

**Two guards whose reason was a generator label**, exactly the class §8 of the
brief names: `terminal_static_ceiling__nix_dynamic_attribute_and_evaluation_semantics`
and `nix_upstream_tags_project_semantics_terminal_static_boundary`. Of the
eleven guards, four more were the generator's boilerplate about overload
resolution, dynamic dispatch and macro expansion -- none of which Nix has.

**One pattern nothing read**: `"or" (comment) @comment @spell`, left behind by
the highlights baseline after the syntax sweep.

**Containment stated as a pattern, three times.** `attrpath_string_binding_context`
hard-coded a three-segment attrpath whose value is a string and emitted
`structured.entry` with fields `root`/`segment1`/`segment2`/`string_value`;
`binding_path_list_context` hard-coded binding-holds-list-holds-path;
`binding_call_context` hard-coded binding-holds-apply-holds-select. Each is a
tree shape the tree already holds, and each declared a kind
(`structured.entry`, `definition.nix_binding_call_context`) that answers no
question -- `structured.entry` arrives as a plain reference to nothing, and
`definition.nix_binding_call_context` is a declaration whose name is the
binding but whose identity is a nesting depth.

**`value.nix_value` was emitted under the `imports` capability** from
`[(attrset_expression) (rec_attrset_expression) (list_expression)
(string_expression) …] @data.value`, named by its own text. That is one
emission per literal and per attribute set in every file, each named with the
whole subtree: on a nixpkgs-shaped file the file is written into the index once
per nesting level. `import.import_expression` was named from the whole
`apply_expression`, so "what does this file import" answered
`import ./modules/web.nix`, the call text, not the path.

**Framework semantics, spelled as injections (Defect L).** Twenty-two
injection patterns keyed on `writeShellApplication`, `runCommand*`,
`writeBash*`, `writeDash*`, `writeFish*`, `writeHaskell*`, `writeJS*`,
`writePerl*`, `writePy*`, `writeRust*`, `nixosTest`, `runTest`, `testScript`,
`^[A-Za-z]+Phase$`, `^pre[A-Za-z]+$`, `^post[A-Za-z]+$`, and a home-manager
Neovim `type = "lua"` / `config = …` pair. Every one of those names is
nixpkgs or home-manager library API, not Nix. `00-INDEX.md` records omega-c's
libc-keyed injections as L-inside-an-injection; this is the same defect, larger.

**Two capabilities were declared for programs that answered nothing.** `data`
carried only the two `structured.entry` templates and `bindings` only the
duplicated locals templates; `imports` carried the whole-node import and the
whole-node value.

## What it should extract

A Nix file is `flake.nix`, `default.nix`, `shell.nix`, a derivation or a
NixOS/home-manager module. The questions asked of it are: **what does this file
declare**, **what is this attribute set to**, **which names does it use**,
**what does it call**, and **which files or search paths does it depend on**.

Nix has exactly one declaring form -- the binding `attrpath = expression;` --
plus `inherit`, plus the two parameter spellings. So the Pack is four binding
patterns that partition `_expression` by the kind of value bound (disjoint, and
together exhaustive over all 24 subtypes, so a binding is matched exactly once),
and nine patterns for everything else.

| what | node | emitted as | family |
|---|---|---|---|
| a function-valued binding | `binding` + `function_expression` | `definition.function` | Callable |
| its parameter list | `formals` / `universal:` | `parameter_shape_candidate` carrier on that binding | attribute |
| its body | `function_expression` `body:` | `scope.function_body`, named by the binding | region |
| an attrset-valued binding | `binding` + `attrset_expression`, `rec_attrset_expression`, `let_attrset_expression` | `definition.attribute` | Value |
| the set it holds | the attrset node | `scope.attribute_set_body`, named by the binding | region |
| a scalar- or alias-valued binding | `binding` + string, int, float, path, spath, hpath, uri, variable, select | `definition.attribute` carrying `value` | Value |
| every other binding | `binding` + the remaining eleven subtypes | `definition.attribute` | Value |
| `inherit a b;` and `inherit (x) a;` | `inherited_attrs` `attr:` | `definition.attribute` | Value |
| a named formal | `formal` `name:` | `definition.parameter` | Value |
| `x: body` | `function_expression` `universal:` | `definition.parameter` | Value |
| a bare name used as a value | `variable_expression` `name:` | `reference.variable` | reference |
| an attribute read | `select_expression`, last `attrpath` segment | `reference.attribute` | reference |
| an application with a nameable callee | `apply_expression` `function:` | `call.function` | call |
| a path literal | `path_expression`, `hpath_expression`, first `path_fragment` | `relation.depends` | depends |
| `<nixpkgs>` | `spath_expression`, brackets stripped | `relation.depends` | depends |
| a bare URI | `uri_expression` | `relation.depends` | depends |
| comments, string internals, `...`, `binding_set`, `source_code` | -- | nothing | -- |

A binding and a `select_expression` are named by the **last** segment of the
attrpath, so `config.services.nginx.enable` is read as `enable` and resolves
onto the binding `enable = …;` wherever the option is defined; the leading
segments are themselves `variable_expression` uses and are stated as such. That
is the one link Nix has, and the old Pack could not make it: it stored the
dotted path as the declaration's name and the bare identifier as the reference,
so the two spellings could never meet.

`import` gets no pattern of its own. A path literal in Nix refers to a file
whether or not it is handed to `import`, so the dependency is stated at the
path and the application is stated as a call to `import` -- two facts from
nodes that exist, instead of one pattern matching a library idiom.

Nothing framework-specific survives: there are no injections, and no pattern
mentions a nixpkgs or home-manager name.

## Still to decide

1. **A call is also a reference.** `lib.mkIf cond x` emits `call.function` on
   the application and `reference.attribute` on the `select_expression` inside
   it. The spans differ and the occurrence kinds differ, so neither row is a
   duplicate of the other, but the same name is recorded twice at nested spans.
   A query cannot see that a `select_expression` is in function position, so
   removing the overlap would mean dropping one of the two questions. Kept;
   revisit against the row count.
2. **A `let` binding is declared as `definition.attribute`, like an attrset
   binding.** Distinguishing them needs `(let_expression (binding_set
   (binding …)))`, which is containment written as a pattern. Nix itself makes
   little of the difference -- a `let` binding and a `rec` attribute are both
   names in a recursive scope -- so one kind is used for both.
3. **`reference.variable` is emitted for every bare name used as a value**,
   which in `with pkgs; [ hello git curl ]` is every package in the list. That
   is the answer to *which files use `ffmpeg`* and is deliberate, but it is the
   Pack's largest single source of rows and the `with` guard says why some of
   those names cannot be resolved.
4. **Bash inside a derivation is no longer parsed.** `buildPhase = '' … '';`
   really does hold a shell script, and the old injections found it by matching
   nixpkgs attribute names. Restoring it belongs in a `frameworks/` overlay for
   nixpkgs stdenv, not here.
