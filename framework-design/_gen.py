"""Generate one design document per Framework.

    python framework-design/_gen.py

Run from the assets repository root. Each document records what the overlay
matches, what it outputs, which of its rules can no longer match and why, and
what the rewritten Pack vocabulary offers instead.
"""
import collections
import io
import json
import os
import sys

sys.path.insert(0, 'pack-design')
exec(open('pack-design/overlay_audit.py', encoding='utf-8').read().split('def main(')[0])

OUT = 'framework-design'


def clause_summary(clauses, acc):
    for c in clauses or []:
        if not isinstance(c, dict):
            continue
        k = c.get('kind')
        if k:
            acc['clauses'][k] += 1
        if k == 'fact_kind':
            acc['kinds'][c.get('value')] += 1
        elif k and k.startswith('field'):
            f = c.get('field') or c.get('value')
            if isinstance(f, str):
                acc['fields'][f] += 1
        elif k == 'attribute_equals':
            a = c.get('attribute') or c.get('field')
            if isinstance(a, str):
                acc['attrs'][a] += 1
        elif k == 'path_glob':
            acc['globs'][c.get('pattern') or c.get('value') or c.get('glob')] += 1
        for key in ('match', 'clauses', 'where'):
            if isinstance(c.get(key), list):
                clause_summary(c[key], acc)
        for key in ('join', 'fact_join_by_field', 'fact_join_by_owner',
                    'fact_join_by_span', 'fact_join_by_path_ancestor'):
            if isinstance(c.get(key), dict):
                clause_summary([c[key]], acc)
        if isinstance(c.get('fact_kind'), str) and k != 'fact_kind':
            acc['kinds'][c['fact_kind']] += 1
            acc['clauses']['(join)'] += 1


def document(fw, kinds, fields, attrs):
    path = os.path.join('frameworks', fw, 'semantic-v2.json')
    if not os.path.exists(path):
        return None
    doc = json.load(open(path, encoding='utf-8'))
    rules = doc.get('rules') or []
    acc = {'clauses': collections.Counter(), 'kinds': collections.Counter(),
           'fields': collections.Counter(), 'attrs': collections.Counter(),
           'globs': collections.Counter()}
    ents = collections.Counter()
    rels = collections.Counter()
    for r in rules:
        clause_summary(r.get('match'), acc)
        for o in r.get('outputs') or []:
            if o.get('kind') == 'entity_candidate':
                ents[o.get('entity_kind')] += 1
            elif o.get('kind') == 'relation_candidate':
                rels[o.get('relation_kind')] += 1
    a = audit(fw, kinds, fields, attrs)

    L = []
    w = L.append
    w('# %s' % fw)
    w('')
    w('Read `00-CONTRACT.md` first: the overlay matches Pack emissions and nothing')
    w('else, so a rule lives or dies by whether a Pack still emits its fact kind.')
    w('')
    w('## State')
    w('')
    w('%d overlay rules, %d detection rules. **%d can match, %d cannot.**'
      % (a['rules'], a['detection_rules'], a['live'], a['dead']))
    w('')
    w('Selector: `%s`. Maturity: `%s`.'
      % (doc.get('selector', '?'), doc.get('maturity_target', '?')))
    w('')
    if ents:
        w('### Entities it declares')
        w('')
        w('| entity_kind | rules |')
        w('|---|---|')
        for k, n in ents.most_common():
            w('| `%s` | %d |' % (k, n))
        w('')
    if rels:
        w('### Relations it declares')
        w('')
        w('| relation_kind | rules |')
        w('|---|---|')
        for k, n in rels.most_common():
            w('| `%s` | %d |' % (k, n))
        w('')
    w('### Fact kinds it matches')
    w('')
    w('| kind | rules | a Pack emits it |')
    w('|---|---|---|')
    for k, n in acc['kinds'].most_common():
        w('| `%s` | %d | %s |' % (k, n, 'yes' if k in kinds else '**no**'))
    w('')
    if acc['clauses']:
        w('Clause vocabulary in use: %s.'
          % ', '.join('`%s` x%d' % (k, n) for k, n in acc['clauses'].most_common()))
        w('')
    if acc['fields']:
        w('Fields read: %s.'
          % ', '.join('`%s`' % f for f, _ in acc['fields'].most_common(20)))
        w('')
    if acc['globs']:
        w('Path globs: %s.'
          % ', '.join('`%s`' % g for g, _ in acc['globs'].most_common(10) if g))
        w('')
    if a['detail']:
        w('## Why a rule cannot match')
        w('')
        w('| rule | what no Pack emits |')
        w('|---|---|')
        for rid, mk, mf, ma in a['detail']:
            bits = []
            if mk:
                bits.append('kind ' + ', '.join('`%s`' % x for x in mk))
            if mf:
                bits.append('field ' + ', '.join('`%s`' % x for x in mf))
            if ma:
                bits.append('attribute ' + ', '.join('`%s`' % x for x in ma))
            w('| `%s` | %s |' % (rid, '; '.join(bits)))
        w('')
    w('## To decide when rewriting')
    w('')
    w('1. For each dead kind above, which of the vocabulary in `00-CONTRACT.md` §6')
    w('   states the same thing? `call.target_candidate` is `call.function`;')
    w('   `structured.entry` is `definition.config_key`; a `*_context` kind is')
    w('   usually a declaration plus a join.')
    w('2. Which rules only restate their input, and should go rather than be ported?')
    w('3. Which rules are one language\'s spelling of something every language now')
    w('   spells the same way, and collapse into one rule?')
    w('4. Which fields are genuinely needed, and which are reachable by')
    w('   `fact_join_by_span` with `within` or by `definition.name`?')
    w('5. What does this framework actually let an agent ask that the language')
    w('   Packs alone cannot answer? That is the whole point of the overlay.')
    io.open(os.path.join(OUT, fw + '.md'), 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(L) + '\n')
    return a


def main():
    os.makedirs(OUT, exist_ok=True)
    kinds, fields, attrs = pack_surface()
    tot = dead = 0
    for fw in sorted(os.listdir('frameworks')):
        a = document(fw, kinds, fields, attrs)
        if a:
            tot += a['rules']
            dead += a['dead']
    print('wrote %d documents; %d of %d rules cannot match'
          % (len(os.listdir(OUT)) - 1, dead, tot))


if __name__ == '__main__':
    main()
