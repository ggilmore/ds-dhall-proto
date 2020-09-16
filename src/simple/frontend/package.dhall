let util = ../../util/package.dhall

let Image = util.Image

let Container = util.Container

let image =
      Image::{
      , name = "sourcegraph/frontend"
      , registry = Some "index.docker.io"
      , digest = Some
          "776606b680d7ce4a5d37451831ef2414ab10414b5e945ed5f50fe768f898d23f"
      , tag = "3.19.2"
      }

let cacheDir = "/mnt/cache"

let volumes = { CACHE_DIR = cacheDir }

let frontendEnvironment =
      { CACHE_DIR = { name = "CACHE_DIR", value = cacheDir }
      , SRC_GIT_SERVERS =
        { name = "SRC_GIT_SERVERS", value = "gitserver-0.gitserver:3178" }
      }

let frontendHostname = "sourcegraph-frontend"

let httpPort = 3080

let healthCheck =
      util.HealthCheck::{
      , endpoint = "/healthz"
      , port = httpPort
      , scheme = util.HealthCheck/Scheme.HTTP
      , initialDelaySeconds = Some 300
      , retries = Some 3
      , timeoutSeconds = Some 10
      , intervalSeconds = Some 5
      }

let frontendContainer =
        Container::{ image }
      ∧ { name = frontendHostname
        , hostname = frontendHostname
        , environment = frontendEnvironment
        , volumes
        , ports.http = 3080
        }

let internalHostname = "sourcegraph-frontend-internal"

let internalContainer =
        frontendContainer
      ⫽ { name = internalHostname
        , hostname = internalHostname
        , ports.http-internal = 3090
        }

let Containers =
      { frontend = frontendContainer ∧ { HealthCheck = healthCheck }
      , frontendInternal = internalContainer
      }

in  { Containers }
