; --- array_object_name_string_pair ---

; Generic JSON array-object owner context:
; { "items": [ { "name": "owner", "field": "value" } ] }
; Emits one syntax fact for each string-valued sibling field paired with the
; object's literal name. Consumer semantics remain outside the Pack.

((pair
  key: (string (string_content) @json.array_named.array_key)
  value: (array
    (object
      (pair
        key: (string (string_content) @_json_array_named_name_key)
        value: (string (string_content) @json.array_named.object_name))
      (pair
        key: (string (string_content) @json.array_named.key)
        value: (string (string_content) @json.array_named.value))) @json.array_named.object)) @json.array_named.container
  (#eq? @_json_array_named_name_key "name"))

((pair
  key: (string (string_content) @json.array_named.array_key)
  value: (array
    (object
      (pair
        key: (string (string_content) @json.array_named.key)
        value: (string (string_content) @json.array_named.value))
      (pair
        key: (string (string_content) @_json_array_named_name_key)
        value: (string (string_content) @json.array_named.object_name))) @json.array_named.object)) @json.array_named.container
  (#eq? @_json_array_named_name_key "name"))

; --- array_object_type_name ---

((pair
  key: (string (string_content) @json.array_object.array_key)
  value: (array
    (object
      (pair
        key: (string (string_content) @_type_key)
        value: (string (string_content) @json.array_object.type))
      (pair
        key: (string (string_content) @_name_key)
        value: (string (string_content) @json.array_object.name))) @json.array_object.object)) @json.array_object.container
  (#eq? @_type_key "type")
  (#eq? @_name_key "name"))

((pair
  key: (string (string_content) @json.array_object.array_key)
  value: (array
    (object
      (pair
        key: (string (string_content) @_name_key)
        value: (string (string_content) @json.array_object.name))
      (pair
        key: (string (string_content) @_type_key)
        value: (string (string_content) @json.array_object.type))) @json.array_object.object)) @json.array_object.container
  (#eq? @_type_key "type")
  (#eq? @_name_key "name"))

; --- comments ---

(comment) @data.comment

; --- depth3_context ---

; Generic depth-3 object leaf: a0 -> a1 -> a2 -> leaf.
(pair
  key: (string (string_content) @json.d3.a0)
  value: (object
    (pair
      key: (string (string_content) @json.d3.a1)
      value: (object
        (pair
          key: (string (string_content) @json.d3.a2)
          value: (object
            (pair
              key: (string (string_content) @json.d3.key)
              value: (_) @json.d3.value) @json.d3.pair)))))) @json.d3.root

; --- literals ---

(string_content) @data.string.content
(escape_sequence) @data.string.escape

; --- nested_array_object_string_pair_context ---

; Generic JSON fixed-depth context:
; { "parent": { "items": [ { "field": "value" } ] } }
; Consumer semantics remain outside the Pack.
(pair
  key: (string (string_content) @json.naosp.parent_key)
  value: (object
    (pair
      key: (string (string_content) @json.naosp.array_key)
      value: (array
        (object
          (pair
            key: (string (string_content) @json.naosp.key)
            value: (string (string_content) @json.naosp.value)) @json.naosp.pair) @json.naosp.object)) @json.naosp.array_pair)) @json.naosp.parent_pair

; --- openapi_operation_schema_refs ---

(pair
  key: (string (string_content) @json.openapi.paths.key)
  value: (object
    (pair
      key: (string (string_content) @json.openapi.path.key)
      value: (object
        (pair
          key: (string (string_content) @json.openapi.method.key)
          value: (object
            (pair
              key: (string (string_content) @json.openapi.responses.key)
              value: (object
                (pair
                  key: (string (string_content) @json.openapi.response.status)
                  value: (object
                    (pair
                      key: (string (string_content) @json.openapi.response.schema.key)
                      value: (object
                        (pair
                          key: (string (string_content) @json.openapi.response.ref.key)
                          value: (string (string_content) @json.openapi.response.ref.value)) @json.openapi.response.ref.pair)) @json.openapi.response.schema.pair)) @json.openapi.response.pair)) @json.openapi.responses.pair)) @json.openapi.method.pair)) @json.openapi.path.pair)) @json.openapi.paths.pair

(pair
  key: (string (string_content) @json.openapi.req.paths.key)
  value: (object
    (pair
      key: (string (string_content) @json.openapi.req.path.key)
      value: (object
        (pair
          key: (string (string_content) @json.openapi.req.method.key)
          value: (object
            (pair
              key: (string (string_content) @json.openapi.req.parameters.key)
              value: (array
                (object
                  (pair
                    key: (string (string_content) @json.openapi.req.schema.key)
                    value: (object
                      (pair
                        key: (string (string_content) @json.openapi.req.ref.key)
                        value: (string (string_content) @json.openapi.req.ref.value)) @json.openapi.req.ref.pair)) @json.openapi.req.schema.pair))) @json.openapi.req.parameters.pair)) @json.openapi.req.method.pair)) @json.openapi.req.path.pair)) @json.openapi.req.paths.pair

; --- owned_context ---

(pair
  key: (string (string_content) @json.parent.key)
  value: (object
    (pair
      key: (string (string_content) @json.child.key)
      value: (_) @json.child.value) @json.child.pair)) @json.parent.pair

(pair
  key: (string (string_content) @json.grandparent.key)
  value: (object
    (pair
      key: (string (string_content) @json.owner.key)
      value: (object
        (pair
          key: (string (string_content) @json.owned.key)
          value: (_) @json.owned.value) @json.owned.pair)) @json.owner.pair)) @json.grandparent.pair

(pair
  key: (string (string_content) @json.string.key)
  value: (string (string_content) @json.string.value)) @json.string.pair

; --- structure ---

(document) @data.document
(document (_) @data.root.value) @data.root
(object) @data.object
(object (pair) @data.object.pair) @data.object.container
(array) @data.array
(array (_) @data.array.element) @data.array.container
(pair
  key: (string) @data.key
  value: (_) @data.value) @data.pair

; --- semantic_closure_v3_146_json_deep_context ---

(pair key: (string (string_content) @json.d4.a0) value: (object (pair key: (string (string_content) @json.d4.a1) value: (object (pair key: (string (string_content) @json.d4.a2) value: (object (pair key: (string (string_content) @json.d4.a3) value: (object (pair key: (string (string_content) @json.d4.key) value: (_) @json.d4.value) @json.d4.pair)))))))) @json.d4.root

(pair key: (string (string_content) @json.d5.a0) value: (object (pair key: (string (string_content) @json.d5.a1) value: (object (pair key: (string (string_content) @json.d5.a2) value: (object (pair key: (string (string_content) @json.d5.a3) value: (object (pair key: (string (string_content) @json.d5.a4) value: (object (pair key: (string (string_content) @json.d5.key) value: (_) @json.d5.value) @json.d5.pair)))))))))) @json.d5.root

(pair key: (string (string_content) @json.d6.a0) value: (object (pair key: (string (string_content) @json.d6.a1) value: (object (pair key: (string (string_content) @json.d6.a2) value: (object (pair key: (string (string_content) @json.d6.a3) value: (object (pair key: (string (string_content) @json.d6.a4) value: (object (pair key: (string (string_content) @json.d6.a5) value: (object (pair key: (string (string_content) @json.d6.key) value: (_) @json.d6.value) @json.d6.pair)))))))))))) @json.d6.root

(pair key: (string (string_content) @json.d7.a0) value: (object (pair key: (string (string_content) @json.d7.a1) value: (object (pair key: (string (string_content) @json.d7.a2) value: (object (pair key: (string (string_content) @json.d7.a3) value: (object (pair key: (string (string_content) @json.d7.a4) value: (object (pair key: (string (string_content) @json.d7.a5) value: (object (pair key: (string (string_content) @json.d7.a6) value: (object (pair key: (string (string_content) @json.d7.key) value: (_) @json.d7.value) @json.d7.pair)))))))))))))) @json.d7.root

(pair key: (string (string_content) @json.seq1.a0) value: (object (pair key: (string (string_content) @json.seq1.array_key) value: (array (object (pair key: (string (string_content) @json.seq1.key) value: (_) @json.seq1.value) @json.seq1.pair) @json.seq1.object)))) @json.seq1.root

(pair key: (string (string_content) @json.seq2.a0) value: (object (pair key: (string (string_content) @json.seq2.a1) value: (object (pair key: (string (string_content) @json.seq2.array_key) value: (array (object (pair key: (string (string_content) @json.seq2.key) value: (_) @json.seq2.value) @json.seq2.pair) @json.seq2.object)))))) @json.seq2.root

(pair key: (string (string_content) @json.seq3.a0) value: (object (pair key: (string (string_content) @json.seq3.a1) value: (object (pair key: (string (string_content) @json.seq3.a2) value: (object (pair key: (string (string_content) @json.seq3.array_key) value: (array (object (pair key: (string (string_content) @json.seq3.key) value: (_) @json.seq3.value) @json.seq3.pair) @json.seq3.object)))))))) @json.seq3.root
