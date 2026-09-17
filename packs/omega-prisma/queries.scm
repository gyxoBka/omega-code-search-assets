; --- completeness_calls_5 ---

(call_expression) @call.expression

; --- completeness_definitions_high_confidence ---

(enum_declaration) @definition.expression @type.expression
(model_declaration) @definition.expression
(type_declaration) @definition.expression @type.expression

; --- completeness_references ---

(member_expression) @reference.symbol

; --- completeness_scopes ---

(enum_block) @scope.lexical
(statement_block) @scope.lexical

; --- completeness_types_high_confidence ---


; --- declaration_category_enum ---

(enum_declaration
  (identifier) @definition.category.enum.name @definition.identity.name @prisma.enum.name
) @definition.category.owner @definition.identity.owner @prisma.enum

; --- declaration_category_model ---

(model_declaration
  (identifier) @definition.category.model.name @definition.identity.name @prisma.model.name
) @definition.category.owner @definition.identity.owner @prisma.model

; --- declaration_category_type ---

(type_declaration
  (identifier) @definition.category.type.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---




; --- semantic_datasource ---

(datasource_declaration
  (identifier) @prisma.datasource.name
) @prisma.datasource

; --- semantic_enum ---


; --- semantic_field ---

(model_declaration
  (identifier) @prisma.field.model
  (statement_block
    (column_declaration
      (identifier) @prisma.field.name
      (column_type) @prisma.field.type
    ) @prisma.field
  )
)

; --- semantic_generator ---

(generator_declaration
  (identifier) @prisma.generator.name
) @prisma.generator

; --- semantic_model ---


; --- semantic_relation ---

((model_declaration
  (identifier) @prisma.relation.model
  (statement_block
    (column_declaration
      (identifier) @prisma.relation.name
      (column_type
        (identifier) @prisma.relation.target
      )
      (attribute
        (call_expression
          (identifier) @prisma.relation.attribute
        )
      )
    ) @prisma.relation.field
  )
)
(#eq? @prisma.relation.attribute "relation"))

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.
(_) @structural.node

; --- terminal_prisma_view_v1 ---
(view_declaration) @definition.expression @type.expression
(view_declaration (identifier) @definition.category.name @definition.identity.name @prisma.view.name) @definition.category.owner @definition.identity.owner @prisma.view
(view_declaration
  (identifier) @prisma.view.field.owner
  (statement_block
    (column_declaration
      (identifier) @prisma.view.field.name
      (column_type) @prisma.view.field.type) @prisma.view.field))

; --- terminal_prisma_enum_block_attrs_v2 ---
(enum_declaration
  (identifier) @prisma.enum.value.owner
  (enum_block (enumeral) @prisma.enum.value)) @prisma.enum.value.context

(model_declaration
  (identifier) @prisma.block_attribute.owner
  (statement_block (block_attribute_declaration) @prisma.block_attribute)) @prisma.block_attribute.context

(view_declaration
  (identifier) @prisma.block_attribute.owner
  (statement_block (block_attribute_declaration) @prisma.block_attribute)) @prisma.block_attribute.context

; --- implicit_model_typed_field_v3_146 ---
; Framework-neutral authored field type target. Joining to an actual data.model
; distinguishes model relations from scalar/enum names without guessing.
(model_declaration
  (identifier) @prisma.typed_field.owner
  (statement_block
    (column_declaration
      (identifier) @prisma.typed_field.name
      (column_type
        (identifier) @prisma.typed_field.target)) @prisma.typed_field.context))

