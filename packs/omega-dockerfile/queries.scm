; omega-dockerfile
;
; A Dockerfile says how one image is built. The questions asked of it are:
; what does this image build on, what build stages does it have and which
; stage does this one copy from, what build arguments and environment
; variables does it define, what does it copy out of the repository, what
; does it expose, where does it work and who does it run as.
;
; Only three kinds of name in a Dockerfile are referred to from elsewhere in
; the same file: a build stage (`COPY --from=`, `RUN --mount=...,from=`,
; `FROM <stage>`), a build argument and an environment variable (`${NAME}`).
; Those three are declared, and the references to them are spelled the way
; the declaration is -- `--from=builder` is stripped to `builder`, `from=base`
; to `base`, `${NODE_VERSION}` to `NODE_VERSION` -- so that a reference can
; reach its declaration. The Pack this replaces stored `--from=builder`
; verbatim and could never have matched anything.
;
; Containment is not stated. Every instruction is a direct child of the file
; and `ONBUILD` wraps the instruction it defers, so the patterns below reach
; a deferred `COPY` or `ENV` without a pattern of their own.

; --- a build stage ---
;
; `AS <name>` is the only place a Dockerfile gives something a name that the
; rest of the file can write down. The image it builds on is carried on the
; declaration rather than repeated as a second name.

(from_instruction
  (image_spec name: (image_name) @stage.image)
  as: (image_alias) @stage.alias) @stage

; --- the image a FROM builds on ---
;
; One pattern for every FROM, aliased or not. `image_spec` splits the
; reference, so the name here is the repository part without the tag or the
; digest: `node:20-alpine` is `node`, and `FROM builder` is `builder`, which
; is how a stage that builds on an earlier stage reaches its declaration.

(image_spec name: (image_name) @image.name) @image.spec

; --- a build argument ---
;
; Two patterns because `default` is an optional field and a template whose
; attribute names an unbound capture is skipped: written as one pattern, every
; `ARG NODE_VERSION` with no default would go undeclared.

(arg_instruction
  name: (unquoted_string) @arg.name
  default: [(unquoted_string) (single_quoted_string) (double_quoted_string)] @arg.default) @arg

(arg_instruction
  !default
  name: (unquoted_string) @arg.bare_name) @arg.bare

; --- an environment variable ---

(env_pair
  name: (unquoted_string) @env.name
  value: [(unquoted_string) (single_quoted_string) (double_quoted_string)] @env.value) @env

; --- a label on the image ---

(label_pair
  key: [(unquoted_string) (single_quoted_string) (double_quoted_string)] @label.key
  value: [(unquoted_string) (single_quoted_string) (double_quoted_string)] @label.value) @label

; --- what a stage copies from another stage ---
;
; `param` is a leaf whose text is the whole flag, so the flag this pattern
; wants is selected by a predicate and the name is cut out of the text.

((copy_instruction
   (param) @copy.from.param) @copy.from
 (#match? @copy.from.param "^--from="))

; --- what a RUN mounts from another stage or image ---
;
; `--mount=type=bind,from=builder,source=/x`. The `name:` field of
; `mount_param` is the anonymous word `mount` itself -- the Pack this replaces
; named every mount in every repository `mount` for that reason.
;
; The options are the `value:` children, but the field is deliberately not
; written here: this grammar puts the separating `,` into the same field, and
; a query that names the field binds only the first option, so
; `value: (mount_param_param)` matches `type=cache` and never reaches
; `from=base`. Measured against the pinned grammar: one match with the field,
; three without it.

((mount_param
   (mount_param_param) @mount.from) @mount
 (#match? @mount.from "^from="))

; --- what the image takes out of the build context ---

(copy_instruction (path) @copy.path) @copy

(add_instruction (path) @add.path) @add

; --- a use of a build argument or an environment variable ---
;
; `${NAME}` and `$NAME`, wherever the grammar opens one: an image tag, a path,
; a quoted string, an exposed port.

(expansion (variable) @expansion.name) @expansion

; --- the image's own settings ---
;
; Each of these names one thing on its own -- a directory, an account, a port,
; a mount point -- so each is declared under that name and an agent can ask
; which images run as `root` or expose `5432`.

(workdir_instruction (path) @workdir.path) @workdir

(user_instruction user: (unquoted_string) @user.name) @user

(expose_instruction (expose_port) @expose.port) @expose

(volume_instruction (path) @volume.path) @volume

(volume_instruction
  (json_string_array (json_string) @volume.json_path)) @volume.json

; --- the shell a RUN, CMD or ENTRYPOINT runs ---
;
; Handed to the bash Pack rather than restated here.

((shell_command
   (shell_fragment) @injection.content)
 (#set! injection.language "bash")
 (#set! injection.combined))

((run_instruction
   (heredoc_block) @injection.content)
 (#set! injection.language "bash")
 (#set! injection.include-children))
