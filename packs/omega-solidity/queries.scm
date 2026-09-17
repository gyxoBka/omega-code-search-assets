; omega-solidity
;
; Solidity is the language of deployed smart contracts. The questions asked of
; a .sol file are: what contracts, interfaces and libraries does it declare;
; what state does a contract hold and what functions can move it; who may call
; them; what does it inherit from, import, emit and revert with; and where does
; it drop into inline assembly.
;
; Containment is not stated as a pattern. The tree already holds it, a member
; declared inside a contract already carries that contract through the `within:`
; namespace segment, and each container's extent is emitted once as a region.
; The one place a parent appears below is the constructor, which has no name of
; its own and is named after the contract it belongs to.

; --- what the file requires of the compiler ---

(pragma_directive (solidity_pragma_token) @pragma.solidity.token) @pragma.solidity

(pragma_directive (any_pragma_token . (identifier) @pragma.name)) @pragma.other

; --- what it pulls in ---
;
; `source`, `import_name` and `alias` are all repeated fields of one directive,
; so asking for two of them in one pattern would match their cross product.
; Three patterns, one match each.

(import_directive source: (string) @import.source) @import.directive

(import_directive import_name: (identifier) @import.symbol)

(import_directive alias: (identifier) @import.alias)

; --- the three contract-like declarations ---
;
; One pattern each, carrying both the declaration and the extent of its body.

(contract_declaration
  name: (identifier) @contract.name
  body: (contract_body) @contract.body) @contract

(interface_declaration
  name: (identifier) @interface.name
  body: (contract_body) @interface.body) @interface

(library_declaration
  name: (identifier) @library.name
  body: (contract_body) @library.body) @library

; A constructor is the one declaration in Solidity with no name node. It is
; matched through its contract so it can be named after it; there is at most
; one constructor per contract, so this costs one match, not a tuple.

(contract_declaration
  name: (identifier) @constructor.owner
  body: (contract_body
    (constructor_definition
      body: (function_body) @constructor.body) @constructor))

; --- what a contract is built out of ---

(inheritance_specifier
  ancestor: (user_defined_type (identifier) @inheritance.base .)) @inheritance

(using_directive (type_alias (identifier) @using.library .)) @using

; --- functions ---
;
; `body` is absent on an interface function and `return_type` on most others,
; so both are optional: the templates that need them are skipped when they are
; not there. Visibility and mutability sit in one repeat group whose order the
; grammar does not fix (`external payable` and `payable external` both parse),
; so they are asked for separately rather than in a sequence that would only
; match one of the two spellings.

(function_definition
  name: (identifier) @function.name
  return_type: (return_type_definition)? @function.return_type
  body: (function_body)? @function.body) @function

(function_definition (visibility) @function.visibility) @function.visibility.owner

(function_definition (state_mutability) @function.mutability) @function.mutability.owner

; `fallback()` and `receive()` are declared by keyword, with no name node. The
; keyword is the first word of the declaration, so the name is taken from its
; own text up to the opening parenthesis.

(fallback_receive_definition body: (function_body)? @fallback.body) @fallback

(modifier_definition
  name: (identifier) @modifier.name
  body: (function_body)? @modifier.body) @modifier

(modifier_invocation . (identifier) @call.modifier)

; --- what a contract declares besides functions ---

(event_definition name: (identifier) @event.name) @event

(error_declaration name: (identifier) @error.name) @error

(struct_declaration
  name: (identifier) @struct.name
  body: (struct_body) @struct.body) @struct

(struct_member
  type: (type_name) @field.type
  name: (identifier) @field.name) @field

(enum_declaration
  name: (identifier) @enum.name
  body: (enum_body) @enum.body) @enum

(enum_value) @enumerator

(user_defined_type_definition
  name: (identifier) @udvt.name
  (primitive_type) @udvt.underlying) @udvt

; --- the state a contract holds ---

(state_variable_declaration
  type: (type_name) @state.type
  visibility: (visibility)? @state.visibility
  name: (identifier) @state.name) @state

(constant_variable_declaration
  type: (type_name) @constant.type
  name: (identifier) @constant.name) @constant

; --- what the code does ---
;
; A member call is stated only in the call position. tree-sitter-solidity spells
; a field read and a method callee with the same `member_expression`, and a
; query cannot see its parent, so a bare member reference would report every
; method call a second time as a field of the receiver.

(call_expression function: (expression (identifier) @call.function))

(call_expression
  function: (expression (member_expression property: (identifier) @call.method)))

(new_expression
  name: (type_name (user_defined_type (identifier) @call.constructor .)))

(emit_statement
  name: (expression
          [(identifier) @emit.event
           (member_expression property: (identifier) @emit.event)]))

(revert_statement
  error: (expression
           [(identifier) @revert.error
            (member_expression property: (identifier) @revert.error)]))

(struct_field_assignment name: (identifier) @struct.field.reference)

; --- every mention of a declared type ---
;
; A qualified name is spelled flat, as a run of identifiers inside one
; `user_defined_type`, so the last one is the type and the leading ones are the
; library or contract that qualifies it.

(user_defined_type (identifier) @type.name .)

(struct_expression type: (expression (identifier) @type.name))

; --- inline assembly ---
;
; Only what Yul names: a function it declares and a call to one. EVM builtins
; are captured by neither, since `yul_evm_builtin` is a distinct node. The name
; is taken from the `identifier` inside `yul_identifier`, which wraps it.

(yul_function_definition . (yul_identifier (identifier) @yul.function.name)) @yul.function

(yul_function_call function: (yul_identifier (identifier) @call.assembly))
