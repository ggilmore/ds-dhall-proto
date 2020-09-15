let util = ../util/package.dhall

let EnvVar = util.EnvVar

let Map/values = https://prelude.dhall-lang.org/v18.0.0/Map/values

let List/unpackOptionals =
      https://prelude.dhall-lang.org/v18.0.0/List/unpackOptionals

let List/map = https://prelude.dhall-lang.org/v18.0.0/List/map

let Simple/Frontend = ../simple/frontend/schemas.dhall

let simpleInternal = Simple/Frontend.Containers.frontendInternal

let SRC_FRONTEND_INTERNAL =
      "${simpleInternal.hostname}:${Natural/show
                                      simpleInternal.ports.http-internal}"

let util = ../util/package.dhall

let EnvVar = util.EnvVar

let environment =
      { Type =
          { DEPLOY_TYPE : EnvVar.Type
          , GOMAXPROCS : EnvVar.Type
          , JAEGER_AGENT_HOST : EnvVar.Type
          , PGHOST : EnvVar.Type
          , SRC_GIT_SERVERS : EnvVar.Type
          , SRC_FRONTEND_INTERNAL : EnvVar.Type
          , SRC_SYNTECT_SERVER : EnvVar.Type
          , SEARCHER_URL : EnvVar.Type
          , SYMBOLS_URL : EnvVar.Type
          , INDEXED_SEARCH_SERVERS : EnvVar.Type
          , REPO_UPDATER_URL : EnvVar.Type
          , PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL : EnvVar.Type
          , GRAFANA_SERVER_URL : EnvVar.Type
          , JAEGER_SERVER_URL : EnvVar.Type
          , GITHUB_BASE_URL : EnvVar.Type
          , PROMETHEUS_URL : EnvVar.Type
          }
      , default =
        { DEPLOY_TYPE = EnvVar::{
          , name = "DEPLOY_TYPE"
          , value = Some "docker-compose"
          }
        , GOMAXPROCS = EnvVar::{ name = "GOMAXPROCS", value = Some "12" }
        , JAEGER_AGENT_HOST = EnvVar::{
          , name = "JAEGER_AGENT_HOST"
          , value = Some "jaeger"
          }
        , PGHOST = EnvVar::{ name = "PGHOST", value = Some "pgsql" }
        , SRC_GIT_SERVERS = EnvVar::{
          , name = "SRC_GIT_SERVERS"
          , value = Some "gitserver-0:3178"
          }
        , SRC_SYNTECT_SERVER = EnvVar::{
          , name = "SRC_SYNTECT_SERVER"
          , value = Some "http://syntect-server:9238"
          }
        , SRC_FRONTEND_INTERNAL = EnvVar::{
          , name = "SRC_FRONTEND_INTERNAL"
          , value = Some SRC_FRONTEND_INTERNAL
          }
        , SEARCHER_URL = EnvVar::{
          , name = "SEARCHER_URL"
          , value = Some "http://searcher-0:3181"
          }
        , SYMBOLS_URL = EnvVar::{
          , name = "SYMBOLS_URL"
          , value = Some "http://symbols-0:3184"
          }
        , INDEXED_SEARCH_SERVERS = EnvVar::{
          , name = "INDEXED_SEARCH_SERVERS"
          , value = Some "zoekt-webserver-0:6070"
          }
        , REPO_UPDATER_URL = EnvVar::{
          , name = "REPO_UPDATER_URL"
          , value = Some "http://repo-updater:3182"
          }
        , PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL = EnvVar::{
          , name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
          , value = Some "http://precise-code-intel-bundle-manager:3187"
          }
        , GRAFANA_SERVER_URL = EnvVar::{
          , name = "GRAFANA_SERVER_URL"
          , value = Some "http://grafana:3370"
          }
        , JAEGER_SERVER_URL = EnvVar::{
          , name = "JAEGER_SERVER_URL"
          , value = Some "http://jaeger:16686"
          }
        , GITHUB_BASE_URL = EnvVar::{
          , name = "GITHUB_BASE_URL"
          , value = Some "http://github-proxy:3180"
          }
        , PROMETHEUS_URL = EnvVar::{
          , name = "PROMETHEUS_URL"
          , value = Some "http://prometheus:9090"
          }
        }
      }

let envVar/show
    : ∀(e : EnvVar.Type) → Optional Text
    = λ(e : EnvVar.Type) →
        merge
          { None = None Text
          , Some = λ(value : Text) → Some "${e.name}=${value}"
          }
          e.value

let environment/toList
    : ∀(e : environment.Type) → List Text
    = λ(e : environment.Type) →
        let envList = Map/values Text EnvVar.Type (toMap e)

        let optionalTextList =
              List/map EnvVar.Type (Optional Text) envVar/show envList

        in  List/unpackOptionals Text optionalTextList

let component =
      { Type =
          { container_name : Text
          , cpus : Natural
          , environment : List Text
          , healthcheck :
              { interval : Text
              , retries : Natural
              , start_period : Text
              , test : Text
              , timeout : Text
              }
          , image : Text
          , mem_limit : Text
          , networks : List Text
          , restart : Text
          , volumes : List Text
          }
      , default = { restart = "always", networks = [ "sourcegraph" ] }
      }

let configuration =
      { Type =
          { image : util.Image.Type
          , replicas : Natural
          , environment : environment.Type
          }
      , defaults.default = environment.default
      }

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let simple/healthCheck = Simple/Frontend.Containers.frontend.HealthCheck

        in  component::{
            , container_name = "sourcegraph-frontend-0"
            , cpus = 4
            , mem_limit = "8g"
            , environment = environment/toList c.environment
            , healthcheck =
              { interval = simple/healthCheck.intervalSeconds
              , retries = 3
              , start_period = "300s"
              , test =
                  "wget -q 'http://127.0.0.1:3080/healthz' -O /dev/null || exit 1"
              , timeout = "10s"
              }
            , image = util.Image/show c.image
            , volumes =
              [ "sourcegraph-frontend-0:${simpleInternal.volumes.CACHE_DIR}" ]
            }

in  generate
