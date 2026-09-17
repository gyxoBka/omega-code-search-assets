; --- comments ---

(comment) @data.comment

; --- deep_context ---

; --- deep_context_depth5_v3_150 ---
; Generic depth-5 mapping leaf: a0 -> a1 -> a2 -> a3 -> a4 -> leaf.
(block_mapping_pair
  key: (_) @yaml.d5.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d5.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d5.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d5.a3
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.d5.a4
                          value: (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.d5.key
                                value: (_) @yaml.d5.value) @yaml.d5.pair))))))))))))))) @yaml.d5.root

; Generic depth-4 mapping leaf: a0 -> a1 -> a2 -> a3 -> leaf.
(block_mapping_pair
  key: (_) @yaml.d4.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d4.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d4.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d4.a3
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.d4.key
                          value: (_) @yaml.d4.value) @yaml.d4.pair)))))))))))) @yaml.d4.root

; Generic depth-7 mapping leaf: a0 -> ... -> a6 -> leaf.
(block_mapping_pair
  key: (_) @yaml.d7.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d7.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d7.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d7.a3
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.d7.a4
                          value: (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.d7.a5
                                value: (block_node
                                  (block_mapping
                                    (block_mapping_pair
                                      key: (_) @yaml.d7.a6
                                      value: (block_node
                                        (block_mapping
                                          (block_mapping_pair
                                            key: (_) @yaml.d7.key
                                            value: (_) @yaml.d7.value) @yaml.d7.pair))))))))))))))))))))) @yaml.d7.root

; Generic depth-8 mapping leaf: a0 -> ... -> a7 -> leaf.
(block_mapping_pair
  key: (_) @yaml.d8.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d8.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d8.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d8.a3
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.d8.a4
                          value: (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.d8.a5
                                value: (block_node
                                  (block_mapping
                                    (block_mapping_pair
                                      key: (_) @yaml.d8.a6
                                      value: (block_node
                                        (block_mapping
                                          (block_mapping_pair
                                            key: (_) @yaml.d8.a7
                                            value: (block_node
                                              (block_mapping
                                                (block_mapping_pair
                                                  key: (_) @yaml.d8.key
                                                  value: (_) @yaml.d8.value) @yaml.d8.pair)))))))))))))))))))))))) @yaml.d8.root

; Generic mapping field inside a sequence item owned at depth 3:
; a0 -> a1 -> a2 -> sequence_key -> [ { item_key: item_value, ... } ].
(block_mapping_pair
  key: (_) @yaml.d3seq.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d3seq.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d3seq.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d3seq.key
                    value: (block_node
                      (block_sequence
                        (block_sequence_item
                          (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.d3seq.item.key
                                value: (_) @yaml.d3seq.item.value) @yaml.d3seq.item.pair))))))))))))))) @yaml.d3seq.root

; --- depth3_context ---

; Generic depth-3 mapping leaf: a0 -> a1 -> a2 -> leaf.
(block_mapping_pair
  key: (_) @yaml.d3.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.d3.a1
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.d3.a2
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.d3.key
                    value: (_) @yaml.d3.value) @yaml.d3.pair))))))))) @yaml.d3.root

; --- document_object_context ---

; Generic YAML document identity with explicit namespace.
; Bounded source shape only: top-level kind plus metadata{name,namespace}.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.doc.kind.key
        value: (_) @yaml.doc.kind.value)
      (block_mapping_pair
        key: (_) @yaml.doc.metadata.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.doc.name.key
              value: (_) @yaml.doc.name.value)
            (block_mapping_pair
              key: (_) @yaml.doc.namespace.key
              value: (_) @yaml.doc.namespace.value))))))) @yaml.doc.span

; Generic document-owned depth-2 mapping leaf: a0 -> a1 -> key/value.
; Carries kind/name/namespace in the same fact so downstream rules need no
; second projected join merely to recover document identity.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.docd2.kind.key
        value: (_) @yaml.docd2.kind.value)
      (block_mapping_pair
        key: (_) @yaml.docd2.metadata.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd2.name.key
              value: (_) @yaml.docd2.name.value)
            (block_mapping_pair
              key: (_) @yaml.docd2.namespace.key
              value: (_) @yaml.docd2.namespace.value))))
      (block_mapping_pair
        key: (_) @yaml.docd2.a0
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd2.a1
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.docd2.key
                    value: (_) @yaml.docd2.value)))))))))) @yaml.docd2.span

; Generic document-owned depth-3 mapping leaf: a0 -> a1 -> a2 -> key/value.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.docd3.kind.key
        value: (_) @yaml.docd3.kind.value)
      (block_mapping_pair
        key: (_) @yaml.docd3.metadata.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd3.name.key
              value: (_) @yaml.docd3.name.value)
            (block_mapping_pair
              key: (_) @yaml.docd3.namespace.key
              value: (_) @yaml.docd3.namespace.value))))
      (block_mapping_pair
        key: (_) @yaml.docd3.a0
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd3.a1
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.docd3.a2
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.docd3.key
                          value: (_) @yaml.docd3.value))))))))))))) @yaml.docd3.span

; Generic document-owned depth-4 mapping leaf: a0 -> a1 -> a2 -> a3 -> key/value.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.docd4.kind.key
        value: (_) @yaml.docd4.kind.value)
      (block_mapping_pair
        key: (_) @yaml.docd4.metadata.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd4.name.key
              value: (_) @yaml.docd4.name.value)
            (block_mapping_pair
              key: (_) @yaml.docd4.namespace.key
              value: (_) @yaml.docd4.namespace.value))))
      (block_mapping_pair
        key: (_) @yaml.docd4.a0
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docd4.a1
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.docd4.a2
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.docd4.a3
                          value: (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.docd4.key
                                value: (_) @yaml.docd4.value)))))))))))))))) @yaml.docd4.span

; Generic document-owned mapping field nested in a depth-3 sequence item:
; a0 -> a1 -> a2 -> sequence_key -> [ { owner_key: { key: value } } ].
; This is intentionally fixed-depth and does not expand aliases/merges/templates.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.docseq.kind.key
        value: (_) @yaml.docseq.kind.value)
      (block_mapping_pair
        key: (_) @yaml.docseq.metadata.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docseq.name.key
              value: (_) @yaml.docseq.name.value)
            (block_mapping_pair
              key: (_) @yaml.docseq.namespace.key
              value: (_) @yaml.docseq.namespace.value))))
      (block_mapping_pair
        key: (_) @yaml.docseq.a0
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.docseq.a1
              value: (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.docseq.a2
                    value: (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @yaml.docseq.sequence_key
                          value: (block_node
                            (block_sequence
                              (block_sequence_item
                                (block_node
                                  (block_mapping
                                    (block_mapping_pair
                                      key: (_) @yaml.docseq.owner_key
                                      value: (block_node
                                        (block_mapping
                                          (block_mapping_pair
                                            key: (_) @yaml.docseq.key
                                            value: (_) @yaml.docseq.value)))))))))))))))))))))) @yaml.docseq.span

; --- owned_context ---

; One mapping pair nested directly below another mapping key.
(block_mapping_pair
  key: (_) @yaml.parent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.child.key
        value: (_) @yaml.child.value) @yaml.child.pair))) @yaml.parent.pair

; One field inside a mapping object that itself is nested below a top-level mapping key.
(block_mapping_pair
  key: (_) @yaml.grandparent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.owner.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.owned.key
              value: (_) @yaml.owned.value) @yaml.owned.pair))) @yaml.owner.pair))) @yaml.grandparent.pair

; First mapping pair of each sequence item owned by grandparent.owner.sequence.
(block_mapping_pair
  key: (_) @yaml.seq.grandparent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.seq.owner.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.seq.key
              value: (block_node
                (block_sequence
                  (block_sequence_item
                    (block_node
                      (block_mapping
                        . (block_mapping_pair
                            key: (_) @yaml.item.key
                            value: (_) @yaml.item.value) @yaml.item.pair))))))))) @yaml.seq.pair))) @yaml.seq.grandparent.pair

; Scalar sequence item owned by a mapping object: owner -> sequence_key -> item.
(block_mapping_pair
  key: (_) @yaml.scalarseq.owner.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.scalarseq.key
        value: (block_node
          (block_sequence
            (block_sequence_item
              (_) @yaml.scalarseq.item.value) @yaml.scalarseq.item))) @yaml.scalarseq.pair))) @yaml.scalarseq.owner.pair

; --- scalars ---

(string_scalar) @data.string
(plain_scalar) @data.scalar
(single_quote_scalar) @data.string
(double_quote_scalar) @data.string
(integer_scalar) @data.integer
(float_scalar) @data.float
(boolean_scalar) @data.boolean
(null_scalar) @data.null
(timestamp_scalar) @data.timestamp
(block_scalar) @data.block_scalar

; --- structure ---

(document) @data.document
(block_mapping) @data.mapping
(flow_mapping) @data.mapping
(block_sequence) @data.sequence
(flow_sequence) @data.sequence
(block_mapping_pair key: (_) @data.key value: (_) @data.value) @data.pair
(flow_pair key: (_) @data.key value: (_) @data.value) @data.pair
(block_sequence_item (_) @data.item) @data.sequence_item
(document (_) @data.root.value) @data.root
(block_mapping (block_mapping_pair) @data.object.pair) @data.object.container
(flow_mapping (flow_pair) @data.object.pair) @data.object.container
(block_sequence (block_sequence_item) @data.array.element) @data.array.container

; --- top_level_context ---

; Top-level mapping pair inside a YAML document.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.top.key
        value: (_) @yaml.top.value) @yaml.top.pair)))

; Scalar item in a top-level sequence such as stages: [build, test] / block form.
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.topseq.key
        value: (block_node
          (block_sequence
            (block_sequence_item
              (_) @yaml.topseq.item.value) @yaml.topseq.item))) @yaml.topseq.pair)))

; First mapping pair of each mapping item in a top-level sequence.
(block_mapping_pair
  key: (_) @yaml.topmapseq.key
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_mapping
            . (block_mapping_pair
                key: (_) @yaml.topmapseq.item.key
                value: (_) @yaml.topmapseq.item.value) @yaml.topmapseq.item.pair)))))) @yaml.topmapseq.pair

; --- flow_sequence_context_v3_146 ---

; Scalar item in a top-level flow sequence: stages: [build, test], include: [a.yml, b.yml].
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.topflowseq.key
        value: (flow_node
          (flow_sequence
            (flow_node) @yaml.topflowseq.item.value)) @yaml.topflowseq.value) @yaml.topflowseq.pair)))

; Scalar flow-sequence item owned by a mapping object: job -> needs: [build, test].
(block_mapping_pair
  key: (_) @yaml.flowseq.owner.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.flowseq.key
        value: (flow_node
          (flow_sequence
            (flow_node) @yaml.flowseq.item.value)) @yaml.flowseq.value) @yaml.flowseq.pair))) @yaml.flowseq.owner.pair

; Every mapping field of each block mapping item in a top-level sequence, e.g. include: - local: x.
(block_mapping_pair
  key: (_) @yaml.topmapseqfield.key
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @yaml.topmapseqfield.item.key
              value: (_) @yaml.topmapseqfield.item.value) @yaml.topmapseqfield.item.pair))) @yaml.topmapseqfield.item))) @yaml.topmapseqfield.pair

; Every mapping field of each flow-mapping item in a top-level flow sequence,
; e.g. include: [{local: x}, {remote: y}].
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.topflowmapseqfield.key
        value: (flow_node
          (flow_sequence
            (flow_node
              (flow_mapping
                (flow_pair
                  key: (flow_node (_) @yaml.topflowmapseqfield.item.key)
                  value: (flow_node (_) @yaml.topflowmapseqfield.item.value)) @yaml.topflowmapseqfield.item.pair)) @yaml.topflowmapseqfield.item)) @yaml.topflowmapseqfield.value) @yaml.topflowmapseqfield.pair)))

; --- semantic_closure_v3_146_yaml_deep_document ---

; Generated recursively to keep fixed-depth document contexts balanced.

(document
  (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd5.kind.key value: (_) @yaml.docd5.kind.value)
      (block_mapping_pair
  key: (_) @yaml.docd5.metadata.key
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd5.name.key value: (_) @yaml.docd5.name.value)
      (block_mapping_pair key: (_) @yaml.docd5.namespace.key value: (_) @yaml.docd5.namespace.value))))
      (block_mapping_pair
  key: (_) @yaml.docd5.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd5.a1
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd5.a2
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd5.a3
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd5.a4
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd5.key value: (_) @yaml.docd5.value))))))))))))))))))) @yaml.docd5.span

(document
  (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd6.kind.key value: (_) @yaml.docd6.kind.value)
      (block_mapping_pair
  key: (_) @yaml.docd6.metadata.key
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd6.name.key value: (_) @yaml.docd6.name.value)
      (block_mapping_pair key: (_) @yaml.docd6.namespace.key value: (_) @yaml.docd6.namespace.value))))
      (block_mapping_pair
  key: (_) @yaml.docd6.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd6.a1
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd6.a2
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd6.a3
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd6.a4
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docd6.a5
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docd6.key value: (_) @yaml.docd6.value)))))))))))))))))))))) @yaml.docd6.span

(document
  (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docitem.kind.key @yaml.docseqf3.kind.key value: (_) @yaml.docitem.kind.value @yaml.docseqf3.kind.value)
      (block_mapping_pair
  key: (_) @yaml.docitem.metadata.key @yaml.docseqf3.metadata.key
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docitem.name.key @yaml.docseqf3.name.key value: (_) @yaml.docitem.name.value @yaml.docseqf3.name.value)
      (block_mapping_pair key: (_) @yaml.docitem.namespace.key @yaml.docseqf3.namespace.key value: (_) @yaml.docitem.namespace.value @yaml.docseqf3.namespace.value))))
      (block_mapping_pair
  key: (_) @yaml.docitem.a0 @yaml.docseqf3.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docitem.a1 @yaml.docseqf3.a1
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docitem.a2 @yaml.docseqf3.a2
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docitem.sequence_key @yaml.docseqf3.sequence_key
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_mapping
            (block_mapping_pair key: (_) @yaml.docitem.key @yaml.docseqf3.key value: (_) @yaml.docitem.value @yaml.docseqf3.value) @yaml.docitem.pair @yaml.docseqf3.pair)))))))))))))))))) @yaml.docitem.span @yaml.docseqf3.span

(document
  (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docnested.kind.key value: (_) @yaml.docnested.kind.value)
      (block_mapping_pair
  key: (_) @yaml.docnested.metadata.key
  value: (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docnested.name.key value: (_) @yaml.docnested.name.value)
      (block_mapping_pair key: (_) @yaml.docnested.namespace.key value: (_) @yaml.docnested.namespace.value))))
      (block_mapping_pair
  key: (_) @yaml.docnested.a0
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docnested.a1
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docnested.a2
  value: (block_node
    (block_mapping
      (block_mapping_pair
  key: (_) @yaml.docnested.outer_sequence_key
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_mapping
            (block_mapping_pair key: (_) @yaml.docnested.owner_name_key value: (_) @yaml.docnested.owner_name)
            (block_mapping_pair
              key: (_) @yaml.docnested.nested_sequence_key
              value: (block_node
                (block_sequence
                  (block_sequence_item
                    (block_node
                      (block_mapping
                        (block_mapping_pair key: (_) @yaml.docnested.key value: (_) @yaml.docnested.value) @yaml.docnested.pair)))))))))))))))))))))))) @yaml.docnested.span

; --- semantic_closure_v3_146_yaml_named_sequence_items ---

(document (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.docseqf1.kind.key value: (_) @yaml.docseqf1.kind.value)
      (block_mapping_pair key: (_) @yaml.docseqf1.metadata.key value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.docseqf1.name.key value: (_) @yaml.docseqf1.name.value)
        (block_mapping_pair key: (_) @yaml.docseqf1.namespace.key value: (_) @yaml.docseqf1.namespace.value))))
      (block_mapping_pair key: (_) @yaml.docseqf1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docseqf1.sequence_key value: (block_node (block_sequence
        (block_sequence_item (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.docseqf1.key value: (_) @yaml.docseqf1.value) @yaml.docseqf1.pair)))))))))))) @yaml.docseqf1.span

(document (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.docseqn1.kind.key value: (_) @yaml.docseqn1.kind.value)
      (block_mapping_pair key: (_) @yaml.docseqn1.metadata.key value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.docseqn1.name.key value: (_) @yaml.docseqn1.name.value)
        (block_mapping_pair key: (_) @yaml.docseqn1.namespace.key value: (_) @yaml.docseqn1.namespace.value))))
      (block_mapping_pair key: (_) @yaml.docseqn1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docseqn1.sequence_key value: (block_node (block_sequence
        (block_sequence_item (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.docseqn1.owner_name_key value: (_) @yaml.docseqn1.owner_name)
          (block_mapping_pair key: (_) @yaml.docseqn1.key value: (_) @yaml.docseqn1.value) @yaml.docseqn1.pair)))))))))))) @yaml.docseqn1.span

(document (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.docseqn3.kind.key value: (_) @yaml.docseqn3.kind.value)
      (block_mapping_pair key: (_) @yaml.docseqn3.metadata.key value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.docseqn3.name.key value: (_) @yaml.docseqn3.name.value)
        (block_mapping_pair key: (_) @yaml.docseqn3.namespace.key value: (_) @yaml.docseqn3.namespace.value))))
      (block_mapping_pair key: (_) @yaml.docseqn3.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docseqn3.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docseqn3.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docseqn3.sequence_key value: (block_node (block_sequence
        (block_sequence_item (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.docseqn3.owner_name_key value: (_) @yaml.docseqn3.owner_name)
          (block_mapping_pair key: (_) @yaml.docseqn3.key value: (_) @yaml.docseqn3.value) @yaml.docseqn3.pair)))))))))))))))))) @yaml.docseqn3.span

; --- semantic_closure_v3_146_yaml_document_identity_no_namespace ---
; Document identity when metadata.name is authored but metadata.namespace is not.
; Downstream frameworks must not silently substitute a deployment-context namespace.
(document
  (block_node
    (block_mapping
      (block_mapping_pair key: (_) @yaml.docnon.kind.key value: (_) @yaml.docnon.kind.value)
      (block_mapping_pair key: (_) @yaml.docnon.metadata.key value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.docnon.name.key value: (_) @yaml.docnon.name.value))))))) @yaml.docnon.span

; --- semantic_closure_v3_146_yaml_no_namespace_deep ---

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon2.kind.key value: (_) @yaml.docnon2.kind.value) (block_mapping_pair key: (_) @yaml.docnon2.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon2.name.key value: (_) @yaml.docnon2.name.value)))) (block_mapping_pair key: (_) @yaml.docnon2.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon2.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon2.key value: (_) @yaml.docnon2.value)))))))))) @yaml.docnon2.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon3.kind.key value: (_) @yaml.docnon3.kind.value) (block_mapping_pair key: (_) @yaml.docnon3.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon3.name.key value: (_) @yaml.docnon3.name.value)))) (block_mapping_pair key: (_) @yaml.docnon3.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon3.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon3.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon3.key value: (_) @yaml.docnon3.value))))))))))))) @yaml.docnon3.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.kind.key value: (_) @yaml.docnon4.kind.value) (block_mapping_pair key: (_) @yaml.docnon4.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.name.key value: (_) @yaml.docnon4.name.value)))) (block_mapping_pair key: (_) @yaml.docnon4.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.a3 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon4.key value: (_) @yaml.docnon4.value)))))))))))))))) @yaml.docnon4.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.kind.key value: (_) @yaml.docnon5.kind.value) (block_mapping_pair key: (_) @yaml.docnon5.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.name.key value: (_) @yaml.docnon5.name.value)))) (block_mapping_pair key: (_) @yaml.docnon5.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.a3 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.a4 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon5.key value: (_) @yaml.docnon5.value))))))))))))))))))) @yaml.docnon5.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.kind.key value: (_) @yaml.docnon6.kind.value) (block_mapping_pair key: (_) @yaml.docnon6.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.name.key value: (_) @yaml.docnon6.name.value)))) (block_mapping_pair key: (_) @yaml.docnon6.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.a3 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.a4 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.a5 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon6.key value: (_) @yaml.docnon6.value)))))))))))))))))))))) @yaml.docnon6.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf1.kind.key value: (_) @yaml.docnonseqf1.kind.value) (block_mapping_pair key: (_) @yaml.docnonseqf1.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf1.name.key value: (_) @yaml.docnonseqf1.name.value)))) (block_mapping_pair key: (_) @yaml.docnonseqf1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf1.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf1.key value: (_) @yaml.docnonseqf1.value) @yaml.docnonseqf1.pair)))))))))))) @yaml.docnonseqf1.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn1.kind.key value: (_) @yaml.docnonseqn1.kind.value) (block_mapping_pair key: (_) @yaml.docnonseqn1.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn1.name.key value: (_) @yaml.docnonseqn1.name.value)))) (block_mapping_pair key: (_) @yaml.docnonseqn1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn1.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn1.owner_name_key value: (_) @yaml.docnonseqn1.owner_name) (block_mapping_pair key: (_) @yaml.docnonseqn1.key value: (_) @yaml.docnonseqn1.value) @yaml.docnonseqn1.pair)))))))))))) @yaml.docnonseqn1.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.kind.key value: (_) @yaml.docnonseqf3.kind.value) (block_mapping_pair key: (_) @yaml.docnonseqf3.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.name.key value: (_) @yaml.docnonseqf3.name.value)))) (block_mapping_pair key: (_) @yaml.docnonseqf3.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqf3.key value: (_) @yaml.docnonseqf3.value) @yaml.docnonseqf3.pair)))))))))))))))))) @yaml.docnonseqf3.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.kind.key value: (_) @yaml.docnonseqn3.kind.value) (block_mapping_pair key: (_) @yaml.docnonseqn3.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.name.key value: (_) @yaml.docnonseqn3.name.value)))) (block_mapping_pair key: (_) @yaml.docnonseqn3.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqn3.owner_name_key value: (_) @yaml.docnonseqn3.owner_name) (block_mapping_pair key: (_) @yaml.docnonseqn3.key value: (_) @yaml.docnonseqn3.value) @yaml.docnonseqn3.pair)))))))))))))))))) @yaml.docnonseqn3.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.kind.key value: (_) @yaml.docnonnested.kind.value) (block_mapping_pair key: (_) @yaml.docnonnested.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.name.key value: (_) @yaml.docnonnested.name.value)))) (block_mapping_pair key: (_) @yaml.docnonnested.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.outer_sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.owner_name_key value: (_) @yaml.docnonnested.owner_name) (block_mapping_pair key: (_) @yaml.docnonnested.nested_sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonnested.key value: (_) @yaml.docnonnested.value) @yaml.docnonnested.pair)))))))))))))))))))))))) @yaml.docnonnested.span

; --- semantic_closure_v3_146_yaml_nested_named_items ---

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docenv.kind.key value: (_) @yaml.docenv.kind.value) (block_mapping_pair key: (_) @yaml.docenv.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docenv.name.key value: (_) @yaml.docenv.name.value) (block_mapping_pair key: (_) @yaml.docenv.namespace.key value: (_) @yaml.docenv.namespace.value)))) (block_mapping_pair key: (_) @yaml.docenv.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docenv.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docenv.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docenv.outer_sequence_key value: (block_node (block_sequence
    (block_sequence_item (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.docenv.outer_name_key value: (_) @yaml.docenv.outer_name)
      (block_mapping_pair key: (_) @yaml.docenv.nested_sequence_key value: (block_node (block_sequence
        (block_sequence_item (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.docenv.inner_name_key value: (_) @yaml.docenv.inner_name)
          (block_mapping_pair key: (_) @yaml.docenv.key value: (_) @yaml.docenv.value) @yaml.docenv.pair)))))))))))))))))))))))) @yaml.docenv.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonenv.kind.key value: (_) @yaml.docnonenv.kind.value) (block_mapping_pair key: (_) @yaml.docnonenv.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonenv.name.key value: (_) @yaml.docnonenv.name.value) ))) (block_mapping_pair key: (_) @yaml.docnonenv.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonenv.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonenv.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonenv.outer_sequence_key value: (block_node (block_sequence
    (block_sequence_item (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.docnonenv.outer_name_key value: (_) @yaml.docnonenv.outer_name)
      (block_mapping_pair key: (_) @yaml.docnonenv.nested_sequence_key value: (block_node (block_sequence
        (block_sequence_item (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.docnonenv.inner_name_key value: (_) @yaml.docnonenv.inner_name)
          (block_mapping_pair key: (_) @yaml.docnonenv.key value: (_) @yaml.docnonenv.value) @yaml.docnonenv.pair)))))))))))))))))))))))) @yaml.docnonenv.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqmap.kind.key value: (_) @yaml.docnonseqmap.kind.value) (block_mapping_pair key: (_) @yaml.docnonseqmap.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqmap.name.key value: (_) @yaml.docnonseqmap.name.value) ))) (block_mapping_pair key: (_) @yaml.docnonseqmap.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqmap.a1 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqmap.a2 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnonseqmap.sequence_key value: (block_node (block_sequence
   (block_sequence_item (block_node (block_mapping
     (block_mapping_pair key: (_) @yaml.docnonseqmap.owner_key value: (block_node (block_mapping
       (block_mapping_pair key: (_) @yaml.docnonseqmap.key value: (_) @yaml.docnonseqmap.value)))))))))))))))))))))) @yaml.docnonseqmap.span

; --- semantic_closure_v3_146_yaml_depth1_top_sequence ---

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docd1.kind.key value: (_) @yaml.docd1.kind.value) (block_mapping_pair key: (_) @yaml.docd1.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docd1.name.key value: (_) @yaml.docd1.name.value) (block_mapping_pair key: (_) @yaml.docd1.namespace.key value: (_) @yaml.docd1.namespace.value)))) (block_mapping_pair key: (_) @yaml.docd1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docd1.key value: (_) @yaml.docd1.value))))))) @yaml.docd1.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.doctopseq.kind.key value: (_) @yaml.doctopseq.kind.value) (block_mapping_pair key: (_) @yaml.doctopseq.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.doctopseq.name.key value: (_) @yaml.doctopseq.name.value) (block_mapping_pair key: (_) @yaml.doctopseq.namespace.key value: (_) @yaml.doctopseq.namespace.value)))) (block_mapping_pair key: (_) @yaml.doctopseq.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.doctopseq.key value: (_) @yaml.doctopseq.value) @yaml.doctopseq.pair))))))))) @yaml.doctopseq.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon1.kind.key value: (_) @yaml.docnon1.kind.value) (block_mapping_pair key: (_) @yaml.docnon1.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon1.name.key value: (_) @yaml.docnon1.name.value) ))) (block_mapping_pair key: (_) @yaml.docnon1.a0 value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnon1.key value: (_) @yaml.docnon1.value))))))) @yaml.docnon1.span

(document (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnontopseq.kind.key value: (_) @yaml.docnontopseq.kind.value) (block_mapping_pair key: (_) @yaml.docnontopseq.metadata.key value: (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnontopseq.name.key value: (_) @yaml.docnontopseq.name.value) ))) (block_mapping_pair key: (_) @yaml.docnontopseq.sequence_key value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair key: (_) @yaml.docnontopseq.key value: (_) @yaml.docnontopseq.value) @yaml.docnontopseq.pair))))))))) @yaml.docnontopseq.span

; --- semantic_closure_v3_146_yaml_named_nested2 ---

(document (block_node (block_mapping
  (block_mapping_pair key: (_) @yaml.bnest2.kind_key value: (_) @yaml.bnest2.doc_kind)
  (block_mapping_pair key: (_) @yaml.bnest2.metadata_key value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bnest2.name_key value: (_) @yaml.bnest2.doc_name))) )
  (block_mapping_pair key: (_) @yaml.bnest2.a0 value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bnest2.a1 value: (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.bnest2.a2 value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.bnest2.outer_sequence_key value: (block_node (block_sequence
          (block_sequence_item (block_node (block_mapping
            (block_mapping_pair key: (_) @yaml.bnest2.outer_name_key value: (_) @yaml.bnest2.outer_name)
            (block_mapping_pair key: (_) @yaml.bnest2.inner_sequence_key value: (block_node (block_sequence
              (block_sequence_item (block_node (block_mapping
                (block_mapping_pair key: (_) @yaml.bnest2.inner_name_key value: (_) @yaml.bnest2.inner_name)
                (block_mapping_pair key: (_) @yaml.bnest2.nested1_key value: (block_node (block_mapping
                  (block_mapping_pair key: (_) @yaml.bnest2.nested2_key value: (block_node (block_mapping
                    (block_mapping_pair key: (_) @yaml.bnest2.key value: (_) @yaml.bnest2.value))))))))))))))))))))))))))))))) @yaml.bnest2.span

; --- semantic_closure_v3_146_yaml_named_nested_seq_map ---

(document (block_node (block_mapping
  (block_mapping_pair key: (_) @yaml.bseqmap.kind_key value: (_) @yaml.bseqmap.doc_kind)
  (block_mapping_pair key: (_) @yaml.bseqmap.metadata_key value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bseqmap.name_key value: (_) @yaml.bseqmap.doc_name))) )
  (block_mapping_pair key: (_) @yaml.bseqmap.a0 value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bseqmap.a1 value: (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.bseqmap.a2 value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.bseqmap.outer_sequence_key value: (block_node (block_sequence
          (block_sequence_item (block_node (block_mapping
            (block_mapping_pair key: (_) @yaml.bseqmap.outer_name_key value: (_) @yaml.bseqmap.outer_name)
            (block_mapping_pair key: (_) @yaml.bseqmap.inner_sequence_key value: (block_node (block_sequence
              (block_sequence_item (block_node (block_mapping
                (block_mapping_pair key: (_) @yaml.bseqmap.nested1_key value: (block_node (block_mapping
                  (block_mapping_pair key: (_) @yaml.bseqmap.key value: (_) @yaml.bseqmap.value)))))))))))))))))))))))))))) @yaml.bseqmap.span

; --- semantic_closure_v3_146_yaml_named_map2 ---

(document (block_node (block_mapping
  (block_mapping_pair key: (_) @yaml.bmap2.kind_key value: (_) @yaml.bmap2.doc_kind)
  (block_mapping_pair key: (_) @yaml.bmap2.metadata_key value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bmap2.name_key value: (_) @yaml.bmap2.doc_name))) )
  (block_mapping_pair key: (_) @yaml.bmap2.a0 value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bmap2.a1 value: (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.bmap2.a2 value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.bmap2.outer_sequence_key value: (block_node (block_sequence
          (block_sequence_item (block_node (block_mapping
            (block_mapping_pair key: (_) @yaml.bmap2.outer_name_key value: (_) @yaml.bmap2.outer_name)
            (block_mapping_pair key: (_) @yaml.bmap2.nested1_key value: (block_node (block_mapping
              (block_mapping_pair key: (_) @yaml.bmap2.nested2_key value: (block_node (block_mapping
                (block_mapping_pair key: (_) @yaml.bmap2.key value: (_) @yaml.bmap2.value))))))))))))))))))))))))) @yaml.bmap2.span

; --- semantic_closure_v3_146_yaml_named_projected_nested ---

(document (block_node (block_mapping
  (block_mapping_pair key: (_) @yaml.bproj.kind_key value: (_) @yaml.bproj.doc_kind)
  (block_mapping_pair key: (_) @yaml.bproj.metadata_key value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bproj.name_key value: (_) @yaml.bproj.doc_name))) )
  (block_mapping_pair key: (_) @yaml.bproj.a0 value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bproj.a1 value: (block_node (block_mapping
      (block_mapping_pair key: (_) @yaml.bproj.a2 value: (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.bproj.outer_sequence_key value: (block_node (block_sequence
          (block_sequence_item (block_node (block_mapping
            (block_mapping_pair key: (_) @yaml.bproj.outer_name_key value: (_) @yaml.bproj.outer_name)
            (block_mapping_pair key: (_) @yaml.bproj.nested1_key value: (block_node (block_mapping
              (block_mapping_pair key: (_) @yaml.bproj.inner_sequence_key value: (block_node (block_sequence
                (block_sequence_item (block_node (block_mapping
                  (block_mapping_pair key: (_) @yaml.bproj.nested2_key value: (block_node (block_mapping
                    (block_mapping_pair key: (_) @yaml.bproj.key value: (_) @yaml.bproj.value))))))))))))))))))))))))))))))) @yaml.bproj.span

; --- semantic_closure_v3_146_yaml_ingress_like_backend ---

(document (block_node (block_mapping
  (block_mapping_pair key: (_) @yaml.bing.kind_key value: (_) @yaml.bing.doc_kind)
  (block_mapping_pair key: (_) @yaml.bing.metadata_key value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bing.name_key value: (_) @yaml.bing.doc_name))) )
  (block_mapping_pair key: (_) @yaml.bing.a0 value: (block_node (block_mapping
    (block_mapping_pair key: (_) @yaml.bing.outer_sequence_key value: (block_node (block_sequence
      (block_sequence_item (block_node (block_mapping
        (block_mapping_pair key: (_) @yaml.bing.host_key value: (_) @yaml.bing.host_value)
        (block_mapping_pair key: (_) @yaml.bing.nested1_key value: (block_node (block_mapping
          (block_mapping_pair key: (_) @yaml.bing.inner_sequence_key value: (block_node (block_sequence
            (block_sequence_item (block_node (block_mapping
              (block_mapping_pair key: (_) @yaml.bing.path_key value: (_) @yaml.bing.path_value)
              (block_mapping_pair key: (_) @yaml.bing.nested2_key value: (block_node (block_mapping
                (block_mapping_pair key: (_) @yaml.bing.nested3_key value: (block_node (block_mapping
                  (block_mapping_pair key: (_) @yaml.bing.key value: (_) @yaml.bing.value)))))))))))))))))))))))))))) @yaml.bing.span

; --- owned_mapping_sequence_field_v3_149 ---
; Generic mapping field from an item in a sequence directly owned by a mapping object:
; owner_key -> sequence_key -> [ { item_key: item_value, ... } ].
(block_mapping_pair
  key: (_) @yaml.ownedmapseq.owner.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.ownedmapseq.sequence.key
        value: (block_node
          (block_sequence
            (block_sequence_item
              (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.ownedmapseq.item.key
                    value: (_) @yaml.ownedmapseq.item.value) @yaml.ownedmapseq.item.pair))))))))) @yaml.ownedmapseq.owner.pair

; --- owned_nested_sequence_mapping_field_v3_150 ---
; Generic bounded nested sequence field:
; owner_key -> outer_sequence_key -> [ { identity_key: identity_value, inner_sequence_key: [ { field_key: field_value } ] } ].
(block_mapping_pair
  key: (_) @yaml.ownednestedseq.owner.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @yaml.ownednestedseq.outer_sequence.key
        value: (block_node
          (block_sequence
            (block_sequence_item
              (block_node
                (block_mapping
                  (block_mapping_pair
                    key: (_) @yaml.ownednestedseq.identity.key
                    value: (_) @yaml.ownednestedseq.identity.value)
                  (block_mapping_pair
                    key: (_) @yaml.ownednestedseq.inner_sequence.key
                    value: (block_node
                      (block_sequence
                        (block_sequence_item
                          (block_node
                            (block_mapping
                              (block_mapping_pair
                                key: (_) @yaml.ownednestedseq.field.key
                                value: (_) @yaml.ownednestedseq.field.value) @yaml.ownednestedseq.field.pair))))))))))))))) @yaml.ownednestedseq.owner.pair
