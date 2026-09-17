; omega-bash
;
; Bash files are entrypoints, build and CI scripts, installers and dotfiles.
; The questions asked of one are: what does this script define, where is this
; variable set and what is it set to, what does this script run, what does it
; pull in with `source`, and where is this subcommand handled. Every pattern
; below answers one of those.
;
; Containment is deliberately not stated. A function's extent is emitted once
; as a region; a pattern per level of nesting would restate what the tree
; already holds. Highlighting captures -- punctuation, keywords, the builtin
; variable list -- are gone: no question reaches them.

; --- a function ---
;
; `foo() { ... }` and `function foo { ... }` are one node. The declaration and
; the region over its body are two templates over this one match.

(function_definition
  name: (word) @function.name
  body: (_) @function.body) @function

; --- a variable, and what it is set to ---
;
; `PORT=8080` is where PORT is set, so the assignment is declared under the
; variable's own name and carries its value. This one pattern covers every
; position an assignment occurs in: at file scope, as a command prefix
; (`FOO=1 cmd`), inside `declare`/`export`/`local`, and in a C-style for
; initializer.

(variable_assignment
  name: [
    (variable_name) @assignment.name
    (subscript name: (variable_name) @assignment.name)
  ]
  value: (_) @assignment.value) @assignment

; --- how it was declared ---
;
; `export`, `local`, `readonly`, `declare` and `typeset` answer whether a
; variable is in the environment of the commands that follow, private to a
; function, or fixed. The keyword is carried onto the declaration that occupies
; the same span -- the assignment node above -- as `omega.pack.modifier`.

(declaration_command
  [ "declare" "typeset" "export" "readonly" "local" ] @declaration.keyword
  (variable_assignment) @declaration.assignment)

; A declaration without a value -- `local tmp`, `export PATH`, `declare -A map`
; -- still names a variable, and is the only place the name occurs.

(declaration_command
  [ "declare" "typeset" "export" "readonly" "local" ] @declared.keyword
  (variable_name) @declared.name)

; --- a loop variable ---
;
; `for host in "${hosts[@]}"` binds `host` for the body; it is the one other
; place bash introduces a name.

(for_statement
  variable: (variable_name) @for.variable)

; --- a command the script runs ---
;
; The name is taken only when it is a literal word, so it can match a function
; declared in this repository. `source` and `.` are excluded here and stated as
; imports below.

((command
  name: (command_name (word) @call.name)) @call
  (#not-any-of? @call.name "source" "."))

; --- what the script pulls in ---
;
; `source lib/common.sh` and `. ./lib/common.sh` are the only way a shell
; script includes another file. Anchored to the first argument: the rest are
; positional parameters for the sourced file, not the file.

((command
  name: (command_name (word) @import.keyword)
  .
  argument: (_) @import.target) @import
  (#any-of? @import.keyword "source" "."))

; --- a variable being read ---
;
; `$name` and `${name}` / `${name[i]}`, stripped to the bare name so they
; resolve onto the declarations above.

(simple_expansion
  (variable_name) @variable.reference.name) @variable.reference

(expansion
  [
    (variable_name) @variable.reference.name
    (subscript name: (variable_name) @variable.reference.name)
  ]) @variable.reference

; --- a dispatch branch ---
;
; `case "$1" in deploy) ... ;; esac` is how a shell script spells its
; subcommands, and "where is `deploy` handled" is a question about a name.
; Bare glob branches (`*`, `?`) name nothing and are excluded.

; An alternative adjacent to `|` is lexed as `extglob_pattern`, not `word`:
; `start|begin|go)` gives two extglob_patterns and one word, so matching `word`
; alone declared one name per branch and which one was lexer-dependent.

((case_item
  value: [(word) (extglob_pattern)] @case.value) @case.item
  (#not-match? @case.value "^[*?]+$"))

; --- another language embedded in a heredoc ---
;
; `<<SQL ... SQL` and `<<PYTHON ... PYTHON` carry a real body of another
; language; the delimiter is its name. `<<EOF` names no registered language and
; resolves to nothing, which is the correct outcome.

(heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @injection.language)
