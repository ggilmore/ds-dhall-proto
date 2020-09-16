let Optional/map =
      https://prelude.dhall-lang.org/v18.0.0/Optional/map sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let Kubernetes/Probe =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.Probe.dhall sha256:34226a06a4df5f6116d94b28b3bc48b307b330fce0f18220bac3b936a2f03f71

let Kubernetes/HTTPGetAction =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall sha256:2771706fa883952b5e2d5e1261997c7c718d2a3d546d346631d4c60ed2b03166

let Kubernetes/IntOrString =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall sha256:04a91539533a52bf0bf114690cceee43b656915bd83c2731ce26ad31f516d47f

let types = ../types.dhall

let HealthCheck = types.HealthCheck

let HealthCheck/Scheme = types.HealthCheck/Scheme

let DockerCompose/HealthCheck = ../../docker-compose/schemas/healthcheck.dhall

let scheme/showK8s
    : ∀(s : HealthCheck/Scheme) → Text
    = λ(s : HealthCheck/Scheme) → merge { HTTP = "HTTP" } s

let toK8s
    : ∀(hc : HealthCheck) → Kubernetes/Probe.Type
    = λ(hc : HealthCheck) →
        Kubernetes/Probe::{
        , httpGet = Some Kubernetes/HTTPGetAction::{
          , path = Some hc.endpoint
          , port = Kubernetes/IntOrString.Int hc.port
          , scheme = Some (scheme/showK8s hc.scheme)
          }
        , initialDelaySeconds = hc.initialDelaySeconds
        , periodSeconds = hc.intervalSeconds
        , timeoutSeconds = hc.timeoutSeconds
        , failureThreshold = hc.retries
        }

let scheme/showDockerCompose
    : ∀(s : HealthCheck/Scheme) → Text
    = λ(s : HealthCheck/Scheme) → merge { HTTP = "http" } s

let toDockerCompose
    : ∀(hc : HealthCheck) → DockerCompose/HealthCheck.Type
    = λ(hc : HealthCheck) →
        let toSeconds
            : Optional Natural → Optional Text
            = λ(seconds : Optional Natural) →
                Optional/map
                  Natural
                  Text
                  (λ(n : Natural) → "${Natural/show n}s")
                  seconds

        let url =
              "${scheme/showDockerCompose
                   hc.scheme}://127.0.0.1:${Natural/show hc.port}${hc.endpoint}"

        let test = "wget -q '${url}' -O /dev/null || exit 1"

        in  DockerCompose/HealthCheck::{
            , interval = toSeconds hc.intervalSeconds
            , retries = hc.retries
            , start_period = toSeconds hc.initialDelaySeconds
            , test
            , timeout = toSeconds hc.timeoutSeconds
            }

in  { HealthCheck/tok8s = toK8s, HealthCheck/toDockerCompose = toDockerCompose }
