module Page.Overview exposing (Model, Msg(..), Plan, Result, Week, fetchPlans, formatDistance, formatDistanceForPlan, formatKm, init, planLinkView, planSelection, update, view, weekSelection)

import Browser exposing (Document)
import Config exposing (globalConfig)
import Element exposing (Length, alignLeft, centerX, centerY, column, el, fill, height, padding, pointer, rgb255, spaceEvenly, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Font as Font
import Element.Region exposing (heading)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import List.Extra
import Pallette
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
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched plans ->
            ( { model | plans = plans }, Cmd.none )


view model =
    { title = "S33 Treningsplan"
    , body =
        wrappedRow
            [ width fill, height fill, centerX, centerY ]
        <|
            [ case model.plans of
                RemoteData.Success plans ->
                    plansView plans

                RemoteData.Loading ->
                    text "Loading plans..."

                RemoteData.Failure _ ->
                    text "Something went wrong :("

                RemoteData.NotAsked ->
                    text "Loading plans..."
            ]
    }


plansView : List Plan -> Element.Element Msg
plansView plans =
    Element.wrappedRow
        [ width fill
        , spacing 60
        , Font.family
            [ Font.typeface "Helvetica"
            , Font.sansSerif
            ]
        , Font.light
        , padding 20
        ]
    <|
        List.concat
            [ [ el
                    [ heading 1
                    , Font.size 64
                    , Font.extraLight
                    ]
                <|
                    text "Plans"
              ]
            , List.map planLinkView plans
            ]


planLinkView : Plan -> Element.Element Msg
planLinkView plan =
    Element.link
        [ width fill
        , Background.color <| Pallette.blue
        , pointer
        ]
        { url = "/plans/" ++ plan.id
        , label =
            column [ width fill, spaceEvenly, alignLeft, padding 30, spacing 10 ]
                [ el [ heading 2, Font.size 24 ] <| text <| plan.name
                , text <| "Duration: " ++ (plan.weeks |> List.length |> String.fromInt) ++ " weeks"
                , text <| "Distance: " ++ formatDistanceForPlan plan.weeks
                ]
        }


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
