#!/usr/bin/env python3
"""Static project validator. This is deliberately not a NetLogo compiler."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOG = ROOT / "logs" / "static_validation.txt"


def main() -> int:
    errors: list[str] = []
    notes: list[str] = []
    required = [
        "NorovirusDormABM.nlogo",
        "NorovirusDormABM.nls",
        "behaviorspace_experiments.xml",
        "experiments/behaviorspace_experiments.xml",
        "README.md",
        "PARAMETERS.md",
        "VALIDATION.md",
        "ANALYSIS_GUIDE.md",
        "scripts/run_experiments.ps1",
        "scripts/run_wsl_experiment.ps1",
        "scripts/check_results.py",
        "scripts/validate_results.py",
        "scripts/analyze_results.py",
    ]
    for relative in required:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required file: {relative}")

    nls = (ROOT / "NorovirusDormABM.nls").read_text(encoding="utf-8")
    nlogo = (ROOT / "NorovirusDormABM.nlogo").read_text(encoding="utf-8")

    procedures = re.findall(r"(?m)^to(?:-report)?\s+[\w?-]+", nls)
    endings = re.findall(r"(?m)^end\s*$", nls)
    if len(procedures) != len(endings):
        errors.append(f"procedure/end mismatch: {len(procedures)} procedures, {len(endings)} ends")
    else:
        notes.append(f"procedure/end balance: {len(procedures)}")

    required_procedures = {
        "setup", "setup-spaces", "setup-students", "seed-infections", "go",
        "enforce-isolation", "move-students", "contaminate-environment",
        "direct-transmission-step", "environmental-transmission-step",
        "infect-student", "progress-disease", "become-symptomatic",
        "become-asymptomatic", "update-isolation-status", "decay-contamination",
        "perform-cleaning", "update-statistics",
    }
    found = {p.split()[1] for p in procedures}
    missing = sorted(required_procedures - found)
    if missing:
        errors.append("missing procedures: " + ", ".join(missing))

    tick_order = [
        "enforce-isolation", "move-students", "contaminate-environment",
        "direct-transmission-step", "environmental-transmission-step",
        "progress-disease", "update-isolation-status", "decay-contamination",
        "perform-cleaning", "update-statistics", "tick",
    ]
    go_match = re.search(r"(?ms)^to go\s+(.*?)^end\s*$", nls)
    if not go_match:
        errors.append("go procedure not found")
    else:
        body = go_match.group(1)
        positions = []
        for item in tick_order:
            match = re.search(rf"(?m)^\s*{re.escape(item)}\s*$", body)
            positions.append(match.start() if match else -1)
        if any(pos < 0 for pos in positions) or positions != sorted(positions):
            errors.append("required tick order is missing or out of order")
        else:
            notes.append("required tick order present")

    for widget in ["GRAPHICS-WINDOW", "BUTTON", "SLIDER", "SWITCH", "MONITOR", "PLOT"]:
        if widget not in nlogo:
            errors.append(f"Interface widget type missing: {widget}")
    if nlogo.count("@#$#@#$#@") < 9:
        errors.append("too few NetLogo section delimiters")
    if "NetLogo 6.4.0" not in nlogo:
        errors.append("model version marker is not NetLogo 6.4.0")

    xml_path = ROOT / "experiments" / "behaviorspace_experiments.xml"
    try:
        xml_root = ET.parse(xml_path).getroot()
    except ET.ParseError as exc:
        errors.append(f"BehaviorSpace XML does not parse: {exc}")
        xml_root = None

    if xml_root is not None:
        experiments = {e.attrib["name"]: e for e in xml_root.findall("experiment")}
        for name in ["smoke_test_18x2", "main_interventions_18x50", "baseline_timeseries_50"]:
            if name not in experiments:
                errors.append(f"missing experiment: {name}")
        for name, reps in [("smoke_test_18x2", 2), ("main_interventions_18x50", 50)]:
            if name in experiments:
                exp = experiments[name]
                if int(exp.attrib.get("repetitions", "0")) != reps:
                    errors.append(f"{name}: repetitions is not {reps}")
                sets = {s.attrib["variable"]: s for s in exp.findall("enumeratedValueSet")}
                counts = [len(sets[v].findall("value")) for v in
                          ["isolation-compliance", "cleaning-frequency", "post-symptom-exclusion"]]
                if counts != [3, 3, 2]:
                    errors.append(f"{name}: factorial levels are {counts}, expected [3, 3, 2]")
                else:
                    notes.append(f"{name}: 18 conditions x {reps} repetitions = {18 * reps} runs")
                metrics = {m.text for m in exp.findall("metric")}
                required_metrics = {
                    "cumulative-infections", "final-attack-rate", "peak-infectious",
                    "time-to-peak", "outbreak-duration", "direct-infections",
                    "environmental-infections", "isolation-person-days",
                }
                if not required_metrics.issubset(metrics):
                    errors.append(f"{name}: missing required final metrics")

    # Reject accidental outputs elsewhere under the project layout.
    excluded_roots = {
        ROOT / ".runtime",
        ROOT / ".venv",
        ROOT / ".pip-cache",
        ROOT / "smart_application_assignment",
        ROOT / "group_report_presentation" / ".build",
        ROOT / "group_report_presentation" / ".codex-finalizer",
        ROOT / "group_report_presentation" / "node_modules",
        ROOT / "group_report_presentation" / "qa",
        ROOT / "group_report_presentation" / "assets",
    }
    for path in ROOT.rglob("*"):
        if any(excluded_root in path.parents or path == excluded_root
               for excluded_root in excluded_roots):
            continue
        if path.is_file() and path.suffix.lower() in {".csv", ".png"}:
            allowed = ((ROOT / "results" in path.parents) or
                       (ROOT / "figures" in path.parents) or
                       (ROOT / "logs" in path.parents))
            if not allowed:
                errors.append(f"output file outside results/ or figures/: {path.relative_to(ROOT)}")

    status = "STATIC VALIDATION: PASS" if not errors else "STATIC VALIDATION: FAIL"
    lines = [status]
    lines.extend(f"- {item}" for item in notes)
    lines.extend(f"- ERROR: {item}" for item in errors)
    lines.append("- NOTE: static validation is not NetLogo compilation or execution")
    receipt = "\n".join(lines) + "\n"
    LOG.parent.mkdir(parents=True, exist_ok=True)
    LOG.write_text(receipt, encoding="utf-8")
    print(receipt, end="")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
