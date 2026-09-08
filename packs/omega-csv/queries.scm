; --- csv_structure ---

(csv) @csv.document
(row) @csv.row
(row (cycle (first) @csv.field.1)) @csv.row.with_field
(row (cycle2 (first) @csv.field.1 (second) @csv.field.2)) @csv.row.with_field
(row (cycle3 (first) @csv.field.1 (second) @csv.field.2 (third) @csv.field.3)) @csv.row.with_field
(row (remainder) @csv.remainder) @csv.row.remainder

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.
(_) @structural.node
