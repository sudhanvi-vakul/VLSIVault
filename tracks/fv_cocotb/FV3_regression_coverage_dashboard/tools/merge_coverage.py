import argparse, json, pathlib
def merge_dict(a,b):
    out=dict(a)
    for k,v in b.items():
        if isinstance(v,dict): out[k]=merge_dict(out.get(k,{}),v)
        else: out[k]=1 if (out.get(k,0) or v) else 0
    return out
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--runs', default='results/runs'); ap.add_argument('--out', default='results/reports/coverage_merged.json'); ap.add_argument('--missing', default='results/reports/missing_bins.txt'); args=ap.parse_args()
    merged={}
    for cov in pathlib.Path(args.runs).rglob('coverage.json'):
        d=json.loads(cov.read_text()); merged=merge_dict(merged,d) if merged else d
    pathlib.Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    pathlib.Path(args.out).write_text(json.dumps(merged, indent=2))
    missing=[]
    for grp,bins in merged.items():
        for name,hit in bins.items():
            if hit==0: missing.append(f"{grp}:{name}")
    pathlib.Path(args.missing).write_text('\n'.join(sorted(missing)))
    print('merged=', args.out); print('missing=', args.missing)
if __name__=='__main__': main()
