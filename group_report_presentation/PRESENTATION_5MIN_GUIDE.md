# Five-minute academic presentation guide

Use `output/Norovirus_Dormitory_ABM_Group_Presentation.pptx`: **eight main slides and two hidden appendices**. The spoken script below is also embedded in PowerPoint Speaker Notes.

## Timing and rehearsal schedule

| Slide | Section & Title | Target | Cumulative |
|---|---|---|---|
| 1 | Formal Cover: *Agent-Based Modelling of Norovirus Transmission and Intervention Strategies in a University Dormitory* | 15 s | 0:15 |
| 2 | 1 · Background: *Background and research objectives* | 25 s | 0:40 |
| 3 | 2 · Model: *Model structure and transmission rules* | 40 s | 1:20 |
| 4 | 3 · Experiment: *Experimental design and verification* | 35 s | 1:55 |
| 5 | 4 · Baseline: *Baseline outbreak dynamics* | 30 s | 2:25 |
| 6 | 5 · Main Results: *Isolation compliance and outbreak outcomes* | 55 s | 3:20 |
| 7 | 6 · Complementary Controls: *Complementary controls and isolation burden* | 50 s | 4:10 |
| 8 | 7 · Conclusions: *Conclusions, limitations and next steps* | 30 s | 4:40 |

The spoken script totals **413 words** across the 8 main slides. At a calm academic delivery pace (~90–95 words per minute with figure pointers), the talk completes in **4 minutes 40 seconds**, leaving 20 seconds of buffer for slide transitions.

Before submission, fill in the group members, student IDs, and presentation/submission date on **Slide 1**.

## English spoken script (Slides 1–8)

### Slide 1 — Formal Cover (15 seconds)
Good morning. We present our LSGI545 group project on agent-based modelling of norovirus transmission and intervention strategies in a university dormitory.

### Slide 2 — Background and research objectives (25 seconds)
Shared bathrooms, kitchens and common rooms create repeated opportunities for close-contact and surface exposure. Typical incubation is 12 to 48 hours, and shedding can continue after symptoms resolve. We ask how isolation, cleaning and continued exclusion compare under consistent model assumptions.

### Slide 3 — Model structure and transmission rules (40 seconds)
The dormitory contains 200 students, initially including two exposed cases, across five space types. Six-hour ticks represent four daily movement phases. Students progress through six disease states. Direct exposure occurs on shared patches, while environmental exposure depends on surface contamination. Isolation changes movement, cleaning reduces contamination, and exclusion restricts post-symptom movement. The 0.22 asymptomatic branching probability is assumed rather than fitted.

### Slide 4 — Experimental design and verification (35 seconds)
We used a three-by-three-by-two factorial design: eighteen policy combinations, each repeated fifty times for nine hundred runs. We evaluate attack rate, run-level peak infectious count, route counts and isolation person-days. Boundary and population checks verify model implementation, not agreement with real outbreak data. The saved final observation is step 119, and random seeds were not logged.

### Slide 5 — Baseline outbreak dynamics (30 seconds)
This separate baseline sample follows fifty trajectories without interventions. The mean infectious curve reaches 16.84 students at exported step 73. That is the peak of the mean curve, not the mean of individual run peaks. Infectious students remain at the last saved observation, showing sustained spread within this calibration.

### Slide 6 — Isolation compliance and outbreak outcomes (55 seconds)
Pooling across cleaning and exclusion settings, mean final attack rate falls from 37.73 percent at zero compliance to 5.51 percent at 50 percent compliance and 1.40 percent at full compliance. Mean run-level peak falls from 19.99 to 4.64 and 2.20 students. Full compliance approaches the one-percent floor from the two initial cases. *(Point to the three panels in Figure 3 and Table 3 rather than reading every bar.)*

### Slide 7 — Complementary controls and isolation burden (50 seconds)
Table 4 separates two different comparisons. Without isolation or exclusion, twice-daily cleaning lowers mean attack rate from 52.86 to 28.77 percent and environmental-attributed infections from 23.26 to 5.44. Separately, pooled across positive-compliance settings, two-day exclusion lowers attack rate from 4.14 to 2.77 percent, while increasing isolation burden from 7.66 to 10.35 person-days. Route counts depend on direct-first ordering.

### Slide 8 — Conclusions, limitations and next steps (30 seconds)
Within this model, higher isolation compliance produces the largest reduction, cleaning reduces environmental risk when compliance is absent, and extended exclusion adds burden for a smaller reduction. Interpretation is bounded by assumed rates, stylised space, a fixed two-day post-symptomatic state and no external validation. Thank you.

## Hidden appendices (Slides 9–10)

- **Slide 9 (Appendix A — References and AI-use disclosure):** Full verified bibliography and truthful AI-use statement.
- **Slide 10 (Appendix B — Assumptions, verification and scenario lookup):** Mean final attack-rate heatmaps (Figure A1), representative 3-scenario lookup table (Table A1), denominator clarification for Wang et al. (2023), and technical verification notes for Q&A.
