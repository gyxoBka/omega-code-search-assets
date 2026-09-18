; omega-rust
;
; Rust is the implementation language of a crate: the questions asked of it are
; where is this item declared, what is its signature, who calls it, who
; implements this trait, what does this file import, and what is behind a cfg.
; Every pattern below answers one of them.
;
; Containment is deliberately not stated. A method inside `impl Foo` is nested
; inside the `impl_item` declaration, and the host reads the enclosing
; declaration from the spans; a pattern per (owner, member) pair would restate
; what the tree already holds. Attribute attachment is the one place a pattern
; is required: `#[derive(..)]`, `#[test]` and `#[cfg(..)]` are *siblings* of the
; item they describe, not ancestors of it, so the tree does not say what they
; attach to and an anchored run of sibling attributes must.
;
; One pattern per node. Where one match answers several questions -- a function
; is a declaration, a visibility, a parameter shape and a return type -- the
; questions are several templates over the one pattern.

; ---------------------------------------------------------------- declarations

; A function, with everything its card's signature line is built from.
(function_item
  (visibility_modifier)? @function.visibility
  (function_modifiers)? @function.modifiers
  name: [(identifier) (metavariable)] @function.name
  type_parameters: (type_parameters)? @function.type_parameters
  parameters: (parameters) @function.parameters
  return_type: (_)? @function.return_type
  body: (block) @function.body) @function

; A trait's required method: a signature with no body.
(function_signature_item
  (visibility_modifier)? @requirement.visibility
  (function_modifiers)? @requirement.modifiers
  name: [(identifier) (metavariable)] @requirement.name
  type_parameters: (type_parameters)? @requirement.type_parameters
  parameters: (parameters) @requirement.parameters
  return_type: (_)? @requirement.return_type) @requirement

(struct_item
  (visibility_modifier)? @struct.visibility
  name: (type_identifier) @struct.name
  type_parameters: (type_parameters)? @struct.type_parameters) @struct

(union_item
  (visibility_modifier)? @union.visibility
  name: (type_identifier) @union.name
  type_parameters: (type_parameters)? @union.type_parameters) @union

(enum_item
  (visibility_modifier)? @enum.visibility
  name: (type_identifier) @enum.name
  type_parameters: (type_parameters)? @enum.type_parameters) @enum

(enum_variant
  (visibility_modifier)? @variant.visibility
  name: (identifier) @variant.name) @variant

(trait_item
  (visibility_modifier)? @trait.visibility
  name: (type_identifier) @trait.name
  type_parameters: (type_parameters)? @trait.type_parameters) @trait

; A named field. A tuple struct's fields have no name in the grammar and are
; not declared; see the coverage guard.
(field_declaration
  (visibility_modifier)? @field.visibility
  name: (field_identifier) @field.name
  type: (_) @field.type) @field

(const_item
  (visibility_modifier)? @const.visibility
  name: (identifier) @const.name
  type: (_) @const.type) @const

(static_item
  (visibility_modifier)? @static.visibility
  name: (identifier) @static.name
  type: (_) @static.type) @static

(type_item
  (visibility_modifier)? @alias.visibility
  name: (type_identifier) @alias.name
  type_parameters: (type_parameters)? @alias.type_parameters
  type: (_) @alias.value) @alias

(associated_type
  name: (type_identifier) @associated.name) @associated

(mod_item
  (visibility_modifier)? @module.visibility
  name: (identifier) @module.name) @module

; `macro_rules! foo` is invoked like a callable, so it is declared as one.
(macro_definition
  name: (identifier) @macro.name) @macro

; A generic parameter is declared so that the mentions of `T` inside the item
; have something to resolve to.
(type_parameter
  name: (type_identifier) @type_parameter.name) @type_parameter

; An impl block is declared under the name of the type it is for. That is what
; puts `Foo::bar` under `Foo` rather than at the top of the module: the host
; takes a declaration's owner from the smallest declaration span around it, and
; without this one a method would be a bare `bar`. Where the self type is not a
; path -- `impl Trait for &[u8]` -- no name can be taken and nothing matches.
(impl_item
  type_parameters: (type_parameters)? @impl.type_parameters
  trait: [(type_identifier) @impl.trait
          (scoped_type_identifier name: (type_identifier) @impl.trait)
          (generic_type type: (type_identifier) @impl.trait)
          (generic_type type: (scoped_type_identifier name: (type_identifier) @impl.trait))]?
  type: [(type_identifier) @impl.name
         (scoped_type_identifier name: (type_identifier) @impl.name)
         (generic_type type: (type_identifier) @impl.name)
         (generic_type type: (scoped_type_identifier name: (type_identifier) @impl.name))]) @impl

; -------------------------------------------------------------------- imports

(use_declaration
  argument: (identifier) @use.name) @use

(use_declaration
  argument: (scoped_identifier
    name: (identifier) @use.scoped.name)) @use.scoped

; Each entry of `use a::{b, c::d};` is its own import.
(use_list
  (identifier) @use.item)

(use_list
  (scoped_identifier
    name: (identifier) @use.item.scoped.name) @use.item.scoped)

(use_as_clause
  path: (_) @use.alias.path
  alias: (identifier) @use.alias.name) @use.alias

; `use a::b::*;` -- the name is the path it opens, with the star removed.
(use_wildcard) @use.glob

(extern_crate_declaration
  name: (identifier) @crate.name
  alias: (identifier)? @crate.alias) @crate

; ---------------------------------------------------------------------- calls

; The argument list is captured beside the name: a call's positional arguments
; are what a framework overlay asks a call for -- an axum route's URL, a
; `.nest()` prefix -- and they are the ordered children of the node the call
; already names them in.

(call_expression
  function: (identifier) @call.function.name
  arguments: (arguments) @call.args) @call.function

(call_expression
  function: (scoped_identifier
    name: (identifier) @call.path.name)
  arguments: (arguments) @call.args) @call.path

(call_expression
  function: (field_expression
    value: (_) @call.receiver
    field: (field_identifier) @call.method.name)
  arguments: (arguments) @call.args) @call.method

(call_expression
  function: (generic_function
    function: [(identifier) @call.turbofish.name
               (scoped_identifier name: (identifier) @call.turbofish.name)
               (field_expression field: (field_identifier) @call.turbofish.name)])) @call.turbofish

(macro_invocation
  macro: [(identifier) @call.macro.name
          (scoped_identifier name: (identifier) @call.macro.name)]) @call.macro

; ----------------------------------------------------------------- references

; Every mention of a type. This is the one bare capture the Pack makes, and it
; is the one the brief allows: a type mention is always an answer someone
; wants. A bare `(identifier)` would be every identifier in the file and is not
; captured anywhere here.
(type_identifier) @reference.type

; `a.b` is not stated. tree-sitter-rust spells a method callee as
; `field_expression` too, and a query cannot see the parent, so this pattern
; reported every method call as a mention of a field: measured over
; crates/ (514 files), 63 649 field mentions against 43 807 method calls --
; 68.8% of them were calls, and they resolved by name onto real field
; declarations. `Foo { b: .. }` and `Foo { b }` below carry the field mentions
; that are unambiguous.

; `Foo { port: 8080 }` and `Foo { port }` are both mentions of the field.
(field_initializer
  field: (field_identifier) @reference.initializer.name) @reference.initializer

(shorthand_field_initializer
  (identifier) @reference.shorthand)

; `Ordering::SeqCst`, `Self::LIMIT`, `Enum::Variant` -- the qualified value
; paths that resolve to a const, a static or a variant declared elsewhere.
(scoped_identifier
  name: (identifier) @reference.path.name) @reference.path

; `#[serde(..)]`, `#[tokio::main]`, `#[inline]` -- which attribute is on what.
(attribute
  [(identifier) @reference.attribute.name
   (scoped_identifier name: (identifier) @reference.attribute.name)]) @reference.attribute

; ------------------------------------------------------------------- implements

; `impl Trait for Type` is carried by the impl pattern above. `#[derive(..)]`
; is the other half of the answer to "who implements this trait", and it is a
; sibling of the type it applies to, so the run of attributes between the
; derive and the declaration is anchored on both sides.

((source_file
   (attribute_item
     (attribute
       (identifier) @derive.attribute
       arguments: (token_tree (identifier) @derive.trait)))
   .
   (attribute_item)*
   .
   [(struct_item name: (type_identifier))
    (enum_item name: (type_identifier))
    (union_item name: (type_identifier))] @derive.owner)
 (#eq? @derive.attribute "derive"))

((declaration_list
   (attribute_item
     (attribute
       (identifier) @derive.attribute
       arguments: (token_tree (identifier) @derive.trait)))
   .
   (attribute_item)*
   .
   [(struct_item name: (type_identifier))
    (enum_item name: (type_identifier))
    (union_item name: (type_identifier))] @derive.owner)
 (#eq? @derive.attribute "derive"))

; ----------------------------------------------------------------------- tests
;
; A function is a test when the attribute run immediately above it carries a
; primary test attribute. The run is anchored on both sides, so the attribute
; belongs to the declaration below it rather than to any declaration below it.
; Auxiliary markers -- #[ignore], #[should_panic] -- never make a test by
; themselves, which is what the intervening `(attribute_item)*` allows without
; matching on. Captured on its own, `(function_item)` beside `(attribute_item)`
; made every function in the corpus a test: 6 053 of them where 1 258 `#[test]`
; were written.

((source_file
   (attribute_item
     (attribute
       [(identifier) @test.attribute
        (scoped_identifier name: (identifier) @test.attribute)]))
   .
   (attribute_item)*
   .
   (function_item
     name: [(identifier) (metavariable)] @test.function.name) @test.function)
 (#match? @test.attribute "^(test|bench)$"))

((declaration_list
   (attribute_item
     (attribute
       [(identifier) @test.attribute
        (scoped_identifier name: (identifier) @test.attribute)]))
   .
   (attribute_item)*
   .
   (function_item
     name: [(identifier) (metavariable)] @test.function.name) @test.function)
 (#match? @test.attribute "^(test|bench)$"))

; ------------------------------------------------------- conditional compilation
;
; `#[cfg(..)]` says an item is only built under a condition, which is the
; question "what is behind this feature, and what is test-only". The condition
; is recorded verbatim on the declaration below it; it is never evaluated.

((source_file
   (attribute_item
     (attribute
       (identifier) @cfg.attribute
       arguments: (token_tree) @cfg.condition))
   .
   (attribute_item)*
   .
   [(function_item) (function_signature_item) (mod_item) (struct_item)
    (union_item) (enum_item) (trait_item) (impl_item) (const_item)
    (static_item) (type_item) (macro_definition)] @cfg)
 (#eq? @cfg.attribute "cfg"))

((declaration_list
   (attribute_item
     (attribute
       (identifier) @cfg.attribute
       arguments: (token_tree) @cfg.condition))
   .
   (attribute_item)*
   .
   [(function_item) (function_signature_item) (mod_item) (struct_item)
    (union_item) (enum_item) (trait_item) (impl_item) (const_item)
    (static_item) (type_item) (macro_definition)] @cfg)
 (#eq? @cfg.attribute "cfg"))

; ------------------------------------------------- what the crate reads at build
;
; `env!` and `include_str!` are the two language-level ways a Rust file depends
; on something that is not Rust: an environment variable and a file on disk.

((macro_invocation
   macro: (identifier) @config.macro
   (token_tree
     (string_literal (string_content) @config.variable))) @config
 (#any-of? @config.macro "env" "option_env"))

((macro_invocation
   macro: (identifier) @include.macro
   (token_tree
     (string_literal (string_content) @include.path))) @include
 (#any-of? @include.macro "include" "include_str" "include_bytes"))
