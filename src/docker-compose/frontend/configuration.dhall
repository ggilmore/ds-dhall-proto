let util = ../../util/package.dhall

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let EnvVar = util.EnvVar

let Map/values = https://prelude.dhall-lang.org/v18.0.0/Map/values

let List/unpackOptionals =
      https://prelude.dhall-lang.org/v18.0.0/List/unpackOptionals

let List/map = https://prelude.dhall-lang.org/v18.0.0/List/map

let Simple/Frontend = ../../simple/frontend/schemas.dhall

let simpleInternal = Simple/Frontend.Containers.frontendInternal

let SRC_FRONTEND_INTERNAL =
      "${simpleInternal.hostname}:${Natural/show
                                      simpleInternal.ports.http-internal}"

let environment = (./environment.dhall).environment

let configuration =
      { Type =
          { image : util.Image.Type
          , replicas : Natural
          , environment : environment.Type
          , healthcheck : DockerCompose/HealthCheck.Type
          }
      , default =
        { environment = environment.default
        , image = Simple/Frontend.Containers.frontend.image
        , replicas = 1
        , healthcheck =
            util.HealthCheck/toDockerCompose
              Simple/Frontend.Containers.frontend.HealthCheck
        }
      }

in  { configuration }
