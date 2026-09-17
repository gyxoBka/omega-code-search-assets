# omega-caddyfile

Language `omega-caddyfile`. Read `00-CONTRACT.md` first: the kind string is a protocol,
and most of what is wrong with a Pack is wrong there.

## What it states today

13 templates over 12 query patterns, 26 of the grammar's 38 named node types.

| capability | declared | templates |
|---|---|---|
| `definitions` | yes | 9 |
| `references` | yes | 4 |

### Declarations

| kind | family the host gives it | templates |
|---|---|---|
| `definition.config_site` | Config | 1 |
| `definition.config_snippet` | Config | 1 |
| `definition.config_route` | Config | 1 |
| `definition.config_matcher` | Config | 1 |
| `definition.config_matcher_condition` | Config | 1 |
| `definition.config_directive` | Config | 1 |
| `definition.config_path` | Config | 1 |

### Carriers

| kind | folds onto | as |
|---|---|---|
| `definition.parameter_shape_candidate` | the `definition.config_directive` at the same span | `omega.pack.parameter_shape` |

### Mentions

| kind | occurrence the host makes | templates |
|---|---|---|
| `relation.depends` | depends | 1 |
| `reference.route` | reference | 1 |
| `reference.matcher` | reference | 1 |
| `reference.environment` | reference | 2 |

## The boundary: what the grammar offers and the Pack ignores

The grammar names 38 node types. The Pack looks at 26 of them.

Untouched:

- `block` — the braces of a site, snippet or route. The construct that owns it
  is declared over the whole node, so the block adds no name and no extent.
- `comment`
- `duration_literal`, `status_code_fallback` — operands of a directive, reached
  as the carried first operand where they are first, not stated on their own.
- `escape_sequence`
- `global_options` — the unnamed `{ ... }` at the head of a file. It names
  nothing; the directives inside it are `directive` nodes and are declared.
- `heredoc`, `heredoc_body`, `heredoc_end`, `heredoc_start` — a response body,
  which is content rather than configuration.
- `matcher_block` — the braces of a named matcher; the conditions inside it are
  `matcher_directive` nodes and are declared.
- `source_file`

## What is wrong with it

**The Pack could not see an ordinary Caddyfile.** `site_definition` matched
`(single_site name: (site_address))` only. This grammar spells a site two ways:
`single_site` is the brace-less shorthand a file may use when it serves exactly
one site, and `site_block` is `example.com { ... }` — the form of every
multi-site file and of nearly every single-site file written in practice.
`site_block` was one of the 22 untouched node types. For the common file the
Pack declared **no site at all**, and the four `structured.entry` owner-context
templates, all of which are rooted at `single_site` or `named_route`, produced
nothing either.

**The one link Caddy has was broken at both ends.** `named_matcher_definition`
named a matcher from `matcher_name` (`api`), while `matcher_reference` was the
bare capture `(matcher_identifier) @caddy.matcher` named with the whole node
(`@api`, sigil included). A reference resolves against a declaration by name, so
`@api` could never meet `api` — the audit's D2, and the reason the Pack's
`references` capability answered nothing. The same bare capture also matched the
`matcher_identifier` **inside** `named_matcher`, so every declaration was also
emitted as a reference to itself.

**Four of the fourteen patterns were containment written out by hand.** The
`owner_context` block hard-coded `(single_site … (named_matcher …))`,
`(single_site … (directive …))`, `(named_route (block (directive …)))` and
`(named_route (block (named_matcher …)))` — one match per (site, member) pair,
to state what the tree already holds and the host already carries through the
`within:` segment. They fed four `structured.entry` templates whose whole
content was the owner's name repeated in a field.

**The same directive was stated twice, as two different sorts of fact.**
`call.directive` and `structured.entry` shared the span `@caddy.directive` and
the name `@caddy.directive.name` — the audit's K2. One arrived as a call
occurrence resolving against nothing (no Caddyfile declares `reverse_proxy`) and
the other as a plain reference, because `structured.entry` is not a relation the
host knows.

**Nothing in a Caddyfile landed in the Config family.** All four declaration
kinds — `definition.site`, `definition.route`, `definition.matcher`,
`definition.snippet` — contain no word from the host's family vocabulary, so a
web server's entire configuration was filed under Value.

**Five of the seven guards were labels.** Four read
`depth_completion_high_confidence_ast_fact`, a generator confidence tier; one
read `caddy_owner_context_for_site_matchers_and_named_route_directives`, which
names the pattern rather than a limitation. A sixth described the provenance of
the query file ("observed in an exact-revision Helix grammar snapshot") rather
than anything the language cannot say.

**Two of the twelve query sections were empty.** `external-helix-locals` and
`helix_independent_structural` contained only provenance comments — a
nvim/helix baseline header over no patterns.

**`scope.block` was a region over every brace pair.** A block is the body of
the site, snippet, route or directive that owns it, and that owner is now
declared over the whole node — the region was the same bytes under no name, and
the `scopes` capability existed for it alone.

**Placeholders and environment variables were emitted verbatim.**
`reference.environment` was named `{$DOMAIN}` and `reference.placeholder`
`{http.request.uri}`, braces and sigils included, so neither could resolve onto
anything, and `{env.DOMAIN}` — the other spelling of the same variable — was
indistinguishable from a request placeholder.

Counted: 13 templates, 14 patterns, 7 guards; 16 of 38 node types touched;
5 label guards, 1 D2, 1 K2, 4 containment patterns, 4 kinds in the wrong family,
2 empty sections, and 5 declared capabilities where 2 are programmed.

## What it should extract

A Caddyfile is the whole configuration of a web server. The questions asked of
one are: what is served at this address, where does this path go, what does this
matcher select, where is this snippet defined and who imports it, and which
environment variables the deployment must supply.

| what | node | emitted as | family |
|---|---|---|---|
| a site, braced or not | `site_block`, `single_site` via `site_address` | `definition.config_site` | Config |
| a snippet | `snippet_definition` via `snippet_name` | `definition.config_snippet` | Config |
| `import name` / `import glob` | `directive` named `import`, first `argument` | `relation.depends` | depends occurrence |
| a named route | `named_route` via `named_route_identifier` | `definition.config_route` | Config |
| `invoke name` | `directive` named `invoke`, first `argument` | `reference.route` | reference |
| a named matcher | `named_matcher` via `matcher_identifier name:` | `definition.config_matcher` | Config |
| a use of one | `matcher` via `matcher_identifier name:` | `reference.matcher` | reference |
| an inline path matcher | `matcher` via `path_matcher` | `definition.config_path` | Config |
| what a matcher tests | `matcher_directive` via `matcher_directive_name` | `definition.config_matcher_condition`, operand as an attribute | Config |
| a directive | `directive` via `directive_name` | `definition.config_directive` | Config |
| its first operand | `directive`, first `argument` | `definition.parameter_shape_candidate` carrier | `omega.pack.parameter_shape` |
| `{$NAME}` | `environment_variable` | `reference.environment` | reference |
| `{env.NAME}` | `placeholder`, filtered by `#match?` | `reference.environment` | reference |
| any other placeholder | `placeholder` | nothing | — |
| a block, the global options block, a heredoc body, comments | `block`, `global_options`, `heredoc*`, `comment` | nothing | — |

Both matcher spellings take the name from the `name:` field, so `@api` at the
use site and `api` at the declaration are one name and the reference resolves.
`{$DOMAIN}` and `{env.DOMAIN}` are both reduced to `DOMAIN`, so the two
spellings of one variable resolve to each other and onto whatever declares it
elsewhere in the repository. A named route's identifier and a snippet's name are
stripped of `&(`, `(` and `)` defensively: `strip_prefix` returns its input
unchanged when the affix is absent, so the chain is correct whether or not the
grammar includes the punctuation in the token.

A site's `name:` field is repeated — `example.com, www.example.com { ... }` — so
the site pattern matches once per address and the site is declared under each
name it answers to. That is what a multi-address site means, and it is the only
place this Pack emits more than one declaration at one span.

**A directive is a declaration, not a call.** Caddy's directive names are built
into the server; no Caddyfile declares `reverse_proxy`, so a `call.directive`
occurrence resolves against nothing forever. Declaring the directive at the point
of use in the Config family makes "where is `tls` configured in this repository"
answerable, which is the question actually asked.

## Still to decide

1. **The first operand is a carrier, and the audit reports it as one that may
   overwrite itself.** `argument` repeats inside `directive`, so
   `carrier_owner = 1` is reported and is right to report in general. Here the
   capture is anchored to the child immediately after the name, so exactly one
   operand binds per match; the audit cannot see an anchor. It is left as the one
   non-zero class, for the same reason the modifier-grouping false positives are
   left in omega-typescript. The alternative — putting the operand in the
   declaration's `attributes` — would make every argument-less directive
   (`file_server`, `templates`, `metrics`) skip its own declaration, because a
   template whose attribute references an unbound capture is skipped entirely.
2. **Only the first operand is carried.** `reverse_proxy a:80 b:80` records one
   upstream. Capturing the rest means either a quantified capture, whose
   evaluation is not specified for `capture_ref`, or a pattern per arity. A guard
   states the limit.
3. **A directive nested in a directive's block is declared like any other.**
   `header_up` inside `reverse_proxy { ... }` becomes a `definition.config_directive`
   named `header_up`, inside the outer directive's span. That is right for
   retrieval — it is where `header_up` is configured — but it means the Config
   family holds one declaration per configuration line of the file. That is the
   same trade omega-json and omega-toml made for a key, and it is taken here for
   the same reason.

## A cross-asset consequence: omega-framework-caddyfile

`frameworks/omega-framework-caddyfile/semantic-v2.json` matches on this Pack's
old kind strings. Three of its rules key on `definition.site`,
`definition.route` and `definition.matcher`, which are now
`definition.config_site`, `definition.config_route` and
`definition.config_matcher`; the rest key on `fact_kind = structured.entry`
together with `attribute_equals role = caddy_site_matcher` /
`caddy_site_directive` and the fields `site`, `matcher`, `directive_name`,
`upstream`.

The `role` attribute was a constant attribute and was removed from this Pack by
the repository-wide sweep before this rewrite, so **those rules already matched
nothing**. The `structured.entry` templates they read were the four
containment patterns described above: Defect E written into a cross-asset
contract, exactly as `00-INDEX.md` records for omega-json in wave 6. They are
not restored. The overlay has to be rewritten against the new declarations —
a directive's owning site is carried by the host's `within:` segment, which is
the same information without a pattern per pair. Nothing in the engine reads
`required_packs` or `required_capabilities`, so the overlay's manifest does not
fail validation; its rules simply match nothing until it is rewritten.
