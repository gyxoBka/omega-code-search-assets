; --- call_targets ---

(call_expression
  function: (_) @call.target) @call.expression

(call_struct_argument
  name: (_) @call.target) @call.expression

(yul_function_call
  function: (_) @call.target) @call.expression

; --- completeness_types_high_confidence ---

(enum_declaration) @type.expression
(interface_declaration) @type.expression
(struct_declaration) @type.expression
(user_defined_type_definition) @type.expression

; --- declaration_category_constant ---

(constant_variable_declaration
  name: (_) @definition.category.constant.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_enum ---

(enum_declaration
  name: (_) @definition.category.enum.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_event ---

(event_definition
  name: (_) @definition.category.event.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(event_parameter
  name: (_) @definition.category.event.name
) @definition.category.owner

; --- declaration_category_function ---

(function_definition
  name: (_) @definition.category.function.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_interface ---

(interface_declaration
  name: (_) @definition.category.interface.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_struct ---

(struct_declaration
  name: (_) @definition.category.struct.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(struct_field_assignment
  name: (_) @definition.category.struct.name
) @definition.category.owner

(struct_member
  name: (_) @definition.category.struct.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_type ---

(user_defined_type_definition
  name: (_) @definition.category.type.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_variable ---

(state_variable_declaration
  name: (_) @definition.category.variable.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(variable_declaration
  name: (_) @definition.category.variable.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_visibility ---

(function_definition
  name: (_) @definition.visibility.name
  (visibility) @definition.visibility.modifier
) @definition.visibility.owner

; --- definition_identity_hints ---

; --- distributed_web_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED structural query.
; External Neovim query body is NOT copied. Exact parser-target evidence: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-solidity/main/parser.json
; Structural node fact observed at: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-solidity/main/queries/highlights.scm
(contract_declaration) @structural.candidate

; --- enclosing_owner_hints ---

(interface_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(struct_declaration 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- import_alias_hints ---

(import_directive
  source: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- import_targets ---

(import_directive
  source: (_) @import.target @import.module_path.target) @import.statement @import.module_path.statement

(using_directive
  source: (_) @import.target) @import.statement

; --- member_access_hints ---

(member_expression
  object: (_) @reference.receiver
  property: (_) @reference.member) @reference.member_expression

; --- member_category_enum ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (enum_declaration
      name: (_) @owned.member_category.enum.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (enum_declaration
      name: (_) @owned.member_category.enum.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_event ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (event_definition
      name: (_) @owned.member_category.event.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (event_definition
      name: (_) @owned.member_category.event.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_function ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (function_definition
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (function_definition
      name: (_) @owned.member_category.function.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_struct ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (struct_declaration
      name: (_) @owned.member_category.struct.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (struct_declaration
      name: (_) @owned.member_category.struct.name @owned.member.name) @owned.member)) @owner.span

(struct_declaration
  name: (_) @owner.name
  body: (struct_body
    (struct_member
      name: (_) @owned.member_category.struct.name @owned.member.name) @owned.member)) @owner.span

; --- member_category_type ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (user_defined_type_definition
      name: (_) @owned.member_category.type.name @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (user_defined_type_definition
      name: (_) @owned.member_category.type.name @owned.member.name) @owned.member)) @owner.span

; --- module_path_hints ---

; --- named_scope_owners ---

(contract_declaration
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

(function_definition
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_members ---

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (error_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (modifier_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span

(contract_declaration
  name: (_) @owner.name
  body: (contract_body
    (state_variable_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (error_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (modifier_definition
      name: (_) @owned.member.name) @owned.member)) @owner.span

(interface_declaration
  name: (_) @owner.name
  body: (contract_body
    (state_variable_declaration
      name: (_) @owned.member.name) @owned.member)) @owner.span

; --- signature_return_type ---

(function_definition
  name: (_) @definition.signature.name
  return_type: (_) @definition.signature.return_type
) @definition.signature.owner

; --- upstream_locals_exact ---

; Exact pinned upstream locals query adapted into Omega P0 staging.
; source: JoranHonig/tree-sitter-solidity@048fe686cb1fde267243739b8bdbec8fc3a55272/queries/locals.scm
(function_definition) @local.scope
(block_statement) @local.scope
(function_definition (parameter name: (_) @local.definition))
(assignment_expression left: (_) @local.definition)
(identifier) @local.reference

; --- upstream_tags_exact ---

; Exact pinned upstream tags query adapted into Omega P0 staging.
; source: JoranHonig/tree-sitter-solidity@048fe686cb1fde267243739b8bdbec8fc3a55272/queries/tags.scm
(contract_declaration (_ (function_definition name: (identifier) @name) @definition.method))
(source_file (function_definition name: (identifier) @name) @definition.function)
(contract_declaration name: (identifier) @name) @definition.class
(interface_declaration name: (identifier) @name) @definition.interface
(library_declaration name: (identifier) @name) @definition.interface
(struct_declaration name: (identifier) @name) @definition.class
(enum_declaration name: (identifier) @name) @definition.class
(event_definition name: (identifier) @name) @definition.class
(call_expression (expression (identifier)) @name) @reference.call
(call_expression (expression (member_expression property: (_) @name))) @reference.call
(emit_statement name: (_) @name) @reference.class
(inheritance_specifier ancestor: (user_defined_type (_) @name .)) @reference.class
(import_directive import_name: (_) @name) @reference.unknown

; --- terminal_solidity_special_definitions_v2 ---
(constructor_definition) @solidity.constructor.definition
(fallback_receive_definition) @solidity.fallback_receive.definition
(enum_declaration
  name: (identifier) @solidity.enum.value.owner
  body: (enum_body (enum_value) @solidity.enum.value)) @solidity.enum.value.context
(yul_function_definition (yul_identifier) @solidity.yul.function.name) @solidity.yul.function
