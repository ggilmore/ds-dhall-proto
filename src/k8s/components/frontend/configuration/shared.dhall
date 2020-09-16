let util = ../../../../util/package.dhall

let Image = util.Image

let ContainerConfiguration = { Type = { image : Image.Type }, default = {=} }

let JaegerImage =
      Image::{
      , digest = Some
          "69b0a662e47534c78a91c2a1d19f495eef750ebaacf190f4e87b676858595cef"
      , registry = Some "index.docker.io"
      , name = "sourcegraph/jaeger-agent"
      , tag = "insiders"
      }

in  { ContainerConfiguration, JaegerImage }
