module Page.Workout exposing
    ( Model
    , Msg(..)
    , Result
    , fetch
    , formatKm
    , init
    , update
    , view
    )

import Browser exposing (Document)
import Element exposing (Length, alignLeft, centerX, centerY, fill, spacing, text, width, wrappedRow)
import Element.Font
import Element.Region as Element
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Treningsplan.Object
import Treningsplan.Object.Workout
import Treningsplan.Query
import Workout.Parser


type Msg
    = Fetched Result


type alias Model =
    { workout : Result
    }


type alias Workout =
    { id : String
    , name : String
    , description : Maybe String
    , purpose : Maybe String
    , distance : Int
    , recipe : Maybe String
    }


type alias Result =
    RemoteData (Graphql.Http.Error (Maybe Workout)) (Maybe Workout)


init =
    { workout = RemoteData.NotAsked }


workoutSelection : SelectionSet Workout Treningsplan.Object.Workout
workoutSelection =
    SelectionSet.map6 Workout
        Treningsplan.Object.Workout.id
        Treningsplan.Object.Workout.name
        Treningsplan.Object.Workout.description
        Treningsplan.Object.Workout.purpose
        Treningsplan.Object.Workout.distance
        Treningsplan.Object.Workout.recipe


fetch : String -> Cmd Msg
fetch id =
    Treningsplan.Query.workout (Treningsplan.Query.WorkoutRequiredArguments id) workoutSelection
        |> Graphql.Http.queryRequest "https://treningsplan-api.s33.no"
        |> Graphql.Http.send (RemoteData.fromResult >> Fetched)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetched workout ->
            ( { model | workout = workout }, Cmd.none )


view : Model -> Document Msg
view model =
    { title =
        case model.workout of
            RemoteData.Success data ->
                case data of
                    Just workout ->
                        workout.name

                    Nothing ->
                        "Could not find workout"

            RemoteData.Loading ->
                "Loading workout..."

            RemoteData.Failure e ->
                "Something went wrong :("

            RemoteData.NotAsked ->
                "Loading workout..."
    , body =
        [ Element.layout [] <|
            wrappedRow
                [ centerX, centerY ]
            <|
                [ case model.workout of
                    RemoteData.Success workout ->
                        case workout of
                            Just w ->
                                workoutView w

                            Nothing ->
                                text "The workout does not exist."

                    RemoteData.Loading ->
                        text "Loading workout..."

                    RemoteData.Failure e ->
                        text "Something went wrong :("

                    RemoteData.NotAsked ->
                        text "Loading workout..."
                ]
        ]
    }


workoutView : Workout -> Element.Element Msg
workoutView workout =
    Element.column
        [ spacing 20, width fill ]
        [ Element.el [ Element.heading 1, Element.Font.extraBold ] <| text <| workout.name ++ " (" ++ formatKm workout.distance ++ "km)"
        , Element.paragraph [ Element.Font.alignLeft ] [ text (Maybe.withDefault "" workout.description) ]
        , Element.paragraph [ Element.Font.alignLeft ] [ text (Maybe.withDefault "" workout.purpose) ]
        , Element.paragraph [ Element.Font.alignLeft ] [ text (Maybe.withDefault "" workout.recipe) ]
        , Element.paragraph [ Element.Font.alignLeft ] [ text (Workout.Parser.parseResultToString <| Workout.Parser.parse (Maybe.withDefault "" workout.recipe)) ]
        ]


formatKm : Int -> String
formatKm km =
    toFloat km / 1000 |> String.fromFloat
