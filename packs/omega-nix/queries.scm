; omega-nix
;
; Nix is the language of `flake.nix`, `default.nix`, `shell.nix`, package
; derivations and NixOS/home-manager modules. The questions asked of a Nix
; file are: what does it declare, what is an attribute set to, which names
; does it use, what does it call, and which files or search paths does it
; depend on. Every pattern below answers one of those.
;
; Nix has exactly one declaring form -- the binding `attrpath = expression;`
; -- plus `inherit`, and one parameter form, `formals`/`universal`. So the
; four binding patterns partition `_expression` by the kind of value bound:
; they are disjoint and together exhaustive over the grammar's 24 expression
; subtypes, and a binding is therefore matched exactly once.
;
; Containment is deliberately not stated. The tree already holds it, and a
; named region is emitted only where the construct has a name to carry.

; --- a binding whose value is a function ---
;
; `foo = { pkgs, lib }: body;` is how Nix declares a callable. One match
; carries the declaration, the body region, and the parameter shape that
; builds the card's signature line -- the two spellings of the parameter
; list are optional captures, so each carrier template is skipped on the
; spelling it does not apply to.

(binding
  attrpath: (attrpath
    attr: (identifier) @function.name .)
  expression: (function_expression
    formals: (formals)? @function.formals
    universal: (identifier)? @function.universal
    body: (_) @function.body)) @function

; --- a binding whose value is an attribute set ---
;
; `programs = { ... };` names a region an agent can ask the extent of.

(binding
  attrpath: (attrpath
    attr: (identifier) @attrset.name .)
  expression: [
    (attrset_expression)
    (rec_attrset_expression)
    (let_attrset_expression)
  ] @attrset.body) @attrset

; --- a binding whose value is a scalar or an alias ---
;
; `version = "1.2.3";`, `port = 8080;`, `src = ./src;`, `cfg = config;`.
; This is where an agent's "what is this set to" is answered, so the value
; is carried on the declaration itself rather than emitted as a mention that
; would resolve against nothing. Quotes are stripped so the stored value is
; what Nix evaluates to.
;
; Indented strings and lists are bound by the pattern below instead: a `''
; ... ''` in Nix is normally a script body and a list is normally long, and
; neither is a value a question can be asked of.

(binding
  attrpath: (attrpath
    attr: (identifier) @value.name .)
  expression: [
    (string_expression)
    (integer_expression)
    (float_expression)
    (path_expression)
    (spath_expression)
    (hpath_expression)
    (uri_expression)
    (variable_expression)
    (select_expression)
  ] @value.literal) @value.binding

; --- every other binding ---
;
; The remaining eleven expression subtypes. The attribute is declared; its
; value is a computed expression and is not stored.

(binding
  attrpath: (attrpath
    attr: (identifier) @attribute.name .)
  expression: [
    (apply_expression)
    (assert_expression)
    (binary_expression)
    (has_attr_expression)
    (if_expression)
    (indented_string_expression)
    (let_expression)
    (list_expression)
    (parenthesized_expression)
    (unary_expression)
    (with_expression)
  ]) @attribute

; --- inherit ---
;
; `inherit pkgs lib;` and `inherit (pkgs) hello;` make those names
; attributes of the enclosing set, so each attr is declared. One match per
; inherited name; the same pattern covers both spellings, since `inherit`
; and `inherit_from` share the `inherited_attrs` node.

(inherited_attrs
  attr: (identifier) @inherit.name)

; --- parameters ---
;
; The formals of a file-level function are that file's inputs: `{ pkgs, lib,
; ... }:` at the top of a derivation or a module. Declared, so that uses of
; the name inside the file resolve to it.

(formal
  name: (identifier) @formal.name) @formal

(function_expression
  universal: (identifier) @universal.name)

; --- a name used ---
;
; `variable_expression` is Nix's only bare-name use. It is not the universal
; identifier capture: the grammar spells attribute names, formals, inherited
; attrs and attrpath segments as their own nodes, so this reaches only names
; that are read as values.

(variable_expression
  name: (identifier) @variable.name) @variable

; --- an attribute read ---
;
; `pkgs.hello`, `config.services.nginx.enable`. Anchored to the last
; segment, so the mention is named the way the binding that declares it is
; named; the leading segments are themselves `variable_expression` uses.

(select_expression
  attrpath: (attrpath
    attr: (identifier) @select.name .)) @select

; --- a call ---
;
; A Nix function is a value, so `f` in `f x` may be any expression. Only the
; two spellings that name a callee are stated: `mkIf cond x` and
; `lib.mkIf cond x`. `f a b` is apply(apply(f, a), b), so the callee is
; named once per chain, not once per argument.

(apply_expression
  function: [
    (variable_expression
      name: (identifier) @call.name)
    (select_expression
      attrpath: (attrpath
        attr: (identifier) @call.name .))
  ]) @call

; --- what the file depends on ---
;
; A path literal in Nix refers to a file, whether or not it is handed to
; `import`. The first fragment is the name: an interpolated path
; (`./modules/${host}.nix`) is several fragments and only the literal head
; of it is knowable here.

[
  (path_expression
    . (path_fragment) @path.first)
  (hpath_expression
    . (path_fragment) @path.first)
] @path.expression

; `<nixpkgs>` -- a lookup in NIX_PATH, stripped of its brackets.

(spath_expression) @spath

; A bare URI literal, the other way a Nix file names something outside it.

(uri_expression) @uri
