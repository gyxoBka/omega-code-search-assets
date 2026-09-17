# omega-docker-compose

Language `omega-docker-compose`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

This Pack is not a language. It is the Compose file format, which is YAML with
a schema, and it shares `grammars/omega-yaml` with `omega-yaml`. Read
`pack-design/omega-yaml.md` beside it: everything this Pack deliberately does
*not* state is stated there, over the same bytes, for the same file.

## What it states today

9 templates over 9 query patterns, 13 distinct node types touched.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 5 |
| `references` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config.service` | Config | 1 |
| `definition.config.volume` | Config | 1 |
| `definition.config.network` | Config | 1 |
| `definition.config.secret` | Config | 1 |
| `definition.config.config_object` | Config | 1 |

The five top-level sections of a Compose file are the only things it names.
`entity_family` splits the kind into whole words and the **last** matching one
wins; `service`, `volume`, `network`, `secret` and `object` match nothing, so
in every one of the five the winning word is `config` and the declaration lands
in Config. That is where it belongs: a Compose file is configuration, and these
five are the named objects in it.

Each declaration's span is the whole of its entry — `web:` down to the last
line of the service — so every reference written inside a service lies inside
that service's declaration and `content_builder` gives it that service as its
`owner` without any pattern or field saying so.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 4 |

Four patterns, one kind. A mention's `output_kind` does not survive into the
index — `content_builder` maps it to one of nine occurrence kinds and keeps
the name, the span, the owner, the attribute bag and five named fields, and
throws the kind away. So `reference.compose_network` and
`reference.compose_secret` would be the same fact in the index, distinguished
by nothing. The distinction is carried in the `qualifier` field instead, whose
value is the capture of the key the reference was written under: `depends_on`,
`networks`, `volumes`, `secrets`, `configs`, `links`, `volumes_from`,
`env_file`, `image`, `build`, `context`, `dockerfile`, `service`, `file`,
`source`. It is read from the source at every match, not a literal, and it is
the only place that information can live.

### Regions

None. A service's extent is its declaration's own span.

### Carriers

None. A Compose service has no signature, and the five carried names the host
assembles a signature line from (`visibility`, `type_parameter_shape`,
`parameter_shape`, `return_type`, `modifier`) mean nothing here.

## The boundary: what the grammar offers and the Pack ignores

There is no `grammars/omega-docker-compose/`. The Pack declares
`parser_id = "tree-sitter-yaml"` and parses with `grammars/omega-yaml`, whose
`node-types.json` is the boundary. The earlier version of this document said
the boundary could not be measured; it can, and it is YAML's.

The grammar names 36 named node types. The Pack looks at 13: `document`,
`block_node`, `block_mapping`, `block_mapping_pair`, `block_sequence`,
`block_sequence_item`, `flow_node`, `flow_mapping`, `flow_pair`,
`flow_sequence`, `plain_scalar`, `double_quote_scalar`, `single_quote_scalar`.

Untouched, and right to be untouched:

- `stream`, `comment`, `escape_sequence`, and the scalar subtypes
  `string_scalar`, `integer_scalar`, `float_scalar`, `boolean_scalar`,
  `null_scalar`, `timestamp_scalar` — reached through `plain_scalar`, which is
  where the text is.
- `anchor`, `anchor_name`, `alias`, `alias_name`, `tag`, `tag_handle`,
  `tag_prefix`, `tag_directive`, `yaml_directive`, `yaml_version`,
  `reserved_directive`, `directive_name`, `directive_parameter` — YAML's own
  constructs, not Compose's. `omega-yaml` states every one of them over the
  same file, and this Pack restating them would be Defect K across two Packs.
- `block_scalar` — `command: |` and an inlined script. Compose gives it no
  name, and a name is not a place to put a shell script.

## What is wrong with it

**Seven of 28 templates state the shape of the tree and nothing else.** Three
`structured.entry` templates and one `structured.object_entry` carried fields
named `grandparent_key`, `owner_key`, `parent_key`, `sequence_key`,
`item_key` — the chain of keys above the one being stated. The tree already
holds that, and the host already derives it: a key nested under another lies
inside its span and comes out as the `within:` namespace segment. The patterns
that fed them were the pure form of Defect E: three of them nested
`block_mapping_pair` inside `block_mapping_pair` inside `block_mapping_pair`,
one of them five levels deep through a sequence item, each costing one match
per *tuple* of pairs at that depth in the file. Three more — `value.document`,
`value.object`, `value.array` — were `(document)`, `(block_mapping)` and
`(block_sequence)` captured bare, one match per mapping and per sequence in
every YAML file in the repository, for an emission whose whole content was
"there is a mapping here".

**`value.document` named the file with the file.** `span_capture` was
`compose.document` and no `name` expression was given, so the name defaulted to
the span capture's own source text: every YAML file in the repository was
stored once as a mention named with its entire contents. `value.object` and
`value.array` did the same for every mapping and every sequence at every level
of nesting, so the bytes of a mapping were written again inside every mapping
that contained it.

**Twenty-two of 28 templates were mentions that resolve to nothing.** One
declaration kind existed per top-level section — five altogether — and
everything else was `data.*`, `structured.*` or `value.*`. Every one of them
became `omega.occurrence.reference` (none of the kinds was one of the six
`relation.*` spellings the host knows), so twenty mention kinds arrived in the
index as one undifferentiated kind of fact. The Pack had no `relation.depends`
at all: `depends_on`, the one edge a Compose file exists to declare, was
emitted as `reference.compose_depends_on` and read as a plain reference.

**Two templates named every instance of a construct with one constant string**
(Defect J): `data.compose_environment` was named `"compose_environment"` and
`data.compose_healthcheck` `"compose_healthcheck"`, so every `environment:`
block in the repository collapsed onto one name, and the value went into a
`fields` entry called `environment`, which `mention_fields` does not read and
`pack_attribute_bag` never sees.

**Seventeen `data.*` templates restated what omega-yaml already says.**
`data.compose_service_field`, `data.compose_service_sequence_item`,
`data.compose_port`, `data.compose_profile`, `data.compose_image`,
`data.compose_build`, `data.compose_volume_mount` and the rest are a service's
ordinary keys with their ordinary values. `omega-yaml` runs over the same file
— the host runs every language Pack whose `parser_id` matches — and states each
of them as `definition.config_key` carrying its value. This Pack was writing
the second copy.

**One guard reason was a label** (Defect G): `bounded_structural_semantics_only`.
Of the other three, one said the Pack "intentionally reuses the yaml parser" as
if that were a limitation of Compose, and one was a paragraph about "the generic
bounded structured-path primitive" that no reader could act on.

**The manifest declared `data`** and seventeen templates programmed it, but the
capability was carrying only the duplication above.

**It matched nothing at the document's top level.** Every pattern began at a
bare `block_mapping_pair`, so `(#eq? @_services "services")` was satisfied by a
`services:` key at *any* depth in *any* YAML file — a Helm values file, an
Ansible playbook, a Serverless manifest. A Pack that runs over every YAML file
and has no filename to test needs that anchor to be telling the truth.

## What it should extract

A Compose file answers four questions: *what services does this project run*,
*what does this service depend on*, *what image or Dockerfile does it come
from*, and *what volume, network, secret or config is this*. Everything else
in the file is a setting, and a setting is a YAML key with a YAML value, which
`omega-yaml` states already.

| what | node | emitted as | family |
|---|---|---|---|
| a service | top-level `services:` → `block_mapping_pair` | `definition.config.service` | Config |
| a named volume | top-level `volumes:` → `block_mapping_pair` | `definition.config.volume` | Config |
| a network | top-level `networks:` → `block_mapping_pair` | `definition.config.network` | Config |
| a secret | top-level `secrets:` → `block_mapping_pair` | `definition.config.secret` | Config |
| a config | top-level `configs:` → `block_mapping_pair` | `definition.config.config_object` | Config |
| `depends_on`, `links`, `volumes_from` | scalar in a sequence, or a mapping key, block or flow | `relation.depends`, `qualifier` = the key | depends |
| `networks`, `volumes`, `secrets`, `configs` on a service | same | `relation.depends`, `qualifier` = the key | depends |
| `env_file` | same, or a scalar | `relation.depends`, `qualifier` = `env_file` | depends |
| the long form of a mount or a secret | `source:` inside a sequence item mapping | `relation.depends`, `qualifier` = the outer key | depends |
| `build.context`, `build.dockerfile` | `block_mapping_pair` under `build:` | `relation.depends`, `qualifier` = the key | depends |
| `extends.service`, `extends.file` | `block_mapping_pair` under `extends:` | `relation.depends`, `qualifier` = the key | depends |
| `image` | scalar value of a service's `image:` | `relation.depends`, `qualifier` = `image` | depends |
| `ports`, `environment`, `command`, `healthcheck`, `deploy`, `labels`, `restart`, `profiles`, every other key | — | nothing; `omega-yaml` states it with its value | — |
| the document, the mapping, the sequence, containment | — | nothing | — |

The name of an attachment is taken up to the first `:` —
`first(split(unquote(text), ":"))` — which is what turns
`pgdata:/var/lib/postgresql/data` into the volume `pgdata`, `db:database` into
the service `db`, and leaves a bare name and a file path untouched. That is the
one place a Compose reference has a sigil to strip, and stripping it is what
lets the reference meet the declaration: the old Pack stored the whole mount
string as the name, so no service's volume could ever resolve to the volume it
mounts.

`image:` is deliberately *not* split: the tag and the registry are part of what
the service depends on and part of what a person searches for.

The five section patterns and the four service patterns are all anchored at
`(document (block_node (block_mapping`. That is not containment stated as a
pattern — it is the discriminator that makes the fact true, and §12a of the
brief is the reason: this Pack has no filename and no schema to test, so the
only evidence that a file is a Compose file is that `services:` is a key of the
document itself. Nine patterns, each rooted at `document`, each linear in the
number of services.

## Still to decide

1. **This Pack is a schema overlay wearing a language Pack's clothes.** Compose
   key semantics are exactly what `frameworks/` exists for, and there is no
   `omega-framework-docker-compose`. Left as a language Pack because that is
   what it is installed as and moving it is not one Pack's change; recorded for
   `00-INDEX.md`.
2. Whether a service's attachment to a **network** and its **`depends_on`** on
   another service should really be the same occurrence kind. They are, because
   the host has six relation spellings and none of them is "attaches to"; the
   `qualifier` field is the compromise. If a seventh relation is ever added,
   `networks`/`volumes`/`secrets`/`configs` should move to it.
3. Whether the top-level `name:` (the project name) should be declared. It is
   not, and cannot be: a pattern cannot require a *sibling* `services:` key, so
   declaring a top-level `name:` here would declare the name of every GitHub
   Actions workflow in the repository as a Compose project.
