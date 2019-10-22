-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Treningsplan.Object.Workout exposing (description, distance, id, name, purpose)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import Treningsplan.InputObject
import Treningsplan.Interface
import Treningsplan.Object
import Treningsplan.Scalar
import Treningsplan.ScalarCodecs
import Treningsplan.Union


{-| -}
description : SelectionSet (Maybe String) Treningsplan.Object.Workout
description =
    Object.selectionForField "(Maybe String)" "description" [] (Decode.string |> Decode.nullable)


{-| -}
distance : SelectionSet Int Treningsplan.Object.Workout
distance =
    Object.selectionForField "Int" "distance" [] Decode.int


{-| -}
id : SelectionSet String Treningsplan.Object.Workout
id =
    Object.selectionForField "String" "id" [] Decode.string


{-| -}
name : SelectionSet String Treningsplan.Object.Workout
name =
    Object.selectionForField "String" "name" [] Decode.string


{-| -}
purpose : SelectionSet (Maybe String) Treningsplan.Object.Workout
purpose =
    Object.selectionForField "(Maybe String)" "purpose" [] (Decode.string |> Decode.nullable)