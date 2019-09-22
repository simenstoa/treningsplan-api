package gqlschema

import "github.com/graphql-go/graphql"

var intensityZoneType = graphql.NewObject(
	graphql.ObjectConfig{
		Name: "IntensityZone",
		Fields: graphql.Fields{
			"id": &graphql.Field{
				Type: graphql.String,
			},
			"name": &graphql.Field{
				Type: graphql.String,
			},
			"intensityType": &graphql.Field{
				Type: graphql.String,
			},
			"description": &graphql.Field{
				Type: graphql.String,
			},
		},
	},
)

func InitIntensityZones(resolver graphql.FieldResolveFn) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewList(intensityZoneType),
		Resolve: resolver,
	}
}
