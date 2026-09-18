"""Relation ends addressing a canonical key no rule mints.

`apply_overlay_runs` resolves a relation's two ends through the intern table of
entities that were actually materialized. An end that resolves to nothing is
dropped -- `unresolved_ends += 1`, the run is marked incomplete, and the edge
simply is not there. Nothing in the audit sees it, because every clause in the
rule matched perfectly well.

So: collect the canonical key templates the entity outputs render, collect the
ones the relation ends address, and report the difference. A `current` end is
the rule's own first entity output and always resolves.

This finds candidates, not verdicts. Two templates that differ textually can
render the same string -- omega-framework-pydantic mints
`pydantic:model:{definition.container}` from a base-class reference and
addresses `pydantic:model:{model.definition.name}` from the class itself, and
the nested join makes them the same name by construction. Read the two rules
before believing a row. What the check does catch mechanically is a key space
nothing mints at all.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRAMEWORKS = os.path.join(ROOT, 'frameworks')


def norm(template):
    """`{op.path}` and `{path}` render the same string.

    A placeholder is resolved against the bound fact named by its prefix, so two
    rules that bind the same fact under different names address one key. Compare
    on the last dotted segment.
    """
    return re.sub(r'\{([^}]*)\}',
                  lambda m: '{' + m.group(1).split('.')[-1] + '}', template)


def ends(fw):
    p = os.path.join(FRAMEWORKS, fw, 'semantic-v2.json')
    if not os.path.exists(p):
        return None
    doc = json.load(open(p, encoding='utf-8'))
    minted, addressed = set(), {}
    for r in doc.get('rules') or []:
        rid = r.get('id', '?')
        for o in r.get('outputs') or []:
            if o.get('kind') == 'entity_candidate':
                tpl = ((o.get('canonical_key') or {}).get('template'))
                if tpl:
                    minted.add(norm(tpl))
            elif o.get('kind') == 'relation_candidate':
                for side in ('source', 'target'):
                    ref = o.get(side) or {}
                    if ref.get('kind') == 'by_canonical_key' and ref.get('template'):
                        addressed.setdefault(norm(ref['template']), set()).add(
                            '%s.%s' % (rid, side))
    return sorted((t, sorted(w)) for t, w in addressed.items() if t not in minted)


def main():
    names = sys.argv[1:] or sorted(os.listdir(FRAMEWORKS))
    names = [n if n.startswith('omega-framework-') else 'omega-framework-' + n
             for n in names]
    total = 0
    for fw in names:
        d = ends(fw)
        if not d:
            continue
        print(fw)
        for tpl, where in d:
            total += len(where)
            print('   %s' % tpl)
            for w in where:
                print('      addressed by %s' % w)
        print()
    print('%d relation ends address a key template no rule mints textually' % total)
    print('-- read each pair before believing it, see the module docstring')


if __name__ == '__main__':
    main()
