# omega-framework-pydantic

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**7 overlay rules, 4 detection rules. All 7 match.** (Was 14 rules, 6 live.)

Selector: `framework:pydantic`. Maturity: `semantic-overlay-full`.
Language: Python only, `omega-python`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `PydanticModel` | 2 (one hub, one kind, no collision) |
| `PydanticField` | 1 |
| `PydanticFieldDeclaration` | 1 |
| `PydanticModelConfig` | 1 |
| `PydanticModelHook` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configures` | 3 |
| `has_field` | 1 |
| `extends` | 1 |
| `references_model` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `relation.implements` | 2 | yes |
| `call.function` | 2 | yes |
| `definition.field` | 1 | yes |
| `type_use.name` | 1 | yes |
| `reference.decorator` | 1 | yes |
| `definition.class` (joined) | 3 | yes |
| `import.from_module` (joined) | 1 | yes |

Fields read: only the host's built-ins — `definition.name`,
`definition.container`, `definition.qname`, `path`, `source.start`.
**No Pack field is required.** omega-python publishes zero fields and zero
attributes on all 30 of its templates, so that was the only option available.

## What was wrong with it

Measured with `python pack-design/overlay_audit.py pydantic` and with
`dump_call_emissions.exe` over a hand-written Pydantic v2 model file.

**1. Eight of fourteen rules matched a fact kind no Pack emits.** They were
keyed to the pre-rewrite generator vocabulary — one composite kind per Python
spelling of a construct:

| dead kind | rules |
|---|---|
| `reference.python_from_import_class_base_context` | 3 (`pydantic.model`, `.model.basemodel`, `.model.rootmodel`) |
| `call.target_candidate` | 1 |
| `import.target_candidate` | 1 |
| `call.direct` | 1 |
| `definition.python_class_field_context` | 1 |
| `definition.python_from_import_constructor_binding_context` | 1 |

**2. Every one of the fourteen rules was gated on `external_path_matches`, and
that clause can never be true for a Python fact.** This is the load-bearing
finding and it is not visible to `overlay_audit.py`. `OverlayFact.external` is
built by `facts_of_surface` from `external_environment`, which registers only a
surface binding whose `target_hint` is set; `target_hint` is
`occurrence.qualifier` (`surface.rs:376`); and `qualifier` is read only from an
emission field or attribute literally named `qualifier`
(`content_builder.rs::mention_fields`). omega-python publishes `module` and
`target` on `binding.import_alias`, never `qualifier` — exactly the shape
`OWED.md` item 7a already records for JavaScript and TypeScript. So
`external.package` and `external.member` are empty for every Python fact, and
**the six rules the audit called "live" matched nothing either.** The true
before-figure is 0 of 14. Not one `external_path_matches` clause survives in the
new file.

**3. Three rules were the same rule written three times.**
`pydantic.model`, `pydantic.model.basemodel` and `pydantic.model.rootmodel`
differed only in a `member_in` list of length one, and two of them disagreed
with the first about the canonical key (`{definition.qname}` versus
`{class_name}`). They are one rule now, with the base as an attribute.

**4. Five decorator rules were byte-identical apart from one string.**
`field_validator`, `model_validator`, `computed_field`, `field_serializer`,
`model_serializer` — one rule now, over a `field_in` list of seven that also
picks up the v1 spellings `validator` and `root_validator`.

**5. Two rules only restated their input.**
`pydantic.generic-api-call.pydantic` minted `pydantic:api-use:{path}:{start}`
and then drew `uses_api` from `current` to the key `current` had just been
minted under — the self-loop shape wave 2 and wave 6 both found.
`pydantic.generic-dependency.pydantic` minted one `pydantic:dependency:pydantic`
node per import and pointed at it from itself. Neither adds a fact; *does this
project depend on pydantic* is what `detection_rules` answers, and it still
does. Both deleted.

**6. Four rules read Pack fields that do not exist** — `owner_class`,
`field_name`, `field_type`, `binding_name`, `class_name`, `decorator.arg0`,
`call.arg0`, `call.kwarg.alias`. The attribute ones would have dropped their
entity outright (`evaluate_attributes` returns `None`), leaving the relations
addressing them dangling. All replaced by host built-ins.

**7. `pydantic.validator` emitted a `validates` relation by
`by_field: decorator.arg0`** — the validated field name, which lives in a string
argument. omega-python emits no fact over a call argument, so that end rendered
nothing. That answer is now recorded as a coverage gap instead of being faked.

## What it states now

Everything below was verified against the emission dump of a file containing
`class User(BaseModel)` with `model_config = ConfigDict(...)`, three fields, a
`Field(...)` declaration, all five hook decorators, a `RootModel[...]` subclass
and a `BaseSettings` subclass.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| Which classes are Pydantic models, and which flavour (model / root model / settings) | `relation.implements` named `BaseModel`, `RootModel`, `BaseSettings`, `GenericModel`, with the host-computed `definition.container` naming the class | entity `PydanticModel` at `pydantic:model:{class}`, attribute `base` |
| Which model extends which model | `relation.implements` whose base is in neither the root set nor a known non-model set, in a file that has an `import.from_module` beginning `pydantic` | entity `PydanticModel` + relation `extends` -> `pydantic:model:{base}` |
| Which fields does this model declare | `definition.field` (a class-body assignment, annotated or not) whose `definition.container` is a class with a Pydantic root base | entity `PydanticField` at `pydantic:field:{path}:{Model.field}` + relation `has_field` from the model |
| Which fields carry an explicit `Field()` / `PrivateAttr()` declaration | `call.function` named `Field`/`PrivateAttr`, span-joined `within` the `definition.field` it initializes and `within` a model `definition.class` | entity `PydanticFieldDeclaration` + relation `configures` -> that field |
| Which models does this model embed (the composition edge, and the only one that crosses files) | `type_use.name` inside a `definition.field` inside a model class, name not in the scalar/typing exclusion set | relation `references_model` from `pydantic:field:{path}:{Model.field}` to `pydantic:model:{TypeName}` |
| Which models are explicitly configured | `call.function` named `ConfigDict`, span-joined `within` a model `definition.class` | entity `PydanticModelConfig` + relation `configures` -> the model |
| Which models carry validation / serialization / computed-field hooks, and of which kind | `reference.decorator` named in the seven-hook set, whose `definition.container` is a model class | entity `PydanticModelHook` (attribute `hook`) + relation `configures` -> the model |

### How a model is recognised without a single Pack field

omega-python emits `relation.implements` spanned on the base-class identifier,
*inside* the `definition.class` span. The host therefore fills that fact's
`definition.container` with the subclass's own name (`overlay.rs:1200-1249`).
That single built-in replaces the whole dead
`reference.python_from_import_class_base_context` family: the base is the fact's
`definition.name`, the subclass is its `definition.container`, and no join is
needed to state *class X is a model whose base is BaseModel*.

The same built-in is the model gate everywhere else. A `definition.field` or a
`reference.decorator` in a class body carries `definition.container` = the class
name, so
`fact_join_by_field(relation.implements, definition.container -> definition.container)`
with a root-base `where` asks *is my owning class a Pydantic model* with no Pack
field on either side. For a fact nested one level deeper — a `Field()` call
inside a field assignment, a type name inside an annotation — the container is
the field, so the gate becomes `fact_join_by_span within definition.class`
carrying the same nested join.

### Every canonical key minted, and every key addressed

| key template | minted by | addressed by |
|---|---|---|
| `pydantic:model:{class}` | `pydantic.model`, `pydantic.model.extends` (same kind, hub) | `.model.config`, `.model.extends`, `.model.field`, `.model.field.type`, `.model.hook` |
| `pydantic:field:{path}:{Model.field}` | `pydantic.model.field` | `.model.field.declaration`, `.model.field.type` |
| `pydantic:model-config:{path}:{class}` | `pydantic.model.config` | — |
| `pydantic:field-declaration:{path}:{Model.field}` | `pydantic.model.field.declaration` | — |
| `pydantic:model-hook:{path}:{start}` | `pydantic.model.hook` | — |

The addressed set is contained in the minted set (brief §3a), and the rules that
address a key carry the minting rule's conditions (§3b): every rule that points
at `pydantic:model:{class}` requires that class to have a root-base
`relation.implements`, which is exactly `pydantic.model`'s own match.
`pydantic.model` sorts alphabetically before `pydantic.model.extends`, so where
both fire the richer attribute set (with `base`) is the one that materializes
(§3g); both mint the same `PydanticModel` kind, so nothing is lost, and
`key_collisions.py` reports nothing.

`current` is the first entity output in all five rules that use it (§3b), and
every attribute is a built-in that is guaranteed present given the match
clauses, so no entity is dropped for an unresolvable attribute (§3b).

## A field only the Pack can supply

**omega-python, `call.function` and `call.method` and `reference.decorator`: the
first string-literal argument.** This is the row `OWED.md` item 1 already
carries for omega-python (asked by django in wave 2) and item 10a generalises to
`literal.string`. For pydantic it costs five distinct answers:

- `Field(alias="userName", ge=0)` — which wire name a field is serialized under,
  and its constraints;
- `field_validator("name")`, `field_serializer("id")` — **which field** a
  validator or serializer applies to. This is the single most asked question
  about a Pydantic model and the overlay can only say *this model has a field
  validator*;
- `model_validator(mode="after")` — whether a model validator runs before or
  after parsing;
- `ConfigDict(frozen=True, populate_by_name=True)` — every model-level setting;
- `class Config: extra = "forbid"` in v1.

Neither route in brief §2 reaches it. `definition.name` is the callee's name,
not its arguments; there is no built-in for argument text; and
`fact_join_by_span` has nothing to bind because omega-python emits **no fact at
all over a string literal or a keyword argument** — the dump of a full model
file contains not one emission inside a call's argument list. The honest shape
is the one `OWED.md` already proposes: one `literal.string` template per Pack,
named by the literal's text and spanned on the literal node.

**Second, unrelated to arguments: `qualifier` on omega-python's
`binding.import_alias` and `import.symbol`.** Without it `OverlayFact.external`
is empty for every Python fact and `external_path_matches` is unreachable, which
is what killed the old file's six "live" rules silently. This is the same
`qualifier` row `OWED.md` item 1 carries for the JS/TS Packs, now measured for
Python; it belongs in item 7a alongside them.

## Still to decide

**`pydantic.model.extends` is the one judgement call in the file.** A subclass
of a project model (`class Admin(User)`) has no Pydantic root base of its own,
so the precise gate cannot see it. The rule instead requires the file to import
something beginning with `pydantic` and the base name not to be in a 31-entry
non-model exclusion list. In a file that imports pydantic that is usually right,
but `class MyError(SomeBaseError)` in the same file will also be minted as a
`PydanticModel`. The alternatives were both worse: gating on the base being
declared in *the same file* loses the ordinary cross-file case, and dropping the
rule loses model inheritance entirely, which is Pydantic's main composition
mechanism. Deliberately kept, with the looser `confidence: candidate`.

Two consequences of that choice, both deliberate:

- The file gate matches `import.from_module`, so `import pydantic` followed by
  `class X(pydantic.BaseModel)` is not gated in. The *root-base* rules are
  unaffected — omega-python names an attribute base by its last identifier, so
  `pydantic.BaseModel` arrives as `BaseModel` — but `pydantic.model.extends`
  does not fire for a file that never writes `from pydantic import ...`.
- `pydantic.model.field.type` targets `pydantic:model:{TypeName}` on a bare
  name. A field annotated with a project type that is not a model addresses an
  entity nothing mints. The scalar/typing exclusion list removes the common
  cases; the residual is accepted because a name is all omega-python resolves,
  and the alternative is losing the model-to-model edge altogether.

**Deliberately not written:** a rule over `call.method` named `model_validate`,
`model_dump` and friends. omega-python publishes no receiver, so the call cannot
be attributed to a model, and an entity keyed by its own position with no
relation is what contract §5 forbids.
