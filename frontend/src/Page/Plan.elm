module Page.Plan exposing (Model, Msg(..), Plan, Result, Week, fetch, init, planSelection, update, view, weekSelection)

import Browser exposing (Document)
import Element exposing (centerX, centerY, column, el, px, spacing, text, width)
import Element.Region exposing (heading)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import List.Extra
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Plan
import Treningsplan.Object.Week
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
    SelectionSet.map3 Week
        Treningsplan.Object.Week.id
        Treningsplan.Object.Week.order
        Treningsplan.Object.Week.distance


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
                [ width <| px 300, centerX, centerY, spacing 20 ]
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
            Element.column []
                [ el [ heading 1 ] <| text p.name
                , text <|
                    (p.weeks |> List.length |> String.fromInt)
                        ++ " weeks"
                        ++ formatDistanceForPlan p.weeks
                ]

        Nothing ->
            text "Could not find the plan :("


formatDistanceForPlan : List Week -> String
formatDistanceForPlan weeks =
    let
        minWeek =
            List.Extra.minimumWith (\a b -> compare a.distance b.distance) weeks

        maxWeek =
            List.Extra.maximumWith (\a b -> compare a.distance b.distance) weeks
    in
    Maybe.map2 formatDistance minWeek maxWeek
        |> Maybe.withDefault ""


formatDistance : Week -> Week -> String
formatDistance minWeek maxWeek =
    " ("
        ++ formatKm minWeek.distance
        ++ "-"
        ++ formatKm maxWeek.distance
        ++ " km)"


formatKm : Int -> String
formatKm km =
    toFloat km / 1000 |> String.fromFloat
