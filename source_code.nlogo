;;;;;;;;;;;;;;;;;;;
;;; CREDENTIALS ;;;
;;;;;;;;;;;;;;;;;;;

; Name: DAVIDE BALDELLI
; e-mail: davide.baldelli4@studio.unibo.it
; ID: 0001052636


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VARIABLES DEFINITION;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own
[
  ;; this is used to mark turtles we have already visited
  explored?
]

globals
[
  component-size          ;; number of turtles explored so far in the current component
  giant-component-size    ;; number of turtles in the giant component
  giant-start-node        ;; node from where we started exploring the giant component
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape turtles "circle"

  create-turtles num-nodes
  [ set color red
    setxy random-xcor random-ycor]
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;
;;;; GO PROCEDURE ;;;;
;;;;;;;;;;;;;;;;;;;;;;


to go

  ask links [ set color gray ]

  ; noisy edge generation or deletion
  if-else random-float 1.0 < strengthen-weaken  ;; the parameter strengthen-weaken sets the porbability of
                                                ;; creating or deleting edges in the noisy generation / deletion of edges
    [repeat random noise [make-link]]
    [repeat random noise [if count links != 0 [ask one-of links [die]]]]

  ; trigger the two procedures that increase-happiness
  if increase-happiness? [increase-happiness decrease-popolarity]

  tick
  layout
  if ticks = 500 [stop]
end


;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Experiments ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;


;; In the first experiment we want to study the trend of the ratio between avg-ff and avg-f and the ratio of happy turtles
;; when varying the wiring porbability of the Erdos-Renyi model

to exp-1 [starting-p]  ;; the experiment will explore the networks with starting-p <= p <= 1

  setup
  set-current-plot "metrics"
  set-plot-x-range starting-p 1
  set wiring-prob starting-p

  ; save the metrics in the following lists
  let r-happy-turtles []
  let temp-r-happy-turtles []
  let r-ff/f []
  let temp-r-ff/f []

  while [wiring-prob < 1][    ;; loop until the completely connectd netwrok is reached

    set temp-r-happy-turtles []
    set temp-r-ff/f []

    repeat 100[               ;; average between 100 observations
      ; Initialize the network
      erdos-renyi-p

      ; save the metrics
      set temp-r-happy-turtles lput ratio-happy-turtles temp-r-happy-turtles
      set temp-r-ff/f lput ff/f temp-r-ff/f
    ]

    ; update the metrics
    set r-happy-turtles lput mean temp-r-happy-turtles r-happy-turtles
    set r-ff/f lput mean temp-r-ff/f r-ff/f

    ; plot the results
    set-current-plot-pen "ratio-happy-turtles"
    plotxy wiring-prob mean temp-r-happy-turtles
    set-current-plot-pen "ff/f"
    plotxy wiring-prob mean temp-r-ff/f
    set-current-plot-pen "0.5"
    plotxy wiring-prob 0.5

    let step 0.01  ; change this parameter for finer precision
    set wiring-prob (wiring-prob + step)
  ]

  ; show the final metrics
  show "ratio happy turtles"
  show r-happy-turtles
  show "ff/f"
  show r-ff/f

end

;; In the second experiment we want to study the trend of the same metrics of exp-1, but here we initialize
;; a network with the Erdos-Renyi model (the variant where we set the number of edges) and add a link at random
;; until the network becomes completely connected

to exp-2

  let r-happy-turtles []
  let r-ff/f []

  set-current-plot "metrics"

  repeat 10 [  ;; do ten trials

    setup

    set num-links round ((bin-coeff num-nodes 2) * 0.1)  ;; setting as number of edges the expected value
    erdos-renyi-e                                        ;; of edges if wiring-probability was 0.1

    while [count links < (max-links)][ ;; repeat until the network is completely connected
      make-link

      set r-happy-turtles lput ratio-happy-turtles r-happy-turtles
      set r-ff/f lput ff/f r-ff/f

      ;; plot the results
      set-current-plot-pen "ratio-happy-turtles"
      plot ratio-happy-turtles
      set-current-plot-pen "ff/f"
      plot ff/f
      set-current-plot-pen "0.5"
      plot 0.5
    ]

  ]
  ; show the final metrics
  show "ratio happy turtles"
  show r-happy-turtles
  show "ff/f"
  show r-ff/f
end


;; In the third experiment we are going to initialize a network with the Erdos-Renyi model and then we are going
;; to randomly add and delete edges, but only allowing the creation fo new edges with an upper bound to the number of
;; friends that a node can have.


to exp-3

  let r-happy-turtles []
  let r-ff/f []
  let r-avg-f []
  let r-avg-ff []
  set-current-plot "metrics"

  repeat 10 [  ; do ten trials

    setup
    erdos-renyi-p

    repeat 500 [

      ;; add or delete edges in a noisy way
      if-else random-float 1.0 < strengthen-weaken
      [repeat random noise [make-link]]
      [repeat random noise [if count links != 0 [ask one-of links [die]]]]

      ; report the metrics
      set r-happy-turtles lput ratio-happy-turtles r-happy-turtles
      set r-ff/f lput ff/f r-ff/f
      set r-avg-f lput avg-f r-avg-f
      set r-avg-ff lput avg-ff r-avg-ff

      ; plot the results
      set-current-plot-pen "ratio-happy-turtles"
      plot ratio-happy-turtles
      set-current-plot-pen "ff/f"
      plot ff/f
      set-current-plot-pen "0.5"
      plot 0.5

    ]
  ]

  ; show the results
  show "ratio happy turtles"
  show r-happy-turtles
  show "ff/f"
  show r-ff/f
  show "avg-f"
  show r-avg-f
  show "avg-ff"
  show r-avg-ff

end

;; For the fourth experiment the newtork will evolve by creating and deleting random edges and by crating and
;; deleting edges with two procecedures that tend to increase the happiness of nodes.

to exp-4

  let r-happy-turtles []
  let r-ff/f []
  let r-avg-f []
  let r-avg-ff []
  set-current-plot "metrics"

  repeat 10 [

    setup
    erdos-renyi-p

    repeat 100 [

      ; add or delete edges in a noisy way
      if-else random-float 1.0 < strengthen-weaken
      [repeat random noise [make-link]]
      [repeat random noise [if count links != 0 [ask one-of links [die]]]]

      ; procedures that increase happiness
      increase-happiness
      decrease-popolarity

      ; report the metrics
      set r-happy-turtles lput ratio-happy-turtles r-happy-turtles
      set r-ff/f lput ff/f r-ff/f
      set r-avg-f lput avg-f r-avg-f
      set r-avg-ff lput avg-ff r-avg-ff

      ; plot the metrics
      set-current-plot-pen "ratio-happy-turtles"
      plot ratio-happy-turtles
      set-current-plot-pen "ff/f"
      plot ff/f
      set-current-plot-pen "0.5"
      plot 0.5

    ]
  ]

  ; show the final metrics
  show "ratio happy turtles"
  show r-happy-turtles
  show "ff/f"
  show r-ff/f
  show "avg-f"
  show r-avg-f
  show "avg-ff"
  show r-avg-ff

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; MAIN PROCEDURES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; erdos-renyi model where each possible pair of nodes
;; gets a chance to create a link between them with a specified probability.
to erdos-renyi-p
  ask links [die]
  ask turtles [
    ask turtles with [ who > [ who ] of myself ] [
      if random-float 1.0 < wiring-prob [
        create-link-with myself
      ]
    ]
  ]
end

;; erdos-renyi model that creates num-links links
to erdos-renyi-e
  ask links [ die ]
  while [ count links < num-links ] [
    ask one-of turtles [
      create-link-with one-of other turtles
    ]
  ]
end


;; create en edge between two random sad turtles
to increase-happiness
  let non-singlets turtles with [count link-neighbors != 0]
  let sad-turtles non-singlets with [n-of-f < n-of-ff]
  let sad-turltes sentence sad-turtles (turtles with [count link-neighbors = 0])
  let sad-1 one-of sad-turtles
  let possible-friends sad-turtles with [link [who] of self [who] of sad-1 = nobody]  ;
  set possible-friends possible-friends with [who != [who] of sad-1]

  if count possible-friends = 0 [stop]

  let sad-2 one-of possible-friends
  ask sad-1 [create-link-with sad-2]
end


;; used for removing an edge between the node with the highest number of friends
;; and his friend with the highest number of friends.
to decrease-popolarity
  let stacy one-of turtles with [n-of-f = max [n-of-f] of turtles]
  let friends-of-stacy [link-neighbors] of stacy
  if count friends-of-stacy = 0 [stop]
  let ex-friend one-of friends-of-stacy with [count [link-neighbors] of self = max [count link-neighbors] of friends-of-stacy]

  ask link [who] of stacy [who] of ex-friend [die]
end


;; used for creating a random new link
to make-link
  if count links = (count turtles * (count turtles - 1) ) / 2 [stop] ;; stop if the net is completelt connected
  if count turtles with [count link-neighbors < allowed-links] <= 2  [stop] ;; stop if all the turtles have the max of allowed friends

  let t1 one-of turtles with [count link-neighbors < allowed-links]
  let t2 one-of turtles with [count link-neighbors < allowed-links]
  if-else (t1 = t2) or ([link-neighbor? t2] of t1)
  [make-link]
  [ask t1 [create-link-with t2 [set color blue]]]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; METRICS AND REPORTERS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; computes the factorial
to-report factorial [n]
  let result 1
  let temp-n n
  repeat n - 1 [
   set result (result * temp-n)
   set temp-n (temp-n - 1)
  ]
  report result
end

;; computes the binobial coefficient
;; it is useful for calculating the expected value of the number of edges
;; when initiaizing a network with Erdos-Renyi-p
to-report bin-coeff [n k]
  report factorial n / (factorial (n - k) * factorial k)
end

;; computes the number of edges required to
;; make the current network completely connected
to-report max-links
  report (num-nodes * (num-nodes - 1)) / 2
end

;; report the number of friends
to-report n-of-f
  report count link-neighbors
end

;; report the average number of friends' friends
to-report n-of-ff
  if-else count link-neighbors = 0 [report ""]  ;; if a turtle doesn't have friends we won't count it
  [report mean [count link-neighbors] of link-neighbors]
end

;; report the average number of friends
to-report avg-f
  report mean [n-of-f] of turtles
end

;; report the average of the mean number of friends' friends
to-report avg-ff
  if-else count links = 0 [report 0]
  [report mean [n-of-ff] of turtles]
end

;; report the ratio between avg-ff and avg-f
to-report ff/f
  if mean [n-of-f] of turtles = 0 [report 0]
  report avg-ff / avg-f
end

;; report the correlation between n-of-f and n-of-ff
to-report correlation
  if count turtles < 2 [report 0]
  let non-singlets turtles with [count link-neighbors != 0]
  let num mean ([(n-of-f - avg-f)*(n-of-ff - avg-ff)] of non-singlets)
  let denum (sqrt variance [n-of-f] of non-singlets) * (sqrt variance [n-of-ff] of non-singlets)
  if-else denum != 0  [report num / denum] [report 0]
end

;; report the ratio of happy turtles. if a turtle has n-of-f = n-of-ff we define it to be sad.
to-report ratio-happy-turtles
  let non-singlets turtles with [count link-neighbors != 0]  ;; set singlets as "sad" by default
  report count non-singlets with [n-of-f > n-of-ff] / count turtles
end


;;;;;;;;;;;;;;
;;; LAYOUT ;;;
;;;;;;;;;;;;;;

;; resize-nodes, change back and forth from size based on degree to a size of 1
to resize-nodes
  ifelse all? turtles [size <= 1]
  [
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ask turtles [ set size sqrt count link-neighbors ]
  ]
  [
    ask turtles [ set size 1 ]
  ]
end

to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count turtles + 1
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring turtles links (1 / factor) (7 / factor) (100 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of turtles + min [xcor] of turtles
  let y-offset max [ycor] of turtles + min [ycor] of turtles

  if-else resize-nodes?
  [ask turtles [ set size (sqrt count link-neighbors) / (sqrt sqrt count turtles) ]]
  [ask turtles [set size 1]]

  find-all-components
  color-giant-component
  color-singlets
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NETWORK EXPLORATION ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; to find all the connected components in the network, their sizes and starting turtles
to find-all-components
  ask turtles [ set explored? false ]
  set giant-component-size 0
  ;; keep exploring till all turtles get explored
  loop
  [
    ;; pick a node that has not yet been explored
    let start one-of turtles with [ not explored? ]
    if start = nobody [ stop ]
    ;; reset the number of turtles found to 0
    ;; this variable is updated each time we explore an
    ;; unexplored node.
    set component-size 0
    ;; at this stage, we recolor everything to blue
    ask start [ explore (blue) ]
    ;; the explore procedure updates the component-size variable.
    ;; so check, have we found a new giant component?
    if component-size > giant-component-size
    [
      set giant-component-size component-size
      set giant-start-node start
    ]

  ]
end

;; Finds all turtles reachable from this node (and recolors them)
to explore [new-color]  ;; node procedure
  if explored? [ stop ]
  set explored? true
  set component-size component-size + 1
  ;; color the node
  set color new-color
  ask link-neighbors [ explore new-color ]
end

;; color the giant component red
to color-giant-component
  ask turtles [ set explored? false ]
  ask giant-start-node [ explore red ]
end

;; colour the singlets pink
to color-singlets
  ask turtles with [count link-neighbors = 0] [set color pink]
end
@#$#@#$#@
GRAPHICS-WINDOW
390
11
710
332
-1
-1
3.43
1
10
1
1
1
0
1
1
1
-45
45
-45
45
1
1
1
ticks
60.0

BUTTON
13
10
76
43
NIL
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

PLOT
0
515
374
699
Average number of f and of ff in time
time (ticks)
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"AVG-f" 1.0 0 -2674135 true "" "plot avg-f\n\n"
"AVG-ff" 1.0 0 -13345367 true "" "plot avg-ff\n"

BUTTON
88
11
151
44
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
0
336
373
510
Distribuiton of f and  ff
N
Count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"f" 1.0 1 -955883 true "" "plot-pen-reset  ;; erase what we plotted before\nhistogram [n-of-f] of turtles"
"AVG-f" 0.05 1 -2674135 true "" "plot-pen-reset  ;; erase what we plotted before\nplotxy avg-f count turtles"
"f of f" 1.0 1 -11221820 true "" "plot-pen-reset  ;; erase what we plotted before\nhistogram [n-of-ff] of turtles"
"AVG-ff" 0.05 1 -13791810 true "" "plot-pen-reset  ;; erase what we plotted before\nplotxy avg-ff count turtles"

BUTTON
159
11
236
44
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
0
289
50
334
avg-f
avg-f
2
1
11

MONITOR
51
289
108
334
avg-ff
avg-ff
2
1
11

SLIDER
14
47
186
80
num-nodes
num-nodes
0
500
50.0
1
1
NIL
HORIZONTAL

SLIDER
13
89
185
122
wiring-prob
wiring-prob
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
13
173
185
206
num-links
num-links
0
max-links
1225.0
1
1
NIL
HORIZONTAL

BUTTON
13
130
131
163
create-edges-p
erdos-renyi-p\n
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
14
214
132
247
create-edges-e
erdos-renyi-e
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
279
12
385
45
adjust-layout
layout
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
218
143
390
176
strengthen-weaken
strengthen-weaken
0
1
0.5
0.05
1
NIL
HORIZONTAL

MONITOR
110
290
167
335
nodes
count turtles
17
1
11

PLOT
390
334
728
560
metrics
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ff/f" 1.0 0 -5825686 true "" "plot ff/f"
"ratio-happy-turtles" 1.0 0 -11221820 true "" "plot ratio-happy-turtles\n\n"
"0.5" 1.0 2 -7500403 false "" "plot 0.5"

INPUTBOX
339
180
389
240
noise
5.0
1
0
Number

MONITOR
168
290
218
335
links
count links
17
1
11

MONITOR
269
244
319
289
ff / f
ff/f
2
1
11

MONITOR
269
290
373
335
ratio happy turtles
ratio-happy-turtles
2
1
11

INPUTBOX
252
181
334
241
allowed-links
1000.0
1
0
Number

SWITCH
219
104
389
137
increase-happiness?
increase-happiness?
0
1
-1000

SWITCH
253
47
386
80
resize-nodes?
resize-nodes?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
