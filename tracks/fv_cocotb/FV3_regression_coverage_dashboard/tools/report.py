import argparse, csv, json, pathlib
def is_fail(txt):
    txt = txt.upper()  # make check case-insensitive
    return ('ASSERTIONERROR' in txt) or ('FAIL' in txt and 'PASS' not in txt)
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--runs', default='results/runs'); ap.add_argument('--out_csv', default='results/reports/summary.csv'); ap.add_argument('--out_md', default='results/reports/report.md'); args=ap.parse_args()
    rows=[]
    for meta in pathlib.Path(args.runs).rglob('metadata.json'):
        d=json.loads(meta.read_text()); run_dir=meta.parent
        log=(run_dir/'sim.log').read_text(errors='ignore') if (run_dir/'sim.log').exists() else ''
        rows.append({'dut':d.get('dut',''),'test':d.get('test','').split('.')[-1],'seed':d.get('seed',''),'status':'FAIL' if is_fail(log) else 'PASS','run_dir':str(run_dir)})
    pathlib.Path(args.out_csv).parent.mkdir(parents=True, exist_ok=True)
    with open(args.out_csv,'w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f, fieldnames=['dut','test','seed','status','run_dir']); w.writeheader();
        for r in rows: w.writerow(r)
    pass_cnt=sum(1 for r in rows if r['status']=='PASS'); fail_cnt=sum(1 for r in rows if r['status']=='FAIL')
    md=['# Regression Report','',f"Total runs: {len(rows)}  PASS: {pass_cnt}  FAIL: {fail_cnt}",'','## Coverage']
    if pathlib.Path('results/reports/coverage_merged.json').exists(): md.append('- merged coverage: results/reports/coverage_merged.json')
    if pathlib.Path('results/reports/missing_bins.txt').exists(): md.append('- missing bins: results/reports/missing_bins.txt')
    pathlib.Path(args.out_md).write_text('\n'.join(md), encoding='utf-8')
    print('wrote', args.out_csv); print('wrote', args.out_md)
if __name__=='__main__': main()
