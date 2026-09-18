"""Check the spherical stress divergence against its component expansion."""

import unittest

import sympy as sp


class StressTensor(unittest.TestCase):
    def test_spherical_components(self):
        r, theta = sp.symbols("r theta", positive=True)
        mu = (1+r)*(1+r**2)
        ur, uh = r+r**2, r**3-r
        for ell in range(4):
            with self.subTest(ell=ell):
                lam = ell*(ell+1)
                Y = sp.legendre(ell, sp.cos(theta))
                dY = sp.diff(Y, theta)
                div = (sp.diff(ur, r)+2*ur/r-lam*uh/r)*Y
                rr = 2*mu*(sp.diff(ur, r)*Y-div/3)
                rh = mu*(sp.diff(uh, r)-uh/r+ur/r)*dY
                tt = 2*mu*(ur*Y/r+uh*sp.diff(dY, theta)/r-div/3)
                pp = 2*mu*(ur*Y/r+uh*sp.cot(theta)*dY/r-div/3)
                fr = sp.diff(rr, r)+(2*rr-tt-pp)/r+(sp.diff(rh, theta)+sp.cot(theta)*rh)/r
                fh = sp.diff(rh, r)+3*rh/r+(sp.diff(tt, theta)+(tt-pp)*sp.cot(theta))/r
                nr = 2*mu*(sp.diff(ur, r)-(sp.diff(ur, r)+2*ur/r-lam*uh/r)/3)
                tr = mu*(sp.diff(uh, r)-uh/r+ur/r)
                expect_r = (sp.diff(nr, r)+3*nr/r-lam*tr/r)*Y
                expect_h = (sp.diff(tr, r)+3*tr/r-nr/(2*r)+mu*(2-lam)*uh/r**2)*dY
                self.assertEqual(sp.simplify(sp.trigsimp(sp.expand_trig(fr-expect_r), method="fu")), 0)
                self.assertEqual(sp.simplify(sp.trigsimp(sp.expand_trig(fh-expect_h), method="fu")), 0)

    def test_zero_shear(self):
        r = sp.symbols("r", positive=True)
        # Homologous radial expansion has no trace-free strain.
        self.assertEqual(sp.diff(r, r)-r/r, 0)
        # Rigid translation is the ell=1 field ur=uh=constant.
        ur = uh = sp.Integer(1)
        div = sp.diff(ur, r)+2*ur/r-2*uh/r
        self.assertEqual(div, 0)
        self.assertEqual(sp.diff(ur, r)-div/3, 0)
        self.assertEqual(sp.diff(uh, r)-uh/r+ur/r, 0)


if __name__ == "__main__":
    unittest.main()
