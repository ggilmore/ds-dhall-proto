let Optional/map = https://prelude.dhall-lang.org/v18.0.0/Optional/map

let Kubernetes/Probe =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/HTTPGetAction =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Kubernetes/IntOrString =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.18/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall

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
