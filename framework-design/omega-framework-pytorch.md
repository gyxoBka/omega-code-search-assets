# omega-framework-pytorch

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

29 overlay rules, 4 detection rules. **1 can match, 28 cannot.**

That was the state before this rewrite, and the two tables below describe
it. The file is now **20 overlay rules, 20 live, 0 dead** — see
*What was wrong with it* and *What it states now*.

Selector: `framework:pytorch`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComputeNode` | 7 |
| `ModelComponent` | 3 |
| `Loss` | 3 |
| `Submodule` | 2 |
| `Parameter` | 2 |
| `ComputeGraph` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `RegisteredState` | 1 |
| `Forward` | 1 |
| `Optimizer` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `compute_depends_on` | 6 |
| `contains` | 3 |
| `has_parameter` | 2 |
| `uses_loss` | 2 |
| `forward_calls` | 2 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `has_forward` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `definition.python_import_bound_member_call_identifier_context` | 5 | **no** |
| `definition.python_class_method_self_member_call_identifier_context` | 5 | **no** |
| `definition.python_class_self_member_from_import_constructor_context` | 3 | **no** |
| `definition.python_class_self_member_import_alias_constructor_context` | 3 | **no** |
| `definition.python_import_bound_member_binding_context` | 2 | **no** |
| `definition.python_import_bound_member_call_two_identifier_context` | 2 | **no** |
| `definition.python_class_method_self_member_call_two_identifier_context` | 2 | **no** |
| `definition.python_import_bound_member_call_three_identifier_context` | 2 | **no** |
| `definition.python_class_method_self_member_call_three_identifier_context` | 2 | **no** |
| `definition.class` | 1 | yes |
| `definition.python_from_import_constructor_binding_context` | 1 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.python_from_import_class_base_context` | 1 | **no** |
| `reference.python_import_alias_class_member_base_context` | 1 | **no** |
| `call.python_class_self_registration_string_context` | 1 | **no** |
| `definition.python_class_method_context` | 1 | **no** |
| `call.python_class_method_self_member_return_identifier_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x60, `fact_kind` x29, `field_equals` x27, `field_in` x26, `path_glob` x7, `fact_join_by_field` x6, `(join)` x6, `external_path_matches` x3.

Fields read: `module_name`, `owner_function`, `source.start`, `binding_name`, `callee_member`, `member`, `member_name`, `imported_name`, `class_name`, `second_identifier`, `third_identifier`, `input_identifier`, `callee_name`, `base_member`, `name_string`, `method_name`.

Path globs: `**/*.py`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `pytorch.direct-functional-compute-node` | kind `definition.python_import_bound_member_call_identifier_context`; field `binding_name`, `callee_member`, `input_identifier`, `module_name`, `owner_function` |
| `pytorch.direct-functional-compute-dependency` | kind `definition.python_import_bound_member_call_identifier_context`; field `binding_name`, `callee_member`, `input_identifier`, `module_name`, `owner_function` |
| `pytorch.source-authored.fx-graph` | kind `definition.python_from_import_constructor_binding_context`; field `binding_name`, `callee_name`, `imported_name`, `module_name` |
| `pytorch.generic-api-call.torch` | kind `call.target_candidate` |
| `pytorch.generic-dependency.torch` | kind `import.target_candidate` |
| `pytorch.module.from-import` | kind `reference.python_from_import_class_base_context`; field `imported_name`, `module_name` |
| `pytorch.module.import-alias` | kind `reference.python_import_alias_class_member_base_context`; field `base_member`, `module_name` |
| `pytorch.submodule.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `class_name`, `imported_name`, `member_name`, `module_name` |
| `pytorch.parameter.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `class_name`, `imported_name`, `member_name`, `module_name` |
| `pytorch.loss-member.from` | kind `definition.python_class_self_member_from_import_constructor_context`; field `imported_name`, `member_name`, `module_name` |
| `pytorch.submodule.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `class_name`, `member_name`, `module_name` |
| `pytorch.parameter.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `class_name`, `member_name`, `module_name` |
| `pytorch.loss-member.alias` | kind `definition.python_class_self_member_import_alias_constructor_context`; field `callee_member`, `member_name`, `module_name` |
| `pytorch.registration` | kind `call.python_class_self_registration_string_context`; field `member`, `name_string` |
| `pytorch.forward` | kind `definition.python_class_method_context`; field `method_name` |
| `pytorch.forward.self-call-node` | kind `definition.python_class_method_self_member_call_identifier_context`; field `binding_name`, `member`, `owner_function` |
| `pytorch.forward.self-return-node` | kind `call.python_class_method_self_member_return_identifier_context`; field `member`, `owner_function` |
| `pytorch.forward.self-call-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`; field `binding_name`, `input_identifier`, `owner_function` |
| `pytorch.optimizer.binding` | kind `definition.python_import_bound_member_binding_context`; field `member`, `module_name` |
| `pytorch.loss.binding` | kind `definition.python_import_bound_member_binding_context`; field `member`, `module_name` |
| `pytorch.direct-functional-second-input-metadata` | kind `definition.python_import_bound_member_call_two_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `second_identifier` |
| `pytorch.direct-functional-second-input-dependency` | kind `definition.python_import_bound_member_call_identifier_context`, `definition.python_import_bound_member_call_two_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `second_identifier` |
| `pytorch.forward.self-call-second-input-metadata` | kind `definition.python_class_method_self_member_call_two_identifier_context`; field `binding_name`, `member`, `owner_function`, `second_identifier` |
| `pytorch.forward.self-call-second-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`, `definition.python_class_method_self_member_call_two_identifier_context`; field `binding_name`, `owner_function`, `second_identifier` |
| `pytorch.direct-functional-third-input-metadata` | kind `definition.python_import_bound_member_call_three_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `third_identifier` |
| `pytorch.direct-functional-third-input-dependency` | kind `definition.python_import_bound_member_call_identifier_context`, `definition.python_import_bound_member_call_three_identifier_context`; field `binding_name`, `callee_member`, `module_name`, `owner_function`, `third_identifier` |
| `pytorch.forward.self-call-third-input-metadata` | kind `definition.python_class_method_self_member_call_three_identifier_context`; field `binding_name`, `member`, `owner_function`, `third_identifier` |
| `pytorch.forward.self-call-third-dependency` | kind `definition.python_class_method_self_member_call_identifier_context`, `definition.python_class_method_self_member_call_three_identifier_context`; field `binding_name`, `owner_function`, `third_identifier` |

## What was wrong with it

29 overlay rules, **28 of which could not match a single Pack emission**, and
the 29th matched nothing either for a reason `overlay_audit.py` cannot see.

**The kind vocabulary was the generator's, not a Pack's.** 18 distinct fact
kinds appeared in the file; **17 of them are emitted by no Pack in the
repository**. They were not language-neutral names with a spelling problem —
they were one-shot descriptions of a *tree shape*, which §5 of the contract
forbids outright:

| shape the kind encoded | rules | what omega-python actually emits |
|---|---|---|
| `definition.python_import_bound_member_call_identifier_context` — "an assignment whose value is a call on an import-bound member, with one bare identifier argument" | 5 | `call.method`, and nothing at all about the assignment target or the arguments |
| `definition.python_class_method_self_member_call_identifier_context` | 5 | `call.method` + `scope.function_body` + `scope.class_body` |
| `definition.python_class_self_member_from_import_constructor_context` | 3 | `call.function` inside `scope.class_body` |
| `definition.python_class_self_member_import_alias_constructor_context` | 3 | `call.method` inside `scope.class_body` |
| `definition.python_import_bound_member_binding_context` | 2 | `call.method` |
| `..._call_two_identifier_context` / `..._call_three_identifier_context` | 8 | nothing — argument arity is not a Pack fact |
| `call.target_candidate`, `import.target_candidate` | 2 | `call.method`/`call.function`, `import.module`/`import.from_module` |
| `reference.python_from_import_class_base_context`, `reference.python_import_alias_class_member_base_context` | 2 | one `relation.implements` fact, for every base-class spelling |
| `call.python_class_self_registration_string_context`, `definition.python_class_method_context`, `definition.python_from_import_constructor_binding_context` | 3 | `call.method`, `definition.function`, `call.function` |

**Eight rules existed only to count arguments.** `...second-input-metadata`,
`...second-input-dependency`, `...third-input-metadata`,
`...third-input-dependency`, twice over (direct-functional and forward-self),
reading `second_identifier` and `third_identifier`. A Pack states that a call
happened and what was called; it does not state the *n*-th positional argument,
and the contract says a rule that needs to know the shape of an argument list
is encoding syntax. All eight are deleted rather than ported. The
`coverage.gaps` entry that promised "first/second/third direct identifier
dependencies" was describing a capability nothing ever had.

**Six rules were one Python spelling of the same construct.** `submodule.from`
/ `submodule.alias`, `parameter.from` / `parameter.alias`, `loss-member.from` /
`loss-member.alias` differed only in whether the source said
`from torch.nn import Conv2d` or `import torch.nn as nn`. omega-python reduces
a qualified callee to its last identifier, so those are now one fact each and
the pairs collapse.

**34 field reads, none of them supplied.** `module_name`, `binding_name`,
`callee_member`, `member_name`, `input_identifier`, `second_identifier`,
`third_identifier`, `class_name`, `owner_function`, `name_string`,
`method_name`, `base_member`, `callee_name`, `imported_name`, `member`.
**omega-python publishes no `fields` on any of its 30 templates** — every one of
those reads was against a map that is always empty. Everything the new file
needs comes from `definition.name`, `path`, `source.start` and
`fact_join_by_span` with `within`.

**The one "live" rule was dead too.** `pytorch.module.subclass` matched
`definition.class` and then asked `external_path_matches { package: "torch.nn",
member_prefix: "Module" }`. `definition.class` carries no resolved external
package, and its single output keyed on `{definition.qname}`, which is not a
field omega-python publishes and not one of the fourteen built-in names
`OverlayFact::field` resolves — so `render` would drop the placeholder even if
the match had succeeded. The audit counted it live because both of its clauses
parse.

**Eleven entity kinds, and half of them were named after their own input.**
`ApiUse`, `Dependency`, `ComputeGraph` and `RegisteredState` each had exactly
one rule, no relation reaching them, and a canonical key that restated the
matched name.

**29 rules became 20, all live.** The audit went from 1 live / 28 dead to 20
live / 0 dead.

## What it states now

Every rule is keyed to a kind `packs/omega-python/rules.json` emits, and reads
only built-in names. Class membership is `fact_join_by_span` / `within` against
`definition.class` (whose span is the whole declaration, so it reaches a base in
the header) or `scope.class_body` (whose span is the body block, so it reaches a
member); function membership is the same join against `scope.function_body`.

| what it answers | Pack fact it reads | entity / relation |
|---|---|---|
| which classes are neural modules | `relation.implements` name in `Module`, `Sequential`, `ModuleList`, `ModuleDict` + `within definition.class` | `NeuralModule` `pytorch:module:{class}` |
| which classes are datasets or samplers | `relation.implements` name in 13 `torch.utils.data` / torchvision bases + `within definition.class` | `Dataset` `pytorch:dataset:{class}` |
| which classes are custom autograd ops | `relation.implements` name `Function`, guarded by a same-path `import.from_module` prefixed `torch` | `AutogradFunction` `pytorch:autograd-function:{class}` |
| where a module's forward pass is | `definition.function` named `forward` + `within scope.class_body` | `Forward` `pytorch:forward:{class}`; `NeuralModule --has_forward--> Forward` |
| what the forward pass calls, in source order | `call.method` + `within scope.function_body` where its name is `forward` + `within scope.class_body` | `ComputeNode` `pytorch:compute-node:{class}.{callee}`; `Forward --forward_calls--> ComputeNode`, carrying `source.start` |
| which layers a module is built from | `call.method` (`nn.Conv2d(...)`) and `call.function` (`Conv2d(...)`) in 82 `torch.nn` layer names + `within scope.class_body` | `Layer` `pytorch:layer:{class}.{type}`; `NeuralModule --contains--> Layer` |
| which modules declare raw parameters or buffers | `call.method` in `Parameter`, `Buffer`, `UninitializedParameter`, `UninitializedBuffer` + `within scope.class_body` | `Parameter` `pytorch:parameter:{class}.{kind}`; `NeuralModule --has_parameter--> Parameter` |
| what objective a function optimizes | `call.method` / `call.function` in 22 `nn.*Loss` classes and 17 `F.*_loss` functions (39 names) + `within scope.function_body` | `Loss` `pytorch:loss:{objective}`; `ComputeSite --uses_loss--> Loss` |
| which optimizer a function constructs | `call.method` / `call.function` in 13 `torch.optim` algorithms + `within scope.function_body` | `Optimizer` `pytorch:optimizer:{algorithm}`; `ComputeSite --uses_optimizer--> Optimizer` |
| what the learning-rate schedule is | `call.method` in 15 `lr_scheduler` names + `within scope.function_body` | `LrSchedule` `pytorch:lr-schedule:{schedule}`; `ComputeSite --uses_lr_schedule--> LrSchedule` |
| where the training loop is | `call.method` in `backward`, `zero_grad`, `clip_grad_norm_`, `clip_grad_value_`, `no_grad`, `inference_mode` + `within scope.function_body` | `TrainingLoop` `pytorch:training-loop:{path}:{fn}`; `ComputeSite --has_training_loop--> TrainingLoop` |
| where model state is written or restored | `call.method` in `state_dict`, `load_state_dict` + `within scope.function_body` | `Checkpoint` `pytorch:checkpoint:{path}:{fn}`; `ComputeSite --persists_state--> Checkpoint` |
| how training is executed — DDP, FSDP, AMP, collectives | `call.method` in 11 `torch.distributed` / `torch.amp` names + `within scope.function_body` | `ExecutionStrategy` `pytorch:execution-strategy:{strategy}`; `ComputeSite --uses_execution_strategy--> ExecutionStrategy` |
| how batches reach the model | `call.method` in 13 `torch.utils.data` names + `within scope.function_body` | `DataPipeline` `pytorch:data-pipeline:{component}`; `ComputeSite --uses_data--> DataPipeline` |
| where the model is compiled, traced, quantized or exported | `call.method` in 10 `compile`/`jit`/`fx`/`onnx`/`quantization` names, guarded by a same-path torch `import.from_module` + `within scope.function_body` | `GraphTransform` `pytorch:graph-transform:{transform}`; `ComputeSite --transforms_graph--> GraphTransform` |
| which part of torch a file depends on | `import.from_module` and `import.module` whose name is prefixed `torch` | `TorchApi` `pytorch:api:{module}`, `SourceFile` `pytorch:file:{path}`; `SourceFile --depends_on--> TorchApi` |

`ComputeSite` `pytorch:site:{path}:{fn}` is the one shared node — the function
in which torch work happens — and every rule that addresses it also mints it, so
no relation end dangles. Checked mechanically: the set of canonical-key
templates the 20 rules address is exactly the set they mint (13 relations, 18
entity kinds, 0 dangling). No rule uses `Reference::Current`, so the
first-output trap of §3b does not apply. No attribute expression depends on
`external.member` or on anything else that can resolve to nothing.

## A field only the Pack can supply

**omega-python, any kind, the name a value inside a function body is bound to.**
`queries.scm` says so deliberately: "Names bound inside a function body — an
assignment, a `for` target, a `with`/`except` alias, a comprehension variable, a
`match` capture — are deliberately absent." For PyTorch that removes the single
most valuable edge in the framework: `self.conv1 = nn.Conv2d(3, 64, 3)` in
`__init__` and `x = self.conv1(x)` in `forward` are the two halves of the model's
layer graph, and without the attribute name `conv1` on the constructor side they
cannot be joined.

Neither route in §2 of the brief reaches it. `definition.name` on the
`call.method` fact is `Conv2d`, the callee, not the target. `definition.field`
covers class-*body* assignments only, so a `fact_join_by_span` / `within` from
the call finds `scope.function_body` (`__init__`) and `scope.class_body` (the
class) but never a fact carrying `conv1` — no fact carrying `conv1` exists.

What would fix it is a new **pattern**, not a field on an existing kind: a
`definition.attribute` (or `binding.self_attribute`) over
`(assignment left: (attribute object: (identifier) @_self attribute:
(identifier) @name) (#eq? @_self "self"))` inside a `function_definition`,
spanning the assignment. Its span would then contain the constructor call, and
the existing `within` join reaches it with no field at all. That is narrower
than the blanket exclusion the Pack wrote: `self.x = ...` is the one
function-body binding that *does* resolve outside its block, because it is the
object's public surface, and it is what Django model instances, dataclasses,
attrs classes and every Python framework with `__init__`-assigned state need as
much as PyTorch does. **It is a cross-framework request, not a PyTorch one**, so it is reported
back as a Pack field this rewrite needs rather than acted on here; it belongs
in `OWED.md`, which this task is not permitted to touch.

Until then the overlay states `NeuralModule --contains--> Layer(type)` and
`Forward --forward_calls--> ComputeNode(callee)` as two separate, correct facts
and does not pretend to connect them. `coverage.gaps` says exactly this.

## Still to decide

- **Generic callee names.** `Function`, `compile`, `script`, `trace` and
  `export` are not PyTorch's alone, and omega-python reduces a qualified callee
  to its last identifier, so `torch.onnx.export` and `parser.export` are the
  same fact. Those two rules carry a same-path `import.from_module` prefixed
  `torch` as a guard. The guard proves the *file* is torch code, not the *call*;
  a file that imports torch and also calls `argparse`'s `export` would emit a
  spurious `GraphTransform`. The alternative was to drop the rules, and
  "is this model compiled or exported to ONNX" is worth the false positive rate
  at file granularity. Revisit if the Pack ever publishes the callee qualifier.
- **`torch` as a prefix.** `pytorch.api.*` uses `field_prefix "torch"`, which
  admits `torchvision`, `torchaudio` and `torchmetrics`. That is deliberate —
  they are the PyTorch ecosystem and an agent asking "what torch surface does
  this file use" wants them — but it is a judgement, not a derivation.
- **A layer's identity.** `pytorch:layer:{class}.{type}` collapses three
  `nn.Linear` calls in one module into one node. Keying by `source.start` would
  separate them but would make the key unstable under any edit. Collapsed is the
  right default while the attribute name is unavailable; if the Pack change above
  lands, the key becomes `{class}.{attribute}` and the question stops being
  ambiguous.
- **Losses and optimizers built at module level.** Both rules require
  `within scope.function_body`, so `criterion = nn.CrossEntropyLoss()` at the top
  of a script emits nothing. Relaxing the join would mean minting a file-scoped
  `ComputeSite`, which is a different entity with the same name. Left as is,
  and recorded in `coverage.gaps`.
