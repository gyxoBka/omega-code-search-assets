; omega-toml
;
; TOML is a configuration language. Its files are Cargo.toml, pyproject.toml,
; netlify.toml, config.toml: the places a project states what it is, what it
; depends on and how it is set up. The questions asked of such a file are
; *where is this setting declared*, *what is it set to*, *what sections does
; this file define* and *which names does it list*.
;
; Every pattern below is rooted at one node and answers one of those. There is
; no pattern for containment: a key declared inside a table is already inside
; that table's declaration, and the host derives the qualified name from the
; nesting. There is no pattern for the document, for comments, or for
; punctuation and syntax roles: none of them names anything a question reaches.

; --- a section header: [server.http] ---
;
; The header is the first key of the table. The pairs that follow are declared
; by the pair patterns below and sit inside this declaration's span.

(table
  . [(bare_key) (dotted_key) (quoted_key)] @table.name) @table

; --- an element of an array of tables: [[bin]] ---
;
; Each occurrence is its own element, so each is its own declaration.

(table_array_element
  . [(bare_key) (dotted_key) (quoted_key)] @table_array.name) @table_array

; --- a key set to a scalar: edition = "2021" ---
;
; This is where a setting is declared and the one place the value is short
; enough, and authored enough, to be worth carrying with it. The quotes are
; stripped so the stored value is the value, not its spelling.

(pair
  . [(bare_key) (dotted_key) (quoted_key)] @scalar.name
  . [(string)
     (integer)
     (float)
     (boolean)
     (local_date)
     (local_date_time)
     (local_time)
     (offset_date_time)] @scalar.value) @scalar

; --- a key set to an array or an inline table ---
;
; The same declaration, without a value: an array is stated by the names it
; lists and an inline table by the keys it contains, both of which are their
; own emissions below. Storing the compound's text here would store the same
; bytes a second and third time.

(pair
  . [(bare_key) (dotted_key) (quoted_key)] @compound.name
  . [(array) (inline_table)]) @compound

; --- a name listed in an array ---
;
; features = ["derive"], members = ["crates/core"], keywords = [...]. A string
; element of an array is how TOML names something that lives elsewhere, so it
; is stated as a data occurrence under the name itself, unquoted, and resolves
; against a declaration of that name if the repository has one.

(array (string) @array.element)
