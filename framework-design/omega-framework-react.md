# omega-framework-react

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

35 overlay rules, 4 detection rules. **1 can match, 34 cannot.**

Selector: `framework:react`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `ComponentWrapper` | 8 |
| `Component` | 4 |
| `ContextFactory` | 4 |
| `LazyComponent` | 4 |
| `Hook` | 3 |
| `ComponentReference` | 3 |
| `PropBinding` | 2 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `ContextReference` | 1 |
| `HookDependency` | 1 |
| `EventBinding` | 1 |
| `HandlerReference` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `renders` | 4 |
| `depends_on` | 2 |
| `declares_props` | 2 |
| `calls` | 1 |
| `uses_api` | 1 |
| `consumes_context` | 1 |
| `references_handler` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.ecmascript_member_identifier_context` | 12 | **no** |
| `call.direct` | 5 | **no** |
| `definition.function` | 4 | yes |
| `import.ecmascript_commonjs_binding_context` | 4 | **no** |
| `import.ecmascript_namespace_binding_context` | 4 | **no** |
| `import.ecmascript_default_binding_context` | 4 | **no** |
| `import.ecmascript_named_binding_context` | 3 | **no** |
| `reference.javascript_function_return_jsx_component_context` | 2 | **no** |
| `definition.javascript_arrow_jsx_component_context` | 2 | **no** |
| `reference.javascript_arrow_return_jsx_component_context` | 2 | **no** |
| `reference.javascript_jsx_identifier_attribute_context` | 2 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.ecmascript_class_extends_identifier_context` | 1 | **no** |
| `reference.ecmascript_class_extends_member_context` | 1 | **no** |
| `call.ecmascript_direct_identifier_argument_context` | 1 | **no** |
| `call.ecmascript_direct_dependency_array_identifier_context` | 1 | **no** |
| `value.javascript_jsx_string_attribute_context` | 1 | **no** |
| `reference.javascript_jsx_member_tag` | 1 | **no** |

Clause vocabulary in use: `field_present` x59, `fact_kind` x35, `field_equals` x30, `fact_join_by_field` x17, `(join)` x17, `path_glob` x12, `external_path_matches` x10, `field_prefix` x3, `field_in` x2, `field_not_prefix` x2, `attribute_equals` x1.

Fields read: `module_source`, `member`, `object`, `arg0`, `owner_function`, `source.start`, `child_component`, `attribute_name`, `operator`, `class_name`, `definition.name`, `attribute_identifier`, `path`, `definition.qname`, `superclass`, `imported_name`, `superclass_object`, `superclass_member`, `arg1`, `dependency`.

Path globs: `**/*.{js,jsx,ts,mjs,cjs,mts,cts}`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `react.hook.call` | kind `call.direct` |
| `react.component.definition` | attribute `name_style` |
| `react.javascript.direct-jsx-component-render` | kind `reference.javascript_function_return_jsx_component_context`; field `child_component`, `definition.qname`, `owner_function` |
| `react.generic-api-call.react` | kind `call.target_candidate` |
| `react.generic-dependency.react` | kind `import.target_candidate` |
| `react.javascript.arrow-jsx-component` | kind `definition.javascript_arrow_jsx_component_context`; field `owner_function` |
| `react.javascript.arrow-jsx-same-file-render` | kind `reference.javascript_arrow_return_jsx_component_context`; field `child_component`, `owner_function` |
| `react.javascript.imported-render.javascript_function_return_jsx_component_context` | kind `import.ecmascript_named_binding_context`, `reference.javascript_function_return_jsx_component_context`; field `child_component`, `module_source`, `owner_function` |
| `react.javascript.imported-render.javascript_arrow_return_jsx_component_context` | kind `import.ecmascript_named_binding_context`, `reference.javascript_arrow_return_jsx_component_context`; field `child_component`, `module_source`, `owner_function` |
| `react.class-component.imported-base` | kind `import.ecmascript_named_binding_context`, `reference.ecmascript_class_extends_identifier_context`; field `class_name`, `imported_name`, `module_source`, `superclass` |
| `react.class-component.react-member-base` | kind `reference.ecmascript_class_extends_member_context`; field `class_name`, `superclass_member`, `superclass_object` |
| `react.custom-hook.definition-javascript_arrow_jsx_component_context` | kind `definition.javascript_arrow_jsx_component_context`; field `owner_function` |
| `react.useContext.identifier` | kind `call.ecmascript_direct_identifier_argument_context`; field `arg1` |
| `react.hook.dependency-array` | kind `call.ecmascript_direct_dependency_array_identifier_context`; field `dependency` |
| `react.javascript.jsx-identifier-prop` | kind `reference.javascript_jsx_identifier_attribute_context`; field `attribute_identifier`, `attribute_name`, `child_component`, `owner_function` |
| `react.javascript.jsx-string-prop` | kind `value.javascript_jsx_string_attribute_context`; field `attribute_name`, `attribute_value`, `owner_function` |
| `react.javascript.jsx-event-handler-reference` | kind `reference.javascript_jsx_identifier_attribute_context`; field `attribute_identifier`, `attribute_name` |
| `react.javascript.jsx-member-component-reference` | kind `reference.javascript_jsx_member_tag`; field `tag` |
| `react.createContext.call` | kind `call.direct` |
| `react.memo.call` | kind `call.direct` |
| `react.forwardRef.call` | kind `call.direct` |
| `react.lazy.call` | kind `call.direct` |
| `react.createContext.member-commonjs-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `member`, `module_source`, `object`, `operator` |
| `react.createContext.member-namespace-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.createContext.member-default-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.memo.member-commonjs-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `member`, `module_source`, `object`, `operator` |
| `react.memo.member-namespace-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.memo.member-default-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.forwardRef.member-commonjs-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `member`, `module_source`, `object`, `operator` |
| `react.forwardRef.member-namespace-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.forwardRef.member-default-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.lazy.member-commonjs-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_commonjs_binding_context`; field `arg0`, `member`, `module_source`, `object`, `operator` |
| `react.lazy.member-namespace-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_namespace_binding_context`; field `arg0`, `member`, `module_source`, `object` |
| `react.lazy.member-default-root` | kind `call.ecmascript_member_identifier_context`, `import.ecmascript_default_binding_context`; field `arg0`, `member`, `module_source`, `object` |

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
