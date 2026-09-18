# omega-framework-angular

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

31 overlay rules, 4 detection rules. **6 can match, 25 cannot.**

Selector: `framework:angular`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `SymbolReference` | 8 |
| `AngularType` | 5 |
| `Component` | 2 |
| `TemplateReference` | 2 |
| `Input` | 2 |
| `Output` | 2 |
| `View` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `Directive` | 1 |
| `Service` | 1 |
| `Module` | 1 |
| `Pipe` | 1 |
| `Selector` | 1 |
| `StyleReference` | 1 |
| `InjectionPoint` | 1 |
| `InputBinding` | 1 |
| `EventBinding` | 1 |
| `StructuralDirective` | 1 |
| `NavigationReference` | 1 |
| `TemplateElement` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `specializes` | 5 |
| `configured_by` | 4 |
| `imports` | 2 |
| `provides` | 2 |
| `declares` | 2 |
| `exports` | 2 |
| `has_input` | 2 |
| `has_output` | 2 |
| `contains` | 1 |
| `renders` | 1 |
| `uses_api` | 1 |
| `depends_on` | 1 |
| `uses_template` | 1 |
| `declares_selector` | 1 |
| `uses_style` | 1 |
| `injects` | 1 |
| `references` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `import.ecmascript_named_binding_context` | 15 | **no** |
| `reference.decorator` | 8 | yes |
| `reference.typescript_class_decorator_object_array_identifier_context` | 8 | **no** |
| `data.html_attribute_context` | 5 | **no** |
| `reference.typescript_class_decorator_object_string_field_context` | 3 | **no** |
| `reference.typescript_class_member_decorator_context` | 2 | **no** |
| `reference.typescript_class_member_marker_decorator_context` | 2 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.typescript_class_decorator_object_array_string_context` | 1 | **no** |
| `reference.typescript_constructor_parameter_type_context` | 1 | **no** |
| `data.html_element_text_context` | 1 | **no** |

Clause vocabulary in use: `field_present` x60, `field_equals` x58, `fact_kind` x31, `fact_join_by_field` x17, `(join)` x17, `external_path_matches` x10, `path_glob` x7, `field_prefix` x4, `field_in` x1.

Fields read: `owner_class`, `decorator_name`, `module_source`, `imported_name`, `field_name`, `attribute_name`, `item_identifier`, `definition.name`, `path`, `tag`, `member_name`, `string_value`, `source.start`, `item_string`, `parameter_name`, `parameter_type`.

Path globs: `**/*.component.html`, `**/*.ts`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `angular.component.inline-template` | kind `reference.typescript_class_decorator_object_string_field_context`; field `decorator_name`, `field_name`, `owner_class`, `string_value` |
| `angular.generic-api-call.angular-core` | kind `call.target_candidate` |
| `angular.generic-dependency.angular-core` | kind `import.target_candidate` |
| `angular.component.metadata-string.templateUrl` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_string_field_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source`, `owner_class`, `string_value` |
| `angular.component.metadata-string.selector` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_string_field_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source`, `owner_class`, `string_value` |
| `angular.component.styleUrls` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_string_context`; field `decorator_name`, `field_name`, `imported_name`, `item_string`, `module_source`, `owner_class` |
| `angular.component.imports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.component.providers` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.component.declarations` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.component.exports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.ngmodule.imports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.ngmodule.providers` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.ngmodule.declarations` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.ngmodule.exports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `item_identifier`, `module_source`, `owner_class` |
| `angular.member.input.typescript_class_member_decorator_context` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_member_decorator_context`; field `decorator_name`, `imported_name`, `member_name`, `module_source`, `owner_class` |
| `angular.member.input.typescript_class_member_marker_decorator_context` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_member_marker_decorator_context`; field `decorator_name`, `imported_name`, `member_name`, `module_source`, `owner_class` |
| `angular.member.output.typescript_class_member_decorator_context` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_member_decorator_context`; field `decorator_name`, `imported_name`, `member_name`, `module_source`, `owner_class` |
| `angular.member.output.typescript_class_member_marker_decorator_context` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_member_marker_decorator_context`; field `decorator_name`, `imported_name`, `member_name`, `module_source`, `owner_class` |
| `angular.constructor.typed-dependency` | kind `reference.typescript_constructor_parameter_type_context`; field `owner_class`, `parameter_name`, `parameter_type` |
| `angular.template.input-binding` | kind `data.html_attribute_context`; field `attribute_name`, `tag` |
| `angular.template.event-binding` | kind `data.html_attribute_context`; field `attribute_name`, `tag` |
| `angular.template.structural-directive` | kind `data.html_attribute_context`; field `attribute_name`, `tag` |
| `angular.template.reference` | kind `data.html_attribute_context`; field `attribute_name`, `tag` |
| `angular.template.router-link` | kind `data.html_attribute_context`; field `attribute_name`, `tag` |
| `angular.template.element` | kind `data.html_element_text_context`; field `tag` |

## To decide when rewriting

1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6
   states the same thing? `call.target_candidate` is `call.function`;
   `structured.entry` is `definition.config_key`; a `*_context` kind is
   usually a declaration plus a join.
2. Which rules only restate their input, and should go rather than be ported?
3. Which rules are one language's spelling of something every language now
   spells the same way, and collapse into one rule?
4. Which fields are genuinely needed, and which are reachable by
   `fact_join_by_span` with `within` or by `definition.name`?
5. What does this framework actually let an agent ask that the language
   Packs alone cannot answer? That is the whole point of the overlay.
