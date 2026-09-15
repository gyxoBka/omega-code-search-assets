; --- call_targets ---

(call_suffix
  name: (_) @call.target) @call.expression

; --- completeness_imports_3 ---

(import_declaration) @import.expression

; --- completeness_types_high_confidence ---

(class_declaration) @type.expression
(protocol_declaration) @type.expression

; --- declaration_category_class ---

(class_declaration
  name: (_) @definition.category.class.name
) @definition.category.owner

; --- declaration_category_constructor ---

(constructor_suffix
  name: (_) @definition.category.constructor.name
) @definition.category.owner

; --- declaration_category_enum ---

(enum_entry
  name: (_) @definition.category.enum.name
) @definition.category.owner

(enum_type_parameters
  name: (_) @definition.category.enum.name
) @definition.category.owner

; --- declaration_category_function ---

(function_declaration
  name: (_) @definition.category.function.name
) @definition.category.owner

(function_type
  name: (_) @definition.category.function.name
) @definition.category.owner

(protocol_function_declaration
  name: (_) @definition.category.function.name
) @definition.category.owner

; --- declaration_category_property ---

(property_declaration
  name: (_) @definition.category.property.name
) @definition.category.owner

; --- declaration_category_protocol ---

(protocol_declaration
  name: (_) @definition.category.protocol.name
) @definition.category.owner

(protocol_property_declaration
  name: (_) @definition.category.protocol.name
) @definition.category.owner

; --- declaration_category_type ---

(associatedtype_declaration
  name: (_) @definition.category.type.name
) @definition.category.owner

(tuple_type_item
  name: (_) @definition.category.type.name
) @definition.category.owner

(typealias_declaration
  name: (_) @definition.category.type.name
) @definition.category.owner

; --- declaration_modifiers ---

(associatedtype_declaration
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(class_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(class_declaration
  name: (_) @definition.modifiers.name
  (property_behavior_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(enum_entry
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(function_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(function_declaration
  name: (_) @definition.modifiers.name
  (property_behavior_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(property_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(property_declaration
  name: (_) @definition.modifiers.name
  (property_behavior_modifier) @definition.modifiers.modifier
) @definition.modifiers.owner

(protocol_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(protocol_function_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(protocol_property_declaration
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(subscript_declaration
  name: (_) @definition.modifiers.name
  (modifiers) @definition.modifiers.modifier
) @definition.modifiers.owner

(typealias_declaration
  (modifiers) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

(typealias_declaration
  (property_behavior_modifier) @definition.modifiers.modifier
  name: (_) @definition.modifiers.name
) @definition.modifiers.owner

; --- definition_identity_hints ---

(associatedtype_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(class_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(enum_entry
  name: (_) @definition.identity.name) @definition.identity.owner

(function_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(function_type
  name: (_) @definition.identity.name) @definition.identity.owner

(property_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(protocol_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(protocol_function_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(protocol_property_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

(tuple_type_item
  name: (_) @definition.identity.name) @definition.identity.owner

(typealias_declaration
  name: (_) @definition.identity.name) @definition.identity.owner

; --- enclosing_owner_hints ---

(class_declaration 
  name: (_) @scope.enclosing_owner.name
  body: (_) @scope.enclosing_owner.body
) @scope.enclosing_owner.span

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=swift kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/swift/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

(import_declaration
  (identifier) @local.definition.import)

(function_declaration
  name: (simple_identifier) @local.definition.function)

; Scopes
[
  (statements)
  (for_statement)
  (while_statement)
  (repeat_while_statement)
  (do_statement)
  (if_statement)
  (guard_statement)
  (switch_statement)
  (property_declaration)
  (function_declaration)
  (class_declaration)
  (protocol_declaration)
] @local.scope

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: Apache-2.0
; source=audit-baselines/external/nvim-treesitter/swift/locals.scm
; sha256=25a2cc839769cdd69791e9db4832fd232844b7e69a86231a34d046c55d883e52

(import_declaration
  (identifier) @local.definition.import)

(function_declaration
  name: (simple_identifier) @local.definition.function)

; Scopes
[
  (statements)
  (for_statement)
  (while_statement)
  (repeat_while_statement)
  (do_statement)
  (if_statement)
  (guard_statement)
  (switch_statement)
  (property_declaration)
  (function_declaration)
  (class_declaration)
  (protocol_declaration)
] @local.scope

; --- member_category_class ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member_category.class.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (class_declaration
      name: (_) @owned.member_category.class.name) @owned.member)) @owner.span

; --- member_category_enum ---

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (enum_entry
      name: (_) @owned.member_category.enum.name) @owned.member)) @owner.span

; --- member_category_function ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (function_declaration
      name: (_) @owned.member_category.function.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (function_declaration
      name: (_) @owned.member_category.function.name) @owned.member)) @owner.span

; --- member_category_property ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (property_declaration
      name: (_) @owned.member_category.property.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (property_declaration
      name: (_) @owned.member_category.property.name) @owned.member)) @owner.span

; --- member_category_protocol ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (protocol_declaration
      name: (_) @owned.member_category.protocol.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (protocol_declaration
      name: (_) @owned.member_category.protocol.name) @owned.member)) @owner.span

; --- member_category_type ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (associatedtype_declaration
      name: (_) @owned.member_category.type.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (typealias_declaration
      name: (_) @owned.member_category.type.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (associatedtype_declaration
      name: (_) @owned.member_category.type.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (typealias_declaration
      name: (_) @owned.member_category.type.name) @owned.member)) @owner.span

; --- module_path_hints ---

(import_declaration
  (identifier) @import.module_path.target) @import.module_path.statement

; --- named_array_string_argument_context ---

(call_expression
  (simple_identifier) @swift.named_array.call_name
  (call_suffix
    (value_arguments
      (value_argument
        name: (value_argument_label
          (simple_identifier) @swift.named_array.argument_name)
        value: (array_literal
          element: (line_string_literal) @swift.named_array.value))))
) @swift.named_array.call_context

; --- named_scope_owners ---

(class_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- named_string_argument_context ---

(call_expression
  (simple_identifier) @swift.named_string.call_name
  (call_suffix
    (value_arguments
      (value_argument
        name: (value_argument_label
          (simple_identifier) @swift.named_string.argument_name)
        value: (line_string_literal) @swift.named_string.value)))
) @swift.named_string.call_context

; --- nvim_pinned_injections ---

; OMEGA EXTERNAL QUERY BASELINE — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; resolved_sha256=da7c2b36de7e8d17fd10bd5b3bba3563b9445dfba06646a937d615da20c60c29
; source_name=swift

; ----- resolved nvim injections source: swift sha256=da7c2b36de7e8d17fd10bd5b3bba3563b9445dfba06646a937d615da20c60c29 -----
((regex_literal) @injection.content
  (#set! injection.language "regex"))

([
  (comment)
  (multiline_comment)
] @injection.content
  (#set! injection.language "comment"))

; --- nvim_pinned_locals ---

; OMEGA EXTERNAL BASELINE ADAPTATION — CONTENT-ADDRESSED PROVENANCE
; provider=nvim-treesitter
; snapshot_marker=e82ef6ae2c3eeb96c6916b29917f96bf630b2cdb
; root_source_sha256=25a2cc839769cdd69791e9db4832fd232844b7e69a86231a34d046c55d883e52
; resolved_query_sha256=6d79dd0553251bfa9cdafac9c12c56784e56acec49e660be0d940799ce8ae510
; parser_revision=7b7909f2f6b9414be0958275f4c8e5d69c3bca43
; source_name=swift
; direct_inherits=
; resolved_sources=swift

; ----- resolved nvim locals source: swift sha256=25a2cc839769cdd69791e9db4832fd232844b7e69a86231a34d046c55d883e52 -----
(import_declaration
  (identifier) @local.definition.import)

(function_declaration
  name: (simple_identifier) @local.definition.function)

; Scopes
[
  (statements)
  (for_statement)
  (while_statement)
  (repeat_while_statement)
  (do_statement)
  (if_statement)
  (guard_statement)
  (switch_statement)
  (property_declaration)
  (function_declaration)
  (class_declaration)
  (protocol_declaration)
] @local.scope

; --- ownership_members ---

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (associatedtype_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (function_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (init_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (property_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (protocol_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (subscript_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (class_body
    (typealias_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (associatedtype_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (class_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (enum_entry
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (function_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (init_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (property_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (protocol_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (subscript_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(class_declaration
  name: (_) @owner.name
  body: (enum_class_body
    (typealias_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- receiver_hints ---

(self_expression) @reference.receiver

(super_expression) @reference.receiver

; --- signature_return_type ---

(function_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(function_type
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

(protocol_function_declaration
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- static_delta ---

(call_expression) @call.expression
(navigation_expression) @reference.navigation
(import_declaration) @module.import
(inheritance_specifier
  inherits_from: (_) @relation.supertype) @relation.inheritance

[(line_string_literal) (multi_line_string_literal) (boolean_literal)] @data.literal

; --- swift_class_method_context ---

(class_declaration
  name: (type_identifier) @swift.class_method.owner_class
  (inheritance_specifier
    inherits_from: (user_type) @swift.class_method.superclass)
  body: (class_body
    (function_declaration
      name: (simple_identifier) @swift.class_method.method_name) @swift.class_method.method)) @swift.class_method.class

; --- swift_computed_property_direct_call_context ---

; Generic Swift owner -> computed-property -> direct-call context.
; Framework-neutral: it captures only source structure. Type/protocol semantics
; and call target identity remain downstream obligations.

(class_declaration
  name: (type_identifier) @swift.computed_call.owner_type
  body: (class_body
    (property_declaration
      name: (pattern
        bound_identifier: (simple_identifier) @swift.computed_call.property_name)
      computed_value: (computed_property
        (statements
          (call_expression
            (simple_identifier) @swift.computed_call.callee_name
            (call_suffix)) @swift.computed_call.call))) @swift.computed_call.property)) @swift.computed_call.owner

; --- upstream_tags ---

(class_declaration
  name: (type_identifier) @name) @definition.class

(protocol_declaration
  name: (type_identifier) @name) @definition.interface

(class_declaration
    (class_body
        [
            (function_declaration
                name: (simple_identifier) @name
            )
            (subscript_declaration
                (parameter (simple_identifier) @name)
            )
            (init_declaration "init" @name)
            (deinit_declaration "deinit" @name)
        ]
    )
) @definition.method

(protocol_declaration
    (protocol_body
        [
            (protocol_function_declaration
                name: (simple_identifier) @name
            )
            (subscript_declaration
                (parameter (simple_identifier) @name)
            )
            (init_declaration "init" @name)
        ]
    )
) @definition.method

(class_declaration
    (class_body
        [
            (property_declaration
                (pattern (simple_identifier) @name)
            )
        ]
    )
) @definition.property

(property_declaration
    (pattern (simple_identifier) @name)
) @definition.property

(function_declaration
    name: (simple_identifier) @name) @definition.function

; --- nominal_conformance_context ---

(class_declaration
  name: (_) @swift.conformance.owner_type
  (inheritance_specifier
    inherits_from: (user_type) @swift.conformance.inherited_type)) @swift.conformance.owner

; --- swift_receiver_member_string_argument_context ---

(call_expression
  (navigation_expression
    target: (simple_identifier) @swift.member_string.receiver
    suffix: (navigation_suffix
      suffix: (simple_identifier) @swift.member_string.member))
  (call_suffix
    (value_arguments
      . (value_argument
          value: (line_string_literal
            text: (line_str_text) @swift.member_string.arg0))))) @swift.member_string.call

; --- framework_neutral_swift_property_attribute_v1 ---

(class_declaration
  name: (_) @swift.attrprop.owner_type
  body: (class_body
    (property_declaration
      (attribute
        [(simple_identifier) (user_type (type_identifier))] @swift.attrprop.attribute_name)
      name: (_) @swift.attrprop.property_name) @swift.attrprop.property)) @swift.attrprop.owner


; --- semantic_closure_v3_146_swift_receiver_member_literal_segments ---

(call_expression
  (navigation_expression
    target: (simple_identifier) @swift.member_segment.receiver
    suffix: (navigation_suffix
      suffix: (simple_identifier) @swift.member_segment.member))
  (call_suffix
    (value_arguments
      (value_argument
        name: (value_argument_label)? @swift.member_segment.arg_label
        value: (line_string_literal
          text: (line_str_text) @swift.member_segment.literal) @swift.member_segment.literal_node) @swift.member_segment.argument))) @swift.member_segment.call
