; --- completeness_types_high_confidence ---

(class_statement) @type.expression @local.scope
(enum_statement) @type.expression

; --- declaration_category_class ---

(class_statement
  (simple_name) @definition.category.class.name @scope.owner.name
) @definition.category.owner @scope.owner

; --- declaration_category_function ---

; --- declaration_category_method ---

; --- external-neovim-distributed-locals ---

; Omega coverage-first adapted external query
; source=neovim-distributed language=powershell kind=locals
; original baseline: audit-baselines/external/neovim-distributed/powershell/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Scopes
;-------

(class_method_definition) @local.scope

(statement_block) @local.scope

(function_statement) @local.scope

; Definitions
;------------
(class_statement
  (simple_name) @local.definition.type
  (#set! definition.var.scope "parent"))

(class_property_definition
  (variable) @local.definition.field
  (#set! definition.var.scope "parent"))

(class_method_definition
  (simple_name) @local.definition.method
  (#set! definition.var.scope "parent"))

(function_statement
  (function_name) @local.definition.function
  (#set! definition.var.scope "parent"))

; function, script block parameters
(parameter_list
  (script_parameter
    (attribute_list
      (attribute
        (type_literal
          (type_spec) @local.definition.associated)))
    (variable) @local.definition.parameter))

; variable assignment
(assignment_expression
  (left_assignment_expression
    (logical_expression
      (bitwise_expression
        (comparison_expression
          (additive_expression
            (multiplicative_expression
              (format_expression
                (range_expression
                  (array_literal_expression
                    (unary_expression
                      (variable) @local.definition.var)))))))))))

; variable with type assignment
(assignment_expression
  (left_assignment_expression
    (logical_expression
      (bitwise_expression
        (comparison_expression
          (additive_expression
            (multiplicative_expression
              (format_expression
                (range_expression
                  (array_literal_expression
                    (unary_expression
                      (expression_with_unary_operator
                        (cast_expression
                          (type_literal
                            (type_spec) @local.definition.associated)
                          (unary_expression
                            (variable) @local.definition.var))))))))))))))

; data sections
(data_name
  (simple_name) @local.definition.var)

; References
;-----------
(variable) @local.reference

(command_name) @local.reference

(invokation_expression
  (variable) @_variable
  (member_name
    (simple_name) @local.reference)
  (#eq? @_variable "$this"))

; --- named_scope_owners ---

(function_statement
  (function_name) @scope.owner.name
  (script_block) @scope.owner.body) @scope.owner

; --- ownership_members ---

(class_statement
  (simple_name) @owner.name
  (class_method_definition
    (simple_name) @owned.member.name) @owned.member) @owner.span

; --- ownership_parameters ---

(function_statement
  (function_name) @owner.name
  (function_parameter_declaration
    (parameter_list
      (script_parameter) @owned.parameter))
  (script_block) @owner.body) @owner.span

; --- signature_parameters ---

(function_statement
  (function_name) @definition.signature.name
  (function_parameter_declaration) @definition.signature.parameters
) @definition.signature.owner

(class_method_definition
  (simple_name) @definition.signature.name
  (class_method_parameter_list) @definition.signature.parameters
) @definition.signature.owner

; --- terminal_powershell_command_calls_v1 ---
(command command_name: (command_name) @powershell.call.name) @powershell.call
(command command_name: (command_name_expr) @powershell.call.dynamic_name) @powershell.call.dynamic

; --- semantic_closure_v3_146_batch2 ---

(enum_statement (simple_name) @powershell.enum.name) @powershell.enum
(enum_member (simple_name) @powershell.enum.member.name) @powershell.enum.member
(attribute (attribute_name) @powershell.attribute.name) @powershell.attribute

((command command_name: (command_name) @powershell.import.module) @powershell.import (#eq? @powershell.import.module "Import-Module"))

; --- semantic_closure_v3_146_batch3 ---

(foreach_statement
  (variable) @powershell.foreach.binding
  (pipeline) @powershell.foreach.sequence) @powershell.foreach

(class_property_definition
  (type_literal) @powershell.property.type
  (variable) @powershell.property.name) @powershell.property

(class_method_definition
  (type_literal) @powershell.method.return_type
  (simple_name) @powershell.method.name) @powershell.method

(redirection
  (file_redirection_operator) @powershell.redirection.operator
  (redirected_file_name) @powershell.redirection.target) @powershell.redirection

(hash_entry
  (key_expression) @powershell.hashtable.key) @powershell.hashtable.entry

((command
  command_name: (command_name) @powershell.import.command
  command_elements: (command_elements
    (string_literal) @powershell.import.module_argument)) @powershell.import.literal
 (#eq? @powershell.import.command "Import-Module"))

