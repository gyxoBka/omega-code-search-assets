# omega-framework-pytorch-extensions

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 12 detection rules. **11 live, 0 cannot match.**
`key_collisions.py` reports `0 entity outputs are overwritten by a same-key rule
that sorts first`.

Selector: `framework:pytorch-extensions`. Maturity: `semantic-overlay-full`.
Scope: the Python build script (`setup.py`, `build.py`, anything that imports
`torch.utils.cpp_extension`) and the C++ translation units it compiles. The two
Packs are **omega-python** and **omega-cpp**. omega-python now publishes the
canonical call view — `call.arg0`, `call.arg0_text`, `call.arg0_name`,
`call.arg1`, `call.arg1_text`, `call.arg2`, `call.last_arg`,
`call.last_arg_name` on `call.function`, and those plus `receiver` on
`call.method`. **omega-cpp still publishes no field on any template**, so every
C++ rule below is built from kind, name, path, span and the host's built-ins.

### Entities it declares

| entity_kind | key space | minted by |
|---|---|---|
| `ExtensionBuildScript` | `pytorch-ext:build-script:{path}` | 5 rules (Python hub) |
| `ExtensionModule` | `pytorch-ext:module:{path}:{call.arg0_text}` | `…py.extension-module`, `…py.qualified-extension-module` |
| `ExtensionBinding` | `pytorch-ext:binding:{path}:{var}` | `…py.extension-binding`, `…py.qualified-extension-binding` |
| `JitExtension` | `pytorch-ext:jit-load:{path}:{call.arg0_text}` | `…py.jit-load`, `…py.qualified-jit-load` |
| `BuildTool` | `pytorch-ext:build-tool:{path}` | `…py.build-extension` |
| `ExtensionSource` | `pytorch-ext:source:{path}` | `…cpp.translation-unit` (C++ hub) |
| `TorchHeader` | `pytorch-ext:header:{header}` | `…cpp.translation-unit` |
| `ExtensionOp` | `pytorch-ext:op:{path}:{function}` | `…cpp.operator` |
| `ExtensionRegistry` | `pytorch-ext:registry:{path}:{macro}:{start}` | `…cpp.registry` |
| `BuildToolchain` | `pytorch-ext:toolchain:cuda` | `…cpp.cuda-source` |

One kind per key space, so `key_collisions.py` reports nothing. Where two rules
mint the same key they mint it with the **same** `entity_kind` and the **same**
attribute expressions, so it does not matter which of the two sorts first. Every
rule that addresses a hub key carries a superset of the clauses of a rule that
mints it, so no relation end dangles.

### Relations it declares

`builds`, `binds`, `configured_by`, `compiled_by`, `declares`, `depends`.

## What was wrong with it

This is the second pass. The first pass fixed the dead kinds; this one fixes
what was written while a call's arguments were unreachable.

**Before this pass: 8 rules, 8 live, 0 dead.** The defects were not dead rules,
they were unreachable answers and one false claim.

1. **The two things a PyTorch extension is named by were not stated, and the
   `coverage.gaps` said so.** One of the six gap sentences read *"omega-python
   captures no call argument, so `sources=[...]`, `include_dirs=[...]`,
   `extra_compile_args=[...]`, `extra_link_args=[...]` and the `name=` of an
   extension are not stated."* That sentence is now **false in its first half**:
   omega-python publishes 8 call fields on `call.function` and 9 on
   `call.method`. Measured with `dump_call_emissions` on a hand-written
   `setup.py`:

   ```
   137-149  call.function  name=CppExtension
            call.arg0="'my_ops'"  call.arg0_text=my_ops  call.arg0_name=my_ops
            call.arg1="['src/ops.cpp', 'src/kernel.cu']"
            call.arg1_text=['src/ops.cpp', 'src/kernel.cu']
   ```

2. **Both named entities were keyed by a byte offset.** `ExtensionModule` was
   `pytorch-ext:module:{path}:{source.start}` and `JitExtension` was
   `pytorch-ext:jit-load:{path}:{source.start}` — 2 of the 10 key spaces
   identified a construct by where it happened to sit in the file, so the
   identity moved on every edit above it and no question could name the thing:
   *where is the extension `my_ops` built* had no key to ask about. Both are now
   keyed on `call.arg0_text`, which is the extension's own Python module name in
   the spelling PyTorch's documentation uses (`CppExtension('lltm_cpp',
   ['lltm.cpp'])`). This is the same move brief §3k describes for a route, with
   the extension name in place of the URL; there is no route to normalize, so
   the raw text is the identity.

3. **The qualified spelling of every Python construct was invisible — 0 of the
   4 Python rules could match it.** All four matched `call.function` only, which
   omega-python emits for a bare callee. `torch.utils.cpp_extension.load(name=…)`
   and `cpp_extension.CppExtension(…)` are `call.method` with `receiver` set,
   and `receiver` is a field that did not exist when the file was written.
   Measured:

   ```
   115-119  call.method  name=load        receiver=torch.utils.cpp_extension
   227-239  call.method  name=CppExtension  receiver=cpp_extension
   ```

   That is the spelling the PyTorch JIT docs use, and it was matching nothing.
   Three rules were added for it — `…py.qualified-extension-module`,
   `…py.qualified-extension-binding`, `…py.qualified-jit-load` — taking the file
   from 8 rules to 11. The three extra rules are what §6 of the brief asks to be
   justified: they answer the same three questions as their `call.function`
   twins, for the module-qualified way of writing the call, and they cannot be
   collapsed into the twins because `fact_kind` is an exact match and
   `call.function` and `call.method` are two kinds.

   They also do not need the `import.from_module` join the unqualified rules
   carry: the receiver **is** the import evidence. The gate is one clause,
   `path_glob` over the field `receiver` with pattern `*cpp_extension`, which
   covers both `torch.utils.cpp_extension` and the `from torch.utils import
   cpp_extension` alias in a single clause (brief §3i: the import join in place
   of `external_path_matches`; here the receiver is stronger and cheaper).

4. **Two attributes were named for a built-in.** `ExtensionBuildScript` carried
   an attribute `path` and `ExtensionSource` carried an attribute `path`, and
   both rules then rendered `{path}` in a later output. Both resolved to the
   same value so nothing broke, but it is exactly the shape brief §3k names as
   the express bug; renamed to `script` and `source_file`.

5. **A zero-argument call would have collapsed two entities into one.**
   `call.arg0_text` is a `default`-to-empty wrapped in strip pairs, so
   `CppExtension()` yields `call.arg0_text=""` (measured) and two such calls in
   one file would render one key. Every rule that keys on it now carries
   `path_glob` on `call.arg0_text` with pattern `?*` — at least one character —
   and the two binding rules carry it too, because they address a key the module
   rules mint (brief §3b: a rule that addresses a key carries the conditions of
   the rule that mints it).

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which files configure a torch C++ extension build | `import.from_module` named `torch.utils.cpp_extension`, joined on `path`; or a `call.method` whose `receiver` ends in `cpp_extension` | `ExtensionBuildScript` at `pytorch-ext:build-script:{path}` |
| which extension modules does this project build, under what Python import name, and is it CPU, CUDA or SYCL | omega-python `call.function` named `CppExtension`/`CUDAExtension`/`SyclExtension`, with `call.arg0_text` | `ExtensionModule` at `pytorch-ext:module:{path}:{call.arg0_text}`; `ExtensionBuildScript --builds--> ExtensionModule`; attributes `module_name`, `extension_kind`, `sources` |
| …the same, written `cpp_extension.CppExtension(…)` | omega-python `call.method`, same names, `receiver` matching `*cpp_extension` | the same entity and edge, same kind and same attributes, so the two rules agree on the key |
| what C++ files does an extension compile | `call.arg1_text` — the **argument as written**, `['src/ops.cpp', 'src/kernel.cu']` | attribute `sources` on `ExtensionModule` / `JitExtension`. Not an edge: a list's elements are not facts (see below) |
| what is the Python variable that holds that extension | the same call, `fact_join_by_span` `within` `definition.variable` (omega-python spans the assignment) | `ExtensionBinding`; `ExtensionBinding --binds--> ExtensionModule` |
| where does this project JIT-compile an extension at import time, and under what name | omega-python `call.function` named `load`/`load_inline` plus an `import.symbol` of that name; or the `call.method` spelling with the `cpp_extension` receiver | `JitExtension` at `pytorch-ext:jit-load:{path}:{call.arg0_text}`; `ExtensionBuildScript --builds--> JitExtension`, `loader` naming which of the two |
| which build scripts drive the build through torch's own `build_ext` | omega-python `import.symbol` named `BuildExtension` | `BuildTool`; `ExtensionBuildScript --configured_by--> BuildTool` |
| which C++ translation units are part of the extension, and which torch headers they pull in | omega-cpp `import.include` named one of 18 torch / ATen / c10 / CUDA / pybind11 headers | `ExtensionSource` and `TorchHeader`; `ExtensionSource --depends--> TorchHeader` |
| which C++ functions are the operators the extension exposes | omega-cpp `reference.type` named `Tensor` (`torch::Tensor` and `at::Tensor` both reduce to it), `fact_join_by_span` `within` `definition.function` | `ExtensionOp`; `ExtensionSource --declares--> ExtensionOp` |
| where is the Python entry point registered, and under what name | omega-cpp `definition.function` named `PYBIND11_MODULE`, `PYBIND11_EMBEDDED_MODULE`, `TORCH_LIBRARY`, `TORCH_LIBRARY_IMPL` or `TORCH_LIBRARY_FRAGMENT`, plus the same-span `definition.parameter_shape_candidate` | `ExtensionRegistry` with `macro` and `signature` (`(TORCH_EXTENSION_NAME, m)`, `(my_ops, m)`); `ExtensionSource --declares--> ExtensionRegistry` |
| does this extension need the CUDA toolkit | omega-cpp `import.include` named one of six CUDA headers | `BuildToolchain` `pytorch-ext:toolchain:cuda`; `ExtensionSource --compiled_by--> BuildToolchain` |

Three shapes are worth copying. The **macro-as-declaration** read: tree-sitter-cpp
parses `PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) { … }` as a function
definition, so the macro arrives as `definition.function` named for the macro and
the whole argument list arrives as `definition.parameter_shape_candidate` on a
byte-identical span — the only way to read a pybind-style macro's operands out
of a fieldless Pack. The **assignment-spans-the-call** read: omega-python spans
`definition.variable` over the entire statement, so a `call.function` inside it
reaches its binding with `fact_join_by_span` / `within` and no field on either
side. And **`receiver` as the import gate**: one `path_glob` over `receiver`
replaces both an `external_path_matches` that can never be true for Python
(brief §3i) and the two-clause import join, for the qualified call spelling.

## A field only the Pack can supply

**omega-python, `call.function` / `call.method`, the elements of a list
argument.** The call view answers the extension's *name*; it does not answer
*which C++ files this extension compiles*. `CppExtension('my_ops',
['src/ops.cpp', 'src/kernel.cu'])` yields `call.arg1_text` as the single string
`['src/ops.cpp', 'src/kernel.cu']`, which is publishable as an attribute for a
reader but can never be a relation end: `src/ops.cpp` and `src/kernel.cu` would
each have to render `pytorch-ext:source:{path}` to meet the `ExtensionSource`
the C++ side mints, and there is no operation that splits a value.

Neither of the first two options in the brief reaches it:

- **No built-in derives it.** `definition.name` is `CppExtension`; `path` and
  its derivatives describe the build script, not the sources.
- **No join reaches it.** `fact_join_by_span` relates facts the Pack emitted,
  and omega-python emits no fact for a string literal inside a list. There is
  nothing inside the `['src/ops.cpp', …]` span to join to.

What would answer it is a per-element emission — `call.string_argument`, one
fact per literal string anywhere in the argument list, on the call's span — not
a `sources` field, which would be a setuptools keyword baked into a Pack. It
would also answer `include_dirs`, `extra_compile_args` and `extra_link_args`
here, and every framework whose configuration is a list of strings in a call.
This is the surviving half of the `OWED.md` call-argument item; the first half
(the scalar arguments) has landed and is used above.

A second one, unchanged from the first pass: **omega-cpp publishes no call
fields at all and spans a callable on its declarator, not its body.**
`PYBIND11_MODULE(…)` spans `167-207` while `m.def("forward", &forward)` sits at
`212-254`, so the individual op registrations — the list of names the extension
actually exports to Python — arrive as `call.method` named `def` with no
reachable owner and no argument text. Two changes are needed and neither is a
Framework's to make: the canonical call view on omega-cpp's `call.function` and
`call.method` templates (which ten Packs now carry and omega-cpp does not), and
a `scope.function_body` template of the kind omega-python already has, to make
the owner reachable.

## Still to decide

- **The keyword spelling of the extension name is stated as written.**
  `CUDAExtension(name='my_cuda_ops', sources=[…])` yields
  `call.arg0_text=name='my_cuda_ops` — the Pack's strip pairs remove the
  trailing quote of a keyword argument but nothing removes the `name='` prefix,
  because the whole `keyword_argument` node is the first ordered child. The key
  is still unique, stable and human-readable, and both spellings of the *same*
  extension in the *same* file would be the same construct written twice, so no
  identity is split in practice — but `my_ops` and `name='my_ops` are two nodes
  if a project writes the constructor both ways in two scripts. A clause could
  discriminate (`field_prefix` on `call.arg0` with a quote byte), but it would
  take one rule per quote style and would state *nothing* for the keyword
  spelling instead of stating it imperfectly. Stating it as written was judged
  better; splitting the keyword argument at its `=` is a Pack question.
- **`*cpp_extension` as the receiver gate is deliberately loose.** It matches
  `cpp_extension`, `torch.utils.cpp_extension` and any alias ending in that
  segment, and it is the only gate the three qualified rules carry. A module
  named `cpp_extension` that is not torch's would be a false positive; the call
  names (`CppExtension`, `CUDAExtension`, `SyclExtension`, `load_inline`) make
  that near-impossible, and the loosest of the four, bare `load`, is still
  `something.cpp_extension.load(…)`.
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
  single global node for the same reason. `pytorch-ext:module:` keeps `{path}`
  in front of the name because two build scripts each declaring an extension
  called `_C` are two extensions.
