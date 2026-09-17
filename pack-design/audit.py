"""Measure the defect classes of 00-INDEX.md across every Pack.

    python pack-design/audit.py            # every Pack
    python pack-design/audit.py omega-ruby # one Pack

Run it from the root of the assets repository. It reads only; it changes
nothing. Every number it prints is a count of something a query could be asked
about and is not getting, or of something stored that answers nothing.
"""
import collections
import json
import os
import re
import sys

TRAIL = re.compile(r'\s*(?:[?*+]|@[\w.\-]+|\(#[^()]*(?:\([^()]*\)[^()]*)*\))')
CONTAINER = {'document', 'object', 'array', 'block', 'element', 'body', 'program',
             'source_file', 'text', 'string', 'chunk', 'table', 'class_body'}
RELATIONS = {'implements', 'tests', 'depends', 'config', 'data', 'handles'}
NOT_TREE_SITTER = re.compile(
    r'#(lua-match\?|not-lua-match\?|is-not\?|has-ancestor\?|not-has-parent\?|'
    r'has-parent\?|is\?|gsub!|strip!|select-adjacent!|trim!)')


def top_patterns(path):
    """Top-level query patterns, each carrying the captures that trail its
    closing bracket: `[ (a) (b) ] @owner` is one pattern binding @owner."""
    s = re.sub(r';[^\n]*', '', open(path, encoding='utf-8').read())
    out, depth, buf, in_string, i = [], 0, '', False, 0
    while i < len(s):
        ch = s[i]
        if in_string:
            buf += ch
            if ch == '"' and s[i - 1] != chr(92):
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            buf += ch
            i += 1
            continue
        if ch in '([':
            depth += 1
        if depth > 0:
            buf += ch
        if ch in ')]':
            depth -= 1
            if depth == 0:
                j = i + 1
                while True:
                    m = TRAIL.match(s, j)
                    if not m:
                        break
                    buf += s[j:m.end()]
                    j = m.end()
                out.append(buf.strip())
                buf = ''
                i = j
                continue
        i += 1
    return out


def is_def(k):
    if k.startswith(('call.', 'reference', 'type_use.', 'value_', 'import')):
        return False
    return 'definition' in k or k.endswith(('.type', '.function', '.class', '.method', '.trait'))


def is_scope(k):
    return k == 'scope' or k.startswith('scope.')


def audit(pack):
    q = 'packs/%s/queries.scm' % pack
    rp = 'packs/%s/rules.json' % pack
    if not os.path.exists(rp):
        return None
    rules = json.load(open(rp, encoding='utf-8'))
    templates = rules.get('templates', [])
    guards = rules.get('coverage_guards', [])
    pats = top_patterns(q) if os.path.exists(q) else []
    cap_sets = [set(re.findall(r'@([\w.\-]+)', p)) for p in pats]
    every_cap = set().union(*cap_sets) if cap_sets else set()
    tpl_blob = json.dumps(templates)
    src = open(q, encoding='utf-8').read() if os.path.exists(q) else ''

    # which node type is each capture attached to
    owner = {}
    for pat in pats:
        for m in re.finditer(r'\((\w+)[^()]*?\)\s*@([\w.\-]+)', pat):
            owner.setdefault(m.group(2), m.group(1))
        for m in re.finditer(r'^\((\w+)\b', pat):
            for c in re.findall(r'@([\w.\-]+)\s*$', pat):
                owner.setdefault(c, m.group(1))

    f = collections.Counter()
    detail = collections.defaultdict(list)

    for t in templates:
        k = t['output_kind']
        name = t.get('name')
        # D - the name is a whole node
        if isinstance(name, dict) and name.get('kind') == 'capture_ref':
            if owner.get(name['name']) in CONTAINER:
                f['D'] += 1
                detail['D'].append('%s <- (%s)' % (k, owner[name['name']]))
        # J - a name that is a constant
        if isinstance(name, dict) and name.get('kind') == 'literal':
            f['J'] += 1
            detail['J'].append('%s = %r' % (k, name.get('value')))
        # F - a constant attribute
        for an, av in (t.get('attributes') or {}).items():
            if isinstance(av, str) or (isinstance(av, dict) and av.get('kind') == 'literal'):
                f['F'] += 1
                detail['F'].append('%s.%s' % (k, an))
        # relation kinds the host does not know
        if k.startswith('relation.') and k[len('relation.'):] not in RELATIONS:
            f['relation'] += 1
            detail['relation'].append(k)
        # a carrier the host will not fold
        if k.endswith('_candidate') and not is_def(k):
            f['carrier'] += 1
            detail['carrier'].append(k)
        # a scope that is also a declaration
        if is_scope(k) and is_def(k):
            f['scope_is_def'] += 1
            detail['scope_is_def'].append(k)
        # M - captures no single pattern binds together
        need = {t['span_capture']}
        need |= set(re.findall(r'"kind": ?"capture_ref", ?"name": ?"([\w.\-]+)"', json.dumps(t)))
        if cap_sets and need <= every_cap and not any(need <= s for s in cap_sets):
            f['M'] += 1
            detail['M'].append('%s needs %s' % (k, sorted(need)))

    # K - the same template twice
    seen = collections.Counter(json.dumps(t, sort_keys=True) for t in templates)
    f['K'] = sum(v - 1 for v in seen.values() if v > 1)

    # I - a pattern nothing reads, and the universal capture
    for pat in pats:
        caps = set(re.findall(r'@([\w.\-]+)', pat))
        if not caps:
            continue
        if re.fullmatch(r'\(_\)\s*@[\w.\-]+', pat.strip()):
            f['I'] += 1
            detail['I'].append('(_) matches every named node')
        if not any(('"%s"' % c) in tpl_blob for c in caps) and not any(
                c.startswith('injection.') for c in caps) and '#set!' not in pat:
            f['unread'] += 1
            detail['unread'].append(re.sub(r'\s+', ' ', pat)[:70])

    # H - an operator tree-sitter does not have
    f['H'] = len(NOT_TREE_SITTER.findall(src))

    # G - a guard whose reason is a label
    for g in guards:
        if ' ' not in (g.get('reason') or ''):
            f['G'] += 1
            detail['G'].append(g.get('reason', ''))

    declared = set()
    mt = re.search(r'^capabilities = \[(.*)\]$',
                   open('packs/%s/manifest.toml' % pack, encoding='utf-8').read(), re.M)
    if mt:
        declared = set(re.findall(r'"([^"]+)"', mt.group(1)))
    programmed = {t['capability'] for t in templates}
    f['cap_mismatch'] = len(declared ^ programmed)
    detail['cap_mismatch'] = sorted(declared ^ programmed)

    return {'templates': len(templates), 'patterns': len(pats), 'guards': len(guards),
            'flags': f, 'detail': detail}


LABEL = {
    'D': 'D  name is a whole node',
    'F': 'F  constant attribute',
    'G': 'G  guard reason is a label',
    'H': 'H  operator tree-sitter does not have',
    'I': 'I  (_) universal capture',
    'J': 'J  name is a constant',
    'K': 'K  duplicate template',
    'M': 'M  template no pattern can bind',
    'relation': '   relation.* the host does not know',
    'carrier': '   carrier the host will not fold',
    'scope_is_def': '   scope that is also a declaration',
    'unread': '   pattern nothing reads',
    'cap_mismatch': '   manifest vs templates',
}


def main():
    packs = sys.argv[1:] or sorted(os.listdir('packs'))
    total = collections.Counter()
    rows = []
    for p in packs:
        r = audit(p)
        if not r:
            continue
        total.update(r['flags'])
        if sum(r['flags'].values()):
            rows.append((p, r))
    if len(packs) == 1 and rows:
        p, r = rows[0]
        print('%s: %d templates over %d patterns, %d guards\n'
              % (p, r['templates'], r['patterns'], r['guards']))
        for k, v in sorted(r['flags'].items(), key=lambda x: -x[1]):
            if not v:
                continue
            print('%-40s %d' % (LABEL.get(k, k), v))
            for d in r['detail'][k][:6]:
                print('      %s' % d)
        return
    print('%-24s %s' % ('pack', '  '.join(sorted(LABEL))))
    for p, r in rows:
        print('%-24s %s' % (p, '  '.join('%s=%d' % (k, r['flags'][k])
                                         for k in sorted(LABEL) if r['flags'][k])))
    print('\nTOTAL')
    for k, v in sorted(total.items(), key=lambda x: -x[1]):
        if v:
            print('   %-40s %d' % (LABEL.get(k, k), v))


if __name__ == '__main__':
    main()
