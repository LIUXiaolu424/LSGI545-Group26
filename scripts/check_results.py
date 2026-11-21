#!/usr/bin/env python3
"""Gate a BehaviorSpace smoke result before the 900-run experiment."""

from __future__ import annotations

import csv
import sys
from collections import Counter
from pathlib import Path


def read_behaviorspace(path: Path) -> list[dict[str, str]]:
    lines = path.read_text(encoding="utf-8-sig").splitlines()
    start = next((i for i, line in enumerate(lines) if line.lstrip().startswith('"[run number]"') or line.startswith("[run number]")), None)
    if start is None:
        raise ValueError("BehaviorSpace header row beginning with [run number] was not found")
    return [row for row in csv.DictReader(lines[start:]) if row.get("[run number]")]


def truthy(value: str) -> bool:
    return value.strip().lower() in {"true", "1", "1.0"}


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "results" / "smoke_test_18x2.csv"
    errors: list[str] = []
    if not path.is_file():
        print(f"SMOKE CHECK: FAIL\n- missing {path}")
        return 1
    try:
        rows = read_behaviorspace(path)
    except Exception as exc:
        print(f"SMOKE CHECK: FAIL\n- {exc}")
        return 1

    if len(rows) != 36:
        errors.append(f"expected 36 final rows, found {len(rows)}")
    factors = ["isolation-compliance", "cleaning-frequency", "post-symptom-exclusion"]
    missing = [name for name in factors if name not in (rows[0] if rows else {})]
    if missing:
        errors.append("missing factor columns: " + ", ".join(missing))
    else:
        combinations = Counter(tuple(row[name] for name in factors) for row in rows)
        if len(combinations) != 18 or any(count != 2 for count in combinations.values()):
            errors.append("factorial coverage is not 18 combinations x 2 repetitions")

    for index, row in enumerate(rows, 1):
        try:
            attack = float(row["final-attack-rate"])
            cumulative = float(row["cumulative-infections"])
            if not 0 <= attack <= 1:
                errors.append(f"row {index}: attack rate outside [0,1]")
            if not 0 <= cumulative <= 200:
                errors.append(f"row {index}: cumulative infections outside [0,200]")
            if "population-conserved?" in row and not truthy(row["population-conserved?"]):
                errors.append(f"row {index}: population conservation failed")
        except (KeyError, ValueError) as exc:
            errors.append(f"row {index}: invalid required metric ({exc})")
            break

    if rows:
        cumulative_values = [float(row["cumulative-infections"]) for row in rows]
        if max(cumulative_values) <= 2:
            errors.append("no run produced secondary transmission; smoke output is epidemiologically degenerate")
        if len(set(cumulative_values)) < 3:
            errors.append("too little between-run variation; inspect stochastic behavior and calibration")

    if errors:
        print("SMOKE CHECK: FAIL")
        for item in errors[:20]:
            print(f"- {item}")
        return 1
    print("SMOKE CHECK: PASS")
    print("- 36 rows")
    print("- 18 conditions x 2 repetitions")
    print("- metric ranges and final population conservation valid")
    print("- secondary transmission and stochastic variation observed")
    attacks = [float(row["final-attack-rate"]) for row in rows]
    secondary = sum(float(row["cumulative-infections"]) > 2 for row in rows)
    print(f"- attack rate min/mean/max = {min(attacks):.3f}/{sum(attacks) / len(attacks):.3f}/{max(attacks):.3f}")
    print(f"- secondary transmission occurred in {secondary}/{len(rows)} runs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
