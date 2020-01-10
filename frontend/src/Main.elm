module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Element exposing (fill, height, px, width)
import Element.Background
import Element.Region
import Fonts
import Html exposing (Html)
import Navigation exposing (Page(..))
import Page.Overview as Overview
import Page.Plan as PlanPage
import Page.Profile as ProfilePage
import Page.Workout as WorkoutPage
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { overview : Overview.Model
    , plan : PlanPage.Model
    , workout : WorkoutPage.Model
    , profile : ProfilePage.Model
    , navigation : Navigation.Model
    }


fetchDataForPage : Navigation.Page -> Cmd Msg
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
            Navigation.urlToPage url

        userId =
            "recfBcTSvqs8CyrCk"
    in
    ( { overview = Overview.init
      , plan = PlanPage.init
      , workout = WorkoutPage.init
      , profile = ProfilePage.init
      , navigation = Navigation.init key page
      }
    , Cmd.batch
        [ Cmd.map ProfileMsg <| ProfilePage.fetch userId
        , fetchDataForPage page
        ]
    )



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
            ( { model | navigation = { page = page, key = model.navigation.key } }, fetchDataForPage page )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navigation.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )



---- VIEW ----


createLayout : Model -> Element.Element Msg -> List (Html Msg)
createLayout model page =
    [ Element.layout [ Fonts.body, Element.Background.image "%PUBLIC_URL%/asoggetti-GYr9A2CPMhY-unsplash.svg" ] <|
        Element.column [ width fill, height fill ] <|
            [ Element.map ProfileMsg <| Navigation.view model.navigation model.profile.profile
            , page
            , Element.el [ Element.Region.footer, height <| px 200 ] Element.none
            ]
    ]


view : Model -> Document Msg
view model =
    case model.navigation.page of
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
            , body = createLayout model <| Element.map ProfileMsg body
            }



---- PROGRAM ----


onUrlChange : Url -> Msg
onUrlChange url =
    UrlChanged <| Navigation.urlToPage url


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
