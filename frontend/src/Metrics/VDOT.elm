module Metrics.VDOT exposing
    ( PaceDescription
    , VDOT
    , defaultPace
    , defaultVdot
    , getVdot
    , intensityToString
    , meterFromDistanceForPace
    , metersToDistance
    , secondsFromDistanceForPace
    , secondsToDistance
    , toIntensity
    , workoutPaceToString
    )

import List.Extra


type alias VDOT =
    { value : Int
    , racePrediction : List RacePrediction
    , workoutPace : List WorkoutPace
    }


type Pace
    = SecPerKm Int


type PaceDescription
    = Constant Pace
    | Between Pace Pace


minPerKm : Pace -> String
minPerKm pace =
    let
        minutes =
            case pace of
                SecPerKm secPerKm ->
                    floor (toFloat secPerKm / 60)

        seconds =
            case pace of
                SecPerKm secPerKm ->
                    modBy 60 secPerKm
    in
    String.fromInt minutes ++ ":" ++ (String.padLeft 2 '0' <| String.fromInt seconds)


workoutPaceToString : PaceDescription -> String
workoutPaceToString paceDescription =
    case paceDescription of
        Constant pace ->
            minPerKm pace

        Between minPace maxPace ->
            minPerKm minPace ++ "-" ++ minPerKm maxPace


type Intensity
    = Easy
    | Interval
    | Threshold
    | Marathon
    | Repitition


intensityToString : Intensity -> String
intensityToString intensity =
    case intensity of
        Easy ->
            "Easy"

        Interval ->
            "Interval"

        Threshold ->
            "Threshold"

        Marathon ->
            "Marathon"

        Repitition ->
            "Repitition"


type alias WorkoutPace =
    { intensity : Intensity, pace : PaceDescription }


type alias RacePrediction =
    { race : Race, pace : Pace }


type Length
    = Meter Int
    | Second Int


type alias Race =
    { name : String, length : Length }


defaultVdot : VDOT
defaultVdot =
    { value = 57
    , racePrediction = [ { race = { name = "10k", length = Meter 10000 }, pace = SecPerKm 222 } ]
    , workoutPace =
        [ { intensity = Easy, pace = Between (SecPerKm 276) (SecPerKm 305) }
        , { intensity = Marathon, pace = Constant (SecPerKm 243) }
        , { intensity = Threshold, pace = Constant (SecPerKm 230) }
        , { intensity = Interval, pace = Constant (SecPerKm 211) }
        , { intensity = Repitition, pace = Constant (SecPerKm 196) }
        ]
    }


defaultPace : PaceDescription
defaultPace =
    Constant (SecPerKm 243)


table : List VDOT
table =
    [ defaultVdot
    ]


metersToDistance : Int -> Length
metersToDistance meters =
    Meter meters


secondsToDistance : Int -> Length
secondsToDistance seconds =
    Second seconds


meterFromDistanceForPace : PaceDescription -> Length -> Float
meterFromDistanceForPace pace distance =
    case distance of
        Meter meter ->
            toFloat meter

        Second second ->
            let
                secPerKm =
                    case pace of
                        Constant (SecPerKm p) ->
                            toFloat p

                        Between (SecPerKm min) (SecPerKm max) ->
                            toFloat (min + max) / 2

                seconds =
                    toFloat second
            in
            seconds / secPerKm


secondsFromDistanceForPace : PaceDescription -> Length -> Int
secondsFromDistanceForPace pace distance =
    case distance of
        Meter meters ->
            let
                secPerKm =
                    case pace of
                        Constant (SecPerKm p) ->
                            toFloat p

                        Between (SecPerKm min) (SecPerKm max) ->
                            toFloat (min + max) / 2
            in
            ceiling (toFloat meters / 1000 * secPerKm)

        Second seconds ->
            seconds


getVdot : Int -> Maybe VDOT
getVdot vdot =
    List.Extra.find (\v -> v.value == vdot) table


toIntensity : String -> Intensity
toIntensity str =
    let
        lowercase =
            String.toLower str
    in
    case lowercase of
        "easy" ->
            Easy

        "marathon" ->
            Marathon

        "threshold" ->
            Threshold

        "interval" ->
            Interval

        "repitition" ->
            Repitition

        _ ->
            Easy
