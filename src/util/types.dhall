let Image =
      { name : Text
      , tag : Text
      , registry : Optional Text
      , digest : Optional Text
      }

let Container = { image : Image }

let EnvVar = { name : Text, value : Optional Text }

let HealthCheck =
      { endpoint : Text
      , port : Optional Natural
      , retries : Optional Natural
      , initialDelaySeconds : Optional Natural
      , timeoutSeconds : Optional Natural
      , intervalSeconds : Optional Natural
      }

in  { Image, Container, EnvVar, HealthCheck }
