module Page.Profile exposing (Model, Msg(..), Profile, Result, fetch, headerView, init, profileSelection, profileView, update, view)

import Browser exposing (Document)
import Config exposing (globalConfig)
import Element exposing (Length, centerX, centerY, fill, spacing, text, width, wrappedRow)
import Element.Background
import Element.Font
import Element.Input
import Element.Region as Element
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


view : Model -> Document Msg
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
        [ Element.layout [] <|
            wrappedRow
                [ centerX, centerY ]
            <|
                [ case model.profile of
                    RemoteData.Success profile ->
                        case profile of
                            Just p ->
                                profileView p

                            Nothing ->
                                text "The profile does not exist."

                    RemoteData.Loading ->
                        text "Loading profile..."

                    RemoteData.Failure e ->
                        text "Something went wrong :("

                    RemoteData.NotAsked ->
                        text "Loading profile..."
                ]
        ]
    }


profileView : Profile -> Element.Element Msg
profileView profile =
    Element.column
        [ spacing 20, width fill ]
        [ Element.el [ Element.heading 1, Element.Font.extraBold ] <| text <| profile.firstname
        , Element.el [ Element.Font.alignLeft ] <| text <| "vdot: " ++ String.fromInt profile.vdot
        ]


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
        [ Element.Background.color Pallette.blue
        , Element.padding 5
        ]
        { onPress = Just <| LogIn "recfBcTSvqs8CyrCk"
        , label = text "Login"
        }


loggedInView : Profile -> Element.Element Msg
loggedInView profile =
    Element.el
        [ Element.padding 5
        , Element.Font.color Pallette.blue
        ]
    <|
        text profile.firstname
