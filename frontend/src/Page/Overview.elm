module Page.Overview exposing (Model, Msg(..), Plan, Result, Week, fetchPlans, formatDistance, formatDistanceForPlan, formatKm, init, planLinkView, planSelection, update, view, weekSelection)

import Browser exposing (Document)
import Element exposing (Length, alignLeft, centerX, centerY, column, el, fill, fillPortion, padding, px, row, spaceEvenly, spacing, text, width)
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
                [ width <| px 1000, centerX, centerY ]
            <|
                case model.plans of
                    RemoteData.Success plans ->
                        List.map planLinkView plans

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
    Element.column [ width fill ]
        [ el [ heading 1 ] <| text "Plans"
        , row [ width fill, alignLeft ]
            [ el [ width <| fillPortion 4 ] <| text "Plan"
            , el [ width <| fillPortion 1 ] <| text "Duration"
            , el [ width <| fillPortion 1 ] <| text "Distance"
            ]
        , Element.link [ width fill ]
            { url = "/plans/" ++ plan.id
            , label =
                row [ width fill, spaceEvenly, alignLeft, padding 10 ]
                    [ el [ width <| fillPortion 4, alignLeft ] <| text plan.name
                    , el [ width <| fillPortion 1, alignLeft ] <| text (plan.weeks |> List.length |> String.fromInt)
                    , el [ width <| fillPortion 1, alignLeft ] <| text (formatDistanceForPlan plan.weeks)
                    ]
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
    formatKm minWeek.distance
        ++ "-"
        ++ formatKm maxWeek.distance
        ++ " km"


formatKm : Int -> String
formatKm km =
    toFloat km / 1000 |> String.fromFloat
