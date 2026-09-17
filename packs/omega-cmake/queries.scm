; omega-cmake
;
; CMake is the build description of a C or C++ project. The questions asked of
; a CMakeLists.txt are: what does this build produce, where is this target or
; variable defined, what does it link against, what does this file pull in,
; and where is this function called. Every pattern below answers one of them.
;
; CMake has no syntax for declaring a target, a variable or an option: the
; grammar spells all of them as `normal_command`, and the command's name is
; the only thing that says which construct it is. Keying on `set`, `option`,
; `add_library` and their siblings is therefore the language itself, not a
; framework overlay -- these commands are built into cmake(1) and cannot be
; redefined into something else.
;
; Containment is deliberately not stated. The tree already holds it; a
; function body is emitted once as a region, and nothing else nests.

; --- a command call ---
;
; Every statement in CMake is a command invocation, and the control-flow
; keywords have their own node types, so `normal_command` is exactly the set
; of calls. This is what resolves a call of a user-defined function or macro
; onto its `function()`/`macro()` declaration.

(normal_command (identifier) @command.name) @command

; --- function and macro declarations ---
;
; The header's argument list is the name followed by the parameters, so the
; parameter shape is the list with the name stripped off its front. A macro
; is declared under a Callable kind too: it is called exactly like a function.

(function_def
  (function_command
    (argument_list . (argument) @function.name) @function.params)) @function

(macro_def
  (macro_command
    (argument_list . (argument) @macro.name) @macro.params)) @macro

; --- the one region CMake has ---
;
; `function()` is the only construct in this grammar that opens a variable
; scope. A macro runs in its caller's scope, and `if`, `foreach` and `while`
; bodies do not scope variables at all, so none of them is a region here.

(function_def
  (function_command (argument_list . (argument) @function.scope.name))
  (body) @function.body)

; --- what the build declares ---

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @project.name)) @project
 (#match? @_cmd "(?i)^project$"))

((normal_command
   (identifier) @target.command
   (argument_list . (argument) @target.name)) @target
 (#match? @target.command "(?i)^add_(library|executable|custom_target)$"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @variable.name)) @variable.set
 (#match? @_cmd "(?i)^set$"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @option.name)) @option
 (#match? @_cmd "(?i)^option$"))

; A foreach loop binds its iteration variable, and `${it}` inside the body is
; a reference to it like any other.

(foreach_command (argument_list . (argument) @foreach.var)) @foreach

; --- tests ---
;
; `add_test(NAME t COMMAND ...)` and the older positional `add_test(t cmd)`
; are two spellings of one declaration, so they are two patterns over one
; template.

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @_kw . (argument) @test.name)) @test
 (#match? @_cmd "(?i)^add_test$")
 (#match? @_kw "(?i)^NAME$"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @test.name)) @test
 (#match? @_cmd "(?i)^add_test$")
 (#not-match? @test.name "(?i)^NAME$"))

; --- what the build depends on ---
;
; `target_link_libraries(app PUBLIC zlib fmt)` states one dependency per
; argument after the target, so the unanchored second `(argument)` gives one
; match per library. The visibility keywords are not libraries, and a name
; assembled from a variable or a generator expression resolves to nothing.

((normal_command
   (identifier) @_cmd
   (argument_list
     . (argument) @link.owner
     (argument) @link.dependency)) @link
 (#match? @_cmd "(?i)^target_link_libraries$")
 (#not-match? @link.dependency
   "(?i)^(PUBLIC|PRIVATE|INTERFACE|LINK_PUBLIC|LINK_PRIVATE|LINK_INTERFACE_LIBRARIES)$|^[$]"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @package.name)) @package
 (#match? @_cmd "(?i)^find_package$"))

; --- what the build pulls in ---

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @include.path)) @include
 (#match? @_cmd "(?i)^include$"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @subdir.path)) @subdir
 (#match? @_cmd "(?i)^add_subdirectory$"))

; --- mentions of a target ---
;
; Every `target_*` command, `set_target_properties` and `add_dependencies`
; take the target they configure as their first argument. `install(TARGETS t)`
; names the target it installs; only the first is anchored, because what
; follows `DESTINATION` is a path and not a target.

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @target.ref)) @target.use
 (#match? @_cmd "(?i)^(target_[a-z_]+|set_target_properties|add_dependencies)$"))

((normal_command
   (identifier) @_cmd
   (argument_list . (argument) @_kw . (argument) @install.target)) @install
 (#match? @_cmd "(?i)^install$")
 (#match? @_kw "(?i)^TARGETS$"))

; --- variable references ---
;
; The grammar exposes the bare name inside `${...}`, so a reference is stored
; as `FOO` and resolves onto the `set(FOO ...)` that declared it. `$CACHE{FOO}`
; is the same name space; `$ENV{FOO}` is the process environment and is a
; different question.

(variable_ref
  [(normal_var (variable) @variable.ref.name)
   (cache_var (variable) @variable.ref.name)]) @variable.ref

(variable_ref (env_var (variable) @env.ref.name)) @env.ref
