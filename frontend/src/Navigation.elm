module Navigation exposing (Model, Page(..), init, urlParser, urlToPage, view)

import Browser.Navigation as Nav
import Element exposing (alignRight, mouseOver, text)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Page.Profile as Profile exposing (Profile)
import Pallette
import RemoteData
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)


type Page
    = Index
    | PlanPage String
    | WorkoutPage String
    | WorkoutsPage
    | ProfilePage String
    | IntensityPage


type NavigationTab
    = Plans
    | Workouts
    | Intensity
    | Profile


type alias Model =
    { key : Nav.Key
    , page : Page
    }


init : Nav.Key -> Page -> Model
init key page =
    { key = key, page = page }


view : Model -> Profile.Result -> Element.Element Profile.Msg
view model profile =
    Element.row [ Element.Region.navigation, alignRight ]
        [ link model.page Plans { url = "/", label = Element.text "Plans" }
        , link model.page Workouts { url = "/workouts", label = Element.text "Workouts" }
        , link model.page Intensity { url = "/intensity", label = Element.text "Intensity" }
        , profileTab model profile
        ]


profileTab : Model -> Profile.Result -> Element.Element Profile.Msg
profileTab model result =
    case result of
        RemoteData.Success profile ->
            case profile of
                Just p ->
                    loggedInView model p

                Nothing ->
                    loginButton

        RemoteData.Loading ->
            text "Logging in..."

        RemoteData.Failure _ ->
            loginButton

        RemoteData.NotAsked ->
            loginButton


loginButton : Element.Element Profile.Msg
loginButton =
    Element.Input.button
        [ Element.Background.color Pallette.sunray
        , Element.padding 20
        ]
        { onPress = Just <| Profile.LogIn "recfBcTSvqs8CyrCk"
        , label = text "Login"
        }


loggedInView : Model -> Profile -> Element.Element Profile.Msg
loggedInView model profile =
    link model.page Profile { url = "/profiles/" ++ profile.id, label = Element.text profile.firstname }


link : Page -> NavigationTab -> { url : String, label : Element.Element msg } -> Element.Element msg
link currentPage tab =
    let
        highlight =
            isCurrentPage currentPage tab
    in
    Element.link
        [ Element.padding 20
        , Element.Background.color Pallette.sunray
        , mouseOver
            [ if highlight then
                Element.Font.color Pallette.sunray

              else
                Element.Font.color Pallette.brown_sugar
            ]
        , if highlight then
            Element.Background.color Pallette.brown_sugar

          else
            Element.Background.color Pallette.sunray
        ]


isCurrentPage : Page -> NavigationTab -> Bool
isCurrentPage current tab =
    let
        currentTab =
            pageToNavigationTab current
    in
    case currentTab of
        Just t ->
            t == tab

        Nothing ->
            False


pageToNavigationTab : Page -> Maybe NavigationTab
pageToNavigationTab page =
    case page of
        Index ->
            Just Plans

        PlanPage _ ->
            Just Plans

        ProfilePage _ ->
            Just Profile

        IntensityPage ->
            Just Intensity

        WorkoutsPage ->
            Just Workouts

        WorkoutPage _ ->
            Just Workouts


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
        , Url.map WorkoutsPage (Url.s "workouts")
        , Url.map ProfilePage (Url.s "profiles" </> Url.string)
        , Url.map IntensityPage (Url.s "intensity")
        ]
