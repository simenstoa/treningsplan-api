module Main exposing (main)

import Browser
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, padding, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout []
        myRowOfStuff


myRowOfStuff : Element Msg
myRowOfStuff =
    column [ width <| px 300, centerX, centerY, spacing 20 ]
        [ emailInput
        , passwordInput
        ]


emailInput : Element Msg
emailInput =
    Input.email
        [ Border.rounded 3
        , padding 10
        , Input.focusedOnLoad
        ]
        { label = Input.labelAbove [ alignLeft ] (text "Email")
        , onChange = \_ -> NoOp
        , text = ""
        , placeholder = Nothing
        }


passwordInput : Element Msg
passwordInput =
    Input.newPassword
        [ Border.rounded 3
        , padding 10
        , Input.focusedOnLoad
        ]
        { label = Input.labelAbove [ alignLeft ] (text "Passord")
        , onChange = \_ -> NoOp
        , placeholder = Nothing
        , text = ""
        , show = False
        }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
