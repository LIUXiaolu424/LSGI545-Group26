# Validation record

This document separates static inspection from actual NetLogo execution. All PASS statuses below are backed by saved CSV or log evidence.

## Environment status

- Target runtime: NetLogo 6.4.0.
- NetLogo discovered system-wide at project creation: **No**.
- Java discovered on Windows `PATH` at project creation: **No**.
- Python discovered: **Yes, Python 3.11.9**.
- Project runtime used: **official NetLogo 6.4.0 headless classes with OpenJDK 11 under WSL**.
- NetLogo compilation status: **PASS — model compiled during every headless experiment**.
- BehaviorSpace execution status: **PASS — validation, 36-run smoke test, 900-run main experiment, and 50-run baseline time series completed**.

## Required dynamic tests

| Test | Configuration and acceptance rule | Status | Evidence |
|---|---|---|---|
| 1. Zero initial infection | `initial-infected = 0`; final cumulative infections must be 0 | PASS | `results/validation_zero_initial.csv`: 5/5 runs ended at 0 |
| 2. Zero transmission | both transmission parameters 0; cumulative infections must equal initial infected and both route counts must be 0 | PASS | `results/validation_zero_transmission.csv`: 10/10 runs ended at 2, with both route counts 0 |
| 3. Environment disabled | `environmental-transmission? = false`; environmental infections must be 0 | PASS | `results/validation_environment_off.csv`: 10/10 runs had 0 environmental infections |
| 4. Population conservation | `population-conserved?` must remain true; a final check is included in every main metric set | PASS | All 25 dedicated validation runs passed the conservation reporter |
| 5. Isolation direction | across repeated matched conditions, mean attack rate for compliance 1 should be lower than for 0 | PASS | Main experiment means: compliance 0 = 0.3773; compliance 1 = 0.0140 |
| 6. Cleaning direction | increased cleaning should lower mean contamination and usually environmental infections | PASS | Main experiment mean final contamination: cleaning 0 = 0.00121909; cleaning 2 = 0.000307711 |
| 7. Stochasticity | repeated identical parameter runs should not all return identical outputs | PASS | Smoke test contained 14 distinct cumulative-infection outcomes |

## Experiment receipts

- Smoke test: `results/smoke_test_18x2.csv`, 36 runs, 18 conditions x 2 repetitions, PASS.
- Main experiment: `results/main_interventions_18x50.csv`, 900 runs, 18 conditions x 50 repetitions, PASS.
- Baseline time series: `results/baseline_timeseries_50.csv`, 50 stochastic repetitions across 120 ticks, PASS.
- Machine-readable validation summary: `logs/dynamic_validation.txt`.

## Static checks

Static checks cover required files, NetLogo section delimiters and Interface widgets, procedure/end balance, experiment XML parsing, factorial counts, required metrics, and output-directory containment. Their latest receipt is written to `logs/static_validation.txt` when `scripts/validate_project.py` is executed.

Passing static checks is not a NetLogo compiler result.

## Directional-test caution

Tests 5 and 6 assess averages over repeated stochastic runs. A single paired run is not required to follow the expected direction.
