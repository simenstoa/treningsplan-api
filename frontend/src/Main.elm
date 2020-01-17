module Main exposing (main)

import Authentication
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Element exposing (fill, height, px, width)
import Element.Background
import Element.Font
import Element.Region
import Fonts
import Html exposing (Html)
import Navigation exposing (Page(..))
import Page.Intensity as IntensityPage
import Page.Overview as Overview
import Page.Plan as PlanPage
import Page.Profile as ProfilePage
import Page.Workout as WorkoutPage
import Page.Workouts as WorkoutsPage
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { overview : Overview.Model
    , plan : PlanPage.Model
    , workouts : WorkoutsPage.Model
    , workout : WorkoutPage.Model
    , profile : ProfilePage.Model
    , intensity : IntensityPage.Model
    , auth : Authentication.Model
    , navigation : Navigation.Model
    }


fetchDataForPage : Navigation.Page -> Authentication.Model -> Cmd Msg
fetchDataForPage page auth =
    case page of
        Index ->
            Cmd.map OverviewMsg <| Overview.fetchPlans

        PlanPage id ->
            Cmd.map PlanMsg <| PlanPage.fetch id

        WorkoutPage id ->
            Cmd.map WorkoutMsg <| WorkoutPage.fetch id

        WorkoutsPage ->
            Cmd.map WorkoutsMsg <| WorkoutsPage.fetch

        ProfilePage ->
            Cmd.map ProfileMsg <| ProfilePage.fetch (Maybe.withDefault "" auth.token)

        IntensityPage ->
            Cmd.map IntensityMsg <| IntensityPage.fetch


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            Navigation.urlToPage url

        auth =
            Authentication.init url
    in
    ( { overview = Overview.init
      , plan = PlanPage.init
      , workout = WorkoutPage.init
      , workouts = WorkoutsPage.init
      , profile = ProfilePage.init
      , auth = auth
      , intensity = IntensityPage.init
      , navigation = Navigation.init key page
      }
    , Cmd.batch
        [ fetchDataForPage page auth
        ]
    )



---- UPDATE ----


type Msg
    = OverviewMsg Overview.Msg
    | PlanMsg PlanPage.Msg
    | WorkoutMsg WorkoutPage.Msg
    | WorkoutsMsg WorkoutsPage.Msg
    | ProfileMsg ProfilePage.Msg
    | IntensityMsg IntensityPage.Msg
    | AuthenticationMsg Authentication.Msg
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

        WorkoutsMsg workoutsMsg ->
            let
                ( workoutsModel, workoutsCmd ) =
                    WorkoutsPage.update workoutsMsg model.workouts
            in
            ( { model | workouts = workoutsModel }, Cmd.map WorkoutsMsg workoutsCmd )

        ProfileMsg profileMsg ->
            let
                ( profileModel, profileCmd ) =
                    ProfilePage.update profileMsg model.profile
            in
            ( { model | profile = profileModel }, Cmd.map ProfileMsg profileCmd )

        IntensityMsg intensityMsg ->
            let
                ( intensityModel, intensityCmd ) =
                    IntensityPage.update intensityMsg model.intensity
            in
            ( { model | intensity = intensityModel }, Cmd.map IntensityMsg intensityCmd )

        AuthenticationMsg authMsg ->
            let
                ( authModel, authCmd ) =
                    Authentication.update authMsg model.auth
            in
            ( { model | auth = authModel }, Cmd.map AuthenticationMsg authCmd )

        UrlChanged page ->
            ( { model | navigation = { page = page, key = model.navigation.key } }, fetchDataForPage page model.auth )

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
    [ Element.layout [ Element.Font.size 18, Fonts.body, Element.Background.image "%PUBLIC_URL%/asoggetti-GYr9A2CPMhY-unsplash.svg" ] <|
        Element.column [ width fill, height fill ] <|
            [ Element.map AuthenticationMsg <| Navigation.view model.navigation model.auth.token
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
            , body = createLayout model <| Element.map WorkoutMsg body
            }

        WorkoutsPage ->
            let
                { title, body } =
                    WorkoutsPage.view model.workouts
            in
            { title = title
            , body = createLayout model <| Element.map WorkoutsMsg body
            }

        ProfilePage ->
            let
                { title, body } =
                    ProfilePage.view model.profile
            in
            { title = title
            , body = createLayout model <| Element.map ProfileMsg body
            }

        IntensityPage ->
            let
                { title, body } =
                    IntensityPage.view model.intensity
            in
            { title = title
            , body = createLayout model <| Element.map IntensityMsg body
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
