module Page.Profile exposing (Model, Msg(..), Profile, Result, fetch, init, profileSelection, profileView, update, view)

import Config exposing (globalConfig)
import Element exposing (Length, alignRight, centerX, centerY, fill, fillPortion, height, minimum, padding, px, spacing, text, width)
import Element.Background
import Element.Border
import Element.Font
import Element.Region exposing (heading)
import Fonts
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Headers
import Metrics.Duration as Duration exposing (Duration(..))
import Metrics.VDOT as VDOT
import Pallette
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Profile
import Treningsplan.Object.Record
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
    , records : List Record
    }


type alias Record =
    { id : String
    , race : String
    , duration : Duration
    }


type alias Result =
    RemoteData (Graphql.Http.Error (Maybe Profile)) (Maybe Profile)


init =
    { profile = RemoteData.NotAsked }


profileSelection : SelectionSet Profile Treningsplan.Object.Profile
profileSelection =
    SelectionSet.map5 Profile
        Treningsplan.Object.Profile.id
        Treningsplan.Object.Profile.firstname
        Treningsplan.Object.Profile.surname
        Treningsplan.Object.Profile.vdot
        (Treningsplan.Object.Profile.records recordSelection)


recordSelection : SelectionSet Record Treningsplan.Object.Record
recordSelection =
    SelectionSet.map3 Record
        Treningsplan.Object.Record.id
        Treningsplan.Object.Record.race
        (SelectionSet.map Seconds Treningsplan.Object.Record.duration)


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
    let
        maybeVdot =
            VDOT.getVdot profile.vdot
    in
    Element.column [ height fill, width fill, padding 40, spacing 40 ]
        [ Element.row
            [ width fill, height <| fillPortion 1, spacing 40 ]
            [ Element.el
                [ width <| (fillPortion 2 |> minimum 265)
                , height fill
                , Element.Background.color <| Pallette.light_moss_green
                ]
              <|
                Element.el [ centerY, heading 1, Fonts.heading, Element.Font.size 30, padding 20 ] <|
                    text <|
                        profile.firstname
                            ++ " "
                            ++ profile.surname
            , Element.el [ height <| fillPortion 1, width <| fillPortion 3, Element.inFront <| vdotView profile ] <|
                Element.none
            ]
        , Element.wrappedRow
            [ width fill, height <| fillPortion 19, spacing 40 ]
            [ Element.column
                [ height (fill |> minimum 400)
                , width <| (fillPortion 2 |> minimum 300)
                , Element.Background.color <| Pallette.light_slate_grey_with_opacity
                ]
              <|
                [ Headers.smallHeader <|
                    "Personal records"
                , Element.column [ padding 20, spacing 20 ] <|
                    Element.row [ Element.Font.bold, spacing 30, width (fill |> minimum 130) ]
                        [ Element.el [ width fill ] <| Element.text "Race"
                        , Element.text "Duration"
                        ]
                        :: List.map
                            (\record ->
                                Element.row [ spacing 30, width (fill |> minimum 100) ]
                                    [ Element.el [ width (fill |> minimum 130) ] <| Element.text record.race
                                    , Element.text <| Duration.format record.duration
                                    ]
                            )
                            (List.sortBy
                                (\r ->
                                    case r.duration of
                                        Seconds sec ->
                                            sec
                                )
                                profile.records
                            )
                ]
            , Element.column [ height (fill |> minimum 400), width <| (fillPortion 3 |> minimum 300) ]
                [ Element.column
                    [ heading 2
                    , height fill
                    , width fill
                    , Element.Background.color <| Pallette.light_slate_grey_with_opacity
                    ]
                  <|
                    [ Headers.smallHeader <|
                        "Workout pace"
                    , case maybeVdot of
                        Just vdot ->
                            Element.column [ padding 20, spacing 20 ] <|
                                Element.row [ Element.Font.bold, spacing 30, width (fill |> minimum 130) ]
                                    [ Element.el [ width fill ] <| Element.text "Intensity"
                                    , Element.text "Pace (min/km)"
                                    ]
                                    :: List.map
                                        (\workoutPace ->
                                            Element.row [ spacing 30, width (fill |> minimum 100) ]
                                                [ Element.el [ width (fill |> minimum 130) ] <| Element.text <| VDOT.intensityToString workoutPace.intensity
                                                , Element.text <| VDOT.workoutPaceToString workoutPace.pace
                                                ]
                                        )
                                        vdot.workoutPace

                        Nothing ->
                            Element.text "VDOT data must be added before you can view workout paces."
                    ]
                ]
            ]
        ]


vdotView : Profile -> Element.Element Msg
vdotView profile =
    Element.el
        [ height <| px 95
        , width <| px 95
        , alignRight
        , Element.moveUp 10
        , Element.moveRight 5
        , Element.Background.color <| Pallette.light_moss_green
        , Element.Border.rounded 150
        , Element.Border.solid
        , Element.Border.width 3
        , Element.Border.color Pallette.sunray
        ]
    <|
        Element.el [ centerX, centerY ] <|
            text <|
                "vdot: "
                    ++ String.fromInt profile.vdot
