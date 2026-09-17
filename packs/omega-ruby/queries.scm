; --- block_call_context ---

; Generic Ruby block-call ownership contexts.
; Preserves only syntax: outer call+label and direct child calls inside its block.

(call
  method: (identifier) @ruby.block.owner_call
  arguments: (argument_list
    (string (string_content) @ruby.block.owner_label))
  block: [(block) (do_block)]) @ruby.block.owner_context

(call
  method: (identifier) @ruby.owned_string.owner_call
  arguments: (argument_list
    (string (string_content) @ruby.owned_string.owner_label))
  block: (block
    body: (block_body
      (call
        method: (identifier) @ruby.owned_string.child_call
        arguments: (argument_list
          (string (string_content) @ruby.owned_string.child_label))) @ruby.owned_string.child_context))) @ruby.owned_string.owner_context

(call
  method: (identifier) @ruby.owned_string.owner_call
  arguments: (argument_list
    (string (string_content) @ruby.owned_string.owner_label))
  block: (do_block
    body: (body_statement
      (call
        method: (identifier) @ruby.owned_string.child_call
        arguments: (argument_list
          (string (string_content) @ruby.owned_string.child_label))) @ruby.owned_string.child_context))) @ruby.owned_string.owner_context

(call
  method: (identifier) @ruby.owned_call.owner_call
  arguments: (argument_list
    (string (string_content) @ruby.owned_call.owner_label))
  block: (block
    body: (block_body
      (call
        method: (identifier) @ruby.owned_call.child_call) @ruby.owned_call.child_context))) @ruby.owned_call.owner_context

(call
  method: (identifier) @ruby.owned_call.owner_call
  arguments: (argument_list
    (string (string_content) @ruby.owned_call.owner_label))
  block: (do_block
    body: (body_statement
      (call
        method: (identifier) @ruby.owned_call.child_call) @ruby.owned_call.child_context))) @ruby.owned_call.owner_context

; --- call_targets ---

(call
  method: (_) @call.target) @call.expression

; --- class_association_explicit_target_context ---

; Framework-neutral authored Ruby class-body association/DSL call with an explicit string option.
; Example:
;   class Post < ApplicationRecord
;     belongs_to :author, class_name: "Admin::User"
;   end
; Captures syntax only. Framework meaning and declaration resolution remain downstream.

(class
  name: (_) @ruby.association.owner_class
  body: (body_statement
    (call
      method: (identifier) @ruby.association.macro
      arguments: (argument_list
        (simple_symbol) @ruby.association.association_name
        (pair
          key: (hash_key_symbol) @ruby.association.option_key
          value: (string
            (string_content) @ruby.association.option_value))))) @ruby.association.context)

; --- class_qualified_super_block_string_context ---

; Framework-neutral Ruby class with explicit two-part qualified superclass and a direct literal-string block call.
; Exact authored subset only. No inheritance resolution beyond captured syntax, no dynamic paths,
; no indirect calls, aliases, mixins, helper expansion, middleware execution, or runtime dispatch.

(class
  name: (constant) @ruby.class_block.owner_class
  superclass: (superclass
    (scope_resolution
      scope: (constant) @ruby.class_block.superclass_scope
      name: (constant) @ruby.class_block.superclass_name))
  body: (body_statement
    (call
      method: (identifier) @ruby.class_block.owner_call
      arguments: (argument_list
        (string (string_content) @ruby.class_block.owner_label))
      block: [(block) (do_block)]) @ruby.class_block.route_call)) @ruby.class_block.context

; --- completeness_modules_3 ---

(module) @module.expression

; --- declaration_category_class ---

(class
  name: (_) @definition.category.class.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- declaration_category_method ---

(method
  name: (_) @definition.category.method.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

(singleton_method
  name: (_) @definition.category.method.name
) @definition.category.owner

; --- declaration_category_module ---

(module
  name: (_) @definition.category.module.name @definition.identity.name
) @definition.category.owner @definition.identity.owner

; --- definition_identity_hints ---




; --- direct_string_call_context ---

; Framework-neutral direct Ruby call with a literal first string argument.
; Captures source syntax only; no Ruby/Bundler runtime evaluation.
(call
  method: (identifier) @ruby.string_call.name
  arguments: (argument_list
    . (string (string_content) @ruby.string_call.arg0))
) @ruby.string_call.context

; --- enclosing_owner_hints ---

(class 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

(module 
  name: (_) @scope.enclosing_owner.name @scope.owner.name
  body: (_) @scope.enclosing_owner.body @scope.owner.body
) @scope.enclosing_owner.span @scope.owner

; --- external-helix-tags ---

; Omega coverage-first adapted external query
; source=helix language=ruby kind=tags
; original baseline: audit-baselines/external/helix/ruby/tags.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Method definitions

(
  (comment)* @doc
  .
  [
    (method
      name: (_) @name) @definition.method
    (singleton_method
      name: (_) @name) @definition.method
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.method)
)

(alias
  name: (_) @name) @definition.method

(setter
  (identifier) @_ignore @ignore)

; Class definitions

(
  (comment)* @doc
  .
  [
    (class
      name: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
    (singleton_class
      value: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.class)
)

; Module definitions

(
  (module
    name: [
      (constant) @name
      (scope_resolution
        name: (_) @name)
    ]) @definition.module
)

; Calls

(call method: (identifier) @name) @reference.call

(
  [(identifier) (constant)] @name @reference.call
  (#is-not? local)
  (#not-match? @name "^(lambda|load|require|require_relative|__FILE__|__LINE__)$")
)

; --- external-nvim-treesitter-locals ---

; Omega coverage-first adapted external query
; source=nvim-treesitter language=ruby kind=locals
; original baseline: audit-baselines/external/nvim-treesitter/ruby/locals.scm
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; The MIT License (MIT)
;
; Copyright (c) 2016 Rob Rix
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
; DECLARATIONS AND SCOPES
(method) @local.scope

(class) @local.scope

[
  (block)
  (do_block)
] @local.scope

(identifier) @local.reference

(constant) @local.reference

(instance_variable) @local.reference

(module
  name: (constant) @local.definition.namespace)

(class
  name: (constant) @local.definition.type)

(method
  name: [
    (identifier)
    (constant)
  ] @local.definition.function)

(singleton_method
  name: [
    (identifier)
    (constant)
  ] @local.definition.function)

(method_parameters
  (identifier) @local.definition.var @local.definition.variable.parameter)

(lambda_parameters
  (identifier) @local.definition.var @local.definition.variable.parameter)

(block_parameters
  (identifier) @local.definition.var @local.definition.variable.parameter)

(splat_parameter
  (identifier) @local.definition.var @local.definition.variable.parameter)

(hash_splat_parameter
  (identifier) @local.definition.var @local.definition.variable.parameter)

(optional_parameter
  name: (identifier) @local.definition.var @local.definition.variable.parameter)

(destructured_parameter
  (identifier) @local.definition.var @local.definition.variable.parameter)

(block_parameter
  name: (identifier) @local.definition.var)

(keyword_parameter
  name: (identifier) @local.definition.var @local.definition.variable.parameter)

(assignment
  left: (_) @local.definition.var)

(left_assignment_list
  (identifier) @local.definition.var)

(rest_assignment
  (identifier) @local.definition.var)

(destructured_left_assignment
  (identifier) @local.definition.var)

; --- import_alias_hints ---

(alias
  name: (_) @import.target
  alias: (_) @import.alias) @import.statement

; --- locals ---

; OMEGA IMPORTED LOCALS BASELINE — CONTENT-ADDRESSED PROVENANCE
; SPDX-License-Identifier: MIT
; Derived by composition only from content-addressed nvim-treesitter locals baselines.
; Runtime grammar/query compatibility is enforced by tools/compile-pack-queries.mjs.

; Omega adaptation source: direct
; path=audit-baselines/external/nvim-treesitter/ruby/locals.scm
; sha256=d507cbb78f380559f314429ae9d2d654cea7abbe3f261c40ae71c3b97ea270e1
; The MIT License (MIT)
;
; Copyright (c) 2016 Rob Rix
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
; DECLARATIONS AND SCOPES























; --- named_scope_owners ---


(method
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner


(singleton_method
  name: (_) @scope.owner.name
  body: (_) @scope.owner.body) @scope.owner

; --- ownership_parameters ---

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (block_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (destructured_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (forward_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (hash_splat_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (identifier) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (keyword_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(method
  name: (_) @owner.name
  parameters: (method_parameters
    (splat_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (block_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (destructured_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (forward_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (hash_splat_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (identifier) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (keyword_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (optional_parameter) @owned.parameter)) @owner.span

(singleton_method
  name: (_) @owner.name
  parameters: (method_parameters
    (splat_parameter) @owned.parameter)) @owner.span

; --- p0-exact-helix-locals ---

; Omega P0 exact-revision enrichment
; source=helix language=ruby file=locals.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/ruby/locals.scm

; Method, class, module and singleton-class bodies don't see locals from the
; enclosing scope in Ruby, so they must not inherit.
([
  (method)
  (singleton_method)
  (class)
  (module)
  (singleton_class)
] @local.scope
 (#set! local.scope-inherits false))

[
  (lambda)
  (block)
  (do_block)
] @local.scope

(block_parameter (identifier) @local.definition.variable.parameter)


; A method-call name is not a variable reference (the grammar only forms `call`
; when it's syntactically a call), so a same-named local must not capture it.
(call
  method: (identifier) @_)

; --- p0-exact-helix-tags ---

; Omega P0 exact-revision enrichment
; source=helix language=ruby file=tags.scm
; parser compatibility: exact_parser_revision_match
; original baseline: audit-baselines/external/helix/ruby/tags.scm

; Method definitions

(
  (comment)* @doc
  .
  [
    (method
      name: (_) @name) @definition.method
    (singleton_method
      name: (_) @name) @definition.method
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.method)
)



; Class definitions

(
  (comment)* @doc
  .
  [
    (class
      name: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
    (singleton_class
      value: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.class)
)

; Module definitions


; Calls


(
  [(identifier) (constant)] @name @reference.call
  (#is-not? local)
  (#not-match? @name "^(lambda|load|require|require_relative|__FILE__|__LINE__)$")
)

; --- receiver_hints ---

(self) @reference.receiver

(super) @reference.receiver

; --- signature_parameters ---

(method
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

(singleton_method
  name: (_) @definition.signature.name
  parameters: (_) @definition.signature.parameters
) @definition.signature.owner

; --- static_delta ---

(call
  method: (identifier) @import.api
  (#match? @import.api "^(require|require_relative|load|autoload)$")) @import.call

(class
  (superclass) @relation.superclass) @relation.owner

; --- upstream_tags ---

; Method definitions

(
  (comment)* @doc
  .
  [
    (method
      name: (_) @name) @definition.method
    (singleton_method
      name: (_) @name) @definition.method
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.method)
)



; Class definitions

(
  (comment)* @doc
  .
  [
    (class
      name: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
    (singleton_class
      value: [
        (constant) @name
        (scope_resolution
          name: (_) @name)
      ]) @definition.class
  ]
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.class)
)

; Module definitions


; Calls


(
  [(identifier) (constant)] @name @reference.call
  (#is-not? local)
  (#not-match? @name "^(lambda|load|require|require_relative|__FILE__|__LINE__)$")
)

; --- direct_string_kwarg_call_context ---

(call
  method: (identifier) @ruby.string_kwarg.call_name
  arguments: (argument_list
    . (string (string_content) @ruby.string_kwarg.arg0)
    (pair
      key: (hash_key_symbol) @ruby.string_kwarg.kwarg_key
      value: (string (string_content) @ruby.string_kwarg.kwarg_value)))) @ruby.string_kwarg.context

; --- final_completion_generic_direct_literals_v1 ---
(integer) @omega.literal.integer
(float) @omega.literal.float
(nil) @omega.literal.nil
(true) @omega.literal.true
(false) @omega.literal.false
(string) @omega.literal.string
