# omega-framework-pydantic

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

**9 overlay rules, 4 detection rules. All 9 match.** (Wave 1: 14 rules, 6 of
them scored live and 0 actually matching. Wave 2: 7 rules, 7 live. Now 9.)

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
| `PydanticModelUse` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configures` | 3 |
| `has_field` | 1 |
| `extends` | 1 |
| `references_model` | 1 |
| `validates` | 1 |
| `uses_model` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `relation.implements` | 2 | yes |
| `call.function` | 3 | yes |
| `call.method` | 1 | yes |
| `definition.field` | 1 | yes |
| `type_use.name` | 1 | yes |
| `reference.decorator` | 1 | yes |
| `definition.class` (joined) | 3 | yes |
| `import.from_module` (joined) | 1 | yes |

Fields read: the host's built-ins -- `definition.name`, `definition.container`,
`definition.qname`, `enclosing.qname`, `path`, `source.start` -- and, new in
this pass, three Pack fields omega-python now publishes on its call templates:
`call.arg0`, `call.arg0_text` and `receiver`.

## What was wrong with it

This is the second pass. The first pass (recorded below) left the file clean:
`overlay_audit.py` reported 7 rules, 7 live, and `key_collisions.py` reported
nothing. What was wrong with *that* file is one thing, and it was not a defect
when it was written.

**Two of its claims were true then and are false now.** omega-python's
`call.function` and `call.method` templates had no `fields` map at all when the
wave-2 file was written -- all 30 templates published zero fields and zero
attributes, which the old State section said in as many words. They now publish
`call.arg0`, `call.arg0_text`, `call.arg0_name`, `call.arg1`, `call.arg1_text`,
`call.arg2`, `call.last_arg`, `call.last_arg_name`, and `call.method`
additionally publishes `receiver`. Measured with `dump_call_emissions` over a
hand-written Pydantic v2 model file and a model-consumer file. That falsified
exactly two sentences, and each is now one new rule:

1. The coverage gap reading *"omega-python emits no fact over a string literal
   or a keyword argument, so aliases, validated field names and config settings
   are not stated"*. **Validated field names are now stated.**
   `@field_validator("name")` emits a `call.function` named `field_validator` on
   span 446-461 carrying `call.arg0 = "\"name\""` and `call.arg0_text = "name"`
   -- the *same span* as the `reference.decorator` the hook rule already keys
   on. New rule `pydantic.model.hook.validates` turns that into an edge. The
   `.md` called this "the single most asked question about a Pydantic model".
2. The closing paragraph *"Deliberately not written: a rule over `call.method`
   named `model_validate`, `model_dump` and friends. omega-python publishes no
   receiver, so the call cannot be attributed to a model."* It publishes one:
   `User.model_validate(payload)` emits `call.method` name=`model_validate`,
   `receiver="User"`. New rule `pydantic.model.use`.

**One claim that looked falsified is not.** `Field(alias="userId", ge=0)` and
`ConfigDict(frozen=True)` still cannot be read -- for a different reason than
before, and it is now a Pack *defect* rather than an absence. See *A field only
the Pack can supply*.

**Counts.** Before: 7 rules, 7 live, 0 collisions, 6 coverage gaps, of which 1
was false and 1 was about to become misleading. After: 9 rules, 9 live, 0
collisions, 8 coverage gaps, all measured. Two `coverage.gaps` sentences were
deleted outright, one was rewritten into the three that are actually true, and
three new ones record the limits of the two new rules. No rule was deleted: the
seven that were there each answer a distinct question and each still matches.

Pydantic has no routes, so the route-identity shape this wave introduced
(`http:{method}:{normalized_route}`) does not apply. Nothing in this file ever
keyed a route by path and byte offset, and `coverage.gaps` never claimed a route
had no URL; the two entities that *are* keyed by byte offset,
`pydantic:model-hook` and `pydantic:model-use`, are keyed that way because a
decorator and a call site have no name of their own, not for want of a URL.

### For the record: what was wrong with the wave-1 file

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

Verified against the emission dump of two hand-written files: a model file with
`class User(BaseModel)`, `model_config = ConfigDict(...)`, four fields, two
`Field(...)` declarations, a `PrivateAttr()`, all five hook decorators, a
`class Admin(User)` and a `BaseSettings` subclass; and a consumer file that
imports those models and calls `User.model_validate`, `User.model_validate_json`,
`User.parse_obj`, `u.model_dump()` and `Admin.model_construct`.

| what it answers | which Pack fact | entity or relation |
|---|---|---|
| Which classes are Pydantic models, and which flavour (model / root model / settings) | `relation.implements` named `BaseModel`, `RootModel`, `BaseSettings`, `GenericModel`, with the host-computed `definition.container` naming the class | entity `PydanticModel` at `pydantic:model:{class}`, attribute `base` |
| Which model extends which model | `relation.implements` whose base is in neither the root set nor a known non-model set, in a file that has an `import.from_module` beginning `pydantic` | entity `PydanticModel` + relation `extends` -> `pydantic:model:{base}` |
| Which fields does this model declare | `definition.field` whose `definition.container` is a class with a Pydantic root base | entity `PydanticField` at `pydantic:field:{path}:{Model.field}` + relation `has_field` from the model |
| Which fields carry an explicit `Field()` / `PrivateAttr()` declaration | `call.function` named `Field`/`PrivateAttr`, span-joined `within` the `definition.field` it initializes and `within` a model `definition.class` | entity `PydanticFieldDeclaration` + relation `configures` -> that field |
| Which models does this model embed (the composition edge, and the one that crosses files) | `type_use.name` inside a `definition.field` inside a model class, name not in the scalar/typing exclusion set | relation `references_model` from `pydantic:field:{path}:{Model.field}` to `pydantic:model:{TypeName}` |
| Which models are explicitly configured | `call.function` named `ConfigDict`, span-joined `within` a model `definition.class` | entity `PydanticModelConfig` + relation `configures` -> the model |
| Which models carry validation / serialization / computed-field hooks, and of which kind | `reference.decorator` named in the seven-hook set, whose `definition.container` is a model class | entity `PydanticModelHook` (attribute `hook`) + relation `configures` -> the model |
| **Which field a validator or serializer validates** (new) | `call.function` named `field_validator`/`field_serializer`/`validator`, `call.arg0` present, `call.arg0_text` the unquoted field name, `enclosing.qname` the owning model | relation `validates` from `pydantic:model-hook:{path}:{start}` to `pydantic:field:{path}:{Model.field}` |
| **Where a model is parsed, dumped or schema'd** (new) | `call.method` named in the 16-name pydantic model API set, with `receiver` joined to a `relation.implements` on a root base anywhere in the view | entity `PydanticModelUse` at `pydantic:model-use:{path}:{start}` (attributes `operation`, `model_name`) + relation `uses_model` -> the model |

### The two new rules, and why each end is reachable

**`pydantic.model.hook.validates`.** omega-python's decorator query captures
`(decorator (call function: (identifier) @decorator.name arguments: ...))`, and
its call query captures that same identifier as `@call.name`, so a decorator
*written with arguments* produces two emissions on one span: a
`reference.decorator` and a `call.function`. That is why the source end can be
`by_canonical_key pydantic:model-hook:{path}:{source.start}` -- `pydantic.model.hook`
mints exactly that key from the `reference.decorator` at the same offset. The
two rules carry the same conditions (brief 3b): `pydantic.model.hook`'s name set
is the seven hooks, this rule's is the three that take a leading field name, a
subset; both require `definition.container` present; both carry the identical
`fact_join_by_field relation.implements` model gate. So the key is always minted
where this rule fires.

The target end is `pydantic:field:{path}:{enclosing.qname}.{call.arg0_text}`.
`pydantic.model.field` keys a field on `{path}:{definition.qname}`, and for a
field in `class User` that renders `User.name`. For the decorator's
`call.function` the ancestor chain is the class alone, so `enclosing.qname` is
`User` and the rendered target is `User.name` -- the same string, and it stays
the same string for a model nested inside another class, where both sides render
`Outer.User.name`. Using `definition.container` instead would have rendered only
`User` and broken the nested case. Keying on `call.arg0` rather than
`call.arg0_text` would have rendered `"name"` with its quote bytes and met
nothing (brief 3l).

The rule emits **no entity**, so it cannot collide with the hook rule's key
(brief 3g); `key_collisions.py` reports nothing.

**`pydantic.model.use`.** The receiver gate is the whole rule: `receiver` is
joined to a `relation.implements` whose own name is a Pydantic root base, which
is `pydantic.model`'s exact match, so `pydantic:model:{receiver}` is minted
wherever this fires. `same_path` is **false** here and only here -- the overlay
runs over the whole view's facts at once (`production.rs:2358`: *"The overlay
runs over the whole view's facts at once: most of its joins and every
canonical-key relation cross artifacts"*), and the normal shape is a model
declared in `models.py` and parsed in `api.py`. The gate is what separates
`User.model_validate(payload)` (receiver is a model class) from `u.model_dump()`
(receiver is a local variable that no `relation.implements` names); both
spellings were measured in the consumer file, and only the first is emitted.

### How a model is recognised without a single Pack field

omega-python emits `relation.implements` spanned on the base-class identifier,
*inside* the `definition.class` span. The host therefore fills that fact's
`definition.container` with the subclass's own name (`overlay.rs:1200-1249`).
The base is the fact's `definition.name`, the subclass is its
`definition.container`, and no join is needed to state *class X is a model whose
base is BaseModel*.

The same built-in is the model gate everywhere else. A `definition.field`, a
`reference.decorator` or a decorator's `call.function` in a class body carries
`definition.container` = the class name, so
`fact_join_by_field(relation.implements, definition.container -> definition.container)`
with a root-base `where` asks *is my owning class a Pydantic model* with no Pack
field on either side. For a fact nested one level deeper -- a `Field()` call
inside a field assignment, a type name inside an annotation -- the container is
the field, so the gate becomes `fact_join_by_span within definition.class`
carrying the same nested join.

### Every canonical key minted, and every key addressed

| key template | minted by | addressed by |
|---|---|---|
| `pydantic:model:{class}` | `pydantic.model`, `pydantic.model.extends` (same kind, hub) | `.model.config`, `.model.extends`, `.model.field`, `.model.field.type`, `.model.hook`, `.model.use` |
| `pydantic:field:{path}:{Model.field}` | `pydantic.model.field` | `.model.field.declaration`, `.model.field.type`, `.model.hook.validates` |
| `pydantic:model-hook:{path}:{start}` | `pydantic.model.hook` | `.model.hook.validates` |
| `pydantic:model-config:{path}:{class}` | `pydantic.model.config` | -- |
| `pydantic:field-declaration:{path}:{Model.field}` | `pydantic.model.field.declaration` | -- |
| `pydantic:model-use:{path}:{start}` | `pydantic.model.use` | -- |

The addressed set is contained in the minted set (brief 3a), and every rule that
addresses a key carries the minting rule's conditions (3b). `pydantic.model`
sorts alphabetically before `pydantic.model.extends`, so where both fire the
richer attribute set (with `base`) is the one that materializes (3g); both mint
the same `PydanticModel` kind, so nothing is lost. `current` is the first entity
output in every rule that uses it, and every attribute is either a host built-in
or a Pack field the match clauses guarantee present -- `receiver` is guarded by
`field_present`, `call.arg0_text` is a `default`-wrapped field that always
resolves -- so no entity is dropped for an unresolvable attribute (3b).
`key_collisions.py` reports nothing.

## A field only the Pack can supply

**omega-python, `call.function` and `call.method`: `call.arg0_text` must not
strip a suffix it did not strip a prefix for.** This is new in this pass, and it
is a *defect*, not an absence. `call.arg0_text` is

    strip_suffix("'", strip_prefix("'", strip_suffix('"', strip_prefix('"', default(arg0, "")))))

-- four independent ops. For a genuine string literal `"name"` that is right and
gives `name`. For a Python **keyword argument**, which arrives in `arg0` whole,
it is destructive; all four rows below are from the dump, not from reasoning:

| written | `call.arg0` | `call.arg0_text` |
|---|---|---|
| `Field(alias="userId", ge=0)` | `alias="userId"` | `alias="userId` |
| `ConfigDict(env_prefix="APP_")` | `env_prefix="APP_"` | `env_prefix="APP_` |
| `model_validator(mode="after")` | `mode="after"` | `mode="after` |
| `ConfigDict(frozen=True)` | `frozen=True` | `frozen=True` |

The trailing quote is removed although the leading one never was, so the value
is neither the source text nor the string. Nothing in a Framework can repair it:
a canonical-key template has no strip at all, `fact_join_by_field` has
`current_strip_prefix` and `join_strip_prefix` and no strip_suffix, and no
clause tests one field against another, so a rule cannot even *detect* that the
value was mangled. The fix belongs in the Pack -- a `strip_suffix` conditioned
on the matching `strip_prefix` having applied, or one `unquote` op in `expr.rs`
-- and it is **not pydantic's alone**: the same four-op spelling is on every
Pack that publishes the canonical call view, and every language whose calls take
named arguments (Python keyword arguments, a JS object literal `{ path: "/x" }`,
Kotlin and Swift argument labels, PHP named arguments) puts a non-quote-leading
value in `arg0`. Reported in `cross_framework_findings`.

Until that lands, five answers stay unstated: the wire alias of a field
(`Field(alias=...)`), its constraints (`ge`, `max_length`), whether a model
validator runs `mode="before"` or `mode="after"`, every `ConfigDict` setting,
and v1's `class Config: extra = "forbid"`.

**Second, still open from the first pass: `qualifier` on omega-python's
`binding.import_alias` and `import.symbol`.** Without it `OverlayFact.external`
is empty for every Python fact and `external_path_matches` is unreachable, which
is what silently killed the wave-1 file's six "live" rules. This is the same
`qualifier` row `OWED.md` item 1 carries for the JS/TS Packs, now measured for
Python; it belongs in item 7a alongside them. This file uses the import join
instead (brief 3i) and needs nothing.

## Still to decide

**`pydantic.model.extends` remains the one judgement call.** A subclass of a
project model (`class Admin(User)`) has no Pydantic root base of its own, so the
precise gate cannot see it. The rule instead requires the file to import
something beginning with `pydantic` and the base name not to be in a 31-entry
non-model exclusion list. In a file that imports pydantic that is usually right,
but `class MyError(SomeBaseError)` in the same file will also be minted as a
`PydanticModel`. The alternatives were both worse: gating on the base being
declared in *the same file* loses the ordinary cross-file case, and dropping the
rule loses model inheritance entirely, which is Pydantic's main composition
mechanism. Deliberately kept, at `confidence: candidate`. Two measured
consequences, both accepted:

- The file gate matches `import.from_module`, so `import pydantic` followed by
  `class X(pydantic.BaseModel)` is not gated in. Measured this pass: that file's
  `relation.implements` does arrive named `BaseModel`, because omega-python
  names a base by its last identifier, so the *root-base* rules are unaffected;
  only `pydantic.model.extends` is.
- `pydantic.model.field.type` targets `pydantic:model:{TypeName}` on a bare
  name, so an annotation naming a project type that is not a model addresses an
  entity nothing mints. The scalar/typing exclusion list removes the common
  cases; a name is all omega-python resolves, and the alternative is losing the
  model-to-model edge altogether.

**The second positional field name of a multi-field validator is not stated.**
`@field_validator("id", "name")` puts `id` in `call.arg0_text` and `name` in
`call.arg1_text`, both clean -- measured. Writing a second rule for it would
also fire on `@validator("name", pre=True)`, where `call.arg1_text` is
`pre=True` and the edge would address a field that does not exist. The only
discriminator is that a string literal's raw `call.arg1` begins with a quote
byte, and a rule's `match` is a conjunction with no disjunction, so telling `"`
from `'` costs two rules for one secondary case. Left as a coverage gap; it
becomes one clean rule the moment the Pack publishes a real unquote (above),
because then "`call.arg1` differs from `call.arg1_text`" would be the test --
which is itself an argument for the Pack fix.

**`@pydantic.field_validator("x")` is not covered.** The attribute spelling
emits `call.method`, not `call.function`, so `pydantic.model.hook.validates`
does not see it. A second rule would double the whole validates path for a
spelling almost nobody writes; recorded as a coverage gap instead.

**`pydantic.model.use`'s name set is 16 pydantic-specific method names.** Per
brief 3f this is a list the Framework chose, not one the Pack constrains --
`call.method` carries whatever was written, so nothing is "deleted" by leaving a
name out, but nothing is covered by it either. `dict`, `json` and `copy`, v1's
generic spellings, are deliberately **not** in it: the receiver gate would admit
them safely, but those names carry no pydantic meaning and the entity would say
nothing the call site does not. `model_dump` and `model_copy` *are* in it
although they are almost always called on an instance, where the receiver gate
excludes them; they cost nothing and they cover `User.model_dump(obj)`.

**Still not statable, and not for want of a call argument: which method
implements a hook.** A decorator's span (446-461) neither contains nor is
contained by the span of the function it decorates (474-514), and no join
relates two disjoint spans. `pydantic.model.hook` therefore keys the hook by its
own offset and relates it to the model that owns it; with this pass it also
names the field it validates, but not the function that does the validating.
That needs a Pack fact spanning the whole `decorated_definition`, or a
`decorated` field on `definition.function` -- neither worth asking for on its
own.
