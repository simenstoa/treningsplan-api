module Metrics.VDOT exposing (getVdot, intensityToString, workoutPaceToString)

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


type Distance
    = Meter Int


type alias Race =
    { name : String, distance : Distance }


table : List VDOT
table =
    [ { value = 57
      , racePrediction = [ { race = { name = "10k", distance = Meter 10000 }, pace = SecPerKm 222 } ]
      , workoutPace =
            [ { intensity = Easy, pace = Between (SecPerKm 276) (SecPerKm 305) }
            , { intensity = Marathon, pace = Constant (SecPerKm 243) }
            , { intensity = Threshold, pace = Constant (SecPerKm 230) }
            , { intensity = Interval, pace = Constant (SecPerKm 211) }
            , { intensity = Repitition, pace = Constant (SecPerKm 196) }
            ]
      }
    ]


getVdot : Int -> Maybe VDOT
getVdot vdot =
    List.Extra.find (\v -> v.value == vdot) table
