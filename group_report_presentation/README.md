# Group report and presentation deliverables

This directory contains the report and presentation for the NetLogo group project:

**Agent-Based Modelling of Norovirus Transmission and Intervention Strategies in a University Dormitory**

## Final outputs

- `output/Norovirus_Dormitory_ABM_Group_Report.docx`
- `output/Norovirus_Dormitory_ABM_Group_Report.pdf`
- `output/Norovirus_Dormitory_ABM_Group_Presentation.pptx`

The report and presentation use the actual NetLogo 6.4.0 BehaviorSpace outputs stored in the parent project's `results/` directory. The presentation is structured as a **formal academic conference-style deck for a five-minute slot: eight main slides plus two hidden appendices**.

- **Main slides (Slides 1–8):**
  1. Formal academic cover (full project title, course, disease-state pipeline, experimental scope, and group member block)
  2. Epidemiological background and three research questions (RQ1–RQ3)
  3. Model architecture, six-compartment diagram, dual transmission equations ($p_{\text{direct}}, p_{\text{env}}$), and intervention mechanisms
  4. BehaviorSpace experimental design ($3 \times 3 \times 2 = 18$ conditions $\times 50$ repetitions $= 900$ main runs; $1{,}011$ total runs), outcome definitions, and implementation verification
  5. Baseline outbreak dynamics (Figure 2 compartment trajectories and step-119 compartment table)
  6. Symptomatic isolation compliance results (Figure 3 18-scenario bar chart, pooled outcomes table, and non-monotonic isolation burden)
  7. Conditional comparisons of communal disinfection and 48-hour post-symptom exclusion (Table 4 with explicit subset definitions and confidence intervals)
  8. Synthesis of findings, model/inference boundaries, and priority sensitivity extensions
- **Hidden appendices (Slides 9–10):**
  - Appendix A: Verified references and truthful AI-use disclosure
  - Appendix B: Mean attack-rate heatmaps (Figure A1), representative scenario lookup table, denominator clarification for Wang et al. (2023), and technical verification notes for Q&A

See `PRESENTATION_5MIN_GUIDE.md` for the per-slide schedule and full English script (approximately 413 words; target 4:40 with 20 seconds of margin). The same script is stored in PowerPoint Speaker Notes.

## Before submission

Fill in group-member names, student IDs and the actual submission date on the report cover and presentation cover (Slide 1). Review the report, eight main slides and two hidden appendices, and align the truthful AI-use disclosure with the course policy.

The 0.22 asymptomatic branching probability is a model assumption, not the cited paper's 21.8% positivity among asymptomatic tested people. Preserve the saved result figures and raw data; do not substitute illustrative values.

The submitted `.nlogo` is self-contained. Report/PPT changes in this revision do not alter the model or rerun simulations.
