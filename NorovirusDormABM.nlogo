; NorovirusDormABM.nlogo
; University dormitory norovirus ABM for NetLogo 6.4.x.
; One tick represents 6 hours; runs stop after 120 ticks (30 days).

breed [students student]

students-own [
  disease-state state-time state-duration symptomatic? isolated?
  infection-route home-patch infectiousness post-exclusion-left
]

patches-own [area-type contamination gathering?]

globals [
  cumulative-infections direct-infections environmental-infections
  new-infections-this-tick peak-infectious time-to-peak
  isolation-person-ticks outbreak-start-tick outbreak-end-tick
  bathroom-gathering-patches kitchen-gathering-patches
  common-gathering-patches isolation-gathering-patches
]

to setup
  clear-turtles
  clear-patches
  clear-drawing
  clear-all-plots
  setup-spaces
  setup-students
  seed-infections
  set direct-infections 0
  set environmental-infections 0
  set new-infections-this-tick 0
  set peak-infectious infectious-count
  set time-to-peak 0
  set isolation-person-ticks 0
  set outbreak-start-tick ifelse-value (initial-infected > 0) [0] [-1]
  set outbreak-end-tick -1
  reset-ticks
end

to setup-spaces
  ask patches [
    set contamination 0 set gathering? false
    ifelse pxcor <= -8 [
      set area-type "bedroom" set pcolor sky + 2
    ] [
      ifelse pxcor <= 0 [
        ifelse pycor >= 0
          [set area-type "bathroom" set pcolor yellow + 2]
          [set area-type "kitchen" set pcolor orange + 2]
      ] [
        ifelse pxcor <= 17
          [set area-type "common" set pcolor gray + 2]
          [set area-type "isolation" set pcolor violet + 2]
      ]
    ]
  ]
  foreach ["bathroom" "kitchen" "common" "isolation"] [kind ->
    ask min-n-of 20 (patches with [area-type = kind]) [pxcor * pxcor + pycor * pycor] [
      set gathering? true
    ]
  ]
  set bathroom-gathering-patches patches with [area-type = "bathroom" and gathering?]
  set kitchen-gathering-patches patches with [area-type = "kitchen" and gathering?]
  set common-gathering-patches patches with [area-type = "common" and gathering?]
  set isolation-gathering-patches patches with [area-type = "isolation" and gathering?]
end

to setup-students
  create-students population [
    set disease-state "S"
    set state-time 0 set state-duration 0
    set symptomatic? false set isolated? false
    set infection-route "" set infectiousness 0 set post-exclusion-left 0
    set home-patch one-of patches with [area-type = "bedroom"]
    move-to home-patch
    set shape "default" set size 0.8
    update-student-appearance
  ]
end

to seed-infections
  let seed-count min (list initial-infected count students)
  ask n-of seed-count students [
    set disease-state "E" set state-time 0
    set state-duration random-duration 2 8
    set infection-route "seed"
    update-student-appearance
  ]
  set cumulative-infections seed-count
end

to go
  if ticks >= 120 [stop]
  set new-infections-this-tick 0
  enforce-isolation
  move-students
  contaminate-environment
  direct-transmission-step
  environmental-transmission-step
  progress-disease
  update-isolation-status
  decay-contamination
  perform-cleaning
  update-statistics
  tick
  if ticks >= 120 [stop]
end

to enforce-isolation
  ask students with [isolated?] [
    let destination gathering-patch "isolation"
    if destination != nobody [move-to destination]
  ]
end

to move-students
  ask students [
    ifelse isolated? [
      let destination gathering-patch "isolation"
      if destination != nobody [move-to destination]
    ] [
      let phase ticks mod 4
      if phase = 0 [move-to home-patch]
      if phase = 1 [
        let draw random-float 1
        if draw < 0.55 [move-to gathering-patch "bathroom"]
        if draw >= 0.55 and draw < 0.80 [move-to gathering-patch "kitchen"]
        if draw >= 0.80 [move-to home-patch]
      ]
      if phase = 2 [
        ifelse random-float 1 < 0.60
          [move-to gathering-patch "common"]
          [move-to home-patch]
      ]
      if phase = 3 [
        let draw random-float 1
        if draw < 0.50 [move-to gathering-patch "common"]
        if draw >= 0.50 and draw < 0.78 [move-to gathering-patch "kitchen"]
        if draw >= 0.78 [move-to gathering-patch "bathroom"]
      ]
    ]
  ]
end

to contaminate-environment
  ask students with [member? disease-state ["I-sym" "I-asym" "P"]] [
    let shedding 0
    if disease-state = "I-sym" [set shedding 0.15]
    if disease-state = "I-asym" [set shedding 0.08]
    if disease-state = "P" [set shedding 0.05]
    ask patch-here [set contamination min (list 1 (contamination + shedding))]
  ]
end

to direct-transmission-step
  ask students with [member? disease-state ["I-sym" "I-asym" "P"]] [
    let source-infectiousness infectiousness
    ask other students-here with [disease-state = "S"] [
      if disease-state = "S" and random-float 1 < direct-transmission * source-infectiousness [
        infect-student self "direct"
      ]
    ]
  ]
end

to environmental-transmission-step
  if environmental-transmission? [
    ask students with [disease-state = "S"] [
      let exposure environmental-transmission * [contamination] of patch-here
      if random-float 1 < exposure [infect-student self "environment"]
    ]
  ]
end

to infect-student [target route]
  ask target [
    if disease-state = "S" [
      set disease-state "E" set state-time 0
      set state-duration random-duration 2 8
      set symptomatic? false set infectiousness 0 set infection-route route
      set cumulative-infections cumulative-infections + 1
      set new-infections-this-tick new-infections-this-tick + 1
      if route = "direct" [set direct-infections direct-infections + 1]
      if route = "environment" [set environmental-infections environmental-infections + 1]
      if outbreak-start-tick < 0 [set outbreak-start-tick ticks]
      update-student-appearance
    ]
  ]
end

to progress-disease
  ask students with [member? disease-state ["E" "I-sym" "I-asym" "P"]] [
    set state-time state-time + 1
    if state-time >= state-duration [
      let previous-state disease-state
      if previous-state = "E" [
        ifelse random-float 1 < asymptomatic-proportion
          [become-asymptomatic]
          [become-symptomatic]
      ]
      if previous-state = "I-sym" [become-post-symptomatic]
      if previous-state = "I-asym" [become-recovered]
      if previous-state = "P" [become-recovered]
    ]
  ]
end

to become-symptomatic
  set disease-state "I-sym" set symptomatic? true
  set state-time 0 set state-duration random-duration 4 12
  set infectiousness 1.0
  if isolation-enabled? and random-float 1 < isolation-compliance [
    set isolated? true
    let destination gathering-patch "isolation"
    if destination != nobody [move-to destination]
  ]
  update-student-appearance
end

to become-asymptomatic
  set disease-state "I-asym" set symptomatic? false
  set state-time 0 set state-duration random-duration 4 12
  set infectiousness 0.5 set isolated? false
  update-student-appearance
end

to become-post-symptomatic
  set disease-state "P" set symptomatic? false
  set state-time 0 set state-duration 8 set infectiousness 0.3
  ifelse isolated? and post-symptom-exclusion > 0
    [set post-exclusion-left round (post-symptom-exclusion * 4)]
    [set isolated? false set post-exclusion-left 0]
  update-student-appearance
end

to become-recovered
  set disease-state "R" set symptomatic? false
  set state-time 0 set state-duration 0 set infectiousness 0
  set isolated? false set post-exclusion-left 0
  update-student-appearance
end

to update-isolation-status
  ask students [
    if disease-state = "P" and isolated? [
      set post-exclusion-left max (list 0 (round (post-symptom-exclusion * 4) - state-time))
      if post-exclusion-left <= 0 [set isolated? false]
    ]
    if disease-state = "R" [set isolated? false set post-exclusion-left 0]
  ]
end

to decay-contamination
  ask patches [set contamination contamination * 0.85]
end

to perform-cleaning
  let clean-now? false
  if cleaning-frequency = 1 and ticks mod 4 = 2 [set clean-now? true]
  if cleaning-frequency = 2 and member? (ticks mod 4) [0 2] [set clean-now? true]
  if clean-now? [
    ask patches with [member? area-type ["bathroom" "kitchen" "common"]] [
      set contamination contamination * 0.1
    ]
  ]
end

to update-statistics
  let current-infectious infectious-count
  if current-infectious > peak-infectious [
    set peak-infectious current-infectious
    set time-to-peak ticks
  ]
  set isolation-person-ticks isolation-person-ticks + count students with [isolated?]
  if outbreak-start-tick >= 0 and outbreak-end-tick < 0 and
     not any? students with [member? disease-state ["E" "I-sym" "I-asym" "P"]] [
    set outbreak-end-tick ticks
  ]
end

to update-student-appearance
  if disease-state = "S" [set color blue]
  if disease-state = "E" [set color yellow]
  if disease-state = "I-sym" [set color red]
  if disease-state = "I-asym" [set color orange]
  if disease-state = "P" [set color violet]
  if disease-state = "R" [set color green]
  ifelse isolated? [set size 1.1] [set size 0.8]
end

to-report random-duration [minimum maximum]
  report minimum + random (maximum - minimum + 1)
end

to-report gathering-patch [kind]
  ; Shared activity patches create repeated co-location without an explicit network.
  ; The 20-patch pool is a structural/calibration assumption.
  if kind = "bathroom" [report one-of bathroom-gathering-patches]
  if kind = "kitchen" [report one-of kitchen-gathering-patches]
  if kind = "common" [report one-of common-gathering-patches]
  if kind = "isolation" [report one-of isolation-gathering-patches]
  report nobody
end

to-report infectious-count
  report count students with [member? disease-state ["I-sym" "I-asym" "P"]]
end

to-report final-attack-rate
  if count students = 0 [report 0]
  report cumulative-infections / count students
end

to-report isolation-person-days
  report isolation-person-ticks / 4
end

to-report outbreak-duration
  if outbreak-start-tick < 0 [report 0]
  if outbreak-end-tick >= 0 [report outbreak-end-tick - outbreak-start-tick]
  report ticks - outbreak-start-tick
end

to-report mean-contamination
  if not any? patches [report 0]
  report mean [contamination] of patches
end

to-report population-conserved?
  report count students = population and
    (count students with [disease-state = "S"] +
     count students with [disease-state = "E"] +
     count students with [disease-state = "I-sym"] +
     count students with [disease-state = "I-asym"] +
     count students with [disease-state = "P"] +
     count students with [disease-state = "R"] = population)
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
720
351
-1
-1
9.85
1
10
1
1
1
0
0
0
1
-25
25
-16
16
1
1
1
ticks
30.0
BUTTON
10
10
95
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1
BUTTON
105
10
190
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0
SLIDER
10
55
190
88
population
population
10
500
200.0
10
1
NIL
HORIZONTAL
SLIDER
10
90
190
123
initial-infected
initial-infected
0
20
2.0
1
1
NIL
HORIZONTAL
SLIDER
10
125
190
158
direct-transmission
direct-transmission
0
0.2
0.05
0.005
1
NIL
HORIZONTAL
SLIDER
10
160
190
193
environmental-transmission
environmental-transmission
0
0.2
0.03
0.005
1
NIL
HORIZONTAL
SLIDER
10
195
190
228
asymptomatic-proportion
asymptomatic-proportion
0
0.5
0.22
0.01
1
NIL
HORIZONTAL
SLIDER
10
230
190
263
isolation-compliance
isolation-compliance
0
1
0.5
0.1
1
NIL
HORIZONTAL
SLIDER
10
265
190
298
cleaning-frequency
cleaning-frequency
0
2
1.0
1
1
times/day
HORIZONTAL
SLIDER
10
300
190
333
post-symptom-exclusion
post-symptom-exclusion
0
2
2.0
2
1
days
HORIZONTAL
SWITCH
10
340
190
373
environmental-transmission?
environmental-transmission?
0
1
-1000
SWITCH
10
375
190
408
isolation-enabled?
isolation-enabled?
0
1
-1000
MONITOR
735
10
830
55
Susceptible
count students with [disease-state = "S"]
0
1
11
MONITOR
835
10
930
55
Exposed
count students with [disease-state = "E"]
0
1
11
MONITOR
935
10
1040
55
Symptomatic
count students with [disease-state = "I-sym"]
0
1
11
MONITOR
1045
10
1150
55
Asymptomatic
count students with [disease-state = "I-asym"]
0
1
11
MONITOR
1155
10
1260
55
Post-symptomatic
count students with [disease-state = "P"]
0
1
11
MONITOR
735
60
830
105
Recovered
count students with [disease-state = "R"]
0
1
11
MONITOR
835
60
940
105
Cumulative
cumulative-infections
0
1
11
MONITOR
945
60
1040
105
Attack rate
final-attack-rate
3
1
11
MONITOR
1045
60
1150
105
Direct
direct-infections
0
1
11
MONITOR
1155
60
1260
105
Environmental
environmental-infections
0
1
11
MONITOR
735
110
850
155
Mean contamination
mean-contamination
4
1
11
MONITOR
855
110
960
155
Peak infectious
peak-infectious
0
1
11
MONITOR
965
110
1070
155
Time to peak
time-to-peak
0
1
11
MONITOR
1075
110
1190
155
Isolation days
isolation-person-days
1
1
11
PLOT
210
365
615
585
Epidemic curve
ticks
students
0.0
120.0
0.0
200.0
true
true
""
""
PENS
"S" 1.0 0 -13345367 true "" "plot count students with [disease-state = \"S\"]"
"E" 1.0 0 -1184463 true "" "plot count students with [disease-state = \"E\"]"
"I-sym" 1.0 0 -2674135 true "" "plot count students with [disease-state = \"I-sym\"]"
"I-asym" 1.0 0 -955883 true "" "plot count students with [disease-state = \"I-asym\"]"
"P" 1.0 0 -8630108 true "" "plot count students with [disease-state = \"P\"]"
"R" 1.0 0 -10899396 true "" "plot count students with [disease-state = \"R\"]"
PLOT
625
365
940
585
New infections
ticks
new infections
0.0
120.0
0.0
20.0
true
true
""
""
PENS
"new" 1.0 1 -2674135 true "" "plot new-infections-this-tick"
PLOT
950
365
1260
585
Transmission route
ticks
cumulative infections
0.0
120.0
0.0
200.0
true
true
""
""
PENS
"direct" 1.0 0 -13345367 true "" "plot direct-infections"
"environment" 1.0 0 -955883 true "" "plot environmental-infections"
@#$#@#$#@
## WHAT IS IT?

This model simulates norovirus transmission among students in a stylised university dormitory. Transmission can occur directly between co-located students and indirectly through a normalized environmental contamination index.

## HOW IT WORKS

Students move among bedrooms, bathrooms, a kitchen, a common room, and an isolation room. Disease states are S, E, I-sym, I-asym, P, and R. One tick is six hours. The model stops after 120 ticks (30 days).

The fixed tick order is: isolation enforcement, movement, shedding, direct transmission, environmental transmission, disease progression, isolation update, environmental decay, cleaning, statistics, and tick advance.

## HOW TO USE IT

Choose parameters, click setup, and click go. Run `smoke_test_18x2` in BehaviorSpace before `main_interventions_18x50`.

## IMPORTANT LIMITATION

Contamination is a normalized model index, not a measured viral-particle count. Direct and environmental transmission probabilities, shedding, decay, cleaning effectiveness, and relative infectiousness are calibration or sensitivity parameters.

See README.md, PARAMETERS.md, VALIDATION.md, and ANALYSIS_GUIDE.md for the complete protocol.
@#$#@#$#@
default
true
0
Circle -7500403 true true 0 0 300
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
setup
repeat 120 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="smoke_test_18x2" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>cumulative-infections</metric><metric>final-attack-rate</metric>
    <metric>peak-infectious</metric><metric>time-to-peak</metric>
    <metric>outbreak-duration</metric><metric>direct-infections</metric>
    <metric>environmental-infections</metric><metric>isolation-person-days</metric>
    <metric>mean-contamination</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0"/><value value="0.5"/><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="0"/><value value="1"/><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="0"/><value value="2"/></enumeratedValueSet>
  </experiment>

  <experiment name="main_interventions_18x50" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>cumulative-infections</metric><metric>final-attack-rate</metric>
    <metric>peak-infectious</metric><metric>time-to-peak</metric>
    <metric>outbreak-duration</metric><metric>direct-infections</metric>
    <metric>environmental-infections</metric><metric>isolation-person-days</metric>
    <metric>mean-contamination</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0"/><value value="0.5"/><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="0"/><value value="1"/><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="0"/><value value="2"/></enumeratedValueSet>
  </experiment>

  <experiment name="baseline_timeseries_50" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>count students with [disease-state = "S"]</metric>
    <metric>count students with [disease-state = "E"]</metric>
    <metric>count students with [disease-state = "I-sym"]</metric>
    <metric>count students with [disease-state = "I-asym"]</metric>
    <metric>count students with [disease-state = "P"]</metric>
    <metric>count students with [disease-state = "R"]</metric>
    <metric>new-infections-this-tick</metric><metric>mean-contamination</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="0"/></enumeratedValueSet>
  </experiment>

  <experiment name="validation_zero_initial" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>cumulative-infections</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0.5"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="2"/></enumeratedValueSet>
  </experiment>

  <experiment name="validation_zero_transmission" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>cumulative-infections</metric><metric>direct-infections</metric>
    <metric>environmental-infections</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0.5"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="2"/></enumeratedValueSet>
  </experiment>

  <experiment name="validation_environment_off" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>environmental-infections</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="environmental-transmission?"><value value="false"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0.5"/></enumeratedValueSet>
    <enumeratedValueSet variable="cleaning-frequency"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="post-symptom-exclusion"><value value="2"/></enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
0
@#$#@#$#@
