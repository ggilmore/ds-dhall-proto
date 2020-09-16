let Kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/package.dhall sha256:1fd165c978dcf237ed0d27e8a7a3e9bffc1aa96d5833f7bb5092e5b64bdffcd6

let Configuration/Internal = ./configuration/internal.dhall

let util = ../../../util/package.dhall

let Jaeger/generate
    : ∀(c : Configuration/Internal.Type) → Kubernetes.Container.Type
    = λ(c : Configuration/Internal.Type) →
        let image = util.Image/show c.Deployment.Containers.Jaeger.image

        let securityContext = c.Deployment.Containers.Jaeger.securityContext

        in  Kubernetes.Container::{
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
            , image = Some image
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
            , securityContext
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

in  Jaeger/generate
