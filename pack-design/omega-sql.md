# omega-sql

Language `omega-sql`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

61 templates over 67 query patterns, 35 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `bindings` | yes | 1 |
| `calls` | yes | 1 |
| `data` | yes | 32 |
| `definitions` | yes | 13 |
| `references` | yes | 13 |
| `scopes` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.cte` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.procedure` | Value | 1 |
| `definition.sql_added_column` | Value | 1 |
| `definition.sql_column` | Value | 1 |
| `definition.sql_constraint` | Value | 1 |
| `definition.sql_index` | Value | 1 |
| `definition.sql_trigger` | Value | 1 |
| `definition.table` | Value | 1 |
| `definition.type` | Type | 1 |
| `definition.view` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.category_candidate` | `omega.pack.category` | 1 |
| `definition.identity_candidate` | `omega.pack.identity` | 1 |

### Regions

- `scope.lexical` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `binding.symbol` | reference | 1 |
| `call.invocation` | call | 1 |
| `data.sql_alter_add_constraint` | reference | 1 |
| `data.sql_constraint` | reference | 1 |
| `data.sql_create_from_relation_context` | reference | 1 |
| `data.sql_delete` | reference | 1 |
| `data.sql_insert` | reference | 1 |
| `data.sql_lateral_join` | reference | 1 |
| `data.sql_primary_key` | reference | 1 |
| `data.sql_renamed_column` | reference | 1 |
| `data.sql_subquery` | reference | 1 |
| `data.sql_update` | reference | 1 |
| `semantic_hint.sql_callable_hint` | call | 1 |
| `semantic_hint.sql_lexical_role` | reference | 12 |
| `semantic_hint.sql_literal_hint` | reference | 4 |
| `semantic_hint.sql_type_hint` | reference | 2 |
| `semantic_hint.sql_value_hint` | reference | 3 |
| `reference.object` | reference | 1 |
| `reference.sql_alter_drop_constraint` | reference | 1 |
| `reference.sql_alter_table` | reference | 1 |
| `reference.sql_column` | reference | 1 |
| `reference.sql_drop_table` | reference | 1 |
| `reference.sql_dropped_column` | reference | 1 |
| `reference.sql_foreign_key_target` | reference | 1 |
| `reference.sql_index_target` | reference | 1 |
| `reference.sql_insert_target` | reference | 1 |
| `reference.sql_join_target` | reference | 2 |
| `reference.sql_qualified_column` | reference | 1 |
| `reference.sql_update_target` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 555 node types. The Pack looks at 403 of them.

Untouched:

- `all_fields`
- `alter_column`
- `alter_database`
- `alter_index`
- `alter_materialized_view`
- `alter_policy`
- `alter_role`
- `alter_schema`
- `alter_sequence`
- `alter_type`
- `alter_view`
- `array`
- `array_size_definition`
- `assignment`
- `assignment_list`
- `bang`
- `between_expression`
- `bigint`
- `binary`
- `binary_expression`
- `bit`
- `block`
- `case`
- `change_column`
- `change_ownership`
- `char`
- `column`
- `column_definitions`
- `column_position`
- `comment_statement`
- `composite_field`
- `constraints`
- `covering_columns`
- `create_database`
- `create_extension`
- `create_materialized_view`
- `create_policy`
- `create_role`
- `create_schema`
- `create_sequence`
- `datetimeoffset`
- `decimal`
- `direction`
- `distinct_from`
- `dollar_quote`
- `drop_database`
- `drop_extension`
- `drop_function`
- `drop_index`
- `drop_materialized_view`
- `drop_procedure`
- `drop_role`
- `drop_schema`
- `drop_sequence`
- `drop_type`
- `drop_view`
- `enum`
- `enum_elements`
- `exists`
- `filter_expression`
- `float`
- `frame_definition`
- `function_argument`
- `function_arguments`
- `function_body`
- `function_cost`
- `function_language`
- `function_leakproof`
- `function_rows`
- `function_safety`
- `function_security`
- `function_strictness`
- `function_support`
- `function_volatility`
- `group_by`
- `having`
- `index_fields`
- `index_hint`
- `int`
- `interval`
- `is_not`
- `keyword_current_role`
- `keyword_current_user`
- `keyword_disable`
- `keyword_enable`
- `keyword_permissive`
- `keyword_policy`
- `keyword_public`
- `keyword_refresh`
- `keyword_restrictive`
- `keyword_rlike`
- `keyword_session_user`
- `lateral_cross_join`
- `limit`
- `list`
- `mediumint`
- `modify_column`
- `nchar`
- `not_distinct_from`
- `not_in`
- `not_like`
- `not_rlike`
- `not_similar_to`
- `numeric`
- `nvarchar`
- `object_id`
- `offset`
- `order_by`
- `order_target`
- `parenthesized_expression`
- `partition_by`
- `procedure_body`
- `program`
- `refresh_materialized_view`
- `rename_object`
- `reset_statement`
- `returning`
- `row_format`
- `select`
- `select_expression`
- `set_configuration`
- `set_operation`
- `set_schema`
- `set_statement`
- `similar_to`
- `smallint`
- `statement`
- `storage_location`
- `storage_parameters`
- `stored_as`
- `subscript`
- `table_partition`
- `table_sort`
- `tablespace`
- `tablet_split`
- `time`
- `timestamp`
- `tinyint`
- `transaction`
- `unary_expression`
- `values`
- `var_declaration`
- `var_declarations`
- `varbinary`
- `varchar`
- `when_clause`
- `where`
- `while_statement`
- `window_clause`
- `window_frame`
- `window_function`
- `window_specification`

## To decide when rewriting

1. Which untouched node types carry meaning for an agent's question,
   and under which capability they belong.
2. Which kinds above route to a family the author did not mean --
   check the family column against what the construct actually is.
3. Which patterns ask for the same node separately and should be one.
4. What is stated that answers no question.
