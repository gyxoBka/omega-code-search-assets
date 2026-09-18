# omega-framework-symfony

Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing
else, so a rule lives or dies by whether a Pack still emits its fact kind.

Selector: `framework:symfony`. Maturity: `semantic-overlay-full`.
Packs read: `omega-php`, `omega-twig`, `omega-yaml`.

## Audit history

| pass | rules | live | dead |
|---|---|---|---|
| as found | 20 | 1 | 19 |
| first rewrite | 10 | 10 | 0 |
| call-view wave | 12 | 12 | 0 |
| attribute-argument wave (this one) | 16 | 16 | 0 |

`python pack-design/key_collisions.py symfony` reports nothing at every pass
from the first rewrite on.

## What was wrong with it

### The original 20 rules (first rewrite)

**20 rules, 1 live.** 19 of the 20 could not match any emission any Pack makes.

**Sixteen rules were one construct spelled sixteen times.** `symfony.attribute.route`,
`.isgranted`, `.cache`, `.maprequestpayload`, `.mapquerystring`, `.autowire`,
`.required`, `.ascommand`, `.aseventlistener`, `.mapuploadedfile`, `.currentuser`,
`.autoconfigure`, `.autoconfiguretag`, `.taggediterator` and `.target` were
byte-identical apart from one string in a `member_in` list of length 1 and the same
string repeated in the canonical key. They are now `field_in` over a list.

**Fifteen of those sixteen matched `call.target_candidate`.** A PHP attribute is not a
call, and `call.target_candidate` is a carrier the host never folded; no Pack has
emitted it since the language-Pack rewrite. omega-php states an attribute as
`reference.attribute`, spanning the `#[...]` node, named by the attribute's last
qualified segment.

**All sixteen also carried an unreachable `external_path_matches`.** They named PHP
namespaces such as `Symfony\Component\HttpKernel\Attribute` as if they were packages.
omega-php publishes no `qualifier`, so `external` is `None` on every PHP fact and all
16 clauses were false regardless of the kind.

**Three rules matched kinds invented for one language's AST shape** --
`definition.php_attributed_method_route_context` (2) and
`reference.php_constructor_parameter_type_context` (1). **Five fields were read that
no Pack publishes**: `attribute_name`, `route`, `parameter_type`, `owner_class`,
`method_name`, `parameter_name`. **`symfony.twig-template`** matched
`data.twig_template`, which nothing emits, and restated its own input.
**`symfony.generic-api-call.symfony-symfony`** emitted `uses_api` from an entity to
itself. **The one live rule emitted a self-loop**, because `path` is a published field
on `import.twig_path` and shadowed the `path` built-in, so both ends of its `includes`
edge rendered the same key.

### The call-view wave (10 -> 12)

One `coverage.gaps` sentence had gone stale: it claimed `symfony:template-name:*` and
`symfony:template:*` were "two key spaces only a resolver over the Twig loader roots
could join". `fact_join_by_field` takes a `join_strip_prefix`, the host pushes a
synthetic `data.file` fact carrying `path` for every artifact (`overlay.rs:41`), and
Symfony's default Twig root is the literal segment `templates/`. Two rules were added
that verify the file exists rather than asserting a convention.

### What this wave found wrong (12 -> 16)

**The headline gap of the last two passes is closed, and its `.md` section was wrong
the day the Pack changed.** Both previous passes recorded, under "A field only the Pack
can supply", that `#[Route('/orders/{id}')]`'s argument list "is captured by nothing
and published in no field", and that "omega-php emits nothing at all inside an
attribute's argument list -- there is no fact under that span to join to". Measured
today with `dump_call_emissions` on `packs/omega-php` + `grammars/omega-php`:

```
279-338  reference.attribute          name=Route
279-338  reference.attribute_applied  name=Route  call.arg0="'/orders/{id}'"
                                      call.arg0_text=/orders/{id}
                                      call.arg1=name: 'order_show'
                                      call.last_arg=methods: ['GET']
```

`reference.attribute_applied` is a second emission on **exactly the same span** as
`reference.attribute`, read with `fact_join_by_span` `relation: "same"`. Three of the
seven `coverage.gaps` entries were assertions that this could not exist; all three are
deleted. **Four rules added.**

**A second stale gap: `definition.config_key`'s scalar is a field now, not an
attribute.** The old gap said "omega-yaml publishes a `definition.config_key`'s value
as an *attribute*, which is write-only, so a YAML route could never be linked to the
class it names". Measured on a `config/routes.yaml`:

```
39-87  definition.config_key  name=controller  value="App\Controller\OrderController::show"
16-34  definition.config_key  name=path        value="/orders/{id}"
```

`value` is a field: it can be a canonical key, a relation end and a join key. What
remains true is narrower and is restated in `coverage.gaps`: the controller is a
fully qualified name and no Pack says which artifact declares a given FQCN.

**Four rule ids were renamed, because ids decide which attributes survive.**
`symfony.action.attribute` sorted before `symfony.controller.action`, so on any action
carrying both an `#[IsGranted]` and a `#[Route]` the Handler entity materialized from
the attribute rule and `route_attribute` was computed and discarded (brief 3g). Adding
a rule that carries the *route itself* made that ordering load-bearing. The four rules
that mint `symfony:handler:*` now sort so that the one with the most to say is first:

| order | id | was |
|---|---|---|
| 1 | `symfony.action.route` | new -- carries `route` |
| 2 | `symfony.action.route-declared` | `symfony.controller.action` |
| 3 | `symfony.action.template` | new |
| 4 | `symfony.attribute.on-action` | `symfony.action.attribute` |

and the three that mint `symfony:attribute:*` sort `symfony.attribute.argument` first,
ahead of `symfony.attribute.on-action` and `symfony.attribute.on-class` (was
`symfony.service.attribute`), so the argument text is the version that survives. The
ids are referenced by nothing outside this file (checked by grep across both
repositories).

## What it states now

The hub is the PHP class, `symfony:class:{file.path}:{Class}`, minted by every rule
that has a class in hand. **Every relation end below is minted by the rule that emits
the relation**, so no key dangles.

| what it answers | which Pack fact | entity / relation |
|---|---|---|
| **which URL an action serves** -- `GET /orders/{id}` | omega-php `reference.attribute` named `Route`/`Get`/`Post`/`Put`/`Patch`/`Delete`/`Head`/`Options`, joined `same`-span to `reference.attribute_applied` (bind `args`) whose `call.arg0_text` starts with `/`, and `within` `definition.method` (bind `action`) and `definition.class` (bind `cls`) | `Route` `symfony:route:{normalized_route}`, `Handler` `symfony:handler:{file.path}:{Class}:{Method}` carrying `route`, `SymfonyClass`; relations `serves` Handler -> Route and `handles` SymfonyClass -> Handler |
| which methods of which class are HTTP entry points at all, including `#[Route]` bare and `#[Route(path: '/x')]` | the same attribute fact with no argument join | `Handler`, `SymfonyClass`, relation `handles` |
| **which template an action renders** | omega-php `reference.attribute` named `Template`, joined `same`-span to `reference.attribute_applied` (bind `tmpl`) with a non-empty `call.arg0_text` that is not the `template:` named-argument spelling, plus the method and class joins | `Handler`, `Template` `symfony:template-name:{tmpl.call.arg0_text}`, relation `renders` -- and that name resolves on to the artifact through `resolves_to` below |
| **what a Symfony attribute was given** -- the role in `#[IsGranted('ROLE_ADMIN')]`, the service in `#[Autowire('@mailer')]`, the alias in `#[AsAlias('x')]` | `reference.attribute` in the union of the two attribute lists, joined `same`-span to `reference.attribute_applied`, `within` `definition.class` | `FrameworkAttribute` `symfony:attribute:{file.path}:{start}:{Name}` carrying `argument`, `SymfonyClass`, relation `configured_by` |
| which actions are secured, cached, templated, or take a deserialized payload / query string / uploaded file / the current user | `reference.attribute`, `field_in` the 16 action-level Symfony attributes, method and class span joins | `FrameworkAttribute`, `Handler`, relation `configured_by` Handler -> FrameworkAttribute |
| which classes are console commands, event listeners, message handlers, decorators, tagged services, Twig components, or explicitly wired | `reference.attribute`, `field_in` the 32 class- and parameter-level Symfony attributes, class span join only | `FrameworkAttribute`, `SymfonyClass`, relation `configured_by` SymfonyClass -> FrameworkAttribute |
| which classes are built on a Symfony base class or contract -- `AbstractController`, `Command`, `AbstractType`, `EventSubscriberInterface`, `VoterInterface`, `UserInterface`, 42 in all | omega-php `relation.implements` (it states `extends`, `implements` and a trait `use` alike), `field_in` the contract list, joined `within` `definition.class` | `SymfonyClass`, `SymfonyContract` `symfony:contract:{Name}`, relation `implements` |
| which services a class receives by constructor injection | omega-php `type_use.name` joined `within` a `definition.method` named `__construct`, and `within` `definition.class` | `ServiceDependency` `symfony:dependency:{file.path}:{Class}:{Type}`, `SymfonyClass`, relation `injects` |
| **which routes `config/routes*.yaml` declares, and which controller each names** | omega-yaml `definition.config_key` named `controller` with a `value`, under a `**/config/routes**` glob, joined by `definition.container` (the route name) to its sibling `definition.config_key` named `path` (bind `routepath`) | `Route` `symfony:route:{normalized_route}` carrying `route_name` and `controller`, `SymfonyControllerRef` `symfony:controller-ref:{value}`, relation `serves` |
| which template a template extends, includes, embeds or uses | omega-twig `relation.depends`, field `path` | `Template` `symfony:template:{file.path}`, `Template` `symfony:template-name:{path}`, relation `includes` |
| which template a template imports macros from | omega-twig `import.twig_path`, field `path` | the same two `Template` keys, relation `includes` |
| which file a Twig name actually is -- `base.html.twig` -> `templates/base.html.twig` | omega-twig `relation.depends` field `path`, joined by field to the host's synthetic `data.file` (bind `tpl`) with `join_strip_prefix: "templates/"` and a `where` of `path_glob templates/**` | `Template` `symfony:template-name:{path}`, `Template` `symfony:template:{tpl.path}`, relation `resolves_to` |
| the same for the source of a macro import | omega-twig `import.twig_path`, the same `data.file` join | the same two `Template` keys, relation `resolves_to` |
| which macro a template takes, and from which template | omega-twig `import.symbol` joined `same`-span with `import.twig_path` (bind `src`) -- both span the whole `{% from ... import ... %}` | `TemplateMacro` `symfony:macro:{src.path}:{Name}`, `Template`, relation `uses_macro` |
| which blocks a template offers a child to override | omega-twig `definition.template_block` | `TemplateBlock` `symfony:block:{file.path}:{Name}`, `Template`, relation `defines` |
| which macros a template declares | omega-twig `definition.macro_function` | `TemplateMacro` `symfony:macro-definition:{file.path}:{Name}`, `Template`, relation `defines` |

Every span join carries `same_path: true`. `JoinBySpan` defaults `same_path` to
`false`, so without it a span join matches facts in other files whose byte offsets
happen to nest.

`symfony:route:{normalized_route}` is minted by two rules, both with kind `Route`:
the attribute rule and the YAML rule. `normalize_http_path` turns `/orders/{id}` into
`/orders/{}`, which is the same identity other HTTP Frameworks in this repository
render for `/orders/:id` and `/orders/[id]`.

## A field only the Pack can supply

**omega-php, `call.function` / `call.method` / `call.static_method` /
`call.constructor`: the canonical call view.**

`$this->render('order/show.html.twig')` is the other place a Symfony controller names
a template, and `$this->redirectToRoute('order_show')` is where it names a route.
Both arrive as `call.method` with the name only: measured today, all five of
omega-php's call templates carry `"fields": {}`, so `call.arg0_text`, `call.arg1_text`,
`call.last_arg_name` and `receiver` do not exist in PHP.

Neither cheaper route reaches it. No built-in name answers it -- `definition.name` is
`render`, and `path`, `path.dir`, `path.stem`, `source.start`/`end`, `enclosing.name`
and `external.*` are all about where the call sits. A join cannot reach it either:
omega-php emits no fact for a string literal, so there is nothing under the argument's
span to bind. The fix is the same one the Pack has now applied to
`reference.attribute_applied` -- a second emission carrying `ordered_children` of the
argument list -- which is why this is reported as a general omega-php gap, not a
Symfony-only field: it would close `Handler -renders-> Template` here and the
equivalent question in every other PHP Framework.

## Still to decide

**A class-level `#[Route('/prefix')]` is not concatenated.** Symfony prefixes every
action's path with the class attribute's path. `symfony.action.route` requires the
`within definition.method` join, so the class-level attribute never mints a Route of
its own -- but it also means an action written `#[Route('/{id}')]` inside a
`#[Route('/orders')]` controller keys as `symfony:route:/{}` rather than
`symfony:route:/orders/{}`. The overlay has no clause for "not inside a method" and no
way to concatenate two values, and minting a wrong global key would be worse than
minting a partial one, so the Route is the path as written at the action. The
`route_attribute` and `controller` attributes on the Handler say which class it sits
in, so the prefix is recoverable by a reader even where the key is not.

**`#[Route(path: '/x')]` is stated as routed but without its URL.** The named-argument
spelling puts the text `path: '/x'` in `call.arg0_text`, which is not a path. Rather
than strip a second prefix in a canonical key (which has no strip at all),
`symfony.action.route` guards on `field_prefix call.arg0_text = "/"` and
`symfony.action.route-declared` -- which carries no argument join -- states what is
left. This is the two-rule shape brief 3l prescribes: the literal one states the
value, the other states what it can. The same applies to `#[AsCommand(name: 'app:x')]`,
which is why no Command entity is minted: the positional spelling
`#[AsCommand('app:x')]` is legal but the documented one is the named argument, and a
rule for the positional form alone would advertise a command inventory that is mostly
empty.

**`symfony.attribute.argument` relates to the class, not to the method.** It is the
rule that puts `argument` on the `FrameworkAttribute` hub, and it sorts first so its
attributes are the ones that survive interning. Its own `configured_by` edge is at
class granularity even when the attribute sits on a method. The finer
`Handler -configured_by-> FrameworkAttribute` edge is emitted by
`symfony.attribute.on-action` where it applies; the class-level edge is kept so that an
attribute used at a level neither placement rule covers -- `#[IsGranted]` on a class,
which is legal -- still reaches the graph instead of becoming an orphan entity.

**Twig namespaces and bundle roots.** `resolves_to` covers the default `templates/`
root only. A reference written `@Admin/list.html.twig`, or one resolved against a root
added by `twig.yaml`'s `paths:`, still lands in `symfony:template-name:*` with no
artifact behind it. The unresolved `includes` edge is kept for exactly this case.

**`symfony:template-name:*` deliberately survives the resolution.** Pointing
`includes` straight at `symfony:template:{tpl.path}` would make every Twig reference
conditional on the join succeeding and silently delete every bundle-namespaced
include. Keeping the name as a hop --
`Template -includes-> TemplateName -resolves_to-> Template` -- costs one edge and loses
nothing. `#[Template('x.html.twig')]` mints into the same name space, so an action's
template resolves to a file through the same hop.

**`SymfonyControllerRef` is a separate key space on purpose.** `config/routes.yaml`
names its controller as `App\Controller\OrderController::show`. The PHP hub is keyed
`symfony:class:{file.path}:{Class}`, and no Pack states which artifact declares a given
fully qualified name, so the two cannot meet. `current_strip_prefix` strips one literal
and the namespace is not one. The reference is stated as its own entity rather than
pointed at a class key no rule mints.

**`AsEventListener`, `AsMessageHandler`, `AsCronTask`, `AsPeriodicTask` and `Required`
appear in both placement lists.** They are legal on a class and on a method, and the
two rules join differently, so the method-level spelling emits both
`Handler -configured_by-> FrameworkAttribute` and
`SymfonyClass -configured_by-> FrameworkAttribute` against the same attribute entity.
Both statements are true and the duplication is intentional; the alternative is a
"not within a method" clause, which the overlay has no way to express.
