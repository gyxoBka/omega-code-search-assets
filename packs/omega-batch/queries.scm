; omega-batch
;
; Windows batch files (.bat, .cmd) are build steps, installers, launchers and
; CI entry points. The questions asked of one are: which subroutines does this
; script define and who jumps into them, which environment variables does it
; set and where are they read, which programs does it run, which other scripts
; does it call, and which files does it write.
;
; Every pattern below is rooted at one node type and answers one of those.
; Containment is not stated: the tree already holds it, and a batch file has no
; nesting worth a pattern per depth.
;
; Batch is case-insensitive in labels, variable names and command words, so
; every name is lowered on both sides of a link. That is a fact about the
; language, not a normalisation habit: `GOTO :Build` and `:build` are the same
; target and must resolve to each other.

; --- the only named code unit batch has ---
;
; A label is a jump target and, with `call`, a subroutine entry. `::` at the
; start of a line is the idiomatic comment; it is excluded here in case the
; grammar lexes it as a label rather than a comment.

((label) @label
  (#not-match? @label "^::"))

; --- an environment variable ---
;
; `set NAME=value`. The value is carried onto the declaration rather than
; emitted as a mention: it is a value, and a mention of it resolves to nothing.
; The value is optional because `set NAME=` clears a variable and still
; declares it; making it optional binds one more capture on the same matches,
; it does not admit new ones.

(variable_assignment
  (variable_name) @assign.name
  [(assignment_value)
   (quoted_assignment_value)
   (caret_quoted_assignment_value)]? @assign.value) @assign

; `set /p NAME=prompt` reads the value from the console. Its own kind, because
; "where does this value come from" has a different answer.

(variable_assignment
  (prompt_assignment (variable_name) @prompt.name)) @prompt

; `set /a NAME=expr` spells the target inside the arithmetic token; the name is
; the text before the first `=`.

(variable_assignment
  (arithmetic_assignment (arithmetic_expression) @arith.expression)) @arith

; --- the loop variable ---
;
; `for %%i in (...) do` binds `%%i`, and the body spells uses of it as ordinary
; variable references, so both sides strip the sigil and meet. One match, two
; facts: the binding and the extent it is live over.

(for_stmt (for_variable) @for.variable) @for

; --- reading a variable ---
;
; `%NAME%`, `!NAME!`, `%NAME:~0,3%`, `%~dp0`, `%1`. Stripped to the bare name so
; it resolves against `set NAME=`.

(variable_reference) @variable.read

; --- calling into this script ---

; `call :build` has no `command_name` child: the label is an anonymous token,
; exactly as in `goto_stmt` below. So the statement is captured whole and the
; target is read out of its text, and the two forms are told apart by whether
; that text begins with a colon. With a `command_name` child required, the
; subroutine call -- the edge from a `call` to the label it enters, which is the
; whole point of declaring labels -- was emitted on no batch file at all.

((call_stmt) @call.label (#match? @call.label "(?i)^call[ 	]+:"))

; --- calling another script or program ---

((call_stmt) @call.script (#not-match? @call.script "(?i)^call[ 	]+:"))

; --- jumping to a label ---
;
; The target of `goto` is an anonymous token in this grammar -- goto_stmt has
; no named child for it -- so the statement is captured whole and the label is
; taken from its text.

(goto_stmt) @goto

; --- running a program ---
;
; Every command line: `msbuild`, `docker`, `robocopy`, `echo`. This is what an
; agent means by "what does this script do".

(cmd (command_name) @command.name) @command

; --- writing a file ---
;
; `> build.log`, `>> %TEMP%\out.txt`, `< input.txt`. `2>&1` has no target node
; and is not stated.

(redirection (redirect_target) @redirect.target) @redirect
