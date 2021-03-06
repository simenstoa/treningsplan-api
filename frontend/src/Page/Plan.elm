module Page.Plan exposing (Model, Msg(..), Plan, Result, Week, fetch, init, planSelection, update, view, weekSelection)

import Browser exposing (Document)
import Config exposing (globalConfig)
import Element exposing (centerX, centerY, column, el, fill, height, padding, paddingXY, paragraph, px, rgb255, rgba255, spacing, text, width)
import Element.Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Element.Region exposing (heading)
import Graphics.LineChart
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Pallette
import RemoteData exposing (RemoteData)
import Svg exposing (Svg)
import Treningsplan.Object
import Treningsplan.Object.Day
import Treningsplan.Object.Plan
import Treningsplan.Object.Week
import Treningsplan.Object.Workout
import Treningsplan.Query


type Msg
    = Fetched Result


type alias Model =
    { plan : Result
    }


type alias WeekGraphPoint =
    { id : String
    , week : Float
    , distance : Float
    }


type alias Plan =
    { id : String
    , name : String
    , weeks : List Week
    }


type alias Week =
    { id : String
    , order : Int
    , distance : Int
    , days : List Day
    }


type alias Day =
    { id : String
    , day : Int
    , distance : Int
    , workouts : List Workout
    }


type alias Workout =
    { id : String
    , name : String
    , distance : Int
    }


type alias Result =
    RemoteData (Graphql.Http.Error (Maybe Plan)) (Maybe Plan)


init : Model
init =
    { plan = RemoteData.NotAsked }


fetch : String -> Cmd Msg
fetch id =
    Treningsplan.Query.plan (Treningsplan.Query.PlanRequiredArguments id) planSelection
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


planSelection : SelectionSet Plan Treningsplan.Object.Plan
planSelection =
    SelectionSet.map3 Plan
        Treningsplan.Object.Plan.id
        Treningsplan.Object.Plan.name
        (Treningsplan.Object.Plan.weeks weekSelection)


weekSelection : SelectionSet Week Treningsplan.Object.Week
weekSelection =
    SelectionSet.map4 Week
        Treningsplan.Object.Week.id
        Treningsplan.Object.Week.order
        Treningsplan.Object.Week.distance
        (Treningsplan.Object.Week.days daySelection)


daySelection : SelectionSet Day Treningsplan.Object.Day
daySelection =
    SelectionSet.map4 Day
        Treningsplan.Object.Day.id
        Treningsplan.Object.Day.day
        Treningsplan.Object.Day.distance
        (Treningsplan.Object.Day.workouts workoutSelection)


workoutSelection : SelectionSet Workout Treningsplan.Object.Workout
workoutSelection =
    SelectionSet.map3 Workout
        Treningsplan.Object.Workout.id
        Treningsplan.Object.Workout.name
        Treningsplan.Object.Workout.distance


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched plan ->
            ( { model | plan = plan }, Cmd.none )


view : Model -> Document Msg
view model =
    { title =
        case model.plan of
            RemoteData.Success data ->
                case data of
                    Just plan ->
                        plan.name

                    Nothing ->
                        "Could not find plan"

            RemoteData.Loading ->
                "Loading plan..."

            RemoteData.Failure e ->
                "Something went wrong :("

            RemoteData.NotAsked ->
                "Loading plan..."
    , body =
        [ Element.layout [ paddingXY 50 25, centerX ] <|
            column
                [ centerX, centerY, spacing 20 ]
            <|
                [ case model.plan of
                    RemoteData.Success data ->
                        planView data

                    RemoteData.Loading ->
                        text "Loading plan..."

                    RemoteData.Failure e ->
                        text "Something went wrong :("

                    RemoteData.NotAsked ->
                        text "Loading plan..."
                ]
        ]
    }


planView : Maybe Plan -> Element.Element Msg
planView plan =
    case plan of
        Just p ->
            Element.column [ spacing 10, Element.alignTop ]
                [ el [ heading 1, Font.size 25 ] <| text p.name
                , el [ width fill ] <| Element.html <| distanceGraph p.weeks
                , Element.column [ spacing 10 ] <| List.map weekView <| List.sortBy (\w -> w.order) p.weeks
                ]

        Nothing ->
            text "Could not find the plan :("


distanceGraph : List Week -> Svg Msg
distanceGraph weeks =
    let
        points =
            weeks
                |> List.sortBy (\w -> w.order)
                |> List.map (\week -> ( toFloat (week.order + 1), toFloat week.distance / 1000.0 ))
    in
    Graphics.LineChart.view 1 14 0 80 points


weekView : Week -> Element.Element Msg
weekView week =
    Element.column
        [ spacing 10
        , padding 20
        , Border.color <| Pallette.light_slate_grey
        , Border.solid
        , Border.width 5
        ]
        [ Element.row [ Element.width fill ]
            [ text <| "Week " ++ (String.fromInt <| week.order + 1)
            , el [ Element.alignRight ] <| text <| formatKm week.distance ++ "km"
            ]
        , Element.wrappedRow [ spacing 5 ] <|
            List.map dayView <|
                List.sortBy (\w -> w.day) week.days
        ]


dayView : Day -> Element.Element Msg
dayView day =
    Element.column [ Border.solid, Border.width 1, padding 5, Element.alignTop, Element.height fill ]
        [ Element.row [ width fill, Element.alignTop ]
            [ el [ Element.alignLeft, Font.size 12 ] <|
                (text <| "Day " ++ (day.day + 1 |> String.fromInt))
            , el [ Element.alignRight, Font.size 12 ] <|
                (text <| formatKm day.distance ++ " km")
            ]
        , Element.column [ height fill ] <| List.map workoutLinkView <| day.workouts
        ]


workoutLinkView : Workout -> Element.Element Msg
workoutLinkView workout =
    Element.link
        [ padding 5, color <| rgba255 47 172 255 0.5, width <| px 150, Element.height fill ]
        { url = "/workouts/" ++ workout.id
        , label =
            Element.column []
                [ el
                    [ padding 5, Font.size 14 ]
                  <|
                    paragraph [] <|
                        [ text
                            workout.name
                        ]
                , el [ Element.alignBottom, Element.alignRight, Font.size 12 ] <|
                    (text <| formatKm workout.distance ++ " km")
                ]
        }


formatKm : Int -> String
formatKm km =
    toFloat km / 1000 |> String.fromFloat
