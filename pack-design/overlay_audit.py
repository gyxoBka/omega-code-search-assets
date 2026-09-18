"""What each framework overlay matches, and whether any Pack still emits it.

    python pack-design/overlay_audit.py            # every framework
    python pack-design/overlay_audit.py react      # one

The overlay matches Pack emissions directly -- an OverlayFact is a kind, a path,
a span, a name, a field map and an attribute map -- so a framework rule is alive
only while some language Pack still emits that kind with those fields. This
reads both sides and reports the rules that can no longer match.
"""
import collections
import json
import os
import sys

PACKS = 'packs'
# Names a fact answers with no published field at all (overlay.rs OverlayFact::field)
BUILTIN = {'path', 'file.path', 'source.path', 'path.value', 'path.dir', 'path.stem',
           'source.start', 'source.end', 'row_kind',
           'definition.name', 'enclosing.name', 'external.package', 'external.member',
           # Synthesized by the host on every fact from the nesting of the
           # definition facts in the same file (overlay.rs:1233-1249), so they
           # are answerable whatever the Pack publishes -- and they are the
           # cheapest ancestor chain a rule can ask for.
           'enclosing.qname', 'definition.container', 'definition.qname'}
FRAMEWORKS = 'frameworks'


_SURFACES = {}


def pack_surface(only=None):
    """kind -> what the Packs emit under it: field names, attribute names.

    `only` restricts the surface to one framework's `host.required_packs`. A
    rule is alive only if the Pack of the language it runs on emits its kind:
    `call.member` is emitted by omega-c and omega-cpp and by no JavaScript
    Pack, so a Node framework matching it matches nothing however many other
    Packs in the repository do emit it.
    """
    key = None if only is None else frozenset(only)
    if key in _SURFACES:
        return _SURFACES[key]
    fields = collections.defaultdict(set)
    attrs = collections.defaultdict(set)
    kinds = set()
    for p in sorted(os.listdir(PACKS)):
        if only is not None and p not in only:
            continue
        rp = os.path.join(PACKS, p, 'rules.json')
        if not os.path.exists(rp):
            continue
        for t in json.load(open(rp, encoding='utf-8')).get('templates', []):
            k = t['output_kind']
            kinds.add(k)
            fields[k] |= set((t.get('fields') or {}).keys())
            attrs[k] |= set((t.get('attributes') or {}).keys())
    # The host pushes one synthetic fact per artifact before any Pack emission
    # (OverlayFact::artifact, overlay.rs:41). It is how a file-shaped rule --
    # file-based routing, a migration, a manifest -- addresses the file itself.
    kinds.add('data.file')
    fields['data.file'] |= {'path'}
    _SURFACES[key] = (kinds, fields, attrs)
    return kinds, fields, attrs


_QUALIFIER = set()


def qualifier_publishers():
    """Packs that publish a field or attribute named `qualifier`.

    `OverlayFact.external` is built by `external_environment` from bindings
    whose `target_hint` is set; `target_hint` is `occurrence.qualifier`, which
    the host reads only from a field or attribute literally named `qualifier`.
    A Framework over a language whose Pack publishes none has `external.package`
    and `external.member` empty on every fact, so an `external_path_matches`
    clause -- scoped or not -- is false for every possible input.
    """
    if not _QUALIFIER:
        for p in sorted(os.listdir(PACKS)):
            rp = os.path.join(PACKS, p, 'rules.json')
            if not os.path.exists(rp):
                continue
            for t in json.load(open(rp, encoding='utf-8')).get('templates', []):
                if 'qualifier' in (t.get('fields') or {}) or                    'qualifier' in (t.get('attributes') or {}):
                    _QUALIFIER.add(p)
    return _QUALIFIER


_EMITTERS = {}


def emitters_of():
    """kind -> the Packs that emit it, read once."""
    if not _EMITTERS:
        for p in sorted(os.listdir(PACKS)):
            rp = os.path.join(PACKS, p, 'rules.json')
            if not os.path.exists(rp):
                continue
            for t in json.load(open(rp, encoding='utf-8')).get('templates', []):
                _EMITTERS.setdefault(t['output_kind'], []).append(p)
    return _EMITTERS


def walk_clauses(clauses, out):
    """Collect (fact_kind, fields, attributes) demanded by a clause list."""
    for c in clauses or []:
        if not isinstance(c, dict):
            continue
        k = c.get('kind')
        if k == 'fact_kind':
            out['kinds'].add(c.get('value'))
        elif k in ('field_equals', 'field_present', 'field_in', 'field_not_in',
                   'field_prefix', 'field_not_prefix'):
            f = c.get('field') or c.get('value')
            if isinstance(f, str):
                out['fields'].add(f)
        elif k == 'attribute_equals':
            a = c.get('attribute') or c.get('field')
            if isinstance(a, str):
                out['attrs'].add(a)
        elif k == 'path_glob':
            # glob_here implements only **, * and ?; a brace is a literal byte,
            # so `**/*.{js,ts}` matches a path that literally ends in that text.
            g = c.get('pattern') or c.get('value') or c.get('glob') or ''
            if '{' in g:
                out['bad_glob'].add(g)
        elif k == 'external_path_matches':
            out['external'] = True
            # parse_external_path takes the FIRST path part as the package, so a
            # scoped npm name is split: `@sveltejs/kit` is package `@sveltejs`.
            vals = [c.get('package'), c.get('package_prefix')] + list(c.get('package_in') or [])
            for v in vals:
                if isinstance(v, str) and v.startswith('@') and '/' in v:
                    out['scoped'].add(v)
        # joins carry their own nested clause list, and their own fact kind
        for key in ('match', 'clauses', 'where'):
            if isinstance(c.get(key), list):
                walk_clauses(c[key], out)
        for key in ('join', 'fact_join_by_field', 'fact_join_by_owner',
                    'fact_join_by_span', 'fact_join_by_path_ancestor'):
            if isinstance(c.get(key), dict):
                walk_clauses([c[key]], out)
        if 'fact_kind' in c and isinstance(c['fact_kind'], str):
            out['kinds'].add(c['fact_kind'])


def audit(fw, kinds, fields, attrs):
    path = os.path.join(FRAMEWORKS, fw, 'semantic-v2.json')
    if not os.path.exists(path):
        return None
    doc = json.load(open(path, encoding='utf-8'))
    required = (doc.get('host') or {}).get('required_packs')
    undeclared = {}
    if required:
        all_kinds, _, _ = kinds, fields, attrs
        kinds, fields, attrs = pack_surface(set(required))
        # A kind some Pack emits, but not one this Framework declares, is a
        # manifest that under-declares its packs, not a rule that matches
        # nothing. Say which Pack, so the fix is one line either way.
        for k in all_kinds - kinds:
            emitters = emitters_of().get(k)
            if emitters:
                undeclared[k] = ', '.join(emitters)
    qualifier_packs = qualifier_publishers()
    rules = doc.get('rules') or []
    dead, live, detail = 0, 0, []
    undeclared_rules, note = 0, []
    for r in rules:
        out = {'kinds': set(), 'fields': set(), 'attrs': set(),
               'bad_glob': set(), 'scoped': set(), 'external': False}
        walk_clauses(r.get('match'), out)
        out['kinds'].discard(None)
        missing_kind = {k for k in out['kinds'] if k not in kinds}
        # a field is satisfiable if any demanded kind publishes it
        supplied = set()
        for k in out['kinds'] & kinds:
            supplied |= fields.get(k, set())
        missing_field = out['fields'] - supplied - BUILTIN
        supplied_a = set()
        for k in out['kinds'] & kinds:
            supplied_a |= attrs.get(k, set())
        missing_attr = out['attrs'] - supplied_a
        # A kind that only another language's Pack emits does not match here,
        # whether the manifest under-declares its packs or the rule is simply
        # written against the wrong language. Name the emitters and let the
        # reader decide which of the two it is.
        undeclared_here = sorted(missing_kind & set(undeclared))
        missing_kind -= set(undeclared)
        if out['external'] and not qualifier_packs & set(required or []):
            out['scoped'].add('external.* is empty: no declared Pack publishes '
                              'a qualifier')
        extra = (['brace glob ' + g for g in sorted(out['bad_glob'])] +
                 [g if g.startswith('external.*') else 'scoped package ' + g
                  for g in sorted(out['scoped'])] +
                 ['%s, emitted only by %s, which host.required_packs does not list'
                  % (k, undeclared[k]) for k in undeclared_here])
        if missing_kind or missing_field or missing_attr or extra:
            dead += 1
            detail.append((r.get('id', '?'), sorted(missing_kind),
                           sorted(missing_field), sorted(missing_attr) + extra))
        else:
            live += 1
    return {'rules': len(rules), 'live': live, 'dead': dead, 'detail': detail,
            'undeclared': undeclared_rules, 'note': note,
            'detection_rules': len(doc.get('detection_rules') or [])}


def main():
    kinds, fields, attrs = pack_surface()
    names = sys.argv[1:] or sorted(os.listdir(FRAMEWORKS))
    names = [n if n.startswith('omega-framework-') else 'omega-framework-' + n for n in names]
    rows = []
    for fw in names:
        r = audit(fw, kinds, fields, attrs)
        if r:
            rows.append((fw, r))
    if len(rows) == 1:
        fw, r = rows[0]
        print('%s: %d overlay rules, %d detection rules -- %d live, %d cannot match\n'
              % (fw, r['rules'], r['detection_rules'], r['live'], r['dead']))
        for rid, kinds_ in r['note']:
            print('   %-46s matches %s -- add that Pack to host.required_packs'
                  % (rid[:46], ', '.join(kinds_)))
        for rid, mk, mf, ma in r['detail']:
            bits = []
            if mk:
                bits.append('kind ' + ', '.join(mk))
            if mf:
                bits.append('field ' + ', '.join(mf))
            if ma:
                bits.append('attribute ' + ', '.join(ma))
            print('   %-46s no Pack emits %s' % (rid[:46], '; '.join(bits)))
        return
    tot = sum(r['rules'] for _, r in rows)
    dead = sum(r['dead'] for _, r in rows)
    print('%-44s %6s %6s %6s' % ('framework', 'rules', 'live', 'dead'))
    for fw, r in sorted(rows, key=lambda x: -x[1]['dead']):
        if r['dead']:
            print('%-44s %6d %6d %6d' % (fw, r['rules'], r['live'], r['dead']))
    print('\n%d overlay rules across %d frameworks; %d cannot match any Pack emission (%d%%)'
          % (tot, len(rows), dead, round(100 * dead / max(tot, 1))))
    und = sum(r['undeclared'] for _, r in rows)
    if und:
        print('%d more match a kind whose Pack the manifest does not list '
              'in host.required_packs' % und)
        for fw, r in sorted(rows, key=lambda x: -x[1]['undeclared']):
            if r['undeclared']:
                print('   %-44s %d' % (fw, r['undeclared']))


if __name__ == '__main__':
    main()
