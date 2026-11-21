# Norovirus Dormitory ABM

**Title:** Agent-Based Modelling of Norovirus Transmission and Intervention Strategies in a University Dormitory

This NetLogo 6.4.x project models direct and environment-mediated norovirus transmission among a single agent type (`Student`) in a stylised dormitory. One tick is six hours and each run ends at 120 ticks (30 days).

## Directory layout

```text
LSGI545/
├── NorovirusDormABM.nlogo          NetLogo model and Interface
├── NorovirusDormABM.nls            independently inspectable source
├── behaviorspace_experiments.xml   full BehaviorSpace import file
├── experiments/                    canonical full experiment definitions
├── scripts/                        validation, headless runner, analysis
├── results/                        BehaviorSpace CSV output only
├── figures/                        analysis figures only
├── logs/                           run logs and validation receipts
├── PARAMETERS.md
├── VALIDATION.md
├── RESULTS_SUMMARY.md
└── ANALYSIS_GUIDE.md
```

All project-generated files are kept inside this directory.

## Completed execution status

The saved deliverable has been compiled and run with NetLogo 6.4.0 headless. It includes the 36-run smoke test, 25 dedicated validation runs, the full 900-run intervention experiment, and a 50-repetition baseline time series. See `VALIDATION.md` for the test-by-test receipt and `RESULTS_SUMMARY.md` for report-ready findings.

## NetLogo Desktop

1. Install NetLogo 6.4.0 (or another compatible 6.4.x release).
2. Open `NorovirusDormABM.nlogo`.
3. Click **setup**, then **go**. The run stops at tick 120.
4. Open **Tools → BehaviorSpace** and run `smoke_test_18x2` first.
5. Export its table to `results/smoke_test_18x2.csv`.
6. Only after the smoke and validation checks pass, run `main_interventions_18x50` and export to `results/main_interventions_18x50.csv`.

The model uses `__includes ["NorovirusDormABM.nls"]`, so keep the `.nlogo` and `.nls` files together.

## Headless execution on Windows

From PowerShell in the project directory:

```powershell
.\scripts\run_experiments.ps1 -NetLogoHome 'C:\Program Files\NetLogo 6.4.0' -Stage Smoke
.\scripts\run_experiments.ps1 -NetLogoHome 'C:\Program Files\NetLogo 6.4.0' -Stage Validation
.\scripts\run_experiments.ps1 -NetLogoHome 'C:\Program Files\NetLogo 6.4.0' -Stage Main
.\scripts\run_experiments.ps1 -NetLogoHome 'C:\Program Files\NetLogo 6.4.0' -Stage Timeseries
```

The runner refuses the `Main` stage unless a smoke CSV is present and passes `scripts/check_results.py`.

This project also contains a local-runtime runner used during development when NetLogo is available through WSL:

```powershell
.\scripts\run_wsl_experiment.ps1 -Experiment smoke_test_18x2 -OutputName smoke_test_18x2.csv
```

## Static checks

```powershell
python .\scripts\validate_project.py
```

Static checks do **not** prove that NetLogo compiles or that experiments ran. Actual run status is recorded in `VALIDATION.md` and `logs/`.

## Analysis

After main and baseline time-series CSV files exist:

```powershell
python .\scripts\analyze_results.py
```

This creates scenario summaries in `results/` and publication-ready PNG files in `figures/`.

## Model scope

The model intentionally excludes GIS, multiple floors, extra agent types, demographic attributes, vaccination, explicit food transmission, viral-load curves, machine learning, and 3-D visualization. Environmental contamination is normalized to `[0, 1]`; it is not a virus-particle count.
