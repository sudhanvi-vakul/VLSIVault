import json, pathlib, time
class TraceWriter:
    def __init__(self, path):
        self.path = pathlib.Path(path); self.path.parent.mkdir(parents=True, exist_ok=True)
        self.f = open(self.path, 'w', encoding='utf-8')
    def event(self, kind, **fields):
        rec={'t':time.time(),'kind':kind}; rec.update(fields)
        self.f.write(json.dumps(rec)+'\n'); self.f.flush()
    def close(self): self.f.close()
