; --- helix_independent_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED. Helix MPL query text is not copied.
; Exact grammar evidence: https://raw.githubusercontent.com/helix-editor/helix/master/runtime/queries/json/highlights.scm
(object) @structural.candidate

; --- literals ---

(string) @data.string
(string_content) @data.string.content
(escape_sequence) @data.string.escape
(number) @data.number
(true) @data.true
(false) @data.false
(null) @data.null
(comment) @data.comment

; --- structure ---

(document) @data.document
(document (_) @data.root.value) @data.root
(object) @data.object
(object (pair) @data.object.pair) @data.object.container
(array) @data.array
(array (_) @data.array.element) @data.array.container
(pair key: (string) @data.key value: (_) @data.value) @data.pair
