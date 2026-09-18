# omega-dockerfile

Language `omega-dockerfile`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

16 templates over 18 query patterns, 29 distinct node types touched.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 11 |
| `references` | yes | 5 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.build_arg` | Value | 2 |
| `definition.build_stage` | Value | 1 |
| `definition.config_label` | Config | 1 |
| `definition.config_port` | Config | 1 |
| `definition.config_user` | Config | 1 |
| `definition.config_volume` | Config | 2 |
| `definition.config_workdir` | Config | 1 |
| `definition.environment_variable` | Value | 1 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `reference.build_arg` | reference | 1 |
| `reference.build_stage` | reference | 2 |
| `reference.container_image` | reference | 1 |
| `reference.copied_path` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 48 node types. The Pack looks at 29 of them.

Untouched:

- `cmd_instruction`, `entrypoint_instruction`, `shell_instruction` -- an
  argument vector, not a name (see the guard). Their shell form reaches the
  bash injection through `shell_command`, which the Pack does capture.
- `env_instruction`, `label_instruction`, `onbuild_instruction` -- containers
  whose children the Pack matches directly. `ONBUILD COPY . /app` is reached by
  the `copy_instruction` pattern with no pattern of its own, which is the whole
  point of not stating containment.
- `image_tag`, `image_digest` -- deliberately not part of the image reference's
  name, so that a reference is spelled the way a stage declaration is.
- `cross_build_instruction`, `maintainer_instruction`, `stopsignal_instruction`
  -- the value is an anonymous token in this grammar and cannot be captured.
- `healthcheck_instruction` -- its `CMD` child is reached through
  `shell_command`; its own `--interval=` options state nothing nameable.
- `comment`, `escape_sequence`, `line_continuation`, `heredoc_end`,
  `heredoc_line`, `heredoc_marker`, `source_file` -- punctuation, the file node,
  and the heredoc internals the injection consumes whole.

## What is wrong with it

This is written against the Pack as it stood before this rewrite: **13 templates
over 16 patterns, 5 guards**, declaring `bindings`, `data`, `definitions` and
`references`.

**One declaration in the whole Pack, and twelve mentions with nothing to
resolve against.** `definition.docker_stage` was the only kind that passed
`is_definition_kind`. Everything else -- the base image, the workdir, the
exposed port, the label, the copied path, the user, the mount -- was a
`data.docker_*` mention, and a mention resolves against declarations. A
Dockerfile declares three kinds of name that the same file writes down again
(a stage, a build argument, an environment variable) and the Pack declared one
of them.

**The two `binding.*` kinds declared nothing.** `binding.docker_arg` and
`binding.docker_env` are the case §12b of the brief names: the `bindings`
capability exists, but `binding.foo` fails `is_definition_kind`, so ARG and ENV
arrived as plain references. Every `${NODE_VERSION}` in the file referred to a
declaration the Pack never made -- and it never made the reference either,
because the one template that read an expansion, `reference.docker_expansion`,
had been swept out before this rewrite along with its pattern.

**The stage reference could never match the stage declaration.**
`reference.docker_stage_from` was named with a `capture_ref` on the whole
`param` node, whose text is `--from=builder`. The declaration it was meant to
reach is named `builder`. Two templates, on `copy_instruction` and
`add_instruction`, both wrong the same way -- and `ADD` has no `--from` flag at
all, so the second one matched nothing on any Dockerfile ever written.

**`data.docker_mount` named every mount in every repository `mount`.** The
pattern was `(mount_param name: (_) @docker.mount.name value: (_) @docker.mount.value)`.
The `name:` field of `mount_param` is the anonymous keyword `mount` itself, so
the name expression evaluated to the constant string `mount` on every match:
Defect J spelled structurally rather than with a `literal`, which is why the
sweep that closed J did not see it. The `value:` field made it worse --
measured against the pinned grammar, `value: (mount_param_param)` binds only
`type=cache` out of `type=cache,target=/root/.npm,from=base`, because this
grammar puts the separating `,` into the same field. So the one thing in a
mount that names something, `from=`, was unreachable by the pattern that
existed for it.

**Nine of thirteen names could not survive the host's own filter.**
`is_resolvable_name` requires a mention's spelling to begin with a letter, `_`,
`$` or `@`. `data.docker_workdir` was named `/app`, `data.docker_copy_path`
`/app/dist`, `data.docker_add_path` `/tmp/`, `data.docker_exposed_port` `8080`.
Every one of them was counted as an unnameable spelling and dropped. The Pack
spent a pattern and an emission per instruction to say nothing at all.

**Five guards, and not one of them was about Dockerfile.** The first was the
generic highlight-baseline sentence -- "Highlight captures provide lexical/role
evidence only" -- and the other four were generator prose: "requires
repository-local file resolution", "requires bounded static-value propagation",
"remain intentionally unmaterialized under the repository secret-safety
policy", "remain runtime semantics". Three of the four named `bindings`, `data`
and `definitions` together, which is every capability the Pack had, so they
said nothing that distinguished one answer from another.

**Two nvim-treesitter highlight patterns survived.** `((heredoc_block
(heredoc_line) @string) (#set! priority 90))` and `(expose_instruction
(expose_port) @number @docker.expose.port)` -- the `@string` and `@number`
captures are a colour scheme's, and `@string` was read by no template. Both are
gone; the expose port keeps one capture under a name of the Pack's own.

**Declared capabilities the templates did not need.** The manifest declared
`bindings` and `data`; after this rewrite neither is programmed, and the kinds
that used them said nothing a question reached. The manifest also carried
`source = "Omega clean production normalization"`, the generator's own phrase,
in place of the repository URL.

## What it should extract

A Dockerfile says how one image is built. The questions asked of it are: what
does this image build on, what stages does it have and which stage does this
one copy from, what build arguments and environment variables does it define,
what does it take out of the repository, what does it expose, where does it
work and who does it run as.

| what | node | emitted as | family |
|---|---|---|---|
| a named build stage | `from_instruction` via `as: image_alias` | `definition.build_stage`, carrying `base_image` | Value |
| the image a FROM builds on | `image_spec` via `name: image_name` | `reference.container_image` | occurrence |
| a build argument with a default | `arg_instruction` via `name:`, `default:` | `definition.build_arg`, carrying `default` | Value |
| a build argument with none | `arg_instruction` with `!default` | `definition.build_arg` | Value |
| an environment variable | `env_pair` via `name:`, `value:` | `definition.environment_variable`, carrying `value` | Value |
| a label | `label_pair` via `key:`, `value:` | `definition.config_label`, carrying `value` | Config |
| `COPY --from=<stage>` | `copy_instruction` via `param`, `#match?` | `reference.build_stage`, `--from=` stripped | occurrence |
| `RUN --mount=...,from=<stage>` | `mount_param` via `mount_param_param`, `#match?` | `reference.build_stage`, `from=` stripped | occurrence |
| a path COPY or ADD reads | `copy_instruction`, `add_instruction` via `path` | `reference.copied_path` | occurrence |
| `${NAME}` and `$NAME` | `expansion` via `variable` | `reference.build_arg` | occurrence |
| the working directory | `workdir_instruction` via `path` | `definition.config_workdir` | Config |
| the account the image runs as | `user_instruction` via `user:` | `definition.config_user` | Config |
| a port the image exposes | `expose_instruction` via `expose_port` | `definition.config_port` | Config |
| a volume mount point | `volume_instruction` via `path` or `json_string` | `definition.config_volume` | Config |
| a RUN, CMD or ENTRYPOINT shell body | `shell_command`, `heredoc_block` | bash injection | -- |
| CMD/ENTRYPOINT/SHELL exec form | `json_string_array` | nothing | -- |
| STOPSIGNAL, MAINTAINER, cross-build | -- | nothing | -- |
| the file, comments, continuations | `source_file`, `comment`, `line_continuation` | nothing | -- |

Three things this buys that the old Pack did not have. A `COPY --from=builder`
is now spelled `builder`, which is what the stage is called, so the reference
and the declaration are the same string. A `${NODE_VERSION}` is now spelled
`NODE_VERSION`, which is what the `ARG` is called. And the image settings that
an agent audits -- who the image runs as, what it exposes, where it works, what
it mounts -- are declarations named by their value, so `root` and `5432` are
names that can be searched for, where before they were mentions the host
discarded for not beginning with a letter.

The `config` word is deliberate in five kinds and deliberately absent from
three. `definition.config_user` splits to `[definition, config, user]`, the
last matching word is `config`, and the host files it under Config: an image
setting. `definition.build_stage`, `definition.build_arg` and
`definition.environment_variable` match no family word and fall to Value, which
is right -- they are names other spans refer to, not settings.

## The one thing the Pack cannot state, and why

**A Dockerfile has no node for a stage's extent.** Every instruction is a
direct child of `source_file`; a `FROM ... AS builder` declaration ends at the
end of its own line, and the twenty instructions that belong to that stage are
its siblings, not its children. The host gives a mention its owner by span
containment (`content_builder.rs`, `enclosing`), and `Relation::admit_claim`
refuses a claim whose subject has no contextual owner
(`MissingContextualSource`). So a `COPY --from=builder` inside stage `runtime`
can never carry `runtime` as the source of an edge, and there is no attribute
the Pack could set instead: `omega.pack.source_name` would have to come from a
capture, and no query over a flat grammar can reach a preceding sibling.

This is why the stage and variable references here are plain `reference.*`
kinds and not `relation.data`. A `relation.data` would be built, found to have
no source, and dropped -- the same silent nothing omega-docker-compose's
`relation.depends` produced before wave 11, one step further down the pipeline.
As plain references they are stored, they are findable by name, and the card
for stage `builder` lists the places that copy from it. What is not built is
the stage-to-stage edge. The first coverage guard says so in those words.

It is not a defect in the host and not fixable in the Pack. It is recorded here
because it is the shape of the answer Omega can give about a Dockerfile.

## Still to decide

1. **The COPY destination is stated beside the source.** `copy_instruction`
   gives every argument the same `path` node and only the order tells a source
   from a destination, which is exactly the two-roles-one-type shape §12a warns
   about -- except that here an anchor cannot help, since `COPY a b dest` has
   three paths and the destination is the last of a variable number. Absolute
   destinations (`/srv`) and `./` are discarded by the host as unnameable
   spellings, which removes most of them by accident rather than by design; a
   relative destination such as `app/` is stated as if it were a source.
   Provisionally: state them all, and revisit if the noise shows up in a row
   count.
2. **Whether an exposed port should be a declaration at all.** `EXPOSE 8080`
   names a port, not an entity, and "which images expose 5432" is answered by a
   name search rather than by a resolution. It is cheap -- one per instruction
   on a file of thirty lines -- and it is the question people actually ask, so
   it stays. The same reasoning is why CMD's argv does not: a vector is not a
   name, and naming it with the whole array would be Defect D.
3. **`--mount=type=secret,id=<name>` is not stated.** It names a build secret
   the same way `from=` names a stage, and a repository that uses BuildKit
   secrets would benefit. Left out because nothing else in the repository
   declares a build secret for it to resolve against; one predicate away if
   that changes.
