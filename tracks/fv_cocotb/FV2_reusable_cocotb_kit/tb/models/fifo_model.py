# tb/models/fifo_model.py
class FifoModel:
    def __init__(self):
        self.queue = []

    def push(self, data):
        self.queue.append(data)

    def pop(self):
        if not self.queue:
            raise AssertionError("FIFO Underflow in model")
        return self.queue.pop(0)