# omega-cpp

Language `omega-cpp`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

35 templates over 35 query patterns, 51 distinct node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 25 |
| `imports` | yes | 4 |
| `modules` | yes | 1 |
| `references` | yes | 3 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.alias_namespace` | Namespace | 1 |
| `definition.class` | Type | 1 |
| `definition.concept` | Type | 1 |
| `definition.conversion_function` | Callable | 1 |
| `definition.destructor` | Callable | 1 |
| `definition.enum` | Type | 1 |
| `definition.enumerator` | Value | 1 |
| `definition.field` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.label` | Value | 1 |
| `definition.macro` | Value | 1 |
| `definition.macro_function` | Callable | 1 |
| `definition.method` | Callable | 1 |
| `definition.module` | Namespace | 1 |
| `definition.namespace` | Namespace | 1 |
| `definition.operator_function` | Callable | 1 |
| `definition.struct` | Type | 1 |
| `definition.type_alias` | Type | 1 |
| `definition.typedef` | Type | 1 |
| `definition.union` | Type | 1 |
| `definition.variable` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.aliased_type_candidate` | `omega.pack.aliased_type` | 2 |
| `definition.owner_candidate` | `omega.pack.owner` | 1 |
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 2 |

Each of the three folds onto a declaration the Pack itself makes at the same
span: the two `parameter_shape` templates onto the `function_declarator` and
the `preproc_function_def` declarations, `owner` onto the qualified-name
function, `aliased_type` onto the `alias_declaration` and `type_definition`
declarations.

### Regions

None. See *What is wrong with it*.

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.function` | call | 1 |
| `call.method` | call | 1 |
| `import.header` | binding | 1 |
| `import.include` | binding | 1 |
| `import.module` | binding | 1 |
| `import.using` | binding | 1 |
| `reference.label` | reference | 1 |
| `reference.type` | reference | 1 |
| `relation.implements` | implements | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 230 node types. The Pack looks at 51 of them.

The previous Pack touched 74, and touching fewer is the point. Most of the
types it touched and this one does not are statement and expression forms it
named only as `@local.scope` -- `if_statement`, `for_statement`,
`while_statement`, `compound_statement`, `try_statement`, `catch_clause`,
`lambda_expression`, `for_range_loop`, `template_declaration` -- whose emission
was a region named with the whole text of the block. What the Pack looks at now
is the set of nodes that *declare* or *name* something.

Two entries in the list below are there for a reason worth stating.
`function_definition` is untouched because every callable is reached through
`function_declarator` instead, which also covers prototypes and out-of-line
definitions and does not have to enumerate declarator depths.
`parameter_declaration` is untouched because a parameter is carried on its
function as `omega.pack.parameter_shape` rather than declared on its own.
Everything else below is the inside of a function body -- expressions,
statements, literals, declarator plumbing, MSVC and GNU extensions, coroutine,
`requires` and SEH forms -- which carries no name a question can resolve to.
The ones that do carry meaning and are still left out are named in
*Still to decide*.

Untouched:

- `_abstract_declarator`
- `_declarator`
- `_field_declarator`
- `_type_declarator`
- `abstract_array_declarator`
- `abstract_function_declarator`
- `abstract_parenthesized_declarator`
- `abstract_pointer_declarator`
- `abstract_reference_declarator`
- `access_specifier`
- `alignas_qualifier`
- `alignof_expression`
- `annotation`
- `argument_list`
- `assignment_expression`
- `attribute`
- `attribute_declaration`
- `attribute_specifier`
- `attributed_declarator`
- `attributed_statement`
- `auto`
- `binary_expression`
- `bitfield_clause`
- `break_statement`
- `case_statement`
- `cast_expression`
- `catch_clause`
- `char_literal`
- `character`
- `co_await_expression`
- `co_return_statement`
- `co_yield_statement`
- `comma_expression`
- `comment`
- `compound_literal_expression`
- `compound_requirement`
- `compound_statement`
- `concatenated_string`
- `condition_clause`
- `conditional_expression`
- `consteval_block_declaration`
- `constraint_conjunction`
- `constraint_disjunction`
- `continue_statement`
- `decltype`
- `default_method_clause`
- `delete_expression`
- `delete_method_clause`
- `dependent_name`
- `dependent_type`
- `do_statement`
- `else_clause`
- `escape_sequence`
- `expansion_statement`
- `explicit_function_specifier`
- `explicit_object_parameter_declaration`
- `export_declaration`
- `expression`
- `expression_statement`
- `extension_expression`
- `false`
- `field_designator`
- `field_initializer`
- `field_initializer_list`
- `fold_expression`
- `for_range_loop`
- `for_statement`
- `friend_declaration`
- `function_definition`
- `generic_expression`
- `global_module_fragment_declaration`
- `gnu_asm_clobber_list`
- `gnu_asm_expression`
- `gnu_asm_goto_list`
- `gnu_asm_input_operand`
- `gnu_asm_input_operand_list`
- `gnu_asm_output_operand`
- `gnu_asm_output_operand_list`
- `gnu_asm_qualifier`
- `if_statement`
- `init_statement`
- `initializer_list`
- `initializer_pair`
- `lambda_capture_initializer`
- `lambda_capture_specifier`
- `lambda_declarator`
- `lambda_default_capture`
- `lambda_expression`
- `lambda_specifier`
- `linkage_specification`
- `literal_suffix`
- `module_partition`
- `ms_based_modifier`
- `ms_call_modifier`
- `ms_declspec_modifier`
- `ms_pointer_modifier`
- `ms_restrict_modifier`
- `ms_signed_ptr_modifier`
- `ms_unaligned_ptr_modifier`
- `ms_unsigned_ptr_modifier`
- `new_declarator`
- `new_expression`
- `noexcept`
- `null`
- `number_literal`
- `offsetof_expression`
- `optional_parameter_declaration`
- `optional_type_parameter_declaration`
- `parameter_declaration`
- `parameter_pack_expansion`
- `parenthesized_declarator`
- `parenthesized_expression`
- `placeholder_type_specifier`
- `pointer_expression`
- `pointer_type_declarator`
- `preproc_arg`
- `preproc_call`
- `preproc_defined`
- `preproc_directive`
- `preproc_elif`
- `preproc_elifdef`
- `preproc_else`
- `preproc_if`
- `preproc_ifdef`
- `primitive_type`
- `private_module_fragment_declaration`
- `pure_virtual_clause`
- `raw_string_content`
- `raw_string_delimiter`
- `raw_string_literal`
- `ref_qualifier`
- `reflect_expression`
- `requirement_seq`
- `requires_clause`
- `requires_expression`
- `return_statement`
- `seh_except_clause`
- `seh_finally_clause`
- `seh_leave_statement`
- `seh_try_statement`
- `simple_requirement`
- `sized_type_specifier`
- `sizeof_expression`
- `splice_expression`
- `splice_specifier`
- `splice_type_specifier`
- `statement`
- `static_assert_declaration`
- `storage_class_specifier`
- `string_content`
- `structured_binding_declarator`
- `subscript_argument_list`
- `subscript_designator`
- `subscript_expression`
- `subscript_range_designator`
- `switch_statement`
- `template_argument_list`
- `template_declaration`
- `template_instantiation`
- `template_parameter_list`
- `template_template_parameter_declaration`
- `this`
- `throw_specifier`
- `throw_statement`
- `trailing_return_type`
- `true`
- `try_statement`
- `type_parameter_declaration`
- `type_qualifier`
- `type_requirement`
- `type_specifier`
- `unary_expression`
- `update_expression`
- `user_defined_literal`
- `variadic_declarator`
- `variadic_parameter_declaration`
- `variadic_type_parameter_declaration`
- `virtual_specifier`
- `while_statement`

## What is wrong with it

Measured on the Pack as found: **90 templates over 124 query patterns, 42
coverage guards**, nine declared capabilities.

**Two identifier sweeps, run over every file.** `(identifier) @local.reference`
matched every identifier in every C++ file and fed *two* templates,
`reference.local` and `reference.cpp_identifier_candidate`. That is the
universal capture of Defect I in all but spelling: two emissions per identifier,
each named with the identifier's own text, neither of which distinguishes a
declaration site, a call, a parameter name or a keyword-like macro argument.
On top of it `((field_identifier) @local.reference)`,
`((type_identifier) @local.reference)` and `((namespace_identifier)
@local.reference)` added three more sweeps into the same two templates.

**The same construct declared two to five times.** The Pack was five generator
passes concatenated -- `external-helix-tags`, `p0-exact-helix-*`,
`upstream_tags`, `locals` and `semantic_closure_v3_146` -- and none reconciled
with the others. A class body produced `definition.class` (from two patterns),
`definition.cpp_class`, `definition.category_candidate` and
`local.definition.type`, which fed both `definition.type` and
`definition.cpp_type`: five declarations of one name at overlapping spans. The
same duplication ran through functions (`definition.function`,
`definition.cpp_function`, `definition.category_candidate`), methods,
namespaces, macros, parameters and variables. 21 of the 90 templates existed
only as a `cpp_`-prefixed copy of a template a few lines above.

**Seven binding templates for two things.** `binding.local`, `binding.var`,
`binding.cpp_variable`, `binding.field`, `binding.parameter`,
`binding.cpp_parameter` and `binding.variable.parameter` all fired off the same
`@local.definition.*` captures. None of them is a declaration by
`is_definition_kind` and none starts with `relation.`, `call` or `import`, so
all seven arrived as **plain references** -- references to nothing, since the
thing they name is the binding itself.

**Scopes on every statement form.** `[(for_statement) (if_statement)
(while_statement) (translation_unit) (function_definition) (compound_statement)
(struct_specifier)] @local.scope`, plus `(declaration) @local.scope`,
`(class_specifier)`, `(template_declaration)`, `(lambda_expression)`,
`(try_statement)`, `(catch_clause)`, `(requires_expression)`,
`(for_range_loop)`, `(namespace_definition)`. Two templates read them --
`scope.lexical` and `scope.cpp_lexical_scope` -- and both took their **name**
from the scope capture, so the name of a region was the entire source text of
the block. Defect D, once per block, twice.

**Fourteen patterns that state containment (Defect E).** Six `ownership_members`
patterns spelling `(class_specifier name: body: (field_declaration_list
(alias_declaration name:)))` and the like, four `member_category_*` patterns of
the same shape, and four more under `semantic_closure_v3_146_cpp_macro_adjacency`.
The tree already holds all of it.

**Ten patterns of macro adjacency, which is a framework overlay (Defect L).**
`semantic_closure_v3_146_cpp_macro_adjacency` and
`..._unreal_macro_argument_items` encode "an expression statement calling a
macro, immediately followed by a class, struct or enum declaration", and then
that macro's arguments one by one. That is `UCLASS()` and `UPROPERTY()` --
Unreal Engine, named in the pass -- written as a tree shape inside a language
Pack. There is an `omega-framework-unreal-engine` for exactly this. Five of the
ten are rooted at `(translation_unit ...)` with an argument wildcard
`(_) @argument`, so each matched once per argument of every top-level macro call
that happened to precede a type.

**Three call-shape patterns that are a test-framework overlay.**
`identifier_string_call_context`, `string_literal_call_context` and
`two_identifier_call_context` match `TEST_CASE("name", "[tag]")` and
`TEST_CASE_METHOD(Fixture, "name", "[tag]")` -- Catch2, named in the comments --
and store the arguments in fields. Framework semantics, in a language Pack.

**Four names that are constants (Defect J).** `data.cpp_requires_clause` was
named `"requires"`, `data.cpp_requires_expression` `"requires_expression"`,
`data.cpp_lambda` `"lambda"` and `data.cpp_template_declaration` `"template"`.
Every lambda in the repository collapsed onto the single name `lambda`.

**Sixteen carriers the host will not fold, one relation it does not know.**
`call.target_candidate`, `module.cpp_candidate`, `type.cpp_declaration_candidate`,
`scope.enclosing_owner_candidate`, `import.target_candidate`,
`reference.cpp_identifier_candidate` and ten more end in `_candidate` without
containing `definition` and without ending in one of the five declaration
suffixes, so they fall through to the mention branch and are stored as
references to nothing. `relation.inherits_candidate` is not one of the six
relations the host knows, so the one relation C++ states outright -- a base
class -- arrived as a plain reference, under capability `calls`.

**Six kinds routed to the wrong family (Defect A).** `definition.cpp_concept`,
`definition.interface` (what the helix-tags pass called a C++ concept),
`definition.cpp_namespace`, `definition.namespace` and `definition.module` all
landed in Value; a concept is a type and a namespace and a module are
namespaces. `definition.cpp_destructor` landed in **Type**, because `destructor`
was not in the Callable vocabulary. All six are now spelled with a word the
host reads.

**Three guards whose reason is a label (Defect G)**, out of 42 guards for 90
templates:
`cpp_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`,
`cpp_overload_and_dynamic_call_resolution_requires_semantic_oracle`,
`cpp_upstream_tags_are_syntax_candidates_only`. Most of the other 39 are one
sentence about "bounded source symbol resolution" restated once per capability.

**Nothing was declared that a C++ file is actually made of.** No enumerator, no
data member under its own name, no namespace-scope variable, no `#include`
target a question could follow, no operator, no conversion function, no `using`
declaration, no goto label.

## What it should extract

C++ files are headers that declare an API and translation units that implement
it. The questions are: *where is this class, function or macro declared*, *what
does this type derive from*, *what calls this*, *what does this file include or
import*, *what is this function's signature*.

| what | node | emitted as | family |
|---|---|---|---|
| a free or qualified function | `function_declarator` via `identifier`, `qualified_identifier` | `definition.function` | Callable |
| a member function | `function_declarator` via `field_identifier` | `definition.method` | Callable |
| a destructor | `function_declarator` via `destructor_name` | `definition.destructor` | Callable |
| an overloaded operator | `function_declarator` via `operator_name` | `definition.operator_function` | Callable |
| a conversion operator | `operator_cast` | `definition.conversion_function` | Callable |
| the callee's parameter list | `parameter_list`, `preproc_params` | `parameter_shape_candidate` carrier | attribute |
| the qualifier on an out-of-line definition | `qualified_identifier` `scope:` | `owner_candidate` carrier | attribute |
| a class | `class_specifier` with a body | `definition.class` | Type |
| a struct | `struct_specifier` with a body | `definition.struct` | Type |
| a union | `union_specifier` with a body | `definition.union` | Type |
| an enum | `enum_specifier` with a body | `definition.enum` | Type |
| an enumerator | `enumerator` | `definition.enumerator` | Value |
| `using X = Y` | `alias_declaration` | `definition.type_alias` + `aliased_type_candidate` | Type |
| `typedef Y X` | `type_definition` | `definition.typedef` + `aliased_type_candidate` | Type |
| a concept | `concept_definition` | `definition.concept` | Type |
| a base class | `base_class_clause` | `relation.implements` | implements |
| a namespace | `namespace_definition` | `definition.namespace` | Namespace |
| a namespace alias | `namespace_alias_definition` | `definition.alias_namespace` | Namespace |
| a module | `module_declaration` | `definition.module` | Namespace |
| an object-like macro | `preproc_def` | `definition.macro` | Value |
| a function-like macro | `preproc_function_def` | `definition.macro_function` | Callable |
| a data member | `field_declaration` | `definition.field` | Value |
| a namespace-scope variable | `declaration` under `translation_unit` / `declaration_list` | `definition.variable` | Value |
| a goto label | `labeled_statement` | `definition.label` | Value |
| `#include` | `preproc_include` | `import.include` | binding |
| `import M;` | `import_declaration` `name:` | `import.module` | binding |
| `import "h";` | `import_declaration` `header:` | `import.header` | binding |
| `using ns::x;` | `using_declaration` | `import.using` | binding |
| a call | `call_expression` `function:` | `call.function` | call |
| a member call | `call_expression` via `field_expression` | `call.method` | call |
| a type mention | `type_identifier` | `reference.type` | reference |
| `goto label` | `goto_statement` | `reference.label` | reference |
| everything inside a function body | expressions, statements, literals | nothing | -- |

Four choices in that table are worth stating outright.

**Every callable is one root node.** C++ spells the return type before the name
and wraps the name in as many pointer, reference and array declarators as it
likes, so a pattern rooted at `function_definition` has to enumerate declarator
depths -- which is what the old Pack's six-deep
`(parameter_declaration (_ (_ (_ (_ (_ (identifier)))))))` ladder was. Rooting
at `function_declarator` instead covers definitions, prototypes, in-class
methods and out-of-line definitions in five patterns, at one match per callable.
`parameters:` is a *required* field of that node, so capturing it changes
nothing about what matches and gives every callable its signature for free.

**Names are reduced to what they resolve against.** A base class written
`std::enable_shared_from_this<Widget>` is emitted as `enable_shared_from_this`:
`first(split(x, "<"))` then `last(split(x, "::"))`. An `#include` is emitted as
the path with its quotes or angle brackets stripped. Both use the expression
vocabulary the runtime already has and the shipped Packs never used.

**No regions.** The old Pack made a region of every block, loop, branch,
declaration and translation unit, and named each one with its whole text. C++
containment is already carried by the `within:` segment of a nested
declaration, and no question is answered by knowing that some range of bytes is
an `if`. The `scopes` capability is dropped with its templates and its guards.

**No locals, parameters or template parameters as declarations.** A local named
`i`, declared once per occurrence across a repository, is a name that resolves
to hundreds of unrelated spans. What an agent asks of a parameter is what a
function's signature is, and that is a carrier on the function. This is stated
in a coverage guard rather than left silent.

Six coverage guards replace 42, one per real limitation: the constructor and the
most vexing parse; the preprocessor never expanding; locals not being declared;
overload resolution and indirect calls; the reduction of type names; includes
and modules not being resolved against a search path.

## Still to decide

1. **Template parameters.** `template <typename T>` declares `T`, and
   `reference.type` emits `T` as a reference that resolves to nothing. The
   alternative -- declaring it -- makes `T` a repository-wide name with hundreds
   of unrelated declarations. Left undeclared; revisit if unresolved `T`
   references turn out to be noisy in retrieval.
2. **Plain member access.** `a.b` outside a call is not emitted, so "where is
   field `b` read" is unanswered while "where is method `b` called" is answered.
   Emitting it would put a second mention of the same bytes under a different
   kind on every member call site. Left out.
3. **`export import M;`** is recorded as the import it contains, not as a
   re-export. Distinguishing it needs a second pattern rooted at
   `export_declaration`, for a fact no current question asks.
4. **A forward declaration** (`class Widget;`) names a type without defining
   it, and is deliberately not a declaration here: it would put a second, empty
   declaration of every type into every header that mentions it. It is still
   emitted as a `reference.type`.
5. **A constructor** cannot be told from any other function by syntax -- it is a
   `function_declarator` whose identifier happens to equal the enclosing class
   name, which a query cannot compare. Distinguishing it would need either a
   host-side comparison or a containment pattern per class; neither is worth it,
   and the guard says so.
