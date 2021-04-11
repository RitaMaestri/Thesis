extensions [ nw csv ]

globals [ previous-movement-time taxi-times stop? separation waiting-times total-waiting-times-list length-paths n-aircraft occupation-times difference-distances folder wt-unanswered]

breed [ gcs gc ]
gcs-own [ congestion-strategy ]

breed [ intersections intersection ]
intersections-own [ name occupation-time occupied-by occupied-list parking runway-entrance runway-exit PAI last-occupation-time last-occupation begin-occupation begin-occupation-time]

breed [ airplanes airplane ]
airplanes-own [ start-node end-node path nodes departure next-node-number next-node next-next-node previous-node distance-next current-road next-road next-next-road stop-intersection speed advised-speed step taxi-time waiting-time total-waiting-time reason-waiting airplane-waiting waiting-times-reason dimension waiting length-airplane airplane-ahead time-airplane-ahead distance-airplane-ahead nodes-occupied distance-occupied unanswered-time]

directed-link-breed [ roads road ]
roads-own [ weight ]

directed-link-breed [ unroads unroad ]
unroads-own [ weight ]

directed-link-breed [ conflicts conflict ]
conflicts-own [active in-node out-node this-in-node this-out-node common-intersections origin destination road-origin-creation road-destination-creation time-creation time-active road-origin-active road-destination-active]

to export
  let waiting-times-to-export []
  foreach waiting-times [x -> set waiting-times-to-export lput (list x) waiting-times-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "waiting-times-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") waiting-times-to-export]
  [csv:to-file (word folder "waiting-times-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") waiting-times-to-export]

  let taxi-times-to-export []
  foreach taxi-times [ x -> set taxi-times-to-export lput (list x) taxi-times-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "taxi-times-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") taxi-times-to-export]
  [csv:to-file (word folder "taxi-times-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") taxi-times-to-export]

  let distances-to-export []
  foreach length-paths [ x -> set distances-to-export lput (list x) distances-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "distance-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") distances-to-export]
  [csv:to-file (word folder "distance-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") distances-to-export]

  let n-aircraft-to-export []
  foreach n-aircraft [ x -> set n-aircraft-to-export lput (list x) n-aircraft-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "n-aircraft-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") n-aircraft-to-export]
  [csv:to-file (word folder "n-aircraft-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") n-aircraft-to-export]

  let occupation-times-to-export []
  foreach occupation-times [ x -> set occupation-times-to-export lput (list x) occupation-times-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "occupation-time-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") occupation-times-to-export]
  [csv:to-file (word folder "occupation-time-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") occupation-times-to-export]

  let difference-distances-to-export []
  foreach difference-distances [ x -> set difference-distances-to-export lput (list x) difference-distances-to-export ]
  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "diff-dist-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") difference-distances-to-export]
  [csv:to-file (word folder "diff-dist-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") difference-distances-to-export]

  ifelse item 1 nw:get-context = roads
  [csv:to-file (word folder "wt-unanswered-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-roads.csv") (list(list wt-unanswered))]
  [csv:to-file (word folder "wt-unanswered-" time-interval-departures "-" ticks "-p-change-" p-change-path "-p-unanswered-" p-unanswered "-unroads.csv") (list(list wt-unanswered))]

end

to setup
  clear-all
  reset-ticks
  random-seed new-seed
  nw:load-graphml "directed-undirected-network.graphml"
  ;nw:load-graphml "simple_network.graphml"
       create-gcs 1 [
    set congestion-strategy false
    fd 37
    set color black
  ]
  set-strategy
  set previous-movement-time 0
  set separation 60
  set waiting-times []
  set total-waiting-times-list []
  set length-paths []
  set n-aircraft []
  set occupation-times []
  set difference-distances []
  layout-circle intersections 35
  ask intersections[
    set begin-occupation-time 0
    set occupation-time 0
    set occupied-by nobody
    set color red
    set shape "dot"
    set occupied-list []
    set last-occupation [nobody]
    set begin-occupation [nobody]
  ]
  set stop? false
  set taxi-times []
  set folder "/home/rita/Documents/Universita/Stage/Projet Jumeau Numérique/Programs/Netlogo/Generated_distributions/p-unanswered/"
  create-airplanes 1 [ settings-new-airplane ]
end

to go
  if ticks - previous-movement-time = time-interval-departures [
    create-airplanes 1[
      settings-new-airplane
      set-conflicts ]
    set n-aircraft lput count airplanes n-aircraft
    if (strategy = "ground controller")[set-gc-strategy]
    set previous-movement-time ticks
  ]

  ask intersections with [occupied-by != nobody] [set occupation-time occupation-time + 1]
  move
  tick
  if ticks = 50000 [set stop? true]
  if stop? [stop]
end

to stop-execution?
    ask airplanes [
    if any? other airplanes-here [
      ask other airplanes-here [
        if (next-node = [previous-node] of myself) and ( previous-node = [next-node] of myself ) and (patch-here != [patch-here] of start-node) and ([patch-here] of myself != [[patch-here] of start-node] of myself) [
          show "same position"
          set stop? true
        ]
      ]
    ]
  ]
end

to set-strategy
  ifelse strategy = "night"
  [show 1 nw:set-context intersections unroads]
  [ifelse strategy = "day"
    [show 2 nw:set-context intersections roads]
    [show 3 set-gc-strategy]
  ]
end

to set-gc-strategy
    ask gcs [
    ifelse count airplanes > threshold-strategy [ set congestion-strategy true set color pink][set congestion-strategy false set color green]
      ifelse congestion-strategy [ nw:set-context intersections roads ] [ nw:set-context intersections unroads ]
    ]
end

to set-stop-intersections [stop-intersection-proposal-self]
  set stop-intersection lput stop-intersection-proposal-self stop-intersection
  ask myself [ set stop-intersection lput value-stop-intersection-ordered self stop-intersection-proposal-self stop-intersection ]
end

to-report conflict-area [ self- myself- ]
  let my-conflict-area []
  foreach range ( length last [stop-intersection] of self- ) [ x ->
    let first-conflict-node item x last [stop-intersection] of self-
    let last-conflict-node item ( ( length last [stop-intersection] of self- ) - 1 - x ) last [stop-intersection] of myself-
    ;show first-conflict-node
    ;show last-conflict-node
    let subset-conflict-area ( sublist path ( position first-conflict-node [path] of self- ) ( 1 +  position last-conflict-node [path] of self- ) )
    set my-conflict-area lput subset-conflict-area my-conflict-area
  ]
  report my-conflict-area
end

to-report next-nodes
  let my-next-nodes []
  foreach (range next-node-number length path) [x ->
    if value-distance-node item x path < 60 + length-airplane / 2 + speed [
      set my-next-nodes lput item x path my-next-nodes
    ]
  ]
  report my-next-nodes
end

to-report in-area [my-conflict-area]
  foreach lput next-node next-nodes [ x ->
    if (member? x my-conflict-area) [report true] ]
  report false
end

to set-conflicts
  ask other airplanes [
    let stop-intersection-proposal value-stop-intersection self myself
    if stop-intersection-proposal != []
    [ set-stop-intersections stop-intersection-proposal
      foreach conflict-area self myself
      [ conflict-area-i ->
        ifelse in-area conflict-area-i
        [ ifelse out-link-to myself = nobody
          [ create-conflict-to-target myself conflict-area-i true ]
          [ update-conflict-to-target myself conflict-area-i true ]
        ]
        [ ifelse out-link-to myself = nobody
          [ create-conflict-to-target myself conflict-area-i false ]
          [ update-conflict-to-target myself conflict-area-i false ]
        ]
        ask myself [
          ifelse out-link-to myself = nobody
          [ create-conflict-to-target myself ( reverse conflict-area-i ) false ]
          [ update-conflict-to-target myself ( reverse conflict-area-i ) false ]
        ]
      ]
    ]
  ]
end

to-report value-stop-intersection [self- myself-]
  let stop-intersection-list []

  foreach range ( length [path] of myself- - 1) [ i ->
    if (list item 0 [path] of self- item 1 [path] of self- ) = (list item (i + 1) [path] of myself- item i [path] of myself-)
    [ set stop-intersection-list lput item 0 [path] of self- stop-intersection-list ]
  ]

  foreach range ( length [path] of self- - 1) [ i ->
    if (list item i [path] of self- item (i + 1) [path] of self- ) = ( list last [path] of myself- item (length [path] of myself- - 2) [path] of myself- )
    [ if not member? (item i [path] of self-) stop-intersection-list [set stop-intersection-list lput item i [path] of self- stop-intersection-list ] ]
  ]

  foreach (range  1 (length [path] of self- - 1)) [ old ->
    foreach range ( length [path] of myself- - 2) [ new ->
      if (list item old [path] of self- item ( old + 1 ) [path] of self- ) = (list item (new + 1) [path] of myself- item new [path] of myself-) and
      not ((list item ( old - 1 ) [path] of self- item ( old ) [path] of self- ) = (list item (new + 2) [path] of myself- item ( new + 1 ) [path] of myself-)) [
        set stop-intersection-list lput item old [path] of self- stop-intersection-list
      ]
    ]
  ]
  report stop-intersection-list
end

to-report value-stop-intersection-ordered [self- stop-intersections-myself]
  let stop-intersection-list []
  foreach stop-intersections-myself [stops ->
    set stop-intersection-list lput (set-value-stop-intersection stops) stop-intersection-list
  ]
  report reverse stop-intersection-list
end

to-report set-value-stop-intersection [stop-myself]
    foreach range min ( list (length [path] of myself - position stop-myself [path] of myself) (position stop-myself [path] of self + 1) ) [ i ->
    let iterator-self position stop-myself [path] of self - i
    let iterator-myself position stop-myself [path] of myself + i
    if (item iterator-self [path] of self = item iterator-myself [path] of myself) and ( (iterator-self = 0) or (iterator-myself = length [path] of myself - 1 ) or (item ( iterator-self - 1 ) [path] of self != item (iterator-myself + 1) [path] of myself) )
    [report item iterator-self [path] of self]
  ]
end

to create-conflict-to-target [target my-conflict-area -active]
  create-conflict-to target [
    set-in-node my-conflict-area
    set-out-node my-conflict-area
    set-common-intersections my-conflict-area
    set color [255 0 0 0]
    set active -active
    set origin myself
    set destination target
    set road-origin-creation [current-road] of myself
    set road-destination-creation [current-road] of target
    set time-creation ticks
    ifelse -active
    [set time-active ticks
      set road-origin-active [current-road] of myself
      set road-destination-active [current-road] of target
      set this-in-node first my-conflict-area
      set this-out-node last my-conflict-area
    ][set time-active "not assigned"
      set road-origin-active "not assigned"
      set road-destination-active "not assigned"
    ]
  ]
end

to update-conflict-to-target [target my-conflict-area -active]
  ask out-conflict-to target [
    set in-node lput (first my-conflict-area) in-node
    set out-node lput (last my-conflict-area) out-node
    set common-intersections lput my-conflict-area common-intersections
    if (not active) [ set active -active ]
    if -active [
      set this-in-node first my-conflict-area
      set this-out-node last my-conflict-area
    ]
  ]
end

to-report both-ends-of [a-link]
  let both-ends-of-a-link 0
  ask a-link [set both-ends-of-a-link both-ends]
  report both-ends-of-a-link
end

to set-in-node [my-conflict-area]
  set in-node []
  set in-node lput (first my-conflict-area) in-node
end

to set-out-node [my-conflict-area]
  set out-node []
  set out-node lput (last my-conflict-area) out-node
end

to set-common-intersections [my-conflict-area]
  set common-intersections []
  set common-intersections lput my-conflict-area common-intersections
end

to set-start-node
  ifelse departure
  [ set start-node one-of intersections with [parking = true and not any? airplanes-here with [start-node = myself]] ]
  [ set start-node one-of intersections with [runway-exit = true] ]
end

to set-end-node
  ifelse departure
  [ set end-node one-of intersections with [runway-entrance = true] ]
  [ set end-node one-of intersections with [parking = true] ]
end

to set-path
  ask start-node [
    let first-path-of-airplane nw:turtles-on-weighted-path-to [end-node] of myself weight
    ask myself [
      ifelse(random-float 1 < p-change-path)
      [ set path new-path first-path-of-airplane ]
      [ set path first-path-of-airplane ]
      if length path = 2 [ set path lput last path path ]
      set length-paths lput my-distance path length-paths
      set difference-distances lput (last (length-paths) - (my-distance first-path-of-airplane)) difference-distances

    ]
  ]
end

to-report my-distance [this-path]
  let this-distance 0
    foreach range (length this-path - 1) [ i ->
      ask item i this-path [
        ask out-unroad-to item (i + 1) this-path [

        set this-distance this-distance + weight ]
      ]
    ]
  report this-distance
end

to-report new-path [path-of-airplane]
  let new-part-path 0
  let deviation-node 0
  let reporter 0

  foreach range 10 [ seed ->
    random-seed seed
    let mistake-node-number 1 + (random (length path-of-airplane - 3))
    let mistake-node item mistake-node-number path-of-airplane

    ask mistake-node
    [ set deviation-node value-deviation-node mistake-node-number path-of-airplane ]

    ifelse deviation-node = nobody
    [ set new-part-path false]
    [ ask deviation-node [set new-part-path value-new-part-path path-of-airplane mistake-node-number] ]

    ifelse new-part-path = false
    [ set reporter path-of-airplane ]
    [ set reporter build-new-path mistake-node-number path-of-airplane new-part-path
     report reporter ]
  ]
  random-seed 10
  report reporter
end

to-report value-deviation-node [mistake-node-number path-of-airplane]
  let nodes-to-avoid list ([who] of item (mistake-node-number - 1 ) path-of-airplane) ([who] of item (mistake-node-number + 1 ) path-of-airplane)
  report one-of out-road-neighbors with [not member? who nodes-to-avoid ]
end

to-report value-new-part-path [path-of-airplane mistake-node-number]
  let new-part-path 0

  ifelse strategy = "day" or (strategy = "ground controller"  and n-aircraft > threshold-strategy)
  [ nw:set-context intersections with [not member? self sublist path-of-airplane 0 (mistake-node-number + 1) ] roads ]
  [ nw:set-context intersections with [not member? self sublist path-of-airplane 0 (mistake-node-number + 1) ] unroads]

  set new-part-path nw:turtles-on-weighted-path-to (last path-of-airplane) weight
  set-strategy

  report new-part-path
end

to-report build-new-path [mistake-node-number path-of-airplane this-new-part-path]
   let this-new-path [ ]
   foreach range (mistake-node-number + 1) [ i -> set this-new-path lput item i path-of-airplane this-new-path ]
   foreach range ((length this-new-part-path)) [ i -> set this-new-path lput item i this-new-part-path this-new-path ]
   report this-new-path
end

to-report path-name [path-]
let inters-names []
  foreach path- [ x -> set inters-names lput [name] of x inters-names ]
  report inters-names
end

to set-nodes [path-of-airplane]
  let inters-names []
  foreach path-of-airplane [ x -> set inters-names lput [name] of x inters-names ]
  set nodes inters-names
end

to set-current-road
  let current-road-temp 0
  ask previous-node [set current-road-temp out-unroad-to [next-node] of myself]
  set current-road current-road-temp
end

to set-next-road
  let next-road-temp 0
  ifelse next-next-node != nobody
  [ ask next-node [set next-road-temp out-unroad-to [next-next-node] of myself] ]
  [ set next-road-temp nobody]
  set next-road next-road-temp
end

to set-next-next-road
  let next-next-road-temp 0
  ifelse length path > (next-node-number + 2)
  [ ask item (next-node-number + 1) path [
      set next-next-road-temp out-unroad-to [item (next-node-number + 2) path] of myself] ]
  [ set next-next-road-temp nobody ]
  set next-next-road next-next-road-temp
end

to settings-new-airplane
  set color yellow
  set shape "airplane"
  set size 2
  ifelse (random-float 1 < 0.75) [set dimension "M"][set dimension "H"]
  set airplane-ahead nobody
  ifelse (dimension = "H")
  [ set advised-speed (random-gamma 22.466376 3.282859)
    set length-airplane 60 ]
  [ set advised-speed (random-gamma 22.031023 2.549299)
    set length-airplane 40 ]
  set speed advised-speed
  set waiting false
  set stop-intersection []
  set unanswered-time 0
  set taxi-time 0
  set total-waiting-time 0
  set waiting-time 0
  set waiting-times-reason []
  set distance-next []
  set distance-occupied []
  set departure one-of [ true false ]
  set distance-airplane-ahead []
  set-start-node
  set-end-node
  set-path
  set-nodes path
  set next-node-number 1
  set next-node item next-node-number path
  set previous-node item 0 path
  set next-next-node item 2 path
  set-current-road
  set-next-road
  set-next-next-road
  move-to item 0 path
  face next-node
  set step ( distance next-node * speed / [weight] of current-road )
end

to verify-distance [candidate-airplane-ahead]
 ifelse (candidate-airplane-ahead != nobody and (60 + ( length-airplane / 2 ) + ( [length-airplane] of candidate-airplane-ahead / 2 ) + speed)  >= (value-distance candidate-airplane-ahead) )
    [ if airplane-ahead = nobody [set time-airplane-ahead ticks]
      set airplane-ahead candidate-airplane-ahead
    ]
    [ set airplane-ahead nobody ]
end

to-report value-candidate-airplane-ahead
  let candidate-airplane-ahead min-one-of other airplanes in-cone 80(10) with [current-road = [current-road] of myself and distance start-node != 0] [distance myself]
  if (candidate-airplane-ahead = nobody and next-road != nobody)
    [ set candidate-airplane-ahead min-one-of other airplanes with [current-road = [next-road] of myself and distance start-node != 0] [distance [next-node] of myself]
      if (candidate-airplane-ahead = nobody and next-next-road != nobody)
  [ set candidate-airplane-ahead min-one-of other airplanes with [current-road = [next-next-road] of myself and distance start-node != 0] [distance [next-next-node] of myself] ]
]
report candidate-airplane-ahead
end

to set-airplane-ahead
verify-distance value-candidate-airplane-ahead
end

to do-one-step
  set-airplane-ahead
  ifelse airplane-ahead != nobody
  [ ifelse ( [waiting] of airplane-ahead = true )
    [ wait-here
      set reason-waiting list "airplane ahead" airplane-ahead
      set airplane-waiting (list airplane-ahead)
    ]
    [ settings-airplane-ahead
      fd-step
      set distance-airplane-ahead lput value-distance airplane-ahead distance-airplane-ahead
      if last distance-airplane-ahead < 20 [
        set stop? true
      inspect self]
    ]
  ]
  [ settings-no-airplane-ahead
    fd-step
  ]
end

to settings-no-airplane-ahead
    set speed advised-speed
    let target-node next-node
    set step ( ( [distance target-node] of previous-node ) * speed / [weight] of current-road )
end

to settings-airplane-ahead
  if [speed] of airplane-ahead < speed [set speed [speed] of airplane-ahead]
    let target-node next-node
    set step ( ( [distance target-node] of previous-node ) * speed / [weight] of current-road )
end

to fd-step
  if waiting-time > 0 [
    set waiting-times lput waiting-time waiting-times
    set waiting-times-reason lput (list next-node waiting-time ticks) waiting-times-reason
    set waiting false
    set waiting-time 0
  ]
  fd step
  set taxi-time ( taxi-time + 1 )
  set-occupied-by-nobody
  set distance-next lput (distance next-node)  distance-next
end

to activate-conflict [this-in-node-]
  set active true
  set time-active ticks
  set road-origin-active [current-road] of myself
  set road-destination-active [current-road] of other-end
  set this-in-node this-in-node-
  set this-out-node item (position this-in-node- in-node) out-node
end

to wait-here
  set-airplane-ahead
  set taxi-time ( taxi-time + 1 )
  set waiting-time waiting-time + 1
  set total-waiting-time total-waiting-time + 1
  set waiting true
end

to change-road
  move-to next-node
  set previous-node next-node
  set next-node-number next-node-number + 1
  set next-node item next-node-number path
  ifelse length path > next-node-number + 1
  [set next-next-node item (next-node-number + 1) path]
  [set next-next-node nobody]
  set-current-road
  set-next-road
  set-next-next-road
  if current-road != nobody [set step (distance next-node * speed / [weight] of current-road)] ;pt
  face next-node
  set taxi-time taxi-time + 1
  set waiting-time 0
end

to set-occupied-by-nobody
  foreach [1 2 3]
    [ k ->  if ( (next-node-number > k - 1 ) and (( length-airplane / 2 ) + 60 + speed ) < value-distance-node item (next-node-number - k) path  and not member? self [last-occupation] of item (next-node-number - k) path )
      [ let this-distance value-distance-node item (next-node-number - k) path
        ask my-out-conflicts with [[item (next-node-number - k) path] of myself = this-out-node] [
          set active false
      ]
        ask item (next-node-number - k) path
        [ set occupied-by nobody
          set occupied-list lput (list ticks nobody myself this-distance) occupied-list
          set last-occupation lput myself last-occupation
          set occupation-times lput (ticks - begin-occupation-time) occupation-times
        ]
      ]
  ]
end

to-report value-distance [airp-ahead]
  ifelse airp-ahead != nobody [
    ifelse ([current-road] of airp-ahead = current-road)
    [ report distance airp-ahead * speed / step ]
    [ ifelse ([current-road] of airp-ahead = next-road)
      [ let dist-next-node distance next-node * speed / step
        let dist-next-node-candidate 0
        ask next-node [ set dist-next-node-candidate (distance [airp-ahead] of myself * [[weight] of next-road] of myself / distance [next-next-node] of myself) ]
        report dist-next-node + dist-next-node-candidate
      ][let dist-next-node distance next-node * speed / step
        let dist-next-next-node-candidate 0
        ask item (next-node-number + 2) path [ set dist-next-next-node-candidate (distance [airp-ahead] of myself * [[weight] of next-next-road] of myself / distance [next-next-node] of myself) ]
        report dist-next-node + dist-next-next-node-candidate + [weight] of next-road
      ]
    ]
  ][
    report nobody
  ]
end

to-report value-distance-node [node]
  let distance-tmp 0
  ifelse position node path < next-node-number
  [ set distance-tmp distance previous-node * speed / step
    foreach (range (position node path) (next-node-number - 1)) [ j -> set distance-tmp distance-tmp + [weight] of [ out-link-to item ( j + 1 ) [path] of myself] of item j path ]
  ]
  [ set distance-tmp distance next-node * speed / step
    foreach (range next-node-number (position node path) ) [ j -> set distance-tmp distance-tmp + [weight] of [ out-link-to item ( j + 1 ) [path] of myself] of item j path ]
  ]
  report distance-tmp
end

to free-node [these-nodes]
  set-airplane-ahead
  ifelse airplane-ahead != nobody and ( [waiting] of airplane-ahead = true )
  [ wait-here
    set reason-waiting list "airplane ahead" airplane-ahead
    set airplane-waiting (list airplane-ahead)
    if waiting-time = 1 [set waiting-times-reason lput list airplane-ahead ticks waiting-times-reason]
  ]
  [ ifelse airplane-ahead != nobody
    [ settings-airplane-ahead
      ifelse distance next-node < step
      [change-road]
      [fd-step]
      set distance-airplane-ahead lput value-distance airplane-ahead distance-airplane-ahead
    ]
    [ settings-no-airplane-ahead
      ifelse distance next-node < step
      [ change-road ]
      [ fd-step]
    ]
    foreach these-nodes [this-node ->
      ask my-out-conflicts with [member? ([this-node] of myself) in-node] [
        activate-conflict this-node
      ]
      ask this-node [
        set occupied-by myself
        set occupied-list lput (list ticks myself) occupied-list
        set begin-occupation lput myself begin-occupation
        set begin-occupation-time  ticks
      ]
    ]
  ]
end

to-report node-to-occupy
  let target-node nobody
 foreach (range next-node-number (next-node-number + ( min list (length path - next-node-number) 3 ) ) ) [ node-number ->
 let candidate-node ( item node-number path )
    if ( value-distance-node candidate-node < 60 + length-airplane / 2  + speed  and ( not member? self [begin-occupation] of candidate-node ) )
      [set target-node candidate-node
    ]
  ]
  report target-node

end

to stop-error
  if reason-waiting = list "occupation time" self [set stop? true]
  if ((( 60 + length-airplane / 2 ) + speed ) * step / speed < distance previous-node ) and ([occupied-by] of previous-node = self)
  [ set stop? true
    inspect self
    inspect previous-node ]
  if ticks = 86000 [set stop? true]
  if (distancexy 0 0 ) > 37 [
    set stop? true
  inspect self
  show 37]
end

to-report conflicts-start-node
  let reporter nobody
  foreach lput start-node next-nodes [ x ->
    let my-conflicts- my-in-conflicts with [x = this-out-node and active = true]
    if any? my-conflicts- [set reporter (link-set reporter my-conflicts-)]
  ]
  report reporter
end

to-report occupations-start-node
  let reporter []
  foreach lput start-node next-nodes [ x ->
    if [occupied-by] of x != nobody
    [ ask x [set reporter lput occupied-by reporter] ]
  ]
  report reporter
end

to-report origin-conflicts [my-conflicts-]
  let origins []
  if my-conflicts != nobody [ ask my-conflicts- [ set origins lput origin origins ] ]
  report origins
end

to set-reason-waiting-conflicts [my-conflicts-]
  set reason-waiting my-conflicts-
  set airplane-waiting origin-conflicts my-conflicts-
  if waiting-time = 1 [set waiting-times-reason lput (list sort my-conflicts- ticks) waiting-times-reason]
end

to set-reason-waiting-occupation [occupied-by-]
  set reason-waiting (list "occupied" occupied-by-)
  set airplane-waiting occupied-by-
  if waiting-time = 1 [set waiting-times-reason lput (list "occupation" occupied-by- ticks) waiting-times-reason]
end

to deconflict [first-airplane]
  if waiting [ foreach airplane-waiting [ x -> if x != nobody [ ask x [ifelse x = first-airplane [show "deconflict" die][deconflict first-airplane]] ] ] ]
end

to move
  ask airplanes [
    stop-error

    if (random-float 1 < p-unanswered and unanswered-time = 0)
    [ set unanswered-time round(random-exponential 30)
      set wt-unanswered wt-unanswered + unanswered-time
    ]

    ifelse unanswered-time > 0 [
      wait-here
      set reason-waiting "unanswered"
      set airplane-waiting (list nobody)
      set unanswered-time unanswered-time - 1

    ][
      ifelse distance start-node = 0 [
        ifelse conflicts-start-node != nobody
        [ wait-here
          set-reason-waiting-conflicts conflicts-start-node ]
        [ ifelse occupations-start-node = []
          [ free-node lput start-node next-nodes ]
          [ wait-here
            set-reason-waiting-occupation occupations-start-node ]
        ]
      ][
        let my-node-to-occupy node-to-occupy
        ifelse (my-node-to-occupy != nobody)
        [ ifelse any? my-in-conflicts with [ [my-node-to-occupy] of myself = this-out-node and active = true ]
          [ wait-here
            set-reason-waiting-conflicts my-in-conflicts with [ [my-node-to-occupy] of myself = this-out-node and active = true ] ]
          [ ifelse [occupied-by] of my-node-to-occupy = nobody
            [ free-node (list my-node-to-occupy)
              set distance-occupied lput list my-node-to-occupy value-distance-node my-node-to-occupy distance-occupied ]
            [ wait-here
              set-reason-waiting-occupation (list [occupied-by] of my-node-to-occupy) ]
          ]
        ][
          ifelse distance next-node > step
          [ do-one-step ]
          [ ifelse next-node-number != (-1 + length path)
            [ change-road ]
            [ move-to next-node
              ask next-node [
                set occupied-by nobody
                set occupied-list lput (list ticks nobody) occupied-list
              ]
              set taxi-times lput taxi-time taxi-times
              if total-waiting-time > 0 [
                set total-waiting-times-list lput total-waiting-time total-waiting-times-list]
              die
            ]
          ]
        ]
      ]
    deconflict self
  ]


  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
418
12
1176
771
-1
-1
10.0
1
10
1
1
1
0
0
0
1
-37
37
-37
37
0
0
1
ticks
30.0

BUTTON
260
281
323
314
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
58
280
131
313
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

SLIDER
45
215
341
248
time-interval-departures
time-interval-departures
6
200
29.0
1
1
seconds
HORIZONTAL

PLOT
1191
271
1533
507
taxi times
taxi time
frequancy
0.0
6000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "set-histogram-num-bars 50" "histogram taxi-times\n"

BUTTON
165
281
228
314
NIL
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

PLOT
1179
512
1535
743
waiting-times
waiting time for each stop
NIL
0.0
500.0
0.0
10.0
true
false
"set-histogram-num-bars 50" ""
PENS
"default" 1.0 1 -16777216 true "set-histogram-num-bars 50" "histogram waiting-times"

BUTTON
155
349
233
382
NIL
export
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
1190
13
1531
268
Number of airplanes
time
number of airplanes
0.0
50000.0
0.0
30.0
true
false
"" "plot count airplanes ticks"
PENS
"default" 1.0 0 -16777216 true "" "plot count airplanes"

CHOOSER
106
46
280
91
strategy
strategy
"night" "day" "ground controller"
1

SLIDER
20
164
192
197
p-change-path
p-change-path
0
1
0.0
0.05
1
NIL
HORIZONTAL

SLIDER
203
164
375
197
p-unanswered
p-unanswered
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
84
111
304
144
threshold-strategy
threshold-strategy
0
30
15.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Simulation of the ground traffic at Paris Charles de Gaulle airport. The configuration of the runways and of the standard routes is facing east.

## HOW IT WORKS
Two networks to simulate the taxiways are created: one directed (roads) and the other undirected (unroads). They have the intersection between taxiways as nodes and the taxiways as links. The weight of the links is the length of the taxiway that they represent. 

The airplanes are created with a time interval between two creations decided by the user (time-interval-departure).
The airplanes have an origin node and a destination node. One of the parking slots is the origin for departing airplanes and the destination for landing airplanes. One of the runway entrances is the destination node for departing aircraft and one of the runway exits is the origin node for landing airplanes.

The airplane moves towards its destination node following the strategy set by the user: with the day strategy they use the shortest path on the directed network, with the night strategy they use the shortest path on the undirected network, with the ground controller strategy they use the night strategy if the number of aircraft on the taxiway is less than threshold-strategy, the day one otherwise. 

The aircraft move avoinding three types of conflicts with other airplanes: 

-Intersection occupation: when the head of an airplane arrives at 60 m from an intersection, if the intersection is free it occupies it. It then continues his journey and sets the intersection free as soon as his tail is at a distance of 60 m from it. If the intersection is occupied, it waits at a distance of 60 m. When its journey starts again, the last waiting time is added to the waiting times histogram. 

-Face to face airplanes: a network of type face-to-face conflicts is created. The network has the airplanes in potential conflict as nodes. A link between two airplanes is created when, during taxiing, they have to cross the same taxiways in opposite directions. The conflict links have a start intersection and an end intersection, that delimit the conflict common taxiways, and an activation attribute, that lights up when one of the two airplanes is crossing the conflict area. When an aircraft arrives at 60 m from the conflict area's beginning, if the conflict link is not active it activates it and it carries on its journey. When it leaves behind the conflict area at a distance of 60 m, it turns off the link. If the link is active, on the contrary, it waits until it turns off. When its journey starts again, the last waiting time is added to the waiting times histogram. 

Airplane ahead: if an airplane is taxiing in front of a second one in the same direction, with his tail at a distance of less than 60 m from the head of the airplane behind and a lower speed, the second sets his speed equal to the one of the first. When the first airplane stops, the second does too. When its journey starts again, the last waiting time is added to the waiting times histogram. 

At the end of its journey, the airplane dies and its taxi time is added to the correspondent histogram.


## HOW TO USE IT


Before starting the simulation, set all the parameters:
-time-interval-departures: time interval between two successive departures.
-strategy: night, day or a mix of the two based on the folowing parameter.
-threshold-strategy: when the ground controller strategy is on, this parameter represents the number of airplanes on the platform at which the strategy passes from the night to the day one.
-p-change: probability that an aircraft is assigned a path that contains a deviation from the shortest path. 
-p-unanswered: probability that for each tick an airplane stops for a time picked randomly from an exponential distribution of mean 30.


## REFERENCES
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
NetLogo 6.1.1
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
