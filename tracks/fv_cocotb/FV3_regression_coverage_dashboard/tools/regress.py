import argparse, os, json, subprocess, time, pathlib

def sh(cmd, env=None, log_path=None):
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, 'w', encoding='utf-8') as f:
        p = subprocess.Popen(cmd, stdout=f, stderr=subprocess.STDOUT, env=env, text=True)
        return p.wait()

def capture_versions(env):
    out = {}
    def cap(name, cmd):
        try:
            out[name] = subprocess.check_output(cmd, env=env, stderr=subprocess.STDOUT, text=True).strip()
        except Exception as e:
            out[name] = f"ERROR: {e}"
    cap('verilator', ['verilator','--version'])
    cap('python', ['python3','--version'])
    cap('pytest', ['pytest','--version'])
    cap('cocotb', ['python3','-c','import cocotb; print(cocotb.__version__)'])
    cap('coverage', ['python3','-c','import coverage; print(coverage.__version__)'])
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dut', default='alu')
    ap.add_argument('--tests', default='tb.tests.test_alu_random')
    ap.add_argument('--seed_start', type=int, default=1)
    ap.add_argument('--seed_end', type=int, default=3)
    ap.add_argument('--txns', type=int, default=200)
    ap.add_argument('--waves', choices=['fail','all','off'], default='fail')
    ap.add_argument('--out', default='results/runs')
    args = ap.parse_args()

    env = os.environ.copy()
    versions = capture_versions(env)

    tests = [t.strip() for t in args.tests.split(',') if t.strip()]
    out_root = pathlib.Path(args.out)

    for test in tests:
        for seed in range(args.seed_start, args.seed_end+1):
            run_dir = out_root / args.dut / test.split('.')[-1] / f"seed_{seed:04d}"
            run_dir.mkdir(parents=True, exist_ok=True)

            cmd = ['make', 'SIM=verilator', f'TOPLEVEL={args.dut}', f'MODULE={test}']
            env_run = env.copy()
            env_run['SEED'] = str(seed)
            env_run['TXNS'] = str(args.txns)
            env_run['WAVES'] = '1' if args.waves != 'off' else '0'

            sim_log = run_dir / 'sim.log'
            rc = sh(cmd, env=env_run, log_path=sim_log)

            meta = {
                'dut': args.dut,
                'test': test,
                'seed': seed,
                'txns': args.txns,
                'cmd': ' '.join(cmd) + f" SEED={seed} TXNS={args.txns}",
                'tool_versions': versions,
                'timestamp_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                'checkpoint_sha256': pathlib.Path('docs/checkpoints/checkpoint_before_regress.sha256').read_text().strip() if pathlib.Path('docs/checkpoints/checkpoint_before_regress.sha256').exists() else ''
            }
            (run_dir / 'metadata.json').write_text(json.dumps(meta, indent=2), encoding='utf-8')

            print(('PASS' if rc==0 else 'FAIL'), args.dut, test, 'seed', seed)

if __name__ == '__main__':
    main()
