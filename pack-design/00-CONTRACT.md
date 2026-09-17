# What a Language Pack is, and what the host does with it

This is the contract a Pack is written against. It is taken from the code
that reads a Pack, not from intent: every rule below names the function
that enforces it.

A Pack answers one question per capture: *what does this piece of syntax
mean?* It never parses, never resolves, never decides what an agent sees.
It states facts about spans. The host turns those facts into declarations,
regions and mentions, and the resolver turns mentions into edges.

---

## 1. The unit a Pack produces

One match of one query pattern, run through one template, produces a
`NormalizedEmission`:

```
capability   which of the Pack's declared abilities this fact belongs to
kind         the output_kind string -- see §3, this is a protocol, not a label
span         the bytes the fact is about
name         the text the fact names
attributes   a typed bag the Pack fills
fields       values the Pack computed
test_signal  set only for the tests capability
```

`crates/omega-ingest/src/pack/runtime.rs` builds it. `content_builder.rs`
consumes it.

---

## 2. Capabilities

A capability is what the Pack claims it can state. The runtime rejects a
manifest that declares a capability with no template
(`Rules("manifest capabilities have no executable template program")`),
and a coverage guard that names a capability the manifest does not declare.

| capability | IR kind it carries |
|---|---|
| `definitions` | definition |
| `references` | reference |
| `calls` | call |
| `imports` | import, import_binding |
| `bindings` | binding |
| `scopes` | scope |
| `types` | type, type_shape |
| `modules` | module |
| `data` | data, external_semantic_candidate, semantic_hint |
| `tests` | test |
| `implements`, `value_origins`, `config_consumers` | relation facts |

`legacy_capability_from_ir_kind` in `pack/runtime.rs` is the mapping.

---

## 3. `output_kind` is a protocol

**The host reads meaning out of substrings of the kind.** This is the single
most important thing to know when writing a Pack, and nothing in the file
format says it. A kind named carelessly produces a fact of the wrong sort,
silently.

### 3.1 Is it a declaration?

`content_builder::is_definition_kind`:

- **not** a declaration if the kind starts with `call.`, `reference`,
  `type_use.`, `value_`, or `import`;
- otherwise it **is** a declaration if it contains `definition`, or ends
  with `.type`, `.function`, `.class`, `.method`, `.trait`.

### 3.2 What family does the declaration belong to?

`content_builder::entity_family`, first match wins:

| the kind contains | family |
|---|---|
| `test` | Test |
| `type`, `class`, `trait`, `struct`, `enum`, `alias` | Type |
| `function`, `method`, `callable` | Callable |
| `config` | Config |
| anything else | Value |

A kind containing two of these words gets the first row that matches, not
the one the author meant.

### 3.3 Is it a region?

`is_scope_kind`: the kind is exactly `scope` or starts with `scope.`.

### 3.4 Is it a carrier?

`is_carrier_kind`: the kind ends with `_candidate`.

A carrier is not a fact of its own. It attaches an attribute to the
declaration that occupies the same span:

```
definition.visibility_candidate  ->  leaf `visibility_candidate`
                                 ->  attribute `visibility`
                                 ->  read as omega.pack.visibility
```

`carried_name` takes the last dot-segment and strips `_candidate`. This is
how a declaration acquires its visibility, its parameter shape, its return
type -- everything a card's signature is built from.

### 3.5 Otherwise it is a mention

Everything that is neither a declaration nor a region becomes an occurrence,
and its sort is chosen by substring again:

| the kind | occurrence |
|---|---|
| starts with `relation.implements` | implements |
| starts with `relation.tests` | tests (or a convention candidate, if the test signal says so) |
| starts with `relation.depends` | depends |
| starts with `relation.config` | config |
| starts with `relation.data` | data |
| starts with `relation.handles` | handles |
| contains `call` | call |
| contains `import` or `export` | binding |
| anything else | reference |

---

## 4. What the host throws away

`pack/emission_roles.rs` drops an emission before it reaches the IR when
its capability and kind say it names nothing:

- `scopes` + `control_flow.*`, `control_context.*`, `scope_context.*`
- `data` + `literal.*`
- `bindings` + `binding.mutable_specifier`, `binding_pattern_shape.*`

**But two of those are load-bearing before they are dropped.** The spans of
`literal.*` and `control_flow.*` are collected first, and any role boundary
sitting exactly on one of them is dropped as being that literal or that
form spelled as its own text. Removing them from a Pack does not save work;
it lets those role boundaries through. Measured: 1 925 extra mentions on
one repository.

The rest -- `control_context.*`, `scope_context.*`, `binding_pattern_shape.*`,
`binding.mutable_specifier` -- are read by nothing and should not be emitted.

---

## 5. What one match may do

The runtime gathers **candidate templates from the captures a single match
binds** and runs each of them (`runtime.rs`, `candidate_templates`). One
pattern can therefore feed many templates.

A template is skipped, not failed, when a capture it needs is unbound: its
name expression, its span capture, or any attribute expression. This is
what lets one pattern carry several optional facts -- and what makes a
pattern with an optional child safe only when each template's
distinguishing capture is among its name, span or attributes.

**Consequence for authoring: one pattern per node, not one per question.**
Asking for the same node from five patterns is five matches over the same
tree for facts one match could carry.

---

## 6. What a Pack must not do

- **No language branch in the host.** A Pack states facts; the host has no
  per-language code and must not need any.
- **No predicate-free duplication.** Two patterns that match the same nodes
  and differ only in capture names are one pattern.
- **No emitting what §4 drops** (except the two marker families).
- **No claiming a capability with no template**, and no coverage guard for
  a capability that is not declared.

---

## 7. What a Pack is judged by

For each language, the boundary of responsibility is the grammar's own node
types. A Pack is complete when every node type that carries meaning for an
agent's question is stated as a fact of the right sort, and nothing else is
stated at all.

The per-Pack files beside this one record, for one language:

1. what the Pack states today, by capability and kind;
2. which node types of the grammar it never looks at;
3. which of those carry meaning and must be covered;
4. what is emitted that nothing reads.
