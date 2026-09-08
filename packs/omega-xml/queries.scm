; --- ancestor_grandchild_attribute_context ---

; Bounded XML ancestor -> intermediate -> grandchild attribute context.
; Generic syntax only. One authored ancestor attribute and one authored
; grandchild attribute are captured across exactly two element edges.
; Namespace/schema/framework semantics are left to overlays.

(element
  (start_tag
    (tag_name) @xml.ancestor_grandchild.ancestor_tag
    (attribute
      (attribute_name) @xml.ancestor_grandchild.ancestor_attribute_name
      (attribute_value) @xml.ancestor_grandchild.ancestor_attribute_value))
  (element
    (start_tag
      (tag_name) @xml.ancestor_grandchild.intermediate_tag)
    (empty_elem_tag
      (tag_name) @xml.ancestor_grandchild.descendant_tag
      (attribute
        (attribute_name) @xml.ancestor_grandchild.descendant_attribute_name
        (attribute_value) @xml.ancestor_grandchild.descendant_attribute_value)) @xml.ancestor_grandchild.descendant_element) @xml.ancestor_grandchild.intermediate_element) @xml.ancestor_grandchild.context

(element
  (start_tag
    (tag_name) @xml.ancestor_grandchild.ancestor_tag
    (attribute
      (attribute_name) @xml.ancestor_grandchild.ancestor_attribute_name
      (attribute_value) @xml.ancestor_grandchild.ancestor_attribute_value))
  (element
    (start_tag
      (tag_name) @xml.ancestor_grandchild.intermediate_tag)
    (element
      (start_tag
        (tag_name) @xml.ancestor_grandchild.descendant_tag
        (attribute
          (attribute_name) @xml.ancestor_grandchild.descendant_attribute_name
          (attribute_value) @xml.ancestor_grandchild.descendant_attribute_value)) @xml.ancestor_grandchild.descendant_element) @xml.ancestor_grandchild.intermediate_element)) @xml.ancestor_grandchild.context

; --- attribute_def_definition ---

(attribute_def (attribute_name) @xml.attribute_def.name) @xml.attribute_def

; --- coordinate_entries ---

(element
  (start_tag (tag_name) @xml.parent.tag)
  (element
    (start_tag (tag_name) @xml.group.tag)
    (text) @xml.group.value)
  (element
    (start_tag (tag_name) @xml.artifact.tag)
    (text) @xml.artifact.value)) @xml.coordinates

; --- depth3_descendant_attribute_context ---

; Generic bounded XML depth-3 descendant attribute context.
; Captures one authored ancestor attribute, one direct-child attribute, an
; intermediate grandchild tag, and one great-grandchild attribute.
; Framework/schema semantics are intentionally absent.

(element
  (start_tag
    (tag_name) @xml.d3.ancestor_tag
    (attribute
      (attribute_name) @xml.d3.ancestor_attribute_name
      (attribute_value) @xml.d3.ancestor_attribute_value))
  (element
    (start_tag
      (tag_name) @xml.d3.child_tag
      (attribute
        (attribute_name) @xml.d3.child_attribute_name
        (attribute_value) @xml.d3.child_attribute_value))
    (element
      (start_tag
        (tag_name) @xml.d3.intermediate_tag)
      (empty_elem_tag
        (tag_name) @xml.d3.descendant_tag
        (attribute
          (attribute_name) @xml.d3.descendant_attribute_name
          (attribute_value) @xml.d3.descendant_attribute_value)) @xml.d3.descendant_element) @xml.d3.intermediate_element) @xml.d3.child_element) @xml.d3.context

(element
  (start_tag
    (tag_name) @xml.d3.ancestor_tag
    (attribute
      (attribute_name) @xml.d3.ancestor_attribute_name
      (attribute_value) @xml.d3.ancestor_attribute_value))
  (element
    (start_tag
      (tag_name) @xml.d3.child_tag
      (attribute
        (attribute_name) @xml.d3.child_attribute_name
        (attribute_value) @xml.d3.child_attribute_value))
    (element
      (start_tag
        (tag_name) @xml.d3.intermediate_tag)
      (element
        (start_tag
          (tag_name) @xml.d3.descendant_tag
          (attribute
            (attribute_name) @xml.d3.descendant_attribute_name
            (attribute_value) @xml.d3.descendant_attribute_value)) @xml.d3.descendant_element) @xml.d3.intermediate_element) @xml.d3.child_element)) @xml.d3.context

; --- element_attribute_context ---

(element
  (start_tag
    (tag_name) @xml.element_attribute.tag
    (attribute
      (attribute_name) @xml.element_attribute.name
      (attribute_value) @xml.element_attribute.value) @xml.element_attribute.attribute)) @xml.element_attribute.element

(empty_elem_tag
  (tag_name) @xml.empty_element_attribute.tag
  (attribute
    (attribute_name) @xml.empty_element_attribute.name
    (attribute_value) @xml.empty_element_attribute.value) @xml.empty_element_attribute.attribute) @xml.empty_element_attribute.element

; --- element_decl_definition ---

(element_decl (element_name) @xml.element_decl.name) @xml.element_decl

; --- element_two_attribute_context ---

; Framework-neutral direct XML same-element two-attribute context.
; Captures two authored attributes in source order from the same start/empty tag.

(element
  (start_tag
    (tag_name) @xml.two_attr.tag
    (attribute
      (attribute_name) @xml.two_attr.name1
      (attribute_value) @xml.two_attr.value1)
    (attribute
      (attribute_name) @xml.two_attr.name2
      (attribute_value) @xml.two_attr.value2))
  ) @xml.two_attr.element

(empty_elem_tag
  (tag_name) @xml.two_attr.tag
  (attribute
    (attribute_name) @xml.two_attr.name1
    (attribute_value) @xml.two_attr.value1)
  (attribute
    (attribute_name) @xml.two_attr.name2
    (attribute_value) @xml.two_attr.value2)) @xml.two_attr.element

; --- entity_reference ---

(entity_ref) @xml.entity.ref

; --- parameter_entity_reference ---

(pe_reference) @xml.pe.ref

; --- parent_child_attribute_context ---

; Direct XML parent->child element attribute context.
; Generic syntax only: one authored parent attribute and one authored direct-child
; attribute are captured together. Namespace/resource semantics are left to overlays.

(element
  (start_tag
    (tag_name) @xml.parent_child.parent_tag
    (attribute
      (attribute_name) @xml.parent_child.parent_attribute_name
      (attribute_value) @xml.parent_child.parent_attribute_value))
  (element
    (start_tag
      (tag_name) @xml.parent_child.child_tag
      (attribute
        (attribute_name) @xml.parent_child.child_attribute_name
        (attribute_value) @xml.parent_child.child_attribute_value))) @xml.parent_child.child_element) @xml.parent_child.context

(element
  (start_tag
    (tag_name) @xml.parent_child.parent_tag
    (attribute
      (attribute_name) @xml.parent_child.parent_attribute_name
      (attribute_value) @xml.parent_child.parent_attribute_value))
  (empty_elem_tag
    (tag_name) @xml.parent_child.child_tag
    (attribute
      (attribute_name) @xml.parent_child.child_attribute_name
      (attribute_value) @xml.parent_child.child_attribute_value)) @xml.parent_child.child_element) @xml.parent_child.context

; --- parent_child_text ---

(element
  (start_tag (tag_name) @xml.parent.tag)
  (element
    (start_tag (tag_name) @xml.child.tag)
    (text) @xml.child.value)) @xml.parent_child_text

; --- shared_grammar_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED SHARED-GRAMMAR DIALECT STRUCTURAL QUERY
; language=xml; shared_grammar=msbuild
(attribute_name) @structural.attribute

; --- structure-v2 ---

(document) @data.document

(element
  (start_tag
    (tag_name) @data.element.name)) @data.element

(empty_elem_tag
  (tag_name) @data.element.name) @data.element

(attribute
  (attribute_name) @data.attribute.name) @data.attribute

(text) @data.text
(document (element) @data.document.element) @data.document.container
(element (start_tag (attribute) @data.element.attribute)) @data.element.container
(empty_elem_tag (attribute) @data.element.attribute) @data.empty_element.container
(element (element) @data.element.child) @data.element.parent
(element (empty_elem_tag) @data.element.child) @data.element.parent
