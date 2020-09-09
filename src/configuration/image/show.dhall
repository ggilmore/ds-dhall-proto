let Optional/default = https://prelude.dhall-lang.org/v18.0.0/Optional/default

let Optional/map = https://prelude.dhall-lang.org/v18.0.0/Optional/map

let Image = ./schema.dhall

let show =
      λ(i : Image.Type) →
        let digest =
              Optional/default
                Text
                ""
                (Optional/map Text Text (λ(d : Text) → "@sha256:${d}") i.digest)

        let registry =
              Optional/default
                Text
                ""
                (Optional/map Text Text (λ(r : Text) → "${r}/") i.registry)

        in  "${registry}${i.name}:${i.tag}${digest}"

let testImage = Image::{ name = "sourcegraph/frontend", tag = "insiders" }

let test =
      assert : show testImage ≡ "index.docker.io/sourcegraph/frontend:insiders"

let test1 =
        assert
      :   show (testImage with registry = None Text)
        ≡ "sourcegraph/frontend:insiders"

let test2 =
        assert
      :   show (testImage with registry = None Text with digest = Some "123tsf")
        ≡ "sourcegraph/frontend:insiders@sha256:123tsf"

let test3 =
        assert
      :   show (testImage with digest = Some "123tsf")
        ≡ "index.docker.io/sourcegraph/frontend:insiders@sha256:123tsf"

in  show
