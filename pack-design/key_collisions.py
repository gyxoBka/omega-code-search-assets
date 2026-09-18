"""Which entity kinds are silently dropped because two rules share a canonical key.

The host interns an entity by its canonical key alone:
EntityId::from_binding(Canonical{key}) ignores the descriptor, and
overlay_ir.rs does entities.entry(id).or_insert(entity) -- first wins.
Candidates are sorted by rule_id (overlay.rs::candidate_order), so the winner
is the alphabetically first rule id that mints that key template.

A shared key is correct when the rules agree on the entity_kind: that is how a
hub entity is minted by every rule that needs it as a relation end. It is a
defect when they disagree: every kind but one is computed and thrown away.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRAMEWORKS = os.path.join(ROOT, 'frameworks')


def collisions(fw):
    p = os.path.join(FRAMEWORKS, fw, 'semantic-v2.json')
    if not os.path.exists(p):
        return None
    doc = json.load(open(p, encoding='utf-8'))
    by_template = {}
    for r in doc.get('rules') or []:
        rid = r.get('id', '?')
        for o in r.get('outputs') or []:
            if o.get('kind') != 'entity_candidate':
                continue
            tpl = ((o.get('canonical_key') or {}).get('template')) or '?'
            by_template.setdefault(tpl, []).append((rid, o.get('entity_kind')))
    out = []
    for tpl, mints in sorted(by_template.items()):
        kinds = {k for _, k in mints}
        if len(kinds) < 2:
            continue
        winner = sorted(mints)[0]
        losers = sorted({(rid, k) for rid, k in mints if k != winner[1]})
        out.append((tpl, winner, losers))
    return out


def across_frameworks():
    """Key templates minted under different kinds by different Frameworks.

    `apply_overlay_runs` interns across every overlay in the run, not one at a
    time, and sorts by rule_id -- so two Frameworks that render the same key
    collide exactly as two rules in one file do, and the framework whose rule
    ids sort first wins.
    """
    by_template = {}
    for fw in sorted(os.listdir(FRAMEWORKS)):
        p = os.path.join(FRAMEWORKS, fw, 'semantic-v2.json')
        if not os.path.exists(p):
            continue
        doc = json.load(open(p, encoding='utf-8'))
        for r in doc.get('rules') or []:
            for o in r.get('outputs') or []:
                if o.get('kind') != 'entity_candidate':
                    continue
                tpl = ((o.get('canonical_key') or {}).get('template')) or '?'
                by_template.setdefault(tpl, set()).add(
                    (fw, r.get('id', '?'), o.get('entity_kind')))
    out = []
    for tpl, mints in sorted(by_template.items()):
        if len({fw for fw, _, _ in mints}) < 2:
            continue
        if len({k for _, _, k in mints}) < 2:
            continue
        out.append((tpl, sorted(mints, key=lambda m: m[1])))
    return out


def main():
    names = sys.argv[1:] or sorted(os.listdir(FRAMEWORKS))
    names = [n if n.startswith('omega-framework-') else 'omega-framework-' + n
             for n in names]
    total = 0
    for fw in names:
        c = collisions(fw)
        if not c:
            continue
        print(fw)
        for tpl, winner, losers in c:
            total += len(losers)
            print('   %s' % tpl)
            print('      kept    %-34s %s' % (winner[1], winner[0]))
            for rid, k in losers:
                print('      DROPPED %-34s %s' % (k, rid))
        print()
    print('%d entity outputs are overwritten by a same-key rule that sorts first'
          % total)
    if len(sys.argv) > 1:
        return
    shared = across_frameworks()
    if shared:
        print()
        print('%d key templates are minted under different kinds by different '
              'Frameworks; interning is global, so these collide too:' % len(shared))
        for tpl, mints in shared:
            print('   %s' % tpl)
            for fw, rid, kind in mints:
                print('      %-34s %-28s %s' % (kind, rid, fw))


if __name__ == '__main__':
    main()
