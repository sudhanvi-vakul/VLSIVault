import argparse, json, pathlib
ALU_OP_BINS = {str(i): 0 for i in range(8)}
ALU_CORNER_BINS = {k: 0 for k in ['a_is_0','a_is_max','b_is_0','b_is_max','a_is_AAAA','a_is_5555']}
def is_max(x, nbits=16): return x == (1<<nbits)-1
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--trace', required=True); ap.add_argument('--out', required=True); args=ap.parse_args()
    bins={'alu_op': dict(ALU_OP_BINS), 'alu_corner': dict(ALU_CORNER_BINS)}
    for line in open(args.trace,'r',encoding='utf-8'):
        rec=json.loads(line)
        if rec.get('kind')!='alu_txn': continue
        op=str(rec.get('op')); 
        if op in bins['alu_op']: bins['alu_op'][op]=1
        a=int(rec.get('a',0))&0xFFFF; b=int(rec.get('b',0))&0xFFFF
        if a==0: bins['alu_corner']['a_is_0']=1
        if is_max(a): bins['alu_corner']['a_is_max']=1
        if b==0: bins['alu_corner']['b_is_0']=1
        if is_max(b): bins['alu_corner']['b_is_max']=1
        if a==0xAAAA: bins['alu_corner']['a_is_AAAA']=1
        if a==0x5555: bins['alu_corner']['a_is_5555']=1
    pathlib.Path(args.out).write_text(json.dumps(bins, indent=2), encoding='utf-8'); print('Wrote', args.out)
if __name__=='__main__': main()
