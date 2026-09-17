# omega-powershell

Language `omega-powershell`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

31 templates over 21 query patterns, 50 of the grammar's 151 named node types.

| capability | declared | templates |
|---|---|---|
| `calls` | yes | 2 |
| `definitions` | yes | 19 |
| `imports` | yes | 1 |
| `references` | yes | 5 |
| `scopes` | yes | 2 |
| `types` | yes | 1 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.class` | Type | 1 |
| `definition.enum` | Type | 1 |
| `definition.enumerator` | Value | 1 |
| `definition.function` | Callable | 1 |
| `definition.method` | Callable | 1 |
| `definition.property` | Value | 1 |
| `definition.parameter` | Value | 2 |
| `definition.variable` | Value | 2 |
| `definition.config_entry` | Config | 1 |
| `definition.data_section` | Value | 1 |

### Carriers -- attributes they attach to the declaration on the same span

| kind | attribute | templates |
|---|---|---|
| `definition.parameter_shape_candidate` | `omega.pack.parameter_shape` | 3 |
| `definition.return_type_candidate` | `omega.pack.return_type` | 1 |
| `definition.declared_type_candidate` | `omega.pack.declared_type` | 4 |

All three carried names are ones the host reads: the first two build the
signature line on a card, the third is in the engine's read-carried set.

### Regions

- `scope.function_body` (2: a function body and a class method body)

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `call.command` | call | 1 |
| `call.method` | call | 1 |
| `relation.implements` | implements | 1 |
| `relation.depends` | depends | 1 |
| `import.module` | binding | 1 |
| `reference.member` | reference | 1 |
| `reference.parameter` | reference | 1 |
| `reference.attribute` | reference | 1 |
| `type_use.name` | reference | 1 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 151 node types. The Pack looks at 50 of them.

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
- `command_argument_sep`
- `command_invokation_operator`
- `comment`
- `comparison_argument_expression`
- `comparison_operator`
- `data_command`
- `data_commands_allowed`
- `data_commands_list`
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
- `file_redirection_operator`
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
- `parenthesized_expression`
- `path_command_name_token`
- `pipeline`
- `post_decrement_expression`
- `post_increment_expression`
- `pre_decrement_expression`
- `pre_increment_expression`
- `program`
- `range_argument_expression`
- `real_literal`
- `redirected_file_name`
- `redirection`
- `redirections`
- `script_block_body`
- `script_block_expression`
- `script_parameter_default`
- `sequence_statement`
- `statement_block`
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

Most of that list is the precedence ladder (`*_argument_expression`,
`comparison_operator`, `format_operator`), control flow (`if_statement`,
`while_statement`, `try_statement`, `switch_statement`), which the host drops,
and literals, which suppress nothing here because this Pack emits no
`reference_context.*` kind. Four untouched types are a deliberate decision and
are listed under **Still to decide**. `catch_type_list`, `trap_statement`,
`generic_type_name` and `array_type_name` are untouched only as node types: the
`type_literal` they each hold is matched, so a caught type and a generic type
argument are stated.

## What is wrong with it

These are the defects of the Pack as found, measured by
`python pack-design/audit.py omega-powershell`: **26 templates over 34
patterns, 10 guards**, touching 48 node types.

**Most of the Pack was an nvim-treesitter `locals.scm` baseline, pasted whole.**
Half the query file sat under the header
`; --- external-neovim-distributed-locals ---` and carried that file's
conventions, not Omega's. It brought with it:

- **Defect I, the universal capture, twice.** `(variable) @local.reference` and
  `(command_name) @local.reference` store *every* `$x` and *every* command name
  in every file as a reference named by its own text. Those two lines alone
  were the highest-volume patterns in the Pack.
- **Defect H, five predicates the runtime never applies.** Five
  `(#set! definition.var.scope "parent")` directives. `#set!` is read only by
  the injection layer, so in a `locals` context it is inert: tree-sitter parses
  it into a bucket nothing reads and the author cannot tell from reading the
  file.
- **Defect D2, seven templates whose name was their own whole span.**
  `type.powershell_declaration_candidate` named itself from the entire
  `(class_statement)` -- the whole class body, every method, stored as a name.
  `definition.associated` did the same from `(type_spec)`, and `binding.field`,
  `binding.parameter`, `binding.var` and `reference.local` from `(variable)`,
  keeping the `$` sigil, so no reference could ever match a declaration.
- **A 12-deep query, written twice.** The two variable-assignment patterns walk
  the whole precedence ladder, once per spelling, for one fact. The ladder
  itself is forced by the grammar; writing it twice was not.

**Four of six carriers carried a name nothing assembles.**
`omega.pack.powershell_declaration`, `omega.pack.named_owner`,
`omega.pack.member_owned` and `omega.pack.parameter_owned` are names no code in
the engine reads, so four templates wrote attributes nobody can retrieve. Three
of them could not even be folded: `type.powershell_declaration_candidate`,
`scope.named_owner_candidate` and `binding.parameter_owned_candidate` all fail
`is_definition_kind`, so the host treated each as a *mention* whose name was an
entire class body or an entire function.

**Two carriers overwrote themselves.** `definition.member_owned_candidate` had
its span on `(class_statement)` and its name on a method's `(simple_name)`, so a
class with eight methods wrote one attribute eight times and kept the last;
`definition.parameter_shape_candidate` did the same over
`(function_parameter_declaration)` inside `(function_statement)`.

**Five of the eight declared capabilities answered the wrong question.**
`binding.field`, `binding.parameter`, `binding.var` and
`binding.powershell_foreach` are not declarations by the host's reading -- they
contain no `definition` and end in none of the five suffixes -- so a class
property, a function parameter, an assigned variable and a `foreach` binding
were all stored as *references*, resolving against nothing, and the language's
four binding sites declared nothing at all. `data.powershell_redirection`,
`data.powershell_pipeline` and `data.powershell_hashtable_entry` were mentions
for the same reason, the last two named by the whole pipeline and the whole
hashtable key expression.

**Nine of ten guards gave a label for a reason**, one of them a single token
(`powershell_type_declarations_are_syntax_candidates_until_name_resolution_and_alias_expansion`).
`category_is_syntactic_from_ast_node_kind; resolution_requires_view_resolver_evidence`
is a generator's confidence tier, not something an agent can act on.

**Two constructs were declared twice under two spellings** (Defect K).
`definition.type` (from the locals baseline) and
`type.powershell_declaration_candidate` both fired on `class_statement`;
`definition.method` and `definition.powershell_method_return_type` both on
`class_method_definition`, the second one a declaration kind whose whole job was
to carry a field named `return_type` that the signature builder does not read.

**The class-name pattern was unanchored.** `(class_statement (simple_name))`
matches *every* bare `simple_name` child, and this grammar spells a base class
as another one, so `class Deployer : Base` declared a class called `Base`.

**And three things the language actually has were never stated**: a parameter's
declared type (spelled as an `attribute` here, which the baseline took for an
annotation); a `param()` block, which is the dominant way a PowerShell function
declares its parameters and which the Pack read only in the `function f($a)`
form; and any `type_literal` outside a class member, so `[System.IO.Path]`, a
cast, a `catch` type and a `trap` type were invisible.

## What it should extract

PowerShell is the language of build, deployment and administration scripts:
`.ps1`, `.psm1`, `.psd1` and DSC configuration. The questions asked of such a
file are *what does this script define*, *what does it run*, *what module does
it need*, *what parameters does this function take*, *which .NET type does it
touch*, and *where is this setting set*.

| what | node | emitted as | family |
|---|---|---|---|
| a function, filter or workflow | `function_statement` via `function_name` | `definition.function` | Callable |
| its parameter list, either spelling | `parameter_list` under `function_parameter_declaration` or `param_block` | `definition.parameter_shape_candidate` | carried |
| its body | `script_block` | `scope.function_body` | region |
| a class | `class_statement`, first `simple_name` | `definition.class` | Type |
| a base class or interface | a later `simple_name` of `class_statement` | `relation.implements` | implements |
| a method | `class_method_definition` via `simple_name` | `definition.method` | Callable |
| its return type | the leading `type_literal` | `definition.return_type_candidate` | carried |
| its parameter list | `class_method_parameter_list` | `definition.parameter_shape_candidate` | carried |
| its body | `script_block` | `scope.function_body` | region |
| a class property | `class_property_definition` via `variable` | `definition.property` | Value |
| its declared type | `type_spec` | `definition.declared_type_candidate` | carried |
| an enum | `enum_statement`, first `simple_name` | `definition.enum` | Type |
| an enum member | `enum_member` via `simple_name` | `definition.enumerator` | Value |
| a parameter | `script_parameter`, `class_method_parameter` via `variable` | `definition.parameter` | Value |
| its declared type | `type_spec` inside the parameter's `attribute` | `definition.declared_type_candidate` | carried |
| a variable binding | `assignment_expression`, the left-hand `variable` | `definition.variable` | Value |
| its cast type | `type_spec` in the `cast_expression` | `definition.declared_type_candidate` | carried |
| a `foreach` binding | `foreach_statement` via `variable` | `definition.variable` | Value |
| a `data` section | `data_statement` via `data_name` | `definition.data_section` | Value |
| a hashtable key | `hash_entry` via `key_expression` | `definition.config_entry` | Config |
| a command | `command` via `command_name` | `call.command` | call |
| a dot-sourced or invoked script | `path_command_name` under `command_name_expr` | `relation.depends` | depends |
| `Import-Module <name>` | `command` with a literal argument | `import.module` | binding |
| `-Path`, `-Force` at a call site | `command_parameter` | `reference.parameter` | reference |
| `$obj.Method()`, `[Math]::Max()` | `member_name` under `invokation_expression` | `call.method` | call |
| `$obj.Property`, `[Math]::PI` | `member_name` under `member_access` | `reference.member` | reference |
| any `[Type]` | `type_literal` via `type_spec` | `type_use.name` | reference |
| `[CmdletBinding()]`, `[Parameter()]` | `attribute` via `attribute_name` | `reference.attribute` | reference |
| a bare `$variable` read | `variable` | nothing -- see the guard | -- |
| control flow, literals, the precedence ladder | `if_statement`, `integer_literal`, `*_argument_expression` | nothing | -- |

Three name expressions do real work. A variable name is stripped of its `$` and
of any scope modifier, so `$script:Config`, `$env:Config` and `$Config` all name
`Config`, and a parameter's declaration and its `-Config` call site can meet. A
command parameter is stripped of its leading `-` and of a trailing `:`, so
`-Force:` resolves onto the parameter `Force`. A module name and a hashtable key
are stripped of their quotes.

One thing is stated by matching a literal command name, which is close to the
line the contract draws against framework overlays. `Import-Module` falls on the
right side of it: this grammar has no `using` statement, so a literal
`Import-Module` argument is the *only* import PowerShell spells here, and it is
a cmdlet of the engine itself, not of a library. Nothing else in the Pack keys
on a command name -- no `Invoke-Pester`, no `Describe`/`It`, no
`New-AzResourceGroup`. Those belong in `frameworks/`.

### One defect class the audit does not report, and why

`audit.py` derives a capture's owning node type with a regex that stops at the
first `)` followed by `@`. The method parameter-shape carrier is written
`(class_method_parameter_list)? @method.parameters`, and the quantifier between
`)` and `@` hides it from that regex, so the *carrier that may overwrite itself*
check never sees it. Had it seen it, it would have fired, because
tree-sitter-powershell groups every child of `class_method_definition` into one
`multiple: true` bucket -- the same false positive the omega-typescript agent
recorded in `00-INDEX.md` for `accessibility_modifier`. A method has exactly one
parameter list in this language, so the carrier is correct; it is written down
here rather than left to look like a pass. The blind spot is `audit.py`'s, not
this Pack's, and it is reported rather than fixed here.

## Still to decide

1. **Every hashtable entry is a `Config` declaration.** In a `.psd1` manifest or
   in DSC configuration data that is exactly right; in a splatted parameter set
   or an ordinary lookup table it declares a Config entry for a value. The
   alternative -- restricting it by file extension -- is not something a query
   can see, and restricting it by key name would be a framework overlay.
   Provisionally: declare it, and revisit against the row count.
2. **A bare `$variable` read is not stated at all.** The old Pack stated every
   one; this Pack states none and declares the four places a variable is bound
   instead. The middle position -- stating a read only where it is the whole
   right-hand side of an assignment, or the receiver of a member access -- would
   answer "what feeds this" without storing every `$_`. Left out until there is
   a measurement to justify the volume.
3. **`named_block` (`begin`/`process`/`end`) and `param_block` attributes are
   untouched.** A `process` block is meaningful to a PowerShell author, but as a
   declaration it collapses onto three names for a whole corpus, and as a region
   it duplicates `scope.function_body`. Left out.
4. **`redirection` and `pipeline` are untouched.** The old Pack emitted both as
   `data.*` mentions, named by the redirected file and by the whole pipeline
   text. A redirection target is a genuine output dependency and could be a
   `relation.depends`, but it is almost always a variable-built path rather than
   a literal, so it would resolve against nothing. Left out.
