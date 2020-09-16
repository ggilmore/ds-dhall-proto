let Map/values =
      https://prelude.dhall-lang.org/v18.0.0/Map/values sha256:ae02cfb06a9307cbecc06130e84fd0c7b96b7f1f11648961e1b030ec00940be8

let Kubernetes/EnvVar =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.EnvVar.dhall sha256:94ea00566409bc470cd81ca29903066714557826c723dad8c25a282897c7acb3

let environment = ./environment.dhall

let toList
    : ∀(e : environment.Type) → List Kubernetes/EnvVar.Type
    = λ(e : environment.Type) → Map/values Text Kubernetes/EnvVar.Type (toMap e)

in  toList
