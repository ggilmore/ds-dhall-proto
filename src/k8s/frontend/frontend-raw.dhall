let Kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/package.dhall

in  { Frontend =
      { Deployment.sourcegraph-frontend
        = Kubernetes.Deployment::{
        , metadata = Kubernetes.ObjectMeta::{
          , annotations = Some
            [ { mapKey = "description"
              , mapValue = "Serves the frontend of Sourcegraph via HTTP(S)."
              }
            ]
          , labels = Some
            [ { mapKey = "app.kubernetes.io/component", mapValue = "frontend" }
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
                    [ Kubernetes.EnvVar::{
                      , name = "PGDATABASE"
                      , value = Some "sg"
                      }
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
                    , Kubernetes.EnvVar::{ name = "PGUSER", value = Some "sg" }
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
                      "index.docker.io/sourcegraph/frontend:insiders@sha256:57958d158b69ab75381089f1334fb2b58ac3cf516bed830e2b29512b9504dcc8"
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
                  , terminationMessagePolicy = Some "FallbackToLogsOnError"
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
      , Ingress.sourcegraph-frontend
        = Kubernetes.Ingress::{
        , metadata = Kubernetes.ObjectMeta::{
          , annotations = Some
            [ { mapKey = "kubernetes.io/ingress.class", mapValue = "nginx" }
            , { mapKey = "nginx.ingress.kubernetes.io/proxy-body-size"
              , mapValue = "150m"
              }
            ]
          , labels = Some
            [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
            , { mapKey = "app.kubernetes.io/component", mapValue = "frontend" }
            , { mapKey = "deploy", mapValue = "sourcegraph" }
            , { mapKey = "sourcegraph-resource-requires"
              , mapValue = "no-cluster-admin"
              }
            ]
          , name = Some "sourcegraph-frontend"
          }
        , spec = Some Kubernetes.IngressSpec::{
          , rules = Some
            [ Kubernetes.IngressRule::{
              , http = Some Kubernetes.HTTPIngressRuleValue::{
                , paths =
                  [ Kubernetes.HTTPIngressPath::{
                    , backend = Kubernetes.IngressBackend::{
                      , serviceName = Some "sourcegraph-frontend"
                      , servicePort = Some (Kubernetes.IntOrString.Int 30080)
                      }
                    , path = Some "/"
                    }
                  ]
                }
              }
            ]
          }
        }
      , Role.sourcegraph-frontend
        = Kubernetes.Role::{
        , metadata = Kubernetes.ObjectMeta::{
          , labels = Some
            [ { mapKey = "app.kubernetes.io/component", mapValue = "frontend" }
            , { mapKey = "category", mapValue = "rbac" }
            , { mapKey = "deploy", mapValue = "sourcegraph" }
            , { mapKey = "sourcegraph-resource-requires"
              , mapValue = "cluster-admin"
              }
            ]
          , name = Some "sourcegraph-frontend"
          }
        , rules = Some
          [ Kubernetes.PolicyRule::{
            , apiGroups = Some [ "" ]
            , resources = Some [ "endpoints", "services" ]
            , verbs = [ "get", "list", "watch" ]
            }
          ]
        }
      , RoleBinding.sourcegraph-frontend
        = Kubernetes.RoleBinding::{
        , metadata = Kubernetes.ObjectMeta::{
          , labels = Some
            [ { mapKey = "app.kubernetes.io/component", mapValue = "frontend" }
            , { mapKey = "category", mapValue = "rbac" }
            , { mapKey = "deploy", mapValue = "sourcegraph" }
            , { mapKey = "sourcegraph-resource-requires"
              , mapValue = "cluster-admin"
              }
            ]
          , name = Some "sourcegraph-frontend"
          }
        , roleRef = Kubernetes.RoleRef::{
          , apiGroup = ""
          , kind = "Role"
          , name = "sourcegraph-frontend"
          }
        , subjects = Some
          [ Kubernetes.Subject::{
            , kind = "ServiceAccount"
            , name = "sourcegraph-frontend"
            }
          ]
        }
      , Service =
        { sourcegraph-frontend = Kubernetes.Service::{
          , metadata = Kubernetes.ObjectMeta::{
            , annotations = Some
              [ { mapKey = "prometheus.io/port", mapValue = "6060" }
              , { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
              ]
            , labels = Some
              [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
              , { mapKey = "app.kubernetes.io/component"
                , mapValue = "frontend"
                }
              , { mapKey = "deploy", mapValue = "sourcegraph" }
              , { mapKey = "sourcegraph-resource-requires"
                , mapValue = "no-cluster-admin"
                }
              ]
            , name = Some "sourcegraph-frontend"
            }
          , spec = Some Kubernetes.ServiceSpec::{
            , ports = Some
              [ Kubernetes.ServicePort::{
                , name = Some "http"
                , port = 30080
                , targetPort = Some (Kubernetes.IntOrString.String "http")
                }
              ]
            , selector = Some
              [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
            , type = Some "ClusterIP"
            }
          }
        , sourcegraph-frontend-internal = Kubernetes.Service::{
          , metadata = Kubernetes.ObjectMeta::{
            , labels = Some
              [ { mapKey = "app", mapValue = "sourcegraph-frontend" }
              , { mapKey = "app.kubernetes.io/component"
                , mapValue = "frontend"
                }
              , { mapKey = "deploy", mapValue = "sourcegraph" }
              , { mapKey = "sourcegraph-resource-requires"
                , mapValue = "no-cluster-admin"
                }
              ]
            , name = Some "sourcegraph-frontend-internal"
            }
          , spec = Some Kubernetes.ServiceSpec::{
            , ports = Some
              [ Kubernetes.ServicePort::{
                , name = Some "http-internal"
                , port = 80
                , targetPort = Some
                    (Kubernetes.IntOrString.String "http-internal")
                }
              ]
            , selector = Some
              [ { mapKey = "app", mapValue = "sourcegraph-frontend" } ]
            , type = Some "ClusterIP"
            }
          }
        }
      , ServiceAccount.sourcegraph-frontend
        = Kubernetes.ServiceAccount::{
        , imagePullSecrets = Some
          [ Kubernetes.LocalObjectReference::{ name = Some "docker-registry" } ]
        , metadata = Kubernetes.ObjectMeta::{
          , labels = Some
            [ { mapKey = "app.kubernetes.io/component", mapValue = "frontend" }
            , { mapKey = "category", mapValue = "rbac" }
            , { mapKey = "deploy", mapValue = "sourcegraph" }
            , { mapKey = "sourcegraph-resource-requires"
              , mapValue = "no-cluster-admin"
              }
            ]
          , name = Some "sourcegraph-frontend"
          }
        }
      }
    }
