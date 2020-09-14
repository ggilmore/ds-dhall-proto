let configuration/Image = ../../configuration/image/package.dhall

let Image = configuration/Image.Image

let frontendImage =
      Image::{
      , name = "sourcegraph/frontend"
      , registry = Some "index.docker.io"
      , digest = Some
          "776606b680d7ce4a5d37451831ef2414ab10414b5e945ed5f50fe768f898d23f"
      , tag = "3.19.2"
      }

let cacheFolder = "/mnt/cache/"

in  { name = "sourcegraph-frontend"
    , image = frontendImage
    , ports = { http = 3080, http-internal = 3090 }
    , environment =
      { CACHE_DIR = { name = "CACHE_DIR", value = cacheFolder }
      , SRC_GIT_SERVERS =
        { name = "SRC_GIT_SERVERS", value = "gitserver-0.gitserver:3178" }
      }
    , volumes.CACHE_DIR = cacheFolder
    , healthcheck = { command = "./script.sh", interval = "3s" }
    }
