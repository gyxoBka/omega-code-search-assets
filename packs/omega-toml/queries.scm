; --- context_entries ---

(table
  [(bare_key) (dotted_key) (quoted_key)] @toml.container
  (pair
    [(bare_key) (dotted_key) (quoted_key)] @toml.key
    (_) @toml.value) @toml.entry) @toml.table

(table_array_element
  [(bare_key) (dotted_key) (quoted_key)] @toml.array_container
  (pair
    [(bare_key) (dotted_key) (quoted_key)] @toml.array_key
    (_) @toml.array_value) @toml.array_entry) @toml.table_array

; --- external_highlights ---

; OMEGA PINNED EXTERNAL HIGHLIGHTS — SYNTAX-ROLE EVIDENCE ONLY
; sha256=059618709a4c7e6b287643a68282257e197c5a05cfb9d82b6ac517d32230cb12

(bare_key) @property

[
  (string)
  (quoted_key)
] @string

(boolean) @boolean

(comment) @comment @spell

(escape_sequence) @string.escape

(integer) @number

(float) @number.float

[
  (local_date)
  (local_date_time)
  (local_time)
  (offset_date_time)
] @string.special

"=" @operator

[
  "."
  ","
] @punctuation.delimiter

[
  "["
  "]"
  "[["
  "]]"
  "{"
  "}"
] @punctuation.bracket

; --- external_injections ---

; OMEGA PINNED EXTERNAL INJECTIONS — BOUNDED CANDIDATE EVIDENCE ONLY
; sha256=e8bc96da2faabe257a32d805d3954e200215d94a85fce4d521530c89e0969244

((comment) @injection.content
  (#set! injection.language "comment"))

; --- external_locals ---

; OMEGA EXTERNAL LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim legacy immutable snapshot
; sha256=c96389d2ab7a653ae9b33637e18cf40dcce428d879547b66d9b5a520e1926213

[
  (table)
  (table_array_element)
] @local.scope

; --- nvim_pinned_highlights ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=059618709a4c7e6b287643a68282257e197c5a05cfb9d82b6ac517d32230cb12
; source_name=toml

; ----- resolved nvim highlights source: toml sha256=059618709a4c7e6b287643a68282257e197c5a05cfb9d82b6ac517d32230cb12 -----
(bare_key) @property

[
  (string)
  (quoted_key)
] @string

(boolean) @boolean

(comment) @comment @spell

(escape_sequence) @string.escape

(integer) @number

(float) @number.float

[
  (local_date)
  (local_date_time)
  (local_time)
  (offset_date_time)
] @string.special

"=" @operator

[
  "."
  ","
] @punctuation.delimiter

[
  "["
  "]"
  "[["
  "]]"
  "{"
  "}"
] @punctuation.bracket

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=e8bc96da2faabe257a32d805d3954e200215d94a85fce4d521530c89e0969244
; source_name=toml

; ----- resolved nvim injections source: toml sha256=e8bc96da2faabe257a32d805d3954e200215d94a85fce4d521530c89e0969244 -----
((comment) @injection.content
  (#set! injection.language "comment"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=c96389d2ab7a653ae9b33637e18cf40dcce428d879547b66d9b5a520e1926213
; resolved_query_sha256=6df4ac2e1d3cfc5a6fe04b0feda1bed473b08a31297073a536a357b6e2407da1
; parser_revision=64b56832c2cffe41758f28e05c756a3a98d16f41
; source_name=toml
; direct_inherits=
; resolved_sources=toml

; ----- resolved nvim locals source: toml sha256=c96389d2ab7a653ae9b33637e18cf40dcce428d879547b66d9b5a520e1926213 -----
[
  (table)
  (table_array_element)
] @local.scope

; --- root_string_pairs ---

(document
  (pair
    [(bare_key) (dotted_key) (quoted_key)] @toml.root.key
    (string) @toml.root.value) @toml.root.entry)

; --- structure-v2 ---

(document) @data.document
(table) @data.table
(table_array_element) @data.table_array
(pair
  (_) @data.key
  (_) @data.value) @data.pair
(array) @data.array
(inline_table) @data.object
(document (pair) @data.document.pair) @data.document.container
(document (table) @data.document.table) @data.document.container
(document (table_array_element) @data.document.table_array) @data.document.container
(table (pair) @data.table.pair) @data.table.container
(table_array_element (pair) @data.table_array.pair) @data.table_array.container
(inline_table (pair) @data.object.pair) @data.object.container

; --- table_array_string_elements ---

(table
  [(bare_key) (dotted_key) (quoted_key)] @toml.array_string.container
  (pair
    [(bare_key) (dotted_key) (quoted_key)] @toml.array_string.key
    (array
      (string) @toml.array_string.value) @toml.array_string.array) @toml.array_string.entry) @toml.array_string.table

; --- final_completion_generic_direct_literals_v1 ---
(string) @omega.literal.string
(integer) @omega.literal.integer
(float) @omega.literal.float
(boolean) @omega.literal.boolean
