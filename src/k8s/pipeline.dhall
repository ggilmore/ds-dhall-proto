-- dhall-to-yaml --explain --file src/k8s/pipeline.dhall

let Configuration/global = ./configuration/global.dhall

let generate = ./components/frontend/generate.dhall

let c =
      Configuration/global::{=}
      with Global.nonRoot = True
      with Global.namespace = Some "not-a-namespace"
      with Global.ImageManipulations.stripDigest = True
      with Global.ImageManipulations.tagSuffix = Some "-hello-world!"
      with Frontend.Deployment.Containers.Frontend.Environment.PGDATABASE.value
           = Some
          "i-am-a-little-tea-pot"

in  generate c
