module Page.Profile exposing (Model, Msg(..), Profile, Result, fetch, headerView, init, profileSelection, profileView, update, view)

import Browser exposing (Document)
import Config exposing (globalConfig)
import Element exposing (Length, alignBottom, alignRight, centerX, centerY, fill, fillPortion, height, minimum, padding, px, spacing, text, width)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Element.Region exposing (heading)
import Fonts
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Pallette
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Profile
import Treningsplan.Query


type Msg
    = Fetched Result
    | LogIn String


type alias Model =
    { profile : Result
    }


type alias Profile =
    { id : String
    , firstname : String
    , surname : String
    , vdot : Int
    }


type alias Result =
    RemoteData (Graphql.Http.Error (Maybe Profile)) (Maybe Profile)


init =
    { profile = RemoteData.NotAsked }


profileSelection : SelectionSet Profile Treningsplan.Object.Profile
profileSelection =
    SelectionSet.map4 Profile
        Treningsplan.Object.Profile.id
        Treningsplan.Object.Profile.firstname
        Treningsplan.Object.Profile.surname
        Treningsplan.Object.Profile.vdot


fetch : String -> Cmd Msg
fetch id =
    Treningsplan.Query.profile (Treningsplan.Query.ProfileRequiredArguments id) profileSelection
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched profile ->
            ( { model | profile = profile }, Cmd.none )

        LogIn id ->
            ( model, fetch id )


view model =
    { title =
        case model.profile of
            RemoteData.Success data ->
                case data of
                    Just profile ->
                        profile.firstname ++ " " ++ profile.surname

                    Nothing ->
                        "Could not find profile"

            RemoteData.Loading ->
                "Loading profile..."

            RemoteData.Failure e ->
                "Something went wrong :("

            RemoteData.NotAsked ->
                "Loading profile..."
    , body =
        case model.profile of
            RemoteData.Success profile ->
                case profile of
                    Just p ->
                        profileView p

                    Nothing ->
                        Element.el [ centerX, centerY ] <| text "The profile does not exist."

            RemoteData.Loading ->
                Element.el [ centerX, centerY ] <| text "Loading profile..."

            RemoteData.Failure e ->
                Element.el [ centerX, centerY ] <| text "Something went wrong :("

            RemoteData.NotAsked ->
                Element.el [ centerX, centerY ] <| text "Loading profile..."
    }


profileView : Profile -> Element.Element Msg
profileView profile =
    Element.column [ height fill, width fill, padding 40, spacing 40 ]
        [ Element.row
            [ width fill, height <| fillPortion 1, spacing 40 ]
            [ Element.el [ width <| fillPortion 2, height fill, Element.Background.color <| Pallette.light_moss_green ] <|
                Element.el [ centerY, centerX, heading 1, Fonts.heading, Element.Font.size 30, padding 20 ] <|
                    text <|
                        profile.firstname
                            ++ " "
                            ++ profile.surname
            , Element.el [ width <| fillPortion 3 ] <|
                Element.none
            ]
        , Element.wrappedRow
            [ width fill, height <| fillPortion 19, spacing 40 ]
            [ Element.el [ height (fill |> minimum 400), width <| (fillPortion 2 |> minimum 300), Element.Background.color <| Pallette.light_slate_grey ] <|
                smallHeader <|
                    "Personal records"
            , Element.column [ height (fill |> minimum 400), width <| (fillPortion 3 |> minimum 300) ]
                [ Element.el
                    [ heading 2
                    , height fill
                    , width fill
                    , Element.Background.color <| Pallette.light_slate_grey
                    , Element.inFront <| vdotView profile
                    ]
                  <|
                    smallHeader <|
                        "Workout pace"
                ]
            ]
        ]


smallHeader : String -> Element.Element Msg
smallHeader header =
    Element.el [ heading 2, padding 20, Element.Font.size 30, Fonts.heading ] <|
        text <|
            header


vdotView : Profile -> Element.Element Msg
vdotView profile =
    Element.el
        [ height <| px 100
        , width <| px 100
        , alignRight
        , Element.moveUp 25
        , Element.moveRight 25
        , Element.Background.color <| Pallette.light_moss_green
        , Element.Border.rounded 150
        ]
    <|
        Element.el [ centerX, centerY ] <|
            text <|
                "vdot: "
                    ++ String.fromInt profile.vdot


headerView : Model -> Element.Element Msg
headerView model =
    case model.profile of
        RemoteData.Success profile ->
            case profile of
                Just p ->
                    loggedInView p

                Nothing ->
                    loginButton

        RemoteData.Loading ->
            text "Logging in..."

        RemoteData.Failure _ ->
            loginButton

        RemoteData.NotAsked ->
            loginButton


loginButton : Element.Element Msg
loginButton =
    Element.Input.button
        [ Element.Background.color Pallette.light_slate_grey
        , Element.padding 5
        ]
        { onPress = Just <| LogIn "recfBcTSvqs8CyrCk"
        , label = text "Login"
        }


loggedInView : Profile -> Element.Element Msg
loggedInView profile =
    Element.el
        [ Element.padding 5
        , Element.Font.color Pallette.light_slate_grey
        ]
    <|
        text profile.firstname
