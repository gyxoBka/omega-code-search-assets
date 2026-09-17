; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=1f5e293fe9065c5bee5565ba5423e3ad7f3211ed13791a259db74f297c00df93
; source_name=dockerfile

; ----- resolved nvim highlights source: dockerfile sha256=1f5e293fe9065c5bee5565ba5423e3ad7f3211ed13791a259db74f297c00df93 -----

((heredoc_block
  (heredoc_line) @string)
  (#set! priority 90))

(expose_instruction (expose_port) @number @docker.expose.port) @docker.expose.context

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=528e6508f127cf583b2d8770e171f884b39fbcb31fe9b59b24daaf04248b7112
; source_name=dockerfile

; ----- resolved nvim injections source: dockerfile sha256=528e6508f127cf583b2d8770e171f884b39fbcb31fe9b59b24daaf04248b7112 -----

((shell_command
  (shell_fragment) @injection.content)
  (#set! injection.language "bash")
  (#set! injection.combined))

((run_instruction
  (heredoc_block) @injection.content)
  (#set! injection.language "bash")
  (#set! injection.include-children))

; --- semantic_dockerfile ---

; Dockerfile declarative semantics; no build/shell execution.
(from_instruction
  (image_spec name: (image_name) @docker.stage.image)
  as: (image_alias) @docker.stage.alias) @docker.stage.context

(from_instruction
  !as
  (image_spec name: (image_name) @docker.stage.image)) @docker.stage.unnamed_context

(env_instruction
  (env_pair
    name: (unquoted_string) @docker.env.name
    value: [(unquoted_string) (single_quoted_string) (double_quoted_string)]?)) @docker.env.context

(arg_instruction
  name: (unquoted_string) @docker.arg.name) @docker.arg.context

(workdir_instruction
  (path) @docker.workdir.path) @docker.workdir.context

; --- terminal_dockerfile_instruction_facts_v1 ---
(label_pair key: (_) @docker.label.key value: (_) @docker.label.value) @docker.label
(copy_instruction (path) @docker.copy.path) @docker.copy
(add_instruction (path) @docker.add.path) @docker.add
(user_instruction user: (_) @docker.user.name group: (_)? @docker.user.group) @docker.user

; --- semantic_closure_v3_146_batch2 ---

((copy_instruction (param) @docker.copy.param) @docker.copy.from (#match? @docker.copy.param "^--from="))
((add_instruction (param) @docker.add.param) @docker.add.from (#match? @docker.add.param "^--from="))

(mount_param name: (_) @docker.mount.name value: (_) @docker.mount.value) @docker.mount
