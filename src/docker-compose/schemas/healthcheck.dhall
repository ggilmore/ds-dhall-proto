let HealthCheck =
      { Type =
          { interval : Optional Text
          , retries : Optional Natural
          , start_period : Optional Text
          , test : Text
          , timeout : Optional Text
          }
      , default =
        { interval = None Text
        , retries = None Natural
        , start_period = None Text
        , test = Text
        , timeout = None Text
        }
      }

in  HealthCheck
