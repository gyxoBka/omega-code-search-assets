# omega-solidity

Language `omega-solidity`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

50 templates over 36 query patterns, 47 distinct named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 5 |
| `definitions` | yes | 27 |
| `imports` | yes | 3 |
| `references` | yes | 5 |
| `scopes` | yes | 9 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.assembly_function` | Callable | 1 |
| `definition.config_pragma` | Config | 2 |
| `definition.constant` | Value | 1 |
| `definition.constructor` | Callable | 1 |
| `definition.contract_class` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.enumerator` | Value | 1 |
| `definition.error` | Value | 1 |
| `definition.event` | Value | 1 |
| `definition.fallback_function` | Callable | 1 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.interface` | Type | 1 |
| `definition.library_class` | Type | 1 |
| `definition.modifier_function` | Callable | 1 |
| `definition.state_variable` | Value | 1 |
| `definition.struct` | Type | 1 |
| `definition.user_value_type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 4 |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.visibility_candidate` | `omega.pack.visibility` | 2 |

All four names are ones the engine reads: `visibility`, `modifier` and
`return_type` build the signature line on a card, and `declared_type` is on the
list the resolver consults.

### Regions

- `scope.contract_body` (3) -- contract, interface, library
- `scope.function_body` (4) -- function, constructor, fallback/receive, modifier
- `scope.type_body` (2) -- struct, enum

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.assembly_function` | call | 1 |
| `call.constructor` | call | 1 |
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `call.modifier` | call | 1 |
| `import.alias` | binding | 1 |
| `import.module` | binding | 1 |
| `import.symbol` | binding | 1 |
| `reference.error` | reference | 1 |
| `reference.event` | reference | 1 |
| `reference.field` | reference | 1 |
| `relation.depends` | depends | 1 |
| `relation.implements` | implements | 1 |
| `type_use.name` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 124 node types. The Pack looks at 47 of them; it looked at 36.

Untouched:

- `any_source_type`
- `array_access`
- `assembly_flags`
- `assembly_statement`
- `assignment_expression`
- `augmented_assignment_expression`
- `binary_expression`
- `block_statement`
- `boolean_literal`
- `break_statement`
- `call_argument`
- `call_struct_argument`
- `catch_clause`
- `comment`
- `continue_statement`
- `do_while_statement`
- `error_parameter`
- `event_parameter`
- `expression_statement`
- `false`
- `for_statement`
- `hex_string_literal`
- `if_statement`
- `immutable`
- `inline_array_expression`
- `layout_specifier`
- `meta_type_expression`
- `number_literal`
- `number_unit`
- `override_specifier`
- `parameter`
- `parenthesized_expression`
- `payable_conversion_expression`
- `pragma_value`
- `return_parameter`
- `return_statement`
- `revert_arguments`
- `slice_access`
- `solidity_version`
- `solidity_version_comparison_operator`
- `source_file`
- `state_location`
- `statement`
- `string_literal`
- `ternary_expression`
- `true`
- `try_statement`
- `tuple_expression`
- `type_cast_expression`
- `unary_expression`
- `unchecked`
- `unicode_string_literal`
- `update_expression`
- `user_definable_operator`
- `using_alias`
- `variable_declaration`
- `variable_declaration_statement`
- `variable_declaration_tuple`
- `virtual`
- `while_statement`
- `yul_assignment`
- `yul_block`
- `yul_boolean`
- `yul_break`
- `yul_continue`
- `yul_decimal_number`
- `yul_evm_builtin`
- `yul_for_statement`
- `yul_hex_number`
- `yul_hex_string_literal`
- `yul_if_statement`
- `yul_label`
- `yul_leave`
- `yul_path`
- `yul_string_literal`
- `yul_switch_statement`
- `yul_variable_declaration`

Most of that list is expression and statement syntax -- `if_statement`,
`binary_expression`, `tuple_expression`, every literal form -- which names
nothing a question could resolve against, plus the Yul statement forms inside
`assembly`. Three groups are left out deliberately and are named in the
coverage guards: the parameter nodes (`parameter`, `event_parameter`,
`error_parameter`, `return_parameter`), because the grammar gives no node
spanning a parameter list; the local-variable nodes
(`variable_declaration`, `variable_declaration_statement`,
`variable_declaration_tuple`); and the Yul statement nodes.

## What is wrong with it

Counted against the Pack as it stood: **29 templates over 64 patterns, with 28
coverage guards.**

**Fifteen of the 29 templates were carriers under a name nothing assembles.**
The audit named them: `omega.pack.target` (twice, under two different kinds),
`omega.pack.identity`, `omega.pack.enclosing_owner`, `omega.pack.member_category`,
`omega.pack.member_owned`, `omega.pack.named_owner`,
`omega.pack.member_access`, `omega.pack.solidity_declaration`,
`omega.pack.alias`, `omega.pack.module_path`. Each was evaluated per match and
written into the item's bag, and no code in the engine ever asks for any of them.
`definition.identity_candidate` is the clearest: it carried a declaration's own
name onto the declaration at its own span.

**Eight of those carriers could not be folded at all.** `call.target_candidate`,
`type.solidity_declaration_candidate`, `scope.enclosing_owner_candidate`,
`import.alias_candidate`, `import.target_candidate`,
`import.module_path_candidate`, `reference.member_access_candidate` and
`scope.named_owner_candidate` end in `_candidate` but fail `is_definition_kind`,
so rather than attaching an attribute they fell through to the mention branch
and were stored as references to nothing.

**Six templates named an emission with a whole node.** `scope.lexical` was named
from the entire `function_definition` -- the complete text of every function in
the corpus, stored as a name, once per function and once per block.
`call.call` was named from the whole `call_expression`, arguments included.
`reference.type_or_event_reference` was named from the whole `emit_statement`,
`import.import_reference` from the whole `import_directive`,
`type.solidity_declaration_candidate` from the whole `enum_declaration`, and
`semantic_hint.solidity_contract_declaration_structure_hint` from the whole
`contract_declaration` -- an entire contract, body included, written into the
index as the name of a hint that nothing reads.

**Twenty-two of the 64 patterns stated containment.** The `member_category_*`
and `ownership_members` families spelled out
`(contract_declaration name: (_) body: (contract_body (function_definition name: (_))))`
and eleven more of the same shape, once per member kind and once per container
kind, to say that a function is inside a contract. The tree already says that,
and the host already carries it through the `within:` namespace segment. Worse,
every template over them took the *contract* as its span and a *member's* name
as its value, so a contract with N members wrote one attribute N times onto one
declaration and kept whichever came last.

**Four guards gave a label instead of a reason**
(`solidity_distributed_highlight_ast_fact_not_symbol_truth`,
`terminal_static_ceiling__solidity_contract_resolution`,
`terminal_static_ceiling__solidity_local_resolution` and
`solidity_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`),
and the remaining 24 were the same sentence -- "resolution requires a
resolver" -- restated once per capability and once per template. Twenty-eight
guards for 29 templates.

**Four declaration kinds routed to the wrong family.**
`definition.contract_or_type` and `definition.interface_or_library` were each
one kind for two different constructs, and `interface_or_library` contains no
word the host knows, so every interface and every library in a repository was
filed as a Value. `definition.solidity_constructor` and
`definition.solidity_enum_value` both landed in Type: the first because
`constructor` then matched on the substring `struct`, the second because `enum`
is a Type word. A constructor was a type and an enum member was a type.

**The Pack declared almost nothing that Solidity declares.** Eight declaration
kinds in all, and missing from them: `fallback` and `receive`, modifiers, custom
errors, state variables under a kind of their own, struct fields, libraries as
distinct from interfaces, the compiler pragma, and the constructor's name -- the
constructor was declared, but named from a capture that no pattern bound
together with it.

**Two patterns were upstream baselines pasted in.** `upstream_locals_exact`
brought `(assignment_expression left: (_) @local.definition)`, which declares
every assignment target in every file as a binding, and
`(function_definition) @local.scope` / `(block_statement) @local.scope`, which is
where the whole-function name came from. `upstream_tags_exact` brought a second,
contradictory spelling of every declaration the Pack already made -- which is why
`definition.method` and `definition.function` both existed over the same
`function_definition` nodes, one of them reached only from inside a contract.

**A `data` capability whose only template was a highlight fact.**
`semantic_hint.solidity_contract_declaration_structure_hint` over
`(contract_declaration) @structural.candidate`, under a comment citing an
nvim-treesitter `highlights.scm` as its evidence: one emission per contract,
named with the contract's entire text, read by nothing.

## What it should extract

Solidity is the language of deployed contracts, and the questions asked of a
`.sol` file are auditing questions: what does this contract declare, what state
does it hold, who may call what, what does it inherit, import, emit and revert
with, and where does it drop into inline assembly.

| what | node | emitted as | family |
|---|---|---|---|
| a contract | `contract_declaration` via `name` | `definition.contract_class` | Type |
| its body's extent | `contract_body` | `scope.contract_body` | region |
| an interface | `interface_declaration` via `name` | `definition.interface` | Type |
| a library | `library_declaration` via `name` | `definition.library_class` | Type |
| a base contract | `inheritance_specifier`, last `identifier` of `ancestor` | `relation.implements` | implements |
| `using L for T` | `using_directive`, last `identifier` of `type_alias` | `relation.depends` | depends |
| a function | `function_definition` via `name` | `definition.function` | Callable |
| its visibility | `visibility` | `visibility_candidate` on the function | attribute |
| its mutability | `state_mutability` | `modifier_candidate` on the function | attribute |
| its return type | `return_type_definition`, `returns` stripped | `return_type_candidate` on the function | attribute |
| its body's extent | `function_body` | `scope.function_body` | region |
| a constructor | `constructor_definition`, named after its contract | `definition.constructor` | Callable |
| `fallback` / `receive` | `fallback_receive_definition`, named from its first word | `definition.fallback_function` | Callable |
| a modifier | `modifier_definition` via `name` | `definition.modifier_function` | Callable |
| applying a modifier | `modifier_invocation`, first `identifier` | `call.modifier` | call |
| an event | `event_definition` via `name` | `definition.event` | Value |
| a custom error | `error_declaration` via `name` | `definition.error` | Value |
| a struct | `struct_declaration` via `name` | `definition.struct` | Type |
| a struct field | `struct_member` via `name` | `definition.field` | Value |
| its declared type | `type_name` | `declared_type_candidate` on the field | attribute |
| an enum | `enum_declaration` via `name` | `definition.enum` | Type |
| an enum member | `enum_value` | `definition.enumerator` | Value |
| a user-defined value type | `user_defined_type_definition` via `name` | `definition.user_value_type` | Type |
| a state variable | `state_variable_declaration` via `name` | `definition.state_variable` | Value |
| its visibility, its type | `visibility`, `type_name` | carriers on the variable | attribute |
| a file-level constant | `constant_variable_declaration` via `name` | `definition.constant` | Value |
| the compiler pragma | `solidity_pragma_token`, `any_pragma_token` | `definition.config_pragma` | Config |
| an import path | `import_directive` via `source`, quotes stripped | `import.module` | binding |
| an imported symbol | `import_directive` via `import_name` | `import.symbol` | binding |
| an import alias | `import_directive` via `alias` | `import.alias` | binding |
| a free call | `call_expression`, `identifier` under `function` | `call.function` | call |
| a member call | `call_expression`, `property` of the callee | `call.method` | call |
| `new C(...)` | `new_expression`, last `identifier` of its type | `call.constructor` | call |
| `emit E(...)` | `emit_statement` via `name` | `reference.event` | reference |
| `revert E(...)` | `revert_statement` via `error` | `reference.error` | reference |
| a struct field set by name | `struct_field_assignment` via `name` | `reference.field` | reference |
| any mention of a named type | `user_defined_type`, `struct_expression` | `type_use.name` | reference |
| a Yul function | `yul_function_definition`, its first identifier | `definition.assembly_function` | Callable |
| a Yul call | `yul_function_call` via `function` | `call.assembly_function` | call |
| expressions, statements, literals, Yul statements | -- | nothing | -- |

Three kinds carry a word chosen against the grammar's own spelling.
`definition.contract_class` and `definition.library_class`: a Solidity contract
and a library are class-like types, and neither `contract` nor `library` is a
word the host knows, so `class` is what puts them in Type where an agent asking
for a type will find them. `definition.enumerator` is spelled that way *because*
`enum` is a Type word and whole-word matching would otherwise file an enum
member as a type -- which is exactly what `definition.solidity_enum_value` did.
`definition.modifier_function` reaches Callable on the word `function`: a
Solidity modifier takes parameters, has a body and is invoked, so Callable is
where it belongs.

Every `relation.*` kind is one of the six the host knows: `relation.implements`
for inheritance, `relation.depends` for `using ... for`. Nothing else in the
language is a relation, so nothing else pretends to be one.

## What the audit still reports, and why it is right here

`carrier that may overwrite itself` -- 2, both on `function_definition`:
`definition.visibility_candidate` from `(visibility)` and
`definition.modifier_candidate` from `(state_mutability)`. This is the false
positive the typescript rewrite documented. tree-sitter-solidity puts
`visibility`, `state_mutability`, `virtual`, `override_specifier` and
`modifier_invocation` into one repeat group, so the grammar admits two
`visibility` tokens on one function and `repeats_in()` sees it. Solidity does
not: `function f() public private` does not compile, and one value is written,
not N. It is also why those two are separate patterns rather than one sequence:
the grammar does not fix their order, so `external payable` and `payable
external` both parse and a single sequenced pattern would bind only one of the
two spellings.

Every other class the audit measures is zero.

## Still to decide

1. **Function parameters are not stated at all.** The grammar has no node
   spanning `(uint256 a, address b)` -- the parameters are direct children of
   `function_definition` between two anonymous tokens -- so
   `omega.pack.parameter_shape` cannot be assembled from any capture, and a
   card's signature line for a Solidity function reads `transfer -> (bool)`
   with the parameters missing. The alternative is to declare every `parameter`,
   `event_parameter` and `error_parameter` as its own `definition.parameter`:
   one Value declaration per parameter in the repository, for a name that
   resolves against nothing outside its own function. Left out, with a guard
   that says so. If the signature line matters more than the row count, that is
   the route; a `parameter_shape` carrier is not available at all without a
   grammar change.
2. **Function locals are not declared.** `variable_declaration_statement` is
   ignored, as it is in the rewritten omega-go and omega-typescript. A local
   named `amount` in one function would resolve by name against every other
   `amount` in the repository.
3. **A bare `member_expression` is not a reference.** `token.balanceOf` under a
   call and `order.amount` as a field read are the same node, and a query cannot
   see the parent, so emitting the property everywhere would report every method
   call a second time as a field of its receiver -- the defect measured in
   omega-rust at 68.8% of its largest emission class. Only the call position and
   `struct_field_assignment` are stated, so a field read outside a struct
   literal is not recorded.
4. **Inline assembly stops at names.** `sload`, `mstore` and the rest are
   `yul_evm_builtin`, a distinct node, and are not emitted: they are EVM
   opcodes, not anything a file declares. Whether "which contracts use inline
   assembly at all" deserves a region of its own is open -- a
   `scope.assembly_block` needs a name, and the only name available is the
   constant `assembly`, which is Defect J. Left out.
