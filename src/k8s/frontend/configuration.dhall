let configuration = ../../configuration/package.dhall

let Kubernetes/EnvVar =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/ObjectFieldSelector =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let Simple/Frontend = ../../simple/frontend/schemas.dhall

let Image = configuration.Image

let containerConfiguration =
      { Type =
        { image: Image.Type
        , runAsUser:  Optional Natural
        , runAsGroup : Optional Natural
        , allowPrivilegeEscalation : Optional Bool
        }
      , default =
        { runAsUser = None Natural
        , runAsGroup = None Natural
        , allowPrivledgeEscalation = None Bool
        }
      }

let postgresEnv =
      { Type =
        { PGDATABASE: Kubernetes/EnvVar.Type
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

let frontendEnvironment =
        { Type =
          { SRC_GIT_SERVERS : Kubernetes/EnvVar.Type
          , POD_NAME : Kubernetes/EnvVar.Type
          , CACHE_DIR : Kubernetes/EnvVar.Type
          , GRAFANA_SERVER_URL : Kubernetes/EnvVar.Type
          , JAEGER_SERVER_URL : Kubernetes/EnvVar.Type
          , PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL : Kubernetes/EnvVar.Type
          , PROMETHEUS_URL : Kubernetes/EnvVar.Type
          } //\\ postgresEnv.Type
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
            , value = Some "/mnt/cache/\$(POD_NAME)"
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
          } /\ postgresEnv.default
        }



let frontendContainer =

       { Type = containerConfiguration.Type //\\ { Environment : frontendEnvironment.Type }
        , default =
          containerConfiguration.default /\ { Environment = frontendEnvironment.default
          , image = Simple/Frontend.Containers.frontend.image
          }
        }

let internalContainer =
      frontendContainer
      with default.image = Simple/Frontend.Containers.frontendInternal.image

let Containers =
      { Type =
        { Frontend : frontendContainer.Type
        , FrontendInteral : internalContainer.Type
        }
      , default =
        { Frontend = frontendContainer.default
        , FrontendInteral = internalContainer.default
        }
      }

let Deployment =
      { Type = {Containers : Containers.Type }, default = Containers.default }

let configuration =
      { Type = { namespace : Optional Text, Deployment : Deployment.Type }
      , default = { namespace = None Text, Deployment = Deployment.default }
      }

in  configuration
