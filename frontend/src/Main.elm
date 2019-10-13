module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (Html)
import Page.Overview as Overview
import Page.Plan as PlanPage
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)



---- MODEL ----


type Page
    = Index
    | PlanPage String


type alias Router =
    { key : Nav.Key
    , page : Page
    }


type alias Model =
    { overview : Overview.Model
    , plan : PlanPage.Model
    , router : Router
    }


fetchDataForPage : Page -> Cmd Msg
fetchDataForPage page =
    case page of
        Index ->
            Cmd.map OverviewMsg <| Overview.fetchPlans

        PlanPage id ->
            Cmd.map PlanMsg <| PlanPage.fetch id


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            urlToPage url
    in
    ( { overview = Overview.init
      , plan = PlanPage.init
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


type Msg
    = OverviewMsg Overview.Msg
    | PlanMsg PlanPage.Msg
    | UrlChanged Page
    | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OverviewMsg overviewMsg ->
            let
                ( overviewModel, overviewCmd ) =
                    Overview.update overviewMsg model.overview
            in
            ( { model | overview = overviewModel }, Cmd.map OverviewMsg overviewCmd )

        PlanMsg planMsg ->
            let
                ( planModel, planCmd ) =
                    PlanPage.update planMsg model.plan
            in
            ( { model | plan = planModel }, Cmd.map PlanMsg planCmd )

        UrlChanged page ->
            ( { model | router = { page = page, key = model.router.key } }, fetchDataForPage page )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.router.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )



---- VIEW ----


view : Model -> Document Msg
view model =
    case model.router.page of
        Index ->
            let
                { title, body } =
                    Overview.view model.overview
            in
            { title = title
            , body = List.map (Html.map OverviewMsg) body
            }

        PlanPage _ ->
            let
                { title, body } =
                    PlanPage.view model.plan
            in
            { title = title
            , body = List.map (Html.map PlanMsg) body
            }



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
        , onUrlRequest = LinkClicked
        , onUrlChange = onUrlChange
        }
