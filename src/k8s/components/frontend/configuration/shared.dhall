let util = ../../../../util/package.dhall

let environment = ./environment/environment.dhall

let Image = util.Image

let ContainerConfiguration =
      { Type = { image : Image.Type, Environment : environment.Type }
      , default.Environment = environment.default
      }

in  { ContainerConfiguration }
