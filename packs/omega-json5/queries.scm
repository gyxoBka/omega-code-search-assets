; --- external-neovim-distributed-highlights ---

; SOURCE-SYNTACTIC ROLE QUERY adapted from the pinned external highlighting baseline.
; source=neovim-distributed
; original=packs/omega-json5/third_party/neovim-distributed/queries/highlights.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(null) @constant @data.null

(string) @string @data.string

(number) @number @data.number

(comment) @comment @spell @data.comment

; --- literals ---

(identifier) @data.identifier
(true) @data.true
(false) @data.false

; --- structure ---

(file) @data.document
(file (_) @data.root.value) @data.root
(object) @data.object
(object (member) @data.object.member) @data.object.container
(array) @data.array
(array (_) @data.array.element) @data.array.container
(member name: (_) @data.key value: (_) @data.value) @data.pair

; --- semantic_closure_v3_146_json5_structured_context ---

(member
  name: (_) @json5.string.key
  value: (string) @json5.string.value) @json5.string.pair

(member
  name: (_) @json5.parent.key
  value: (object
    (member
      name: (_) @json5.child.key
      value: (_) @json5.child.value) @json5.child.pair)) @json5.parent.pair

(member
  name: (_) @json5.naosp.parent_key
  value: (object
    (member
      name: (_) @json5.naosp.array_key
      value: (array
        (object
          (member
            name: (_) @json5.naosp.key
            value: (string) @json5.naosp.value) @json5.naosp.pair) @json5.naosp.object)) @json5.naosp.array_pair)) @json5.naosp.parent_pair
