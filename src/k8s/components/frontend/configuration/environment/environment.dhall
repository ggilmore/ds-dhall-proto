let Kubernetes/EnvVar =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.EnvVar.dhall sha256:94ea00566409bc470cd81ca29903066714557826c723dad8c25a282897c7acb3

let Kubernetes/EnvVarSource =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.EnvVarSource.dhall sha256:f049413a4f2c8db088e841b418fd403ff314e691d3d6fadc34fa65252de18e9b

let Kubernetes/ObjectFieldSelector =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall sha256:e9a6ea292ae1419188577786c4c5d84c4adb7977990181b6df73885a87b586ff

let Simple/Frontend = ../../../../../simple/frontend/package.dhall

let Simple/Frontend/frontend = Simple/Frontend.Containers.frontend

let postgresEnv =
      { Type =
          { PGDATABASE : Kubernetes/EnvVar.Type
          , PGHOST : Kubernetes/EnvVar.Type
          , PGPORT : Kubernetes/EnvVar.Type
          , PGSSLMODE : Kubernetes/EnvVar.Type
          , PGUSER : Kubernetes/EnvVar.Type
          }
      , default =
        { PGDATABASE = Kubernetes/EnvVar::{
          , name = "PGDATABASE"
          , value = Some "sg"
          }
        , PGHOST = Kubernetes/EnvVar::{ name = "PGHOST", value = Some "pgsql" }
        , PGPORT = Kubernetes/EnvVar::{ name = "PGPORT", value = Some "5432" }
        , PGSSLMODE = Kubernetes/EnvVar::{
          , name = "PGSSLMODE"
          , value = Some "disable"
          }
        , PGUSER = Kubernetes/EnvVar::{ name = "PGUSER", value = Some "sg" }
        }
      }

let environment =
      { Type =
            { SRC_GIT_SERVERS : Kubernetes/EnvVar.Type
            , POD_NAME : Kubernetes/EnvVar.Type
            , CACHE_DIR : Kubernetes/EnvVar.Type
            , GRAFANA_SERVER_URL : Kubernetes/EnvVar.Type
            , JAEGER_SERVER_URL : Kubernetes/EnvVar.Type
            , PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL : Kubernetes/EnvVar.Type
            , PROMETHEUS_URL : Kubernetes/EnvVar.Type
            }
          ⩓ postgresEnv.Type
      , default =
            { SRC_GIT_SERVERS = Kubernetes/EnvVar::{
              , name = "SRC_GIT_SERVERS"
              , value = Some "gitserver-0.gitserver:3178"
              }
            , POD_NAME = Kubernetes/EnvVar::{
              , name = "POD_NAME"
              , valueFrom = Some Kubernetes/EnvVarSource::{
                , fieldRef = Some Kubernetes/ObjectFieldSelector::{
                  , fieldPath = "metadata.name"
                  }
                }
              }
            , CACHE_DIR = Kubernetes/EnvVar::{
              , name = "CACHE_DIR"
              , value = Some
                  "${Simple/Frontend/frontend.volumes.CACHE_DIR}/\$(POD_NAME)"
              }
            , GRAFANA_SERVER_URL = Kubernetes/EnvVar::{
              , name = "GRAFANA_SERVER_URL"
              , value = Some "http://grafana:30070"
              }
            , JAEGER_SERVER_URL = Kubernetes/EnvVar::{
              , name = "JAEGER_SERVER_URL"
              , value = Some "http://jaeger-query:16686"
              }
            , PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL = Kubernetes/EnvVar::{
              , name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
              , value = Some "http://precise-code-intel-bundle-manager:3187"
              }
            , PROMETHEUS_URL = Kubernetes/EnvVar::{
              , name = "PROMETHEUS_URL"
              , value = Some "http://prometheus:30090"
              }
            }
          ∧ postgresEnv.default
      }

in  environment
