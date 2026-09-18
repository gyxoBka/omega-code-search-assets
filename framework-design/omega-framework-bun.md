# omega-framework-bun

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

13 overlay rules, 4 detection rules. **13 can match, 0 cannot.**
`key_collisions.py` reports nothing.

(Wave 1 took the file from 20 rules — 10 dead by the audit, 20 of 20 dead in
fact — to 11 live. This second pass takes it to 13, and turns four of the
eleven from `candidate` into `exact`.)

Selector: `framework:bun`. Maturity: `semantic-overlay-full`.
Languages: javascript, typescript, tsx, toml.

### Entities it declares

| entity_kind | rules |
|---|---|
| `BunFile` | 11 |
| `BunConfigFile` | 2 |
| `BunServer` | 2 |
| `BunModule`, `BunProcess`, `BunFileAccess`, `BunResource`, `BunDatabase`, `BunQuery`, `BunTest`, `BunTestHook`, `BunNativeBinding`, `BunNativeLibrary`, `BunConfigTable`, `BunConfigSetting` | 1 each |

### Relations it declares

| relation_kind | rules |
|---|---|
| `uses_resource` | 5 |
| `creates_server`, `registers_test`, `configured_by` | 2 each |
| `depends_on`, `spawns`, `uses_api` | 1 each |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.method` | 4 | yes |
| `call.function` | 5 | yes |
| `import.module` | 1 | yes |
| `call.constructor` | 1 | yes |
| `definition.config_table` | 1 | yes |
| `definition.config_key` | 1 | yes |

Fields read: `definition.name`, `definition.qname`, `path`, `source.start`,
`module.definition.name`, and — new in this pass — `receiver`,
`call.arg0_text`, `call.arg1_text`. The last three are published by
`omega-javascript`, `omega-typescript` and `omega-tsx` on their `call.function`
and `call.method` templates; everything else is a host built-in.

## What was wrong with it

The rules were all live, and the entities were all reachable. What was wrong is
that **the file said where every Bun construct is and almost nothing about
what it is**, because when it was written a call argument and a call receiver
were both unreachable. Both are published now, measured with
`dump_call_emissions` against `packs/omega-typescript` and
`packs/omega-javascript`:

    171-176  call.method  name=serve  receiver=String("Bun")  call.arg0_text=String("{\n  port: 3000, ...")
    361-365  call.method  name=file   receiver=String("Bun")  call.arg0_text=String("./data/input.json")
    512-517  call.method  name=query  receiver=String("db")   call.arg0_text=String("SELECT * FROM users WHERE id = ?")
    599-607  call.function name=describe                      call.arg0_text=String("user service")
    682-688  call.function name=dlopen                        call.arg0_text=String("libsqlite3.so")

Concretely:

1. **Four rules were `candidate` for one reason, and that reason is gone.**
   `bun.server.serve`, `bun.process.spawn` and `bun.filesystem.access` matched
   `serve`, `spawn`, `spawnSync`, `file` and `write` **by member name alone**,
   so `app.serve()`, `child_process.spawn()` and `stream.write()` matched with
   them. The old `.md` argued this out at length under "A field only the Pack
   can supply" and asked for `receiver` on `call.method`. The Packs publish it.
   All three rules now carry `field_equals receiver Bun` and are `exact`; that
   whole section of this document is deleted, and so is the first
   `coverage.gaps` sentence.

2. **Every one of the eleven entities was addressed by byte offset and named
   only by its API.** `bun:file-access:{path}:{start}` said *a Bun file call
   happens here* and nothing about which file; `bun:test:{path}:{start}` said
   *a test is registered here* and not which test; `bun:query:{path}:{start}`
   did not carry the SQL; `bun:native-binding:{path}:{start}` did not name the
   library. Six of the eleven rules now carry the operand as an attribute, and
   two of them promote it to an identity (below).

3. **Two operands were cross-file identities being thrown away.** The file a
   project reads through `Bun.file("./config/app.json")` and the native library
   it opens through `dlopen("libsqlite3.so")` are the same thing when two source
   files name them, and there was no key for either. `BunResource` and
   `BunNativeLibrary` are keyed on `call.arg0_text` and are the only two keys in
   this file that are not per-file or per-site — they are what joins two
   consumers of one resource.

4. **One spelling of the server declaration was not matched at all.**
   `import { serve } from "bun"; serve({ ... })` is a bare `call.function` with
   no receiver, so a receiver-gated rule alone would have *lost* coverage the
   old member-name rule accidentally had. `bun.server.serve-import` gates on the
   `bun` import in the same file instead, and mints the same key space with the
   same kind, so the two spellings are one answer and `key_collisions.py` stays
   quiet.

5. **`coverage.gaps` had one sentence that is now false and one that was vague.**
   The receiver sentence is deleted. "Argument values ... are published as fields
   by no Pack" was true of every kind when written and is now true of exactly
   one: `call.constructor` carries no fields in any JS/TS Pack, which is why
   `new Database("app.sqlite")` still names no database file. The gap now says
   that, and only that.

### What this Framework does *not* get from the route work

The wave brief asks every HTTP framework to key its routes `http:{method}:{normalized_route}`
from `call.arg0_text`. **Bun has no such call.** A Bun route is a quoted key in
an object literal:

```ts
Bun.serve({ routes: { "/api/users": listUsers, "/api/users/:id": handler } });
```

Measured on exactly that file, both `omega-javascript` and `omega-typescript`
emit **nothing at all** for a string-keyed property — not for
`"/api/users": listUsers`, not for `"/api/users/:id": async (req) => ...`, not
for the `"/health"(req) { ... }` method form. (An *identifier*-keyed property
does emit `definition.method` in `omega-javascript`; the quoting is what breaks
it.) The whole routes table arrives as one blob in the `serve` call's
`call.arg0_text` and there is no fact under it to match. So there is no
`http:` key space here, no `route` attribute, and no route-to-handler edge —
writing one would mean inventing a fact. This is the first `coverage.gaps`
entry, and the first item under **A field only the Pack can supply**.

## What it states now

Every rule mints `bun:file:{path}` (`BunFile`) itself, and the only other
shared keys — `bun:config-file:{path}` and `bun:server:{path}:{start}` — are
minted by both rules that address them. No relation end addresses a key no rule
mints, and no key template carries two entity kinds.

| what it answers | which Pack fact | which entity or relation |
|---|---|---|
| Which files use Bun, and which built-in module each one pulls in | `import.module` named `bun`, `bun:ffi`, `bun:jsc`, `bun:main`, `bun:sqlite`, `bun:test`, `bun:wrap` | `BunFile` `bun:file:{path}`, `BunModule` `bun:module:{name}`, `depends_on` |
| Where **Bun's** HTTP server is declared (not any `.serve()`) | `call.method` `serve` with `receiver` = `Bun` | `BunServer` `bun:server:{path}:{start}`, `creates_server` from the file |
| ... and the same declaration written as a named import | `call.function` `serve` + join to `import.module` `bun` in the same path | the same `BunServer` key space |
| Where the project starts a child process, **and the argv it starts** | `call.method` `spawn`/`spawnSync`, `receiver` = `Bun`, `call.arg0_text` | `BunProcess` `bun:process:{path}:{start}` with attribute `command`, `spawns` from the file |
| Where the project reads or writes a file through Bun | `call.method` `file`/`write`, `receiver` = `Bun` | `BunFileAccess` `bun:file-access:{path}:{start}`, `uses_resource` from the file |
| **Which file on disk that is**, across every source file that names it | `call.arg0_text` of the same call | `BunResource` `bun:resource:{call.arg0_text}`, `uses_resource` from the access site |
| Where a SQLite database is opened | `call.constructor` `Database` + join to `import.module` `bun:sqlite` | `BunDatabase` `bun:database:{path}:{start}`, `uses_resource` from the file |
| Where the project runs SQL, **and what SQL it runs** | `call.method` in the bun:sqlite statement set + the `bun:sqlite` join, `call.arg0_text` | `BunQuery` `bun:query:{path}:{start}` with attribute `sql`, `uses_api` from the file |
| Every suite and case the runner collects, **under its registered title** | `call.function` `describe`/`it`/`test` + the `bun:test` join, `call.arg0_text` | `BunTest` `bun:test:{path}:{start}` with attribute `title`, `registers_test` from the file |
| What runs around a test case | `call.function` `beforeAll`/`beforeEach`/`afterAll`/`afterEach` + the `bun:test` join | `BunTestHook` `bun:test-hook:{path}:{start}`, `registers_test` from the file |
| Where the project crosses into native code | `call.function` in the bun:ffi set + the `bun:ffi` join | `BunNativeBinding` `bun:native-binding:{path}:{start}` with attribute `operand`, `uses_resource` from the file |
| **Which native library it loads**, across every file that opens it | `call.function` `dlopen`/`linkSymbols`, `call.arg0_text` non-empty, + the `bun:ffi` join | `BunNativeLibrary` `bun:native-library:{call.arg0_text}`, `uses_resource` from the file |
| Which areas of the runtime `bunfig.toml` configures | `definition.config_table` under `**/bunfig.toml` | `BunConfigTable` `bun:config-table:{path}:{table}`, `configured_by` from `BunConfigFile` |
| Every setting `bunfig.toml` states, qualified by its table | `definition.config_key` under `**/bunfig.toml` | `BunConfigSetting` `bun:config-setting:{path}:{definition.qname}`, `configured_by` from `BunConfigFile` |

Two questions are new to the graph with this pass — *which files share a data
file* and *which native libraries does this project load* — and six that could
previously be answered only as "something happens at byte 361" now come back
with the operand: the path, the argv, the SQL, the test title, the library.

Where an operand is used as an **identity** rather than an attribute
(`BunResource`, `BunNativeLibrary`), the rule carries
`field_present call.arg0_text`. That clause is not vacuous — `call.arg0_text`
is a published field, not a host built-in (brief §3e) — and `field_present`
rejects the empty string, which is what the Pack's `default` yields for a call
with no arguments. Without it a zero-argument call would mint `bun:resource:`
and every such call in the repository would be one entity. Where the operand is
only an attribute, there is no such guard, deliberately: `stmt.all()` must stay
in the graph with an empty `sql` rather than be dropped.

## A field only the Pack can supply

**Pack: `omega-javascript`, `omega-typescript`, `omega-tsx`. Kind: a fact for a
string-keyed object-literal property.**

This is Bun's route table, and it is the one thing this Framework cannot state:

```ts
Bun.serve({ routes: { "/api/users": listUsers, "/api/users/:id": handler } });
```

Measured: no emission of any kind for those two lines, in either Pack.
`omega-javascript` has `(pair key: (property_identifier) value: (function))`
and emits `definition.method`; `omega-typescript` emits `definition.method`
only for the shorthand method form. A **quoted** key emits nothing in either,
whether the value is an identifier, an arrow or a method body.

Neither of the first two options in brief §2 reaches it. There is no fact to
read a built-in name off. No join reaches it either: `span_capture` for
`call.method serve` is the six bytes of the `serve` token, so nothing about the
route table is inside the call's span, and the only fact that does contain both
— `definition.variable server`, spanning `server = Bun.serve({...})` — covers
every route in the table equally and could not tell them apart if it did
(brief §3j, second idiom, and its stated limit).

What would fix it is one template: `definition.config_key`, or a
`definition.route_key`, for `(pair key: (string) value: _)`, with the key text
unquoted and the value's last identifier segment as `call.last_arg_name` is. It
is not this Framework's alone — every JS framework with a config object or a
handler map (Vite's `resolve.alias`, Webpack's loaders, Jest's `moduleNameMapper`)
is blind to the same construct.

**Second: `call.constructor` carries no fields.** In all three JS/TS Packs the
canonical call view (`call.arg0`, `call.arg0_text`, `receiver`, ...) is on
`call.function` and `call.method` only. So `new Database("app.sqlite")` names no
database file, and neither does `new Pool(connectionString)` or
`new Worker("./w.ts")` for any other JS framework. The constructor template's
`span_capture` is the `Database` identifier alone, so no span join reaches the
argument list. Adding the same field block that `call.function` already carries
would cost nothing new conceptually and would light up every JS framework that
constructs a client.

**Third, unchanged from wave 1: `omega-toml` publishes a scalar's value as an
attribute**, and an attribute is write-only to the overlay (brief §3a), so
`bun:config-setting` names `install.registry` but cannot say what registry.
That is already `OWED.md`'s collected attribute→field Pack change for
omega-yaml/omega-json; omega-toml belongs on the same list.

## Still to decide

- **`bun:resource:{call.arg0_text}` is keyed on the operand as written**, which
  means `./data/app.json` written in `src/a.ts` and `../data/app.json` written
  in `src/lib/b.ts` are two entities although they are one file, and
  `Bun.file(configPath)` mints a resource named `configPath`. The alternative —
  no resource entity, only a `resource` attribute on the access site — answers
  strictly less and joins nothing. Kept as is: an over-split identity is
  recoverable by a consumer, an absent one is not. A `normalize_path` template
  op (the path analogue of `normalize_route`) would settle it.
- **`bun.ffi.library` matches `linkSymbols` as well as `dlopen`.** `dlopen`'s
  first argument is a library path; `linkSymbols`' is a symbol map, so that
  spelling mints a `BunNativeLibrary` named after an object literal. It is kept
  because both are "the project bound to something native here" and because
  brief §3f is explicit that dropping a value from a list is deleting an answer.
  If the noise matters, `dlopen` alone is the honest narrowing.
- **`path_glob: "**/*.*s*"`** is unchanged and still the JavaScript-family
  filter: `glob_here` implements no braces (§3c), and `**/*.*s` would exclude
  `.tsx`/`.jsx`. The looser glob also admits `.sh`, `.rs` and `.css`, which is
  harmless — no such Pack emits `call.method` with `receiver` = `Bun` or
  `import.module` named `bun:test`. A `path_extension_in` clause would be the
  honest fix and does not exist.
