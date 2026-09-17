; omega-xml
;
; XML is the file format of configuration, project definitions and schemas.
; The questions asked of an XML file are: where is this element configured,
; what does this attribute set, what does this document depend on, and what
; does this entity refer to. Every pattern below answers one of them.
;
; Containment is deliberately not stated. The tree already holds it, an
; element's extent is emitted as a scope, and a pattern per depth costs one
; match per tuple of nodes at that depth.

; --- an element ---
;
; Both spellings, `<a>...</a>` and `<a/>`, are one pattern. The declaration
; and the scope are two templates over this one match.

(element
  [(start_tag (tag_name) @element.name)
   (empty_elem_tag (tag_name) @element.name)]) @element

; --- the value a leaf element holds ---
;
; `<port>8080</port>` states that `port` is 8080. The text is carried on the
; element's own declaration, not emitted as a mention: it is a value, and a
; mention of it would resolve against nothing.

(element
  (start_tag (tag_name) @element.text.name)
  (text) @element.text.value) @element.text

; --- an attribute ---
;
; `port="8080"` is where `port` is set, so the attribute is declared under its
; own name and carries its value.

(attribute
  (attribute_name) @attribute.name
  (attribute_value) @attribute.value) @attribute

; --- what the prolog points at ---

(doctype_decl (doctype) @doctype.root) @doctype

(external_id [(system_literal) (pubid_literal)] @external.literal) @external

(processing_instructions (pi_target) @pi.target) @pi

; --- the DTD: the one place XML declares a shape ---

(element_decl (element_name) @element_decl.name) @element_decl

(attlist_decl (attlist_name) @attlist.element) @attlist

(attribute_def (attribute_name) @attribute_def.name) @attribute_def

(notation_decl (notation_name) @notation.name) @notation

; The entity name is an anonymous token in this grammar, so the declaration is
; captured whole and named from its first word.

(entity_decl (ge_decl) @entity.general.body) @entity.general

(entity_decl (pe_decl) @entity.parameter.body) @entity.parameter

; --- the links XML has ---
;
; `&name;` and `%name;` are stripped to the name they refer to, so they resolve
; against the declarations above.

(entity_ref) @entity.ref

(pe_reference) @pe.ref
