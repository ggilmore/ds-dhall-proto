let port = < http | http-internal >

let toNatural
    : ∀(p : port) → Natural
    = λ(p : port) → merge { http = 3080, http-internal = 3090 } p

in  { port, toNatural }
