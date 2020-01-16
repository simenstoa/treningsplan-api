module Graphics.LineChart exposing (area, h, line, padding, tranfromToAreaData, transformToLineData, view, w, xAxis, xScale, yAxis, yScale)

import Axis
import Color
import Path exposing (Path)
import Scale exposing (ContinuousScale)
import Shape
import TypedSvg exposing (g, svg)
import TypedSvg.Attributes exposing (class, fill, stroke, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (strokeWidth)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Fill(..), Transform(..))


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    30


xScale : Float -> Float -> ContinuousScale Float
xScale min max =
    Scale.linear ( w - 2 * padding, 0 ) ( max, min )


yScale : Float -> Float -> ContinuousScale Float
yScale min max =
    Scale.linear ( h - 2 * padding, 0 ) ( min, max )


xAxis : Float -> Float -> List ( Float, Float ) -> Svg msg
xAxis min max model =
    Axis.bottom [ Axis.tickCount (List.length model) ] <| xScale min max


yAxis : Float -> Float -> Svg msg
yAxis min max =
    Axis.left [ Axis.tickCount 5 ] <| yScale min max


transformToLineData : Float -> Float -> Float -> Float -> ( Float, Float ) -> Maybe ( Float, Float )
transformToLineData xMin xMax yMin yMax ( x, y ) =
    Just ( Scale.convert (xScale xMin xMax) x, Scale.convert (yScale yMin yMax) y )


tranfromToAreaData : Float -> Float -> Float -> Float -> ( Float, Float ) -> Maybe ( ( Float, Float ), ( Float, Float ) )
tranfromToAreaData xMin xMax yMin yMax ( x, y ) =
    Just
        ( ( Scale.convert (xScale xMin xMax) x, Tuple.first (Scale.rangeExtent (yScale yMin yMax)) )
        , ( Scale.convert (xScale xMin xMax) x, Scale.convert (yScale yMin yMax) y )
        )


line : Float -> Float -> Float -> Float -> List ( Float, Float ) -> Path
line xMin xMax yMin yMax model =
    List.map (transformToLineData xMin xMax yMin yMax) model
        |> Shape.line Shape.monotoneInXCurve


area : Float -> Float -> Float -> Float -> List ( Float, Float ) -> Path
area xMin xMax yMin yMax model =
    List.map (tranfromToAreaData xMin xMax yMin yMax) model
        |> Shape.area Shape.monotoneInXCurve


view : Float -> Float -> Float -> Float -> List ( Float, Float ) -> Svg msg
view xMin xMax yMin yMax model =
    svg [ viewBox 0 0 w h ]
        [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis xMin xMax model ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis yMin yMax ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ]
            [ Path.element (area xMin xMax yMin yMax model) [ strokeWidth 3, fill <| Fill <| Color.rgba 1 0 0 0.54 ]
            , Path.element (line xMin xMax yMin yMax model) [ stroke (Color.rgb 1 0 0), strokeWidth 3, fill FillNone ]
            ]
        ]
