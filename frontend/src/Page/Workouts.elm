module Page.Workouts exposing (Model, Msg, fetch, init, update, view)

import Config exposing (globalConfig)
import Element exposing (Length, alignLeft, centerX, centerY, column, fill, height, maximum, minimum, padding, pointer, spaceEvenly, spacing, text, width, wrappedRow)
import Element.Background as Background
import Graphql.Http exposing (Error, RawError(..))
import Graphql.Http.GraphqlError
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Headers
import Pallette
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.WorkoutV2
import Treningsplan.Query


type Msg
    = Fetched Result


type alias Model =
    { workouts : Result
    }


type alias Workout =
    { id : String
    , name : String
    , description : Maybe String
    }


type alias Result =
    RemoteData (Graphql.Http.Error (List Workout)) (List Workout)


init =
    { workouts = RemoteData.NotAsked }


workoutSelection : SelectionSet Workout Treningsplan.Object.WorkoutV2
workoutSelection =
    SelectionSet.map3 Workout
        Treningsplan.Object.WorkoutV2.id
        Treningsplan.Object.WorkoutV2.name
        Treningsplan.Object.WorkoutV2.description


fetch : Cmd Msg
fetch =
    Treningsplan.Query.workoutV2s workoutSelection
        |> Graphql.Http.queryRequest globalConfig.graphQLUrl
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched plans ->
            ( { model | workouts = plans }, Cmd.none )


view : Model -> { title : String, body : Element.Element Msg }
view model =
    { title = "Workouts"
    , body =
        wrappedRow
            [ width fill, height fill, centerX, centerY ]
        <|
            [ case model.workouts of
                RemoteData.Success workouts ->
                    workoutsView workouts

                RemoteData.Loading ->
                    Element.el [ centerX, centerY ] <| text "Loading workouts..."

                RemoteData.Failure err ->
                    Element.el [ centerX, centerY ] <| text <| "Something went wrong :( \n" ++ graphqlErrToString err

                RemoteData.NotAsked ->
                    Element.el [ centerX, centerY ] <| text "Loading workouts..."
            ]
    }


graphqlErrToString : Error (List Workout) -> String
graphqlErrToString err =
    case err of
        GraphqlError _ e ->
            String.join " - " <| List.map .message e

        _ ->
            "Unknown error"


workoutsView : List Workout -> Element.Element Msg
workoutsView workouts =
    Element.wrappedRow
        [ width fill
        ]
    <|
        [ Headers.mainHeader "Workouts"
        , Element.wrappedRow
            [ width fill
            , spacing 60
            , padding 20
            ]
          <|
            List.map
                workoutLinkView
                workouts
        ]


workoutLinkView : Workout -> Element.Element Msg
workoutLinkView workout =
    Element.link
        [ width (fill |> minimum 300 |> maximum 400)
        , Background.color <| Pallette.light_slate_grey_with_opacity
        , pointer
        ]
        { url = "/workouts/" ++ workout.id
        , label =
            column [ width fill, spaceEvenly, alignLeft, padding 30, spacing 10 ]
                [ Headers.paragraphHeader <| workout.name
                , Element.paragraph []
                    [ text <| Maybe.withDefault "No description added." workout.description
                    ]
                ]
        }
