; omega-powershell
;
; PowerShell is the language of build scripts, deployment and administration:
; `.ps1` scripts, `.psm1` modules, `.psd1` manifests and DSC configuration.
; The questions asked of such a file are: which functions, classes and enums
; does it declare, what parameters do they take, which commands does it run,
; which module does it load, which .NET type does it touch, and where is this
; setting set. Every pattern below answers one of them.
;
; Containment is not stated. A function body and a method body are emitted as
; one region each; nothing else restates an edge the tree already holds.
;
; A bare `$variable` mention is deliberately not stated -- see the coverage
; guards in rules.json. The Pack declares the places a variable is bound
; (assignment, `foreach`, a parameter, a class property) and leaves reads
; unstated rather than storing every `$_` in every pipeline.

; --- a function ---
;
; `function`, `filter` and `workflow` are one node here. A function declares
; its parameters in one of two places -- `function f($a, $b)` or a `param()`
; block at the top of the body -- and both are captured, so the signature line
; is built whichever spelling the author used. One match, four templates.

(function_statement
  (function_name) @function.name
  (function_parameter_declaration (parameter_list) @function.parameters)?
  (script_block
    (param_block (parameter_list) @function.param_parameters)?) @function.body) @function

; --- a class ---
;
; `class_statement` spells the class name and every base type as bare
; `simple_name` children of the same node, so the name is anchored to the first
; one; an unanchored pattern would declare `Bar` in `class Foo : Bar` as a
; class of its own.

(class_statement . (simple_name) @class.name) @class

; Every later `simple_name` child is a base class or an implemented interface.
(class_statement . (simple_name) @class.name (simple_name) @class.base)

; --- a method ---

(class_method_definition
  (type_literal (type_spec) @method.return_type)?
  (simple_name) @method.name
  (class_method_parameter_list)? @method.parameters
  (script_block) @method.body) @method

; --- a class property ---

(class_property_definition
  (type_literal (type_spec) @property.type)?
  (variable) @property.name) @property

; --- an enum and its members ---

(enum_statement . (simple_name) @enum.name) @enum

(enum_member (simple_name) @enumerator.name) @enumerator

; --- a parameter ---
;
; A script, a function and a `param()` block all spell a parameter as
; `script_parameter`, so one pattern covers all three. This grammar parses a
; parameter's type as an attribute -- `[string]$Name` is an `attribute` holding
; a `type_literal` -- which is what separates it from `[Parameter()]`, an
; `attribute` holding an `attribute_name`.

(script_parameter
  (attribute_list (attribute (type_literal (type_spec) @parameter.type)))?
  (variable) @parameter.name) @parameter

(class_method_parameter
  (type_literal (type_spec) @method_parameter.type)?
  (variable) @method_parameter.name) @method_parameter

; --- a variable binding ---
;
; The chain below is not stated containment: this grammar routes every
; expression through the full precedence ladder, so twelve nested nodes are the
; shortest path from an assignment to the variable on its left. The alternation
; is the two spellings `$x = ...` and `[int]$x = ...`.

(assignment_expression
  (left_assignment_expression
    (logical_expression
      (bitwise_expression
        (comparison_expression
          (additive_expression
            (multiplicative_expression
              (format_expression
                (range_expression
                  (array_literal_expression
                    (unary_expression
                      [(variable) @assign.name
                       (expression_with_unary_operator
                         (cast_expression
                           (type_literal (type_spec) @assign.type)
                           (unary_expression (variable) @assign.name)))]))))))))))) @assign

(foreach_statement (variable) @foreach.name) @foreach

; --- a data section ---

(data_statement (data_name (simple_name) @data.name)) @data

; --- a hashtable entry ---
;
; The hashtable literal is PowerShell's configuration form: a module manifest,
; DSC configuration data and a splatted parameter set are all one. The key is
; where a setting is set, so it is declared under its own name.

(hash_entry (key_expression) @hash.key) @hash.entry

; --- a command ---
;
; The name as authored. It resolves onto a `definition.function` of the same
; name when the function is in the repository.

(command command_name: (command_name) @call.command.name) @call.command

; `. .\lib.ps1` and `& $PSScriptRoot\build.ps1` -- the file this script pulls in.
(command command_name: (command_name_expr (path_command_name) @depends.path)) @depends

; `Import-Module` is the language's module loader, not a library API: this
; grammar has no `using` statement, so a literal module argument is the only
; import PowerShell spells.
((command
   command_name: (command_name) @import.command
   command_elements: (command_elements
     [(string_literal) (generic_token)] @import.name)) @import
 (#match? @import.command "(?i)^import-module$"))

; `-Path`, `-Force`: the call site of a declared parameter.
(command_parameter) @command.parameter

; --- a member ---
;
; `$obj.Method()` puts `member_name` directly under `invokation_expression`;
; `$obj.Property` and `[Math]::PI` put it under `member_access`. Two node
; types, so a call can never be read as a property access.

(invokation_expression (member_name (simple_name) @call.method.name)) @call.method

(member_access (member_name (simple_name) @member.name)) @member

; --- a type ---
;
; `[System.IO.Path]`, `[MyClass]`, a cast, a catch type, a trap type and a
; parameter's type are all `type_literal`. The name is the `type_spec` text, so
; a reference to a class declared in the repository resolves onto it.

(type_literal (type_spec) @type.name) @type.use

; `[CmdletBinding()]`, `[Parameter(Mandatory)]`, `[ValidateSet(...)]`.
(attribute (attribute_name (type_spec) @attribute.name)) @attribute
