# omega-framework-bun

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

11 overlay rules, 4 detection rules. **11 can match, 0 cannot.** (Was 20 rules,
10 of them dead by the audit and, as measured below, 20 of 20 dead in fact.)

Selector: `framework:bun`. Maturity: `semantic-overlay-full`.
Languages: javascript, typescript, tsx, toml.

### Entities it declares

| entity_kind | rules |
|---|---|
| `BunFile` | 9 |
| `BunConfigFile` | 2 |
| `BunModule`, `BunServer`, `BunProcess`, `BunFileAccess`, `BunDatabase`, `BunQuery`, `BunTest`, `BunTestHook`, `BunNativeBinding`, `BunConfigTable`, `BunConfigSetting` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_resource` | 3 |
| `registers_test` | 2 |
| `configured_by` | 2 |
| `depends_on`, `creates_server`, `spawns`, `uses_api` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 4 | yes |
| `call.function` | 3 | yes |
| `import.module` | 1 | yes |
| `call.constructor` | 1 | yes |
| `definition.config_table` | 1 | yes |
| `definition.config_key` | 1 | yes |

Clause vocabulary in use: `fact_kind` x11, `path_glob` x11, `field_in` x7,
`fact_join_by_field` x5, `field_equals` x2.

Fields read: `definition.name`, `definition.qname`, `path`, `source.start`,
`module.definition.name` — all of them built-ins or a joined fact's built-in.
The file asks no Pack for a published field.

## What was wrong with it

The audit reported 10 of 20 rules dead. The true number was **20 of 20**: not
one rule could match anything in a JavaScript or TypeScript file.

1. **Ten rules were keyed to kinds no Pack emits**, all of them the old
   generator's private ECMAScript spellings:
   `reference.ecmascript_root_member_call_context` (2),
   `data.ecmascript_root_member_object_identifier_context` (3),
   `data.ecmascript_root_member_string_argument_context` (1),
   `reference.ecmascript_root_member_context` (1), `call.target_candidate` (2),
   `import.target_candidate` (1). Those are the rules the audit named.

2. **The other ten matched `call.member`, which no JavaScript or TypeScript
   Pack emits either.** `call.member` is emitted by exactly three Packs —
   `omega-c`, `omega-cpp`, `omega-c-sharp`. `omega-javascript`,
   `omega-typescript` and `omega-tsx` emit `call.function`, `call.method` and
   `call.constructor`. The audit calls such a rule live because *some* Pack
   emits the kind; for a JavaScript framework it is dead. This is the one
   finding here that is not this Framework's problem alone: the audit's
   liveness test is per-repository, not per-language, and a framework declaring
   `host.languages` can be keyed to a kind none of those languages emits and
   still be reported live.

3. **All ten of those also carried `external_path_matches`**, `package: "bun"`
   / `"bun:sqlite"` / `"bun:test"`. `OverlayFact::external` is filled from
   `external_environment`, which reads `binding.target_hint`; the JS/TS Packs
   publish `target` and `module` as *attributes* on `binding.import_alias`, so
   JS/TS facts carry no `external` at all (`OWED.md` item 7a, brief §3c). Every
   one of those clauses was false regardless of the kind.

4. **Six rules read `call.arg0`**, a field no Pack publishes, as an entity
   attribute. Per brief §3b an unresolvable attribute expression drops the
   entity and leaves the relation rendering its ends, so even had the kind been
   right those six would have emitted an edge into nothing.

5. **Sixteen of the twenty relations were self-loops.** `bun.api.write` minted
   `bun:filewrite:{path}:{source.start}` and then emitted `uses_resource` from
   `current` — which is that same entity, `emit()` having set `own_key` from
   the rule's first entity output — to `by_canonical_key` of the identical
   template. The comment claimed an "enclosing-symbol uses edge"; there is no
   enclosing symbol anywhere in the rule. Sixteen rules stated *X uses X*.
   `bun.source-authored.serve-fetch-handler` was the seventeenth bad edge: its
   target was `by_field value_identifier`, a raw identifier rendered as a
   canonical key that no rule in any file mints.

6. **Per-spelling duplication.** `bun.api.spawn` and `bun.api.spawnsync` were
   two rules differing in one literal; `bun.generic-api-call.bun` and
   `bun.generic-dependency.bun` were the generator's catch-alls, restating
   "there is a call" and "there is an import" with no framework meaning at all.

Deleted outright, rather than ported: the two generic catch-alls (they restate
their input), `bun.test.assertion-api` (an `expect` site per assertion adds
volume, not an answer, once the test file itself is in the graph),
`bun.api.listen` / `bun.api.connect` (`Bun.listen`/`Bun.connect` are TCP
sockets, and `listen` and `connect` as bare member names with no receiver are
almost entirely false positives), `bun.env` and the three `Bun.serve` handler
rules (nothing states them — see **A field only the Pack can supply**).

## What it states now

Every rule mints `bun:file:{path}` (`BunFile`) itself, so no relation end
addresses a key another rule might not have created; the only other shared key,
`bun:config-file:{path}` (`BunConfigFile`), is minted by both rules that
address it. `key_collisions.py` reports nothing: no key template carries two
kinds.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files use Bun, and which built-in module each one pulls in | `import.module` named `bun`, `bun:ffi`, `bun:jsc`, `bun:main`, `bun:sqlite`, `bun:test`, `bun:wrap` | `BunFile` `bun:file:{path}`, `BunModule` `bun:module:{name}`, `depends_on` |
| Where the HTTP server is declared | `call.method` named `serve` | `BunServer` `bun:server:{path}:{start}`, `creates_server` from the file |
| Where the project starts a child process | `call.method` named `spawn`/`spawnSync` | `BunProcess` `bun:process:{path}:{start}`, `spawns` from the file |
| Where the project reads or writes a file through Bun | `call.method` named `file`/`write` | `BunFileAccess` `bun:file-access:{path}:{start}`, `uses_resource` from the file |
| Where a SQLite database is opened | `call.constructor` named `Database` joined to an `import.module` `bun:sqlite` in the same path | `BunDatabase` `bun:database:{path}:{start}`, `uses_resource` from the file |
| Where the project runs SQL | `call.method` in the bun:sqlite statement set, joined to the `bun:sqlite` import | `BunQuery` `bun:query:{path}:{start}`, `uses_api` from the file |
| Every suite and case the Bun test runner collects | `call.function` named `describe`/`it`/`test`, joined to the `bun:test` import | `BunTest` `bun:test:{path}:{start}`, `registers_test` from the file |
| What runs around a test case | `call.function` named `beforeAll`/`beforeEach`/`afterAll`/`afterEach`, joined to the `bun:test` import | `BunTestHook` `bun:test-hook:{path}:{start}`, `registers_test` from the file |
| Where the project crosses into native code | `call.function` in the bun:ffi set, joined to the `bun:ffi` import | `BunNativeBinding` `bun:native-binding:{path}:{start}`, `uses_resource` from the file |
| Which areas of the runtime `bunfig.toml` configures | `definition.config_table` under `**/bunfig.toml` | `BunConfigTable` `bun:config-table:{path}:{table}`, `configured_by` from `BunConfigFile` |
| Every setting `bunfig.toml` states, qualified by its table | `definition.config_key` under `**/bunfig.toml` | `BunConfigSetting` `bun:config-setting:{path}:{definition.qname}`, `configured_by` from `BunConfigFile` |

`bunfig.toml` is new coverage: Bun's own configuration file was not read at all
before, and `omega-toml` states it as `definition.config_table` plus
`definition.config_key`, with the host's `definition.qname` already giving
`install.registry` without a join or a Pack field.

The five joins are all `fact_join_by_field` on `path`, the shape
omega-framework-node-js established: *this call is in a file that imports that
module*. It is the only evidence available that a Bun-named API call is Bun's,
and it is why the `bun:sqlite`, `bun:test` and `bun:ffi` rules are `exact`
while the four `Bun.*` global rules are `candidate`.

## A field only the Pack can supply

**Pack: `omega-javascript`, `omega-typescript`, `omega-tsx`. Kind:
`call.method`. Field: `receiver`.**

Bun's headline APIs are properties of a global: `Bun.serve`, `Bun.spawn`,
`Bun.file`, `Bun.write`, `Bun.password.hash`. The Packs capture
`(call_expression function: (member_expression property: (property_identifier)
@call.method))` and emit the property name alone, so the overlay sees `serve`
and cannot tell `Bun.serve(...)` from `app.serve(...)`. Four rules here are
`candidate` for that reason and nothing else.

Neither of the first two options in brief §2 reaches it. No built-in name
carries it: `definition.name` is the member, `definition.container` and
`enclosing.qname` are the *enclosing declarations*, not the receiver of the
call. No span join reaches it either: `span_capture` for `call.method` is the
`property_identifier` node, and the receiver is its sibling inside the
`member_expression`, a disjoint span that no `definition.*` fact covers, so
`fact_join_by_span` with `same` or `within` has nothing to bind.

The host already expects this field. `facts_of_surface`
(`overlay.rs:1204-1215`) resolves a construct's external identity from
`fields["receiver"]`, falling back to `object` and `call_root`, paired with
`fields["member"]`. The JS/TS Packs publish none of the three, so that whole
path is dead for JavaScript — one field on one template would light it up for
every JS framework, not only this one.

A second, smaller case: **`omega-typescript` emits no fact for an object
literal property.** `omega-javascript` has the `(pair key: ... value:
function)` query and emits `definition.method`, but the TypeScript and TSX
Packs do not, and Bun servers are written in TypeScript. That is what makes
`Bun.serve({ fetch: handleRequest })` unanswerable: even in JavaScript the
`fetch` property is a `definition.method` with no stated relation to the
`serve` call, whose span is one token.

## Still to decide

- **The four `Bun.*` global rules are matched on member name alone.** `serve`,
  `spawn`, `spawnSync`, `file` and `write` will also match `app.serve()`,
  `child_process.spawn()`, `stream.write()`. They are kept because the overlay
  runs only on projects the detector has already identified as Bun, because
  §3f says narrowing a value list is a deletion and every value dropped is an
  answer deleted, and because the alternative is that the Bun runtime's
  principal APIs are not in the graph at all. They carry
  `confidence: "candidate"` and the `coverage.gaps` entry says so. If
  `receiver` ever lands on `call.method`, these four become `exact` with one
  clause each and no other change.
- **`path_glob: "**/*.*s*"`** is the JavaScript-family filter. `glob_here`
  implements no braces (§3c), so `**/*.{js,ts}` would be a literal byte match;
  `**/*.*s` — the spelling omega-framework-node-js uses — excludes `.tsx` and
  `.jsx`, which the tsx Pack does emit for. The looser glob also admits `.sh`,
  `.rs` and `.css`, which is harmless here: no such Pack emits
  `call.constructor` named `Database` or `import.module` named `bun:test`.
  A `path_extension_in` clause would be the honest fix and does not exist.
- **`bunfig.toml` setting values are unreadable.** `omega-toml` publishes a
  scalar's value as an *attribute*, and an attribute is write-only to the
  overlay (§3a). So `bun:config-setting` names `install.registry` but cannot
  say what registry. That is already `OWED.md`'s collected Pack change
  (attribute -> field) for omega-yaml/omega-json; omega-toml belongs on the
  same list.
