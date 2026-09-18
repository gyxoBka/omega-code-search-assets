# omega-csv

Language `omega-csv`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

1 template over 1 query pattern, 1 distinct root node type.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.column` | Value | 1 |

### Mentions

None. A CSV file has nothing that refers to anything.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 17 node types. The Pack names 9 of them: `csv`, `row`, and
the seven cell types `first` … `seventh`.

Untouched:

- `cycle`
- `cycle2`
- `cycle3`
- `cycle4`
- `cycle5`
- `cycle6`
- `cycle7`
- `remainder`

These eight are the grouping nodes that tree-sitter-csv (a rainbow-highlighting
grammar) wraps a row's cells in, seven at a time. They carry no meaning of their
own — a `cycle3` is "the first three cells of this row" and nothing else — so
the Pack reaches its cells through a `(_ …)` wildcard rather than naming any of
them. This is the one class the audit would count as unreached that is right to
leave unreached.

## What is wrong with it

The Pack that was here had **5 templates over 5 patterns, 1 guard**, and every
one of the five templates was a defect.

**Two templates named an emission with a whole node (Defect D2 — the audit
reported both).** `value.document` had `span_capture: csv.document` and
`name: capture_ref csv.document`, so the name of the emission was the source
text of the `(csv)` node: *the entire file*, stored as a string in the index,
once per CSV file in the repository. `value.csv_row` did the same at row
granularity — the whole line as the name of the line. Neither is a name any
question can reach, and on a data file of any size the first one is the single
most expensive thing a Pack can do.

**Three patterns stated containment the tree already holds (Defect E).**
`(row (cycle (first) @f1))`, `(row (cycle2 (first) @f1 (second) @f2))` and
`(row (cycle3 (first) @f1 (second) @f2 (third) @f3))` are the same fact —
"a row has cells" — written out once per arity, and only for the first three
arities. A four-column CSV, the ordinary case, matched none of them and the
Pack stated nothing about it at all.

**The Pack declared nothing.** All five kinds — `value.document`,
`value.csv_row`, three `structured.entry` — fail `is_definition_kind`, so all
five arrived in the mention branch as plain references. A reference resolves
against a declaration; there were no declarations anywhere in the Pack, so the
five mentions resolved against nothing, in every direction, forever. Every
emission the Pack made was unreachable.

**Every emission was one per cell, and the cell is unnamed.** The three
`structured.entry` templates emitted the raw text of cells 1, 2 and 3 of every
row of every file. tree-sitter-csv gives a cell its ordinal position and nothing
else — no role, no type, no link to the header cell above it — so the text of a
data cell has no name to resolve to and no question that reaches it. This is
exactly the row explosion the rewrite exists to undo: a 20 000-row CSV produced
60 003 emissions, all of them references to nothing.

**The one guard's reason was two limitations welded together** and neither was
the real one. It said header/schema inference and delimiter dialect are not
claimed; it did not say that *nothing in the file was declared*.

**A dead comment block.** The file ended with a "structural-fallback" heading
and two comment lines announcing a fallback that "matches every named syntax
node" — a description of Defect I, the universal capture — with no pattern
under it. Either the generator's universal capture was stripped and its banner
left, or the banner was written for a pattern that never arrived. Removed.

The Pack named 8 node types before and 9 now, but the set changed: the three
arity patterns reached only cells 1–3, and cells 4–7 (`fourth` … `seventh`) and
the wide-row `remainder` path were unreachable. All seven cell positions are now
read, at any width.

## What it should extract

A CSV file in a repository is a table with a schema line on top: a fixture, a
lookup table, a locale file, a seed, an export. The question asked of it is
**what columns does this table have** — because a column name is the one string
in a CSV that code elsewhere refers to, in `row["user_id"]`, `df.user_id`,
`SELECT user_id`, a migration, a schema. Everything else in the file is data,
and data in a CSV names nothing.

| what | node | emitted as | family |
|---|---|---|---|
| a column of the table | the first `row` of `csv`, cell `first` … `seventh` under any grouping node | `definition.column` | Value |
| the document | `csv` | nothing | — |
| a row | `row` | nothing | — |
| a data cell | `first` … `seventh` below the first row | nothing | — |
| the cell grouping | `cycle` … `cycle7`, `remainder` | nothing (reached by wildcard) | — |
| the delimiter | `,` `;` `\|` | nothing | — |

One pattern, anchored as the first child of `csv`, produces one match per header
cell. The name is the cell's own text — a leaf naming itself, which §9 D calls
correct and ordinary — after `trim`, a BOM strip, and a quote strip on both
sides, so `"user id"` and a BOM-prefixed `id` resolve as `user id` and `id`
rather than as themselves plus punctuation.

`definition.column`: `entity_family` splits it into `definition` and `column`,
neither of which is in any family's word list, so it lands in **Value**. That is
right — a column of a data table is a value-shaped thing, not a type, not a
callable, and not configuration.

### Where the header judgement lives, and why it is a predicate

CSV has no syntax for saying "row 1 is a header". The whole of that judgement is
one `#match?`:

```
(#match? @header.column "^[^A-Za-z0-9]{0,2}[A-Za-z_]")
```

A cell that begins with a letter or an underscore — after at most two
non-alphanumeric characters, which covers a UTF-8 BOM and an opening quote — is
read as a column name. `42`, `2024-01-01`, `3.14`, `-` and an empty cell are
not. So a headerless file of numbers and dates declares nothing at all, which is
the correct answer, and a headerless file whose first row happens to be textual
declares that row as its columns, which is the failure this heuristic has and
which the first coverage guard states plainly.

`#match?` is one of the six predicates the runtime actually applies (§6a); the
Pack uses no other.

### What is deliberately not stated, and the four guards that say so

1. **The header judgement is a heuristic** — the guard above.
2. **Data cell values.** One emission per cell, with no name anything resolves
   to, on the file class that produced the row explosion. Not stated.
3. **The column ordinal.** `cycle` … `cycle7` number the first seven cells and
   then `remainder` restarts the numbering, so `first` means column 1 *or*
   column 8 *or* column 15. An ordinal attribute would be correct to the seventh
   column and a lie after it, so none is written. (It is recoverable for the
   first seven by anchoring the grouping node as the row's first child and
   writing one pattern per arity — seven patterns and up to twenty-eight
   templates to answer "which column is this", for an answer that stops at
   column seven. Not worth it.)
4. **The delimiter.** The grammar accepts `,`, `;` and `|` as anonymous tokens;
   which one a file uses is visible in the tree but occupies no span that names
   anything, and quoted cells containing a delimiter are not re-split by this
   grammar.

### The tree-sitter static analysis on this grammar

The oracle (§12a) works here only when node types are named. `(csv . (row
(third) @c))` is refused as `Impossible pattern`, which is how the cell depth
was confirmed: a cell is always two levels below the row, under a grouping node.
But a wildcard parent defeats the analysis — `(csv . (row (_ [(row) …] @c)))`,
which can never match anything, compiles without complaint. The shipping pattern
uses the wildcard, so it was verified by writing the named form first and
letting the validator refute the wrong depth, then substituting the wildcard.
Worth remembering for any Pack whose grammar wraps its payload in a node that
carries no meaning: the wildcard that is right for the Pack is the wildcard that
switches the oracle off.

## Still to decide

1. **The first column of every data row as a key.** In a locale table, an enum
   table or a seed, column 1 of each row is an identifier that code refers to by
   name — `welcome.title`, `ROLE_ADMIN` — and declaring it would make the one
   genuinely resolvable link a CSV has. It is left out for three reasons, and
   the third is the blocking one: it is a convention of particular files rather
   than a fact of CSV; it is one emission per row on the file class the rewrite
   is shrinking; and **it cannot be told apart from the header**. There is no
   "not the first child" anchor in tree-sitter, so a pattern over every row's
   first cell also matches the header's first cell, which would then be declared
   twice on one span — once as a column and once as a key. Revisit if an anchor
   for "after the first child" ever exists, or if the header declaration is
   dropped in favour of keys.
2. **Whether a wide file should declare more than seven columns.** It does, via
   the `remainder` path and the wildcard, and those columns are indistinguishable
   from columns 1–7. That is the right answer for the name, which is all the Pack
   states, and would be the wrong answer for an ordinal — see the guard above.
