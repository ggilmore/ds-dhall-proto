let configuration = ../../configuration/package.dhall

let Image = configuration.Image

let Image/show = configuration.Image/show

let Frontend/configuration = ./configuration.dhall

let Kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/package.dhall

let generate =
      λ(c : Frontend/configuration.Type) →
        let out =
              { Deployment.sourcegraph-frontend
                =
                { metadata = Kubernetes.ObjectMeta::{
                  , namespace = c.namespace
                  , annotations = Some
                    [ { mapKey = "description"
                      , mapValue =
                          "Serves the frontend of Sourcegraph via HTTP(S)."
                      }
                    ]
                  , labels = Some
                    [ { mapKey = "app.kubernetes.io/component"
                      , mapValue = "frontend"
                      }
                    , { mapKey = "deploy", mapValue = "sourcegraph" }
                    , { mapKey = "sourcegraph-resource-requires"
                      , mapValue = "no-cluster-admin"
                      }
                    ]
                  , name = Some "sourcegraph-frontend"
                  }
                , spec = Some Kubernetes.DeploymentSpec::{
                  , minReadySeconds = Some 10
                  , replicas = Some 1
                  , revisionHistoryLimit = Some 10
                  , selector = Kubernetes.LabelSelector::{
                    , matchLabels = Some
                      [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
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
                      , labels = Some
                        [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        ]
                      }
                    , spec = Some Kubernetes.PodSpec::{
                      , containers =
                        [ Kubernetes.Container::{
                          , args = Some [ "serve" ]
                          , env = Some
                            [ c.Deployment.Containers.Frontend.Environment.PGDATABASE
                            , Kubernetes.EnvVar::{
                              , name = "PGHOST"
                              , value = Some "pgsql"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "PGPORT"
                              , value = Some "5432"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "PGSSLMODE"
                              , value = Some "disable"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "PGUSER"
                              , value = Some "sg"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "SRC_GIT_SERVERS"
                              , value = Some "gitserver-0.gitserver:3178"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "POD_NAME"
                              , valueFrom = Some Kubernetes.EnvVarSource::{
                                , fieldRef = Some Kubernetes.ObjectFieldSelector::{
                                  , fieldPath = "metadata.name"
                                  }
                                }
                              }
                            , Kubernetes.EnvVar::{
                              , name = "CACHE_DIR"
                              , value = Some "/mnt/cache/\$(POD_NAME)"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "GRAFANA_SERVER_URL"
                              , value = Some "http://grafana:30070"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "JAEGER_SERVER_URL"
                              , value = Some "http://jaeger-query:16686"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
                              , value = Some
                                  "http://precise-code-intel-bundle-manager:3187"
                              }
                            , Kubernetes.EnvVar::{
                              , name = "PROMETHEUS_URL"
                              , value = Some "http://prometheus:30090"
                              }
                            ]
                          , image = Some
                              ( Image/show
                                  c.Deployment.Containers.Frontend.image
                              )
                          , livenessProbe = Some Kubernetes.Probe::{
                            , httpGet = Some Kubernetes.HTTPGetAction::{
                              , path = Some "/healthz"
                              , port = Kubernetes.IntOrString.String "http"
                              , scheme = Some "HTTP"
                              }
                            , initialDelaySeconds = Some 300
                            , timeoutSeconds = Some 5
                            }
                          , name = "frontend"
                          , ports = Some
                            [ Kubernetes.ContainerPort::{
                              , containerPort = 3080
                              , name = Some "http"
                              }
                            , Kubernetes.ContainerPort::{
                              , containerPort = 3090
                              , name = Some "http-internal"
                              }
                            ]
                          , readinessProbe = Some Kubernetes.Probe::{
                            , httpGet = Some Kubernetes.HTTPGetAction::{
                              , path = Some "/healthz"
                              , port = Kubernetes.IntOrString.String "http"
                              , scheme = Some "HTTP"
                              }
                            , periodSeconds = Some 5
                            , timeoutSeconds = Some 5
                            }
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
                          , volumeMounts = Some
                            [ Kubernetes.VolumeMount::{
                              , mountPath = "/mnt/cache"
                              , name = "cache-ssd"
                              }
                            ]
                          }
                        , Kubernetes.Container::{
                          , args = Some
                            [ "--reporter.grpc.host-port=jaeger-collector:14250"
                            , "--reporter.type=grpc"
                            ]
                          , env = Some
                            [ Kubernetes.EnvVar::{
                              , name = "POD_NAME"
                              , valueFrom = Some Kubernetes.EnvVarSource::{
                                , fieldRef = Some Kubernetes.ObjectFieldSelector::{
                                  , apiVersion = Some "v1"
                                  , fieldPath = "metadata.name"
                                  }
                                }
                              }
                            ]
                          , image = Some
                              "index.docker.io/sourcegraph/jaeger-agent:insiders@sha256:69b0a662e47534c78a91c2a1d19f495eef750ebaacf190f4e87b676858595cef"
                          , name = "jaeger-agent"
                          , ports = Some
                            [ Kubernetes.ContainerPort::{
                              , containerPort = 5775
                              , protocol = Some "UDP"
                              }
                            , Kubernetes.ContainerPort::{
                              , containerPort = 5778
                              , protocol = Some "TCP"
                              }
                            , Kubernetes.ContainerPort::{
                              , containerPort = 6831
                              , protocol = Some "UDP"
                              }
                            , Kubernetes.ContainerPort::{
                              , containerPort = 6832
                              , protocol = Some "UDP"
                              }
                            ]
                          , resources = Some Kubernetes.ResourceRequirements::{
                            , limits = Some
                              [ { mapKey = "cpu", mapValue = "1" }
                              , { mapKey = "memory", mapValue = "500M" }
                              ]
                            , requests = Some
                              [ { mapKey = "cpu", mapValue = "100m" }
                              , { mapKey = "memory", mapValue = "100M" }
                              ]
                            }
                          }
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
              }

        in  out

in  generate
