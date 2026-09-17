# omega-sas

Language `omega-sas`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

Rewritten. The tables below describe the Pack as it stands after the rewrite;
the record of what was there before is in *What was wrong with it*.

## What it states today

15 templates over 13 query patterns, 13 distinct root node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 6 |
| `imports` | yes | 2 |
| `references` | yes | 3 |
| `scopes` | yes | 2 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.macro_function` | Callable | 1 |
| `definition.macro_variable` | Value | 2 |
| `definition.dataset` | Value | 1 |
| `definition.library` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 1 |

### Regions

- `scope.data_step` (1)
- `scope.proc_step` (1)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.macro` | call | 1 |
| `call.procedure` | call | 1 |
| `import.include` | binding | 1 |
| `import.library_path` | binding | 1 |
| `reference.dataset` | reference | 2 |
| `reference.macro_variable` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 45 node types. The Pack looks at 23 of them, and reaches
`fileref_source` through `source: (_)` on `%include` without naming it.

Untouched:

- `block_comment`
- `ds_options`
- `generic_statement`
- `line_comment`
- `macro_arguments`
- `macro_do_statement`
- `macro_end`
- `macro_if_statement`
- `macro_label`
- `macro_options`
- `null_statement`
- `numeric_literal`
- `options_statement`
- `percent_comment`
- `proc_sql_header`
- `proc_sql_step`
- `program`
- `run_or_quit_statement`
- `run_statement`
- `sql_join_clause`
- `sql_select_statement`

Each of these is untouched for a reason, not by omission:

- `line_comment`, `block_comment`, `percent_comment`, `null_statement`,
  `run_statement`, `run_or_quit_statement` and `program` carry no name.
- `numeric_literal`, and `string_literal` where it is a value rather than a
  name, are literals. This Pack emits no `reference_context.*` kind, so a
  `literal.*` emission would suppress nothing and the host would drop it: one
  match per constant in every file for a fact nobody reads. A `string_literal`
  is read only where it *is* a name -- the location of a `libname` and the
  source of an `%include`.
- `generic_statement`, `options_statement`, `ds_options`, `macro_options` and
  `macro_arguments` are option and expression soup. This grammar does not break
  a `keep=`, a `where=` or a `data=` option into a key and a value -- it emits
  the run of tokens -- so there is no name in them to state. `data=` and `out=`
  on a PROC are the one real loss and are recorded in a guard.
- `macro_do_statement` and `macro_if_statement` are control flow. The host drops
  `control_flow.*` outright, and a region per `%do` would state the block
  structure the tree already holds.
- `macro_end` is `%mend build;` -- the closing token of a declaration that is
  already spanned whole.
- `macro_label` is the target of a `%goto`, and this grammar has no `%goto`
  node, so the declaration would have nothing that could ever reference it.
- `sql_select_statement` and `sql_join_clause` are reached through the
  `table_reference` inside them, which is the only named thing they hold; a
  pattern for the clause as well would be the same table stated twice.
- `proc_sql_step` and `proc_sql_header` have no procedure-name node -- `PROC
  SQL` is spelled as its own step -- so a region for it could only be named by a
  constant. A `PROC SQL` step is reached through the tables it creates and reads.

## What was wrong with it

The Pack that was here stated 27 templates over 26 patterns with 9 guards, and
was assembled by four generator passes whose batch names were still in the file
as section headers (`semantic_closure_v3_146_batch2`, `_batch4`,
`terminal_sas_source_semantics_v1`, `practical-p1-*`). Six of those twenty-six
sections were headers with no pattern under them at all.

**Ten templates named an emission with a whole node (D2).** Every one of the
"practical-p1" templates set `name` to its own `span_capture`:
`definition.data_step` was named with the entire text of the DATA step, from
`data` to `run;`; `definition.proc_step` with the whole PROC step; `call.macro`
with `%build_summary(work.sales, outdata=work.out)`; `import.include` with
`%include "&root./macros/common.sas";`; `import.library` with the whole
`libname` statement; `scope.sas_macro` with the entire body of the macro. A DATA
step is routinely two hundred lines. The index stored each of those bodies once
as the name of a declaration, and an agent asking for a declaration called
`work.sales` got back nothing, because no declaration was called that.

**The same construct was declared twice under two spellings (K).** The macro
definition produced `definition.macro` (named with the whole `%macro ... %mend`)
*and* `definition.macro.name` (named with `build_summary`, spanning only the
name token) *and* `definition.identity_candidate`. The macro call produced
`call.macro`, `call.macro.name` and `call.target_candidate`. Three emissions
each, for one fact.

**Four carriers carried nothing (carrier_unread), and three of those could not
fold at all (carrier).** `call.target_candidate`, `import.target_candidate` and
`import.module_path_candidate` all fail `is_definition_kind` -- the prefixes
`call.` and `import` exclude them -- so the host never folded them; they were
stored as references to nothing. The fourth, `definition.identity_candidate`,
did fold, onto `omega.pack.identity`, a carried name nothing in the engine ever
reads. Not one of the five names that build a card's signature line was emitted,
so a SAS macro's card showed no parameters even though the Pack captured
`(macro_parameters (identifier))` and spent a template on it.

**References were spelled so that they could not resolve.** Seven mention kinds
existed for datasets -- `reference.sas_table`, `reference.sas_select_table`,
`reference.sas_join_table`, `reference.sas_insert_target`,
`reference.sas_data_set_input`, `reference.sas_data_merge_input`,
`reference.sas_data_update_input` -- against two declaration kinds spelled
differently again (`definition.sas_dataset`, `definition.sas_sql_output`). And
`reference.macro_variable` was named `&outdata`, ampersand included, while
nothing declared a macro variable at all: `macro_variable_assignment`, the
`%let` statement, was one of the node types the Pack never looked at. Every
macro-variable reference in every SAS program in the corpus was a mention of a
name no declaration could ever carry.

**Nothing the language declares was declared.** No `%let`. No macro parameter.
No libref -- `libname` was an `import.library` named with the whole statement.
`output work.sales_out;` was filed as `definition.sas_output_dataset`, a
*declaration* of a dataset that the DATA step header had already declared, so a
`data`/`output` pair declared the same dataset twice, once under each kind.

**Every declaration landed in Value.** Seven declaration kinds, seven Value
families. A SAS macro is the language's only callable and was filed beside the
datasets.

**Nine guards, and one of them was a single token** (G):
`terminal_static_ceiling__sas_macro_expansion_library_resolution_and_sql_runtime`.
Four more were the generator's boilerplate about overload resolution and dynamic
dispatch, neither of which SAS has.

## What it should extract

SAS is the language of data preparation and reporting. A program is a sequence
of DATA steps and PROC steps wired together by dataset names, parameterised by a
macro language layered on top. The questions asked of it are: *which dataset
does this build*, *who reads it*, *where is this macro defined and who calls
it*, *what is this macro variable*, *where does this libref point*, and *what
does this program pull in*.

| what | node | emitted as | family |
|---|---|---|---|
| `%macro build(...)` | `macro_definition` via `macro_name` | `definition.macro_function` | Callable |
| its parameter list | `macro_parameters` | `parameter_shape_candidate` carrier on the macro | attribute |
| each parameter | `macro_parameters` via `identifier` | `definition.macro_variable` | Value |
| `%build(x)`, statement or inline | `macro_call_statement`, `macro_call` via `macro_name` | `call.macro` | call |
| `%let cutoff = ...` | `macro_variable_assignment` via `identifier` | `definition.macro_variable` | Value |
| `&cutoff`, `&cutoff.`, `&&x` | `macro_variable_ref` | `reference.macro_variable` | reference |
| `data work.sales work.audit;` | `data_step_header` via `dataset_name` | `definition.dataset` | Value |
| `create table x as` | `sql_create_statement` via `output:` | `definition.dataset` | Value |
| the DATA step's extent | `data_step` | `scope.data_step` | region |
| `set`, `merge`, `update`, `output` | those statements via `dataset_name` | `reference.dataset` | reference |
| `insert into t` | `sql_insert_statement` via `dataset_name` | `reference.dataset` | reference |
| `from t as a`, `join t as b` | `table_reference` via `dataset_name` | `reference.dataset` | reference |
| `proc sort ...;` | `proc_step_header` via `name:` | `call.procedure` | call |
| the PROC step's extent | `proc_step` | `scope.proc_step` | region |
| `libname mylib ...` | `libname_statement` via `libref:` | `definition.library` | Value |
| the library's location | `libname_statement` via `string_literal` | `import.library_path` | binding |
| `%include "f.sas"` | `include_statement` via `source:` | `import.include` | binding |
| options, control flow, comments, literals | -- | nothing | -- |

Two decisions carry most of the value.

**One kind for a dataset on each side.** Everything that builds a dataset is
`definition.dataset` and everything that reads one or writes into one is
`reference.dataset`, both named with the two-level `libref.member` name exactly
as SAS spells it. Seven reference kinds against two declaration kinds could not
resolve; one against one does. *Who reads `mylib.raw_sales`* is now a single
lookup.

**Names are lowered.** SAS is case-insensitive in every namespace a Pack can
see: `%MACRO Build;` is invoked as `%build()`, `WORK.SALES` and `work.sales` are
one dataset, `&Root` and `&ROOT` are one macro variable. The host resolves a
mention onto a declaration by exact string match on the name
(`omega-semantic/src/indexes.rs`, a hash lookup), so without the fold the
uppercase style that most legacy SAS is written in resolves against nothing at
all. Paths are left as written, because a file system is not case-insensitive.

`definition.macro_function` is spelled with the word `function` deliberately:
`entity_family` matches whole words and the last match wins, so
`[definition, macro, function]` lands in Callable. A SAS macro is the one thing
the language declares that is invoked by name with arguments, and the kind
string is the only lever over where it lands. It is not a `%sysfunc` macro
function; the word is the host's vocabulary, not SAS's.

### Two notes on the audit

Both are places where `audit.py` prints zero and the reason deserves saying out
loud.

**`dataset_name` is a name node with named children, and D2 does not fire on
it.** `work.sales` parses as `(dataset_name (identifier) (identifier))`, so a
template whose name is its own span capture over a `dataset_name` is exactly the
shape D2 measures. It does not fire here only because the name is wrapped in
`lower(...)` and D2 tests for a bare `capture_ref`. The wrapping is there for
the resolution reason above, not to hide the check -- and the check would be a
false positive in any case: the children of a `dataset_name` are the libref and
the member of a two-level SAS name, so its text *is* the name and is never more
than a few dozen bytes. That is the opposite of what D2 measures, which is a
name that is a whole `data_step` -- and that one the old Pack really did have,
ten times over.

**The carrier on the macro is not checked for self-overwriting.** The
`parameter_shape` carrier spans the `macro_definition` and is named from the
`macro_parameters` inside it, and `macro_definition` groups every body item into
one repeat, so `repeats_in` would report that `macro_parameters` may occur more
than once inside it -- the grammar-grouping false positive already recorded for
omega-typescript. `audit.py` does not report it, but for a different reason: its
owner map is built with a regex that allows only `]` and whitespace between a
node's closing bracket and its capture, so a capture written `(x)? @cap` has no
owner recorded and is checked for neither D, D2 nor `carrier_owner`. That is a
gap in the audit, not in the Pack, and it is reported for `00-INDEX.md` rather
than worked around here. A `macro_definition` can hold only one direct
`macro_parameters`; a nested `%macro` carries its own.

## Still to decide

1. **Whether a libref is a Namespace.** `mylib.sales` is a two-level name whose
   first level is the libref, which is very nearly what the host means by a
   namespace, and `definition.library_namespace` would file it there. It is left
   in Value because a libref names a directory of data rather than a region of
   code, and because the question asked of it -- *where does `mylib` point* --
   is answered by the declaration and the `import.library_path` beside it in
   either family. Revisit if namespace queries over SAS turn out to want it.
2. **`%put`, `%global` and `%local` arrive as `call.macro`.** This grammar
   parses every `%word ...;` statement as `macro_call_statement`, so the macro
   language's own statements are indistinguishable from a user macro call. They
   are left in rather than excluded by a name list: the list would have to
   enumerate the macro statements of every SAS release, and a user macro may be
   called `%put` in a site library. The cost is one call mention per `%put`,
   resolving to nothing, which is the same cost every Pack pays for a call to a
   built-in.
3. **A dataset name built from macro variables** (`data &outdata;`) is declared
   under the name `&outdata`, ampersand included, because the Pack does not
   expand macros. It is declared rather than dropped so that the DATA step is
   still visible as building *something*, and the second guard says the name is
   not the dataset's. If these turn out to be a large share of real SAS,
   dropping them is a one-line change.
