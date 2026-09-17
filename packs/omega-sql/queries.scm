; omega-sql
;
; SQL in a repository is schema: migrations, DDL, views, stored routines and
; the queries that read and write them. The questions asked of it are: where
; is this table, column, view, index, function or type defined; which
; statements read or write this table; which table does this foreign key,
; index or trigger point at; and where is this column used.
;
; Every pattern below is rooted at one node and answers one of those. Nothing
; states containment: the tree already holds it, a declaration nested in
; another already carries its container through the host's `within:` segment,
; and a pattern per nesting level costs one match per tuple of nodes at that
; level.
;
; Nothing here highlights. The previous Pack carried an nvim-treesitter
; `highlights.scm` baseline -- some 350 keyword tokens, every literal, every
; operator and every bracket -- as `semantic_hint.*` emissions. A keyword is
; not an answer.

; --- a table ---
;
; `create_table` holds exactly one `object_reference` of its own; the sources
; of `CREATE TABLE ... AS SELECT` sit under `from`/`relation` and are matched
; by the relation pattern below, so the lineage of a created table needs no
; pattern of its own.

(create_table
  (object_reference
    name: (identifier) @table.name)) @table

; --- a view ---

[(create_view
   (object_reference
     name: (identifier) @view.name))
 (create_materialized_view
   (object_reference
     name: (identifier) @view.name))] @view

; --- an index, and the table it is on ---
;
; This grammar carries the index name in a field spelled `column` and the
; indexed table as the one `object_reference` of the statement. The name is
; optional in the pattern because `CREATE INDEX ON t (...)` is legal: the
; declaration template is then skipped and the table is still stated.

(create_index
  column: (_)? @index.name
  (object_reference
    name: (identifier) @index.table)) @index

; --- a function ---
;
; The name is the object_reference immediately after FUNCTION: the `custom_type`
; field of the same node is also an object_reference and would otherwise be
; taken as a second name. The argument list is optional in the pattern so that
; a function without one is still declared; the template that needs it is
; skipped when it is unbound.

(create_function
  (keyword_function) . (object_reference
    name: (identifier) @function.name)
  (function_arguments)? @function.params) @function

; RETURNS in this grammar is followed by one node, which may be a type node, a
; `keyword_setof`, a `keyword_trigger` or -- for RETURNS TABLE -- a
; `keyword_table`. The anchor takes that one node and nothing else.

(create_function
  (keyword_returns) . (_) @function.returns) @function.returns.owner

; --- a procedure ---

(create_procedure
  [(keyword_procedure) (keyword_exists)] . (object_reference
    name: (identifier) @procedure.name)
  (function_arguments)? @procedure.params) @procedure

; --- a trigger, and the table it fires on ---

(create_trigger
  [(keyword_trigger) (keyword_exists)] . (identifier) @trigger.name) @trigger

(create_trigger
  (keyword_on) . (object_reference
    name: (identifier) @trigger.on.table)) @trigger.on

; --- a user-defined type ---

(create_type
  (object_reference
    name: (identifier) @type.name)) @type

; --- a schema ---

(create_schema
  [(keyword_schema) (keyword_exists)] . (identifier) @schema.name) @schema

; --- a sequence ---

(create_sequence
  [(keyword_sequence) (keyword_exists)] . (object_reference
    name: (identifier) @sequence.name)) @sequence

; --- an extension the file requires ---

(create_extension
  [(keyword_extension) (keyword_exists)] . (identifier) @extension.name) @extension

; --- a column, and the type it is declared with ---
;
; One pattern serves CREATE TABLE, ALTER TABLE ADD COLUMN, CREATE TYPE AS and
; RETURNS TABLE, because all four spell a column as `column_definition`.
; The type is anchored to the node immediately after the name: this grammar
; puts `int` and `array_size_definition` in one repeat group, so `x int[]`
; would otherwise carry its type twice.

(column_definition
  name: (_) @column.name . type: (_) @column.type) @column

; --- a named constraint ---

(constraint
  name: (identifier) @constraint.name) @constraint

; --- what a foreign key points at ---
;
; Both spellings: the table constraint `FOREIGN KEY (a) REFERENCES t (b)` and
; the column constraint `a int REFERENCES t (b)`.

[(constraint
   (keyword_references) . (object_reference
     name: (identifier) @foreign_key.target))
 (column_definition
   (keyword_references) . (object_reference
     name: (identifier) @foreign_key.target))] @foreign_key

; --- a common table expression ---
;
; The CTE name is the first named child; the identifiers that follow it are
; the `argument` field of `WITH x (a, b) AS ...`.

(cte . (identifier) @cte.name) @cte

; --- a table a query reads or writes, and the name it is read under ---
;
; `relation` is FROM, JOIN, CROSS JOIN and the target of UPDATE and DELETE, so
; one pattern answers "which statements touch this table" for all of them. The
; alias is optional: without it the correlation-name template is skipped.

(relation
  (object_reference
    name: (identifier) @relation.name)
  alias: (identifier)? @relation.alias) @relation

; --- the table INSERT writes to ---
;
; INSERT does not wrap its target in a `relation`, so it needs its own pattern.

(insert
  (object_reference
    name: (identifier) @insert.target)) @insert

; --- a column a select list names ---

(term
  alias: (identifier) @term.alias) @term

; --- a column a statement uses ---
;
; The qualifier of `u.email` is deliberately dropped: in almost every query it
; is a correlation name local to that query, and resolving `u` against a table
; called `u` somewhere else in the repository would be wrong.

(field
  column: (_) @field.column) @field

; --- a function call ---
;
; The callee is the first named child; `unit:` on the same node is the
; `INTERVAL '1' DAY` unit and is not a callee.

(invocation . (object_reference
  name: (identifier) @invocation.name)) @invocation

; --- schema change: what it renames, drops and alters ---

(alter_table
  (object_reference
    name: (identifier) @alter_table.name)) @alter_table

[(drop_table (object_reference name: (identifier) @drop.name))
 (drop_view (object_reference name: (identifier) @drop.name))
 (drop_materialized_view (object_reference name: (identifier) @drop.name))
 (drop_index name: (identifier) @drop.name)
 (drop_sequence (object_reference name: (identifier) @drop.name))
 (drop_type (object_reference name: (identifier) @drop.name))
 (drop_function (object_reference name: (identifier) @drop.name))
 (drop_procedure (object_reference name: (identifier) @drop.name))
 (drop_schema (identifier) @drop.name)
 (drop_extension (identifier) @drop.name)] @drop

(drop_column
  name: (identifier) @drop_column.name) @drop_column

(rename_column
  old_name: (identifier) @rename_column.old
  new_name: (identifier) @rename_column.new) @rename_column

(drop_constraint
  (identifier) @drop_constraint.name) @drop_constraint

; --- a variable declared in a routine body ---

[(var_declaration . (identifier) @variable.name)
 (function_declaration . (identifier) @variable.name)] @variable
