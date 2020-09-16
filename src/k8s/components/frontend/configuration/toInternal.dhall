let Kubernetes/SecurityContext =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.SecurityContext.dhall sha256:ebd2dfc83e8a5bec031f3d71e9c5bf2ac583ab56572f8d7f3a8f9c9f113e3a0a

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let util = ../../../../util/package.dhall

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal.Type
    = λ(cg : Configuration/global.Type) →
        let globalOpts = cg.Global

        let security =
              if    globalOpts.nonRoot
              then  Some
                      Kubernetes/SecurityContext::{
                      , runAsUser = Some 100
                      , runAsGroup = Some 101
                      , allowPrivilegeEscalation = Some False
                      }
              else  None Kubernetes/SecurityContext.Type

        let cgContainers = cg.Frontend.Deployment.Containers

        let manipulate/options = globalOpts.ImageManipulations

        let frontendImage =
              util.Image/manipulate
                manipulate/options
                cgContainers.Frontend.image

        let internalImage =
              util.Image/manipulate
                manipulate/options
                cgContainers.FrontendInteral.image

        let FrontendConfig =
              cg.Frontend.Deployment.Containers.Frontend
              with image = frontendImage
              with securityContext = security

        let InternalConfig =
              cg.Frontend.Deployment.Containers.FrontendInteral
              with image = internalImage
              with securityContext = security

        in    { namespace = globalOpts.namespace
              , Deployment.Containers
                =
                { Frontend = FrontendConfig, FrontendInternal = InternalConfig }
              }
            : Configuration/internal.Type

in  toInternal
