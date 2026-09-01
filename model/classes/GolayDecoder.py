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

    def decode(self, r, full_codeword = False):
        """
        Get info bits of given vector. Correction is made if applicable

        Args:
            r: Given received vector
            full_codeword: True to return full corrected vector, False to return only info bits. Defaults to False.

        Returns:
            tuple: (info_bits, corrected_flag, uncorrectable_flag)
        """
        r, corrected, uncorrectable = self.correct(r)
        word                        = r if full_codeword else r[0:self._k]
        return word, corrected, uncorrectable

    def correct(self, r):
        """
        Correct given vector if applicable and return status flags. If uncorrectable received vector is unchanged

        Args:
            r: Given received vector

        Returns:
            tuple: (corrected_vector, corrected_flag, uncorrectable_flag)
        """
        r_low           = r[0:self._k]
        r_high          = r[self._k::]
        corrected       = False
        uncorrectable   = False

        s = self._gf.mat_mul(r_low, self._G2412B) ^ r_high
        q = self._gf.mat_mul(r_high, self._G2412B) ^ r_low
        
        if self._gf.do_pack(s) != 0:
            error = self.get_error(s, q)

            if error is None:
                # r, remains uncorrected
                uncorrectable = True
            else:
                r           = r ^ error
                corrected   = True

        return r, corrected, uncorrectable
    
    def get_error(self, s, q):
        """
        Implements the golay 24,12 decoder 4 cases

        Args:
            s: Given syndrome
            q: Given q

        Returns:
            np.array: Error pattern or None
        """
        error_low   = None
        error_high  = None

        # all errors in parity
        if self._gf.hamming_weight(s) <= 3:
            error_low   = self._gf.do_unpack(0, self._k)
            error_high  = s
        # all errors in word
        elif self._gf.hamming_weight(q) <= 3:
            error_low   = q
            error_high  = self._gf.do_unpack(0, self._k)
        else:
            for i, bi in enumerate(self._G2412B):
                sbi = s ^ bi
                qbi = q ^ bi
                ui  = self._gf.do_unpack(1<<i, self._k)[::-1]
                # only one error in word, remaining in parity
                if self._gf.hamming_weight(sbi) <= 2:
                    error_low   = ui
                    error_high  = sbi
                    break
                # only one error in parity remaining in word
                elif self._gf.hamming_weight(qbi) <= 2:
                    error_low   = qbi
                    error_high  = ui
                    break

        # if more than one error in word and parity also, then errors > 3, uncorrectable
        error = None if error_low is None else np.hstack((error_low, error_high)).astype(np.uint8)
        return error