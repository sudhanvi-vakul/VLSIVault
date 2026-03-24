import os, subprocess, argparse, pathlib

def run(cmd, log_path):
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, 'w', encoding='utf-8') as f:
        p = subprocess.Popen(cmd, stdout=f, stderr=subprocess.STDOUT, text=True)
        return p.wait()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--test', default='tb.tests.test_alu_random')
    ap.add_argument('--dut', default='alu')
    args = ap.parse_args()

    env = os.environ.copy()
    env['SEED'] = str(args.seed)

    cmd = ['make', 'SIM=verilator', f'TOPLEVEL={args.dut}', f'MODULE={args.test}']
    log = pathlib.Path('results') / f"{args.dut}_{args.test.split('.')[-1]}_seed{args.seed}.log"
    rc = subprocess.call(cmd, env=env, stdout=open(log, 'w'), stderr=subprocess.STDOUT)
    raise SystemExit(rc)

if __name__ == '__main__':
    main()
