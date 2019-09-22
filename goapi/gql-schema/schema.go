package gqlschema

import (
	"github.com/graphql-go/graphql"
	gqlcommon "goapi/gql-common"
)

func InitSchema(intensity gqlcommon.Resolvable, workout gqlcommon.Resolvable, workoutBouts gqlcommon.Resolvable, bout gqlcommon.Resolvable) (graphql.Schema, error) {
	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": InitIntensityZones(intensity.GetAll()),
				"workouts":       InitWorkouts(workout.GetAll(), workoutBouts.GetByIds, bout.GetById),
				"workout":        InitWorkout(workout.Get(), workoutBouts.GetByIds, bout.GetById),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
