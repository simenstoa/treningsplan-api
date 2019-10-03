package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	"goapi/resolvables/days"
	"goapi/resolvables/plans"
	"goapi/resolvables/workouts"
)

func dayFields(workoutType *graphql.Object, resolvableWorkouts workouts.Resolvable) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.String,
		},
		"order": &graphql.Field{
			Type: graphql.Int,
		},
		"workouts": &graphql.Field{
			Type: graphql.NewList(workoutType),
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
			Type: graphql.Int,
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

func daysField(resolvableDay plans.Resolvable, dayType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type:    graphql.NewList(dayType),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvableDay.GetAll(p.Context)
		},
	}
}

func dayField(resolvablePlan plans.Resolvable, planType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: planType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvablePlan.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.NewNonNull(graphql.String),
				Description:  "The id of the day",
			},
		},
	}
}
