package gqlschema

import (
	"context"
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/bout"
	gqlcommon "goapi/gql-common"
	"goapi/workout"
	workoutbouts "goapi/workout-bouts"
)

var boutType = graphql.NewObject(graphql.ObjectConfig{
	Name: "Bout",
	Fields: graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.String,
		},
		"order": &graphql.Field{
			Type: graphql.Int,
		},
		"name": &graphql.Field{
			Type: graphql.String,
		},
		"duration": &graphql.Field{
			Type: graphql.Int,
		},
		"length": &graphql.Field{
			Type: graphql.Int,
		},
		"type": &graphql.Field{
			Type: graphql.String,
		},
		"intensity": &graphql.Field{
			Type: graphql.NewList(graphql.String),
		},
	},
})

type boutGqlType struct {
	Id        string
	Order     int
	Name      string
	Duration  int
	Length    int
	Type      string
	Intensity []string
}

func workoutFields(getWorkoutBoutsByIds func(ctx context.Context, ids []string) (interface{}, error), getBout func(ctx context.Context, id string) (interface{}, error)) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.String,
		},
		"name": &graphql.Field{
			Type: graphql.String,
		},
		"purpose": &graphql.Field{
			Type: graphql.String,
		},
		"description": &graphql.Field{
			Type: graphql.String,
		},
		"bouts": &graphql.Field{
			Type: graphql.NewList(boutType),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				ids := p.Source.(workout.Workout).WorkoutBouts
				workoutBouts, err := getWorkoutBoutsByIds(p.Context, ids)
				if err != nil {
					return nil, err
				}
				var bouts []boutGqlType
				for _, workoutBout := range workoutBouts.(workoutbouts.Result) {
					boutIds := workoutBout.Bout
					if len(boutIds) != 1 {
						return nil, errors.New("invalid workout bouts")
					}
					b, err := getBout(p.Context, boutIds[0])
					if err != nil {
						return nil, err
					}
					bt := b.(bout.Bout)
					bouts = append(bouts, boutGqlType{
						Id:        bt.Id,
						Order:     workoutBout.Order,
						Name:      bt.Name,
						Length:    bt.Length,
						Duration:  bt.Duration,
						Type:      bt.Type,
						Intensity: bt.Intensity,
					})
				}
				return bouts, nil
			},
		},
	}
}

func workoutsType(getWorkoutBoutsForWorkout func(ctx context.Context, ids []string) (interface{}, error), getBout func(ctx context.Context, id string) (interface{}, error)) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Workouts",
			Fields: workoutFields(getWorkoutBoutsForWorkout, getBout),
		},
	)
}

func workoutType(getWorkoutBoutsForWorkout func(ctx context.Context, ids []string) (interface{}, error), getBout func(ctx context.Context, id string) (interface{}, error)) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Workout",
			Fields: workoutFields(getWorkoutBoutsForWorkout, getBout),
		},
	)
}

func InitWorkouts(getAll graphql.FieldResolveFn, getWorkoutBoutsForWorkout func(ctx context.Context, ids []string) (interface{}, error), getBout func(ctx context.Context, id string) (interface{}, error)) *graphql.Field {
	return &graphql.Field{
		Type:    graphql.NewList(workoutsType(getWorkoutBoutsForWorkout, getBout)),
		Resolve: getAll,
	}
}

func InitWorkout(get graphql.FieldResolveFn, getWorkoutBoutsForWorkout func(ctx context.Context, ids []string) (interface{}, error), getBout func(ctx context.Context, id string) (interface{}, error)) *graphql.Field {
	return &graphql.Field{
		Type: workoutType(getWorkoutBoutsForWorkout, getBout),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			if id == "" {
				return nil, errors.New("id not found")
			} else {
				return get(p)
			}
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.String,
				DefaultValue: "",
				Description:  "Id for the workout",
			},
		},
	}
}
