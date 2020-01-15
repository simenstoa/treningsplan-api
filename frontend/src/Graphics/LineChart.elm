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


xScale : Float -> ContinuousScale Float
xScale max =
    Scale.linear ( w - 2 * padding, 0 ) ( max, 0 )


yScale : Float -> ContinuousScale Float
yScale max =
    Scale.linear ( h - 2 * padding, 0 ) ( 0, max )


xAxis : Float -> List ( Float, Float ) -> Svg msg
xAxis max model =
    Axis.bottom [ Axis.tickCount (List.length model) ] <| xScale max


yAxis : Float -> Svg msg
yAxis max =
    Axis.left [ Axis.tickCount 5 ] <| yScale max


transformToLineData : Float -> Float -> ( Float, Float ) -> Maybe ( Float, Float )
transformToLineData xMax yMax ( x, y ) =
    Just ( Scale.convert (xScale xMax) x, Scale.convert (yScale yMax) y )


tranfromToAreaData : Float -> Float -> ( Float, Float ) -> Maybe ( ( Float, Float ), ( Float, Float ) )
tranfromToAreaData xMax yMax ( x, y ) =
    Just
        ( ( Scale.convert (xScale xMax) x, Tuple.first (Scale.rangeExtent (yScale yMax)) )
        , ( Scale.convert (xScale xMax) x, Scale.convert (yScale yMax) y )
        )


line : Float -> Float -> List ( Float, Float ) -> Path
line xMax yMax model =
    List.map (transformToLineData xMax yMax) model
        |> Shape.line Shape.monotoneInXCurve


area : Float -> Float -> List ( Float, Float ) -> Path
area xMax yMax model =
    List.map (tranfromToAreaData xMax yMax) model
        |> Shape.area Shape.monotoneInXCurve


view : Float -> Float -> List ( Float, Float ) -> Svg msg
view xMax yMax model =
    svg [ viewBox 0 0 w h ]
        [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis xMax model ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis yMax ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ]
            [ Path.element (area xMax yMax model) [ strokeWidth 3, fill <| Fill <| Color.rgba 1 0 0 0.54 ]
            , Path.element (line xMax yMax model) [ stroke (Color.rgb 1 0 0), strokeWidth 3, fill FillNone ]
            ]
        ]
