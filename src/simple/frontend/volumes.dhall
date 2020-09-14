let volumes = < CACHE_DIR >

let toPath
    : ∀(v : volumes) → Text
    = λ(v : volumes) → merge { CACHE_DIR = "/mnt/cache" } v

in  { volumes, toPath }
