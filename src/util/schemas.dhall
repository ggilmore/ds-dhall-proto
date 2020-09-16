let types = ./types.dhall

let Image =
      { Type = types.Image
      , default = { registry = Some "index.docker.io", digest = None Text }
      }

let Container = { Type = types.Container, default = {=} }

let EnvVar = { Type = types.EnvVar, default.value = Some "" }

let HealthCheck =
      { Type = types.HealthCheck
      , default =
        { endpoint = ""
        , port = None Natural
        , retries = None Natural
        , initialDelaySeconds = None Natural
        , intervalSeconds = None Natural
        , timeoutSeconds = None Natural
        }
      }

in  { Image, Container, EnvVar, HealthCheck }
