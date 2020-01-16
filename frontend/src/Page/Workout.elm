module Page.Workout exposing
    ( Model
    , Msg(..)
    , Result
    , fetch
    , init
    , update
    , view
    )

import Config exposing (globalConfig)
import Element exposing (Length, alignRight, alignTop, centerX, centerY, fill, height, maximum, minimum, padding, px, spaceEvenly, spacing, text, width)
import Element.Background
import Element.Font
import Graphics.LineChart as LineChart
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Headers
import List.Extra
import Metrics.Distance as Distance exposing (Distance(..))
import Metrics.Duration as Duration exposing (Duration(..))
import Metrics.VDOT as VDOT exposing (PaceDescription, VDOT)
import Page.Intensity exposing (Intensity, intensitySelection)
import Page.Profile as ProfilePage exposing (Profile)
import Pallette
import RemoteData exposing (RemoteData)
import Round
import Treningsplan.Enum.MetricV2
import Treningsplan.Object
import Treningsplan.Object.WorkoutPart
import Treningsplan.Object.WorkoutV2
import Treningsplan.Query
import Tuple exposing (second)
import TypedSvg.Core exposing (Svg)


type Msg
    = Fetched Result


type alias Model =
    { workout : Result
    }


type Metric
    = Meter
    | Second


type alias Workout =
    { id : String
    , name : String
    , description : Maybe String
    , parts : List WorkoutPart
    }


type alias WorkoutPart =
    { order : Int
    , distance : Int
    , metric : Metric
    , intensity : Intensity
    }


type alias Result =
    RemoteData (Graphql.Http.Error (Maybe Workout)) (Maybe Workout)


init =
    { workout = RemoteData.NotAsked }


workoutSelection : SelectionSet Workout Treningsplan.Object.WorkoutV2
workoutSelection =
    SelectionSet.map4 Workout
        Treningsplan.Object.WorkoutV2.id
        Treningsplan.Object.WorkoutV2.name
        Treningsplan.Object.WorkoutV2.description
        (Treningsplan.Object.WorkoutV2.parts workoutPartSelection)


workoutPartSelection : SelectionSet WorkoutPart Treningsplan.Object.WorkoutPart
workoutPartSelection =
    SelectionSet.map4 WorkoutPart
        Treningsplan.Object.WorkoutPart.order
        Treningsplan.Object.WorkoutPart.distance
        (Treningsplan.Object.WorkoutPart.metric
            |> SelectionSet.map
                (\m ->
                    case m of
                        Treningsplan.Enum.MetricV2.Meter ->
                            Meter

                        Treningsplan.Enum.MetricV2.Second ->
                            Second
                )
        )
        (Treningsplan.Object.WorkoutPart.intensity intensitySelection)


fetch : String -> Cmd Msg
fetch id =
    Treningsplan.Query.workoutV2 (Treningsplan.Query.WorkoutV2RequiredArguments id) workoutSelection
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched workout ->
            ( { model | workout = workout }, Cmd.none )


view profile model =
    { title =
        case model.workout of
            RemoteData.Success data ->
                case data of
                    Just workout ->
                        workout.name

                    Nothing ->
                        "Could not find workout"

            RemoteData.Loading ->
                "Loading workout..."

            RemoteData.Failure e ->
                "Something went wrong :("

            RemoteData.NotAsked ->
                "Loading workout..."
    , body =
        case model.workout of
            RemoteData.Success workout ->
                case workout of
                    Just w ->
                        workoutView profile w

                    Nothing ->
                        text "The workout does not exist."

            RemoteData.Loading ->
                text "Loading workout..."

            RemoteData.Failure _ ->
                text "Something went wrong :("

            RemoteData.NotAsked ->
                text "Loading workout..."
    }


workoutView : ProfilePage.Result -> Workout -> Element.Element Msg
workoutView profile workout =
    Element.column
        [ height fill, width fill, padding 20 ]
        [ Headers.mainHeader workout.name
        , Element.el [ padding 10, width fill, spacing 20 ] <|
            case profile of
                RemoteData.Success data ->
                    case data of
                        Just p ->
                            workoutDetailsView p workout

                        Nothing ->
                            Element.paragraph [ centerX, centerY ] [ text "Profile is needed to see workout details." ]

                RemoteData.Loading ->
                    Element.paragraph [ centerX, centerY ] [ text "Loading profile..." ]

                RemoteData.Failure _ ->
                    Element.paragraph [ centerX, centerY ] [ text "Error while fetching profile. A Profile is needed to see workout details." ]

                RemoteData.NotAsked ->
                    Element.paragraph [ centerX, centerY ] [ text "Loading profile..." ]
        ]


workoutDetailsView : Profile -> Workout -> Element.Element Msg
workoutDetailsView profile workout =
    let
        vdot =
            Maybe.withDefault VDOT.defaultVdot <| VDOT.getVdot profile.vdot

        totalDistance =
            getTotalDistanceInMeter vdot workout.parts
    in
    Element.column [ width fill, spacing 20, Element.Background.color Pallette.light_slate_grey_with_opacity, padding 20 ]
        [ Headers.paragraphHeader <| "Workout details"
        , Element.wrappedRow [ width fill, spacing 40 ]
            [ Element.column [ height fill, alignTop, spacing 20 ]
                [ Element.paragraph []
                    [ text <| "For " ++ profile.firstname ++ " " ++ profile.lastname ++ " with vdot " ++ String.fromInt profile.vdot ]
                , workoutDescription workout vdot totalDistance
                ]
            , Element.el [ alignTop, width (fill |> minimum 200 |> maximum 800) ] <| Element.html <| graph totalDistance 2.5 <| second <| List.foldl (getPoints vdot) ( 0, [] ) workout.parts
            ]
        , workoutPartsDescription vdot workout.parts
        ]


workoutDescription : Workout -> VDOT -> Float -> Element.Element msg
workoutDescription workout vdot totalDistance =
    let
        totalDuration =
            getTotalDistanceInSeconds vdot workout.parts

        totalStress =
            getTotalIntensity vdot workout.parts
    in
    Element.column [ height fill, alignTop, width <| px 275, Element.Background.color <| Pallette.light_slate_grey, padding 10, spacing 10 ]
        [ Headers.smallParagraphHeader "Overview"
        , Element.wrappedRow [ width fill, spacing 15 ]
            [ Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Distance", Element.column [] [ text <| formatKm totalDistance ] ]
            , Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Duration", Element.paragraph [] [ text <| Duration.format <| Seconds totalDuration ] ]
            , Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Stress", Element.column [] [ text <| formatStress totalStress ] ]
            ]
        , Element.column [ alignTop, spacing 5, width fill ] [ Element.el [ Element.Font.size 10 ] <| text <| "Description", Element.paragraph [] [ text <| Maybe.withDefault "" workout.description ] ]
        , Element.column [ alignTop, spacing 5, width fill ] [ Element.el [ Element.Font.size 10 ] <| text <| "Intensities", getIntensitiesOverview vdot workout.parts ]
        ]


graph : Float -> Float -> List ( Float, Float ) -> Svg msg
graph xMax yMax points =
    LineChart.view 0 xMax 0 yMax points


workoutPartsDescription : VDOT -> List WorkoutPart -> Element.Element msg
workoutPartsDescription vdot parts =
    Element.column [ spacing 10 ]
        [ Headers.smallParagraphHeader "Parts"
        , Element.wrappedRow [ spacing 10 ] <| List.map (workoutPart vdot) parts
        ]


workoutPart : VDOT -> WorkoutPart -> Element.Element msg
workoutPart vdot part =
    Element.column [ height fill, alignTop, width <| px 275, Element.Background.color <| Pallette.light_slate_grey, padding 10, spacing 10 ]
        [ Element.paragraph []
            [ text <| (String.fromInt <| part.order + 1) ++ ".", text <| " " ++ part.intensity.name ]
        , Element.row
            [ spacing 20 ]
            [ Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Distance", Element.paragraph [ padding 0, width (fill |> minimum 60) ] [ text <| formatKm <| getDistanceForPartInMeter vdot part ] ]
            , Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Pace", Element.paragraph [] [ text <| VDOT.workoutPaceToString <| Maybe.withDefault VDOT.defaultPace <| getPaceDescription vdot part ] ]
            , Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Duration", Element.paragraph [] [ text <| Duration.format <| Seconds <| getDistanceForPartInSeconds vdot part ] ]
            , Element.column [ alignTop, spacing 5 ] [ Element.el [ Element.Font.size 10 ] <| text <| "Stress", Element.paragraph [] [ text <| formatStress <| getStressForPart vdot part ] ]
            ]
        ]


getIntensitiesOverview : VDOT -> List WorkoutPart -> Element.Element msg
getIntensitiesOverview vdot workoutParts =
    Element.column [ width fill, spacing 10 ] <|
        (workoutParts
            |> List.Extra.uniqueBy (\part -> part.intensity.id)
            |> List.sortBy (\part -> part.intensity.coefficient)
            |> List.map (\part -> ( part.intensity.name, Maybe.withDefault VDOT.defaultPace (getPaceDescription vdot part) ))
            |> List.map (\( name, pace ) -> Element.row [ width fill, spaceEvenly ] [ Element.text name, Element.el [ alignRight ] <| Element.text <| VDOT.workoutPaceToString pace ++ " min/km" ])
        )


getTotalDistanceInMeter : VDOT -> List WorkoutPart -> Float
getTotalDistanceInMeter vdot workoutParts =
    List.map (getDistanceForPartInMeter vdot) workoutParts
        |> List.sum


getTotalDistanceInSeconds : VDOT -> List WorkoutPart -> Int
getTotalDistanceInSeconds vdot workoutParts =
    List.map (getDistanceForPartInSeconds vdot) workoutParts
        |> List.sum


getTotalIntensity : VDOT -> List WorkoutPart -> Float
getTotalIntensity vdot workoutParts =
    List.map (getStressForPart vdot) workoutParts
        |> List.sum


getStressForPart : VDOT -> WorkoutPart -> Float
getStressForPart vdot part =
    let
        pace =
            Maybe.withDefault VDOT.defaultPace <| getPaceDescription vdot part

        distance =
            case part.metric of
                Meter ->
                    VDOT.metersToDistance part.distance

                Second ->
                    VDOT.secondsToDistance part.distance

        duration =
            VDOT.meterFromDistanceForPace pace distance
    in
    duration * part.intensity.coefficient


getDistanceForPartInMeter : VDOT -> WorkoutPart -> Float
getDistanceForPartInMeter vdot part =
    let
        pace =
            Maybe.withDefault VDOT.defaultPace <| getPaceDescription vdot part

        distance =
            case part.metric of
                Meter ->
                    VDOT.metersToDistance part.distance

                Second ->
                    VDOT.secondsToDistance part.distance
    in
    VDOT.meterFromDistanceForPace pace distance


getDistanceForPartInSeconds : VDOT -> WorkoutPart -> Int
getDistanceForPartInSeconds vdot part =
    let
        pace =
            Maybe.withDefault VDOT.defaultPace <| getPaceDescription vdot part

        distance =
            case part.metric of
                Meter ->
                    VDOT.metersToDistance part.distance

                Second ->
                    VDOT.secondsToDistance part.distance
    in
    VDOT.secondsFromDistanceForPace pace distance


getPaceDescription : VDOT -> WorkoutPart -> Maybe PaceDescription
getPaceDescription vdot part =
    let
        intensity =
            VDOT.toIntensity part.intensity.name

        workoutPace =
            List.Extra.find (\pd -> pd.intensity == intensity) vdot.workoutPace
    in
    case workoutPace of
        Just pace ->
            Just pace.pace

        Nothing ->
            Nothing


getPoints vdot part ( offset, parts ) =
    let
        nextOffset =
            offset + getDistanceForPartInMeter vdot part

        height =
            part.intensity.coefficient

        start =
            ( offset, height )

        end =
            ( nextOffset, height )

        nextParts =
            List.concat [ parts, [ start, end ] ]
    in
    ( nextOffset, nextParts )


formatKm : Float -> String
formatKm km =
    Round.round 1 km ++ " km"


formatStress : Float -> String
formatStress intensity =
    Round.round 2 intensity
