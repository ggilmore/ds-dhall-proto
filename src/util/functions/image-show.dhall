let Optional/default = https://prelude.dhall-lang.org/v18.0.0/Optional/default

let Optional/map = https://prelude.dhall-lang.org/v18.0.0/Optional/map

let Image = (../schemas.dhall).Image

let Image/show =
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
        assert
      : Image/show testImage ≡ "index.docker.io/sourcegraph/frontend:insiders"

let test1 =
        assert
      :   Image/show (testImage with registry = None Text)
        ≡ "sourcegraph/frontend:insiders"

let test2 =
        assert
      :   Image/show
            (testImage with registry = None Text with digest = Some "123tsf")
        ≡ "sourcegraph/frontend:insiders@sha256:123tsf"

let test3 =
        assert
      :   Image/show (testImage with digest = Some "123tsf")
        ≡ "index.docker.io/sourcegraph/frontend:insiders@sha256:123tsf"

let test4 =
        assert
      :   Image/show
            ( testImage
              with registry = Some "index.sourcegraph.net"
              with digest = Some "123tsf"
            )
        ≡ "index.sourcegraph.net/sourcegraph/frontend:insiders@sha256:123tsf"

in  { Image/show }
