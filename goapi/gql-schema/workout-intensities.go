package gqlschema

import (
	"github.com/graphql-go/graphql"
)

func workoutIntensityFields() graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"distance": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
		// TODO: graphql.ID?
		"intensity": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		// TODO: enum?
		"metric": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewEnum(graphql.EnumConfig{
				Name: "Metric",
				Values: graphql.EnumValueConfigMap{
					"METER": &graphql.EnumValueConfig{
						Value: "Meter",
					},
					"MINUTE": &graphql.EnumValueConfig{
						Value: "Minute",
					},
				},
			})),
		},
		"name": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"description": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"coefficient": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Float),
		},
	}
}

func workoutIntensityType() *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "WorkoutIntensity",
			Fields: workoutIntensityFields(),
		},
	)
}
