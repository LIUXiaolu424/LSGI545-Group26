# Five-minute presentation guide

Use `output/Norovirus_Dormitory_ABM_Group_Presentation.pptx`: **six main slides and two hidden appendices**. The six spoken scripts below are also stored in PowerPoint Speaker Notes.

## Timing and rehearsal

| Slide | Focus | Target | Cumulative |
|---|---|---:|---:|
| 1 | Research question | 25 seconds | 0:25 |
| 2 | Model mechanism | 50 seconds | 1:15 |
| 3 | Experiment and implementation checks | 40 seconds | 1:55 |
| 4 | Isolation result | 65 seconds | 3:00 |
| 5 | Cleaning and continued-exclusion trade-offs | 60 seconds | 4:00 |
| 6 | Takeaway and limits | 40 seconds | 4:40 |

The script contains approximately **454 words**. Aim for 4:40, leaving 20 seconds for transitions or hesitation. This is a rehearsal target, not a measured guarantee: record at least two complete rehearsals with a stopwatch. Do not read all chart labels or add a live NetLogo demonstration unless the time allocation changes.

Before submission, fill in the group members and student IDs on slide 1. If several people present, practise handovers within the same five-minute total. Slides advance by click rather than automatically.

## English spoken script

### 1. Research question — 25 seconds

Our project asks how isolation, communal cleaning and post-symptom exclusion affect norovirus transmission in a university dormitory. Students repeatedly share bathrooms, kitchens and common rooms, allowing exposure through both people and contaminated surfaces. We use an agent-based model to compare these controls, not to predict an outbreak at a particular university.

### 2. Model mechanism — 50 seconds

The model represents 200 students, with two initially infected, in five types of space. A tick represents six hours. Students progress through susceptible, exposed, symptomatic or asymptomatic infectious, post-symptomatic and recovered states. Movement follows four daily phases. Isolation changes which spaces symptomatic students visit, cleaning reduces surface contamination, and continued exclusion keeps them isolated after symptoms stop. The exposed state is non-infectious, and the 0.22 asymptomatic branching probability is assumed rather than fitted. These choices matter when interpreting the results.

### 3. Experiment and checks — 40 seconds

We varied three isolation-compliance levels, three cleaning frequencies and two exclusion periods. Eighteen combinations, repeated fifty times each, give nine hundred main runs. Saved checks include zero initial infection, zero transmission, the environmental route disabled and population conservation. These are implementation checks, not validation against real outbreak data. The configured horizon is thirty days; the saved final observation is step 119. Random seeds were not recorded.

### 4. Main result — 65 seconds

This is the central finding. Averaged across cleaning and exclusion settings, mean attack rate was 37.7 percent at zero isolation compliance, 5.5 percent at half compliance and 1.4 percent at full compliance. These are pooled comparisons, not one matched policy pair. The figure shows all eighteen scenario means with approximate confidence intervals. Full compliance approaches the one-percent floor created by the two initial infections. Isolation changes both contact opportunities and shedding locations. Route counts also depend on direct-first processing, so they are not independent causal shares. The reduction is large within this calibration, but not a measured campus-policy effect.

**Delivery:** point to the three large percentages and the three chart panels; do not enumerate all 18 conditions.

### 5. Other controls and burden — 60 seconds

The other controls have different trade-offs. With no isolation and zero exclusion, increasing cleaning from none to twice daily lowered mean attack rate from 52.9 to 28.8 percent. Separately, pooled over positive-compliance settings, adding two exclusion days lowered attack rate from 4.14 to 2.77 percent, while increasing isolation burden from 7.66 to 10.35 person-days. These comparisons use different subsets and should not be read as a universal ranking. At full compliance, the small observed cleaning difference does not establish extra benefit.

**Delivery:** discuss the left block, then the right block. Explain person-days as total time spent in isolation summed over students, not the outbreak duration.

### 6. Takeaway and limitations — 40 seconds

Our takeaway is to consider isolation and hygiene together while checking the cost of continued exclusion. Higher compliance had the largest observed reduction here. However, transmission rates are assumed, the layout is stylised, and there is no external campus validation. Two-day exclusion covers the entire modelled post-symptomatic state, whereas real shedding can last longer. The results motivate further sensitivity testing, not an optimal real-campus policy. Thank you.

## Hidden appendices

- **Appendix A:** verified references and truthful AI-use disclosure.
- **Appendix B:** model assumptions, saved verification evidence and uncertainty caveats.

Both are hidden from ordinary slide-show navigation. They remain in the submitted file for inspection or questions; they are not part of the timed script. In a question period, open them from the slide navigator or temporarily unhide them. References and disclosure are supplementary materials, not omitted or deleted.

The report contains the full methods and results. Model code, raw CSVs, stored summary statistics and the report were not changed for this shorter presentation. The former 33-slide deck is backed up locally at `D:\Data\lsgi545_5min_20261124_v1\backup\Norovirus_Dormitory_ABM_Group_Presentation.pptx`.
