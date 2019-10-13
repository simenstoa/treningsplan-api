module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Element, centerX, centerY, column, el, link, px, spacing, text, width)
import Element.Region exposing (heading)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import List.Extra
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Plan
import Treningsplan.Object.Week
import Treningsplan.Query
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)



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


type Page
    = Index
    | PlanPage String


type alias Router =
    { key : Nav.Key
    , page : Page
    }


type alias Model =
    { plans : PlansResult
    , plan : PlanResult
    , router : Router
    }


type alias Response =
    List Plan


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
        |> Graphql.Http.send (RemoteData.fromResult >> PlansFetched)


fetchPlan : String -> Cmd Msg
fetchPlan id =
    Treningsplan.Query.plan (Treningsplan.Query.PlanRequiredArguments id) planSelection
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no"
        |> Graphql.Http.send (RemoteData.fromResult >> PlanFetched)


fetchDataForPage : Page -> Cmd Msg
fetchDataForPage page =
    case page of
        Index ->
            fetchPlans

        PlanPage id ->
            fetchPlan id


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            urlToPage url
    in
    ( { plans = RemoteData.NotAsked
      , plan = RemoteData.NotAsked
      , router = { key = key, page = page }
      }
    , fetchDataForPage page
    )


urlToPage : Url -> Page
urlToPage url =
    url
        |> Url.parse urlParser
        |> Maybe.withDefault Index


urlParser : Parser (Page -> a) a
urlParser =
    Url.oneOf
        [ Url.map Index Url.top
        , Url.map PlanPage (Url.s "plans" </> Url.string)
        ]



---- UPDATE ----


type alias PlansResult =
    RemoteData (Graphql.Http.Error (List Plan)) (List Plan)


type alias PlanResult =
    RemoteData (Graphql.Http.Error (Maybe Plan)) (Maybe Plan)


type Msg
    = PlansFetched PlansResult
    | PlanFetched PlanResult
    | UrlChanged Page
    | ClickedLink Browser.UrlRequest
    | Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlansFetched plansResult ->
            ( { model | plans = plansResult }, Cmd.none )

        PlanFetched planResult ->
            ( { model | plan = planResult }, Cmd.none )

        UrlChanged page ->
            ( { model | router = { page = page, key = model.router.key } }, fetchDataForPage page )

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.router.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        Noop ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Document Msg
view model =
    { title = "S33 Treningsplan"
    , body =
        [ case model.router.page of
            Index ->
                plansView model

            PlanPage _ ->
                Element.layout [] <|
                    column
                        [ width <| px 300, centerX, centerY, spacing 20 ]
                    <|
                        case model.plan of
                            RemoteData.Success data ->
                                [ planView data ]

                            RemoteData.Loading ->
                                [ text "Loading plan..." ]

                            RemoteData.Failure e ->
                                [ text "Something went wrong :(" ]

                            RemoteData.NotAsked ->
                                [ text "Loading plan..." ]
        ]
    }


plansView : Model -> Html Msg
plansView model =
    Element.layout [] <|
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



---- PROGRAM ----


onUrlChange : Url -> Msg
onUrlChange url =
    UrlChanged <| urlToPage url


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = ClickedLink
        , onUrlChange = onUrlChange
        }
