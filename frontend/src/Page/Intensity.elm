module Page.Intensity exposing (Intensity, Model, Msg, fetch, init, intensitySelection, update, view)

import Color
import Config exposing (globalConfig)
import Element exposing (Length, alignTop, centerX, fill, fillPortion, height, maximum, padding, spacing, text, width)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Headers
import Html exposing (Html)
import Maybe exposing (Maybe)
import RemoteData exposing (RemoteData)
import Svg.Attributes
import Treningsplan.Object
import Treningsplan.Object.Intensity
import Treningsplan.Query
import TypedSvg exposing (svg)
import TypedSvg.Attributes
import TypedSvg.Attributes.InPx
import TypedSvg.Core exposing (Svg)
import TypedSvg.Events
import TypedSvg.Types


type Msg
    = Fetched Result
    | Clicked Intensity
    | MouseEnter Intensity
    | MouseLeave


type alias Model =
    { intensities : Result
    , intensity : Maybe Intensity
    , hoverIntensity : Maybe Intensity
    }


type alias Intensity =
    { id : String
    , name : String
    , description : Maybe String
    , coefficient : Float
    }


type alias Result =
    RemoteData (Graphql.Http.Error (List Intensity)) (List Intensity)


init =
    { intensities = RemoteData.NotAsked
    , intensity = Nothing
    , hoverIntensity = Nothing
    }


intensitySelection : SelectionSet Intensity Treningsplan.Object.Intensity
intensitySelection =
    SelectionSet.map4 Intensity
        Treningsplan.Object.Intensity.id
        Treningsplan.Object.Intensity.name
        Treningsplan.Object.Intensity.description
        Treningsplan.Object.Intensity.coefficient


fetch : Cmd Msg
fetch =
    Treningsplan.Query.intensityZones intensitySelection
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched intensities ->
            ( { model | intensities = intensities }, Cmd.none )

        Clicked intensity ->
            ( { model | intensity = Just intensity }, Cmd.none )

        MouseEnter intensity ->
            ( { model | hoverIntensity = Just intensity }, Cmd.none )

        MouseLeave ->
            ( { model | hoverIntensity = Nothing }, Cmd.none )


view model =
    { title =
        case model.intensities of
            RemoteData.Success _ ->
                "Intensities"

            RemoteData.Loading ->
                "Loading intensities..."

            RemoteData.Failure e ->
                "Something went wrong :("

            RemoteData.NotAsked ->
                "Loading intensities..."
    , body =
        case model.intensities of
            RemoteData.Success intensities ->
                intensitiesView intensities model.intensity model.hoverIntensity

            RemoteData.Loading ->
                text "Loading intensities..."

            RemoteData.Failure e ->
                text "Something went wrong :("

            RemoteData.NotAsked ->
                text "Loading intensities..."
    }


intensitiesView : List Intensity -> Maybe Intensity -> Maybe Intensity -> Element.Element Msg
intensitiesView intensities maybeIntensity hoverIntensity =
    Element.column [ height fill, width fill, padding 40 ]
        [ Headers.mainHeader "Intensity"
        , Element.wrappedRow [ padding 20, width fill, spacing 20, centerX ]
            [ Element.el [ alignTop, centerX, width <| (fillPortion 1 |> maximum 300) ] <| Element.html <| intensitiesSvg intensities maybeIntensity hoverIntensity
            , Element.column [ height fill, width <| fillPortion 2, spacing 30 ]
                [ case maybeIntensity of
                    Just intensity ->
                        Element.column [ spacing 20, width (fill |> maximum 400) ]
                            [ Headers.paragraphHeader intensity.name
                            , Element.paragraph [] [ Element.text <| Maybe.withDefault "No description is available for this intensity." intensity.description ]
                            ]

                    Nothing ->
                        Element.column [ spacing 20, width (fill |> maximum 400) ]
                            [ Headers.paragraphHeader "Intensity"
                            , Element.paragraph [] [ Element.text <| "Choose an intensity to learn more." ]
                            ]
                , Element.column [ spacing 20, width (fill |> maximum 400) ]
                    [ Headers.paragraphHeader "Training intensities"
                    , Element.paragraph [] [ Element.text "Training intensities are based on the intensities presented in Daniels' Running Formula by the renowned running coach Jack Daniels. Each intensity has a corresponding coefficient to help you track, not only your overall milage, but also your overall stress." ]
                    , Element.paragraph [] [ Element.text "Click one of the intensities for more information." ]
                    ]
                ]
            ]
        ]


intensitiesSvg : List Intensity -> Maybe Intensity -> Maybe Intensity -> Html Msg
intensitiesSvg intensities maybeIntensity hoverIntensity =
    let
        chartWidth =
            20

        viewBoxWidth =
            150

        viewBoxHeight =
            350
    in
    svg
        [ TypedSvg.Attributes.InPx.width <| viewBoxWidth
        , TypedSvg.Attributes.InPx.height <| viewBoxHeight
        , TypedSvg.Attributes.viewBox 0 0 viewBoxWidth viewBoxHeight
        ]
    <|
        List.concat
            [ graph chartWidth viewBoxHeight
            , List.concatMap (intensityLabel chartWidth viewBoxHeight maybeIntensity hoverIntensity) intensities
            ]


graph : Float -> Float -> List (TypedSvg.Core.Svg msg)
graph chartWidth chartHeight =
    [ TypedSvg.defs []
        [ TypedSvg.linearGradient
            [ Svg.Attributes.id "base"
            , TypedSvg.Attributes.InPx.x1 0
            , TypedSvg.Attributes.InPx.x2 0
            , TypedSvg.Attributes.InPx.y1 0
            , TypedSvg.Attributes.InPx.y2 1
            ]
            [ TypedSvg.stop [ TypedSvg.Attributes.offset "0%", TypedSvg.Attributes.stopColor "purple" ] []
            , TypedSvg.stop [ TypedSvg.Attributes.offset "33%", TypedSvg.Attributes.stopColor "red" ] []
            , TypedSvg.stop [ TypedSvg.Attributes.offset "66%", TypedSvg.Attributes.stopColor "yellow" ] []
            , TypedSvg.stop [ TypedSvg.Attributes.offset "100%", TypedSvg.Attributes.stopColor "green" ] []
            ]
        ]
    , TypedSvg.rect
        [ TypedSvg.Attributes.InPx.width chartWidth
        , TypedSvg.Attributes.InPx.height chartHeight
        , Svg.Attributes.fill "url(#base)"
        ]
        []
    ]


intensityLabel : Float -> Float -> Maybe Intensity -> Maybe Intensity -> Intensity -> List (TypedSvg.Core.Svg Msg)
intensityLabel chartWidth chartHeight maybeIntensity hoverIntensity intensity =
    let
        y =
            chartHeight - ((intensity.coefficient / 1.6) * chartHeight)

        textHeight =
            18

        chosen =
            isIntensity maybeIntensity intensity

        hovered =
            isIntensity hoverIntensity intensity

        bold =
            hovered || chosen
    in
    [ TypedSvg.rect
        [ TypedSvg.Attributes.stroke <| Color.black
        , TypedSvg.Attributes.InPx.width chartWidth
        , TypedSvg.Attributes.InPx.height 2
        , TypedSvg.Attributes.InPx.y y
        ]
        []
    , TypedSvg.text_
        [ TypedSvg.Attributes.stroke <| Color.black
        , TypedSvg.Attributes.InPx.height textHeight
        , TypedSvg.Attributes.InPx.x <| chartWidth + 10
        , TypedSvg.Attributes.InPx.y (y + (textHeight / 2))
        , TypedSvg.Events.onClick <| Clicked intensity
        , if bold then
            TypedSvg.Attributes.fontWeight TypedSvg.Types.FontWeightBold

          else
            TypedSvg.Attributes.fontWeight TypedSvg.Types.FontWeightNormal
        , if hovered then
            TypedSvg.Attributes.cursor TypedSvg.Types.CursorPointer

          else
            TypedSvg.Attributes.cursor TypedSvg.Types.CursorDefault
        , TypedSvg.Events.onMouseOver <| MouseEnter intensity
        , TypedSvg.Events.onMouseOut <| MouseLeave
        ]
        [ TypedSvg.Core.text intensity.name ]
    ]


isIntensity : Maybe Intensity -> Intensity -> Bool
isIntensity current intensity =
    case current of
        Just insty ->
            if insty == intensity then
                True

            else
                False

        Nothing ->
            False
