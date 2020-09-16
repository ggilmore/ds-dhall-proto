let Frontend/configuration = ../components/frontend/configuration/user.dhall

let Image/manipulate/options =
      (../../util/package.dhall).Image/manipulate/options

let configuration =
      { Type =
          { Global :
              { ImageManipulations : Image/manipulate/options.Type
              , nonRoot : Bool
              , namespace : Optional Text
              }
          , Frontend : Frontend/configuration.Type
          }
      , default =
        { Global =
          { ImageManipulations = Image/manipulate/options.default
          , nonRoot = False
          , namespace = None Text
          }
        , Frontend = Frontend/configuration.default
        }
      }

in  configuration
