; omega-razor
;
; A Razor file (.razor, .cshtml) is one compilation unit made of three
; languages: HTML markup, C# written inside `@code`/`@{ }` islands, and the
; Razor directives that say what the generated class is -- its route, its base
; class, its namespace, the services injected into it.
;
; The questions asked of one are: what does this page serve, what does it
; inherit or implement, what services and namespaces does it pull in, what C#
; does it declare, and what does that C# call. Every pattern below answers one
; of them.
;
; Containment is never stated as a pattern. The tree holds it, a nested
; declaration carries its container through `within:`, and the one region worth
; naming -- where the C# island is -- is emitted once as a scope.

; ---------------------------------------------------------------------------
; Razor directives: what the generated class is
; ---------------------------------------------------------------------------

; `@page "/counter"` -- the route this file answers.
(razor_page_directive
  (string_literal (string_literal_content) @page.route)) @page

; `@namespace Foo.Bar` -- the namespace of the generated class.
(razor_namespace_directive (qualified_name) @namespace.name) @namespace

; `@layout MainLayout` -- the page cannot render without it.
(razor_layout_directive name: (_) @layout.name) @layout

; `@inherits ComponentBase<T>` and `@implements IDisposable` -- the base list
; of the generated class, written one directive at a time.
(razor_inherits_directive name: (_) @inherits.name) @inherits

(razor_implements_directive name: (_) @implements.name) @implements

; `@model Customer` -- the type of the page's model.
(razor_model_directive name: (_) @model.name) @model

; `@typeparam TItem` -- a generic parameter of the generated component.
(razor_typeparam_directive name: (_) @typeparam.name) @typeparam

; `@rendermode InteractiveServer` -- how the component is configured to render.
(razor_rendermode_directive (razor_rendermode) @rendermode.value) @rendermode

; `@preservewhitespace true`
(razor_preservewhitespace_directive
  (boolean_literal) @preservewhitespace.value) @preservewhitespace

; `@section Scripts { ... }` -- a named block a layout renders by name.
(razor_section (identifier) @section.name) @section

; `@inject IWeatherService Weather` -- a property of the generated class, and
; the one place a Razor file names a dependency it does not construct.
(razor_inject_directive
  (variable_declaration
    type: (_) @inject.type
    (variable_declarator name: (identifier) @inject.name) @inject))

; `@using System.Linq` and `@using Grid = Components.DataGrid`.
; The first pattern sees both spellings and states the import; the second sees
; only the aliased one and states the alias it declares.
(razor_using_directive (type) @razor_using.target) @razor_using

(razor_using_directive
  name: (identifier) @razor_using.alias) @razor_using.alias_owner

; The same two, written as C# inside a code island.
(using_directive (type) @using.target) @using

(using_directive
  name: (identifier) @using.alias) @using.alias_owner

; ---------------------------------------------------------------------------
; The C# the file declares
; ---------------------------------------------------------------------------

(class_declaration name: (identifier) @class.name) @class

(interface_declaration name: (identifier) @interface.name) @interface

(struct_declaration name: (identifier) @struct.name) @struct

(record_declaration name: (identifier) @record.name) @record

(enum_declaration name: (identifier) @enum.name) @enum

(delegate_declaration
  type: (_) @delegate.returns
  name: (identifier) @delegate.name
  parameters: (_) @delegate.parameters) @delegate

(type_parameter name: (identifier) @type_parameter.name) @type_parameter

(namespace_declaration name: (_) @namespace.name) @namespace

(file_scoped_namespace_declaration name: (_) @namespace.name) @namespace

; A callable and its signature come out of one match: the declaration, the
; return type it carries and the parameter shape it carries.
(method_declaration
  returns: (_) @method.returns
  name: (identifier) @method.name
  parameters: (_) @method.parameters) @method

(local_function_statement
  type: (_) @local_function.returns
  name: (identifier) @local_function.name
  parameters: (_) @local_function.parameters) @local_function

(constructor_declaration
  name: (identifier) @constructor.name
  parameters: (_) @constructor.parameters) @constructor

(destructor_declaration
  name: (identifier) @destructor.name
  parameters: (_) @destructor.parameters) @destructor

(property_declaration
  type: (_) @property.type
  name: (identifier) @property.name) @property

(event_declaration
  type: (_) @event.type
  name: (identifier) @event.name) @event

; An indexer has no name in the grammar and none in the language; `this[]` is
; what C# calls it.
(indexer_declaration
  type: (_) @indexer.type
  parameters: (_) @indexer.parameters) @indexer

(enum_member_declaration name: (identifier) @constant.name) @constant

(parameter name: (identifier) @parameter.name) @parameter

; A field, an event field and a local are the same shape -- a declarator under
; a typed declaration -- and differ only in what declares them. The declarator
; is the span, so each name in `int a, b;` is its own declaration.
(field_declaration
  (variable_declaration
    type: (_) @field.type
    (variable_declarator name: (identifier) @field.name) @field))

(event_field_declaration
  (variable_declaration
    type: (_) @event_field.type
    (variable_declarator name: (identifier) @event_field.name) @event_field))

(local_declaration_statement
  (variable_declaration
    type: (_) @local.type
    (variable_declarator name: (identifier) @local.name) @local))

; `@foreach (var item in items)` and its C# equivalent both bind a name.
(razor_foreach left: (identifier) @loop.name)

(foreach_statement left: (identifier) @loop.name)

; ---------------------------------------------------------------------------
; What the C# refers to
; ---------------------------------------------------------------------------

; A base list is the one place a C# type says what it is. Predefined types are
; excluded: `enum Flags : int` states a storage size, not a base type.
(base_list
  [(identifier) (qualified_name) (generic_name) (alias_qualified_name)]
  @base.type)

; `[Authorize]`, whether written on a C# member or as `@attribute [Authorize]`.
(attribute name: (_) @attribute.name) @attribute

; A call is recorded under the name written at the call site, not under the
; whole receiver chain, so it can resolve against a method declaration.
(invocation_expression
  function: [
    (identifier) @call.name
    (generic_name (identifier) @call.name)
    (member_access_expression name: (_) @call.name)
    (member_binding_expression name: (_) @call.name)
    (qualified_name name: (_) @call.name)
  ]) @call

(object_creation_expression type: (_) @new.type) @new

; `Model.Name`, `item?.Title` -- the member being read.
(member_access_expression name: (identifier) @member.name)

(member_binding_expression name: (identifier) @member.name)

; `@onclick="Increment"` -- a Razor attribute whose whole value is one C#
; identifier. That identifier is a member of this file's own class, so it
; resolves; anything more complex is an expression and is left alone.
(razor_html_attribute
  (razor_attribute_name) @html_attribute.name
  (razor_attribute_value (identifier) @html_attribute.value))

; ---------------------------------------------------------------------------
; The one region worth naming
; ---------------------------------------------------------------------------

; Where the C# island is. Everything else in the file is markup, and asking
; whether a span is code or markup is answered by this and nothing else.
(razor_block) @code_block
