; --- helix_independent_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED. Helix MPL query text is not copied.
; Exact grammar evidence: https://raw.githubusercontent.com/helix-editor/helix/master/runtime/queries/json/highlights.scm
(object) @structural.candidate @data.object

; --- literals ---

(string_content) @data.string.content
(escape_sequence) @data.string.escape

; --- structure ---

(document) @data.document
(document (_) @data.root.value) @data.root
(object (pair) @data.object.pair) @data.object.container
(array) @data.array
(array (_) @data.array.element) @data.array.container
(pair key: (string) @data.key value: (_) @data.value) @data.pair
