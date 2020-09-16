let shared = ./shared.dhall

let ContainerConfiguration = shared.ContainerConfiguration

let Simple/Frontend/Containers =
      (../../../../simple/frontend/package.dhall).Containers

let environment = ./environment/environment.dhall

let FrontendContainer =
      { Type = ContainerConfiguration.Type ⩓ { Environment : environment.Type }
      , default =
            ContainerConfiguration.default
          ⫽ { Environment = environment.default
            , image = Simple/Frontend/Containers.frontend.image
            }
      }

let JaegerContainer =
      ContainerConfiguration
      with default.image = shared.JaegerImage

let Containers =
      { Type =
          { Frontend : FrontendContainer.Type, Jaeger : JaegerContainer.Type }
      , default =
        { Frontend = FrontendContainer.default
        , Jaeger = JaegerContainer.default
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
