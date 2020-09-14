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
