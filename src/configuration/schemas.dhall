let types = ./types.dhall

let Image =
      { Type = types.Image
      , default = { registry = Some "index.docker.io", digest = None Text }
      }

let Container = { Type = types.Container, default = {=} }

let EnvVar = { Type = types.EnvVar, default.value = Some "" }

in  { Image, Container, EnvVar }
