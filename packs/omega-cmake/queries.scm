; --- command_context ---

(normal_command
  (identifier) @cmake.project.command
  (#eq? @cmake.project.command "project")
  (argument_list
    . (argument (unquoted_argument) @cmake.project.name))) @cmake.project.context

(normal_command
  (identifier) @cmake.target.command
  (#any-of? @cmake.target.command "add_library" "add_executable")
  (argument_list
    . (argument (unquoted_argument) @cmake.target.name))) @cmake.target.context

(normal_command
  (identifier) @cmake.link.command
  (#eq? @cmake.link.command "target_link_libraries")
  (argument_list
    . (argument (unquoted_argument) @cmake.link.target)
    . (argument (unquoted_argument) @cmake.link.visibility)
    . (argument (unquoted_argument) @cmake.link.dependency))) @cmake.link.context

; --- completeness_definitions_semantic2 ---

(function_def) @definition.expression
(macro_def) @definition.expression

; --- completeness_references_semantic2 ---

(variable_ref) @reference.expression @none @cmake.variable.reference

; --- completeness_scopes ---

(block) @scope.lexical

; --- definition_identity_hints ---

(function_def (function_command (argument_list (argument) @definition.identity.name))) @definition.identity.owner

(macro_def (macro_command (argument_list (argument) @definition.identity.name))) @definition.identity.owner

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=8dbfb4506f5767d7ee94867976feb741a6c3875db30474f83ce9ddd7169fd2cd
; source_name=cmake

; ----- resolved nvim highlights source: cmake sha256=8dbfb4506f5767d7ee94867976feb741a6c3875db30474f83ce9ddd7169fd2cd -----
(normal_command
  (identifier)
  (argument_list
    (argument
      (unquoted_argument)) @constant)
  (#lua-match? @constant "^[%u@][%u%d_]+$"))

[
  (quoted_argument)
  (bracket_argument)
] @string


(variable) @variable

[
  (bracket_comment)
  (line_comment)
] @comment @spell

(normal_command
  (identifier) @function)

[
  "ENV"
  "CACHE"
] @module

[
  "$"
  "{"
  "}"
] @punctuation.special

[
  "("
  ")"
] @punctuation.bracket

[
  (function)
  (endfunction)
  (macro)
  (endmacro)
] @keyword.function

[
  (if)
  (elseif)
  (else)
  (endif)
] @keyword.conditional

[
  (foreach)
  (endforeach)
  (while)
  (endwhile)
] @keyword.repeat

(normal_command
  (identifier) @keyword.repeat
  (#match? @keyword.repeat "(?i)^(continue|break)$"))

(normal_command
  (identifier) @keyword.return
  (#match? @keyword.return "(?i)^return$"))

(function_command
  (function)
  (argument_list
    .
    (argument) @function
    (argument)* @variable.parameter))

(macro_command
  (macro)
  (argument_list
    .
    (argument) @function.macro
    (argument)* @variable.parameter))

(block_def
  (block_command
    (block) @function.builtin
    (argument_list
      (argument
        (unquoted_argument) @constant))
    (#any-of? @constant "SCOPE_FOR" "POLICIES" "VARIABLES" "PROPAGATE"))
  (endblock_command
    (endblock) @function.builtin))

;
((argument) @boolean
  (#match? @boolean "(?i)^(1|on|yes|true|y|0|off|no|false|n|ignore|notfound|.*-notfound)$"))

;
(if_command
  (if)
  (argument_list
    (argument) @keyword.operator)
  (#any-of? @keyword.operator
    "NOT" "AND" "OR" "COMMAND" "POLICY" "TARGET" "TEST" "DEFINED" "IN_LIST" "EXISTS" "IS_NEWER_THAN"
    "IS_DIRECTORY" "IS_SYMLINK" "IS_ABSOLUTE" "MATCHES" "LESS" "GREATER" "EQUAL" "LESS_EQUAL"
    "GREATER_EQUAL" "STRLESS" "STRGREATER" "STREQUAL" "STRLESS_EQUAL" "STRGREATER_EQUAL"
    "VERSION_LESS" "VERSION_GREATER" "VERSION_EQUAL" "VERSION_LESS_EQUAL" "VERSION_GREATER_EQUAL"))

(elseif_command
  (elseif)
  (argument_list
    (argument) @keyword.operator)
  (#any-of? @keyword.operator
    "NOT" "AND" "OR" "COMMAND" "POLICY" "TARGET" "TEST" "DEFINED" "IN_LIST" "EXISTS" "IS_NEWER_THAN"
    "IS_DIRECTORY" "IS_SYMLINK" "IS_ABSOLUTE" "MATCHES" "LESS" "GREATER" "EQUAL" "LESS_EQUAL"
    "GREATER_EQUAL" "STRLESS" "STRGREATER" "STREQUAL" "STRLESS_EQUAL" "STRGREATER_EQUAL"
    "VERSION_LESS" "VERSION_GREATER" "VERSION_EQUAL" "VERSION_LESS_EQUAL" "VERSION_GREATER_EQUAL"))

(normal_command
  (identifier) @function.builtin
  (#match? @function.builtin
    "(?i)^(cmake_host_system_information|cmake_language|cmake_minimum_required|cmake_parse_arguments|cmake_path|cmake_policy|configure_file|execute_process|file|find_file|find_library|find_package|find_path|find_program|foreach|get_cmake_property|get_directory_property|get_filename_component|get_property|include|include_guard|list|macro|mark_as_advanced|math|message|option|separate_arguments|set|set_directory_properties|set_property|site_name|string|unset|variable_watch|add_compile_definitions|add_compile_options|add_custom_command|add_custom_target|add_definitions|add_dependencies|add_executable|add_library|add_link_options|add_subdirectory|add_test|aux_source_directory|build_command|create_test_sourcelist|define_property|enable_language|enable_testing|export|fltk_wrap_ui|get_source_file_property|get_target_property|get_test_property|include_directories|include_external_msproject|include_regular_expression|install|link_directories|link_libraries|load_cache|project|remove_definitions|set_source_files_properties|set_target_properties|set_tests_properties|source_group|target_compile_definitions|target_compile_features|target_compile_options|target_include_directories|target_link_directories|target_link_libraries|target_link_options|target_precompile_headers|target_sources|try_compile|try_run|ctest_build|ctest_configure|ctest_coverage|ctest_empty_binary_directory|ctest_memcheck|ctest_read_custom_files|ctest_run_script|ctest_sleep|ctest_start|ctest_submit|ctest_test|ctest_update|ctest_upload)$"))

(normal_command
  (identifier) @_function
  (argument_list
    .
    (argument) @variable)
  (#match? @_function "(?i)^set$"))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^set$")
  (argument_list
    .
    (argument)
    ((argument) @_cache @keyword.modifier
      .
      (argument) @_type @type
      (#eq? @_cache "CACHE")
      (#any-of? @_type "BOOL" "FILEPATH" "PATH" "STRING" "INTERNAL"))))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^unset$")
  (argument_list
    .
    (argument)
    (argument) @keyword.modifier
    (#any-of? @keyword.modifier "CACHE" "PARENT_SCOPE")))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^list$")
  (argument_list
    .
    (argument) @constant
    (#any-of? @constant "LENGTH" "GET" "JOIN" "SUBLIST" "FIND")
    .
    (argument) @variable
    (argument) @variable .))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^list$")
  (argument_list
    .
    (argument) @constant
    .
    (argument) @variable
    (#any-of? @constant
      "APPEND" "FILTER" "INSERT" "POP_BACK" "POP_FRONT" "PREPEND" "REMOVE_ITEM" "REMOVE_AT"
      "REMOVE_DUPLICATES" "REVERSE" "SORT")))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^list$")
  (argument_list
    .
    (argument) @_transform @constant
    .
    (argument) @variable
    .
    (argument) @_action @constant
    (#eq? @_transform "TRANSFORM")
    (#any-of? @_action "APPEND" "PREPEND" "TOUPPER" "TOLOWER" "STRIP" "GENEX_STRIP" "REPLACE")))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^list$")
  (argument_list
    .
    (argument) @_transform @constant
    .
    (argument) @variable
    .
    (argument) @_action @constant
    .
    (argument)? @_selector @constant
    (#eq? @_transform "TRANSFORM")
    (#any-of? @_action "APPEND" "PREPEND" "TOUPPER" "TOLOWER" "STRIP" "GENEX_STRIP" "REPLACE")
    (#any-of? @_selector "AT" "FOR" "REGEX")))

(normal_command
  (identifier) @_function
  (#match? @_function "(?i)^list$")
  (argument_list
    .
    (argument) @_transform @constant
    (argument) @constant
    .
    (argument) @variable
    (#eq? @_transform "TRANSFORM")
    (#eq? @constant "OUTPUT_VARIABLE")))

(escape_sequence) @string.escape

((source_file
  .
  (line_comment) @keyword.directive @nospell)
  (#lua-match? @keyword.directive "^#!/"))

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=e1610c4b058fc5b3b646c4dffcc7327ceaa1a049cdd2058471eb845bd2f08d4d
; source_name=cmake

; ----- resolved nvim injections source: cmake sha256=e1610c4b058fc5b3b646c4dffcc7327ceaa1a049cdd2058471eb845bd2f08d4d -----
([
  (bracket_comment)
  (line_comment)
] @injection.content
  (#set! injection.language "comment"))

; --- semantic_closure_v3_146 ---

(normal_command (identifier) @cmake.call.name (argument_list) @cmake.call.args) @cmake.call
((normal_command (identifier) @_cmd (argument_list (argument) @cmake.include.path)) @cmake.include (#eq? @_cmd "include"))
((normal_command (identifier) @_cmd (argument_list (argument) @cmake.subdir.path)) @cmake.subdir (#eq? @_cmd "add_subdirectory"))
((normal_command (identifier) @_cmd (argument_list (argument) @cmake.target.name)) @cmake.target (#any-of? @_cmd "add_executable" "add_library" "add_custom_target"))
((normal_command (identifier) @_cmd (argument_list (argument) @cmake.link.owner (argument) @cmake.link.target)) @cmake.link (#eq? @_cmd "target_link_libraries"))
((normal_command (identifier) @_cmd (argument_list (argument) @cmake.property.owner (argument) @cmake.property.value)) @cmake.property (#any-of? @_cmd "set_property" "set_target_properties" "set_source_files_properties"))

; --- semantic_closure_v3_147_cmake_surface ---
(function_def (function_command (argument_list . (argument) @cmake.function.name)) @cmake.function.header) @cmake.function.definition
(macro_def (macro_command (argument_list . (argument) @cmake.macro.name)) @cmake.macro.header) @cmake.macro.definition
((normal_command (identifier) @_cmd (argument_list . (argument) @cmake.project.name)) @cmake.project (#eq? @_cmd "project"))
((normal_command (identifier) @_cmd (argument_list . (argument) @cmake.package.name)) @cmake.package (#eq? @_cmd "find_package"))
((normal_command (identifier) @_cmd (argument_list . (argument) @cmake.variable.name)) @cmake.variable.binding (#eq? @_cmd "set"))
((normal_command (identifier) @_cmd (argument_list . (argument) @cmake.option.name)) @cmake.option.definition (#eq? @_cmd "option"))
((normal_command (identifier) @_cmd (argument_list . (argument) @cmake.install.target)) @cmake.install.target_context (#eq? @_cmd "install"))
