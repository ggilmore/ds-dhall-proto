let Kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/package.dhall sha256:1fd165c978dcf237ed0d27e8a7a3e9bffc1aa96d5833f7bb5092e5b64bdffcd6

let Configuration/global = ../../configuration/global.dhall

let Configuration/Internal = ./configuration/internal.dhall

let Configuration/toInternal = ./configuration/toInternal.dhall

let environment/toList = ./configuration/environment/toList.dhall

let Simple/Frontend = ../../../simple/frontend/package.dhall

let util = ../../../util/package.dhall

let jaegerContainer = ./jaeger.dhall

let deploySourcegraphLabel = { deploy = "sourcegraph" }

let componentLabel = { `app.kubernetes.io/component` = "frontend" }

let noClusterAdminLabel = { sourcegraph-resource-requires = "no-cluster-admin" }

let appLabel = { app = "sourcegraph-frontend" }

let Deployment/generate
    : ∀(c : Configuration/Internal.Type) → Kubernetes.Deployment.Type
    = λ(c : Configuration/Internal.Type) →
        let config = c.Deployment

        let simple/frontend = Simple/Frontend.Containers.frontend

        let simple/internal = Simple/Frontend.Containers.frontendInternal

        let deploymentLabels =
              toMap
                (deploySourcegraphLabel ∧ componentLabel ∧ noClusterAdminLabel)

        let environment =
              environment/toList config.Containers.Frontend.Environment

        let image = util.Image/show config.Containers.Frontend.image

        let livenessProbe = util.HealthCheck/tok8s simple/frontend.HealthCheck

        let readinessProbe
            : Kubernetes.Probe.Type
            = livenessProbe
              with initialDelaySeconds = None Natural

        let httpPort =
              Kubernetes.ContainerPort::{
              , containerPort = simple/frontend.ports.http
              , name = Some "http"
              }

        let internalPort =
              Kubernetes.ContainerPort::{
              , containerPort = simple/internal.ports.http-internal
              , name = Some "http-internal"
              }

        let cacheVolume =
              Kubernetes.VolumeMount::{
              , mountPath = simple/frontend.volumes.CACHE_DIR
              , name = "cache-ssd"
              }

        let securityContext = config.Containers.Frontend.securityContext

        let deployment =
              Kubernetes.Deployment::{
              , metadata = Kubernetes.ObjectMeta::{
                , annotations = Some
                    ( toMap
                        { description =
                            "Serves the frontend of Sourcegraph via HTTP(S)."
                        }
                    )
                , labels = Some deploymentLabels
                , name = Some "sourcegraph-frontend"
                , namespace = c.namespace
                }
              , spec = Some Kubernetes.DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes.LabelSelector::{
                  , matchLabels = Some (toMap appLabel)
                  }
                , strategy = Some Kubernetes.DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes.RollingUpdateDeployment::{
                    , maxSurge = Some (Kubernetes.IntOrString.Int 2)
                    , maxUnavailable = Some (Kubernetes.IntOrString.Int 0)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template = Kubernetes.PodTemplateSpec::{
                  , metadata = Kubernetes.ObjectMeta::{
                    , labels = Some (toMap (appLabel ∧ deploySourcegraphLabel))
                    }
                  , spec = Some Kubernetes.PodSpec::{
                    , containers =
                      [ Kubernetes.Container::{
                        , args = Some [ "serve" ]
                        , env = Some environment
                        , image = Some image
                        , livenessProbe = Some livenessProbe
                        , name = "frontend"
                        , ports = Some [ httpPort, internalPort ]
                        , readinessProbe = Some readinessProbe
                        , resources = Some Kubernetes.ResourceRequirements::{
                          , limits = Some
                            [ { mapKey = "cpu", mapValue = "2" }
                            , { mapKey = "memory", mapValue = "4G" }
                            ]
                          , requests = Some
                            [ { mapKey = "cpu", mapValue = "2" }
                            , { mapKey = "memory", mapValue = "2G" }
                            ]
                          }
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , securityContext
                        , volumeMounts = Some [ cacheVolume ]
                        }
                      , jaegerContainer
                      ]
                    , securityContext = Some Kubernetes.PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , serviceAccountName = Some "sourcegraph-frontend"
                    , volumes = Some
                      [ Kubernetes.Volume::{
                        , emptyDir = Some Kubernetes.EmptyDirVolumeSource::{=}
                        , name = "cache-ssd"
                        }
                      ]
                    }
                  }
                }
              }

        in  deployment

let generate =
      λ(cg : Configuration/global.Type) →
        let config = Configuration/toInternal cg

        let deployment = Deployment/generate config

        in  { Deployment.sourcegraph-frontend = deployment }

in  generate
