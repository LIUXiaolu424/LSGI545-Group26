# Parameter classification

The categories below distinguish empirical support from simplifying assumptions and tunable calibration parameters. None of the calibration values should be presented as an exact real-world estimate.

## A. Literature-supported ranges or policy values

| Quantity | Model representation | Interpretation |
|---|---:|---|
| Incubation period | 2–8 ticks | 12–48 hours |
| Symptomatic period | 4–12 ticks | 1–3 days |
| Post-symptom exclusion | 0 or 2 days | The intervention comparison includes a 48-hour exclusion condition |
| Asymptomatic proportion | baseline 0.22 | Approximate baseline for the model, not a certain universal value; sensitivity values are 0.10, 0.22, and 0.30 |

These ranges require appropriate citations in the submitted report. This file classifies their role but is not a literature review.

## B. Structural model assumptions

| Parameter or rule | Baseline |
|---|---:|
| Population | 200 students |
| Initial infected | 2 |
| Time step | 6 hours |
| Run length | 120 ticks / 30 days |
| Agent types | Student only |
| Spaces | bedroom, bathroom, kitchen, common room, isolation room |
| Exposed infectiousness | 0 |
| Post-symptomatic duration | 8 ticks |
| Movement | four simple daily phases, no timetable or contact network |
| Cleaning scope | bathroom, kitchen, and common room; bedrooms excluded |
| Infection-route attribution | route of first successful infection event |

## C. Calibration and sensitivity parameters

| Parameter | Baseline | Code location |
|---|---:|---|
| Direct transmission probability per co-location opportunity | 0.05 | Interface / BehaviorSpace |
| Environmental transmission multiplier | 0.03 | Interface / BehaviorSpace |
| Relative infectiousness: I-sym | 1.0 | `become-symptomatic` |
| Relative infectiousness: I-asym | 0.5 | `become-asymptomatic` |
| Relative infectiousness: P | 0.3 | `become-post-symptomatic` |
| Shedding per tick: I-sym | 0.15 | `contaminate-environment` |
| Shedding per tick: I-asym | 0.08 | `contaminate-environment` |
| Shedding per tick: P | 0.05 | `contaminate-environment` |
| Natural environmental retention per tick | 0.85 | `decay-contamination` |
| Contamination retained after cleaning | 0.10 | `perform-cleaning` |

## Intervention factors

The primary factorial design is:

- isolation compliance: `0`, `0.5`, `1`
- cleaning frequency: `0`, `1`, `2` times/day
- post-symptom exclusion: `0`, `2` days

This gives 18 conditions. The smoke test uses 2 repetitions (36 runs); the main experiment uses 50 repetitions (900 runs).
