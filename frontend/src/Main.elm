module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Element exposing (alignLeft, alignRight, fill, px)
import Html exposing (Html)
import Page.Overview as Overview
import Page.Plan as PlanPage
import Page.Profile as ProfilePage
import Page.Workout as WorkoutPage
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)



---- MODEL ----


type Page
    = Index
    | PlanPage String
    | WorkoutPage String
    | ProfilePage String


type alias Router =
    { key : Nav.Key
    , page : Page
    }


type alias Model =
    { overview : Overview.Model
    , plan : PlanPage.Model
    , workout : WorkoutPage.Model
    , profile : ProfilePage.Model
    , router : Router
    }


fetchDataForPage : Page -> Cmd Msg
fetchDataForPage page =
    case page of
        Index ->
            Cmd.map OverviewMsg <| Overview.fetchPlans

        PlanPage id ->
            Cmd.map PlanMsg <| PlanPage.fetch id

        WorkoutPage id ->
            Cmd.map WorkoutMsg <| WorkoutPage.fetch id

        ProfilePage id ->
            Cmd.map ProfileMsg <| ProfilePage.fetch id


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            urlToPage url
    in
    ( { overview = Overview.init
      , plan = PlanPage.init
      , workout = WorkoutPage.init
      , profile = ProfilePage.init
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
        , Url.map WorkoutPage (Url.s "workouts" </> Url.string)
        , Url.map ProfilePage (Url.s "profiles" </> Url.string)
        ]



---- UPDATE ----


type Msg
    = OverviewMsg Overview.Msg
    | PlanMsg PlanPage.Msg
    | WorkoutMsg WorkoutPage.Msg
    | ProfileMsg ProfilePage.Msg
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

        WorkoutMsg workoutMsg ->
            let
                ( workoutModel, workoutCmd ) =
                    WorkoutPage.update workoutMsg model.workout
            in
            ( { model | workout = workoutModel }, Cmd.map WorkoutMsg workoutCmd )

        ProfileMsg profileMsg ->
            let
                ( profileModel, profileCmd ) =
                    ProfilePage.update profileMsg model.profile
            in
            ( { model | profile = profileModel }, Cmd.map ProfileMsg profileCmd )

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


createLayout : Model -> Element.Element Msg -> List (Html Msg)
createLayout model page =
    [ Element.layout [] <|
        Element.column [] <|
            [ Element.map ProfileMsg <|
                Element.el
                    [ alignRight ]
                <|
                    ProfilePage.headerView model.profile
            , page
            ]
    ]


view : Model -> Document Msg
view model =
    case model.router.page of
        Index ->
            let
                { title, body } =
                    Overview.view model.overview
            in
            { title = title
            , body = createLayout model <| Element.map OverviewMsg body
            }

        PlanPage _ ->
            let
                { title, body } =
                    PlanPage.view model.plan
            in
            { title = title
            , body = List.map (Html.map PlanMsg) body
            }

        WorkoutPage _ ->
            let
                { title, body } =
                    WorkoutPage.view model.workout
            in
            { title = title
            , body = List.map (Html.map WorkoutMsg) body
            }

        ProfilePage _ ->
            let
                { title, body } =
                    ProfilePage.view model.profile
            in
            { title = title
            , body = List.map (Html.map ProfileMsg) body
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
