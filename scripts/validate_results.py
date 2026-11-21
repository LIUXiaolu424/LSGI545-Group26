#!/usr/bin/env python3
"""Validate actual NetLogo BehaviorSpace result files."""

from __future__ import annotations

import csv
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
RECEIPT = ROOT / "logs" / "dynamic_validation.txt"


def read_bs(name: str) -> list[dict[str, str]]:
    path = RESULTS / name
    lines = path.read_text(encoding="utf-8-sig").replace("\x00", "").splitlines()
    start = next(i for i, line in enumerate(lines) if line.lstrip().startswith('"[run number]"') or line.startswith("[run number]"))
    return [row for row in csv.DictReader(lines[start:]) if row.get("[run number]")]


def true(value: str) -> bool:
    return value.strip().lower() == "true"


def main() -> int:
    checks: list[tuple[str, bool, str]] = []
    zero_initial = read_bs("validation_zero_initial.csv")
    checks.append(("Test 1 zero initial infection",
                   len(zero_initial) == 5 and all(float(r["cumulative-infections"]) == 0 for r in zero_initial),
                   f"runs={len(zero_initial)}, cumulative={sorted({r['cumulative-infections'] for r in zero_initial})}"))

    zero_tx = read_bs("validation_zero_transmission.csv")
    zero_tx_ok = len(zero_tx) == 10 and all(
        float(r["cumulative-infections"]) == 2 and float(r["direct-infections"]) == 0 and
        float(r["environmental-infections"]) == 0 for r in zero_tx)
    checks.append(("Test 2 zero transmission", zero_tx_ok,
                   f"runs={len(zero_tx)}, cumulative={sorted({r['cumulative-infections'] for r in zero_tx})}"))

    env_off = read_bs("validation_environment_off.csv")
    checks.append(("Test 3 environment disabled",
                   len(env_off) == 10 and all(float(r["environmental-infections"]) == 0 for r in env_off),
                   f"runs={len(env_off)}, environmental infections={sorted({r['environmental-infections'] for r in env_off})}"))

    all_validation = zero_initial + zero_tx + env_off
    checks.append(("Test 4 population conservation",
                   all(true(r["population-conserved?"]) for r in all_validation),
                   f"checked {len(all_validation)} validation runs"))

    smoke = read_bs("smoke_test_18x2.csv")
    smoke_cumulative = [float(r["cumulative-infections"]) for r in smoke]
    checks.append(("Test 7 stochastic variation",
                   len(set(smoke_cumulative)) >= 3,
                   f"{len(set(smoke_cumulative))} distinct cumulative-infection outcomes across {len(smoke)} runs"))

    main_path = RESULTS / "main_interventions_18x50.csv"
    if main_path.is_file():
        main_rows = read_bs(main_path.name)
        attack_by_iso: dict[float, list[float]] = {}
        contamination_by_cleaning: dict[float, list[float]] = {}
        for row in main_rows:
            attack_by_iso.setdefault(float(row["isolation-compliance"]), []).append(float(row["final-attack-rate"]))
            contamination_by_cleaning.setdefault(float(row["cleaning-frequency"]), []).append(float(row["mean-contamination"]))
        iso0 = statistics.mean(attack_by_iso[0.0])
        iso1 = statistics.mean(attack_by_iso[1.0])
        clean0 = statistics.mean(contamination_by_cleaning[0.0])
        clean2 = statistics.mean(contamination_by_cleaning[2.0])
        checks.append(("Test 5 isolation direction", iso1 < iso0,
                       f"mean attack rate: compliance 0={iso0:.4f}, compliance 1={iso1:.4f}"))
        checks.append(("Test 6 cleaning direction", clean2 < clean0,
                       f"mean final contamination: cleaning 0={clean0:.6g}, cleaning 2={clean2:.6g}"))
    else:
        checks.append(("Test 5 isolation direction", False, "NOT RUN: main CSV absent"))
        checks.append(("Test 6 cleaning direction", False, "NOT RUN: main CSV absent"))

    hard_failures = [name for name, passed, detail in checks[:5] if not passed]
    lines = ["DYNAMIC VALIDATION RECEIPT (actual NetLogo 6.4.0 output)"]
    for name, passed, detail in checks:
        status = "PASS" if passed else ("NOT RUN" if detail.startswith("NOT RUN") else "FAIL")
        lines.append(f"- {name}: {status} - {detail}")
    RECEIPT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 1 if hard_failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
