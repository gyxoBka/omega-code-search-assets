; --- block_context ---

; Generic HCL block-label and attribute context for Framework overlays.
; Immediate named-child anchors keep one-label and two-label blocks distinct.

(block
  . (identifier) @hcl.block.kind
  . (string_lit) @hcl.block.label0
  . (string_lit) @hcl.block.label1
  . (body) @hcl.block.body) @hcl.block.two_labels

(block
  . (identifier) @hcl.block.kind
  . (string_lit) @hcl.block.label0
  . (body) @hcl.block.body) @hcl.block.one_label

(attribute
  . (identifier) @hcl.attribute.key
  . (expression) @hcl.attribute.value) @hcl.attribute

; --- block_list_traversal_context ---

; Framework-neutral HCL owner-aware direct two-segment traversal in a list-valued block attribute.
; Exact structural subset only. Examples:
; resource "aws_s3_bucket" "assets" { depends_on = [aws_iam_role.bucket] }
; module "app" { depends_on = [module.network] }
; Function calls, indexes, splats, conditionals and deeper traversal chains are intentionally excluded.

(block
  . (identifier) @hcl.list_ref.owner_kind
  . (string_lit) @hcl.list_ref.owner_label0
  . (string_lit) @hcl.list_ref.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.list_ref.attribute_key
        . (expression
            (collection_value
              (tuple
                (expression
                  (variable_expr
                    (identifier) @hcl.list_ref.target_root)
                  (get_attr
                    (identifier) @hcl.list_ref.target_name)) @hcl.list_ref.target_expression))) @hcl.list_ref.attribute_value) @hcl.list_ref.attribute)) @hcl.list_ref.owner_two_labels

(block
  . (identifier) @hcl.list_ref.owner_kind
  . (string_lit) @hcl.list_ref.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.list_ref.attribute_key
        . (expression
            (collection_value
              (tuple
                (expression
                  (variable_expr
                    (identifier) @hcl.list_ref.target_root)
                  (get_attr
                    (identifier) @hcl.list_ref.target_name)) @hcl.list_ref.target_expression))) @hcl.list_ref.attribute_value) @hcl.list_ref.attribute)) @hcl.list_ref.owner_one_label

; --- block_traversal_context ---

; Framework-neutral HCL owner-aware direct two-segment traversal used as the complete value of a block attribute.
; Exact structural subset only. Examples:
; resource "aws_s3_bucket" "assets" { role = aws_iam_role.bucket }
; module "app" { region = var.region }
; output "peer" { value = module.network }
; Deeper traversal chains, functions, indexes, splats, conditionals and templates are intentionally excluded.

(block
  . (identifier) @hcl.ref.owner_kind
  . (string_lit) @hcl.ref.owner_label0
  . (string_lit) @hcl.ref.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.ref.attribute_key
        . (expression
            (variable_expr
              (identifier) @hcl.ref.target_root)
            (get_attr
              (identifier) @hcl.ref.target_name)) @hcl.ref.target_expression) @hcl.ref.attribute)) @hcl.ref.owner_two_labels

(block
  . (identifier) @hcl.ref.owner_kind
  . (string_lit) @hcl.ref.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.ref.attribute_key
        . (expression
            (variable_expr
              (identifier) @hcl.ref.target_root)
            (get_attr
              (identifier) @hcl.ref.target_name)) @hcl.ref.target_expression) @hcl.ref.attribute)) @hcl.ref.owner_one_label

; Exact three-segment traversal used by typed Terraform data sources:
; data.<type>.<name>. Dynamic expressions, indexes, splats and deeper chains
; remain outside this fact.
(block
  . (identifier) @hcl.ref3.owner_kind
  . (string_lit) @hcl.ref3.owner_label0
  . (string_lit) @hcl.ref3.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.ref3.attribute_key
        . (expression
            (variable_expr
              (identifier) @hcl.ref3.target_root)
            (get_attr
              (identifier) @hcl.ref3.target_type)
            (get_attr
              (identifier) @hcl.ref3.target_name)) @hcl.ref3.target_expression) @hcl.ref3.attribute)) @hcl.ref3.owner_two_labels

(block
  . (identifier) @hcl.ref3.owner_kind
  . (string_lit) @hcl.ref3.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.ref3.attribute_key
        . (expression
            (variable_expr
              (identifier) @hcl.ref3.target_root)
            (get_attr
              (identifier) @hcl.ref3.target_type)
            (get_attr
              (identifier) @hcl.ref3.target_name)) @hcl.ref3.target_expression) @hcl.ref3.attribute)) @hcl.ref3.owner_one_label

; --- distributed_web_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED structural query.
; External Neovim query body is NOT copied. Exact parser-target evidence: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-hcl/main/parser.json
; Structural node fact observed at: https://raw.githubusercontent.com/neovim-treesitter/nvim-treesitter-queries-hcl/main/queries/highlights.scm
(function_call) @structural.candidate

; --- practical_semantics ---

; Omega practical P0 HCL semantics for the exact pinned tree-sitter-hcl grammar.
; HCL block labels/types are syntax-level entities; Terraform/Packer/Nomad
; interpretation is deliberately guarded rather than guessed.

(block
  (identifier) @definition.block.kind) @definition.block

(attribute
  (identifier) @definition.attribute.name) @definition.attribute

(function_call
  (identifier) @reference.call.target @hcl.function.name) @call.function @hcl.function.context

(variable_expr
  (identifier) @reference.variable)

(get_attr
  (identifier) @reference.member)
(block . (identifier) @hcl.local.block_kind @hcl.owner0_attr.owner_kind . (body (attribute . (identifier) @hcl.local.name @hcl.owner0_attr.key . (expression) @hcl.local.value @hcl.owner0_attr.value) @hcl.local.attribute @hcl.owner0_attr.context) @hcl.local.body) @hcl.local.block @hcl.owner0_attr.owner

(for_intro
  (identifier) @binding.for)

(template_for_start
  (identifier) @binding.template_for)

(template_interpolation) @reference.template_interpolation

(template_if_intro) @reference.template_condition

(body) @scope.body
(block) @scope.block


; --- semantic_closure_v3_146_hcl_owner_attributes_nested_blocks ---
; Framework-neutral block-owned authored attributes and nested block shape.

(block
  . (identifier) @hcl.owner_attr.owner_kind
  . (string_lit) @hcl.owner_attr.owner_label0
  . (string_lit) @hcl.owner_attr.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.owner_attr.key
        . (expression) @hcl.owner_attr.value) @hcl.owner_attr.context)) @hcl.owner_attr.owner_two_labels

(block
  . (identifier) @hcl.owner_attr.owner_kind
  . (string_lit) @hcl.owner_attr.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.owner_attr.key
        . (expression) @hcl.owner_attr.value) @hcl.owner_attr.context)) @hcl.owner_attr.owner_one_label

(block
  . (identifier) @hcl.owner_string.owner_kind
  . (string_lit) @hcl.owner_string.owner_label0
  . (string_lit) @hcl.owner_string.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.owner_string.key
        . (expression
            (literal_value
              (string_lit
                (template_literal) @hcl.owner_string.value))) @hcl.owner_string.expression) @hcl.owner_string.context)) @hcl.owner_string.owner_two_labels

(block
  . (identifier) @hcl.owner_string.owner_kind
  . (string_lit) @hcl.owner_string.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.owner_string.key
        . (expression
            (literal_value
              (string_lit
                (template_literal) @hcl.owner_string.value))) @hcl.owner_string.expression) @hcl.owner_string.context)) @hcl.owner_string.owner_one_label

; Nested block with one authored label (for example dynamic "x", provisioner "local-exec").
(block
  . (identifier) @hcl.nested.owner_kind
  . (string_lit) @hcl.nested.owner_label0
  . (string_lit) @hcl.nested.owner_label1
  . (body
      (block
        . (identifier) @hcl.nested.child_kind
        . (string_lit) @hcl.nested.child_label
        . (body) @hcl.nested.child_body) @hcl.nested.context)) @hcl.nested.owner_two_labels_labeled_child

(block
  . (identifier) @hcl.nested.owner_kind
  . (string_lit) @hcl.nested.owner_label0
  . (body
      (block
        . (identifier) @hcl.nested.child_kind
        . (string_lit) @hcl.nested.child_label
        . (body) @hcl.nested.child_body) @hcl.nested.context)) @hcl.nested.owner_one_label_labeled_child

; Nested unlabeled block (for example lifecycle).
(block
  . (identifier) @hcl.nested.owner_kind
  . (string_lit) @hcl.nested.owner_label0
  . (string_lit) @hcl.nested.owner_label1
  . (body
      (block
        . (identifier) @hcl.nested.child_kind
        . (body) @hcl.nested.child_body) @hcl.nested.context)) @hcl.nested.owner_two_labels_unlabeled_child

(block
  . (identifier) @hcl.nested.owner_kind
  . (string_lit) @hcl.nested.owner_label0
  . (body
      (block
        . (identifier) @hcl.nested.child_kind
        . (body) @hcl.nested.child_body) @hcl.nested.context)) @hcl.nested.owner_one_label_unlabeled_child

(block
  . (identifier) @hcl.owner0_string.owner_kind
  . (body
      (attribute
        . (identifier) @hcl.owner0_string.key
        . (expression
            (literal_value
              (string_lit
                (template_literal) @hcl.owner0_string.value))) @hcl.owner0_string.expression) @hcl.owner0_string.context)) @hcl.owner0_string.owner

(block
  . (identifier) @hcl.nested0.owner_kind
  . (body
      (block
        . (identifier) @hcl.nested0.child_kind
        . (string_lit) @hcl.nested0.child_label
        . (body) @hcl.nested0.child_body) @hcl.nested0.context)) @hcl.nested0.owner_labeled_child

(block
  . (identifier) @hcl.nested0.owner_kind
  . (body
      (block
        . (identifier) @hcl.nested0.child_kind
        . (body) @hcl.nested0.child_body) @hcl.nested0.context)) @hcl.nested0.owner_unlabeled_child


; --- semantic_closure_v3_146_hcl_list_traversal3 ---
; Owner-aware authored three-segment traversal within a tuple-valued block attribute.
(block
  . (identifier) @hcl.list_ref3.owner_kind
  . (string_lit) @hcl.list_ref3.owner_label0
  . (string_lit) @hcl.list_ref3.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.list_ref3.attribute_key
        . (expression
            (collection_value
              (tuple
                (expression
                  (variable_expr (identifier) @hcl.list_ref3.target_root)
                  (get_attr (identifier) @hcl.list_ref3.target_type)
                  (get_attr (identifier) @hcl.list_ref3.target_name)) @hcl.list_ref3.target_expression))) @hcl.list_ref3.attribute_value) @hcl.list_ref3.attribute)) @hcl.list_ref3.owner_two_labels

(block
  . (identifier) @hcl.list_ref3.owner_kind
  . (string_lit) @hcl.list_ref3.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.list_ref3.attribute_key
        . (expression
            (collection_value
              (tuple
                (expression
                  (variable_expr (identifier) @hcl.list_ref3.target_root)
                  (get_attr (identifier) @hcl.list_ref3.target_type)
                  (get_attr (identifier) @hcl.list_ref3.target_name)) @hcl.list_ref3.target_expression))) @hcl.list_ref3.attribute_value) @hcl.list_ref3.attribute)) @hcl.list_ref3.owner_one_label
; --- generic_hcl_function_context_v3_146 ---



; --- semantic_closure_v3_146_hcl_block_object_entries ---

(block
  . (identifier) @hcl.obj2.owner_kind
  . (string_lit) @hcl.obj2.owner_label0
  . (string_lit) @hcl.obj2.owner_label1
  . (body
      (attribute
        . (identifier) @hcl.obj2.attribute_key
        . (expression
            (collection_value
              (object
                (object_elem
                  key: (expression) @hcl.obj2.object_key
                  val: (expression) @hcl.obj2.object_value) @hcl.obj2.object_entry))) @hcl.obj2.attribute_value) @hcl.obj2.attribute)) @hcl.obj2.owner

(block
  . (identifier) @hcl.obj1.owner_kind
  . (string_lit) @hcl.obj1.owner_label0
  . (body
      (attribute
        . (identifier) @hcl.obj1.attribute_key
        . (expression
            (collection_value
              (object
                (object_elem
                  key: (expression) @hcl.obj1.object_key
                  val: (expression) @hcl.obj1.object_value) @hcl.obj1.object_entry))) @hcl.obj1.attribute_value) @hcl.obj1.attribute)) @hcl.obj1.owner

(block
  . (identifier) @hcl.obj0.owner_kind
  . (body
      (attribute
        . (identifier) @hcl.obj0.attribute_key
        . (expression
            (collection_value
              (object
                (object_elem
                  key: (expression) @hcl.obj0.object_key
                  val: (expression) @hcl.obj0.object_value) @hcl.obj0.object_entry))) @hcl.obj0.attribute_value) @hcl.obj0.attribute)) @hcl.obj0.owner

; --- final_completion_generic_direct_literals_v1 ---
(string_lit) @omega.literal.string
(numeric_lit) @omega.literal.number
(bool_lit) @omega.literal.boolean
(null_lit) @omega.literal.null
