let util = ../../util/package.dhall

let configuration = (./configuration.dhall).configuration

let environment/toList = (./environment.dhall).environment/toList

let DockerCompose/HealthCheck = ../schemas/healthcheck.dhall

let Simple/Frontend = ../../simple/frontend/schemas.dhall

let component =
      { Type =
          { container_name : Text
          , cpus : Natural
          , environment : List Text
          , healthcheck : DockerCompose/HealthCheck.Type
          , image : Text
          , mem_limit : Text
          , networks : List Text
          , restart : Text
          , volumes : List Text
          }
      , default = { restart = "always", networks = [ "sourcegraph" ] }
      }

let generate
    : ∀(c : configuration.Type) → component.Type
    = λ(c : configuration.Type) →
        let name = "sourcegraph-frontend-0"

        let environment = environment/toList c.environment

        let simple = Simple/Frontend.Containers.frontend

        let mountDir = simple.volumes.CACHE_DIR

        let image = util.Image/show c.image

        in  component::{
            , container_name = name
            , cpus = 4
            , mem_limit = "8g"
            , environment
            , healthcheck = c.healthcheck
            , image
            , volumes = [ "${name}:${mountDir}" ]
            }

let toList
    : ∀(c : configuration.Type) → List component.Type
    = λ(c : configuration.Type) → [ generate c ]

in  toList
