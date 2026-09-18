# omega-framework-nestjs

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State

31 overlay rules, 4 detection rules. **12 can match, 19 cannot.**

Selector: `framework:nestjs`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `RequestBinding` | 11 |
| `Controller` | 1 |
| `Route` | 1 |
| `Handler` | 1 |
| `Service` | 1 |
| `Module` | 1 |
| `ApiUse` | 1 |
| `Dependency` | 1 |
| `GuardBinding` | 1 |
| `InterceptorBinding` | 1 |
| `PipeBinding` | 1 |
| `FilterBinding` | 1 |
| `Gateway` | 1 |
| `ExceptionFilter` | 1 |
| `Provider` | 1 |
| `ControllerReference` | 1 |
| `Export` | 1 |
| `ModuleReference` | 1 |
| `InjectionPoint` | 1 |
| `MessageHandler` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 17 |
| `depends_on` | 3 |
| `handles` | 2 |
| `injects` | 2 |
| `contains` | 2 |
| `uses_api` | 1 |
| `exports` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `reference.decorator` | 15 | yes |
| `import.ecmascript_named_binding_context` | 15 | **no** |
| `reference.typescript_method_parameter_decorator_context` | 11 | **no** |
| `reference.typescript_class_decorator_object_array_identifier_context` | 5 | **no** |
| `call.target_candidate` | 1 | **no** |
| `import.target_candidate` | 1 | **no** |
| `reference.typescript_constructor_parameter_type_context` | 1 | **no** |

Clause vocabulary in use: `field_equals` x51, `fact_kind` x31, `fact_join_by_field` x18, `(join)` x18, `external_path_matches` x17, `field_present` x14.

Fields read: `decorator_name`, `module_source`, `imported_name`, `definition.name`, `field_name`, `definition.qname`, `source.start`, `source.path`, `owner_class`, `item_identifier`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `nestjs.module.explicit-imports-dependency` | kind `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `definition.qname`, `field_name`, `item_identifier`, `owner_class` |
| `nestjs.generic-api-call.nestjs-core` | kind `call.target_candidate` |
| `nestjs.generic-dependency.nestjs-core` | kind `import.target_candidate` |
| `nestjs.module.providers` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source` |
| `nestjs.module.controllers` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source` |
| `nestjs.module.exports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source` |
| `nestjs.module.imports` | kind `import.ecmascript_named_binding_context`, `reference.typescript_class_decorator_object_array_identifier_context`; field `decorator_name`, `field_name`, `imported_name`, `module_source` |
| `nestjs.constructor.typed-dependency` | kind `reference.typescript_constructor_parameter_type_context` |
| `nestjs.param.param` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.query` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.body` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.headers` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.req` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.res` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.session` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.ip` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.hostparam` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.uploadedfile` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |
| `nestjs.param.uploadedfiles` | kind `import.ecmascript_named_binding_context`, `reference.typescript_method_parameter_decorator_context`; field `decorator_name`, `imported_name`, `module_source` |

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
