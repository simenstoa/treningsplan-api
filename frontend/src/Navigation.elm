module Navigation exposing (Model, Page(..), init, urlParser, urlToPage, view)

import Authentication
import Browser.Navigation as Nav
import Element exposing (alignRight, mouseOver, text)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Pallette
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)


type Page
    = Index
    | PlanPage String
    | WorkoutPage String
    | WorkoutsPage
    | ProfilePage
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


view : Model -> Maybe String -> Element.Element Authentication.Msg
view model token =
    Element.row [ Element.Region.navigation, alignRight ]
        [ link model.page Plans { url = "/", label = Element.text "Plans" }
        , link model.page Workouts { url = "/workouts", label = Element.text "Workouts" }
        , link model.page Intensity { url = "/intensity", label = Element.text "Intensity" }
        , profileTab model token
        ]


profileTab : Model -> Maybe String -> Element.Element Authentication.Msg
profileTab model token =
    case token of
        Just _ ->
            --check expiry?
            loggedInView model

        Nothing ->
            loginButton


loginButton : Element.Element Authentication.Msg
loginButton =
    Element.Input.button
        [ Element.Background.color Pallette.sunray
        , Element.padding 20
        ]
        { onPress = Just <| Authentication.SignInRequested
        , label = text "Login"
        }


loggedInView : Model -> Element.Element msg
loggedInView model =
    link model.page Profile { url = "/profile", label = Element.text "Profile" }


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

        ProfilePage ->
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
        , Url.map ProfilePage (Url.s "profile")
        , Url.map IntensityPage (Url.s "intensity")
        ]
