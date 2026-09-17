# omega-powershell

Language `omega-powershell`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

31 templates over 38 query patterns, 21 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 5 |
| `calls` | yes | 2 |
| `data` | yes | 3 |
| `definitions` | yes | 13 |
| `imports` | yes | 2 |
| `references` | yes | 3 |
| `scopes` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.associated` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.method` | Callable | 1 |
| `definition.powershell_enum` | Type | 1 |
| `definition.powershell_enum_member` | Type | 1 |
| `definition.powershell_method_return_type` | Type | 1 |
| `definition.powershell_typed_property` | Type | 1 |
| `definition.type` | Type | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `binding.parameter_owned_candidate` | `omega.pack.parameter_owned` | 1 |
| `definition.category_candidate` | `omega.pack.category` | 3 |
| `definition.member_owned_candidate` | `omega.pack.member_owned` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |
| `scope.named_owner_candidate` | `omega.pack.named_owner` | 1 |
| `type.powershell_declaration_candidate` | `omega.pack.powershell_declaration` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.field` | reference | 1 |
| `binding.parameter` | reference | 1 |
| `binding.powershell_foreach` | reference | 1 |
| `binding.var` | reference | 1 |
| `call.powershell_command` | call | 1 |
| `call.powershell_command_dynamic` | call | 1 |
| `data.powershell_hashtable_entry` | reference | 1 |
| `data.powershell_pipeline` | reference | 1 |
| `data.powershell_redirection` | reference | 1 |
| `import.powershell_module` | binding | 1 |
| `import.powershell_module_literal_argument` | binding | 1 |
| `reference.local` | reference | 1 |
| `reference.powershell_attribute` | reference | 1 |
| `reference.powershell_member` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 151 node types. The Pack looks at 49 of them.

Untouched:

- `additive_argument_expression`
- `argument_expression`
- `argument_expression_list`
- `argument_list`
- `array_expression`
- `array_type_name`
- `assignement_operator`
- `attribute_argument`
- `attribute_arguments`
- `bitwise_argument_expression`
- `block_name`
- `braced_variable`
- `catch_clause`
- `catch_clauses`
- `catch_type_list`
- `class_attribute`
- `class_method_parameter`
- `command_argument_sep`
- `command_invokation_operator`
- `command_parameter`
- `comment`
- `comparison_argument_expression`
- `comparison_operator`
- `data_command`
- `data_commands_allowed`
- `data_commands_list`
- `data_statement`
- `decimal_integer_literal`
- `dimension`
- `do_statement`
- `element_access`
- `else_clause`
- `elseif_clause`
- `elseif_clauses`
- `empty_statement`
- `expandable_here_string_literal`
- `expandable_string_literal`
- `finally_clause`
- `flow_control_statement`
- `for_condition`
- `for_initializer`
- `for_iterator`
- `for_statement`
- `foreach_command`
- `foreach_parameter`
- `format_argument_expression`
- `format_operator`
- `generic_token`
- `generic_type_arguments`
- `generic_type_name`
- `hash_literal_body`
- `hash_literal_expression`
- `hexadecimal_integer_literal`
- `if_statement`
- `inlinescript_statement`
- `integer_literal`
- `invokation_foreach_expression`
- `label`
- `label_expression`
- `logical_argument_expression`
- `merging_redirection_operator`
- `multiplicative_argument_expression`
- `named_block`
- `named_block_list`
- `parallel_statement`
- `param_block`
- `parenthesized_expression`
- `path_command_name`
- `path_command_name_token`
- `post_decrement_expression`
- `post_increment_expression`
- `pre_decrement_expression`
- `pre_increment_expression`
- `program`
- `range_argument_expression`
- `real_literal`
- `redirections`
- `script_block_body`
- `script_block_expression`
- `script_parameter_default`
- `sequence_statement`
- `statement_list`
- `stop_parsing`
- `sub_expression`
- `switch_body`
- `switch_clause`
- `switch_clause_condition`
- `switch_clauses`
- `switch_condition`
- `switch_filename`
- `switch_parameter`
- `switch_parameters`
- `switch_statement`
- `trap_statement`
- `try_statement`
- `type_identifier`
- `type_name`
- `verbatim_command_argument`
- `verbatim_here_string_characters`
- `verbatim_string_characters`
- `while_condition`
- `while_statement`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
