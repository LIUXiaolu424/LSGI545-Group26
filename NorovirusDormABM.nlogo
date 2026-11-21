globals [
  population initial-infected direct-transmission environmental-transmission
  asymptomatic-proportion isolation-compliance cleaning-frequency
  post-symptom-exclusion environmental-transmission? isolation-enabled?
]
__includes ["NorovirusDormABM.nls"]
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
    <metric>cumulative-infections</metric><metric>final-attack-rate</metric><metric>peak-infectious</metric><metric>time-to-peak</metric><metric>outbreak-duration</metric><metric>direct-infections</metric><metric>environmental-infections</metric><metric>isolation-person-days</metric><metric>mean-contamination</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet><enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet><enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet><enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet><enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet><enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet><enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0"/><value value="0.5"/><value value="1"/></enumeratedValueSet><enumeratedValueSet variable="cleaning-frequency"><value value="0"/><value value="1"/><value value="2"/></enumeratedValueSet><enumeratedValueSet variable="post-symptom-exclusion"><value value="0"/><value value="2"/></enumeratedValueSet>
  </experiment>
  <experiment name="main_interventions_18x50" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup><go>go</go><timeLimit steps="120"/>
    <metric>cumulative-infections</metric><metric>final-attack-rate</metric><metric>peak-infectious</metric><metric>time-to-peak</metric><metric>outbreak-duration</metric><metric>direct-infections</metric><metric>environmental-infections</metric><metric>isolation-person-days</metric><metric>mean-contamination</metric><metric>population-conserved?</metric>
    <enumeratedValueSet variable="population"><value value="200"/></enumeratedValueSet><enumeratedValueSet variable="initial-infected"><value value="2"/></enumeratedValueSet><enumeratedValueSet variable="direct-transmission"><value value="0.05"/></enumeratedValueSet><enumeratedValueSet variable="environmental-transmission"><value value="0.03"/></enumeratedValueSet><enumeratedValueSet variable="asymptomatic-proportion"><value value="0.22"/></enumeratedValueSet><enumeratedValueSet variable="isolation-enabled?"><value value="true"/></enumeratedValueSet><enumeratedValueSet variable="environmental-transmission?"><value value="true"/></enumeratedValueSet>
    <enumeratedValueSet variable="isolation-compliance"><value value="0"/><value value="0.5"/><value value="1"/></enumeratedValueSet><enumeratedValueSet variable="cleaning-frequency"><value value="0"/><value value="1"/><value value="2"/></enumeratedValueSet><enumeratedValueSet variable="post-symptom-exclusion"><value value="0"/><value value="2"/></enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
0
@#$#@#$#@
