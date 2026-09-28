"""Run bounded envelope checks using an existing schema-130 profile."""

import argparse
import json
import os
from pathlib import Path
import subprocess

import h5py
import numpy as np


def read_summary(path):
    lines = path.read_text().splitlines()
    i = next(i for i, line in enumerate(lines) if "Re(omega)" in line)
    names = lines[i].split()
    return [dict(zip(names, map(float, line.split()))) for line in lines[i+1:] if line.strip()]


def inlist(profile, ell, alpha, n_iter=60, conv="FROZEN_PESNELL_4", x_i=0.1):
    control = "" if alpha is None else f"  tdc_alpha_M = {alpha}\n"
    return f"""&constants
/
&model
  model_type = 'EVOL'
  file = '{profile}'
  file_format = 'MESA'
  interp_type = 'LINEAR'
/
&mode
  l = {ell}
/
&rot
/
&osc
  adiabatic = .false.
  nonadiabatic = .true.
  variables_set = 'GYRE'
  inner_bound = 'ZERO_R'
  outer_bound = 'JCD'
  conv_scheme = '{conv}'
  alpha_hfc = {1 if conv == 'PERTURBED_TDC_LOCAL' else 0}
  tdc_include_Pturb = .true.
{control}/
&num
  diff_scheme = 'COLLOC_GL2'
  nad_matrix_solver = 'BANDED'
  nad_search = 'FILE'
  file = 'seeds.h5'
  file_format = 'SUMMARY'
  deflate_roots = .false.
  restrict_roots = .false.
  n_iter_max = {n_iter}
/
&scan
  grid_type = 'INVERSE'
  freq_min = 8.333333333333333d-4
  freq_max = 0.1d0
  freq_units = 'CYC_PER_DAY'
  n_freq = 500
/
&grid
  scaffold_src = 'FILE'
  file = 'grid.txt'
  file_format = 'TEXT'
  x_i = {x_i}
  w_osc = 0
  w_exp = 0
  w_ctr = 0
  w_thm = 0
  dx_min = 1d-12
/
&ad_output
/
&nad_output
  summary_file = 'summary.txt'
  summary_file_format = 'TXT'
  summary_item_list = 'id,l,n_p,n_g,omega,freq,E_norm,chi,n_iter'
  detail_template = 'mode_%id.h5'
  detail_item_list = 'l,omega,freq,x,xi_r,xi_h,lag_P,lag_T,lag_L'
  freq_units = 'CYC_PER_DAY'
/
"""


def run_case(binary, folder, text, grid, seeds, timeout):
    folder.mkdir(parents=True, exist_ok=False)
    (folder/"gyre.in").write_text(text)
    np.savetxt(folder/"grid.txt", grid, fmt="%.17e")
    values = np.array([(w.real, w.imag) for w in seeds], dtype=[("re", "<f8"), ("im", "<f8")])
    with h5py.File(folder/"seeds.h5", "w") as stream:
        stream.create_dataset("omega", data=values)
    env = os.environ | {"OMP_NUM_THREADS": "10", "OPENBLAS_NUM_THREADS": "1"}
    print(folder.name, flush=True)
    with (folder/"gyre.log").open("w") as log:
        result = subprocess.run([str(binary), "gyre.in"], cwd=folder, env=env,
                                stdout=log, stderr=subprocess.STDOUT, timeout=timeout)
    if result.returncode:
        raise RuntimeError(f"GYRE failed: {folder/'gyre.log'}")
    rows = read_summary(folder/"summary.txt") if (folder/"summary.txt").exists() else []
    if not rows:
        raise RuntimeError(f"No converged roots: {folder/'gyre.log'}")
    print([(r["Re(freq)"], r["Im(freq)"]) for r in rows], flush=True)
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--previous-binary", type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--degrees", nargs="+", type=int, default=[0, 1, 2, 3])
    parser.add_argument("--points", type=int, default=4000)
    parser.add_argument("--period", type=float, default=120.)
    parser.add_argument("--first-p-order", type=int, default=1)
    parser.add_argument("--timeout", type=int, default=240)
    args = parser.parse_args()
    profile, binary = args.profile.resolve(), args.binary.resolve()
    _, mass, radius, _, version = profile.open().readline().split()
    if int(version) != 130:
        raise ValueError("Requires a schema-130 profile")
    dyn = np.sqrt(6.67430e-8*float(mass)/float(radius)**3)
    grid = np.geomspace(.1, 1., args.points)
    guess = 2*np.pi/(args.period*86400*dyn)
    seeds = guess*np.array([1., 1.7, 2.5])*(1+0.01j)
    results = {}
    for ell in args.degrees:
        ad_text = inlist(profile, ell, None).replace("\n  adiabatic = .false.", "\n  adiabatic = .true.")
        ad_text = ad_text.replace("\n  nonadiabatic = .true.", "\n  nonadiabatic = .false.")
        ad_text = ad_text.replace("&ad_output\n/", "&ad_output\n  summary_file = 'summary.txt'\n"
            "  summary_file_format = 'TXT'\n  freq_units = 'CYC_PER_DAY'\n"
            "  summary_item_list = 'id,l,n_p,n_g,omega,freq,E_norm,chi,n_iter'\n/")
        ad = run_case(binary, args.output/f"l{ell}_ad", ad_text, grid, seeds, args.timeout)
        acoustic = [r for r in ad if r["n_p"] >= args.first_p_order and r["n_g"] == 0]
        if not acoustic:
            raise RuntimeError(f"No acoustic seeds for ell={ell}")
        seeds = [r["Re(omega)"]*(shift+0.01j) for r in acoustic[:3] for shift in (0.985,1.015)]
        cases = [("default", None, binary), ("zero", "0d0", binary),
                 ("override", "0.15d0", binary), ("profile", "-1d0", binary)]
        if args.previous_binary:
            cases.insert(0, ("previous", None, args.previous_binary.resolve()))
        for label, alpha, exe in cases:
            name = f"l{ell}_{label}"
            results[name] = run_case(exe, args.output/name,
                inlist(profile, ell, alpha), grid, seeds, args.timeout)
        assert results[f"l{ell}_default"] == results[f"l{ell}_zero"]
        if args.previous_binary:
            assert results[f"l{ell}_previous"] == results[f"l{ell}_zero"]
        # Interpolation of the imported coefficient can change its last bit.
        imported = results[f"l{ell}_profile"]
        overridden = results[f"l{ell}_override"]
        assert len(imported) == len(overridden)
        for a, b in zip(imported, overridden):
            wa = complex(a["Re(omega)"], a["Im(omega)"])
            wb = complex(b["Re(omega)"], b["Im(omega)"])
            assert abs(wa-wb) < 1e-11*abs(wb)
        base = results[f"l{ell}_override"]
        seeds_refine = [complex(r["Re(omega)"], r["Im(omega)"]) for r in base]
        for label, points, conv in [("refined", 2*args.points, "FROZEN_PESNELL_4"),
                                    ("tdc", args.points, "PERTURBED_TDC_LOCAL")]:
            name = f"l{ell}_{label}"
            trial_seeds = seeds_refine if label == "refined" else [w*shift for w in seeds_refine for shift in (0.985,1.015)]
            results[name] = run_case(binary, args.output/name,
                inlist(profile, ell, "0.15d0", conv=conv),
                np.geomspace(.1, 1., points), trial_seeds, args.timeout)
        (args.output/"results.json").write_text(json.dumps(results, indent=2)+"\n")
    print("PASS: default, zero, imported and overridden coefficients", flush=True)


if __name__ == "__main__":
    main()
