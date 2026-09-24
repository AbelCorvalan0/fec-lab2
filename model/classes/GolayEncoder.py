import numpy as np

class GolayEncoder:
    def __init__(self):
        self._k = 12
        self._n = 24

        # define golay 24,12 parity matrix
        self._G2412B = np.array([
            [1,0,0,1,1,0,0,0,1,1,1,1]   ,
            [0,1,0,0,1,1,1,0,0,1,1,1]   ,
            [0,0,1,1,0,1,0,1,0,1,1,1]   ,
            [1,0,1,1,1,1,1,0,0,0,1,0]   ,
            [1,1,0,1,1,1,0,1,0,0,0,1]   ,
            [0,1,1,1,1,1,0,0,1,1,0,0]   ,
            [0,1,0,1,0,0,1,1,1,1,0,1]   ,
            [0,0,1,0,1,0,1,1,1,1,1,0]   ,
            [1,0,0,0,0,1,1,1,1,0,1,1]   ,
            [1,1,1,0,0,1,1,1,0,1,0,0]   ,
            [1,1,1,1,0,0,0,1,1,0,1,0]   ,
            [1,1,1,0,1,0,1,0,1,0,0,1]]  , dtype=np.uint8)

    def encode(self, word):
        if np.all(word == 0):
            parity = np.full(self._n-self._k, 0, dtype=np.uint8)
        else:
            parity = None
            for i, w in enumerate(word):
                if w == 1:
                    parity = self._G2412B[i] if parity is None else parity ^ self._G2412B[i]

        codeword = np.array([word, parity], dtype=np.uint8).flatten()
        return codeword