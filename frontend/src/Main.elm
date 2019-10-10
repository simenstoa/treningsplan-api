module Main exposing (main)

import Browser
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, padding, px, rgb255, row, spacing, text, width)
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)
import RemoteData exposing (RemoteData)
import Treningsplan.Object.Plan
import Treningsplan.Query



---- MODEL ----


type alias Plan =
    { id : String
    , name : String
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


planSelection =
    SelectionSet.map2 Plan
        Treningsplan.Object.Plan.name
        Treningsplan.Object.Plan.id


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no/"
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
                    [ text "Should ask" ]


treningsplanView : Response -> List (Element.Element msg)
treningsplanView response =
    List.map planView response


planView : Plan -> Element.Element msg
planView plan =
    Element.column []
        [ text <| plan.name
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
