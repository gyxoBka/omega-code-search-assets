; omega-csv
;
; A CSV file in a repository is a table: a schema line followed by rows of
; data. The one thing it declares is its columns, and a column name is what
; code elsewhere refers to -- `row["user_id"]`, `df.user_id`, `SELECT user_id`.
; That is the only question this Pack answers, and it answers it with one
; pattern.
;
; What is deliberately not stated:
;
;   * The document and the row. Their text is the file and the line; naming an
;     emission with either stores the bytes of the file in the index as a name
;     that no question can reach. The old Pack did both.
;
;   * Cell values. tree-sitter-csv gives a cell its ordinal position
;     (`first` .. `seventh`, then the cycle repeats inside `remainder`) and
;     nothing else -- no role, no type, no link to the header. A value has no
;     name anything can resolve to, and one emission per cell is one index row
;     per cell of the file. CSV is exactly the data-file class that produced
;     the row explosion this rewrite is undoing.
;
;   * Containment. `row` inside `csv`, `first` inside `cycle3`: the tree holds
;     all of it. The old Pack spelled the first three arities out as three
;     patterns and got three copies of the same fact.
;
;   * The column ordinal. `cycle` .. `cycle7` number the first seven cells and
;     then `remainder` starts the numbering again, so `first` means column 1 or
;     column 8 or column 15. An ordinal attribute would be a lie past the
;     seventh column, so none is written. The `cycle*` grouping nodes are a
;     rainbow-colouring artifact and are matched by wildcard, never by name.

; --- the header row's cells: the file's columns ---
;
; Anchored as the first child of `csv`, so only the first row of the file is
; read. The grouping node is a wildcard because `cycle` .. `cycle7` and
; `remainder` all hold the same seven cell types, and a header wider than
; seven columns continues inside `remainder`.
;
; A CSV cannot say that it has a header. The predicate is the whole of that
; judgement: a cell that begins with a letter or an underscore -- after at most
; two non-alphanumeric characters, which covers a UTF-8 BOM and an opening
; quote -- is read as a column name. `42`, `2024-01-01`, `3.14`, `-` and an
; empty cell are not, so a headerless file of numbers declares nothing.

(csv
  .
  (row
    (_
      [(first)
       (second)
       (third)
       (fourth)
       (fifth)
       (sixth)
       (seventh)] @header.column))
  (#match? @header.column "^[^A-Za-z0-9]{0,2}[A-Za-z_]"))
