; --- completeness_types_high_confidence ---

(enum_type_definition) @type.expression
(input_object_type_definition) @type.expression
(interface_type_definition) @type.expression
(object_type_definition) @type.expression @structural.candidate
(root_operation_type_definition) @type.expression
(scalar_type_definition) @type.expression
(type_definition) @type.expression
(union_type_definition) @type.expression

; --- distributed_web_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED structural query.
; External Neovim query body is NOT copied. Exact parser-target evidence: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-graphql/main/parser.json
; Structural node fact observed at: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-graphql/main/queries/highlights.scm

; --- root_field_schema_context ---

; Framework-neutral GraphQL root operation field -> named response/input type context.
; Covers Query/Mutation/Subscription structurally; framework overlays decide which owners are operation roots.

; Response named type, direct.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (named_type (name) @graphql.root_field.response_type)) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Response named type, non-null.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (non_null_type (named_type (name) @graphql.root_field.response_type))) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Response named type, list.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (list_type (type (named_type (name) @graphql.root_field.response_type)))) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Response named type, list item non-null.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (list_type (type (non_null_type (named_type (name) @graphql.root_field.response_type))))) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Response named type, outer non-null list.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (non_null_type (list_type (type (named_type (name) @graphql.root_field.response_type))))) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Response named type, outer non-null list with non-null item.
(object_type_definition
  (name) @graphql.root_field.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_field.field_name
      (type (non_null_type (list_type (type (non_null_type (named_type (name) @graphql.root_field.response_type)))))) @graphql.root_field.type) @graphql.root_field.field)) @graphql.root_field.owner

; Request argument named type, direct.
(object_type_definition
  (name) @graphql.root_arg.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_arg.field_name
      (arguments_definition
        (input_value_definition
          (name) @graphql.root_arg.argument_name
          (type (named_type (name) @graphql.root_arg.argument_type)) @graphql.root_arg.type) @graphql.root_arg.argument) ) @graphql.root_arg.field)) @graphql.root_arg.owner

; Request argument named type, non-null.
(object_type_definition
  (name) @graphql.root_arg.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_arg.field_name
      (arguments_definition
        (input_value_definition
          (name) @graphql.root_arg.argument_name
          (type (non_null_type (named_type (name) @graphql.root_arg.argument_type))) @graphql.root_arg.type) @graphql.root_arg.argument) ) @graphql.root_arg.field)) @graphql.root_arg.owner

; Request argument named type, list.
(object_type_definition
  (name) @graphql.root_arg.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_arg.field_name
      (arguments_definition
        (input_value_definition
          (name) @graphql.root_arg.argument_name
          (type (list_type (type (named_type (name) @graphql.root_arg.argument_type)))) @graphql.root_arg.type) @graphql.root_arg.argument) ) @graphql.root_arg.field)) @graphql.root_arg.owner

; Request argument named type, list item non-null / outer wrappers.
(object_type_definition
  (name) @graphql.root_arg.owner_type
  (fields_definition
    (field_definition
      (name) @graphql.root_arg.field_name
      (arguments_definition
        (input_value_definition
          (name) @graphql.root_arg.argument_name
          (type (non_null_type (list_type (type (non_null_type (named_type (name) @graphql.root_arg.argument_type)))))) @graphql.root_arg.type) @graphql.root_arg.argument) ) @graphql.root_arg.field)) @graphql.root_arg.owner

; --- schema_semantics ---

; Omega-owned GraphQL schema/executable semantics.
; Node shapes are derived from the exact pinned tree-sitter-graphql node-types contract.

(object_type_definition (name) @definition.object_type)
(interface_type_definition (name) @definition.interface_type)
(input_object_type_definition (name) @definition.input_object_type)
(enum_type_definition (name) @definition.enum_type)
(scalar_type_definition (name) @definition.scalar_type)
(directive_definition (name) @definition.directive)
(field_definition (name) @definition.field)
(input_value_definition (name) @definition.input_value)
(enum_value_definition (enum_value (name) @definition.enum_value))
(fragment_definition (fragment_name (name) @definition.fragment))
(operation_definition (name) @definition.operation)

(named_type (name) @reference.type)
(fragment_spread (fragment_name (name) @reference.fragment))
(field (name) @reference.field)
(directive (name) @reference.directive)

; --- terminal_graphql_extension_schema_variables_v1 ---
(object_type_extension (name) @graphql.extension.object.name) @graphql.extension.object
(interface_type_extension (name) @graphql.extension.interface.name) @graphql.extension.interface
(input_object_type_extension (name) @graphql.extension.input.name) @graphql.extension.input
(enum_type_extension (name) @graphql.extension.enum.name) @graphql.extension.enum
(scalar_type_extension (name) @graphql.extension.scalar.name) @graphql.extension.scalar
(union_type_extension (name) @graphql.extension.union.name) @graphql.extension.union

(variable_definition (variable) @graphql.variable.name (type) @graphql.variable.type) @graphql.variable.definition

; --- semantic_closure_v3_146_batch2 ---

(implements_interfaces (named_type) @graphql.implements.type) @graphql.implements
(union_type_definition (name) @graphql.union.name (union_member_types (named_type) @graphql.union.member)) @graphql.union

(directive_definition (name) @graphql.directive.name (directive_locations) @graphql.directive.locations) @graphql.directive
(argument (name) @graphql.argument.name (value) @graphql.argument.value) @graphql.argument

; --- semantic_closure_v3_147_graphql_surface ---
(object_type_definition (name) @graphql.implements.owner (implements_interfaces (named_type (name) @graphql.implements.target)) @graphql.implements.edge)
(interface_type_definition (name) @graphql.interface_implements.owner (implements_interfaces (named_type (name) @graphql.interface_implements.target)) @graphql.interface_implements.edge)
(union_type_definition (name) @graphql.union_ref.owner (union_member_types (named_type (name) @graphql.union_ref.target)) @graphql.union_ref.edge)
(directive_definition (name) @graphql.directive_arg.owner (arguments_definition (input_value_definition (name) @graphql.directive_arg.name (type) @graphql.directive_arg.type) @graphql.directive_arg.definition))
(directive_definition (name) @graphql.directive_location.owner (directive_locations (directive_location) @graphql.directive_location.value) @graphql.directive_location.edge)
(input_value_definition (name) @graphql.default.owner (type) @graphql.default.type (default_value) @graphql.default.explicit) @graphql.default.definition
