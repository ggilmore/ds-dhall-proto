let Kubernetes/SecurityContext =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.SecurityContext.dhall sha256:ebd2dfc83e8a5bec031f3d71e9c5bf2ac583ab56572f8d7f3a8f9c9f113e3a0a

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Image/manipulate = (../../../../util/package.dhall).Image/manipulate

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal.Type
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let securityContext =
              if    globalOpts.nonRoot
              then  Some nonRootSecurityContext
              else  None Kubernetes/SecurityContext.Type

        let cgContainers = cg.Frontend.Deployment.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let frontendImage =
              Image/manipulate manipulate/options cgContainers.Frontend.image

        let jaegerImgae =
              Image/manipulate manipulate/options cgContainers.Jaeger.image

        let FrontendConfig =
              cg.Frontend.Deployment.Containers.Frontend
              with image = frontendImage
              with securityContext = securityContext

        let JaegerConfig =
              cg.Frontend.Deployment.Containers.Jaeger
              with image = jaegerImgae
              with securityContext = securityContext

        in  { namespace = globalOpts.namespace
            , Deployment.Containers
              =
              { Frontend = FrontendConfig, Jaeger = JaegerConfig }
            }

in  toInternal
