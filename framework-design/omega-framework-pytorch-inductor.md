# omega-framework-pytorch-inductor

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

8 overlay rules, 12 detection rules. **8 live, 0 dead.** (Was 5 rules, 0 live.)

Selector: `framework:pytorch-inductor`. Maturity: `semantic-overlay-full`.
Language: Python only (`host.required_packs = ["omega-python"]`).

### Entities it declares

| entity_kind | key template | minted by |
|---|---|---|
| `TorchModule` | `pytorch:module:{path}` | 7 rules |
| `TorchPackage` | `pytorch:package:{definition.name}` | 2 rules |
| `TorchCompileSite` | `pytorch:compile-site:{path}:{source.start}` | 4 rules |
| `TorchCompiledSymbol` | `pytorch:symbol:{path}:{holder.definition.name}` | 1 rule |
| `DynamoDirective` | `pytorch:dynamo:{path}:{source.start}` | 2 rules |

One kind per key template, and one attribute set per key template, so nothing
is computed and thrown away (brief 3g). `key_collisions.py pytorch-inductor`
reports nothing.

### Relations it declares

`contains` (module → compile site), `compiles` (compile site → the name it
binds), `configures` (Dynamo directive → module), `depends` (module → torch
subpackage). Every relation end is a key some rule in this file mints.

## What was wrong with it

The old file had **5 rules and none of them could match.** Concretely:

1. **Three dead fact kinds, in 3 rules.** `call.direct`, and two generator
   spellings — `definition.python_import_bound_member_call_literal_keyword_context`
   and `definition.python_import_bound_member_two_keyword_identifiers_context`.
   No Pack has emitted any of the three since the Pack rewrite.
2. **Five dead fields, across 2 rules.** `module_name`, `callee_member`,
   `binding_name`, `keyword_name`, `keyword_string` — plus `keyword1`,
   `value1`, `keyword2`, `value2` read in attributes. **omega-python publishes
   no fields at all**: all 30 of its templates have `"fields": {}`. Every rule
   in this file now reads only built-ins (`path`, `source.start`,
   `definition.name`, `definition.qname`) and joined facts.
3. **Three `external_path_matches` clauses, in 3 rules, all false always.**
   Brief 3i: `external.package` is fed only by a Pack field or attribute
   literally named `qualifier`, and only omega-c-sharp and omega-docker-compose
   publish one. `{"package": "torch", "member_prefix": "compile"}` was false for
   every possible Python fact. Replaced by the import join, which is the same
   question asked of a fact the Pack does emit.
4. **Two rules matched `call.member`**, which omega-c/omega-cpp/omega-c-sharp
   emit and omega-python does not. Python spells it `call.method`.
5. **Attributes read off thin air.** `call.arg0`, `call.kwarg.backend`,
   `call.kwarg.mode` are not fields of anything; per brief 3b an unresolvable
   attribute drops the entity and leaves the relation dangling, so even had the
   kind matched, `CompiledFunction` would never have materialized.
6. **A relation from an entity to itself.** `inductor.torch-compile` emitted
   `configures` from `current` to `pytorch:compiled:{path}:{source.start}` —
   which *is* `current`'s own key. Same for `inductor.dynamo-optimize`. Two of
   the four relations in the file were self-edges carrying no information.
7. **`inductor.compile.call` emitted one entity and no relation**, keyed on its
   own span: an answer-free restatement of its input (brief 1).
8. **Two `path_glob: "**/*.py"` clauses** on rules whose fact kind already
   implied Python. Dropped as restating what the Pack decided.

## What it states now

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| which Python modules use PyTorch at all | `import.module` / `import.from_module`, name prefixed `torch` | `TorchModule` `pytorch:module:{path}` |
| which torch subpackage a module pulls in — `torch._inductor.config` and `torch._dynamo` are named as written, so *who reaches into the Inductor backend* is the edges into `pytorch:package:torch._inductor*` | same two facts, `definition.name` as written | `TorchPackage`, and `depends` module → package |
| where `torch.compile(...)` is applied | `call.method` named `compile`, in a file that imports `torch` | `TorchCompileSite`, and `contains` module → site |
| where `@torch.compile` is applied (including the bare, un-parenthesised form, which emits no call) | `reference.decorator` named `compile`, same import gate | the same `TorchCompileSite` key, same kind, same attributes |
| where `compile(...)` is applied after `from torch import compile` | `call.function` named `compile`, gated on an `import.symbol` named `compile` **and** a `torch` `import.from_module` in the same file | the same `TorchCompileSite` key |
| which enclosing function or class a compile site sits in | `definition.qname`, the host's ancestor chain (contract §2) | `applied_in` attribute of `TorchCompileSite` |
| which module-level name holds the compiled model | `fact_join_by_span` `within` to `definition.variable` | `TorchCompiledSymbol`, and `compiles` site → symbol |
| where Dynamo is steered — `optimize`, `allow_in_graph`, `mark_dynamic`, `graph_break`, `register_backend`, `set_stance` and the rest, in either the `torch._dynamo.x()` or the `from torch._dynamo import x` spelling | `call.method` / `call.function` with that name, import-gated | `DynamoDirective`, and `configures` directive → module |

Eight rules, no rule keyed to a private spelling, every rule import-gated so
`call.method compile` cannot mean something else's `.compile()`.

### Why the gate is an import join and not `external_path_matches`

Brief 3i. `import.module` with `field_prefix definition.name = "torch"` is true
for `torch`, `torch.nn`, `torch._dynamo` and `torch._inductor.config`, and it is
the only statement of "this file is a PyTorch file" that omega-python actually
makes. It also admits `torchvision` and `torchaudio`; those are PyTorch too, and
a `.compile()` in them is still `torch.compile`, so the looseness is not a
defect. `inductor.dynamo.imported-call` uses the tighter prefix `torch._`,
because `optimize` as a bare call is common enough to want the private-module
proof.

## A field only the Pack can supply

**omega-python / `reference.decorator` / a link to the declaration it
decorates.**

`@torch.compile def step(x)` is the idiomatic spelling and the overlay cannot
say *which function is compiled*. Measured with `dump_call_emissions` on a
hand-written file: the decorator emits `reference.decorator compile` at bytes
274–281 and the function emits `definition.function step` at 297–326. Neither
span contains the other, because tree-sitter-python's `decorated_definition`
holds the decorators and the `function_definition` as *siblings* — so
`fact_join_by_span` fails in both directions. `fact_join_by_field` needs a
shared field and omega-python publishes none. `definition.container` reaches
only the enclosing *class* (for a decorated method) and is absent at module
scope, so it names the wrong thing or nothing.

The cheap fix is not a field at all: **span `reference.decorator` on the
`decorated_definition` node** instead of on the decorator name. Then the
declaration lies inside the decorator fact and `fact_join_by_span` with
`within` reaches it from the declaration side, with no new bytes on any
emission. Failing that, a `decorates` field naming the declaration. This is not
one framework's problem — every Python framework that reads decorators
(django, flask, fastapi, celery, pytest) has the same hole, so it belongs in
`00-INDEX.md` rather than here.

## Still to decide

- **`backend=` and `mode=` are gone, and this file no longer claims them.** The
  old rules pretended to read them from fields no Pack published. omega-python
  emits nothing for a call's arguments, so *is this compiled with the Inductor
  backend* is unanswerable from source. The `detection_rules` half still
  detects the literal signature `backend="inductor"` from the row program, and
  that is left alone because it is a different program over different input.
  Whether the Pack should emit call arguments at all is a much larger question
  than this framework; it is recorded as a coverage gap, not as a Pack ask.
- **`torch._inductor.config.max_autotune = True`** is the other common way to
  configure Inductor, and omega-python emits `definition.variable` only for an
  *identifier* left-hand side at module scope, so an attribute assignment emits
  nothing. Recorded as a gap; a Pack pattern for module-level attribute
  assignment would serve more than this framework.
- **`TorchModule` is minted by seven rules.** That is deliberate (brief 3a: mint
  the entity your relation addresses in the same rule), kept safe by giving it
  one kind and one attribute set everywhere. If a future rule wants to attach
  something module-specific it must go on a relation, not on that entity.
