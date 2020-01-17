module Authentication exposing (Model, Msg(..), init, update)

import Browser.Navigation as Navigation exposing (Key)
import Maybe exposing (Maybe)
import Url exposing (Protocol(..), Url)


type Msg
    = SignInRequested
    | SignOutRequested


type alias Model =
    { redirectUri : Url
    , error : Maybe String
    , token : Maybe String
    }


init : Url -> Model
init origin =
    let
        model : Model
        model =
            { error = Nothing
            , redirectUri = origin
            , token = Nothing
            }
    in
    { model | token = tokenParser origin }


tokenParser : Url -> Maybe String
tokenParser url =
    case url.fragment of
        Just str ->
            case String.split "=" str of
                [ _, token ] ->
                    Just token

                _ ->
                    Nothing

        Nothing ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignInRequested ->
            ( model
            , "https://treningsplan.eu.auth0.com/authorize?client_id=uUux3mJmyrEWLGcWoduN16KCaG6CwC4M&redirect_uri=https%3A%2F%2Ftreningsplan.s33.no&response_type=id_token&scope=openid%20profile&nonce=shouldchange" |> Navigation.load
            )

        SignOutRequested ->
            ( model
            , Navigation.load (Url.toString model.redirectUri)
            )
