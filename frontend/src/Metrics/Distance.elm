module Metrics.Distance exposing (Distance(..), format)


type Distance
    = Meter Int


format : Distance -> String
format duration =
    case duration of
        Meter meter ->
            let
                inMeter =
                    meter < 1000
            in
            if inMeter then
                String.fromInt meter ++ " m"

            else
                let
                    km =
                        toFloat meter / 1000
                in
                String.fromFloat km ++ " km"
