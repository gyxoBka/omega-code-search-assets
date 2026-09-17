# omega-sql

Language `omega-sql`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

33 templates over 27 query patterns, 48 node types named in the query file --
37 of them constructs, 11 of them keyword tokens used only as anchors.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 1 |
| `definitions` | yes | 20 |
| `references` | yes | 12 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.column` | Value | 2 |
| `definition.constraint` | Value | 1 |
| `definition.correlation_name` | Value | 1 |
| `definition.cte` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.index` | Value | 1 |
| `definition.namespace` | Namespace | 1 |
| `definition.procedure` | Callable | 1 |
| `definition.result_column` | Value | 1 |
| `definition.sequence` | Value | 1 |
| `definition.table` | Value | 1 |
| `definition.trigger` | Value | 1 |
| `definition.type` | Type | 1 |
| `definition.variable` | Value | 1 |
| `definition.view` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |

### Regions

None. See *What it deliberately does not state*.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `reference.column` | reference | 3 |
| `reference.constraint` | reference | 1 |
| `reference.dropped_object` | reference | 1 |
| `reference.table` | reference | 1 |
| `relation.data` | data | 2 |
| `relation.depends` | depends | 4 |

### Coverage guards

Five, each naming a limitation in SQL's own terms: the dropped qualifier of
`u.email`, the dropped schema segment of `analytics.events`, the absence of any
import or file path to resolve a name against, SQL assembled at runtime, and
the derived table `FROM (SELECT ...) AS t` whose alias is not named.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 555 node types, 371 of which are `keyword_*` tokens. The Pack
names 48, and 37 of those are constructs.

Untouched, excluding the keyword tokens:

- `add_column`
- `add_constraint`
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
- `cast`
- `change_column`
- `change_ownership`
- `char`
- `column`
- `column_definitions`
- `column_position`
- `comment`
- `comment_statement`
- `composite_field`
- `constraints`
- `covering_columns`
- `create_database`
- `create_policy`
- `create_query`
- `create_role`
- `cross_join`
- `datetimeoffset`
- `decimal`
- `delete`
- `direction`
- `distinct_from`
- `dollar_quote`
- `double`
- `drop_database`
- `drop_role`
- `enum`
- `enum_elements`
- `exists`
- `filter_expression`
- `float`
- `frame_definition`
- `from`
- `function_argument`
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
- `join`
- `lateral_cross_join`
- `lateral_join`
- `limit`
- `list`
- `literal`
- `marginalia`
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
- `op_other`
- `op_unary_other`
- `order_by`
- `order_target`
- `ordered_columns`
- `parameter`
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
- `subquery`
- `subscript`
- `table_option`
- `table_partition`
- `table_sort`
- `tablespace`
- `tablet_split`
- `time`
- `timestamp`
- `tinyint`
- `transaction`
- `unary_expression`
- `update`
- `values`
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

Most of that list is reached through a node the Pack does name, and reaching it
again would be Defect E. `add_column`, `change_column`, `modify_column`,
`column_definitions` and `constraints` all hold a `column_definition` or a
`constraint`, and those are matched wherever they sit. `from`, `join`,
`cross_join`, `lateral_join`, `update`, `delete`, `select`, `select_expression`,
`create_query`, `subquery` and `set_operation` all reach a table through
`relation`, and `relation` is matched once for all of them. `index_fields`,
`covering_columns`, `composite_field`, `order_by`, `group_by`, `partition_by`
and `where` reach a column through `field`.

The type nodes -- `int`, `varchar`, `numeric`, `timestamp`, `enum`,
`array_size_definition` and the twenty others -- are reached as the `type:`
field of `column_definition` and carried onto the column; naming each of them
separately would state the same fact once per dialect spelling.

What is genuinely left out, and why:

- **Expressions.** `binary_expression`, `case`, `when_clause`, `exists`,
  `between_expression`, `subscript`, `cast`, `window_function` and the rest.
  A predicate is not a name; the columns and functions inside it are already
  stated as `field` and `invocation`.
- **Literals**, including `literal`, `object_id` and the numeric type nodes as
  values. The Pack emits no `reference_context.*` kind, so a `literal.*`
  emission would suppress nothing and the host would drop it (§5 of the brief).
- **Comments**, `comment` and `marginalia`. The old Pack injected a language
  called `comment` into them, which no grammar in this repository provides.
- **Operational DDL**: `create_role`, `create_database`, `create_policy`,
  `alter_role`, `alter_database`, `alter_policy`, `set_statement`,
  `set_configuration`, `reset_statement`, `tablespace`, `transaction`,
  `storage_location`, `row_format`, `stored_as`, `table_partition`. These
  configure a server, not a schema an agent asks questions about.
- **`table_option`** (`ENGINE=InnoDB`, `AUTO_INCREMENT=5`). A table option
  states nothing a query resolves to. The old Pack used it for the one
  construct it had left: see below.
- **`parameter`** (`$1`, `?`, `:name`). Declaring `$1` in every statement in a
  repository collapses thousands of spans onto a handful of names.
- **`rename_object`**, `alter_view`, `alter_index`, `alter_sequence`,
  `alter_type`, `alter_schema`, `refresh_materialized_view`,
  `comment_statement`. Each names an object that is already declared elsewhere;
  they are the next thing to add if "every statement that touches this table"
  turns out to need them, and each is one flat pattern.

## What is wrong with it

Measured before the rewrite: **52 templates over 58 patterns, 10 guards**,
naming 399 of the grammar's node types -- 360 of them `keyword_*`.

**Twenty-two of 52 templates were a syntax highlighter.** One block of the
query file was a copied nvim-treesitter `highlights.scm`, header and
`source_sha256` included. It captured 360 keyword tokens in five alternations,
every `literal`, every operator, both bracket kinds and the three punctuation
marks, and `rules.json` put a template on each capture: `semantic_hint.sql_lexical_role`
twelve times, `semantic_hint.sql_literal_hint` four times,
`semantic_hint.sql_value_hint` three times, `semantic_hint.sql_type_hint`
twice. Each of those is a mention named with the token's own text, so a corpus
of SQL was indexed as a stream of references called `SELECT`, `FROM`, `(`, `,`
and `;`. That is the whole `data` capability of the Pack, and it answered
nothing. The `keyword_*` half of the "399 node types touched" figure is this
block and only this block.

**Three declarations were named with the whole statement.** `definition.procedure`
and `definition.function` had `span_capture` and `name` both on the bare
`(create_procedure)` / `(create_function)` node, so the name of a function was
its entire body -- every line of PL/pgSQL, stored as a name. `scope.lexical`
did the same with `function_declaration`, and three `semantic_hint.sql_literal_hint`
templates did it with `(literal)`. The audit reported eight instances of D2 on
this Pack; six were these.

**The rest of the `data` capability was a second spelling of the `references`
one.** `data.sql_create_from_relation_context`, `data.sql_renamed_column`,
`data.sql_primary_key` and `data.sql_alter_add_constraint` are all turned into
a plain reference by the host, exactly like `reference.sql_insert_target`,
`reference.sql_update_target`, `reference.sql_alter_table` and the nine other
`reference.sql_*` kinds beside them. Twenty-one mention kinds in all, and three
occurrence sorts between them: call, reference, reference. Not one kind was a
`relation.*` the host knows, so nothing this Pack said was ever recorded as a
data edge or as a dependency, and `CREATE VIEW v AS SELECT ... FROM t` produced
a reference named `v` rather than an edge from `v` to `t`.

**`data.sql_primary_key` was named with the constant `'primary_key'`** (Defect
J): every primary key in every file in the repository collapsed onto one name.

**The one carrier carried nothing anyone assembles.**
`definition.identity_candidate` folds to `omega.pack.identity`, which no code
in the engine reads, and its value was taken from `table_option` -- a MySQL
`ENGINE=`/`AUTO_INCREMENT=` clause -- so the "identity" of a table was the word
`InnoDB`. It was also the Pack's only carrier, which means the ten declarations
it did make carried no visibility, no parameter shape and no return type: every
function card read as a bare name.

**The create-from pattern was cubic and stated what the tree already says.**

    (create_view (object_reference) @out
      (create_query (from (relation (object_reference) @in))))

Four edges deep, twice (once for `create_view`, once for `create_table`), to
say that a view selects from a table -- which the `relation` inside it says on
its own, once, in one pattern that also covers every `SELECT`, `JOIN`, `UPDATE`
and `DELETE` in the language.

**Two patterns took the wrong `object_reference` because they were not
anchored.** `(create_index (object_reference) @sql.index.target)` matched the
index name as well as the indexed table, so `CREATE INDEX idx_users_email ON
users (email)` reported `idx_users_email` as a table that the index depends on;
and `(object_reference) @reference.object` at top level -- unanchored and
unqualified -- emitted a reference for every object name in the file, including
the ones the same file was declaring.

**Every declaration was named with the whole `object_reference`**, so
`CREATE TABLE public.users` declared a table called `public.users` while
`FROM users` referenced `users`, and the two never met.

**Ten guards, three of them a single token**: `binding_nodes_are_syntactic_candidates_not_resolved_values`,
`syntactic_scope_boundaries_only_no_runtime_scope_inference`,
`sql_highlight_capture_not_symbol_truth`. Two more were a generator's
confidence tier spelled as a sentence.

**And the whole of the schema was missing.** No index, no trigger, no schema,
no sequence, no extension, no CTE name, no correlation name, no select alias,
no column type, no function signature; `create_index`, `create_trigger`,
`create_schema`, `create_sequence`, `create_extension`, `create_materialized_view`,
`drop_view`, `drop_function`, `drop_index`, `drop_type`, `rename_object` and
`comment_statement` were untouched node types. A Pack for the language of
schemas made ten declaration templates and highlighted 360 keywords.

## What it should extract

SQL in a repository is schema and the statements that use it: migrations, DDL,
views, stored routines, and queries. The questions are *where is this table /
column / view / function defined*, *which statements read or write this table*,
*what does this foreign key, index or trigger point at*, and *where is this
column used*.

| what | node | emitted as | family |
|---|---|---|---|
| a table | `create_table` via `object_reference name:` | `definition.table` | Value |
| a view, materialized or not | `create_view`, `create_materialized_view` | `definition.view` | Value |
| a column | `column_definition name:` | `definition.column` | Value |
| its declared type | `column_definition type:` | `declared_type_candidate` carrier on the column | attribute |
| a named constraint | `constraint name:` | `definition.constraint` | Value |
| an index | `create_index column:` | `definition.index` | Value |
| a function | `create_function` after `FUNCTION` | `definition.function` | Callable |
| its argument list | `function_arguments` | `parameter_shape_candidate` carrier | attribute |
| its return type | the node after `RETURNS` | `return_type_candidate` carrier | attribute |
| a procedure | `create_procedure` | `definition.procedure` | Callable |
| a trigger | `create_trigger` via `identifier` | `definition.trigger` | Value |
| a user-defined type | `create_type` | `definition.type` | Type |
| a schema | `create_schema` | `definition.namespace` | Namespace |
| a sequence | `create_sequence` | `definition.sequence` | Value |
| a CTE | `cte` via its first `identifier` | `definition.cte` | Value |
| a table alias | `relation alias:` | `definition.correlation_name` | Value |
| a select-list alias | `term alias:` | `definition.result_column` | Value |
| a routine variable | `var_declaration`, `function_declaration` | `definition.variable` | Value |
| a column a migration adds | `rename_column new_name:` | `definition.column` | Value |
| a table a query reads or writes | `relation` | `relation.data` | data occurrence |
| a table INSERT writes to | `insert` via `object_reference` | `relation.data` | data occurrence |
| a foreign key's target | `constraint`/`column_definition` after `REFERENCES` | `relation.depends` | depends occurrence |
| the table an index is on | `create_index` via `object_reference` | `relation.depends` | depends occurrence |
| the table a trigger fires on | `create_trigger` after `ON` | `relation.depends` | depends occurrence |
| an extension the file needs | `create_extension` | `relation.depends` | depends occurrence |
| a column a statement uses | `field column:` | `reference.column` | reference |
| a column dropped or renamed | `drop_column`, `rename_column old_name:` | `reference.column` | reference |
| the table ALTER changes | `alter_table` | `reference.table` | reference |
| an object DROP removes | ten `drop_*` nodes, one pattern | `reference.dropped_object` | reference |
| a dropped constraint | `drop_constraint` | `reference.constraint` | reference |
| a function call | `invocation` | `call.function` | call |
| keywords, operators, literals, punctuation | -- | nothing | -- |

Every name is the **last segment** of its object reference, on both the
declaring and the referencing side, so `CREATE TABLE public.users` and
`FROM users` meet. The schema segment is dropped and a guard says so.

Two kinds of edge, and only the two the host knows: a statement that reads or
writes a table is `relation.data`, and a schema object that cannot exist
without another is `relation.depends`. Everything else that mentions a name by
which it could be resolved is a plain `reference.*`.

### What it deliberately does not state

- **No regions.** A `scope.*` emission is a span, and for every construct in
  SQL that has an extent -- a function, a procedure, a CTE, a subquery -- the
  declaration's own span already covers it, and the host nests what is inside
  through `within:`. The old `scope.lexical` on `function_declaration` was a
  region over a `DECLARE` item, named with its own text. The `scopes`
  capability is gone.
- **No bindings.** The old `binding.symbol` on `(parameter)` made `$1` a
  binding in every statement. A `binding.*` kind is not a declaration and not a
  relation, so it arrived as a reference to nothing. The `bindings` capability
  is gone.
- **No `data` capability.** Everything it held was either a highlight or a
  second spelling of a reference. The two facts that are genuinely data facts
  are `relation.data` mentions under `references`.
- **No injections.** The old Pack declared an injection of a language called
  `comment` into `comment` and `marginalia`. No such grammar exists in this
  repository, so the injection layer had nothing to run.
- **No qualified-column pattern.** `(field (object_reference) (identifier))`
  was emitted as `reference.sql_qualified_column` named with the column and
  carrying the qualifier. In nearly every query the qualifier is a correlation
  name that exists only inside that statement; resolving it against a table of
  the same name elsewhere in the repository would be wrong more often than
  right, so only the column is stated and a guard records it.

## A known false positive in the audit

`python pack-design/audit.py omega-sql` reports two instances of *carrier that
may overwrite itself*:

    definition.parameter_shape_candidate: (function_arguments) repeats inside (create_function)
    definition.parameter_shape_candidate: (function_arguments) repeats inside (create_procedure)

This is the case the check's own label warns about. `repeats_in()` reads
`node-types.json` and treats every member of a `"multiple": true` children
group as repeatable; in this grammar `create_function` has exactly one such
group holding *all* of its children, from `function_arguments` to
`keyword_create`. A `CREATE FUNCTION` has one argument list, so the carrier is
written once. Every other class the audit measures is zero.

## Still to decide

1. **The schema segment.** `object_reference` carries `schema:` and
   `database:` fields that the Pack drops. Carrying the schema onto a table
   declaration as `omega.pack.container_name` -- a name the engine does read --
   would let a query distinguish `analytics.events` from `public.events`. It
   costs one more pattern rooted at `create_table`, and it only pays off in a
   repository that uses more than one schema. Left out; the guard says the
   limitation is there.
2. **Enum labels.** `CREATE TYPE status AS ENUM ('active', 'closed')` leaves
   `enum_elements` untouched. The labels are values, not declarations, and
   filing them under a kind containing `enum` would put each one in the Type
   family beside the type itself. Carrying the whole element list onto the type
   as its declared value set is the alternative. Left out.
3. **`term alias:` volume.** Every `SELECT x AS total` now declares `total`.
   In a repository of large reporting queries that is a real number of
   declarations for names that are local to one statement -- but they are also
   exactly the names a downstream CTE, view or application column refers to.
   Declared for now; revisit against a row count, the same decision
   `pack-design/omega-xml.md` records for the repeated element.
4. **`RETURNS TABLE(...)`.** The return-type carrier takes the one node after
   `RETURNS`, which for `RETURNS TABLE (a int, b int)` is the `keyword_table`
   token, so the card reads `-> TABLE`. Taking the `column_definitions` that
   follows instead would read `-> (a int, b int)`; both are honest and the
   second costs another pattern.
