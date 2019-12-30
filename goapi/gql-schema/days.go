package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/resolvables/days"
	"goapi/resolvables/workouts"
)

func dayFields(workoutType *graphql.Object, resolvableWorkouts workouts.Resolvable) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"day": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
		"workouts": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(workoutType))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				ids :=  p.Source.(days.Day).Workouts
				ws, err := resolvableWorkouts.GetByIds(p.Context, ids)
				if err != nil {
					return nil, err
				}
				wsMap := make(map[string]workouts.Workout)
				for _, bt := range ws {
					wsMap[bt.Id] = bt
				}
				var allWs workouts.Workouts
				for _, id := range ids {
					allWs = append(allWs, wsMap[id])
				}
				return allWs, nil
			},
		},
		"distance": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
	}
}

func dayType(workoutType *graphql.Object, resolvableWorkouts workouts.Resolvable) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Day",
			Fields: dayFields(workoutType, resolvableWorkouts),
		},
	)
}
