; omega-hcl
;
; HCL is the language of infrastructure configuration: Terraform, Packer,
; Nomad, Consul, Vault, Waypoint. A file is a list of blocks, each block a
; list of attributes, and the values are expressions that refer to other
; blocks. The questions asked of such a file are *where is this thing
; declared*, *what is this setting set to* and *what does this block refer
; to*. Every pattern below is rooted at one node and answers one of them.
;
; There is no pattern for containment. A block declared inside another block
; is already inside that block's span, and the host derives the qualified
; name from the nesting; a pattern that spells out owner-body-attribute costs
; one match per tuple of nodes at that depth and states what the tree already
; holds.
;
; Note on anchors: `block_start` and `block_end` are named nodes in this
; grammar, so the child immediately after a block's last label is `{`, not
; `body`. Anchoring a label to `(body)` matches nothing at all.

; --- a block with two labels: resource "aws_s3_bucket" "assets" { ---
;
; The last label is the name an agent searches for. The block type and the
; first label are carried with it, because "which kind of block is this" and
; "which resource type" are asked of the same declaration.

(block
  . (identifier) @block2.type
  . [(string_lit) (identifier)] @block2.label0
  . [(string_lit) (identifier)] @block2.label1
  . (block_start)) @block2

; --- a block with one label: variable "region" {, module "network" { ---
;
; The anchor on `block_start` makes this exactly one label, so a two-label
; block is not declared twice.

(block
  . (identifier) @block1.type
  . [(string_lit) (identifier)] @block1.label0
  . (block_start)) @block1

; --- a block with no label: terraform {, locals {, lifecycle { ---
;
; An unlabeled block is named by its type: that is the only name it has.

(block
  . (identifier) @block0.type
  . (block_start)) @block0

; --- a setting whose value is a scalar: region = "us-east-1" ---
;
; This is where a setting is declared and the one place the value is short
; enough, and authored enough, to carry with it. A quoted template
; ("${var.region}-app") is carried as written; its interpolations are stated
; separately by the traversal pattern below.

(attribute
  . (identifier) @attribute.scalar.name
  . (expression
      . [(literal_value)
         (template_expr (quoted_template))] @attribute.scalar.value .)) @attribute.scalar

; --- a setting whose value is compound ---
;
; The same declaration, without a value. An object, a tuple, a heredoc, a
; function call, a conditional or a for-expression is stated by the entries,
; calls and references inside it; storing its text here would store the same
; bytes a second time, and a heredoc is often an entire embedded script.

(attribute
  . (identifier) @attribute.compound.name
  . (expression
      . [(collection_value)
         (conditional)
         (expression)
         (for_expr)
         (function_call)
         (index)
         (operation)
         (splat)
         (variable_expr)
         (template_expr (heredoc_template))])) @attribute.compound

; --- an entry of an object value: tags = { Env = "prod" } ---
;
; An object entry is a setting too: `tags = { Env = "prod" }` is where Env is
; set. The key is a bare identifier or a quoted string; both are stated under
; the name itself.

(object_elem
  key: (expression
         [(variable_expr (identifier) @object.scalar.key)
          (literal_value (string_lit) @object.scalar.key)])
  val: (expression
         . [(literal_value)
            (template_expr (quoted_template))] @object.scalar.value .)) @object.scalar

(object_elem
  key: (expression
         [(variable_expr (identifier) @object.compound.key)
          (literal_value (string_lit) @object.compound.key)])
  val: (expression
         . [(collection_value)
            (conditional)
            (expression)
            (for_expr)
            (function_call)
            (index)
            (operation)
            (splat)
            (variable_expr)
            (template_expr (heredoc_template))])) @object.compound

; --- a function call: cidrsubnet(var.cidr, 8, 1) ---

(function_call
  . (identifier) @call.name) @call

; --- a reference to another block: var.region, aws_s3_bucket.assets ---
;
; The one link HCL has. A traversal is `root.segment...`; the segment that
; names something is the first one, and it is spelled exactly as the block
; label or the attribute name it refers to, so it resolves. The root is kept
; as an attribute because it says which namespace was addressed -- `var`,
; `local`, `module`, or a resource type.
;
; Deeper segments are attribute reads of whatever was addressed (`.arn`,
; `.id`, `.value`) and are not stated: they would match, by name alone, any
; attribute declared anywhere in the repository.
;
; A bare identifier with no segment after it is not stated either. In this
; grammar an object key and a type keyword (`type = string`) are both a
; `variable_expr`, so a reference to every one of them would be a reference
; to nothing.

(expression
  . (variable_expr (identifier) @traversal.root)
  . (get_attr (identifier) @traversal.segment))
