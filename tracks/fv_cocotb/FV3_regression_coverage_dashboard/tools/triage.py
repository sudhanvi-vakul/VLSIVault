import argparse, pathlib, re, collections
FAIL_PATTERNS = [re.compile(r"AssertionError: (.*)"), re.compile(r"MISMATCH.*"), re.compile(r"FAIL.*")]
def signature_from_log(text):
    for line in text.splitlines():
        for pat in FAIL_PATTERNS:
            m = pat.search(line)
            if m:
                return m.group(0)[:160]
    return None
def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--runs', default='results/runs'); args = ap.parse_args()
    groups = collections.defaultdict(list)
    for log in pathlib.Path(args.runs).rglob('sim.log'):
        sig = signature_from_log(log.read_text(errors='ignore'))
        if sig: groups[sig].append(str(log.parent))
    for sig, items in sorted(groups.items(), key=lambda kv: len(kv[1]), reverse=True):
        print('\n=== SIGNATURE ==='); print(sig); print('count=', len(items))
        for it in items[:5]: print('  ', it)
if __name__ == '__main__': main()
