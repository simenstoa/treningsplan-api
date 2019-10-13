module Page.Plan exposing (Model, Msg(..), Plan, Result, Week, fetch, init, planSelection, update, view, weekSelection)

import Browser exposing (Document)
import Element exposing (centerX, centerY, column, el, padding, px, rgb, rgba, spacing, text, width)
import Element.Background exposing (color)
import Element.Region exposing (heading)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Day
import Treningsplan.Object.Plan
import Treningsplan.Object.Week
import Treningsplan.Object.Workout
import Treningsplan.Query


type alias Model =
    { plan : Result
    }


type Msg
    = Fetched Result


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


init =
    { plan = RemoteData.NotAsked }


fetch : String -> Cmd Msg
fetch id =
    Treningsplan.Query.plan (Treningsplan.Query.PlanRequiredArguments id) planSelection
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no"
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
        [ Element.layout [] <|
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
            Element.column [ spacing 10 ]
                [ el [ heading 1 ] <| text p.name
                , Element.wrappedRow [ spacing 10 ] <| List.map weekView <| List.sortBy (\w -> w.order) p.weeks
                ]

        Nothing ->
            text "Could not find the plan :("


weekView : Week -> Element.Element Msg
weekView week =
    Element.column
        [ spacing 10, padding 20, color <| rgb 0 201 0 ]
        [ text <| "Week " ++ (String.fromInt <| week.order + 1)
        , Element.column [ spacing 10 ] <|
            List.map dayView <|
                List.sortBy (\w -> w.day) week.days
        ]


dayView : Day -> Element.Element Msg
dayView day =
    Element.column [] <| List.map workoutView <| day.workouts


workoutView : Workout -> Element.Element Msg
workoutView workout =
    el [ padding 10, color <| rgb 155 201 0 ] <| text <| workout.name ++ " (" ++ formatKm workout.distance ++ " km) "


formatKm : Int -> String
formatKm km =
    toFloat km / 1000 |> String.fromFloat
