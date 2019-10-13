module Page.Overview exposing (Model, Msg(..), Plan, Result, Week, fetchPlans, formatDistance, formatDistanceForPlan, formatKm, init, planLinkView, planSelection, update, view, weekSelection)

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


type Msg
    = Fetched Result


type alias Model =
    { plans : Result
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
    }


type alias Result =
    RemoteData (Graphql.Http.Error (List Plan)) (List Plan)


init =
    { plans = RemoteData.NotAsked }


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


fetchPlans : Cmd Msg
fetchPlans =
    Treningsplan.Query.plans planSelection
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no"
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched plans ->
            ( { model | plans = plans }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "S33 Treningsplan"
    , body =
        [ Element.layout [] <|
            column
                [ width <| px 300, centerX, centerY, spacing 20 ]
            <|
                case model.plans of
                    RemoteData.Success data ->
                        List.map planLinkView data

                    RemoteData.Loading ->
                        [ text "Loading plans..." ]

                    RemoteData.Failure e ->
                        [ text "Something went wrong :(" ]

                    RemoteData.NotAsked ->
                        [ text "Loading plans..." ]
        ]
    }


planLinkView : Plan -> Element.Element Msg
planLinkView plan =
    Element.column []
        [ el [ heading 1 ] <| text "Plan"
        , Element.link []
            { url = "/plans/" ++ plan.id
            , label =
                text <|
                    plan.name
                        ++ " - "
                        ++ (plan.weeks |> List.length |> String.fromInt)
                        ++ " weeks"
                        ++ formatDistanceForPlan plan.weeks
            }
        ]


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
