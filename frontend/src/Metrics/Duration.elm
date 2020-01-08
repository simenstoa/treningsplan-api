module Metrics.Duration exposing (Duration(..), format)


type Duration
    = Seconds Int


format : Duration -> String
format duration =
    case duration of
        Seconds sec ->
            let
                hours =
                    floor (toFloat sec / 3600)

                minutes =
                    floor (toFloat (modBy 3600 sec) / 60)

                seconds =
                    modBy 60 sec
            in
            if hours == 0 && minutes == 0 then
                String.fromInt seconds ++ " sec"

            else
                (if hours > 0 then
                    String.fromInt hours ++ ":"

                 else
                    ""
                )
                    ++ String.padLeft 2 '0' (String.fromInt minutes)
                    ++ ":"
                    ++ String.padLeft 2 '0' (String.fromInt seconds)
