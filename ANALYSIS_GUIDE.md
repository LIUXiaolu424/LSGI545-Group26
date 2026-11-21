# Analysis guide

## Required input

- `results/main_interventions_18x50.csv`: final metrics for 900 runs.
- `results/baseline_timeseries_50.csv`: per-tick metrics for a baseline condition.
- Optional validation CSV files produced by `scripts/run_experiments.ps1 -Stage Validation`.

BehaviorSpace files contain metadata rows before the actual CSV header. The analysis scripts locate the row beginning with `[run number]` automatically.

## Outputs

Run:

```powershell
python .\scripts\analyze_results.py
```

Expected outputs:

- `results/scenario_summary.csv`: 18-condition means, standard errors, and 95% confidence intervals.
- `figures/figure1_attack_rate_18_scenarios.png`: mean final attack rate with 95% CI.
- `figures/figure2_baseline_epidemic_curve.png`: mean state counts over time with 95% CI bands when repetitions permit.
- `figures/figure3_heatmap_exclusion_0.png` and `figure3_heatmap_exclusion_2.png`: isolation × cleaning heatmaps.
- `figures/figure4_transmission_routes.png`: mean direct versus environmental infections by scenario.

## Interpretation

Report both outcome and burden metrics. A strategy may reduce attack rate but increase isolation person-days. Compare the two post-symptom exclusion panels to isolate the incremental effect of the 48-hour rule. Treat route counts as model-attributed transmission events, not observed causal classifications.

## Reproducibility

Do not manually delete BehaviorSpace metadata or rename raw output columns. Preserve raw CSV files and generate summaries from scripts. Record the NetLogo version, experiment name, date, and any changed calibration parameters in the report.
