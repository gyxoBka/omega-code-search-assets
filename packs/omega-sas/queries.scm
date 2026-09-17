; omega-sas
;
; SAS is the language of data preparation and reporting: a program is a
; sequence of DATA steps and PROC steps, wired together by dataset names,
; and parameterised by the macro language that sits on top of it.
;
; The questions asked of a SAS program are: which dataset does this step
; build, which datasets does it read, where is this macro defined and who
; calls it, what is this macro variable set to, which library does a
; two-level name point at, and which file does this program pull in.
; Every pattern below answers one of them.
;
; Containment is not stated. A DATA step and a PROC step are emitted as
; regions, and the tree already holds the rest; the nesting of macro inside
; step inside macro is reached through the declaration spans, not through a
; pattern per depth.
;
; Names are lowered. SAS is case-insensitive in every namespace a Pack can
; see -- `%MACRO Build;` is invoked as `%build()`, `WORK.SALES` and
; `work.sales` are one dataset, `&Root` and `&ROOT` are one macro variable --
; and the host resolves a mention onto a declaration by exact name. Without
; the fold, legacy uppercase SAS resolves against nothing. Paths are left as
; written, because a file system is not case-insensitive.

; --- a macro definition ---
;
; `%macro build(indata, out=work.summary);` declares the one callable thing
; SAS has. The declaration spans `%macro` to `%mend`, so the extent of the
; macro is the declaration's own span and needs no separate region. The
; parameter list is carried onto it as the signature line of its card.

(macro_definition
  name: (macro_name) @macro.name
  (macro_parameters)? @macro.parameters) @macro

; --- a macro parameter ---
;
; A parameter is a macro variable local to the macro, declared exactly as
; `%let` declares a global one, so `&indata` in the body resolves onto it.

(macro_parameters (identifier) @macro.parameter)

; --- a macro call ---
;
; Both spellings: `%build(x)` as a statement of its own, and `%build(x)`
; inside an expression or an argument list. One kind, because the question
; is who calls this macro, not in which position.

[(macro_call_statement name: (macro_name) @call.macro.name)
 (macro_call name: (macro_name) @call.macro.name)] @call.macro

; --- a macro variable ---
;
; `%let cutoff = 20240101;` declares it; `&cutoff` and `&cutoff.` refer to
; it. The reference is stripped of its sigil and of the terminating dot so
; that it spells the same name as the declaration. `&&name` is stripped
; twice; what an indirect reference finally resolves to is run-time.

(macro_variable_assignment name: (identifier) @let.name)

(macro_variable_ref) @macro.variable.ref

; --- a library ---
;
; `libname mylib "/data/warehouse";` binds the first level of every
; `mylib.member` name in the program, and points it at a location outside
; the source. The libref is declared; the location is stated separately,
; once per path, because a concatenated library lists several.

(libname_statement libref: (identifier) @libname.name) @libname

; Anchored to the string that directly follows the libref. Unanchored, this
; matched every quoted option of an external-engine LIBNAME, so
; `libname odb odbc dsn="PRODDB" user="svc_etl" password="x";` stored the DSN,
; the user id and the password as three library paths. An external-engine
; library states no path, and a coverage guard says so.

(libname_statement libref: (identifier) . (string_literal) @libname.path)

; --- an included file ---

(include_statement source: (_) @include.source) @include

; --- a dataset this program builds ---
;
; `data work.sales work.audit;` declares both; `proc sql; create table x as`
; declares one. The name is the two-level `libref.member` as written, which
; is what a later `set` spells.

[(data_step_header (dataset_name) @dataset.declared)
 (sql_create_statement output: (dataset_name) @dataset.declared)]

; --- a dataset this program reads or writes into ---

[(set_statement (dataset_name) @dataset.ref)
 (merge_statement (dataset_name) @dataset.ref)
 (update_statement (dataset_name) @dataset.ref)
 (output_statement (dataset_name) @dataset.ref)
 (sql_insert_statement . (dataset_name) @dataset.ref)]

; A table in a FROM or a JOIN. The span is the whole table reference so that
; it covers the alias; the name is the table.

(table_reference . (dataset_name) @table.name) @table

; --- a PROC step ---
;
; `proc sort data=...;` invokes a SAS procedure. The header is the call; the
; step is the region it governs.

(proc_step . (proc_step_header name: (identifier) @proc.name) @proc.header) @proc.step

; --- a DATA step ---
;
; The region is named for the first dataset it builds, which is how a SAS
; programmer refers to the step.

(data_step . (data_step_header . (dataset_name) @data_step.name)) @data_step
