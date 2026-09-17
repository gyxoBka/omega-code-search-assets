; --- call_targets ---

(macro_call
  name: (_) @call.target) @call.expression

(macro_call_statement
  name: (_) @call.target) @call.expression

; --- declaration_category_macro ---

(macro_definition
  name: (_) @definition.category.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(macro_variable_assignment
  name: (_) @definition.category.name
) @definition.category.owner

; --- definition_identity_hints ---

; --- import_targets ---

(include_statement
  source: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

; --- module_path_hints ---

; --- practical-p1-calls ---

; Omega P1 enterprise/provider semantic enrichment
; provider_revision=48728be2d495cd0fba9bdd7a1a360eecaff0f918
; source=ix-infrastructure/tree-sitter-sas@48728be2d495cd0fba9bdd7a1a360eecaff0f918 queries/tags.scm; adapted as source-syntactic Pack facts

(macro_call_statement name: (macro_name) @call.macro.name) @call.macro
(macro_call name: (macro_name) @call.macro.name) @call.macro_inline

; --- practical-p1-definitions ---

; Omega P1 enterprise/provider semantic enrichment
; provider_revision=48728be2d495cd0fba9bdd7a1a360eecaff0f918
; source=ix-infrastructure/tree-sitter-sas@48728be2d495cd0fba9bdd7a1a360eecaff0f918 queries/tags.scm; adapted as source-syntactic Pack facts

(macro_definition name: (macro_name) @definition.macro.name) @definition.macro
(data_step) @definition.data_step
(proc_step) @definition.proc_step

; --- practical-p1-imports-references ---

; Omega P1 enterprise/provider semantic enrichment
; provider_revision=48728be2d495cd0fba9bdd7a1a360eecaff0f918
; source=ix-infrastructure/tree-sitter-sas@48728be2d495cd0fba9bdd7a1a360eecaff0f918 queries/tags.scm; adapted as source-syntactic Pack facts

(include_statement) @import.include
(libname_statement) @import.library
(macro_variable_ref) @reference.macro_variable

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.

; --- terminal_sas_source_semantics_v1 ---

(macro_parameters
  (identifier) @sas.macro.parameter) @sas.macro.parameters
(table_reference
  (dataset_name) @sas.table.reference) @sas.table.reference.owner
(macro_definition) @sas.macro.scope

; --- semantic_closure_v3_146_batch2 ---

(data_step_header (dataset_name) @sas.data.output) @sas.data.step
(proc_sql_step) @sas.proc.sql
(sql_create_statement output: (dataset_name) @sas.sql.create.output) @sas.sql.create
(sql_insert_statement (dataset_name) @sas.sql.insert.target) @sas.sql.insert
(sql_join_clause (table_reference) @sas.sql.join.target) @sas.sql.join
(sql_select_statement (table_reference) @sas.sql.select.table) @sas.sql.select
(table_reference) @sas.table.reference

; --- semantic_closure_v3_146_batch4 ---

(set_statement
  (dataset_name) @sas.data.input) @sas.data.set

(merge_statement
  (dataset_name) @sas.data.merge_input) @sas.data.merge

(update_statement
  (dataset_name) @sas.data.update_input) @sas.data.update

(output_statement
  (dataset_name) @sas.data.output_target) @sas.data.output_statement

(libname_statement
  libref: (identifier) @sas.libname.name
  (string_literal)? @sas.libname.location) @sas.libname

