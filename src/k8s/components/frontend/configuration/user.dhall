let sharedConfiguration = ./shared.dhall

let Simple/Frontend/Containers =
      (../../../../simple/frontend/package.dhall).Containers

let FrontendContainer =
      sharedConfiguration.ContainerConfiguration
      with default.image = Simple/Frontend/Containers.frontend.image

let InternalContainer =
      FrontendContainer
      with default.image = Simple/Frontend/Containers.frontendInternal.image

let Containers =
      { Type =
          { Frontend : FrontendContainer.Type
          , FrontendInteral : InternalContainer.Type
          }
      , default =
        { Frontend = FrontendContainer.default
        , FrontendInteral = InternalContainer.default
        }
      }

let Deployment =
      { Type = { Containers : Containers.Type }
      , default.Containers = Containers.default
      }

let configuration =
      { Type = { Deployment : Deployment.Type }
      , default.Deployment = Deployment.default
      }

in  configuration
