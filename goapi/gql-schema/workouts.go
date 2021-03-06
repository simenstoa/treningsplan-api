package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	workout_intensities "goapi/resolvables/workout-intensities"
	"goapi/resolvables/workouts"
)

func workoutFields(resolvableWorkoutIntensity workout_intensities.Resolvable) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"name": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"purpose": &graphql.Field{
			Type: graphql.String,
		},
		"description": &graphql.Field{
			Type: graphql.String,
		},
		"distance": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
		"intensity": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(workoutIntensityType()))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return resolvableWorkoutIntensity.GetByParentId(p.Context, p.Source.(workouts.Workout).Id)
			},
		},
	}
}

func workoutType(resolvableWorkoutIntensity workout_intensities.Resolvable) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Workout",
			Fields: workoutFields(resolvableWorkoutIntensity),
		},
	)
}

func workoutsField(resolvableWorkout workouts.Resolvable, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(workoutType))),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvableWorkout.GetAll(p.Context)
		},
	}
}

func workoutField(resolvableWorkout workouts.Resolvable, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: workoutType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvableWorkout.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:        graphql.NewNonNull(graphql.String),
				Description: "The id of the workout",
			},
		},
	}
}
