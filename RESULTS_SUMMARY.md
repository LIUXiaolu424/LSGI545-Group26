# Results summary for report and presentation

## Experiment design

- Model horizon: 120 ticks (30 days; 1 tick = 6 hours).
- Main factorial experiment: 3 isolation-compliance levels x 3 cleaning frequencies x 2 post-symptom exclusion periods.
- Replications: 50 per condition, 900 runs in total.
- Uncertainty in the scenario chart: mean plus/minus 95% confidence interval.

## Main findings

1. Isolation compliance was the strongest intervention in this calibrated model. Averaged across cleaning and exclusion settings, mean final attack rate fell from 0.3773 at compliance 0 to 0.0140 at compliance 1.
2. In the no-isolation, no-cleaning, no-post-exclusion condition, mean final attack rate was 0.5286 (95% CI half-width 0.0683), mean peak infectious count was 28.26, and mean direct/environmental infections were 80.46/23.26.
3. With full isolation compliance, two cleanings per day, and two post-symptom exclusion days, mean final attack rate was 0.0114 (95% CI half-width 0.0011), close to the seeded proportion of 0.0100.
4. Cleaning reduced the environmental component. With no isolation and no post-symptom exclusion, mean environmental infections fell from 23.26 at zero cleaning to 5.44 at two cleanings per day; mean attack rate fell from 0.5286 to 0.2877.
5. Direct-attributed counts exceeded environmental-attributed counts in high-transmission conditions under direct-first ordering. These are not independent causal shares: direct infection is attempted first and successful targets immediately leave S. Isolation changes both contacts and shedding locations.
6. Post-symptom exclusion was most interpretable when isolation compliance was above zero. Differences between exclusion settings at compliance 0 are stochastic sampling differences because no student accepts isolation in that condition; they should not be interpreted as a causal exclusion effect.

## Suggested presentation wording

"Across 900 stochastic simulations, isolation compliance produced the largest reduction in outbreak size. Cleaning mainly reduced environmental transmission, while the additional 48-hour exclusion period offered a smaller incremental benefit when isolation was actually followed. These are model-based comparative results, not fitted real-world effect estimates."

## Reusable outputs

- Scenario-level statistics: `results/scenario_summary.csv`.
- Full run-level results: `results/main_interventions_18x50.csv`.
- Baseline time-series results: `results/baseline_timeseries_50.csv`.
- Attack-rate comparison: `figures/figure1_attack_rate_18_scenarios.png`.
- Baseline epidemic curve: `figures/figure2_baseline_epidemic_curve.png`.
- Intervention heatmaps: `figures/figure3_heatmap_exclusion_0.png` and `figures/figure3_heatmap_exclusion_2.png`.
- Transmission-route comparison: `figures/figure4_transmission_routes.png`.

## Interpretation limits

- Transmission, shedding, decay, cleaning effectiveness, and relative infectiousness values are calibration assumptions.
- The model is a stylised dormitory, not a fitted campus reconstruction.
- Repetitions were not paired using aligned common random streams; seeds were not explicitly recorded.
- The 0.22 asymptomatic branching probability is assumed, not fitted from the cited asymptomatic-test positivity estimate.
- At full compliance and zero exclusion, cleaning means 0.0162 versus 0.0159 differ by 0.0003; the approximate 95% difference interval spans zero. No formal factorial interaction test was performed.
- Two-day exclusion covers the entire fixed eight-tick P state; longer post-symptom shedding is not represented.
- Saved final records have exported `[step] = 119`; baseline observations span steps 0–119. These should not be labelled verified tick-120 observations.
- Results support comparison among model scenarios; they are not forecasts or clinical/public-health effect estimates.
