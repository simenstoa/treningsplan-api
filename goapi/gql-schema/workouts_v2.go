package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/database"
	"goapi/gql-common"
)

var (
	partType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "WorkoutPart",
			Fields: graphql.Fields{
				"order": &graphql.Field{
					Type: graphql.NewNonNull(graphql.Int),
				},
				"distance": &graphql.Field{
					Type: graphql.NewNonNull(graphql.Int),
				},
				"metric": &graphql.Field{
					Type: graphql.NewNonNull(graphql.NewEnum(graphql.EnumConfig{
						Name: "MetricV2",
						Values: graphql.EnumValueConfigMap{
							"METER": &graphql.EnumValueConfig{
								Value: "meter",
							},
							"MINUTE": &graphql.EnumValueConfig{
								Value: "minute",
							},
						},
					})),
				},
				"intensity": &graphql.Field{
					Type: graphql.NewNonNull(intensityType),
				},
			}})
)

func workoutV2Fields() graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"name": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"description": &graphql.Field{
			Type: graphql.String,
		},
		"parts": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(partType))),
		},
	}
}

func workoutV2Type() *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "WorkoutV2",
			Fields: workoutV2Fields(),
		},
	)
}

func workoutV2sField(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(workoutType))),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return dbClient.GetWorkouts(p.Context)
		},
	}
}

func workoutV2Field(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: workoutType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return dbClient.GetWorkout(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:        graphql.NewNonNull(graphql.String),
				Description: "The id of the workout",
			},
		},
	}
}
