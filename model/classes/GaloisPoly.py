import numpy as np
from .defs import *

class GaloisPoly:
    def __init__(self, gf, p):
        self._gf    = gf
        self._p     = p
        self._deg   = self._get_poly_degree(p)

    def __call__(self, x):
        for i, ak in enumerate(self._p[::-1]):
            if i == 0:
                ans = self._p[0]
            elif ak != ELEMENT_ZERO:
                # compute powers, multiply by ak, add all
                x_pow   = self._gf.pow(x, i)[ID_POWER]
                term    = self._gf.mul(ak, x_pow)[ID_POWER]
                ans     = self._gf.add(term, ans)[ID_POWER]

        return ans

    def __str__(self):
        info ="p(x) == "
        for i, ak in enumerate(self._p):
            # ommit zero terms
            if ak != ELEMENT_ZERO:
                # manage powers
                if self._deg-i == 0:
                    info += "1" if ak == ELEMENT_ONE else f"a^{ak}\n"
                elif self._deg-i == 1:
                    info += "" if ak == ELEMENT_ONE else f"a^{ak}*"
                    info += f"x + "
                else: 
                    info += "" if ak == ELEMENT_ONE else f"a^{ak}*"
                    info += f"x^{self._deg-i} + "

        return info

    def __repr__(self):
        return str(self._p)

    def __add__(self, other):
        ans = self._add_poly(self._p, other._p)
        return GaloisPoly(self._gf, ans)

    def __mul__(self, other):
        if isinstance(other, int):
            ans = self._scale_poly(self._p, other)
        else:
            ans = self._mul_poly(self._p, other._p)
        return GaloisPoly(self._gf, ans)

    def __rmul__(self, other):
        if isinstance(other, int):
            ans = self._scale_poly(self._p, other)
            return GaloisPoly(self._gf, ans)

    def __truediv__(self, other):
        q, r = self._div_poly(self._p, other._p)
        return GaloisPoly(self._gf, q), GaloisPoly(self._gf, r)

    def __floordiv__(self, other):
        q, _ = self._div_poly(self._p, other._p)
        return GaloisPoly(self._gf, q)

    def __mod__(self, other):
        _, r = self._div_poly(self._p, other._p)
        return GaloisPoly(self._gf, r)

# =======================================================================================
# =======================================================================================
    def _get_poly_degree(self, p):
        return len(p) - 1

    def _align_terms(self, f, g):
        diff = self._get_poly_degree(f) - self._get_poly_degree(g)
        if diff > 0:
            g   = [ELEMENT_ZERO]*diff + g
        elif diff < 0:
            f   = [ELEMENT_ZERO]*(-diff) + f

        return f, g

    def _scale_poly(self, p, alpha):
        ans = p.copy()
        for i, ak in enumerate(p):
            if ak != ELEMENT_ZERO:
                ans[i] = self._gf.mul(ak, alpha)[ID_POWER]
        return ans
    
    def _add_terms(self, term_stack):
        term_stack = np.atleast_2d(term_stack)
        term, power = term_stack.shape

        ans = []
        for p in range(power):
            sum = ELEMENT_ZERO
            for t in range(term):
                sum = self._gf.add(term_stack[t,p], sum)[ID_POWER]

            ans += [sum]

        return ans

    def _add_poly(self, f, g):
        # complete poly terms
        f, g = self._align_terms(f, g)

        # add same power terms
        term_stack = np.vstack((f,g))
        ans = self._add_terms(term_stack)

        return ans

    def _mul_poly(self, f, g):
        f_degree = self._get_poly_degree(f)
        g_degree = self._get_poly_degree(g)

        # expand size to match f*g final poly, reverse it so power == col index
        if g_degree > f_degree:
            long_poly   = np.array(g[::-1] + [ELEMENT_ZERO]*f_degree)
            short_poly  = np.array(f[::-1])
        else:
            long_poly   = np.array(f[::-1] + [ELEMENT_ZERO]*g_degree)
            short_poly  = np.array(g[::-1])

        term_stack = None
        for i, ak in enumerate(short_poly):
            if ak != ELEMENT_ZERO:
                # manage powers
                rotated = np.roll(long_poly, i)
                # multiply by constant
                rotated     = self._scale_poly(rotated, ak)
                term_stack  = np.array(rotated) if term_stack is None else np.vstack((term_stack, rotated))

        # final reduction, reverse to normal power-order ans[0] = xn
        ans = self._add_terms(term_stack)[::-1]

        return ans

    def _div_poly(self, f, g):
        diff = self._get_poly_degree(f) - self._get_poly_degree(g)
        if diff < 0:
            raise ValueError("ArithmeticError: Degree of f must >= to degree of g")

        step    = f
        q       = None
        for i in range(diff + 1):
            # compute new term of q for this step
            ak      = self._gf.div(step[0], g[0])[ID_POWER]
            q_term  = [ak] + diff*[ELEMENT_ZERO]
            q       = q_term if q is None else self._add_poly(q, q_term)
            # compute next step to divide
            to_add  = self._mul_poly(q_term, g)
            step    = self._add_poly(to_add, step)
            # remove leading zeros
            while len(step) > 1 and step[0] == ELEMENT_ZERO:
                step.pop(0)

            diff = self._get_poly_degree(step) - self._get_poly_degree(g)

        r = step

        return q, r

# =======================================================================================
# =======================================================================================
    def poly_from_roots(self, roots):
        if len(roots) == 1:
            poly = [ELEMENT_ONE] + roots
        else:
            poly = None
            for r in roots:
                factor  = [ELEMENT_ONE, r]
                poly    = factor if poly is None else self._mul_poly(poly, factor)

        return GaloisPoly(self._gf, poly)
