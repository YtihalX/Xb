"""Stage 6: panel convergence at recorded 2++ interior and near-threshold probes.

From the repo root, build xb2c (cd code/xb2c; zig build -Doptimize=ReleaseFast),
then run: uv run --script checks/stage6_panel_convergence.py

Same baseline fit, S40 path and node set at each energy; only L_p or n_p
changes. The on-shell T target and scaling are those of NOTEBOOK.md,
Tolerances, and test/seam1.zig, continuity. D~ drift is diagnostic, not a
bound on a pole displacement. No zero search or pole refinement is done.
"""

from concurrent.futures import ThreadPoolExecutor
import json
import math
from pathlib import Path
import re
import subprocess
from tempfile import TemporaryDirectory

XB2C = Path(__file__).resolve().parents[1] / "code/xb2c"
# Energies in GeV from 2 m_Bstar; sheets and node masks in (BB, BB*, B*B*) order.
PROBES = (
    ("lower strip", complex(-0.06785, -0.010), "(-,+,+)", [1, 0, 0]),
    ("upper strip", complex(-0.02262, -0.010), "(-,-,+)", [1, 1, 0]),
    # Centres of examples B and Bd of notes/07-continued-lse/cert_conditions.py.
    ("B", complex(-0.0458, -0.00030), "(-,+,+)", [1, 1, 0]),
    ("Bd", complex(-0.04665, -0.00035), "(-,+,+)", [1, 0, 0]),
    # Inside the lowest-C5-margin cell of the upper strip, toward its upper-right corner:
    # the small scan box there keeps the VV near node, unlike the one at the cell centre.
    ("upper C5", complex(-0.0012, -0.0013), "(-,-,+)", [1, 1, 1]),
    # 0.5 MeV above BB: at this depth the flat path does not pass the pion window.
    ("BB kernel window", complex(-0.08996, -0.010), "(-,+,+)", [1, 0, 0]),
)
RULES = ((250, 16), (125, 16), (250, 32))  # (L_p in MeV, n_p)
T_TARGET = 1e-6


def scan(model, workdir, rule, probe):
    length, degree = rule
    name, e, sheet, nodes = probe
    workdir.mkdir()
    config = workdir / "probe.zon"
    config.write_text(
        f"""{model}
    .quadrature = .{{ .panel_nodes = {degree}, .panel_length = {length / 1000}, .pole_margin = 0.05 }},
    .scan = .{{ .re = .{{ {e.real}, {e.real} }}, .points = 1, .im = {e.imag}, .box = 1e-6 }},
    .workers = 1,
    .output = "probe.jsonl",
}}
""",
        encoding="utf-8",
    )
    subprocess.run([XB2C / "zig-out/bin/xb2c", config.name], cwd=workdir, check=True)
    with (workdir / "probe.jsonl").open(encoding="utf-8") as output:
        records = [r for r in map(json.loads, output) if r["kind"] == "scan"]
    if len(records) != 1:
        raise SystemExit(f"FAIL {rule} {name}: expected one scan record, got {len(records)}")
    record = records[0]
    cert = record["certificate"]
    if (record["E"], record["sheet"], cert["failed"], cert["node"]) != ([e.real, e.imag], sheet, 0, nodes):
        raise SystemExit(f"FAIL {rule} {name}: unexpected sheet, energy or certificate: {cert}")
    if name == "Bd" and cert["dropped"][1] != 5:
        raise SystemExit(f"FAIL {rule} Bd: expected the BB* near node to be dropped by C5")
    if record["log_det"] is None:
        raise SystemExit(f"FAIL {rule} {name}: no determinant at {e} GeV")
    t = tuple(complex(*v) for v in record["t"] if v is not None)
    channels = nodes[0] + nodes[1] + 4 * nodes[2]
    if len(t) != channels ** 2 or not all(math.isfinite(abs(v)) for v in t):
        raise SystemExit(f"FAIL {rule} {name}: incomplete on-shell T at {e} GeV")
    return complex(*record["log_det"]), t, cert["n_path"], cert["depth"]


def determinant_drift(ld, reference):
    a = ld.real - reference.real
    b = math.remainder(ld.imag - reference.imag, math.tau)
    # |exp(a+ib)-1|, without subtracting two nearly equal exponentials.
    return math.hypot(math.expm1(a), 2 * math.exp(a / 2) * math.sin(b / 2))


def main():
    config = (XB2C / "config/scan-2pp.zon").read_text(encoding="utf-8")
    # Keep the checked-in sector and model parameters, not its scan grid or output path.
    model, _ = re.split(r"(?m)^\s*\.quadrature\s*=", config, maxsplit=1)
    with TemporaryDirectory(prefix="xb2c-stage6-") as tmp, ThreadPoolExecutor(max_workers=6) as pool:
        runs = [
            [pool.submit(scan, model, Path(tmp) / f"{i}-{j}", rule, probe)
             for j, probe in enumerate(PROBES)]
            for i, rule in enumerate(RULES)
        ]
        values = [[run.result() for run in batch] for batch in runs]

    failed = False
    print("E in MeV from 2 m_Bstar; rules (L_p in MeV, n_p); eps_T target 1e-6")
    for probe, (name, e, sheet, _) in enumerate(PROBES):
        for i, j in ((0, 1), (0, 2), (1, 2)):
            ld, t, n, depth = values[i][probe]
            ld_ref, t_ref, n_ref, depth_ref = values[j][probe]
            if depth != depth_ref:
                raise SystemExit(f"FAIL {name}: the contour depth changed with the panel rule")
            scale = max(abs(v) for v in t_ref)
            if scale == 0:
                raise SystemExit(f"FAIL {RULES[j]} {name}: undefined relative T error at {e} GeV")
            dt = max(abs(a - b) for a, b in zip(t, t_ref, strict=True)) / scale
            dd = determinant_drift(ld, ld_ref)
            ok = dt <= T_TARGET
            failed |= not ok
            print(f"{'PASS' if ok else 'FAIL'} {name}: {1000*e.real:.8g}{1000*e.imag:+.6g}i {sheet} "
                  f"{RULES[i]} -> {RULES[j]} ({n}->{n_ref} path nodes, depth={1000*depth:.4g} MeV): "
                  f"eps_D={dd:.6g} eps_T={dt:.6g}")
    return failed


if __name__ == "__main__":
    raise SystemExit(main())
