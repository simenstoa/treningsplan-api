module Main exposing (main)

import Browser
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, padding, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)



---- MODEL ----


type alias Model =
    { email : String
    , password : String
    , loggedIn : Bool
    }


initialModel : Model
initialModel =
    { email = ""
    , password = ""
    , loggedIn = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = UpdateEmail String
    | UpdatePassword String
    | LogIn


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.mutationRequest
            "https://localhost:4000"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateEmail newVal ->
            ( { model | email = newVal }, Cmd.none )

        UpdatePassword newVal ->
            ( { model | password = newVal }, Cmd.none )

        LogIn ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column
            [ width <| px 300, centerX, centerY, spacing 20 ]
            [ emailInput model.email
            , passwordInput model.password
            , loginButton
            ]


emailInput : String -> Element Msg
emailInput value =
    Input.email
        [ Border.rounded 3
        , padding 10
        , Input.focusedOnLoad
        ]
        { label = Input.labelAbove [ alignLeft ] (text "Email")
        , onChange = \newText -> UpdateEmail newText
        , text = value
        , placeholder = Nothing
        }


passwordInput : String -> Element Msg
passwordInput value =
    Input.newPassword
        [ Border.rounded 3
        , padding 10
        , Input.focusedOnLoad
        ]
        { label = Input.labelAbove [ alignLeft ] (text "Passord")
        , onChange = \newText -> UpdatePassword newText
        , placeholder = Nothing
        , text = value
        , show = False
        }


loginButton : Element Msg
loginButton =
    Input.button
        [ Border.rounded 3
        , padding 10
        , Background.color <| rgb255 251 247 244
        , alignRight
        ]
        { label = text "Logg inn", onPress = Just LogIn }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
