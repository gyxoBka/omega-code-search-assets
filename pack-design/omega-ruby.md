# omega-ruby

Language `omega-ruby`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

54 templates over 87 query patterns, 33 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 4 |
| `calls` | yes | 10 |
| `data` | yes | 6 |
| `definitions` | yes | 20 |
| `imports` | yes | 3 |
| `modules` | yes | 1 |
| `references` | yes | 5 |
| `scopes` | yes | 5 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 2 |
| `definition.function` | Callable | 1 |
| `definition.method` | Callable | 2 |
| `definition.module` | Value | 2 |
| `definition.namespace` | Value | 1 |
| `definition.ruby_class` | Type | 1 |
| `definition.ruby_function` | Callable | 1 |
| `definition.ruby_method` | Callable | 1 |
| `definition.ruby_module` | Value | 1 |
| `definition.ruby_namespace` | Value | 1 |
| `definition.ruby_type` | Type | 1 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `call.target_candidate` | `omega.pack.target` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `import.alias_candidate` | `omega.pack.alias` | 1 |
| `relation.inherits_candidate` | `omega.pack.inherits` | 1 |
| `module.ruby_candidate` | `omega.pack.ruby` | 1 |
| `reference.receiver_candidate` | `omega.pack.receiver` | 1 |
| `reference.ruby_identifier_candidate` | `omega.pack.ruby_identifier` | 1 |
| `scope.enclosing_owner_candidate` | `omega.pack.enclosing_owner` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |

### Regions

- `scope.lexical` (2)
- `scope.ruby_lexical_scope` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.ruby_variable` | reference | 1 |
| `binding.var` | reference | 1 |
| `binding.variable.parameter` | reference | 1 |
| `call.call` | call | 2 |
| `call.ruby_block_string_context` | call | 1 |
| `call.ruby_call` | call | 1 |
| `call.ruby_class_qualified_super_block_string_context` | call | 1 |
| `call.ruby_owned_call_context` | call | 1 |
| `call.ruby_owned_string_call_context` | call | 1 |
| `call.ruby_string_arg_context` | call | 1 |
| `call.ruby_string_kwarg_context` | call | 1 |
| `import.require_like` | binding | 1 |
| `reference.local` | reference | 2 |
| `reference.ruby_class_association_explicit_target_context` | reference | 1 |

### Emitted, dropped as mentions, but read as span markers

These are not waste: their spans tell the host that a role boundary
sitting on them is really a literal or a control form.

- `literal.boolean` (2)
- `literal.null` (1)
- `literal.number` (2)
- `literal.string` (1)

## The boundary: what the grammar offers and the Pack ignores

The grammar names 149 node types. The Pack looks at 46 of them.

Untouched:

- `_arg`
- `_call_operator`
- `_expression`
- `_lhs`
- `_method_name`
- `_nonlocal_variable`
- `_pattern_constant`
- `_pattern_expr`
- `_pattern_expr_basic`
- `_pattern_primitive`
- `_pattern_top_expr_body`
- `_primary`
- `_simple_numeric`
- `_statement`
- `_variable`
- `alternative_pattern`
- `array`
- `array_pattern`
- `as_pattern`
- `bare_string`
- `bare_symbol`
- `begin`
- `begin_block`
- `binary`
- `block_argument`
- `break`
- `case`
- `case_match`
- `chained_string`
- `character`
- `class_variable`
- `complex`
- `conditional`
- `delimited_symbol`
- `do`
- `element_reference`
- `else`
- `elsif`
- `empty_statement`
- `encoding`
- `end_block`
- `ensure`
- `escape_sequence`
- `exception_variable`
- `exceptions`
- `expression_reference_pattern`
- `file`
- `find_pattern`
- `for`
- `forward_argument`
- `global_variable`
- `hash`
- `hash_pattern`
- `hash_splat_argument`
- `hash_splat_nil`
- `heredoc_beginning`
- `heredoc_body`
- `heredoc_content`
- `heredoc_end`
- `if`
- `if_guard`
- `if_modifier`
- `in`
- `in_clause`
- `interpolation`
- `keyword_pattern`
- `line`
- `match_pattern`
- `next`
- `operator`
- `operator_assignment`
- `parenthesized_pattern`
- `parenthesized_statements`
- `pattern`
- `program`
- `range`
- `rational`
- `redo`
- `regex`
- `rescue`
- `rescue_modifier`
- `retry`
- `return`
- `right_assignment_list`
- `splat_argument`
- `string_array`
- `subshell`
- `symbol_array`
- `test_pattern`
- `then`
- `unary`
- `undef`
- `uninterpreted`
- `unless`
- `unless_guard`
- `unless_modifier`
- `until`
- `until_modifier`
- `variable_reference_pattern`
- `when`
- `while`
- `while_modifier`
- `yield`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
