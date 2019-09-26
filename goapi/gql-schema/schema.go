package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/bouts"
	"goapi/intensity-zones"
	"goapi/workouts"
	workoutbouts "goapi/workout-bouts"
)

func InitSchema(resolvableIntensityZones intensityzones.Resolvable, resolvableWorkout workouts.Resolvable, resolvableWorkoutBouts workoutbouts.Resolvable, resolvableBout bouts.Resolvable) (graphql.Schema, error) {
	boutType := boutType(resolvableIntensityZones)
	workoutType := workoutType(resolvableWorkoutBouts, resolvableBout, boutType)

	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": InitIntensityZones(resolvableIntensityZones),
				"workouts":       workoutsField(resolvableWorkout, workoutType),
				"workout":        workoutField(resolvableWorkout, workoutType),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
