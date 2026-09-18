# omega-framework-symfony

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

## State as found (the diagnosis this rewrite acted on)

20 overlay rules, 4 detection rules. **1 can match, 19 cannot.**
After the rewrite: **10 overlay rules, 4 detection rules -- 10 live, 0 cannot match.**

Selector: `framework:symfony`. Maturity: `semantic-overlay-full`.

### Entities it declares

| entity_kind | rules |
|---|---|
| `FrameworkAttribute` | 15 |
| `Template` | 3 |
| `Controller` | 1 |
| `Handler` | 1 |
| `Route` | 1 |
| `ApiUse` | 1 |
| `ServiceDependency` | 1 |

### Relations it declares

| relation_kind | rules |
|---|---|
| `configured_by` | 15 |
| `handles` | 1 |
| `includes` | 1 |
| `uses_api` | 1 |
| `injects` | 1 |

### Fact kinds it matches

| kind | rules | a Pack emits it |
|---|---|---|
| `call.target_candidate` | 15 | **no** |
| `definition.php_attributed_method_route_context` | 2 | **no** |
| `data.twig_template` | 1 | **no** |
| `import.twig_path` | 1 | yes |
| `reference.php_constructor_parameter_type_context` | 1 | **no** |

Clause vocabulary in use: `fact_kind` x20, `external_path_matches` x16, `field_present` x12, `path_glob` x3, `field_in` x1.

Fields read: `source.start`, `attribute_name`, `route`, `path`, `parameter_type`.

Path globs: `**/*.twig`, `**/*.php`.

## Why a rule cannot match

| rule | what no Pack emits |
|---|---|
| `symfony.route-attribute` | kind `definition.php_attributed_method_route_context`; field `attribute_name`, `route` |
| `symfony.twig-template` | kind `data.twig_template` |
| `symfony.generic-api-call.symfony-symfony` | kind `call.target_candidate` |
| `symfony.constructor.di` | kind `reference.php_constructor_parameter_type_context`; field `parameter_type` |
| `symfony.attribute.route` | kind `definition.php_attributed_method_route_context` |
| `symfony.attribute.isgranted` | kind `call.target_candidate` |
| `symfony.attribute.cache` | kind `call.target_candidate` |
| `symfony.attribute.maprequestpayload` | kind `call.target_candidate` |
| `symfony.attribute.mapquerystring` | kind `call.target_candidate` |
| `symfony.attribute.autowire` | kind `call.target_candidate` |
| `symfony.attribute.required` | kind `call.target_candidate` |
| `symfony.attribute.ascommand` | kind `call.target_candidate` |
| `symfony.attribute.aseventlistener` | kind `call.target_candidate` |
| `symfony.attribute.mapuploadedfile` | kind `call.target_candidate` |
| `symfony.attribute.currentuser` | kind `call.target_candidate` |
| `symfony.attribute.autoconfigure` | kind `call.target_candidate` |
| `symfony.attribute.autoconfiguretag` | kind `call.target_candidate` |
| `symfony.attribute.taggediterator` | kind `call.target_candidate` |
| `symfony.attribute.target` | kind `call.target_candidate` |

## What was wrong with it

**20 rules, 1 live.** Measured by `pack-design/overlay_audit.py symfony` before the
rewrite, 19 of the 20 could not match any emission any Pack makes.

**Sixteen rules were one construct spelled sixteen times.** `symfony.attribute.route`,
`.isgranted`, `.cache`, `.maprequestpayload`, `.mapquerystring`, `.autowire`,
`.required`, `.ascommand`, `.aseventlistener`, `.mapuploadedfile`, `.currentuser`,
`.autoconfigure`, `.autoconfiguretag`, `.taggediterator` and `.target` were
byte-identical apart from one string in a `member_in` list of length 1 and the same
string repeated in the canonical key. They are now one `field_in` over a list, on the
one kind that states an attribute — three rules, split by *what the attribute
configures* (an action, a service class) rather than by its name.

**Fifteen of those sixteen matched `call.target_candidate`.** A PHP attribute is not a
call, and `call.target_candidate` is a carrier the host never folded; no Pack has
emitted it since the language-Pack rewrite. omega-php states an attribute as
`reference.attribute`, spanning the `#[...]` node, named by the attribute's last
qualified segment.

**All sixteen also carried an unreachable `external_path_matches`.** They named
packages like `Symfony\Component\HttpKernel\Attribute` — a PHP namespace, not a
package. `external` is set only when a Pack resolves an import to an external
package, and omega-php publishes no `qualifier`, so `external` is `None` on every PHP
fact and every one of the 16 clauses failed regardless of the kind.

**Three rules matched kinds invented for one language's AST shape.**
`definition.php_attributed_method_route_context` (2 rules) and
`reference.php_constructor_parameter_type_context` (1 rule) are the old generator's
private spellings; they are replaced by a declaration plus a `fact_join_by_span` /
`within`, which is how the overlay reaches an enclosing method or class now.

**Five fields were read that no Pack publishes**: `attribute_name`, `route`,
`parameter_type`, and — used in canonical keys without ever being matched on —
`owner_class`, `method_name`, `parameter_name`. Every key that depended on them
rendered to nothing.

**`symfony.twig-template` matched `data.twig_template`**, which nothing emits, and its
only output was a `Template` entity keyed `symfony:template:{path}` carrying the
attribute `path` = `{path}`: an entity that restated its own input with no relation.

**`symfony.generic-api-call.symfony-symfony`** minted an `ApiUse` entity keyed by file
and byte offset, then emitted `uses_api` from `current` to that same key — a self-loop
from the entity to itself, dead twice over.

**The one live rule, `symfony.twig-import`, emitted a dangling half.** Its `includes`
relation went from `symfony:template:{path}` to `symfony:template-ref:{path}`, and
both templates rendered the *same* value, because `path` is a published field on
`import.twig_path` and a Pack field shadows the `path` built-in. So the source and the
target were one key and the edge was a self-loop. Both ends now render distinct
values: `{file.path}` for the artifact, `{path}` for the referenced Twig name.

**20 rules became 10, and all 10 are live.**

## What it states now

The hub is the PHP class, `symfony:class:{file.path}:{Class}`, minted by every rule
that has a class in hand. Every relation end below is minted by the rule that emits
the relation, so no key dangles.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| which methods of which class are HTTP entry points, and by which routing attribute | omega-php `reference.attribute` named `Route`/`Get`/`Post`/`Put`/`Patch`/`Delete`/`Head`/`Options`, joined `within` `definition.method` (bind `action`) and `within` `definition.class` (bind `cls`) | `Handler` `symfony:handler:{file.path}:{Class}:{Method}`, `SymfonyClass`, relation `handles` SymfonyClass -> Handler with `via` = the attribute name |
| which actions are secured, cached, templated, or take a deserialized payload / query string / uploaded file / the current user | same fact, `field_in` the 16 action-level Symfony attributes, same two span joins | `FrameworkAttribute` `symfony:attribute:{file.path}:{start}:{Name}`, `Handler`, relation `configured_by` Handler -> FrameworkAttribute |
| which classes are console commands, event listeners, message handlers, decorators, tagged services, Twig components, or explicitly wired | same fact, `field_in` the 32 class- and parameter-level Symfony attributes, joined `within` `definition.class` only | `FrameworkAttribute`, `SymfonyClass`, relation `configured_by` SymfonyClass -> FrameworkAttribute |
| which classes are built on a Symfony base class or contract — `AbstractController`, `Command`, `AbstractType`, `EventSubscriberInterface`, `VoterInterface`, `UserInterface`, 40 in all | omega-php `relation.implements` (it states `extends`, `implements` and a trait `use` alike), `field_in` the contract list, joined `within` `definition.class` | `SymfonyClass`, `SymfonyContract` `symfony:contract:{Name}`, relation `implements` |
| which services a class receives by constructor injection | omega-php `type_use.name` joined `within` `definition.method` whose `definition.name` is `__construct`, and `within` `definition.class` | `ServiceDependency` `symfony:dependency:{file.path}:{Class}:{Type}`, `SymfonyClass`, relation `injects` |
| which template a template extends, includes, embeds or uses | omega-twig `relation.depends`, field `path` | `Template` `symfony:template:{file.path}`, `Template` `symfony:template-name:{path}`, relation `includes` |
| which template a template imports macros from | omega-twig `import.twig_path`, field `path` | same two `Template` keys, relation `includes` |
| which macro a template takes, and from which template | omega-twig `import.symbol` joined `same`-span with `import.twig_path` (bind `src`) — both templates span the whole `{% from ... import ... %}` statement | `TemplateMacro` `symfony:macro:{src.path}:{Name}`, `Template`, relation `uses_macro` |
| which blocks a template offers a child to override | omega-twig `definition.template_block` | `TemplateBlock` `symfony:block:{file.path}:{Name}`, `Template`, relation `defines` |
| which macros a template declares | omega-twig `definition.macro_function` | `TemplateMacro` `symfony:macro-definition:{file.path}:{Name}`, `Template`, relation `defines` |

Every span join carries `same_path: true`. `JoinBySpan` defaults `same_path` to
`false`, so without it a span join matches facts in other files whose byte offsets
happen to nest.

## A field only the Pack can supply

**omega-php, `reference.attribute`, a field carrying the attribute's argument text.**

`#[Route('/orders/{id}', name: 'order_show', methods: ['GET'])]` is the one place a
Symfony project states a URL. omega-php's pattern is

```scheme
(attribute
  . [(name) (qualified_name) (relative_name)] @attribute.name) @attribute
```

so the emission's name is `Route` and its span covers the whole `#[...]`; the
`(arguments)` sibling is captured by nothing and published in no field.

Neither of the two cheaper routes reaches it. No built-in name answers it:
`definition.name` is the attribute's own name, and `path`, `path.dir`, `path.stem`,
`source.start`/`end`, `enclosing.name` and `external.*` are all about where the
attribute sits, not what it says. A join cannot reach it either: a
`fact_join_by_span` can only bind another *emission*, and omega-php emits nothing at
all inside an attribute's argument list — a string literal is not a fact, and
`(#[Route('/x')])` produces exactly one emission. There is no fact under that span to
join to.

Without it this overlay can say *this method is a routed action* but not *this method
serves `GET /orders/{id}`*, which is the question the framework exists to answer.
`reference.attribute` is emitted by one template in one Pack, so the byte cost is
confined to PHP files that actually use attributes.

The same shape blocks the second question: `$this->render('order/show.html.twig')`
arrives as `call.method` named `render` with no argument text, so *which template does
this controller render* cannot be stated. That one is a general
"first-string-argument of a call" gap rather than a Symfony one, and it is the same
`call.<lang>_string_arg_context` family the Pack rewrite removed; it is noted here
rather than claimed as a Symfony-only field.

## Still to decide

**Two template key spaces that nothing joins.** A Twig reference is a logical name
(`base.html.twig`), resolved at runtime against the Twig loader's roots
(`templates/`, plus each bundle's `Resources/views`). The artifact is a project path
(`templates/base.html.twig`). `symfony:template-name:{path}` and
`symfony:template:{file.path}` are therefore two distinct key spaces, and
`Template -includes-> Template` currently always lands in the second space. Closing it
needs either a host-side path resolver or a convention rule
(`templates/{name}`), and a convention rule would be the overlay asserting a fact no
Pack stated. Left open deliberately; `symfony.template.macro-use` and
`symfony.template.macro-definition` are split for the same reason and are not joined
to each other.

**Routing declared in YAML is not read.** `config/routes.yaml` reaches the graph as
omega-yaml `definition.config_key`, and a rule over it could state a `Route` with a
real path — but its `controller:` value is published as an *attribute*, not a field
(`00-INDEX.md`, wave 1), and an attribute is write-only, so the route could not be
linked to the class it names. Deferred until that Pack change lands.

**`AsEventListener`, `AsMessageHandler`, `AsCronTask`, `AsPeriodicTask` and `Required`
appear in both attribute lists.** They are legal on a class and on a method, and the
two rules join differently, so the method-level spelling emits both
`Handler -configured_by-> FrameworkAttribute` and
`SymfonyClass -configured_by-> FrameworkAttribute` against the same attribute entity.
Both statements are true and the duplication is intentional; the alternative is a
"not within a method" clause, which the overlay has no way to express.
