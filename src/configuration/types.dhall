let Image =
      { name : Text
      , tag : Text
      , registry : Optional Text
      , digest : Optional Text
      }

let Container = { image : Image }

let EnvVar = { name : Text, value : Optional Text }

in  { Image, Container, EnvVar }
