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

Report both outcome and burden metrics. Isolation person-days are not monotonic with compliance: pooled means are 0, 11.80 and 6.21 at compliance 0, 0.5 and 1. Compare exclusion policies only where students isolate; differences at compliance 0 are sampling variation, not a policy effect.

Route counts are model-attributed, not independent causal shares: direct transmission is attempted first, so competing successful opportunities are preferentially assigned to that route. Heatmaps describe sample means; no formal factorial interaction test was performed. At full compliance and zero exclusion, the 0.0003 cleaning difference is small and its approximate 95% difference interval spans zero.

## Reproducibility

Do not manually delete BehaviorSpace metadata or rename raw output columns. Preserve raw CSV files and generate summaries from scripts. Record the NetLogo version, experiment name, date, and any changed calibration parameters in the report.

Saved final records have `[step] = 119`; baseline records have steps 0–119, including the initial observation. Distinguish these indices from the configured 120-tick stopping horizon. No explicit random seeds were recorded. Properly aligned common random streams could reduce variance in future paired comparisons; identical starting seeds alone do not guarantee aligned random calls.
