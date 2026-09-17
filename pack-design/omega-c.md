# omega-c

Language `omega-c`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

27 templates over 32 query patterns, 40 distinct named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 20 |
| `imports` | yes | 1 |
| `references` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.function` | Callable | 1 |
| `definition.macro_function` | Callable | 1 |
| `definition.struct` | Type | 1 |
| `definition.union` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.typedef` | Type | 1 |
| `definition.enumerator` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.variable` | Value | 1 |
| `definition.label` | Value | 1 |
| `definition.macro` | Value | 1 |

`definition.field` carries one attribute, `declared_type`, the written type of
the member. Every other attribute in the Pack is a carrier.

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates | attaches to |
|---|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 | the `function_declarator`, the `preproc_function_def` |
| `definition.return_type_candidate` | `omega.pack.return_type` | 2 | the `function_declarator` |
| `definition.modifier_candidate` | `omega.pack.modifier` | 1 | the `function_declarator` |
| `definition.value_candidate` | `omega.pack.value` | 2 | the `preproc_def`, the `enumerator` |
| `definition.aliased_type_candidate` | `omega.pack.aliased_type` | 1 | the `type_definition` |

Three of these -- `parameter_shape`, `return_type`, `modifier` -- are among the
five names `declared_signature` assembles a card's signature line from, so a C
function's card reads `static char *strdup(const char *s)` and not `strdup`.

### Regions

None. A C function's own declaration span already covers its body, and a
`compound_statement` has no name a region could be asked for.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `call.member` | call | 1 |
| `import.include` | binding | 1 |
| `reference.type` | reference | 1 |
| `reference.member` | reference | 1 |
| `reference.macro` | reference | 1 |
| `reference.label` | reference | 1 |
| `reference.attribute` | reference | 1 |

Every one of them is a name that resolves against a declaration this Pack also
emits: `reference.type` against a struct, union, enum or typedef;
`reference.member` against a field; `reference.macro` against a `#define`;
`reference.label` against a label; `call.function` against a function or a
function-like macro.

### Injections

One: a `preproc_arg` -- a macro replacement body -- is re-parsed as C. It is
the only embedded region C has that Omega has a grammar for. The Neovim
baseline's injections into `printf`, `asm`, `doxygen`, `re2c` and `comment`
were removed with the template that stored every comment in the file under its
own full text as a name.

## The boundary: what the grammar offers and the Pack ignores

The grammar names 132 node types. The Pack looks at 40 of them.

The Pack it replaced looked at 88, and that number went down on purpose: 49 of
those 88 are no longer matched, and 47 of the 49 are expression, statement,
literal and extension nodes that were emitted as nameless mentions (see below).
What the Pack states about the *declaring* half of the grammar went up:
file-scope variables, C23 attributes, callback typedefs, function-pointer
struct members and `*`-returning functions are declared now and were not
before, and `.f =`, `#elifdef F` and `defined(F)` are names that resolve rather
than whole nodes stored under their own text.

Untouched:

- `_abstract_declarator`
- `_declarator`
- `_field_declarator`
- `_type_declarator`
- `abstract_array_declarator`
- `abstract_function_declarator`
- `abstract_parenthesized_declarator`
- `abstract_pointer_declarator`
- `alignas_qualifier`
- `alignof_expression`
- `argument_list`
- `assignment_expression`
- `attribute_declaration`
- `attribute_specifier`
- `attributed_declarator`
- `attributed_statement`
- `binary_expression`
- `bitfield_clause`
- `break_statement`
- `case_statement`
- `cast_expression`
- `char_literal`
- `character`
- `comma_expression`
- `comment`
- `compound_literal_expression`
- `compound_statement`
- `concatenated_string`
- `conditional_expression`
- `continue_statement`
- `declaration_list`
- `do_statement`
- `else_clause`
- `escape_sequence`
- `expression`
- `expression_statement`
- `extension_expression`
- `false`
- `for_statement`
- `generic_expression`
- `gnu_asm_clobber_list`
- `gnu_asm_expression`
- `gnu_asm_goto_list`
- `gnu_asm_input_operand`
- `gnu_asm_input_operand_list`
- `gnu_asm_output_operand`
- `gnu_asm_output_operand_list`
- `gnu_asm_qualifier`
- `if_statement`
- `initializer_list`
- `initializer_pair`
- `linkage_specification`
- `macro_type_specifier`
- `ms_based_modifier`
- `ms_call_modifier`
- `ms_declspec_modifier`
- `ms_pointer_modifier`
- `ms_restrict_modifier`
- `ms_signed_ptr_modifier`
- `ms_unaligned_ptr_modifier`
- `ms_unsigned_ptr_modifier`
- `null`
- `number_literal`
- `offsetof_expression`
- `parameter_declaration`
- `preproc_call`
- `preproc_directive`
- `preproc_elif`
- `preproc_else`
- `preproc_if`
- `primitive_type`
- `return_statement`
- `seh_except_clause`
- `seh_finally_clause`
- `seh_leave_statement`
- `seh_try_statement`
- `sized_type_specifier`
- `sizeof_expression`
- `statement`
- `string_content`
- `subscript_designator`
- `subscript_expression`
- `subscript_range_designator`
- `switch_statement`
- `true`
- `type_descriptor`
- `type_qualifier`
- `type_specifier`
- `unary_expression`
- `update_expression`
- `variadic_parameter`
- `while_statement`

Four groups, and the reason each is left alone:

1. **Statements and expressions** (`if_statement`, `binary_expression`,
   `subscript_expression`, `return_statement`, …). Control flow is not a name.
   An agent asks *what calls `free`*, not *where is there an `if`*; the old
   Pack answered the second question with 38 templates and nobody asked it.
2. **Literals and punctuation** (`number_literal`, `string_literal` as a value,
   `true`, `false`, `null`, `escape_sequence`). `literal.*` emissions are
   dropped by `retain_named_spans`, and their spans suppress only
   `reference_context.*` kinds, which this Pack does not emit -- so they would
   be one match per literal in every file for nothing (AGENT-BRIEF §5).
3. **Compiler extensions** (`gnu_asm_*`, `ms_*`, `seh_*`, `attribute_specifier`,
   `__declspec`). These carry meaning, and the Pack says so in a coverage
   guard rather than emitting the token. `__attribute__((deprecated))` parses
   as an `attribute_specifier` holding an `argument_list` of raw expressions,
   with no field naming the attribute, so a fact taken from it would be a
   whole-node name. The C23 spelling `[[deprecated]]` *does* have a `name:`
   field and is recorded.
4. **Nodes that exist only as grammar plumbing** (`_declarator`, `expression`,
   `statement`, `type_specifier` are supertypes; `argument_list`,
   `declaration_list`, `compound_statement`, `initializer_list` are containers
   whose children are already reached through their parents).

## What is wrong with it

Measured with `pack-design/audit.py omega-c` before the rewrite: **199
templates over 108 patterns, 33 guards**, ten declared capabilities.

**Half the Pack was a second copy of the parse tree.** 73 of the 199 templates
were under `data`, and they restated the syntax node by node: `data.c_expr_binary`
plus `_left`, `_operator` and `_right`; the same four for assignment; three for
the conditional operator; `control.c_control_if` plus `_condition`, and so for
`switch`, `while`, `do`, `for`, `case`, `goto`, `return`, `break`, `continue`.
Each arrives at the host as a *plain reference* -- a mention of a name -- and
the name is the operand's own source text. `reference` to `x + 1`. Nothing
resolves against it, no question reaches it, and there is one per operator in
every C file in the repository.

**78 templates named an emission with a whole node** (audit class D2). The
worst are the ones that fire most: `call.c_call_arguments` stored the whole
`(argument_list)` -- every argument of every call, as a name;
`aggregate.c_aggregate_struct` stored the whole `struct_specifier`, body
included, so a 60-line struct was written into the index as a name, and again
as `aggregate.c_aggregate_struct_body`, and again as `definition.c_definition_struct`.
`syntax.c_syntax_error` stored the text of every parse error.

**Ten `relation.*` kinds the host does not know.** `relation.c_preproc_include`,
`relation.c_preproc_macro`, `relation.c_preproc_function_macro`,
`relation.c_preproc_condition(al)` and their `_name`/`_path` twins. The host
recognises exactly `relation.implements`, `.tests`, `.depends`, `.config`,
`.data` and `.handles` and compares the suffix exactly, so all ten arrived as
plain references -- and they were the *declarations* of the macros, filed under
capability `imports`, which is where a `#define` is not.

**Seven carriers the host will not fold, and fifteen folded onto the wrong
span.** `call.target_candidate`, `import.target_candidate`,
`reference.member_access_candidate`, `scope.enclosing_owner_candidate`,
`import.module_path_candidate` and `embedded_region.embedded_language_candidate`
end in `_candidate` but contain no `definition` and end in none of the five
definition suffixes, so each fell through to the mention branch and was stored
as a reference to nothing. Of the fifteen that did fold,
`definition.category_candidate` × 5 wrote the *member's* name onto the
*enclosing* `struct_specifier`, once per member, keeping the last -- and the
value it wrote was already the `output_kind` of a template ten lines away.

**Nothing in the old Pack built a signature.** The five names
`declared_signature` reads are `visibility`, `type_parameter_shape`,
`parameter_shape`, `return_type` and `modifier`. The Pack emitted
`definition.parameter_shape_candidate` exactly once, on `preproc_function_def`,
so a *macro* had a parameter list on its card and no C function ever did. The
return type was emitted instead as `function.c_function_return_type`, a
separate declaration of its own named by the type's whole text -- so `int` was
declared as an entity, once per function in the corpus.

**The `tests` capability was two templates that match everything.**
`test.c_test_include` fired on every `#include` and `test.c_test_call` on every
`call_expression` with an identifier callee. C has no test construct; a test in
C is a framework (Unity, CMocka, Check, Criterion) and belongs in
`frameworks/`. Removed with the capability.

**Six guards whose reason is a label** (audit class G) --
`terminal_static_ceiling__c_function_pointer_targets_are` twice,
`c_extensions_are_compiler_specific`,
`c_preprocessor_evaluation_is_build_configuration_dependent` twice,
`terminal_static_ceiling__c_embedded_language_resolution` -- and 27 more whose
reason is a sentence of generator vocabulary ("requires bounded source symbol
resolution") rather than a fact about C. 33 guards for a Pack that could not
state a function's parameters.

**Injections into five languages Omega has no grammar for**, four of them
keyed on a list of libc function names pinned in `#any-of?` literals
(`printf`, `snprintf`, `mvwprintw`, …) -- the shape Defect L describes, a
library's API spelled into a language Pack. The template that read those
regions, `embedded_region.embedded_language_candidate`, named each one with the
whole captured text: every comment in every C file, stored as a name.

**And two things were simply absent.** No file-scope variable was ever declared
-- `int errno_saved;` at the top of a translation unit produced
`declaration.c_declaration`, a mention named with the whole declaration. And no
`#include` produced a name a question could match: the path was stored as
written *including the quotes or angle brackets*, under a `relation.*` kind, so
`"config.h"` never matched the file `config.h`.

## What it should extract

C is used for headers that declare an interface and translation units that
implement it. The questions asked of a C file are: *where is this function,
this type, this macro or this variable declared*; *what does this file
include*; *what calls this function*; *where is this type, this member or this
macro used*. Everything below answers one of those, and nothing else is stated.

| what | node | emitted as | family |
|---|---|---|---|
| a function, defined or prototyped | `function_declarator` with an `identifier` declarator | `definition.function` | Callable |
| its parameter list | `parameter_list` | `parameter_shape_candidate` on the declarator | attribute |
| its return type | `function_definition`/`declaration` `type:` | `return_type_candidate` on the declarator | attribute |
| `static`, `extern`, `inline` | `storage_class_specifier` | `modifier_candidate` on the declarator | attribute |
| a struct | `struct_specifier` with a body | `definition.struct` | Type |
| a union | `union_specifier` with a body | `definition.union` | Type |
| an enum | `enum_specifier` with a body | `definition.enum` | Type |
| an enum constant | `enumerator` | `definition.enumerator` | Value |
| its value | `enumerator` `value:` | `value_candidate` on the enumerator | attribute |
| a typedef, including the callback form | `type_definition` | `definition.typedef` | Type |
| what it aliases | `type_definition` `type:` | `aliased_type_candidate` on the typedef | attribute |
| a struct or union member | `field_declaration` | `definition.field` + `declared_type` | Value |
| a file-scope variable | `declaration` directly under `translation_unit` | `definition.variable` | Value |
| a label | `labeled_statement` | `definition.label` | Value |
| an object-like macro | `preproc_def` | `definition.macro` | Value |
| its replacement text | `preproc_arg` | `value_candidate` on the macro | attribute |
| a function-like macro | `preproc_function_def` | `definition.macro_function` | Callable |
| `#include "x.h"`, `#include <x.h>` | `preproc_include` | `import.include`, unquoted | binding |
| `f(x)`, `(*fp)(x)` | `call_expression` | `call.function` | call |
| `s->op(x)` | `call_expression` over a `field_expression` | `call.member` | call |
| every named type mention | `type_identifier` | `reference.type` | reference |
| `x.f`, `p->f`, `.f =` | `field_expression`, `field_designator` | `reference.member` | reference |
| `#ifdef F`, `#elifdef F`, `defined(F)` | `preproc_ifdef`, `preproc_elifdef`, `preproc_defined` | `reference.macro` | reference |
| `goto end` | `goto_statement` | `reference.label` | reference |
| `[[deprecated]]` | `attribute` | `reference.attribute` | reference |
| control flow, operators, literals, `asm`, MSVC and GNU extensions | — | nothing | — |

Three notes on where the host puts these.

`definition.union` is a Type: `union` was added to `entity_family`'s Type row,
so a C union is now found by a question about types. `definition.enumerator` is
deliberately *not*: `entity_family` matches whole words, and `enumerator` is
not `enum`, so an enum constant lands in Value, which is what it is.
`definition.typedef` lands in Type on the word `typedef`, which is right rather
than accidental now that matching is whole-word.

`definition.macro_function` ends in the word `function`, and last-word-wins puts
it in Callable -- a function-like macro is called like a function and answers
"what calls this" the same way.

The carriers are all spanned on the **declaration's own node**, not on the
node the evidence was read from: the return type is read off the
`function_definition` and written onto the `function_declarator`, because that
is the span `definition.function` occupies and a carrier folds only onto a
declaration at the same span.

## Still to decide

1. **Whether a prototype and its definition should be one declaration or two.**
   They are two here, both `definition.function`, both named `foo`, one in the
   header and one in the .c file -- which is exactly what a reader wants from
   "where is `foo` declared", but it doubles the declaration count for any
   library with a full header. Left as two; the resolver merges by name
   elsewhere, and the header is usually the answer wanted.
2. **Whether `(type_identifier) @reference.type` is worth its volume.** It is
   one emission per type mention in every file, and a struct's own definition
   site counts as one reference to itself. It is kept for the same reason
   omega-cpp keeps it: every type mention is an answer someone wants, and it is
   the only reference stream that reliably resolves to a declaration in C.
3. **Whether a `static` function should be namespaced by its file.** Two
   translation units may each define a different `static int helper(void)`, and
   this Pack gives both the same name. Fixing it means encoding the file into
   the name, which is the resolver's job, not a language fact. Stated as a
   coverage guard instead.
4. **Whether an `#include` should be `relation.depends` rather than
   `import.include`.** `import.*` becomes a binding occurrence and
   `relation.depends` a depends occurrence; the second reads better for a
   dependency question, but `#include` is C's only import and the Packs for
   C++, and every other language with an import, spell it `import.*`.
   Consistency won.
