module Main exposing (main)

import Browser
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, padding, px, rgb255, row, spacing, text, width)
import Element.Region exposing (heading)
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)
import List.Extra
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Plan
import Treningsplan.Object.Week
import Treningsplan.Query



---- MODEL ----


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


type alias Model =
    { plans : List Plan
    , result : PlansResult
    }


type alias Response =
    List Plan


query : SelectionSet Response RootQuery
query =
    Treningsplan.Query.plans planSelection


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


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no"
        |> Graphql.Http.send (RemoteData.fromResult >> PlansFetched)


initialModel : Model
initialModel =
    { plans =
        []
    , result = RemoteData.NotAsked
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , makeRequest
    )



---- UPDATE ----


type alias PlansResult =
    RemoteData (Graphql.Http.Error Response) Response


type Msg
    = PlansFetched PlansResult


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlansFetched plansResult ->
            ( { model | result = plansResult }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column
            [ width <| px 300, centerX, centerY, spacing 20 ]
        <|
            case model.result of
                RemoteData.Success data ->
                    treningsplanView data

                RemoteData.Loading ->
                    [ text "Loading plans..." ]

                RemoteData.Failure e ->
                    [ text "Something went wrong :(" ]

                RemoteData.NotAsked ->
                    [ text "Loading plans..." ]


treningsplanView : Response -> List (Element.Element msg)
treningsplanView response =
    List.map planView response


planView : Plan -> Element.Element msg
planView plan =
    Element.column []
        [ el [ heading 1 ] <| text "Plans"
        , text <|
            plan.name
                ++ " - "
                ++ (plan.weeks |> List.length |> String.fromInt)
                ++ " weeks"
                ++ formatDistanceForPlan plan.weeks
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



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
