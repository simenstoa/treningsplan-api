module Workout.Parser exposing (parse, parseResultToString)

import Parser exposing ((|.), (|=), DeadEnd, Parser, deadEndsToString, int, keyword, oneOf, run, spaces, succeed, symbol)


parseResultToString : Result (List DeadEnd) Intensity -> String
parseResultToString res =
    case res of
        Ok i ->
            String.fromInt i.intervals
                ++ " intervals of "
                ++ String.fromInt i.amount
                ++ (case i.metric of
                        Meters ->
                            " meters"

                        Minutes ->
                            " minutes"
                   )
                ++ " at "
                ++ (case i.intensityType of
                        Threshold ->
                            "threshold"

                        Interval ->
                            "interval"

                        Easy ->
                            "easy"
                   )
                ++ " intensity"

        Err deadEnds ->
            deadEndsToString deadEnds


parse : String -> Result (List DeadEnd) Intensity
parse str =
    run intensity str


type alias Intensity =
    { intervals : Int
    , amount : Int
    , metric : Metric
    , intensityType : IntensityType
    }


type Metric
    = Minutes
    | Meters


type IntensityType
    = Threshold
    | Interval
    | Easy


intensity : Parser Intensity
intensity =
    succeed Intensity
        |= int
        |. symbol "*"
        |= int
        |. spaces
        |= oneOf
            [ succeed Minutes
                |. keyword "min"
            , succeed Meters
                |. keyword "m"
            ]
        |. spaces
        |. symbol "@"
        |= oneOf
            [ succeed Threshold
                |. keyword "LT"
            , succeed Interval
                |. keyword "I"
            , succeed Easy
                |. keyword "E"
            ]
