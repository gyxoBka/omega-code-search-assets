; --- call_targets ---

(command
  name: (_) @call.target) @call.expression

; --- declaration_category_function ---

(function_definition
  name: (_) @definition.category.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=bash kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/bash/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Scopes

; Definitions

; References

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/bash/locals.scm
; sha256=cc82e0fccf88c4e47f8e7b968ea19babb799fda492d834d90959bfd213c49e97

; Scopes

; Definitions

; References

; --- named_scope_owners ---

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=a4e5e1afa7656c3275629467170362997a7b36f51405b0fc0e6c0be080693acd
; source_name=bash

; ----- resolved nvim highlights source: bash sha256=a4e5e1afa7656c3275629467170362997a7b36f51405b0fc0e6c0be080693acd -----

[
  ";"
  ";;"
  ";&"
  ";;&"
  "&"
] @punctuation.delimiter

; Do *not* spell check strings since they typically have some sort of
; interpolation in them, or, are typically used for things like filenames, URLs,
; flags and file content.

 ; bare dollar

"export" @keyword.import

"function" @keyword.function

(special_variable_name) @constant

; help trap

; trap -l

"``" @punctuation.special

(variable_name) @variable

((variable_name) @variable.builtin
  (#any-of? @variable.builtin
    ; https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Variables.html
    "CDPATH" "HOME" "IFS" "MAIL" "MAILPATH" "OPTARG" "OPTIND" "PATH" "PS1" "PS2"
    ; https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
    "_" "BASH" "BASHOPTS" "BASHPID" "BASH_ALIASES" "BASH_ARGC" "BASH_ARGV" "BASH_ARGV0" "BASH_CMDS"
    "BASH_COMMAND" "BASH_COMPAT" "BASH_ENV" "BASH_EXECUTION_STRING" "BASH_LINENO"
    "BASH_LOADABLES_PATH" "BASH_REMATCH" "BASH_SOURCE" "BASH_SUBSHELL" "BASH_VERSINFO"
    "BASH_VERSION" "BASH_XTRACEFD" "CHILD_MAX" "COLUMNS" "COMP_CWORD" "COMP_LINE" "COMP_POINT"
    "COMP_TYPE" "COMP_KEY" "COMP_WORDBREAKS" "COMP_WORDS" "COMPREPLY" "COPROC" "DIRSTACK" "EMACS"
    "ENV" "EPOCHREALTIME" "EPOCHSECONDS" "EUID" "EXECIGNORE" "FCEDIT" "FIGNORE" "FUNCNAME"
    "FUNCNEST" "GLOBIGNORE" "GROUPS" "histchars" "HISTCMD" "HISTCONTROL" "HISTFILE" "HISTFILESIZE"
    "HISTIGNORE" "HISTSIZE" "HISTTIMEFORMAT" "HOSTFILE" "HOSTNAME" "HOSTTYPE" "IGNOREEOF" "INPUTRC"
    "INSIDE_EMACS" "LANG" "LC_ALL" "LC_COLLATE" "LC_CTYPE" "LC_MESSAGES" "LC_NUMERIC" "LC_TIME"
    "LINENO" "LINES" "MACHTYPE" "MAILCHECK" "MAPFILE" "OLDPWD" "OPTERR" "OSTYPE" "PIPESTATUS"
    "POSIXLY_CORRECT" "PPID" "PROMPT_COMMAND" "PROMPT_DIRTRIM" "PS0" "PS3" "PS4" "PWD" "RANDOM"
    "READLINE_ARGUMENT" "READLINE_LINE" "READLINE_MARK" "READLINE_POINT" "REPLY" "SECONDS" "SHELL"
    "SHELLOPTS" "SHLVL" "SRANDOM" "TIMEFORMAT" "TMOUT" "TMPDIR" "UID"))

((command
  name: (command_name
    (word) @_printf)
  .
  argument: (word) @_v
  .
  argument: (word) @variable)
  (#eq? @_printf "printf")
  (#eq? @_v "-v")
  (#match? @variable "^[a-zA-Z_][a-zA-Z0-9_]*$"))

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=cdadaef6c336ca6d75e53be80d1689f6b1d65182c2d51fc55226acded40ccc5c
; source_name=bash

; ----- resolved nvim injections source: bash sha256=cdadaef6c336ca6d75e53be80d1689f6b1d65182c2d51fc55226acded40ccc5c -----

(heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @injection.language)

; printf 'format'

; printf -v var 'format'

; printf -- 'format'

((command
  name: (command_name) @_command
  .
  argument: [
    (string)
    (raw_string)
  ] @injection.content)
  (#eq? @_command "trap")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.self))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=cc82e0fccf88c4e47f8e7b968ea19babb799fda492d834d90959bfd213c49e97
; resolved_query_sha256=2e84182204734335aef8f1d62dec548212a239bf8e9d54697775a4bc71028394
; parser_revision=a06c2e4415e9bc0346c6b86d401879ffb44058f7
; source_name=bash
; direct_inherits=
; resolved_sources=bash

; ----- resolved nvim locals source: bash sha256=cc82e0fccf88c4e47f8e7b968ea19babb799fda492d834d90959bfd213c49e97 -----
; Scopes
(function_definition) @local.scope

; Definitions
(variable_assignment
  name: (variable_name) @local.definition.var)

(function_definition
  name: (word) @local.definition.function)

; References

; --- static_delta ---

(command
  name: (command_name) @call.target) @call.command

((command
  name: (command_name) @import.api
  argument: (_) @import.target) @import.command
  (#match? @import.api "^(source|\\.)$"))

(variable_assignment
  name: (variable_name) @data.assignment.name
  value: (_) @data.assignment.value) @data.assignment

; --- semantic_closure_v3_146_batch2 ---

(for_statement variable: (variable_name) @bash.for.binding value: (_) @bash.for.sequence) @bash.for

(variable_assignment name: (variable_name) @bash.assignment.name value: (_) @bash.assignment.value) @bash.assignment

; --- semantic_closure_v3_146_batch4 ---

(file_redirect
  destination: (_) @bash.redirect.file_destination) @bash.redirect.file

(simple_expansion
  (variable_name) @bash.expansion.variable) @bash.expansion.simple_variable

(expansion
  (variable_name) @bash.expansion.variable) @bash.expansion.parameter

(pipeline
  (_) @bash.pipeline.statement) @bash.pipeline.owned_statement

