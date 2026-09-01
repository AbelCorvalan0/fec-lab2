import numpy as np
from classes.GaloisField import GaloisField

class GolayDecoder:
    def __init__(self):
        self._k     = 12
        self._n     = 24
        self._gf    = GaloisField(1,0b11)

        # define golay 24,12 parity matrix

        # KEY PROPERTIES: B == BT, B*B == I
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

    def decode(self, r):
        r = self.correct(r)

        if r is None:
            word = None
        else:
            word = r[0:self._k]

        return word

    def correct(self, r):
        r_low   = r[0:self._k]
        r_high  = r[self._k::]

        s = self._gf.mat_mul(r_low, self._G2412B) ^ r_high
        q = self._gf.mat_mul(r_high, self._G2412B) ^ r_low
        
        if self._gf.do_pack(s) != 0:
            error = self.get_error(s, q)
            if error is None:
                r = None
            else:
                r = r ^ error
        return r
    
    def get_error(self, s, q):
        error_low   = None
        error_high  = None

        # all errors in parity
        if self._gf.hamming_weight(s) <= 3:
            error_low   = np.zeros(self._k)
            error_high  = s
        # all errors in word
        elif self._gf.hamming_weight(q) <=3:
            error_low   = q
            error_high  = np.zeros(self._k)
        else:
            for i, bi in enumerate(self._G2412B):
                sbi = s ^ bi
                qbi = q ^ bi
                # only one error in word, remaining in parity
                if self._gf.hamming_weight(sbi) <=2:
                    error_low   = np.zeros(self._k); error_low[i] = 1
                    error_high  = sbi
                    break
                # only one error in parity remaining in word
                elif self._gf.hamming_weight(qbi) <= 2:
                    error_low   = qbi
                    error_high  = np.zeros(self._k); error_high[i] = 1
                    break

        # if more than one error in word and parity also, then errors > 3, uncorrectable
        error = None if error_low is None else np.hstack((error_low, error_high)).astype(np.uint8)
        return error