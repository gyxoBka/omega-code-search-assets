# omega-hcl

Language `omega-hcl`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

9 templates over 9 query patterns, 6 distinct root node types
(`block`, `attribute`, `object_elem`, `function_call`, `expression`).

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 7 |
| `references` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_attribute` | Config | 2 |
| `definition.config_block` | Config | 3 |
| `definition.config_entry` | Config | 2 |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `reference.traversal` | reference | 1 |

### Regions

None. A block's declaration span is the whole `block` node, so a block
declared inside another block is already inside it and the host derives the
qualified name from the nesting. A separate `scope.*` emission would state
that a second time and would have to be named with the container's text.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 64 node types. The Pack looks at 20 of them.

Untouched:

- `attr_splat`
- `binary_operation`
- `block_end`
- `body`
- `bool_lit`
- `comment`
- `config_file`
- `ellipsis`
- `for_cond`
- `for_intro`
- `for_object_expr`
- `for_tuple_expr`
- `full_splat`
- `function_arguments`
- `heredoc_identifier`
- `heredoc_start`
- `legacy_index`
- `new_index`
- `null_lit`
- `numeric_lit`
- `object`
- `object_end`
- `object_start`
- `quoted_template_end`
- `quoted_template_start`
- `strip_marker`
- `template_directive`
- `template_directive_end`
- `template_directive_start`
- `template_else_intro`
- `template_for`
- `template_for_end`
- `template_for_start`
- `template_if`
- `template_if_end`
- `template_if_intro`
- `template_interpolation`
- `template_interpolation_end`
- `template_interpolation_start`
- `template_literal`
- `tuple`
- `tuple_end`
- `tuple_start`
- `unary_operation`

Why each group is right to be untouched:

- **Punctuation that the grammar happens to name.** `block_start`,
  `block_end`, `object_start`, `object_end`, `tuple_start`, `tuple_end`,
  `quoted_template_start`, `quoted_template_end`,
  `template_interpolation_start`/`_end`, `template_directive_start`/`_end`,
  `strip_marker`, `ellipsis`. These are the braces, brackets, quotes, `${`,
  `%{`, `~` and `...` of the language. They name nothing. `block_start` is
  nevertheless *mentioned* in the query file, as the anchor that separates a
  one-label block from a two-label one; it carries no capture.
- **Wrappers reached through their parent.** `body`, `object`, `tuple`,
  `config_file`, `function_arguments`, `binary_operation`, `unary_operation`,
  `attr_splat`, `full_splat`, `legacy_index`, `new_index`,
  `for_object_expr`, `for_tuple_expr`, `for_cond`. Every one of them is
  either a container whose members are stated individually, or a shape
  variant already covered through `operation`, `splat`, `index` or
  `for_expr` in the value alternations.
- **Literal leaves.** `bool_lit`, `numeric_lit`, `null_lit`,
  `template_literal`. Their text is carried as the `value` attribute of the
  setting that holds them. The Pack emits no `reference_context.*` kind, so
  a `literal.*` emission on each of them would suppress nothing and the host
  would drop it (brief §5): that is one match per literal in every file for
  a row nobody ever sees.
- **The template mini-language.** `template_interpolation`,
  `template_if`/`_intro`/`_end`, `template_for`/`_start`/`_end`,
  `template_else_intro`, `template_directive`. `${...}` and `%{...}`
  contain an `expression`, and the traversal pattern is rooted at
  `expression`, so the reference inside an interpolation is already stated
  on exactly the same bytes. Emitting the interpolation as well says only
  "there is an interpolation here", which no question reaches.
- **`for_intro`.** A `for` binding (`[for s in var.list : upper(s)]`) names
  `s` for the length of one expression. Nothing else in the file can refer
  to it and the Pack does not state bare identifiers, so the binding would
  resolve against nothing and nothing would resolve against it.
- **`comment`, `heredoc_start`, `heredoc_identifier`.** A comment names
  nothing; the heredoc marker is its own terminator.

## What is wrong with it

This section describes the Pack as it was found -- 31 templates over 36
patterns, 9 guards, capabilities `bindings calls data definitions references
scopes` -- and is kept because the first failure below is not visible from
reading the file.

**Nineteen of the 36 patterns could not match anything, in any file, ever.**
`block_start` and `block_end` are *named* nodes in this grammar, so the named
child immediately after a block's last label is `{`, not `body`. Every
owner-aware pattern in the Pack was written as

    (block . (identifier) @kind . (string_lit) @label . (body (attribute ...)))

and the anchor between the label and `(body)` is unsatisfiable. Probed against
the pinned grammar with a 60-line Terraform file: *no matches*, for all
nineteen. That killed 14 of the 31 templates outright --
`definition.hcl_block_labeled` (both arities), `definition.hcl_local`, all six
`data.hcl_*_context` kinds, the three object-entry kinds and
`reference.hcl_block_list_traversal3_context` -- while the manifest went on
declaring `data` and the coverage layer went on repeating it.

**So the Pack declared every block under its block type.** With the labeled
form dead, the only surviving block declaration was
`(block (identifier) @definition.block.kind) @definition.block`, whose name is
the *first* identifier: the block type. Every `resource "aws_s3_bucket"
"assets"` in a repository was declared as `resource`, every `variable "region"`
as `variable`, every `module "network"` as `module`. Asking Omega where
`assets` is defined returned nothing; asking for `resource` returned every
resource in the corpus collapsed onto one name. That is defect J reached by a
different route -- the name was not literally a constant, it was a capture of
the one identifier that is the same for every instance of the construct.

**Thirteen patterns stated containment (defect E).** Six families -- owner
attribute, owner string attribute, nested block, unlabeled variants of each,
list traversal, object entry -- spelled out `block > body > attribute` or
`block > body > block` at two and three edges, once per block arity, to say
what the tree already holds and what the host already derives through the
`within:` namespace segment.

**Thirteen mention kinds, one occurrence.** `data.hcl_block_attribute_context`,
`data.hcl_nested_block_context`,
`semantic_hint.hcl_function_call_structure_hint`, `structured.entry`,
`reference_context.template_interpolation` and the rest all arrive as a plain
reference. None of them is one of the six relations the host knows, and none of
them names something another emission declares.

**Six templates named an emission with a whole node (D2).**
`scope.hcl_body` and `scope.hcl_block` were named from `(body)` and `(block)`,
so the text of every block in the file was stored twice as a name, once for the
block and once for its body. `semantic_hint.hcl_function_call_structure_hint`
was named from the whole `(function_call)`, arguments included.
`reference_context.template_interpolation` and `.template_condition` were named
from the whole directive. `literal.string` was named from `(string_lit)`.

**The `literal.*` templates suppressed nothing.** The Pack emitted
`literal.string`, `.number`, `.boolean`, `.null` on every scalar in every file.
Their only purpose is to mark spans so that a `reference_context.*` emission on
the same bytes is dropped -- and the two `reference_context.*` kinds this Pack
emitted are on `template_interpolation` and `template_if_intro`, which are never
the same span as a literal. Four templates, four query patterns, one match per
scalar in every file, for four emissions the host drops.

**Three guards whose reason was a label (G).**
`hcl_distributed_highlight_ast_fact_not_symbol_truth`,
`terminal_static_ceiling__hcl_host_product_semantics`,
`terminal_static_ceiling__hcl_dynamic_expression_resolution`. Of the other six,
four were two spellings of the same two sentences about "generic bounded
expression-path primitive" debt.

**A highlighting import.** `(function_call) @structural.candidate` arrived under
a comment naming a Neovim queries repository, and produced
`semantic_hint.hcl_function_call_structure_hint` -- a second, unnamed emission
over the same `function_call` node that `call.hcl_function_call` already stated.

**Measured on one 60-line Terraform file:** 128 matches, 129 emissions, 121
captures of which 51 were never read by any template. The rewritten Pack gives
46 matches and 46 emissions on the same file -- one emission per match, with no
template skipped and every capture read.

## What it should extract

HCL is the language of infrastructure configuration: Terraform, Packer, Nomad,
Consul, Vault, Waypoint. A file is a list of blocks, each block a list of
settings, and the values are expressions that address other blocks. Three
questions are asked of it: *where is this thing declared*, *what is this
setting set to*, and *what does this block refer to*.

| what | node | emitted as | family |
|---|---|---|---|
| `resource "aws_s3_bucket" "assets" {` | `block` with two labels | `definition.config_block` named from the last label, carrying `block_type` and `type_label` | Config |
| `variable "region" {` | `block` with one label | `definition.config_block` named from the label, carrying `block_type` | Config |
| `terraform {`, `locals {`, `lifecycle {` | `block` with no label | `definition.config_block` named from the block type | Config |
| `region = "us-east-1"` | `attribute` with a `literal_value` or quoted template | `definition.config_attribute` named from the key, carrying `value` unquoted | Config |
| `tags = { ... }`, `script = <<-EOT` | `attribute` with a compound value | `definition.config_attribute` named from the key, no value | Config |
| `Env = "prod"` inside an object | `object_elem` with a scalar value | `definition.config_entry` named from the key, carrying `value` | Config |
| `Owner = var.owner` inside an object | `object_elem` with a compound value | `definition.config_entry` named from the key | Config |
| `cidrsubnet(var.cidr, 8, 1)` | `function_call` | `call.function` named from the callee | call occurrence |
| `var.region`, `aws_s3_bucket.assets` | `expression` = `variable_expr` + first `get_attr` | `reference.traversal` named from the segment, carrying `root` | reference occurrence |
| `${...}`, `%{ if ... }` | `template_interpolation`, `template_if` | nothing of their own -- the expression inside is already a traversal | -- |
| every literal, bracket and wrapper node | | nothing | -- |

The one link HCL has is the traversal, and it now resolves: `var.region` names
`region`, which is the declaration a `variable "region"` block makes;
`local.name_prefix` names `name_prefix`, which is an attribute declaration
inside `locals`; `module.network` names `network`; `aws_s3_bucket.assets` names
`assets`. The reference is spelled exactly as the declaration once the label's
quotes are stripped, so no other sigil handling is needed.

Containment is answered by the declaration spans: a block's span is the whole
`block` node and a nested block's declaration sits inside it, so the host's
`within:` segment gives the path for free.

## Still to decide

1. **Which label is the address.** `resource "aws_s3_bucket" "assets"` is
   referred to as `aws_s3_bucket.assets`, but `data "aws_ami" "ubuntu"` as
   `data.aws_ami.ubuntu`. For a `resource` the resolvable segment is the second
   label, for a `data` block the first. Naming the declaration from the last
   label is right for every two-label block except `data`, and the rule that
   makes `data` different is Terraform's, not HCL's, so a query predicate on the
   literal `data` would be a framework overlay inside a language Pack. Recorded
   as a coverage guard instead.
2. **Whether the first `get_attr` is always the right segment.** It is for
   `var.`, `local.`, `module.` and for a resource address. It is not for `data.`
   (above) or for a `dynamic` block's iterator (`rule.value.id` names `value`,
   which resolves to nothing). Deeper segments are deliberately not stated:
   `.arn`, `.id`, `.value` would link, by name alone, to any attribute declared
   anywhere in the repository.
3. **Whether an unlabeled block should be declared at all.** `lifecycle`,
   `content` and `required_providers` collapse many instances onto one name.
   Provisionally: declare them -- the block type is genuinely the only name such
   a block has, and the resolver merges by name as it does elsewhere.

## The three Terraform framework overlays no longer match

`frameworks/omega-framework-terraform` (86 rules),
`omega-framework-terraform-providers` (8) and
`omega-framework-terraform-template` (15) match on this Pack's `fact_kind` and
read its `fields`. All 109 rules key on the old kinds. **103 of them already
matched nothing before this rewrite:**

- 64 rules match `reference.hcl_block_traversal_context`,
  `reference.hcl_block_traversal3_context` and
  `reference.hcl_block_list_traversal_context`, whose templates were deleted by
  the repository-wide duplicate sweep that preceded this wave;
- 39 rules match `definition.hcl_block_labeled`, `definition.hcl_local`,
  `data.hcl_block_attribute_context`, `data.hcl_block_string_attribute_context`,
  `data.hcl_nested_block_context`,
  `data.hcl_unlabeled_block_attribute_context` and the two object-entry kinds,
  every one of which is produced only by a pattern with the unsatisfiable
  `(body)` anchor described above.

The six that did work are broken here: two on `scope.hcl_body`, two on
`reference_context.template_interpolation`, one on
`reference_context.template_condition` and one on `call.hcl_function_context`.

This is the omega-json situation again, and it is resolved the same way: the
overlays have to be rewritten against the new declarations rather than the Pack
restoring a pattern per block arity and per nesting depth. The facts they need
are all still stated -- `terraform.resource` wants the block type and the two
labels, which are the `block_type` and `type_label` attributes and the
declaration's own name on `definition.config_block`; the attribute-context
rules want an owner and a key/value pair, which is a
`definition.config_attribute` inside the block's span. What the overlays cannot
have back is one emission per (owner, body, attribute) tuple.

## A defect in the host

None found. Everything wrong with this Pack was the Pack's.
