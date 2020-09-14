{ CACHE_DIR = { name = "CACHE_DIR", value = "/mnt/cache/\$(POD_NAME)" }
, GRAFANA_SERVER_URL =
  { name = "GRAFANA_SERVER_URL", value = "http://grafana:30070" }
, JAEGER_SERVER_URL =
  { name = "JAEGER_SERVER_URL", value = "http://jaeger-query:16686" }
, PGDATABASE = { name = "PGDATABASE", value = "sg" }
, PGHOST = { name = "PGHOST", value = "pgsql" }
, PGPORT = { name = "PGPORT", value = "5432" }
, PGSSLMODE = { name = "PGSSLMODE", value = "disable" }
, PGUSER = { name = "PGUSER", value = "sg" }
, PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL =
  { name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
  , value = "http://precise-code-intel-bundle-manager:3187"
  }
, PROMETHEUS_URL =
  { name = "PROMETHEUS_URL", value = "http://prometheus:30090" }
, SRC_GIT_SERVERS =
  { name = "SRC_GIT_SERVERS", value = "gitserver-0.gitserver:3178" }
}

let environment = < CACHE_DIR | SRC_GIT_SERVERS: Natural  | GRAFANA_SERVER_URL >

let toValue
    : ∀(e : environment) →  { name: Text, value: Text }
    = λ(e : environment) → merge { CACHE_DIR = "/mnt/cache", } v

let type = { name: Text, value: Text }

let environment = {
    CACHE_DIR: Text
}


let environment = {
    CACHE_DIR
}
