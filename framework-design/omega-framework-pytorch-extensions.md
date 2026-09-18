# omega-framework-pytorch-extensions

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

8 overlay rules, 12 detection rules. **8 live, 0 cannot match.**

Selector: `framework:pytorch-extensions`. Maturity: `semantic-overlay-full`.
Scope: the Python build script (`setup.py`, `build.py`, anything that imports
`torch.utils.cpp_extension`) and the C++ translation units it compiles. The two
Packs are **omega-python** and **omega-cpp**, and **neither publishes a single
field on a single template** — every rule below is built from kind, name, path,
span and the host's built-ins.

### Entities it declares

| entity_kind | key space | minted by |
|---|---|---|
| `ExtensionBuildScript` | `pytorch-ext:build-script:{path}` | 3 rules (Python hub) |
| `ExtensionModule` | `pytorch-ext:module:{path}:{source.start}` | `…py.extension-module` |
| `ExtensionBinding` | `pytorch-ext:binding:{path}:{var}` | `…py.extension-binding` |
| `JitExtension` | `pytorch-ext:jit-load:{path}:{source.start}` | `…py.jit-load` |
| `BuildTool` | `pytorch-ext:build-tool:{path}` | `…py.build-extension` |
| `ExtensionSource` | `pytorch-ext:source:{path}` | `…cpp.translation-unit` (C++ hub) |
| `TorchHeader` | `pytorch-ext:header:{header}` | `…cpp.translation-unit` |
| `ExtensionOp` | `pytorch-ext:op:{path}:{function}` | `…cpp.operator` |
| `ExtensionRegistry` | `pytorch-ext:registry:{path}:{macro}:{start}` | `…cpp.registry` |
| `BuildToolchain` | `pytorch-ext:toolchain:cuda` | `…cpp.cuda-source` |

One kind per key space, so `key_collisions.py` reports nothing. The two hubs are
each minted by the rules that address them, with identical kind and identical
attributes, and every rule that addresses a hub key carries a superset of the
clauses of the rule that mints it — so no relation end dangles.

### Relations it declares

`builds`, `binds`, `configured_by`, `compiled_by`, `declares`, `depends`.

## What was wrong with it

**All 8 rules were dead**, 7 of them because they named a fact kind of the
pre-rewrite generator vocabulary and the eighth because it named another
language's kind:

| kind the rule matched | rules | emitted by |
|---|---|---|
| `definition.python_from_import_constructor_keyword_identifier_list_context` | 4 | nobody |
| `definition.python_from_import_constructor_binding_context` | 1 | nobody |
| `definition.python_from_import_constructor_keyword_identifier_context` | 1 | nobody |
| `call.direct` | 1 | nobody |
| `call.member` | 1 | omega-c only — not in `host.required_packs` |

Three further defects, which is why this is a rewrite and not a translation.

1. **The whole design rested on call-argument text that no Pack has ever
   published.** Six of the eight rules read `module_name`, `imported_name`,
   `callee_name`, `binding_name`, `keyword_name`, `list_item` or
   `keyword_identifier` — **7 distinct field names, none of them published by omega-python, which
   publishes no field at all on any of its 30 templates.** The four
   `…-item` rules existed solely to turn one element of `sources=[...]`,
   `include_dirs=[...]`, `extra_compile_args=[...]` or `extra_link_args=[...]`
   into a `BuildInput`/`BuildOption` entity. omega-python emits `call.function`
   spanning **only the callee name** (`124-136` for
   `ext = CppExtension(name=…, sources=[…])`), so the arguments are not merely
   unfielded, they are not facts. Those four rules are deleted, not ported.

2. **Both of the two relation-emitting rules pointed the relation at the entity
   they had just minted.** `pytorch.ext.load` and `pytorch.ext.buildextension`
   each emitted `source: current` and `target: by_canonical_key` rendering the
   very key `current` was minted under — the self-loop shape wave 2 and wave 6
   found in gitlab-ci and symfony. Even had their kinds been live, each would
   have added one edge from a node to itself and nothing else.

3. **Two rules used `external_path_matches` against `torch.utils.cpp_extension`,
   which cannot resolve for Python.** `external` is filled from
   `external_environment`, which registers only a binding whose `target_hint` is
   set; `target_hint` is `occurrence.qualifier`; and `qualifier` is read only
   from a field or attribute literally named `qualifier`, which omega-python does
   not publish (its only attributes are `module` and `target` on
   `binding.import_alias`, and an attribute is write-only anyway). This is the
   same mechanism `00-INDEX.md` item 7a records for JS/TS; it applies to Python
   too. Both clauses are replaced by a `fact_join_by_field` on `path` against
   `import.from_module` named `torch.utils.cpp_extension`, which is the
   statement the rule actually wanted: *this file imports torch's C++ extension
   builder*.

**Measured, not assumed.** Every fact named below was produced by
`dump_call_emissions` on a hand-written `setup.py`, `ops.cpp` and `kern.cu`, and
the eight rules were then replayed over those emissions: all 8 match, 18
entities and 16 relations materialize, no attribute is unresolvable and no
relation end is unminted.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files in this repo configure a torch C++ extension build | `import.from_module` named `torch.utils.cpp_extension`, joined on `path` from each Python rule | `ExtensionBuildScript` at `pytorch-ext:build-script:{path}` |
| which extension modules does this project build, and is it CPU, CUDA or SYCL | omega-python `call.function` named `CppExtension` / `CUDAExtension` / `SyclExtension` | `ExtensionModule`; `ExtensionBuildScript --builds--> ExtensionModule`, `extension_kind` on both |
| what is the Python name for that extension | the same call, `fact_join_by_span` `within` `definition.variable` (the assignment spans the call) | `ExtensionBinding` (the variable); `ExtensionBinding --binds--> ExtensionModule` |
| where does this project JIT-compile an extension at import time | omega-python `call.function` named `load` / `load_inline`, plus an `import.symbol` of that name in the same file | `JitExtension`; `ExtensionBuildScript --builds--> JitExtension`, `loader` naming which of the two |
| which build scripts drive the build through torch's own `build_ext` | omega-python `import.symbol` named `BuildExtension` | `BuildTool`; `ExtensionBuildScript --configured_by--> BuildTool` |
| which C++ translation units are part of the extension, and which torch headers they pull in | omega-cpp `import.include` named one of 18 torch / ATen / c10 / CUDA / pybind11 headers | `ExtensionSource` and `TorchHeader`; `ExtensionSource --depends--> TorchHeader` |
| which C++ functions are the operators the extension exposes | omega-cpp `reference.type` named `Tensor` (`torch::Tensor` and `at::Tensor` both reduce to it), `fact_join_by_span` `within` `definition.function` | `ExtensionOp` keyed by the function; `ExtensionSource --declares--> ExtensionOp` |
| where is the Python entry point registered, and under what name | omega-cpp `definition.function` named `PYBIND11_MODULE`, `PYBIND11_EMBEDDED_MODULE`, `TORCH_LIBRARY`, `TORCH_LIBRARY_IMPL` or `TORCH_LIBRARY_FRAGMENT`, plus the same-span `definition.parameter_shape_candidate` | `ExtensionRegistry` with `macro` and `signature` (`(TORCH_EXTENSION_NAME, m)`, `(my_ops, m)`); `ExtensionSource --declares--> ExtensionRegistry` |
| does this extension need the CUDA toolkit | omega-cpp `import.include` named one of six CUDA headers | `BuildToolchain` `pytorch-ext:toolchain:cuda`; `ExtensionSource --compiled_by--> BuildToolchain` |

Two shapes are worth copying. The **macro-as-declaration** read: tree-sitter-cpp
parses `PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) { … }` as a function
definition, so the macro arrives as `definition.function` named for the macro and
the whole argument list arrives as `definition.parameter_shape_candidate` on a
byte-identical span — the same same-span carrier trick omega-kotlin-multiplatform
used for `expect`/`actual`, and the only way to read an Unreal- or pybind-style
macro's operands out of a fieldless Pack. And the **assignment-spans-the-call**
read: omega-python spans `definition.variable` over the entire statement, so a
`call.function` inside it reaches its binding with `fact_join_by_span` /
`within` and no field on either side.

## A field only the Pack can supply

**omega-python, `call.function`, the call's argument text.** The one question
this framework exists for that it still cannot answer is *which C++ files does
this extension compile* — `CppExtension(name='my_ops', sources=['src/ops.cpp',
'src/kernel.cu'])`. The same absence hides `include_dirs`, `extra_compile_args`,
`extra_link_args`, and the `name=` under which the module is imported from
Python.

Neither of the first two options in the brief reaches it:

- **No built-in derives it.** `definition.name` is `CppExtension`; `path` and
  its derivatives describe the build script, not the sources.
- **No join reaches it.** `fact_join_by_span` relates facts the Pack emitted.
  omega-python emits **no fact at all** for a string literal, a keyword
  argument, a list, or an argument list — its 30 templates cover classes,
  functions, type aliases, module and class variables, decorators, calls, type
  uses, imports, globals and tests, and nothing below the call's callee name.
  There is no fact inside the `CppExtension(...)` span to join to.

So this needs an omega-python change, and it is the same change `00-INDEX.md`
already records for omega-go under wave 8 (`app.Get("/users/:id", h)`): **a Pack
fact for a call's literal string arguments.** It is not a pytorch-extensions
field and should not be added as one — `sources=`/`include_dirs=` are
`setuptools` keywords, and a generic `call.argument` / `call.string_argument`
emission, or a `string_arguments` field on `call.function`, would answer this,
Go's routes, Ruby's `render`, and every framework whose configuration lives in a
call. Recorded in `OWED.md` as the Go row; this is the second framework blocked
on it.

A second, smaller one: **omega-cpp spans a callable on its declarator, not its
body.** `PYBIND11_MODULE(…)` spans `167-207` while `m.def("forward", &forward)`
sits at `212-254`, so the individual op registrations — the list of names the
extension actually exports to Python — arrive as `call.method` named `def` with
no reachable owner and no argument text. A `scope.function_body` template of the
kind omega-python already has would make the owner reachable; the argument text
is the same Pack change as above.

## Still to decide

- **`.cu` and `.cuh` are not parsed at all.** `grammars/omega-cpp/manifest.toml`
  registers `cc, cxx, hpp, hxx, hh, ipp, tpp` (plus `cpp` via the language
  alias) and `grammars/omega-c` registers `h`; no bundle claims `cu` or `cuh`.
  So the CUDA kernels of a CUDA extension are invisible, and
  `pytorch-ext.cpp.cuda-source` recognises CUDA through the CUDA headers a
  parsed `.cpp`/`.cc`/`.cxx` includes instead of through the file extension.
  Registering `cu`/`cuh` on omega-cpp would be a one-line grammar-manifest
  change with a real payoff for this framework, but it is a Pack/grammar
  decision, not a Framework one, and tree-sitter-cpp's handling of `__global__`
  and `<<<>>>` launch syntax should be measured before claiming it.
- **The header list is the Framework's own choice, not a Pack constraint.**
  omega-cpp emits `import.include` for *every* `#include`, so the 18-name list
  in `…cpp.translation-unit` and the 6-name CUDA subset constrain nothing but
  this rule (brief §3f). They are deliberately the headers a torch extension
  includes directly; a project that includes torch only transitively through its
  own header is not recognised as an extension source. Widening to a
  `field_prefix` is not possible without dropping the other prefixes, since
  clauses conjoin.
- **`pytorch-ext:header:{header}` is deliberately path-free**, so
  `torch/extension.h` is one node across the repository and *which translation
  units use the torch C++ API* is one hop. `pytorch-ext:toolchain:cuda` is a
  single global node for the same reason.
